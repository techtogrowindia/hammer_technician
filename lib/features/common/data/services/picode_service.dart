import 'dart:convert';
import 'package:hammer_app/core/config/api_constants.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';
import 'package:http/http.dart' as http;

class PincodeResponse {
  final bool success;
  final String message;
  final Map<String, String>? data;

  PincodeResponse({
    required this.success,
    required this.message,
    this.data,
  });
}

class PincodeService {
  /// Fetches district, taluk, city from hammerapp.in locations-list API.
  static Future<PincodeResponse> getLocation(String pincode) async {
    try {
      final sessionToken = await SharedPrefsHelper.getToken();
      final token = (sessionToken != null && sessionToken.isNotEmpty) 
          ? sessionToken 
          : ApiConstants.preAuthBearerToken;

      final res = await http.get(
        Uri.parse(ApiConstants.locationsList(pincode)),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Connection': 'close',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      final body = res.body.trim();
      final isHtml = body.startsWith('<!DOCTYPE') ||
          (res.headers['content-type']?.contains('text/html') ?? false);
      
      if (isHtml) {
        return PincodeResponse(
          success: false, 
          message: 'Server format error. Please try again.', 
          data: null
        );
      }

      if (res.statusCode != 200) {
         return PincodeResponse(
          success: false, 
          message: 'Server error (${res.statusCode})', 
          data: null
        );
      }

      final data = jsonDecode(body) as Map<String, dynamic>;
      final bool success = data['success'] == true;
      final String message = data['message'] ?? 'Location not found';

      final result = data['data'];
      if (result == null) {
        return PincodeResponse(success: false, message: message, data: null);
      }

      Map<String, dynamic>? first;
      if (result is Map<String, dynamic>) {
        first = result;
      } else if (result is List && result.isNotEmpty) {
        first = result[0] as Map<String, dynamic>?;
      }

      if (first != null) {
        final district = (first['district'] ?? first['district_name'])?.toString();
        final taluk = (first['taluk_name'] ?? first['taluk'])?.toString();
        final city = (first['village_town_city_name'] ??
                first['village_town_city'] ??
                first['city'] ??
                first['location'])
            ?.toString();

        if (district != null || taluk != null || city != null) {
          return PincodeResponse(
            success: true,
            message: message,
            data: {
              'district': district ?? '',
              'taluk_name': taluk ?? '',
              'village_town_city_name': city ?? '',
            },
          );
        }
      }
      
      return PincodeResponse(success: false, message: 'Invalid data received', data: null);
    } catch (e) {
      if (e is FormatException) {
        return PincodeResponse(success: false, message: 'Invalid response format', data: null);
      }
      return PincodeResponse(success: false, message: 'Connection issue: $e', data: null);
    }
  }
}
