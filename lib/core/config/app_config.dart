enum AppEnvironment { dev, live }

enum AppType { technician }

/// Technician app config.
class AppConfig {
  final AppEnvironment environment;
  final String appName;
  final String baseUrl;

  AppConfig({
    required this.environment,
    required this.appName,
    required this.baseUrl,
  });

  static late AppConfig instance;
}
