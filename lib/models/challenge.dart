enum ChallengeStatus {
  inProgress, // 진행 중
  done, // 완료
  missed, // 놓친 챌린지
  notStarted, // 시작 전
}

class Challenge {
  final String title;
  int participants;
  final int day; // 총 챌린지 일수
  final ChallengeStatus status;
  final String category;
  final DateTime createdAt;
  final String? type;
  final List<String> tags;
  final String? imageUrl;
  final String? bannerPeriod;
  final String? bannerDescription;
  bool isFavorite;

  int progressDays; // ✅ 여기 추가 (사용자가 인증한 일수)

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
    this.progressDays = 0, // 기본 0일
  }) : tags = tags ?? [];

  double get progressPercent => day > 0 ? progressDays / day : 0;

  /// JSON → Challenge 변환
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
          (json['challengeTags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      imageUrl: null,
      bannerPeriod: null,
      bannerDescription: json['challengeDescription'],
    );
  }

  /// Challenge → JSON 변환
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
    };
  }

  /// 상태 매핑 (진짜 날짜 기준)
  static ChallengeStatus mapStatus(
    int? progress,
    DateTime start,
    DateTime end,
  ) {
    final now = DateTime.now();

    if (now.isBefore(start)) return ChallengeStatus.notStarted; // 시작 전
    if (now.isAfter(end) && (progress == null || progress == 0)) {
      return ChallengeStatus.missed; // 놓친 챌린지
    }
    if (progress != null && progress < 100) return ChallengeStatus.inProgress;
    if (progress != null && progress >= 100) return ChallengeStatus.done;

    return ChallengeStatus.notStarted; // 안전망
  }
}
