import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hammer_app/features/forgot_password/data/repositories/forgot_password_repository.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgotPasswordRepository repository;

  ForgotPasswordCubit(this.repository) : super(ForgotPasswordInitial());

  Future<void> sendOtp(String mobile) async {
    try {
      emit(ForgotPasswordLoading());
      final response = await repository.sendOtp(mobile);
      if (response.success) {
        emit(SendOtpSuccess(response.message));
      } else {
        emit(ForgotPasswordFailure(response.message));
      }
    } catch (e) {
      emit(ForgotPasswordFailure(e.toString()));
    }
  }

  Future<void> verifyOtp(String mobile, String otp) async {
    try {
      emit(ForgotPasswordLoading());
      final response = await repository.verifyOtp(mobile, otp);
      if (response.success) {
        emit(
          VerifyOtpSuccess(
            resetToken: response.resetToken,
            message: response.message,
          ),
        );
      } else {
        emit(ForgotPasswordFailure(response.message));
      }
    } catch (e) {
      emit(ForgotPasswordFailure(e.toString()));
    }
  }

  Future<void> resetPassword(
    String resetToken,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      emit(ForgotPasswordLoading());
      final response = await repository.resetPassword(
        resetToken,
        password,
        passwordConfirmation,
      );
      if (response.success) {
        emit(ResetPasswordSuccess(response.message));
      } else {
        emit(ForgotPasswordFailure(response.message));
      }
    } catch (e) {
      emit(ForgotPasswordFailure(e.toString()));
    }
  }
}
