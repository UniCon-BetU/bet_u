// models/challenge.dart
enum ChallengeStatus { inProgress, done, missed, notStarted }

enum TodayCheck { waiting, done, notStarted }

class Challenge {
  final int id;
  final String title;
  int participants;
  final int day;
  ChallengeStatus status;
  final String category;
  final DateTime createdAt;
  final String? type;
  final List<String> tags;
  final String? imageUrl;
  final String? bannerPeriod;
  final String? bannerDescription;
  final String? WhoMadeIt;
  TodayCheck todayCheck;

  bool isFavorite;
  bool participating;
  int progressDays;

  Challenge({
    required this.id,
    required this.title,
    required this.participants,
    required this.day,
    required this.status,
    required this.category,
    required this.createdAt,
    this.type,
    List<String>? tags,
    this.imageUrl,
    this.bannerPeriod,
    this.bannerDescription,
    this.isFavorite = false,
    this.progressDays = 0,
    this.WhoMadeIt,
    this.todayCheck = TodayCheck.notStarted,
    this.participating = false,
  }) : tags = tags ?? [];

  double get progressPercent => day > 0 ? progressDays / day : 0;

  static const Map<String, String> tagKoMap = {
    'EXAM': '수능',
    'UNIVERSITY': '대학',
    'TOEIC': '토익',
    'CERTIFICATE': '자격증',
    'CIVIL_SERVICE': '공무원/행시',
    'LEET': 'LEET',
    'CPA': '회계사',
    'SELF_DEVELOPMENT': '생활/자기계발',
  };

  factory Challenge.fromJson(Map<String, dynamic> json) {
    final start = DateTime.tryParse(json['challengeStartDate'] ?? '');
    final end = DateTime.tryParse(json['challengeEndDate'] ?? '');
    final progress = json['progress'] as int?;
    final type = json['challengeType'] == 'DURATION' ? 'time' : 'goal';
    final day = type == 'time' ? (json['challengeDuration'] ?? 0) : 0;
    final progressDays =
        (progress != null && start != null && end != null && day > 0)
        ? ((progress.clamp(0, 100) / 100.0) * day).round()
        : 0;

    final backendTags =
        (json['challengeTags'] as List?)
            ?.map((e) => e.toString())
            .map((e) => Challenge.tagKoMap[e.toUpperCase()] ?? e)
            .toList() ??
        [];

    final customTags =
        (json['customTags'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final allTags = [...backendTags, ...customTags];

    return Challenge(
      id: json['challengeId'] ?? 0,
      title: json['challengeName'] ?? '',
      participants: json['participantCount'] ?? 0,
      day: day,
      status: (start != null && end != null)
          ? ChallengeStatus.inProgress
          : ChallengeStatus.notStarted,
      category: json['challengeScope'] ?? 'USER',
      WhoMadeIt: (json['challengeScope'] == 'BETU')
          ? 'BETU'
          : (json['whomadeit'] ?? 'USER'),
      createdAt: start ?? DateTime.now(),
      type: type,
      tags: allTags,
      imageUrl: json['imageUrl'],
      bannerPeriod: (start != null && end != null)
          ? "${start.toIso8601String()}~${end.toIso8601String()}"
          : null,
      bannerDescription: json['challengeDescription'],
      isFavorite: json['isFavorite'] ?? false,
      progressDays: progressDays,
      participating: json['participating'] ?? false,
    );
  }
}
