import '/plugins.dart';

class LoadingViewBuilder extends StatelessWidget {
  final Function(BuildContext) builder;
  final bool loading;

  const LoadingViewBuilder(
      {super.key, required this.loading, required this.builder});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Loading();
    }
    return builder(context);
  }
}
