import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../utils/token_util.dart';
import '../models/challenge.dart';
import '../data/global_challenges.dart'; // allChallengesNotifier, mapBackendChallenges

class BetuChallengeLoader {
  static bool _loading = false;
  static bool get isLoading => _loading;

  static Future<void> loadAndPublish({BuildContext? context}) async {
    if (_loading) return;
    _loading = true;

    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('로그인이 필요합니다');
      }

      final uri = Uri.parse('https://54.180.150.39.nip.io/api/challenges');
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );

      if (res.statusCode != 200) {
        throw Exception('챌린지 조회 실패: ${res.statusCode} ${res.body}');
      }

      final decoded = jsonDecode(res.body);
      final List<dynamic> raw =
          decoded is List
              ? decoded
              : (decoded is Map<String, dynamic> && decoded['content'] is List)
                  ? decoded['content'] as List
                  : throw Exception('알 수 없는 응답 형식');

      // 백엔드 → 앱 모델 변환 (duration/target 정규화, 상태/참여/좋아요 반영)
      final list = mapBackendChallenges(raw)
        ..sort((a, b) => b.participants.compareTo(a.participants));

      // 전역 갱신
      allChallengesNotifier.value = List<Challenge>.from(list);
    } catch (e) {
      debugPrint('load backend challenges error: $e');
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('챌린지 불러오기 실패: $e')),
        );
      }
    } finally {
      _loading = false;
    }
  }
}
