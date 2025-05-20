import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../shared/repositories/user_repository.dart';
import '../di/injection.dart';
import '../errors/auth_exception.dart';
import '../utils/logger.dart';
import 'error_service.dart';

@lazySingleton
class AuthService {
  final FirebaseAuth _firebaseAuth;
  final UserRepository _userRepository;
  late final ErrorService _errorService;

  AuthService(this._firebaseAuth, this._userRepository) {
    // Initialize _errorService via getIt
    _errorService = getIt<ErrorService>();
  }

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  bool get isAuthenticated => currentUser != null;

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set user information for Crashlytics
      final user = userCredential.user;
      if (user != null) {
        await _errorService.setUserInfo(user.uid, email: user.email, name: user.displayName);
      }

      return user;
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('Sign in error', e, stackTrace);
      await _errorService.recordError(
        e,
        stackTrace,
        reason: 'Sign in error: ${e.code}',
        information: ['email: $email'],
      );
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Sign in error', e, stackTrace);
      await _errorService.recordError(
        e,
        stackTrace,
        reason: 'Sign in error: unexpected',
        information: ['email: $email'],
      );
      throw AuthException(message: 'An unexpected error occurred');
    }
  }

  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      // 1. Create user in Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // 2. Create user in Firestore
        await _userRepository.createUser(user);

        // 3. Set user information for Crashlytics
        await _errorService.setUserInfo(user.uid, email: user.email, name: user.displayName);
      }

      return user;
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('Sign up error', e, stackTrace);
      await _errorService.recordError(
        e,
        stackTrace,
        reason: 'Sign up error: ${e.code}',
        information: ['email: $email'],
      );
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Sign up error', e, stackTrace);
      await _errorService.recordError(
        e,
        stackTrace,
        reason: 'Sign up error: unexpected',
        information: ['email: $email'],
      );
      throw AuthException(message: 'An unexpected error occurred');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('Password reset error', e, stackTrace);
      await _errorService.recordError(
        e,
        stackTrace,
        reason: 'Password reset error: ${e.code}',
        information: ['email: $email'],
      );
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Password reset error', e, stackTrace);
      await _errorService.recordError(
        e,
        stackTrace,
        reason: 'Password reset error: unexpected',
        information: ['email: $email'],
      );
      throw AuthException(message: 'An unexpected error occurred');
    }
  }

  Future<void> signOut() async {
    try {
      // Reset user information for Crashlytics
      await _errorService.setUserInfo('anonymous');

      await _firebaseAuth.signOut();
    } catch (e, stackTrace) {
      AppLogger.error('Sign out error', e, stackTrace);
      await _errorService.recordError(e, stackTrace, reason: 'Sign out error');
      throw AuthException(message: 'Failed to sign out');
    }
  }
}
