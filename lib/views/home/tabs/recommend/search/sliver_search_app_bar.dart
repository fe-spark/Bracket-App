import '/model/index/child.dart';

import 'background_wave.dart';
import 'search_bar.dart';
import 'package:flutter/material.dart';

class SliverSearchAppBar extends SliverPersistentHeaderDelegate {
  final GlobalKey _childKey = GlobalKey();
  final List<Child>? tags;
  double height = 180;
  SliverSearchAppBar({this.tags});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    var adjustedShrinkOffset =
        shrinkOffset > minExtent ? minExtent : shrinkOffset;
    double offset = (minExtent - adjustedShrinkOffset) * 0.2;
    double topPadding = MediaQuery.of(context).padding.top + 16;

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          height = (_childKey.currentContext?.findRenderObject() as RenderBox)
              .size
              .height;
        });
        return false;
      },
      child: SizeChangedLayoutNotifier(
          child: Stack(
        key: _childKey,
        children: [
          const BackgroundWave(
            height: 300,
          ),
          Positioned(
            top: topPadding + offset,
            left: 0,
            right: 0,
            bottom: 0,
            child: SearchAppBar(tags: tags, height: height),
          )
        ],
      )),
    );
  }

  @override
  double get maxExtent => 300;

  @override
  double get minExtent => 180;

  double get extent {
    return (_childKey.currentContext?.findRenderObject() as RenderBox)
        .size
        .height;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      oldDelegate.maxExtent != maxExtent || oldDelegate.minExtent != minExtent;
}
