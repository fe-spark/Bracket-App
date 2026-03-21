import 'package:flutter/scheduler.dart';
import 'package:video_player/video_player.dart';

import '/plugins.dart';
import '/utils/bv_utils.dart';

import 'percentage.dart';

const double _maxAndroidPlaybackRate = 3.0;
const double _maxIosPlaybackRate = 2.0;
const double _topBarHeight = 56.0;
const double _bottomBarHeight = 52.0;
const double _fullscreenBottomBarHeight = 76.0;
const double _bottomBarHorizontalPadding = 6.0;
const double _fullscreenBottomBarHorizontalPadding = 16.0;
const double _fullscreenBottomBarVerticalPadding = 4.0;
const double _fullscreenProgressStartCorrection = 5.0;
const double _bottomBarPlayProgressSpacing = 6.0;
const double _bottomBarProgressTimeSpacing = 8.0;
const double _bottomBarTimeActionSpacing = 4.0;
const double _bottomBarTrailingButtonSpacing = 0.0;
const double _bottomBarInlineButtonExtent = 30.0;
const double _fullscreenBottomBarInlineButtonExtent = 34.0;
const double _bottomBarInlineIconSize = 22.0;
const double _fullscreenBottomBarInlineIconSize = 24.0;
const double _bottomBarTrailingButtonWidth = 24.0;
const double _bottomBarTrailingButtonHeight = 30.0;
const double _bottomBarTrailingIconSize = 22.0;
const double _bottomBarTimeWidth = 84.0;
const double _fullscreenBottomBarRowSpacing = 6.0;
const double _fullscreenBottomBarTimeFontSize = 12.0;
const double _fullscreenTopActionHeight = 36.0;
const double _fullscreenTopToolbarSpacing = 10.0;
const double _fullscreenTopChipHorizontalPadding = 14.0;
const double _fullscreenTopChipIconSize = 18.0;
const double _fullscreenTopChipFontSize = 13.0;
const double _fullscreenTransportButtonSize = 52.0;
const double _fullscreenTransportButtonIconSize = 24.0;
const double _fullscreenTransportButtonSpacing = 24.0;
const Duration _overlayAnimationDuration = Duration(milliseconds: 180);
const double _loadingOverlayMargin = 12.0;
const double _feedbackOverlayOffsetY = -72.0;
const double _gestureLockDistance = 10.0;
const double _gestureDirectionBias = 1.08;
const double _verticalGestureLockDistance = 18.0;
const double _verticalGestureSensitivity = 1.75;
const double _minHorizontalSeekRangeMs = 3 * 60 * 1000;
const double _maxHorizontalSeekRangeMs = 12 * 60 * 1000;

enum _CenterOverlayMode {
  hidden,
  transport,
  loading,
  error,
}

enum _GestureMode {
  idle,
  pending,
  horizontalSeek,
  verticalVolume,
  verticalBrightness,
  longPressSpeed,
}

@immutable
class VideoPlayerRuntimeState {
  final bool playing;
  final bool completed;
  final bool buffering;
  final bool stalledPlayback;
  final bool hasRecentProgress;
  final Duration position;
  final Duration duration;
  final Duration buffer;
  final double volume;
  final double playbackSpeed;
  final double lastAudibleVolume;

  const VideoPlayerRuntimeState({
    required this.playing,
    required this.completed,
    required this.buffering,
    required this.stalledPlayback,
    required this.hasRecentProgress,
    required this.position,
    required this.duration,
    required this.buffer,
    required this.volume,
    required this.playbackSpeed,
    required this.lastAudibleVolume,
  });

  static const empty = VideoPlayerRuntimeState(
    playing: false,
    completed: false,
    buffering: false,
    stalledPlayback: false,
    hasRecentProgress: false,
    position: Duration.zero,
    duration: Duration.zero,
    buffer: Duration.zero,
    volume: 100.0,
    playbackSpeed: 1.0,
    lastAudibleVolume: 100.0,
  );
}

class VideoPlayerMaterialControls extends StatefulWidget {
  final VideoPlayerController? controller;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;
  final ValueChanged<bool> onPlayRequestedChanged;
  final Widget title;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final Future<void> Function() onRetry;
  final bool opening;
  final String? errorMessage;
  final bool playbackReady;
  final bool playRequested;
  final VideoPlayerRuntimeState runtimeState;
  final bool showControlsOnInitialize;

  const VideoPlayerMaterialControls({
    super.key,
    required this.controller,
    required this.isFullscreen,
    required this.onToggleFullscreen,
    required this.onPlayRequestedChanged,
    required this.title,
    required this.onRetry,
    required this.opening,
    this.errorMessage,
    this.playbackReady = false,
    this.playRequested = false,
    this.runtimeState = VideoPlayerRuntimeState.empty,
    this.onPrev,
    this.onNext,
    this.showControlsOnInitialize = true,
  });

  @override
  State<VideoPlayerMaterialControls> createState() =>
      _VideoPlayerMaterialControlsState();
}

