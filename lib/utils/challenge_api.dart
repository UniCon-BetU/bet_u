import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_util.dart';

class ChallengeApi {
  static const String _base = 'https://54.180.150.39.nip.io';

  /// POST /api/challenges/{challengeId}/join
  /// body: { "betAmount": <int> }
  static Future<void> joinChallenge({
    required int challengeId,
    required int betAmount,
  }) async {
    final token = await TokenStorage.getToken();
    final uri = Uri.parse('$_base/api/challenges/$challengeId/join');

    final res = await http.post(
      uri,
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'betAmount': betAmount}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('참여 실패: ${res.statusCode} ${res.body}');
    }
    // 200 OK: 서버가 포인트 차감 + UserChallenge.betAmount 기록 + 상태 IN_PROGRESS 전환 완료
  }
}
