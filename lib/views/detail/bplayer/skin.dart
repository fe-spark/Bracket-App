// ignore: implementation_imports
import 'package:better_player_plus/src/configuration/better_player_controls_configuration.dart';
// ignore: implementation_imports
import 'package:better_player_plus/src/controls/better_player_clickable_widget.dart';
// ignore: implementation_imports
import 'package:better_player_plus/src/controls/better_player_controls_state.dart';
// ignore: implementation_imports
import 'package:better_player_plus/src/controls/better_player_material_progress_bar.dart';
// ignore: implementation_imports
import 'package:better_player_plus/src/controls/better_player_multiple_gesture_detector.dart';
// ignore: implementation_imports
import 'package:better_player_plus/src/controls/better_player_progress_colors.dart';
// ignore: implementation_imports
import 'package:better_player_plus/src/core/better_player_controller.dart';
// ignore: implementation_imports
import 'package:better_player_plus/src/core/better_player_utils.dart';
// ignore: implementation_imports
import 'package:better_player_plus/src/video_player/video_player.dart';
import '/utils/bv_utils.dart';
import '/plugins.dart';

import 'percentage.dart';

class BetterPlayerMaterialControls extends StatefulWidget {
  ///Callback used to send information if player bar is hidden or not
  final Function(bool visbility) onControlsVisibilityChanged;

  ///Controls config
  final BetterPlayerControlsConfiguration controlsConfiguration;

  final Widget title;
  final Function? onPrev;
  final Function? onNext;

  const BetterPlayerMaterialControls({
    super.key,
    required this.title,
    required this.onControlsVisibilityChanged,
    required this.controlsConfiguration,
    this.onPrev,
    this.onNext,
  });

  @override
  State<StatefulWidget> createState() {
    return _BetterPlayerMaterialControlsState();
  }
}

