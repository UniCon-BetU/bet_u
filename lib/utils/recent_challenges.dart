// utils/recent_challenges.dart

import '../models/challenge.dart';

// 전역 변수: 최근 방문 챌린지 목록
List<Challenge> recentVisitedChallengesGlobal = [];

// 챌린지를 최근 방문 목록에 추가하는 함수
void addRecentVisitedChallenge(Challenge challenge) {
  recentVisitedChallengesGlobal.removeWhere((c) => c.title == challenge.title);
  recentVisitedChallengesGlobal.insert(0, challenge); // 최신 방문이 제일 앞
  if (recentVisitedChallengesGlobal.length > 10) {
    recentVisitedChallengesGlobal.removeLast(); // 최대 10개 유지
  }
}
