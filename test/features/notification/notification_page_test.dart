import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hatch_care/features/notification/presentation/pages/notification_page.dart';

void main() {
  testWidgets('NotificationPage renders notifications and app bar correctly',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NotificationPage(),
      ),
    );

    // Verify AppBar title
    expect(find.text('Notifikasi'), findsOneWidget);

    // Verify notification titles
    expect(find.text('Suhu Inkubator'), findsOneWidget);
    expect(find.text('Kelembapan Ruang Telur Menurun'), findsOneWidget);
    expect(find.text('Sistem'), findsOneWidget);

    // Verify buttons and status
    expect(find.text('Cek Inkubator'), findsOneWidget);
    expect(find.text('Periksa Baki'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);
  });
}
