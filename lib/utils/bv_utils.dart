import 'package:flutter/foundation.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:screen_brightness/screen_brightness.dart';

class BVUtils {
  static Future<double> get volume async {
    return (await FlutterVolumeController.getVolume()) ?? 0.0;
  }

  static Future<void> setVolume(double volume) async {
    await FlutterVolumeController.setVolume(volume);
  }

  static Future<double> get brightness async {
    try {
      return await ScreenBrightness().application;
    } catch (e) {
      return 0.5;
    }
  }

  static Future<void> setBrightness(double brightness) async {
    try {
      await ScreenBrightness().setApplicationScreenBrightness(brightness);
    } catch (e) {
      debugPrint('Failed to set brightness: $e');
    }
  }

  static Future<void> resetCustomBrightness() async {
    try {
      await ScreenBrightness().resetApplicationScreenBrightness();
    } catch (e) {
      debugPrint('Failed to reset brightness: $e');
    }
  }
}
