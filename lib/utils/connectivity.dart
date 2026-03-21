import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

void watchConnectivity(ConnectivityResult? result, Function cb) {
  StreamSubscription<ConnectivityResult>? subscription;
  Connectivity connectivity = Connectivity();

  subscription =
      connectivity.onConnectivityChanged.listen((ConnectivityResult event) {
    if (result == null) {
      subscription?.cancel();
      cb();
    } else {
      if (event == result) {
        subscription?.cancel();
        cb();
      }
    }
  });
}
