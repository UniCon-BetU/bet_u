import 'package:flutter/material.dart';
import '../models/challenge.dart';

const String baseUrl = 'https://54.180.150.39.nip.io';

/// 전역: 전체 챌린지 리스트
final ValueNotifier<List<Challenge>> allChallengesNotifier =
    ValueNotifier<List<Challenge>>([]);

/// ---------- 내부 유틸 ----------
int _asInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) {
    final p = int.tryParse(v);
    if (p != null) return p;
  }
  return fallback;
}

String _normalizeType(dynamic raw) {
  final s = (raw ?? '').toString().trim().toUpperCase();
  switch (s) {
    case 'DURATION':
      return 'duration';
    case 'TARGET':
      return 'target';
    // 혹시 과거 값(time/goal)과 호환
    case 'TIME':
      return 'duration';
    case 'GOAL':
      return 'target';
    default:
      return s.toLowerCase();
  }
}

/// ---------- 백엔드 → 앱 모델 매핑 ----------
/// 백엔드 한 개 객체를 Challenge로 변환
Challenge mapBackendToFlutterChallenge(
  Map<String, dynamic> j, {
  bool defaultParticipating = false,
}) {
  // 타입/기간
  final type = _normalizeType(j['challengeType']);
  final duration = _asInt(j['challengeDuration']);
  // target 타입은 기간 표시 안 쓰므로 0으로 둠 (타일에서 자동 처리)
  final int day = (type == 'duration') ? (duration == 0 ? 1 : duration) : 0;

  // 이미지: 리스트/단일 모두 대응
  final List<String> imageUrls = (j['imageUrls'] is List)
      ? (j['imageUrls'] as List).map((e) => e.toString()).toList()
      : (j['imageUrl'] != null
            ? <String>[j['imageUrl'].toString()]
            : const <String>[]);
  final String? imageUrl =
      (j['imageUrl'] as String?) ??
      (imageUrls.isNotEmpty ? imageUrls.first : null);

  // 상태 플래그
  final bool participating =
      (j['participating'] ?? j['isParticipating'] ?? defaultParticipating)
          as bool;
  final bool todayVerified = (j['todayVerified'] ?? false) as bool;
  final bool liked = (j['liked'] ?? j['isFavorite'] ?? false) as bool;

  // 진행일(없으면 0)
  final int progressDays = _asInt(j['progress'] ?? j['progressDays']);

  // status 계산 (완료 판정 가능 시 completed)
  final status = _deriveStatus(
    participating: participating,
    progressDays: progressDays,
    totalDays: day,
  );

  // todayCheck: 서버는 대기값이 없으니 notStarted/done 두 값만 기본
  final todayCheck = todayVerified ? TodayCheck.done : TodayCheck.notStarted;

  // crew
  final crewObj = (j['crew'] is Map<String, dynamic>)
      ? (j['crew'] as Map<String, dynamic>)
      : null;
  final crew = crewObj != null ? Crew.fromJson(crewObj) : null;

  return Challenge(
    // 기본
    id: _asInt(j['challengeId'] ?? j['id']),
    scope: (j['challengeScope'] ?? j['scope'] ?? '') as String,
    crew: crew,

    // 분류/태그
    type: type, // 'duration' | 'target'
    tags: (j['challengeTags'] is List)
        ? (j['challengeTags'] as List).map((e) => e.toString()).toList()
        : const <String>[],
    customTags: (j['customTags'] is List)
        ? (j['customTags'] as List).map((e) => e.toString()).toList()
        : const <String>[],

    // 텍스트
    title: (j['challengeName'] ?? j['title'] ?? '').toString(),
    description: (j['challengeDescription'] ?? j['description'] ?? '')
        .toString(),

    // 이미지
    imageUrls: imageUrls,
    imageUrl: imageUrl,

    // 수치
    day: day,
    participants: _asInt(j['participantCount']),
    favoriteCount: _asInt(j['favoriteCount']),
    progressDays: progressDays,

    // 상태(가변)
    participating: participating,
    status: status,
    todayCheck: todayCheck,
    liked: liked,
  );
}

/// 여러 개 변환
List<Challenge> mapBackendChallenges(
  List<dynamic> backendList, {
  bool defaultParticipating = false,
}) {
  return backendList
      .whereType<Map<String, dynamic>>()
      .map(
        (e) => mapBackendToFlutterChallenge(
          e,
          defaultParticipating: defaultParticipating,
        ),
      )
      .toList();
}

/// ---------- 편의: 전역 퍼블리시 ----------
void publishAllChallenges(List<Challenge> items) {
  allChallengesNotifier.value = List<Challenge>.from(items);
}

/// 내부: status 계산 로직
ChallengeStatus _deriveStatus({
  required bool participating,
  required int progressDays,
  required int totalDays,
}) {
  if (totalDays > 0 && progressDays >= totalDays) {
    return ChallengeStatus.completed;
  }
  return participating
      ? ChallengeStatus.inProgress
      : ChallengeStatus.notStarted;
}
