import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hatch_care/screens/connected_app.dart';

void main() {
  testWidgets('form login menampilkan validasi', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: AuthPage(onAuthenticated: () {})),
    );
    await tester.tap(find.text('Masuk'));
    await tester.pump();
    expect(find.text('Username atau email wajib diisi'), findsOneWidget);
    expect(find.text('Kata sandi wajib diisi'), findsOneWidget);
  });
}
