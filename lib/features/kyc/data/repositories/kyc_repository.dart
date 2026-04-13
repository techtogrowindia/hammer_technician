import 'dart:io';

import 'package:hammer_app/features/kyc/data/models/kyc_service_model.dart';
import 'package:hammer_app/features/kyc/data/services/kyc_service.dart';

import '../models/kyc_step1_model.dart';
import '../models/kyc_step2_model.dart';
import '../models/kyc_step3_model.dart';

class KycRepository {
  final KycApiService api;

  KycRepository(this.api);

  Future<void> submitKyc({
    KycStep1Response? step1,
    KycStep2Response? step2,
    KycStep3Response? step3,
    List<KycServiceModel>? services,
  }) async {
    if (step1 != null) {
      await api.savePersonalKyc(step1.toJson());
    }
    if (step2 != null) {
      await api.saveCompanyKyc(step2.toJson());
    }
    if (step3 != null) {
      await api.saveBankKyc(step3.toJson());
    }
  }

  /// Save education qualification (new step 2)
  Future<Map<String, dynamic>> saveEduQualification({
    required String qualification,
    String? passedOutYear,
    required List<File> files,
  }) async {
    return api.saveEduQualification(
      qualification: qualification,
      passedOutYear: passedOutYear,
      files: files,
    );
  }

  /// Get the technician's selected service categories
  Future<Map<String, dynamic>> getServiceCategories() async {
    return api.getServiceCategories();
  }

  /// Save/update selected service categories
  Future<Map<String, dynamic>> saveServiceCategories(
    List<int> categories, {
    bool isUpdate = false,
  }) async {
    return api.saveServiceCategories(categories, isUpdate: isUpdate);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TECHNICIAN SERVICES (New API - replaces part of old services_kyc)
  // ──────────────────────────────────────────────────────────────────────────

  /// Get the technician's selected services
  Future<Map<String, dynamic>> getTechnicianServices() async {
    return api.getTechnicianServices();
  }

  /// Save/update selected service IDs (must belong to selected categories)
  Future<Map<String, dynamic>> saveTechnicianServices(
    List<int> serviceIds, {
    bool isUpdate = false,
  }) async {
    return api.saveTechnicianServices(serviceIds, isUpdate: isUpdate);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SERVICE CERTIFICATES (New API - replaces old service_certificate_list + upload)
  // ──────────────────────────────────────────────────────────────────────────

  /// Get certificate requirements and uploads for selected services
  Future<Map<String, dynamic>> getServiceCertificates() async {
    return api.getServiceCertificates();
  }

  /// Upload a single certificate (with files) for a specific service
  Future<Map<String, dynamic>> uploadServiceCertificate({
    required int serviceId,
    required int certificateId,
    String? certificateNumber,
    bool noExpiry = true,
    String? expiryDate,
    required List<File> files,
  }) async {
    return api.uploadServiceCertificate(
      serviceId: serviceId,
      certificateId: certificateId,
      certificateNumber: certificateNumber,
      noExpiry: noExpiry,
      expiryDate: expiryDate,
      files: files,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // GST VERIFICATION
  // ──────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> verifyGst(
    String gst, {
    required bool hasFirm,
    required bool hasGst,
  }) async {
    return api.verifyGst(gst, hasFirm: hasFirm, hasGst: hasGst);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // DOCUMENT KYC
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> submitDocuments({required Map<String, File> files}) async {
    final nonNull = Map<String, File>.fromEntries(files.entries);
    if (nonNull.isEmpty) throw Exception('No files to upload');
    await api.uploadDocumentKyc(nonNull);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // OTP & SIGNATURE
  // ──────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> sendKycOtp() async =>
      api.sendKycOtp();

  Future<Map<String, dynamic>> verifyKycOtp({
    required String verificationToken,
    required String otp,
  }) async =>
      api.verifyKycOtp(verificationToken: verificationToken, otp: otp);

  Future<Map<String, dynamic>> uploadSignature(File file) async =>
      api.uploadSignature(file);

  Future<Map<String, dynamic>> updateKycStatus({
    required int technicianId,
    required String kycStatus,
  }) async =>
      api.updateKycStatus(technicianId: technicianId, kycStatus: kycStatus);
}
