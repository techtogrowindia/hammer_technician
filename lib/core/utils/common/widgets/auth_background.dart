// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:hammer_app/core/colors/colors.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
                child: _curve(w * 0.6, h * 0.35),
              ),
              Positioned(
                top: h * 0.42,
                right: -w * 0.22,
                child: _curve(w * 0.4, h * 0.18),
              ),
              Positioned(
                bottom: -h * 0.28,
                left: -w * 0.3,
                child: _curve(w * 0.7, h * 0.4),
              ),
              SafeArea(child: child),
            ],
          ),
        );
      },
    );
  }

  Widget _curve(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 243, 181, 67),
        borderRadius: BorderRadius.circular(w),
      ),
    );
  }
}
