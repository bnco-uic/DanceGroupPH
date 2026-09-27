/// The ONLY place where URLs and network settings live.
///
/// Change the backend URL without editing code:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.5/api
///
/// Default 10.0.2.2 = "my PC" as seen from the Android emulator.
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2/api',
  );

  /// When true, PUT and DELETE are sent as POST + "_method".
  /// Turn on only if your hosting blocks PUT/DELETE:
  ///   --dart-define=USE_METHOD_OVERRIDE=true
  static const bool useMethodOverride = bool.fromEnvironment(
    'USE_METHOD_OVERRIDE',
  );

  static const String groupsUrl = '$apiBaseUrl/dance_groups.php';

  // Third-party API: Open-Meteo (free, no API key needed).
  static const String geocodingUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String forecastUrl = 'https://api.open-meteo.com/v1/forecast';

  /// City shown in the weather card on the dashboard.
  static const String dashboardCity = 'Davao City';

  /// Every HTTP request gives up after 15 seconds.
  static const Duration requestTimeout = Duration(seconds: 15);
}
