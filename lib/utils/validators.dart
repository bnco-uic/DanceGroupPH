import '../models/dance_group.dart';

/// Form validation rules. They match the PHP API rules exactly.
/// Each function returns an error message, or null when the value is valid.
class Validators {
  // runes.length counts characters the same way PHP's mb_strlen does.
  static int _length(String text) => text.runes.length;

  static String? groupName(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Group name is required.';
    if (_length(text) < 2 || _length(text) > 100) {
      return 'Group name must be 2 to 100 characters.';
    }
    return null;
  }

  static String? danceStyle(String? value) {
    if (value == null || !kDanceStyles.contains(value)) {
      return 'Please choose a dance style.';
    }
    return null;
  }

  static String? region(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please choose a region.';
    return null;
  }

  static String? city(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'City is required.';
    if (_length(text) > 80) return 'City must be at most 80 characters.';
    return null;
  }

  /// Optional. [currentYear] can be passed in tests; defaults to this year.
  static String? foundedYear(String? value, {int? currentYear}) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final maxYear = currentYear ?? DateTime.now().year;
    final year = int.tryParse(text);
    if (year == null || year < 1900 || year > maxYear) {
      return 'Founded year must be between 1900 and $maxYear.';
    }
    return null;
  }

  static String? memberCount(String? value) {
    final count = int.tryParse((value ?? '').trim());
    if (count == null || count < 1 || count > 500) {
      return 'Member count must be a whole number from 1 to 500.';
    }
    return null;
  }

  /// For optional text fields like leader name and signature dance.
  static String? optionalMax100(String? value, String label) {
    if (_length((value ?? '').trim()) > 100) {
      return '$label must be at most 100 characters.';
    }
    return null;
  }
}
