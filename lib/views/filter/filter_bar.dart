import '/model/film_classify_search/search.dart';
import '/plugins.dart';

class FilterBar extends StatelessWidget {
  final Map<String, dynamic>? activeMap;
  final Search? search;
  final Function onSearch;
  final bool loading;

  const FilterBar({
    super.key,
    required this.search,
    required this.onSearch,
    required this.activeMap,
    required this.loading,
  });

  List<String>? get _sortList {
    return search?.sortList;
  }

  Map<String, dynamic> get _titles {
    Map<String, dynamic> map = {};
    var titles = search?.titles?.toJson();
    _sortList?.forEach(
      (e) {
        map[e] = titles?[e];
      },
    );
    return map;
  }

  Map<String, dynamic> get _tags {
    Map<String, dynamic> map = {};
    var jsonTags = search?.tags?.toJson();
    _sortList?.forEach((e) {
      map[e] = jsonTags?[e];
    });
    return map;
  }

  @override
  Widget build(BuildContext context) {
    // var theme = context.watch<ThemeStore>();

    if (_tags.keys.isEmpty) {
      return Container();
    }
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 8,
      ),
      child: Column(
        children: [
          ...(_tags.keys.map(
            (key) {
              return Row(
                children: [
                  Expanded(
                    flex: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                      ),
                      child: Text(_titles[key]),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 8,
                        children: _tags[key]?.map<ChoiceChip>((e) {
                          return ChoiceChip(
                            label: Text(
                              (e?.name ?? ''),
                            ),
                            selected: activeMap?[key]?.value == e?.value,
                            onSelected: !loading
                                ? (newValue) {
                                    Map params = {};
                                    activeMap?.forEach((k, v) {
                                      params[k] =
                                          k == key ? e?.value : v?.value;
                                    });
                                    onSearch(params);
                                  }
                                : null,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ).toList()),
        ],
      ),
    );
  }
}
