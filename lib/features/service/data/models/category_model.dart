import 'subcategory_model.dart';

class CategoryModel {
  final int id;
  final String name;
  final String image;
  final List<SubCategoryModel> subcategories;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.subcategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      subcategories: (json['subcategories'] as List? ?? [])
          .map((e) => SubCategoryModel.fromJson(e))
          .toList(),
    );
  }
}