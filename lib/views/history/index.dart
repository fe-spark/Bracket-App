import '/plugins.dart';

import 'slidable_tile.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    // _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var histryStore = context.watch<HistoryStore>();
    var list = histryStore.data;
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return MyDialog(
                    title: '提示',
                    content: '是否删除播放记录',
                    onConfirm: () async {
                      histryStore.clearStore();
                    },
                  );
                },
              );
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: list.isNotEmpty
              ? ListView.separated(
                  itemBuilder: (context, index) {
                    var item = list[index];
                    return SlidableTile(
                      data: item,
                    );
                  },
                  itemCount: list.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(
                      height: 8,
                    );
                  },
                )
              : const Center(
                  child: Text('暂无数据'),
                ),
        ),
      ),
    );
  }
}
