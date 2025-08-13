enum ChallengeStatus { inProgress, done, missed }

class Challenge {
  final String title;
  int participants;
  final int day;
  final ChallengeStatus status;
  final String category;
  final DateTime createdAt;
  final int popularity;
  final String? type;
  final List<String> tags; // null이 아닌 빈 리스트로 기본값
  final String? imageUrl; // 이미지 URL

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
  }) : tags = tags ?? []; // tags가 null이면 빈 리스트로 초기화
}

bool isGoalChallenge(Challenge challenge) {
  return challenge.type == 'goal';
}
