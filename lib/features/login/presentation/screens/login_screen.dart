// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_auth/local_auth.dart';
import 'package:hammer_app/core/utils/snackbar_utils.dart';

import 'package:hammer_app/core/colors/colors.dart';

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
  bool biometricAvailable = false;
  bool biometricBusy = false;
  bool biometricEnabled = false;
  bool _autoBiometricAttempted = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _initializeLoginFlow();
  }

  Future<void> _initializeLoginFlow() async {
    final creds = await SharedPrefsHelper.getCredentials();
    final enabled = await SharedPrefsHelper.isBiometricEnabled();
    bool available = false;
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final deviceSupported = await _localAuth.isDeviceSupported();
      final enrolled = await _localAuth.getAvailableBiometrics();
      available = (canCheck || deviceSupported) && enrolled.isNotEmpty;
    } catch (_) {
      available = false;
    }

    if (!mounted) return;
    mobile.text = creds["phone"];
    password.text = creds["password"];
    setState(() {
      rememberMe = creds["remember"];
      biometricEnabled = enabled;
      biometricAvailable = available;
    });
    await _checkBiometricOnOpen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<LoginCubit, LoginState>(
            listener: (context, state) async {
              if (state is LoginFailure) {
                AppSnackBar.show(context, state.message, isError: true);
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

                if (!user.mobileVerified) {
                  _showRequestOtpDialog(context, mobile.text);
                  return;
                }

                await _maybeAskToEnableBiometric();
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
                if (user.kycStatus != 'verified') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => KycOnboardingScreen()),
                    (route) => false,
                  );
                  return;
                }

                if (user.kycStatus == 'verified') {
                  AppSnackBar.show(context, "Login successful!");
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
                AppSnackBar.show(context, state.message, isError: true);
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
                            final loading = state is LoginLoading;
                            return AuthButton(
                              text: "LOGIN",
                              loading: loading || biometricBusy,
                              onTap: _onLogin,
                            );
                          },
                        ),

                        if (biometricAvailable && biometricEnabled) ...[
                          const SizedBox(height: 20),
                          Center(
                            child: InkWell(
                              onTap: _loginWithBiometric,
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.fingerprint,
                                    size: 40,
                                    color: AppColors.primaryBlue,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Login with Biometric",
                                    style: TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

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

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final isFirstPrompt =
        !(await SharedPrefsHelper.isLocationPromptShownOnce());
    if (isFirstPrompt) {
      final userAllowed = await _showLocationAccessDialog();
      await SharedPrefsHelper.markLocationPromptShownOnce();
      if (!userAllowed) return;
    }

    final hasPermission = await _ensureLocationPermission();
    if (!hasPermission) {
      AppSnackBar.show(
        context,
        "Location permission is required to login.",
        isError: true,
      );
      return;
    }

    final request = LoginRequest(
      mobile: mobile.text.trim(),
      password: password.text.trim(),
    );
    context.read<LoginCubit>().submit(request);
  }

  Future<bool> _showLocationAccessDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Location Access Required",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  "Hammer Technician collects location data to:\n\n"
                  "• Track technician attendance\n"
                  "• Verify live service location\n"
                  "• Enable customer service updates\n\n"
                  "Location data may be collected even when the app is closed or not in use for technician tracking and assigned service monitoring.\n\n"
                  "Your location data is not shared with third parties.",
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Deny"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Allow"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  Future<bool> _ensureLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> _checkBiometricOnOpen() async {
    if (!mounted || _autoBiometricAttempted) {
      return;
    }
    if (!biometricEnabled || !biometricAvailable) {
      return;
    }
    if (mobile.text.trim().isEmpty || password.text.trim().isEmpty) {
      return;
    }

    _autoBiometricAttempted = true;
    // Small delay to ensure the login screen is fully rendered
    // before the system biometric dialog appears
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    await _loginWithBiometric();
  }

  Future<void> _loginWithBiometric() async {
    setState(() => biometricBusy = true);
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to login to Hammer App',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );

      if (!didAuthenticate || !mounted) return;

      if (mobile.text.trim().isEmpty || password.text.trim().isEmpty) {
        AppSnackBar.show(
          context,
          "Please login manually once to save credentials for biometric login.",
          isError: true,
        );
        return;
      }

      await _submitLoginRequest();
    } catch (e) {
      // Silently ignore user cancellation and other common setup errors
      // so the user can just use the manual login button without distraction
      if (e.toString().contains('userCanceled') ||
          e.toString().contains('NotEnrolled') ||
          e.toString().contains('LockedOut')) {
        return;
      }

      if (!mounted) return;
      AppSnackBar.show(context, "Biometric Error: $e", isError: true);
    } finally {
      if (mounted) setState(() => biometricBusy = false);
    }
  }

  Future<void> _maybeAskToEnableBiometric() async {
    if (!biometricAvailable) return;
    final alreadyAsked = await SharedPrefsHelper.isBiometricPromptAskedOnce();
    if (alreadyAsked) return;

    final enable = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Enable Biometric Login"),
          content: const Text(
            "Would you like to enable biometric login for quicker sign in next time?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (enable == true) {
      await SharedPrefsHelper.setBiometricEnabled(true);
      await SharedPrefsHelper.saveCredentials(
        mobile.text.trim(),
        password.text.trim(),
        true,
      );
      if (mounted) {
        setState(() {
          biometricEnabled = true;
          rememberMe = true;
        });
      }
    }

    await SharedPrefsHelper.markBiometricPromptAskedOnce();
  }

  Future<void> _submitLoginRequest() async {
    final request = LoginRequest(
      mobile: mobile.text.trim(),
      password: password.text.trim(),
    );
    context.read<LoginCubit>().submit(request);
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

  bool _isKycStepCompleted(Map<String, dynamic>? steps, String key) {
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
