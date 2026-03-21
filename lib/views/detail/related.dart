import '/model/film_play_info/relate.dart';
import '/plugins.dart';
import '/widgets/movie_grid_tile.dart';

class Related extends StatefulWidget {
  final List<Relate> list;

  const Related({super.key, required this.list});

  @override
  State<Related> createState() => _RelatedState();
}

class _RelatedState extends State<Related> {
  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: widget.list.length,
          gridDelegate: buildMovieGridDelegate(
            availableWidth: constraints.maxWidth,
            isLandscape: isLandscape,
            childAspectRatio: 0.62,
          ),
          itemBuilder: (BuildContext context, int index) {
            var movie = widget.list[index];
            return MovieGridTile(
              movie: movie,
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  MYRouter.detailPagePath,
                  arguments: {
                    'id': movie.id,
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
