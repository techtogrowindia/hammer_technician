// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'package:hammer_app/core/utils/common/widgets/auth_background.dart';
import 'package:hammer_app/core/utils/common/widgets/auth_button.dart';
import 'package:hammer_app/core/utils/common/widgets/auth_textfield.dart';
import 'package:hammer_app/core/utils/common/widgets/white_card.dart';

import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import 'reset_password_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String mobile;

  const VerifyOtpScreen({super.key, required this.mobile});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: AuthCard(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/gif/hammer_gif.gif',
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Verify OTP",
                    style: TextStyle(
                      fontSize: 24,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Enter the OTP sent to your mobile number.",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 30),
                  AuthTextField(
                    controller: otpController,
                    label: "OTP",
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "OTP required";
                      if (v.length < 4) return "Enter valid OTP";
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
                    listener: (context, state) {
                      if (state is VerifyOtpSuccess) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResetPasswordScreen(
                              resetToken: state.resetToken,
                            ),
                          ),
                        );
                      } else if (state is ForgotPasswordFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return AuthButton(
                        text: "Verify OTP",
                        loading: state is ForgotPasswordLoading,
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<ForgotPasswordCubit>().verifyOtp(
                              widget.mobile,
                              otpController.text.trim(),
                            );
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    child: Text(
                      "Resend OTP",
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      context.read<ForgotPasswordCubit>().sendOtp(
                        widget.mobile,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
