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

/// PNG 1x1 valid sebagai isi foto tiruan (agar bounding box bisa dirender).
const _fakeImageUri =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ'
    'AAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

const _box = '[0,0,1,1]';

/// Body JSON tiruan `GET /incubator/latest` dengan 3 foto: dua pertama
/// terang, satu terakhir gelap (lampu mati). Setiap foto membawa hasil
/// deteksi YOLO miliknya sendiri; foto tertua belum dianalisis.
const _fakeLatestJson =
    '''
{
  "status": "online",
  "online": true,
  "image": "$_fakeImageUri",
  "url": "$_fakeImageUri",
  "total_eggs": 4,
  "detections": [
    {"id": 1, "box": $_box, "class": "retak", "confidence": 0.54},
    {"id": 2, "box": $_box, "class": "utuh", "confidence": 0.76},
    {"id": 3, "box": $_box, "class": "utuh", "confidence": 0.37},
    {"id": 4, "box": $_box, "class": "utuh", "confidence": 0.40}
  ],
  "detection": {
    "status": "success", "total_eggs": 4,
    "detections": [
      {"id": 1, "box": $_box, "class": "retak", "confidence": 0.54},
      {"id": 2, "box": $_box, "class": "utuh", "confidence": 0.76},
      {"id": 3, "box": $_box, "class": "utuh", "confidence": 0.37},
      {"id": 4, "box": $_box, "class": "utuh", "confidence": 0.40}
    ]
  },
  "temperature": 37.3,
  "humidity": 58.7,
  "lamp": true,
  "motor": false,
  "rssi": -64,
  "history": [
    {"id": "c", "filename": "inc_3.jpg", "url": "$_fakeImageUri",
     "timestamp": 1762900020, "temperature": 37.3, "humidity": 58.7,
     "lamp": true, "motor": false, "size_kb": 200,
     "detection": {
       "status": "success", "total_eggs": 4,
       "detections": [
         {"id": 1, "box": $_box, "class": "retak", "confidence": 0.54},
         {"id": 2, "box": $_box, "class": "utuh", "confidence": 0.76},
         {"id": 3, "box": $_box, "class": "utuh", "confidence": 0.37},
         {"id": 4, "box": $_box, "class": "utuh", "confidence": 0.40}
       ]
     }},
    {"id": "b", "filename": "inc_2.jpg", "url": "$_fakeImageUri",
     "timestamp": 1762899900, "temperature": 37.1, "humidity": 59.0,
     "lamp": false, "motor": false, "size_kb": 74,
     "detection": {
       "status": "success", "total_eggs": 2,
       "detections": [
         {"id": 1, "box": $_box, "class": "utuh", "confidence": 0.60},
         {"id": 2, "box": $_box, "class": "utuh", "confidence": 0.40}
       ]
     }},
    {"id": "a", "filename": "inc_1.jpg", "url": "$_fakeImageUri",
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
    overrides: [apiClientProvider.overrideWithValue(_mockClient())],
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

/// Memuat halaman dan memberi waktu dekode gambar base64 berjalan.
Future<void> _pumpHistory(WidgetTester tester, Size size) async {
  await tester.pumpWidget(_buildTestableScreen(size: size));
  await tester.pumpAndSettle();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 200)),
  );
  await tester.pumpAndSettle();
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
      testWidgets('tidak overflow dan menampilkan data history', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await _pumpHistory(tester, size);
        expect(tester.takeException(), isNull);

        // Elemen utama tampil.
        expect(find.text('History'), findsOneWidget);
        expect(
          find.text('Kamera online · 3 foto (1 jam terakhir)'),
          findsOneWidget,
        );
        // Ringkasan: suhu, kelembapan, jumlah telur foto terbaru.
        expect(find.text('37.3°C'), findsOneWidget);
        expect(find.text('59%'), findsOneWidget);
        expect(find.text('4 butir'), findsOneWidget);
        expect(find.text('3 utuh · 1 retak'), findsNWidgets(2));
        // Tile kartu tangkapan: 3 foto.
        expect(find.text('200 KB'), findsOneWidget);
        expect(find.text('74 KB'), findsOneWidget);
        expect(find.text('120 KB'), findsOneWidget);
        // Dua foto punya hasil deteksi sendiri; foto tertua belum dianalisis.
        expect(find.text('4 telur'), findsOneWidget);
        expect(find.text('2 telur'), findsOneWidget);
        expect(find.text('Belum dianalisis'), findsOneWidget);
        // Bounding box YOLO tampil di thumbnail foto yang dianalisis.
        expect(
          find.byKey(const ValueKey('egg-detection-overlay')),
          findsNWidgets(2),
        );
      });
    });
  }

  testWidgets('Mengetuk filter lampu mengubah isi grid', (tester) async {
    const size = Size(360, 640);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await _pumpHistory(tester, size);

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

    await _pumpHistory(tester, size);

    // Ketuk kartu pertama (foto terbaru, ada deteksi).
    await tester.tap(find.text('4 telur'));
    await tester.pumpAndSettle();

    expect(find.text('Perbandingan'), findsOneWidget);
    expect(find.text('Sebelum'), findsOneWidget);
    expect(find.text('Sekarang'), findsOneWidget);
    expect(find.text('Kondisi saat foto diambil'), findsOneWidget);
    // Ringkasan + rincian deteksi YOLO per telur.
    expect(find.text('Hasil Deteksi YOLO'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Utuh'), findsOneWidget);
    expect(find.text('Retak'), findsOneWidget);
    expect(find.text('Skor keyakinan per telur'), findsOneWidget);
    expect(find.text('Keyakinan rata-rata'), findsOneWidget);
    expect(find.text('#1 Retak'), findsOneWidget);
    expect(find.text('#2 Utuh'), findsOneWidget);
    expect(find.text('#3 Utuh'), findsOneWidget);
    expect(find.text('#4 Utuh'), findsOneWidget);
    expect(find.text('54%'), findsOneWidget);
    expect(find.text('52%'), findsOneWidget);
    expect(find.text('Lampu pemanas'), findsOneWidget);
    expect(find.text('Menyala'), findsOneWidget);
  });
}
