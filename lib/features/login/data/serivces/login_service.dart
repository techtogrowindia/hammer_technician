import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hammer_app/core/config/api_constants.dart';
import 'package:hammer_app/features/login/data/models/login_request_model.dart';
import 'package:hammer_app/features/login/data/models/login_response_model.dart';
import 'package:http/http.dart' as http;

class LoginService {
  static final http.Client _client = http.Client();

  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Connection': 'keep-alive',
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
  };

  Future<LoginResponse> login(LoginRequest request) async {
    final uri = Uri.parse(ApiConstants.login);

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final response = await _client.post(
          uri,
          headers: {
            ..._defaultHeaders,
            'Authorization': 'Bearer ${ApiConstants.preAuthBearerToken}',
          },
          body: jsonEncode(request.toJson()),
        ).timeout(const Duration(seconds: 20));

        debugPrint("LOGIN STATUS => ${response.statusCode}");
        
        if (response.statusCode == 502 || response.statusCode == 503 || response.statusCode == 504) {
          throw Exception('Server temporarily unavailable');
        }

        final isHtml = response.body.trim().startsWith('<!DOCTYPE') ||
            (response.headers['content-type']?.contains('text/html') ?? false);
        if (isHtml) {
          throw const FormatException('HTML Response');
        }

        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;

        if (response.statusCode == 200) {
          return LoginResponse.fromJson(json);
        } else if (response.statusCode == 401 || response.statusCode == 422) {
          return LoginResponse.fromJson(json);
        } else {
          return LoginResponse(
            success: false,
            message: json['message']?.toString() ?? 'Login failed (${response.statusCode})',
          );
        }
      } catch (e) {
        retryCount++;
        final isRetryable = e is SocketException || 
                           e is http.ClientException || 
                           e.toString().contains('TimeoutException') || 
                           e.toString().contains('unavailable');
        
        debugPrint("[LoginService] Retry $retryCount/$maxRetries for login. Error: $e");
        
        if (retryCount < maxRetries && isRetryable) {
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }

        if (retryCount >= maxRetries) {
          return LoginResponse(
            success: false,
            message: "Network error. Server is unreachable after $maxRetries attempts.",
          );
        }

        // Return error for non-retryable issues (like FormatException)
        return LoginResponse(
          success: false,
          message: "Network error: ${e.toString().replaceAll('Exception: ', '')}",
        );
      }
    }
    
    return LoginResponse(
      success: false,
      message: "Network error. Failed to connect.",
    );
  }
}
