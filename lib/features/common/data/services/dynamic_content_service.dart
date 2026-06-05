import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hammer_app/core/config/api_constants.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';
import 'package:http/http.dart' as http;
import '../models/dynamic_content_model.dart';

class DynamicContentService {
  final http.Client client;

  DynamicContentService({http.Client? client}) : client = client ?? http.Client();

  Future<DynamicContentModel> getDynamicContent() async {
    final userToken = await SharedPrefsHelper.getToken();
    final token = (userToken != null && userToken.isNotEmpty) ? userToken : ApiConstants.preAuthBearerToken;
    final url = Uri.parse(ApiConstants.dynamicContent);

    final response = await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body) as Map<String, dynamic>;
      return DynamicContentModel.fromJson(jsonBody);
    } else {
      throw Exception('Failed to load dynamic content (${response.statusCode})');
    }
  }

  Future<String?> getPositiveMessage() async {
    final token = await SharedPrefsHelper.getToken();
    debugPrint('[PositiveMessage] token present: ${token != null && token.isNotEmpty}');
    if (token == null || token.isEmpty) return null;

    final url = Uri.parse(ApiConstants.positiveMessage);
    debugPrint('[PositiveMessage] URL: $url');
    try {
      final response = await client
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('[PositiveMessage] status: ${response.statusCode}');
      debugPrint('[PositiveMessage] body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body) as Map<String, dynamic>;
        final msg = (jsonBody['data'] as Map<String, dynamic>?)?['positive_message']?.toString();
        debugPrint('[PositiveMessage] parsed message: $msg');
        return msg;
      }
    } catch (e) {
      debugPrint('[PositiveMessage] ERROR: $e');
    }

    return null;
  }
}
