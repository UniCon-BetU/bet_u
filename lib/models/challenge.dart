enum ChallengeStatus { inProgress, missed, done }

class Challenge {
  final String title;
  final int participants;
  final int day;
  final ChallengeStatus status;

  const Challenge({
    required this.title,
    required this.participants,
    required this.day,
    required this.status,
  });

  get tags => null;

  get createdAt => null;
}
