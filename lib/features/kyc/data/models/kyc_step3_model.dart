class KycStep3Response {
  final String bankName;
  final String bankAccountNumber;
  final String holderName;
  final String accountType;
  final String ifscCode;
  final String branchName;
  final String? upiId;

  KycStep3Response({
    required this.bankName,
    required this.bankAccountNumber,
    required this.holderName,
    required this.accountType,
    required this.ifscCode,

    required this.branchName,
    this.upiId,
  });

  Map<String, dynamic> toJson() {
    return {
      "bank_name": bankName,
      "account_number": bankAccountNumber,
      'account_holder_name': holderName,
      "account_type": accountType,
      "ifsc_code": ifscCode,
      "branch_name": branchName,
      if (upiId != null && upiId!.isNotEmpty) "upi_id": upiId,
    };
  }
}
