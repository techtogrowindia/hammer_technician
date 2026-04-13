

import 'package:hammer_app/features/login/data/models/login_request_model.dart';
import 'package:hammer_app/features/login/data/models/login_response_model.dart';
import 'package:hammer_app/features/login/data/serivces/login_service.dart';
class LoginRepository {
  final LoginService service;

  LoginRepository(this.service);

  Future<LoginResponse> login(LoginRequest request) {
    return service.login(request);
  }
}