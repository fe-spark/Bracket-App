import '/plugins.dart';
import 'package:rive/rive.dart';

class NoDataView extends StatelessWidget {
  const NoDataView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 180,
        width: 180,
        child: RiveAnimation.asset(
          'assets/rive/404_cat.riv',
          artboard: '404',
          // fit: BoxFit.scaleDown,
        ),
      ),
    );
  }
}
