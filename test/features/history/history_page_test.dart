import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:hatch_care/app/theme/app_theme.dart';
import 'package:hatch_care/core/network/api_client.dart';
import 'package:hatch_care/features/history/presentation/pages/history_page.dart';

/// Body JSON tiruan `GET /incubator/latest` dengan 3 foto: dua pertama
/// terang, satu terakhir gelap (lampu mati).
const _fakeLatestJson = '''
{
  "status": "online",
  "online": true,
  "image": "/incubator/photo/inc_3.jpg",
  "url": "/incubator/photo/inc_3.jpg",
  "total_eggs": 6,
  "detections": [{"confidence": 0.95}, {"confidence": 0.9}],
  "temperature": 37.3,
  "humidity": 58.7,
  "lamp": true,
  "motor": false,
  "rssi": -64,
  "history": [
    {"id": "c", "filename": "inc_3.jpg", "url": "/incubator/photo/inc_3.jpg",
     "timestamp": 1762900020, "temperature": 37.3, "humidity": 58.7,
     "lamp": true, "motor": false, "size_kb": 200},
    {"id": "b", "filename": "inc_2.jpg", "url": "/incubator/photo/inc_2.jpg",
     "timestamp": 1762899900, "temperature": 37.1, "humidity": 59.0,
     "lamp": false, "motor": false, "size_kb": 74},
    {"id": "a", "filename": "inc_1.jpg", "url": "/incubator/photo/inc_1.jpg",
     "timestamp": 1762899780, "temperature": 37.0, "humidity": 59.2,
     "lamp": true, "motor": true, "size_kb": 120}
  ]
}
''';

/// Membungkus [HistoryPage] dengan ProviderScope, mock HTTP client,
/// MaterialApp.router, ukuran layar [size], dan text scale 1.5 — meniru
/// kondisi perangkat kecil.
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
    overrides: [
      apiClientProvider.overrideWithValue(_mockClient()),
    ],
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
}

/// Client tiruan: semua request GET `/incubator/latest` dijawab JSON tiruan,
/// request foto (path /incubator/photo/*) dijawab byte PNG 1x1.
http.Client _mockClient() {
  return MockClient((request) async {
    if (request.url.path.contains('/incubator/photo/')) {
      // PNG transparan 1x1.
      return http.Response.bytes(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk'
          'YPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
        ),
        200,
        headers: {'content-type': 'image/png'},
      );
    }
    return http.Response(
      _fakeLatestJson,
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });
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
    group(
      'HistoryPage pada ${size.width.toInt()}x${size.height.toInt()} '
      'dengan text scale 1.5:',
      () {
        testWidgets('tidak overflow dan menampilkan data history', (
          tester,
        ) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(_buildTestableScreen(size: size));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          // Elemen utama tampil.
          expect(find.text('History'), findsOneWidget);
          expect(find.text('Kamera online · 3 foto (1 jam terakhir)'), findsOneWidget);
          // Ringkasan: suhu, kelembapan, jumlah telur foto terbaru.
          expect(find.text('37.3°C'), findsOneWidget);
          expect(find.text('59%'), findsOneWidget);
          expect(find.text('6 butir'), findsOneWidget);
          // Tile kartu tangkapan: 3 foto.
          expect(find.text('200 KB'), findsOneWidget);
          expect(find.text('74 KB'), findsOneWidget);
          expect(find.text('120 KB'), findsOneWidget);
          // Hanya foto terbaru yang punya deteksi.
          expect(find.text('6 telur'), findsOneWidget);
          expect(find.text('Belum dianalisis'), findsNWidgets(2));
        });
      },
    );
  }

  testWidgets('Mengetuk filter lampu mengubah isi grid', (tester) async {
    const size = Size(360, 640);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildTestableScreen(size: size));
    await tester.pumpAndSettle();

    // Awal: filter "Semua" aktif, 3 foto tampil (ukuran file unik per foto).
    expect(find.text('200 KB'), findsOneWidget);
    expect(find.text('74 KB'), findsOneWidget);
    expect(find.text('120 KB'), findsOneWidget);

    // Tap filter "Lampu mati" → hanya 1 foto (lampu false).
    await _tapFilter(tester, 'filter_lampuMati');
    expect(find.text('200 KB'), findsNothing);
    expect(find.text('74 KB'), findsOneWidget);
    expect(find.text('120 KB'), findsNothing);

    // Tap filter "Semua" kembali → 3 foto tampil lagi.
    await _tapFilter(tester, 'filter_semua');
    expect(find.text('200 KB'), findsOneWidget);
    expect(find.text('74 KB'), findsOneWidget);
    expect(find.text('120 KB'), findsOneWidget);
  });

  testWidgets('Mengetuk kartu membuka detail dengan perbandingan', (
    tester,
  ) async {
    const size = Size(360, 640);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildTestableScreen(size: size));
    await tester.pumpAndSettle();

    // Ketuk kartu pertama (foto terbaru, ada deteksi).
    await tester.tap(find.text('6 telur'));
    await tester.pumpAndSettle();

    // Route halaman tetap ada di tree di bawah sheet, jadi "6 butir" muncul
    // di ringkasan halaman + baris detail = 2.
    expect(find.text('Perbandingan'), findsOneWidget);
    expect(find.text('Sebelum'), findsOneWidget);
    expect(find.text('Sekarang'), findsOneWidget);
    expect(find.text('Kondisi saat foto diambil'), findsOneWidget);
    expect(find.text('Telur terdeteksi'), findsOneWidget);
    expect(find.text('6 butir'), findsNWidgets(2));
    expect(find.text('Konfiden rata-rata 93% (YOLO)'), findsOneWidget);
    expect(find.text('Lampu pemanas'), findsOneWidget);
    expect(find.text('Menyala'), findsOneWidget);
  });
}
