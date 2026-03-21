import '/plugins.dart';

class SplashPage extends StatefulWidget {
  final String? title;
  const SplashPage({super.key, this.title});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      navigationPage();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  void navigationPage() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(MYRouter.homePagePath, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: 750.px,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              border: Border.all(color: const Color.fromRGBO(133, 0, 0, 1))),
          child: const Column(children: []),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigationPage,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
