import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeta_ess/core/api_constants/auth_apis/auth_api.dart';
import 'package:zeta_ess/core/providers/userContext_provider.dart';
import 'package:zeta_ess/features/auth/repository/auth_repository.dart';
import 'package:zeta_ess/models/company_model.dart';
import 'package:zeta_ess/models/user_model.dart';

// Generate mocks
@GenerateMocks([Dio, UserContext, BuildContext])
import 'auth_repository_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AuthRepository Tests', () {
    late AuthRepository authRepository;
    late MockDio mockDio;
    late MockUserContext mockUserContext;
    late MockBuildContext mockBuildContext;

    setUp(() {
      mockDio = MockDio();
      mockUserContext = MockUserContext();
      mockBuildContext = MockBuildContext();

      authRepository = AuthRepository();
      // Replace the dio instance with our mock
      authRepository.dio = mockDio;

      // Setup common mock returns for UserContext
      when(mockUserContext.baseUrl).thenReturn('https://api.example.com');
      when(mockUserContext.companyCode).thenReturn('TEST123');
      when(mockUserContext.companyConnection).thenReturn('TEST_CONN');
      when(mockUserContext.jwtToken).thenReturn('mock_jwt_token');
    });

    tearDown(() {
      reset(mockDio);
      reset(mockUserContext);
      reset(mockBuildContext);
    });

    group('activateUrl', () {
      const testUrl = 'https://test-api.com';

      test('should return success response when API call succeeds', () async {
        // Arrange
        final mockResponse = Response<Map<String, dynamic>>(
          data: {'message': 'URL activated successfully'},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(
          mockDio.get('$testUrl${AuthApis.activateUrl}'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await authRepository.activateUrl(url: testUrl);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should return right'),
          (data) =>
              expect(data, equals({'message': 'URL activated successfully'})),
        );
        verify(mockDio.get('$testUrl${AuthApis.activateUrl}')).called(1);
      });

      test('should return failure when status code is not 200', () async {
        // Arrange
        final mockResponse = Response<Map<String, dynamic>>(
          data: {'error': 'Bad request'},
          statusCode: 400,
          requestOptions: RequestOptions(path: ''),
        );

        when(
          mockDio.get('$testUrl${AuthApis.activateUrl}'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await authRepository.activateUrl(url: testUrl);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.errMsg, equals('Unknown error occurred')),
          (data) => fail('Should return left'),
        );
      });

      test('should return failure when response data is null', () async {
        // Arrange
        final mockResponse = Response<Map<String, dynamic>>(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(
          mockDio.get('$testUrl${AuthApis.activateUrl}'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await authRepository.activateUrl(url: testUrl);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.errMsg, equals('Unknown error occurred')),
          (data) => fail('Should return left'),
        );
      });

      test('should handle DioException', () async {
        // Arrange
        when(mockDio.get('$testUrl${AuthApis.activateUrl}')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        // Act
        final result = await authRepository.activateUrl(url: testUrl);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.errMsg, equals('Invalid Activation Url')),
          (data) => fail('Should return left'),
        );
      });

      test('should handle generic exception', () async {
        // Arrange
        when(
          mockDio.get('$testUrl${AuthApis.activateUrl}'),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await authRepository.activateUrl(url: testUrl);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.errMsg, equals('Invalid Activation Url')),
          (data) => fail('Should return left'),
        );
      });
    });

    group('loginUser', () {
      const userName = 'testuser';
      const password = 'testpass';
      const fcmToken = 'mock_fcm_token';

      test('should return UserModel when login is successful', () async {
        // Arrange
        final mockResponseData = {
          'success': true,
          'data': [
            {
              'id': '123',
              'name': 'Test User',
              'email': 'test@example.com',
              'escode': '0', // Success code
            },
          ],
        };

        final mockResponse = Response<Map<String, dynamic>>(
          data: mockResponseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(
          mockDio.post(any, data: anyNamed('data')),
        ).thenAnswer((_) async => mockResponse);

        // Mock ApiErrors.isError to return false (no error)
        // You'll need to mock this static method or restructure it for testing

        // Act
        final result = await authRepository.loginUser(
          userContext: mockUserContext,
          fcmToken: fcmToken,
          userName: userName,
          password: password,
          context: mockBuildContext,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('Should return right'), (user) {
          expect(user, isA<UserModel>());
        });
      });

      test('should return failure when API returns error code', () async {
        // Arrange
        final mockResponseData = {
          'success': true,
          'data': [
            {
              'escode': 'ERROR_001', // Error code
            },
          ],
        };

        final mockResponse = Response<Map<String, dynamic>>(
          data: mockResponseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(
          mockDio.post(any, data: anyNamed('data')),
        ).thenAnswer((_) async => mockResponse);

        // Mock ApiErrors.isError to return true (has error)
        // This would need to be mocked or restructured

        // Act
        final result = await authRepository.loginUser(
          userContext: mockUserContext,
          fcmToken: fcmToken,
          userName: userName,
          password: password,
          context: mockBuildContext,
        );

        // Assert
        expect(result.isLeft(), true);
      });

      test('should handle DioException', () async {
        // Arrange
        when(mockDio.post(any, data: anyNamed('data'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        // Act
        final result = await authRepository.loginUser(
          userContext: mockUserContext,
          fcmToken: fcmToken,
          userName: userName,
          password: password,
          context: mockBuildContext,
        );

        // Assert
        expect(result.isLeft(), true);
      });

      test('should send correct payload data', () async {
        // Arrange
        final mockResponse = Response<Map<String, dynamic>>(
          data: {
            'success': true,
            'data': [
              {'id': '123', 'escode': '0'},
            ],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(
          mockDio.post(any, data: anyNamed('data')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await authRepository.loginUser(
          userContext: mockUserContext,
          fcmToken: fcmToken,
          userName: userName,
          password: password,
          context: mockBuildContext,
        );

        // Assert
        final captured =
            verify(
              mockDio.post(captureAny, data: captureAnyNamed('data')),
            ).captured;

        final url = captured[0] as String;
        final payloadData = captured[1] as Map<String, dynamic>;

        expect(url, contains(AuthApis.loginInApi));
        expect(payloadData['userId'], equals(userName));
        expect(payloadData['password'], equals(password.toLowerCase()));
        expect(payloadData['deviceId'], equals(fcmToken));
        expect(payloadData['sucode'], equals('TEST123'));
        expect(payloadData['suconn'], equals('TEST_CONN'));
      });
    });

    group('ssoLogin', () {
      const email = 'test@example.com';

      test('should return UserModel when SSO login is successful', () async {
        // Arrange
        final mockResponseData = {
          'data': [
            {'id': '123', 'name': 'Test User', 'email': email, 'escode': '0'},
          ],
        };

        final mockResponse = Response<Map<String, dynamic>>(
          data: mockResponseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(
          mockDio.post(any, data: anyNamed('data')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await authRepository.ssoLogin(
          userContext: mockUserContext,
          email: email,
          context: mockBuildContext,
        );

        // Assert
        expect(result.isRight(), true);
      });

      test('should send correct SSO login payload', () async {
        // Arrange
        final mockResponse = Response<Map<String, dynamic>>(
          data: {
            'data': [
              {'id': '123', 'escode': '0'},
            ],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(
          mockDio.post(any, data: anyNamed('data')),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await authRepository.ssoLogin(
          userContext: mockUserContext,
          email: email,
          context: mockBuildContext,
        );

        // Assert
        final captured =
            verify(
              mockDio.post(captureAny, data: captureAnyNamed('data')),
            ).captured;

        final payloadData = captured[1] as Map<String, dynamic>;

        expect(payloadData['userMail'], equals(email));
        expect(payloadData['sucode'], equals('TEST123'));
        expect(payloadData['suconn'], equals('TEST_CONN'));
      });
    });

    group('getCompanies', () {
      test('should return list of CompanyModel when successful', () async {
        // Arrange
        final mockResponseData = {
          'success': true,
          'data': [
            {'id': '1', 'name': 'Company 1', 'code': 'COMP1'},
            {'id': '2', 'name': 'Company 2', 'code': 'COMP2'},
          ],
        };

        final mockResponse = Response<Map<String, dynamic>>(
          data: mockResponseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockDio.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await authRepository.getCompanies(
          userContext: mockUserContext,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('Should return right'), (companies) {
          expect(companies, isA<List<CompanyModel>>());
          expect(companies.length, equals(2));
        });
      });

      test('should return failure when success is false', () async {
        // Arrange
        final mockResponse = Response<Map<String, dynamic>>(
          data: {'success': false, 'data': []},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockDio.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await authRepository.getCompanies(
          userContext: mockUserContext,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.errMsg, equals('Unknown error occurred')),
          (data) => fail('Should return left'),
        );
      });

      test('should handle DioException', () async {
        // Arrange
        when(mockDio.get(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        // Act
        final result = await authRepository.getCompanies(
          userContext: mockUserContext,
        );

        // Assert
        expect(result.isLeft(), true);
      });
    });

    group('forgotPassword', () {
      const userId = 'testuser';
      const sucode = 'TEST123';

      test(
        'should return success message when password reset is successful',
        () async {
          // Arrange
          final mockResponseData = {
            'success': true,
            'data': 'Password reset email sent successfully',
          };

          final mockResponse = Response<Map<String, dynamic>>(
            data: mockResponseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          );

          when(
            mockDio.post(
              any,
              data: anyNamed('data'),
              options: anyNamed('options'),
            ),
          ).thenAnswer((_) async => mockResponse);

          // Act
          final result = await authRepository.forgotPassword(
            userContext: mockUserContext,
            userId: userId,
            sucode: sucode,
          );

          // Assert
          expect(result.isRight(), true);
          result.fold(
            (failure) => fail('Should return right'),
            (message) => expect(
              message,
              equals('Password reset email sent successfully'),
            ),
          );
        },
      );

      test('should send correct forgot password payload', () async {
        // Arrange
        final mockResponse = Response<Map<String, dynamic>>(
          data: {'success': true, 'data': 'Success'},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(
          mockDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        await authRepository.forgotPassword(
          userContext: mockUserContext,
          userId: userId,
          sucode: sucode,
        );

        // Assert
        final captured =
            verify(
              mockDio.post(
                captureAny,
                data: captureAnyNamed('data'),
                options: captureAnyNamed('options'),
              ),
            ).captured;

        final payloadData = captured[1] as Map<String, dynamic>;

        expect(payloadData['sucode'], equals('TEST123'));
        expect(payloadData['suconn'], equals('TEST_CONN'));
        expect(payloadData['userid'], equals(userId));
        expect(payloadData['activateurl'], equals('https://api.example.com'));
        expect(
          payloadData['sucode'],
          equals('TEST123'),
        ); // Note: sucode appears twice in original
      });

      test('should handle API failure', () async {
        // Arrange
        final mockResponse = Response<Map<String, dynamic>>(
          data: {'success': false},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(
          mockDio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await authRepository.forgotPassword(
          userContext: mockUserContext,
          userId: userId,
          sucode: sucode,
        );

        // Assert
        expect(result.isLeft(), true);
      });
    });

    group('Provider Tests', () {
      test('authRepositoryProvider should return AuthRepository instance', () {
        // Arrange
        final container = ProviderContainer();

        // Act
        final repository = container.read(authRepositoryProvider);

        // Assert
        expect(repository, isA<AuthRepository>());

        // Cleanup
        container.dispose();
      });
    });

    group('Integration Tests', () {
      test('should handle network timeout gracefully', () async {
        // Arrange
        when(mockDio.get(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        // Act
        final result = await authRepository.activateUrl(
          url: 'https://test.com',
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure.errMsg, equals('Invalid Activation Url')),
          (data) => fail('Should return left'),
        );
      });

      test('should handle malformed response data', () async {
        // Arrange
        final mockResponse = Response<Map<String, dynamic>>(
          data: {'invalid': 'structure'},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );

        when(mockDio.get(any)).thenAnswer((_) async => mockResponse);

        // Act
        final result = await authRepository.getCompanies(
          userContext: mockUserContext,
        );

        // Assert
        expect(result.isLeft(), true);
      });
    });
  });
}

// // Helper function to create mock UserModel (if needed)
// UserModel createMockUser({
//   String id = '123',
//   String name = 'Test User',
//   String email = 'test@example.com',
// }) {
//   return UserModel(id: id, name: name, email: email);
// }
//
// // Helper function to create mock CompanyModel (if needed)
// CompanyModel createMockCompany({
//   String id = '1',
//   String name = 'Test Company',
//   String code = 'TEST',
// }) {
//   return CompanyModel(id: id, name: name, code: code);
// }
