// lib/utils/point_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_util.dart';

class PointApi {
  static Future<int> fetchUserPoints() async {
    final token = await TokenStorage.getToken();
    final url = Uri.parse('https://54.180.150.39.nip.io/api/user/points');

    final res = await http.get(
      url,
      headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      // 서버가 숫자 하나(예: 0, 12345)를 그대로 반환하므로 바로 파싱
      return int.tryParse(res.body) ?? 0;
    }
    throw Exception('포인트 조회 실패: ${res.statusCode}');
  }

  static Future<ConfirmedPoint> confirmCharge({
    required String paymentKey,
    required String orderId,
    required int amount,
  }) async {
    final token = await TokenStorage.getToken();
    final url = Uri.parse(
      'https://54.180.150.39.nip.io/api/points/charge/confirm',
    );

    final response = await http.post(
      url,
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'paymentKey': paymentKey,
        'orderId': orderId,
        'amount': amount,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ConfirmedPoint(
        credited: data['credited'] ?? 0,
        totalPoint: data['totalPoint'] ?? 0,
      );
    } else {
      throw Exception('포인트 충전 실패: ${response.statusCode}');
    }
  }
}

class ConfirmedPoint {
  final int credited;
  final int totalPoint;
  ConfirmedPoint({required this.credited, required this.totalPoint});
}
