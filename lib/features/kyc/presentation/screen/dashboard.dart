// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'package:hammer_app/features/common/cubit/dynamic_content_cubit.dart';
import 'package:hammer_app/features/common/cubit/dynamic_content_state.dart';
import 'package:hammer_app/features/login/presentation/screens/login_screen.dart';
import 'package:hammer_app/features/logout/exit_dialog.dart';
import 'package:hammer_app/features/logout/logout_service.dart';
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
import 'package:url_launcher/url_launcher.dart';
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

  double _calculateProgress(GeneralProfile? gp) {
    if (gp == null) return 0.0;
    int filled = 0;
    if (gp.genderInfo?.genderIdentity != null) filled++;
    if (gp.maritalInfo?.isMarried != null) filled++;
    if (gp.spouseEmergency?.emergencyContactNoSos != null) filled++;
    if (gp.govtWelfareCard?.haveWelfareCard != null) filled++;
    if (gp.bonusPoints?.festivalSelection?.isNotEmpty ?? false) filled++;
    if (gp.utilityTshirt?.tshirtSize != null) filled++;
    if (gp.policeVerification?.provisionStatus == 'provided') filled++;
    if (gp.employeeNumber?.employeeId != null) filled++;
    if (gp.insuranceDetails?.insuranceProvider != null) filled++;
    if (gp.earningScreen?.paymentMethod != null) filled++;
    return (filled / 10).clamp(0.0, 1.0);
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
              final progress = _calculateProgress(gp);

              return RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.primaryAmber,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopHeader(context, sw, mq.padding.top),

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

  Widget _buildTopHeader(BuildContext context, double sw, double topPadding) {
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
        ],
      ),
    );

  }

  Widget _buildDynamicNote(double sw) {
    return BlocBuilder<DynamicContentCubit, DynamicContentState>(
      builder: (context, state) {
        String message =
            "Welcome to Hammer Family 👋\nWe are launching soon in your town.";
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
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryAmber,
                    ),
                  ),
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
      AppSnackBar.show(context, "Biometric authentication is not available on this device.", isError: true);
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
    return Column(
      children: [
        // FRONT SIDE
        Container(
          width: double.infinity,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Blue Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 10, bottom: 25),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Column(
                  children: [
                    // Lanyard Slot
                    Container(
                      width: 50,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Logo and Brand
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            // color: Colors.black,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Image.asset(
                              'assets/images/hammer.png',
                              // height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.home_repair_service_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hammer",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              "Home Fix",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Body Section (White background)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Placeholder
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!, width: 2),
                      ),
                      child: Container(
                        width: 90,
                        height: 110,
                        color: Colors.grey[100],
                        child: profile?.documentKycUrls?['photo'] != null
                            ? Image.network(
                                profile!.documentKycUrls!['photo']!,
                                headers: _token != null
                                    ? {'Authorization': 'Bearer $_token'}
                                    : null,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.person_rounded,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                              )
                            : const Icon(
                                Icons.person_rounded,
                                size: 60,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Label
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "Technician",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Name and ID details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _idTextLine("Name: ${profile?.name ?? '---'}"),
                          _idTextLine(
                            "Technician ID: ${profile?.uniqueId ?? '---'}",
                          ),
                          _idTextLine("Role: Service Partner"),
                        ],
                      ),
                    ),
                    // Verification QR
                    Column(
                      children: [
                        const Text(
                          "Verification",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: const Icon(
                            Icons.qr_code_2_rounded,
                            size: 45,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Blue Footer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Blood Group: ${profile?.bloodGroup ?? '---'}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Emergency: ${gp?.spouseEmergency?.emergencyContactNoSos ?? '---'}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // BACK SIDE
        Container(
          width: double.infinity,
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
          child: Column(
            children: [
              // Amber Header
              Container(
                width: double.infinity,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primaryAmber,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),

              // Back Content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.home_repair_service_rounded,
                      color: Colors.black,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Hammer Home\nFix Solution",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "No 75/53, Sabanayagar Street,\nChidambaram - 608001",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 25),
                    _supportRow("Support: support@hammerapp.in"),
                    _supportRow("WhatsApp: 9788990040"),
                    const SizedBox(height: 30),
                    const Text(
                      "This card is property of Hammer Home Fix.\nIf found, please return to the above address.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Amber Footer
              Container(
                width: double.infinity,
                height: 25,
                decoration: const BoxDecoration(
                  color: AppColors.primaryAmber,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _idTextLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _supportRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  Widget _idRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.primaryBlue,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _idFooterRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
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
