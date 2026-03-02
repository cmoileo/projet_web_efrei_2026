import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_model.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/user_service.dart';
import '../../../core/utils/firebase_error_messages.dart';
import 'auth_state.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(firestoreProvider));
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserModelProvider = StreamProvider<UserModel?>((ref) async* {
  final authService = ref.read(authServiceProvider);
  final userService = ref.read(userServiceProvider);

  await for (final firebaseUser in authService.authStateChanges) {
    debugPrint('[Auth] authStateChanges → uid=${firebaseUser?.uid ?? "null"}');
    if (firebaseUser == null) {
      yield null;
    } else {
      // Retry avec backoff pour absorber la race condition entre
      // createUserWithEmailAndPassword (authStateChanges immédiat)
      // et createUser (écriture Firestore légèrement différée).
      UserModel? model;
      const maxAttempts = 4;
      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          debugPrint(
              '[Auth] Fetching UserModel for uid=${firebaseUser.uid} (attempt $attempt/$maxAttempts)');
          model = await userService.getUser(firebaseUser.uid);
          if (model != null) break;
        } catch (e) {
          debugPrint('[Auth] Erreur getUser (attempt $attempt): $e');
        }
        if (attempt < maxAttempts) {
          await Future<void>.delayed(Duration(seconds: attempt));
        }
      }

      debugPrint(
          '[Auth] UserModel fetched → ${model == null ? "null after $maxAttempts attempts" : model.uid}');

      if (model == null) {
        // Après plusieurs tentatives toujours pas de doc → compte vraiment orphelin.
        debugPrint('[Auth] Compte orphelin confirmé, déconnexion automatique.');
        await authService.signOut();
      } else {
        yield model;
      }
    }
  }
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    authService: ref.watch(authServiceProvider),
    userService: ref.watch(userServiceProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({
    required AuthService authService,
    required UserService userService,
  })  : _authService = authService,
        _userService = userService,
        super(const AuthState());

  final AuthService _authService;
  final UserService _userService;

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = await _userService.getUser(credential.user!.uid);
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: FirebaseErrorMessages.fromException(e),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Impossible de charger votre profil. Réessayez.',
      );
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String nickname,
    required DateTime birthdate,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    UserCredential? credential;
    try {
      credential = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final now = DateTime.now();
      final newUser = UserModel(
        uid: credential.user!.uid,
        firstName: firstName,
        lastName: lastName,
        nickname: nickname,
        email: email,
        birthdate: birthdate,
        role: role,
        createdAt: now,
        updatedAt: now,
      );
      await _userService.createUser(newUser);
      state = state.copyWith(isLoading: false, user: newUser);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: FirebaseErrorMessages.fromException(e),
      );
      return false;
    } catch (_) {
      // Échec de l'écriture Firestore (ex. permission-denied) :
      // on supprime le compte Firebase Auth pour éviter un compte orphelin.
      await credential?.user?.delete();
      state = state.copyWith(
        isLoading: false,
        error:
            'La création du profil a échoué. Vérifiez votre connexion et réessayez.',
      );
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authService.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: FirebaseErrorMessages.fromException(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
