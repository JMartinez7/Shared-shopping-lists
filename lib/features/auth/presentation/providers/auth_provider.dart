import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_user.dart';
import '../../infrastructure/repositories/auth_repository.dart';

// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Auth state provider - listens to Firebase auth state changes
final authStateProvider = StreamProvider<AppUser?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

// Current user provider
final currentUserProvider = Provider<AppUser?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.currentUser;
});

// Auth actions provider
final authActionsProvider = Provider<AuthActions>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthActions(authRepository);
});

class AuthActions {
  final AuthRepository _authRepository;

  AuthActions(this._authRepository);

  Future<AppUser?> signInWithGoogle() async {
    return await _authRepository.signInWithGoogle();
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
