import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '/model/film_play_info/detail.dart';
import '/plugins.dart';

import 'skin.dart';

@immutable
class _PlayerSurfaceState {
  final bool opening;
  final String? errorMessage;
  final bool playRequested;
  final VideoPlayerRuntimeState runtimeState;

  const _PlayerSurfaceState({
    required this.opening,
    required this.errorMessage,
    required this.playRequested,
    required this.runtimeState,
  });

  static const initial = _PlayerSurfaceState(
    opening: true,
    errorMessage: null,
    playRequested: true,
    runtimeState: VideoPlayerRuntimeState.empty,
  );

  _PlayerSurfaceState copyWith({
    bool? opening,
    String? errorMessage,
    bool clearError = false,
    bool? playRequested,
    VideoPlayerRuntimeState? runtimeState,
  }) {
    return _PlayerSurfaceState(
      opening: opening ?? this.opening,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      playRequested: playRequested ?? this.playRequested,
      runtimeState: runtimeState ?? this.runtimeState,
    );
  }
}

class Player extends StatefulWidget {
  final double aspectRatio;
  final double fullScreenAspectRatio;
  final Detail? detail;

  const Player({
    super.key,
    required this.aspectRatio,
    this.detail,
    required this.fullScreenAspectRatio,
  });

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  static const MethodChannel _audioSessionChannel =
      MethodChannel('bracket/audio_session');
  static const MethodChannel _orientationChannel =
      MethodChannel('bracket/orientation');

  final Throttler _throttler = Throttler(milliseconds: 5000);
  final ValueNotifier<int> _fullscreenRevision = ValueNotifier<int>(0);

  VideoPlayerController? _controller;
  PlayVideoIdsStore? _playVideoIdsStore;
  HistoryStore? _historyStore;
  VideoSourceStore? _videoSourceStore;
  _PlayerSurfaceState _surfaceState = _PlayerSurfaceState.initial;
  DateTime? _lastProgressAt;
  Duration _lastProgressPosition = Duration.zero;
  double _lastAudibleVolume = 100.0;

  bool _presentingFullscreen = false;
  bool _fullscreenOrientationLocked = false;
  bool _advancingToNextEpisode = false;
  bool _lastPlaying = false;
  bool _lastCompleted = false;
  int _openRequestId = 0;

  bool get _isPlaybackReady =>
      _controller?.value.isInitialized == true &&
      !_surfaceState.opening &&
      _surfaceState.errorMessage == null;

  bool get _hasRecentPlaybackProgress {
    final lastProgressAt = _lastProgressAt;
    if (lastProgressAt == null) return false;
    return DateTime.now().difference(lastProgressAt) <=
        const Duration(milliseconds: 900);
  }

  double get _resolvedVideoAspectRatio {
    final controller = _controller;
    final value = controller?.value;
    if (value != null &&
        value.isInitialized &&
        value.aspectRatio.isFinite &&
        value.aspectRatio > 0) {
      return value.aspectRatio;
    }
    return widget.aspectRatio;
  }

  bool get _isPortraitVideo => _resolvedVideoAspectRatio < 1.0;

  @override
  void initState() {
    super.initState();
    _playVideoIdsStore = context.read<PlayVideoIdsStore>();
    _historyStore = context.read<HistoryStore>();
    _videoSourceStore = context.read<VideoSourceStore>();
    _playVideoIdsStore?.addListener(_handleVideoInfoChanged);
    _openCurrentMedia();
  }

