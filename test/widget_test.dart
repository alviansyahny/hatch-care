import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:hatch_care/app/app.dart';
import 'package:hatch_care/app/theme/app_theme.dart';
import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/features/auth/presentation/pages/login_page.dart';
import 'package:hatch_care/features/auth/presentation/pages/register_page.dart';
import 'package:hatch_care/features/auth/presentation/pages/syarat_ketentuan_page.dart';
import 'package:hatch_care/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:hatch_care/features/splash/presentation/pages/splash_page.dart';

Widget _buildTestableScreen(Widget page, {required Size size}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: const TextScaler.linear(1.5),
          ),
          child: page,
        ),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const Scaffold(),
      ),
      GoRoute(path: '/register', builder: (context, state) => const Scaffold()),
      GoRoute(path: '/login', builder: (context, state) => const Scaffold()),
      GoRoute(
        path: '/syarat-ketentuan',
        builder: (context, state) => const Scaffold(),
      ),
    ],
  );

  return MaterialApp.router(theme: AppTheme.light, routerConfig: router);
}

void main() {
  testWidgets('Smoke test: Splash menampilkan logo, teks, dan navigasi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: HatchCareApp()));

    // Splash: logo sudah tampil.
    expect(find.byType(Image), findsOneWidget);

    // Teks "HATCH-CARE" sudah ada di widget tree.
    expect(find.text('HATCH-CARE'), findsOneWidget);

    // Background scaffold harus warna Tertiary.
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, AppColors.tertiary);

    // Majukan waktu melewati animasi dan timer navigasi.
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();

    // Sudah sampai di onboarding.
    expect(find.text('Mulai Monitoring'), findsOneWidget);
  });

  const testSizes = [Size(360, 640), Size(320, 568)];

  for (final size in testSizes) {
    group(
      'Render test pada ${size.width.toInt()}x${size.height.toInt()} dengan text scale 1.5:',
      () {
        testWidgets('SplashPage tidak overflow', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            _buildTestableScreen(const SplashPage(), size: size),
          );
          expect(tester.takeException(), isNull);

          // Majukan timer splash agar selesai.
          await tester.pump(const Duration(milliseconds: 1600));
          await tester.pump(const Duration(milliseconds: 2000));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });

        testWidgets('OnboardingPage tidak overflow', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            _buildTestableScreen(const OnboardingPage(), size: size),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
          expect(find.text('HATCH - CARE'), findsOneWidget);
        });

        testWidgets('RegisterPage tidak overflow', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            _buildTestableScreen(const RegisterPage(), size: size),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
          expect(find.text('Daftar'), findsWidgets);
        });

        testWidgets('LoginPage tidak overflow', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            _buildTestableScreen(const LoginPage(), size: size),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
          expect(find.text('Halo, Selamat Datang!'), findsOneWidget);
        });

        testWidgets('SyaratKetentuanPage tidak overflow', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            _buildTestableScreen(const SyaratKetentuanPage(), size: size),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
          expect(find.text('Syarat Dan Ketentuan'), findsOneWidget);
        });
      },
    );
  }
}
