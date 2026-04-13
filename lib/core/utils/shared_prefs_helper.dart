
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static const tokenKey = "auth_token";

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  static const phoneKey = "phone";
  static const passwordKey = "password";
  static const rememberMeKey = "remember_me";

  static Future<void> saveCredentials(
    String phone,
    String password,
    bool remember,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (remember) {
      await prefs.setString(phoneKey, phone);
      await prefs.setString(passwordKey, password);
      await prefs.setBool(rememberMeKey, true);
    } else {
      await prefs.remove(phoneKey);
      await prefs.remove(passwordKey);
      await prefs.setBool(rememberMeKey, false);
    }
  }

  static Future<Map<String, dynamic>> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "phone": prefs.getString(phoneKey) ?? "",
      "password": prefs.getString(passwordKey) ?? "",
      "remember": prefs.getBool(rememberMeKey) ?? false,
    };
  }

  static const kycStep1Key = "kyc_step_1";
  static const kycStep2Key = "kyc_step_2";
  static const kycStep3Key = "kyc_step_3";
  static const kycStep4Key = "kyc_step_4";

  static Future<void> saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  static Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  static const cachedProfileKey = "cached_profile_response";

  static Future<void> saveCachedProfileResponse(
    Map<String, dynamic> profileResponseJson,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(cachedProfileKey, jsonEncode(profileResponseJson));
  }

  static Future<Map<String, dynamic>?> getCachedProfileResponse() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(cachedProfileKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(cachedProfileKey);
    await prefs.remove('fcm_token');
    // We can also just call prefs.clear() if want to wipe everything, 
    // but usually better to clear specific auth/user data.
  }
}
