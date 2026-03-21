import '/plugins.dart';

class SearchHeader extends SliverPersistentHeaderDelegate {
  final double minTopBarHeight;
  final double maxTopBarHeight;
  final double searchContainerWidth;
  final double searchContainerHeight;
  final double searchBottomPadding;
  final double borderRadius;
  final double safeAreaTopInset;
  final EdgeInsets titlePadding;
  final TextStyle? titleStyle;
  final TextStyle? collapsedTitleStyle;
  final String title;
  final Widget search;

  SearchHeader({
    required this.title,
    required this.search,
    this.minTopBarHeight = 100,
    this.maxTopBarHeight = 200,
    this.searchContainerWidth = 200,
    this.searchContainerHeight = 50,
    this.searchBottomPadding = 10,
    this.borderRadius = 36,
    this.safeAreaTopInset = 0,
    this.titlePadding = const EdgeInsets.only(top: 20, bottom: 28),
    this.titleStyle,
    this.collapsedTitleStyle,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final extentDelta = max(maxExtent - minExtent, 1.0);
    final shrinkFactor = min(1.0, shrinkOffset / extentDelta).toDouble();
    final currentExtent = max(maxExtent - shrinkOffset, minExtent);
    final panelCollapseRange = max(maxTopBarHeight - minExtent, 1.0);
    final initialSearchOverlap =
        maxExtent - max(maxTopBarHeight, minExtent) - searchBottomPadding;
    final headerFastPhase = max(
      ((panelCollapseRange - initialSearchOverlap) / extentDelta)
          .clamp(0.0, 1.0),
      0.001,
    );
    final panelShrinkFactor = (shrinkFactor / headerFastPhase).clamp(0.0, 1.0);
    final panelHeight =
        maxTopBarHeight - (panelCollapseRange * panelShrinkFactor);
    final searchTop =
        currentExtent - searchBottomPadding - searchContainerHeight;
    final headerCollapsed = panelShrinkFactor >= 0.999;
    final expandedTitleStyle = titleStyle ??
        Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            );
    final effectiveCollapsedTitleStyle = collapsedTitleStyle ??
        Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ) ??
        expandedTitleStyle?.copyWith(
          fontSize: (expandedTitleStyle.fontSize ?? 36) * 0.62,
        );
    final effectiveTitleStyle = TextStyle.lerp(
      expandedTitleStyle,
      effectiveCollapsedTitleStyle,
      panelShrinkFactor,
    );
    final titleAreaHeight = max(panelHeight - safeAreaTopInset, 0.0);
    final titleAlignment = Alignment.lerp(
      const Alignment(0, 0.18),
      Alignment.center,
      panelShrinkFactor,
    )!;
    final effectiveTitleBottomPadding =
        titlePadding.bottom * (1 - panelShrinkFactor);

    var bgTopBar = Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        alignment: Alignment.center,
        height: panelHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
            width: 4,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          boxShadow: [
            BoxShadow(
              offset: const Offset(5, 5),
              blurRadius: 10,
              color: Theme.of(context)
                  .colorScheme
                  .inversePrimary
                  .withValues(alpha: 0.23),
            )
          ],
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(borderRadius),
            bottomRight: Radius.circular(borderRadius),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: safeAreaTopInset),
          child: ClipRect(
            child: SizedBox(
              height: titleAreaHeight,
              child: Padding(
                padding: EdgeInsets.only(bottom: effectiveTitleBottomPadding),
                child: Align(
                  alignment: titleAlignment,
                  child: Text(
                    title,
                    style: effectiveTitleStyle,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return SizedBox(
      height: currentExtent,
      child: Stack(
        fit: StackFit.loose,
        children: [
          if (!headerCollapsed) bgTopBar,
          Positioned(
            top: searchTop,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                alignment: Alignment.center,
                width: searchContainerWidth,
                height: searchContainerHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(5, 5),
                      blurRadius: 10,
                      color: Theme.of(context)
                          .colorScheme
                          .inversePrimary
                          .withValues(alpha: 0.23),
                    )
                  ],
                ),
                child: search,
              ),
            ),
          ),
          if (headerCollapsed) bgTopBar,
        ],
      ),
    );
  }

  @override
  double get maxExtent =>
      max(maxTopBarHeight, minExtent) +
      searchBottomPadding +
      searchContainerHeight * 0.5;

  @override
  double get minExtent {
    final collapsedFontSize =
        collapsedTitleStyle?.fontSize ?? titleStyle?.fontSize ?? 26;
    final collapsedLineHeight =
        collapsedTitleStyle?.height ?? titleStyle?.height ?? 1.2;
    return max(
      minTopBarHeight,
      safeAreaTopInset + (collapsedFontSize * collapsedLineHeight) + 8,
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
