import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/services/dynamic_content_service.dart';
import 'dynamic_content_state.dart';

class DynamicContentCubit extends Cubit<DynamicContentState> {
  final DynamicContentService service;

  DynamicContentCubit({required this.service}) : super(DynamicContentInitial());

  Future<void> fetchDynamicContent() async {
    emit(DynamicContentLoading());
    try {
      final model = await service.getDynamicContent();
      emit(DynamicContentLoaded(model));
    } catch (e) {
      emit(DynamicContentError(e.toString()));
    }
  }
}
