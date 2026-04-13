import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'package:hammer_app/features/login/presentation/screens/login_screen.dart';
import 'package:hammer_app/features/register/cubit/register_cubit.dart';
import 'package:hammer_app/features/register/cubit/register_state.dart';
import 'package:hammer_app/features/register/data/models/register_request_model.dart';
import 'package:hammer_app/core/utils/common/widgets/auth_background.dart';
import 'package:hammer_app/core/utils/common/widgets/auth_button.dart';
import 'package:hammer_app/core/utils/common/widgets/auth_textfield.dart';
import 'package:hammer_app/core/utils/common/widgets/white_card.dart';
import 'package:hammer_app/features/otp/presentation/screens/otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final mobile = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  bool show = false;
  bool showcnf = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is RegisterSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => OtpScreen(
                  mobile: state.response.data!.mobile,
                  id: state.response.data!.id,
                  fromLogin: false,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return AuthBackground(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: AuthCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // const SizedBox(height: 8),
                              // const Text("Sign up to register your shop"),
                              const SizedBox(height: 30),

                              AuthTextField(
                                controller: name,
                                label: "Name (As per Aadhar)",
                                validator: (v) =>
                                    v!.isEmpty ? "Name required" : null,
                              ),
                              const SizedBox(height: 20),

                              AuthTextField(
                                controller: email,
                                label: "Email",
                                validator: (v) =>
                                    v!.isEmpty ? "Email required" : null,
                              ),
                              const SizedBox(height: 20),

                              AuthTextField(
                                controller: mobile,
                                label: "Mobile Number",
                                keyboardType: TextInputType.phone,
                                validator: (v) =>
                                    v!.length < 10 ? "Invalid mobile" : null,
                              ),
                              const SizedBox(height: 20),

                              AuthTextField(
                                controller: password,
                                label: "Password",
                                obscure: !show,
                                suffix: IconButton(
                                  icon: Icon(
                                    show
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () => setState(() => show = !show),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return "Password required";
                                  }

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
                                controller: confirm,
                                label: "Confirm Password",
                                obscure: !showcnf,
                                suffix: IconButton(
                                  icon: Icon(
                                    showcnf
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () =>
                                      setState(() => showcnf = !showcnf),
                                ),
                                validator: (v) => v != password.text
                                    ? "Password mismatch"
                                    : null,
                              ),
                              const SizedBox(height: 30),

                              AuthButton(
                                text: "JOIN US",
                                loading: state is RegisterLoading,
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    final request = RegisterRequest(
                                      name: name.text.trim(),
                                      email: email.text.trim(),
                                      mobile: mobile.text.trim(),
                                      password: password.text.trim(),
                                      passwordConfirmation: confirm.text.trim(),
                                    );
                                    context.read<RegisterCubit>().submit(
                                      request,
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 30),

                              Align(
                                alignment: Alignment.centerRight,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Already have an account?",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    InkWell(
                                      child: Text(
                                        "Login",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryBlue,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => LoginScreen(),
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
              );
            },
          );
        },
      ),
    );
  }
}
