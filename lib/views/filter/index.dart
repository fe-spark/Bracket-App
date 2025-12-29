// import '/model/film_classify_search/params.dart';

// import 'package:flutter/cupertino.dart';

import '/plugins.dart';
import '/model/film_classify_search/film_classify_search.dart';
import '/model/film_classify_search/search.dart';
import '/model/film_classify_search/data.dart';

import 'dynamic_sliver_appbar.dart';
import 'filter_bar.dart';
import 'sticky_appbar.dart';

class FilterPage extends StatefulWidget {
  final Map? arguments;

  const FilterPage({super.key, this.arguments});

  @override
  State<StatefulWidget> createState() {
    return _FilterPageState();
  }
}

class _FilterPageState extends State<FilterPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey();
  Data? _data;
  bool _loading = false;
  double _scrollPixels = 0;
  double _sliverAppbarHeight = 0;

  List<dynamic> _list = [];
  int _current = 1;
  int _total = 0;
  bool _finish = false;
  Map? _request = {};

  Search? get _search {
    return _data?.search;
  }

  List<String>? get _sortList {
    return _search?.sortList;
  }

  Map<String, dynamic> get _params {
    var params = _request;
    Map<String, dynamic> map = {};
    _sortList?.forEach(
      (e) {
        map[e] = params?[e];
      },
    );
    return map;
  }

  Map<String, dynamic>? get _tags {
    Map<String, dynamic> map = {};
    var jsonTags = _search?.tags?.toJson();
    _sortList?.forEach((e) {
      var value = _params[e];
      map[e] = jsonTags?[e].firstWhere((e) => e?.value == value);
    });
    return map;
  }

  List _getTags() {
    List? arr = [];
    _tags?.keys.forEach((e) {
      if (_tags?[e].value != null && _tags?[e].value != '') {
        arr.add(_tags?[e]);
      }
    });
    return arr;
  }

  Future _fetchData(bool init) async {
    int pid = widget.arguments?['pid'];
    int? category = widget.arguments?['category'];
    if (init) {
      setState(() {
        _list = [];
        _finish = false;
        _current = 1;
      });
    }

    if (_loading || _finish) return;

    setState(() {
      _loading = true;
    });

    var res = await Api.filmClassifySearch(context: context, queryParameters: {
      'Pid': pid,
      'Category': category,
      'current': _current,
      ...?_request,
    });
    if (res != null && res.runtimeType != String) {
      FilmClassifySearch jsonData = FilmClassifySearch.fromJson(res);
      setState(() {
        _loading = false;
        _data = jsonData.data;
        _request = _data?.params?.toJson();

        _current = jsonData.data?.page?.current ?? 1;
        _total = jsonData.data?.page?.total ?? 0;

        if (_current == 1) {
          _list = _data?.list ?? [];
          if (_scrollController.hasClients) _scrollController.jumpTo(0);
        } else {
          _list.addAll(_data?.list ?? []);
        }

        if (_list.length >= _total) {
          _finish = true;
        }

        _current = _current + 1;
      });
    } else {
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _loading = false;
      });
      if (mounted) {
        return await _fetchData(init);
      }
    }
  }

  @override
  void initState() {
    _fetchData(true);
    _scrollController.addListener(() {
      double pixels = _scrollController.position.pixels;

      setState(() {
        _scrollPixels = pixels;
        // _showUpIcon = pixels > MediaQuery.of(context).size.height;
      });

      if (pixels + 30 >= _scrollController.position.maxScrollExtent) {
        _fetchData(false);
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
    MediaQueryData mediaQuery = MediaQuery.of(context);

    return Scaffold(
      floatingActionButton: _scrollPixels > mediaQuery.size.height
          ? FloatingActionButton(
              heroTag: null,
              onPressed: () {
                if (_scrollController.hasClients) _scrollController.jumpTo(0);
              },
              child: const Icon(
                Icons.arrow_upward,
                size: 24,
              ),
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          key: _refreshKey,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // if (_tags!.keys.isNotEmpty)
              DynamicSliverAppBar(
                onHeightListener: (height) {
                  setState(() {
                    _sliverAppbarHeight = height;
                  });
                },
                maxHeight: mediaQuery.size.height,
                child: FilterBar(
                  loading: _loading,
                  activeMap: _tags,
                  search: _search,
                  onSearch: (Map? params) {
                    _request = params;
                    _fetchData(true);
                  },
                ),
              ),
              SliverPersistentHeader(
                pinned: true, //是否固定在顶部
                floating: true,
                delegate: StickyAppbar(
                  appBar: AppBar(
                    centerTitle: false,
                    title: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 10,
                        children: _getTags()
                            .map<ActionChip>(
                              (e) => ActionChip(
                                label: Text(e.name ?? ''),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    actions: _scrollPixels > _sliverAppbarHeight
                        ? [
                            IconButton(
                              onPressed: () {
                                if (_scrollController.hasClients) {
                                  _scrollController.jumpTo(0);
                                }
                              },
                              icon: const Icon(Icons.filter_list),
                            )
                          ]
                        : [],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      var movie = _list[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            MYRouter.detailPagePath,
                            arguments: {
                              'id': movie?.id,
                            },
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getMovieGridContent(context, movie),
                            getMovieGridFooter(context, movie)
                          ],
                        ),
                      );
                    },
                    childCount: _list.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    // max: mediaQuery.size.width / 3,
                    // mainAxisExtent: mediaQuery.size.width / 3,
                    crossAxisCount: (mediaQuery.size.width / 120).truncate(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: .6,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _loadMoreWidget(),
              ),
            ],
          ),
          onRefresh: () async {
            return await _fetchData(true);
          },
        ),
      ),
    );
  }

  Widget _loadMoreWidget() {
    return Align(
      heightFactor: 1,
      alignment: Alignment.center,
      child: _loading
          ? const Loading()
          : _list.length == _total
              ? const Text('暂无更多数据')
              : const Text('上拉加载'),
    );
  }
}

Widget getMovieGridHeader(BuildContext context, content) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          content?.nav?.name ?? '',
          // style: Theme.of(context).textTheme.titleLarge,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(MYRouter.filterPagePath,
                arguments: {'pid': content?.nav?.id});
          },
          child: Row(
            children: [
              Text(
                '查看更多',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: Theme.of(context).textTheme.bodyMedium?.fontSize,
              )
            ],
          ),
        ),
      ],
    ),
  );
}

