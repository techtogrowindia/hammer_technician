import 'dart:io';

import '../models/general_profile_model.dart';
import '../models/profile_response_model.dart';
import '../models/festival_model.dart';
import '../services/profile_service.dart';

class ProfileRepository {
  final ProfileService service;

  ProfileRepository(this.service);

  Future<ProfileResponse> getProfile() {
    return service.fetchProfile();
  }

  Future<GeneralProfile> getGeneralProfile() {
    return service.fetchGeneralProfile();
  }

  Future<GeneralProfile> updateGeneralProfile({
    required Map<String, dynamic> fields,
    Map<String, File>? files,
  }) {
    return service.updateGeneralProfile(fields: fields, files: files);
  }

  Future<List<Festival>> getFestivals() {
    return service.fetchFestivals();
  }
}
