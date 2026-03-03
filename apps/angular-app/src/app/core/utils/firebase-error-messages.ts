const ERROR_MESSAGES: Record<string, string> = {
  'auth/email-already-in-use': 'Cette adresse email est déjà utilisée.',
  'auth/invalid-email': "L'adresse email n'est pas valide.",
  'auth/weak-password': 'Le mot de passe est trop faible.',
  'auth/user-not-found': 'Aucun compte associé à cet email.',
  'auth/wrong-password': 'Mot de passe incorrect.',
  'auth/invalid-credential': 'Email ou mot de passe incorrect.',
  'auth/too-many-requests': 'Trop de tentatives. Réessayez dans quelques minutes.',
  'auth/network-request-failed': 'Problème de connexion réseau.',
  'auth/user-disabled': 'Ce compte a été désactivé.',
};

export function mapFirebaseError(code: string): string {
  return ERROR_MESSAGES[code] ?? "Une erreur inattendue s'est produite.";
}
