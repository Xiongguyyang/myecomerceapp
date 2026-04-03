enum Environment { dev, prod }

class AppConfig {
  final String appName;
  final Environment environment;
  final bool showDebugBanner;
  final String firebaseProjectId;

  const AppConfig({
    required this.appName,
    required this.environment,
    required this.showDebugBanner,
    required this.firebaseProjectId,
  });

  bool get isDev => environment == Environment.dev;
  bool get isProd => environment == Environment.prod;

  static const dev = AppConfig(
    appName: 'Flexy (Dev)',
    environment: Environment.dev,
    showDebugBanner: false,
    firebaseProjectId: 'myecomerceapp-27315',
  );

  static const prod = AppConfig(
    appName: 'Flexy',
    environment: Environment.prod,
    showDebugBanner: false,
    firebaseProjectId: 'myecomerceapp-27315',
  );
}
