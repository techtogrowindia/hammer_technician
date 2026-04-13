import 'dart:convert';
import 'package:hammer_app/core/config/api_constants.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';
import 'package:http/http.dart' as http;

class LogoutService {
  static Future<String> logout() async {
    final url = Uri.parse(ApiConstants.logout);

    try {
      final token = await SharedPrefsHelper.getToken();
      
      // Attempt to tell the server to revoke the token
      await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      ).timeout(const Duration(seconds: 5));

    } catch (e) {
      // Ignore network errors when logging out
      // We still want the user to be able to sign out locally
    } finally {
      // Always clear local session to prevent the user from being trapped in the app
      await SharedPrefsHelper.clearToken();
      await SharedPrefsHelper.clearAllCache();
    }
    
    return 'SUCCESS';
  }
}
