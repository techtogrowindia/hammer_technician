// cubit/common_details_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/common_details_repositories.dart';
import 'common_details_state.dart';

class CommonDetailsCubit extends Cubit<CommonDetailsState> {
  final CommonDetailsRepository repository;

  CommonDetailsCubit({required this.repository}) : super(CommonDetailsInitial());

  Future<void> getCommonDetails() async {
    emit(CommonDetailsLoading());
    try {
      final details = await repository.fetchCommonDetails();
      emit(CommonDetailsLoaded(details));
    } catch (e) {
      emit(CommonDetailsError(e.toString()));
    }
  }
}
