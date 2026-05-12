// ignore_for_file: depend_on_referenced_packages

class GeneralProfile {
  final MaritalInfo? maritalInfo;
  final SpouseEmergency? spouseEmergency;
  final GovtWelfareCard? govtWelfareCard;
  final GenderInfo? genderInfo;
  final BonusPoints? bonusPoints;
  final UtilityTshirt? utilityTshirt;
  final PoliceVerification? policeVerification;
  final EmployeeNumber? employeeNumber;
  final InsuranceDetails? insuranceDetails;
  final EarningScreen? earningScreen;

  GeneralProfile({
    this.maritalInfo,
    this.spouseEmergency,
    this.govtWelfareCard,
    this.genderInfo,
    this.bonusPoints,
    this.utilityTshirt,
    this.policeVerification,
    this.employeeNumber,
    this.insuranceDetails,
    this.earningScreen,
  });

  /// Dual-Mode Parsing: Looks for section data in either grouped keys or flat root keys.
  factory GeneralProfile.fromJson(Map<String, dynamic> json) {
    return GeneralProfile(
      maritalInfo: MaritalInfo.fromJson(json['marital_status'] is Map ? json['marital_status'] : json),
      spouseEmergency: SpouseEmergency.fromJson(json['spouse_emergency_sos'] is Map ? json['spouse_emergency_sos'] : json),
      govtWelfareCard: GovtWelfareCard.fromJson(json['govt_welfare_card'] is Map ? json['govt_welfare_card'] : json),
      genderInfo: GenderInfo.fromJson(json['gender'] is Map ? json['gender'] : json),
      bonusPoints: BonusPoints.fromJson(json['bonus_points'] is Map ? json['bonus_points'] : json),
      utilityTshirt: UtilityTshirt.fromJson(json['utility_tshirt'] is Map ? json['utility_tshirt'] : json),
      policeVerification: PoliceVerification.fromJson(json['police_verification'] is Map ? json['police_verification'] : json),
      employeeNumber: EmployeeNumber.fromJson(json['employee_number'] is Map ? json['employee_number'] : json),
      insuranceDetails: InsuranceDetails.fromJson(json['insurance_details'] is Map ? json['insurance_details'] : json),
      earningScreen: EarningScreen.fromJson(json['earning_screen'] is Map ? json['earning_screen'] : json),
    );
  }

  bool get isEmpty {
    final gp = this;
    return (gp.genderInfo?.genderIdentity == null || gp.genderInfo!.genderIdentity!.isEmpty) &&
           (gp.maritalInfo?.isMarried == null) &&
           (gp.spouseEmergency?.emergencyContactNoSos == null || gp.spouseEmergency!.emergencyContactNoSos!.isEmpty) &&
           (gp.govtWelfareCard?.haveWelfareCard == null);
  }
}

// ─────────────────────── SECTION MODELS ───────────────────────

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value == 1 || value == '1' || value == 'true') return true;
  if (value == 0 || value == '0' || value == 'false') return false;
  return null;
}

class Nominee {
  final String? name;
  final String? aadharCardNo;
  final String? phoneNumber;
  final int? percentage;

  Nominee({this.name, this.aadharCardNo, this.phoneNumber, this.percentage});

  factory Nominee.fromJson(Map<String, dynamic> json) {
    return Nominee(
      name: json['name'] ?? json['nominee_name'],
      aadharCardNo: json['aadhar_card_no'] ?? json['nominee_aadhar_card_no'],
      phoneNumber: json['phone_number'] ?? json['nominee_phone_number'],
      percentage: json['percentage'] != null ? int.tryParse(json['percentage'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'aadhar_card_no': aadharCardNo,
    'phone_number': phoneNumber,
    'percentage': percentage,
  };
}

class MaritalInfo {
  final bool? isMarried;
  final String? nomineeName;
  final String? nomineeAadharCardNo;
  final String? nomineePhoneNumber;
  final List<Nominee>? nominees;

  MaritalInfo({
    this.isMarried,
    this.nomineeName,
    this.nomineeAadharCardNo,
    this.nomineePhoneNumber,
    this.nominees,
  });

  factory MaritalInfo.fromJson(Map<String, dynamic> json) {
    // Only return data if at least one characteristic key exists
    if (!json.containsKey('is_married') && 
        !json.containsKey('nominee_name') && 
        !json.containsKey('nominees')) return MaritalInfo();
        
    return MaritalInfo(
      isMarried: _asBool(json['is_married']),
      nomineeName: json['nominee_name'],
      nomineeAadharCardNo: json['nominee_aadhar_card_no'],
      nomineePhoneNumber: json['nominee_phone_number'],
      nominees: (json['nominees'] as List?)
          ?.map((e) => Nominee.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SpouseEmergency {
  final String? spouseName;
  final String? emergencyContactNoSos;
  final String? marriageDate;
  final bool? sosVisibility;

  SpouseEmergency({this.spouseName, this.emergencyContactNoSos, this.marriageDate, this.sosVisibility});

  factory SpouseEmergency.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('sos_visibility') && !json.containsKey('emergency_contact_no_sos')) return SpouseEmergency();
    return SpouseEmergency(
      spouseName: json['spouse_name'],
      emergencyContactNoSos: json['emergency_contact_no_sos'],
      marriageDate: json['marriage_date'],
      sosVisibility: _asBool(json['sos_visibility']),
    );
  }
}

class GovtWelfareCard {
  final bool? haveWelfareCard;
  final String? cardTypeSchemeName;
  final FileInfo? cardImage;
  final String? cardExpiryDate;

  GovtWelfareCard({this.haveWelfareCard, this.cardTypeSchemeName, this.cardImage, this.cardExpiryDate});

  factory GovtWelfareCard.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('have_welfare_card') && 
        !json.containsKey('card_type_scheme_name') &&
        !json.containsKey('welfare_card_type_scheme_name')) return GovtWelfareCard();
    return GovtWelfareCard(
      haveWelfareCard: _asBool(json['have_welfare_card']),
      cardTypeSchemeName: json['welfare_card_type_scheme_name'] ?? json['card_type_scheme_name'],
      cardImage: json['card_image'] is Map<String, dynamic> ? FileInfo.fromJson(json['card_image']) : null,
      cardExpiryDate: json['welfare_card_expiry_date'] ?? json['card_expiry_date'],
    );
  }
}

class GenderInfo {
  final String? genderIdentity;
  final String? bloodGroup;
  GenderInfo({this.genderIdentity, this.bloodGroup});
  factory GenderInfo.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('gender_identity') && !json.containsKey('blood_group')) return GenderInfo();
    return GenderInfo(
      genderIdentity: json['gender_identity'],
      bloodGroup: json['blood_group'],
    );
  }
}

class BonusPoints {
  final List<String>? festivalSelection;
  final bool? earningScreenVisibility;

