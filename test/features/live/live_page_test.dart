import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:hatch_care/app/theme/app_theme.dart';
import 'package:hatch_care/features/live/presentation/pages/live_page.dart';
import 'package:hatch_care/features/live/presentation/widgets/live_candling_display.dart';

Widget _buildTestableLiveScreen({required Size size, double textScale = 1.0}) {
  final router = GoRouter(
    initialLocation: '/live',
    routes: [
      GoRoute(
        path: '/live',
        builder: (context, state) => MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
          ),
          child: const LivePage(),
        ),
      ),
      GoRoute(path: '/home', builder: (context, state) => const Scaffold()),
      GoRoute(
        path: '/home/egg-check',
        builder: (context, state) => const Scaffold(),
      ),
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
  testWidgets('LivePage menampilkan display kamera dan deskripsi morfologi', (
    WidgetTester tester,
  ) async {
    const size = Size(390, 844);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildTestableLiveScreen(size: size));
    await tester.pump();

    // Verifikasi judul dan timestamp
    expect(find.text('Live'), findsOneWidget);
    expect(find.text('Hari ini, 14:15:22 WIB'), findsOneWidget);

    // Verifikasi display video dan tombol perbesar
    expect(find.byType(LiveCandlingDisplay), findsOneWidget);
    expect(find.text('Perbesar Foto'), findsOneWidget);

    // Verifikasi status dan deskripsi
    expect(find.text('FERTIL'), findsOneWidget);
    expect(find.text('Deskripsi Morfologi Vaskular'), findsOneWidget);

    // Verifikasi tombol periksa ulang
    expect(find.text('Periksa Ulang Telur'), findsOneWidget);
  });

  testWidgets('Mengetuk tombol perbesar foto membuka fullscreen viewer', (
    WidgetTester tester,
  ) async {
    const size = Size(390, 844);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildTestableLiveScreen(size: size));
    await tester.pump();

    // Ketuk tombol perbesar foto
    await tester.tap(find.text('Perbesar Foto'));
    await tester.pumpAndSettle();

    // Modal dialog fullscreen terbuka dengan tombol close
    expect(find.byIcon(Icons.close), findsOneWidget);

    // Tutup dialog
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.close), findsNothing);
  });
}
