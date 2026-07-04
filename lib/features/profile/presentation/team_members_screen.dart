import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'package:hammer_app/core/utils/snackbar_utils.dart';
import '../cubit/team_member_cubit.dart';
import '../cubit/team_member_state.dart';
import '../data/models/team_member_model.dart';

class TeamMembersScreen extends StatefulWidget {
  const TeamMembersScreen({super.key});

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TeamMemberCubit>().loadTeamMembers();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    return BlocListener<TeamMemberCubit, TeamMemberState>(
      listener: (context, state) {
        if (state is TeamMemberActionSuccess) {
          AppSnackBar.show(context, state.message, isError: false);
        } else if (state is TeamMemberError) {
          AppSnackBar.show(context, state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: AppColors.primaryAmber,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Team Members (Child IDs)",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<TeamMemberCubit, TeamMemberState>(
          builder: (context, state) {
            if (state is TeamMemberLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryAmber),
              );
            }

            List<TeamMember> teamMembers = [];
            if (state is TeamMembersLoaded) {
              teamMembers = state.teamMembers;
            } else if (context.read<TeamMemberCubit>().state is TeamMembersLoaded) {
              teamMembers = (context.read<TeamMemberCubit>().state as TeamMembersLoaded).teamMembers;
            }

            if (teamMembers.isEmpty) {
              return _buildEmptyState(sw, sh);
            }

            return RefreshIndicator(
              color: AppColors.primaryAmber,
              onRefresh: () => context.read<TeamMemberCubit>().loadTeamMembers(),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sh * 0.02),
                itemCount: teamMembers.length,
                itemBuilder: (context, index) {
                  return _buildTeamMemberCard(context, teamMembers[index], sw, sh);
                },
              ),
            );
          },
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0E2A66),
                Color(0xFF1A3D7C),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0E2A66).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => _showAddMemberBottomSheet(context),
            backgroundColor: Colors.transparent,
            elevation: 0,
            highlightElevation: 0,
            icon: const Icon(Icons.person_add_rounded, color: Colors.white),
            label: const Text(
              "Add Team Member",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(double sw, double sh) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
        child: SizedBox(
          height: sh * 0.75,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: sw * 0.32,
                height: sw * 0.32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.group_add_rounded,
                    size: sw * 0.14,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              SizedBox(height: sh * 0.04),
              Text(
                "Establish Your Team",
                style: TextStyle(
                  fontSize: sw * 0.05,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryBlue,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: sh * 0.015),
              Text(
                "Create child accounts for your team members. Tapping 'Add Team Member' lets you issue credentials instantly.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: sw * 0.034,
                  color: Colors.grey[500],
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMemberCard(BuildContext context, TeamMember member, double sw, double sh) {
    final initials = member.name.trim().isNotEmpty
        ? member.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'TM';

    return _TeamMemberCard(
      member: member,
      initials: initials,
      sw: sw,
      sh: sh,
      onDelete: () => _confirmDelete(context, member),
    );
  }

  void _showAddMemberBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddMemberBottomSheetBody(),
    );
  }

  void _confirmDelete(BuildContext context, TeamMember member) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Remove Team Member?",
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to remove ${member.name}? This will delete their child account, along with all active sessions and OTP logs.",
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<TeamMemberCubit>().deleteTeamMember(member.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Remove",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Stateful card widget to handle the expandable Aadhaar section per card.
class _TeamMemberCard extends StatefulWidget {
  final TeamMember member;
  final String initials;
  final double sw;
  final double sh;
  final VoidCallback onDelete;

  const _TeamMemberCard({
    required this.member,
    required this.initials,
    required this.sw,
    required this.sh,
    required this.onDelete,
  });

  @override
  State<_TeamMemberCard> createState() => _TeamMemberCardState();
}

class _TeamMemberCardState extends State<_TeamMemberCard>
    with SingleTickerProviderStateMixin {
  bool _isAadharExpanded = false;
  late AnimationController _animController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleAadhar() {
    setState(() {
      _isAadharExpanded = !_isAadharExpanded;
      if (_isAadharExpanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final member = widget.member;
    final sw = widget.sw;
    final sh = widget.sh;

    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E2A66).withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                const Color(0xFFF8FAFC).withOpacity(0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(sw * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar, Name, Mobile, and Delete
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Modern Gradient Avatar
                    Container(
                      width: sw * 0.12,
                      height: sw * 0.12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryAmber,
                            AppColors.primaryAmberLogo,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.initials,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: sw * 0.038,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.04),
                    // Name and Mobile
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: TextStyle(
                              fontSize: sw * 0.042,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryBlue,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.phone_android_rounded, size: 12, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(
                                "+91 ${member.mobile}",
                                style: TextStyle(
                                  fontSize: sw * 0.032,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Trash Icon Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onDelete,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: sh * 0.015),

                // Divider
                Container(
                  height: 1,
                  color: Colors.grey.withOpacity(0.1),
                ),

                // Expandable Aadhaar Section
                InkWell(
                  onTap: _toggleAadhar,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: sh * 0.012),
                    child: Row(
                      children: [
                        Icon(Icons.fingerprint_rounded, size: 16, color: AppColors.primaryAmber),
                        const SizedBox(width: 8),
                        Text(
                          "AADHAAR NUMBER",
                          style: TextStyle(
                            fontSize: sw * 0.026,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Spacer(),
                        AnimatedRotation(
                          turns: _isAadharExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 22,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Animated Aadhaar value
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  axisAlignment: -1.0,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.04,
                        vertical: sh * 0.012,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAmber.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryAmber.withOpacity(0.15),
                        ),
                      ),
                      child: Text(
                        _formatAadhar(member.aadharNumber),
                        style: TextStyle(
                          fontSize: sw * 0.04,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddMemberBottomSheetBody extends StatefulWidget {
  const _AddMemberBottomSheetBody();

  @override
  State<_AddMemberBottomSheetBody> createState() => _AddMemberBottomSheetBodyState();
}

class _AddMemberBottomSheetBodyState extends State<_AddMemberBottomSheetBody> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _aadharController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _aadharController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    return BlocListener<TeamMemberCubit, TeamMemberState>(
      listener: (context, state) {
        if (state is TeamMemberActionSuccess) {
          Navigator.pop(context);
        } else if (state is TeamMemberError) {
          setState(() {
            _isSubmitting = false;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          bottom: mq.viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: sw * 0.12,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: sh * 0.025),
                Text(
                  "Add Team Member",
                  style: TextStyle(
                    fontSize: sw * 0.048,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryBlue,
                  ),
                ),
                SizedBox(height: sh * 0.005),
                Text(
                  "Enter the details to create a child account.",
                  style: TextStyle(
                    fontSize: sw * 0.03,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: sh * 0.025),
                _buildLabel("Name"),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: sw * 0.038,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: _buildInputDecoration(Icons.person_rounded, "Enter full name"),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Name is required";
                    }
                    return null;
                  },
                ),
                SizedBox(height: sh * 0.02),
                _buildLabel("Mobile Number"),
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: sw * 0.038,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: _buildInputDecoration(Icons.phone_android_rounded, "Enter 10-digit mobile number"),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Mobile number is required";
                    }
                    if (val.trim().length != 10) {
                      return "Mobile number must be exactly 10 digits";
                    }
                    return null;
                  },
                ),
                SizedBox(height: sh * 0.02),
                _buildLabel("Aadhaar Number"),
                TextFormField(
                  controller: _aadharController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                    _AadharInputFormatter(),
                  ],
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: sw * 0.038,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                  decoration: _buildInputDecoration(Icons.fingerprint_rounded, "1234 5678 9012"),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Aadhaar number is required";
                    }
                    final digits = val.replaceAll(' ', '');
                    if (digits.length != 12) {
                      return "Aadhaar number must be exactly 12 digits";
                    }
                    return null;
                  },
                ),
                SizedBox(height: sh * 0.04),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFF59E0B),
                          Color(0xFFD97706),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD97706).withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Create Child ID",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: sh * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(IconData icon, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey[400],
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: AppColors.primaryBlue.withOpacity(0.5), size: 18),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryAmber, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });
      context.read<TeamMemberCubit>().createTeamMember(
            name: _nameController.text.trim(),
            mobile: _mobileController.text.trim(),
            aadharNumber: _aadharController.text.replaceAll(' ', '').trim(),
          );
    }
  }
}

/// Formats an Aadhaar number string with spaces every 4 digits.
String _formatAadhar(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && i % 4 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Custom TextInputFormatter that auto-inserts spaces every 4 digits.
class _AadharInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip all non-digits
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Limit to 12 digits
    final limited = digitsOnly.length > 12 ? digitsOnly.substring(0, 12) : digitsOnly;

    // Insert spaces every 4 digits
    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(limited[i]);
    }
    final formatted = buffer.toString();

    // Calculate new cursor position
    // Count how many digits are before the cursor in the new (unformatted) value
    int digitsBeforeCursor = 0;
    final cursorPos = newValue.selection.baseOffset.clamp(0, newValue.text.length);
    for (int i = 0; i < cursorPos && i < newValue.text.length; i++) {
      if (RegExp(r'\d').hasMatch(newValue.text[i])) {
        digitsBeforeCursor++;
      }
    }
    // Clamp to limited length
    if (digitsBeforeCursor > limited.length) {
      digitsBeforeCursor = limited.length;
    }

    // Map digit count back to formatted position
    int newCursorPos = 0;
    int digitsSeen = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (digitsSeen == digitsBeforeCursor) break;
      if (formatted[i] != ' ') digitsSeen++;
      newCursorPos = i + 1;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }
}
