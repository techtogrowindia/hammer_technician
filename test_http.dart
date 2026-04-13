import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hammer_app/core/config/api_constants.dart';

void main() async {
  final url = Uri.parse('https://hammerapp.in/api/technician/login');
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer 12345678',
        'User-Agent': 'Dalvik/2.1.0 (Linux; U; Android 13; I2219 Build/TP1A.220624.014)',
      },
      body: jsonEncode({'mobile': '1234567890', 'password': '123'}),
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}
