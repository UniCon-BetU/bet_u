// lib/models/challenge.dart
import 'package:flutter/foundation.dart';

enum ChallengeStatus { notStarted, inProgress, completed }
enum TodayCheck { notStarted, waiting, done }

@immutable
class Crew {
  final int crewId;
  final String crewName;
  final String crewDescription;
  final String crewCode;
  final bool crewIsPublic;
  final List<String> customTags;

  const Crew({
    required this.crewId,
    required this.crewName,
    required this.crewDescription,
    required this.crewCode,
    required this.crewIsPublic,
    required this.customTags,
  });

  factory Crew.fromJson(Map<String, dynamic> j) {
    return Crew(
      crewId: _asInt(j['crewId']),
      crewName: (j['crewName'] ?? '') as String,
      crewDescription: (j['crewDescription'] ?? '') as String,
      crewCode: (j['crewCode'] ?? '') as String,
      crewIsPublic: (j['crewIsPublic'] ?? j['isPublic'] ?? false) as bool,
      customTags: (j['customTags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
    );
  }

  Map<String, dynamic> toJson() => {
        'crewId': crewId,
        'crewName': crewName,
        'crewDescription': crewDescription,
        'crewCode': crewCode,
        'crewIsPublic': crewIsPublic,
        'customTags': customTags,
      };
}

class Challenge {
  // ===== 불변 필드 =====
  final int id;                // challengeId
  final String scope;          // CREW / PUBLIC / BETU
  final Crew? crew;

  // 분류/태그
  /// 서버: challengeType (DURATION / TARGET) → 'duration' / 'target'
  final String type;
  final List<String> tags;       // challengeTags
  final List<String> customTags;

  // 표시 텍스트
  final String title;            // challengeName
  final String description;      // challengeDescription

  // 이미지
  final List<String> imageUrls;  // 상세: imageUrls
  final String? imageUrl;        // /me: imageUrl 또는 imageUrls.first

  // 수치
  final int day;                 // challengeDuration
  final int participants;        // participantCount
  final int favoriteCount;       // favoriteCount
  final int progressDays;        // progress

  // ===== 가변 필드 =====
  bool participating;            // ✅ 서버 boolean 그대로 들고 있음
  ChallengeStatus status;        // ✅ UI용 상태
  TodayCheck todayCheck;         // ✅ todayVerified 매핑
  bool liked;                    // ✅ 좋아요

  Challenge({
    required this.id,
    required this.scope,
    required this.crew,
    required this.type,
    required this.tags,
    required this.customTags,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.imageUrl,
    required this.day,
    required this.participants,
    required this.favoriteCount,
    required this.progressDays,
    required this.participating, // ✅
    required this.status,
    required this.todayCheck,
    required this.liked,
  });

  /// 서버 응답 흡수 (/me, 상세 공통)
  factory Challenge.fromJson(Map<String, dynamic> j) {
    final id = _asInt(j['id'] ?? j['challengeId']);
    final scope = (j['challengeScope'] ?? j['scope'] ?? '') as String;

    final rawType =
        (j['challengeType'] ?? j['type'] ?? '').toString().trim().toUpperCase();
    final type = switch (rawType) {
      'DURATION' => 'duration',
      'TARGET' => 'target',
      _ => rawType.toLowerCase(),
    };

    final title =
        (j['title'] ?? j['challengeName'] ?? '챌린지').toString().trim();
    final description =
        (j['description'] ?? j['challengeDescription'] ?? '').toString();

    final List<String> imageUrls = (j['imageUrls'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        (j['imageUrl'] != null
            ? <String>[j['imageUrl'].toString()]
            : const <String>[]);
    final String? imageUrl =
        (j['imageUrl'] as String?) ?? (imageUrls.isNotEmpty ? imageUrls.first : null);

    final day = _asInt(j['day'] ?? j['challengeDuration']);
    final participants = _asInt(j['participants'] ?? j['participantCount']);
    final favoriteCount = _asInt(j['favoriteCount']);
    final progressDays = _asInt(j['progress'] ?? j['progressDays']);

    final List<String> tags = (j['tags'] ?? j['challengeTags'] ?? const <String>[])
            is List
        ? ((j['tags'] ?? j['challengeTags']) as List)
            .map((e) => e.toString())
            .toList()
        : const <String>[];
    final List<String> customTags =
        (j['customTags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            const <String>[];

    final participating =
        (j['participating'] ?? j['isParticipating'] ?? false) as bool;
    final todayVerified = (j['todayVerified'] ?? false) as bool;
    final liked = (j['liked'] ?? false) as bool;

    // status 계산: 완료 판정이 가능하면 우선 completed
    final status = _deriveStatus(
      participating: participating,
      progressDays: progressDays,
      totalDays: day,
    );

    final todayCheck =
        todayVerified ? TodayCheck.done : TodayCheck.notStarted;

    final crew = (j['crew'] is Map<String, dynamic>)
        ? Crew.fromJson(j['crew'] as Map<String, dynamic>)
        : null;

    return Challenge(
      id: id,
      scope: scope,
      crew: crew,
      type: type,
      tags: tags,
      customTags: customTags,
      title: title,
      description: description,
      imageUrls: imageUrls,
      imageUrl: imageUrl,
      day: day,
      participants: participants,
      favoriteCount: favoriteCount,
      progressDays: progressDays,
      participating: participating, // ✅
      status: status,
      todayCheck: todayCheck,
      liked: liked,
    );
  }

  Map<String, dynamic> toJson() => {
        'challengeId': id,
        'challengeScope': scope,
        'crew': crew?.toJson(),
        'challengeType': type.toUpperCase(),
        'challengeTags': tags,
        'customTags': customTags,
        'challengeName': title,
        'challengeDescription': description,
        'imageUrls': imageUrls,
        'imageUrl': imageUrl,
        'challengeDuration': day,
        'participantCount': participants,
        'favoriteCount': favoriteCount,
        'progress': progressDays,
        'participating': participating,                 // ✅ 서버로 그대로
        'todayVerified': todayCheck == TodayCheck.done,
        'liked': liked,
      };

  // ===== 편의 메서드 =====
  void toggleLiked() => liked = !liked;
  void setLiked(bool v) => liked = v;

  void setStatus(ChallengeStatus s) => status = s;
  void setTodayCheck(TodayCheck t) => todayCheck = t;

  /// participating과 status를 함께 다루기 쉽게 동기화 메서드
  void setParticipating(bool v) {
    participating = v;
    // 완료가 아닌 경우에만 participating에 따라 status 정리
    if (status != ChallengeStatus.completed) {
      status = v ? ChallengeStatus.inProgress : ChallengeStatus.notStarted;
    }
  }

  void markCompleted() {
    status = ChallengeStatus.completed;
    // 완료 시 participating은 그대로 두는 편이 자연스러움(참여해서 끝난 상태)
    // 필요하다면 여기서 participating=false로 바꿔도 됨
  }

  bool get isDuration => type == 'duration';
  bool get isTarget => type == 'target';
}

ChallengeStatus _deriveStatus({
  required bool participating,
  required int progressDays,
  required int totalDays,
}) {
  if (totalDays > 0 && progressDays >= totalDays) {
    return ChallengeStatus.completed;
  }
  return participating ? ChallengeStatus.inProgress : ChallengeStatus.notStarted;
}

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
