import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hammer_app/core/colors/colors.dart';

class ProfileStrengthDashboard extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  const ProfileStrengthDashboard({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toInt();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _CircularProgress(progress: progress),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Profile Strength",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStrengthText(percentage),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                if (percentage < 100)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAmber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Complete Now",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryAmber,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStrengthText(int percentage) {
    if (percentage < 30) return "Just getting started! Add more details to stand out.";
    if (percentage < 70) return "Looking good! You're halfway to a verified expert profile.";
    if (percentage < 100) return "Almost there! Just a few more details to reach 100%.";
    return "Perfect! Your profile is complete and optimized.";
  }
}

class _CircularProgress extends StatelessWidget {
  final double progress;

  const _CircularProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: 80,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 8,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade100),
          ),
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            strokeCap: StrokeCap.round,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryAmber),
          ),
          Center(
            child: Text(
              "${(progress * 100).toInt()}%",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
