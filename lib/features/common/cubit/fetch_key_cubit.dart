import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/services/fetch_key_service.dart';
import 'fetch_key_state.dart';

class FetchKeyCubit extends Cubit<FetchKeyState> {
  final FetchKeyService service;

  FetchKeyCubit(this.service) : super(FetchKeyInitial());

  Future<void> fetchKey() async {
    emit(FetchKeyLoading());
    try {
      final resp = await service.fetchKey();
      final data = resp['data'] as Map<String, dynamic>? ?? {};
      final amountStr =
          data['technician_onboarding_charges']?.toString() ?? '0';
      final amount = int.tryParse(amountStr) ?? 0;
      final razorKey = data['razorpay_key']?.toString() ?? '';

      emit(FetchKeyLoaded(
        amount: amount,
        razorpayKey: razorKey,
      ));
    } catch (e) {
      emit(FetchKeyError(e.toString()));
    }
  }
}
