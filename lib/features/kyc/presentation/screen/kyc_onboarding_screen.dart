import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'package:hammer_app/core/utils/snackbar_utils.dart';
import 'package:hammer_app/features/common/cubit/fetch_key_cubit.dart';
import 'package:hammer_app/features/common/cubit/fetch_key_state.dart';
import 'package:hammer_app/features/common/data/services/payment_service.dart';
import 'package:hammer_app/features/common/data/services/razorpay_service.dart';
import 'package:hammer_app/core/utils/service_locators.dart';
import 'package:hammer_app/features/kyc/data/repositories/kyc_repository.dart';
import 'package:hammer_app/features/kyc/presentation/screen/dashboard.dart';
import 'package:hammer_app/features/kyc/presentation/screen/kyc_screen.dart';
import 'package:hammer_app/features/login/presentation/screens/login_screen.dart';
import 'package:hammer_app/features/logout/exit_dialog.dart';
import 'package:hammer_app/features/logout/logout_service.dart';
import 'package:hammer_app/features/logout/delete_account_service.dart';
import 'package:hammer_app/features/profile/cubit/profile_cubit.dart';
import 'package:hammer_app/features/profile/cubit/profile_state.dart';
import 'package:hammer_app/features/profile/data/models/profile_response_model.dart';
import 'package:hammer_app/features/service/cubit/service_cubit.dart'; // 👈 ADD THIS
import 'package:hammer_app/features/service/cubit/service_state.dart'; // 👈 ADD THIS

class KycOnboardingScreen extends StatefulWidget {
  const KycOnboardingScreen({super.key});

  @override
  State<KycOnboardingScreen> createState() => _KycOnboardingScreenState();
}

