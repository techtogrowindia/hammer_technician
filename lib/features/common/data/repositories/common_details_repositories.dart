import '../models/common_details_model.dart';
import '../services/common_detail_service.dart';

class CommonDetailsRepository {
  final CommonDetailsService service;

  CommonDetailsRepository({required this.service});

  Future<CommonDetailsModel> fetchCommonDetails() {
    return service.getCommonDetails();
  }
}
