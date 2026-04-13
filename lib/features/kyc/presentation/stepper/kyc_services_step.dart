import 'package:flutter/material.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'package:hammer_app/features/kyc/presentation/widgets/kyc_textfield.dart';
import 'kyc_stepper_models.dart';

class KycServicesStep extends StatelessWidget {
  final List<SelectedCategoryData> selectedCategories;
  final List<SelectedServiceData> selectedServices;
  final bool isLoadingServices;
  final VoidCallback onOpenCategoryBottomSheet;
  final VoidCallback onOpenServiceBottomSheet;

  const KycServicesStep({
    super.key,
    required this.selectedCategories,
    required this.selectedServices,
    required this.isLoadingServices,
    required this.onOpenCategoryBottomSheet,
    required this.onOpenServiceBottomSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CATEGORY SELECTION
        Text(
          'Select Service Categories (Max 3) *',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onOpenCategoryBottomSheet,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.grey.shade50,
            ),
            child: selectedCategories.isEmpty
                ? const Text("Choose Categories", style: TextStyle(color: Colors.grey))
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedCategories.map((cat) {
                      return Chip(
                        label: Text(cat.name, style: const TextStyle(fontSize: 12)),
                        onDeleted: onOpenCategoryBottomSheet, // Simple jump to modal
                        backgroundColor: AppColors.primaryAmber.withOpacity(0.1),
                      );
                    }).toList(),
                  ),
          ),
        ),
        const SizedBox(height: 20),

        // EXPERIENCE PER CATEGORY
        if (selectedCategories.isNotEmpty) ...[
          const Text(
            'Years of Experience per Category *',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 10),
          ...selectedCategories.map((cat) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: KycTextField(
                controller: cat.experienceController,
                label: "Experience in ${cat.name}",
                keyboardType: TextInputType.number,
              ),
            );
          }),
        ],
        const SizedBox(height: 10),

        // SERVICE SELECTION (only if categories are selected)
        if (selectedCategories.isNotEmpty) ...[
          Text(
            'Select All Services You Provide *',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onOpenServiceBottomSheet,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: selectedServices.isEmpty
                  ? const Text("Select subcategories/services", style: TextStyle(color: Colors.grey))
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${selectedServices.length} service(s) selected", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                      const SizedBox(height: 8),
                      Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedServices.take(5).map((service) {
                            return Chip(
                                label: Text(service.serviceName, style: const TextStyle(fontSize: 11)),
                                visualDensity: VisualDensity.compact,
                            );
                          }).toList() + [ if (selectedServices.length > 5) const Chip(label: Text("..."), visualDensity: VisualDensity.compact)],
                        ),
                    ],
                  ),
            ),
          ),
        ],
      ],
    );
  }
}
