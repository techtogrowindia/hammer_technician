import 'package:flutter/material.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'package:hammer_app/core/utils/service_locators.dart';
import 'package:hammer_app/core/utils/snackbar_utils.dart';
import 'package:hammer_app/features/profile/data/repositories/referral_repository.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final ReferralRepository _referralRepo = sl<ReferralRepository>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileController = TextEditingController();

  String _selectedRole = 'Customer';
  final List<String> _roles = ['Technician', 'Customer', 'Retailer'];

  bool _isSubmitting = false;
  bool _isLoadingHistory = false;
  List<dynamic> _referrals = [];

  @override
  void initState() {
    super.initState();
    _loadReferralHistory();
  }

  Future<void> _loadReferralHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final list = await _referralRepo.getReferrals();
      if (mounted) {
        setState(() {
          _referrals = list;
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
        AppSnackBar.show(context, 'Error loading referrals: $e', isError: true);
      }
    }
  }

  Future<void> _submitReferral() async {
    if (!_formKey.currentState!.validate()) return;

    final mobile = _mobileController.text.trim();

    if (_selectedRole != 'Customer') {
      AppSnackBar.show(
        context,
        'Referral for $_selectedRole is currently under development. Static notification only.',
        isError: false,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await _referralRepo.submitReferral(mobile);
      if (mounted) {
        setState(() => _isSubmitting = false);
        
        final msg = response['message'] ?? 'Referral submitted successfully!';
        AppSnackBar.show(context, msg, isError: false);
        _mobileController.clear();
        _loadReferralHistory(); // Refresh history
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppSnackBar.show(context, e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.primaryAmber,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Referrals",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // Top Section: Refer Form
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(sw * 0.05),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Refer a New Member",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Role Dropdown
                    const Text(
                      "Select Refer Type",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                      items: _roles.map((String role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedRole = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Mobile Field
                    const Text(
                      "Mobile Number",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: "Enter 10 digit mobile number",
                        prefixIcon: const Icon(Icons.phone_android_rounded, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "Mobile number is required";
                        }
                        if (val.trim().length != 10 || int.tryParse(val.trim()) == null) {
                          return "Enter a valid 10-digit mobile number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReferral,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAmber,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                "Submit Referral",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Bottom Section: History Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: 10),
              color: const Color(0xFFF1F5F9),
              child: const Text(
                "REFERRAL HISTORY",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                  letterSpacing: 0.8,
                ),
              ),
            ),

            // Referral History List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadReferralHistory,
                color: AppColors.primaryAmber,
                child: _isLoadingHistory
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryAmber),
                      )
                    : _referrals.isEmpty
                        ? _buildEmptyState(sw)
                        : ListView.builder(
                            padding: EdgeInsets.all(sw * 0.04),
                            itemCount: _referrals.length,
                            itemBuilder: (context, index) {
                              final item = _referrals[index];
                              return _buildReferralCard(item, sw);
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(double sw) {
    return ListView(
      children: [
        SizedBox(height: 100),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.group_add_rounded,
                  size: 48,
                  color: AppColors.primaryAmber,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "No Referrals Found",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Share the app with others to start earning.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReferralCard(dynamic item, double sw) {
    final String mobile = item['mobile'] ?? '---';
    final String status = (item['status'] ?? 'pending').toString().toLowerCase();
    final String createdAt = item['created_at'] != null 
        ? item['created_at'].toString().split('T').first 
        : '---';

    Color statusColor = Colors.orange;
    String statusText = 'Pending';
    if (status == 'registered' || status == 'completed') {
      statusColor = Colors.green;
      statusText = 'Registered';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_android_rounded,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mobile,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Referred on: $createdAt",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }
}
