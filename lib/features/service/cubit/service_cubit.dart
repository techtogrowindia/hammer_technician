import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/service_repository.dart';
import 'service_state.dart';

class ServiceCubit extends Cubit<ServiceState> {
  final ServiceRepository repository;

  ServiceCubit(this.repository) : super(ServiceInitial());

  Future<void> loadServices() async {
    emit(ServiceLoading());
    try {
      final services = await repository.fetchServices();
      emit(ServiceLoaded(services));
    } catch (e) {
      emit(ServiceError(e.toString()));
    }
  }
}
