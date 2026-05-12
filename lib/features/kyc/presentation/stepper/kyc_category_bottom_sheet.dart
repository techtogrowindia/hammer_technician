import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'package:hammer_app/features/kyc/presentation/stepper/kyc_stepper_models.dart';
import 'package:hammer_app/core/utils/snackbar_utils.dart';
import 'package:hammer_app/features/service/cubit/service_cubit.dart';
import 'package:hammer_app/features/service/cubit/service_state.dart';

void showKycCategoryBottomSheet({
  required BuildContext context,
  required List<SelectedCategoryData> selectedCategories,
  required void Function() onSelectionChanged,
}) {
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
              final categories = state is ServiceLoaded ? state.categories : [];

              return Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Select Service Categories (Max 3) *",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (loading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            final isSelected = selectedCategories.any((e) => e.id == cat.id);

                            return ListTile(
                              selected: isSelected,
                              title: Text(cat.name),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: Colors.orange)
                                  : const Icon(Icons.circle_outlined),
                              onTap: () {
                                if (isSelected) {
                                  setModalStateInner(() {
                                    selectedCategories.removeWhere((e) => e.id == cat.id);
                                  });
                                } else {
                                  if (selectedCategories.length >= 3) {
                                    AppSnackBar.show(context, "Maximum 3 categories allowed", isError: true);
                                    return;
                                  }
                                  setModalStateInner(() {
                                    selectedCategories.add(SelectedCategoryData(id: cat.id, name: cat.name));
                                  });
                                }
                                onSelectionChanged();
                              },
                            );
                          },
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
