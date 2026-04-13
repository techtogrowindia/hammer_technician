import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hammer_app/features/kyc/presentation/widgets/kyc_signature_pad.dart';

/// Full-screen digital signature screen for KYC.
class KycSignatureScreen extends StatelessWidget {
  final void Function(File file) onSignatureSaved;

  const KycSignatureScreen({super.key, required this.onSignatureSaved});

  static Future<File?> open(BuildContext context) async {
    return Navigator.of(context).push<File>(
      MaterialPageRoute(
        builder: (_) => KycSignatureScreen(
          onSignatureSaved: (file) => Navigator.of(context).pop(file),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Digital Signature"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxH = (constraints.maxHeight - 130).clamp(
                      180.0,
                      600.0,
                    );
                    // final padHeight =
                    //     (maxH < constraints.maxWidth * 0.55
                    //             ? maxH
                    //             : constraints.maxWidth * 0.55)
                    //         .clamp(180.0, 500.0);
                    return KycSignaturePad(
                      height: maxH,
                      onSaved: (file) => onSignatureSaved(file),
                      onCancel: () => Navigator.of(context).pop(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
