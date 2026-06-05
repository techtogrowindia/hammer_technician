import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hammer_app/features/kyc/data/models/service_certificate_list_model.dart';
import 'package:open_filex/open_filex.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'kyc_document_picker.dart';

class KycProfessionalDocumentStep extends StatefulWidget {
  final ServiceCertificateListResponse? certificateResponse;

  /// Map key = "serviceId_certificateId", value = list of selected files
  final Map<String, List<File>> certificateFiles;
  final void Function(String key, List<File> files) onFilesPicked;
  final void Function(String key, int fileIndex) onRemoveFile;

  /// Map key = "serviceId_certificateId"
  final Map<String, TextEditingController> numberControllers;
  final Map<String, TextEditingController> expiryControllers;
  final Map<String, bool> noExpiryMap;
  final void Function(String key, bool value) onNoExpiryChanged;

  /// Toggle map for optional certificates section per serviceId
  final Map<int, bool> showOptionalCertsMap;
  final void Function(int serviceId, bool value) onShowOptionalChanged;

  /// NEW: Currently selected mandatory certificate keys per service ("serviceId" -> list of "certificateId")
  final Map<int, List<int>> selectedMandatoryCerts;
  final void Function(int serviceId, List<int> certificateIds) onMandatorySelected;

  const KycProfessionalDocumentStep({
    super.key,
    required this.certificateResponse,
    required this.certificateFiles,
    required this.onFilesPicked,
    required this.onRemoveFile,
    required this.numberControllers,
    required this.expiryControllers,
    required this.noExpiryMap,
    required this.onNoExpiryChanged,
    required this.showOptionalCertsMap,
    required this.onShowOptionalChanged,
    required this.selectedMandatoryCerts,
    required this.onMandatorySelected,
  });

  @override
  State<KycProfessionalDocumentStep> createState() =>
      _KycProfessionalDocumentStepState();
}

