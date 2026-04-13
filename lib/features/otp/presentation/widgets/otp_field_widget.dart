import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:hammer_app/core/colors/colors.dart';

class OtpFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final int otpLength;

  const OtpFieldWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.otpLength = 4,
  });

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: otpLength,
      controller: controller,
      keyboardType: TextInputType.number,
      animationType: AnimationType.none,
      autoFocus: true,
      enableActiveFill: false,
      cursorColor: AppColors.primaryBlue,
      onChanged: onChanged ?? (_) {},
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(12),
        fieldHeight: otpLength == 4 ? 56 : 48,
        fieldWidth: otpLength == 4 ? 56 : 48,
        activeColor: AppColors.primaryBlue,
        selectedColor: AppColors.primaryBlue,
        inactiveColor: Colors.grey.shade300,
      ),
      validator: (v) {
        if (v == null || v.length != otpLength) {
          return 'Enter valid OTP';
        }
        return null;
      },
    );
  }
}
