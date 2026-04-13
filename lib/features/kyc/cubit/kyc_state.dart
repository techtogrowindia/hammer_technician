abstract class KycState {}

class KycInitial extends KycState {}

class KycLoading extends KycState {}

class KycSuccess extends KycState {
  final int step;
  KycSuccess(this.step);
}

class KycError extends KycState {
  final String message;
  KycError(this.message);
}

class GstVerifyError extends KycState {
  final String message;
  GstVerifyError(this.message);
}

class GstVerified extends KycState {
  final Map<String, dynamic> gstDetails;
  GstVerified(this.gstDetails);
}

class GstVerifyLoading extends KycState {
  GstVerifyLoading();
}

class DocumentUploading extends KycState {}

class DocumentUploaded extends KycState {}

class ProfessionalDocumentsUploaded extends KycState {}

class SignatureUploaded extends KycState {
  final Object? file; // File - passed from upload
  SignatureUploaded([this.file]);
}

class KycOtpSent extends KycState {
  final String verificationToken;
  KycOtpSent(this.verificationToken);
}

class KycOtpVerified extends KycState {}

// ──────────────────────────────────────────────────────────────────────────
// New states for the granular service API flow
// ──────────────────────────────────────────────────────────────────────────

/// Emitted when service categories (max 3) are saved successfully
class ServiceCategoriesSaved extends KycState {}

class EduQualificationSaved extends KycState {}

/// Emitted when technician services are saved successfully
class TechnicianServicesSaved extends KycState {
  /// Service IDs that were ignored because they don't belong to selected categories
  final List<int> ignoredServiceIds;
  TechnicianServicesSaved({this.ignoredServiceIds = const []});
}
