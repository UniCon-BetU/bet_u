enum ChallengeStatus {
  inProgress, // 진행 중
  done, // 완료
  missed, // 놓친 챌린지
}

class Challenge {
  final String title; // 챌린지 제목
  int participants; // 참여자 수
  final int day; // 챌린지 기간(일)
  final ChallengeStatus status; // 진행 상태
  final String category; // 카테고리 (예: 운동, 공부, 생활습관)
  final DateTime createdAt; // 생성일
  final String? type; // 챌린지 유형 (예: goal, time 등)
  final List<String> tags; // 태그 리스트
  final String? imageUrl; // 이미지 URL

  Challenge({
    required this.title,
    required this.participants,
    required this.day,
    required this.status,
    required this.category,
    required this.createdAt,
    this.type,
    List<String>? tags,
    this.imageUrl,
  }) : tags = tags ?? []; // null이면 빈 리스트로 초기화
}
