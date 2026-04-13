import 'package:hammer_app/features/otp/data/models/verify_otp_response_model.dart';
import 'package:hammer_app/features/otp/data/serivces/mobile_otp_service.dart';

class MobileOtpRepository {
  final MobileOtpService service;

  MobileOtpRepository(this.service);

  Future<String> sendOtp() => service.sendOtp();

  Future<String> resendOtp() => service.resendOtp();

  Future<OtpVerifyResponse> verifyOtp(String otp) =>
      service.verifyOtp(otp);
}
