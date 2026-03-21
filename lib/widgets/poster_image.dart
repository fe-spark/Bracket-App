import 'package:flutter/foundation.dart';
import '/plugins.dart';

class PosterImage extends StatefulWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const PosterImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  State<PosterImage> createState() => _PosterImageState();
}

class _PosterImageState extends State<PosterImage> {
  static final Map<String, Future<Uint8List?>> _requestCache = {};

  late String _sanitizedUrl;
  late Future<Uint8List?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _configureImageFuture();
  }

  @override
  void didUpdateWidget(covariant PosterImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _configureImageFuture();
    }
  }

  void _configureImageFuture() {
    _sanitizedUrl = sanitizeImageUrl(widget.imageUrl);
    _imageFuture = _resolveImageFuture(_sanitizedUrl);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        final bytes = snapshot.data;
        if (bytes == null || bytes.isEmpty) {
          return _buildFallback();
        }

        return Image.memory(
          bytes,
          fit: widget.fit,
          width: widget.width,
          height: widget.height,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      },
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.2,
        color: Colors.white.withValues(alpha: 0.9),
      ),
    );
  }

  Widget _buildFallback() {
    return Image.asset(
      'assets/images/logo.png',
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
    );
  }

  Future<Uint8List?> _resolveImageFuture(String url) {
    if (!_isSupportedNetworkImageUrl(url)) {
      return Future.value(null);
    }

    return _requestCache.putIfAbsent(url, () => _fetchImageBytes(url));
  }

  Future<Uint8List?> _fetchImageBytes(String url) async {
    HttpClient? client;
    try {
      client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final bytes = await consolidateHttpClientResponseBytes(response);
      if (bytes.isEmpty) {
        return null;
      }
      return bytes;
    } catch (_) {
      return null;
    } finally {
      client?.close(force: true);
    }
  }
}

bool _isSupportedNetworkImageUrl(String url) {
  if (url.isEmpty) {
    return false;
  }

  final uri = Uri.tryParse(url);
  if (uri == null) {
    return false;
  }

  return (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
}
