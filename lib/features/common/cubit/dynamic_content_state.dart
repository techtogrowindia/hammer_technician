import '../data/models/dynamic_content_model.dart';

abstract class DynamicContentState {}

class DynamicContentInitial extends DynamicContentState {}

class DynamicContentLoading extends DynamicContentState {}

class DynamicContentLoaded extends DynamicContentState {
  final DynamicContentModel model;

  DynamicContentLoaded(this.model);
}

class DynamicContentError extends DynamicContentState {
  final String message;

  DynamicContentError(this.message);
}
