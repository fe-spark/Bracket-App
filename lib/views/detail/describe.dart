import '/model/film_play_info/relate.dart';

import '/model/film_play_info/data.dart';
// import '/model/film_play_info/detail.dart';
import '/views/detail/related.dart';
import '/plugins.dart';

class Describe extends StatefulWidget {
  final Data? data;
  const Describe({super.key, this.data});

  @override
  State<Describe> createState() => _DescribeState();
}

class _DescribeState extends State<Describe> {
  // Detail? get _detail {
  //   return widget.data?.detail;
  // }

  List<Relate> get _relate {
    return widget.data?.relate ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return LoadingViewBuilder(
      loading: widget.data == null,
      builder: (_) => MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 12),
            child: Column(
              children: [
                Related(
                  list: _relate,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
