import 'app_config.dart';

/// Technician API only (per API document). Base URL from AppConfig.
class ApiConstants {
  static String get baseUrl => AppConfig.instance.baseUrl;
  /// Backend-required static auth token for public auth endpoints.
  static const String preAuthBearerToken = '12345678';

  static String get login => '$baseUrl/api/technician/login';
  static String get create => '$baseUrl/api/technician/create';
  static String get register => create;
  static String get verifyOtp => '$baseUrl/api/technician/verify-otp';
  static String get resendOtp => '$baseUrl/api/technician/resend-otp';
  static String get verifyMobileOtp => verifyOtp;
  static String get sendOtp => resendOtp;

  static String get kyc => '$baseUrl/api/technician/personal_kyc';
  static String get personalKyc => kyc;
  static String get personalKycPatch => kyc;
  static String get eduQualification => '$baseUrl/api/technician/edu-qualification';
  /// New granular service endpoints (replaces deprecated services_kyc)
  static String get technicianServiceCategory =>
      '$baseUrl/api/technician/technician_service_category';
  static String get technicianServices =>
      '$baseUrl/api/technician/technician_services';
  static String get serviceCertificates =>
      '$baseUrl/api/technician/service_certificates';
  static String serviceCertificatesDownload(int id, int index) =>
      '$baseUrl/api/technician/service_certificates/download/$id/$index';
  static String get bankKyc => '$baseUrl/api/technician/bank_kyc';
  static String get companyKyc => '$baseUrl/api/technician/company_kyc';
  static String get documentKyc => '$baseUrl/api/technician/document_kyc';
  static String get documentKycAllDocs =>
      '$baseUrl/api/technician/document_kyc/all_docs';
  static String documentKycDownload(String documentKey) =>
      '$documentKyc/download?document=$documentKey';
  static String get technicianKycFull =>
      '$baseUrl/api/technician/technician_kyc_full';
  static String get aadharPanLinkage =>
      '$baseUrl/api/general/aadhar_pan_linkage';
  static String get kycSendOtp => '$baseUrl/api/general/send_otp';
  static String get kycVerifyOtp => '$baseUrl/api/general/verify_otp';
  static String get technicianSignature => '$baseUrl/api/technician/signature';
  static String locationsList(String pincode) =>
      '$baseUrl/api/general/locations-list?pincode=$pincode';

  static String get service => '$baseUrl/api/general/services';
  static String get dynamicContent => '$baseUrl/api/general/dynamic_content';
  static String get positiveMessage => '$baseUrl/api/general/positive_message';
  static String get gst => '$baseUrl/api/technician/kyc/verify-gst';
  static String get profile => '$baseUrl/api/technician/profile';
  static String get logout => '$baseUrl/api/technician/logout';
  static String get forgotPassword => '$baseUrl/api/technician/forgot-password';
  static String get verifyForgotPasswordOtp =>
      '$baseUrl/api/technician/verify-forgot-password-otp';
  static String get updatePassword => '$baseUrl/api/technician/update-password';
  static String get bloodgroup => '$baseUrl/api/general/blood_group';
  static String get forgotSendOtp => forgotPassword;
  static String get forgotVerifyOtp => verifyForgotPasswordOtp;
  static String get forgotResetPassword => updatePassword;

  static String get commonDetails => '$baseUrl/api/general/common-details';
  static String get fetchKey => '$baseUrl/api/general/fetch_key';
  static String get razorpayOrderCreate => '$baseUrl/api/payment/razorpay-order-create';
  static String get paymentUpdate => '$baseUrl/api/payment/payment-update';
  static String get technicianKycStatus => '$baseUrl/api/technician/kyc_status';
  static String get createOrder => '$baseUrl/api/payment/razorpay-order-create';
  static String get generalProfile => '$baseUrl/api/technician/general_profile';
  static String get deleteAccount => '$baseUrl/api/general/account';
  
  // NOTE: This must match the backend's company_api_bearer_token setting.
  // Configure this in Company -> Settings -> Company API bearer token.
  static const String companyApiBearerToken = '12345678';
}
