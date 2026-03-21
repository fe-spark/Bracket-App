import '/plugins.dart';

class Error extends StatefulWidget {
  final String? message;
  final Function? onRefresh;

  const Error({super.key, this.message, this.onRefresh});

  @override
  State<Error> createState() => _ErrorState();
}

class _ErrorState extends State<Error> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const NoDataView(),
          Text(
            widget.message ?? '未能成功解析，请检查网络后重试',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (widget.onRefresh != null) {
                widget.onRefresh!();
              }
            },
            child: const Text('刷新'),
          ),
        ],
      ),
    );
  }
}
