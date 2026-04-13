import '../data/models/general_profile_model.dart';
import '../data/models/festival_model.dart';

abstract class GeneralProfileState {}

class GeneralProfileInitial extends GeneralProfileState {}

class GeneralProfileLoading extends GeneralProfileState {}

class GeneralProfileLoaded extends GeneralProfileState {
  final GeneralProfile profile;
  final List<Festival> festivals;
  GeneralProfileLoaded(this.profile, {this.festivals = const []});
}

class GeneralProfileUpdating extends GeneralProfileState {
  final GeneralProfile profile;
  final List<Festival> festivals;
  GeneralProfileUpdating(this.profile, {this.festivals = const []});
}

class GeneralProfileError extends GeneralProfileState {
  final String message;
  GeneralProfileError(this.message);
}
