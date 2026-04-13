import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';
import 'package:hammer_app/features/register/data/models/register_request_model.dart';
import 'package:hammer_app/features/register/data/models/register_response_model.dart';
import 'package:hammer_app/features/register/data/repositories/register_repository.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterRepository repository;

  RegisterCubit(this.repository) : super(RegisterInitial());

  Future<void> submit(RegisterRequest request) async {
    emit(RegisterLoading());

    try {
      final RegisterResponse response = await repository.register(request);

      if (response.success) {
        if (response.token != null && response.token!.isNotEmpty) {
          await SharedPrefsHelper.saveToken(response.token!);
        }
        emit(RegisterSuccess(response));
      } else {
        final errorMessage = response.errors != null
            ? response.errors!.values
                .expand((list) => list)
                .join('\n')
            : response.message;

        emit(RegisterFailure(errorMessage));
      }
    } on SocketException {
      emit(RegisterFailure("No internet connection"));
    } on FormatException {
      emit(RegisterFailure("Invalid server response"));
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '').trim();
      emit(RegisterFailure(message.isEmpty ? "Unable to register now" : message));
    }
  }
}
