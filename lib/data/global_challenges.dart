import 'package:flutter/material.dart';

import '../models/challenge.dart';

const String baseUrl = 'https://54.180.150.39.nip.io';
final ValueNotifier<List<Challenge>> allChallengesNotifier =
    ValueNotifier<List<Challenge>>([]);

/// 백엔드에서 온 챌린지 데이터를 Flutter Challenge로 변환
Challenge mapBackendToFlutterChallenge(Map<String, dynamic> backendChallenge) {
  int day = 0;
  String type;

  // 타입과 day 계산
  if (backendChallenge['challengeType'] == "DURATION") {
    day = backendChallenge['challengeDuration'] ?? 0; // 기간 챌린지일 경우 period
    type = "time"; // Flutter에서 DURATION은 time으로
  } else if (backendChallenge['challengeType'] == "TARGET") {
    day = backendChallenge['targetCount'] ?? 0; // 목표 달성일 경우 count
    type = "goal"; // Flutter에서 TARGET은 goal로
  } else {
    type = "time"; // 기본값
  }

  return Challenge(
    id: backendChallenge['challengeId'],
    title: backendChallenge['challengeName'] ?? '',
    participants: backendChallenge['participantCount'] ?? 0,
    day: day,
    status: ChallengeStatus.notStarted, // 참여 전
    category:
        (backendChallenge['challengeTags'] != null &&
            backendChallenge['challengeTags'].isNotEmpty)
        ? backendChallenge['challengeTags'][0]
        : '기타',
    createdAt: DateTime.parse(backendChallenge['challengeStartDate']),
    type: type,
    tags: backendChallenge['challengeTags'] != null
        ? List<String>.from(backendChallenge['challengeTags'])
        : [],
    bannerPeriod:
        "${backendChallenge['challengeStartDate']}~${backendChallenge['challengeEndDate']}",
    bannerDescription: backendChallenge['challengeDescription'] ?? '',
    WhoMadeIt: "BETU",
    todayCheck: TodayCheck.waiting,
    progressDays: backendChallenge['progress'] ?? 0,
    isFavorite: backendChallenge['isFavorite'] ?? false,
  );
}

/// 백엔드 챌린지 리스트 변환
List<Challenge> mapBackendChallenges(List<Map<String, dynamic>> backendList) {
  return backendList.map((e) => mapBackendToFlutterChallenge(e)).toList();
}

final List<Challenge> allChallenges = [
  /*
  Challenge(
    title: '휴대폰 줄이기 | 스크린타임 인증 챌린지',
    participants: 2686,
    day: 14,
    status: ChallengeStatus.inProgress,
    category: '생활습관',
    createdAt: DateTime(2025, 8, 20),
    type: 'time',
    tags: ['생활습관', '집중', '기상'],
    bannerPeriod: '상시',
    bannerDescription: '하루 휴대폰 사용을 줄이고 집중 습관을 만드는 인증 챌린지입니다.',
    WhoMadeIt: 'BETU',
    todayCheck: TodayCheck.waiting,
    progressDays: 13,
    isFavorite: false,
  ),
  Challenge(
    title: '수능 국어 하루 3지문',
    participants: 1723,
    day: 12,
    status: ChallengeStatus.inProgress,
    category: '수능',
    createdAt: DateTime(2025, 7, 1),
    type: 'time',
    tags: ['국어', '독해', '수능'],
    bannerPeriod: '2025.7.1~2025.7.12',
    bannerDescription: '매일 3지문씩 꾸준히 읽으며 국어 독해력을 향상시키는 챌린지입니다.',
    WhoMadeIt: 'BETU',
    todayCheck: TodayCheck.done,
    progressDays: 6,
    isFavorite: false,
  ),
  Challenge(
    title: '영어 단어 30개 암기',
    participants: 2105,
    day: 30,
    status: ChallengeStatus.inProgress,
    category: '수능',
    createdAt: DateTime(2025, 6, 15),
    type: 'time',
    tags: ['영어', '단어', '암기'],
    bannerPeriod: '2025.6.15~2025.7.14',
    bannerDescription: '매일 30개의 영어 단어를 암기하여 영어 실력을 높이는 챌린지입니다.',
    WhoMadeIt: 'BETU',
    todayCheck: TodayCheck.done,
    progressDays: 10,
    isFavorite: false,
  ),
  Challenge(
    title: '수학 문제집 하루 20문제',
    participants: 1980,
    day: 20,
    status: ChallengeStatus.inProgress,
    category: '수능',
    createdAt: DateTime(2025, 6, 20),
    type: 'time',
    tags: ['수학', '문제풀이'],
    bannerPeriod: '2025.6.20~2025.7.9',
    bannerDescription: '하루 20문제를 꾸준히 풀며 수학 실력을 향상시키는 챌린지입니다.',
    WhoMadeIt: 'BETU',
    todayCheck: TodayCheck.waiting,
    progressDays: 9,
    isFavorite: false,
  ),
  Challenge(
    title: '학기 GPA 4.5 달성',
    participants: 1320,
    day: 25,
    status: ChallengeStatus.inProgress,
    category: '대학',
    createdAt: DateTime(2025, 7, 3),
    type: 'goal',
    tags: ['건강', '습관'],
    bannerPeriod: '상시',
    bannerDescription: '학기 목표 GPA 4.5 달성을 위해 계획과 습관을 관리하는 챌린지입니다.',
    WhoMadeIt: 'BETU',
    progressDays: 0,
    isFavorite: false,
  ),
  Challenge(
    title: '토익 단어 50개 외우기',
    participants: 980,
    day: 15,
    status: ChallengeStatus.notStarted,
    category: '토익',
    createdAt: DateTime(2025, 6, 25),
    type: 'time',
    tags: ['영어', '토익', '단어'],
    bannerPeriod: '2025.6.25~2025.7.9',
    bannerDescription: '하루 50개 단어 암기를 목표로 하는 챌린지입니다.',
    WhoMadeIt: 'BETU',
    todayCheck: TodayCheck.notStarted,
    isFavorite: false,
  ),
  Challenge(
    title: '회계사 기출 문제 하루 10문제',
    participants: 450,
    day: 20,
    status: ChallengeStatus.notStarted,
    category: '회계사',
    createdAt: DateTime(2025, 5, 20),
    type: 'time',
    tags: ['회계사', '기출', '문제풀이'],
    bannerPeriod: '2025.5.20~2025.6.8',
    bannerDescription: '매일 10문제를 풀며 회계사 시험 대비 능력을 키우는 챌린지입니다.',
    WhoMadeIt: 'BETU',
    todayCheck: TodayCheck.notStarted,
    isFavorite: false,
  ),
  Challenge(
    title: '주간 운동 루틴',
    participants: 540,
    day: 7,
    status: ChallengeStatus.inProgress,
    category: '건강',
    createdAt: DateTime(2025, 7, 10),
    type: 'goal',
    tags: ['운동', '건강'],
    bannerPeriod: '상시',
    bannerDescription: '주간 운동 루틴을 꾸준히 실천하는 챌린지입니다.',
    WhoMadeIt: 'BETU',
    progressDays: 0,
    isFavorite: false,
  ),
  */
];
