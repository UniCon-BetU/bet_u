import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_util.dart';

class PointApi {
  static Future<int> fetchUserPoints() async {
    final token = await TokenStorage.getToken();
    final url = Uri.parse('https://54.180.150.39.nip.io/api/user/points');
    final response = await http.get(
      url,
      headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('포인트 조회 실패: ${response.statusCode}');
    }
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
