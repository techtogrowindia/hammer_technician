import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

class KycSignaturePad extends StatefulWidget {
  final void Function(File file) onSaved;
  final VoidCallback? onCancel;
  final double height;

  const KycSignaturePad({
    super.key,
    required this.onSaved,
    this.onCancel,
    this.height = 180,
  });

  @override
  State<KycSignaturePad> createState() => _KycSignaturePadState();
}

class _KycSignaturePadState extends State<KycSignaturePad> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_controller.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final bytes = await _controller.toPngBytes();
      if (bytes == null) throw Exception('Could not export signature');
      var image = img.decodeImage(bytes);
      if (image != null && image.height > image.width) {
        image = img.copyRotate(image, angle: 90);
      }
      final outBytes = image != null ? img.encodePng(image) : bytes;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(outBytes);
      widget.onSaved(file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Sign here',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: widget.height,
              child: Container(
                color: Colors.grey.shade100,
                child: Signature(
                  controller: _controller,
                  width: double.infinity,
                  height: widget.height,
                  backgroundColor: Colors.grey.shade100,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: _controller.clear,
                child: const Text('Clear'),
              ),
              const Spacer(),
              if (widget.onCancel != null)
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
              if (widget.onCancel != null) const SizedBox(width: 8),
              FilledButton(
                onPressed: _isSaving || _controller.isEmpty ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