Widget getMovieGridContent(BuildContext context, movie) => Expanded(
      flex: 1,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey,
            ),
            child: Image(
              fit: BoxFit.cover,
              loadingBuilder:
                  (BuildContext _, Widget widget, ImageChunkEvent? event) {
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
                movie?.picture ?? '',
              ),
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return Image.asset(
                  fit: BoxFit.cover,
                  'assets/images/logo.png',
                );
              },
            ),
          ),
          Positioned(
            top: 4,
            left: 4,
            right: 4,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withAlpha(200),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                      movie?.year ?? '',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize:
                            Theme.of(context).textTheme.bodySmall?.fontSize,
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withAlpha(200),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                      movie?.cName ?? '',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize:
                            Theme.of(context).textTheme.bodySmall?.fontSize,
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withAlpha(200),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                      movie?.remarks ?? '',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize:
                            Theme.of(context).textTheme.bodySmall?.fontSize,
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

Widget getMovieGridFooter(BuildContext context, movie) => Padding(
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie?.name ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            textAlign: TextAlign.left,
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            (movie?.subTitle?.trim().isEmpty ?? true)
                ? '暂无'
                : movie?.subTitle?.trim() ?? '暂无',
            style: TextStyle(
              color: Theme.of(context).disabledColor,
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            maxLines: 1,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
