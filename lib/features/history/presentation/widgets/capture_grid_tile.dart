import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/core/utils/date_formatter.dart';
import 'package:hatch_care/features/history/domain/models/history_models.dart';
import 'package:hatch_care/features/history/presentation/widgets/capture_image.dart';
import 'package:hatch_care/features/live/presentation/widgets/live_detection_image.dart';

/// Kartu tangkapan untuk grid halaman History.
///
/// Menampilkan thumbnail foto, waktu pengambilan (overlay), status lampu dan
/// motor (badge atas), serta hasil deteksi YOLO milik foto tersebut (bounding
/// box, jumlah telur, utuh/retak) bila tersedia.
class CaptureGridTile extends StatelessWidget {
  const CaptureGridTile({super.key, required this.record, required this.onTap});

  final CaptureRecord record;
  final VoidCallback onTap;

  IconData get _statusIcon {
    if (record.hasDetection) return Icons.egg_outlined;
    if (record.detectionPending) return Icons.hourglass_top;
    if (record.detectionFailed) return Icons.error_outline;
    return Icons.egg_outlined;
  }

  Color get _statusColor {
    if (record.hasDetection) return AppColors.primary;
    if (record.detectionPending) return AppColors.blueAccent;
    if (record.detectionFailed) return AppColors.statusOfflineText;
    return AppColors.textMuted;
  }

  String get _statusLabel {
    if (record.hasDetection) {
      return '${record.eggCount ?? record.detections.length} telur';
    }
    if (record.detectionPending) return 'Sedang dianalisis';
    if (record.detectionFailed) return 'Deteksi gagal';
    return 'Belum dianalisis';
  }

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
                  if (record.detections.any((detection) => detection.hasBox))
                    LiveDetectionImage(
                      image: record.image,
                      detections: record.detections,
                      fit: BoxFit.cover,
                      semanticLabel:
                          'Foto tray inkubator dengan bounding box YOLO',
                    )
                  else
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_statusIcon, size: 14, color: _statusColor),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          _statusLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: record.hasDetection ? 11 : 10,
                            fontWeight: record.hasDetection
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _statusColor,
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
                  if (record.hasDetection) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${record.intactEggCount} utuh · '
                      '${record.crackedEggCount} retak',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: record.crackedEggCount > 0
                            ? AppColors.statusOfflineText
                            : AppColors.statusOnlineText,
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
