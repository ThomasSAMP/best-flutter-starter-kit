import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../shared/repositories/user_repository.dart';
import '../errors/auth_exception.dart';
import '../utils/logger.dart';

@lazySingleton
class AuthService {
  final FirebaseAuth _firebaseAuth;
  final UserRepository _userRepository;

  AuthService(this._firebaseAuth, this._userRepository);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  bool get isAuthenticated => currentUser != null;

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('Sign in error', e, stackTrace);
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Sign in error', e, stackTrace);
      throw AuthException(message: 'An unexpected error occurred');
    }
  }

  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      // 1. Créer l'utilisateur dans Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // 2. Créer l'utilisateur dans Firestore
        await _userRepository.createUser(user);
      }

      return user;
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('Sign up error', e, stackTrace);
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Sign up error', e, stackTrace);
      throw AuthException(message: 'An unexpected error occurred');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('Password reset error', e, stackTrace);
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Password reset error', e, stackTrace);
      throw AuthException(message: 'An unexpected error occurred');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e, stackTrace) {
      AppLogger.error('Sign out error', e, stackTrace);
      throw AuthException(message: 'Failed to sign out');
    }
  }
}
