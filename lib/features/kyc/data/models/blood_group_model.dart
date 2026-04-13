class BloodGroupModel {
  final int id;
  final String name;

  BloodGroupModel({required this.id, required this.name});

  factory BloodGroupModel.fromJson(Map<String, dynamic> json) {
    return BloodGroupModel(
      id: json['id'],
      name: json['name'],
    );
  }
}