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

  static Future<void> loadAndPublish({BuildContext? context}) async {
    if (_loading) return;
    _loading = true;
    try {
      final token = await TokenStorage.getToken();
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

      // 리스트 응답 / 페이지 응답(content) 모두 대응
      final decoded = jsonDecode(res.body);
      final List<dynamic> raw =
          decoded is List ? decoded
          : (decoded is Map<String, dynamic> && decoded['content'] is List)
              ? decoded['content'] as List
              : throw Exception('알 수 없는 응답 형식');

      final items = raw
          .map<Challenge>((j) => Challenge.fromJson(j as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.participants.compareTo(a.participants)); // 취향껏 정렬

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
