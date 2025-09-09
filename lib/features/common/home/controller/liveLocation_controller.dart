import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

// Location Data Model
class LiveLocation {
  final Position position;
  final String placeName;

  LiveLocation({required this.position, required this.placeName});
}

class LiveLocationController extends StateNotifier<AsyncValue<LiveLocation>> {
  StreamSubscription<Position>? _positionStream;

  LiveLocationController() : super(const AsyncValue.loading()) {
    _startListening();
  }

  Future<void> _startListening() async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      // Start listening to location changes
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // update when user moves 10 meters
        ),
      ).listen((position) async {
        String placeName = await _getPlaceNameFromCoordinates(position);

        state = AsyncValue.data(
          LiveLocation(position: position, placeName: placeName),
        );
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String> _getPlaceNameFromCoordinates(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        return '${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}';
      }
      return 'Unknown location';
    } catch (_) {
      return 'Unable to get location name';
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}

/*
// Location Controller Class
class LiveLocationController extends StateNotifier<AsyncValue<LiveLocation>> {
  LiveLocationController() : super(const AsyncValue.loading()) {
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      await _getCurrentLocation();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _getCurrentLocation() async {
    state = const AsyncValue.loading();

    try {
      // ✅ Only check permission; do NOT check if location is enabled manually
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      // ✅ This will show the **default system dialog** if location is OFF
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      String placeName = await _getPlaceNameFromCoordinates(position);

      state = AsyncValue.data(
        LiveLocation(position: position, placeName: placeName),
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<String> _getPlaceNameFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}';
      }
      return 'Unknown location';
    } catch (e) {
      return 'Unable to get location name';
    }
  }

  // Method to manually refresh location
  Future<void> refreshLocation() async {
    await _getCurrentLocation();
  }

  // Method to handle permission granted scenario
  Future<void> onPermissionGranted() async {
    // Wait a bit for the system to process the permission
    await Future.delayed(const Duration(milliseconds: 500));
    await _getCurrentLocation();
  }
}
*/

// Provider definition
final liveLocationControllerProvider =
    StateNotifierProvider<LiveLocationController, AsyncValue<LiveLocation>>((
      ref,
    ) {
      return LiveLocationController();
    });

// Alternative: FutureProvider approach (simpler but less control)
final liveLocationFutureProvider = FutureProvider<LiveLocation>((ref) async {
  // Check if location services are enabled
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled');
  }

  // Check location permission
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permissions are permanently denied');
  }

  //TODO check this is right or wrtong newly given code !
  // Position position = await Geolocator.getCurrentPosition(
  //   desiredAccuracy: LocationAccuracy.high,
  //   timeLimit: const Duration(seconds: 10),
  // );

  Position? position;
  try {
    position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,

      timeLimit: const Duration(seconds: 10),
    );
  } on TimeoutException {
    position = await Geolocator.getLastKnownPosition();
    if (position == null) {
      throw Exception('Unable to get location..');
    }
  }

  // Get place name
  String placeName = 'Unknown location';
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      placeName =
          '${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}';
    }
  } catch (e) {
    placeName = 'Unable to get location name';
  }

  return LiveLocation(position: position, placeName: placeName);
});

// Permission handler helper
class LocationPermissionHandler {
  static Future<void> handlePermissionResult(WidgetRef ref) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      // Permission granted, refresh the location
    }
  }
}
