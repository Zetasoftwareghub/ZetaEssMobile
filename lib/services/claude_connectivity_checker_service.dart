// // 1. Add to pubspec.yaml:
// // dependencies:
// //   connectivity_plus: ^5.0.2
// //   internet_connection_checker: ^1.0.0+1
//
// import 'dart:async';
//
// // 2. Network Connectivity Service
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
//
// class NetworkConnectivityService {
//   static final NetworkConnectivityService _instance =
//       NetworkConnectivityService._internal();
//   factory NetworkConnectivityService() => _instance;
//   NetworkConnectivityService._internal();
//
//   final Connectivity _connectivity = Connectivity();
//   final InternetConnectionChecker _internetChecker =
//       InternetConnectionChecker.instance;
//
//   StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
//   StreamSubscription<InternetConnectionStatus>? _internetSubscription;
//
//   final StreamController<bool> _networkStatusController =
//       StreamController<bool>.broadcast();
//
//   Stream<bool> get networkStatusStream => _networkStatusController.stream;
//
//   bool _isConnected = true;
//   bool get isConnected => _isConnected;
//
//   Future<void> initialize() async {
//     // Check initial connectivity
//     await _checkInitialConnectivity();
//
//     // Listen to connectivity changes
//     _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
//       _onConnectivityChanged,
//     );
//
//     // Listen to internet connection changes
//     _internetSubscription = _internetChecker.onStatusChange.listen(
//       _onInternetStatusChanged,
//     );
//   }
//
//   Future<void> _checkInitialConnectivity() async {
//     try {
//       final connectivityResults = await _connectivity.checkConnectivity();
//       final hasInternet = await _internetChecker.hasConnection;
//
//       _isConnected =
//           connectivityResults.any(
//             (result) => result != ConnectivityResult.none,
//           ) &&
//           hasInternet;
//       _networkStatusController.add(_isConnected);
//     } catch (e) {
//       _isConnected = false;
//       _networkStatusController.add(false);
//     }
//   }
//
//   void _onConnectivityChanged(List<ConnectivityResult> results) {
//     final hasConnection = results.any(
//       (result) => result != ConnectivityResult.none,
//     );
//     if (!hasConnection) {
//       _isConnected = false;
//       _networkStatusController.add(false);
//     } else {
//       _checkInternetConnection();
//     }
//   }
//
//   void _onInternetStatusChanged(InternetConnectionStatus status) {
//     _isConnected = status == InternetConnectionStatus.connected;
//     _networkStatusController.add(_isConnected);
//   }
//
//   Future<void> _checkInternetConnection() async {
//     try {
//       final hasInternet = await _internetChecker.hasConnection;
//       _isConnected = hasInternet;
//       _networkStatusController.add(_isConnected);
//     } catch (e) {
//       _isConnected = false;
//       _networkStatusController.add(false);
//     }
//   }
//
//   Future<bool> checkConnectivity() async {
//     try {
//       final connectivityResults = await _connectivity.checkConnectivity();
//       final hasConnection = connectivityResults.any(
//         (result) => result != ConnectivityResult.none,
//       );
//
//       if (!hasConnection) {
//         _isConnected = false;
//         return false;
//       }
//
//       final hasInternet = await _internetChecker.hasConnection;
//       _isConnected = hasInternet;
//       return _isConnected;
//     } catch (e) {
//       _isConnected = false;
//       return false;
//     }
//   }
//
//   void dispose() {
//     _connectivitySubscription?.cancel();
//     _internetSubscription?.cancel();
//     _networkStatusController.close();
//   }
// }
//
// // 3. Custom Alert Dialog Widget
// class CustomNetworkAlertDialog extends StatelessWidget {
//   final VoidCallback? onRetry;
//   final VoidCallback? onCancel;
//   final String title;
//   final String message;
//   final String retryText;
//   final String cancelText;
//
//   const CustomNetworkAlertDialog({
//     Key? key,
//     this.onRetry,
//     this.onCancel,
//     this.title = 'No Internet Connection',
//     this.message = 'Please check your internet connection and try again.',
//     this.retryText = 'Retry',
//     this.cancelText = 'Cancel',
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       title: Row(
//         children: [
//           Icon(Icons.wifi_off, color: Colors.red, size: 24),
//           SizedBox(width: 12),
//           Text(
//             title,
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//           ),
//         ],
//       ),
//       content: Text(
//         message,
//         style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//       ),
//       actions: [
//         if (onCancel != null)
//           TextButton(
//             onPressed: onCancel,
//             child: Text(cancelText, style: TextStyle(color: Colors.grey[600])),
//           ),
//         ElevatedButton(
//           onPressed: onRetry,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.blue,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//           child: Text(retryText),
//         ),
//       ],
//     );
//   }
//
//   static Future<void> show(
//     BuildContext context, {
//     VoidCallback? onRetry,
//     VoidCallback? onCancel,
//     String title = 'No Internet Connection',
//     String message = 'Please check your internet connection and try again.',
//     String retryText = 'Retry',
//     String cancelText = 'Cancel',
//     bool barrierDismissible = false,
//   }) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: barrierDismissible,
//       builder: (BuildContext context) {
//         return CustomNetworkAlertDialog(
//           onRetry: onRetry,
//           onCancel: onCancel,
//           title: title,
//           message: message,
//           retryText: retryText,
//           cancelText: cancelText,
//         );
//       },
//     );
//   }
// }
//
// // 4. Network Aware Widget Mixin
// mixin NetworkAwareMixin<T extends StatefulWidget> on State<T> {
//   StreamSubscription<bool>? _networkSubscription;
//   bool _isDialogShowing = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _startNetworkMonitoring();
//   }
//
//   void _startNetworkMonitoring() {
//     _networkSubscription = NetworkConnectivityService().networkStatusStream
//         .listen((isConnected) {
//           if (!isConnected && !_isDialogShowing) {
//             _showNetworkDialog();
//           }
//         });
//   }
//
//   void _showNetworkDialog() {
//     if (!mounted) return;
//
//     _isDialogShowing = true;
//     CustomNetworkAlertDialog.show(
//       context,
//       onRetry: () async {
//         Navigator.of(context).pop();
//         _isDialogShowing = false;
//
//         // Check connectivity again
//         final isConnected =
//             await NetworkConnectivityService().checkConnectivity();
//         if (!isConnected) {
//           // Still no connection, show dialog again after a delay
//           Future.delayed(Duration(milliseconds: 500), () {
//             if (mounted) _showNetworkDialog();
//           });
//         } else {
//           // Connection restored, call onNetworkRestored if implemented
//           onNetworkRestored();
//         }
//       },
//       onCancel: () {
//         Navigator.of(context).pop();
//         _isDialogShowing = false;
//       },
//       barrierDismissible: false,
//     );
//   }
//
//   // Override this method in your widgets if needed
//   void onNetworkRestored() {
//     // Default implementation - can be overridden
//   }
//
//   @override
//   void dispose() {
//     _networkSubscription?.cancel();
//     super.dispose();
//   }
// }
//
// // 5. Network Connectivity Wrapper Widget
// class NetworkConnectivityWrapper extends StatefulWidget {
//   final Widget child;
//   final VoidCallback? onNetworkRestored;
//
//   const NetworkConnectivityWrapper({
//     Key? key,
//     required this.child,
//     this.onNetworkRestored,
//   }) : super(key: key);
//
//   @override
//   State<NetworkConnectivityWrapper> createState() =>
//       _NetworkConnectivityWrapperState();
// }
//
// class _NetworkConnectivityWrapperState extends State<NetworkConnectivityWrapper>
//     with NetworkAwareMixin {
//   @override
//   void onNetworkRestored() {
//     widget.onNetworkRestored?.call();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return widget.child;
//   }
// }
//
// // 6. Network-aware HTTP Client Helper
// class NetworkAwareHttpClient {
//   static Future<bool> checkConnectivityBeforeRequest() async {
//     final isConnected = await NetworkConnectivityService().checkConnectivity();
//     return isConnected;
//   }
//
//   static Future<T?> safeNetworkCall<T>(
//     Future<T> Function() networkCall, {
//     required BuildContext context,
//     VoidCallback? onNoNetwork,
//   }) async {
//     try {
//       final hasConnection = await checkConnectivityBeforeRequest();
//       if (!hasConnection) {
//         onNoNetwork?.call();
//         return null;
//       }
//       return await networkCall();
//     } catch (e) {
//       // Handle network-related errors
//       if (e.toString().contains('Network') ||
//           e.toString().contains('connection')) {
//         onNoNetwork?.call();
//       }
//       rethrow;
//     }
//   }
// }
//
// // 8. Example usage in a screen
// class ExampleScreen extends StatefulWidget {
//   @override
//   _ExampleScreenState createState() => _ExampleScreenState();
// }
//
// class _ExampleScreenState extends State<ExampleScreen> with NetworkAwareMixin {
//   @override
//   void onNetworkRestored() {
//     // Custom logic when network is restored
//     // For example, refresh data, retry failed requests, etc.
//     print('Network restored in ExampleScreen');
//     // You can call your data fetching methods here
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Example Screen')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async {
//             // Example of safe network call
//             await NetworkAwareHttpClient.safeNetworkCall(
//               () => yourApiCall(),
//               context: context,
//               onNoNetwork: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('No internet connection')),
//                 );
//               },
//             );
//           },
//           child: Text('Make Network Call'),
//         ),
//       ),
//     );
//   }
//
//   Future<void> yourApiCall() async {
//     // Your actual API call here
//   }
// }
//
// // 9. Helper function to check connectivity before specific operations
// Future<bool> ensureConnectivity(BuildContext context) async {
//   final isConnected = await NetworkConnectivityService().checkConnectivity();
//   if (!isConnected) {
//     CustomNetworkAlertDialog.show(
//       context,
//       onRetry: () async {
//         Navigator.of(context).pop();
//         await ensureConnectivity(context);
//       },
//     );
//     return false;
//   }
//   return true;
// }
