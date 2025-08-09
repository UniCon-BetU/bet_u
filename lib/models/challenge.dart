enum ChallengeStatus { inProgress, done, missed }

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
}
