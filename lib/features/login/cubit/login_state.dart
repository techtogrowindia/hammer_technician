
import 'package:hammer_app/features/login/data/models/login_response_model.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final LoginResponse response;

  LoginSuccess(this.response);
}

class LoginFailure extends LoginState {
  final String message;

  LoginFailure(this.message);
}
