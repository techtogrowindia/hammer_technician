import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hammer_app/core/utils/common/widgets/auth_background.dart';
import 'package:hammer_app/core/utils/common/widgets/auth_button.dart';
import 'package:hammer_app/core/utils/common/widgets/white_card.dart';
import 'package:hammer_app/core/utils/common/widgets/dynamic_gif_widget.dart';
import 'package:hammer_app/core/utils/snackbar_utils.dart';
import 'package:hammer_app/features/kyc/cubit/kyc_cubit.dart';
import 'package:hammer_app/features/kyc/cubit/kyc_state.dart';
import 'package:hammer_app/features/kyc/presentation/screen/kyc_onboarding_screen.dart';
import 'package:hammer_app/features/otp/presentation/widgets/otp_field_widget.dart';

class KycVerificationOtpScreen extends StatefulWidget {
  final String verificationToken;

  const KycVerificationOtpScreen({super.key, required this.verificationToken});

  @override
  State<KycVerificationOtpScreen> createState() =>
      _KycVerificationOtpScreenState();
}

class _KycVerificationOtpScreenState extends State<KycVerificationOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final otpController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  void _onVerify() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<KycCubit>().verifyKycOtp(
        verificationToken: widget.verificationToken,
        otp: otpController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KycCubit, KycState>(
      listener: (context, state) {
        if (state is KycError) {
          AppSnackBar.show(context, state.message, isError: true);
        }
        if (state is KycOtpVerified) {
          AppSnackBar.show(
            context,
            "KYC verified successfully",
            isError: false,
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const KycOnboardingScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: AuthBackground(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Center(
                child: AuthCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         Center(
                          child: DynamicGifWidget(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: MediaQuery.of(context).size.width * 0.6,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Verify OTP",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Enter the OTP sent to your registered mobile number",
                        ),
                        const SizedBox(height: 30),
                        OtpFieldWidget(controller: otpController, otpLength: 6),
                        const SizedBox(height: 30),
                        BlocBuilder<KycCubit, KycState>(
                          builder: (context, state) {
                            return AuthButton(
                              text: "VERIFY",
                              loading: state is KycLoading,
                              onTap: _onVerify,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
