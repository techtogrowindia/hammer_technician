import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hammer_app/features/otp/data/repositories/mobile_otp_repository.dart';
import 'mobile_otp_state.dart';

class MobileOtpCubit extends Cubit<MobileOtpState> {
  final MobileOtpRepository repository;

  MobileOtpCubit(this.repository) : super(MobileOtpInitial());

  Future<void> sendOtp() async {
    try {
      emit(MobileOtpLoading());
      final msg = await repository.sendOtp();
      emit(MobileOtpSent(msg));
    } catch (e) {
      emit(MobileOtpFailure(e.toString()));
    }
  }

  Future<void> resendOtp() async {
    try {
      emit(MobileOtpLoading());
      final msg = await repository.resendOtp();
      emit(MobileOtpSent(msg));
    } catch (e) {
      emit(MobileOtpFailure(e.toString()));
    }
  }

  Future<void> verifyOtp(String otp) async {
    emit(MobileOtpLoading());
    try {
      final response = await repository.verifyOtp(otp);

      emit(MobileOtpVerified(response));
    } catch (e) {
      emit(MobileOtpFailure(e.toString()));
    }
  }
}
