// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'package:hammer_app/features/login/presentation/screens/login_screen.dart';
import 'package:hammer_app/features/register/presentation/register_screen.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryAmber,
                    AppColors.primaryAmber,
                    AppColors.primaryAmber.withOpacity(0.75),
                    AppColors.primaryAmber.withOpacity(0.75),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -h * 0.18,
                    left: -w * 0.25,
                    child: _filledCurve(w * 0.6, h * 0.35),
                  ),

                  Positioned(
                    top: h * 0.42,
                    right: -w * 0.22,
                    child: _filledCurve(w * 0.4, h * 0.18),
                  ),

                  Positioned(
                    bottom: -h * 0.28,
                    left: -w * 0.3,
                    child: _filledCurve(w * 0.7, h * 0.4),
                  ),

                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/hammer.png',
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: h * 0.04),

                          Text(
                            "Grow with Hammer",
                            style: TextStyle(
                              fontSize: w * 0.075,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),

                          SizedBox(height: h * 0.015),

                          Text(
                            "More Jobs More Benefits",
                            style: TextStyle(
                              fontSize: w * 0.04,
                              color: Colors.black87,
                            ),
                          ),

                          SizedBox(height: h * 0.05),

                          IntrinsicWidth(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,

                                    foregroundColor: AppColors.primaryBlue,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        w * 0.08,
                                      ),
                                      side: BorderSide(
                                        color: AppColors.primaryBlue
                                            .withOpacity(0.4),
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w * 0.18,
                                      vertical: h * 0.018,
                                    ),
                                  ),
                                  child: Ink(
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                        fontSize: w * 0.042,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: h * 0.02),

                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    foregroundColor: AppColors.primaryBlue,
                                    side: BorderSide(
                                      color: AppColors.primaryBlue.withOpacity(
                                        0.5,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        w * 0.08,
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: w * 0.18,
                                      vertical: h * 0.018,
                                    ),
                                  ),
                                  child: Text(
                                    "Join Us",
                                    style: TextStyle(
                                      fontSize: w * 0.042,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _filledCurve(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 243, 181, 67),
        borderRadius: BorderRadius.circular(width),
      ),
    );
  }
}
