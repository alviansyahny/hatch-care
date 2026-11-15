import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/core/utils/date_formatter.dart';
import 'package:hatch_care/features/history/domain/models/history_models.dart';
import 'package:hatch_care/features/history/presentation/widgets/capture_image.dart';

/// Kartu tangkapan untuk grid halaman History.
///
/// Menampilkan thumbnail foto, waktu pengambilan (overlay), status lampu dan
/// motor (badge atas), serta jumlah telur hasil deteksi YOLO bila tersedia
/// (hanya foto terbaru yang dianalisis server).
class CaptureGridTile extends StatelessWidget {
  const CaptureGridTile({
    super.key,
    required this.record,
    required this.onTap,
  });

  final CaptureRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final timeText = record.capturedAt != null
        ? formatTanggalSingkat(record.capturedAt!)
        : 'Waktu tidak diketahui';

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: AppColors.neutral,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Thumbnail + overlay badge ---
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CaptureImage(image: record.image),
                  if (record.lamp != null || record.motor == true)
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: Row(
                        children: [
                          if (record.lamp != null) ...[
                            _IconBadge(
                              icon: record.lamp!
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                              color: record.lamp!
                                  ? AppColors.tertiary
                                  : AppColors.textSlateLight,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          if (record.motor == true)
                            _IconBadge(
                              icon: Icons.motion_photos_on,
                              color: AppColors.statusConnected,
                            ),
                        ],
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black54, Colors.transparent],
                        ),
                      ),
                      child: Text(
                        timeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // --- Info bawah thumbnail ---
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.xs,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  if (record.hasDetection) ...[
                    const Icon(
                      Icons.egg_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        '${record.eggCount} telur',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ] else
                    const Expanded(
                      child: Text(
                        'Belum dianalisis',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  if (record.sizeKb != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${record.sizeKb} KB',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }
}
