import '../data/models/profile_response_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileResponse response;

  ProfileLoaded(this.response);

  UserProfile get profile => response.data;
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
