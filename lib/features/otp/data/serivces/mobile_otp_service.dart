import 'dart:convert';
import 'package:hammer_app/features/otp/data/models/verify_otp_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:hammer_app/core/config/api_constants.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';

class MobileOtpService {
  Future<String> sendOtp() async {
    final response = await _authorizedPost(ApiConstants.sendOtp);

    return response['message'];
  }

  Future<String> resendOtp() async {
    final response = await _authorizedPost(ApiConstants.resendOtp);

    return response['message'];
  }

  Future<OtpVerifyResponse> verifyOtp(String otp) async {
    final response = await _authorizedPost(
      ApiConstants.verifyMobileOtp,
      body: {'otp': otp},
    );

    return OtpVerifyResponse.fromJson(response);
  }

  // 🔐 Common authorized POST
  Future<Map<String, dynamic>> _authorizedPost(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    final token = await SharedPrefsHelper.getToken();

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      } else {
        throw decoded['message'] ?? 'Something went wrong';
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
