import 'package:flutter/material.dart';

// 屏幕自适应方案实现
// 重写int/double
// 扩展px方法

class SparkPxFit {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static double? rpx;
  static double? px;

  static void initialize(BuildContext context, {double standardWidth = 750}) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData?.size.width;
    screenHeight = _mediaQueryData?.size.height;
    px = screenWidth! / standardWidth;
  }

  static double setPx(double? size) {
    return SparkPxFit.px! * size!;
  }
}

extension IntFit on int {
  double get px {
    return SparkPxFit.setPx(toDouble());
  }
}

extension DoubleFit on double {
  double get px {
    return SparkPxFit.setPx(this);
  }
}
