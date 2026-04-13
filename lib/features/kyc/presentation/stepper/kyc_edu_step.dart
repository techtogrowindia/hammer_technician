import 'dart:io';
import 'package:flutter/material.dart';
import 'kyc_shared_widgets.dart';
import 'kyc_stepper_models.dart';
import 'kyc_document_picker.dart';

class KycEduStep extends StatelessWidget {
  final String? selectedQualification;
  final String? passedOutYear;
  final List<String> qualifications = [
    'SSLC',
    'HSC',
    'ITI',
    'DIPLOMA',
    'Graduate',
    'Post Graduate',
    'OTHERS'
  ];
  final ValueChanged<String?> onQualificationChanged;
  final ValueChanged<String?> onYearChanged;
  final bool hasCertificate;
  final ValueChanged<bool> onHasCertificateChanged;
  final List<File> selectedFiles;
  final List<ExistingDocument>? existingCertificates;
  final Function(List<File> files) onFilesPicked;
  final ValueChanged<int> onRemoveFile;
  final ValueChanged<int>? onRemoveExisting;

  KycEduStep({
    super.key,
    required this.selectedQualification,
    required this.passedOutYear,
    required this.onQualificationChanged,
    required this.onYearChanged,
    required this.hasCertificate,
    required this.onHasCertificateChanged,
    required this.selectedFiles,
    this.existingCertificates,
    required this.onFilesPicked,
    required this.onRemoveFile,
    this.onRemoveExisting,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Maximum Educational Qualification *",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedQualification,
              hint: const Text("Select Qualification", style: TextStyle(fontSize: 14)),
              items: qualifications.map((q) {
                return DropdownMenuItem(value: q, child: Text(q, style: const TextStyle(fontSize: 14)));
              }).toList(),
              onChanged: onQualificationChanged,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Passed Out Year",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? pickedYear = await showDialog<DateTime>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Select Year"),
                  content: SizedBox(
                    width: 300,
                    height: 300,
                    child: YearPicker(
                      firstDate: DateTime(1970),
                      lastDate: DateTime.now(),
                      initialDate: DateTime.now(),
                      selectedDate: passedOutYear != null
                          ? DateTime(int.parse(passedOutYear!))
                          : DateTime.now(),
                      onChanged: (DateTime dateTime) {
                        Navigator.pop(context, dateTime);
                      },
                    ),
                  ),
                );
              },
            );
            if (pickedYear != null) {
              onYearChanged(pickedYear.year.toString());
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  passedOutYear ?? "Select Year",
                  style: TextStyle(
                    fontSize: 14,
                    color: passedOutYear == null ? Colors.grey : Colors.black,
                  ),
                ),
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Do you have certificate?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Switch(
              value: hasCertificate,
              onChanged: onHasCertificateChanged,
              activeColor: Colors.orange,
            ),
          ],
        ),
        if (hasCertificate) ...[
          const SizedBox(height: 10),
          const Text(
            "Upload Certificate",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _pickButton(
                  context,
                  Icons.camera_alt,
                  "Take Photo",
                  () async {
                    final files = await KycDocumentPicker.pickFromCamera(context);
                    if (files.isNotEmpty) onFilesPicked(files);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _pickButton(
                  context,
                  Icons.photo_library,
                  "Select File",
                  () async {
                    final files = await KycDocumentPicker.pickFromGallery(context);
                    if (files.isNotEmpty) onFilesPicked(files);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (existingCertificates != null && existingCertificates!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Currently Uploaded:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                ...existingCertificates!.asMap().entries.map((entry) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(entry.value.filename, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => onRemoveExisting?.call(entry.key),
                    ),
                  );
                }),
              ],
            ),
          if (selectedFiles.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (existingCertificates?.isNotEmpty ?? false) const SizedBox(height: 10),
                const Text("New Uploads:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                ...selectedFiles.asMap().entries.map((entry) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.file_present),
                    title: Text(entry.value.path.split(RegExp(r'[/\\]')).last, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                child: kycZoomableImage(entry.value),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => onRemoveFile(entry.key),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
        ],
      ],
    );
  }

  Widget _pickButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.orange),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
