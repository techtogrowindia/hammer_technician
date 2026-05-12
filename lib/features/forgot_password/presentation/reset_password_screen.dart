// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'package:hammer_app/core/utils/common/widgets/auth_background.dart';
import 'package:hammer_app/core/utils/common/widgets/auth_button.dart';
import 'package:hammer_app/core/utils/common/widgets/auth_textfield.dart';
import 'package:hammer_app/core/utils/common/widgets/white_card.dart';
import 'package:hammer_app/core/utils/snackbar_utils.dart';
import 'package:hammer_app/features/login/presentation/screens/login_screen.dart';

import '../cubit/forgot_password_cubit.dart';
import '../cubit/forgot_password_state.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String resetToken;

  const ResetPasswordScreen({super.key, required this.resetToken});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  bool showPassword = false;

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
                    "Reset Password",
                    style: TextStyle(
                      fontSize: 24,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AuthTextField(
                    controller: passwordController,
                    label: "New Password",
                    obscure: !showPassword,
                    suffix: IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() {
                        showPassword = !showPassword;
                      }),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Password required";

                      final pattern =
                          r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$';
                      final regExp = RegExp(pattern);

                      if (!regExp.hasMatch(v)) {
                        return "Password must be at least 8 characters,\ninclude 1 uppercase, 1 number & 1 special character";
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AuthTextField(
                    controller: confirmController,
                    label: "Confirm Password",
                    obscure: !showPassword,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Confirm your password";
                      }
                      if (v != passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
                    listener: (context, state) {
                      if (state is ResetPasswordSuccess) {
                        AppSnackBar.show(context, state.message, isError: false);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      } else if (state is ForgotPasswordFailure) {
                        AppSnackBar.show(context, state.message, isError: true);
                      }
                    },
                    builder: (context, state) {
                      return AuthButton(
                        text: "Reset Password",
                        loading: state is ForgotPasswordLoading,
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<ForgotPasswordCubit>().resetPassword(
                              widget.resetToken,
                              passwordController.text.trim(),
                              confirmController.text.trim(),
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
