import '/plugins.dart';

class DynamicSliverAppBar extends StatefulWidget {
  const DynamicSliverAppBar({
    required this.maxHeight,
    this.child,
    this.onHeightListener,
    super.key,
  });

  final Function(double)? onHeightListener;
  final Widget? child;
  final double maxHeight;

  @override
  State<DynamicSliverAppBar> createState() => _DynamicSliverAppBarState();
}

class _DynamicSliverAppBarState extends State<DynamicSliverAppBar> {
  final GlobalKey _childKey = GlobalKey();
  bool isHeightCalculated = false;
  double? height;
  double toolbarHeight = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!isHeightCalculated) {
        setState(() {
          height = (_childKey.currentContext?.findRenderObject() as RenderBox)
              .size
              .height;
        });
        isHeightCalculated = true;
        if (widget.onHeightListener != null) {
          widget.onHeightListener!(height ?? 0);
        }
      }
    });
    return SliverAppBar(
      // snap: true,
      // floating: true,
      // primary: false,
      pinned: true,
      stretch: true,
      toolbarHeight: toolbarHeight,
      expandedHeight: (isHeightCalculated) ? height : widget.maxHeight,
      flexibleSpace: FlexibleSpaceBar(
        // collapseMode: CollapseMode.pin,
        background: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NotificationListener<SizeChangedLayoutNotification>(
              onNotification: (notification) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  isHeightCalculated = true;
                  setState(() {
                    height = (_childKey.currentContext?.findRenderObject()
                            as RenderBox)
                        .size
                        .height;
                  });
                  if (widget.onHeightListener != null) {
                    widget.onHeightListener!(height ?? 0);
                  }
                });
                return false;
              },
              child: SizeChangedLayoutNotifier(
                child: Container(
                  key: _childKey,
                  child: widget.child,
                ),
              ),
            ),
            const Expanded(
              child: SizedBox.shrink(),
            )
          ],
        ),
      ),
    );
  }
}
