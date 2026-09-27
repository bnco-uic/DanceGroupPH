/// The six dance styles allowed by the app and the PHP API.
const List<String> kDanceStyles = [
  'Folk',
  'Festival',
  'Street',
  'Contemporary',
  'Cultural',
  'Ballroom',
];

/// Philippine regions for the region dropdown.
const List<String> kRegions = [
  'NCR',
  'CAR',
  'Ilocos Region',
  'Cagayan Valley',
  'Central Luzon',
  'CALABARZON',
  'MIMAROPA',
  'Bicol Region',
  'Western Visayas',
  'Negros Island Region',
  'Central Visayas',
  'Eastern Visayas',
  'Zamboanga Peninsula',
  'Northern Mindanao',
  'Davao Region',
  'SOCCSKSARGEN',
  'Caraga',
  'BARMM',
];

/// One row of the dance_groups table.
class DanceGroup {
  const DanceGroup({
    this.id,
    required this.groupName,
    required this.danceStyle,
    required this.region,
    required this.city,
    this.foundedYear,
    required this.memberCount,
    this.leaderName,
    this.signatureDance,
    this.description,
    this.isActive = true,
    this.createdAt,
  });

  final int? id; // null for a new group that is not saved yet
  final String groupName;
  final String danceStyle;
  final String region;
  final String city;
  final int? foundedYear;
  final int memberCount;
  final String? leaderName;
  final String? signatureDance;
  final String? description;
  final bool isActive;
  final String? createdAt;

  /// Builds a DanceGroup from the API's JSON (snake_case keys).
  factory DanceGroup.fromJson(Map<String, dynamic> json) {
    return DanceGroup(
      id: _toInt(json['id']),
      groupName: json['group_name'] as String? ?? '',
      danceStyle: json['dance_style'] as String? ?? '',
      region: json['region'] as String? ?? '',
      city: json['city'] as String? ?? '',
      foundedYear: _toInt(json['founded_year']),
      memberCount: _toInt(json['member_count']) ?? 0,
      leaderName: json['leader_name'] as String?,
      signatureDance: json['signature_dance'] as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] == true ||
          json['is_active'] == 1 ||
          json['is_active'] == '1',
      createdAt: json['created_at'] as String?,
    );
  }

  /// The JSON body sent to the API for create and update.
  Map<String, dynamic> toJson() {
    return {
      'group_name': groupName,
      'dance_style': danceStyle,
      'region': region,
      'city': city,
      'founded_year': foundedYear,
      'member_count': memberCount,
      'leader_name': leaderName,
      'signature_dance': signatureDance,
      'description': description,
      'is_active': isActive,
    };
  }

  /// Up to two letters for the avatar, e.g. "Metro Groove Collective" -> "MG".
  String get initials {
    final words = groupName.trim().split(RegExp(r'\s+'));
    final letters = words
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0].toUpperCase())
        .join();
    return letters.isEmpty ? '?' : letters;
  }

  /// Accepts 5 or "5" (some servers send numbers as text).
  static int? _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('${value ?? ''}');
  }
}
