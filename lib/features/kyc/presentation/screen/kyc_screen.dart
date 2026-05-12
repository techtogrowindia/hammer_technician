// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:hammer_app/core/utils/snackbar_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hammer_app/core/config/api_constants.dart';
import 'package:hammer_app/core/utils/service_locators.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';
import 'package:hammer_app/features/kyc/data/models/blood_group_model.dart';
import 'package:hammer_app/features/kyc/data/models/kyc_service_model.dart';
import 'package:hammer_app/features/kyc/data/repositories/kyc_repository.dart';
import 'package:hammer_app/features/service/data/models/subcategory_model.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:image_picker/image_picker.dart';

import 'package:hammer_app/features/common/data/services/picode_service.dart';
import 'package:hammer_app/features/kyc/data/models/kyc_step1_model.dart';
import 'package:hammer_app/features/kyc/data/models/kyc_step2_model.dart';
import 'package:hammer_app/features/kyc/data/models/kyc_step3_model.dart';

import 'package:hammer_app/features/kyc/data/models/service_certificate_list_model.dart';
import 'package:hammer_app/features/kyc/presentation/screen/kyc_verification_otp_screen.dart';
import 'package:hammer_app/features/kyc/presentation/stepper/kyc_stepper_steps.dart';
import 'package:hammer_app/features/service/cubit/service_cubit.dart';
import 'package:hammer_app/features/service/cubit/service_state.dart';

import '../../cubit/kyc_cubit.dart';
import '../../cubit/kyc_state.dart';

class KycStepperScreen extends StatefulWidget {
  final int initialStep;
  final bool isEditMode;
  const KycStepperScreen({
    super.key,
    required this.initialStep,
    this.isEditMode = false,
  });

  @override
  State<KycStepperScreen> createState() => _KycStepperScreenState();
}

class _KycStepperScreenState extends State<KycStepperScreen> {
  Map<String, ExistingDocument> existingDocuments = {};
  List<ServiceDropdownModel> dropdownServices = [];
  bool isLoadingKyc = true;
  Map<String, dynamic>? fullKycData;
  List<BloodGroupModel> bloodGroups = [];
  String? selectedBloodGroupName;
  bool bloodLoading = false;
  int activeStep = 0;
  final List<bool> stepCompleted = List.generate(10, (_) => false);
  final List<bool> stepError = List.generate(10, (_) => false);
  bool declarationAccepted = false;

  List<SelectedServiceData> selectedServices = [];
  bool isLoadingServices = true;

  ServiceCertificateListResponse? serviceCertificateListResponse;
  Map<String, File?> professionalDocFiles = {};
  bool isLoadingCertificateList = false;

  File? signatureFile;

  Map<String, File?> pickedFiles = {};
  SizedBox fieldSpace = const SizedBox(height: 14);
  bool showAccountNumber = false;
  bool showConfirmAccountNumber = false;
  final ImagePicker picker = ImagePicker();
  // STEP 1

  final nameController = TextEditingController();
  final dobController = TextEditingController();

  final aadharController = TextEditingController();
  final panController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final talukController = TextEditingController();
  final districtController = TextEditingController();
  final pincodeController = TextEditingController();

  // STEP 2
  bool hasFirm = false;
  bool hasGst = false;
  bool hasEmployees = false;
  bool gstVerifying = false;
  bool gstVerified = false;

  final legalNameController = TextEditingController();
  final companyNameController = TextEditingController();
  final companyAddressController = TextEditingController();
  final companyCityController = TextEditingController();
  final companyTalukController = TextEditingController();
  final companyDistrictController = TextEditingController();
  final companyPincodeController = TextEditingController();
  final numberOfEmployeesController = TextEditingController();
  final gstController = TextEditingController();

  // STEP 3
  final bankNameController = TextEditingController();
  final holderNameController = TextEditingController();
  final accountTypeController = TextEditingController();
  final accountNumberController = TextEditingController();
  final cnfAccountNumberController = TextEditingController();
  final ifscController = TextEditingController();
  final branchNameController = TextEditingController();
  final upiController = TextEditingController();
  bool hasNavigated = false;
  final GlobalKey signSectionKey = GlobalKey();
  final ScrollController scrollController = ScrollController();
  bool _isPrefilling = false;
  Map<String, String>? personalFieldErrors;
  bool isDomestic = false;
  bool isCommercial = false;
  bool isCorporate = false;
  Map<String, String>? companyFieldErrors;
  Map<String, String>? bankFieldErrors;
  Set<String>? documentMissingKeys;

  // New Services Logic (Step 3) — Years of Experience per Category
  Map<int, TextEditingController> categoryExperienceControllers = {};

  // STEP 4 FILES
  File? aadharFront;
  File? aadharBack;
  File? panCard;
  File? bankStatement;
  File? photo;
  File? gstDocument;
  bool panLinkLoading = false;
  bool? isPanLinked;
  DateTime? selectedDob;

  late final StreamSubscription serviceSub;
  Map<String, List<dynamic>> categoryServices = {};

  // STEP 2: EDUCATION (New)
  String? selectedQualification;
  String? passedOutYear;
  bool hasEduCertificate = false;
  List<File> eduCertificateFiles = [];
  List<ExistingDocument> existingEduCertificates = [];
  Map<String, dynamic>? _kycSteps;

  // STEP 3: CATEGORIES & SERVICES
  List<SelectedCategoryData> selectedCategories = [];

  // STEP 4: PROFESSIONAL CERTIFICATES (key = "serviceId_certificateId")
  Map<String, List<File>> professionalFilesMap = {};
  Map<String, TextEditingController> certNumberControllers = {};
  Map<String, TextEditingController> certExpiryControllers = {};
  Map<String, bool> noExpiryMap = {};
  Map<int, bool> showOptionalCertsMap = {};
  Map<int, int?> selectedMandatoryCerts = {};

  @override
  void initState() {
    super.initState();

    checkLocationPermission();

    activeStep = widget.initialStep;

    pincodeController.addListener(_onPincodeChange);
    companyPincodeController.addListener(_onCompanyPincodeChange);

    accountNumberController.addListener(() => setState(() {}));
    cnfAccountNumberController.addListener(() => setState(() {}));
    panController.addListener(() {
      if (isPanLinked != null) {
        setState(() {
          isPanLinked = null;
        });
      }
    });

    fetchBloodGroups();

    gstController.addListener(() {
      if (!mounted) return;
      if (gstVerified) {
        setState(() => gstVerified = false);
      }
    });

    _initializeScreen();
  }

