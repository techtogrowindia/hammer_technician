import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hammer_app/core/colors/colors.dart';

Widget kycPreviewRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            value.isEmpty ? "-" : value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ],
    ),
  );
}

Widget kycModernPreviewCard({
  required String title,
  required IconData icon,
  required List<Widget> children,
  VoidCallback? onEdit,
}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primaryAmber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primaryAmber),
                onPressed: onEdit,
              ),
          ],
        ),
        const Divider(height: 24),
        ...children,
      ],
    ),
  );
}

Widget kycZoomableImage(File file) {
  return InteractiveViewer(
    minScale: 1,
    maxScale: 5,
    child: Image.file(file, fit: BoxFit.contain),
  );
}

Widget kycZoomableNetworkImage(String url) {
  return InteractiveViewer(
    minScale: 1,
    maxScale: 5,
    child: Image.network(
      url, 
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return const Center(child: Text("Cannot load image", style: TextStyle(color: Colors.red)));
      },
    ),
  );
}
