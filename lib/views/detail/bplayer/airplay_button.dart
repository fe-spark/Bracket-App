import 'package:flutter/rendering.dart' show PlatformViewHitTestBehavior;

import '/plugins.dart';

const String _airPlayRoutePickerViewType = 'bracket/airplay_route_picker';
const MethodChannel _androidMediaRouteChannel = MethodChannel(
  'bracket/media_route_picker',
);

class AndroidCastMedia {
  final String url;
  final String title;
  final String? subtitle;
  final int positionSeconds;
  final String? posterUrl;

  const AndroidCastMedia({
    required this.url,
    required this.title,
    this.subtitle,
    this.positionSeconds = 0,
    this.posterUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'title': title,
      'subtitle': subtitle,
      'positionSeconds': positionSeconds,
      'posterUrl': posterUrl,
    };
  }
}

class AirPlayRoutePickerButton extends StatelessWidget {
  final double size;
  final Color iconColor;
  final Color activeIconColor;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final AndroidCastMedia? androidMedia;

  const AirPlayRoutePickerButton({
    super.key,
    this.size = 32,
    this.iconColor = Colors.white,
    this.activeIconColor = Colors.white,
    this.backgroundColor = Colors.transparent,
    this.padding = const EdgeInsets.all(4),
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
    this.androidMedia,
  });

  static bool get isSupported => Platform.isIOS || Platform.isAndroid;

  @override
  Widget build(BuildContext context) {
    if (!isSupported) {
      return const SizedBox.shrink();
    }

    if (Platform.isAndroid) {
      final resolvedPadding = padding.resolve(Directionality.of(context));
      final iconSize = max(
        16.0,
        size - max(resolvedPadding.horizontal, resolvedPadding.vertical),
      );

      return SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: borderRadius.resolve(Directionality.of(context)),
              onTap: () async {
                final media = androidMedia;
                if (media == null) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('当前视频暂不支持投屏')),
                  );
                  return;
                }

                final uri = Uri.tryParse(media.url);
                final isSupportedMedia = uri != null &&
                    (uri.scheme == 'http' || uri.scheme == 'https');

                if (!isSupportedMedia) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('当前视频暂不支持投屏')),
                  );
                  return;
                }

                final castMedia = media;
                try {
                  final response = await _androidMediaRouteChannel
                      .invokeMapMethod<String, dynamic>(
                    'presentDevicePicker',
                    castMedia.toMap(),
                  );
                  if (!context.mounted || response == null) return;
                  final deviceName = response['name'] as String?;
                  if (deviceName != null && deviceName.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已发送到 $deviceName')),
                    );
                  }
                } on PlatformException catch (error) {
                  if (error.code == 'cancelled') {
                    return;
                  }
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error.message ?? '无法打开投屏设备列表'),
                    ),
                  );
                }
              },
              child: Padding(
                padding: padding,
                child: Icon(
                  Icons.cast_rounded,
                  size: iconSize,
                  color: iconColor,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        child: Padding(
          padding: padding,
          child: UiKitView(
            viewType: _airPlayRoutePickerViewType,
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            creationParams: {
              'tintColor': iconColor.toARGB32(),
              'activeTintColor': activeIconColor.toARGB32(),
            },
            creationParamsCodec: const StandardMessageCodec(),
          ),
        ),
      ),
    );
  }
}
