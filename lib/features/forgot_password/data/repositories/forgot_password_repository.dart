import '../services/forgot_password_service.dart';
import '../models/send_otp_response.dart';
import '../models/verify_otp_response.dart';
import '../models/reset_password_response.dart';

class ForgotPasswordRepository {
  final ForgotPasswordService service;

  ForgotPasswordRepository(this.service);

  Future<SendOtpResponse> sendOtp(String mobile) async {
    final data = await service.sendOtp(mobile);
    return SendOtpResponse.fromJson(data);
  }

  Future<VerifyOtpResponse> verifyOtp(String mobile, String otp) async {
    final data = await service.verifyOtp(mobile, otp);
    return VerifyOtpResponse.fromJson(data);
  }

  Future<ResetPasswordResponse> resetPassword(
    String resetToken,
    String password,
    String passwordConfirmation,
  ) async {
    final data = await service.resetPassword(
      resetToken,
      password,
      passwordConfirmation,
    );
    return ResetPasswordResponse.fromJson(data);
  }
}

