import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  late Razorpay _razorpay;

  final Future<void> Function(String paymentId, String orderId, String signature) onSuccess;
  final Function(String error) onFailure;

  RazorpayService({required this.onSuccess, required this.onFailure}) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleWallet);
  }

  void openCheckout({
    required String key,
    required String orderId,
    required int amount,
    required String name,
    required String email,
    required String phone,
  }) {
    // amount is in paise (Razorpay expects smallest currency unit)
    var options = {
      'key': key,
      'amount': amount,
      'currency': 'INR',
      'order_id': orderId,
      'name': 'Hammer App',
      'description': 'Onboarding Charges',
      'prefill': {'contact': phone, 'email': email},
      'theme': {'color': '#1565C0'},
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Razorpay error: $e");
    }
  }

  void _handleSuccess(PaymentSuccessResponse response) async {
    debugPrint("[RazorpayService] Payment success: paymentId=${response.paymentId}, orderId=${response.orderId}");
    try {
      await onSuccess(response.paymentId!, response.orderId!, response.signature!);
      debugPrint("[RazorpayService] onSuccess callback completed successfully");
    } catch (e) {
      debugPrint("[RazorpayService] onSuccess callback error: $e");
    }
  }

  void _handleError(PaymentFailureResponse response) {
    debugPrint("[RazorpayService] Payment error: ${response.message}");
    onFailure(response.message ?? "Payment failed");
  }

  void _handleWallet(ExternalWalletResponse response) {}

  void dispose() {
    _razorpay.clear();
  }
}
