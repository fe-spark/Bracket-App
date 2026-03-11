import 'dart:async';
import 'package:flutter/foundation.dart';
import '/plugins.dart';

class VideoSourceStore with ChangeNotifier, DiagnosticableTreeMixin {
  final preferenceKey = 'videoSourceStore';

  VideoSource? _data;

  VideoSource? get data {
    if (_data != null) return _data;
    var map = PreferenceUtil.getMap(preferenceKey);
    if (map != null) {
      _data = VideoSource.fromJson(map);
    }
    return _data;
  }

  Future<void> clearStore() async {
    if (_data != null) {
      _data!.actived = null;
      await setStore(_data!);
    } else {
      var map = PreferenceUtil.getMap(preferenceKey);
      if (map != null) {
        var current = VideoSource.fromJson(map);
        current.actived = null;
        await setStore(current);
      }
    }
  }

  Future<void> setStore(VideoSource data) async {
    _data = data;
    await PreferenceUtil.setMap(preferenceKey, data.toJson());
    // Use microtask to allow gestures to finish before route swap
    scheduleMicrotask(() {
      notifyListeners();
    });
  }

  Future<void> addSource(String url) async {
    var current = data ?? VideoSource(source: [], actived: url);
    List<String> sources = List<String>.from(current.source ?? []);

    // Remove if exists to re-insert at top
    sources.remove(url);
    sources.insert(0, url);

    // Limit to 30
    if (sources.length > 30) {
      sources = sources.sublist(0, 30);
    }

    current.source = sources;
    current.actived = url;

    await setStore(current);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty(preferenceKey, data));
  }
}
