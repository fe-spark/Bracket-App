// import "/views/detail/related.dart";

import '/plugins.dart';
import "package:bracket/model/film_play_info/detail.dart";
import "/model/film_play_info/data.dart" show Data;
import "/model/film_play_info/film_play_info.dart" show FilmPlayInfo;
import "/views/detail/describe.dart" show Describe;
import "bplayer/airplay_button.dart"
    show AirPlayRoutePickerButton, AndroidCastMedia;
import "bplayer/player.dart" show Player;

import "series.dart";

class Utils {
  static Future<String> getFileUrl(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/$fileName";
  }
}

class DetailPage extends StatefulWidget {
  final Map? arguments;
  const DetailPage({super.key, this.arguments});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class MyTab {
  final Widget icon;
  final String label;
  final Key key;

  MyTab({required this.icon, required this.label, required this.key});
}

class _DetailPageState extends State<DetailPage> {
  final double _playerAspectRatio = 16 / 9;
  final List<MyTab> _tabs = [
    MyTab(icon: const Icon(Icons.abc_outlined), label: '详情', key: UniqueKey()),
    MyTab(
        icon: const Icon(Icons.abc_outlined), label: '相关推荐', key: UniqueKey()),
  ];

  Data? _data;

  Future _fetchData(id) async {
    var playIdsInfo = context.read<PlayVideoIdsStore>();
    var res = await Api.filmDetail(
      context: context,
      queryParameters: {
        'id': id,
      },
    );
    if (res != null && res.runtimeType != String) {
      FilmPlayInfo jsonData = FilmPlayInfo.fromJson(res);
      setState(() {
        _data = jsonData.data;
      });

      var item = getHistory(id);

      if (item != null) {
        var originId = item['originId'];
        var originIndex = _data?.detail?.list
            ?.indexWhere((element) => originId == element.id);

        playIdsInfo.setVideoInfo(
          (originIndex != null && originIndex >= 0) ? originIndex : 0,
          teleplayIndex: item['teleplayIndex'] ?? 0,
          startAt: item['startAt'] ?? 0,
        );
      } else {
        playIdsInfo.setVideoInfo(0, teleplayIndex: 0, startAt: 0);
      }
    }
  }

  Map<String, dynamic>? getHistory(id) {
    var data = context.read<HistoryStore>().data;
    var item = data.firstWhereOrNull((element) => element['id'] == id);

    return item;
  }

  AndroidCastMedia? _resolveAndroidCastMedia(
    Detail? detail,
    PlayVideoIdsStore playVideoIdsStore,
  ) {
    final list = detail?.list;
    if (detail == null || list == null || list.isEmpty) return null;

    final originIndex = playVideoIdsStore.originIndex.clamp(0, list.length - 1);
    final linkList = list[originIndex].linkList;
    if (linkList == null || linkList.isEmpty) return null;

    final teleplayIndex =
        (playVideoIdsStore.teleplayIndex ?? 0).clamp(0, linkList.length - 1);
    final playItem = linkList[teleplayIndex];
    final url = playItem.link;
    if (url == null || url.isEmpty) return null;

    final titleParts = <String>[
      if (detail.name?.trim().isNotEmpty ?? false) detail.name!.trim(),
      if (playItem.episode?.trim().isNotEmpty ?? false) playItem.episode!.trim(),
    ];
    final title = titleParts.join(' - ');
    final subtitle = list[originIndex].name;

    return AndroidCastMedia(
      url: url,
      title: title.isEmpty ? 'Bracket' : title,
      subtitle: subtitle,
      posterUrl: detail.picture,
    );
  }

  @override
  void initState() {
    int id = widget.arguments?['id'];
    super.initState();
    // _saveAssetVideoToFile();
    _fetchData(id);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Detail? detail = _data?.detail;
    final playVideoIdsStore = context.watch<PlayVideoIdsStore>();
    final androidCastMedia = _resolveAndroidCastMedia(detail, playVideoIdsStore);

    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: const Icon(Icons.expand),
      // ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Flex(
            direction: orientation == Orientation.portrait
                ? Axis.vertical
                : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: orientation == Orientation.portrait ? 0 : 1,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: SafeArea(
                    bottom: orientation != Orientation.portrait,
                    right: orientation == Orientation.portrait,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        Size size = MediaQuery.of(context).size;
                        double width = constraints.maxWidth;
                        double height = constraints.maxHeight;
                        double aspectRatio = orientation == Orientation.portrait
                            ? _playerAspectRatio
                            : width / height;
                        double fullScreenAspectRatio = size.width / size.height;

                        return Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: aspectRatio,
                              child: detail == null
                                  ? const RiveLoading()
                                  : Player(
                                      aspectRatio: aspectRatio,
                                      fullScreenAspectRatio:
                                          fullScreenAspectRatio,
                                      detail: detail,
                                    ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Row(
                                  children: [
                                    BackButton(
                                      color: Colors.white,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    const Spacer(),
                                     if (AirPlayRoutePickerButton.isSupported &&
                                         androidCastMedia != null)
                                       SizedBox.square(
                                         dimension: kMinInteractiveDimension,
                                         child: Center(
                                           child: AirPlayRoutePickerButton(
                                             size: 36,
                                             padding: const EdgeInsets.all(6),
                                             backgroundColor: const Color(
                                               0x59000000,
                                             ),
                                             androidMedia: androidCastMedia,
                                           ),
                                         ),
                                       ),
                                   ],
                                 ),
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              if (orientation == Orientation.portrait)
                Container(
                  height: 8,
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.4),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    width: 0.5,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              Expanded(
                flex: 1,
                child: SafeArea(
                  top: false,
                  left: orientation == Orientation.portrait,
                  child: DefaultTabController(
                    length: _tabs.length,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TabBar(
                          tabAlignment: TabAlignment.start,
                          isScrollable: true,
                          tabs: _tabs
                              .map<Tab>(
                                (MyTab e) => Tab(
                                  key: e.key,
                                  child: Text(
                                    e.label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        Expanded(
                          flex: 1,
                          child: TabBarView(
                            children: [
                              Series(data: _data),
                              Describe(data: _data),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
