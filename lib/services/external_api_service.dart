import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/weather.dart';
import 'api_service.dart';

/// Third-party API: Open-Meteo (https://open-meteo.com), no key needed.
///
/// Step 1: Geocoding API turns a city name into latitude/longitude.
/// Step 2: Forecast API gives the current weather at that location.
class ExternalApiService {
  /// Returns null when the city cannot be found (the "no data" case).
  Future<Weather?> getWeatherForCity(String city) async {
    final place = await _findPlace(city);
    if (place == null) return null;

    final forecastUrl = Uri.parse(AppConfig.forecastUrl).replace(
      queryParameters: {
        'latitude': '${place['latitude']}',
        'longitude': '${place['longitude']}',
        'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,'
            'weather_code,wind_speed_10m,is_day',
        'timezone': 'auto',
      },
    );
    final forecast = await _getJson(forecastUrl);
    if (forecast['current'] is! Map) return null;

    return Weather.fromJson(place: place, forecast: forecast);
  }

  /// Looks up the city in the Philippines. Returns the first match or null.
  Future<Map<String, dynamic>?> _findPlace(String city) async {
    final url = Uri.parse(AppConfig.geocodingUrl).replace(
      queryParameters: {
        'name': city,
        'count': '1',
        'language': 'en',
        'format': 'json',
        'countryCode': 'PH',
      },
    );
    final json = await _getJson(url);

    // When nothing matches, Open-Meteo leaves out the "results" key.
    final results = json['results'];
    if (results is! List || results.isEmpty) return null;
    return results.first as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _getJson(Uri url) async {
    final http.Response response;
    try {
      response = await http.get(url).timeout(AppConfig.requestTimeout);
    } on TimeoutException {
      throw ApiException('The weather service took too long. Please retry.');
    } on Exception {
      throw ApiException('Cannot reach the weather service. Check your internet.');
    }

    if (response.statusCode != 200) {
      throw ApiException('Weather service error (HTTP ${response.statusCode}).');
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      // handled below
    }
    throw ApiException('The weather service sent data we could not read.');
  }
}
