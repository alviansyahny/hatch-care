import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/features/egg_check/presentation/widgets/egg_candling_custom_painter.dart';

/// Komponen visual tampilan live candling telur.
///
/// Menampilkan feed/foto resolusi tinggi dengan fixture lampu LED atas-bawah
/// serta tombol "Perbesar Foto" di pojok kanan bawah.
class LiveCandlingDisplay extends StatelessWidget {
  const LiveCandlingDisplay({
    super.key,
    required this.onZoomIn,
  });

  final VoidCallback onZoomIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF070B12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background gelap ruang candling
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.9,
                  colors: [
                    Color(0xFF151C28),
                    Color(0xFF070B12),
                  ],
                ),
              ),
            ),
          ),

          // Lampu dudukan fixture atas
          Positioned(
            top: 24,
            child: Container(
              width: 90,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                  bottom: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),

          // Telur Candling di tengah
          SizedBox(
            width: 220,
            height: 240,
            child: const CustomPaint(
              painter: EggCandlingPainter(isTorchOn: true),
            ),
          ),

          // Dudukan fixture bawah
          Positioned(
            bottom: 24,
            child: Container(
              width: 76,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),

          // Tombol "Perbesar Foto" di pojok kanan bawah
          Positioned(
            right: 14,
            bottom: 14,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onZoomIn,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.search,
                        size: 15,
                        color: AppColors.primaryDark,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Perbesar Foto',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
