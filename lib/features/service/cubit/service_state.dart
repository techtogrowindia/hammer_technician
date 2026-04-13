import '../data/models/category_model.dart';

abstract class ServiceState {}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}

class ServiceLoaded extends ServiceState {
  final List<CategoryModel> categories;

  ServiceLoaded(this.categories);
}

class ServiceError extends ServiceState {
  final String message;

  ServiceError(this.message);
}
