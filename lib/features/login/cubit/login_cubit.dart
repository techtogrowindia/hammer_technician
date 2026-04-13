import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';
import 'package:hammer_app/features/login/data/models/login_request_model.dart';
import 'package:hammer_app/features/login/data/models/login_response_model.dart';
import 'package:hammer_app/features/login/data/repositories/login_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepository repository;

  LoginCubit(this.repository) : super(LoginInitial());

  Future<void> submit(LoginRequest request) async {
    emit(LoginLoading());

    try {
      final LoginResponse response = await repository.login(request);

      if (response.success && response.data != null && response.token != null) {
        await SharedPrefsHelper.saveToken(response.token!);
        emit(LoginSuccess(response));
      } else {
        emit(LoginFailure(response.message));
      }
    } on SocketException {
      emit(LoginFailure("No internet connection"));
    } on FormatException {
      emit(LoginFailure("Invalid server response"));
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '').trim();
      emit(LoginFailure(message.isEmpty ? "Unable to login now" : message));
    }
  }
}
