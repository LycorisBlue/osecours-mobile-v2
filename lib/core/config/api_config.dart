class ApiConfig {
  // Configuration pour l'API DeepSeek
  static const String deepseekApiKey = String.fromEnvironment(
    'DEEPSEEK_API_KEY',
    defaultValue: 'sk-10983d74a0524ff1bca3c71a52e029de',
  );

  static const String deepseekBaseUrl = 'https://api.deepseek.com/v1/chat/completions';
  static const String deepseekModel = 'deepseek-chat';

  // Paramètres par défaut
  static const int maxTokens = 1000;
  static const double temperature = 0.7;
}
