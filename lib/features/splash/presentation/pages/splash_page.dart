import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hatch_care/core/constants/app_assets.dart';
import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';

/// Layar splash HATCH-CARE.
///
/// Alur:
///  1. Tampilkan logo di tengah layar kuning (splash 1).
///  2. Setelah 1,5 detik, logo naik & teks "HATCH-CARE" fade-in (splash 2).
///  3. Setelah total ~3,5 detik, navigasi ke /onboarding.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _logoSlide;

  Timer? _navigateTimer;
  Timer? _animateTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textOpacity = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Logo bergeser ke atas sedikit saat teks muncul.
    _logoSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.15),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Setelah 1,5 detik mulai animasi transisi ke splash 2.
    _animateTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) _controller.forward();
    });

    // Setelah 3,5 detik navigasi ke onboarding.
    _navigateTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _animateTimer?.cancel();
    _navigateTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Logo ~40% lebar layar, responsif.
    final logoSize = screenWidth * 0.4;

    return Scaffold(
      backgroundColor: AppColors.tertiary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SlideTransition(
              position: _logoSlide,
              child: Image.asset(
                AppAssets.logo,
                width: logoSize,
                height: logoSize,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FadeTransition(
              opacity: _textOpacity,
              child: Text(
                'HATCH-CARE',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: screenWidth * 0.09,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
