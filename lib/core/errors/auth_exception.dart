import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  final String code;
  final String message;

  AuthException({this.code = 'unknown', required this.message});

  factory AuthException.fromFirebaseAuthException(FirebaseAuthException e) {
    String message;

    switch (e.code) {
      case 'invalid-email':
        message = 'The email address is not valid.';
        break;
      case 'user-disabled':
        message = 'This user has been disabled.';
        break;
      case 'user-not-found':
        message = 'No user found with this email.';
        break;
      case 'wrong-password':
        message = 'Incorrect password.';
        break;
      case 'email-already-in-use':
        message = 'This email is already in use by another account.';
        break;
      case 'weak-password':
        message = 'The password is too weak.';
        break;
      case 'operation-not-allowed':
        message = 'This operation is not allowed.';
        break;
      case 'too-many-requests':
        message = 'Too many requests. Try again later.';
        break;
      default:
        message = e.message ?? 'An unknown error occurred.';
    }

    return AuthException(code: e.code, message: message);
  }

  @override
  String toString() => 'AuthException: $message (code: $code)';
}
