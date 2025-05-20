import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/injection.dart';
import '../../core/services/auth_service.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

// Provider pour l'utilisateur Firebase Auth
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = getIt<AuthService>();
  return authService.authStateChanges;
});

// Provider pour l'utilisateur actuel (modèle complet)
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return null;

      final userRepository = getIt<UserRepository>();
      return userRepository.getCurrentUser();
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Provider pour vérifier si l'utilisateur est authentifié
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});
