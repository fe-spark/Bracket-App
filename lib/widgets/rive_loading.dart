import '/plugins.dart';
import 'package:rive/rive.dart';

class RiveLoading extends StatelessWidget {
  const RiveLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 120,
        width: 120,
        child: RiveAnimation.asset(
          'assets/rive/loading_smile.riv',
          artboard: 'Loading',
          // fit: BoxFit.scaleDown,
        ),
      ),
    );
  }
}
