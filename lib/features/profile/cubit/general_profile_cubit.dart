import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/profile_repository.dart';
import '../data/models/festival_model.dart';
import 'general_profile_state.dart';

class GeneralProfileCubit extends Cubit<GeneralProfileState> {
  final ProfileRepository repository;

  GeneralProfileCubit(this.repository) : super(GeneralProfileInitial());

  Future<void> loadGeneralProfile() async {
    emit(GeneralProfileLoading());
    try {
      final profile = await repository.getGeneralProfile();
      final festivals = await repository.getFestivals();
      emit(GeneralProfileLoaded(profile, festivals: festivals));
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
