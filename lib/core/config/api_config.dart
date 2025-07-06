// lib/core/config/api_config.dart
class ApiConfig {
  // Configuration pour l'API DeepSeek (conservée en backup)
  static const String deepseekApiKey = String.fromEnvironment(
    'DEEPSEEK_API_KEY',
    defaultValue: 'sk-10983d74a0524ff1bca3c71a52e029de',
  );

  static const String deepseekBaseUrl = 'https://api.deepseek.com/v1/chat/completions';
  static const String deepseekModel = 'deepseek-chat';

  // 🆕 Configuration pour l'API Gemini
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyCiLYnOBa48N6HGkIOwdn_gqZu4vbHNgX8', // À REMPLACER par votre vraie clé
  );

  static const String geminiModel = 'gemini-2.0-flash-exp';

  // Paramètres par défaut (partagés)
  static const int maxTokens = 1000;
  static const double temperature = 0.7;
}
