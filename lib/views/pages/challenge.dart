enum ChallengeStatus { inProgress, done, missed }

class Challenge {
  final String title;
  int participants;
  final int day;
  final ChallengeStatus status;
  final String category; // 큰 분류 (예: 운동, 공부, 생활습관)
  final DateTime createdAt;
  final int popularity;
  final String? type; // goal, time 등
  final List<String> tags; // 태그 (여러 개 가능)
  final String? imageUrl; // 이미지 URL
  final bool? madebybetu;

  Challenge({
    required this.title,
    required this.participants,
    required this.day,
    required this.status,
    required this.category,
    required this.createdAt,
    required this.popularity,
    this.type,
    List<String>? tags,
    this.imageUrl,
    this.madebybetu,
  }) : tags = tags ?? []; // null이면 빈 리스트로 초기화
}

/// 목표형 챌린지인지 판별
bool isGoalChallenge(Challenge challenge) {
  return challenge.type == 'goal';
}

/// 카테고리로 필터링
List<Challenge> filterByCategory(List<Challenge> challenges, String category) {
  return challenges.where((c) => c.category == category).toList();
}

/// 태그로 검색 (#유산소, 유산소 둘 다 가능)
List<Challenge> searchByTag(List<Challenge> challenges, String keyword) {
  keyword = keyword.replaceFirst('#', '');
  return challenges
      .where((c) => c.tags.any((tag) => tag.contains(keyword)))
      .toList();
}
