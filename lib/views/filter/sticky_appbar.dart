import '/plugins.dart';

class StickyAppbar extends SliverPersistentHeaderDelegate {
  StickyAppbar({
    required this.appBar,
  });
  final AppBar appBar;

  @override
  double get minExtent => appBar.preferredSize.height;

  @override
  double get maxExtent => appBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: appBar);
  }

  @override
  bool shouldRebuild(StickyAppbar oldDelegate) {
    return true;
  }
}
