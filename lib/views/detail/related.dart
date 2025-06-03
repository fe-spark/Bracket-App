import '/views/filter/index.dart';
import '/model/film_play_info/relate.dart';
import '/plugins.dart';

class Related extends StatefulWidget {
  final List<Relate> list;

  const Related({super.key, required this.list});

  @override
  State<Related> createState() => _RelatedState();
}

class _RelatedState extends State<Related> {
  @override
  Widget build(BuildContext context) {
    // MediaQueryData mediaQuery = MediaQuery.of(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // padding: const EdgeInsets.all(10.0),
      itemCount: widget.list.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12.0,
        crossAxisSpacing: 12.0,
        childAspectRatio: .54,
      ),
      itemBuilder: (BuildContext context, int index) {
        // print(content?.movies?.length);
        var movie = widget.list[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(
              context,
              MYRouter.detailPagePath,
              arguments: {
                'id': movie.id,
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
    );
  }
}
