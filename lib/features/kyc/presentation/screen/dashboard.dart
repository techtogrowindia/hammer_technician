// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'package:hammer_app/features/common/cubit/dynamic_content_cubit.dart';
import 'package:hammer_app/features/common/cubit/dynamic_content_state.dart';
import 'package:hammer_app/features/login/presentation/screens/login_screen.dart';
import 'package:hammer_app/features/logout/exit_dialog.dart';
import 'package:hammer_app/features/logout/logout_service.dart';
import 'package:hammer_app/features/logout/delete_account_service.dart';
import 'package:hammer_app/features/profile/cubit/profile_cubit.dart';
import 'package:hammer_app/features/profile/cubit/profile_state.dart';
import 'package:hammer_app/features/profile/cubit/general_profile_cubit.dart';
import 'package:hammer_app/features/profile/cubit/general_profile_state.dart';
import 'package:hammer_app/features/profile/data/models/profile_response_model.dart';
import 'package:hammer_app/features/profile/data/models/general_profile_model.dart';
import 'package:hammer_app/features/profile/presentation/profile_screen.dart';
import 'package:hammer_app/features/profile/presentation/general_profile_edit_sheet.dart';
import 'package:hammer_app/features/service/presenation/service_screen.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';
import 'package:local_auth/local_auth.dart';
import 'package:hammer_app/core/utils/snackbar_utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _token;
  bool _biometricEnabled = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = await SharedPrefsHelper.getToken();
    final biometricEnabled = await SharedPrefsHelper.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _token = token;
        _biometricEnabled = biometricEnabled;
      });
    }
    context.read<ProfileCubit>().loadProfile();
    context.read<GeneralProfileCubit>().loadGeneralProfile();
    context.read<DynamicContentCubit>().fetchDynamicContent();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      drawer: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) => _buildDrawer(context, state),
      ),
      floatingActionButton:
          BlocBuilder<GeneralProfileCubit, GeneralProfileState>(
            builder: (context, state) {
              final gp = state is GeneralProfileLoaded ? state.profile : null;
              return FloatingActionButton.extended(
                onPressed: () => _editSpouseEmergency(gp),
                backgroundColor: AppColors.danger,
                icon: const Icon(
                  Icons.emergency_share_rounded,
                  color: Colors.white,
                ),
                label: const Text(
                  "SOS",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              );
            },
          ),
      appBar: null,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          if (profileState is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryAmber),
            );
          }
          final profile = profileState is ProfileLoaded
              ? profileState.profile
              : null;

          return BlocBuilder<GeneralProfileCubit, GeneralProfileState>(
            builder: (context, gpState) {
              final gp = gpState is GeneralProfileLoaded
                  ? gpState.profile
                  : null;

              return RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.primaryAmber,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopHeader(context, sw, mq.padding.top, profile),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: sw * 0.07),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: sh * 0.03),
                            _buildDynamicNote(sw),
                            SizedBox(height: sh * 0.03),
                            _buildIDCard(sw, profile, gp),
                            SizedBox(height: sh * 0.04),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTopHeader(
    BuildContext context,
    double sw,
    double topPadding,
    UserProfile? profile,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(sw * 0.05, topPadding + 10, sw * 0.05, 15),
      decoration: const BoxDecoration(
        color: AppColors.primaryAmber,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: Icon(
              Icons.sort_rounded,
              color: AppColors.primaryBlue,
              size: sw * 0.08,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Spacer(),
          Text(
            "HAMMER",
            style: TextStyle(
              fontSize: sw * 0.045,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: AppColors.primaryBlue,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: CircleAvatar(
                radius: sw * 0.06,
                backgroundColor: Colors.white,
                backgroundImage:
                    (profile?.documentKycUrls?['photo'] != null &&
                        _token != null)
                    ? NetworkImage(
                        profile!.documentKycUrls!['photo']!,
                        headers: {'Authorization': 'Bearer $_token'},
                      )
                    : null,
                child:
                    (profile?.documentKycUrls?['photo'] == null ||
                        _token == null)
                    ? Icon(
                        Icons.person_rounded,
                        size: sw * 0.045,
                        color: AppColors.primaryBlue,
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicNote(double sw) {
    return BlocBuilder<DynamicContentCubit, DynamicContentState>(
      builder: (context, state) {
        String message =
            "வரவேற்பதில் பெருமிதம் கொள்கிறோம்! 🎉\n\nநமது ஹேமர் (Hammer) நிறுவனத்துடன் இணைந்துள்ள புதிய சேவை வழங்குநரை ஹேமர் குழுமம் மற்றும் அதன் நிறுவனர்கள் சார்பாக அன்போடு, நெஞ்சார வரவேற்கிறோம்! 🤝\n\nவாடிக்கையாளர்களுக்குத் தரமான, நம்பிக்கையான சேவைகளை \"ஒரே டச்சில்\" (One Tap) கொண்டு சேர்க்கும் நமது லட்சியப் பயணத்தில், உங்கள் பங்களிப்பு மிக முக்கியமானது.\n\nஉங்கள் வளர்ச்சிக்கும், வெற்றிக்கும் ஹேமர் குழுமம் என்றும் உறுதுணையாக இருக்கும்.\n\nஇணைந்து வளர்வோம்... வெற்றியைப் பகிர்வோம்! 🚀";
        if (state is DynamicContentLoaded) {
          message = state.model.data?.positiveMessage ?? message;
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Brand Accent Bar
                Container(
                  width: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryAmber,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "OFFICIAL BULLETIN",
                              style: TextStyle(
                                color: AppColors.primaryBlue.withOpacity(0.4),
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.verified_user_rounded,
                              color: AppColors.primaryBlue.withOpacity(0.1),
                              size: 16,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          message,
                          style: TextStyle(
                            fontSize: sw * 0.046,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                            height: 1.5,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Hammer Home Fix updates will appear here.",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black38,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Drawer _buildDrawer(BuildContext context, ProfileState state) {
    final name = state is ProfileLoaded
        ? (state.profile.name ?? 'User')
        : 'Loading...';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final profile = state is ProfileLoaded ? state.profile : null;

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primaryAmber),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      (profile?.documentKycUrls?['photo'] != null &&
                          _token != null)
                      ? NetworkImage(
                          profile!.documentKycUrls!['photo']!,
                          headers: {'Authorization': 'Bearer $_token'},
                        )
                      : null,
                  child:
                      (profile?.documentKycUrls?['photo'] == null ||
                          _token == null)
                      ? Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryAmber,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  "Hammer Partner",
                  style: TextStyle(
                    color: AppColors.primaryBlue.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(Icons.person_outline_rounded, "Profile Status", () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          }),
          _drawerItem(Icons.work_outline_rounded, "Service Catalog", () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ServicesPage()),
            );
          }),
          _drawerItem(
            _biometricEnabled ? Icons.fingerprint : Icons.fingerprint_outlined,
            _biometricEnabled ? "Disable Biometric" : "Enable Biometric",
            () async {
              Navigator.pop(context);
              await _toggleBiometricFromDrawer();
            },
          ),
          const SizedBox(height: 20),
          const Divider(indent: 20, endIndent: 20),
          _drawerItem(Icons.logout_rounded, "Log Out", () async {
            final shouldExit = await ExitConfirmation.show(
              context,
              message: 'Log out from the app?',
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
          }, color: Colors.black87),
          _drawerItem(Icons.delete_forever_rounded, "Delete Account", () async {
            final shouldDelete = await ExitConfirmation.show(
              context,
              title: 'Delete Account?',
              message:
                  'This will permanently delete your account and all related data. This action cannot be undone.',
              confirmText: 'Delete',
            );
            if (shouldDelete) {
              final techId = profile?.id;
              if (techId != null) {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                );

                final success =
                    await DeleteAccountService.deleteTechnicianAccount(techId);

                // Remove loading indicator
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
          }, color: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primaryBlue),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color ?? AppColors.primaryBlue,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> _toggleBiometricFromDrawer() async {
    if (_biometricEnabled) {
      await SharedPrefsHelper.setBiometricEnabled(false);
      if (!mounted) return;
      setState(() => _biometricEnabled = false);
      AppSnackBar.show(context, "Biometric login disabled.");
      return;
    }

    final canCheck = await _localAuth.canCheckBiometrics;
    final supported = await _localAuth.isDeviceSupported();
    if (!canCheck && !supported) {
      if (!mounted) return;
      if (!mounted) return;
      AppSnackBar.show(
        context,
        "Biometric authentication is not available on this device.",
        isError: true,
      );
      return;
    }

    final enable = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Enable Biometric Login"),
        content: const Text(
          "Use fingerprint/face authentication for faster login?",
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
      ),
    );

    if (enable == true) {
      await SharedPrefsHelper.setBiometricEnabled(true);
      if (!mounted) return;
      setState(() => _biometricEnabled = true);
      AppSnackBar.show(context, "Biometric login enabled.");
    }
  }

  Widget _buildIDCard(double sw, UserProfile? profile, GeneralProfile? gp) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardW = constraints.maxWidth;
        final circleD = cardW * 1.6;

        return Column(
          children: [
            // FRONT
            Container(
              height: 520,
              width: cardW,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    // Top curve
                    Positioned(
                      top: 150 - circleD, // Bottom edge at 150
                      left: -(circleD - cardW) / 2,
                      child: Container(
                        width: circleD,
                        height: circleD,
                        decoration: BoxDecoration(
                          color: AppColors.primaryAmber,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryBlue,
                            width: 6,
                          ),
                        ),
                      ),
                    ),
                    // Header Logo & Text
                    Positioned(
                      top: 25,
                      left: 15,
                      right: 15,
                      child: Row(
                        children: [
                          // Logo
                          Container(
                            width: 65,
                            height: 65,
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                'assets/images/hammer.png',
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => const Icon(
                                  Icons.home_repair_service_rounded,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Texts
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "HAMMER",
                                  style: TextStyle(
                                    fontSize: cardW * 0.08,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryBlue,
                                    letterSpacing: 1.0,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "HOME FIX SOLUTION PRIVATE LIMITED",
                                  style: TextStyle(
                                    fontSize: cardW * 0.025,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "All services in one Tap 👆",
                                  style: TextStyle(
                                    fontSize: cardW * 0.03,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Profile Photo
                    Positioned(
                      top: 90,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 140,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: AppColors.primaryBlue,
                              width: 4,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(21),
                            child: profile?.documentKycUrls?['photo'] != null
                                ? Image.network(
                                    profile!.documentKycUrls!['photo']!,
                                    headers: _token != null
                                        ? {'Authorization': 'Bearer $_token'}
                                        : null,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => const Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                      ),
                    ),
                    // Details
                    Positioned(
                      top: 280,
                      left: cardW * 0.08,
                      right: cardW * 0.08,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow("NAME", profile?.name ?? '---'),
                          const SizedBox(height: 18),
                          _infoRow("ROLE", "Technician"),
                          const SizedBox(height: 18),
                          _infoRow("ID", profile?.uniqueId ?? '---'),
                          const SizedBox(height: 18),
                          _infoRow("🩸 GROUP", profile?.bloodGroup ?? '---'),
                        ],
                      ),
                    ),
                    // QR Code Box
                    Positioned(
                      bottom: 25,
                      right: 25,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black54, width: 1.5),
                          color: Colors.white,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "QR",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    // Bottom Strip
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 12,
                        color: AppColors.primaryAmber,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // BACK
            Container(
              height: 520,
              width: cardW,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    // Text Content
                    Positioned(
                      top: 50,
                      left: 20,
                      right: 20,
                      child: Column(
                        children: [
                          const Text(
                            "Company Address:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "No. 75/53, Sabanayagar street,\nChidambaram - 608001.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 25),
                          const Text(
                            "B.O: 865, Cuddalore bypass Road,\nVandigate, Chidambaram.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 35),
                          const Text(
                            "Business Support",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Businesssupport@hammerapp.in",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "🌐 Hammerapp.in",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.message_rounded,
                                color: Colors.green,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "9788990040",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Bottom SOS Curve
                    Positioned(
                      top: 380,
                      left: -(circleD - cardW) / 2,
                      child: Container(
                        width: circleD,
                        height: circleD,
                        decoration: BoxDecoration(
                          color: AppColors.primaryAmber,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryBlue,
                            width: 6,
                          ),
                        ),
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(top: 25),
                        child: const Text(
                          "SOS",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        const Text(
          ":   ",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<void> _editSpouseEmergency(GeneralProfile? gp) async {
    final s = gp?.spouseEmergency;
    final result = await showProfileEditSheet(
      context: context,
      title: "SOS / Emergency Contact",
      fields: [
        EditField(
          key: 'emergency_contact_no_sos',
          label: 'Emergency Mobile Number',
          initialValue: s?.emergencyContactNoSos,
          type: EditFieldType.phone,
        ),
        EditField(
          key: 'spouse_name',
          label: 'Spouse/Relation Name',
          initialValue: s?.spouseName,
        ),
      ],
    );

    if (result != null) {
      result['sos_visibility'] = true;
      context.read<GeneralProfileCubit>().updateGeneralProfile(fields: result);
    }
  }
}
