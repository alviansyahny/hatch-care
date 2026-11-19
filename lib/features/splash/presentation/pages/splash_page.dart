import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hatch_care/core/constants/app_assets.dart';
import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/core/constants/app_text_styles.dart';
import 'package:hatch_care/features/auth/presentation/providers/auth_provider.dart';

/// Layar splash HATCH-CARE.
///
/// Alur:
///  1. Tampilkan logo di tengah layar kuning (splash 1).
///  2. Setelah 1,5 detik, logo naik & teks "HATCH-CARE" fade-in (splash 2).
///  3. Setelah total ~3,5 detik, navigasi ke /home bila pengguna masih
///     tercatat login, selain itu ke /onboarding.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
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

    // Setelah 3,5 detik navigasi: /home jika masih login, /onboarding jika tidak.
    _navigateTimer = Timer(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      final session = ref.read(authSessionProvider);
      context.go(session != null ? '/home' : '/onboarding');
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
                style: AppTextStyles.brandTitle.copyWith(
                  color: AppColors.primary,
                  fontSize: screenWidth * 0.08,
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
