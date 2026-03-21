import '/plugins.dart';

class PercentageOverlayData {
  final String message;
  final bool hidden;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry padding;
  final String? caption;
  final IconData? icon;
  final double? progress;
  final Offset? offset;

  const PercentageOverlayData({
    this.message = '',
    this.hidden = true,
    this.alignment = Alignment.topCenter,
    this.padding = const EdgeInsets.only(top: 30),
    this.caption,
    this.icon,
    this.progress,
    this.offset = Offset.zero,
  });
}

class PercentageController extends ChangeNotifier {
  PercentageOverlayData _data = const PercentageOverlayData();

  PercentageOverlayData get data => _data;

  void show(
    String message, {
    AlignmentGeometry alignment = Alignment.topCenter,
    EdgeInsetsGeometry padding = const EdgeInsets.only(top: 30),
    String? caption,
    IconData? icon,
    double? progress,
    Offset offset = Offset.zero,
  }) {
    _data = PercentageOverlayData(
      message: message,
      hidden: false,
      alignment: alignment,
      padding: padding,
      caption: caption,
      icon: icon,
      progress: progress,
      offset: offset,
    );
    notifyListeners();
  }

  void hide() {
    if (_data.hidden) return;
    _data = PercentageOverlayData(
      alignment: _data.alignment,
      padding: _data.padding,
    );
    notifyListeners();
  }
}

class PercentageWidget extends StatefulWidget {
  final PercentageController controller;

  const PercentageWidget({
    super.key,
    required this.controller,
  });

  @override
  State<PercentageWidget> createState() => _PercentageWidgetState();
}

class _PercentageWidgetState extends State<PercentageWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChanged);
  }

  @override
  void didUpdateWidget(covariant PercentageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleChanged);
      widget.controller.addListener(_handleChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChanged);
    super.dispose();
  }

  void _handleChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.controller.data;
    final child =
        data.hidden ? const SizedBox.shrink() : _buildOverlay(context, data);
    return IgnorePointer(
      child: Padding(
        padding: data.padding,
        child: Align(
          alignment: data.alignment,
          child: Transform.translate(
            offset: data.offset ?? Offset.zero,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context, PercentageOverlayData data) {
    final cardColor = Colors.black.withValues(alpha: 0.74);
    final shadowColor = Colors.black.withValues(alpha: 0.22);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (data.icon != null)
            Icon(
              data.icon,
              size: 18,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          if (data.icon != null) const SizedBox(width: 8),
          Text(
            data.message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
