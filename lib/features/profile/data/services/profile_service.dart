import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hammer_app/core/config/api_constants.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';
import 'package:http/http.dart' as http;

import '../models/profile_response_model.dart';
import '../models/general_profile_model.dart';
import '../models/festival_model.dart';

class ProfileService {
  static const Duration _requestTimeout = Duration(seconds: 20);

  // ──────────────────────────────────────────────────────────────────────────
  // NETWORK HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  Future<http.Response> _getWithRetry(Uri uri, {required Map<String, String> headers}) async {
    int retryCount = 0;
    const maxRetries = 2;
    while (true) {
      try {
        final h = Map<String, String>.from(headers);
        h.addAll({
          'Connection': 'close',
          'User-Agent': 'HammerApp/1.0.0',
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        });
        return await http.get(uri, headers: h).timeout(_requestTimeout);
      } catch (e) {
        if (retryCount < maxRetries && (e is SocketException || e is http.ClientException)) {
          retryCount++;
          await Future.delayed(Duration(seconds: retryCount));
          continue;
        }
        rethrow;
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SERVICE METHODS
  // ──────────────────────────────────────────────────────────────────────────

  Future<ProfileResponse> fetchProfile() async {
    final token = await SharedPrefsHelper.getToken();
    final response = await _getWithRetry(Uri.parse(ApiConstants.profile), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      await SharedPrefsHelper.saveCachedProfileResponse(decoded);
      return ProfileResponse.fromJson(decoded);
    }
    throw Exception('Failed to load profile (${response.statusCode})');
  }

  Future<GeneralProfile> fetchGeneralProfile() async {
    final token = await SharedPrefsHelper.getToken();
    final response = await _getWithRetry(Uri.parse(ApiConstants.generalProfile), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return GeneralProfile.fromJson(decoded['data'] ?? {});
    }
    throw Exception('Failed to load general profile');
  }

  /// PATCH /api/technician/general_profile (Final Sync Fix: POST with PATCH Override)
  Future<GeneralProfile> updateGeneralProfile({
    required Map<String, dynamic> fields,
    Map<String, File>? files,
  }) async {
    final token = await SharedPrefsHelper.getToken();
    if (token == null) throw Exception('Missing auth token');

    final hasFiles = files != null && files.isNotEmpty;
    http.Response response;

    if (!hasFiles) {
      // 1. JSON POST with PATCH Override (Safe for Native Booleans)
      // Sending raw booleans (true/false) as requested by the validator
      response = await http.post(
        Uri.parse(ApiConstants.generalProfile),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-HTTP-Method-Override': 'PATCH',
        },
        body: jsonEncode(fields),
      ).timeout(_requestTimeout);
    } else {
      // 2. MULTIPART POST with PATCH Override
      final request = http.MultipartRequest('POST', Uri.parse(ApiConstants.generalProfile));
      request.headers.addAll({
        'Authorization': 'Bearer $token', 
        'Accept': 'application/json', 
        'X-HTTP-Method-Override': 'PATCH'
      });

      // Add text fields as strings "1"/"0" for booleans
      fields.forEach((key, value) {
        if (value is bool) {
          request.fields[key] = value ? "1" : "0";
        } else if (value is List) {
          for (var item in value) {
            request.fields['$key[]'] = item.toString();
          }
        } else {
          request.fields[key] = value.toString();
        }
      });

      // Add files using their native keys from the edit sheet
      for (final e in files.entries) {
        request.files.add(await http.MultipartFile.fromPath(e.key, e.value.path));
      }
      response = await http.Response.fromStream(await request.send());
    }

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return GeneralProfile.fromJson(decoded['data'] ?? {});
    }
    
    throw Exception(_parseError(response));
  }

  String _parseError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        return (data['errors'] as Map).values.map((v) => (v is List) ? v.join(',') : v).join('|');
      }
      return data['message'] ?? 'Update failed (${response.statusCode})';
    } catch (_) {
      return 'Update failed';
    }
  }

  Future<List<Festival>> fetchFestivals() async {
    try {
      final response = await http.get(Uri.parse('https://hammerapp.in/festival.json')).timeout(_requestTimeout);
      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        return decoded.map((f) => Festival.fromJson(f)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
