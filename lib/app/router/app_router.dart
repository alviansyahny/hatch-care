import 'package:go_router/go_router.dart';

import 'package:hatch_care/features/auth/presentation/pages/login_page.dart';
import 'package:hatch_care/features/auth/presentation/pages/register_page.dart';
import 'package:hatch_care/features/auth/presentation/pages/syarat_ketentuan_page.dart';
import 'package:hatch_care/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:hatch_care/features/splash/presentation/pages/splash_page.dart';

/// Konfigurasi routing aplikasi menggunakan GoRouter.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/syarat-ketentuan',
      builder: (context, state) => const SyaratKetentuanPage(),
    ),
  ],
);
