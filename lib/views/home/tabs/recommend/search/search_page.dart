import '/model/search_film/list.dart';
import '/model/search_film/search_film.dart';
import '/plugins.dart';

class SearchPage extends SearchDelegate<String> {
  BuildContext context;
  SearchPage(this.context) : super();

  @override
  String get searchFieldLabel => '请输入视频名';

  @override
  TextStyle? get searchFieldStyle =>
      TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        // 点击把文本空的内容清空
        onPressed: () => query = "",
      )
    ];
  }

  // 点击箭头返回
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        // 使用动画效果返回
        icon: AnimatedIcons.menu_arrow, progress: transitionAnimation,
      ),
      // 点击的时候关闭页面（上下文）
      onPressed: () {
        close(context, query);
      },
    );
  }

  // 点击搜索出现结果
  @override
  Widget buildResults(BuildContext context) {
    var queryString = query.trim();
    if (queryString == "") {
      return buildSuggestions(context);
    }
    return SearchList(query: query.trim());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    SearchStore searchStore = context.watch<SearchStore>();
    final suggestionList = searchStore.data;

    if (suggestionList.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              // runSpacing: 6,
              children: suggestionList
                  .map(
                    (e) => OutlinedButton(
                      onPressed: () {
                        query = e;
                        showResults(context);
                      },
                      child: Text(e),
                    ),
                  )
                  .toList(),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                searchStore.clearStore();
                // global.setSearchRecord(str)
              },
              child: const Text('清除历史输入'),
            ),
          )
        ],
      );
    }
    return const Center(
      child: Text(
        '没有历史搜索',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}

class SearchList extends StatefulWidget {
  final String query;
  const SearchList({super.key, required this.query});

  @override
  State<SearchList> createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  bool _loading = false;
  final ScrollController _scrollController = ScrollController();
  List<ListData> _list = [];
  int _current = 1;
  int _total = 0;

  Future<void> _fetchData() async {
    SearchStore searchStore = context.read<SearchStore>();
    if (_loading) return;
    setState(() {
      _loading = true;
    });
    var res = await Api.searchFilm(
      context: context,
      queryParameters: {
        'keyword': widget.query,
        'current': _current,
      },
    );

    if (widget.query.isNotEmpty) {
      searchStore.addSearchRecord(widget.query);
    }
    if (res != null && res.runtimeType != String) {
      SearchFilm jsonData = SearchFilm.fromJson(res);
      setState(() {
        _loading = false;
        _current = jsonData.data?.page?.current ?? 1;
        _total = jsonData.data?.page?.total ?? 0;
        if (_current == 1) {
          _list = jsonData.data?.list ?? [];
        } else {
          _list.addAll(jsonData.data?.list ?? []);
        }
        if (_list.length < _total) _current = _current + 1;
      });
    } else {
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _loading = false;
      });
      if (mounted) {
        return await _fetchData();
      }
    }
  }

  @override
  void initState() {
    // page = 1;
    _fetchData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels + 30 >
          _scrollController.position.maxScrollExtent) {
        //滚动到最后请求更多
        _fetchData();
      }
    });

    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.all(6),
        controller: _scrollController,
        itemBuilder: (context, index) {
          if (index < _list.length) {
            var item = _list[index];
            return searchItemView(item);
          }

          return _loadMoreWidget(_list);
        },
        itemCount: _list.length + 1,
      ),
    );
  }

  Widget _loadMoreWidget(list) {
    return Align(
      heightFactor: 2,
      alignment: Alignment.center,
      child: _loading
          ? SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          : list.length == _total
              ? const Text('暂无更多数据')
              : const Text('上拉加载'),
    );
  }

  Widget searchItemView(ListData item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            MYRouter.detailPagePath,
            arguments: {
              'id': item.id,
            },
          );
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  width: 120,
                  height: 150,
                  child: Image(
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext _, Widget widget,
                        ImageChunkEvent? event) {
                      if (event == null) {
                        return widget;
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          value: event.expectedTotalBytes != null
                              ? event.cumulativeBytesLoaded /
                                  event.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    width: double.infinity,
                    height: double.infinity,
                    image: NetworkImage(
                      item.picture ?? '',
                    ),
                    errorBuilder: (BuildContext context, Object error,
                        StackTrace? stackTrace) {
                      return Image.asset(
                        fit: BoxFit.cover,
                        'assets/images/logo.png',
                      );
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name ?? '',
                        softWrap: true,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        (item.blurb?.trim().isEmpty ?? true)
                            ? '暂无介绍'
                            : item.blurb?.trim() ?? '暂无介绍',
                        style: TextStyle(
                          color: Theme.of(context).disabledColor,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 4,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
