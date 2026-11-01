import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hatch_care/features/splash/presentation/pages/splash_page.dart';

/// Konfigurasi routing aplikasi menggunakan GoRouter.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const _OnboardingPlaceholder(),
    ),
  ],
);

/// Halaman placeholder onboarding — akan diganti di task berikutnya.
class _OnboardingPlaceholder extends StatelessWidget {
  const _OnboardingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Halaman Onboarding — Segera hadir')),
    );
  }
}
