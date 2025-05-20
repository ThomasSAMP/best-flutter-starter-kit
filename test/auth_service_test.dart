// IMPORTANT: to build mocks, you need to execute this command
// flutter pub run build_runner build --delete-conflicting-outputs

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_template/core/config/env_config.dart';
import 'package:flutter_template/core/errors/auth_exception.dart';
import 'package:flutter_template/core/services/auth_service.dart';
import 'package:flutter_template/shared/repositories/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_service_test.mocks.dart';

export 'mocks/mock_logger.dart' show MockAppLogger;

@GenerateMocks([FirebaseAuth, UserCredential, User, UserRepository])
void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserRepository mockUserRepository;
  late AuthService authService;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  // Initialize EnvConfig before all tests
  setUpAll(() {
    // Initialize EnvConfig with test environnement
    EnvConfig.initialize(Environment.dev);
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserRepository = MockUserRepository();
    authService = AuthService(mockFirebaseAuth, mockUserRepository);
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
  });

  group('AuthService', () {
    test('currentUser should return user from FirebaseAuth', () {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // Act
      final result = authService.currentUser;

      // Assert
      expect(result, mockUser);
      verify(mockFirebaseAuth.currentUser).called(1);
    });

    test('isAuthenticated should return true when user is not null', () {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // Act
      final result = authService.isAuthenticated;

      // Assert
      expect(result, true);
      verify(mockFirebaseAuth.currentUser).called(1);
    });

    test('isAuthenticated should return false when user is null', () {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = authService.isAuthenticated;

      // Assert
      expect(result, false);
      verify(mockFirebaseAuth.currentUser).called(1);
    });

    test('signInWithEmailAndPassword should return user on success', () async {
      // Arrange
      when(
        mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password',
        ),
      ).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);

      // Act
      final result = await authService.signInWithEmailAndPassword('test@example.com', 'password');

      // Assert
      expect(result, mockUser);
      verify(
        mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password',
        ),
      ).called(1);
    });

    test(
      'signInWithEmailAndPassword should throw AuthException on FirebaseAuthException',
      () async {
        // Arrange
        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password',
          ),
        ).thenThrow(FirebaseAuthException(code: 'user-not-found'));

        // Act & Assert
        expect(
          () => authService.signInWithEmailAndPassword('test@example.com', 'password'),
          throwsA(isA<AuthException>()),
        );
      },
    );

    test('createUserWithEmailAndPassword should create user in Firestore', () async {
      // Arrange
      when(
        mockFirebaseAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password',
        ),
      ).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUserRepository.createUser(mockUser)).thenAnswer((_) async => {});

      // Act
      final result = await authService.createUserWithEmailAndPassword(
        'test@example.com',
        'password',
      );

      // Assert
      expect(result, mockUser);
      verify(
        mockFirebaseAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password',
        ),
      ).called(1);
      verify(mockUserRepository.createUser(mockUser)).called(1);
    });
  });
}
