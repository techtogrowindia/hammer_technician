import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/profile_repository.dart';
import '../data/models/festival_model.dart';
import '../data/models/general_profile_model.dart';
import 'general_profile_state.dart';

class GeneralProfileCubit extends Cubit<GeneralProfileState> {
  final ProfileRepository repository;

  GeneralProfileCubit(this.repository) : super(GeneralProfileInitial());

  Future<void> loadGeneralProfile() async {
    emit(GeneralProfileLoading());
    try {
      final results = await Future.wait([
        repository.getGeneralProfile(),
        repository.getFestivals(),
      ]);
      emit(GeneralProfileLoaded(
        results[0] as GeneralProfile,
        festivals: results[1] as List<Festival>,
      ));
    } catch (e) {
      emit(GeneralProfileError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> updateGeneralProfile({
    required Map<String, dynamic> fields,
    Map<String, File>? files,
  }) async {
    final currentState = state;
    final currentProfile = currentState is GeneralProfileLoaded
        ? currentState.profile
        : (currentState is GeneralProfileUpdating ? currentState.profile : null);
    
    final currentFestivals = currentState is GeneralProfileLoaded
        ? currentState.festivals
        : (currentState is GeneralProfileUpdating ? currentState.festivals : <Festival>[]);

    if (currentProfile != null) {
      emit(GeneralProfileUpdating(currentProfile, festivals: currentFestivals));
    }

    try {
      final updated = await repository.updateGeneralProfile(
        fields: fields,
        files: files,
      );
      emit(GeneralProfileLoaded(updated, festivals: currentFestivals));
    } catch (e) {
      if (currentProfile != null) {
        emit(GeneralProfileLoaded(currentProfile, festivals: currentFestivals));
      } else {
        emit(GeneralProfileError(e.toString().replaceFirst('Exception: ', '')));
      }
      rethrow;
    }
  }
}
