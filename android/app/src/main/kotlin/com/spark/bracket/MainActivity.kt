package com.spark.bracket

import android.os.Bundle
import android.util.TypedValue
import android.view.ContextThemeWrapper
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    companion object {
        private const val MEDIA_ROUTE_CHANNEL = "bracket/media_route_picker"
    }

    private val castExecutor: ExecutorService = Executors.newSingleThreadExecutor()
    private lateinit var dlnaCastingClient: DlnaCastingClient

    private var progressDialog: AlertDialog? = null
    private var devicePickerDialog: AlertDialog? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        dlnaCastingClient = DlnaCastingClient(applicationContext)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            MEDIA_ROUTE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "presentDevicePicker" -> {
                    val mediaRequest = CastMediaRequest.fromArguments(call.arguments)
                    if (mediaRequest == null) {
                        result.error("invalid_args", "投屏参数无效", null)
                        return@setMethodCallHandler
                    }
                    presentDevicePicker(mediaRequest, result)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        dismissDialogs()
        castExecutor.shutdownNow()
        super.onDestroy()
    }

    private fun presentDevicePicker(
        mediaRequest: CastMediaRequest,
        result: MethodChannel.Result,
    ) {
        if (!mediaRequest.isSupportedRemoteMedia) {
            result.error("unsupported_media", "当前视频暂不支持投屏", null)
            return
        }

        showProgressDialog("正在搜索投屏设备…")

        castExecutor.execute {
            runCatching {
                dlnaCastingClient.discoverDevices()
            }.onSuccess { devices ->
                runOnUiThread {
                    dismissProgressDialog()
                    if (devices.isEmpty()) {
                        result.error(
                            "no_device_found",
                            "未发现可投屏设备，请确认电视或盒子与手机在同一局域网。",
                            null,
                        )
                        return@runOnUiThread
                    }
                    showDevicePicker(devices, mediaRequest, result)
                }
            }.onFailure { error ->
                runOnUiThread {
                    dismissProgressDialog()
                    result.error(
                        "discovery_failed",
                        error.message ?: "搜索投屏设备失败",
                        null,
                    )
                }
            }
        }
    }

    private fun showDevicePicker(
        devices: List<DlnaDevice>,
        mediaRequest: CastMediaRequest,
        result: MethodChannel.Result,
    ) {
        devicePickerDialog?.dismiss()

        val labels = devices.map { device ->
            listOfNotNull(
                device.friendlyName.takeIf { it.isNotBlank() },
                device.manufacturer?.takeIf { it.isNotBlank() },
                device.modelName?.takeIf { it.isNotBlank() },
            ).joinToString(" · ")
        }.toTypedArray()

        var handled = false
        val dialog = AlertDialog.Builder(
            ContextThemeWrapper(this, androidx.appcompat.R.style.Theme_AppCompat_Dialog),
        ).setTitle("选择投屏设备")
            .setItems(labels) { picker, which ->
                if (handled) {
                    picker.dismiss()
                    return@setItems
                }
                handled = true
                picker.dismiss()
                castToDevice(devices[which], mediaRequest, result)
            }
            .setNegativeButton("取消") { picker, _ ->
                picker.dismiss()
                if (!handled) {
                    handled = true
                    result.error("cancelled", "已取消投屏", null)
                }
            }
            .setOnCancelListener {
                if (!handled) {
                    handled = true
                    result.error("cancelled", "已取消投屏", null)
                }
            }
            .create()

        devicePickerDialog = dialog
        dialog.show()
    }

    private fun castToDevice(
        device: DlnaDevice,
        mediaRequest: CastMediaRequest,
        result: MethodChannel.Result,
    ) {
        showProgressDialog("正在连接 ${device.friendlyName}…")

        castExecutor.execute {
            runCatching {
                dlnaCastingClient.cast(device, mediaRequest)
            }.onSuccess {
                runOnUiThread {
                    dismissProgressDialog()
                    result.success(
                        mapOf(
                            "name" to device.friendlyName,
                            "type" to "dlna",
                        ),
                    )
                }
            }.onFailure { error ->
                runOnUiThread {
                    dismissProgressDialog()
                    result.error(
                        "cast_failed",
                        error.message ?: "投屏失败，请稍后重试。",
                        null,
                    )
                }
            }
        }
    }

    private fun showProgressDialog(message: String) {
        dismissProgressDialog()

        val container = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            val padding = 20.dp
            setPadding(padding, padding, padding, padding)
            gravity = android.view.Gravity.CENTER_VERTICAL
            addView(ProgressBar(context))
            addView(
                TextView(context).apply {
                    text = message
                    setPadding(16.dp, 0, 0, 0)
                    setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f)
                },
            )
        }

        progressDialog = AlertDialog.Builder(
            ContextThemeWrapper(this, androidx.appcompat.R.style.Theme_AppCompat_Dialog),
        ).setView(container)
            .setCancelable(false)
            .create()
            .also { it.show() }
    }

    private fun dismissProgressDialog() {
        progressDialog?.dismiss()
        progressDialog = null
    }

    private fun dismissDialogs() {
        dismissProgressDialog()
        devicePickerDialog?.dismiss()
        devicePickerDialog = null
    }

    private val Int.dp: Int
        get() = TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            toFloat(),
            resources.displayMetrics,
        ).toInt()
}
