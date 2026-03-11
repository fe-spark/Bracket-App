import 'package:better_player_plus/better_player_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '/model/film_play_info/detail.dart';

import '/plugins.dart';
import 'skin.dart';

class Player extends StatefulWidget {
  final double aspectRatio;
  final double fullScreenAspectRatio;
  final Detail? detail;
  const Player(
      {super.key,
      required this.aspectRatio,
      this.detail,
      required this.fullScreenAspectRatio});

  @override
  State createState() => _PlayerState();
}

class _PlayerState extends State<Player> with TickerProviderStateMixin {
  int? _originIndex;
  int? _teleplayIndex;
  // bool _ischanging = false;
  BetterPlayerController? _betterPlayerController;
  PlayVideoIdsStore? _playVideoIdsStore;
  HistoryStore? _historyStore;
  final _throttler = Throttler(milliseconds: 5000);

  @override
  void initState() {
    _playVideoIdsStore = context.read<PlayVideoIdsStore>();
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      fit: BoxFit.contain,
      allowedScreenSleep: true,
      aspectRatio: widget.aspectRatio,
      fullScreenAspectRatio: widget.fullScreenAspectRatio,
      autoDetectFullscreenDeviceOrientation: true,
      autoDetectFullscreenAspectRatio: false,
      deviceOrientationsOnFullScreen: [
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ],
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
      ],
      startAt: Duration(seconds: _playVideoIdsStore?.startAt ?? 0),
      autoPlay: true,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        playerTheme: BetterPlayerTheme.custom,
        customControlsBuilder: (BetterPlayerController controller,
            Function(bool) visibility,
            BetterPlayerControlsConfiguration configuration) {
          var list = widget.detail?.list;
          var originIndex = _playVideoIdsStore?.originIndex ?? 0;
          int? teleplayIndex = _playVideoIdsStore?.teleplayIndex;
          var linkList = list?[originIndex].linkList;

          bool hasNext = teleplayIndex != null &&
              linkList != null &&
              teleplayIndex < linkList.length - 1;
          bool hasPrev = teleplayIndex != null && teleplayIndex > 0;

          return BetterPlayerMaterialControls(
            title: Text(
              teleplayIndex != null && linkList != null
                  ? '${widget.detail?.name ?? ''}-${linkList[teleplayIndex].episode ?? ''}'
                  : '${widget.detail?.name ?? ''}-未选择',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            onControlsVisibilityChanged: visibility,
            onPrev: hasPrev ? _prev : null,
            onNext: hasNext ? _next : null,
            controlsConfiguration: const BetterPlayerControlsConfiguration(
              // loadingWidget: RiveLoading(),
              showControlsOnInitialize: true,
            ),
          );
        },
      ),
    );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      getCurrentUrl() ?? '',
    );
    _betterPlayerController = BetterPlayerController(
      betterPlayerConfiguration,
      betterPlayerDataSource: dataSource,
    );

    // _betterPlayerController
    //     ?.seekTo(Duration(seconds: _playVideoIdsStore?.startAt ?? 0));

    _betterPlayerController?.addEventsListener(_betterPlayerControllerListener);
    _playVideoIdsStore?.addListener(_changeDataSource);
    _historyStore = context.read<HistoryStore>();

    super.initState();
  }

  String? getCurrentUrl() {
    var list = widget.detail?.list;
    _playVideoIdsStore = context.read<PlayVideoIdsStore>();
    _originIndex = _playVideoIdsStore!.originIndex;
    _teleplayIndex = _playVideoIdsStore!.teleplayIndex;

    if (_teleplayIndex == null) return null;

    String? url = list?[_originIndex!].linkList?[_teleplayIndex!].link;

    return url;
  }

  void _changeDataSource() {
    var url = getCurrentUrl();

    if (url != null) {
      BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url,
      );

      _betterPlayerController?.setupDataSource(dataSource).then((value) {
        var playVideoIdsStore = context.read<PlayVideoIdsStore>();
        _betterPlayerController?.seekTo(
            Duration(seconds: playVideoIdsStore.startAt ?? 0));
      });
    }
  }

  void _betterPlayerControllerListener(BetterPlayerEvent e) async {
    if (e.betterPlayerEventType == BetterPlayerEventType.progress) {
      _throttler.run(() => _setHistory());
    } else if (e.betterPlayerEventType == BetterPlayerEventType.pause ||
        e.betterPlayerEventType == BetterPlayerEventType.finished) {
      _setHistory();
    }

    var isPlaying = _betterPlayerController?.isPlaying() == true;

    if (isPlaying) {
      bool isEnabled = await WakelockPlus.enabled;
      if (!isEnabled) WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  void _prev() {
    _playVideoIdsStore = context.read<PlayVideoIdsStore>();
    var originIndex = _playVideoIdsStore?.originIndex;
    var teleplayIndex = _playVideoIdsStore?.teleplayIndex;

    var prevIndex = teleplayIndex! - 1;
    _playVideoIdsStore?.setVideoInfo(
      originIndex,
      teleplayIndex: prevIndex,
      startAt: 0,
    );
  }

  void _next() {
    _playVideoIdsStore = context.read<PlayVideoIdsStore>();
    var originIndex = _playVideoIdsStore?.originIndex;
    var teleplayIndex = _playVideoIdsStore?.teleplayIndex;
    var nextIndex = teleplayIndex! + 1;

    _playVideoIdsStore?.setVideoInfo(
      originIndex,
      teleplayIndex: nextIndex,
      startAt: 0,
    );
  }

  void _setHistory() {
    var videoPlayerController = _betterPlayerController?.videoPlayerController;
    var detail = widget.detail;
    var list = detail?.list;
    var teleplayIndex = _playVideoIdsStore?.teleplayIndex ?? 0;
    var originIndex = _playVideoIdsStore?.originIndex ?? 0;

    var position = videoPlayerController?.value.position.inSeconds ?? 0;

    _historyStore?.addHistory({
      'id': detail?.id,
      "name": detail?.name,
      "timeStamp": DateTime.now().microsecondsSinceEpoch,
      "picture": detail?.picture,
      "originId": list?[originIndex].id,
      "teleplayIndex": teleplayIndex,
      'startAt': position,
    });
  }

  @override
  void didChangeDependencies() {
    _playVideoIdsStore = context.read<PlayVideoIdsStore>();
    _historyStore = context.read<HistoryStore>();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _setHistory();
    _betterPlayerController
        ?.removeEventsListener(_betterPlayerControllerListener);
    _playVideoIdsStore?.removeListener(_changeDataSource);
    _betterPlayerController?.dispose();
    _throttler.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Player oldWidget) {
    super.didUpdateWidget(oldWidget);

    // if (oldWidget.detail != widget.detail) {
    //   _changeDataSource();
    // }

    if (oldWidget.aspectRatio != widget.aspectRatio) {
      _betterPlayerController?.setOverriddenAspectRatio(widget.aspectRatio);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BetterPlayer(controller: _betterPlayerController!);
  }
}