class _KycOnboardingScreenState extends State<KycOnboardingScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    context.read<FetchKeyCubit>().fetchKey();
    context.read<ServiceCubit>().loadServices(); // 👈 ADD THIS
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileCubit>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (prev, curr) => curr is ProfileError,
      listener: (context, state) {
        if (state is ProfileError) {
          AppSnackBar.show(context, state.message, isError: true);
        }
      },
      builder: (context, state) {
        final profile = state is ProfileLoaded ? state.response.data : null;

        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: profile == null
                ? const Center(child: CircularProgressIndicator())
                : Builder(
                    builder: (context) {
                      bool isFinished(String? status) {
                        if (status == null) return false;
                        final s = status.toLowerCase();
                        return s == 'completed' ||
                            s == 'verified' ||
                            s == 'approved';
                      }

                      int finishedCount = 0;
                      if (isFinished(profile.kycSteps?.profileKyc?.status))
                        finishedCount++;

                      final svcStatus = profile.kycSteps?.servicesKyc?.status;
                      if (isFinished(svcStatus)) finishedCount++;
                      if (isFinished(profile.kycSteps?.companyKyc?.status))
                        finishedCount++;
                      if (isFinished(profile.kycSteps?.bankKyc?.status))
                        finishedCount++;
                      if (isFinished(profile.kycSteps?.documentKyc?.status))
                        finishedCount++;

                      final allDone =
                          isFinished(profile.kycStatus) || finishedCount >= 5;
                      final progress = allDone ? 1.0 : (finishedCount / 5);

                      return CustomScrollView(
                        slivers: [
                          _buildSliverAppBar(profile, progress, allDone),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (allDone ||
                                      profile.accountStatus == 'active') ...[
                                    _buildDepositSection(profile, allDone),
                                    const SizedBox(height: 24),
                                  ],
                                  const Text(
                                    "KYC Steps",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildStepTile(
                                    title: "Profile KYC",
                                    subtitle: "Basic personal information",
                                    stepData: profile.kycSteps?.profileKyc,
                                    icon: Icons.person_outline,
                                    index: 0,
                                    allDone: allDone,
                                  ),

                                  _buildStepTile(
                                    title: "Services KYC",
                                    subtitle:
                                        "Categories and service selection",
                                    stepData: profile.kycSteps?.servicesKyc,
                                    icon: Icons.build_circle_outlined,
                                    index: 2,
                                    allDone: allDone,
                                  ),
                                  _buildStepTile(
                                    title: "Company KYC",
                                    subtitle: "Business and GST details",
                                    stepData: profile.kycSteps?.companyKyc,
                                    icon: Icons.business_outlined,
                                    index: 4,
                                    allDone: allDone,
                                  ),
                                  _buildStepTile(
                                    title: "Bank KYC",
                                    subtitle: "Bank account and UPI info",
                                    stepData: profile.kycSteps?.bankKyc,
                                    icon: Icons.account_balance_outlined,
                                    index: 5,
                                    allDone: allDone,
                                  ),
                                  _buildStepTile(
                                    title: "Document KYC",
                                    subtitle: "Aadhar, PAN and other documents",
                                    stepData: profile.kycSteps?.documentKyc,
                                    icon: Icons.description_outlined,
                                    index: 6,
                                    allDone: allDone,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildAccountActions(profile),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(
    UserProfile profile,
    double progress,
    bool allDone,
  ) {
    final statusText = profile.accountStatus == 'active'
        ? "Account Verified"
        : (allDone ? "Verification Ready" : "Steps Pending");

    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(color: AppColors.primaryAmber),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: Opacity(
                opacity: 0.1,
                child: Image.asset(
                  'assets/images/logo_white.png',
                  width: 200,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.shield, size: 200, color: Colors.white),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white10,
                            child: Text(
                              profile.name?.substring(0, 1).toUpperCase() ??
                                  '-',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome back,",
                                style: TextStyle(
                                  color: AppColors.primaryBlue.withOpacity(0.9),
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                profile.name ?? 'Technician',
                                style: const TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () =>
                                context.read<ProfileCubit>().loadProfile(),
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 45,
                                height: 45,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 5,
                                  backgroundColor: Colors.white10,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                ),
                              ),
                              Text(
                                "${(progress * 100).toInt()}%",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  allDone
                                      ? "All Steps Completed"
                                      : "KYC Progress",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${(progress * 6).toInt()} of 6 modules finished",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: allDone
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.white24,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTile({
    required String title,
    required String subtitle,
    required KycStep? stepData,
    required IconData icon,
    required int index,
    required bool allDone,
  }) {
    final normalizedStatus = (stepData?.status ?? 'not_started').toLowerCase();
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (normalizedStatus) {
      case 'completed':
      case 'approved':
      case 'verified':
        statusColor = const Color(0xFF22C55E);
        statusIcon = Icons.check_circle_rounded;
        statusText = normalizedStatus == 'verified'
            ? "Verified"
            : (normalizedStatus == 'approved' ? "Approved" : "Completed");
        break;
      case 'pending':
        statusColor = const Color(0xFF3B82F6);
        statusIcon = Icons.hourglass_bottom_rounded;
        statusText = "Pending for Approval";
        break;
      case 'rejected':
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.error_rounded;
        statusText = "Rejected";
        break;
      case 'need_clarification':
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.info_rounded;
        statusText = "Clarification";
        break;
      case 'not_completed':
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.pending_actions_rounded;
        statusText = "Not Completed";
        break;
      default:
        statusColor = const Color(0xFF94A3B8);
        statusIcon = Icons.radio_button_unchecked_rounded;
        statusText = "Not Started";
    }

    final isEducation = title == "Education KYC";
    bool isEssentialDone(String? s) {
      if (s == null) return false;
      final statusLower = s.toLowerCase();
      return statusLower == 'completed' ||
          statusLower == 'verified' ||
          statusLower == 'approved';
    }

    // Show edit icon only if all steps are not completed AND specifically this step is not yet finished/verified/pending/approved
    final showEditIcon = !allDone && !isEssentialDone(normalizedStatus);

    final canEdit = showEditIcon;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canEdit ? () => _navigateToStep(index) : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Stack(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: AppColors.primaryBlue, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (!isEducation) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    statusIcon,
                                    color: statusColor,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (showEditIcon)
                  Positioned(
                    top: 0,
                    right: 4,
                    child: Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.primaryBlue,
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToStep(int step) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            KycStepperScreen(initialStep: step, isEditMode: true),
      ),
    ).then((_) => context.read<ProfileCubit>().loadProfile());
  }

  Widget _buildDepositSection(UserProfile profile, bool allDone) {
    if (profile.accountStatus == 'active') {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "🎉 Congratulations!",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your account is now active and ready to receive orders. Start exploring your dashboard!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.dashboard_rounded),
                label: const Text(
                  "Go to Dashboard",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF16A34A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (!allDone) return const SizedBox.shrink();

    return BlocBuilder<FetchKeyCubit, FetchKeyState>(
      builder: (context, state) {
        if (state is! FetchKeyLoaded) {
          // Only show loading if we are actually waiting
          if (state is FetchKeyError) {
            // Silently retry in the background once if it failed
            Future.microtask(() => context.read<FetchKeyCubit>().fetchKey());
          }
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30.0),
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          );
        }

        final loadedState = state;
        final isPaid =
            profile.initialDeposit == 'paid' ||
            profile.kycStatus.toLowerCase() == 'verified' ||
            profile.kycStatus.toLowerCase() == 'approved';

        return BlocBuilder<ServiceCubit, ServiceState>(
          builder: (context, serviceState) {
            int calculatedAmount = loadedState.amount;

            if (serviceState is ServiceLoaded && profile.technicianServiceIds.isNotEmpty) {
              int maxActivationCharge = 0;
              int validServiceCount = 0;

              debugPrint('--- Payment Calculation Started ---');
              debugPrint('Selected Service IDs: ${profile.technicianServiceIds}');
              debugPrint('Base Onboarding Charge (loadedState.amount): ₹${loadedState.amount}');

              for (final cat in serviceState.categories) {
                for (final sub in cat.subcategories) {
                  for (final svc in sub.services) {
                    if (profile.technicianServiceIds.contains(svc.id)) {
                      debugPrint('Found Selected Service: ${svc.serviceName} (ID: ${svc.id})');
                      debugPrint('  -> Activation Charge: ₹${svc.technicianActivationCharges}');
                      validServiceCount++;
                      if (svc.technicianActivationCharges > maxActivationCharge) {
                        maxActivationCharge = svc.technicianActivationCharges;
                      }
                    }
                  }
                }
              }

              if (validServiceCount > 0) {
                calculatedAmount = maxActivationCharge + ((validServiceCount - 1) * loadedState.amount);
                debugPrint('Highest Activation Charge: ₹$maxActivationCharge');
                debugPrint('Remaining Services: ${validServiceCount - 1}');
                debugPrint('Calculation: $maxActivationCharge + (${validServiceCount - 1} * ${loadedState.amount}) = ₹$calculatedAmount');
              } else {
                debugPrint('No matching services found for calculation. Using default amount: ₹$calculatedAmount');
              }
              debugPrint('--- Payment Calculation Ended ---');
            }

            final amount = isPaid ? profile.initialDepositAmount : calculatedAmount;

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPaid
                  ? [const Color(0xFF22C55E), const Color(0xFF16A34A)]
                  : [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isPaid ? Colors.green : Colors.blue).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPaid ? Icons.check_circle : Icons.payment,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isPaid
                          ? "Initial Deposit Paid"
                          : "One-Time Security Deposit",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    "₹$amount",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isPaid
                    ? (profile.accountStatus == 'active'
                          ? "Thank you! Your account is now active and ready for orders."
                          : "Thank you! Your payment is received. Account is currently Inactive while we finalize your background verification.")
                    : "Please complete the security deposit of ₹$amount to start receiving technician orders.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
              if (!isPaid && loadedState.razorpayKey != null) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _openPaymentDialog(
                      context,
                      razorKey: loadedState.razorpayKey,
                      amount: amount,
                      profile: profile,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Pay Now",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      });
      },
    );
  }

  Widget _buildAccountActions(UserProfile profile) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF475569).withOpacity(0.06),
              foregroundColor: const Color(0xFF475569),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () async {
              final shouldExit = await ExitConfirmation.show(
                context,
                message: 'Do you want to logout?',
              );
              if (shouldExit) {
                final result = await LogoutService.logout();
                if (result == "SUCCESS") {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
            icon: const Icon(Icons.logout_rounded, size: 22),
            label: const Text(
              "Logout from account",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444).withOpacity(0.08),
              foregroundColor: const Color(0xFFEF4444),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () async {
              final shouldDelete = await ExitConfirmation.show(
                context,
                title: 'Delete Account?',
                message:
                    'This will permanently delete your account and all related data. This action cannot be undone.',
                confirmText: 'Delete',
              );
              if (shouldDelete) {
                final techId = profile.id;
                if (techId != null) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  final success = await DeleteAccountService.deleteTechnicianAccount(techId);

                  Navigator.pop(context);

                  if (success) {
                    AppSnackBar.show(context, "Account deleted successfully.");
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  } else {
                    AppSnackBar.show(
                      context,
                      "Failed to delete account. Please try again or contact support.",
                      isError: true,
                    );
                  }
                } else {
                  AppSnackBar.show(
                    context,
                    "Profile data not found. Please wait until it loads.",
                    isError: true,
                  );
                }
              }
            },
            icon: const Icon(Icons.delete_forever_rounded, size: 22),
            label: const Text(
              "Delete Account",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openPaymentDialog(
    BuildContext context, {
    required String razorKey,
    required int amount,
    required UserProfile profile,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Creating payment order...', style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );

    try {
      final orderResponse = await PaymentService.createRazorpayOrder(
        amount: amount.toDouble(),
        userType: 'technician',
        userId: profile.id!,
      );
      if (!context.mounted) return;
      Navigator.pop(context);

      final data = orderResponse['data'] as Map<String, dynamic>?;
      if (data != null &&
          data['razorpay_order_id'] != null &&
          data['amount_paise'] != null) {
        final orderId = data['order_id'] as int? ?? 0;
        final razorpayOrderId = data['razorpay_order_id'] as String;
        final amountPaise = (data['amount_paise'] is int)
            ? data['amount_paise'] as int
            : (data['amount_paise'] as num).toInt();

        final razorpayService = RazorpayService(
          onSuccess: (paymentId, razorOrderId, signature) async {
            try {
              print(
                "[PaymentFlow] Step 1: Calling PaymentService.updatePayment...",
              );
              await PaymentService.updatePayment(
                orderId: orderId,
                razorpayOrderId: razorOrderId,
                razorpayPaymentId: paymentId,
              );
              print(
                "[PaymentFlow] Step 1 DONE. Now calling updateKycStatus...",
              );
              print(
                "[PaymentFlow] Step 2: technicianId=${profile.id}, kycStatus=verified",
              );
              await sl<KycRepository>().updateKycStatus(
                technicianId: profile.id!,
                kycStatus: 'verified',
              );
              print(
                "[PaymentFlow] Step 2 DONE. KYC status updated successfully!",
              );
              if (context.mounted) {
                context.read<ProfileCubit>().loadProfile();
                AppSnackBar.show(context, "Payment Successful!", isError: false);
              }
            } catch (e) {
              print("[PaymentFlow] ERROR: $e");
              if (context.mounted) {
                print("Payment update failed: $e");
                AppSnackBar.show(context, "Payment success but update failed: $e", isError: true);
              }
            }
          },
          onFailure: (error) {
            AppSnackBar.show(context, "Payment Failed: $error", isError: true);
          },
        );

        razorpayService.openCheckout(
          key: razorKey,
          orderId: razorpayOrderId,
          amount: amountPaise,
          name: "Hammer App",
          email: profile.email ?? "support@hammer.com",
          phone: profile.mobile ?? '1234567890',
        );
      } else {
        final msg = orderResponse['message'] ?? 'Failed to create order';
        print("Payment Order Creation Failed: $msg");
        AppSnackBar.show(context, msg, isError: true);
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      print("Payment Exception: $errorMsg");
      AppSnackBar.show(context, errorMsg, isError: true);
    }
  }
}
