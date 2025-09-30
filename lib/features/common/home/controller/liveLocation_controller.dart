import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

// Location Data Model
class LiveLocation {
  final Position position;
  final String placeName;

  LiveLocation({required this.position, required this.placeName});

  @override
  String toString() =>
      'LiveLocation(lat: ${position.latitude}, lng: ${position.longitude}, place: $placeName)';
}

// Custom Exceptions
class LocationServiceDisabledException implements Exception {
  final String message;
  LocationServiceDisabledException([
    this.message = 'Location services are disabled',
  ]);
  @override
  String toString() => message;
}

class LocationPermissionDeniedException implements Exception {
  final String message;
  LocationPermissionDeniedException([
    this.message = 'Location permission denied',
  ]);
  @override
  String toString() => message;
}

class LocationPermissionPermanentlyDeniedException implements Exception {
  final String message;
  LocationPermissionPermanentlyDeniedException([
    this.message = 'Location permission permanently denied',
  ]);
  @override
  String toString() => message;
}

class LiveLocationController extends StateNotifier<AsyncValue<LiveLocation>> {
  StreamSubscription<Position>? _positionStream;
  Timer? _timeoutTimer;
  Timer? _serviceMonitorTimer;

  LiveLocationController() : super(const AsyncValue.loading()) {
    _initialize();
  }

  // Initialize location tracking
  Future<void> _initialize() async {
    try {
      await _checkLocationServices();
      await _checkLocationPermission();
      await _startLocationTracking();
    } catch (e, stackTrace) {
      _cancelTimeoutTimer(); // Cancel timeout on error
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Helper method to cancel timeout timer
  void _cancelTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  // Check if location services are enabled
  Future<void> _checkLocationServices() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceDisabledException(
        'Location services are disabled. Please enable them in device settings.'
            .tr(),
      );
    }
  }

