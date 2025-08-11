enum ChallengeStatus { inProgress, done, missed }

class Challenge {
  final String title;
  final int participants;
  final int day;
  final ChallengeStatus status;
  final String category;
  final DateTime createdAt;
  final int popularity;

  Challenge({
    required this.title,
    required this.participants,
    required this.day,
    required this.status,
    required this.category,
    required this.createdAt,
    required this.popularity,
  });
}
