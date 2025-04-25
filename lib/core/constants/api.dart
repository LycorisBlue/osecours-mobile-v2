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
  static const String testBaseUrl = 'http://46.202.170.228:3000';

  /**
   * URL de base pour l'environnement de production.
   * Utilisée pour l'application en production avec
   * les données réelles.
   */
  static const String prodBaseUrl = 'https://api.osecours.ci/api/v1';

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
  static const String register = '/citizen/register';
}

/**
 * Endpoints relatifs aux opérations OTP (One Time Password).
 * Gère les chemins d'accès pour la demande et la vérification
 * des codes à usage unique.
 */
abstract class OtpEndpoints {
  static const String request = '/citizen/otp-request';
  static const String verify = '/citizen/verify-otp';
  static const String resend = '/citizen/otp-request';
}

/**
 * Endpoints relatifs aux notifications.
 * Contient les chemins d'accès pour la gestion des
 * notifications utilisateur.
 */
abstract class NotificationEndpoints {
  static const String count = '/notifications/count';
  static const String unread = '/notifications/unread';
  static const String read = '/notifications/mark-read';
  static const String readAll = '/notifications/mark-all-read';
  static const String externalId = '/notifications/external-id';
}

/**
 * Endpoints relatifs aux alertes.
 * Contient les chemins d'accès pour la gestion des
 * alertes créées par les utilisateurs.
 */
abstract class AlertEndpoints {
  static const String create = '/citizen/create-alert';
  static const String latest = '/citizen/latest-alert';
  static const String all = '/citizen/all-alerts';
  static const String details = '/citizen/get-alert-details';
  static const String geocode = '/citizen/reverse-geocode';
}

/**
 * Endpoints relatifs aux numéros de confiance (safe numbers).
 * Contient les chemins d'accès pour la gestion des
 * numéros de contact à alerter en cas d'urgence.
 */
abstract class SafeNumberEndpoints {
  static const String add = '/citizen/safe-numbers';
  static const String delete = '/citizen/safe-numbers';
  static const String get = '/citizen/safe-numbers';
}

/**
 * Endpoints relatifs au profil utilisateur.
 * Contient les chemins d'accès pour la gestion du
 * profil de l'utilisateur.
 */
abstract class ProfileEndpoints {
  static const String addEmail = '/citizen/add-email';
  static const String addPicture = '/citizen/add-picture';
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
    return '${ApiConfig.baseUrl}$endpoint/$id';
  }
}
