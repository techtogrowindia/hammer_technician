// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'package:hammer_app/core/utils/service_locators.dart';
import 'package:hammer_app/features/profile/cubit/general_profile_cubit.dart';
import 'package:hammer_app/features/profile/cubit/general_profile_state.dart';
import 'package:hammer_app/features/profile/cubit/profile_cubit.dart';
import 'package:hammer_app/features/profile/cubit/profile_state.dart';
import 'package:hammer_app/features/profile/data/models/festival_model.dart';
import 'package:hammer_app/features/profile/data/models/general_profile_model.dart';
import 'package:hammer_app/features/profile/data/models/profile_response_model.dart';
import 'package:hammer_app/features/profile/presentation/general_profile_edit_sheet.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';
import 'package:hammer_app/core/utils/snackbar_utils.dart';
import 'package:hammer_app/features/kyc/presentation/stepper/kyc_data_loader.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late GeneralProfileCubit _generalCubit;
  String? _token;
  Map<String, dynamic>? _fullKycData;


  @override
  void initState() {
    super.initState();
    _loadToken();
    context.read<ProfileCubit>().loadProfile();
    _generalCubit = sl<GeneralProfileCubit>();
    _generalCubit.loadGeneralProfile();
    _fetchKycData();
  }

  Future<void> _fetchKycData() async {
    final data = await KycDataLoader.fetchFullKyc();
    if (mounted) {
      setState(() {
        _fullKycData = data;
      });
    }
  }


  Future<void> _loadToken() async {
    final token = await SharedPrefsHelper.getToken();
    if (mounted) {
      setState(() {
        _token = token;
      });
    }
  }

  @override
  void dispose() {
    _generalCubit.close();
    super.dispose();
  }

  // ──────────────────────────── HELPERS ────────────────────────────

  String _fmt(String? value) {
    if (value == null || value.isEmpty || value == "None") return 'Not set';
    final v = value.toLowerCase().replaceAll('_', ' ');
    return v[0].toUpperCase() + v.substring(1);
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

  // ──────────────────────────── ADAPTIVE BUILD ────────────────────────────

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: null,
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
            bloc: _generalCubit,
            builder: (context, gpState) {
              final gp = gpState is GeneralProfileLoaded
                  ? gpState.profile
                  : (gpState is GeneralProfileUpdating
                        ? gpState.profile
                        : null);

              final festivals = gpState is GeneralProfileLoaded
                  ? gpState.festivals
                  : (gpState is GeneralProfileUpdating
                        ? gpState.festivals
                        : <Festival>[]);

              final progress = _calculateProgress(gp);

              return CustomScrollView(
                slivers: [
                  _buildAdaptiveHeroHeader(context, profile, gp, sw, sh),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                      child: Column(
                        children: [
                          _buildProfileStrength(sw, sh, progress),

                          SizedBox(height: sh * 0.02),
                          _buildSectionTitle("Detail Information"),
                          _buildDetailedTile(
                            Icons.person_rounded,
                            "Profile Name",
                            profile?.name ?? "Not set",
                            null,
                            sw,
                            profile?.name != null,
                            isReadOnly: true,
                          ),
                          _buildDetailedTile(
                            Icons.fingerprint_rounded,
                            "User ID",
                            profile?.uniqueId ?? "Not set",
                            null,
                            sw,
                            profile?.uniqueId != null,
                            isReadOnly: true,
                          ),
                          _buildDetailedTile(
                            Icons.phone_android_rounded,
                            "Mobile Number",
                            profile?.mobile ?? "Not set",
                            null,
                            sw,
                            profile?.mobile != null,
                            isReadOnly: true,
                            statusLabel: (profile?.mobileVerified ?? false) ? "Verified" : null,
                          ),
                          _buildDetailedTile(
                            Icons.email_rounded,
                            "Email Address",
                            profile?.email ?? "Not set",
                            null,
                            sw,
                            profile?.email != null,
                            isReadOnly: true,
                          ),

                          SizedBox(height: sh * 0.02),
                          _buildSectionTitle("Registration & Verifications"),
                          _buildDetailedTile(
                            Icons.verified_user_rounded,
                            "KYC Status",
                            _fmt(profile?.kycStatus).toUpperCase(),
                            null, // Read-only status
                            sw,
                            profile?.kycStatus == 'verified',
                            isReadOnly: true,
                            statusLabel: "KYC Unit Verified",
                          ),
                          _buildDetailedTile(
                            Icons.policy_rounded,
                            "Police Verification",
                            _fmt(gp?.policeVerification?.provisionStatus),
                            (gp?.policeVerification?.provisionStatus != 'provided') ? () => _editPolice(gp) : null,
                            sw,
                            gp?.policeVerification?.provisionStatus == 'provided',
                            isReadOnly: gp?.policeVerification?.provisionStatus == 'provided',
                            statusLabel: gp?.policeVerification?.provisionStatus == 'provided' ? "Completed" : null,
                          ),
                          _buildDetailedTile(
                            Icons.account_balance_wallet_rounded,
                            "Initial Deposit",
                            profile?.initialDeposit == 'paid' ? "Successful (₹${profile?.initialDepositAmount ?? 0})" : "Pending",
                            null, // Status display
                            sw,
                            profile?.initialDeposit == 'paid',
                            isReadOnly: true,
                            statusLabel: profile?.initialDeposit == 'paid' ? "Confirmed" : "Action Required",
                          ),

                          SizedBox(height: sh * 0.02),
                          _buildSectionTitle("Selected Benefits & Details"),
                          _buildDetailedTile(
                            Icons.celebration_rounded,
                            "Bonus",
                            (gp?.bonusPoints?.festivalSelection?.isNotEmpty ?? false)
                                ? "${gp?.bonusPoints?.festivalSelection?.length} Festival Selected"
                                : "No festivals selected",
                            (gp?.bonusPoints?.festivalSelection?.isEmpty ?? true) 
                                ? () => _editBonusPoints(gp, festivals) 
                                : null,
                            sw,
                            gp?.bonusPoints?.festivalSelection?.isNotEmpty ?? false,
                            statusLabel: "Selected",
                            showEditIcon: (gp?.bonusPoints?.festivalSelection?.isEmpty ?? true),
                          ),
                          _buildDetailedTile(
                            Icons.card_membership_rounded,
                            "Govt Welfare Card",
                            _fmt(gp?.govtWelfareCard?.cardTypeSchemeName),
                            (gp?.govtWelfareCard?.haveWelfareCard != true) 
                                ? () => _editWelfare(gp) 
                                : null,
                            sw,
                            gp?.govtWelfareCard?.haveWelfareCard == true,
                            statusLabel: "Registered",
                            showEditIcon: (gp?.govtWelfareCard?.haveWelfareCard != true),
                          ),
                          _buildDetailedTile(
                            Icons.account_balance_rounded,
                            "Economic/Bank Details",
                            _fmt(gp?.earningScreen?.paymentMethod),
                            () => _editEarning(gp), // Perpetually editable
                            sw,
                            gp?.earningScreen?.paymentMethod != null,
                            statusLabel: "Provided",
                          ),
                          _buildDetailedTile(
                            Icons.health_and_safety_rounded,
                            "Personal Insurance",
                            _fmt(gp?.insuranceDetails?.insuranceProvider),
                            (gp?.insuranceDetails?.insuranceProvider == null) ? () => _editInsurance(gp) : null,
                            sw,
                            gp?.insuranceDetails?.insuranceProvider != null,
                            isReadOnly: gp?.insuranceDetails?.insuranceProvider != null,
                            statusLabel: "Provided",
                          ),

                          SizedBox(height: sh * 0.02),
                          _buildSectionTitle("Other Information"),
                          _buildDetailedTile(
                            Icons.family_restroom_rounded,
                            "Marital & Nominees",
                            (gp?.maritalInfo?.isMarried ?? false)
                                ? "${gp?.spouseEmergency?.spouseName ?? 'Married'} | ${(gp?.maritalInfo?.nominees?.length ?? 0)} Nominees"
                                : "Single | ${(gp?.maritalInfo?.nominees?.length ?? 0)} Nominees",
                            () => _editMarital(gp), // Perpetually editable
                            sw,
                            gp?.maritalInfo?.isMarried != null,
                          ),
                          _buildDetailedTile(
                            Icons.emergency_share_rounded,
                            "Emergency Contact (SOS)",
                            _fmt(gp?.spouseEmergency?.emergencyContactNoSos),
                            (gp?.spouseEmergency?.emergencyContactNoSos == null) ? () => _editSpouseEmergency(gp) : null,
                            sw,
                            gp?.spouseEmergency?.emergencyContactNoSos != null,
                            isReadOnly: gp?.spouseEmergency?.emergencyContactNoSos != null,
                          ),
                          _buildDetailedTile(
                            Icons.work_history_rounded,
                            "Employee Detail",
                            _fmt(gp?.employeeNumber?.employeeId),
                            (gp?.employeeNumber?.employeeId == null) ? () => _editEmployee(gp) : null,
                            sw,
                            gp?.employeeNumber?.employeeId != null,
                            isReadOnly: gp?.employeeNumber?.employeeId != null,
                          ),
                          _buildDetailedTile(
                            Icons.wc_rounded,
                            "Gender",
                            _fmt(gp?.genderInfo?.genderIdentity),
                            (gp?.genderInfo?.genderIdentity == null) ? () => _editGender(gp) : null,
                            sw,
                            gp?.genderInfo?.genderIdentity != null,
                            isReadOnly: gp?.genderInfo?.genderIdentity != null,
                          ),
                          _buildDetailedTile(
                            Icons.checkroom_rounded,
                            "T-Shirt Size",
                            _fmt(gp?.utilityTshirt?.tshirtSize),
                            () => _editTshirt(gp), // Perpetually editable
                            sw,
                            gp?.utilityTshirt?.tshirtSize != null,
                          ),

                          SizedBox(height: sh * 0.06),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ──────────────────────────── COMPONENTS ────────────────────────────

  Widget _buildProfileStrength(double sw, double sh, double progress) {
    return Container(
      margin: EdgeInsets.only(top: sh * 0.07, bottom: sh * 0.02),
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.05),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Profile Strength",
                style: TextStyle(
                  fontSize: sw * 0.035,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: TextStyle(
                  fontSize: sw * 0.035,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryAmber,
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.015),
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 8,
                width: sw * 0.84 * progress,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primaryAmber,
                      AppColors.primaryAmberLogo,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveHeroHeader(
    BuildContext context,
    UserProfile? profile,
    GeneralProfile? gp,
    double sw,
    double sh,
  ) {
    final mq = MediaQuery.of(context);
    final headerHeight = sh * 0.35;
    return SliverToBoxAdapter(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: _AdaptiveHeaderClipper(),
            child: Container(
              height: headerHeight,
              width: sw,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryAmber,
                    AppColors.primaryAmberLogo,
                    AppColors.primaryAmber,
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: sh * 0.05,
                    right: -sw * 0.1,
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(
                        Icons.bolt_rounded,
                        size: sw * 0.5,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: sh * 0.08,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: sw * 0.23,
                      height: sw * 0.23,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          width: 4,
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: sw * 0.1,
                      backgroundColor: Colors.white,
                      backgroundImage: (profile?.documentKycUrls?['photo'] != null && _token != null)
                          ? NetworkImage(
                              profile!.documentKycUrls!['photo']!,
                              headers: {'Authorization': 'Bearer $_token'},
                            )
                          : null,
                      child: (profile?.documentKycUrls?['photo'] == null || _token == null)
                          ? Icon(
                              Icons.person_rounded,
                              size: sw * 0.1,
                              color: AppColors.primaryBlue,
                            )
                          : null,
                    ),
                  ],
                ),
                SizedBox(height: sh * 0.015),
                Text(
                  profile?.name ?? "HAMMER TECH",
                  style: TextStyle(
                    fontSize: sw * 0.055,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryBlue,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: sh * 0.005),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.03,
                    vertical: sh * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(sw * 0.02),
                  ),
                  child: Text(
                    profile?.uniqueId ?? "ID: ---",
                    style: TextStyle(
                      fontSize: sw * 0.028,
                      color: AppColors.primaryBlue.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: -sh * 0.04,
            left: sw * 0.04,
            right: sw * 0.04,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: sh * 0.02,
                horizontal: sw * 0.05,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(sw * 0.06),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _adaptiveContactItem(
                    Icons.phone_android_rounded,
                    profile?.mobile ?? "---",
                    sw,
                    isVerified: profile?.mobileVerified ?? false,
                  ),
                  Container(
                    width: 1,
                    height: sh * 0.035,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  _adaptiveContactItem(
                    Icons.email_outlined,
                    profile?.email ?? "---",
                    sw,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: mq.padding.top + 8,
            left: 10,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primaryBlue,
                size: sw * 0.05,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _adaptiveContactItem(
    IconData icon,
    String value,
    double sw, {
    bool isVerified = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: sw * 0.045, color: AppColors.primaryBlue),
          SizedBox(height: sw * 0.015),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: sw * 0.028,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isVerified) ...[
                SizedBox(width: sw * 0.01),
                Icon(
                  Icons.verified_rounded,
                  size: sw * 0.03,
                  color: Colors.green,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptivePaymentHub(UserProfile? profile, double sw, double sh) {
    final isPaid = profile?.initialDeposit == 'paid';
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(sw * 0.05),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.03),
            decoration: BoxDecoration(
              color: isPaid
                  ? Colors.green.withOpacity(0.2)
                  : Colors.amber.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPaid
                  ? Icons.check_circle_rounded
                  : Icons.pending_actions_rounded,
              color: isPaid ? Colors.greenAccent : Colors.amberAccent,
              size: sw * 0.07,
            ),
          ),
          SizedBox(width: sw * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Initial Deposit Status",
                  style: TextStyle(
                    fontSize: sw * 0.03,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: sh * 0.002),
                Text(
                  isPaid
                      ? "SUCCESSFUL (₹${profile?.initialDepositAmount ?? 0})"
                      : "PAYMENT PENDING",
                  style: TextStyle(
                    fontSize: sw * 0.038,
                    fontWeight: FontWeight.w900,
                    color: isPaid ? Colors.greenAccent : Colors.amberAccent,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "KYC UNIT",
                style: TextStyle(
                  fontSize: sw * 0.022,
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _fmt(profile?.kycStatus).toUpperCase(),
                style: TextStyle(
                  fontSize: sw * 0.028,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Builder(
      builder: (context) {
        final sw = MediaQuery.of(context).size.width;
        return Padding(
          padding: EdgeInsets.fromLTRB(sw * 0.01, sw * 0.03, 0, sw * 0.03),
          child: Row(
            children: [
              Container(
                width: sw * 0.01,
                height: sw * 0.035,
                decoration: BoxDecoration(
                  color: AppColors.primaryAmber,
                  borderRadius: BorderRadius.circular(sw * 0.005),
                ),
              ),
              SizedBox(width: sw * 0.025),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: sw * 0.03,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryBlue,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // NEW: Modern Detailed List Tile
  Widget _buildDetailedTile(
    IconData icon,
    String title,
    String value,
    VoidCallback? onEdit,
    double sw,
    bool isComplete, {
    bool isReadOnly = false,
    String? statusLabel,
    bool showEditIcon = true,
  }) {
    final canEdit = onEdit != null && !isReadOnly;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: InkWell(
        onTap: canEdit ? onEdit : null,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: sw * 0.04),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(sw * 0.02),
                decoration: BoxDecoration(
                  color: (isComplete ? Colors.green : AppColors.primaryAmber)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: sw * 0.05,
                  color: isComplete ? Colors.green : AppColors.primaryAmber,
                ),
              ),
              SizedBox(width: sw * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: sw * 0.03,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: sw * 0.005),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: sw * 0.035,
                        fontWeight: FontWeight.w900,
                        color: isComplete ? Colors.green[700] : AppColors.primaryBlue,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (statusLabel != null && isComplete)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: EdgeInsets.only(right: canEdit ? 8 : 0),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: sw * 0.022,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  if (canEdit && showEditIcon)
                    Icon(
                      Icons.edit_note_rounded,
                      size: sw * 0.05,
                      color: AppColors.primaryAmber,
                    )
                  else if (isComplete && statusLabel == null)
                    Icon(
                      Icons.verified_rounded,
                      size: sw * 0.045,
                      color: Colors.green,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────── EDIT HANDLERS ────────────────────────────

  Future<void> _editMarital(GeneralProfile? gp) async {
    final m = gp?.maritalInfo;
    final s = gp?.spouseEmergency;
    
    // Map existing nominees to the format expected by the edit sheet
    final initialNominees = m?.nominees?.map((n) => {
      'name': n.name ?? '',
      'aadhar_card_no': n.aadharCardNo ?? '',
      'phone_number': n.phoneNumber ?? '',
      'percentage': n.percentage ?? 0,
    }).toList() ?? [];

    // Fallback to legacy fields if nominees array is empty
    if (initialNominees.isEmpty && m?.nomineeName != null) {
      initialNominees.add({
        'name': m?.nomineeName ?? '',
        'aadhar_card_no': m?.nomineeAadharCardNo ?? '',
        'phone_number': m?.nomineePhoneNumber ?? '',
        'percentage': 100,
      });
    }

    final result = await showProfileEditSheet(
      context: context,
      title: "Marital & Nominee Info",
      fields: [
        EditField(
          key: 'is_married',
          label: 'Are you married?',
          initialValue: m?.isMarried ?? false,
          type: EditFieldType.toggle,
        ),
        EditField(
          key: 'spouse_name',
          label: 'Spouse Name',
          initialValue: s?.spouseName,
          dependsOnKey: 'is_married',
          dependsOnValue: true,
        ),
        EditField(
          key: 'marriage_date',
          label: 'Marriage Date',
          initialValue: s?.marriageDate,
          type: EditFieldType.date,
          dependsOnKey: 'is_married',
          dependsOnValue: true,
        ),
        EditField(
          key: 'nominees',
          label: 'Nominees',
          initialValue: initialNominees,
          type: EditFieldType.nomineeList,
        ),
      ],
    );

    if (result != null) {
      // Validation: Total percentage must be <= 100
      final nominees = result['nominees'] as List?;
      if (nominees != null) {
        int total = 0;
        for (var n in nominees) {
          total += (n['percentage'] as int? ?? 0);
        }
        if (total > 100) {
          showSnackBar(context, "Total nominee percentage cannot exceed 100%", isError: true);
          return;
        }
      }
      _submitFields(result);
    }
  }

  Future<void> _editSpouseEmergency(GeneralProfile? gp) async {
    final s = gp?.spouseEmergency;
    final result = await showProfileEditSheet(
      context: context,
      title: "Emergency & SOS",
      fields: [
        EditField(
          key: 'emergency_contact_no_sos',
          label: 'SOS Contact',
          initialValue: s?.emergencyContactNoSos,
          type: EditFieldType.phone,
        ),
      ],
    );
    if (result != null) {
      result['sos_visibility'] = true;
      _submitFields(result);
    }
  }

  Future<void> _editBonusPoints(
    GeneralProfile? gp,
    List<Festival> festivals,
  ) async {
    final result = await showProfileEditSheet(
      context: context,
      title: "Festivals",
      fields: [
        EditField(
          key: 'festival_selection',
          label: 'Select Festivals',
          initialValue: gp?.bonusPoints?.festivalSelection ?? [],
          type: EditFieldType.multiSelect,
          dropdownOptions: festivals.map((f) => f.name).toList(),
        ),
      ],
    );
    if (result != null) _submitFields(result);
  }

  Future<void> _editGender(GeneralProfile? gp) async {
    final result = await showProfileEditSheet(
      context: context,
      title: "Gender",
      fields: [
        EditField(
          key: 'gender_identity',
          label: 'Gender Identity',
          initialValue: gp?.genderInfo?.genderIdentity,
          type: EditFieldType.dropdown,
          dropdownOptions: ['male', 'female', 'other'],
        ),
      ],
    );
    if (result != null) _submitFields(result);
  }

  Future<void> _editTshirt(GeneralProfile? gp) async {
    final result = await showProfileEditSheet(
      context: context,
      title: "T-Shirt Size",
      fields: [
        EditField(
          key: 'tshirt_size',
          label: 'Select Size',
          initialValue: gp?.utilityTshirt?.tshirtSize,
          type: EditFieldType.dropdown,
          dropdownOptions: ['S', 'M', 'L', 'XL', 'XXL', 'XXXL'],
        ),
        EditField(
          key: 'colour_preference',
          label: 'Color Preference',
          initialValue: gp?.utilityTshirt?.colourPreference,
          type: EditFieldType.dropdown,
          dropdownOptions: [
            'Black',
            'White',
            'Navy Blue',
            'Royal Blue',
            'Red',
            'Grey',
            'Maroon',
            'Green',
            'Yellow',
            'Orange'
          ],
        ),
      ],
    );
    if (result != null) _submitFields(result);
  }

  Future<void> _editEmployee(GeneralProfile? gp) async {
    final result = await showProfileEditSheet(
      context: context,
      title: "Employee Details",
      fields: [
        EditField(
          key: 'employee_id',
          label: 'Employee ID',
          initialValue: gp?.employeeNumber?.employeeId,
        ),
        EditField(
          key: 'department',
          label: 'Department',
          initialValue: gp?.employeeNumber?.department,
        ),
        EditField(
          key: 'designation',
          label: 'Designation',
          initialValue: gp?.employeeNumber?.designation,
        ),
        EditField(
          key: 'joining_date',
          label: 'Joining Date',
          initialValue: gp?.employeeNumber?.joiningDate,
          type: EditFieldType.date,
        ),
      ],
    );
    if (result != null) _submitFields(result);
  }

  Future<void> _editWelfare(GeneralProfile? gp) async {
    final w = gp?.govtWelfareCard;
    final result = await showProfileEditSheet(
      context: context,
      title: "Govt Welfare Card",
      fields: [
        EditField(
          key: 'have_welfare_card',
          label: 'Welfare Card?',
          initialValue: w?.haveWelfareCard ?? false,
          type: EditFieldType.toggle,
        ),
        EditField(
          key: 'welfare_card_type_scheme_name',
          label: 'Scheme Name',
          initialValue: w?.cardTypeSchemeName,
        ),
        EditField(
          key: 'welfare_card_expiry_date',
          label: 'Expiry Date',
          initialValue: w?.cardExpiryDate,
          type: EditFieldType.date,
        ),
        EditField(
          key: 'card_image',
          label: 'Upload Card Image',
          type: EditFieldType.file,
        ),
      ],
    );
    if (result != null) _submitFields(result);
  }

  Future<void> _editPolice(GeneralProfile? gp) async {
    final p = gp?.policeVerification;
    final result = await showProfileEditSheet(
      context: context,
      title: "Police Verification",
      fields: [
        EditField(
          key: 'police_certificate_number',
          label: 'Cert Number',
          initialValue: p?.certificateNumber,
        ),
        EditField(
          key: 'police_issued_by',
          label: 'Issued By',
          initialValue: p?.issuedBy,
        ),
        EditField(
          key: 'police_issue_date',
          label: 'Issue Date',
          initialValue: p?.issueDate,
          type: EditFieldType.date,
        ),
        EditField(
          key: 'police_provision_status',
          label: 'Status',
          initialValue: p?.provisionStatus,
          type: EditFieldType.dropdown,
          dropdownOptions: ['provided', 'pending'],
        ),
        EditField(
          key: 'upload_document',
          label: 'Upload Document',
          type: EditFieldType.file,
        ),
      ],
    );
    if (result != null) _submitFields(result);
  }

  Future<void> _editInsurance(GeneralProfile? gp) async {
    final i = gp?.insuranceDetails;
    final result = await showProfileEditSheet(
      context: context,
      title: "Insurance Details",
      fields: [
        EditField(
          key: 'insurance_provider',
          label: 'Provider',
          initialValue: i?.insuranceProvider,
        ),
        EditField(
          key: 'policy_number',
          label: 'Policy Number',
          initialValue: i?.policyNumber,
        ),
        EditField(
          key: 'policy_start_date',
          label: 'Start Date',
          initialValue: i?.policyStartDate,
          type: EditFieldType.date,
        ),
        EditField(
          key: 'policy_expiry_date',
          label: 'Expiry Date',
          initialValue: i?.policyExpiryDate,
          type: EditFieldType.date,
        ),
        EditField(
          key: 'upload_insurance_document',
          label: 'Policy Document',
          type: EditFieldType.file,
        ),
      ],
    );
    if (result != null) _submitFields(result);
  }

  Future<void> _editEarning(GeneralProfile? gp) async {
    final e = gp?.earningScreen;

    // Autofetch if local earning screen is empty
    String? bankName = e?.paymentMethod;
    String? accNo = e?.bankAccountNumber;
    String? ifsc = e?.ifscCode;
    String? upi = e?.upiId;

    if ((bankName == null || bankName.isEmpty) && (accNo == null || accNo.isEmpty)) {
      if (_fullKycData == null) {
        // Fallback: Fetch if not already available
        _fullKycData = await KycDataLoader.fetchFullKyc();
      }

      if (_fullKycData != null) {
        final bankKyc = _fullKycData!['bank_kyc'];
        if (bankKyc != null) {
          if (bankName == null || bankName.isEmpty) bankName = bankKyc['bank_name']?.toString();
          if (accNo == null || accNo.isEmpty) accNo = bankKyc['account_number']?.toString();
          if (ifsc == null || ifsc.isEmpty) ifsc = bankKyc['ifsc_code']?.toString();
          if (upi == null || upi.isEmpty) upi = bankKyc['upi_id']?.toString();
        }
      }
    }

    final result = await showProfileEditSheet(
      context: context,
      title: "Economic Details",
      fields: [
        EditField(
          key: 'payment_method',
          label: 'Bank Name',
          initialValue: bankName,
        ),
        EditField(
          key: 'bank_account_number',
          label: 'Account Number',
          initialValue: accNo,
        ),
        EditField(
          key: 'ifsc_code',
          label: 'IFSC Code',
          initialValue: ifsc,
        ),
        EditField(key: 'upi_id', label: 'UPI ID', initialValue: upi),
      ],
    );
    if (result != null) _submitFields(result);
  }


  Future<void> _submitFields(Map<String, dynamic> result) async {
    final fields = <String, dynamic>{};
    final files = <String, File>{};
    for (final e in result.entries) {
      if (e.value is File)
        files[e.key] = e.value as File;
      else
        fields[e.key] = e.value;
    }
    if (fields.isEmpty && files.isEmpty) return;
    try {
      await _generalCubit.updateGeneralProfile(
        fields: fields,
        files: files.isNotEmpty ? files : null,
      );
      if (mounted) {
        showSnackBar(context, "Profile updated successfully", isError: false);
        context.read<ProfileCubit>().loadProfile();
      }
    } catch (e) {
      if (mounted) showSnackBar(context, e.toString(), isError: true);
    }
  }

  void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    AppSnackBar.show(context, message, isError: isError);
  }
}

class _AdaptiveHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.82);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.82,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
