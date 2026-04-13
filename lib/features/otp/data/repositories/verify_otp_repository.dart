import 'package:hammer_app/features/otp/data/models/verify_otp_response_model.dart';
import 'package:hammer_app/features/otp/data/serivces/verify_otp_service.dart';

class OtpRepository {
  final OtpService otpService;

  OtpRepository(this.otpService);

  Future<OtpVerifyResponse> verifyOtp({required String otp}) {
    return otpService.verifyOtp(otp: otp);
  }
}
