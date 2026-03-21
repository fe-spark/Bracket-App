import '/plugins.dart';
import './tabs/recommend/index.dart' show RecommendTab;
import './tabs/user_center.dart' show UserCenterTab;
import './tabs/classify/index.dart' show ClassifyTab;
import 'nav.dart';

class HomePage extends StatefulWidget {
  final String? arguments;
  const HomePage({super.key, this.arguments});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<Widget> _pages = [];
  final _pageController = PageController();

  void _pageChanged(int index) {
    setState(() {
      if (_currentIndex != index) _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  void initState() {
    if (mounted) {
      _currentIndex = 0;
      _pages = [
        const RecommendTab(),
        const ClassifyTab(),
        const UserCenterTab(),
      ];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool willpop) {
        if (willpop) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return MyDialog(
              title: '提示',
              content: '是否退出应用？',
              onConfirm: () async {
                SystemNavigator.pop();
              },
            );
          },
        );
      },
      child: Scaffold(
        extendBody: true,
        body: PageView.builder(
          controller: _pageController,
          // physics: NeverScrollableScrollPhysics(),
          onPageChanged: _pageChanged,
          itemCount: _pages.length,
          itemBuilder: (context, index) => _pages[index],
        ),
        bottomNavigationBar: BottonNavWithAnimatedIcons(
          index: _currentIndex,
          onChange: _onTabTapped,
        ),
        // floatingActionButton: ElevatedButton(
        //     child: Text('data'),
        //     onPressed: () {
        //       Navigator.of(context).pushNamed(MYRouter.testPagePath);
        //     }),
      ),
    );
  }
}
