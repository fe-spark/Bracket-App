import '/model/index/data.dart';

import '/plugins.dart';

class ClassifyTab extends StatefulWidget {
  const ClassifyTab({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ClassifyTabState();
  }
}

class _ClassifyTabState extends State<ClassifyTab>
    with AutomaticKeepAliveClientMixin {
  // late TabController _tabController;
  late ScrollController _scrollViewController;
  Data? _data;
  bool _loading = false;
  bool _error = false;

  // List<Content> get _content {
  //   return _data?.content ?? [];
  // }

  Future _fetchData({bool refresh = false}) async {
    if (!refresh) {
      setState(() {
        _loading = true;
        _error = false;
      });
    } else {
      await Future.delayed(const Duration(seconds: 1));
    }
    if (!mounted) return;
    var res = await Api.index(
      context: context,
    );

    if (res != null && res.runtimeType != String) {
      Recommend jsonData = Recommend.fromJson(res);
      setState(() {
        _loading = false;
        _error = false;
        _data = jsonData.data;
      });
    } else {
      // await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    _fetchData();
    // _tabController = TabController(length: 6, vsync: this);
    _scrollViewController = ScrollController();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    // _tabController.dispose();
    _scrollViewController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String? name) {
    if (name == null) return Icons.widgets_rounded;
    if (name.contains('电影')) return Icons.movie_creation_rounded;
    if (name.contains('剧')) return Icons.tv_rounded;
    if (name.contains('漫')) return Icons.animation_rounded;
    if (name.contains('综')) return Icons.mic_external_on_rounded;
    if (name.contains('录') || name.contains('纪')) return Icons.videocam_rounded;
    return Icons.category_rounded;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                  side: BorderSide(
                    color: colorScheme.primary.withValues(alpha: 0.5),
                    width: 4,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
                expandedHeight: 140.0,
                pinned: true,
                stretch: true,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: const Text(
                    '影片分类',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 4,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(32),
                        ),
                        child: Image.asset(
                          'assets/images/header.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Gradient Overlay: Fades to Primary Theme Color
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(32),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              colorScheme.primary.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: RefreshIndicator(
            color: Colors.white,
            backgroundColor: colorScheme.primary,
            onRefresh: () => _fetchData(refresh: true),
            child: LoadingViewBuilder(
              loading: _loading,
              builder: (_) {
                return _error
                    ? Error(
                        onRefresh: _fetchData,
                      )
                    : _listContent(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _listContent(_) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      bottom: true,
      child: MediaQuery.removePadding(
        context: context,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            ...?_data?.category?.children!.asMap().entries.map(
              (entry) {
                int index = entry.key;
                var e = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, left: 4),
                      child: GestureDetector(
                        onTap: () {
                          // Navigator.of(context).pushNamed(
                          //   MYRouter.filterPagePath,
                          //   arguments: {
                          //     "pid": e.id,
                          //   },
                          // );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(e.name),
                              color: colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              e.name ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            // const SizedBox(width: 4),
                            // Icon(
                            //   Icons.arrow_forward_ios_rounded,
                            //   size: 14,
                            //   color: colorScheme.onSurface.withValues(alpha: 0.5),
                            // ),
                          ],
                        ),
                      ),
                    ),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.4,
                      padding: const EdgeInsets.only(top: 4),
                      children: e.children!.map(
                        (item) {
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                MYRouter.filterPagePath,
                                arguments: {"pid": e.id, "category": item.id},
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(12),
                                // No shadow for cleaner "Flat Tile" look, or keeping it subtle
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.shadow
                                        .withValues(alpha: 0.05),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                item.name ?? '',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                    // 最后一个不要
                    if (index != _data!.category!.children!.length - 1)
                      const SizedBox(height: 32), // Space between sections
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
