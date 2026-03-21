import 'package:flutter/material.dart';

class MyDialog extends StatefulWidget {
  const MyDialog({
    super.key,
    required this.title,
    required this.content,
    this.cancelText,
    this.confirmText,
    this.onConfirm,
    this.onCancel,
  });

  final String title;
  final String content;
  final String? cancelText;
  final String? confirmText;
  final Future Function()? onConfirm;
  final Future Function()? onCancel;

  @override
  State<MyDialog> createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  bool _isLoading = false;

  void showLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: _isLoading
          ? Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16.0),
                Text(widget.content),
              ],
            )
          : Text(widget.content),
      actions: <Widget>[
        TextButton(
          onPressed: !_isLoading
              ? () async {
                  if (widget.onCancel != null) {
                    showLoading(); // 显示loading状态
                    await widget.onCancel!();
                    hideLoading(); // 隐藏loading状态
                  }
                  if (context.mounted) Navigator.of(context).pop();
                }
              : null,
          child: Text(widget.cancelText ?? '取消'),
        ),
        TextButton(
          onPressed: !_isLoading
              ? () async {
                  if (widget.onConfirm != null) {
                    showLoading(); // 显示loading状态
                    await widget.onConfirm!();
                    hideLoading(); // 隐藏loading状态
                  }
                  if (context.mounted) Navigator.of(context).pop();
                }
              : null,
          child: Text(widget.confirmText ?? '确定'),
        ),
      ],
    );
  }
}
