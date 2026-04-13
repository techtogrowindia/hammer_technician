import 'package:flutter/services.dart';

/// Formats DOB as DD/MM/YYYY
class DobFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 8) return oldValue;

    if (text.isEmpty) {
      return const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    }

    String formatted;
    if (text.length <= 2) {
      formatted = text;
    } else if (text.length <= 4) {
      formatted = '${text.substring(0, 2)}/${text.substring(2)}';
    } else {
      formatted = '${text.substring(0, 2)}/${text.substring(2, 4)}/${text.substring(4)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
