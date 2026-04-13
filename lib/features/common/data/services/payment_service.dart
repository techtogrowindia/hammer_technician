import 'dart:convert';
import 'package:hammer_app/core/config/api_constants.dart';
import 'package:hammer_app/core/utils/shared_prefs_helper.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  static final http.Client _client = http.Client();

  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Connection': 'keep-alive',
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
  };

  /// Create Razorpay order via /api/payment/razorpay-order-create
  static Future<Map<String, dynamic>> createRazorpayOrder({
    required num amount,
    required String userType,
    required int userId,
    String purpose = 'onboarding',
  }) async {
    final token = await SharedPrefsHelper.getToken();
    if (token == null || token.isEmpty) throw Exception('Not authenticated');

    int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final response = await _client
            .post(
              Uri.parse(ApiConstants.razorpayOrderCreate),
              headers: {
                ..._defaultHeaders,
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({
                'purpose': purpose,
                'amount': amount is int ? amount.toDouble() : amount,
                'user_type': userType,
                'user_id': userId,
              }),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 502 || response.statusCode == 503 || response.statusCode == 504) {
          throw Exception("Server returned Error ${response.statusCode}");
        }

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return data;
        }
        throw Exception(data['message'] ?? 'Failed to create order');
      } catch (e) {
        retryCount++;
        print("Razorpay order error (Attempt $retryCount): $e");
        
        // Wait before retrying (exponential backoff)
        if (retryCount < maxRetries) {
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }

        // We exhausted all retries, throw the original error directly so it's not masked
        throw Exception("Failed to create order after $maxRetries attempts: ${e.toString().replaceAll('Exception: ', '')}");
      }
    }
    
    throw Exception("Failed to connect after $maxRetries attempts.");
  }

  /// Update payment after Razorpay success via /api/payment/payment-update
  static Future<Map<String, dynamic>> updatePayment({
    required int orderId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
  }) async {
    final token = await SharedPrefsHelper.getToken();
    if (token == null || token.isEmpty) throw Exception('Not authenticated');

    try {
      final response = await _client
          .post(
            Uri.parse(ApiConstants.paymentUpdate),
            headers: {
              ..._defaultHeaders,
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'order_id': orderId,
              'razorpay_order_id': razorpayOrderId,
              'razorpay_payment_id': razorpayPaymentId,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("Payment update successful: $data");
        return data;
      }
      throw Exception(data['message'] ?? 'Failed to update payment');
    } catch (e) {
      print("Payment update error: $e");
      rethrow;
    }
  }
}
