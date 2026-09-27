import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sayaw_pilipinas/models/dance_group.dart';
import 'package:sayaw_pilipinas/models/weather.dart';
import 'package:sayaw_pilipinas/utils/validators.dart';
import 'package:sayaw_pilipinas/widgets/empty_state.dart';
import 'package:sayaw_pilipinas/widgets/error_state.dart';

void main() {
  group('DanceGroup model', () {
    test('parses the JSON sent by the PHP API', () {
      final group = DanceGroup.fromJson({
        'id': 3,
        'group_name': 'Singkil Heritage Ensemble',
        'dance_style': 'Cultural',
        'region': 'BARMM',
        'city': 'Marawi City',
        'founded_year': null,
        'member_count': '25', // numbers as text are accepted too
        'leader_name': null,
        'signature_dance': 'Singkil',
        'description': null,
        'is_active': false,
        'created_at': '2026-01-20 09:00:00',
      });

      expect(group.id, 3);
      expect(group.foundedYear, isNull);
      expect(group.memberCount, 25);
      expect(group.isActive, isFalse);
      expect(group.initials, 'SH');
    });

    test('toJson uses the API field names', () {
      const group = DanceGroup(
        groupName: 'Test Troupe',
        danceStyle: 'Folk',
        region: 'NCR',
        city: 'Manila',
        memberCount: 10,
      );

      final json = group.toJson();
      expect(json['group_name'], 'Test Troupe');
      expect(json['member_count'], 10);
      expect(json['is_active'], isTrue);
      expect(json.containsKey('id'), isFalse);
    });
  });

  group('Weather model', () {
    test('parses real Open-Meteo responses', () {
      final weather = Weather.fromJson(
        place: {'name': 'Davao City', 'admin1': 'Davao Region'},
        forecast: {
          'current': {
            'time': '2026-09-26T23:30',
            'temperature_2m': 25.9,
            'relative_humidity_2m': 92,
            'apparent_temperature': 31.4,
            'weather_code': 1,
            'wind_speed_10m': 6.3,
            'is_day': 0,
          },
        },
      );

      expect(weather.temperature, 25.9);
      expect(weather.humidity, 92);
      expect(weather.isDay, isFalse);
      expect(weather.description, 'Partly cloudy');
      expect(weather.updatedAt, '23:30');
    });
  });

  group('Validators (same rules as PHP)', () {
    test('group name must be 2 to 100 characters', () {
      expect(Validators.groupName(''), isNotNull);
      expect(Validators.groupName('A'), isNotNull);
      expect(Validators.groupName('AB'), isNull);
      expect(Validators.groupName('x' * 101), isNotNull);
    });

    test('dance style must be one of the six styles', () {
      expect(Validators.danceStyle('Folk'), isNull);
      expect(Validators.danceStyle('Tango'), isNotNull);
      expect(Validators.danceStyle(null), isNotNull);
    });

    test('founded year is optional but must be 1900 to this year', () {
      expect(Validators.foundedYear('', currentYear: 2026), isNull);
      expect(Validators.foundedYear('1899', currentYear: 2026), isNotNull);
      expect(Validators.foundedYear('2026', currentYear: 2026), isNull);
      expect(Validators.foundedYear('2027', currentYear: 2026), isNotNull);
    });

    test('member count must be a whole number from 1 to 500', () {
      expect(Validators.memberCount(''), isNotNull);
      expect(Validators.memberCount('0'), isNotNull);
      expect(Validators.memberCount('1'), isNull);
      expect(Validators.memberCount('500'), isNull);
      expect(Validators.memberCount('501'), isNotNull);
    });
  });

  testWidgets('ErrorState shows the message and Retry works', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorState(
            message: 'Cannot reach the server.',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('Cannot reach the server.'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('EmptyState shows the friendly message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(title: 'No dance groups yet, add the first one!'),
        ),
      ),
    );

    expect(find.text('No dance groups yet, add the first one!'), findsOneWidget);
  });
}
