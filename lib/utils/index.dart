import 'dart:async';
import 'dart:ui';

export 'preference.dart';
export 'px_fit.dart';
export 'date_scope.dart';
export 'connectivity.dart';

class Throttler {
  final int milliseconds;
  Timer? _timer;
  bool _isReady = true;

  Throttler({required this.milliseconds});

  void run(VoidCallback action) {
    if (_isReady) {
      _isReady = false;
      action();
      _timer = Timer(Duration(milliseconds: milliseconds), () {
        _isReady = true;
      });
    }
  }

  void cancel() {
    _timer?.cancel();
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void cancel() {
    _timer?.cancel();
  }
}

// Address splicing
String getUrl(String origin, String url) {
  if (origin.endsWith('/')) {
    return '$origin$url';
  } else {
    return '$origin/$url';
  }
}

String getDomainName(String url) {
  final uri = Uri.parse(url);
  return uri.host;
}

String sanitizeImageUrl(String? url) {
  final value = url?.trim() ?? '';
  if (value.isEmpty) {
    return '';
  }

  return value.replaceFirst(RegExp(r'\?\[(?:#)?[^\]]+\]$'), '');
}
