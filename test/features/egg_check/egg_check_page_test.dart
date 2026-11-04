import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:hatch_care/app/theme/app_theme.dart';
import 'package:hatch_care/features/egg_check/presentation/pages/egg_check_page.dart';
import 'package:hatch_care/features/egg_check/presentation/widgets/egg_candling_viewfinder.dart';
import 'package:hatch_care/features/egg_check/presentation/widgets/egg_check_controls.dart';
import 'package:hatch_care/features/egg_check/presentation/widgets/egg_check_tray_list.dart';

Widget _buildTestableEggCheckScreen({required Size size, double textScale = 1.0}) {
  final router = GoRouter(
    initialLocation: '/test',
    routes: [
      GoRoute(
        path: '/test',
        builder: (context, state) => MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
          ),
          child: const EggCheckPage(),
        ),
      ),
      GoRoute(path: '/home', builder: (context, state) => const Scaffold()),
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
  const testSizes = [Size(360, 640), Size(320, 568)];

  for (final size in testSizes) {
    group(
      'EggCheckPage pada ${size.width.toInt()}x${size.height.toInt()} dengan text scale 1.5:',
      () {
        testWidgets('semua widget utama terpasang', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            _buildTestableEggCheckScreen(size: size, textScale: 1.5),
          );
          await tester.pump();

          // Memastikan judul dan header muncul
          expect(find.text('Pengecekan Telur'), findsOneWidget);
          expect(find.text('E01'), findsOneWidget);
          expect(find.text('Hari 11'), findsOneWidget);

          // Memastikan komponen viewfinder, kontrol, dan tray list ada
          expect(find.byType(EggCandlingViewfinder), findsOneWidget);
          expect(find.byType(EggCheckControls), findsOneWidget);
          expect(find.byType(EggCheckTrayList), findsOneWidget);
        });
      },
    );
  }

  testWidgets('Mengetuk tombol torch mengubah status ON / OFF', (tester) async {
    const size = Size(390, 844);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildTestableEggCheckScreen(size: size));
    await tester.pump();

    expect(find.text('TORCH: ON'), findsOneWidget);

    await tester.tap(find.text('TORCH: ON'));
    await tester.pumpAndSettle();

    expect(find.text('TORCH: OFF'), findsOneWidget);

    await tester.tap(find.text('TORCH: OFF'));
    await tester.pumpAndSettle();

    expect(find.text('TORCH: ON'), findsOneWidget);
  });

  testWidgets('Mengetuk tombol shutter memicu pemindaian telur', (tester) async {
    const size = Size(390, 844);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildTestableEggCheckScreen(size: size));
    await tester.pump();

    final shutterFinder = find.byIcon(Icons.camera);
    expect(shutterFinder, findsOneWidget);
    await tester.tap(shutterFinder);
    await tester.pump();

    expect(find.text('Foto telur berhasil dipindai!'), findsOneWidget);
  });

  testWidgets('Mengetuk tombol gallery memicu snackbar galeri', (tester) async {
    const size = Size(390, 844);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildTestableEggCheckScreen(size: size));
    await tester.pump();

    final galleryFinder = find.text('Gallery');
    expect(galleryFinder, findsOneWidget);
    await tester.tap(galleryFinder);
    await tester.pump();

    expect(find.text('Pilih foto telur dari galeri'), findsOneWidget);
  });

  testWidgets('Mengetuk item pada tray list mengubah target', (tester) async {
    const size = Size(390, 844);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildTestableEggCheckScreen(size: size));
    await tester.pump();

    expect(find.text('Egg #05'), findsOneWidget);

    await tester.tap(find.text('Egg #05'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
