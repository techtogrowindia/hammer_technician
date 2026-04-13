
import 'package:hammer_app/features/otp/data/models/verify_otp_response_model.dart';

abstract class OtpState {}

class OtpInitial extends OtpState {}

class OtpLoading extends OtpState {}

class OtpSuccess extends OtpState {
  final OtpVerifyResponse response;

  OtpSuccess(this.response);
}

class OtpFailure extends OtpState {
  final String error;

  OtpFailure(this.error);
}
