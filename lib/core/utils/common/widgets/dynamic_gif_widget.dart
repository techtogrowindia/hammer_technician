import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hammer_app/features/common/cubit/dynamic_content_cubit.dart';
import 'package:hammer_app/features/common/cubit/dynamic_content_state.dart';

class DynamicGifWidget extends StatelessWidget {
  final double width;
  final double height;
  final BoxFit fit;

  const DynamicGifWidget({
    super.key,
    this.width = 150,
    this.height = 150,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DynamicContentCubit, DynamicContentState>(
      builder: (context, state) {
        String? gifUrl;
        if (state is DynamicContentLoaded) {
          gifUrl = state.model.data?.otpScreenGif;
        }

        if (gifUrl != null && gifUrl.isNotEmpty) {
          return Image.network(
            gifUrl,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/gif/hammer_gif.gif',
                width: width,
                height: height,
                fit: fit,
              );
            },
          );
        } else {
          return Image.asset(
            'assets/gif/hammer_gif.gif',
            width: width,
            height: height,
            fit: fit,
          );
        }
      },
    );
  }
}
