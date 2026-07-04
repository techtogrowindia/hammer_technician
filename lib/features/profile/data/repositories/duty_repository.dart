import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hammer_app/core/config/api_constants.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';

class DutyRepository {
  Future<Map<String, dynamic>> getDutyStatus() async {
    final token = await SharedPrefsHelper.getToken();
    final response = await http.get(
      Uri.parse(ApiConstants.duty),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true && decoded['data'] != null) {
        return decoded['data'] as Map<String, dynamic>;
      }
      throw Exception('Invalid response format');
    } else {
      throw Exception('Failed to fetch duty status: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateDutyStatus(bool isOn) async {
    final token = await SharedPrefsHelper.getToken();
    final response = await http.post(
      Uri.parse(ApiConstants.duty),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'status': isOn ? 'on' : 'off',
      }),
    );

    final decoded = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (decoded['success'] == true && decoded['data'] != null) {
        return decoded['data'] as Map<String, dynamic>;
      }
      throw Exception('Invalid response format');
    } else {
      final msg = decoded['message'] ?? 'Failed to update duty status';
      throw Exception(msg);
    }
  }
}
