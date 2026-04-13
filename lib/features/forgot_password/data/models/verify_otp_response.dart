class VerifyOtpResponse {
  final bool success;
  final String message;
  final String resetToken;

  VerifyOtpResponse({
    required this.success,
    required this.message,
    required this.resetToken,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      resetToken: json['token'] ?? json['data']?['reset_token'] ?? '',
    );
  }
}
