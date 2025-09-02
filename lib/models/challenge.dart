// models/challenge.dart
enum ChallengeStatus { inProgress, done, missed, notStarted }

enum TodayCheck {
  waiting, // 인증 대기중
  done, // 완료
  notStarted, // 시작 전
}

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
    // 날짜 파싱은 로컬 타임존 보정(서버가 UTC일 수 있음)
    DateTime? parse(String? s) {
      if (s == null || s.isEmpty) return null;
      try {
        final dt = DateTime.parse(s);
        return dt.isUtc ? dt.toLocal() : dt;
      } catch (_) {
        return null;
      }
    }

    final start = parse(json['challengeStartDate']);
    final end = parse(json['challengeEndDate']);

    // 타입/기간
    final isDuration =
        (json['challengeType']?.toString().toUpperCase() ?? '') == 'DURATION';
    final int durationDays = isDuration ? (json['challengeDuration'] ?? 0) : 0;

    // 진행(서버가 0~100 정수라고 가정)
    final int progressPct = (json['progress'] is num)
        ? (json['progress'] as num).round()
        : 0;
    final int progressDays = (isDuration && durationDays > 0)
        ? ((progressPct.clamp(0, 100) / 100.0) * durationDays).round()
        : 0;

    // 태그 매핑 (백엔드 태그 + 커스텀 태그)
    final backendTags =
        (json['challengeTags'] as List?)
            ?.map((e) => e.toString())
            .map((e) => Challenge.tagKoMap[e.toUpperCase()] ?? e)
            .toList() ??
        const [];
    final customTags =
        (json['customTags'] as List?)?.map((e) => e.toString()).toList() ??
        const [];
    final allTags = [...backendTags, ...customTags];

    // 이미지: 배열 우선 → 단일 폴백
    final List<String> imageUrls =
        (json['imageUrls'] as List?)?.map((e) => e.toString()).toList() ??
        const [];
    final String? imageUrl = imageUrls.isNotEmpty
        ? imageUrls.first
        : (json['imageUrl'] as String?);

    // 참여/좋아요/인증
    final bool participating = json['participating'] == true;
    final bool todayVerified = json['todayVerified'] == true;
    final bool isFavorite = (json['liked'] ?? json['isFavorite']) == true;

    // 상태 계산: 서버/날짜/진행률 종합
    ChallengeStatus status;
    final now = DateTime.now();
    if (progressPct >= 100 || (end != null && now.isAfter(end))) {
      status = ChallengeStatus.done;
    } else if (start != null && now.isBefore(start)) {
      status = ChallengeStatus.notStarted;
    } else if (participating) {
      status = ChallengeStatus.inProgress;
    } else {
      // 날짜가 없으면 보수적으로 notStarted
      status = (start != null || end != null)
          ? ChallengeStatus.inProgress
          : ChallengeStatus.notStarted;
    }

    // 오늘 인증 상태 매핑
    TodayCheck todayCheck;
    final bool inPeriod = (start != null && end != null)
        ? (now.isAfter(start) && now.isBefore(end)) ||
              now.isAtSameMomentAs(start) ||
              now.isAtSameMomentAs(end)
        : true;
    if (!participating || !inPeriod) {
      todayCheck = TodayCheck.notStarted;
    } else {
      todayCheck = todayVerified ? TodayCheck.done : TodayCheck.waiting;
    }

    return Challenge(
      id: json['challengeId'] ?? 0,
      title: json['challengeName'] ?? (json['title'] ?? ''),
      participants: json['participantCount'] ?? 0,
      day: durationDays,
      status: status,
      category: json['challengeScope']?.toString() ?? 'USER',
      createdAt: start ?? DateTime.now(),
      type: isDuration ? 'time' : 'goal',
      tags: allTags,
      imageUrl: imageUrl,
      bannerPeriod: (start != null && end != null)
          ? '${start.toIso8601String()}~${end.toIso8601String()}'
          : null,
      bannerDescription: (json['challengeDescription'] ?? json['description'])
          ?.toString(),
      isFavorite: isFavorite,
      progressDays: progressDays,
      participating: participating,
      WhoMadeIt: (json['challengeScope']?.toString().toUpperCase() == 'BETU')
          ? 'BETU'
          : (json['Whomadeit'] ?? json['WhoMadeIt'] ?? 'USER'),
      todayCheck: todayCheck,
    );
  }
}
