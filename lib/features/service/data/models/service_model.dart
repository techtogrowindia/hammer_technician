

class ServiceModel {
  final int id;
  final String serviceName;
  final String image;
  final int taxPercentage;
  final int technicianActivationCharges;
  final List<CertificateModel> certificates; // 👈 ADD THIS

  ServiceModel({
    required this.id,
    required this.serviceName,
    required this.image,
    required this.taxPercentage,
    required this.technicianActivationCharges,
    required this.certificates,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      serviceName: json['service_name'] ?? '',
      image: json['image'] ?? '',
      taxPercentage: json['tax_percentage'] ?? 0,
      technicianActivationCharges: json['technician_activation_charges'] ?? 0,
      certificates: (json['certificates'] as List? ?? [])
          .map((e) => CertificateModel.fromJson(e))
          .toList(),
    );
  }
}

class CertificateModel {
  final int id;
  final String name;
  final String image;

  CertificateModel({
    required this.id,
    required this.name,
    required this.image,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}