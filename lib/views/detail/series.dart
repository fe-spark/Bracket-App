import 'package:flutter_html/flutter_html.dart';
import '/widgets/expandable.dart';
import '/model/film_play_info/data.dart';
import '/model/film_play_info/detail.dart';
import '/model/film_play_info/list.dart';
import '/plugins.dart';

const _episodeTileSpacing = 10.0;
const _episodeTileHorizontalPadding = 12.0;
const _episodeTileVerticalPadding = 10.0;
const _episodeTileSelectedBorderWidth = 2.0;
const _episodeTileMinHeight = 44.0;

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
  final Map<int, int> _selectedGroupIndexBySource = {};
  int? _lastTeleplayIndex;
  int? _lastActiveOriginIndex;
  int? _viewOriginIndex;
  bool _lastDataNonNull = false;

  final ScrollController _scrollController = ScrollController();
  final ScrollController _groupScrollController = ScrollController();
  final ScrollController _sourceScrollController = ScrollController();
  final GlobalKey _activeEpisodeKey = GlobalKey();
  final Map<int, GlobalKey> _sourceKeyMap = {};
  final Map<int, GlobalKey> _groupKeyMap = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveItem(immediate: true);
    });
  }

  @override
  void didUpdateWidget(Series oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If data just arrived, trigger scroll
    if (oldWidget.data == null && widget.data != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActiveItem(immediate: true);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _groupScrollController.dispose();
    _sourceScrollController.dispose();
    super.dispose();
  }

  int _getSelectedGroupIndex(int sourceIndex) {
    return _selectedGroupIndexBySource[sourceIndex] ?? 0;
  }

  void _setSelectedGroupIndex(int sourceIndex, int groupIndex) {
    _selectedGroupIndexBySource[sourceIndex] = groupIndex;
  }

  bool _fitsEpisodeText(
    String text,
    TextStyle style,
    TextScaler textScaler,
    double maxWidth, {
    int maxLines = 1,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: maxLines,
      ellipsis: '...',
    )..layout(maxWidth: maxWidth);
    return !painter.didExceedMaxLines;
  }

  _EpisodeTileLayout _resolveEpisodeTileLayout({
    required String text,
    required double containerWidth,
    required double spacing,
    required TextStyle style,
    required TextScaler textScaler,
  }) {
    final quarterWidth = (containerWidth - spacing * 3) / 4;
    final halfWidth = quarterWidth * 2 + spacing;
    const horizontalInset =
        _episodeTileHorizontalPadding * 2 + _episodeTileSelectedBorderWidth * 2;
    final quarterContentWidth = max(0.0, quarterWidth - horizontalInset);
    final halfContentWidth = max(0.0, halfWidth - horizontalInset);

    if (_fitsEpisodeText(
      text,
      style,
      textScaler,
      quarterContentWidth,
    )) {
      return _EpisodeTileLayout(
        width: quarterWidth,
        minHeight: _episodeTileMinHeight,
      );
    }

    if (_fitsEpisodeText(
      text,
      style,
      textScaler,
      halfContentWidth,
    )) {
      return _EpisodeTileLayout(
        width: halfWidth,
        minHeight: _episodeTileMinHeight,
      );
    }

    return _EpisodeTileLayout(
      width: containerWidth,
      minHeight: _episodeTileMinHeight,
    );
  }

  void _scrollToActiveItem({bool immediate = false}) {
    if (!mounted) return;
    final viewOriginIndex = _viewOriginIndex;
    if (viewOriginIndex == null) return;

    final duration =
        immediate ? Duration.zero : const Duration(milliseconds: 300);
    final selectedGroupIndex = _getSelectedGroupIndex(viewOriginIndex);

    // Helper to scroll a specific controller to a key without affecting other axes
    void scrollIsolated(ScrollController controller, GlobalKey key) {
      final context = key.currentContext;
      if (context != null && controller.hasClients) {
        final renderObject = context.findRenderObject();
        if (renderObject != null) {
          controller.position.ensureVisible(
            renderObject,
            duration: duration,
            alignment: 0.5,
          );
        }
      }
    }

    // 1. Source Bar: Isolated horizontal scroll
    if (_viewOriginIndex != null && _sourceKeyMap[_viewOriginIndex!] != null) {
      scrollIsolated(
          _sourceScrollController, _sourceKeyMap[_viewOriginIndex!]!);
    }

    // 2. Group Bar: Isolated horizontal scroll
    if (_groupKeyMap[selectedGroupIndex] != null) {
      scrollIsolated(_groupScrollController, _groupKeyMap[selectedGroupIndex]!);
    }

    // 3. Main List: Isolated vertical scroll
    scrollIsolated(_scrollController, _activeEpisodeKey);
  }

  @override
  Widget build(BuildContext context) {
    var info = context.watch<PlayVideoIdsStore>();
    Detail? detail = widget.data?.detail;
    List<ListData?>? list = detail?.list;
    int? activeOriginIndex = info.originIndex;
    int? teleplayIndex = info.teleplayIndex;

    // Unified Synchronization Logic
    bool dataJustArrived = !_lastDataNonNull && list != null;
    _lastDataNonNull = list != null;

    bool stateChanged = false;

    // A. Sync Source Index
    if (activeOriginIndex != _lastActiveOriginIndex) {
      _lastActiveOriginIndex = activeOriginIndex;
      _viewOriginIndex = activeOriginIndex;
      stateChanged = true;
    }

    // Initial fallback
    if (_viewOriginIndex == null) {
      _viewOriginIndex = 0;
      stateChanged = true;
    }

    var linkList = list != null && _viewOriginIndex! < list.length
        ? list[_viewOriginIndex!]?.linkList ?? []
        : [];

    const int groupSize = 100;
    bool needsGrouping = linkList.length > groupSize;

    // B. Sync Teleplay & Group Index
    if (teleplayIndex != _lastTeleplayIndex || dataJustArrived) {
      _lastTeleplayIndex = teleplayIndex;
      if (_viewOriginIndex != null && teleplayIndex != null && needsGrouping) {
        _setSelectedGroupIndex(_viewOriginIndex!, teleplayIndex ~/ groupSize);
      }
      stateChanged = true;
    }

    // Unified Scroll Trigger
    if (stateChanged || dataJustArrived) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToActiveItem());
    }

    int groupCount = (linkList.length / groupSize).ceil();
    int selectedGroupIndex = _getSelectedGroupIndex(_viewOriginIndex!);

    // Ensure selected group index is within valid range after source switch.
    if (selectedGroupIndex >= groupCount) {
      selectedGroupIndex = 0;
      _setSelectedGroupIndex(_viewOriginIndex!, selectedGroupIndex);
    }
    int groupStart = selectedGroupIndex * groupSize;
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
                      controller: _sourceScrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 8,
                        children: list.mapIndexed((i, e) {
                          _sourceKeyMap[i] ??= GlobalKey();
                          return ChoiceChip(
                              key: _sourceKeyMap[i],
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
                            bool isSelected = selectedGroupIndex == index;
                            _groupKeyMap[index] ??= GlobalKey();
                            return Padding(
                              key: _groupKeyMap[index],
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 4),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _setSelectedGroupIndex(
                                      _viewOriginIndex!,
                                      index,
                                    );
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
                        child: list?[_viewOriginIndex!] != null &&
                                linkList.isNotEmpty
                            ? LayoutBuilder(
                                builder: (context, constraints) {
                                  final containerWidth = constraints.maxWidth;
                                  final textScaler =
                                      MediaQuery.textScalerOf(context);

                                  return Wrap(
                                    spacing: _episodeTileSpacing,
                                    runSpacing: _episodeTileSpacing,
                                    children:
                                        visibleEpisodes.mapIndexed((i, e) {
                                      final colorScheme =
                                          Theme.of(context).colorScheme;

                                      final absoluteIndex = groupStart + i;
                                      final isSelected = _viewOriginIndex ==
                                              activeOriginIndex &&
                                          absoluteIndex == teleplayIndex;
                                      final text = '${e.episode}';
                                      final textStyle = TextStyle(
                                        fontSize: 14,
                                        color: isSelected
                                            ? colorScheme.onPrimaryContainer
                                            : colorScheme.onSurface,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        height: 1.25,
                                      );
                                      final layout = _resolveEpisodeTileLayout(
                                        text: text,
                                        containerWidth: containerWidth,
                                        spacing: _episodeTileSpacing,
                                        style: textStyle,
                                        textScaler: textScaler,
                                      );

                                      return SizedBox(
                                        key: isSelected
                                            ? _activeEpisodeKey
                                            : null,
                                        width: layout.width,
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
                                            constraints: BoxConstraints(
                                              minHeight: layout.minHeight,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  _episodeTileHorizontalPadding,
                                              vertical:
                                                  _episodeTileVerticalPadding,
                                            ),
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
                                                      width:
                                                          _episodeTileSelectedBorderWidth,
                                                    )
                                                  : null,
                                            ),
                                            child: LayoutBuilder(
                                              builder:
                                                  (context, tileConstraints) {
                                                return SizedBox(
                                                  width:
                                                      tileConstraints.maxWidth,
                                                  child: _EpisodeMarqueeText(
                                                    text: text,
                                                    style: textStyle,
                                                  ),
                                                );
                                              },
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

class _EpisodeTileLayout {
  final double width;
  final double minHeight;

  const _EpisodeTileLayout({
    required this.width,
    required this.minHeight,
  });
}

class _EpisodeMarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _EpisodeMarqueeText({
    required this.text,
    required this.style,
  });

  @override
  State<_EpisodeMarqueeText> createState() => _EpisodeMarqueeTextState();
}

class _EpisodeMarqueeTextState extends State<_EpisodeMarqueeText>
    with SingleTickerProviderStateMixin {
  static const _initialPause = Duration(milliseconds: 700);
  static const _gap = 24.0;
  static const _pixelsPerSecond = 32.0;

  late final AnimationController _controller = AnimationController(vsync: this);
  int _runToken = 0;
  String? _lastText;
  double? _lastViewportWidth;
  bool? _lastShouldScroll;
  double? _lastCycleWidth;

  @override
  void dispose() {
    _runToken += 1;
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startMarquee(double cycleWidth) async {
    final token = ++_runToken;
    _controller
      ..stop()
      ..value = 0;
    await Future<void>.delayed(_initialPause);

    if (!mounted || token != _runToken || cycleWidth <= 0) {
      return;
    }

    final duration = Duration(
      milliseconds: max(2200, (cycleWidth / _pixelsPerSecond * 1000).round()),
    );
    _controller
      ..duration = duration
      ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0;
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        final shouldScroll =
            viewportWidth > 0 && painter.width > viewportWidth + 1;
        final cycleWidth = painter.width + _gap;
        final contentHeight = painter.height;
        final textScaler = MediaQuery.textScalerOf(context);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final changed = _lastText != widget.text ||
              (_lastViewportWidth == null ||
                  (_lastViewportWidth! - viewportWidth).abs() > 0.5) ||
              _lastShouldScroll != shouldScroll ||
              (_lastCycleWidth == null ||
                  (_lastCycleWidth! - cycleWidth).abs() > 0.5);
          if (changed) {
            _lastText = widget.text;
            _lastViewportWidth = viewportWidth;
            _lastShouldScroll = shouldScroll;
            _lastCycleWidth = cycleWidth;
            if (shouldScroll) {
              _startMarquee(cycleWidth);
            } else {
              _runToken += 1;
              _controller
                ..stop()
                ..value = 0;
            }
          }
        });

        if (!shouldScroll) {
          return SizedBox(
            width: double.infinity,
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
              style: widget.style,
            ),
          );
        }

        return ClipRect(
          child: SizedBox(
            width: viewportWidth,
            height: contentHeight,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(viewportWidth, contentHeight),
                  painter: _EpisodeMarqueePainter(
                    text: widget.text,
                    style: widget.style,
                    textScaler: textScaler,
                    progress: _controller.value,
                    gap: _gap,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _EpisodeMarqueePainter extends CustomPainter {
  final String text;
  final TextStyle style;
  final TextScaler textScaler;
  final double progress;
  final double gap;

  const _EpisodeMarqueePainter({
    required this.text,
    required this.style,
    required this.textScaler,
    required this.progress,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();

    final cycleWidth = painter.width + gap;
    final dy = (size.height - painter.height) / 2;
    final dx = -progress * cycleWidth;

    painter.paint(canvas, Offset(dx, dy));
    painter.paint(canvas, Offset(dx + cycleWidth, dy));
  }

  @override
  bool shouldRepaint(covariant _EpisodeMarqueePainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.style != style ||
        oldDelegate.textScaler != textScaler ||
        oldDelegate.progress != progress ||
        oldDelegate.gap != gap;
  }
}
