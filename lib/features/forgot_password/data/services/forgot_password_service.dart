import 'package:hammer_app/core/config/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ForgotPasswordService {
  static const Duration _requestTimeout = Duration(seconds: 20);

  Future<Map<String, dynamic>> _postWithRetry(
    Uri url, {
    required Map<String, String> headers,
    required String body,
  }) async {
    try {
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(_requestTimeout);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on SocketException {
      await Future.delayed(const Duration(milliseconds: 350));
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(_requestTimeout);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on http.ClientException {
      await Future.delayed(const Duration(milliseconds: 350));
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(_requestTimeout);
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
  }

  Future<Map<String, dynamic>> sendOtp(String mobile) async {
    final url = Uri.parse(ApiConstants.forgotPassword);
    return _postWithRetry(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Connection': 'close',
        'Authorization': 'Bearer ${ApiConstants.preAuthBearerToken}',
      },
      body: jsonEncode({'mobile': mobile}),
    );
  }

  Future<Map<String, dynamic>> verifyOtp(String mobile, String otp) async {
    final url = Uri.parse(ApiConstants.verifyForgotPasswordOtp);

    return _postWithRetry(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Connection': 'close',
        'Authorization': 'Bearer ${ApiConstants.preAuthBearerToken}',
      },
      body: jsonEncode({'mobile': mobile, 'otp': otp}),
    );
  }

  /// Updates password using session token from verify OTP.
  Future<Map<String, dynamic>> resetPassword(
    String resetToken,
    String password,
    String passwordConfirmation,
  ) async {
    final url = Uri.parse(ApiConstants.updatePassword);
    return _postWithRetry(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Connection': 'close',
        'User-Agent': 'HammerTechnicianApp/1.0.0 (Android; Mobile)',
        'Authorization': 'Bearer $resetToken',
      },
      body: jsonEncode({
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );
  }
}
