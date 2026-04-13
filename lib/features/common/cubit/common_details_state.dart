// cubit/common_details_state.dart
import 'package:equatable/equatable.dart';
import '../data/models/common_details_model.dart';

abstract class CommonDetailsState extends Equatable {
  const CommonDetailsState();

  @override
  List<Object?> get props => [];
}

class CommonDetailsInitial extends CommonDetailsState {}

class CommonDetailsLoading extends CommonDetailsState {}

class CommonDetailsLoaded extends CommonDetailsState {
  final CommonDetailsModel details;

  const CommonDetailsLoaded(this.details);

  @override
  List<Object?> get props => [details];
}

class CommonDetailsError extends CommonDetailsState {
  final String message;

  const CommonDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
