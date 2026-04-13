class Festival {
  final String name;
  final String? type;
  final String? description;
  final String? month;

  Festival({
    required this.name,
    this.type,
    this.description,
    this.month,
  });

  factory Festival.fromJson(Map<String, dynamic> json) {
    return Festival(
      name: json['name'] ?? '',
      type: json['type'],
      description: json['description'],
      month: json['month'],
    );
  }
}