  void _onCompanyPincodeChange() async {
    if (_isPrefilling) return;
    final pin = companyPincodeController.text.trim();
    if (pin.length == 6) {
      final response = await PincodeService.getLocation(pin);
      if (response.success && response.data != null && mounted) {
        setState(() {
          companyDistrictController.text = response.data!['district'] ?? '';
          companyTalukController.text = response.data!['taluk_name'] ?? '';
          companyCityController.text =
              response.data!['village_town_city_name'] ?? '';
        });
      }
    }
  }

  void _initializeScreen() {
    serviceSub = context.read<ServiceCubit>().stream.listen((state) {
      if (state is ServiceLoaded) {
        setState(() {
          categoryServices.clear();
          for (var cat in state.categories) {
            final catName = cat.name;
            if (!categoryServices.containsKey(catName)) {
              categoryServices[catName] = [];
            }
            // Add all services for this category
            for (var sub in cat.subcategories) {
              for (var service in sub.services) {
                categoryServices[catName]!.add(
                  ServiceDropdownModel(
                    id: service.id,
                    categoryId: cat.id,
                    categoryName: cat.name,
                    subcategoryName: sub.name,
                    serviceName: service.serviceName,
                    hasCertificate: service.certificates.isNotEmpty,
                  ),
                );
              }
            }
          }
          isLoadingServices = false;
          _deriveCategoriesIfMissing();
        });
      }
    });

    context.read<ServiceCubit>().loadServices();
    fetchFullKyc();
    if (activeStep >= 3) {
      _fetchServiceCertificateList();
    }
  }

  Future<void> fetchFullKyc() async {
    try {
      final data = await KycDataLoader.fetchFullKyc();
      if (data != null && mounted) {
        fullKycData = data;
        _prefillFromFullKyc(data);
        final steps = data['kyc_steps'] as Map<String, dynamic>?;
        if (steps != null) {
          final completed = KycDataLoader.updateStepCompletionFromApi(steps);
          for (
            var i = 0;
            i < completed.length && i < stepCompleted.length;
            i++
          ) {
            stepCompleted[i] = completed[i];
          }
        }
      }
    } catch (e) {
      debugPrint("Failed to fetch full KYC: $e");
    } finally {
      if (mounted) setState(() => isLoadingKyc = false);
    }
  }

