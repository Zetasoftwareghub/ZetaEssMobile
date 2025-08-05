import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityStatusProvider =
    StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
      return ConnectivityNotifier();
    });

class ConnectivityNotifier extends StateNotifier<bool> {
  late StreamSubscription _subscription;

  ConnectivityNotifier() : super(true) {
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      state = result != ConnectivityResult.none;
    });

    _initialize();
  }

  Future<void> _initialize() async {
    final result = await Connectivity().checkConnectivity();
    state = result != ConnectivityResult.none;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
