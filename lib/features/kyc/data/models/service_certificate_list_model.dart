/// Model for GET /api/technician/service_certificates response.
/// API shape:
/// {
///   "success": true,
///   "data": {
///     "services": [
///       {
///         "service_id": 1,
///         "service_name": "New House Wiring",
///         "certificates": [
///           {
///             "certificate_id": 1,
///             "certificate_name": "Licensed Electrician",
///             "is_mandatory": true,
///             "uploaded": false,
///             "uploaded_details": null
///           }
///         ],
///         "missing_mandatory_count": 1
///       }
///     ],
///     "missing_mandatory_total": 3
///   }
/// }

class CertificateItem {
  final int certificateId;
  final String certificateName;
  final bool isMandatory;
  final bool uploaded;
  final Map<String, dynamic>? uploadedDetails;

  CertificateItem({
    required this.certificateId,
    required this.certificateName,
    required this.isMandatory,
    required this.uploaded,
    this.uploadedDetails,
  });

  factory CertificateItem.fromJson(Map<String, dynamic> json) {
    return CertificateItem(
      certificateId: json['certificate_id'] as int? ?? 0,
      certificateName: json['certificate_name'] as String? ?? '',
      isMandatory: json['is_mandatory'] as bool? ?? false,
      uploaded: json['uploaded'] as bool? ?? false,
      uploadedDetails: json['uploaded_details'] as Map<String, dynamic>?,
    );
  }
}

class ServiceWithCertificates {
  final int serviceId;
  final String serviceName;
  final bool anyoneMandatoryIsEnough;
  final String mandatoryPolicy;
  final List<CertificateItem> certificates;
  final int missingMandatoryCount;

  ServiceWithCertificates({
    required this.serviceId,
    required this.serviceName,
    required this.anyoneMandatoryIsEnough,
    required this.mandatoryPolicy,
    required this.certificates,
    required this.missingMandatoryCount,
  });

  factory ServiceWithCertificates.fromJson(Map<String, dynamic> json) {
    final certs = (json['certificates'] as List? ?? [])
        .map((c) => CertificateItem.fromJson(c as Map<String, dynamic>))
        .toList();
    return ServiceWithCertificates(
      serviceId: json['service_id'] as int? ?? 0,
      serviceName: json['service_name'] as String? ?? '',
      anyoneMandatoryIsEnough: json['anyone_mandatory_is_enough'] as bool? ?? false,
      mandatoryPolicy: json['mandatory_policy'] as String? ?? 'all',
      certificates: certs,
      missingMandatoryCount: json['missing_mandatory_count'] as int? ?? 0,
    );
  }

  List<CertificateItem> get mandatoryCertificates =>
      certificates.where((c) => c.isMandatory).toList();

  List<CertificateItem> get optionalCertificates =>
      certificates.where((c) => !c.isMandatory).toList();
}

class ServiceCertificateListResponse {
  final List<ServiceWithCertificates> services;
  final int missingMandatoryTotal;

  ServiceCertificateListResponse({
    required this.services,
    required this.missingMandatoryTotal,
  });

  factory ServiceCertificateListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final servicesList = (data['services'] as List? ?? [])
        .map((s) =>
            ServiceWithCertificates.fromJson(s as Map<String, dynamic>))
        .toList();

    return ServiceCertificateListResponse(
      services: servicesList,
      missingMandatoryTotal: data['missing_mandatory_total'] as int? ?? 0,
    );
  }

}
