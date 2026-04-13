import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hammer_app/features/kyc/presentation/stepper/kyc_stepper_models.dart';
import 'package:hammer_app/features/kyc/presentation/stepper/kyc_shared_widgets.dart';

class KycDocumentsStep extends StatelessWidget {
  final Map<String, File?> pickedFiles;
  final Map<String, ExistingDocument> existingDocuments;
  final bool hasFirm;
  final bool hasGst;
  final Set<String>? missingKeys;

  final void Function(String key) onDocumentAction;

  const KycDocumentsStep({
    super.key,
    required this.pickedFiles,
    required this.existingDocuments,
    required this.hasFirm,
    required this.hasGst,
    this.missingKeys,
    required this.onDocumentAction,
  });

  Widget _documentTile(
    BuildContext context,
    String title,
    String key, {
    bool required = true,
  }) {
    final file = pickedFiles[key];
    final existing = existingDocuments[key];
    final hasError = missingKeys?.contains(key) ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError ? Colors.red : Colors.grey.shade300,
          width: hasError ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            file != null || existing != null
                ? Icons.check_circle
                : Icons.upload_file,
            color: file != null || existing != null ? Colors.green : Colors.blue,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (required)
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  file != null
                      ? file.path.split(RegExp(r'[/\\]')).last
                      : existing != null
                          ? existing.filename
                          : "No file selected",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (file != null)
            IconButton(
              icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(child: kycZoomableImage(file)),
                );
              },
            ),
          IconButton(
            icon: Icon(
              file != null || existing != null ? Icons.delete : Icons.upload,
              color: file != null || existing != null ? Colors.red : Colors.blue,
            ),
            onPressed: () => onDocumentAction(key),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _documentTile(context, "Aadhar Front", "aadhar_front"),
        _documentTile(context, "Aadhar Back", "aadhar_back"),
        _documentTile(context, "PAN Card", "pan_card"),
        _documentTile(context, "Bank Statement", "bank_statement"),
        _documentTile(context, "Profile Photo", "photo"),
        _documentTile(context, 'Driving License Front', 'license_front'),
        _documentTile(context, 'Driving License Back', 'license_back'),
        if (hasFirm) _documentTile(context, "Company Photo", "company_photo"),
        if (hasGst) _documentTile(context, "GST Document", "gst_document"),
      ],
    );
  }
}
