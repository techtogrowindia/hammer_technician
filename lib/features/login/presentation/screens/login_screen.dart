// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hammer_app/core/colors/colors.dart';
import 'package:hammer_app/core/firebase/fcm_api.dart';
import 'package:hammer_app/core/firebase/fcm_service.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';
import 'package:hammer_app/core/utils/common/widgets/auth_background.dart';
import 'package:hammer_app/core/utils/common/widgets/auth_button.dart';
import 'package:hammer_app/core/utils/common/widgets/auth_textfield.dart';
import 'package:hammer_app/core/utils/common/widgets/white_card.dart';
import 'package:hammer_app/features/forgot_password/presentation/forgot_password_screen.dart';

import 'package:hammer_app/features/kyc/presentation/screen/kyc_onboarding_screen.dart';
import 'package:hammer_app/features/otp/cubit/mobile_otp_cubit.dart';
import 'package:hammer_app/features/otp/cubit/mobile_otp_state.dart';
import 'package:hammer_app/features/otp/presentation/screens/otp_screen.dart';
import 'package:hammer_app/features/kyc/presentation/screen/dashboard.dart';
import 'package:hammer_app/features/register/presentation/register_screen.dart';

import '../../cubit/login_cubit.dart';
import '../../cubit/login_state.dart';
import '../../data/models/login_request_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final mobile = TextEditingController();
  final password = TextEditingController();

  bool showPassword = false;
  bool rememberMe = false;
  bool navigated = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final creds = await SharedPrefsHelper.getCredentials();
    mobile.text = creds["phone"];
    password.text = creds["password"];
    setState(() {
      rememberMe = creds["remember"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<LoginCubit, LoginState>(
            listener: (context, state) async {
              if (state is LoginFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }

              if (state is LoginSuccess) {
                await SharedPrefsHelper.saveCredentials(
                  mobile.text.trim(),
                  password.text.trim(),
                  rememberMe,
                );

                final user = state.response.data;
                if (user == null || navigated) return;
                await SharedPrefsHelper.saveCachedProfileResponse({
                  'success': true,
                  'message': state.response.message,
                  'data': user.toProfileJson(),
                });

                final fcmService = FcmService();
                final fcmToken = await fcmService.getToken();
                if (fcmToken != null) {
                  await FcmApi.sendFcmToken(fcmToken: fcmToken);
                }
                fcmService.listenTokenRefresh((newToken) async {
                  await FcmApi.sendFcmToken(fcmToken: newToken);
                });

                if (!user.mobileVerified) {
                  _showRequestOtpDialog(context, mobile.text);
                  return;
                }

                navigated = true;

                final steps = user.kycSteps;
                final allStepsCompleted =
                    _isKycStepCompleted(steps, 'profile_kyc') &&
                    _isKycStepCompleted(steps, 'services_kyc') &&
                    _isKycStepCompleted(steps, 'bank_kyc') &&
                    _isKycStepCompleted(steps, 'company_kyc') &&
                    _isKycStepCompleted(steps, 'document_kyc');

                if (user.accountStatus != 'active') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => KycOnboardingScreen()),
                    (route) => false,
                  );
                  return;
                }

                if (!allStepsCompleted && user.kycStatus != 'verified') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => KycOnboardingScreen()),
                    (route) => false,
                  );
                  return;
                }

                if (user.kycStatus == 'verified') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Login successful!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                    (route) => false,
                  );
                  return;
                }
              }
            },
          ),

          BlocListener<MobileOtpCubit, MobileOtpState>(
            listener: (context, state) async {
              if (state is MobileOtpFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }

              if (state is MobileOtpSent) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        OtpScreen(mobile: mobile.text, id: 0, fromLogin: true),
                  ),
                );

                return;
              }
            },
          ),

        ],

        child: AuthBackground(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Center(
                child: AuthCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hello!",
                          style: TextStyle(
                            fontSize: 24,
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Login with your registered credentials.",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 30),

                        AuthTextField(
                          controller: mobile,
                          label: "Mobile Number",
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Mobile number required";
                            }
                            if (v.length < 10) {
                              return "Enter valid mobile number";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        AuthTextField(
                          controller: password,
                          label: "Password",
                          obscure: !showPassword,
                          suffix: IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? "Password required"
                              : null,
                        ),

                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(color: AppColors.primaryBlue),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Checkbox(
                                value: rememberMe,
                                activeColor: AppColors.primaryAmber,
                                checkColor: Colors.black,
                                onChanged: (v) {
                                  setState(() => rememberMe = v!);
                                },
                              ),
                              const Text(
                                "Remember Me",
                                style: TextStyle(color: AppColors.primaryBlue),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        BlocBuilder<LoginCubit, LoginState>(
                          builder: (context, state) {
                            return AuthButton(
                              text: "LOGIN",
                              loading: state is LoginLoading,
                              onTap: _onLogin,
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 4),
                              InkWell(
                                child: Text(
                                  "Join Us",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
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

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      final request = LoginRequest(
        mobile: mobile.text.trim(),
        password: password.text.trim(),
      );
      context.read<LoginCubit>().submit(request);
    }
  }

  void _showRequestOtpDialog(BuildContext context, String mobile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Mobile Verification"),
          content: Text(
            "Your mobile number $mobile is not verified. Please verify using OTP.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                context.read<MobileOtpCubit>().sendOtp();
              },
              child: const Text("Send OTP"),
            ),
          ],
        );
      },
    );
  }

  bool _isKycStepCompleted(
    Map<String, dynamic>? steps,
    String key,
  ) {
    if (steps == null) return false;
    final dynamic raw = steps[key];
    if (raw is Map<String, dynamic>) {
      return raw['status'] == 'completed';
    }
    return false;
  }

  @override
  void dispose() {
    mobile.dispose();
    password.dispose();
    super.dispose();
  }
}
