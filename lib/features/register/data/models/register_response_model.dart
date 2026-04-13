import 'package:hammer_app/core/config/app_config.dart';

class RegisterResponse {
  final bool success;
  final String message;
  final RegisterData? data;
  final Map<String, List<String>>? errors;
  /// True when OTP was sent on create. When true, [token] is usually present.
  final bool otpSent;
  /// Session token for subsequent API calls (Bearer). Present when OTP was sent.
  final String? token;

  RegisterResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.otpSent = false,
    this.token,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? RegisterData.fromJson(
              json['data'] as Map<String, dynamic>,
              AppType.technician,
            )
          : null,
      errors: json['errors'] != null
          ? (json['errors'] as Map<String, dynamic>).map(
              (key, value) =>
                  MapEntry(key, List<String>.from(value as List)),
            )
          : null,
      otpSent: json['otp_sent'] == true,
      token: json['token'] as String?,
    );
  }
}

class RegisterData {
  final int id;
  final String name;
  final String mobile;
  final String email;
  final bool mobileVerified;

  RegisterData({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.mobileVerified,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json, AppType appType) {
    return RegisterData(
      id: json['id'] as int,
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      mobileVerified: json['mobile_verified'] ?? false,
    );
  }
}
