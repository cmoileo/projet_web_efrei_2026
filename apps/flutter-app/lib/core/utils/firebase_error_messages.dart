import 'package:firebase_auth/firebase_auth.dart';

abstract final class FirebaseErrorMessages {
  static String fromCode(String code) => switch (code) {
        'email-already-in-use' => 'Cette adresse email est déjà utilisée.',
        'invalid-email' => "L'adresse email n'est pas valide.",
        'weak-password' => 'Le mot de passe est trop faible.',
        'user-not-found' => 'Aucun compte associé à cet email.',
        'wrong-password' => 'Mot de passe incorrect.',
        'invalid-credential' => 'Email ou mot de passe incorrect.',
        'too-many-requests' =>
          'Trop de tentatives. Réessayez dans quelques minutes.',
        'network-request-failed' => 'Problème de connexion réseau.',
        'user-disabled' => 'Ce compte a été désactivé.',
        _ => 'Une erreur inattendue s\'est produite.',
      };

  static String fromException(FirebaseAuthException e) => fromCode(e.code);
}
