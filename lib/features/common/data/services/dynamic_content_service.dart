import 'dart:convert';
import 'package:hammer_app/core/config/api_constants.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';
import 'package:http/http.dart' as http;
import '../models/dynamic_content_model.dart';

class DynamicContentService {
  final http.Client client;

  DynamicContentService({http.Client? client}) : client = client ?? http.Client();

  Future<DynamicContentModel> getDynamicContent() async {
    final token = await SharedPrefsHelper.getToken();
    final url = Uri.parse(ApiConstants.dynamicContent);

    final response = await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return DynamicContentModel.fromJson(jsonBody);
    } else {
      throw Exception('Failed to load dynamic content (${response.statusCode})');
    }
  }
}