  // Check and request location permission
  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationPermissionDeniedException(
          'Location permission denied by user.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionPermanentlyDeniedException(
        'Location permission permanently denied. Please enable it in app settings.',
      );
    }

    if (permission == LocationPermission.unableToDetermine) {
      throw LocationPermissionDeniedException(
        'Unable to determine location permission status.',
      );
    }
  }

  // Start location tracking with continuous monitoring
  Future<void> _startLocationTracking() async {
    // Cancel any existing stream and timers
    await _positionStream?.cancel();
    _cancelTimeoutTimer();

    // Set a timeout for getting first location
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      // Only show timeout error if still in loading state
      if (state is AsyncLoading && mounted) {
        state = AsyncValue.error(
          LocationServiceDisabledException(
            'Unable to get location. Please check your location and try again.',
          ),
          StackTrace.current,
        );
      }
    });

    try {
      Position? initialPosition;
      try {
        initialPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } on TimeoutException {
        initialPosition = await Geolocator.getLastKnownPosition();
        try {
          if (initialPosition == null) {
            throw LocationServiceDisabledException(
              'Unable to fetch location (timeout). Try moving to an open area.',
            );
          }
        } catch (e) {
          if (e is PermissionDeniedException) {
            throw LocationPermissionDeniedException();
          } else {
            throw Exception('Location error: $e');
          }
        }
      } catch (e) {
        // Handle other location errors
        if (e.toString().contains('PERMISSION_DENIED')) {
          throw LocationPermissionDeniedException(
            'Location permission is required to continue.',
          );
        } else if (e.toString().contains('LOCATION_SERVICES_DISABLED')) {
          throw LocationServiceDisabledException(
            'Please enable location services to continue.',
          );
        } else {
          throw LocationServiceDisabledException(
            'Unable to get your location. Please check your location settings.',
          );
        }
      }

      if (initialPosition != null) {
        final placeName = await _getPlaceNameFromCoordinates(initialPosition);

        // SUCCESS: Cancel timeout timer immediately and update state
        _cancelTimeoutTimer();

        if (mounted) {
          state = AsyncValue.data(
            LiveLocation(position: initialPosition, placeName: placeName),
          );
        }
      }

      // Start listening to position stream with error handling
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update when user moves 10 meters
        ),
      ).listen(
        (Position position) async {
          try {
            // Double-check location services are still enabled
            final serviceEnabled = await Geolocator.isLocationServiceEnabled();
            if (!serviceEnabled) {
              if (mounted) {
                state = AsyncValue.error(
                  LocationServiceDisabledException(
                    'Location services were disabled. Please enable them to continue.',
                  ),
                  StackTrace.current,
                );
              }
              return;
            }

            final placeName = await _getPlaceNameFromCoordinates(position);

            if (mounted) {
              state = AsyncValue.data(
                LiveLocation(position: position, placeName: placeName),
              );
            }
          } catch (e) {
            // If geocoding fails, still update position with unknown location
            if (mounted) {
              state = AsyncValue.data(
                LiveLocation(position: position, placeName: 'Unknown location'),
              );
            }
          }
        },
        onError: (error, stackTrace) {
          // Cancel timeout timer on stream error
          _cancelTimeoutTimer();

          // Convert technical errors to user-friendly messages
          String userFriendlyMessage;

          if (error is TimeoutException) {
            userFriendlyMessage =
                'Unable to get location. Please check your location signal and try again.';
          } else if (error.toString().contains('PERMISSION_DENIED')) {
            userFriendlyMessage =
                'Location permission is required. Please enable it in settings.';
          } else if (error.toString().toLowerCase().contains('location') &&
              error.toString().toLowerCase().contains('disabled')) {
            userFriendlyMessage =
                'Location services are disabled. Please enable them in device settings.';
          } else if (error.toString().contains('location') ||
              error.toString().contains('NETWORK_ERROR')) {
            userFriendlyMessage =
                'Unable to get location. Please check your location and network connection.';
          } else {
            userFriendlyMessage =
                'Unable to get your location. Please try again.';
          }

          if (mounted) {
            state = AsyncValue.error(
              LocationServiceDisabledException(userFriendlyMessage),
              StackTrace.current,
            );
          }
        },
      );

      // Start periodic location service monitoring
      _startLocationServiceMonitoring();
    } catch (e, stackTrace) {
      // Cancel timeout timer on any error
      _cancelTimeoutTimer();

      // Ensure we always show user-friendly errors
      if (e is LocationServiceDisabledException ||
          e is LocationPermissionDeniedException ||
          e is LocationPermissionPermanentlyDeniedException) {
        if (mounted) {
          state = AsyncValue.error(e, StackTrace.current);
        }
      } else {
        if (mounted) {
          state = AsyncValue.error(
            LocationServiceDisabledException(
              'Unable to get your location. Please check your settings and try again.',
            ),
            StackTrace.current,
          );
        }
      }
    }
  }

  // Monitor location services periodically
  void _startLocationServiceMonitoring() {
    _serviceMonitorTimer?.cancel();
    _serviceMonitorTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      try {
        // Only monitor if we have a successful location state
        if (state.hasValue && mounted) {
          final serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            timer.cancel();
            state = AsyncValue.error(
              LocationServiceDisabledException(
                'Location services were disabled. Please enable them to continue.',
              ),
              StackTrace.current,
            );
          }
        }
      } catch (e) {
        // Silent fail for monitoring - don't change state
        print('Location service monitoring error: $e');
      }
    });
  }

  // Get place name from coordinates with error handling
  Future<String> _getPlaceNameFromCoordinates(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 5));

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final addressParts = <String>[
          if (place.street?.isNotEmpty == true) place.street!,
          if (place.subLocality?.isNotEmpty == true) place.subLocality!,
          if (place.locality?.isNotEmpty == true) place.locality!,
          if (place.administrativeArea?.isNotEmpty == true)
            place.administrativeArea!,
          if (place.country?.isNotEmpty == true) place.country!,
        ];

        return addressParts.isNotEmpty
            ? addressParts.join(', ')
            : 'Unknown location';
      }
      return 'Unknown location';
    } catch (e) {
      print('Geocoding error: $e');
      return 'Unable to get location name';
    }
  }

  // Public method to retry location request
  Future<void> retry() async {
    _cancelTimeoutTimer(); // Cancel any existing timeout
    state = const AsyncValue.loading();
    await _initialize();
  }

  // Method to handle manual retry with comprehensive checks
  Future<void> manualRetry() async {
    _cancelTimeoutTimer(); // Cancel any existing timeout
    state = const AsyncValue.loading();

    try {
      // Check location services first
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationServiceDisabledException();
      }

      // Check permission status
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        throw LocationPermissionPermanentlyDeniedException();
      }

      if (permission == LocationPermission.denied) {
        final newPermission = await Geolocator.requestPermission();
        if (newPermission == LocationPermission.denied) {
          throw LocationPermissionDeniedException();
        }
        if (newPermission == LocationPermission.deniedForever) {
          throw LocationPermissionPermanentlyDeniedException();
        }
      }

      // If all checks pass, start tracking
      await _startLocationTracking();
    } catch (e, stackTrace) {
      _cancelTimeoutTimer(); // Cancel timeout on error
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  // Helper method to open location settings
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      print('Could not open location settings: $e');
      return false;
    }
  }

  // Helper method to open app settings
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      print('Could not open app settings: $e');
      return false;
    }
  }

  // Get current location status
  Future<Map<String, dynamic>> getLocationStatus() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Geolocator.checkPermission();

    return {
      'serviceEnabled': serviceEnabled,
      'permission': permission.toString(),
      'canRequestPermission': permission == LocationPermission.denied,
      'needsAppSettings': permission == LocationPermission.deniedForever,
    };
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _cancelTimeoutTimer();
    _serviceMonitorTimer?.cancel();
    super.dispose();
  }
}

// Provider definition
final liveLocationControllerProvider =
    StateNotifierProvider<LiveLocationController, AsyncValue<LiveLocation>>((
      ref,
    ) {
      return LiveLocationController();
    });
