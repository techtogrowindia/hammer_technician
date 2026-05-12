// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'package:image_picker/image_picker.dart';

/// A field definition for the edit bottom sheet.
class EditField {
  final String key;
  final String label;
  final dynamic initialValue;
  final EditFieldType type;
  final List<String>? dropdownOptions;
  final bool isRequired;
  final String? dependsOnKey;
  final dynamic dependsOnValue;

  EditField({
    required this.key,
    required this.label,
    this.initialValue,
    this.type = EditFieldType.text,
    this.dropdownOptions,
    this.isRequired = false,
    this.dependsOnKey,
    this.dependsOnValue,
  });
}

enum EditFieldType { text, date, toggle, dropdown, file, phone, multiSelect, nomineeList }

/// Shows a bottom sheet for editing a profile section.
/// Returns a map of changed fields (String keys, String or File values) or null if cancelled.
Future<Map<String, dynamic>?> showProfileEditSheet({
  required BuildContext context,
  required String title,
  required List<EditField> fields,
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EditSheetBody(title: title, fields: fields),
  );
}

class _EditSheetBody extends StatefulWidget {
  final String title;
  final List<EditField> fields;

  const _EditSheetBody({required this.title, required this.fields});

  @override
  State<_EditSheetBody> createState() => _EditSheetBodyState();
}

