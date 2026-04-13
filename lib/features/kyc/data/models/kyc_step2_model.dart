class KycStep2Response {
  final bool hasFirm;
  final bool? hasGst;
  final String? companyName;
  final String? companyAddress;
  final String? companyCity;
  final String? companyDistrict;
  final String? companyTaluk;
  final String? companyPincode;
  final int? numberOfEmployees;
  final String? gstNumber;
  final String? legalName;

  KycStep2Response({
    required this.hasFirm,
    this.hasGst,
    this.companyName,
    this.companyAddress,
    this.companyCity,
    this.companyDistrict,
    this.companyTaluk,
    this.companyPincode,
    this.numberOfEmployees,
    this.gstNumber,
    this.legalName,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      "company_available": hasFirm,
      "gst_available": hasGst ?? false,
    };

    if (hasFirm) {
      data.addAll({
        "company_name": companyName,
        "legal_name": legalName,
        "company_address": companyAddress,
        "district": companyDistrict,
        "taluk": companyTaluk,
        "city_town_village": companyCity,
        "pincode": companyPincode,
        "number_of_employees": numberOfEmployees,
      });
    }

    if (hasGst == true && gstNumber != null) {
      data["gstin"] = gstNumber;
    }

    return data;
  }
}
