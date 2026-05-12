import 'package:hammer_app/core/config/app_config.dart';

class LoginResponse {
  final bool success;
  final String message;
  final User? data;
  /// Session token for subsequent API calls (Bearer). Present on success.
  final String? token;

  LoginResponse({
    required this.success,
    required this.message,
    this.data,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? User.fromJson(
              json['data'] as Map<String, dynamic>,
              AppType.technician,
            )
          : null,
      token: json['token'] as String?,
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String mobile;
  final bool mobileVerified;
  final String accountStatus;
  final bool? emailVerified;
  final String? verificationStatus;
  final String? uniqueId;
  final String? kycStatus;
  final Map<String, dynamic>? kycSteps;
  final String? bloodGroup;
  final Map<String, dynamic>? documentKycUrls;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.mobileVerified,
    required this.accountStatus,
    this.emailVerified,
    this.verificationStatus,
    this.uniqueId,
    this.kycStatus,
    this.kycSteps,
    this.bloodGroup,
    this.documentKycUrls,
  });

  factory User.fromJson(Map<String, dynamic> json, AppType appType) {
    return User(
      id: json['id'] as int,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      mobileVerified: json['mobile_verified'] ?? false,
      accountStatus: json['account_status'] ?? 'inactive',
      emailVerified: json['email_verified'] as bool?,
      verificationStatus: json['verification_status'] as String?,
      uniqueId: json['unique_id'] as String?,
      kycStatus: json['kyc_status'] as String?,
      kycSteps: json['kyc_steps'] as Map<String, dynamic>?,
      bloodGroup: json['blood_group'] as String?,
      documentKycUrls: json['document_kyc_urls'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toProfileJson() {
    return {
      'id': id,
      'unique_id': uniqueId,
      'name': name,
      'mobile': mobile,
      'email': email,
      'mobile_verified': mobileVerified,
      'account_status': accountStatus,
      'kyc_status': kycStatus,
      'kyc_steps': kycSteps,
      'initial_deposit': 'not_paid',
      'initial_deposit_amount': 0,
      'blood_group': bloodGroup,
      'document_kyc_urls': documentKycUrls,
    };
  }
}
