// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hammer_app/core/colors/colors.dart';
import 'package:hammer_app/core/utils/common/widgets/auth_background.dart';
import 'package:hammer_app/core/utils/common/widgets/auth_button.dart';
import 'package:hammer_app/core/utils/common/widgets/white_card.dart';
import 'package:hammer_app/core/utils/common/widgets/dynamic_gif_widget.dart';
import 'package:hammer_app/core/utils/snackbar_utils.dart';

import 'package:hammer_app/features/kyc/presentation/screen/kyc_onboarding_screen.dart';
import 'package:hammer_app/features/otp/presentation/widgets/otp_field_widget.dart';

import '../../cubit/verify_otp_cubit.dart';
import '../../cubit/verify_otp_state.dart';
import '../../cubit/mobile_otp_cubit.dart';
import '../../cubit/mobile_otp_state.dart';

class OtpScreen extends StatefulWidget {
  final String mobile;
  final int id;
  final bool fromLogin;

  const OtpScreen({
    super.key,
    required this.mobile,
    required this.id,
    required this.fromLogin,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          /// 🔐 VERIFY OTP LISTENER
          BlocListener<OtpCubit, OtpState>(
            listener: (context, state) {
              if (state is OtpFailure) {
                AppSnackBar.show(context, state.error, isError: true);
              }

              if (state is OtpSuccess) {
                AppSnackBar.show(
                  context,
                  state.response.message,
                  isError: false,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => KycOnboardingScreen()),
                );
              }
            },
          ),

          /// 📱 SEND / RESEND OTP LISTENER
          BlocListener<MobileOtpCubit, MobileOtpState>(
            listener: (context, state) {
              if (state is MobileOtpFailure) {
                AppSnackBar.show(context, state.message, isError: true);
              }
              if (state is MobileOtpVerified) {
                AppSnackBar.show(
                  context,
                  state.response.message,
                  isError: false,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => KycOnboardingScreen()),
                );
              }

              if (state is MobileOtpSent) {
                AppSnackBar.show(context, state.message, isError: false);
              }
            },
          ),
        ],

        child: BlocBuilder<OtpCubit, OtpState>(
          builder: (context, state) {
            return AuthBackground(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
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
                            Text("Enter the OTP sent to ${widget.mobile}"),
                            const SizedBox(height: 30),

                            OtpFieldWidget(controller: otpController),

                            const SizedBox(height: 30),

                            AuthButton(
                              text: "VERIFY OTP",
                              loading: state is OtpLoading,
                              onTap: _onVerifyOtp,
                            ),

                            const SizedBox(height: 20),

                            Align(
                              alignment: Alignment.center,
                              child: TextButton(
                                onPressed: () {
                                  context.read<MobileOtpCubit>().resendOtp();
                                },
                                child: const Text(
                                  "Resend OTP",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onVerifyOtp() {
    if (_formKey.currentState!.validate()) {
      if (widget.fromLogin == false) {
        context.read<OtpCubit>().verifyOtp(otp: otpController.text.trim());
      } else {
        context.read<MobileOtpCubit>().verifyOtp(otpController.text.trim());
      }
    }
  }
}
