import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';

/// CustomPainter untuk menggambar overlay candling:
/// - Kontur telur dengan garis putus-putus
/// - Garis lengkung putus-putus untuk "AIR CELL ZONE" di bagian atas telur
/// - Tanda bidik (crosshair ticks) di 4 penjuru (atas, bawah, kiri, kanan)
/// - Visualisasi transluminasi embrio dan jaringan vaskular (pembuluh darah)
class EggCandlingPainter extends CustomPainter {
  const EggCandlingPainter({
    required this.isTorchOn,
    this.embryoProgress = 0.5,
  });

  final bool isTorchOn;
  final double embryoProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final eggWidth = size.width * 0.72;
    final eggHeight = size.height * 0.82;

    final eggRect = Rect.fromCenter(
      center: center,
      width: eggWidth,
      height: eggHeight,
    );

    // Bentuk telur yang realistis (bagian atas sedikit lebih ramping daripada bawah)
    final eggPath = Path();
    eggPath.moveTo(center.dx, eggRect.top);
    // Lengkungan kanan atas
    eggPath.cubicTo(
      center.dx + eggWidth * 0.52,
      eggRect.top,
      center.dx + eggWidth * 0.55,
      center.dy,
      center.dx + eggWidth * 0.50,
      eggRect.bottom - eggHeight * 0.15,
    );
    // Lengkungan kanan bawah menuju kutub bawah
    eggPath.cubicTo(
      center.dx + eggWidth * 0.45,
      eggRect.bottom,
      center.dx + eggWidth * 0.20,
      eggRect.bottom,
      center.dx,
      eggRect.bottom,
    );
    // Lengkungan kiri bawah
    eggPath.cubicTo(
      center.dx - eggWidth * 0.20,
      eggRect.bottom,
      center.dx - eggWidth * 0.45,
      eggRect.bottom,
      center.dx - eggWidth * 0.50,
      eggRect.bottom - eggHeight * 0.15,
    );
    // Lengkungan kiri atas kembali ke kutub atas
    eggPath.cubicTo(
      center.dx - eggWidth * 0.55,
      center.dy,
      center.dx - eggWidth * 0.52,
      eggRect.top,
      center.dx,
      eggRect.top,
    );
    eggPath.close();

    // 1. Gambar isi transluminasi jika senter (torch) menyala
    if (isTorchOn) {
      canvas.save();
      canvas.clipPath(eggPath);

      // Glow utama candling (gradien radial hangat oranye/kuning ke gelap)
      final glowPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment(0.0, -0.05),
          radius: 0.9,
          colors: const [
            Color(0xFFFFC043),
            Color(0xFFE67E22),
            Color(0xFFD35400),
            Color(0xFF8B2500),
            Color(0xFF2C1005),
          ],
          stops: const [0.0, 0.35, 0.65, 0.85, 1.0],
        ).createShader(eggRect);

      canvas.drawRect(eggRect, glowPaint);

