class TeamMember {
  final dynamic id;
  final String name;
  final String mobile;
  final String aadharNumber;
  final Map<String, dynamic>? parentTechnician;
  final String? createdAt;
  final String? updatedAt;

  TeamMember({
    this.id,
    required this.name,
    required this.mobile,
    required this.aadharNumber,
    this.parentTechnician,
    this.createdAt,
    this.updatedAt,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    // Standardizing fields from API structure
    final rawAadhar = json['aadhar_number'] ?? json['aadhar'] ?? '';

    return TeamMember(
      id: json['id'],
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      aadharNumber: rawAadhar.toString(),
      parentTechnician: json['parent_technician'] is Map<String, dynamic>
          ? json['parent_technician'] as Map<String, dynamic>
          : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'mobile': mobile,
      'aadhar_number': aadharNumber,
      'parent_technician': parentTechnician,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }
}
