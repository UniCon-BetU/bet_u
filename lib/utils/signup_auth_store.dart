import 'package:shared_preferences/shared_preferences.dart';

/// 회원가입 플로우 전용 임시 인증 토큰 저장소
class SignupAuthStore {
  static const _kKey = 'signup_temp_authorization';

  static Future<void> save(String token) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_kKey, token);
  }

  static Future<String?> get() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(_kKey);
  }

  static Future<void> clear() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove(_kKey);
  }
}
