import 'service_model.dart';

class SubCategoryModel {
  final int id;
  final String name;
  final String image;
  final List<ServiceModel> services;

  SubCategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.services,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      services: (json['services'] as List? ?? [])
          .map((e) => ServiceModel.fromJson(e))
          .toList(),
    );
  }
}