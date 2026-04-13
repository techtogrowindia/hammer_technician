import 'dart:convert';
import 'package:hammer_app/core/config/api_constants.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';

class ServiceApi {
  Future<List<CategoryModel>> getServices() async {
    final uri = Uri.parse(ApiConstants.service);

    final token = await SharedPrefsHelper.getToken();
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',

        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List data = decoded['data'];

      return data.map((e) => CategoryModel.fromJson(e)).toList();
    } else {
      throw Exception('Unable to fetch services');
    }
  }
}
