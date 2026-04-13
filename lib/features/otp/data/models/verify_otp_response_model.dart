import 'package:hammer_app/core/config/app_config.dart';

class OtpVerifyResponse {
  final bool success;
  final String message;
  final OtpVerifyData? data;

  OtpVerifyResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory OtpVerifyResponse.fromJson(Map<String, dynamic> json) {
    return OtpVerifyResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? OtpVerifyData.fromJson(
              json['data'] as Map<String, dynamic>,
              AppType.technician,
            )
          : null,
    );
  }
}

/// User info returned after verify-otp (no token; token was from create).
class OtpVerifyData {
  final int id;
  final String name;
  final String email;
  final String mobile;
  final bool mobileVerified;

  OtpVerifyData({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.mobileVerified,
  });

  factory OtpVerifyData.fromJson(
    Map<String, dynamic> json,
    AppType appType,
  ) {
    return OtpVerifyData(
      id: json['id'] as int,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      mobileVerified: json['mobile_verified'] ?? false,
    );
  }
}