class _BetterPlayerMaterialControlsState
    extends BetterPlayerControlsState<BetterPlayerMaterialControls> {
  VideoPlayerValue? _latestValue;
  double? _latestVolume;
  Timer? _hideTimer;
  Timer? _initTimer;
  Timer? _showAfterExpandCollapseTimer;
  bool _displayTapped = false;
  bool _wasLoading = false;

  bool _varTouchInitSuc = false;
  bool _isDargVerLeft = false;
  double _updatePrevDy = 0;
  double _updateDargVarVal = 0;
  double _tempPlaybackSpeed = 1.0;

  VideoPlayerController? _controller;
  BetterPlayerController? _betterPlayerController;
  StreamSubscription? _controlsVisibilityStreamSubscription;
  final PercentageWidget _percentageWidget = PercentageWidget();

  BetterPlayerControlsConfiguration get _controlsConfiguration =>
      widget.controlsConfiguration;

  @override
  VideoPlayerValue? get latestValue => _latestValue;

  @override
  BetterPlayerController? get betterPlayerController => _betterPlayerController;

  @override
  BetterPlayerControlsConfiguration get betterPlayerControlsConfiguration =>
      _controlsConfiguration;

  @override
  Widget build(BuildContext context) {
    // return _buildMainWidget();
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        Rect rect = Rect.fromLTRB(
          0,
          0,
          width,
          height,
        );

        return Stack(
          children: [
            Positioned.fromRect(
              rect: rect,
              child: _buildMainWidget(),
            )
          ],
        );
      },
    );
  }

  static Future<double> getVolume() async {
    return await BVUtils.volume;
  }

  // 设置音量
  static Future<void> setVolume(double volume) async {
    return await BVUtils.setVolume(volume);
  }

  // 获取亮度
  static Future<double> getBrightness() async {
    return await BVUtils.brightness;
  }

  // 设置亮度
  static Future<void> setBrightness(double brightness) async {
    return await BVUtils.setBrightness(brightness);
  }

  static Future<void> resetCustomBrightness() async {
    return await BVUtils.resetCustomBrightness();
  }

  @override
  bool isLoading(VideoPlayerValue? latestValue) {
    if (latestValue != null) {
      if (!latestValue.isPlaying && latestValue.duration == null) {
        return true;
      }

      final Duration position = latestValue.position;

      Duration? bufferedEndPosition;
      if (latestValue.buffered.isNotEmpty == true) {
        bufferedEndPosition = latestValue.buffered.last.end;
      }

      if (bufferedEndPosition != null) {
        final difference = bufferedEndPosition - position;

        if (latestValue.isPlaying &&
            latestValue.isBuffering &&
            difference.inSeconds <= 1) {
          return true;
        }
      }
    }
    return false;
  }

  ///Builds main widget of the controls.
  Widget _buildMainWidget() {
    _wasLoading = isLoading(_latestValue);

    return GestureDetector(
      key: const Key("BetterPlayerSkin"),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (BetterPlayerMultipleGestureDetector.of(context) != null) {
          BetterPlayerMultipleGestureDetector.of(context)!.onTap?.call();
        }
        controlsNotVisible
            ? cancelAndRestartTimer()
            : changePlayerControlsNotVisible(true);
      },
      onDoubleTap: () {
        if (BetterPlayerMultipleGestureDetector.of(context) != null) {
          BetterPlayerMultipleGestureDetector.of(context)!.onDoubleTap?.call();
        }
        if (betterPlayerController?.isFullScreen == true) {
          betterPlayerController?.exitFullScreen();
        } else {
          betterPlayerController?.enterFullScreen();
        }
      },

      onLongPressStart: (detail) {
        // _accelerating = true;
        // print(betterPlayerController?.videoPlayerController?.value.speed);
        double nowPlaybackSpeed = 2.0;

        _tempPlaybackSpeed =
            betterPlayerController?.videoPlayerController?.value.speed ?? 1.0;

        betterPlayerController?.setSpeed(nowPlaybackSpeed);
        _percentageWidget.percentageCallback('2.0x');
      },
      onLongPressEnd: (detail) {
        betterPlayerController?.setSpeed(_tempPlaybackSpeed);
        _percentageWidget.offstageCallback(true);
      },
      onVerticalDragStart: (DragStartDetails details) async {
        double clientW = context.size!.width;
        double curTouchPosX = details.globalPosition.dx;

        setState(() {
          // 更新位置
          _updatePrevDy = details.globalPosition.dy;
          // 是否左边
          _isDargVerLeft = (curTouchPosX > (clientW / 2)) ? false : true;
        });

        if (!_isDargVerLeft) {
          await getVolume().then((double v) {
            _varTouchInitSuc = true;
            setState(() {
              _updateDargVarVal = v;
            });
          });
        } else {
          // 亮度
          await getBrightness().then((double v) {
            _varTouchInitSuc = true;
            setState(() {
              _updateDargVarVal = v;
            });
          });
        }
      }, // 根据起始位置。确定是调整亮度还是调整声音
      onVerticalDragUpdate: (DragUpdateDetails details) async {
        if (!_varTouchInitSuc) return;
        double curDragDy = details.globalPosition.dy;
        // 确定当前是前进或者后退
        int cdy = curDragDy.toInt();
        int pdy = _updatePrevDy.toInt();
        bool isBefore = cdy < pdy;
        // + -, 不满足, 上下滑动合法滑动值，> 3
        if (isBefore && pdy - cdy < 3 || !isBefore && cdy - pdy < 3) return;
        // 区间
        double dragRange =
            isBefore ? _updateDargVarVal + 0.03 : _updateDargVarVal - 0.03;
        // 是否溢出
        if (dragRange > 1) {
          dragRange = 1.0;
        }
        if (dragRange < 0) {
          dragRange = 0.0;
        }
        setState(() {
          _updatePrevDy = curDragDy;
          _varTouchInitSuc = true;
          _updateDargVarVal = dragRange;
          // 音量
          if (!_isDargVerLeft) {
            setVolume(dragRange);
            _percentageWidget
                .percentageCallback('音量：${(dragRange * 100).toInt()}%');
          } else {
            setBrightness(dragRange);
            _percentageWidget
                .percentageCallback('亮度：${(dragRange * 100).toInt()}%');
          }
        });
      }, // 一般在更新的时候，同步调整亮度或声音
      onVerticalDragEnd: (_) {
        _percentageWidget.offstageCallback(true);
        setState(() {
          _varTouchInitSuc = false;
        });
      },
      child: AbsorbPointer(
        absorbing: controlsNotVisible,
        child: Stack(
          children: [
            if (_wasLoading)
              Center(child: _buildLoadingWidget())
            else
              _buildHitArea(),
            _percentageWidget,
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(),
            ),
            Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
            // _buildNextVideoWidget(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    _controller?.removeListener(_updateState);
    _hideTimer?.cancel();
    _initTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
    _controlsVisibilityStreamSubscription?.cancel();
    resetCustomBrightness();
  }

  @override
  void didChangeDependencies() {
    final oldController = _betterPlayerController;
    _betterPlayerController = BetterPlayerController.of(context);
    _controller = _betterPlayerController!.videoPlayerController;
    _latestValue = _controller!.value;

    if (oldController != _betterPlayerController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  Widget _buildErrorWidget() {
    final errorBuilder =
        _betterPlayerController!.betterPlayerConfiguration.errorBuilder;
    if (errorBuilder != null) {
      return errorBuilder(
          context,
          _betterPlayerController!
              .videoPlayerController!.value.errorDescription);
    } else {
      final textStyle = TextStyle(color: _controlsConfiguration.textColor);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              color: _controlsConfiguration.iconsColor,
              size: 42,
            ),
            Text(
              _betterPlayerController!.translations.generalDefaultError,
              style: textStyle,
            ),
            if (_controlsConfiguration.enableRetry)
              TextButton(
                onPressed: () {
                  _betterPlayerController!.retryDataSource();
                },
                child: Text(
                  _betterPlayerController!.translations.generalRetry,
                  style: textStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              )
          ],
        ),
      );
    }
  }

  Widget _buildTopBar() {
    if (!betterPlayerController!.controlsEnabled) {
      return const SizedBox();
    }

    var fullScreenAspectRatio = _betterPlayerController
            ?.betterPlayerConfiguration.fullScreenAspectRatio ??
        1.0;
    var videoAspectRatio =
        _betterPlayerController?.videoPlayerController?.value.aspectRatio ??
            1.0;
    final isFullScreen = _betterPlayerController?.isFullScreen == true;

    return SafeArea(
      top: videoAspectRatio < fullScreenAspectRatio,
      bottom: false,
      left: isFullScreen,
      right: isFullScreen,
      child: (_controlsConfiguration.enableOverflowMenu)
          ? AnimatedOpacity(
              opacity:
                  controlsNotVisible && _betterPlayerController!.isFullScreen
                      ? 0.0
                      : 1.0,
              duration: _controlsConfiguration.controlsHideTime,
              onEnd: _onPlayerHide,
              child: SizedBox(
                height: _controlsConfiguration.controlBarHeight,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: betterPlayerController?.isFullScreen == true
                      ? [
                          BackButton(
                            color: Colors.white,
                            onPressed: () {
                              betterPlayerController?.exitFullScreen();
                            },
                          ),
                          Expanded(flex: 1, child: widget.title),
                          widget.onPrev != null
                              ? _buildNextOrPrevButton(
                                  Icon(
                                    Icons.skip_previous,
                                    color: _controlsConfiguration.iconsColor,
                                  ),
                                  widget.onPrev,
                                )
                              : const SizedBox(),
                          const SizedBox(
                            width: 12,
                          ),
                          widget.onNext != null
                              ? _buildNextOrPrevButton(
                                  Icon(
                                    Icons.skip_next,
                                    color: _controlsConfiguration.iconsColor,
                                  ),
                                  widget.onNext,
                                )
                              : const SizedBox(),
                          const SizedBox(
                            width: 12,
                          ),
                          _buildMoreButton(),
                        ]
                      : [],
                ),
              ),
            )
          : const SizedBox(),
    );
  }

  Widget _buildMoreButton() {
    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        onShowMoreClicked();
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          _controlsConfiguration.overflowMenuIcon,
          color: _controlsConfiguration.iconsColor,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (!betterPlayerController!.controlsEnabled) {
      return const SizedBox();
    }
    final isFullScreen = _betterPlayerController?.isFullScreen == true;

    return SafeArea(
      top: false,
      bottom: isFullScreen,
      left: isFullScreen,
      right: isFullScreen,
      child: AnimatedOpacity(
        opacity: controlsNotVisible ? 0.0 : 1.0,
        duration: _controlsConfiguration.controlsHideTime,
        onEnd: _onPlayerHide,
        child: SizedBox(
          height: _controlsConfiguration.controlBarHeight + 16,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: _controlsConfiguration.enableProgressBar
                      ? _buildProgressBar()
                      : const SizedBox(),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      if (_controlsConfiguration.enablePlayPause)
                        _buildPlayPause(_controller!)
                      else
                        const SizedBox(),
                      if (_betterPlayerController!.isLiveStream())
                        _buildLiveWidget()
                      else
                        _controlsConfiguration.enableProgressText
                            ? _buildPosition()
                            : const SizedBox(),
                      const Spacer(),
                      if (_controlsConfiguration.enableMute)
                        _buildMuteButton(_controller)
                      else
                        const SizedBox(),
                      if (_controlsConfiguration.enableFullscreen)
                        _buildExpandButton()
                      else
                        const SizedBox(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveWidget() {
    return Padding(
        padding: const EdgeInsets.only(left: 22),
        child: Text(
          _betterPlayerController!.translations.controlsLive,
          style: TextStyle(
              color: _controlsConfiguration.liveTextColor,
              fontWeight: FontWeight.bold),
        ));
  }

  Widget _buildExpandButton() {
    return BetterPlayerMaterialClickableWidget(
      onTap: _onExpandCollapse,
      child: AnimatedOpacity(
        opacity: controlsNotVisible ? 0.0 : 1.0,
        duration: _controlsConfiguration.controlsHideTime,
        child: Container(
          height: _controlsConfiguration.controlBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Center(
            child: Icon(
              _betterPlayerController!.isFullScreen
                  ? _controlsConfiguration.fullscreenDisableIcon
                  : _controlsConfiguration.fullscreenEnableIcon,
              color: _controlsConfiguration.iconsColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHitArea() {
    if (!betterPlayerController!.controlsEnabled) {
      return const SizedBox();
    }
    return Center(
      child: AnimatedOpacity(
        opacity: controlsNotVisible ? 0.0 : 1.0,
        duration: _controlsConfiguration.controlsHideTime,
        child: _buildMiddleRow(),
      ),
    );
  }

  Widget _buildMiddleRow() {
    return Container(
      color: _controlsConfiguration.controlBarColor.withAlpha(155),
      width: double.infinity,
      height: double.infinity,
      child: _betterPlayerController?.isLiveStream() == true
          ? const SizedBox()
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_controlsConfiguration.enableSkips &&
                    betterPlayerController?.isFullScreen == true)
                  _buildSkipButton()
                else
                  const SizedBox(),
                _buildReplayButton(_controller!),
                if (_controlsConfiguration.enableSkips &&
                    betterPlayerController?.isFullScreen == true)
                  _buildForwardButton()
                else
                  const SizedBox(),
              ],
            ),
    );
  }

  Widget _buildHitAreaClickableButton(
      {Widget? icon, required void Function() onClicked}) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 80.0, maxWidth: 80.0),
      child: BetterPlayerMaterialClickableWidget(
        onTap: onClicked,
        child: Align(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(48),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Stack(
                children: [icon!],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return _buildHitAreaClickableButton(
      icon: Icon(
        _controlsConfiguration.skipBackIcon,
        size: 24,
        color: _controlsConfiguration.iconsColor,
      ),
      onClicked: skipBack,
    );
  }

  Widget _buildForwardButton() {
    return _buildHitAreaClickableButton(
      icon: Icon(
        _controlsConfiguration.skipForwardIcon,
        size: 24,
        color: _controlsConfiguration.iconsColor,
      ),
      onClicked: skipForward,
    );
  }

  Widget _buildReplayButton(VideoPlayerController controller) {
    final bool isFinished = isVideoFinished(_latestValue);
    return _buildHitAreaClickableButton(
      icon: isFinished
          ? Icon(
              Icons.replay,
              size: 42,
              color: _controlsConfiguration.iconsColor,
            )
          : Icon(
              controller.value.isPlaying
                  ? _controlsConfiguration.pauseIcon
                  : _controlsConfiguration.playIcon,
              size: 42,
              color: _controlsConfiguration.iconsColor,
            ),
      onClicked: () {
        if (isFinished) {
          if (_latestValue != null && _latestValue!.isPlaying) {
            if (_displayTapped) {
              changePlayerControlsNotVisible(true);
            } else {
              cancelAndRestartTimer();
            }
          } else {
            _onPlayPause();
            changePlayerControlsNotVisible(true);
          }
        } else {
          _onPlayPause();
        }
      },
    );
  }

  // Widget _buildNextVideoWidget() {
  //   return StreamBuilder<int?>(
  //     stream: _betterPlayerController!.nextVideoTimeStream,
  //     builder: (context, snapshot) {
  //       final time = snapshot.data;
  //       if (time != null && time > 0) {
  //         return BetterPlayerMaterialClickableWidget(
  //           onTap: () {
  //             _betterPlayerController!.playNextVideo();
  //           },
  //           child: Align(
  //             alignment: Alignment.bottomRight,
  //             child: Container(
  //               margin: EdgeInsets.only(
  //                   bottom: _controlsConfiguration.controlBarHeight + 20,
  //                   right: 24),
  //               decoration: BoxDecoration(
  //                 color: _controlsConfiguration.controlBarColor,
  //                 borderRadius: BorderRadius.circular(16),
  //               ),
  //               child: Padding(
  //                 padding: const EdgeInsets.all(12),
  //                 child: Text(
  //                   "${_betterPlayerController!.translations.controlsNextVideoIn} $time...",
  //                   style: const TextStyle(color: Colors.white),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         );
  //       } else {
  //         return const SizedBox();
  //       }
  //     },
  //   );
  // }

  Widget _buildNextOrPrevButton(Icon icon, Function? onTap) {
    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        cancelAndRestartTimer();
        onTap?.call();
      },
      child: AnimatedOpacity(
        opacity: controlsNotVisible ? 0.0 : 1.0,
        duration: _controlsConfiguration.controlsHideTime,
        child: ClipRect(
          child: Container(
            height: _controlsConfiguration.controlBarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: icon,
          ),
        ),
      ),
    );
  }

  Widget _buildMuteButton(
    VideoPlayerController? controller,
  ) {
    return BetterPlayerMaterialClickableWidget(
      onTap: () {
        cancelAndRestartTimer();
        if (_latestValue!.volume == 0) {
          _betterPlayerController!.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller!.value.volume;
          _betterPlayerController!.setVolume(0.0);
        }
      },
      child: AnimatedOpacity(
        opacity: controlsNotVisible ? 0.0 : 1.0,
        duration: _controlsConfiguration.controlsHideTime,
        child: ClipRect(
          child: Container(
            height: _controlsConfiguration.controlBarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Icon(
              (_latestValue != null && _latestValue!.volume > 0)
                  ? _controlsConfiguration.muteIcon
                  : _controlsConfiguration.unMuteIcon,
              color: _controlsConfiguration.iconsColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayPause(VideoPlayerController controller) {
    return BetterPlayerMaterialClickableWidget(
      key: const Key("better_player_material_controls_play_pause_button"),
      onTap: _onPlayPause,
      child: ClipRect(
        child: Container(
          height: _controlsConfiguration.controlBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Icon(
            controller.value.isPlaying
                ? _controlsConfiguration.pauseIcon
                : _controlsConfiguration.playIcon,
            color: _controlsConfiguration.iconsColor,
          ),
        ),
      ),
    );
  }

  Widget _buildPosition() {
    final position =
        _latestValue != null ? _latestValue!.position : Duration.zero;
    final duration = _latestValue != null && _latestValue!.duration != null
        ? _latestValue!.duration!
        : Duration.zero;

    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
      ),
      child: RichText(
        text: TextSpan(
            text: BetterPlayerUtils.formatDuration(position),
            style: TextStyle(
              fontSize: 10.0,
              color: _controlsConfiguration.textColor,
              decoration: TextDecoration.none,
            ),
            children: <TextSpan>[
              TextSpan(
                text: ' / ${BetterPlayerUtils.formatDuration(duration)}',
                style: TextStyle(
                  fontSize: 10.0,
                  color: _controlsConfiguration.textColor,
                  decoration: TextDecoration.none,
                ),
              )
            ]),
      ),
    );
  }

  @override
  void cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    changePlayerControlsNotVisible(false);
    _displayTapped = true;
  }

  Future<void> _initialize() async {
    _controller!.addListener(_updateState);

    _updateState();

    if ((_controller!.value.isPlaying) ||
        _betterPlayerController!.betterPlayerConfiguration.autoPlay) {
      _startHideTimer();
    }

    if (_controlsConfiguration.showControlsOnInitialize) {
      _initTimer = Timer(const Duration(milliseconds: 200), () {
        changePlayerControlsNotVisible(false);
      });
    }

    _controlsVisibilityStreamSubscription =
        _betterPlayerController!.controlsVisibilityStream.listen((state) {
      changePlayerControlsNotVisible(!state);
      if (!controlsNotVisible) {
        cancelAndRestartTimer();
      }
    });
  }

  void _onExpandCollapse() {
    changePlayerControlsNotVisible(true);
    _betterPlayerController!.toggleFullScreen();
    _showAfterExpandCollapseTimer =
        Timer(_controlsConfiguration.controlsHideTime, () {
      setState(() {
        cancelAndRestartTimer();
      });
    });
  }

  void _onPlayPause() {
    bool isFinished = false;

    if (_latestValue?.position != null && _latestValue?.duration != null) {
      isFinished = _latestValue!.position >= _latestValue!.duration!;
    }

    if (_controller!.value.isPlaying) {
      changePlayerControlsNotVisible(false);
      _hideTimer?.cancel();
      _betterPlayerController!.pause();
    } else {
      cancelAndRestartTimer();

      if (!_controller!.value.initialized) {
      } else {
        if (isFinished) {
          _betterPlayerController!.seekTo(const Duration());
        }
        _betterPlayerController!.play();
        _betterPlayerController!.cancelNextVideoTimer();
      }
    }
  }

  void _startHideTimer() {
    if (_betterPlayerController!.controlsAlwaysVisible) {
      return;
    }
    _hideTimer = Timer(const Duration(milliseconds: 3000), () {
      changePlayerControlsNotVisible(true);
    });
  }

  void _updateState() {
    if (mounted) {
      if (!controlsNotVisible ||
          isVideoFinished(_controller!.value) ||
          _wasLoading ||
          isLoading(_controller!.value)) {
        setState(() {
          _latestValue = _controller!.value;
          if (isVideoFinished(_latestValue) &&
              _betterPlayerController?.isLiveStream() == false) {
            // changePlayerControlsNotVisible(false);
          }
        });
      }
    }
  }

  Widget _buildProgressBar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BetterPlayerMaterialVideoProgressBar(
        _controller,
        _betterPlayerController,
        onDragStart: () {
          _hideTimer?.cancel();
        },
        onDragEnd: () {
          _startHideTimer();
          // _controller?.refresh();
        },
        onTapDown: () {
          cancelAndRestartTimer();
        },
        colors: BetterPlayerProgressColors(
          playedColor: _controlsConfiguration.progressBarPlayedColor,
          handleColor: _controlsConfiguration.progressBarHandleColor,
          bufferedColor: _controlsConfiguration.progressBarBufferedColor,
          backgroundColor: _controlsConfiguration.progressBarBackgroundColor,
        ),
      ),
    );
  }

  void _onPlayerHide() {
    _betterPlayerController!.toggleControlsVisibility(!controlsNotVisible);
    widget.onControlsVisibilityChanged(!controlsNotVisible);
  }

  Widget? _buildLoadingWidget() {
    if (_latestValue?.hasError == true) {
      return _buildErrorWidget();
    }
    if (_controlsConfiguration.loadingWidget != null) {
      return Container(
        color: _controlsConfiguration.controlBarColor,
        child: _controlsConfiguration.loadingWidget,
      );
    }

    return CircularProgressIndicator(
      valueColor:
          AlwaysStoppedAnimation<Color>(_controlsConfiguration.loadingColor),
    );
  }
}
