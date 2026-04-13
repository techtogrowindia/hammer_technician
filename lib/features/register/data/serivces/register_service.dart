import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:hammer_app/core/config/api_constants.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';

class RegisterService {
  static const Duration _requestTimeout = Duration(seconds: 20);

  Future<http.Response> _postWithRetry(
    Uri uri, {
    required Map<String, String> headers,
    required String body,
  }) async {
    int retryCount = 0;
    const maxRetries = 2;

    while (true) {
      try {
        final headersCopy = Map<String, String>.from(headers);
        headersCopy['Connection'] = 'close';
        headersCopy['User-Agent'] = 'HammerTechnicianApp/1.0.0 (Android; Mobile)';

        return await http
            .post(uri, headers: headersCopy, body: body)
            .timeout(_requestTimeout);
      } catch (e) {
        final isRetryable = e is SocketException || 
                           e is http.ClientException || 
                           e.toString().contains('TimeoutException');
        
        if (retryCount < maxRetries && isRetryable) {
          retryCount++;
          await Future.delayed(Duration(seconds: retryCount));
          continue;
        }
        rethrow;
      }
    }
  }


  Future<RegisterResponse> register(RegisterRequest request) async {
    final uri = Uri.parse(ApiConstants.create);
    final body = jsonEncode(request.toJson());
    const headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Connection': 'close',
      'User-Agent': 'HammerTechnicianApp/1.0.0 (Android; Mobile)',
      'Authorization': 'Bearer ${ApiConstants.preAuthBearerToken}',
    };

    try {
      final response = await _postWithRetry(uri, headers: headers, body: body);

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 422) {
        return RegisterResponse.fromJson(json);
      }

      return RegisterResponse(
        success: false,
        message: json['message'] ?? 'Registration failed',
        errors: json['errors'] != null
            ? (json['errors'] as Map<String, dynamic>).map(
                (k, v) => MapEntry(k, List<String>.from(v as List)),
              )
            : null,
      );
    } catch (e) {
      return RegisterResponse(
        success: false,
        message: 'Unable to register now. Please try again.',
      );
    }
  }
}
