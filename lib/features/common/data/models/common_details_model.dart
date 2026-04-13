// models/common_details_model.dart
class CommonDetailsModel {
  final bool success;
  final String message;
  final Data data;

  CommonDetailsModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CommonDetailsModel.fromJson(Map<String, dynamic> json) {
    return CommonDetailsModel(
      success: json['success'],
      message: json['message'],
      data: Data.fromJson(json['data']),
    );
  }
}

class Data {
  final DepositAmounts depositAmounts;
  final RazorpayDetails razorpay;
  final String? contactAdmin;

  Data({
    required this.depositAmounts,
    required this.razorpay,
    this.contactAdmin,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      depositAmounts: DepositAmounts.fromJson(json['deposit_amounts']),
      razorpay: RazorpayDetails.fromJson(json['razorpay']),
      contactAdmin: json['contact_admin'],
    );
  }
}

class DepositAmounts {
  final int technician;
  final int shop;

  DepositAmounts({
    required this.technician,
    required this.shop,
  });

  factory DepositAmounts.fromJson(Map<String, dynamic> json) {
    return DepositAmounts(
      technician: json['technician'],
      shop: json['shop'],
    );
  }
}

class RazorpayDetails {
  final String key;
  final String secret;

  RazorpayDetails({
    required this.key,
    required this.secret,
  });

  factory RazorpayDetails.fromJson(Map<String, dynamic> json) {
    return RazorpayDetails(
      key: json['key'],
      secret: json['secret'],
    );
  }
}
