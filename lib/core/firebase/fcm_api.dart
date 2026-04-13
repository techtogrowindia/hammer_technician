import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hammer_app/core/config/api_constants.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';
import 'package:http/http.dart' as http;

class FcmApi {
  static const Duration _requestTimeout = Duration(seconds: 20);

  static Future<bool> sendFcmToken({required String fcmToken}) async {
    final authToken = await SharedPrefsHelper.getToken();
    if (authToken == null || authToken.isEmpty) {
      debugPrint('FCM token sync skipped: missing auth token');
      return false;
    }

    final uri = Uri.parse(ApiConstants.fcmToken);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $authToken',
    };
    final body = jsonEncode({'fcm': fcmToken});

    try {
      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(_requestTimeout);
      debugPrint(
        'FCM Token Registration Response: ${response.statusCode} - ${response.body}',
      );
      return response.statusCode == 200;
    } on SocketException catch (e) {
      debugPrint('FCM token sync socket error: $e');
      try {
        final retryResponse = await http
            .post(uri, headers: headers, body: body)
            .timeout(_requestTimeout);
        debugPrint(
          'FCM Token Registration Retry: ${retryResponse.statusCode} - ${retryResponse.body}',
        );
        return retryResponse.statusCode == 200;
      } catch (retryError) {
        debugPrint('FCM token sync retry failed: $retryError');
        return false;
      }
    } on http.ClientException catch (e) {
      debugPrint('FCM token sync client error: $e');
      return false;
    } catch (e) {
      debugPrint('FCM token sync failed: $e');
      return false;
    }
  }
}