  @override
  void didChangeDependencies() {
    _playVideoIdsStore = context.read<PlayVideoIdsStore>();
    _historyStore = context.read<HistoryStore>();
    _videoSourceStore = context.read<VideoSourceStore>();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant Player oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detail?.id != widget.detail?.id) {
      _openCurrentMedia();
    }
  }

  @override
  void dispose() {
    _setHistory();
    _throttler.cancel();
    _fullscreenRevision.dispose();
    _playVideoIdsStore?.removeListener(_handleVideoInfoChanged);
    final controller = _controller;
    if (controller != null) {
      controller.removeListener(_handleControllerValueChanged);
      unawaited(controller.dispose());
    }
    WakelockPlus.disable();
    super.dispose();
  }

  void _notifyFullscreenRebuild() {
    if (_presentingFullscreen) {
      _fullscreenRevision.value += 1;
    }
  }

  void _setPlayerState(VoidCallback update) {
    if (!mounted) {
      update();
      _notifyFullscreenRebuild();
      return;
    }
    setState(update);
    _notifyFullscreenRebuild();
  }

  void _updateSurfaceState(_PlayerSurfaceState next) {
    if (_surfaceState == next) return;
    _setPlayerState(() {
      _surfaceState = next;
    });
  }

  void _handleVideoInfoChanged() {
    if (!mounted) return;
    _openCurrentMedia();
  }

  void _setPlayRequested(bool value) {
    if (_surfaceState.playRequested == value) return;
    _updateSurfaceState(_surfaceState.copyWith(playRequested: value));
  }

  Future<void> _openCurrentMedia() async {
    final media = _resolveCurrentMedia();
    if (media == null) return;

    final previous = _controller;
    previous?.removeListener(_handleControllerValueChanged);

    final headers = _buildVideoRequestHeaders();
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(media.url),
      httpHeaders: headers,
    );
    controller.addListener(_handleControllerValueChanged);

    final requestId = ++_openRequestId;
    _controller = controller;
    _advancingToNextEpisode = false;
    _lastPlaying = false;
    _lastCompleted = false;
    _lastProgressAt = null;
    _lastProgressPosition = Duration.zero;
    _lastAudibleVolume = 100.0;
    _updateSurfaceState(
      _surfaceState.copyWith(
        opening: true,
        clearError: true,
        playRequested: true,
        runtimeState: VideoPlayerRuntimeState.empty,
      ),
    );

    if (previous != null) {
      unawaited(previous.dispose());
    }

    try {
      await _ensurePlaybackAudioSession();
      await controller.initialize();
      if (!mounted || requestId != _openRequestId) {
        controller.removeListener(_handleControllerValueChanged);
        await controller.dispose();
        return;
      }

      if (media.startAt > 0) {
        final target = _clampDuration(
          Duration(seconds: media.startAt),
          Duration.zero,
          controller.value.duration,
        );
        if (target > Duration.zero) {
          await controller.seekTo(target);
        }
      }

      await controller.play();
      if (!mounted || requestId != _openRequestId) return;

      _updateSurfaceState(_surfaceState.copyWith(opening: false));
      _handleControllerValueChanged();
    } catch (error) {
      if (!mounted || requestId != _openRequestId) return;
      _setFatalError('$error');
    }
  }

  Future<void> _ensurePlaybackAudioSession() async {
    if (!Platform.isIOS) return;
    try {
      final info = await _audioSessionChannel.invokeMapMethod<String, dynamic>(
        'ensurePlaybackSession',
      );
      if (info != null) {
        debugPrint('AVAudioSession ready: $info');
      }
    } catch (error) {
      debugPrint('Failed to ensure AVAudioSession: $error');
    }
  }

  Future<void> _syncWakelock(bool playing) async {
    if (playing) {
      final enabled = await WakelockPlus.enabled;
      if (!enabled) {
        await WakelockPlus.enable();
      }
    } else {
      await WakelockPlus.disable();
    }
  }

  void _handleControllerValueChanged() {
    final controller = _controller;
    if (controller == null) return;

    final value = controller.value;
    final playing = value.isPlaying;
    final completed = value.isCompleted;
    final position = value.position;
    if (position != _lastProgressPosition) {
      _lastProgressPosition = position;
      _lastProgressAt = DateTime.now();
    }

    if (value.hasError) {
      _setFatalError(value.errorDescription ?? '播放失败');
      return;
    }

    if (playing) {
      _throttler.run(_setHistory);
    }
    if (!playing && _lastPlaying) {
      _setHistory();
    }
    if (completed && !_lastCompleted) {
      if (!_advanceToNextEpisodeInCurrentSource()) {
        _setHistory();
      }
    }

    _lastPlaying = playing;
    _lastCompleted = completed;
    final volume = value.volume * 100;
    if (volume > 0) {
      _lastAudibleVolume = volume;
    }
    final bufferedPosition = _bufferedPosition(value.buffered);
    final hasBufferedHeadroom =
        bufferedPosition - position > const Duration(milliseconds: 600);
    final stalledPlayback =
        _surfaceState.playRequested &&
        !completed &&
        !value.hasError &&
        value.duration > Duration.zero &&
        !value.isBuffering &&
        !hasBufferedHeadroom &&
        !_hasRecentPlaybackProgress;
    final nextPlayRequested =
        completed ? false : (playing ? true : _surfaceState.playRequested);
    final nextRuntimeState = VideoPlayerRuntimeState(
      playing: playing,
      completed: completed,
      buffering: value.isBuffering,
      stalledPlayback: stalledPlayback,
      hasRecentProgress: _hasRecentPlaybackProgress,
      position: position,
      duration: value.duration,
      buffer: bufferedPosition,
      volume: volume,
      playbackSpeed: value.playbackSpeed,
      lastAudibleVolume: _lastAudibleVolume,
    );
    final nextSurfaceState = _surfaceState.copyWith(
      playRequested: nextPlayRequested,
      runtimeState: nextRuntimeState,
    );
    final shouldRebuild = _surfaceState != nextSurfaceState;
    if (shouldRebuild) {
      _updateSurfaceState(nextSurfaceState);
    }
    unawaited(_syncWakelock(playing));

    if (_surfaceState.opening && value.isInitialized) {
      _updateSurfaceState(_surfaceState.copyWith(opening: false));
      return;
    }

    if (!shouldRebuild) {
      _notifyFullscreenRebuild();
    }
  }

  void _setFatalError(String message) {
    _updateSurfaceState(
      _surfaceState.copyWith(
        opening: false,
        errorMessage: message,
        playRequested: false,
        runtimeState: VideoPlayerRuntimeState(
          playing: false,
          completed: false,
          buffering: false,
          stalledPlayback: false,
          hasRecentProgress: false,
          position: _surfaceState.runtimeState.position,
          duration: _surfaceState.runtimeState.duration,
          buffer: _surfaceState.runtimeState.buffer,
          volume: _surfaceState.runtimeState.volume,
          playbackSpeed: _surfaceState.runtimeState.playbackSpeed,
          lastAudibleVolume: _surfaceState.runtimeState.lastAudibleVolume,
        ),
      ),
    );
  }

  Future<void> _enterFullscreen() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await Future.wait([
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.immersiveSticky,
            overlays: [],
          ),
          _applyFullscreenOrientations(),
        ]);
      }
    } catch (error) {
      debugPrint('Failed to enter fullscreen: $error');
    }
  }

  Future<void> _exitFullscreen() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await Future.wait([
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: SystemUiOverlay.values,
          ),
          SystemChrome.setPreferredOrientations(const []),
        ]);
      }
    } catch (error) {
      debugPrint('Failed to exit fullscreen: $error');
    }
  }

  Future<void> _showFullscreen() async {
    if (_presentingFullscreen) return;
    _setPlayerState(() {
      _presentingFullscreen = true;
      _fullscreenOrientationLocked = false;
    });
    await _enterFullscreen();
    if (!mounted) return;

    try {
      await Navigator.of(context).push(
        PageRouteBuilder<void>(
          opaque: true,
          pageBuilder: (routeContext, _, __) {
            return ValueListenableBuilder<int>(
              valueListenable: _fullscreenRevision,
              builder: (context, _, __) {
                return Scaffold(
                  backgroundColor: Colors.black,
                  body: _buildViewport(
                    isFullscreen: true,
                    onToggleFullscreen: () {
                      Navigator.of(routeContext).maybePop();
                    },
                  ),
                );
              },
            );
          },
        ),
      );
    } finally {
      _setPlayerState(() {
        _presentingFullscreen = false;
        _fullscreenOrientationLocked = false;
      });
      await _exitFullscreen();
    }
  }

  List<DeviceOrientation> get _preferredFullscreenOrientations =>
      _isPortraitVideo
          ? const [
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]
          : const [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ];

  Future<DeviceOrientation?> _readCurrentDeviceOrientation() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return null;
    }
    try {
      final value = await _orientationChannel.invokeMethod<String>(
        'getCurrentDeviceOrientation',
      );
      switch (value) {
        case 'portraitUp':
          return DeviceOrientation.portraitUp;
        case 'portraitDown':
          return DeviceOrientation.portraitDown;
        case 'landscapeLeft':
          return DeviceOrientation.landscapeLeft;
        case 'landscapeRight':
          return DeviceOrientation.landscapeRight;
      }
    } catch (error) {
      debugPrint('Failed to read current device orientation: $error');
    }
    return null;
  }

  Future<void> _applyFullscreenOrientations() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    if (_fullscreenOrientationLocked) {
      final current =
          await _readCurrentDeviceOrientation() ??
          _preferredFullscreenOrientations.first;
      await SystemChrome.setPreferredOrientations([current]);
      return;
    }
    await SystemChrome.setPreferredOrientations(_preferredFullscreenOrientations);
  }

  Future<void> _toggleFullscreenOrientationLock() async {
    if (!_presentingFullscreen) return;
    _setPlayerState(() {
      _fullscreenOrientationLocked = !_fullscreenOrientationLocked;
    });
    await _applyFullscreenOrientations();
  }

  _CurrentMedia? _resolveCurrentMedia() {
    final detail = widget.detail;
    final list = detail?.list;
    if (detail == null || list == null || list.isEmpty) return null;

    final originIndex =
        (_playVideoIdsStore?.originIndex ?? 0).clamp(0, list.length - 1);
    final linkList = list[originIndex].linkList;
    if (linkList == null || linkList.isEmpty) return null;

    final teleplayIndex =
        (_playVideoIdsStore?.teleplayIndex ?? 0).clamp(0, linkList.length - 1);
    final url = linkList[teleplayIndex].link;
    if (url == null || url.isEmpty) return null;

    return _CurrentMedia(
      originIndex: originIndex,
      teleplayIndex: teleplayIndex,
      startAt: _playVideoIdsStore?.startAt ?? 0,
      url: url,
    );
  }

  Map<String, String> _buildVideoRequestHeaders() {
    if (!Platform.isIOS) {
      return const <String, String>{};
    }

    final headers = <String, String>{
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1',
    };

    final source = _videoSourceStore?.data?.actived;
    if (source != null && source.isNotEmpty) {
      headers['Referer'] = source;
      final sourceUri = Uri.tryParse(source);
      if (sourceUri != null && sourceUri.hasScheme && sourceUri.host.isNotEmpty) {
        headers['Origin'] = '${sourceUri.scheme}://${sourceUri.host}';
      }
    }
    return headers;
  }

  void _prev() {
    final originIndex = _playVideoIdsStore?.originIndex;
    final teleplayIndex = _playVideoIdsStore?.teleplayIndex;
    if (teleplayIndex == null || teleplayIndex <= 0) return;

    _playVideoIdsStore?.setVideoInfo(
      originIndex,
      teleplayIndex: teleplayIndex - 1,
      startAt: 0,
    );
  }

  void _next() {
    _advanceToNextEpisodeInCurrentSource();
  }

  bool _advanceToNextEpisodeInCurrentSource() {
    final detail = widget.detail;
    final list = detail?.list;
    if (list == null || list.isEmpty || _advancingToNextEpisode) return false;

    final originIndex =
        (_playVideoIdsStore?.originIndex ?? 0).clamp(0, list.length - 1);
    final linkList = list[originIndex].linkList;
    final teleplayIndex = _playVideoIdsStore?.teleplayIndex;

    if (teleplayIndex == null ||
        linkList == null ||
        teleplayIndex >= linkList.length - 1) {
      return false;
    }

    _advancingToNextEpisode = true;
    _setHistory();
    _playVideoIdsStore?.setVideoInfo(
      originIndex,
      teleplayIndex: teleplayIndex + 1,
      startAt: 0,
    );
    return true;
  }

  Future<void> _retry() async {
    await _openCurrentMedia();
  }

  void _setHistory() {
    final detail = widget.detail;
    final list = detail?.list;
    final controller = _controller;
    if (detail == null || list == null || list.isEmpty || controller == null) {
      return;
    }

    final originIndex =
        (_playVideoIdsStore?.originIndex ?? 0).clamp(0, list.length - 1);
    final teleplayIndex = _playVideoIdsStore?.teleplayIndex ?? 0;
    final position = controller.value.position.inSeconds;

    _historyStore?.addHistory({
      'id': detail.id,
      'name': detail.name,
      'timeStamp': DateTime.now().microsecondsSinceEpoch,
      'picture': detail.picture,
      'originId': list[originIndex].id,
      'teleplayIndex': teleplayIndex,
      'startAt': position,
    });
  }

  Widget _buildVideoContent({
    required VideoPlayerController controller,
    required double fallbackAspectRatio,
  }) {
    final value = controller.value;
    final aspectRatio =
        value.isInitialized &&
                value.aspectRatio.isFinite &&
                value.aspectRatio > 0
            ? value.aspectRatio
            : fallbackAspectRatio;

    return Center(
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: VideoPlayer(controller),
      ),
    );
  }

  Widget _buildViewport({
    required bool isFullscreen,
    required VoidCallback onToggleFullscreen,
  }) {
    if (_presentingFullscreen && !isFullscreen) {
      return const ColoredBox(color: Colors.black);
    }

    final controller = _controller;
    final showVideo =
        controller != null &&
        controller.value.isInitialized &&
        (!_presentingFullscreen || isFullscreen);

    final titleText = _buildTitleText();
    final availability = _episodeAvailability();

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showVideo)
            _buildVideoContent(
              controller: controller,
              fallbackAspectRatio:
                  isFullscreen
                      ? widget.fullScreenAspectRatio
                      : widget.aspectRatio,
            ),
          VideoPlayerMaterialControls(
            controller: controller,
            isFullscreen: isFullscreen,
            onToggleFullscreen: onToggleFullscreen,
            orientationLocked: _fullscreenOrientationLocked,
            onToggleOrientationLock:
                isFullscreen
                    ? () {
                        unawaited(_toggleFullscreenOrientationLock());
                      }
                    : null,
            onPlayRequestedChanged: _setPlayRequested,
            title: Text(
              titleText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            onPrev: availability.hasPrev ? _prev : null,
            onNext: availability.hasNext ? _next : null,
            onRetry: _retry,
            opening: _surfaceState.opening,
            errorMessage: _surfaceState.errorMessage,
            playbackReady: _isPlaybackReady,
            playRequested: _surfaceState.playRequested,
            runtimeState: _surfaceState.runtimeState,
          ),
        ],
      ),
    );
  }

  _EpisodeAvailability _episodeAvailability() {
    final detail = widget.detail;
    final list = detail?.list;
    final originIndex = _playVideoIdsStore?.originIndex ?? 0;
    final teleplayIndex = _playVideoIdsStore?.teleplayIndex;
    final linkList =
        list != null && list.isNotEmpty && originIndex < list.length
            ? list[originIndex].linkList
            : null;

    final hasPrev = teleplayIndex != null && teleplayIndex > 0;
    final hasNext =
        teleplayIndex != null &&
        linkList != null &&
        teleplayIndex < linkList.length - 1;
    return _EpisodeAvailability(hasPrev: hasPrev, hasNext: hasNext);
  }

  String _buildTitleText() {
    final detail = widget.detail;
    final list = detail?.list;
    final originIndex = _playVideoIdsStore?.originIndex ?? 0;
    final teleplayIndex = _playVideoIdsStore?.teleplayIndex;
    final linkList =
        list != null && list.isNotEmpty && originIndex < list.length
            ? list[originIndex].linkList
            : null;

    if (teleplayIndex != null &&
        linkList != null &&
        teleplayIndex >= 0 &&
        teleplayIndex < linkList.length) {
      return '${detail?.name ?? ''}-${linkList[teleplayIndex].episode ?? ''}';
    }
    return '${detail?.name ?? ''}-未选择';
  }

  @override
  Widget build(BuildContext context) {
    return _buildViewport(
      isFullscreen: false,
      onToggleFullscreen: _showFullscreen,
    );
  }
}

class _CurrentMedia {
  final int originIndex;
  final int teleplayIndex;
  final int startAt;
  final String url;

  const _CurrentMedia({
    required this.originIndex,
    required this.teleplayIndex,
    required this.startAt,
    required this.url,
  });
}

class _EpisodeAvailability {
  final bool hasPrev;
  final bool hasNext;

  const _EpisodeAvailability({
    required this.hasPrev,
    required this.hasNext,
  });
}

Duration _clampDuration(Duration value, Duration min, Duration max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

Duration _bufferedPosition(List<DurationRange> ranges) {
  if (ranges.isEmpty) return Duration.zero;
  Duration maxEnd = Duration.zero;
  for (final range in ranges) {
    if (range.end > maxEnd) {
      maxEnd = range.end;
    }
  }
  return maxEnd;
}
