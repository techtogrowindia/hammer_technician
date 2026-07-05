import 'package:flutter/material.dart';
import 'package:hammer_app/core/config/env_url.dart';

enum DynamicGifType { splash, otp }

class DynamicGifWidget extends StatelessWidget {
  final DynamicGifType type;
  final double width;
  final double height;
  final BoxFit fit;

  const DynamicGifWidget({
    super.key,
    this.type = DynamicGifType.otp,
    this.width = 150,
    this.height = 150,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    // GIF is uploaded via admin Settings → App GIF Settings.
    // The endpoint redirects to the stored file so the URL stays stable.
    // If no GIF is configured, the endpoint returns 404 and we show nothing.
    final url = '${EnvUrls.liveBaseUrl}/api/general/otp-gif';
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // No GIF configured (404) or load failed — hide gracefully instead of showing broken image
        return SizedBox(width: width, height: height);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          ),
        );
      },
    );
  }
}
