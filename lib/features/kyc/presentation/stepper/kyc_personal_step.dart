import 'package:flutter/material.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'package:hammer_app/features/kyc/data/models/blood_group_model.dart';
import 'package:hammer_app/features/kyc/presentation/widgets/kyc_textfield.dart';
import 'package:hammer_app/features/kyc/presentation/widgets/aadhar_formatter.dart';
import 'package:hammer_app/features/kyc/presentation/widgets/dob_formatter.dart';
import 'package:hammer_app/features/kyc/presentation/widgets/uppercase_formatter.dart';

class KycPersonalStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController dobController;
  final TextEditingController aadharController;
  final TextEditingController panController;
  final TextEditingController addressController;
  final TextEditingController pincodeController;
  final TextEditingController districtController;
  final TextEditingController talukController;
  final TextEditingController cityController;

  final List<BloodGroupModel> bloodGroups;
  final String? selectedBloodGroupName;
  final ValueChanged<String?> onBloodGroupChanged;
  final bool isDomestic;
  final bool isCommercial;
  final bool isCorporate;
  final void Function(String field, bool value) onWorkingFieldChanged;

  final bool bloodLoading;
  final bool panLinkLoading;
  final bool? isPanLinked;
  final VoidCallback onPickDob;
  final VoidCallback onCheckPanAadharLink;
  final Map<String, String>? fieldErrors;

  static const _fieldSpace = SizedBox(height: 14);

  const KycPersonalStep({
    super.key,
    required this.nameController,
    required this.dobController,
    required this.aadharController,
    required this.panController,
    required this.addressController,
    required this.pincodeController,
    required this.districtController,
    required this.talukController,
    required this.cityController,
    required this.bloodGroups,
    required this.selectedBloodGroupName,
    required this.onBloodGroupChanged,
    required this.isDomestic,
    required this.isCommercial,
    required this.isCorporate,
    required this.onWorkingFieldChanged,
    required this.bloodLoading,
    required this.panLinkLoading,
    required this.isPanLinked,
    required this.onPickDob,
    required this.onCheckPanAadharLink,
    this.fieldErrors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldSpace,
        KycTextField(
          controller: nameController,
          label: "Name (As per Aadhar)",
          keyboardType: TextInputType.text,
          required: true,
          errorText: fieldErrors?['name'],
        ),
        _fieldSpace,
        KycTextField(
          controller: dobController,
          label: "Date of Birth (DD/MM/YYYY)",
          inputFormatters: [DobFormatter()],
          maxLength: 10,
          keyboardType: TextInputType.number,
          suffix: IconButton(
            icon: const Icon(Icons.calendar_month, color: AppColors.primaryAmber),
            onPressed: onPickDob,
          ),
          required: true,
          errorText: fieldErrors?['dob'],
        ),
        _fieldSpace,
        bloodLoading
            ? const Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<String>(
                value: bloodGroups.any((e) => e.name == selectedBloodGroupName)
                    ? selectedBloodGroupName
                    : null,
                decoration: InputDecoration(
                  labelText: "Blood Group *",
                  errorText: fieldErrors?['bloodGroup'],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primaryBlue,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                items: bloodGroups
                    .map((blood) => DropdownMenuItem<String>(
                          value: blood.name,
                          child: Text(blood.name),
                        ))
                    .toList(),
                onChanged: onBloodGroupChanged,
              ),
        _fieldSpace,
        KycTextField(
          controller: aadharController,
          label: "Aadhar Number",
          maxLength: 14,
          keyboardType: TextInputType.number,
          inputFormatters: [AadharSpaceFormatter()],
          required: true,
          errorText: fieldErrors?['aadhar'],
        ),
        _fieldSpace,
        KycTextField(
          controller: panController,
          label: "PAN Number",
          maxLength: 10,
          inputFormatters: [UpperCaseTextFormatter()],
          suffix: panLinkLoading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : isPanLinked == true
                  ? const SizedBox.shrink()
                  : ValueListenableBuilder<TextEditingValue>(
                      valueListenable: panController,
                      builder: (context, value, _) {
                        if (value.text.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ElevatedButton(
                            onPressed: onCheckPanAadharLink,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPanLinked == false
                                  ? Colors.red.shade100
                                  : AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPanLinked == false
                                      ? Icons.warning_amber_rounded
                                      : Icons.verified_user,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  "Verify",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          required: true,
          errorText: fieldErrors?['pan'],
        ),
        if (isPanLinked != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              isPanLinked == true
                  ? "Aadhar & PAN are linked"
                  : "Aadhar & PAN are not linked",
              style: TextStyle(
                color: isPanLinked == true ? Colors.green : Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        _fieldSpace,
        KycTextField(
          controller: addressController,
          label: "Address",
          required: true,
          errorText: fieldErrors?['address'],
        ),
        _fieldSpace,
        KycTextField(
          controller: pincodeController,
          label: "Pincode",
          keyboardType: TextInputType.number,
          maxLength: 6,
          required: true,
          errorText: fieldErrors?['pincode'],
        ),
        _fieldSpace,
        KycTextField(
          controller: districtController,
          label: "District",
          suffix: Icon(Icons.edit, size: 20, color: Colors.grey.shade600),
          required: true,
          errorText: fieldErrors?['district'],
        ),
        _fieldSpace,
        KycTextField(
          controller: talukController,
          label: "Taluk",
          suffix: Icon(Icons.edit, size: 20, color: Colors.grey.shade600),
          required: true,
          errorText: fieldErrors?['taluk'],
        ),
        _fieldSpace,
        KycTextField(
          controller: cityController,
          label: "City",
          suffix: Icon(Icons.edit, size: 20, color: Colors.grey.shade600),
          required: true,
          errorText: fieldErrors?['city'],
        ),
        _fieldSpace,
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Select the working field *",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ),
        Wrap(
          spacing: 10,
          children: ["Domestic", "Commercial", "Corporate"].map((option) {
            bool isSelected = false;
            if (option == "Domestic") isSelected = isDomestic;
            if (option == "Commercial") isSelected = isCommercial;
            if (option == "Corporate") isSelected = isCorporate;

            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                onWorkingFieldChanged(option, selected);
              },
              selectedColor: AppColors.primaryBlue.withOpacity(0.1),
              checkmarkColor: AppColors.primaryAmber,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primaryAmber : const Color(0xFF475569),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
            );
          }).toList(),
        ),
        if (fieldErrors?['workingField'] != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              fieldErrors!['workingField']!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        _fieldSpace,
      ],
    );
  }
}
