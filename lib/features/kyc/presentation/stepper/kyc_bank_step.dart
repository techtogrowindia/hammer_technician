import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hammer_app/features/kyc/presentation/widgets/kyc_textfield.dart';
import 'package:hammer_app/features/kyc/presentation/widgets/uppercase_formatter.dart';

class KycBankStep extends StatelessWidget {
  final Map<String, String>? fieldErrors;
  final TextEditingController bankNameController;
  final TextEditingController holderNameController;
  final TextEditingController accountTypeController;
  final TextEditingController accountNumberController;
  final TextEditingController cnfAccountNumberController;
  final TextEditingController ifscController;
  final TextEditingController branchNameController;
  final TextEditingController upiController;

  final bool showAccountNumber;
  final VoidCallback onToggleShowAccountNumber;

  static const _fieldSpace = SizedBox(height: 14);

  static const _accountTypes = ["Saving account", "Current account"];

  Widget _accountTypeDropdown(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: accountTypeController,
      builder: (context, value, _) {
        final current = value.text;
        final selected = _accountTypes.contains(current) ? current : null;
        return DropdownButtonFormField<String>(
          value: selected,
          decoration: InputDecoration(
            labelText: "Account Type",
            errorText: fieldErrors?['accountType'],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          hint: const Text("Select account type"),
          items: _accountTypes
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (v) {
            if (v != null) accountTypeController.text = v;
          },
        );
      },
    );
  }

  const KycBankStep({
    super.key,
    this.fieldErrors,
    required this.bankNameController,
    required this.holderNameController,
    required this.accountTypeController,
    required this.accountNumberController,
    required this.cnfAccountNumberController,
    required this.ifscController,
    required this.branchNameController,
    required this.upiController,
    required this.showAccountNumber,
    required this.onToggleShowAccountNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _fieldSpace,
        KycTextField(
          controller: bankNameController,
          label: "Bank Name",
          errorText: fieldErrors?['bankName'],
        ),
        _fieldSpace,
        KycTextField(
          controller: holderNameController,
          label: "Account Holder Name",
          errorText: fieldErrors?['holderName'],
        ),
        _fieldSpace,
        _accountTypeDropdown(context),
        _fieldSpace,
        KycTextField(
          controller: accountNumberController,
          label: "Account Number",
          keyboardType: TextInputType.number,
          obscure: !showAccountNumber,
          enableInteractiveSelection: false,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          errorText: fieldErrors?['accountNumber'],
          suffix: IconButton(
            icon: Icon(
              showAccountNumber ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: onToggleShowAccountNumber,
          ),
        ),
        _fieldSpace,
        KycTextField(
          controller: cnfAccountNumberController,
          label: "Confirm Account Number",
          keyboardType: TextInputType.number,
          obscure: !showAccountNumber,
          enableInteractiveSelection: false,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          errorText: fieldErrors?['cnfAccountNumber'],
          suffix: Icon(
            cnfAccountNumberController.text == accountNumberController.text
                ? Icons.check_circle
                : Icons.error,
            color: cnfAccountNumberController.text.isEmpty
                ? Colors.grey
                : cnfAccountNumberController.text == accountNumberController.text
                    ? Colors.green
                    : Colors.red,
          ),
        ),
        _fieldSpace,
        KycTextField(
          controller: ifscController,
          label: "IFSC Code",
          maxLength: 11,
          inputFormatters: [UpperCaseTextFormatter()],
          errorText: fieldErrors?['ifsc'],
        ),
        _fieldSpace,
        KycTextField(
          controller: branchNameController,
          label: "Branch Name",
          errorText: fieldErrors?['branchName'],
        ),
        _fieldSpace,
        KycTextField(controller: upiController, label: "UPI ID/UPI Number"),
      ],
    );
  }
}
