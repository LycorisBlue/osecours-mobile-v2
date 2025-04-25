/// Cette classe `ApiErrorMessages` fournit des messages d'erreur standardisés
/// pour différentes situations d'erreur rencontrées lors de l'utilisation de l'API.
/// 
/// La méthode statique `getErrorMessage` prend un type d'erreur en entrée et 
/// retourne un message d'erreur approprié en fonction du type d'erreur fourni.
/// 
/// Cette classe permet de centraliser et de standardiser les messages d'erreur,
/// facilitant ainsi la gestion des erreurs et l'expérience utilisateur.
class ApiErrorMessages {
  // Méthode statique pour obtenir un message d'erreur en fonction du type d'erreur
  static String getErrorMessage(String errorType) {
    switch (errorType) {
      // Erreurs de validation
      case 'VALIDATION_ERROR':
        return 'Veuillez saisir correctement tous les champs du formulaire.';

      // Erreurs d'authentification
      case 'USER_NOT_FOUND':
        return 'Email inconnu, veuillez vous renseigner ou créer un compte.';
      case 'INVALID_PASSWORD':
        return 'Mot de passe incorrect.';
      case 'UNAUTHORIZED':
        return 'Accès non autorisé, veuillez vous connecter.';

      // Erreurs de token
      case 'TOKEN_MISSING':
        return 'Session expirée, veuillez vous reconnecter.';
      case 'TOKEN_INVALID':
        return 'Session invalide, veuillez vous reconnecter.';
      case 'TOKEN_EXPIRED':
        return 'Votre session a expiré, veuillez vous reconnecter.';
      case 'TOKEN_REVOKED':
        return 'Cette session n\'est plus valide, veuillez vous reconnecter.';
      case 'INVALID_TOKEN_TYPE':
        return 'Type de jeton non valide, veuillez vous reconnecter.';
      case 'TOKEN_REVOCATION_ERROR':
        return 'Erreur lors de la déconnexion, veuillez réessayer.';
      case 'ROOT_USER_REFRESH':
        return 'Les utilisateurs administrateurs doivent se reconnecter manuellement.';

      // Erreurs liées au OTP
      case 'OTP_ERROR':
        return 'Ce numéro doit être vérifié avec un code avant l\'inscription.';
      case 'INVALID_OTP':
        return 'Code de vérification invalide.';
      case 'EXPIRED_OTP':
        return 'Code de vérification expiré, veuillez demander un nouveau code.';

      // Erreurs liées à l'inscription
      case 'DUPLICATE_EMAIL':
        return 'Cet email est déjà utilisé, veuillez en choisir un autre.';
      case 'DUPLICATE_PHONE':
        return 'Ce numéro de téléphone est déjà utilisé.';

      // Erreurs liés au téléversement de fichier
      case 'NO_FILES_PROVIDED':
        return 'Aucun fichier fourni pour le signalement.';
      case 'FILE_SIZE_EXCEEDED':
        return 'La taille du fichier dépasse la limite autorisée (10MB).';
      case 'MAX_FILES_EXCEEDED':
        return 'Le nombre maximum de fichiers par requête est dépassé (5 max).';
      case 'SIGNALEMENT_NOT_FOUND':
        return 'Le signalement demandé n\'existe pas ou n\'est plus accessible.';
      case 'UNAUTHORIZED_ACTION':
        return 'Vous n\'êtes pas autorisé à effectuer cette action sur ce signalement.';
      case 'NO_LINKS_PROVIDED':
        return 'Aucun lien fourni pour le signalement.';
      case 'FORBIDDEN':
        return 'Vous n\'avez pas les permissions nécessaires pour effectuer cette action.';

      // Erreurs de limite de requêtes
      case 'RATE_LIMIT_ERROR':
        return 'Trop de tentatives, veuillez réessayer plus tard.';

      // Erreurs d'envoi de SMS
      case 'SMS_ERROR':
        return 'Impossible d\'envoyer le SMS, veuillez vérifier votre numéro ou réessayer plus tard.';

      // Erreur serveur par défaut
      case 'SERVER_ERROR':
      default:
        return 'Une erreur s\'est produite, veuillez réessayer plus tard.';
    }
  }
}
