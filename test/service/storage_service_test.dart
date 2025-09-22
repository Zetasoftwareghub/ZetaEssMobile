import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:zeta_ess/core/api_constants/keys/storage_keys.dart';
import 'package:zeta_ess/services/secure_stroage_service.dart';

import 'storage_service_test.mocks.dart';

// Generate mocks
@GenerateMocks([FlutterSecureStorage])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('SecureStorageService Tests', () {
    late MockFlutterSecureStorage mockStorage;
    late SecureStorageService testService;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      testService = SecureStorageService();
      SecureStorageService.testInit(mockStorage);
    });

    tearDown(() {
      reset(mockStorage);
    });

    group('write', () {
      test(
        'should call FlutterSecureStorage.write with correct parameters',
        () async {
          // Arrange
          const key = 'test_key';
          const value = 'test_value';
          when(
            mockStorage.write(key: key, value: value),
          ).thenAnswer((_) async => {});

          // Act
          await SecureStorageService.write(key: key, value: value);

          // Assert
          verify(mockStorage.write(key: key, value: value)).called(1);
        },
      );

      test('should handle write operation with empty value', () async {
        // Arrange
        const key = 'test_key';
        const value = '';
        when(
          mockStorage.write(key: key, value: value),
        ).thenAnswer((_) async => {});

        // Act
        await SecureStorageService.write(key: key, value: value);

        // Assert
        verify(mockStorage.write(key: key, value: value)).called(1);
      });

      test('should handle write operation with special characters', () async {
        // Arrange
        const key = 'test_key';
        const value = 'test@#\$%^&*()_+value';
        when(
          mockStorage.write(key: key, value: value),
        ).thenAnswer((_) async => {});

        // Act
        await SecureStorageService.write(key: key, value: value);

        // Assert
        verify(mockStorage.write(key: key, value: value)).called(1);
      });

      test('should throw exception when write fails', () async {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        when(
          mockStorage.write(key: key, value: value),
        ).thenThrow(Exception('Storage write failed'));

        // Act & Assert
        expect(
          () => SecureStorageService.write(key: key, value: value),
          throwsException,
        );
      });
    });

    group('read', () {
      test('should return value when key exists', () async {
        // Arrange
        const key = 'test_key';
        const expectedValue = 'test_value';
        when(mockStorage.read(key: key)).thenAnswer((_) async => expectedValue);

        // Act
        final result = await SecureStorageService.read(key: key);

        // Assert
        expect(result, equals(expectedValue));
        verify(mockStorage.read(key: key)).called(1);
      });

      test('should return null when key does not exist', () async {
        // Arrange
        const key = 'non_existent_key';
        when(mockStorage.read(key: key)).thenAnswer((_) async => null);

        // Act
        final result = await SecureStorageService.read(key: key);

        // Assert
        expect(result, isNull);
        verify(mockStorage.read(key: key)).called(1);
      });

      test('should handle read operation with empty string value', () async {
        // Arrange
        const key = 'test_key';
        const expectedValue = '';
        when(mockStorage.read(key: key)).thenAnswer((_) async => expectedValue);

        // Act
        final result = await SecureStorageService.read(key: key);

        // Assert
        expect(result, equals(expectedValue));
        verify(mockStorage.read(key: key)).called(1);
      });

      test('should throw exception when read fails', () async {
        // Arrange
        const key = 'test_key';
        when(
          mockStorage.read(key: key),
        ).thenThrow(Exception('Storage read failed'));

        // Act & Assert
        expect(() => SecureStorageService.read(key: key), throwsException);
      });
    });

    group('delete', () {
      test(
        'should call FlutterSecureStorage.delete with correct key',
        () async {
          // Arrange
          const key = 'test_key';
          when(mockStorage.delete(key: key)).thenAnswer((_) async => {});

          // Act
          await SecureStorageService.delete(key: key);

          // Assert
          verify(mockStorage.delete(key: key)).called(1);
        },
      );

      test('should handle delete operation for non-existent key', () async {
        // Arrange
        const key = 'non_existent_key';
        when(mockStorage.delete(key: key)).thenAnswer((_) async => {});

        // Act
        await SecureStorageService.delete(key: key);

        // Assert
        verify(mockStorage.delete(key: key)).called(1);
      });

      test('should throw exception when delete fails', () async {
        // Arrange
        const key = 'test_key';
        when(
          mockStorage.delete(key: key),
        ).thenThrow(Exception('Storage delete failed'));

        // Act & Assert
        expect(() => SecureStorageService.delete(key: key), throwsException);
      });
    });

    group('clearAll', () {
      test(
        'should delete all keys except baseUrl and hasShownShowcase',
        () async {
          // Arrange
          final mockData = {
            'user_token': 'token_value',
            'user_id': '123',
            StorageKeys.baseUrl: 'https://api.example.com',
            StorageKeys.hasShownShowcase: 'true',
            'other_key': 'other_value',
          };

          when(mockStorage.readAll()).thenAnswer((_) async => mockData);

          // Mock delete calls for keys that should be deleted
          when(
            mockStorage.delete(key: 'user_token'),
          ).thenAnswer((_) async => {});
          when(mockStorage.delete(key: 'user_id')).thenAnswer((_) async => {});
          when(
            mockStorage.delete(key: 'other_key'),
          ).thenAnswer((_) async => {});

          // Act
          await SecureStorageService.clearAll();

          // Assert
          verify(mockStorage.readAll()).called(1);

          // Verify that keys except baseUrl and hasShownShowcase are deleted
          verify(mockStorage.delete(key: 'user_token')).called(1);
          verify(mockStorage.delete(key: 'user_id')).called(1);
          verify(mockStorage.delete(key: 'other_key')).called(1);

          // Verify that protected keys are NOT deleted
          verifyNever(mockStorage.delete(key: StorageKeys.baseUrl));
          verifyNever(mockStorage.delete(key: StorageKeys.hasShownShowcase));
        },
      );

      test('should handle empty storage', () async {
        // Arrange
        when(mockStorage.readAll()).thenAnswer((_) async => <String, String>{});

        // Act
        await SecureStorageService.clearAll();

        // Assert
        verify(mockStorage.readAll()).called(1);
        verifyNever(mockStorage.delete(key: anyNamed('key')));
      });

      test('should handle storage with only protected keys', () async {
        // Arrange
        final mockData = {
          StorageKeys.baseUrl: 'https://api.example.com',
          StorageKeys.hasShownShowcase: 'true',
        };

        when(mockStorage.readAll()).thenAnswer((_) async => mockData);

        // Act
        await SecureStorageService.clearAll();

        // Assert
        verify(mockStorage.readAll()).called(1);
        verifyNever(mockStorage.delete(key: anyNamed('key')));
      });

      test('should throw exception when readAll fails', () async {
        // Arrange
        when(
          mockStorage.readAll(),
        ).thenThrow(Exception('Storage readAll failed'));

        // Act & Assert
        expect(() => SecureStorageService.clearAll(), throwsException);
      });

      test(
        'should continue clearing even if one delete operation fails',
        () async {
          // Arrange
          final mockData = {
            'key1': 'value1',
            'key2': 'value2',
            'key3': 'value3',
          };

          when(mockStorage.readAll()).thenAnswer((_) async => mockData);

          when(mockStorage.delete(key: 'key1')).thenAnswer((_) async => {});
          when(
            mockStorage.delete(key: 'key2'),
          ).thenThrow(Exception('Delete failed'));
          when(mockStorage.delete(key: 'key3')).thenAnswer((_) async => {});

          // Act & Assert
          expect(() => SecureStorageService.clearAll(), throwsException);

          // Verify that the method attempted to delete all keys
          verify(mockStorage.delete(key: 'key1')).called(1);
          verify(mockStorage.delete(key: 'key2')).called(1);
          // key3 might not be called due to exception in key2
        },
      );
    });

    group('Integration Tests', () {
      test('should write and read the same value', () async {
        // Arrange
        const key = 'integration_key';
        const value = 'integration_value';

        when(
          mockStorage.write(key: key, value: value),
        ).thenAnswer((_) async => {});
        when(mockStorage.read(key: key)).thenAnswer((_) async => value);

        // Act
        await SecureStorageService.write(key: key, value: value);
        final result = await SecureStorageService.read(key: key);

        // Assert
        expect(result, equals(value));
      });

      test('should return null after deleting a key', () async {
        // Arrange
        const key = 'to_delete_key';

        when(mockStorage.delete(key: key)).thenAnswer((_) async => {});
        when(mockStorage.read(key: key)).thenAnswer((_) async => null);

        // Act
        await SecureStorageService.delete(key: key);
        final result = await SecureStorageService.read(key: key);

        // Assert
        expect(result, isNull);
      });
    });
  });
}
