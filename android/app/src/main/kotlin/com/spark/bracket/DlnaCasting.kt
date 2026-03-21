package com.spark.bracket

import android.content.Context
import android.net.wifi.WifiManager
import android.os.SystemClock
import org.w3c.dom.Document
import org.w3c.dom.Element
import org.xml.sax.InputSource
import java.io.IOException
import java.io.StringReader
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.HttpURLConnection
import java.net.InetAddress
import java.net.SocketTimeoutException
import java.net.URL
import java.nio.charset.StandardCharsets
import java.util.Locale
import javax.xml.parsers.DocumentBuilderFactory

internal data class CastMediaRequest(
    val url: String,
    val title: String,
    val subtitle: String?,
    val positionSeconds: Int,
    val posterUrl: String?,
) {
    val isSupportedRemoteMedia: Boolean
        get() = url.startsWith("http://", ignoreCase = true) ||
            url.startsWith("https://", ignoreCase = true)

    companion object {
        fun fromArguments(arguments: Any?): CastMediaRequest? {
            val map = arguments as? Map<*, *> ?: return null
            val url = map["url"] as? String ?: return null
            val title = map["title"] as? String ?: "Bracket"
            val subtitle = map["subtitle"] as? String
            val positionSeconds = (map["positionSeconds"] as? Number)?.toInt() ?: 0
            val posterUrl = map["posterUrl"] as? String
            return CastMediaRequest(
                url = url,
                title = title,
                subtitle = subtitle,
                positionSeconds = positionSeconds.coerceAtLeast(0),
                posterUrl = posterUrl,
            )
        }
    }
}

internal data class DlnaDevice(
    val id: String,
    val friendlyName: String,
    val manufacturer: String?,
    val modelName: String?,
    val avTransportServiceType: String,
    val avTransportControlUrl: String,
)

