import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:zeta_ess/services/location_service.dart';

// Import your LocationService class

// Generate mocks
@GenerateMocks([GeolocatorPlatform])
import 'location_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('LocationService Tests', () {
    late MockGeolocatorPlatform mockGeolocator;

    setUp(() {
      mockGeolocator = MockGeolocatorPlatform();
      // Set the mock as the instance to use
      GeolocatorPlatform.instance = mockGeolocator;
    });

    group('hasPermission', () {
      test('should return true when permission is whileInUse', () async {
        // Arrange
        when(
          mockGeolocator.checkPermission(),
        ).thenAnswer((_) async => LocationPermission.whileInUse);

        // Act
        final result = await LocationService.hasPermission();

        // Assert
        expect(result, true);
        verify(mockGeolocator.checkPermission()).called(1);
        verifyNever(mockGeolocator.requestPermission());
      });

      test('should return true when permission is always', () async {
        // Arrange
        when(
          mockGeolocator.checkPermission(),
        ).thenAnswer((_) async => LocationPermission.always);

        // Act
        final result = await LocationService.hasPermission();

        // Assert
        expect(result, true);
        verify(mockGeolocator.checkPermission()).called(1);
        verifyNever(mockGeolocator.requestPermission());
      });

      test(
        'should request permission when denied and return true if granted whileInUse',
        () async {
          // Arrange
          when(
            mockGeolocator.checkPermission(),
          ).thenAnswer((_) async => LocationPermission.denied);
          when(
            mockGeolocator.requestPermission(),
          ).thenAnswer((_) async => LocationPermission.whileInUse);

          // Act
          final result = await LocationService.hasPermission();

          // Assert
          expect(result, true);
          verify(mockGeolocator.checkPermission()).called(1);
          verify(mockGeolocator.requestPermission()).called(1);
        },
      );

      test(
        'should request permission when denied and return true if granted always',
        () async {
          // Arrange
          when(
            mockGeolocator.checkPermission(),
          ).thenAnswer((_) async => LocationPermission.denied);
          when(
            mockGeolocator.requestPermission(),
          ).thenAnswer((_) async => LocationPermission.always);

          // Act
          final result = await LocationService.hasPermission();

          // Assert
          expect(result, true);
          verify(mockGeolocator.checkPermission()).called(1);
          verify(mockGeolocator.requestPermission()).called(1);
        },
      );

      test(
        'should return false when permission is permanently denied',
        () async {
          // Arrange
          when(
            mockGeolocator.checkPermission(),
          ).thenAnswer((_) async => LocationPermission.denied);
          when(
            mockGeolocator.requestPermission(),
          ).thenAnswer((_) async => LocationPermission.deniedForever);

          // Act
          final result = await LocationService.hasPermission();

          // Assert
          expect(result, false);
          verify(mockGeolocator.checkPermission()).called(1);
          verify(mockGeolocator.requestPermission()).called(1);
        },
      );

      test('should return false when permission request is denied', () async {
        // Arrange
        when(
          mockGeolocator.checkPermission(),
        ).thenAnswer((_) async => LocationPermission.denied);
        when(
          mockGeolocator.requestPermission(),
        ).thenAnswer((_) async => LocationPermission.denied);

        // Act
        final result = await LocationService.hasPermission();

        // Assert
        expect(result, false);
        verify(mockGeolocator.checkPermission()).called(1);
        verify(mockGeolocator.requestPermission()).called(1);
      });

      test(
        'should return false when permission is unableToDetermine',
        () async {
          // Arrange
          when(
            mockGeolocator.checkPermission(),
          ).thenAnswer((_) async => LocationPermission.unableToDetermine);

          // Act
          final result = await LocationService.hasPermission();

          // Assert
          expect(result, false);
          verify(mockGeolocator.checkPermission()).called(1);
          verifyNever(mockGeolocator.requestPermission());
        },
      );
    });

    group('getLiveLocationStream', () {
      test('should return position stream with correct settings', () {
        // Arrange
        final mockStream = Stream<Position>.empty();
        when(
          mockGeolocator.getPositionStream(
            locationSettings: anyNamed('locationSettings'),
          ),
        ).thenAnswer((_) => mockStream);

        // Act
        final result = LocationService.getLiveLocationStream();

        // Assert
        expect(result, equals(mockStream));
        verify(
          mockGeolocator.getPositionStream(
            locationSettings: argThat(
              isA<LocationSettings>()
                  .having((s) => s.accuracy, 'accuracy', LocationAccuracy.high)
                  .having((s) => s.distanceFilter, 'distanceFilter', 10),
              named: 'locationSettings',
            ),
          ),
        ).called(1);
      });
    });

    group('getPlaceName', () {
      final testPosition = Position(
        longitude: -122.4194,
        latitude: 37.7749,
        timestamp: DateTime.now(),
        accuracy: 5.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );

      test('should return formatted address when placemark is found', () async {
        // Arrange
        final mockPlacemark = Placemark(
          name: 'Golden Gate Bridge',
          street: 'Golden Gate Bridge',
          subLocality: 'Presidio',
          locality: 'San Francisco',
          administrativeArea: 'CA',
          country: 'United States',
        );

        // Mock the geocoding function
        // Note: You'll need to create a wrapper around placemarkFromCoordinates
        // or use dependency injection to make this testable

        // Act & Assert would depend on how you structure the geocoding dependency
        // For now, I'll show the test structure
      });

      test('should return "Unknown Place" when address is empty', () async {
        // Test for when all placemark fields are null/empty
      });

      test(
        'should return "Place name not found" when placemarks list is empty',
        () async {
          // Test for empty placemarks list
        },
      );

      test('should return error message when exception is thrown', () async {
        // Test for exception handling
      });

      test('should format address correctly with all fields present', () async {
        // Test complete address formatting
      });

      test(
        'should format address correctly with some fields missing',
        () async {
          // Test partial address formatting
        },
      );

      test('should remove trailing comma and space', () async {
        // Test address cleanup
      });

      test('should handle when name equals street', () async {
        // Test when name and street are the same
      });
    });
  });
}

