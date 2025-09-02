import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'token_util.dart';

class PointStore {
  PointStore._();
  static final PointStore instance = PointStore._();

  /// 서버 권위 포인트. 화면들은 이걸 구독(ValueListenableBuilder 등)만 하면 됨.
  final ValueNotifier<int> points = ValueNotifier<int>(10000); // 기본값 수정

  bool _loaded = false;
  bool get isLoaded => _loaded;

  /// 앱 시작 후 한 번 호출 (또는 포인트가 필요한 화면에서 ensureLoaded)
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    await refreshFromServer();
    _loaded = true;
  }

  /// 서버에서 현재 포인트 새로고침
  Future<void> refreshFromServer() async {
    final token = await TokenStorage.getToken();
    final url = Uri.parse('https://54.180.150.39.nip.io/api/user/points');
    final res = await http.get(
      url,
      headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final raw = res.body.trim();
      final serverPoint = int.tryParse(raw) ?? 0;
      points.value = serverPoint;
    } else {
      throw Exception('포인트 조회 실패: ${res.statusCode}');
    }
  }

  /// 토스 결제 완료 후 서버 컨펌 + 포인트 갱신
  Future<void> confirmCharge({
    required String paymentKey,
    required String orderId,
    required int amount,
  }) async {
    final token = await TokenStorage.getToken();
    final url = Uri.parse(
      'https://54.180.150.39.nip.io/api/points/charge/confirm',
    );
    final res = await http.post(
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

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body); // { credited, totalPoint }
      final total = data['totalPoint'] ?? 0;
      points.value = total; // 서버 권위 값으로 갱신
    } else {
      throw Exception('포인트 충전 실패: ${res.statusCode} ${res.body}');
    }
  }

  /// 참여 시 차감(서버가 차감 성공 응답을 줬을 때만 로컬 갱신)
  void deductLocally(int amount) {
    points.value = (points.value - amount).clamp(0, 1 << 31);
  }

  /// 정산 등 서버 응답 totalPoint로 동기화할 때
  void setFromServer(int totalPoint) {
    points.value = totalPoint;
  }

  /// 🔧 기존 코드 호환용 얇은 래퍼 (set -> setFromServer)
  void set(int totalPoint) => setFromServer(totalPoint);
  Future<bool> hasToken() async {
    final token = await TokenStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}
