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

  String krCategory(String enCategory) {
    switch (enCategory) {
      case "EXAM": return "수능";
      case "UNIVERSITY": return "대학";
      case "TOEIC": return "토익";
      case "CERTIFICATE": return "자격증";
      case "CIVIL_SERVICE": return "공무원/행시";
      case "LEET": return "LEET";
      case "CPA": return "회계사";
      case "SELF_DEVELOPMENT": return "생활/자기계발";
    }
    return '기타';
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
        ? krCategory(backendChallenge['challengeTags'][0])
        : '기타',
    createdAt: DateTime.parse(backendChallenge['challengeStartDate']),
    type: type,
    tags: backendChallenge['challengeTags'] != null
        ? List<String>.from(backendChallenge['challengeTags'])
        : [],
    bannerPeriod:
        "${backendChallenge['challengeStartDate']}~${backendChallenge['challengeEndDate']}",
    bannerDescription: backendChallenge['challengeDescription'] ?? '',
    whoMadeIt: backendChallenge['challengeScope'] == "BETU" ? "BETU" : null,
    todayCheck: TodayCheck.waiting,
    progressDays: backendChallenge['progress'] ?? 0,
    isFavorite: backendChallenge['isFavorite'] ?? false,
  );
}

/// 백엔드 챌린지 리스트 변환
List<Challenge> mapBackendChallenges(List<Map<String, dynamic>> backendList) {
  return backendList.map((e) => mapBackendToFlutterChallenge(e)).toList();
}

final List<Challenge> allChallenges = [];
