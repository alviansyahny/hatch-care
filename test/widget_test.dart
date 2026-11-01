import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hatch_care/app/app.dart';
import 'package:hatch_care/core/constants/app_colors.dart';

void main() {
  testWidgets('Splash menampilkan logo dan teks HATCH-CARE', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: HatchCareApp()));

    // Splash 1: logo sudah tampil.
    expect(find.byType(Image), findsOneWidget);

    // Teks "HATCH-CARE" sudah ada di tree (opacity 0 pada awal).
    expect(find.text('HATCH-CARE'), findsOneWidget);

    // Background scaffold harus kuning (Tertiary).
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, AppColors.tertiary);

    // Majukan waktu melewati semua timer (3,5 detik + sedikit lebih)
    // agar tidak ada timer menggantung.
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();
  });
}
