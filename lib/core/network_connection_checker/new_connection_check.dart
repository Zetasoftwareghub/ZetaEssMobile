import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Checks if the device has an active internet connection
///
/// This function performs a two-step check:
/// 1. First checks if device is connected to WiFi/Mobile network
/// 2. Then verifies actual internet connectivity by making a DNS lookup
///
/// Returns [true] if internet is available, [false] otherwise
Future<bool> checkInternetConnection() async {
  try {
    // Step 1: Check network connectivity type
    final connectivityResult = await Connectivity().checkConnectivity();

    // If not connected to any network, return false immediately
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    // Step 2: Verify actual internet access by DNS lookup
    // This ensures we're not just connected to WiFi without internet
    final result = await InternetAddress.lookup(
      'google.com',
    ).timeout(const Duration(seconds: 5));

    // If we got results and at least one address is not empty, we have internet
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }

    return false;
  } on SocketException catch (_) {
    // DNS lookup failed - no internet
    return false;
  } catch (e) {
    // Any other error - assume no internet for safety
    return false;
  }
}

/// Alternative: Simple network connectivity check (faster but less reliable)
/// Only checks if device is connected to WiFi/Mobile, doesn't verify internet access
Future<bool> checkNetworkConnection() async {
  try {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  } catch (e) {
    return false;
  }
}

/// Stream-based connectivity monitoring
/// Useful for real-time network status updates
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Stream that emits connectivity changes
  Stream<List<ConnectivityResult>> get connectivityStream =>
      _connectivity.onConnectivityChanged;

  /// Check current connectivity status
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return await _connectivity.checkConnectivity();
  }

  /// Check if currently connected to any network
  Future<bool> isConnected() async {
    final result = await checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Full internet check with DNS lookup
  Future<bool> hasInternetAccess() async {
    return await checkInternetConnection();
  }
}

/// Usage Example:
///
/// ```dart
/// // Simple check
/// final hasInternet = await checkInternetConnection();
/// if (!hasInternet) {
///   showNoInternetPopup();
/// }
///
/// // Using ConnectivityService
/// final connectivityService = ConnectivityService();
///
/// // One-time check
/// final isConnected = await connectivityService.hasInternetAccess();
///
/// // Listen to connectivity changes
/// connectivityService.connectivityStream.listen((result) {
///   if (result == ConnectivityResult.none) {
///     print('No internet connection');
///   } else if (result == ConnectivityResult.mobile) {
///     print('Connected via mobile data');
///   } else if (result == ConnectivityResult.wifi) {
///     print('Connected via WiFi');
///   }
/// });
/// ```
