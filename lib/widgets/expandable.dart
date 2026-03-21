import 'package:flutter/material.dart';

class SmoothExpandable extends StatefulWidget {
  final Widget child;
  final bool initiallyExpanded;
  final Duration duration;
  final Curve curve;
  final ValueChanged<bool>? onExpandChanged;

  const SmoothExpandable({
    super.key,
    required this.child,
    this.initiallyExpanded = false,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.onExpandChanged,
  });

  @override
  SmoothExpandableState createState() => SmoothExpandableState();
}

class SmoothExpandableState extends State<SmoothExpandable>
    with TickerProviderStateMixin {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  void expand() {
    if (!_expanded) setState(() => _expanded = true);
    widget.onExpandChanged?.call(true);
  }

  void collapse() {
    if (_expanded) setState(() => _expanded = false);
    widget.onExpandChanged?.call(false);
  }

  void toggle() {
    setState(() => _expanded = !_expanded);
    widget.onExpandChanged?.call(_expanded);
  }

  bool get isExpanded => _expanded;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: widget.duration,
      curve: widget.curve,
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: _expanded
            ? const BoxConstraints()
            : const BoxConstraints(maxHeight: 0),
        child: ClipRect(
          child: widget.child,
        ),
      ),
    );
  }
}
