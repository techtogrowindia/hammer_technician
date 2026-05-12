// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'package:hammer_app/core/utils/common/widgets/auth_background.dart';
import 'package:hammer_app/core/utils/common/widgets/auth_button.dart';
import 'package:hammer_app/core/utils/common/widgets/auth_textfield.dart';
import 'package:hammer_app/core/utils/common/widgets/white_card.dart';
import 'package:hammer_app/core/utils/snackbar_utils.dart';

import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';
import 'verify_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
                  const Text(
                    "Forgot Password",
                    style: TextStyle(
                      fontSize: 24,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AuthTextField(
                    controller: mobileController,
                    label: "Mobile Number",
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Mobile required";

                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
                    listener: (context, state) {
                      if (state is SendOtpSuccess) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VerifyOtpScreen(
                              mobile: mobileController.text.trim(),
                            ),
                          ),
                        );
                      } else if (state is ForgotPasswordFailure) {
                        AppSnackBar.show(context, state.message, isError: true);
                      }
                    },
                    builder: (context, state) {
                      return AuthButton(
                        text: "Send OTP",
                        loading: state is ForgotPasswordLoading,
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<ForgotPasswordCubit>().sendOtp(
                              mobileController.text.trim(),
                            );
                          }
                        },
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
