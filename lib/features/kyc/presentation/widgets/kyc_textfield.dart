import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hammer_app/core/colors/colors.dart';

class KycTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int? maxLength;
  final int maxLines;
  final bool obscure;
  final Widget? suffix;
  final Widget? prefix;
  final bool enabled;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool required;
  final String? errorText;
  final String? hintText;
  final ValueChanged<String>? onChanged;

  const KycTextField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLength,
    this.maxLines = 1,
    this.obscure = false,
    this.suffix,
    this.prefix,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.required = false,
    this.errorText,
    this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "$label ${required ? '*' : ''}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ),
        TextFormField(
          enabled: enabled,
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          onChanged: onChanged,
          maxLength: maxLength,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5), fontSize: 14),
            errorText: errorText,
            counterText: "",
            filled: false,
            prefixIcon: prefix,
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
