import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:hatch_care/app/theme/app_theme.dart';
import 'package:hatch_care/features/history/presentation/pages/history_page.dart';
import 'package:hatch_care/features/history/presentation/widgets/candling_record_card.dart';

/// Membungkus [HistoryPage] dengan ProviderScope, MaterialApp.router, ukuran
/// layar [size], dan text scale 1.5 — meniru kondisi perangkat kecil.
Widget _buildTestableScreen({required Size size}) {
  final router = GoRouter(
    initialLocation: '/test',
    routes: [
      GoRoute(
        path: '/test',
        builder: (context, state) => MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: const TextScaler.linear(1.5),
          ),
          child: const HistoryPage(),
        ),
      ),
      GoRoute(path: '/home', builder: (context, state) => const Scaffold()),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
}

/// Menggeser barisan chip sampai chip dengan [key] terlihat, lalu mengetuknya.
/// Barisan chip bisa digeser horizontal, jadi chip di ujung kanan bisa berada
/// di luar layar sebelum digeser.
Future<void> _tapFilter(WidgetTester tester, String key) async {
  final finder = find.byKey(Key(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  const testSizes = [Size(360, 640), Size(320, 568)];

  for (final size in testSizes) {
    group('HistoryPage pada ${size.width.toInt()}x${size.height.toInt()} '
        'dengan text scale 1.5:', () {
      testWidgets('tidak overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(_buildTestableScreen(size: size));
        await tester.pump();
        expect(tester.takeException(), isNull);

        // Pastikan elemen utama tampil.
        expect(find.text('History'), findsOneWidget);
        expect(find.text('Egg #12'), findsOneWidget);
      });
    });
  }

  testWidgets('Mengetuk filter mengubah isi daftar', (tester) async {
    const size = Size(360, 640);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildTestableScreen(size: size));
    await tester.pump();

    // Awal: filter "Semua" aktif, record fertil (Egg #12) terlihat.
    expect(find.text('Egg #12'), findsOneWidget);

    // Tap filter "Mortalitas".
    await _tapFilter(tester, 'filter_mortalitas');

    // Egg fertil tidak tampil lagi, tetapi masih ada kartu mortalitas.
    expect(find.text('Egg #12'), findsNothing);
    expect(find.byType(CandlingRecordCard), findsWidgets);

    // Tap filter "Semua" kembali.
    await _tapFilter(tester, 'filter_semua');

    // Semua record tampil kembali.
    expect(find.text('Egg #12'), findsOneWidget);
  });
}
