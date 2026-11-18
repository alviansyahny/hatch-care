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

  testWidgets('foto menampilkan hasil kelas dan kegagalan deteksi', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: IncubatorPhoto(
              photo: {
                'detection': {
                  'status': 'success',
                  'total_eggs': 2,
                  'detections': [
                    {'id': 1, 'class': 'utuh', 'confidence': 0.9},
                    {'id': 2, 'class': 'retak', 'confidence': 0.8},
                  ],
                },
              },
            ),
          ),
        ),
      ),
    );
    expect(find.text('Utuh: 1'), findsOneWidget);
    expect(find.text('Retak: 1'), findsOneWidget);
    expect(find.text('Telur 2: retak (80.0%)'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: IncubatorPhoto(
            photo: {
              'detection': {'status': 'failed'},
            },
          ),
        ),
      ),
    );
    expect(
      find.text('Deteksi YOLO gagal. Foto asli tetap tersedia.'),
      findsOneWidget,
    );
  });
}
