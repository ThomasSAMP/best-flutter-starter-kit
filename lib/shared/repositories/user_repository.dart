import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../models/user_model.dart';
import '../../core/utils/logger.dart';

@lazySingleton
class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserRepository(this._firestore, this._auth);

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!..['id'] = doc.id);
      }

      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting current user', e, stackTrace);
      return null;
    }
  }

  Future<void> createUser(User user) async {
    try {
      final now = DateTime.now();
      final userModel = UserModel(
        id: user.uid,
        email: user.email!,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toJson());
    } catch (e, stackTrace) {
      AppLogger.error('Error creating user', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(updatedUser.toJson());
    } catch (e, stackTrace) {
      AppLogger.error('Error updating user', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      await _auth.currentUser?.delete();
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting user', e, stackTrace);
      rethrow;
    }
  }
}
