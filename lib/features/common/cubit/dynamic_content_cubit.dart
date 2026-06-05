import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/services/dynamic_content_service.dart';
import '../data/models/dynamic_content_model.dart';
import 'dynamic_content_state.dart';

class DynamicContentCubit extends Cubit<DynamicContentState> {
  final DynamicContentService service;

  DynamicContentCubit({required this.service}) : super(DynamicContentInitial());

  Future<void> fetchDynamicContent() async {
    DynamicContentData? existing = state is DynamicContentLoaded
        ? (state as DynamicContentLoaded).model.data
        : null;

    try {
      final positiveMessage = await service.getPositiveMessage();
      debugPrint('[DynamicCubit] positiveMessage from API: $positiveMessage');
      
      DynamicContentData? fromApi;
      try {
        final dynamic = await service.getDynamicContent();
        fromApi = dynamic.data;
        debugPrint('[DynamicCubit] fromApi positiveMessage: ${fromApi?.positiveMessage}');
      } catch (_) {}

      final finalMsg = positiveMessage ??
          fromApi?.positiveMessage ??
          existing?.positiveMessage;
      debugPrint('[DynamicCubit] FINAL positiveMessage emitted: $finalMsg');

      emit(
        DynamicContentLoaded(
          DynamicContentModel(
            success: true,
            message: 'Success',
            data: DynamicContentData(
              otpScreenGif: fromApi?.otpScreenGif ?? existing?.otpScreenGif,
              positiveMessage: finalMsg,
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('[DynamicCubit] ERROR in fetchDynamicContent: $e');
      if (existing != null) {
        emit(
          DynamicContentLoaded(
            DynamicContentModel(
              success: true,
              message: 'Success',
              data: existing,
            ),
          ),
        );
      } else {
        emit(DynamicContentError(e.toString()));
      }
    }
  }
}
