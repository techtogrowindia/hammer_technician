import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hammer_app/features/otp/cubit/verify_otp_state.dart';
import 'package:hammer_app/features/otp/data/repositories/verify_otp_repository.dart';

class OtpCubit extends Cubit<OtpState> {
  final OtpRepository otpRepository;

  OtpCubit(this.otpRepository) : super(OtpInitial());

  Future<void> verifyOtp({required String otp}) async {
    emit(OtpLoading());
    try {
      final response = await otpRepository.verifyOtp(otp: otp);
      if (response.success) {
        emit(OtpSuccess(response));
      } else {
        emit(OtpFailure(response.message));
      }
    } catch (e) {
      emit(OtpFailure(e.toString()));
    }
  }
}
