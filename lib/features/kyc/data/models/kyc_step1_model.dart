class KycStep1Response {
  final String name;
  final String dob;
  final String bloodGroup;
  final String aadharNumber;
  final String panNumber;
  final String address;
  final String city;
  final String taluk;
  final String district;
  final String pincode;
  final bool isDomestic;
  final bool isCommercial;
  final bool isCorporate;

  KycStep1Response({
    required this.name,
    required this.dob,
    required this.bloodGroup,
    required this.aadharNumber,
    required this.panNumber,
    required this.address,
    required this.city,
    required this.taluk,
    required this.district,
    required this.pincode,
    this.isDomestic = false,
    this.isCommercial = false,
    this.isCorporate = false,
  });

  Map<String, dynamic> toJson() {
    String formattedDob = dob;
    if (dob.contains('/')) {
      final parts = dob.split('/');
      if (parts.length == 3) {
        // DD/MM/YYYY -> YYYY-MM-DD
        formattedDob = '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    }

    return {
      "name": name,
      "date_of_birth": formattedDob,
      "blood_group": bloodGroup,
      "aadhar_number": aadharNumber,
      "pan_number": panNumber,
      "address": address,
      "city_town_village": city,
      "taluk": taluk,
      "district": district,
      "pincode": pincode,
      "domestic": isDomestic,
      "commercial": isCommercial,
      "corporate": isCorporate,
    };
  }
}