class _EditSheetBodyState extends State<_EditSheetBody> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _values = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, TextEditingController> _nomineeControllers = {};

  @override
  void initState() {
    super.initState();
    for (final f in widget.fields) {
      _values[f.key] = f.initialValue ?? '';
      if (f.type == EditFieldType.text || f.type == EditFieldType.phone) {
        _controllers[f.key] = TextEditingController(text: f.initialValue ?? '');
      } else if (f.type == EditFieldType.nomineeList) {
        final nominees = (f.initialValue as List?) ?? [];
        for (int i = 0; i < nominees.length; i++) {
          final n = nominees[i] as Map<String, dynamic>;
          _initNomineeControllers(f.key, i, n);
        }
      }
    }
  }

  void _initNomineeControllers(String listKey, int index, Map<String, dynamic> data) {
    for (final fieldKey in ['name', 'aadhar_card_no', 'phone_number', 'percentage']) {
      final ctrlKey = "${listKey}_${index}_$fieldKey";
      _nomineeControllers[ctrlKey] = TextEditingController(text: data[fieldKey]?.toString() ?? '');
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final c in _nomineeControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Form(
              key: _formKey,
              child: ListView(
                controller: scrollController,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Title
                  Text(
                    "Edit ${widget.title}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Fields
                  ...widget.fields.map(_buildField),
                  const SizedBox(height: 24),
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAmber,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(EditField field) {
    // Dependency check
    if (field.dependsOnKey != null) {
      final depVal = _values[field.dependsOnKey];
      if (depVal != field.dependsOnValue) {
        return const SizedBox.shrink();
      }
    }

    switch (field.type) {
      case EditFieldType.text:
      case EditFieldType.phone:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            controller: _controllers[field.key],
            keyboardType: field.type == EditFieldType.phone
                ? TextInputType.phone
                : TextInputType.text,
            decoration: InputDecoration(
              labelText: field.label,
              labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              filled: true,
              fillColor: AppColors.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryAmber, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (v) => _values[field.key] = v,
          ),
        );

      case EditFieldType.date:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => _pickDate(field),
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: field.label,
                labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: const Icon(Icons.calendar_today, size: 18, color: AppColors.primaryAmber),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              child: Text(
                (_values[field.key]?.toString().isNotEmpty ?? false)
                    ? _values[field.key].toString()
                    : 'Select date',
                style: TextStyle(
                  color: (_values[field.key]?.toString().isNotEmpty ?? false)
                      ? AppColors.textPrimary
                      : Colors.grey.shade500,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        );

      case EditFieldType.toggle:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  field.label,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                ),
                Switch(
                  value: _values[field.key] == 'true' || _values[field.key] == true,
                  onChanged: (v) => setState(() => _values[field.key] = v),
                  activeColor: AppColors.primaryAmber,
                ),
              ],
            ),
          ),
        );

      case EditFieldType.dropdown:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DropdownButtonFormField<String>(
            value: (field.dropdownOptions?.contains(_values[field.key]) ?? false)
                ? _values[field.key]
                : null,
            items: (field.dropdownOptions ?? [])
                .map((o) => DropdownMenuItem(value: o, child: Text(_capitalize(o))))
                .toList(),
            onChanged: (v) => setState(() => _values[field.key] = v ?? ''),
            decoration: InputDecoration(
              labelText: field.label,
              labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              filled: true,
              fillColor: AppColors.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        );

      case EditFieldType.multiSelect:
        final selected = (_values[field.key] as List?)?.cast<String>() ?? [];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(field.label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: (field.dropdownOptions ?? []).map((o) {
                  final isSelected = selected.contains(o);
                  return FilterChip(
                    label: Text(_capitalize(o), style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.primaryBlue)),
                    selected: isSelected,
                    selectedColor: AppColors.primaryAmber,
                    checkmarkColor: Colors.white,
                    backgroundColor: AppColors.inputFill,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          selected.add(o);
                        } else {
                          selected.remove(o);
                        }
                        _values[field.key] = List<String>.from(selected);
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );

      case EditFieldType.file:
        final hasFile = _values[field.key] is File;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(field.label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hasFile
                            ? (_values[field.key] as File).path.split(RegExp(r'[/\\]')).last
                            : (field.initialValue?.toString() ?? 'No file selected'),
                        style: TextStyle(
                          color: hasFile ? AppColors.success : Colors.grey.shade500,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _pickFile(field),
                      icon: const Icon(Icons.upload_file, size: 16),
                      label: const Text("Choose"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryAmber,
                        side: const BorderSide(color: AppColors.primaryAmber),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

      case EditFieldType.nomineeList:
        final nominees = (_values[field.key] as List?) ?? [];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(field.label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                  TextButton.icon(
                    onPressed: () => _addNominee(field.key),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Add Nominee"),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primaryAmber),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...nominees.asMap().entries.map((entry) {
                final idx = entry.key;
                final n = entry.value as Map<String, dynamic>;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.primaryBlue,
                            child: Text("${idx + 1}", style: const TextStyle(fontSize: 10, color: Colors.white)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              n['name']?.toString().isNotEmpty == true ? n['name'] : "New Nominee",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                            onPressed: () => _removeNominee(field.key, idx),
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildNomineeField(field.key, idx, 'name', 'Name', Icons.person),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildNomineeField(field.key, idx, 'aadhar_card_no', 'Aadhar', Icons.badge)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildNomineeField(field.key, idx, 'phone_number', 'Phone', Icons.phone, type: TextInputType.phone)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildNomineeField(field.key, idx, 'percentage', 'Share Percentage (0-100)', Icons.percent, type: TextInputType.number),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
    }
    return const SizedBox();
  }

  Widget _buildNomineeField(String listKey, int index, String fieldKey, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    final ctrlKey = "${listKey}_${index}_$fieldKey";
    final controller = _nomineeControllers[ctrlKey];
    
    return TextFormField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        prefixIcon: Icon(icon, size: 16, color: AppColors.primaryAmber),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      onChanged: (v) {
        setState(() {
          if (fieldKey == 'percentage') {
            final val = int.tryParse(v) ?? 0;
            _values[listKey][index][fieldKey] = val;
            
            // Logic for instant update when exactly 2 nominees
            final nominees = _values[listKey] as List;
            if (nominees.length == 2) {
              final otherIdx = index == 0 ? 1 : 0;
              final remaining = (100 - val).clamp(0, 100);
              nominees[otherIdx]['percentage'] = remaining;
              
              // Update the other controller instantly
              final otherCtrlKey = "${listKey}_${otherIdx}_percentage";
              if (_nomineeControllers.containsKey(otherCtrlKey)) {
                _nomineeControllers[otherCtrlKey]!.text = remaining.toString();
              }
            }
          } else {
            _values[listKey][index][fieldKey] = v;
          }
        });
      },
    );
  }

  void _addNominee(String key) {
    setState(() {
      final list = List<Map<String, dynamic>>.from(_values[key] ?? []);
      
      // Calculate total current percentage
      int totalCurrent = 0;
      for (var n in list) {
        totalCurrent += (n['percentage'] as int? ?? 0);
      }
      
      // Default to remaining percentage (max 100)
      int remaining = 100 - totalCurrent;
      if (remaining < 0) remaining = 0;

      final newData = {
        'name': '',
        'aadhar_card_no': '',
        'phone_number': '',
        'percentage': remaining
      };
      
      list.add(newData);
      _values[key] = list;
      _initNomineeControllers(key, list.length - 1, newData);
    });
  }

  void _removeNominee(String key, int index) {
    setState(() {
      final list = List<Map<String, dynamic>>.from(_values[key] ?? []);
      list.removeAt(index);
      _values[key] = list;
      
      // Clear controllers for this index and shift others
      _rebuildNomineeControllers(key, list);
    });
  }

  void _rebuildNomineeControllers(String listKey, List<Map<String, dynamic>> list) {
    // Remove all keys starting with listKey
    _nomineeControllers.removeWhere((key, _) => key.startsWith("${listKey}_"));
    for (int i = 0; i < list.length; i++) {
      _initNomineeControllers(listKey, i, list[i]);
    }
  }

  Future<void> _pickDate(EditField field) async {
    final now = DateTime.now();
    final initial = DateTime.tryParse(_values[field.key]?.toString() ?? '') ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryAmber,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _values[field.key] = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pickFile(EditField field) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _values[field.key] = File(picked.path);
      });
    }
  }

  void _save() {
    final result = <String, dynamic>{};
    for (final f in widget.fields) {
      final val = _values[f.key];
      if (val == null) continue;
      
      // Preserve native types (bool for toggles, list for multiselect)
      if (val is bool || val is List || val is File) {
        result[f.key] = val;
      } else if (val.toString().isNotEmpty) {
        result[f.key] = val.toString();
      }
    }
    Navigator.pop(context, result);
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
