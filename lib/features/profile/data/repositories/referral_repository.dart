import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hammer_app/core/config/api_constants.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';

class ReferralRepository {
  Future<List<dynamic>> getReferrals() async {
    final token = await SharedPrefsHelper.getToken();
    final response = await http.get(
      Uri.parse(ApiConstants.referrals),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true && decoded['data'] != null) {
        return decoded['data']['referrals'] as List<dynamic>? ?? [];
      }
      return [];
    } else {
      throw Exception('Failed to load referrals: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> submitReferral(String mobile) async {
    final token = await SharedPrefsHelper.getToken();
    final response = await http.post(
      Uri.parse(ApiConstants.referral),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'mobile': mobile,
      }),
    );

    final decoded = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return decoded;
    } else {
      final msg = decoded['message'] ?? 'Failed to submit referral';
      throw Exception(msg);
    }
  }
}
