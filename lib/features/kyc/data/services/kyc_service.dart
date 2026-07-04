import 'dart:convert';
import 'dart:io';
import 'package:hammer_app/core/config/api_constants.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';
import 'package:http/http.dart' as http;

/// Per-step KYC API (Technician API document). Each step has its own endpoint.
/// Updated to use the new granular service endpoints:
///   - /api/technician/technician_service_category (GET/POST/PATCH)
///   - /api/technician/technician_services (GET/POST/PATCH)
///   - /api/technician/service_certificates (GET/POST)
class KycApiService {
  static final http.Client _client = http.Client();

  KycApiService();

  Future<Map<String, dynamic>> _request({
    required String method,
    required String url,
    Map<String, dynamic>? body,
    bool useSessionToken = true,
  }) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (true) {
      try {
        final token = useSessionToken
            ? await SharedPrefsHelper.getToken()
            : '12345678';
        final headers = <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Connection': 'keep-alive',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        };
        final uri = Uri.parse(url);
        http.Response response;

        if (method == 'GET') {
          response = await _client
              .get(uri, headers: headers)
              .timeout(const Duration(seconds: 30));
        } else if (method == 'POST') {
          response = await _client
              .post(
                uri,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(const Duration(seconds: 30));
        } else if (method == 'PATCH') {
          response = await _client
              .patch(
                uri,
                headers: headers,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(const Duration(seconds: 30));
        } else {
          throw Exception('Unsupported method $method');
        }

        // Check for HTML response before decoding JSON
        final isHtml =
            response.body.trim().startsWith('<!DOCTYPE') ||
            (response.headers['content-type']?.contains('text/html') ?? false);
        if (isHtml) {
          throw Exception(
            'Server returned invalid response (HTML). Please try again.',
          );
        }

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return data;
        }

        if (data.containsKey('errors')) {
          final errors = data['errors'] as Map<String, dynamic>;
          final msg = errors.entries
              .map(
                (e) =>
                    (e.value is List) ? (e.value as List).join('\n') : e.value,
              )
              .join('\n');
          throw Exception(msg.isNotEmpty ? msg : data['message']);
        }
        throw Exception(
          data['message'] ?? 'Request failed (${response.statusCode})',
        );
      } catch (e) {
        final isRetryable =
            e is SocketException ||
            e is http.ClientException ||
            e.toString().contains('TimeoutException') ||
            e.toString().contains('HTML');
        if (retryCount < maxRetries && isRetryable) {
          retryCount++;
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }
        if (e is FormatException) {
          throw Exception(
            'Server error: Invalid response format. Please try again.',
          );
        }
        rethrow;
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PERSONAL KYC
  // ──────────────────────────────────────────────────────────────────────────

  /// GET /api/technician/personal_kyc
  Future<Map<String, dynamic>> getPersonalKyc() async {
    return _request(method: 'GET', url: ApiConstants.personalKyc);
  }

  /// POST /api/technician/personal_kyc
  Future<Map<String, dynamic>> savePersonalKyc(
    Map<String, dynamic> body, {
    bool isUpdate = false,
  }) async {
    final url = ApiConstants.personalKyc;
    return _request(method: isUpdate ? 'PATCH' : 'POST', url: url, body: body);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // EDUCATION QUALIFICATION (New Step 2)
  // Doc endpoint 12a: POST /api/technician/edu-qualification
  // ──────────────────────────────────────────────────────────────────────────

  /// POST /api/technician/edu-qualification (multipart/form-data)
  /// Fields: maximum_education_qualification
  /// Files: certificate_files[]
  Future<Map<String, dynamic>> saveEduQualification({
    required String qualification,
    String? passedOutYear,
    required List<File> files,
  }) async {
    final token = await SharedPrefsHelper.getToken();
    if (token == null || token.isEmpty) throw Exception('Not authenticated');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstants.eduQualification),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.headers['Connection'] = 'close';
    request.headers['User-Agent'] =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

    request.fields['maximum_education_qualification'] = qualification;
    if (passedOutYear != null) {
      request.fields['passed_out_year'] = passedOutYear;
    }

    for (final file in files) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'certificate_files[]',
          file.path,
          filename: file.path.split(RegExp(r'[/\\]')).last,
        ),
      );
    }

    final stream = await request.send();
    final response = await http.Response.fromStream(stream);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    throw Exception(data['message'] ?? 'Education qualification saving failed');
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SERVICE CATEGORIES (New — replaces old services_kyc step 1)
  // Doc endpoints 29-31: GET/POST/PATCH /api/technician/technician_service_category
  // Max 3 categories. Payload: { "technician_service_category": [1, 2] }
  // ──────────────────────────────────────────────────────────────────────────

  /// GET /api/technician/technician_service_category
  /// Returns the technician's selected service categories (max 3).
  Future<Map<String, dynamic>> getServiceCategories() async {
    return _request(method: 'GET', url: ApiConstants.technicianServiceCategory);
  }

  /// POST /api/technician/technician_service_category
  /// Body: { "technician_service_category": [{"category_id": 1, "years_of_experience": 2}] }
  Future<Map<String, dynamic>> saveServiceCategories(
    List<Map<String, dynamic>> categories, {
    bool isUpdate = false,
  }) async {
    return _request(
      method: isUpdate ? 'PATCH' : 'POST',
      url: ApiConstants.technicianServiceCategory,
      body: {'technician_service_category': categories},
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TECHNICIAN SERVICES (New — replaces old services_kyc step 2)
  // Doc endpoints 32-34: GET/POST/PATCH /api/technician/technician_services
  // Only services belonging to selected categories are accepted.
  // Payload: { "technician_services": [10, 11, 12] }
  // ──────────────────────────────────────────────────────────────────────────

  /// GET /api/technician/technician_services
  /// Returns the technician's selected services (from technician_services_kyc).
  Future<Map<String, dynamic>> getTechnicianServices() async {
    return _request(method: 'GET', url: ApiConstants.technicianServices);
  }

  /// POST /api/technician/technician_services
  /// Set the technician's selected service IDs. No count restriction.
  /// Services not belonging to selected categories are ignored (not saved).
  Future<Map<String, dynamic>> saveTechnicianServices(
    List<int> serviceIds, {
    bool isUpdate = false,
  }) async {
    return _request(
      method: isUpdate ? 'PATCH' : 'POST',
      url: ApiConstants.technicianServices,
      body: {'technician_services': serviceIds},
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SERVICE CERTIFICATES (New — replaces old service_certificate_list + upload)
  // Doc endpoints 35-37:
  //   GET  /api/technician/service_certificates — list requirements & uploads
  //   POST /api/technician/service_certificates — upload certificate (multipart)
  //   GET  /api/technician/service_certificates/download/{id}/{index}
  // ──────────────────────────────────────────────────────────────────────────

  /// GET /api/technician/service_certificates
  /// Returns certificate requirements for each selected service, including
  /// mandatory/optional flags and already uploaded details.
  Future<Map<String, dynamic>> getServiceCertificates() async {
    return _request(method: 'GET', url: ApiConstants.serviceCertificates);
  }

  /// POST /api/technician/service_certificates (multipart/form-data)
  /// Upload a certificate for one selected service.
  /// Fields: service_id, certificate_id, certificate_number, no_expiry, expiry_date
  /// Files: files[] (one or more files)
  Future<Map<String, dynamic>> uploadServiceCertificate({
    required int serviceId,
    required int certificateId,
    String? certificateNumber,
    bool noExpiry = true,
    String? expiryDate,
    required List<File> files,
  }) async {
    final token = await SharedPrefsHelper.getToken();
    if (token == null || token.isEmpty) throw Exception('Not authenticated');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstants.serviceCertificates),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.headers['Connection'] = 'close';
    request.headers['User-Agent'] =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

    request.fields['service_id'] = serviceId.toString();
    request.fields['certificate_id'] = certificateId.toString();
    if (certificateNumber != null && certificateNumber.isNotEmpty) {
      request.fields['certificate_number'] = certificateNumber;
    }
    request.fields['no_expiry'] = noExpiry ? '1' : '0';
    if (!noExpiry && expiryDate != null) {
      request.fields['expiry_date'] = expiryDate;
    }

    for (final file in files) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'files[]',
          file.path,
          filename: file.path.split(RegExp(r'[/\\]')).last,
        ),
      );
    }

    print('[CertUpload] Fields: ${request.fields}');
    print(
      '[CertUpload] Files: ${request.files.map((f) => '${f.field}=${f.filename}').toList()}',
    );

    final stream = await request.send();
    final response = await http.Response.fromStream(stream);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    print('[CertUpload] Status: ${response.statusCode} Body: ${response.body}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    // Include validation errors in the exception message
    if (data.containsKey('errors')) {
      final errors = data['errors'] as Map<String, dynamic>;
      final msg = errors.entries
          .map(
            (e) =>
                '${e.key}: ${(e.value is List) ? (e.value as List).join(', ') : e.value}',
          )
          .join(' | ');
      throw Exception(
        msg.isNotEmpty ? msg : (data['message'] ?? 'Certificate upload failed'),
      );
    }
    throw Exception(data['message'] ?? 'Certificate upload failed');
  }

  // ──────────────────────────────────────────────────────────────────────────
  // BANK KYC
  // ──────────────────────────────────────────────────────────────────────────

  /// GET /api/technician/bank_kyc
  Future<Map<String, dynamic>> getBankKyc() async {
    return _request(method: 'GET', url: ApiConstants.bankKyc);
  }

  /// POST or PATCH /api/technician/bank_kyc
  Future<Map<String, dynamic>> saveBankKyc(
    Map<String, dynamic> body, {
    bool isUpdate = false,
  }) async {
    return _request(
      method: isUpdate ? 'PATCH' : 'POST',
      url: ApiConstants.bankKyc,
      body: body,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // COMPANY KYC
  // ──────────────────────────────────────────────────────────────────────────

  /// GET /api/technician/company_kyc
  Future<Map<String, dynamic>> getCompanyKyc() async {
    return _request(method: 'GET', url: ApiConstants.companyKyc);
  }

  /// POST or PATCH /api/technician/company_kyc (GST verified via IDFY in this call)
  Future<Map<String, dynamic>> saveCompanyKyc(
    Map<String, dynamic> body, {
    bool isUpdate = false,
  }) async {
    return _request(
      method: isUpdate ? 'PATCH' : 'POST',
      url: ApiConstants.companyKyc,
      body: body,
    );
  }

  /// Verify GST by PATCH company_kyc with hasfirm, hasgst, gstin. Returns gst_details.
  Future<Map<String, dynamic>?> verifyGst(
    String gstin, {
    required bool hasFirm,
    required bool hasGst,
  }) async {
    final res = await saveCompanyKyc({
      'company_available': hasFirm,
      'gst_available': hasGst,
      'gstin': gstin,
    }, isUpdate: true);
    final data = res['data'] as Map<String, dynamic>?;
    return data?['gst_details'] as Map<String, dynamic>?;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // DOCUMENT KYC
  // ──────────────────────────────────────────────────────────────────────────

  /// GET /api/technician/document_kyc
  Future<Map<String, dynamic>> getDocumentKyc() async {
    return _request(method: 'GET', url: ApiConstants.documentKyc);
  }

  Future<Map<String, dynamic>> uploadDocumentKyc(
    Map<String, File> files,
  ) async {
    final token = await SharedPrefsHelper.getToken();
    if (token == null || token.isEmpty) throw Exception('Not authenticated');
    final apiKeys = <String, String>{
      'bank_statement': 'bank_passbook',
      'gst_document': 'gst',
    };
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstants.documentKyc),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.headers['Connection'] = 'close';
    request.headers['User-Agent'] =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    for (final e in files.entries) {
      final key = apiKeys[e.key] ?? e.key;
      final file = e.value;
      request.files.add(
        await http.MultipartFile.fromPath(
          key,
          file.path,
          filename: file.path.split(RegExp(r'[/\\]')).last,
        ),
      );
    }
    final stream = await request.send();
    final response = await http.Response.fromStream(stream);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    throw Exception(data['message'] ?? 'Upload failed');
  }

  // ──────────────────────────────────────────────────────────────────────────
  // OTP & SIGNATURE
  // ──────────────────────────────────────────────────────────────────────────

  /// POST /api/general/send_otp - KYC final verification OTP
  Future<Map<String, dynamic>> sendKycOtp() async {
    return _request(
      method: 'POST',
      url: ApiConstants.kycSendOtp,
      body: {'purpose': 'KYC_FINAL_VERIFICATION'},
    );
  }

  /// POST /api/general/verify_otp - Verify KYC OTP
  Future<Map<String, dynamic>> verifyKycOtp({
    required String verificationToken,
    required String otp,
  }) async {
    return _request(
      method: 'POST',
      url: ApiConstants.kycVerifyOtp,
      body: {'verification_token': verificationToken, 'otp': otp},
    );
  }

  /// POST /api/technician/signature - Upload signature as form data
  Future<Map<String, dynamic>> uploadSignature(File signatureFile) async {
    final token = await SharedPrefsHelper.getToken();
    if (token == null || token.isEmpty) throw Exception('Not authenticated');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstants.technicianSignature),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.headers['Connection'] = 'close';
    request.headers['User-Agent'] =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    request.files.add(
      await http.MultipartFile.fromPath(
        'signature',
        signatureFile.path,
        filename: 'signature.png',
      ),
    );

    final stream = await request.send();
    final response = await http.Response.fromStream(stream);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    throw Exception(data['message'] ?? 'Signature upload failed');
  }

  // ──────────────────────────────────────────────────────────────────────────
  // KYC STATUS (Admin API)
  // ──────────────────────────────────────────────────────────────────────────

  /// PATCH /api/technician/kyc_status - Update KYC status to Verified
  Future<Map<String, dynamic>> updateKycStatus({
    required int technicianId,
    required String kycStatus,
  }) async {
    print("Updating KYC status for technicianId: $technicianId to $kycStatus");
    return _request(
      method: 'PATCH',
      url: ApiConstants.technicianKycStatus,
      body: {'technician_id': technicianId, 'kyc_status': kycStatus},
      useSessionToken: false, // Admin API, doesn't use technician token
    );
  }
}