  BonusPoints({this.festivalSelection, this.earningScreenVisibility});

  factory BonusPoints.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('festival_selection') && !json.containsKey('earning_screen_visibility')) return BonusPoints();
    return BonusPoints(
      festivalSelection: (json['festival_selection'] as List?)?.cast<String>(),
      earningScreenVisibility: _asBool(json['earning_screen_visibility']),
    );
  }
}

class UtilityTshirt {
  final String? tshirtSize;
  final String? colourPreference;
  UtilityTshirt({this.tshirtSize, this.colourPreference});
  factory UtilityTshirt.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('tshirt_size')) return UtilityTshirt();
    return UtilityTshirt(tshirtSize: json['tshirt_size'], colourPreference: json['colour_preference']);
  }
}

class PoliceVerification {
  final String? certificateNumber;
  final String? issuedBy;
  final String? issueDate;
  final FileInfo? uploadDocument;
  final String? provisionStatus;

  PoliceVerification({this.certificateNumber, this.issuedBy, this.issueDate, this.uploadDocument, this.provisionStatus});

  factory PoliceVerification.fromJson(Map<String, dynamic> json) {
    final key = json.containsKey('certificate_number') ? 'certificate_number' : 'police_certificate_number';
    if (!json.containsKey(key)) return PoliceVerification();
    return PoliceVerification(
      certificateNumber: json[key],
      issuedBy: json['police_issued_by'] ?? json['issued_by'],
      issueDate: json['police_issue_date'] ?? json['issue_date'],
      uploadDocument: (json['upload_document'] ?? json['police_upload_document']) is Map<String, dynamic> 
          ? FileInfo.fromJson(json['upload_document'] ?? json['police_upload_document']) : null,
      provisionStatus: json['police_provision_status'] ?? json['provision_status'],
    );
  }
}

class EmployeeNumber {
  final String? employeeId;
  final String? department;
  final String? designation;
  final String? joiningDate;

  EmployeeNumber({this.employeeId, this.department, this.designation, this.joiningDate});

  factory EmployeeNumber.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('employee_id')) return EmployeeNumber();
    return EmployeeNumber(
      employeeId: json['employee_id'],
      department: json['department'],
      designation: json['designation'],
      joiningDate: json['joining_date'],
    );
  }
}

class InsuranceDetails {
  final String? insuranceProvider;
  final String? policyNumber;
  final String? policyStartDate;
  final String? policyExpiryDate;
  final FileInfo? uploadInsuranceDocument;

  InsuranceDetails({this.insuranceProvider, this.policyNumber, this.policyStartDate, this.policyExpiryDate, this.uploadInsuranceDocument});

  factory InsuranceDetails.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('insurance_provider')) return InsuranceDetails();
    return InsuranceDetails(
      insuranceProvider: json['insurance_provider'],
      policyNumber: json['policy_number'],
      policyStartDate: json['policy_start_date'],
      policyExpiryDate: json['policy_expiry_date'],
      uploadInsuranceDocument: json['upload_insurance_document'] is Map<String, dynamic> 
          ? FileInfo.fromJson(json['upload_insurance_document']) : null,
    );
  }
}

class EarningScreen {
  final String? paymentMethod;
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? upiId;

  EarningScreen({this.paymentMethod, this.bankAccountNumber, this.ifscCode, this.upiId});

  factory EarningScreen.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('payment_method') && !json.containsKey('bank_account_number')) return EarningScreen();
    return EarningScreen(
      paymentMethod: json['payment_method'],
      bankAccountNumber: json['bank_account_number'],
      ifscCode: json['ifsc_code'],
      upiId: json['upi_id'],
    );
  }
}

class FileInfo {
  final String? url;
  final String? name;
  FileInfo({this.url, this.name});
  factory FileInfo.fromJson(Map<String, dynamic> json) => FileInfo(
        url: json['download_url'] ?? json['url'],
        name: json['filename'] ?? json['name'],
      );
}
