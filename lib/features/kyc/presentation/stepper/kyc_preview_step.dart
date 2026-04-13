import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'package:hammer_app/features/kyc/presentation/screen/kyc_signature_screen.dart';
import 'package:hammer_app/features/kyc/presentation/stepper/kyc_shared_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class KycPreviewStep extends StatelessWidget {
  final String name;
  final String dob;
  final String bloodGroup;
  final String aadhar;
  final String pan;
  final String address;
  final String district;
  final String taluk;
  final String city;
  final String pincode;

  final String servicesSummary;

  final bool hasFirm;
  final bool hasGst;
  final String legalName;
  final String companyName;
  final String companyAddress;
  final String companyDistrict;
  final String companyCity;
  final String companyTaluk;
  final String companyPincode;
  final String numberOfEmployees;
  final String gstNumber;

  final String bankName;
  final String holderName;
  final String accountType;
  final String accountNumber;
  final String ifsc;
  final String upi;

  final Map<String, File?> pickedFiles;

  final bool declarationAccepted;
  final File? signatureFile;
  final void Function(File file)? onSignatureSaved;
  final VoidCallback? onReSign;
  final ValueChanged<bool> onDeclarationChanged;

  final VoidCallback onEditPersonal;
  final VoidCallback onEditServices;
  final VoidCallback? onEditProfessionalDoc;
  final VoidCallback onEditCompany;
  final VoidCallback onEditBank;
  final VoidCallback onEditDocuments;

  final Widget Function(File file) zoomableImageBuilder;
  final GlobalKey? signSectionKey;
  final VoidCallback? onScrollToSign;

  final String? qualification;
  final String? passedOutYear;
  final List<File>? eduCertificateFiles;
  final VoidCallback? onEditEducation;

  final Map<String, List<File>> professionalFilesMap;
  final Map<String, TextEditingController> certNumberControllers;
  final Map<String, TextEditingController> certExpiryControllers;
  final Map<String, bool> noExpiryMap;
  final dynamic certificateResponse; // To look up names
  final String? workingField;

  const KycPreviewStep({
    super.key,
    required this.name,
    required this.dob,
    required this.bloodGroup,
    required this.aadhar,
    required this.pan,
    required this.address,
    required this.district,
    required this.taluk,
    required this.city,
    required this.pincode,
    this.workingField,
    required this.servicesSummary,
    required this.hasFirm,
    required this.hasGst,
    required this.legalName,
    required this.companyName,
    required this.companyAddress,
    required this.companyDistrict,
    required this.companyCity,
    required this.companyTaluk,
    required this.companyPincode,
    required this.numberOfEmployees,
    required this.gstNumber,
    required this.bankName,
    required this.holderName,
    required this.accountType,
    required this.accountNumber,
    required this.ifsc,
    required this.upi,
    required this.pickedFiles,
    required this.declarationAccepted,
    required this.onDeclarationChanged,
    required this.professionalFilesMap,
    required this.certNumberControllers,
    required this.certExpiryControllers,
    required this.noExpiryMap,
    required this.certificateResponse,
    this.signatureFile,
    this.onSignatureSaved,
    this.onReSign,
    required this.onEditPersonal,
    required this.onEditServices,
    this.onEditProfessionalDoc,
    required this.onEditCompany,
    required this.onEditBank,
    required this.onEditDocuments,
    required this.zoomableImageBuilder,
    this.signSectionKey,
    this.onScrollToSign,
    this.qualification,
    this.passedOutYear,
    this.eduCertificateFiles,
    this.onEditEducation,
  });

  Widget _termsAndConditionsLink(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
          children: [
            const TextSpan(text: "Please read our "),
            TextSpan(
              text: "Terms and Conditions",
              style: TextStyle(
                color: AppColors.primaryAmber,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  final uri = Uri.parse('https://hammerapp.in/terms');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
            ),
            const TextSpan(text: " before proceeding."),
          ],
        ),
      ),
    );
  }

  static String _documentDisplayName(String key) {
    const names = {
      'aadhar_front': 'Aadhar Front',
      'aadhar_back': 'Aadhar Back',
      'pan_card': 'PAN Card',
      'bank_statement': 'Bank Statement',
      'photo': 'Profile Photo',
      'license_front': 'Driving License Front',
      'license_back': 'Driving License Back',
      'company_photo': 'Company Photo',
      'gst_document': 'GST Document',
    };
    return names[key] ?? key;
  }

  Widget _filePreviewGrid(BuildContext context) {
    final validFiles = pickedFiles.entries
        .where((e) => e.value != null)
        .toList();

    if (validFiles.isEmpty) {
      return const Text("No documents uploaded");
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: validFiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final entry = validFiles[index];
        final key = entry.key;
        final file = entry.value!;
        final displayName = _documentDisplayName(key);
        final isPdf = file.path.toLowerCase().endsWith('.pdf');

        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => Dialog(
                child: isPdf
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "PDF preview not supported",
                          textAlign: TextAlign.center,
                        ),
                      )
                    : zoomableImageBuilder(file),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPdf ? Icons.picture_as_pdf : Icons.image,
                  size: 36,
                  color: isPdf ? Colors.red : Colors.blue,
                ),
                const SizedBox(height: 6),
                Text(
                  displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        kycModernPreviewCard(
          title: "Personal Details",
          icon: Icons.person_outline,
          onEdit: onEditPersonal,
          children: [
            kycPreviewRow("Name", name),
            kycPreviewRow("Date of Birth", dob),
            kycPreviewRow("Blood Group", bloodGroup),
            kycPreviewRow("Aadhar", aadhar),
            kycPreviewRow("PAN", pan),
            kycPreviewRow("Address", address),
            kycPreviewRow("District", district),
            kycPreviewRow("Taluk", taluk),
            kycPreviewRow("City", city),
            kycPreviewRow("Pincode", pincode),
            if (workingField != null) kycPreviewRow("Working Field", workingField!),
          ],
        ),
        if (onEditEducation != null)
          kycModernPreviewCard(
            title: "Education Details",
            icon: Icons.school_outlined,
            onEdit: onEditEducation!,
            children: [
              kycPreviewRow("Qualification", qualification ?? "N/A"),
              kycPreviewRow("Passed Out Year", passedOutYear ?? "N/A"),
              kycPreviewRow("Documents", "${eduCertificateFiles?.length ?? 0} file(s)"),
            ],
          ),
        kycModernPreviewCard(
          title: "Services",
          icon: Icons.design_services,
          onEdit: onEditServices,
          children: [kycPreviewRow("Services", servicesSummary)],
        ),
        if (onEditProfessionalDoc != null)
          kycModernPreviewCard(
            title: "Selected Certificates",
            icon: Icons.badge_outlined,
            onEdit: onEditProfessionalDoc!,
            children: [
              if (professionalFilesMap.isEmpty)
                kycPreviewRow("Certificates", "None uploaded")
              else
                ...professionalFilesMap.entries.where((e) => e.value.isNotEmpty).map((e) {
                  final key = e.key;
                  final files = e.value;
                  
                  // Try to find the certificate name from the response
                  String certName = "Certificate";
                  String categoryName = "";
                  if (certificateResponse != null) {
                    try {
                      final parts = key.split('_');
                      final sId = int.parse(parts[0]);
                      final cId = int.parse(parts[1]);
                      for (final svc in certificateResponse.services) {
                        if (svc.serviceId == sId) {
                          categoryName = svc.serviceName ?? "";
                          for (final cert in svc.certificates) {
                            if (cert.certificateId == cId) {
                              certName = cert.certificateName;
                              break;
                            }
                          }
                        }
                      }
                    } catch (_) {}
                  }

                  final certNo = certNumberControllers[key]?.text ?? "N/A";
                  final isNoExpiry = noExpiryMap[key] ?? true;
                  final expiry = isNoExpiry ? "No Expiry" : (certExpiryControllers[key]?.text ?? "N/A");

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName.isNotEmpty ? "$categoryName - $certName" : certName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.primaryAmber,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (categoryName.isNotEmpty) kycPreviewRow("Category", categoryName),
                        kycPreviewRow("Number", certNo),
                        kycPreviewRow("Expiry", expiry),
                        kycPreviewRow("Files", "${files.length} file(s)"),
                        if (e.key != professionalFilesMap.keys.last)
                          const Divider(height: 20, thickness: 0.5),
                      ],
                    ),
                  );
                }),
            ],
          ),
        kycModernPreviewCard(
          title: "Company Details",
          icon: Icons.business_outlined,
          onEdit: onEditCompany,
          children: [
            kycPreviewRow("Has Company", hasFirm ? "Yes" : "No"),
            kycPreviewRow("Has GST", hasGst ? "Yes" : "No"),
            if (hasFirm) kycPreviewRow("Legal Name", legalName),
            if (hasFirm) kycPreviewRow("Company", companyName),
            if (hasFirm) kycPreviewRow("Address", companyAddress),
            if (hasFirm) kycPreviewRow("District", companyDistrict),
            if (hasFirm) kycPreviewRow("City", companyCity),
            if (hasFirm) kycPreviewRow("Taluk", companyTaluk),
            if (hasFirm) kycPreviewRow("Pincode", companyPincode),
            if (hasFirm) kycPreviewRow("No. of Employees", numberOfEmployees),
            if (hasGst) kycPreviewRow("GST Number", gstNumber),
          ],
        ),
        kycModernPreviewCard(
          title: "Bank Details",
          icon: Icons.account_balance_outlined,
          onEdit: onEditBank,
          children: [
            kycPreviewRow("Bank Name", bankName),
            kycPreviewRow("Holder Name", holderName),
            kycPreviewRow("Account Type", accountType),
            kycPreviewRow("Account No", accountNumber),
            kycPreviewRow("IFSC", ifsc),
            kycPreviewRow("UPI", upi),
          ],
        ),
        kycModernPreviewCard(
          title: "Uploaded Documents",
          icon: Icons.folder_open_outlined,
          onEdit: onEditDocuments,
          children: [_filePreviewGrid(context)],
        ),
        const SizedBox(height: 20),
        _termsAndConditionsLink(context),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade50,
          ),
          child: CheckboxListTile(
            value: declarationAccepted,
            onChanged: (v) {
              final accepted = v ?? false;
              onDeclarationChanged(accepted);
              if (accepted) onScrollToSign?.call();
            },
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              "I hereby declare that all the information provided above is true "
              "and correct to the best of my knowledge. I understand that any false "
              "information may result in rejection of my KYC verification.",
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        if (declarationAccepted) ...[
          const SizedBox(height: 20),
          Builder(
            key: signSectionKey,
            builder: (_) => signatureFile != null
                ? Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            height: 60,
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Image.file(
                              signatureFile!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            "Signature \nsaved",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        if (onReSign != null)
                          TextButton(
                            onPressed: onReSign,
                            child: const Text("Re-sign"),
                          ),
                      ],
                    ),
                  )
                : InkWell(
                    onTap: () async {
                      final file = await KycSignatureScreen.open(context);
                      if (file != null && onSignatureSaved != null) {
                        onSignatureSaved!(file);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryAmber.withOpacity(0.4),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        color: AppColors.primaryAmber.withOpacity(0.05),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryAmber.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.draw_rounded,
                              color: AppColors.primaryAmber,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Tap here to Draw your Signature",
                            style: TextStyle(
                              color: AppColors.primaryAmber,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Required for KYC Final Submission",
                            style: TextStyle(
                              color: AppColors.primaryAmber.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          // "Has No GST" Checkbox with Hyperlink - only show when user has no GST
          if (!hasGst) Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Checkbox(
                  value: true,
                  onChanged: (v) {},
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      children: [
                        const TextSpan(text: "I confirm that I have "),
                        TextSpan(
                          text: "No GST Registration",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              final uri = Uri.parse('https://hammerapp.in/docs/gst-individual.pdf');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            },
                        ),
                        const TextSpan(text: " for my business."),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
