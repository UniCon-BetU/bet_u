// models/challenge.dart
enum ChallengeStatus { inProgress, done, missed, notStarted }

enum TodayCheck { waiting, done, notStarted }

class Challenge {
  final String title;
  int participants;
  final int day; // 총 일수
  ChallengeStatus status;
  final String category; // (GLOBAL/CREW 등)
  final DateTime createdAt; // 시작일
  final String? type; // "DURATION"/"GOAL" 등
  final List<String> tags;
  final String? imageUrl;
  final String? bannerPeriod;
  final String? bannerDescription;
  final String? WhoMadeIt;
  TodayCheck todayCheck;

  bool isFavorite;
  bool participating; // ✅ 내가 참여 중인지 (서버 participating 매핑)

  int progressDays;

  Challenge({
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
    this.participating = false, // ✅ 기본 false
  }) : tags = tags ?? [];

  double get progressPercent => day > 0 ? progressDays / day : 0;

  factory Challenge.fromJson(Map<String, dynamic> json) {
    final start = DateTime.tryParse(json['challengeStartDate'] ?? '');
    final end = DateTime.tryParse(json['challengeEndDate'] ?? '');

    final progress = json['progress'] as int?;

    return Challenge(
      title: json['challengeName'] ?? '',
      participants: json['participantCount'] ?? 0,
      day: (start != null && end != null) ? end.difference(start).inDays : 0,
      status: (start != null && end != null)
          ? mapStatus(progress, start, end)
          : ChallengeStatus.notStarted,
      category: (json['challengeScope'] ?? 'GLOBAL').toString(),
      createdAt: start ?? DateTime.now(),
      type: json['challengeType'],
      tags:
          (json['challengeTags'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      imageUrl: null,
      bannerPeriod: null,
      bannerDescription: json['challengeDescription'],
      isFavorite: false,
      progressDays: (progress != null && start != null && end != null)
          ? ((progress.clamp(0, 100) / 100.0) * (end.difference(start).inDays))
                .round()
          : 0,
      participating: json['participating'] ?? false, // ✅ 서버 participating 반영
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "challengeName": title,
      "participantCount": participants,
      "challengeStartDate": createdAt.toIso8601String(),
      "challengeEndDate": createdAt.add(Duration(days: day)).toIso8601String(),
      "challengeType": type,
      "challengeTags": tags,
      "challengeDescription": bannerDescription,
      "challengeScope": category,
      "participating": participating, // 로컬 유지용
    };
  }

  static ChallengeStatus mapStatus(
    int? progress,
    DateTime start,
    DateTime end,
  ) {
    final now = DateTime.now();
    if (now.isBefore(start)) return ChallengeStatus.notStarted;
    if (now.isAfter(end) && (progress == null || progress == 0)) {
      return ChallengeStatus.missed;
    }
    if (progress != null && progress < 100) return ChallengeStatus.inProgress;
    if (progress != null && progress >= 100) return ChallengeStatus.done;
    return ChallengeStatus.notStarted;
  }
}
