
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/token_util.dart';
import '../models/challenge.dart';
import '../data/global_challenges.dart';

class BetuChallengeLoader {
  static bool _loading = false;
  static bool get isLoading => _loading;

  static Future<void> loadAndPublish({BuildContext? context}) async {
    if (_loading) return;
    _loading = true;
    try {
      final token = await TokenStorage.getToken();
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

      final List<dynamic> raw = jsonDecode(res.body);
      final list = raw
          .map<Challenge>((j) => Challenge.fromJson(j as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.participants.compareTo(a.participants));

      // 전역 갱신
      allChallenges
        ..clear()
        ..addAll(list);
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