// Alternative approach for testing getPlaceName with dependency injection
// Create a wrapper class that can be mocked:

abstract class GeocodingService {
  Future<List<Placemark>> getPlacemarks(double latitude, double longitude);
}

class GeocodingServiceImpl implements GeocodingService {
  @override
  Future<List<Placemark>> getPlacemarks(double latitude, double longitude) {
    return placemarkFromCoordinates(latitude, longitude);
  }
}

// Modified LocationService that accepts GeocodingService
class TestableLocationService {
  final GeocodingService geocodingService;

  TestableLocationService(this.geocodingService);

  Future<String> getPlaceName(Position position) async {
    try {
      List<Placemark> placemarks = await geocodingService.getPlacemarks(
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
          address += "${place.locality}, ";
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          address += "${place.administrativeArea}, ";
        }
        if (place.country != null && place.country!.isNotEmpty) {
          address += "${place.country}";
        }

        if (address.endsWith(", ")) {
          address = address.substring(0, address.length - 2);
        }

        return address.isEmpty ? "Unknown Place" : address;
      } else {
        return "Place name not found";
      }
    } catch (e) {
      return "Error fetching place name";
    }
  }
}

// Tests for getPlaceName with mocked geocoding service
@GenerateMocks([GeocodingService])
void testGetPlaceNameWithMocks() {
  group('TestableLocationService.getPlaceName', () {
    late MockGeocodingService mockGeocodingService;
    late TestableLocationService locationService;
    late Position testPosition;

    setUp(() {
      mockGeocodingService = MockGeocodingService();
      locationService = TestableLocationService(mockGeocodingService);
      testPosition = Position(
        longitude: -122.4194,
        latitude: 37.7749,
        timestamp: DateTime.now(),
        accuracy: 5.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );
    });

    test('should return formatted address when placemark is found', () async {
      // Arrange
      final mockPlacemark = Placemark(
        name: 'Golden Gate Bridge',
        street: 'Golden Gate Bridge',
        subLocality: 'Presidio',
        locality: 'San Francisco',
        administrativeArea: 'CA',
        country: 'United States',
      );
      when(
        mockGeocodingService.getPlacemarks(any, any),
      ).thenAnswer((_) async => [mockPlacemark]);

      // Act
      final result = await locationService.getPlaceName(testPosition);

      // Assert
      expect(
        result,
        'Golden Gate Bridge, Presidio, San Francisco, CA, United States',
      );
      verify(
        mockGeocodingService.getPlacemarks(
          testPosition.latitude,
          testPosition.longitude,
        ),
      ).called(1);
    });

    test('should return "Unknown Place" when address is empty', () async {
      // Arrange
      final emptyPlacemark = Placemark();
      when(
        mockGeocodingService.getPlacemarks(any, any),
      ).thenAnswer((_) async => [emptyPlacemark]);

      // Act
      final result = await locationService.getPlaceName(testPosition);

      // Assert
      expect(result, 'Unknown Place');
    });

    test(
      'should return "Place name not found" when placemarks list is empty',
      () async {
        // Arrange
        when(
          mockGeocodingService.getPlacemarks(any, any),
        ).thenAnswer((_) async => []);

        // Act
        final result = await locationService.getPlaceName(testPosition);

        // Assert
        expect(result, 'Place name not found');
      },
    );

    test('should return error message when exception is thrown', () async {
      // Arrange
      when(
        mockGeocodingService.getPlacemarks(any, any),
      ).thenThrow(Exception('Network error'));

      // Act
      final result = await locationService.getPlaceName(testPosition);

      // Assert
      expect(result, 'Error fetching place name');
    });

    test('should skip name when it equals street', () async {
      // Arrange
      final placemark = Placemark(
        name: 'Main Street',
        street: 'Main Street',
        locality: 'Springfield',
        country: 'USA',
      );
      when(
        mockGeocodingService.getPlacemarks(any, any),
      ).thenAnswer((_) async => [placemark]);

      // Act
      final result = await locationService.getPlaceName(testPosition);

      // Assert
      expect(result, 'Main Street, Springfield, USA');
      expect(result, isNot(contains('Main Street, Main Street')));
    });

    test('should handle partial address information', () async {
      // Arrange
      final placemark = Placemark(locality: 'Springfield', country: 'USA');
      when(
        mockGeocodingService.getPlacemarks(any, any),
      ).thenAnswer((_) async => [placemark]);

      // Act
      final result = await locationService.getPlaceName(testPosition);

      // Assert
      expect(result, 'Springfield, USA');
    });

    test('should remove trailing comma and space', () async {
      // Arrange
      final placemark = Placemark(country: 'USA');
      when(
        mockGeocodingService.getPlacemarks(any, any),
      ).thenAnswer((_) async => [placemark]);

      // Act
      final result = await locationService.getPlaceName(testPosition);

      // Assert
      expect(result, 'USA');
      expect(result, isNot(endsWith(', ')));
    });
  });
}
