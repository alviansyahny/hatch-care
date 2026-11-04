import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:hatch_care/app/theme/app_theme.dart';
import 'package:hatch_care/features/egg_check/presentation/pages/egg_check_page.dart';

Widget _buildTestableEggCheckScreen({
  required Size size,
  double textScale = 1.0,
}) {
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

          // Memastikan judul dan elemen utama muncul
          expect(find.text('Egg Checking (Candling)'), findsOneWidget);
          expect(find.text('Ambil Foto Candling'), findsOneWidget);
        });
      },
    );
  }
}