class _VideoPlayerMaterialControlsState extends State<VideoPlayerMaterialControls>
    with SingleTickerProviderStateMixin {
  final PercentageController _percentageController = PercentageController();

  VideoPlayerController? _controller;
  Timer? _hideTimer;
  Timer? _initTimer;
  late final AnimationController _longPressSpeedOverlayController;

  bool _controlsVisible = true;
  bool _seeking = false;

  Duration? _seekTarget;
  Duration? _seekCompletionTarget;

  double _tempPlaybackSpeed = 1.0;
  bool _resumePlaybackAfterLongPress = false;

  bool _draggingProgress = false;
  double _dragProgressValue = 0.0;

  bool _showLongPressSpeedOverlay = false;
  bool _discreteGestureAllowed = false;
  _GestureMode _gestureMode = _GestureMode.idle;
  int? _gesturePointerId;
  Offset? _gestureStartLocalPosition;
  bool _gestureStartedOnLeftSide = false;
  double _gestureStartVolume = 0.0;
  double _gestureStartBrightness = 0.5;
  Duration _gestureStartSeekPosition = Duration.zero;

  bool get _isFullscreen => widget.isFullscreen;

  double get _maxPlaybackRate =>
      Platform.isIOS ? _maxIosPlaybackRate : _maxAndroidPlaybackRate;

  String? get _error =>
      widget.errorMessage?.isEmpty ?? true ? null : widget.errorMessage;

  bool get _isPlaybackExpectedToContinue =>
      widget.playRequested && !_completed && _error == null;

  bool get _isRuntimeBlocked => _seeking || _buffering || _stalledPlayback;

  bool get _isLoading =>
      !_draggingProgress &&
      _error == null &&
      (widget.opening || (_isPlaybackExpectedToContinue && _isRuntimeBlocked));

  bool get _canInteractWithPlayback =>
      widget.playbackReady && !widget.opening && _error == null;

  bool get _playerGesturesEnabled => widget.playbackReady && _error == null;

  bool get _hasTrackedPointerGesture =>
      _gesturePointerId != null && _gestureMode != _GestureMode.idle;

  bool get _fullscreenSwipeGesturesEnabled =>
      _isFullscreen && _canInteractWithPlayback;

  bool get _showTransportControls =>
      _controlsVisible && widget.playbackReady && !_isLoading && _error == null;

  bool get _showCenterTransportButton =>
      _showTransportControls && !_isPlaybackExpectedToContinue;

  bool get _showBottomBar =>
      _controlsVisible && widget.playbackReady && _error == null;

  bool get _showBottomScrim =>
      _controlsVisible && widget.playbackReady && _error == null;

  bool get _showPausedBackdrop =>
      _showTransportControls &&
      !_isPlaybackExpectedToContinue &&
      _error == null &&
      !_isLoading;

  EdgeInsets get _fullscreenSafePadding =>
      _isFullscreen ? MediaQuery.paddingOf(context) : EdgeInsets.zero;

  double get _topControlsExtent {
    if (_isFullscreen) {
      if (!_controlsVisible) {
        return 0;
      }
      return _topBarHeight;
    }
    // Embedded player always has the page-level back button in the top-left.
    return _topBarHeight;
  }

  double get _bottomControlsExtent {
    if (!_showBottomBar) {
      return 0;
    }
    return _isFullscreen ? _fullscreenBottomBarHeight : _bottomBarHeight;
  }

  double get _loadingBottomExtent => _bottomBarHeight + _loadingOverlayMargin;

  double get _feedbackBottomExtent => _loadingBottomExtent;

  EdgeInsets get _feedbackOverlayPadding => EdgeInsets.fromLTRB(
        _loadingOverlayMargin,
        _loadingOverlayMargin,
        _loadingOverlayMargin,
        _feedbackBottomExtent,
      );

  _CenterOverlayMode get _centerOverlayMode {
    if (_error != null) {
      return _CenterOverlayMode.error;
    }
    if (_isLoading) {
      return _CenterOverlayMode.loading;
    }
    if (_showCenterTransportButton) {
      return _CenterOverlayMode.transport;
    }
    return _CenterOverlayMode.hidden;
  }

  VideoPlayerController? get _currentController => widget.controller;
  VideoPlayerRuntimeState get _runtime => widget.runtimeState;
  bool get _playing => _runtime.playing;
  bool get _completed => _runtime.completed;
  bool get _buffering => _runtime.buffering;
  Duration get _position => _runtime.position;
  Duration get _duration => _runtime.duration;
  Duration get _buffer => _runtime.buffer;
  double get _volume => _runtime.volume;
  double get _rate => _runtime.playbackSpeed;
  double get _lastNonZeroVolume => _runtime.lastAudibleVolume;
  bool get _stalledPlayback => _runtime.stalledPlayback;

  @override
  void initState() {
    super.initState();
    _longPressSpeedOverlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _attachController();
    if (widget.showControlsOnInitialize) {
      _initTimer = Timer(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        setState(() {
          _controlsVisible = true;
        });
      });
    }
  }

  @override
  void didUpdateWidget(covariant VideoPlayerMaterialControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != _currentController) {
      _detachController();
      _attachController();
    }
    if (oldWidget.errorMessage != widget.errorMessage && _error != null) {
      _controlsVisible = true;
      _hideTimer?.cancel();
    }
    if (oldWidget.opening != widget.opening) {
      if (widget.opening) {
        _hideTimer?.cancel();
      } else {
        _startHideTimer();
      }
    }
    if (_seeking &&
        (oldWidget.runtimeState.position != widget.runtimeState.position ||
            oldWidget.runtimeState.buffering != widget.runtimeState.buffering ||
            oldWidget.runtimeState.completed != widget.runtimeState.completed)) {
      _maybeCompleteSeeking(widget.runtimeState.position);
    }
    if (!_playerGesturesEnabled) {
      _cancelActiveGesture();
    }
  }

  void _attachController() {
    _controller = _currentController;
    if (_playing) {
      _startHideTimer();
    }
  }

  void _detachController() {
    _controller = null;
    _hideTimer?.cancel();
    _initTimer?.cancel();
  }

  @override
  void dispose() {
    _percentageController.hide();
    _longPressSpeedOverlayController.dispose();
    _detachController();
    BVUtils.resetCustomBrightness();
    super.dispose();
  }

  void _toggleControls() {
    if (_controlsVisible) {
      _hideTimer?.cancel();
      setState(() {
        _controlsVisible = false;
      });
    } else {
      _showControls();
    }
  }

  void _showControls() {
    _hideTimer?.cancel();
    setState(() {
      _controlsVisible = true;
    });
    _startHideTimer();
  }

  void _showFeedbackOverlay(
    String message, {
    String? caption,
    IconData? icon,
    double? progress,
  }) {
    _percentageController.show(
      message,
      alignment: Alignment.center,
      padding: _feedbackOverlayPadding,
      caption: caption,
      icon: icon,
      progress: progress,
      offset: const Offset(0, _feedbackOverlayOffsetY),
    );
  }

  bool _canHandleBackgroundGestureAt(Offset localPosition) {
    return _playerGesturesEnabled && _shouldHandlePointerGesture(localPosition);
  }

  bool _tracksPointer(int pointer) {
    return _playerGesturesEnabled &&
        _gesturePointerId == pointer &&
        _gestureMode != _GestureMode.idle;
  }

  void _rememberDiscreteGestureEligibility(Offset localPosition) {
    _discreteGestureAllowed = _canHandleBackgroundGestureAt(localPosition);
  }

  void _clearDiscreteGestureEligibility() {
    _discreteGestureAllowed = false;
  }

  void _initializeGestureTracking(
    Offset localPosition, {
    required bool primeSystemValues,
  }) {
    _gestureMode = _GestureMode.pending;
    _gestureStartLocalPosition = localPosition;
    _gestureStartedOnLeftSide =
        localPosition.dx <= (context.size?.width ?? 0) / 2;
    _gestureStartSeekPosition = _displayedPosition;
    _gestureStartVolume = (_volume / 100).clamp(0.0, 1.0);
    if (!primeSystemValues) {
      return;
    }
    unawaited(_primeGestureBrightness());
    unawaited(_primeGestureVolume());
  }

  Future<void> _primeGestureBrightness() async {
    final brightness = (await BVUtils.brightness).clamp(0.0, 1.0);
    if (_gestureMode != _GestureMode.pending ||
        _gestureStartLocalPosition == null) {
      return;
    }
    _gestureStartBrightness = brightness;
  }

  Future<void> _primeGestureVolume() async {
    final volume = (await BVUtils.volume).clamp(0.0, 1.0);
    if (_gestureMode != _GestureMode.pending ||
        _gestureStartLocalPosition == null) {
      return;
    }
    _gestureStartVolume = volume;
  }

  void _resetGestureTracking() {
    _gestureMode = _GestureMode.idle;
    _gesturePointerId = null;
    _gestureStartLocalPosition = null;
    _gestureStartedOnLeftSide = false;
    _gestureStartSeekPosition = Duration.zero;
  }

  void _setLongPressSpeedOverlayVisible(bool visible) {
    if (_showLongPressSpeedOverlay == visible) return;
    if (!mounted) {
      _showLongPressSpeedOverlay = visible;
      return;
    }

    setState(() {
      _showLongPressSpeedOverlay = visible;
    });

    if (visible) {
      _longPressSpeedOverlayController
        ..stop()
        ..repeat();
    } else {
      _longPressSpeedOverlayController
        ..stop()
        ..reset();
    }
  }

  void _cancelLongPressSpeedGesture() {
    if (_gestureMode != _GestureMode.longPressSpeed) {
      _setLongPressSpeedOverlayVisible(false);
      _clearDiscreteGestureEligibility();
      return;
    }
    _setLongPressSpeedOverlayVisible(false);
    final controller = _controller;
    if (controller != null) {
      unawaited(controller.setPlaybackSpeed(_tempPlaybackSpeed));
      if (_resumePlaybackAfterLongPress && !controller.value.isPlaying) {
        unawaited(controller.play());
      }
    }
    _percentageController.hide();
    _clearDiscreteGestureEligibility();
    _resumePlaybackAfterLongPress = false;
    _resetGestureTracking();
  }

  Future<void> _finishLongPressSpeedGesture() async {
    if (_gestureMode != _GestureMode.longPressSpeed) return;
    _setLongPressSpeedOverlayVisible(false);
    final controller = _controller;
    if (controller != null) {
      await controller.setPlaybackSpeed(_tempPlaybackSpeed);
      if (_resumePlaybackAfterLongPress && !controller.value.isPlaying) {
        await controller.play();
      }
    }
    _percentageController.hide();
    _clearDiscreteGestureEligibility();
    _resumePlaybackAfterLongPress = false;
    _resetGestureTracking();
  }

  void _cancelActiveGesture() {
    switch (_gestureMode) {
      case _GestureMode.horizontalSeek:
      case _GestureMode.verticalVolume:
      case _GestureMode.verticalBrightness:
      case _GestureMode.pending:
        _cancelPanGesture();
        return;
      case _GestureMode.longPressSpeed:
        _cancelLongPressSpeedGesture();
        return;
      case _GestureMode.idle:
        _setLongPressSpeedOverlayVisible(false);
        _percentageController.hide();
        _clearDiscreteGestureEligibility();
        _resetGestureTracking();
        return;
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    if (!_isPlaybackExpectedToContinue ||
        _isLoading ||
        _error != null ||
        widget.opening) {
      return;
    }
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _controlsVisible = false;
      });
    });
  }

  Future<void> _onPlayPause() async {
    final controller = _controller;
    if (controller == null || !_canInteractWithPlayback) return;

    if (_completed) {
      widget.onPlayRequestedChanged(true);
      await _performSeek(Duration.zero);
    }

    if (widget.playRequested) {
      widget.onPlayRequestedChanged(false);
      await controller.pause();
      if (!mounted) return;
      setState(() {
        _controlsVisible = true;
      });
    } else {
      widget.onPlayRequestedChanged(true);
      await controller.play();
      _showControls();
    }
  }

  Future<void> _seekRelative(int seconds) async {
    final controller = _controller;
    if (controller == null || !_canInteractWithPlayback) return;
    final max = _duration;
    final next = _clampDuration(
      _position + Duration(seconds: seconds),
      Duration.zero,
      max,
    );
    _showControls();
    await _performSeek(next);
    _showControls();
  }

  Future<void> _performSeek(Duration target) async {
    final controller = _controller;
    if (controller == null || !_canInteractWithPlayback) return;
    final shouldResumePlayback = widget.playRequested;

    _beginSeeking(target);
    await SchedulerBinding.instance.endOfFrame;
    await controller.seekTo(target);
    if (shouldResumePlayback) {
      await controller.play();
    }
  }

  Duration get _displayedPosition =>
      _draggingProgress
          ? Duration(milliseconds: _dragProgressValue.round())
          : _position;

  void _beginProgressPreview(double value) {
    final durationMs = _duration.inMilliseconds.toDouble();
    final max = durationMs <= 0 ? 0.0 : durationMs;
    final clampedValue = value.clamp(0.0, max);
    _hideTimer?.cancel();
    if (!mounted) {
      _controlsVisible = true;
      _draggingProgress = true;
      _dragProgressValue = clampedValue;
      return;
    }
    setState(() {
      _controlsVisible = true;
      _draggingProgress = true;
      _dragProgressValue = clampedValue;
    });
  }

  void _updateProgressPreview(double value) {
    final durationMs = _duration.inMilliseconds.toDouble();
    final max = durationMs <= 0 ? 0.0 : durationMs;
    final clampedValue = value.clamp(0.0, max);
    if (!mounted) {
      _draggingProgress = true;
      _dragProgressValue = clampedValue;
      return;
    }
    setState(() {
      _draggingProgress = true;
      _dragProgressValue = clampedValue;
    });
  }

  void _clearProgressPreview() {
    if (!_draggingProgress) return;
    if (!mounted) {
      _draggingProgress = false;
      _dragProgressValue = 0;
      return;
    }
    setState(() {
      _draggingProgress = false;
      _dragProgressValue = 0;
    });
  }

  Future<void> _commitProgressPreview() async {
    if (!_draggingProgress) return;
    final target = Duration(milliseconds: _dragProgressValue.round());
    await _performSeek(target);
    if (!mounted) return;
    setState(() {
      _draggingProgress = false;
      _dragProgressValue = 0;
      _controlsVisible = true;
    });
    _showControls();
  }

  void _beginSeeking(Duration target) {
    final remaining = max(
      0,
      _duration.inMilliseconds - target.inMilliseconds,
    );
    final settleOffset = Duration(
      milliseconds: min(300, remaining),
    );
    final completionTarget = target + settleOffset;

    if (!mounted) {
      _seeking = true;
      _seekTarget = target;
      _seekCompletionTarget = completionTarget;
      return;
    }
    setState(() {
      _seeking = true;
      _seekTarget = target;
      _seekCompletionTarget = completionTarget;
    });
  }

  void _maybeCompleteSeeking(Duration position) {
    if (!_seeking) return;
    final target = _seekTarget;
    if (target == null) {
      if (!mounted) {
        _seeking = false;
        _seekCompletionTarget = null;
      } else {
        setState(() {
          _seeking = false;
          _seekCompletionTarget = null;
        });
      }
      return;
    }

    final delta = (position - target).abs();
    if (delta > const Duration(milliseconds: 800) && position < target) {
      return;
    }

    if (_buffering) {
      return;
    }

    final completionTarget = _seekCompletionTarget ?? target;
    if ((_playing || widget.opening) && position < completionTarget) {
      return;
    }

    if (!mounted) {
      _seeking = false;
      _seekTarget = null;
      _seekCompletionTarget = null;
      return;
    }

    setState(() {
      _seeking = false;
      _seekTarget = null;
      _seekCompletionTarget = null;
    });
  }

  Future<void> _toggleFullscreen() async {
    _showControls();
    widget.onToggleFullscreen();
  }

  Future<void> _toggleMute() async {
    final controller = _controller;
    if (controller == null) return;
    if (_volume <= 0) {
      await controller.setVolume(
        (_lastNonZeroVolume <= 0 ? 100.0 : _lastNonZeroVolume) / 100,
      );
    } else {
      await controller.setVolume(0.0);
    }
    _showControls();
  }

  Future<void> _showSpeedSheet() async {
    final controller = _controller;
    if (controller == null || !_canInteractWithPlayback) return;

    final options =
        Platform.isIOS
            ? const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
            : const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 2.5, 3.0];
    final rate = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
                bottom: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '播放速度',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '当前 ${_formatPlaybackRate(_rate)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '点击后立即生效',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.62),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: options.map((item) {
                    final selected = (_rate - item).abs() < 0.01;
                    final child = Text(
                      _formatPlaybackRate(item),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    );

                    if (selected) {
                      return SizedBox(
                        width: 88,
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(item),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(88, 42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: child,
                        ),
                      );
                    }

                    return SizedBox(
                      width: 88,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(item),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(88, 42),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.45),
                          ),
                        ),
                        child: child,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (rate != null) {
      await controller.setPlaybackSpeed(rate);
      _showControls();
    }
  }

  double get _horizontalSeekRangeMs {
    final durationMs = _duration.inMilliseconds.toDouble();
    if (durationMs <= 0) return 0.0;
    final proportionalRange = durationMs * 0.35;
    return min(
      max(proportionalRange, _minHorizontalSeekRangeMs),
      min(durationMs, _maxHorizontalSeekRangeMs),
    );
  }

  bool _lockGestureMode(Offset localPosition) {
    final start = _gestureStartLocalPosition;
    if (start == null) return false;

    final delta = localPosition - start;
    final dx = delta.dx.abs();
    final dy = delta.dy.abs();
    if (max(dx, dy) < _gestureLockDistance) {
      return false;
    }

    if (dx > dy * _gestureDirectionBias &&
        _canInteractWithPlayback &&
        _duration > Duration.zero) {
      _gestureMode = _GestureMode.horizontalSeek;
      _gestureStartSeekPosition = _displayedPosition;
      _beginProgressPreview(_gestureStartSeekPosition.inMilliseconds.toDouble());
      return true;
    }

    if (dy >= _verticalGestureLockDistance &&
        dy > dx * _gestureDirectionBias &&
        _fullscreenSwipeGesturesEnabled) {
      _gestureMode =
          _gestureStartedOnLeftSide
              ? _GestureMode.verticalBrightness
              : _GestureMode.verticalVolume;
      return true;
    }

    return false;
  }

  bool _shouldHandlePointerGesture(Offset localPosition) {
    final size = context.size;
    if (size == null) return true;

    final topBlockedExtent =
        _isFullscreen && _controlsVisible
            ? _topControlsExtent + _fullscreenSafePadding.top
            : 0.0;
    final bottomBlockedExtent =
        _showBottomBar
            ? _bottomControlsExtent + _fullscreenSafePadding.bottom
            : 0.0;

    if (localPosition.dy <= topBlockedExtent) {
      return false;
    }
    if (localPosition.dy >= size.height - bottomBlockedExtent) {
      return false;
    }
    return true;
  }

  void _beginPointerGesture(PointerDownEvent event) {
    _gesturePointerId = event.pointer;
    _initializeGestureTracking(
      event.localPosition,
      primeSystemValues: true,
    );
  }

  void _updateLockedGesture(Offset localPosition) {
    switch (_gestureMode) {
      case _GestureMode.horizontalSeek:
        _updateHorizontalSeek(localPosition);
        return;
      case _GestureMode.verticalVolume:
        _updateVerticalGesture(localPosition, isVolume: true);
        return;
      case _GestureMode.verticalBrightness:
        _updateVerticalGesture(localPosition, isVolume: false);
        return;
      case _GestureMode.idle:
      case _GestureMode.pending:
      case _GestureMode.longPressSpeed:
        return;
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!_canHandleBackgroundGestureAt(event.localPosition) ||
        _hasTrackedPointerGesture) {
      return;
    }
    _beginPointerGesture(event);
  }

  void _handleGestureMove(Offset localPosition) {
    if (!_hasTrackedPointerGesture ||
        _gestureMode == _GestureMode.longPressSpeed) {
      return;
    }

    if (_gestureMode == _GestureMode.pending &&
        !_lockGestureMode(localPosition)) {
      return;
    }
    _updateLockedGesture(localPosition);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_tracksPointer(event.pointer)) {
      return;
    }
    _handleGestureMove(event.localPosition);
  }

  void _updateHorizontalSeek(Offset localPosition) {
    final start = _gestureStartLocalPosition;
    if (start == null) return;

    final width = max(context.size?.width ?? 0, 1.0);
    final targetMs =
        _gestureStartSeekPosition.inMilliseconds.toDouble() +
        (localPosition.dx - start.dx) / width * _horizontalSeekRangeMs;
    _updateProgressPreview(targetMs);

    final target = _displayedPosition;
    final deltaSeconds = (target - _gestureStartSeekPosition).inSeconds;
    final deltaText =
        deltaSeconds == 0
            ? '0s'
            : '${deltaSeconds > 0 ? '+' : '-'}${deltaSeconds.abs()}s';
    _showFeedbackOverlay(
      '${_formatDuration(target)} / ${_formatDuration(_duration)}  $deltaText',
      icon:
          deltaSeconds >= 0
              ? Icons.fast_forward_rounded
              : Icons.fast_rewind_rounded,
    );
  }

  void _updateVerticalGesture(
    Offset localPosition, {
    required bool isVolume,
  }) {
    final start = _gestureStartLocalPosition;
    if (start == null) return;

    final height = max(context.size?.height ?? 0, 1.0);
    final baseValue = isVolume ? _gestureStartVolume : _gestureStartBrightness;
    final nextValue =
        (baseValue -
                (localPosition.dy - start.dy) /
                    height *
                    _verticalGestureSensitivity)
            .clamp(0.0, 1.0);

    if (isVolume) {
      _gestureStartVolume = nextValue;
      _gestureStartLocalPosition = localPosition;
      unawaited(BVUtils.setVolume(nextValue));
      _showFeedbackOverlay(
        '${(nextValue * 100).round()}%',
        icon:
            nextValue <= 0
                ? Icons.volume_off_rounded
                : Icons.volume_up_rounded,
      );
      return;
    }

    _gestureStartBrightness = nextValue;
    _gestureStartLocalPosition = localPosition;
    unawaited(BVUtils.setBrightness(nextValue));
    _showFeedbackOverlay(
      '${(nextValue * 100).round()}%',
      icon: Icons.light_mode_rounded,
    );
  }

  Future<void> _finishPanGesture() async {
    final mode = _gestureMode;
    if (mode == _GestureMode.horizontalSeek) {
      await _commitProgressPreview();
    } else {
      _clearProgressPreview();
    }
    _percentageController.hide();
    if (mode != _GestureMode.pending) {
      _clearDiscreteGestureEligibility();
    }
    _resetGestureTracking();
  }

  void _cancelPanGesture() {
    _clearProgressPreview();
    _percentageController.hide();
    _clearDiscreteGestureEligibility();
    _resetGestureTracking();
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_gestureMode == _GestureMode.longPressSpeed) {
      return;
    }
    if (!_tracksPointer(event.pointer)) {
      return;
    }
    unawaited(_finishPanGesture());
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (_gestureMode == _GestureMode.longPressSpeed) {
      return;
    }
    if (!_tracksPointer(event.pointer)) {
      return;
    }
    _cancelPanGesture();
  }

  void _handleTapCancel() {
    _clearDiscreteGestureEligibility();
    // Tap cancellation also happens when long press wins the gesture arena.
    // Keep any in-flight pointer gesture intact and let pointer up/cancel
    // perform the real cleanup.
    if (_hasTrackedPointerGesture ||
        _gestureMode == _GestureMode.longPressSpeed) {
      return;
    }
    _resetGestureTracking();
  }

  Widget _buildTopBar() {
    if (!_isFullscreen) return const SizedBox.shrink();

    return IgnorePointer(
      ignoring: !_controlsVisible,
      child: AnimatedOpacity(
        opacity: _controlsVisible ? 1 : 0,
        duration: _overlayAnimationDuration,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.68),
                Colors.black.withValues(alpha: 0.34),
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            left: true,
            right: true,
            child: SizedBox(
              height: _topBarHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _fullscreenBottomBarHorizontalPadding,
                ),
                child: Row(
                  children: [
                    _buildFullscreenToolbarIconButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: _toggleFullscreen,
                    ),
                    const SizedBox(width: _fullscreenTopToolbarSpacing),
                    Expanded(child: widget.title),
                    const SizedBox(width: 12),
                    if (widget.onPrev != null)
                      _buildFullscreenActionChip(
                        icon: Icons.skip_previous_rounded,
                        label: '上集',
                        onTap: () {
                          _showControls();
                          widget.onPrev?.call();
                        },
                      ),
                    if (widget.onPrev != null)
                      const SizedBox(width: _fullscreenTopToolbarSpacing),
                    if (widget.onNext != null)
                      _buildFullscreenActionChip(
                        icon: Icons.skip_next_rounded,
                        label: '下集',
                        onTap: () {
                          _showControls();
                          widget.onNext?.call();
                        },
                      ),
                    if (widget.onNext != null)
                      const SizedBox(width: _fullscreenTopToolbarSpacing),
                    _buildFullscreenActionChip(
                      icon: Icons.speed_rounded,
                      label: _formatPlaybackRate(_rate),
                      onTap: _canInteractWithPlayback ? _showSpeedSheet : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (!_showBottomBar) {
      return const SizedBox.shrink();
    }

    final displayedPosition = _displayedPosition;
    final safeBottomInset = _isFullscreen ? _fullscreenSafePadding.bottom : 0.0;

    return IgnorePointer(
      ignoring: !_showBottomBar,
      child: AnimatedOpacity(
        opacity: _showBottomBar ? 1 : 0,
        duration: _overlayAnimationDuration,
        child: SizedBox(
          height: _bottomControlsExtent + safeBottomInset,
          child: SafeArea(
            top: false,
            bottom: _isFullscreen,
            left: _isFullscreen,
            right: _isFullscreen,
            child: SizedBox(
              height: _bottomControlsExtent,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  _isFullscreen
                      ? _fullscreenBottomBarHorizontalPadding
                      : _bottomBarHorizontalPadding,
                  _isFullscreen ? _fullscreenBottomBarVerticalPadding : 2,
                  _isFullscreen
                      ? _fullscreenBottomBarHorizontalPadding
                      : _bottomBarHorizontalPadding,
                  _isFullscreen ? _fullscreenBottomBarVerticalPadding : 2,
                ),
                child: _buildBottomBarContent(displayedPosition),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBarContent(Duration displayedPosition) {
    if (_isFullscreen) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProgressBar(
            padding: const EdgeInsets.only(
              left: _fullscreenProgressStartCorrection,
            ),
          ),
          const SizedBox(height: _fullscreenBottomBarRowSpacing),
          Row(
            children: [
              _buildBottomInlineButton(
                icon:
                    _isPlaybackExpectedToContinue
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                onTap: _canInteractWithPlayback ? _onPlayPause : null,
                iconSize: _fullscreenBottomBarInlineIconSize,
                buttonWidth: _fullscreenTopActionHeight,
                buttonHeight: _fullscreenTopActionHeight,
                circularBackground: true,
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: _bottomBarTimeWidth + 12,
                child: Text(
                  '${_formatDuration(displayedPosition)} / ${_formatDuration(_duration)}',
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: _fullscreenBottomBarTimeFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              _buildBottomInlineButton(
                icon:
                    _volume > 0
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                onTap: _canInteractWithPlayback ? _toggleMute : null,
                iconSize: _fullscreenBottomBarInlineIconSize,
                buttonWidth: _fullscreenBottomBarInlineButtonExtent,
                buttonHeight: _fullscreenBottomBarInlineButtonExtent,
              ),
              const SizedBox(width: 6),
              _buildBottomInlineButton(
                icon: Icons.fullscreen_exit_rounded,
                onTap: _canInteractWithPlayback ? _toggleFullscreen : null,
                iconSize: _fullscreenBottomBarInlineIconSize,
                buttonWidth: _fullscreenBottomBarInlineButtonExtent,
                buttonHeight: _fullscreenBottomBarInlineButtonExtent,
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildBottomInlineButton(
          icon:
              _isPlaybackExpectedToContinue
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
          onTap: _canInteractWithPlayback ? _onPlayPause : null,
          iconSize: _bottomBarInlineIconSize,
          buttonWidth: _bottomBarInlineButtonExtent,
          buttonHeight: _bottomBarInlineButtonExtent,
        ),
        const SizedBox(width: _bottomBarPlayProgressSpacing),
        Expanded(
          child: _buildProgressBar(
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(width: _bottomBarProgressTimeSpacing),
        SizedBox(
          width: _bottomBarTimeWidth,
          child: Text(
            '${_formatDuration(displayedPosition)} / ${_formatDuration(_duration)}',
            maxLines: 1,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: _bottomBarTimeActionSpacing),
        _buildBottomInlineButton(
          icon:
              _volume > 0 ? Icons.volume_up_rounded : Icons.volume_off_rounded,
          onTap: _canInteractWithPlayback ? _toggleMute : null,
          iconSize: _bottomBarTrailingIconSize,
          buttonWidth: _bottomBarTrailingButtonWidth,
          buttonHeight: _bottomBarTrailingButtonHeight,
          iconAlignment: Alignment.centerRight,
        ),
        const SizedBox(width: _bottomBarTrailingButtonSpacing),
        _buildBottomInlineButton(
          icon: _isFullscreen
              ? Icons.fullscreen_exit_rounded
              : Icons.fullscreen_rounded,
          onTap: _canInteractWithPlayback ? _toggleFullscreen : null,
          iconSize: _bottomBarTrailingIconSize,
          buttonWidth: _bottomBarTrailingButtonWidth,
          buttonHeight: _bottomBarTrailingButtonHeight,
          iconAlignment: Alignment.centerLeft,
        ),
      ],
    );
  }

  Widget _buildBottomScrim() {
    if (!_showBottomScrim) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: 1,
        duration: _overlayAnimationDuration,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            widthFactor: 1,
            heightFactor: _isFullscreen ? 0.34 : 0.48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.18),
                    Colors.black.withValues(alpha: 0.44),
                    Colors.black.withValues(alpha: 0.78),
                  ],
                  stops: const [0, 0.28, 0.65, 1],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPausedBackdrop() {
    if (!_showPausedBackdrop) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: 1,
          duration: _overlayAnimationDuration,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color:
                  Colors.black.withValues(alpha: _isFullscreen ? 0.20 : 0.24),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar({
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 12),
  }) {
    final durationMs = _duration.inMilliseconds.toDouble();
    final max = durationMs <= 0 ? 1.0 : durationMs;
    final canSeek = durationMs > 0 && _canInteractWithPlayback;
    final positionValue =
        _displayedPosition.inMilliseconds.toDouble().clamp(0.0, max);
    final bufferValue = _buffer.inMilliseconds.toDouble().clamp(0.0, max);

    return Padding(
      padding: padding,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Align(
              child: LinearProgressIndicator(
                value: max <= 0 ? 0 : bufferValue / max,
                minHeight: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withValues(alpha: 0.38),
                ),
                backgroundColor: Colors.white.withValues(alpha: 0.14),
              ),
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              trackShape: const _EdgeToEdgeSliderTrackShape(),
              overlayShape: SliderComponentShape.noOverlay,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              inactiveTrackColor: Colors.transparent,
              activeTrackColor: Theme.of(context).colorScheme.primary,
              thumbColor: Theme.of(context).colorScheme.primary,
            ),
            child: Slider(
              padding: EdgeInsets.zero,
              value: positionValue,
              max: max,
              onChangeStart: canSeek
                  ? (value) {
                      _beginProgressPreview(value);
                    }
                  : null,
              onChanged: canSeek
                  ? (value) {
                      _updateProgressPreview(value);
                    }
                  : null,
              onChangeEnd: canSeek
                  ? (value) async {
                      await _commitProgressPreview();
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportOverlay() {
    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isFullscreen)
          _buildTransportButton(
            icon: Icons.replay_10_rounded,
            size: _fullscreenTransportButtonSize,
            iconSize: _fullscreenTransportButtonIconSize,
            onTap: () => _seekRelative(-10),
          ),
        if (_isFullscreen)
          const SizedBox(width: _fullscreenTransportButtonSpacing),
        _buildTransportButton(
          icon:
              _completed ? Icons.replay_rounded : Icons.play_arrow_rounded,
          size: 76,
          iconSize: 42,
          prominent: true,
          onTap: _onPlayPause,
        ),
        if (_isFullscreen)
          const SizedBox(width: _fullscreenTransportButtonSpacing),
        if (_isFullscreen)
          _buildTransportButton(
            icon: Icons.forward_10_rounded,
            size: _fullscreenTransportButtonSize,
            iconSize: _fullscreenTransportButtonIconSize,
            onTap: () => _seekRelative(10),
          ),
      ],
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: controls,
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
          SizedBox(width: 12),
          Text(
            '加载中...',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(PercentageOverlayData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (data.icon != null)
            Icon(
              data.icon,
              size: 18,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          if (data.icon != null) const SizedBox(width: 8),
          Text(
            data.message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  double _centerOverlayBottomAvoidance({
    required BoxConstraints constraints,
    required double contentHeight,
  }) {
    if (!_showBottomBar) {
      return 0;
    }
    final controlTop = constraints.maxHeight - _bottomControlsExtent;
    final centeredBottom = constraints.maxHeight / 2 + contentHeight / 2;
    final requiredShift = max(
      0.0,
      centeredBottom - (controlTop - _loadingOverlayMargin),
    );
    return requiredShift * 2;
  }

  Widget _buildCenteredStatusGroup({
    required Widget primary,
    Widget? secondary,
    double secondaryEstimatedHeight = 0,
  }) {
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          _loadingOverlayMargin,
          _loadingOverlayMargin,
          _loadingOverlayMargin,
          _loadingOverlayMargin,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hasSecondary = secondary != null;
            final compact = constraints.maxHeight < 112;
            final spacing = compact ? 8.0 : 12.0;
            final estimatedHeight =
                44.0 + (hasSecondary ? secondaryEstimatedHeight + spacing : 0.0);
            final bottomAvoidance = _centerOverlayBottomAvoidance(
              constraints: constraints,
              contentHeight: estimatedHeight,
            );
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomAvoidance),
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: max(0.0, constraints.maxHeight - bottomAvoidance),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: constraints.maxWidth),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasSecondary) ...[
                            secondary,
                            SizedBox(height: spacing),
                          ],
                          primary,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCenteredOverlayOnly({
    required Widget child,
    required double estimatedHeight,
  }) {
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          _loadingOverlayMargin,
          _loadingOverlayMargin,
          _loadingOverlayMargin,
          _loadingOverlayMargin,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomAvoidance = _centerOverlayBottomAvoidance(
              constraints: constraints,
              contentHeight: estimatedHeight,
            );
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomAvoidance),
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: max(0.0, constraints.maxHeight - bottomAvoidance),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: constraints.maxWidth),
                      child: child,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLongPressSpeedOverlayContent() {
    return AnimatedBuilder(
      animation: _longPressSpeedOverlayController,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(3, (index) {
              final delay = index * 0.16;
              final rawPhase = _longPressSpeedOverlayController.value - delay;
              final phase = rawPhase < 0 ? rawPhase + 1 : rawPhase;
              final activeProgress = phase < 0.45 ? 1 - (phase / 0.45) : 0.0;
              final emphasis = Curves.easeOut.transform(activeProgress);

              return Transform.translate(
                offset: Offset((1 - emphasis) * -2.5, 0),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 0.5,
                  ),
                  child: Opacity(
                    opacity: 0.24 + (emphasis * 0.76),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(width: 6),
            Text(
              _formatPlaybackRate(_maxPlaybackRate),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScaledErrorText(String message) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const baseStyle = TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.28,
        );
        const minFontSize = 9.0;
        final maxWidth = max(0.0, constraints.maxWidth);
        final textDirection = Directionality.of(context);
        final maxFontSize = baseStyle.fontSize ?? 18;

        double low = minFontSize;
        double high = maxFontSize;
        double fitted = minFontSize;

        while ((high - low) > 0.25) {
          final mid = (low + high) / 2;
          final style = baseStyle.copyWith(fontSize: mid);
          if (_fitsErrorText(
            message,
            style: style,
            maxWidth: maxWidth,
            textDirection: textDirection,
          )) {
            fitted = mid;
            low = mid;
          } else {
            high = mid;
          }
        }

        final resolvedStyle = baseStyle.copyWith(
          fontSize: _fitsErrorText(
            message,
            style: baseStyle.copyWith(fontSize: high),
            maxWidth: maxWidth,
            textDirection: textDirection,
          )
              ? high
              : fitted,
        );

        return Text(
          message,
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.clip,
          textAlign: TextAlign.center,
          style: resolvedStyle,
        );
      },
    );
  }

  bool _fitsErrorText(
    String message, {
    required TextStyle style,
    required double maxWidth,
    required TextDirection textDirection,
  }) {
    if (maxWidth <= 0) return true;

    final painter = TextPainter(
      text: TextSpan(text: message, style: style),
      textAlign: TextAlign.center,
      textDirection: textDirection,
      maxLines: 2,
    )..layout(maxWidth: maxWidth);

    return !painter.didExceedMaxLines;
  }

  Widget _buildErrorOverlay() {
    final errorMessage = _error;
    if (errorMessage == null) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      ignoring: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 150;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '播放异常',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 16 : 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: compact ? 6 : 10),
                    _buildScaledErrorText(errorMessage),
                    SizedBox(height: compact ? 10 : 16),
                    FilledButton(
                      onPressed: widget.onRetry,
                      style: FilledButton.styleFrom(
                        minimumSize: Size(compact ? 96 : 104, compact ? 36 : 40),
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 18 : 22,
                          vertical: compact ? 8 : 10,
                        ),
                        shape: const StadiumBorder(),
                        textStyle: TextStyle(
                          fontSize: compact ? 14 : 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('重新播放'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCenterOverlay() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _percentageController,
        builder: (context, _) {
          final feedback = _percentageController.data;
          final hasFeedback = !feedback.hidden;
          final hasLongPressSpeedOverlay = _showLongPressSpeedOverlay;
          final secondaryOverlay = hasLongPressSpeedOverlay
              ? _buildLongPressSpeedOverlayContent()
              : hasFeedback
                  ? _buildFeedbackCard(feedback)
                  : null;
          final secondaryOverlayHeight = hasLongPressSpeedOverlay ? 46.0 : 38.0;
          final overlayPadding = _fullscreenSafePadding.add(
            _centerOverlayMode == _CenterOverlayMode.loading ||
                    (_centerOverlayMode == _CenterOverlayMode.hidden &&
                        (hasFeedback || hasLongPressSpeedOverlay))
                ? EdgeInsets.zero
                : EdgeInsets.only(
                    top: _topControlsExtent,
                    bottom: _bottomControlsExtent,
                  ),
          );

          Widget child = const SizedBox.shrink();
          switch (_centerOverlayMode) {
            case _CenterOverlayMode.hidden:
              child = secondaryOverlay != null
                  ? _buildCenteredOverlayOnly(
                      child: secondaryOverlay,
                      estimatedHeight: secondaryOverlayHeight,
                    )
                  : const SizedBox.shrink();
              break;
            case _CenterOverlayMode.transport:
              child = _buildTransportOverlay();
              break;
            case _CenterOverlayMode.loading:
              child = _buildCenteredStatusGroup(
                primary: _buildLoadingCard(),
                secondary: secondaryOverlay,
                secondaryEstimatedHeight: secondaryOverlayHeight,
              );
              break;
            case _CenterOverlayMode.error:
              child = _buildErrorOverlay();
              break;
          }

          return AnimatedPadding(
            duration: _overlayAnimationDuration,
            curve: Curves.easeOut,
            padding: overlayPadding,
            child: AnimatedSwitcher(
              duration: _overlayAnimationDuration,
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: KeyedSubtree(
                key: ValueKey(
                  '$_centerOverlayMode-$hasFeedback-$hasLongPressSpeedOverlay',
                ),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransportButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 56,
    double iconSize = 28,
    bool prominent = false,
  }) {
    final showBackground = prominent || _isFullscreen;
    final backgroundColor =
        prominent
            ? Colors.black.withValues(alpha: 0.34)
            : Colors.black.withValues(alpha: 0.20);
    final borderColor =
        prominent
            ? Colors.white.withValues(alpha: 0.22)
            : Colors.white.withValues(alpha: 0.12);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: showBackground ? backgroundColor : Colors.transparent,
          border:
              showBackground
                  ? Border.all(color: borderColor)
                  : null,
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: iconSize,
            color:
                prominent ? Colors.white : Colors.white.withValues(alpha: 0.94),
          ),
        ),
      ),
    );
  }

  Widget _buildFullscreenToolbarIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: _fullscreenTopActionHeight,
        height: _fullscreenTopActionHeight,
      ),
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.42),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.14),
          ),
        ),
      ),
      icon: Icon(
        icon,
        size: 20,
      ),
    );
  }

  Widget _buildFullscreenActionChip({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, _fullscreenTopActionHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: _fullscreenTopChipHorizontalPadding,
          vertical: 4,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(
          horizontal: -1,
          vertical: -1,
        ),
        backgroundColor: Colors.black.withValues(alpha: 0.42),
        disabledBackgroundColor: Colors.black.withValues(alpha: 0.22),
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.14),
          ),
        ),
      ),
      icon: Icon(icon, size: _fullscreenTopChipIconSize),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: _fullscreenTopChipFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBottomInlineButton({
    required IconData icon,
    VoidCallback? onTap,
    double iconSize = 22,
    double buttonWidth = 30,
    double buttonHeight = 30,
    AlignmentGeometry iconAlignment = Alignment.center,
    bool circularBackground = false,
  }) {
    final iconWidget = Align(
      alignment: iconAlignment,
      child: Icon(
        icon,
        size: iconSize,
        color:
            onTap == null
                ? Colors.white.withValues(alpha: 0.45)
                : Colors.white,
      ),
    );

    if (circularBackground) {
      return IconButton(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(
          width: buttonWidth,
          height: buttonHeight,
        ),
        onPressed: onTap,
        style: IconButton.styleFrom(
          backgroundColor: Colors.black.withValues(alpha: 0.42),
          disabledBackgroundColor: Colors.black.withValues(alpha: 0.22),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white.withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
        ),
        icon: iconWidget,
      );
    }

    return IconButton(
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(
        width: buttonWidth,
        height: buttonHeight,
      ),
      onPressed: onTap,
      icon: iconWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) {
          _rememberDiscreteGestureEligibility(details.localPosition);
        },
        onTap: () {
          if (!_discreteGestureAllowed) return;
          _clearDiscreteGestureEligibility();
          _resetGestureTracking();
          _toggleControls();
        },
        onTapCancel: _handleTapCancel,
        onDoubleTapDown: (details) {
          _rememberDiscreteGestureEligibility(details.localPosition);
        },
        onDoubleTap: () {
          if (!_discreteGestureAllowed) return;
          _clearDiscreteGestureEligibility();
          _resetGestureTracking();
          unawaited(_onPlayPause());
        },
        onLongPressStart: (details) async {
          if (!_canHandleBackgroundGestureAt(details.localPosition) ||
              _gestureMode != _GestureMode.pending) {
            return;
          }
          final controller = _controller;
          if (controller == null || !_canInteractWithPlayback || !_playing) {
            return;
          }
          _clearDiscreteGestureEligibility();
          _gestureMode = _GestureMode.longPressSpeed;
          _tempPlaybackSpeed = _rate;
          _resumePlaybackAfterLongPress = controller.value.isPlaying;
          await controller.setPlaybackSpeed(_maxPlaybackRate);
          if (_resumePlaybackAfterLongPress && !controller.value.isPlaying) {
            await controller.play();
          }
          _setLongPressSpeedOverlayVisible(true);
        },
        onLongPressEnd: (_) async {
          await _finishLongPressSpeedGesture();
        },
        child: Stack(
          children: [
            _buildPausedBackdrop(),
            _buildBottomScrim(),
            _buildCenterOverlay(),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(),
            ),
          ],
        ),
      ),
    );
  }
}

Duration _clampDuration(Duration value, Duration min, Duration max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

String _formatDuration(Duration duration) {
  final totalSeconds = max(0, duration.inSeconds);
  final totalMinutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;

  return '${totalMinutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

String _formatPlaybackRate(double rate) {
  final normalized = rate == rate.roundToDouble()
      ? rate.toStringAsFixed(0)
      : rate
          .toStringAsFixed(2)
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
  return '${normalized}x';
}

class _EdgeToEdgeSliderTrackShape extends RoundedRectSliderTrackShape {
  const _EdgeToEdgeSliderTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 0;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    return Rect.fromLTWH(
      offset.dx,
      trackTop,
      parentBox.size.width,
      trackHeight,
    );
  }
}
