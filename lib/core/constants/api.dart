/**
 * Configuration des URLs de l'API pour différents environnements.
 * Ce fichier contient toutes les constantes liées aux endpoints de l'API
 * ainsi que les configurations des URLs pour chaque environnement.
 */
class ApiConfig {
  /** 
   * URL de base pour l'environnement de développement local.
   * Utilisée principalement pendant la phase de développement
   * pour tester les fonctionnalités en local.
   */
  static const String devBaseUrl = 'http://localhost:3000';

  /**
   * URL de base pour l'environnement de test.
   * Utilisée pour les tests d'intégration et la validation
   * avant le déploiement en production.
   */
  static const String testBaseUrl = 'https://artci.api-medev.com';

  /**
   * URL de base pour l'environnement de production.
   * Utilisée pour l'application en production avec
   * les données réelles.
   */
  static const String prodBaseUrl = 'https://api.railtrack.ci/api/v1';

  /**
   * Détermine l'URL de base à utiliser en fonction de l'environnement.
   * Retourne l'URL appropriée selon la configuration actuelle.
   */
  static String get baseUrl {
    const environment = "test";

    switch (environment) {
      case 'prod':
        return prodBaseUrl;
      case 'test':
        return testBaseUrl;
      default:
        return devBaseUrl;
    }
  }
}

/**
 * Endpoints relatifs à l'authentification.
 * Contient tous les chemins d'accès pour les opérations
 * liées à l'authentification des utilisateurs.
 */
abstract class AuthEndpoints {
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String userDetails = '/auth/me';
}

/**
 * Endpoints relatifs aux opérations OTP (One Time Password).
 * Gère les chemins d'accès pour la demande et la vérification
 * des codes à usage unique.
 */
abstract class OtpEndpoints {
  static const String request = '/otp/request';
  static const String verify = '/otp/verify';
}

/**
 * Endpoints relatifs aux opérations citoyens.
 * Contient les chemins d'accès pour la gestion des
 * comptes citoyens.
 */
abstract class CitoyenEndpoints {
  static const String register = '/citoyen/register';
}

/**
 * Endpoints relatifs aux notifications.
 * Contient les chemins d'accès pour la gestion des
 * notifications utilisateur.
 */
abstract class NotificationEndpoints {
  static const String count = '/notification/count';
  static const String list = '/notification/list';
  static const String read = '/notification/read';
  static const String readAll = '/notification/read-all';
}

/**
 * Endpoints relatifs aux signalements.
 * Contient les chemins d'accès pour la gestion des
 * signalements créés par les citoyens.
 */
abstract class SignalementEndpoints {
  static const String create = '/signalement/create';
  static const String userList = '/signalement/user-list';
  static const String details = '/signalement/detail';
  static const String uploadProofFile = '/signalement/upload-proof/file';
  static const String uploadProofLink = '/signalement/upload-proof/link';
}

/**
 * Classe utilitaire pour la construction des URLs.
 * Fournit des méthodes helper pour générer les URLs
 * complètes à partir des endpoints.
 */
class ApiHelper {
  /**
   * Construit l'URL complète en combinant l'URL de base
   * avec l'endpoint spécifié.
   */
  static String buildUrl(String endpoint) {
    return '${ApiConfig.baseUrl}$endpoint';
  }

  /**
   * Construit l'URL complète en combinant l'URL de base,
   * l'endpoint et un identifiant spécifique.
   */
  static String buildUrlWithId(String endpoint, String id) {
    return '${ApiConfig.baseUrl}$endpoint$id';
  }
}
