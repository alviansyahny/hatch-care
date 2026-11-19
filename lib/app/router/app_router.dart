import 'package:go_router/go_router.dart';

import 'package:hatch_care/features/auth/presentation/pages/login_page.dart';
import 'package:hatch_care/features/auth/presentation/pages/register_page.dart';
import 'package:hatch_care/features/auth/presentation/pages/syarat_ketentuan_page.dart';
import 'package:hatch_care/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:hatch_care/features/egg_check/presentation/pages/egg_check_page.dart';
import 'package:hatch_care/features/history/presentation/pages/history_page.dart';
import 'package:hatch_care/features/live/presentation/pages/live_page.dart';
import 'package:hatch_care/features/notification/presentation/pages/notification_page.dart';
import 'package:hatch_care/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:hatch_care/features/setting/presentation/pages/setting_page.dart';
import 'package:hatch_care/features/shell/presentation/pages/main_shell_page.dart';
import 'package:hatch_care/features/splash/presentation/pages/splash_page.dart';

/// Konfigurasi routing aplikasi menggunakan GoRouter.
///
/// Struktur route:
/// - `/`                : SplashPage
/// - `/onboarding`      : OnboardingPage
/// - `/login`           : LoginPage
/// - `/register`        : RegisterPage
/// - `/syarat-ketentuan`: SyaratKetentuanPage
/// - `/home`            : DashboardPage       (branch 0, tab Home)
/// - `/home/live`       : LivePage             (branch 1, tab Live)
/// - `/home/egg-check`  : EggCheckPage        (branch 2, tab Egg Check)
/// - `/home/history`    : HistoryPage          (branch 3, tab History)
/// - `/home/setting`    : SettingPage          (branch 4, tab Setting)
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
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationPage(),
    ),

    // Shell dengan empat tab navigasi bawah
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShellPage(navigationShell: navigationShell),
      branches: [
        // Branch 0: Home → Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const DashboardPage(),
            ),
          ],
        ),

        // Branch 1: Live
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home/live',
              builder: (context, state) => const LivePage(),
            ),
          ],
        ),

        // Branch 2: Egg Check
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home/egg-check',
              builder: (context, state) => const EggCheckPage(),
            ),
          ],
        ),

        // Branch 3: History
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home/history',
              builder: (context, state) => const HistoryPage(),
            ),
          ],
        ),

        // Branch 4: Setting
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home/setting',
              builder: (context, state) => const SettingPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
