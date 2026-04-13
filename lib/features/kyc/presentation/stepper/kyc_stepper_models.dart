import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

/// Existing document from API (already uploaded).
class ExistingDocument {
  final String filename;
  final String url;

  ExistingDocument({required this.filename, required this.url});
}

/// Service option for dropdown.
class ServiceDropdownModel {
  final int id;
  final int? categoryId;
  final String categoryName;
  final String subcategoryName;
  final String serviceName;
  final bool hasCertificate;

  ServiceDropdownModel({
    required this.id,
    this.categoryId,
    required this.categoryName,
    required this.subcategoryName,
    required this.serviceName,
    required this.hasCertificate,
  });
}

/// Selected service with experience/certificate inputs.
class SelectedServiceData {
  final int serviceId;
  final String serviceName;
  final bool hasCertificate;

  final TextEditingController experienceController = TextEditingController();
  final TextEditingController certificateNumberController =
      TextEditingController();

  SelectedServiceData({
    required this.serviceId,
    required this.serviceName,
    required this.hasCertificate,
  });

  /// Fallback conversion for when no matching dropdown model exists.
  ServiceDropdownModel toDropdownModel() {
    return ServiceDropdownModel(
      id: serviceId,
      categoryName: '',
      subcategoryName: '',
      serviceName: serviceName,
      hasCertificate: hasCertificate,
    );
  }
}

class SelectedCategoryData {
  final int id;
  final String name;
  final TextEditingController experienceController = TextEditingController();

  SelectedCategoryData({required this.id, required this.name});
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
