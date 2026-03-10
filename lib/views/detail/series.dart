import 'package:flutter_html/flutter_html.dart';
import '/widgets/expandable.dart';
import '/model/film_play_info/data.dart';
import '/model/film_play_info/detail.dart';
import '/model/film_play_info/list.dart';
import '/plugins.dart';

class Series extends StatefulWidget {
  final Data? data;

  const Series({
    super.key,
    required this.data,
  });

  @override
  State<Series> createState() => _SeriesState();
}

class _SeriesState extends State<Series> {
  _SeriesState();
  final smoothExpandableKey = GlobalKey<SmoothExpandableState>();
  bool _isOpen = false;
  int _selectedGroupIndex = 0;
  int? _lastTeleplayIndex;
  int? _viewOriginIndex;
  
  final ScrollController _scrollController = ScrollController();
  final ScrollController _groupScrollController = ScrollController();
  final GlobalKey _activeEpisodeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveItem(immediate: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _groupScrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveItem({bool immediate = false}) {
    if (!mounted) return;

    // 1. Scroll main view to the active episode
    if (_activeEpisodeKey.currentContext != null) {
      Scrollable.ensureVisible(
        _activeEpisodeKey.currentContext!,
        duration: immediate ? Duration.zero : const Duration(milliseconds: 300),
        alignment: 0.5,
      );
    }

    // 2. Scroll group bar to active group
    if (_groupScrollController.hasClients) {
      // Approximate calculation: each group item is around 80px wide
      double targetOffset = (_selectedGroupIndex * 80.0) - 100.0;
      targetOffset = targetOffset.clamp(0, _groupScrollController.position.maxScrollExtent);
      
      _groupScrollController.animateTo(
        targetOffset,
        duration: immediate ? Duration.zero : const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var info = context.watch<PlayVideoIdsStore>();
    Detail? detail = widget.data?.detail;
    List<ListData?>? list = detail?.list;
    int? activeOriginIndex = info.originIndex;
    int? teleplayIndex = info.teleplayIndex;
    
    // Initial view sync or sync if active origin changed and we haven't manually switched view
    _viewOriginIndex ??= activeOriginIndex;
    
    var linkList = list?[_viewOriginIndex!]?.linkList ?? [];

    const int groupSize = 100;
    bool needsGrouping = linkList.length > groupSize;

    // Auto-sync group index with currently playing teleplay index
    if (teleplayIndex != _lastTeleplayIndex) {
      _lastTeleplayIndex = teleplayIndex;
      if (teleplayIndex != null && needsGrouping) {
        _selectedGroupIndex = teleplayIndex ~/ groupSize;
        // Trigger scroll when index changes
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActiveItem());
      }
    }

    int groupCount = (linkList.length / groupSize).ceil();

    // Ensure _selectedGroupIndex is within valid range after source switch
    if (_selectedGroupIndex >= groupCount) {
      _selectedGroupIndex = 0;
    }
    int groupStart = _selectedGroupIndex * groupSize;
    int groupEnd = (groupStart + groupSize).clamp(0, linkList.length);
    var visibleEpisodes = linkList.sublist(groupStart, groupEnd);

    return LoadingViewBuilder(
      loading: list == null,
      builder: (_) => MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                detail?.name ?? '',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                (detail?.descriptor?.subTitle == "" ||
                                        detail?.descriptor?.subTitle == null)
                                    ? '暂无数据'
                                    : (detail?.descriptor?.subTitle ?? '暂无数据'),
                                style: TextStyle(
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: _isOpen
                            ? const Icon(Icons.expand_less)
                            : const Icon(Icons.expand_more),
                        onPressed: () {
                          smoothExpandableKey.currentState?.toggle();
                        },
                      )
                    ],
                  ),
                  SmoothExpandable(
                    key: smoothExpandableKey,
                    onExpandChanged: (value) {
                      setState(() {
                        _isOpen = value;
                      });
                    },
                    child: Card(
                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                      child: Html(
                        data: detail?.descriptor?.content ?? '暂无介绍',
                      ),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 12,
                  ),
                  if (list != null)
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 8,
                        children: list.mapIndexed((i, e) {
                          return ChoiceChip(
                              label: Text(e?.name ?? '未知源'),
                              selected: _viewOriginIndex == i,
                              onSelected: (_) {
                                setState(() {
                                  _viewOriginIndex = i;
                                });
                              });
                        }).toList(),
                      ),
                    ),
                ]),
              ),
            ),
            if (needsGrouping)
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyGroupDelegate(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        controller: _groupScrollController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(groupCount, (index) {
                            int start = index * groupSize + 1;
                            int end = ((index + 1) * groupSize)
                                .clamp(0, linkList.length);
                            bool isSelected = _selectedGroupIndex == index;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 4),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedGroupIndex = index;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Text(
                                    '$start-$end',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Colors.white
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: list?[_viewOriginIndex!] != null && linkList.isNotEmpty
                            ? LayoutBuilder(
                                builder: (context, constraints) {
                                  final containerWidth = constraints.maxWidth;
                                  const spacing = 10.0;
                                  // 计算单个item的基础宽度（4列）
                                  final baseWidth =
                                      (containerWidth - spacing * 3) / 4;

                                  return Wrap(
                                    spacing: spacing,
                                    runSpacing: spacing,
                                    children:
                                        visibleEpisodes.mapIndexed((i, e) {
                                      final colorScheme =
                                          Theme.of(context).colorScheme;

                                      final absoluteIndex = groupStart + i;
                                      final isSelected =
                                          _viewOriginIndex == activeOriginIndex &&
                                          absoluteIndex == teleplayIndex;
                                      final text = '${e.episode}';

                                      // 根据文本长度决定宽度
                                      double itemWidth;
                                      bool needsScroll = false;

                                      if (text.length <= 4) {
                                        // 短文本：1/4宽度
                                        itemWidth = baseWidth;
                                      } else if (text.length <= 8) {
                                        // 中等文本：1/2宽度
                                        itemWidth = baseWidth * 2 + spacing;
                                      } else {
                                        // 长文本：全宽
                                        itemWidth = containerWidth;
                                        // 超过12字符可能需要滚动
                                        if (text.length > 12) {
                                          needsScroll = true;
                                        }
                                      }

                                      return SizedBox(
                                        key: isSelected ? _activeEpisodeKey : null,
                                        width: itemWidth,
                                        child: InkWell(
                                          onTap: () {
                                            var historyStore =
                                                context.read<HistoryStore>();
                                            var historyData = historyStore.data;
                                            var currentOriginId =
                                                list?[_viewOriginIndex!]?.id;

                                            // Try to find progress for this specific episode in history
                                            var historyItem = historyData
                                                .firstWhereOrNull((item) =>
                                                    item['id'] == detail?.id &&
                                                    item['originId'] ==
                                                        currentOriginId &&
                                                    item['teleplayIndex'] ==
                                                        absoluteIndex);

                                            info.setVideoInfo(
                                              _viewOriginIndex,
                                              teleplayIndex: absoluteIndex,
                                              startAt:
                                                  historyItem?['startAt'] ?? 0,
                                            );
                                          },
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? colorScheme.primaryContainer
                                                  : colorScheme
                                                      .surfaceContainerHigh,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: isSelected
                                                  ? Border.all(
                                                      color:
                                                          colorScheme.primary,
                                                      width: 2)
                                                  : null,
                                            ),
                                            child: needsScroll
                                                ? SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Text(
                                                      text,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: isSelected
                                                            ? colorScheme
                                                                .onPrimaryContainer
                                                            : colorScheme
                                                                .onSurface,
                                                        fontWeight: isSelected
                                                            ? FontWeight.bold
                                                            : FontWeight.w500,
                                                      ),
                                                    ),
                                                  )
                                                : Text(
                                                    text,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: isSelected
                                                          ? colorScheme
                                                              .onPrimaryContainer
                                                          : colorScheme
                                                              .onSurface,
                                                      fontWeight: isSelected
                                                          ? FontWeight.bold
                                                          : FontWeight.w500,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              )
                            : const Center(
                                child: Text('暂无数据'),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyGroupDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyGroupDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 56.0;

  @override
  double get minExtent => 56.0;

  @override
  bool shouldRebuild(covariant _StickyGroupDelegate oldDelegate) {
    return true;
  }
}
