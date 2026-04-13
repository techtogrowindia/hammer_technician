class DynamicContentModel {
  final bool success;
  final String message;
  final DynamicContentData? data;

  DynamicContentModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory DynamicContentModel.fromJson(Map<String, dynamic> json) {
    return DynamicContentModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? DynamicContentData.fromJson(json['data']) : null,
    );
  }
}

class DynamicContentData {
  final String? otpScreenGif;
  final String? positiveMessage;

  DynamicContentData({this.otpScreenGif, this.positiveMessage});

  factory DynamicContentData.fromJson(Map<String, dynamic> json) {
    return DynamicContentData(
      otpScreenGif: json['otp_screen_gif'],
      positiveMessage: json['positive_message'],
    );
  }
}
