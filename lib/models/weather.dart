import 'package:flutter/material.dart';

/// Current weather for a city, built from two Open-Meteo responses:
/// 1. the geocoding result (place name, province)
/// 2. the forecast "current" block (temperature, wind, ...)
class Weather {
  const Weather({
    required this.placeName,
    this.province,
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.isDay,
    required this.time,
  });

  final String placeName;
  final String? province;
  final double temperature; // °C
  final double apparentTemperature; // "feels like" °C
  final int humidity; // %
  final double windSpeed; // km/h
  final int weatherCode; // WMO weather code
  final bool isDay;
  final String time; // local time, e.g. 2026-09-26T23:30

  factory Weather.fromJson({
    required Map<String, dynamic> place,
    required Map<String, dynamic> forecast,
  }) {
    final current = forecast['current'] as Map<String, dynamic>;
    return Weather(
      placeName: place['name'] as String? ?? '',
      province: place['admin1'] as String?,
      temperature: (current['temperature_2m'] as num).toDouble(),
      apparentTemperature: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).round(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      isDay: current['is_day'] == 1,
      time: current['time'] as String? ?? '',
    );
  }

  /// "HH:mm" part of the time, e.g. "23:30".
  String get updatedAt => time.length >= 16 ? time.substring(11, 16) : time;

  bool get isRainy =>
      (weatherCode >= 51 && weatherCode <= 67) ||
      (weatherCode >= 80 && weatherCode <= 99);

  /// Text for the WMO weather code (see open-meteo.com/en/docs).
  String get description {
    if (weatherCode == 0) return 'Clear sky';
    if (weatherCode <= 2) return 'Partly cloudy';
    if (weatherCode == 3) return 'Overcast';
    if (weatherCode == 45 || weatherCode == 48) return 'Foggy';
    if (weatherCode >= 51 && weatherCode <= 57) return 'Drizzle';
    if (weatherCode >= 61 && weatherCode <= 67) return 'Rain';
    if (weatherCode >= 71 && weatherCode <= 77) return 'Snow';
    if (weatherCode >= 80 && weatherCode <= 82) return 'Rain showers';
    if (weatherCode >= 95) return 'Thunderstorm';
    return 'Unknown';
  }

  IconData get icon {
    if (weatherCode == 0) return isDay ? Icons.wb_sunny : Icons.nightlight_round;
    if (weatherCode <= 3) return isDay ? Icons.wb_cloudy : Icons.cloud;
    if (weatherCode == 45 || weatherCode == 48) return Icons.foggy;
    if (weatherCode >= 95) return Icons.thunderstorm;
    if (isRainy) return Icons.umbrella;
    return Icons.cloud;
  }

  /// A small rehearsal tip based on the weather.
  String get danceTip {
    if (weatherCode >= 95) return 'Thunderstorm: keep rehearsals indoors today.';
    if (isRainy) return 'Wet floors outside: rehearse in the gym or hall.';
    if (apparentTemperature >= 35) return 'Very hot: rehearse early and drink water often.';
    if (!isDay) return 'Evening practice? Make sure the area is well lit.';
    return 'Good weather for an outdoor rehearsal!';
  }
}
