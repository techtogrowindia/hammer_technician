import 'dart:convert';
import 'package:hammer_app/core/config/api_constants.dart';
import 'package:hammer_app/features/logout/logout_service.dart';
import 'package:http/http.dart' as http;

class DeleteAccountService {
  static Future<bool> deleteTechnicianAccount(int technicianId) async {
    final url = Uri.parse(ApiConstants.deleteAccount);

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer ${ApiConstants.companyApiBearerToken}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'technician_id': technicianId,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // Automatically logout from local session if deletion was successful
        await LogoutService.logout();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
