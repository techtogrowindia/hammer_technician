class KycServiceModel {
  final int serviceId;
  final int? yearsOfExperience;
  final int? certificateId;
  final String? certificateNumber;

  KycServiceModel({
    required this.serviceId,
    this.yearsOfExperience,
    this.certificateId,
    this.certificateNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      if (yearsOfExperience != null)
        'years_of_experience': yearsOfExperience,
      if (certificateId != null)
        'certificate_id': certificateId,
      if (certificateNumber != null &&
          certificateNumber!.isNotEmpty)
        'certificate_number': certificateNumber,
    };
  }
}