import '../models/category_model.dart';
import '../services/service_api.dart';

class ServiceRepository {
  final ServiceApi _api = ServiceApi();

  Future<List<CategoryModel>> fetchServices() {
    return _api.getServices();
  }
}
