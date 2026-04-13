// services/common_details_service.dart
import 'dart:convert';
import 'package:hammer_app/core/config/api_constants.dart';
import 'package:http/http.dart' as http;
import '../models/common_details_model.dart';

class CommonDetailsService {


  Future<CommonDetailsModel> getCommonDetails() async {
    final url = Uri.parse(ApiConstants.commonDetails); 
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return CommonDetailsModel.fromJson(jsonBody);
    } else {
      throw Exception('Failed to load common details');
    }
  }
}
