// utils/recent_challenges.dart

import '../models/challenge.dart';

// 전역 변수: 최근 방문 챌린지 목록
List<Challenge> recentVisitedChallengesGlobal = [];

// 챌린지를 최근 방문 목록에 추가하는 함수
void addRecentVisitedChallenge(Challenge challenge) {
  // 중복 챌린지가 있다면 기존 항목을 제거합니다.
  recentVisitedChallengesGlobal.removeWhere(
    (item) => item.title == challenge.title,
  );
  // 가장 최근에 방문한 챌린지를 목록 맨 앞에 추가합니다.
  recentVisitedChallengesGlobal.insert(0, challenge);
  // 목록 최대 길이를 10개로 유지합니다.
  if (recentVisitedChallengesGlobal.length > 10) {
    recentVisitedChallengesGlobal.removeLast();
  }
}
