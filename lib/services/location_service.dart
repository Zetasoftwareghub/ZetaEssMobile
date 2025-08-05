import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<bool> hasPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  static Stream<Position> getLiveLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // meters
      ),
    );
  }

  static Future<String> getPlaceName(Position position) async {
    try {
      // Use the geocoding package to get Placemark objects
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        String address = "";
        if (place.name != null &&
            place.name!.isNotEmpty &&
            place.name != place.street) {
          address += "${place.name}, ";
        }
        if (place.street != null && place.street!.isNotEmpty) {
          address += "${place.street}, ";
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          address += "${place.subLocality}, ";
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += "${place.locality}, "; // City
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          address += "${place.administrativeArea}, "; // State
        }
        if (place.country != null && place.country!.isNotEmpty) {
          address += "${place.country}";
        }

        // Remove trailing comma and space if any
        if (address.endsWith(", ")) {
          address = address.substring(0, address.length - 2);
        }

        return address.isEmpty ? "Unknown Place" : address;
      } else {
        return "Place name not found";
      }
    } catch (e) {
      print("Error getting place name: $e");
      return "Error fetching place name";
    }
  }
}
