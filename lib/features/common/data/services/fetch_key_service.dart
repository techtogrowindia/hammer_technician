import 'dart:convert';
import 'package:hammer_app/core/config/api_constants.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';
import 'package:http/http.dart' as http;

class FetchKeyService {
  Future<Map<String, dynamic>> fetchKey() async {
    final token = await SharedPrefsHelper.getToken();
    if (token == null || token.isEmpty) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse(ApiConstants.fetchKey),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    throw Exception(data['message'] ?? 'Failed to fetch app settings');
  }
}
