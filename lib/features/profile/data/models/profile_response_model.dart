class ProfileResponse {
  final bool success;
  final String message;
  final UserProfile data;

  ProfileResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'] == true,
      message: json['message'] ?? '',
      data: UserProfile.fromJson(json['data'] ?? {}),
    );
  }
}

class UserProfile {
  final int? id;
  final String? uniqueId;
  final String? name;
  final String? mobile;
  final String? email;
  final bool mobileVerified;
  final String accountStatus;
  final String kycStatus;
  final KycSteps? kycSteps;
  final String initialDeposit;
  final int initialDepositAmount;
  final String? bloodGroup;
  final Map<String, String?>? documentKycUrls;

  UserProfile({
    this.id,
    this.uniqueId,
    this.name,
    this.mobile,
    this.email,
    required this.accountStatus,
    required this.mobileVerified,
    required this.kycStatus,
    this.kycSteps,
    required this.initialDeposit,
    required this.initialDepositAmount,
    this.bloodGroup,
    this.documentKycUrls,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      uniqueId: json['unique_id'],
      name: json['name'],
      mobile: json['mobile'],
      email: json['email'],
      mobileVerified: json['mobile_verified'] == true,
      accountStatus: json['account_status'] ?? 'inactive',
      kycStatus: json['kyc_status'] ?? 'not_started',
      kycSteps: json['kyc_steps'] != null
          ? KycSteps.fromJson(json['kyc_steps'], json)
          : null,
      initialDeposit: json['initial_deposit'] ?? 'not_paid',
      initialDepositAmount: json['initial_deposit_amount'] ?? 0,
      bloodGroup: json['blood_group'],
      documentKycUrls: json['document_kyc_urls'] != null
          ? Map<String, String?>.from(json['document_kyc_urls'])
          : null,
    );
  }
}

class KycSteps {
  final KycStep? profileKyc;
  final KycStep? servicesKyc;
  final KycStep? bankKyc;
  final KycStep? companyKyc;
  final KycStep? documentKyc;
  final KycStep? educationKyc;

  KycSteps({
    this.profileKyc,
    this.servicesKyc,
    this.bankKyc,
    this.companyKyc,
    this.documentKyc,
    this.educationKyc,
  });

  factory KycSteps.fromJson(Map<String, dynamic> json, [Map<String, dynamic>? rootJson]) {
    // Support both old 'services_kyc' and new 'technician_services' keys
    final servicesJson = json['technician_services'] ?? json['services_kyc'];
    
    // Search for education status (very robust search)
    dynamic foundEdu;
    final searchKeys = ['edu', 'qualification', 'academic', 'passed_out'];
    
    void findEdu(Map<String, dynamic> map) {
      for (var entry in map.entries) {
        if (searchKeys.any((s) => entry.key.toLowerCase().contains(s))) {
          if (entry.value != null) {
            foundEdu = entry.value;
            return;
          }
        }
        if (entry.value is Map<String, dynamic>) {
          findEdu(entry.value as Map<String, dynamic>);
          if (foundEdu != null) return;
        }
      }
    }

    findEdu(json);
    if (foundEdu == null && rootJson != null) findEdu(rootJson);

    final eduJson = foundEdu ?? 
                    json['educational_qualification'] ?? 
                    json['edu_qualification'] ?? 
                    rootJson?['educational_qualification'] ?? 
                    rootJson?['profile_kyc']?['educational_qualification'] ??
                    rootJson?['personal_kyc']?['educational_qualification'];

    return KycSteps(
      profileKyc: json['profile_kyc'] != null
          ? KycStep.fromJson(json['profile_kyc'])
          : null,
      servicesKyc: servicesJson != null
          ? KycStep.fromJson(servicesJson)
          : null,
      bankKyc: json['bank_kyc'] != null
          ? KycStep.fromJson(json['bank_kyc'])
          : null,
      companyKyc: json['company_kyc'] != null
          ? KycStep.fromJson(json['company_kyc'])
          : null,
      documentKyc: json['document_kyc'] != null
          ? KycStep.fromJson(json['document_kyc'])
          : null,
      educationKyc: eduJson != null
          ? KycStep.fromJson(eduJson)
          : null,
    );
  }
}

class KycStep {
  final String? status;
  final String? remark;

  KycStep({this.status, this.remark});

  factory KycStep.fromJson(dynamic json) {
    if (json is String) {
      return KycStep(status: json);
    }
    if (json is Map<String, dynamic>) {
      return KycStep(status: json['status'], remark: json['remark']);
    }
    return KycStep();
  }
}
