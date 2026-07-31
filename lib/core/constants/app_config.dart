/// App-wide configuration.
class AppConfig {
  AppConfig._();

  static const String appName = 'Rimi';
  static const String appTagline = 'Baby Shop & Rewards';

  /// Production API (no trailing slash).
  static const String apiBaseUrl = 'https://rimi-api.miromi.id';

  /// API prefix.
  static const String apiPrefix = '/api/v1';

  static String get apiUrl => '$apiBaseUrl$apiPrefix';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  static const String accessTokenKey = 'rimi_access_token';
  static const String refreshTokenKey = 'rimi_refresh_token';
  static const String userJsonKey = 'rimi_user_json';
  static const String onboardingDoneKey = 'rimi_onboarding_done';
}
