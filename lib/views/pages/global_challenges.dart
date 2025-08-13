import 'challenge.dart';

int userPoints = 50000; // 더미 포인트

final List<Challenge> allChallenges = [
  Challenge(
    title: '수능 국어 1일 3지문',
    participants: 1723,
    day: 12,
    status: ChallengeStatus.inProgress,
    category: '공부',
    createdAt: DateTime(2025, 7, 1),
    popularity: 120,
  ),
  Challenge(
    title: '영어 단어 30개 암기',
    participants: 2105,
    day: 30,
    status: ChallengeStatus.inProgress,
    category: '공부',
    createdAt: DateTime(2025, 6, 15),
    popularity: 230,
  ),
  Challenge(
    title: '수학 문제집 하루 20문제',
    participants: 1980,
    day: 20,
    status: ChallengeStatus.done,
    category: '공부',
    createdAt: DateTime(2025, 6, 20),
    popularity: 180,
  ),
  Challenge(
    title: '조깅 30분 걷기',
    participants: 1120,
    day: 10,
    status: ChallengeStatus.inProgress,
    category: '운동',
    createdAt: DateTime(2025, 5, 30),
    popularity: 80,
  ),
  Challenge(
    title: '물 2리터 마시기',
    participants: 1320,
    day: 25,
    status: ChallengeStatus.missed,
    category: '생활습관',
    createdAt: DateTime(2025, 7, 3),
    popularity: 90,
  ),
];
