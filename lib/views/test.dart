import 'package:video_player/video_player.dart';

import '/plugins.dart';

class AutoFullscreenOrientationPage extends StatefulWidget {
  const AutoFullscreenOrientationPage({super.key});

  @override
  State<AutoFullscreenOrientationPage> createState() =>
      _AutoFullscreenOrientationPageState();
}

class _AutoFullscreenOrientationPageState
    extends State<AutoFullscreenOrientationPage> {
  VideoPlayerController? _controller;
  String _currentUrl =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4';

  @override
  void initState() {
    super.initState();
    _open(_currentUrl);
  }

  @override
  void dispose() {
    final controller = _controller;
    if (controller != null) {
      unawaited(controller.dispose());
    }
    super.dispose();
  }

  Future<void> _open(String url) async {
    final previous = _controller;
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize();
    await controller.play();
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() {
      _currentUrl = url;
      _controller = controller;
    });
    if (previous != null) {
      unawaited(previous.dispose());
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final initialized = controller?.value.isInitialized ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto full screen orientation'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'This page now uses video_player. Current source: $_currentUrl',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio:
                initialized ? controller!.value.aspectRatio : 16 / 9,
            child:
                initialized
                    ? VideoPlayer(controller!)
                    : const ColoredBox(color: Colors.black),
          ),
          ElevatedButton(
            onPressed: () {
              _open(
                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
              );
            },
            child: const Text('Play horizontal video'),
          ),
          ElevatedButton(
            onPressed: () {
              _open(
                'http://www.exit109.com/~dnn/clips/RW20seconds_1.mp4',
              );
            },
            child: const Text('Play vertical video'),
          ),
        ],
      ),
    );
  }
}
