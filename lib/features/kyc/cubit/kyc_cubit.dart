import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hammer_app/features/kyc/data/models/kyc_service_model.dart';
import 'package:hammer_app/features/kyc/data/repositories/kyc_repository.dart';
import '../data/models/kyc_step1_model.dart';
import '../data/models/kyc_step2_model.dart';
import '../data/models/kyc_step3_model.dart';
import 'kyc_state.dart';

class KycCubit extends Cubit<KycState> {
  final KycRepository repository;

  KycCubit(this.repository) : super(KycInitial());

  Future<void> submitStep({
    int stepIndex = 0,
    KycStep1Response? step1,
    KycStep2Response? step2,
    KycStep3Response? step3,
    List<KycServiceModel>? services,
  }) async {
    emit(KycLoading());
    try {
      await repository.submitKyc(
        step1: step1,
        step2: step2,
        step3: step3,
        services: services,
      );
      emit(KycSuccess(stepIndex));
    } catch (e) {
      emit(KycError(e.toString()));
    }
  }

  /// Save education qualification (Step 2)
  Future<void> saveEduQualification({
    required String qualification,
    String? passedOutYear,
    required List<File> files,
  }) async {
    emit(KycLoading());
    try {
      await repository.saveEduQualification(
        qualification: qualification,
        passedOutYear: passedOutYear,
        files: files,
      );
      emit(EduQualificationSaved());
    } catch (e) {
      emit(KycError(e.toString()));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SERVICE CATEGORIES (New — replaces old services_kyc)
  // ──────────────────────────────────────────────────────────────────────────

  /// Save/update selected service categories
  Future<void> saveServiceCategories(
    List<Map<String, dynamic>> categories, {
    bool isUpdate = false,
  }) async {
    emit(KycLoading());
    try {
      await repository.saveServiceCategories(categories, isUpdate: isUpdate);
      emit(ServiceCategoriesSaved());
    } catch (e) {
      emit(KycError(e.toString()));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TECHNICIAN SERVICES (New — replaces old services_kyc)
  // ──────────────────────────────────────────────────────────────────────────

  /// Save selected technician service IDs
  Future<void> saveTechnicianServices(List<int> serviceIds, {bool isUpdate = false}) async {
    emit(KycLoading());
    try {
      final result = await repository.saveTechnicianServices(
        serviceIds,
        isUpdate: isUpdate,
      );
      final ignoredIds = result['data']?['ignored_service_ids'] as List? ?? [];
      emit(TechnicianServicesSaved(ignoredServiceIds: ignoredIds.cast<int>()));
    } catch (e) {
      emit(KycError(e.toString()));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SERVICE CERTIFICATES (New — replaces old uploadServicesKycWithFiles)
  // ──────────────────────────────────────────────────────────────────────────

  /// Upload a certificate for a specific service
  Future<void> uploadServiceCertificate({
    required int serviceId,
    required int certificateId,
    String? certificateNumber,
    bool noExpiry = true,
    String? expiryDate,
    required List<File> files,
  }) async {
    emit(DocumentUploading());
    try {
      await repository.uploadServiceCertificate(
        serviceId: serviceId,
        certificateId: certificateId,
        certificateNumber: certificateNumber,
        noExpiry: noExpiry,
        expiryDate: expiryDate,
        files: files,
      );
      emit(ProfessionalDocumentsUploaded());
    } catch (e) {
      emit(KycError(e.toString()));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // GST VERIFICATION
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> verifyGst(String gst, {required bool hasFirm, required bool hasGst}) async {
    emit(GstVerifyLoading());
    try {
      final gstDetails = await repository.verifyGst(gst, hasFirm: hasFirm, hasGst: hasGst);
      emit(GstVerified(gstDetails ?? {}));
    } catch (e) {
      emit(GstVerifyError(e.toString()));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // DOCUMENT KYC (Step 4)
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> uploadStep4({required Map<String, File> files}) async {
    emit(DocumentUploading());
    try {
      await repository.submitDocuments(files: files);
      emit(DocumentUploaded());
    } catch (e) {
      emit(KycError(e.toString()));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SIGNATURE
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> uploadSignature(File file) async {
    emit(DocumentUploading());
    try {
      await repository.uploadSignature(file);
      emit(SignatureUploaded(file));
    } catch (e) {
      emit(KycError(e.toString()));
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // OTP
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> sendKycOtp() async {
    emit(KycLoading());
    try {
      final resp = await repository.sendKycOtp();
      final data = resp['data'] as Map<String, dynamic>?;
      final token = data?['verification_token']?.toString();
      if (token == null || token.isEmpty) throw Exception('No verification token');
      emit(KycOtpSent(token));
    } catch (e) {
      emit(KycError(e.toString()));
    }
  }

  Future<void> verifyKycOtp({
    required String verificationToken,
    required String otp,
  }) async {
    emit(KycLoading());
    try {
      await repository.verifyKycOtp(
        verificationToken: verificationToken,
        otp: otp,
      );
      emit(KycOtpVerified());
    } catch (e) {
      emit(KycError(e.toString()));
    }
  }

  void clear() => emit(KycInitial());
}
