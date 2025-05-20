import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_template/core/services/auth_service.dart';
import 'package:flutter_template/core/errors/auth_exception.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([FirebaseAuth, UserCredential, User])
void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late AuthService authService;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    authService = AuthService(mockFirebaseAuth);
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
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password',
      )).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);

      // Act
      final result = await authService.signInWithEmailAndPassword(
        'test@example.com',
        'password',
      );

      // Assert
      expect(result, mockUser);
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password',
      )).called(1);
    });

    test('signInWithEmailAndPassword should throw AuthException on FirebaseAuthException', () async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password',
      )).thenThrow(
        FirebaseAuthException(code: 'user-not-found'),
      );

      // Act & Assert
      expect(
        () => authService.signInWithEmailAndPassword('test@example.com', 'password'),
        throwsA(isA<AuthException>()),
      );
    });
  });
}