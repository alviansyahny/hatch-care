import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/features/egg_check/domain/models/egg_check_models.dart';
import 'package:hatch_care/features/egg_check/presentation/widgets/egg_candling_custom_painter.dart';

/// Kartu viewfinder candling kamera:
/// Menampilkan visualisasi telur yang sedang dicandling, status senter (torch),
/// indikator lumens, dan tips candling di bagian bawah.
class EggCandlingViewfinder extends StatelessWidget {
  const EggCandlingViewfinder({
    super.key,
    required this.data,
    required this.onToggleTorch,
  });

  final EggCheckData data;
  final VoidCallback onToggleTorch;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF062347),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF02162E).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Bagian atas viewfinder dengan kontrol Torch dan area visualizer telur
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                // Tombol toggle Torch (Senter)
                InkWell(
                  onTap: onToggleTorch,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF041935).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          data.isTorchOn
                              ? Icons.flashlight_on
                              : Icons.flashlight_off,
                          color: data.isTorchOn
                              ? AppColors.tertiary
                              : Colors.white60,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'TORCH: ${data.isTorchOn ? "ON" : "OFF"}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Area kanvas candling telur
          SizedBox(
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Kanvas telur & reticle
                SizedBox(
                  width: 220,
                  height: 240,
                  child: CustomPaint(
                    painter: EggCandlingPainter(isTorchOn: data.isTorchOn),
                  ),
                ),

                // Label "AIR CELL ZONE"
                Positioned(
                  top: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    child: const Text(
                      'AIR CELL ZONE',
                      style: TextStyle(
                        color: AppColors.tertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Indikator Lumens
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                const Icon(
                  Icons.wb_sunny_outlined,
                  color: Colors.white70,
                  size: 16,
                ),
                // Bar Lumens
                Container(
                  width: 70,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 70 * data.lumensLevel.clamp(0.0, 1.0),
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.tertiary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                Text(
                  data.lumensStatus,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Kotak tip panduan candling
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF021733).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Candling Tip: ',
                      style: TextStyle(
                        color: AppColors.tertiary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                    TextSpan(
                      text: data.tipText,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
