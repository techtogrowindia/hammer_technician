import 'dart:convert';
import 'package:hammer_app/core/config/api_constants.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';
import 'package:hammer_app/features/kyc/data/models/blood_group_model.dart';
import 'package:http/http.dart' as http;

class KycDataLoader {
  static final http.Client _client = http.Client();

  static Future<Map<String, String>> _headers() async {
    final token = await SharedPrefsHelper.getToken();
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Connection": "keep-alive",
      "Accept-Encoding": "identity",
      "X-Requested-With": "XMLHttpRequest",
      "Referer": "https://hammerapp.in/",
      "User-Agent": "PostmanRuntime/7.29.2", // Use a more permissive UA
    };
  }

  static Future<Map<String, dynamic>?> fetchFullKyc() async {
    int retryCount = 0;
    const maxRetries = 5;

    while (retryCount <= maxRetries) {
      try {
        final headers = await _headers();
        final response = await _client.get(
          Uri.parse(ApiConstants.technicianKycFull),
          headers: headers,
        ).timeout(const Duration(seconds: 40));

        final body = response.body.trim();
        if (body.startsWith('<!DOCTYPE') || (response.headers['content-type']?.contains('text/html') ?? false)) {
          print("[KycDataLoader] HTML received for KYC Full. Status: ${response.statusCode}. Retry ${retryCount + 1}");
          retryCount++;
          await Future.delayed(Duration(seconds: 2));
          continue;
        }

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            return data['data'] as Map<String, dynamic>?;
          }
        }
        break;
      } catch (e) {
        if (retryCount < maxRetries) {
          retryCount++;
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }
        print("[KycDataLoader] Failed to fetch full KYC: $e");
        break;
      }
    }
    return null;
  }

  static Future<List<BloodGroupModel>> fetchBloodGroups() async {
    int retryCount = 0;
    const maxRetries = 5;

    while (retryCount <= maxRetries) {
      try {
        final headers = await _headers();
        final response = await _client.get(
          Uri.parse(ApiConstants.bloodgroup),
          headers: headers,
        ).timeout(const Duration(seconds: 40));

        final body = response.body.trim();
        if (body.startsWith('<!DOCTYPE') || (response.headers['content-type']?.contains('text/html') ?? false)) {
          print("[KycDataLoader] HTML received for Blood Groups. Status: ${response.statusCode}. Retry ${retryCount + 1}");
          retryCount++;
          await Future.delayed(Duration(seconds: 2));
          continue;
        }

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            return (data['data'] as List)
                .map((e) => BloodGroupModel.fromJson(e))
                .toList();
          }
        }
        break;
      } catch (e) {
        if (retryCount < maxRetries) {
          retryCount++;
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }
        print("[KycDataLoader] Failed to fetch blood groups: $e");
        break;
      }
    }
    return [];
  }

  static List<bool> updateStepCompletionFromApi(Map<String, dynamic> steps) {
    // Support both old 'services_kyc' and new 'technician_services' keys
    final servicesStatus =
        (steps['technician_services'] ?? steps['services_kyc']);
    return [
      steps['profile_kyc']?['status'] == 'completed',
      servicesStatus?['status'] == 'completed',
      steps['company_kyc']?['status'] == 'completed',
      steps['bank_kyc']?['status'] == 'completed',
      steps['document_kyc']?['status'] == 'completed',
    ];
  }

  static String mapApiKeyToLocalKey(String apiKey) {
    switch (apiKey) {
      case 'bank_passbook':
        return 'bank_statement';
      case 'gst':
        return 'gst_document';
      default:
        return apiKey;
    }
  }
}