class _KycProfessionalDocumentStepState
    extends State<KycProfessionalDocumentStep> {
  @override
  Widget build(BuildContext context) {
    final response = widget.certificateResponse;
    if (response == null || response.services.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 24),
        child: Center(
          child: Text(
            "No certificates required for selected services.",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Missing mandatory banner

        // Iterate through each service
        ...response.services.map((svc) => _buildServiceSection(svc)),

        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildServiceSection(ServiceWithCertificates svc) {
    final mandatoryCerts = svc.mandatoryCertificates;
    final selectedIds = widget.selectedMandatoryCerts[svc.serviceId] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Modern Service Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        svc.serviceName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      if (mandatoryCerts.length > 1)
                        const Text(
                          "Any one certificate is sufficient",
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Certificate Selection (Dropdown style)
                if (mandatoryCerts.isNotEmpty) ...[
                  const Text(
                    "Required Document",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      _showMultiSelectDialog(context, svc.serviceId, mandatoryCerts);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedIds.isEmpty
                                  ? "Choose certificates"
                                  : "${selectedIds.length} certificate(s) selected",
                              style: TextStyle(
                                fontSize: 14,
                                color: selectedIds.isEmpty ? Colors.black54 : Colors.black87,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),

                  if (selectedIds.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ...selectedIds.map((id) {
                      final cert = mandatoryCerts.firstWhere(
                        (c) => c.certificateId == id,
                        orElse: () => mandatoryCerts.first,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildUploadFields(
                          svc.serviceId,
                          cert,
                          isAdditional: false,
                        ),
                      );
                    }).toList(),
                  ],
                ],

                const Divider(height: 6),
                InkWell(
                  onTap: () => widget.onShowOptionalChanged(
                    svc.serviceId,
                    !(widget.showOptionalCertsMap[svc.serviceId] ?? false),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Additional Document?",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "Upload any extra valid certificates",
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value:
                              widget.showOptionalCertsMap[svc.serviceId] ??
                              false,
                          onChanged: (v) =>
                              widget.onShowOptionalChanged(svc.serviceId, v),
                          activeColor: AppColors.primaryAmber,
                        ),
                      ),
                    ],
                  ),
                ),

                if (widget.showOptionalCertsMap[svc.serviceId] ?? false) ...[
                  Builder(
                    builder: (_) {
                      final allCerts = svc.certificates;
                      CertificateItem? targetCert;

                      if (allCerts.isNotEmpty) {
                        // Try to find an optional certificate that isn't already selected as mandatory
                        final optionalCerts = allCerts
                            .where(
                              (c) =>
                                  !c.isMandatory && !selectedIds.contains(c.certificateId),
                            )
                            .toList();

                        if (optionalCerts.isNotEmpty) {
                          targetCert = optionalCerts.firstWhere(
                            (c) =>
                                c.certificateName.toLowerCase().contains(
                                  'other',
                                ) ||
                                c.certificateName.toLowerCase().contains(
                                  'additional',
                                ),
                            orElse: () => optionalCerts.first,
                          );
                        } else {
                          // Fallback: Use any cert that isn't selected, or just the first one
                          targetCert = allCerts.firstWhere(
                            (c) => !selectedIds.contains(c.certificateId),
                            orElse: () => allCerts.first,
                          );
                        }
                      }

                      // If still null (service has no certs), try to find ANY valid certificate ID from the whole response
                      if (targetCert == null &&
                          widget.certificateResponse != null) {
                        for (final s in widget.certificateResponse!.services) {
                          if (s.certificates.isNotEmpty) {
                            targetCert = s.certificates.first;
                            break;
                          }
                        }
                      }

                      // Final fallback to avoid ID 0 if possible (using ID 1 as a common default)
                      targetCert ??= CertificateItem(
                        certificateId: 1,
                        certificateName: "Additional Document",
                        isMandatory: false,
                        uploaded: false,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _buildUploadFields(
                          svc.serviceId,
                          targetCert,
                          isAdditional: true,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadFields(
    int serviceId,
    CertificateItem cert, {
    required bool isAdditional,
  }) {
    final certificateId = cert.certificateId;
    final key = "${serviceId}_$certificateId";
    final files = widget.certificateFiles[key] ?? [];

    final hasFiles = files
        .isNotEmpty; // Reveal fields only after selecting a NEW file (as requested)

    final isVendorLetter = cert.certificateName == "Letter from Registered Vendor";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isAdditional) ...[
          const SizedBox(height: 8),
          if (isVendorLetter) ...[
            const SizedBox.shrink(),
          ] else
            InkWell(
              onTap: () async {
                final picked = await KycDocumentPicker.pickFromGallery(context);
                if (picked.isNotEmpty) {
                  widget.onFilesPicked(key, [picked.first]);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Text(
                      "Upload ${cert.certificateName}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      color: AppColors.primaryBlue,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
        ] else ...[
          // Minimised UI for Additional: Icon only button
          Row(
            children: [
              const Text(
                "Add Extra Cert: ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () async {
                  final picked = await KycDocumentPicker.pickFromGallery(
                    context,
                  );
                  if (picked.isNotEmpty) widget.onFilesPicked(key, picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAmber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_a_photo_outlined,
                    color: AppColors.primaryAmber,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],

        // State Check: Show Remote or Local Files (Skip for Vendor Letter as requested)
        if (!isVendorLetter && (cert.uploaded || hasFiles)) ...[
          const SizedBox(height: 12),

          // 2. Show Local Selected Files
          ...files.asMap().entries.map(
            (e) => _buildFileItem(key, e.value, e.key),
          ),
        ],

        // 3. Certificate Details Reveal (Only for Mandatory and ONLY after a file is SELECTED)
        if (!isAdditional && hasFiles && !isVendorLetter) ...[
          const SizedBox(height: 16),
          const Divider(thickness: 0.5),
          const SizedBox(height: 16),
          const Text(
            "Certificate Number (Optional)",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: widget.numberControllers[key],
            decoration: InputDecoration(
              hintText: "Enter number if available",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: widget.noExpiryMap[key] ?? true,
                  onChanged: (v) => widget.onNoExpiryChanged(key, v ?? true),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "This certificate does not have an expiry date",
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          if (!(widget.noExpiryMap[key] ?? true)) ...[
            const SizedBox(height: 12),
            const Text(
              "Expiry Date",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () => _pickDate(key),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.expiryControllers[key]!.text.isEmpty
                          ? "Select Date"
                          : widget.expiryControllers[key]!.text,
                    ),
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: AppColors.primaryAmber,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  // Widget _buildRemoteFileItem(Map<String, dynamic> details) {
  //   final fileName = details['file_name'] ?? 'Previously Uploaded';

  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4),
  //     child: Row(
  //       children: [
  //         const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
  //         const SizedBox(width: 8),
  //         Expanded(
  //           child: Text(
  //             "Previously Uploaded: $fileName",
  //             style: TextStyle(
  //               fontSize: 12,
  //               color: Colors.green.shade700,
  //               fontWeight: FontWeight.w500,
  //             ),
  //             maxLines: 1,
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _pickButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(String key, File file, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.insert_drive_file,
            color: AppColors.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              file.path.split('/').last,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.visibility_outlined,
              size: 18,
              color: Colors.blue,
            ),
            onPressed: () => OpenFilex.open(file.path),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.red),
            onPressed: () => widget.onRemoveFile(key, index),
          ),
        ],
      ),
    );
  }

  void _pickDate(String key) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      widget.expiryControllers[key]!.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {});
    }
  }

  void _showMultiSelectDialog(BuildContext context, int serviceId, List<CertificateItem> certs) {
    final selected = List<int>.from(widget.selectedMandatoryCerts[serviceId] ?? []);
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Select Certificates", style: TextStyle(fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: certs.map((c) {
                    return CheckboxListTile(
                      title: Text(c.certificateName, style: const TextStyle(fontSize: 14)),
                      value: selected.contains(c.certificateId),
                      onChanged: (val) {
                        setStateDialog(() {
                          if (val == true) {
                            selected.add(c.certificateId);
                          } else {
                            selected.remove(c.certificateId);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    widget.onMandatorySelected(serviceId, selected);
                    Navigator.pop(ctx);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
