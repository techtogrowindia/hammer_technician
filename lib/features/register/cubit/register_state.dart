import 'package:hammer_app/features/register/data/models/register_response_model.dart';

abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  RegisterResponse response;
  RegisterSuccess(this.response);
}

class RegisterFailure extends RegisterState {
  final String message;

  RegisterFailure(this.message);
}
