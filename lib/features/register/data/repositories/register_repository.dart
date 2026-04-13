
import 'package:hammer_app/features/register/data/models/register_request_model.dart';
import 'package:hammer_app/features/register/data/models/register_response_model.dart';
import 'package:hammer_app/features/register/data/serivces/register_service.dart';


class RegisterRepository {
  final RegisterService service;

  RegisterRepository(this.service);

  Future<RegisterResponse> register(RegisterRequest request) async {
    return await service.register(request);
  }
}

