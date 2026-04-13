import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'package:hammer_app/features/kyc/presentation/stepper/kyc_stepper_models.dart';
import 'package:hammer_app/features/service/cubit/service_cubit.dart';
import 'package:hammer_app/features/service/cubit/service_state.dart';

void showKycServiceBottomSheet({
  required BuildContext context,
  required List<SelectedCategoryData> selectedCategories,
  required List<SelectedServiceData> selectedServices,
  required void Function() onSelectionChanged,
}) {
  final categoryIds = selectedCategories.map((e) => e.id).toSet();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (modalContext) {
      return StatefulBuilder(
        builder: (context, setModalStateInner) {
          return BlocBuilder<ServiceCubit, ServiceState>(
            builder: (context, state) {
              final loading = state is ServiceLoading;
              final list = state is ServiceLoaded
                  ? [
                      for (var category in state.categories)
                        if (categoryIds.contains(category.id))
                          for (var sub in category.subcategories)
                            for (var service in sub.services)
                              ServiceDropdownModel(
                                id: service.id,
                                categoryName: category.name,
                                subcategoryName: sub.name,
                                serviceName: service.serviceName,
                                hasCertificate: service.certificates.isNotEmpty,
                              ),
                    ]
                  : [];

              return Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Select Services (${list.length} available)",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (loading)
                      const Center(child: CircularProgressIndicator())
                    else if (list.isEmpty)
                      const Flexible(child: Center(child: Text("No services found for selected categories")))
                    else
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text("Select All", style: TextStyle(fontWeight: FontWeight.bold)),
                              trailing: Icon(
                                selectedServices.length == list.length && list.isNotEmpty
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: selectedServices.length == list.length && list.isNotEmpty
                                    ? AppColors.primaryBlue
                                    : null,
                              ),
                              onTap: () {
                                setModalStateInner(() {
                                  if (selectedServices.length == list.length && list.isNotEmpty) {
                                    selectedServices.clear();
                                  } else {
                                    selectedServices.clear();
                                    for (var service in list) {
                                      selectedServices.add(
                                        SelectedServiceData(
                                          serviceId: service.id,
                                          serviceName: service.serviceName,
                                          hasCertificate: service.hasCertificate,
                                        ),
                                      );
                                    }
                                  }
                                });
                                onSelectionChanged();
                              },
                            ),
                            const Divider(height: 1),
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: list.length,
                                itemBuilder: (context, index) {
                                  final service = list[index];
                                  final isSelected = selectedServices.any((e) => e.serviceId == service.id);

                                  return ListTile(
                                    selected: isSelected,
                                    title: Text(service.serviceName),
                                    subtitle: Text(service.subcategoryName),
                                    trailing: isSelected
                                        ? const Icon(Icons.check_box, color: AppColors.primaryBlue)
                                        : const Icon(Icons.check_box_outline_blank),
                                    onTap: () {
                                      if (isSelected) {
                                        setModalStateInner(() {
                                          selectedServices.removeWhere((e) => e.serviceId == service.id);
                                        });
                                      } else {
                                        setModalStateInner(() {
                                          selectedServices.add(
                                            SelectedServiceData(
                                              serviceId: service.id,
                                              serviceName: service.serviceName,
                                              hasCertificate: service.hasCertificate,
                                            ),
                                          );
                                        });
                                      }
                                      onSelectionChanged();
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Done", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}
