import 'package:flutter/material.dart';
import 'package:hammer_app/core/colors/colors.dart';

class KycStatusConfig {
  final Color color;
  final IconData icon;
  final String message;
  final bool showActionButton;
  final String buttonText;

  const KycStatusConfig({
    required this.color,
    required this.icon,
    required this.message,
    required this.showActionButton,
    required this.buttonText,
  });
}

KycStatusConfig getKycConfig(String status) {
  switch (status) {

    /// 🔶 NOT STARTED
    case 'not_started':
      return const KycStatusConfig(
        color: Colors.orange,
        icon: Icons.play_circle_outline,
        message:
            'Your KYC process has not been started.\nPlease complete all required steps.',
        showActionButton: true,
        buttonText: 'Start KYC',
      );

    /// 🔶 PARTIALLY COMPLETED
    case 'not_completed':
      return const KycStatusConfig(
        color: Colors.orange,
        icon: Icons.pending_actions,
        message:
            'Your KYC is partially completed.\nPlease complete remaining steps.',
        showActionButton: true,
        buttonText: 'Continue KYC',
      );

    /// 🟡 PENDING (Under Review)
    case 'pending':
      return const KycStatusConfig(
        color: AppColors.primaryAmber,
        icon: Icons.hourglass_top,
        message:
            'Your KYC is under review.\nAdmin will verify your details shortly.',
        showActionButton: false,
        buttonText: '',
      );

    /// 🟠 NEED CLARIFICATION
    case 'need_clarification':
      return const KycStatusConfig(
        color: Colors.deepOrange,
        icon: Icons.help_outline,
        message:
            'Your KYC needs clarification.\nPlease update required details and resubmit.',
        showActionButton: true,
        buttonText: 'Update KYC',
      );

    /// 🔴 REJECTED
    case 'rejected':
      return const KycStatusConfig(
        color: Colors.red,
        icon: Icons.cancel_outlined,
        message:
            'Your KYC verification has been rejected.\nPlease correct the details and resubmit.',
        showActionButton: true,
        buttonText: 'Resubmit KYC',
      );

    /// 🟢 VERIFIED
    case 'verified':
      return const KycStatusConfig(
        color: Colors.green,
        icon: Icons.verified,
        message:
            'Your KYC has been successfully verified.\nYou can proceed with account activation.',
        showActionButton: false,
        buttonText: '',
      );

    /// DEFAULT SAFETY
    default:
      return const KycStatusConfig(
        color: Colors.grey,
        icon: Icons.info_outline,
        message: 'KYC status unavailable.',
        showActionButton: false,
        buttonText: '',
      );
  }
}