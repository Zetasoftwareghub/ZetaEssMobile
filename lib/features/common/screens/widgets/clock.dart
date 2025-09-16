import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zeta_ess/core/common/loader.dart';
import 'package:zeta_ess/core/theme/common_theme.dart';

import '../../home/controller/liveLocation_controller.dart';

final locationTimeProvider = StateProvider<DateTime?>((ref) => null);

class RealTimeClock extends ConsumerStatefulWidget {
  const RealTimeClock({super.key});

  @override
  ConsumerState<RealTimeClock> createState() => _RealTimeClockState();
}

class _RealTimeClockState extends ConsumerState<RealTimeClock>
    with WidgetsBindingObserver {
  Timer? _timer;
  final Dio dio = Dio();
  final String apiKey = 'EGZAA5DADGVE';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startClockTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App resumed, refresh time
      debugPrint('App resumed, refreshing time...');
      final locationState = ref.read(liveLocationControllerProvider);
      locationState.whenData((location) {
        _fetchLocationTime(
          location.position.latitude,
          location.position.longitude,
        ).then((newTime) {
          if (newTime != null && mounted) {
            ref.read(locationTimeProvider.notifier).state = newTime;
          } else if (mounted) {
            ref.read(locationTimeProvider.notifier).state = DateTime.now();
          }
        });
      });
    }
  }

  void _startClockTimer() {
    // Timer to update clock every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final previous = ref.read(locationTimeProvider);
      if (previous != null) {
        ref.read(locationTimeProvider.notifier).state = previous.add(
          const Duration(seconds: 1),
        );
      }
    });
  }

  Future<void> _initializeTimeFromLocation(LiveLocation location) async {
    if (_isInitialized) return;

    try {
      final locationTime = await _fetchLocationTime(
        location.position.latitude,
        location.position.longitude,
      );

      if (!mounted) return;
      ref.read(locationTimeProvider.notifier).state =
          locationTime ?? DateTime.now();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error fetching location time: $e');
      if (!mounted) return;
      ref.read(locationTimeProvider.notifier).state = DateTime.now();
      _isInitialized = true;
    }
  }

  Future<DateTime?> _fetchLocationTime(double lat, double lng) async {
    try {
      final response = await dio.get(
        'http://api.timezonedb.com/v2.1/get-time-zone',
        queryParameters: {
          'key': apiKey,
          'format': 'json',
          'by': 'position',
          'lat': lat,
          'lng': lng,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final timeStr = data['formatted'];
        return DateTime.parse(timeStr);
      } else {
        debugPrint('TimeZoneDB failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception fetching time: $e');
      return null;
    }
  }

  String _formatTime(DateTime dateTime) =>
      DateFormat('hh   :  mm   :  ss   a').format(dateTime);
  String _formatDate(DateTime dateTime) =>
      DateFormat('MMM dd, yyyy - EEEE').format(dateTime);
  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(liveLocationControllerProvider);
    final locationTime = ref.watch(locationTimeProvider);
    final size = MediaQuery.of(context).size;
    final w = size.width;

    // Listen to location changes and initialize time when location is available
    locationState.whenData((location) {
      // Use a microtask to avoid calling setState during build
      Future.microtask(() => _initializeTimeFromLocation(location));
    });

    // Show loader if we don't have time yet
    if (locationTime == null) {
      return const Text('');
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Temporarily hidden: Clock display
        Text(
          _formatTime(locationTime),
          style: TextStyle(fontSize: w * 0.07, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),

        Text(_formatDate(locationTime), style: AppTextStyles.mediumFont()),
      ],
    );
  }
}

// final locationTimeProvider = StateProvider<DateTime?>((ref) => null);
//
// class RealTimeClock extends ConsumerStatefulWidget {
//   const RealTimeClock({super.key});
//
//   @override
//   ConsumerState<RealTimeClock> createState() => _RealTimeClockState();
// }
//
// class _RealTimeClockState extends ConsumerState<RealTimeClock> {
//   Timer? _timer;
//   final Dio dio = Dio();
//   final String apiKey = 'EGZAA5DADGVE';
//   Timer? _retryTimer;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeTimeWithPermissionRetry();
//     });
//   }
//
//   @override
//   void dispose() {
//     _retryTimer?.cancel();
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   Future<void> _initializeTimeWithPermissionRetry() async {
//     // Initial try
//     DateTime initialTime = await _getLocationTimeOrNow();
//
//     if (!mounted) return;
//     ref.read(locationTimeProvider.notifier).state = initialTime;
//
//     // Retry every 5 seconds
//     _retryTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
//       print('Retrying for permission...');
//       final hasPermission = await LocationService.hasPermission();
//
//       if (hasPermission) {
//         final updatedTime = await _getLocationTimeOrNow();
//         if (!mounted) return;
//         ref.read(locationTimeProvider.notifier).state = updatedTime;
//         timer.cancel(); // Stop retrying
//       }
//     });
//
//     // Timer to update clock every second
//     _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (!mounted) return;
//       final previous = ref.read(locationTimeProvider);
//       if (previous != null) {
//         ref.read(locationTimeProvider.notifier).state = previous.add(
//           const Duration(seconds: 1),
//         );
//       }
//     });
//   }
//
//   Future<DateTime> _getLocationTimeOrNow() async {
//     try {
//       final hasPermission = await LocationService.hasPermission();
//       if (!hasPermission) throw Exception('Location permission not granted');
//
//       final position = await Geolocator.getCurrentPosition();
//       final locationTime = await _fetchLocationTime(
//         position.latitude,
//         position.longitude,
//       );
//       return locationTime ?? DateTime.now();
//     } catch (e) {
//       debugPrint('Error fetching location time: $e');
//       return DateTime.now();
//     }
//   }
//
//   Future<DateTime?> _fetchLocationTime(double lat, double lng) async {
//     try {
//       final response = await dio.get(
//         'http://api.timezonedb.com/v2.1/get-time-zone',
//         queryParameters: {
//           'key': apiKey,
//           'format': 'json',
//           'by': 'position',
//           'lat': lat,
//           'lng': lng,
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final data = response.data;
//         final timeStr = data['formatted'];
//         return DateTime.parse(timeStr);
//       } else {
//         debugPrint('TimeZoneDB failed: ${response.statusCode}');
//         return null;
//       }
//     } catch (e) {
//       debugPrint('Exception fetching time: $e');
//       return null;
//     }
//   }
//
//   String _formatTime(DateTime dateTime) =>
//       DateFormat('hh   :  mm   :  ss   a').format(dateTime);
//   String _formatDate(DateTime dateTime) =>
//       DateFormat('MMM dd, yyyy - EEEE').format(dateTime);
//
//   @override
//   Widget build(BuildContext context) {
//     final locationTime = ref.watch(locationTimeProvider);
//     final size = MediaQuery.of(context).size;
//     final w = size.width;
//
//     if (locationTime == null) {
//       return const Loader();
//     }
//
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           _formatTime(locationTime),
//           style: TextStyle(fontSize: w * 0.07, fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(height: 5),
//         Text(
//           _formatDate(locationTime),
//           style: TextStyle(color: Colors.black54, fontSize: w * 0.035),
//         ),
//       ],
//     );
//   }
// }