internal class DlnaCastingClient(
    private val context: Context,
) {
    companion object {
        private const val multicastHost = "239.255.255.250"
        private const val multicastPort = 1900
        private const val mediaRendererSearchTarget =
            "urn:schemas-upnp-org:device:MediaRenderer:1"
        private const val rootDeviceSearchTarget = "upnp:rootdevice"
        private const val anyDeviceSearchTarget = "ssdp:all"
        private const val discoveryTimeoutMs = 3600
        private const val receiveTimeoutMs = 650
        private const val networkTimeoutMs = 3000
    }

    fun discoverDevices(): List<DlnaDevice> {
        val discoveredLocations = linkedSetOf<String>()
        val multicastLock = acquireMulticastLock()
        val socket = DatagramSocket().apply {
            soTimeout = receiveTimeoutMs
            broadcast = true
            reuseAddress = true
        }

        try {
            repeat(2) {
                sendDiscoveryRequest(socket, mediaRendererSearchTarget)
                sendDiscoveryRequest(socket, rootDeviceSearchTarget)
                sendDiscoveryRequest(socket, anyDeviceSearchTarget)
                Thread.sleep(120)
            }

            val deadline = SystemClock.elapsedRealtime() + discoveryTimeoutMs
            val buffer = ByteArray(8 * 1024)
            while (SystemClock.elapsedRealtime() < deadline) {
                val packet = DatagramPacket(buffer, buffer.size)
                try {
                    socket.receive(packet)
                } catch (_: SocketTimeoutException) {
                    continue
                }

                val response = String(packet.data, 0, packet.length, StandardCharsets.UTF_8)
                val headers = parseHeaders(response)
                val location = headers["location"] ?: continue
                discoveredLocations.add(location)
            }
        } finally {
            socket.close()
            releaseMulticastLock(multicastLock)
        }

        return discoveredLocations.mapNotNull { location ->
            runCatching { loadDeviceDescription(location) }.getOrNull()
        }
            .distinctBy { it.id }
            .sortedBy { it.friendlyName.lowercase(Locale.getDefault()) }
    }

    fun cast(
        device: DlnaDevice,
        mediaRequest: CastMediaRequest,
    ) {
        val metadata = buildDidlLiteMetadata(mediaRequest)

        runCatching {
            sendAvTransportAction(
                controlUrl = device.avTransportControlUrl,
                serviceType = device.avTransportServiceType,
                action = "Stop",
                parameters = mapOf(
                    "InstanceID" to "0",
                ),
            )
        }

        sendAvTransportAction(
            controlUrl = device.avTransportControlUrl,
            serviceType = device.avTransportServiceType,
            action = "SetAVTransportURI",
            parameters = mapOf(
                "InstanceID" to "0",
                "CurrentURI" to mediaRequest.url,
                "CurrentURIMetaData" to metadata,
            ),
        )

        sendAvTransportAction(
            controlUrl = device.avTransportControlUrl,
            serviceType = device.avTransportServiceType,
            action = "Play",
            parameters = mapOf(
                "InstanceID" to "0",
                "Speed" to "1",
            ),
        )

        if (mediaRequest.positionSeconds > 0) {
            Thread.sleep(450)
            runCatching {
                sendAvTransportAction(
                    controlUrl = device.avTransportControlUrl,
                    serviceType = device.avTransportServiceType,
                    action = "Seek",
                    parameters = mapOf(
                        "InstanceID" to "0",
                        "Unit" to "REL_TIME",
                        "Target" to formatDlnaTime(mediaRequest.positionSeconds),
                    ),
                )
                sendAvTransportAction(
                    controlUrl = device.avTransportControlUrl,
                    serviceType = device.avTransportServiceType,
                    action = "Play",
                    parameters = mapOf(
                        "InstanceID" to "0",
                        "Speed" to "1",
                    ),
                )
            }
        }
    }

    private fun sendDiscoveryRequest(
        socket: DatagramSocket,
        searchTarget: String,
    ) {
        val request = buildString {
            append("M-SEARCH * HTTP/1.1\r\n")
            append("HOST: $multicastHost:$multicastPort\r\n")
            append("MAN: \"ssdp:discover\"\r\n")
            append("MX: 2\r\n")
            append("ST: $searchTarget\r\n")
            append("\r\n")
        }
        val bytes = request.toByteArray(StandardCharsets.UTF_8)
        val packet = DatagramPacket(
            bytes,
            bytes.size,
            InetAddress.getByName(multicastHost),
            multicastPort,
        )
        socket.send(packet)
    }

    private fun parseHeaders(response: String): Map<String, String> {
        val headers = linkedMapOf<String, String>()
        response.lineSequence()
            .drop(1)
            .map { it.trim() }
            .filter { it.contains(':') }
            .forEach { line ->
                val index = line.indexOf(':')
                val name = line.substring(0, index).trim().lowercase(Locale.US)
                val value = line.substring(index + 1).trim()
                headers[name] = value
            }
        return headers
    }

    private fun loadDeviceDescription(location: String): DlnaDevice? {
        val xml = openTextUrl(location)
        val document = parseXml(xml) ?: return null
        val deviceElement = document.getElementsByTagName("device")
            .item(0) as? Element ?: return null

        val transportService = findAvTransportService(deviceElement, location) ?: return null
        val friendlyName = findFirstText(deviceElement, "friendlyName")
            ?.takeIf { it.isNotBlank() } ?: "DLNA 设备"
        val manufacturer = findFirstText(deviceElement, "manufacturer")
        val modelName = findFirstText(deviceElement, "modelName")
        val deviceId = findFirstText(deviceElement, "UDN")
            ?.takeIf { it.isNotBlank() } ?: transportService.controlUrl

        return DlnaDevice(
            id = deviceId,
            friendlyName = friendlyName,
            manufacturer = manufacturer,
            modelName = modelName,
            avTransportServiceType = transportService.serviceType,
            avTransportControlUrl = transportService.controlUrl,
        )
    }

    private fun findAvTransportService(
        deviceElement: Element,
        baseLocation: String,
    ): AvTransportService? {
        val serviceNodes = deviceElement.getElementsByTagName("service")
        for (index in 0 until serviceNodes.length) {
            val serviceElement = serviceNodes.item(index) as? Element ?: continue
            val serviceType = findFirstText(serviceElement, "serviceType") ?: continue
            if (!serviceType.contains("AVTransport", ignoreCase = true)) {
                continue
            }

            val controlUrl = findFirstText(serviceElement, "controlURL") ?: continue
            return AvTransportService(
                serviceType = serviceType,
                controlUrl = resolveUrl(baseLocation, controlUrl),
            )
        }
        return null
    }

    private fun resolveUrl(
        baseLocation: String,
        url: String,
    ): String {
        if (url.startsWith("http://", ignoreCase = true) ||
            url.startsWith("https://", ignoreCase = true)
        ) {
            return url
        }

        val baseUrl = URL(baseLocation)
        return URL(baseUrl, url).toString()
    }

    private fun buildDidlLiteMetadata(mediaRequest: CastMediaRequest): String {
        val artworkTag = mediaRequest.posterUrl
            ?.takeIf {
                it.startsWith("http://", ignoreCase = true) ||
                    it.startsWith("https://", ignoreCase = true)
            }
            ?.let { "<upnp:albumArtURI>${escapeXml(it)}</upnp:albumArtURI>" }
            .orEmpty()

        val subtitleTag = mediaRequest.subtitle
            ?.takeIf { it.isNotBlank() }
            ?.let { "<dc:description>${escapeXml(it)}</dc:description>" }
            .orEmpty()

        return """
            <DIDL-Lite
              xmlns="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/"
              xmlns:dc="http://purl.org/dc/elements/1.1/"
              xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/">
              <item id="0" parentID="-1" restricted="0">
                <dc:title>${escapeXml(mediaRequest.title)}</dc:title>
                $subtitleTag
                <upnp:class>object.item.videoItem</upnp:class>
                $artworkTag
                <res protocolInfo="http-get:*:*:*">${escapeXml(mediaRequest.url)}</res>
              </item>
            </DIDL-Lite>
        """.trimIndent()
    }

    private fun sendAvTransportAction(
        controlUrl: String,
        serviceType: String,
        action: String,
        parameters: Map<String, String>,
    ) {
        val payload = buildString {
            append("""<?xml version="1.0" encoding="utf-8"?>""")
            append(
                """<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" """
                    + """s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">""",
            )
            append("<s:Body>")
            append("""<u:$action xmlns:u="$serviceType">""")
            parameters.forEach { (key, value) ->
                append("<$key>${escapeXml(value)}</$key>")
            }
            append("</u:$action>")
            append("</s:Body></s:Envelope>")
        }

        val connection = (URL(controlUrl).openConnection() as HttpURLConnection).apply {
            requestMethod = "POST"
            doOutput = true
            connectTimeout = networkTimeoutMs
            readTimeout = networkTimeoutMs
            useCaches = false
            setRequestProperty("Content-Type", "text/xml; charset=\"utf-8\"")
            setRequestProperty(
                "SOAPACTION",
                "\"$serviceType#$action\"",
            )
        }

        connection.outputStream.use { stream ->
            stream.write(payload.toByteArray(StandardCharsets.UTF_8))
        }

        val responseCode = connection.responseCode
        if (responseCode !in 200..299) {
            val responseMessage = readConnectionBody(connection)
            connection.disconnect()
            throw IOException(
                "设备拒绝了投屏请求（$responseCode）"
                    + responseMessage?.let { "：$it" }.orEmpty(),
            )
        }

        connection.inputStream.close()
        connection.disconnect()
    }

    private fun openTextUrl(url: String): String {
        val connection = (URL(url).openConnection() as HttpURLConnection).apply {
            connectTimeout = networkTimeoutMs
            readTimeout = networkTimeoutMs
            useCaches = false
        }

        return try {
            connection.inputStream.bufferedReader(StandardCharsets.UTF_8).use { it.readText() }
        } finally {
            connection.disconnect()
        }
    }

    private fun parseXml(xml: String): Document? {
        return runCatching {
            val factory = DocumentBuilderFactory.newInstance().apply {
                isNamespaceAware = false
                trySetFeature("http://apache.org/xml/features/disallow-doctype-decl", true)
                trySetFeature("http://xml.org/sax/features/external-general-entities", false)
                trySetFeature("http://xml.org/sax/features/external-parameter-entities", false)
            }
            val builder = factory.newDocumentBuilder()
            builder.parse(InputSource(StringReader(xml)))
        }.getOrNull()
    }

    private fun DocumentBuilderFactory.trySetFeature(
        name: String,
        enabled: Boolean,
    ) {
        runCatching { setFeature(name, enabled) }
    }

    private fun findFirstText(
        element: Element,
        tagName: String,
    ): String? {
        val node = element.getElementsByTagName(tagName).item(0) ?: return null
        return node.textContent?.trim()
    }

    private fun escapeXml(value: String): String {
        return value
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&apos;")
    }

    private fun readConnectionBody(connection: HttpURLConnection): String? {
        val stream = connection.errorStream ?: connection.inputStream ?: return null
        return stream.bufferedReader(StandardCharsets.UTF_8).use { it.readText().trim() }
            .takeIf { it.isNotEmpty() }
    }

    private fun formatDlnaTime(totalSeconds: Int): String {
        val safeSeconds = totalSeconds.coerceAtLeast(0)
        val hours = safeSeconds / 3600
        val minutes = (safeSeconds % 3600) / 60
        val seconds = safeSeconds % 60
        return String.format(Locale.US, "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private fun acquireMulticastLock(): WifiManager.MulticastLock? {
        val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE)
            as? WifiManager ?: return null
        return runCatching {
            wifiManager.createMulticastLock("bracket-dlna-discovery").apply {
                setReferenceCounted(false)
                acquire()
            }
        }.getOrNull()
    }

    private fun releaseMulticastLock(lock: WifiManager.MulticastLock?) {
        runCatching {
            if (lock?.isHeld == true) {
                lock.release()
            }
        }
    }

    private data class AvTransportService(
        val serviceType: String,
        val controlUrl: String,
    )
}
