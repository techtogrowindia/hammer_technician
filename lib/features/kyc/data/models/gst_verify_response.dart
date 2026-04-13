class GstVerifyResponse {
  final bool success;
  final bool isValid;
  final String? legalName;
  final String message;

  GstVerifyResponse({
    required this.success,
    required this.isValid,
    this.legalName,
    required this.message,
  });

  factory GstVerifyResponse.fromJson(Map<String, dynamic> json) {
    return GstVerifyResponse(
      success: json['success'],
      isValid: json['is_valid'],
      legalName: json['legal_name'],
      message: json['message'],
    );
  }
}
