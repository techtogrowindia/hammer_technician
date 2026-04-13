import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hammer_app/features/kyc/cubit/kyc_cubit.dart';
import 'package:hammer_app/features/kyc/cubit/kyc_state.dart';
import 'package:hammer_app/features/kyc/presentation/screen/dashboard.dart';
import 'package:hammer_app/features/kyc/presentation/screen/kyc_onboarding_screen.dart';
import 'package:hammer_app/features/profile/cubit/profile_cubit.dart';
import 'package:hammer_app/features/profile/cubit/profile_state.dart';

class KycStepperListeners extends StatelessWidget {
  final Widget child;

  final bool hasNavigated;
  final void Function(bool) setHasNavigated;

  final void Function() onKycSuccess;
  final void Function(String) onKycError;
  final void Function() onGstVerifyLoading;
  final void Function(Map<String, dynamic>) onGstVerified;
  final void Function(String) onGstVerifyError;
  final void Function() onDocumentUploaded;
  final void Function()? onProfessionalDocumentsUploaded;
  final void Function(Object? file)? onSignatureUploaded;
  final void Function(String verificationToken)? onKycOtpSent;

  const KycStepperListeners({
    super.key,
    required this.child,
    required this.hasNavigated,
    required this.setHasNavigated,
    required this.onKycSuccess,
    required this.onKycError,
    required this.onGstVerifyLoading,
    required this.onGstVerified,
    required this.onGstVerifyError,
    required this.onDocumentUploaded,
    this.onProfessionalDocumentsUploaded,
    this.onSignatureUploaded,
    this.onKycOtpSent,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded && !hasNavigated) {
              setHasNavigated(true);
              final profile = state.response.data;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (profile.kycStatus != 'completed' ||
                    profile.accountStatus == 'inactive') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => KycOnboardingScreen()),
                    (route) => false,
                  );
                } else if (profile.kycStatus == 'completed' &&
                    profile.accountStatus == 'active') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DashboardScreen()),
                    (route) => false,
                  );
                }
              });
            }
            if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<KycCubit, KycState>(
          listener: (context, state) {
            if (state is KycSuccess) {
              onKycSuccess();
            }
            if (state is ServiceCategoriesSaved) {
              // Categories saved, services step will follow
            }
            if (state is EduQualificationSaved) {
              onKycSuccess();
            }
            if (state is TechnicianServicesSaved) {
              if (state.ignoredServiceIds.isNotEmpty) {
                onKycError(
                  'Some services were ignored (not in selected categories): '
                  '${state.ignoredServiceIds.join(", ")}',
                );
              }
              onKycSuccess();
            }
            if (state is KycError) {
              onKycError(state.message);
            }
            if (state is GstVerifyLoading) {
              onGstVerifyLoading();
            }
            if (state is GstVerified) {
              onGstVerified(state.gstDetails);
            }
            if (state is GstVerifyError) {
              onGstVerifyError(state.message);
            }
            if (state is DocumentUploaded) {
              onDocumentUploaded();
            }
            if (state is ProfessionalDocumentsUploaded) {
              onProfessionalDocumentsUploaded?.call();
            }
            if (state is SignatureUploaded) {
              onSignatureUploaded?.call(state.file);
            }
            if (state is KycOtpSent) {
              onKycOtpSent?.call(state.verificationToken);
            }
          },
        ),
      ],
      child: child,
    );
  }
}