  Future<void> fetchBloodGroups() async {
    setState(() => bloodLoading = true);
    try {
      final list = await KycDataLoader.fetchBloodGroups();
      if (mounted) {
        setState(() {
          bloodGroups = list;
          bloodLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => bloodLoading = false);
      debugPrint("Failed to load blood groups: $e");
    }
  }

  Future<void> _pickDob() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDob = picked;
        dobController.text =
            "${picked.day.toString().padLeft(2, '0')}/"
            "${picked.month.toString().padLeft(2, '0')}/"
            "${picked.year}";
      });
    }
  }

  Future<void> checkPanAadharLink() async {
    final aadhar = aadharController.text.replaceAll(' ', '').trim();
    final pan = panController.text.trim();

    if (aadhar.length != 12 || pan.length != 10) {
      _error("Enter valid Aadhar & PAN");
      return;
    }

    setState(() {
      panLinkLoading = true;
      isPanLinked = null;
    });

    try {
      final token = await SharedPrefsHelper.getToken();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstants.aadharPanLinkage),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Connection'] = 'close';

      request.fields['aadhaar_number'] = aadhar;
      request.fields['pan_number'] = pan;

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      setState(() {
        panLinkLoading = false;
        isPanLinked = data['data']['is_linked'] == true;
      });
    } catch (e) {
      setState(() {
        panLinkLoading = false;
        isPanLinked = false;
      });

      _error("Verification failed");
    }
  }

  bool _shouldAdvance() {
    if (!widget.isEditMode) return true;
    final nextStep = activeStep + 1;

    String? nextStepKey;
    switch (nextStep) {
      case 1:
        nextStepKey = 'educational_qualification';
        break;
      case 2:
        nextStepKey = 'technician_service_category';
        break;
      case 3:
        nextStepKey = 'service_certificates';
        break;
      case 4:
        nextStepKey = 'company_kyc';
        break;
      case 5:
        nextStepKey = 'bank_kyc';
        break;
      case 6:
        nextStepKey = 'document_kyc';
        break;
    }

    if (nextStep == 7) return true;
    if (nextStepKey == null) return false;

    // Robust lookup for the next step status
    final nextStepData =
        _kycSteps?[nextStepKey] ??
        _kycSteps?[nextStepKey.replaceAll('_', '-')] ??
        _kycSteps?[nextStepKey.split('_').first] ??
        _kycSteps?['${nextStepKey.split('_').first}_kyc'];

    final status = nextStepData?['status'] ?? 'not_started';

    // During a completely fresh account flow (no steps started at all),
    // allow moving forward to everything.
    final anyStepStarted =
        _kycSteps?.values.any((v) {
          if (v is! Map) return false;
          final s = v['status'];
          return s != null && s != 'not_started';
        }) ??
        false;
    if (!anyStepStarted) return true;

    // Normalize status for comparisons
    final s = (status ?? "not_started").toLowerCase().trim();

    // We only restrict movement if the next step is already successfully submitted.
    // This allows moving into steps that are unstarted, rejected, or in any unknown state.
    final isSubmitted = s == 'pending' || s == 'completed' || s == 'verified';
    return !isSubmitted;
  }

  void handleBack() {
    if (widget.isEditMode) {
      Navigator.pop(context);
      return;
    }
    if (activeStep > 0) {
      setState(() {
        activeStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    print(position);
  }

  void _prefillFromFullKyc(Map<String, dynamic> data) {
    if (mounted) setState(() => _isPrefilling = true);
    try {
      final kycSteps = data['kyc_steps'] as Map<String, dynamic>? ?? {};
      _kycSteps = kycSteps;

      setState(() {
        // Try profile_kyc as separate key first, then inside kyc_steps
        final profile =
            data['profile_kyc'] ??
            data['personal_kyc'] ??
            kycSteps['profile_kyc'];
        if (profile != null) {
          nameController.text = profile['name'] ?? data['name'] ?? '';
          dobController.text = profile['date_of_birth'] ?? '';
          selectedBloodGroupName = profile['blood_group'];

          final aadharVal = (profile['aadhar_number'] ?? '')
              .toString()
              .replaceAll(RegExp(r'[^0-9]'), '');
          if (aadharVal.length <= 12) {
            final buf = StringBuffer();
            for (var i = 0; i < aadharVal.length; i++) {
              if (i > 0 && i % 4 == 0) buf.write(' ');
              buf.write(aadharVal[i]);
            }
            aadharController.text = buf.toString();
          } else {
            aadharController.text = profile['aadhar_number'] ?? '';
          }

          panController.text = (profile['pan_number'] ?? '')
              .toString()
              .toUpperCase();
          addressController.text = profile['address'] ?? '';
          cityController.text =
              profile['city'] ?? profile['city_town_village'] ?? '';
          talukController.text = profile['taluk'] ?? '';
          districtController.text = profile['district'] ?? '';
          pincodeController.text = profile['pincode'] ?? '';

          isDomestic = profile['domestic'] == 1 || profile['domestic'] == true;
          isCommercial =
              profile['commercial'] == 1 || profile['commercial'] == true;
          isCorporate =
              profile['corporate'] == 1 || profile['corporate'] == true;
        }

        final edu =
            data['edu_qualification'] ??
            data['educational_qualification'] ??
            kycSteps['educational_qualification'] ??
            kycSteps['edu_qualification'];
        if (edu != null) {
          selectedQualification =
              edu['maximum_education_qualification'] ?? edu['qualification'];
          passedOutYear = edu['passed_out_year']?.toString();
          existingEduCertificates.clear();
          if (edu['certificates'] != null &&
              (edu['certificates'] as List).isNotEmpty) {
            hasEduCertificate = true;
            for (var c in edu['certificates']) {
              existingEduCertificates.add(
                ExistingDocument(
                  filename: c['filename'] ?? c['key'] ?? '',
                  url: c['url'] ?? '',
                ),
              );
            }
          } else {
            hasEduCertificate =
                edu['has_certificate'] == 1 || edu['has_certificate'] == true;
          }
        }

        final categories =
            (data['technician_service_category'] ??
                    kycSteps['technician_service_category'])
                as List? ??
            [];
        selectedCategories.clear();
        for (var c in categories) {
          final id =
              int.tryParse((c['category_id'] ?? c['id']).toString()) ?? 0;
          final catName = c['category_name'] ?? c['name'] ?? '';
          if (catName.isNotEmpty) {
            final cat = SelectedCategoryData(id: id, name: catName);
            cat.experienceController.text = (c['years_of_experience'] ?? "")
                .toString();
            selectedCategories.add(cat);
          }
        }

        final servicesList =
            (data['technician_services'] ?? kycSteps['technician_services'])
                as List? ??
            [];
        selectedServices.clear();
        for (var s in servicesList) {
          final id = int.tryParse((s['service_id'] ?? s['id']).toString()) ?? 0;
          final sName = s['service_name'] ?? s['name'] ?? '';
          if (sName.isNotEmpty) {
            selectedServices.add(
              SelectedServiceData(
                serviceId: id,
                serviceName: sName,
                hasCertificate:
                    s['hasCertificate'] == true || s['has_certificate'] == true,
              ),
            );
          }
        }

        final company = data['company_kyc'] ?? kycSteps['company_kyc'];
        if (company != null) {
          hasFirm =
              company['company_available'] == 1 ||
              company['company_available'] == true;
          hasGst =
              company['gst_available'] == 1 || company['gst_available'] == true;
          gstController.text = company['gstin'] ?? '';
          legalNameController.text = company['legal_name'] ?? '';
          companyNameController.text = company['company_name'] ?? '';
          companyAddressController.text = company['company_address'] ?? '';
          companyCityController.text = company['city_town_village'] ?? '';
          companyTalukController.text = company['taluk'] ?? '';
          companyDistrictController.text = company['district'] ?? '';
          companyPincodeController.text = company['pincode'] ?? '';
          numberOfEmployeesController.text =
              company['number_of_employees']?.toString() ?? '';
          hasEmployees =
              (int.tryParse(numberOfEmployeesController.text) ?? 0) > 0;
        }

        final bank = data['bank_kyc'] ?? kycSteps['bank_kyc'];
        if (bank != null) {
          bankNameController.text = bank['bank_name'] ?? '';
          holderNameController.text = bank['account_holder_name'] ?? '';
          accountNumberController.text = bank['account_number'] ?? '';
          cnfAccountNumberController.text = bank['account_number'] ?? '';
          accountTypeController.text = bank['account_type'] ?? '';
          ifscController.text = (bank['ifsc_code'] ?? '')
              .toString()
              .toUpperCase();
          branchNameController.text = bank['branch_name'] ?? '';
          upiController.text = bank['upi_id'] ?? '';
        }

        final documents =
            (data['document_kyc'] ?? kycSteps['document_kyc']) as List? ?? [];
        existingDocuments.clear();
        for (var doc in documents) {
          final key = KycDataLoader.mapApiKeyToLocalKey(doc['key']);
          existingDocuments[key] = ExistingDocument(
            filename: doc['filename'] ?? '',
            url: doc['url'] ?? '',
          );
        }

        _deriveCategoriesIfMissing();
      });
    } finally {
      if (mounted) setState(() => _isPrefilling = false);
    }
  }

  void _deriveCategoriesIfMissing() {
    if (selectedCategories.isEmpty &&
        selectedServices.isNotEmpty &&
        categoryServices.isNotEmpty) {
      final derivedCategoryIds = <int>{};
      for (final selectedSvc in selectedServices) {
        for (final catName in categoryServices.keys) {
          final svcList = categoryServices[catName] as List;
          for (final model in svcList) {
            if (model.id == selectedSvc.serviceId) {
              if (!derivedCategoryIds.contains(model.categoryId)) {
                derivedCategoryIds.add(model.categoryId);
                final cat = SelectedCategoryData(
                  id: model.categoryId,
                  name: model.categoryName,
                );
                cat.experienceController.text =
                    "1"; // Default experience backward compatibility
                selectedCategories.add(cat);
              }
            }
          }
        }
      }
    }
  }

  void _onPincodeChange() async {
    if (_isPrefilling) return;
    final pin = pincodeController.text.trim();

    if (pin.length == 6) {
      final response = await PincodeService.getLocation(pin);

      if (response.success && response.data != null && mounted) {
        setState(() {
          districtController.text = response.data!['district'] ?? '';
          talukController.text = response.data!['taluk_name'] ?? '';
          cityController.text = response.data!['village_town_city_name'] ?? '';
        });
      } else if (mounted) {
        setState(() {
          districtController.clear();
          talukController.clear();
          cityController.clear();
        });
        _error(response.message);
      }
    } else if (pin.isEmpty && mounted) {
      setState(() {
        districtController.clear();
        talukController.clear();
        cityController.clear();
      });
    }
  }

  Future<void> pickPassportPhoto() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    await KycDocumentPicker.pickPassportPhoto(
      picker: picker,
      onPicked: (file) {
        if (mounted) {
          setState(() {
            pickedFiles["photo"] = file;
            documentMissingKeys = null;
          });
        }
      },
      onError: _error,
    );
    if (mounted && Navigator.canPop(context)) Navigator.pop(context);
  }

  Future<void> pickDocument(String key) async {
    await KycDocumentPicker.showDocumentSourceSheet(
      context: context,
      key: key,
      picker: picker,
      validateFile: (f, k) => KycDocumentPicker.validateFile(f, k, _error),
      onFilePicked: (file) => setState(() {
        pickedFiles[key] = file;
        documentMissingKeys = null;
      }),
    );
  }

  void _error(String msg) {
    AppSnackBar.show(context, msg, isError: true);
  }

  void _handleProfessionalDocAction(String parameterName) {
    final file = professionalDocFiles[parameterName];
    if (file != null) {
      setState(() => professionalDocFiles[parameterName] = null);
    } else {
      pickProfessionalDocument(parameterName);
    }
  }

  Future<void> pickProfessionalDocument(String parameterName) async {
    await KycDocumentPicker.showDocumentSourceSheet(
      context: context,
      key: parameterName,
      picker: picker,
      validateFile: (f, k) => KycDocumentPicker.validateFile(f, k, _error),
      onFilePicked: (file) =>
          setState(() => professionalDocFiles[parameterName] = file),
    );
  }

  void _handleDocumentAction(String key) {
    final file = pickedFiles[key];
    final existing = existingDocuments[key];

    if (file != null) {
      setState(() => pickedFiles.remove(key));
    } else if (existing != null) {
      setState(() {
        existingDocuments.remove(key);
        pickedFiles.remove(key);
      });
    } else {
      if (key == "photo") {
        pickPassportPhoto();
      } else {
        pickDocument(key);
      }
    }
  }

  Future<void> pickEduCertificates() async {
    final files = await KycDocumentPicker.pickFiles(context);
    if (files.isNotEmpty) {
      setState(() => eduCertificateFiles = files);
    }
  }

  Future<void> pickProfessionalFiles(String certKey) async {
    final files = await KycDocumentPicker.pickFiles(context);
    if (files.isNotEmpty) {
      setState(() {
        final existing = professionalFilesMap[certKey] ?? [];
        professionalFilesMap[certKey] = [...existing, ...files];
      });
    }
  }

  Widget stepContent() {
    switch (activeStep) {
      case 0:
        return KycPersonalStep(
          nameController: nameController,
          dobController: dobController,
          aadharController: aadharController,
          panController: panController,
          addressController: addressController,
          pincodeController: pincodeController,
          districtController: districtController,
          talukController: talukController,
          cityController: cityController,
          bloodGroups: bloodGroups,
          selectedBloodGroupName: selectedBloodGroupName,
          onBloodGroupChanged: (v) =>
              setState(() => selectedBloodGroupName = v),
          bloodLoading: bloodLoading,
          panLinkLoading: panLinkLoading,
          isPanLinked: isPanLinked,
          onPickDob: _pickDob,
          onCheckPanAadharLink: checkPanAadharLink,
          isDomestic: isDomestic,
          isCommercial: isCommercial,
          isCorporate: isCorporate,
          onWorkingFieldChanged: (field, value) {
            setState(() {
              if (field == "Domestic") isDomestic = value;
              if (field == "Commercial") isCommercial = value;
              if (field == "Corporate") isCorporate = value;
            });
          },
          fieldErrors: personalFieldErrors,
        );
      case 1:
        return KycEduStep(
          selectedQualification: selectedQualification,
          passedOutYear: passedOutYear,
          onQualificationChanged: (v) =>
              setState(() => selectedQualification = v),
          onYearChanged: (v) => setState(() => passedOutYear = v),
          hasCertificate: hasEduCertificate,
          onHasCertificateChanged: (v) => setState(() => hasEduCertificate = v),
          selectedFiles: eduCertificateFiles,
          existingCertificates: existingEduCertificates,
          onFilesPicked: (files) =>
              setState(() => eduCertificateFiles.addAll(files)),
          onRemoveFile: (idx) =>
              setState(() => eduCertificateFiles.removeAt(idx)),
          onRemoveExisting: (idx) =>
              setState(() => existingEduCertificates.removeAt(idx)),
        );
      case 2:
        return KycServicesStep(
          selectedCategories: selectedCategories,
          selectedServices: selectedServices,
          isLoadingServices: isLoadingServices,
          onOpenCategoryBottomSheet: _openCategoryBottomSheet,
          onOpenServiceBottomSheet: _openServiceBottomSheet,
        );
      case 3:
        if (isLoadingCertificateList) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return KycProfessionalDocumentStep(
          certificateResponse: serviceCertificateListResponse,
          certificateFiles: professionalFilesMap,
          onFilesPicked: (key, files) => setState(() {
            final existing = professionalFilesMap[key] ?? [];
            professionalFilesMap[key] = [...existing, ...files];
          }),
          onRemoveFile: (key, idx) =>
              setState(() => professionalFilesMap[key]!.removeAt(idx)),
          numberControllers: certNumberControllers,
          expiryControllers: certExpiryControllers,
          noExpiryMap: noExpiryMap,
          onNoExpiryChanged: (key, v) => setState(() => noExpiryMap[key] = v),
          showOptionalCertsMap: showOptionalCertsMap,
          onShowOptionalChanged: (svcId, v) => setState(() {
            showOptionalCertsMap[svcId] = v;
          }),
          selectedMandatoryCerts: selectedMandatoryCerts,
          onMandatorySelected: (svcId, certId) async {
            setState(() {
              selectedMandatoryCerts[svcId] = certId;
            });

            // Logic to handle "Letter from Registered Vendor"
            final svc = serviceCertificateListResponse?.services
                .where((s) => s.serviceId == svcId)
                .firstOrNull;
            if (svc != null) {
              final cert = svc.certificates
                  .where((c) => c.certificateId == certId)
                  .firstOrNull;
              if (cert?.certificateName == "Letter from Registered Vendor") {
                final key = '${svcId}_$certId';
                // If no file already added, auto-load the placeholder as a File
                if ((professionalFilesMap[key] ?? []).isEmpty) {
                  final file = await _loadAssetAsFile('assets/images/no_image.png');
                  if (file != null) {
                    setState(() {
                      professionalFilesMap[key] = [file];
                      noExpiryMap[key] = true; // Auto-set no expiry
                    });
                  }
                } else {
                  // Even if files were there, ensure no expiry is checked
                  setState(() => noExpiryMap[key] = true);
                }
              }
            }
          },
        );
      case 4:
        return KycCompanyStep(
          fieldErrors: companyFieldErrors,
          hasFirm: hasFirm,
          hasGst: hasGst,
          gstVerifying: gstVerifying,
          gstVerified: gstVerified,
          hasEmployees: hasEmployees,
          onHasFirmChanged: (v) => setState(() => hasFirm = v),
          onHasGstChanged: (v) => setState(() => hasGst = v),
          onHasEmployeesChanged: (v) => setState(() => hasEmployees = v),
          gstController: gstController,
          legalNameController: legalNameController,
          companyNameController: companyNameController,
          companyAddressController: companyAddressController,
          companyPincodeController: companyPincodeController,
          companyDistrictController: companyDistrictController,
          companyTalukController: companyTalukController,
          companyCityController: companyCityController,
          numberOfEmployeesController: numberOfEmployeesController,
        );
      case 5:
        return KycBankStep(
          fieldErrors: bankFieldErrors,
          bankNameController: bankNameController,
          holderNameController: holderNameController,
          accountTypeController: accountTypeController,
          accountNumberController: accountNumberController,
          cnfAccountNumberController: cnfAccountNumberController,
          ifscController: ifscController,
          branchNameController: branchNameController,
          upiController: upiController,
          showAccountNumber: showAccountNumber,
          onToggleShowAccountNumber: () =>
              setState(() => showAccountNumber = !showAccountNumber),
        );
      case 6:
        return KycDocumentsStep(
          pickedFiles: pickedFiles,
          existingDocuments: existingDocuments,
          hasFirm: hasFirm,
          hasGst: hasGst,
          missingKeys: documentMissingKeys,
          onDocumentAction: _handleDocumentAction,
        );
      case 7:
        if (serviceCertificateListResponse == null && !isLoadingCertificateList) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted &&
                serviceCertificateListResponse == null &&
                !isLoadingCertificateList) {
              _fetchServiceCertificateList();
            }
          });
        }
        return KycPreviewStep(
          qualification: selectedQualification,
          passedOutYear: passedOutYear,
          eduCertificateFiles: eduCertificateFiles,
          existingEduCertificates: existingEduCertificates,
          onEditEducation: () => setState(() => activeStep = 1),
          name: nameController.text,
          dob: dobController.text,
          bloodGroup: selectedBloodGroupName ?? "Not selected",
          aadhar: aadharController.text,
          pan: panController.text,
          address: addressController.text,
          district: districtController.text,
          taluk: talukController.text,
          city: cityController.text,
          pincode: pincodeController.text,
          servicesSummary: selectedServices.isNotEmpty
              ? selectedServices.map((s) => s.serviceName).join(", ")
              : "No services selected",
          hasFirm: hasFirm,
          hasGst: hasGst,
          legalName: legalNameController.text,
          companyName: companyNameController.text,
          companyAddress: companyAddressController.text,
          companyDistrict: companyDistrictController.text,
          companyCity: companyCityController.text,
          companyTaluk: companyTalukController.text,
          companyPincode: companyPincodeController.text,
          numberOfEmployees: numberOfEmployeesController.text,
          gstNumber: gstController.text,
          bankName: bankNameController.text,
          holderName: holderNameController.text,
          accountType: accountTypeController.text,
          accountNumber: accountNumberController.text,
          ifsc: ifscController.text,
          upi: upiController.text,
          pickedFiles: pickedFiles,
          declarationAccepted: declarationAccepted,
          onDeclarationChanged: (v) =>
              setState(() => declarationAccepted = v ?? false),
          professionalFilesMap: professionalFilesMap,
          certNumberControllers: certNumberControllers,
          certExpiryControllers: certExpiryControllers,
          noExpiryMap: noExpiryMap,
          certificateResponse: serviceCertificateListResponse,
          workingField: [
            if (isDomestic) "Domestic",
            if (isCommercial) "Commercial",
            if (isCorporate) "Corporate",
          ].join(", "),
          signatureFile: signatureFile,
          onSignatureSaved: (file) =>
              context.read<KycCubit>().uploadSignature(file),
          onReSign: () => setState(() => signatureFile = null),
          onEditPersonal: () => setState(() => activeStep = 0),
          onEditServices: () => setState(() => activeStep = 2),
          onEditProfessionalDoc: () => setState(() => activeStep = 3),
          onEditCompany: () => setState(() => activeStep = 4),
          onEditBank: () => setState(() => activeStep = 5),
          onEditDocuments: () => setState(() => activeStep = 6),
          zoomableImageBuilder: kycZoomableImage,
          signSectionKey: signSectionKey,
          onScrollToSign: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                );
              });
            });
          },
        );
      default:
        return const SizedBox();
    }
  }

  List<String> get requiredDocumentKeys => [
    "aadhar_front",
    "aadhar_back",
    "pan_card",
    "bank_statement",
    "photo",
    'license_front',
    'license_back',
    if (hasFirm) "company_photo",
    if (hasGst) "gst_document",
  ];

  bool allFilesPicked() {
    return requiredDocumentKeys.every(
      (k) => pickedFiles[k] != null || existingDocuments[k] != null,
    );
  }

  Set<String> getMissingDocumentKeys() {
    return requiredDocumentKeys
        .where((k) => pickedFiles[k] == null && existingDocuments[k] == null)
        .toSet();
  }

  void _applyGstDetails(Map<String, dynamic> d) {
    legalNameController.text =
        d['legal_name']?.toString() ?? legalNameController.text;
    companyNameController.text =
        d['trade_name']?.toString() ??
        d['legal_name']?.toString() ??
        companyNameController.text;
    final addr =
        d['principal_place_of_business_fields'] as Map<String, dynamic>?;
    final addrFields =
        addr?['principal_place_of_business_address'] as Map<String, dynamic>?;
    if (addrFields != null) {
      final parts = <String>[];
      for (final k in [
        'door_number',
        'building_name',
        'street',
        'location',
        'dst',
        'state_name',
        'pincode',
      ]) {
        final v = addrFields[k]?.toString();
        if (v != null && v.isNotEmpty) parts.add(v);
      }
      if (parts.isNotEmpty) companyAddressController.text = parts.join(', ');
      final pinVal = addrFields['pincode']?.toString();
      if (pinVal != null && pinVal.isNotEmpty) {
        companyPincodeController.text = pinVal;
      }
      final dstVal = addrFields['dst']?.toString();
      if (dstVal != null && dstVal.isNotEmpty) {
        companyDistrictController.text = dstVal;
      }
      final cityVal =
          addrFields['city']?.toString() ?? addrFields['location']?.toString();
      if (cityVal != null && cityVal.isNotEmpty) {
        companyCityController.text = cityVal;
      }
      final locVal = addrFields['location']?.toString();
      if (locVal != null && locVal.isNotEmpty) {
        companyTalukController.text = locVal;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KycStepperListeners(
      hasNavigated: hasNavigated,
      setHasNavigated: (v) => hasNavigated = v,
      onKycSuccess: () {
        // Helper to check if a step is already completed
        bool _isStepDone(int step) {
          List<String> keys;
          switch (step) {
            case 1:
              keys = [
                'educational_qualification',
                'edu_qualification',
                'education_kyc',
              ];
              break;
            case 2:
              keys = [
                'technician_service_category',
                'technician_services',
                'services_kyc',
              ];
              break;
            case 3:
              keys = ['service_certificates'];
              break;
            case 4:
              keys = ['company_kyc'];
              break;
            case 5:
              keys = ['bank_kyc'];
              break;
            case 6:
              keys = ['document_kyc'];
              break;
            default:
              return false;
          }
          for (final key in keys) {
            final stepData = _kycSteps?[key];
            if (stepData != null) {
              final s =
                  (stepData is Map
                          ? (stepData['status'] ?? 'not_started')
                          : stepData)
                      .toString()
                      .toLowerCase();
              if (s == 'completed' || s == 'verified' || s == 'approved')
                return true;
            }
          }
          return false;
        }

        stepCompleted[activeStep] = true;
        final nextStep = activeStep + 1;

        // If next step is already completed or we reached the end, go back to onboarding
        if (nextStep > 6 || _isStepDone(nextStep)) {
          Navigator.pop(context);
          return;
        }

        // Next step is not completed, move to it
        setState(() {
          activeStep = nextStep;
        });
        if (activeStep == 2 && serviceCertificateListResponse == null) {
          _fetchServiceCertificateList();
        }
      },
      onKycError: (msg) => AppSnackBar.show(context, msg, isError: true),
      onGstVerifyLoading: () => setState(() => gstVerifying = true),
      onGstVerified: (d) {
        setState(() {
          gstVerifying = false;
          gstVerified = true;
          _applyGstDetails(d);
        });
        AppSnackBar.show(context, "GST verified successfully", isError: false);
      },
      onGstVerifyError: (msg) {
        setState(() {
          gstVerifying = false;
          gstVerified = false;
        });
        AppSnackBar.show(context, msg, isError: true);
      },
      onDocumentUploaded: () {
        AppSnackBar.show(context, "Documents uploaded successfully", isError: false);
        setState(() {
          stepCompleted[6] = true;
          activeStep = 7;
        });
      },
      onProfessionalDocumentsUploaded: () {
        AppSnackBar.show(context, "Certificate documents uploaded successfully", isError: false);
        if (widget.isEditMode) {
          Navigator.pop(context);
          return;
        }
        setState(() {
          stepCompleted[3] = true;
          activeStep = 4;
        });
      },
      onSignatureUploaded: (file) {
        if (file is File) {
          setState(() {
            signatureFile = file;
          });
          AppSnackBar.show(context, "Signature saved successfully", isError: false);
        }
      },
      onKycOtpSent: (verificationToken) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                KycVerificationOtpScreen(verificationToken: verificationToken),
          ),
        );
      },
      child: BlocBuilder<KycCubit, KycState>(
        builder: (context, state) {
          if (isLoadingKyc) {
            return Scaffold(
              appBar: AppBar(title: const Text("Loading Profile...")),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          return KycStepperScaffold(
            activeStep: activeStep,
            stepCompleted: stepCompleted,
            stepError: stepError,
            stepContent: stepContent(),
            onBack: handleBack,
            onNext: handleNext,
            isLoading:
                state is KycLoading ||
                state is DocumentUploading ||
                _isPrefilling,
            scrollController: scrollController,
          );
        },
      ),
    );
  }

  void handleNext() async {
    final cubit = context.read<KycCubit>();

    if (activeStep == 0) {
      final aadharClean = aadharController.text.replaceAll(' ', '');
      final errors = <String, String>{};
      if (nameController.text.trim().isEmpty) errors['name'] = 'Required';
      if (dobController.text.trim().isEmpty) errors['dob'] = 'Required';
      if (selectedBloodGroupName == null) errors['bloodGroup'] = 'Required';
      if (aadharClean.isEmpty || aadharClean.length != 12) {
        errors['aadhar'] = '12 digits';
      }
      if (panController.text.trim().length != 10) {
        errors['pan'] = '10 digits';
      }
      if (addressController.text.trim().isEmpty) errors['address'] = 'Required';
      if (pincodeController.text.trim().isEmpty) errors['pincode'] = 'Required';
      if (districtController.text.trim().isEmpty) {
        errors['district'] = 'Required';
      }
      if (talukController.text.trim().isEmpty) errors['taluk'] = 'Required';
      if (cityController.text.trim().isEmpty) errors['city'] = 'Required';
      if (!isDomestic && !isCommercial && !isCorporate) {
        errors['workingField'] = 'Select at least one';
      }

      if (errors.isNotEmpty) {
        setState(() => personalFieldErrors = errors);
        _error("Please correct all personal errors");
        return;
      }
      setState(() => personalFieldErrors = null);
      await cubit.submitStep(
        stepIndex: 0,
        step1: KycStep1Response(
          name: nameController.text,
          dob: dobController.text,
          bloodGroup: selectedBloodGroupName ?? "",
          aadharNumber: aadharClean,
          panNumber: panController.text,
          address: addressController.text,
          taluk: talukController.text,
          district: districtController.text,
          city: cityController.text,
          pincode: pincodeController.text,
          isDomestic: isDomestic,
          isCommercial: isCommercial,
          isCorporate: isCorporate,
        ),
      );
    } else if (activeStep == 1) {
      if (selectedQualification == null) {
        _error("Please select a qualification");
        return;
      }
      if (passedOutYear == null) {
        _error("Please select passed out year");
        return;
      }
      if (hasEduCertificate &&
          eduCertificateFiles.isEmpty &&
          existingEduCertificates.isEmpty) {
        _error("Please upload education certificate");
        return;
      }
      await cubit.saveEduQualification(
        qualification: selectedQualification!,
        passedOutYear: passedOutYear!,
        files: eduCertificateFiles,
      );
    } else if (activeStep == 2) {
      if (selectedCategories.isEmpty) {
        _error("Please select at least one category");
        return;
      }
      for (var cat in selectedCategories) {
        if (cat.experienceController.text.isEmpty) {
          _error("Enter experience for ${cat.name}");
          return;
        }
      }
      if (selectedServices.isEmpty) {
        _error("Please select services");
        return;
      }

      final catIds = selectedCategories.map((c) => c.id).toList();
      await cubit.saveServiceCategories(catIds);

      final serviceIds = selectedServices.map((s) => s.serviceId).toList();
      await cubit.saveTechnicianServices(serviceIds);

      // Pre-fetch certificates for the next step (Step 3)
      _fetchServiceCertificateList();
    } else if (activeStep == 3) {
      final response = serviceCertificateListResponse;
      if (response != null) {
        // Validate mandatory certificates have files uploaded
        for (final svc in response.services) {
          // If the backend says no mandatory certificates are missing, skip validation for this service
          if (svc.missingMandatoryCount == 0) continue;

          // For all services, uploading even one mandatory certificate is now considered enough (as requested)
          const isAnyOne = true;
          // final policy = svc.mandatoryPolicy; // "all" or "any_one"
          // final isAnyOne = svc.anyoneMandatoryIsEnough || policy == 'any_one';

          if (isAnyOne) {
            // Check if AT LEAST ONE mandatory cert is either already uploaded OR being uploaded now.
            bool met = false;

            // NEW: Also check if the currently selected mandatory cert is the 'Vendor Letter' which needs no upload
            final selectedId = selectedMandatoryCerts[svc.serviceId];
            final vendorLetterCertId = svc.mandatoryCertificates
                .where((c) => c.certificateName == "Letter from Registered Vendor")
                .firstOrNull
                ?.certificateId;

            if (selectedId != null && selectedId == vendorLetterCertId) {
              met = true;
            } else {
              for (final cert in svc.mandatoryCertificates) {
                final key = '${svc.serviceId}_${cert.certificateId}';
                if (cert.uploaded ||
                    (professionalFilesMap[key] ?? []).isNotEmpty) {
                  met = true;
                  break;
                }
              }
            }

            if (!met) {
              _error(
                "Please upload at least one mandatory certificate for ${svc.serviceName}",
              );
              return;
            }
          } else {
            // ALL must be uploaded
            for (final cert in svc.mandatoryCertificates) {
              final key = '${svc.serviceId}_${cert.certificateId}';
              final selectedFiles = professionalFilesMap[key] ?? [];
              if (!cert.uploaded && selectedFiles.isEmpty) {
                _error(
                  "${cert.certificateName} is required for ${svc.serviceName}",
                );
                return;
              }
            }
          }
        }

        // Upload all certificates that have files — use repo directly
        try {
          final repo = context.read<KycCubit>().repository;
          for (final certKey in professionalFilesMap.keys) {
            final files = professionalFilesMap[certKey]!;
            if (files.isNotEmpty) {
              final parts = certKey.split('_');
              final serviceId = int.parse(parts[0]);
              final certificateId = int.parse(parts[1]);
              await repo.uploadServiceCertificate(
                serviceId: serviceId,
                certificateId: certificateId,
                certificateNumber: certNumberControllers[certKey]?.text,
                noExpiry: noExpiryMap[certKey] ?? true,
                expiryDate: certExpiryControllers[certKey]?.text,
                files: files,
              );
            }
          }
          // Only advance on success
          AppSnackBar.show(context, "Certificates uploaded successfully", isError: false);
          if (widget.isEditMode) {
            Navigator.pop(context);
            return;
          }
          setState(() {
            stepCompleted[3] = true;
            activeStep = 4;
          });
        } catch (e) {
          _error("Certificate upload failed: $e");
        }
      } else {
        // No certificates required, just skip
        setState(() {
          stepCompleted[3] = true;
          activeStep = 4;
        });
      }
    } else if (activeStep == 4) {
      if (hasFirm) {
        final companyErrors = <String, String>{};
        if (companyNameController.text.trim().isEmpty) {
          companyErrors['companyName'] = 'Required';
        }
        if (companyAddressController.text.trim().isEmpty) {
          companyErrors['companyAddress'] = 'Required';
        }
        if (companyPincodeController.text.trim().isEmpty) {
          companyErrors['companyPincode'] = 'Required';
        }
        if (companyErrors.isNotEmpty) {
          setState(() => companyFieldErrors = companyErrors);
          _error("Company details required");
          return;
        }
      }
      setState(() => companyFieldErrors = null);
      await cubit.submitStep(
        stepIndex: 4,
        step2: KycStep2Response(
          hasFirm: hasFirm,
          hasGst: hasGst,
          companyName: companyNameController.text,
          companyAddress: companyAddressController.text,
          legalName: legalNameController.text,
          gstNumber: gstController.text,
          numberOfEmployees: hasEmployees
              ? (int.tryParse(numberOfEmployeesController.text) ?? 1)
              : 0,
          companyPincode: companyPincodeController.text,
          companyDistrict: companyDistrictController.text,
          companyTaluk: companyTalukController.text,
          companyCity: companyCityController.text,
        ),
      );
    } else if (activeStep == 5) {
      final bankErrors = <String, String>{};
      if (bankNameController.text.trim().isEmpty) {
        bankErrors['bankName'] = 'Required';
      }
      if (holderNameController.text.trim().isEmpty) {
        bankErrors['holderName'] = 'Required';
      }
      if (accountNumberController.text.trim().isEmpty) {
        bankErrors['accountNumber'] = 'Required';
      }
      if (cnfAccountNumberController.text.trim().isEmpty) {
        bankErrors['cnfAccountNumber'] = 'Required';
      }
      if (ifscController.text.trim().isEmpty) bankErrors['ifsc'] = 'Required';
      if (accountNumberController.text != cnfAccountNumberController.text) {
        bankErrors['cnfAccountNumber'] = 'Mismatch';
      }
      if (bankErrors.isNotEmpty) {
        setState(() => bankFieldErrors = bankErrors);
        _error("Bank details required");
        return;
      }
      setState(() => bankFieldErrors = null);
      await cubit.submitStep(
        stepIndex: 5,
        step3: KycStep3Response(
          bankName: bankNameController.text,
          bankAccountNumber: accountNumberController.text,
          holderName: holderNameController.text,
          accountType: accountTypeController.text,
          ifscCode: ifscController.text,
          branchName: branchNameController.text,
          upiId: upiController.text,
        ),
      );
    } else if (activeStep == 6) {
      setState(() => documentMissingKeys = null);
      final uploadFiles = Map<String, File>.fromEntries(
        pickedFiles.entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
      if (uploadFiles.isEmpty) {
        setState(() {
          stepCompleted[6] = true;
          activeStep = 7;
        });
        return;
      }
      await cubit.uploadStep4(files: uploadFiles);
    } else if (activeStep == 7) {
      if (!declarationAccepted) {
        _error("Accept declaration");
        return;
      }
      if (signatureFile == null) {
        _error("Provide signature");
        return;
      }
      context.read<KycCubit>().sendKycOtp();
    }
  }

  void _fetchServiceCertificateList() async {
    if (isLoadingCertificateList) return;
    setState(() => isLoadingCertificateList = true);
    try {
      final resp = await context
          .read<KycCubit>()
          .repository
          .getServiceCertificates();
      final data = ServiceCertificateListResponse.fromJson(resp);
      setState(() {
        serviceCertificateListResponse = data;
        // Initialize maps for every certificate across all services
          for (final svc in data.services) {
            // Auto-select the first mandatory certificate if not already selected
            if (selectedMandatoryCerts[svc.serviceId] == null) {
              final mandatories = svc.certificates
                  .where((c) => c.isMandatory)
                  .toList();
              if (mandatories.isNotEmpty) {
                selectedMandatoryCerts[svc.serviceId] =
                    mandatories.first.certificateId;
              }
            }

            for (final cert in svc.certificates) {
              final key = '${svc.serviceId}_${cert.certificateId}';
              if (!professionalFilesMap.containsKey(key)) {
                professionalFilesMap[key] = [];
                certNumberControllers[key] = TextEditingController();
                certExpiryControllers[key] = TextEditingController();
                noExpiryMap[key] = false;
              }
            }

            // AUTO-UPLOAD logic for "Vendor Letter" on initial fetch
            final selectedId = selectedMandatoryCerts[svc.serviceId];
            if (selectedId != null) {
              final cert = svc.certificates
                  .where((c) => c.certificateId == selectedId)
                  .firstOrNull;
              if (cert?.certificateName == "Letter from Registered Vendor") {
                final k = '${svc.serviceId}_$selectedId';
                if ((professionalFilesMap[k] ?? []).isEmpty) {
                  _loadAssetAsFile('assets/images/no_image.png').then((f) {
                    if (f != null && mounted) {
                      setState(() {
                        professionalFilesMap[k] = [f];
                        noExpiryMap[k] = true; // Auto-set no expiry
                      });
                    }
                  });
                } else {
                  if (mounted) setState(() => noExpiryMap[k] = true);
                }
              }
            }
          }
        isLoadingCertificateList = false;
      });
    } catch (e) {
      setState(() => isLoadingCertificateList = false);
      _error("Failed to fetch certificate requirements: $e");
    }
  }

  void _openCategoryBottomSheet() {
    showKycCategoryBottomSheet(
      context: context,
      selectedCategories: selectedCategories,
      onSelectionChanged: () => setState(() {}),
    );
  }

  void _openServiceBottomSheet() {
    showKycServiceBottomSheet(
      context: context,
      selectedCategories: selectedCategories,
      selectedServices: selectedServices,
      onSelectionChanged: () => setState(() {}),
    );
  }

  @override
  void dispose() {
    serviceSub.cancel();
    nameController.dispose();
    dobController.dispose();
    selectedBloodGroupName = null;
    aadharController.dispose();
    panController.dispose();
    addressController.dispose();
    cityController.dispose();
    talukController.dispose();
    districtController.dispose();
    pincodeController.dispose();
    legalNameController.dispose();
    companyNameController.dispose();
    companyDistrictController.dispose();
    companyTalukController.dispose();
    companyAddressController.dispose();
    companyCityController.dispose();
    companyPincodeController.dispose();
    numberOfEmployeesController.dispose();
    gstController.dispose();
    bankNameController.dispose();
    holderNameController.dispose();
    accountTypeController.dispose();
    cnfAccountNumberController.dispose();
    accountNumberController.dispose();
    ifscController.dispose();
    branchNameController.dispose();
    upiController.dispose();
    pincodeController.removeListener(_onPincodeChange);
    scrollController.dispose();

    super.dispose();
  }

  Future<File?> _loadAssetAsFile(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final fileName = assetPath.split('/').last;
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ));
      return file;
    } catch (e) {
      return null;
    }
  }
}
