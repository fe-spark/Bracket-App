import '/plugins.dart';

class UnknownPage extends StatelessWidget {
  final Map? arguments;
  static const String routeName = "404";
  const UnknownPage({super.key, this.arguments});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('页面未找到'),
      ),
      body: const SafeArea(
        child: Center(child: NoDataView()),
      ),
    );
  }
}
