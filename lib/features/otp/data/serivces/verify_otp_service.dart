import 'dart:convert';
import 'package:hammer_app/core/config/api_constants.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';
import 'package:hammer_app/features/otp/data/models/verify_otp_response_model.dart';
import 'package:http/http.dart' as http;

class OtpService {
  final http.Client _client = http.Client();

  Future<OtpVerifyResponse> verifyOtp({required String otp}) async {
    final uri = Uri.parse(ApiConstants.verifyOtp);
    final token = await SharedPrefsHelper.getToken();
    final body = {'otp': otp};

    try {
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      final otpVerifyResponse = OtpVerifyResponse.fromJson(json);

      if (response.statusCode == 200) {
        return otpVerifyResponse;
      }
      if (response.statusCode == 422) {
        return otpVerifyResponse;
      }
      throw Exception(otpVerifyResponse.message);
    } catch (e) {
      return OtpVerifyResponse(
        success: false,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}
