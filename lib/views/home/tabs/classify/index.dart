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

  double _responsiveValue({
    required double compact,
    required double regular,
    required double viewportHeight,
  }) {
    const compactHeight = 390.0;
    const regularHeight = 844.0;
    final t =
        ((viewportHeight - compactHeight) / (regularHeight - compactHeight))
            .clamp(0.0, 1.0);
    return compact + (regular - compact) * t;
  }

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
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final headerRadius = _responsiveValue(
      compact: 24,
      regular: 32,
      viewportHeight: viewportHeight,
    );
    final expandedHeight = _responsiveValue(
      compact: 104,
      regular: 140,
      viewportHeight: viewportHeight,
    );
    final titlePadding = EdgeInsets.only(
      left: _responsiveValue(
        compact: 16,
        regular: 20,
        viewportHeight: viewportHeight,
      ),
      bottom: _responsiveValue(
        compact: 12,
        regular: 16,
        viewportHeight: viewportHeight,
      ),
    );
    final collapsedTitleSize = _responsiveValue(
      compact: 20,
      regular: 24,
      viewportHeight: viewportHeight,
    );
    final expandedTitleSize = _responsiveValue(
      compact: 32,
      regular: 44,
      viewportHeight: viewportHeight,
    );
    final titleStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: collapsedTitleSize,
      shadows: const [
        Shadow(
          offset: Offset(0, 1),
          blurRadius: 4,
          color: Colors.black45,
        ),
      ],
    );
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
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(headerRadius),
                  ),
                ),
                expandedHeight: expandedHeight,
                pinned: true,
                stretch: true,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  centerTitle: false,
                  expandedTitleScale: expandedTitleSize / collapsedTitleSize,
                  titlePadding: titlePadding,
                  title: Text(
                    '影片分类',
                    style: titleStyle,
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(headerRadius),
                        ),
                        child: Image.asset(
                          'assets/images/header.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Gradient Overlay: Fades to Primary Theme Color
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(headerRadius),
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

  Widget _listContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomNavigationInset = MediaQuery.paddingOf(context).bottom;
    final categories = _data?.category?.children
            ?.where((e) => e.children != null && e.children!.isNotEmpty)
            .toList() ??
        [];

    return SafeArea(
      top: false,
      bottom: false,
      child: MediaQuery.removePadding(
        context: context,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(16, 24, 16, bottomNavigationInset),
          children: [
            ...categories.asMap().entries.map(
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
                    const SizedBox(height: 24),
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
