import '/model/index/child.dart';
import '/plugins.dart';
import 'search_page.dart';

class SearchAppBar extends StatefulWidget {
  final List<Child>? tags;
  final double height;
  const SearchAppBar({super.key, this.tags, required this.height});

  @override
  State<StatefulWidget> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  @override
  Widget build(BuildContext context) {
    final iconSize = (widget.height * 0.45).clamp(18.0, 22.0);
    final fontSize = (widget.height * 0.36).clamp(14.0, 18.0);

    return GestureDetector(
      onTap: () {
        showSearch(
          context: context,
          delegate: SearchPage(context),
        );
      },
      child: Container(
        height: widget.height,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: iconSize,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  '搜索视频',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
