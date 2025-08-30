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
  final String? type; // "time"/"goal" 등
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

  double get progressPercent => day > 0 ? progressDays / day : 0;
  factory Challenge.fromJson(Map<String, dynamic> json) {
    final start = DateTime.tryParse(json['challengeStartDate'] ?? '');
    final end = DateTime.tryParse(json['challengeEndDate'] ?? '');
    final progress = json['progress'] as int?;

    // type 결정
    final type = json['challengeType'] == 'DURATION' ? 'time' : 'goal';

    final day = type == 'time'
        ? (json['challengeDuration'] ?? 0) // DURATION이면 백엔드 값 그대로
        : 0; // TARGET 타입은 필요하면 다른 계산

    // progressDays 계산
    final progressDays =
        (progress != null && start != null && end != null && day > 0)
        ? ((progress.clamp(0, 100) / 100.0) * day).round()
        : 0;

    // ✅ 백엔드 대표 태그 (영어 → 한국어 매핑)
    final backendTags =
        (json['challengeTags'] as List?)
            ?.map((e) => e.toString())
            .map((e) => tagKoMap[e.toUpperCase()] ?? e) // 한글 매핑
            .toList() ??
        [];

    // ✅ 커스텀 태그
    final customTags =
        (json['customTags'] as List?)?.map((e) => e.toString()).toList() ?? [];

    // ✅ 최종 태그 합치기
    final allTags = [...backendTags, ...customTags];

    return Challenge(
      title: json['challengeName'] ?? '',
      participants: json['participantCount'] ?? 0,
      day: day,
      status: (start != null && end != null)
          ? ChallengeStatus
                .inProgress // mapStatus(progress, start, end) // ✅ 진행 중으로 기본 설정
          : ChallengeStatus.notStarted,
      category:
          (json['challengeScope'] ==
              'BETU') //사용? : category: mapWhomadeit(json['challengeScope'], json['whomadeit']),
          ? 'BETU' // 화면에서 보여줄 whomadeit 값
          : json['whomadeit'] ?? 'USER', // 그 외에는 서버가 보내는 값 사용
      createdAt: start ?? DateTime.now(),
      type: type,
      tags: allTags, // ✅ 한국어 매핑 + 커스텀 태그 반영
      imageUrl: json['imageUrl'],
      bannerPeriod: (start != null && end != null)
          ? "${start.toIso8601String()}~${end.toIso8601String()}"
          : null,
      bannerDescription: json['challengeDescription'],
      isFavorite: json['isFavorite'] ?? false,
      progressDays: progressDays,
      participating: json['participating'] ?? false, // ✅ 서버 participating 반영
    );
  }
}
