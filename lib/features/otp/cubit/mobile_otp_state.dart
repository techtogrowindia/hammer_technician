import 'package:equatable/equatable.dart';
import 'package:hammer_app/features/otp/data/models/verify_otp_response_model.dart';

abstract class MobileOtpState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MobileOtpInitial extends MobileOtpState {}

class MobileOtpLoading extends MobileOtpState {}

class MobileOtpSent extends MobileOtpState {
  final String message;
  MobileOtpSent(this.message);

  @override
  List<Object?> get props => [message];
}

class MobileOtpVerified extends MobileOtpState {
    final OtpVerifyResponse response;
    MobileOtpVerified(this.response);
  
}

class MobileOtpFailure extends MobileOtpState {
  final String message;
  MobileOtpFailure(this.message);

  @override
  List<Object?> get props => [message];
}
