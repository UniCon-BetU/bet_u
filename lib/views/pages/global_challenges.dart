import 'challenge.dart';

int userPoints = 50000; // 더미 포인트

final List<Challenge> allChallenges = [
  // 전체 공부 관련
  Challenge(
    title: '수능 국어 1일 3지문',
    participants: 1723,
    day: 12,
    status: ChallengeStatus.inProgress,
    category: '수능',
    createdAt: DateTime(2025, 7, 1),
    popularity: 120,
  ),
  Challenge(
    title: '영어 단어 30개 암기',
    participants: 2105,
    day: 30,
    status: ChallengeStatus.inProgress,
    category: '수능',
    createdAt: DateTime(2025, 6, 15),
    popularity: 230,
  ),
  Challenge(
    title: '토익 단어 50개 외우기',
    participants: 890,
    day: 20,
    status: ChallengeStatus.inProgress,
    category: '토익',
    createdAt: DateTime(2025, 5, 25),
    popularity: 150,
  ),
  Challenge(
    title: '공무원 한국사 매일 1강 듣기',
    participants: 560,
    day: 15,
    status: ChallengeStatus.inProgress,
    category: '공무원/행시',
    createdAt: DateTime(2025, 6, 1),
    popularity: 70,
  ),
  Challenge(
    title: '회계사 시험 기출문제 10문제 풀이',
    participants: 320,
    day: 10,
    status: ChallengeStatus.done,
    category: '회계사',
    createdAt: DateTime(2025, 6, 10),
    popularity: 50,
  ),
  Challenge(
    title: 'LEET 코딩 문제 1문제 풀기',
    participants: 450,
    day: 7,
    status: ChallengeStatus.inProgress,
    category: 'LEET',
    createdAt: DateTime(2025, 5, 28),
    popularity: 60,
  ),
  Challenge(
    title: '자격증 기초문제 하루 20문제',
    participants: 780,
    day: 25,
    status: ChallengeStatus.inProgress,
    category: '자격증',
    createdAt: DateTime(2025, 6, 5),
    popularity: 90,
  ),
  // 생활습관 관련
  Challenge(
    title: '물 2리터 마시기',
    participants: 1320,
    day: 25,
    status: ChallengeStatus.missed,
    category: '생활습관',
    createdAt: DateTime(2025, 7, 3),
    popularity: 90,
  ),
  Challenge(
    title: '조깅 30분 걷기',
    participants: 1120,
    day: 10,
    status: ChallengeStatus.inProgress,
    category: '생활습관',
    createdAt: DateTime(2025, 5, 30),
    popularity: 80,
  ),
  // 자기계발 관련
  Challenge(
    title: '매일 아침 10분 명상',
    participants: 640,
    day: 20,
    status: ChallengeStatus.inProgress,
    category: '자기계발',
    createdAt: DateTime(2025, 6, 12),
    popularity: 100,
  ),
  Challenge(
    title: '하루 1페이지 책 읽기',
    participants: 980,
    day: 30,
    status: ChallengeStatus.done,
    category: '자기계발',
    createdAt: DateTime(2025, 5, 20),
    popularity: 130,
  ),
];

class PresentedChallenge {
  final String title;
  final String imageUrl;
  final int participants;
  final int daysLeft;
  final bool isParticipated;

  PresentedChallenge({
    required this.title,
    required this.imageUrl,
    required this.participants,
    required this.daysLeft,
    required this.isParticipated,
  });
}

List<PresentedChallenge> globalPresentedChallenges = [
  PresentedChallenge(
    title: '매일 아침 7시 기상 | 수능을 위한 미라클 모닝',
    imageUrl: 'https://picsum.photos/200/100', // 임시 이미지
    participants: 2686,
    daysLeft: 30,
    isParticipated: false,
  ),
  PresentedChallenge(
    title: '가을 학기 대학 학점 4.0 도전!',
    imageUrl: 'https://picsum.photos/200/101',
    participants: 924,
    daysLeft: 30,
    isParticipated: true,
  ),
  PresentedChallenge(
    title: '휴대폰 보기를 줄여라 | 스크린타임 인생',
    imageUrl: 'https://picsum.photos/200/102',
    participants: 1227,
    daysLeft: 30,
    isParticipated: false,
  ),
];
