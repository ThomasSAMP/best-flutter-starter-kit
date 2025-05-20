enum Environment { dev, staging, prod }

class EnvConfig {
  final String apiUrl;
  final String appName;
  final bool enableLogging;
  final Environment environment;

  EnvConfig({
    required this.apiUrl,
    required this.appName,
    required this.enableLogging,
    required this.environment,
  });

  static late EnvConfig _instance;

  static void initialize(Environment env) {
    switch (env) {
      case Environment.dev:
        _instance = EnvConfig(
          apiUrl: 'https://dev-api.example.com',
          appName: 'Flutter Template Dev',
          enableLogging: true,
          environment: Environment.dev,
        );
        break;
      case Environment.staging:
        _instance = EnvConfig(
          apiUrl: 'https://staging-api.example.com',
          appName: 'Flutter Template Staging',
          enableLogging: true,
          environment: Environment.staging,
        );
        break;
      case Environment.prod:
        _instance = EnvConfig(
          apiUrl: 'https://api.example.com',
          appName: 'Flutter Template',
          enableLogging: false,
          environment: Environment.prod,
        );
        break;
    }
  }

  static EnvConfig get instance => _instance;

  static bool get isProduction => _instance.environment == Environment.prod;
  static bool get isDevelopment => _instance.environment == Environment.dev;
  static bool get isStaging => _instance.environment == Environment.staging;
}
