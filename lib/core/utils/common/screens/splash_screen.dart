import 'package:flutter/material.dart';
import 'package:hammer_app/core/colors/colors.dart';
import 'package:hammer_app/core/config/env_url.dart';
import 'package:hammer_app/core/utils/common/screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  void _navigateToWelcome() {
    if (_navigated || !mounted) return;

    _navigated = true;

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAmberLogo,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.network(
              '${EnvUrls.liveBaseUrl}/api/general/otp-gif',
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              fit: BoxFit.contain,

              // Called when image is loaded
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (frame != null || wasSynchronouslyLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _navigateToWelcome();
                  });
                }

                return child;
              },

              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }

                return const CircularProgressIndicator(color: Colors.white);
              },

              errorBuilder: (context, error, stackTrace) {
                debugPrint('GIF Error: $error');

                return const Icon(
                  Icons.broken_image,
                  color: Colors.white,
                  size: 80,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
