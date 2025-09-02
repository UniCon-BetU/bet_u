import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/token_util.dart';
import '../models/challenge.dart';
import '../data/my_challenges.dart';

class MyChallengeLoader {
  static bool _loading = false;
  static bool get isLoading => _loading;

  static const _base = 'https://54.180.150.39.nip.io';

  // 서버 응답(JSON) -> Challenge.fromJson 이 기대하는 형태로 변환
  static Map<String, dynamic> _normalizeForChallengeModel(
    Map<String, dynamic> j,
  ) {
    // ⚠️ 아래 우측 값들은 너희 Challenge.fromJson 이 기대하는 "키 이름"에 맞게 바꿔 둔 예시야.
    // 네 모델의 필드명이 다르면 이 부분 키를 맞춰줘.
    return {
      // 기본 식별/텍스트
      'id': j['challengeId'],
      'name': j['challengeName'],
      'description': j['challengeDescription'],
      'imageUrl': j['imageUrl'],

      // 분류/스코프/타입/태그
      'scope': j['challengeScope'],                // e.g. "CREW"
      'type': j['challengeType'],                  // e.g. "DURATION"
      'tags': j['challengeTags'] ?? <String>[],
      'customTags': j['customTags'] ?? <String>[],

      // 수치들
      'favoriteCount': j['favoriteCount'] ?? 0,
      // 기존 모델이 participants 라는 필드를 쓴다면 이름을 participants 로 맞춰 줌
      'participants': j['participantCount'] ?? 0,

      // 기간/일수 (기존 모델이 day/totalDays 같은 걸 쓴다면 여기에 매핑)
      'day': j['challengeDuration'] ?? 0,

      // crew (모델에 crew 객체/필드가 있으면 함께 넘겨줌)
      'crew': j['crew'],

      // 모델이 status/todayCheck/participating 등을 요구한다면 기본값 채우기
      // 'status': 'IN_PROGRESS',  // 필요시
      // 'todayCheck': 'WAITING',  // 필요시
      // 'participating': true,    // 필요시
    };
  }

  static Future<void> loadAndPublish({BuildContext? context}) async {
    if (_loading) return;
    _loading = true;

    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('로그인 토큰이 없습니다');
      }

      final uri = Uri.parse('$_base/api/challenges/me');
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );

      if (res.statusCode != 200) {
        throw Exception('내 챌린지 조회 실패: ${res.statusCode} ${res.body}');
      }

      // 이 API는 항상 "리스트"를 반환
      final decoded = jsonDecode(res.body);
      if (decoded is! List) {
        throw Exception('예상과 다른 응답 형식(리스트가 아님)');
      }

      // 1) 키 변환 -> 2) Challenge.fromJson -> 3) 정렬
      final items = decoded
          .whereType<Map<String, dynamic>>()
          .map((j) => _normalizeForChallengeModel(j))
          .map<Challenge>((m) => Challenge.fromJson(m))
          // 참가자 수 기준 내림차순 (키를 participants 로 맞춰줬음)
          .toList()
        ..sort((a, b) {
          final ap = a.participants; // 모델에 맞게 널가드
          final bp = b.participants;
          return bp.compareTo(ap);
        });

      // 전역 상태 반영
      myChallenges
        ..clear()
        ..addAll(items);
      myChallengesNotifier.value = List<Challenge>.from(items);
    } catch (e) {
      debugPrint('load my challenges error: $e');
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('내 챌린지 불러오기 실패: $e')),
        );
      }
    } finally {
      _loading = false;
    }
  }
}
