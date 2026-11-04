import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:hatch_care/app/theme/app_theme.dart';
import 'package:hatch_care/features/setting/presentation/pages/setting_page.dart';

Widget _buildTestableSettingScreen({required Size size, double textScale = 1.0}) {
  final router = GoRouter(
    initialLocation: '/setting',
    routes: [
      GoRoute(
        path: '/setting',
        builder: (context, state) => MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
          ),
          child: const SettingPage(),
        ),
      ),
      GoRoute(path: '/home', builder: (context, state) => const Scaffold()),
      GoRoute(path: '/login', builder: (context, state) => const Scaffold()),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

void main() {
  testWidgets('SettingPage menampilkan profil dan menu pengaturan akun', (
    WidgetTester tester,
  ) async {
    const size = Size(390, 844);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildTestableSettingScreen(size: size));
    await tester.pump();

    // Verifikasi profil
    expect(find.text('Juliana Intan'), findsOneWidget);
    expect(find.text('@julianaintan'), findsOneWidget);
    expect(find.text('tang01@gmail.com'), findsOneWidget);

    // Verifikasi menu pengaturan
    expect(find.text('PENGATURAN AKUN'), findsOneWidget);
    expect(find.text('Ubah Password'), findsOneWidget);
    expect(find.text('Notifikasi'), findsOneWidget);
    expect(find.text('Aktif'), findsOneWidget);
    expect(find.text('Tentang HATCH-CARE'), findsOneWidget);

    // Verifikasi tombol keluar
    expect(find.text('Keluar (Logout)'), findsOneWidget);
  });
}
