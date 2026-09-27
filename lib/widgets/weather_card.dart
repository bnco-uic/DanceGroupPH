import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../services/api_service.dart';
import '../services/external_api_service.dart';

/// Shows live weather for [city] from Open-Meteo (the third-party API).
/// Handles its own loading, error (with Retry), and "no data" states.
class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key, required this.city});

  final String city;

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  final _service = ExternalApiService();

  bool _loading = true;
  String? _error;
  Weather? _weather; // stays null when the city was not found

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  // Reload when the card is reused for a different city (after an edit).
  @override
  void didUpdateWidget(WeatherCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.city != widget.city) _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final weather = await _service.getWeatherForCity(widget.city);
      if (!mounted) return;
      setState(() {
        _weather = weather;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isNight = _weather != null && !_weather!.isDay;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isNight
              ? const [Color(0xFF1A237E), Color(0xFF4A148C)]
              : const [Color(0xFF0038A8), Color(0xFF0277BD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_outlined, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Weather in ${widget.city}',
                  style: textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
              ),
              IconButton(
                tooltip: 'Refresh weather',
                onPressed: _loading ? null : _loadWeather,
                icon: const Icon(Icons.refresh),
                color: Colors.white,
                disabledColor: Colors.white54,
              ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildBody(textTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(TextTheme textTheme) {
    const white = TextStyle(color: Colors.white);

    if (_loading) {
      return Row(
        key: const ValueKey('loading'),
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text('Checking the sky over ${widget.city}...', style: white),
        ],
      );
    }

    if (_error != null) {
      return Column(
        key: const ValueKey('error'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_error!, style: white),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _loadWeather,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white70),
            ),
          ),
        ],
      );
    }

    final weather = _weather;
    if (weather == null) {
      return Text(
        'No weather data found for "${widget.city}".',
        key: const ValueKey('empty'),
        style: white,
      );
    }

    return Column(
      key: const ValueKey('content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(weather.icon, color: Colors.white, size: 52),
            const SizedBox(width: 12),
            Text(
              '${weather.temperature.round()}°C',
              style: textTheme.displaySmall?.copyWith(color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.description,
                    style: textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  Text(
                    [weather.placeName, weather.province]
                        .whereType<String>()
                        .join(', '),
                    style: const TextStyle(color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _WeatherPill(
              icon: Icons.thermostat,
              text: 'Feels ${weather.apparentTemperature.round()}°C',
            ),
            _WeatherPill(
              icon: Icons.water_drop_outlined,
              text: '${weather.humidity}% humidity',
            ),
            _WeatherPill(
              icon: Icons.air,
              text: '${weather.windSpeed.round()} km/h wind',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.tips_and_updates_outlined,
                color: Color(0xFFFCD116), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                weather.danceTip,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Weather data by Open-Meteo.com • local time ${weather.updatedAt}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

class _WeatherPill extends StatelessWidget {
  const _WeatherPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
