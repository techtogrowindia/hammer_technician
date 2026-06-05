import 'package:flutter/material.dart';

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
    return Image.network(
      'https://hammerapp.in/images/otp.gif',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
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
