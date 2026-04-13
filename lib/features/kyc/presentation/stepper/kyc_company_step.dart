import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'package:hammer_app/features/kyc/cubit/kyc_cubit.dart';
import 'package:hammer_app/features/kyc/presentation/widgets/kyc_textfield.dart';

class KycCompanyStep extends StatelessWidget {
  final Map<String, String>? fieldErrors;
  final bool hasFirm;
  final bool hasGst;
  final bool gstVerifying;
  final bool gstVerified;
  final bool hasEmployees;
  final ValueChanged<bool> onHasFirmChanged;
  final ValueChanged<bool> onHasGstChanged;
  final ValueChanged<bool> onHasEmployeesChanged;

  final TextEditingController gstController;
  final TextEditingController legalNameController;
  final TextEditingController companyNameController;
  final TextEditingController companyAddressController;
  final TextEditingController companyPincodeController;
  final TextEditingController companyDistrictController;
  final TextEditingController companyTalukController;
  final TextEditingController companyCityController;
  final TextEditingController numberOfEmployeesController;

  static const _fieldSpace = SizedBox(height: 14);
  static final _editIcon = Icon(
    Icons.edit,
    size: 20,
    color: Colors.grey.shade600,
  );

  const KycCompanyStep({
    super.key,
    this.fieldErrors,
    required this.hasFirm,
    required this.hasGst,
    required this.gstVerifying,
    required this.gstVerified,
    required this.hasEmployees,
    required this.onHasFirmChanged,
    required this.onHasGstChanged,
    required this.onHasEmployeesChanged,
    required this.gstController,
    required this.legalNameController,
    required this.companyNameController,
    required this.companyAddressController,
    required this.companyPincodeController,
    required this.companyDistrictController,
    required this.companyTalukController,
    required this.companyCityController,
    required this.numberOfEmployeesController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text("Do you have a Firm/Company/Agency?"),
          value: hasFirm,
          onChanged: onHasFirmChanged,
        ),
        SwitchListTile(
          title: const Text("Do you have GST?"),
          value: hasGst,
          onChanged: onHasGstChanged,
        ),
        if (hasGst)
          TextField(
            controller: gstController,
            maxLength: 15,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: "GST Number",
              errorText: fieldErrors?['gst'],
              counterText: "",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: gstVerifying
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : gstVerified
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ElevatedButton(
                            onPressed: () {
                              if (gstController.text.length != 15) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Enter valid 15 digit GST number",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              context.read<KycCubit>().verifyGst(
                                    gstController.text.trim(),
                                    hasFirm: hasFirm,
                                    hasGst: hasGst,
                                  );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryAmber,
                              foregroundColor: Colors.white,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_user,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Verify",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
            ),
          ),
        SwitchListTile(
          title: const Text("Do you have a Employee/Staff?"),
          value: hasEmployees,
          onChanged: onHasEmployeesChanged,
        ),
        if (hasEmployees)
          Column(
            children: [
              _fieldSpace,
              KycTextField(
                controller: numberOfEmployeesController,
                label: "No of Employees",
                keyboardType: TextInputType.number,
                maxLength: 2,
                errorText: fieldErrors?['numberOfEmployees'],
              ),
            ],
          ),
        if (hasFirm)
          Column(
            children: [
              _fieldSpace,
              KycTextField(
                controller: legalNameController,
                label: "Legal Name",
                suffix: _editIcon,
                errorText: fieldErrors?['legalName'],
              ),
              _fieldSpace,
              KycTextField(
                controller: companyNameController,
                label: "Name",
                suffix: _editIcon,
                errorText: fieldErrors?['companyName'],
              ),
              _fieldSpace,
              KycTextField(
                controller: companyAddressController,
                label: "Address",
                suffix: _editIcon,
                errorText: fieldErrors?['companyAddress'],
              ),
              _fieldSpace,
              KycTextField(
                controller: companyPincodeController,
                label: "Pincode",
                keyboardType: TextInputType.number,
                maxLength: 6,
                suffix: _editIcon,
                errorText: fieldErrors?['companyPincode'],
              ),
              _fieldSpace,
              KycTextField(
                controller: companyDistrictController,
                label: "District",
                suffix: _editIcon,
                errorText: fieldErrors?['companyDistrict'],
              ),
              _fieldSpace,
              KycTextField(
                controller: companyTalukController,
                label: "Taluk",
                suffix: _editIcon,
                errorText: fieldErrors?['companyTaluk'],
              ),
              _fieldSpace,
              KycTextField(
                controller: companyCityController,
                label: 'City',
                suffix: _editIcon,
                errorText: fieldErrors?['companyCity'],
              ),
            ],
          ),
      ],
    );
  }
}