      // Spot embrio (bayangan gelap di tengah)
      final embryoCenter = Offset(center.dx - 8, center.dy - 12);
      final embryoPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF261108).withValues(alpha: 0.85),
            const Color(0xFF3E1E0F).withValues(alpha: 0.6),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(
          Rect.fromCircle(center: embryoCenter, radius: eggWidth * 0.28),
        );
      canvas.drawCircle(embryoCenter, eggWidth * 0.28, embryoPaint);

      // Titik mata embrio (dark eye spot)
      final eyeSpotPaint = Paint()
        ..color = const Color(0xFF140804).withValues(alpha: 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(
        Offset(embryoCenter.dx + 4, embryoCenter.dy + 2),
        10,
        eyeSpotPaint,
      );

      // Jaringan vaskular (pembuluh darah halus)
      _drawVascularWebbing(canvas, embryoCenter, eggWidth);

      canvas.restore();
    } else {
      // Jika lampu mati, tampilkan bayangan telur gelap
      canvas.save();
      canvas.clipPath(eggPath);
      final darkPaint = Paint()..color = const Color(0xFF061527);
      canvas.drawRect(eggRect, darkPaint);
      canvas.restore();
    }

    // 2. Garis putus-putus kontur telur
    final dashedOutlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    _drawDashedPath(canvas, eggPath, dashedOutlinePaint, dashLength: 6, gapLength: 4);

    // 3. Garis lengkung "AIR CELL ZONE" di bagian atas telur
    final airCellPath = Path();
    final airCellY = eggRect.top + eggHeight * 0.22;
    airCellPath.moveTo(center.dx - eggWidth * 0.44, airCellY);
    airCellPath.quadraticBezierTo(
      center.dx,
      airCellY + eggHeight * 0.08,
      center.dx + eggWidth * 0.44,
      airCellY,
    );

    final airCellPaint = Paint()
      ..color = AppColors.tertiary.withValues(alpha: 0.75)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    _drawDashedPath(canvas, airCellPath, airCellPaint, dashLength: 4, gapLength: 3);

    // 4. Crosshair Ticks (Kuning) pada 4 sisi
    final tickPaint = Paint()
      ..color = AppColors.tertiary
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const tickLength = 10.0;
    // Atas
    canvas.drawLine(
      Offset(center.dx, eggRect.top - 8),
      Offset(center.dx, eggRect.top - 8 + tickLength),
      tickPaint,
    );
    // Bawah
    canvas.drawLine(
      Offset(center.dx, eggRect.bottom + 8 - tickLength),
      Offset(center.dx, eggRect.bottom + 8),
      tickPaint,
    );
    // Kiri
    canvas.drawLine(
      Offset(center.dx - eggWidth * 0.52 - 6, center.dy),
      Offset(center.dx - eggWidth * 0.52 - 6 + tickLength, center.dy),
      tickPaint,
    );
    // Kanan
    canvas.drawLine(
      Offset(center.dx + eggWidth * 0.52 + 6 - tickLength, center.dy),
      Offset(center.dx + eggWidth * 0.52 + 6, center.dy),
      tickPaint,
    );
  }

  /// Menggambar jaring pembuluh darah vaskular yang realistis.
  void _drawVascularWebbing(Canvas canvas, Offset origin, double eggWidth) {
    final veinPaint = Paint()
      ..color = const Color(0xFF6B1800).withValues(alpha: 0.65)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fineVeinPaint = Paint()
      ..color = const Color(0xFF8B2500).withValues(alpha: 0.45)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final branches = [
      // Cabang ke kiri atas
      [
        origin,
        Offset(origin.dx - eggWidth * 0.15, origin.dy - 18),
        Offset(origin.dx - eggWidth * 0.28, origin.dy - 35),
      ],
      // Cabang ke kanan atas
      [
        origin,
        Offset(origin.dx + eggWidth * 0.14, origin.dy - 15),
        Offset(origin.dx + eggWidth * 0.26, origin.dy - 30),
      ],
      // Cabang ke kanan bawah
      [
        origin,
        Offset(origin.dx + eggWidth * 0.18, origin.dy + 20),
        Offset(origin.dx + eggWidth * 0.30, origin.dy + 45),
      ],
      // Cabang ke kiri bawah
      [
        origin,
        Offset(origin.dx - eggWidth * 0.16, origin.dy + 18),
        Offset(origin.dx - eggWidth * 0.28, origin.dy + 40),
      ],
      // Cabang ke bawah
      [
        origin,
        Offset(origin.dx - 4, origin.dy + 25),
        Offset(origin.dx + 6, origin.dy + 50),
      ],
    ];

    for (final branch in branches) {
      final path = Path()..moveTo(branch[0].dx, branch[0].dy);
      path.quadraticBezierTo(
        branch[1].dx,
        branch[1].dy,
        branch[2].dx,
        branch[2].dy,
      );
      canvas.drawPath(path, veinPaint);

      // Anak cabang halus
      final subPath = Path()..moveTo(branch[1].dx, branch[1].dy);
      subPath.quadraticBezierTo(
        branch[1].dx + 10,
        branch[1].dy + 8,
        branch[1].dx + 16,
        branch[1].dy + 20,
      );
      canvas.drawPath(subPath, fineVeinPaint);
    }
  }

  /// Utility untuk menggambar path putus-putus (dashed).
  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final currentDash = math.min(dashLength, metric.length - distance);
        final extractPath = metric.extractPath(distance, distance + currentDash);
        canvas.drawPath(extractPath, paint);
        distance += currentDash + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant EggCandlingPainter oldDelegate) {
    return oldDelegate.isTorchOn != isTorchOn ||
        oldDelegate.embryoProgress != embryoProgress;
  }
}
