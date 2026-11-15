import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/core/utils/date_formatter.dart';
import 'package:hatch_care/features/history/domain/models/history_models.dart';
import 'package:hatch_care/features/history/presentation/widgets/capture_image.dart';
import 'package:hatch_care/features/live/domain/models/incubator_models.dart';

/// Bottom sheet detail satu tangkapan foto kamera inkubator.
///
/// Isi: foto besar (pinch-zoom), perbandingan "Sebelum vs Sekarang" bila ada
/// foto sebelumnya, dan rincian kondisi tray saat foto diambil (suhu,
/// kelembapan, lampu, motor, ukuran file, hasil deteksi telur).
void showCaptureDetailSheet(
  BuildContext context, {
  required List<CaptureRecord> records,
  required int index,
}) {
  if (index < 0 || index >= records.length) return;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.neutral,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) =>
        _CaptureDetailSheet(records: records, index: index),
  );
}

class _CaptureDetailSheet extends StatelessWidget {
  const _CaptureDetailSheet({required this.records, required this.index});

  final List<CaptureRecord> records;
  final int index;

  @override
  Widget build(BuildContext context) {
    final record = records[index];
    // Records terurut terbaru dulu, jadi "sebelum" ada di index+1.
    final previous = index + 1 < records.length ? records[index + 1] : null;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Handle + header ---
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.photo_camera_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      record.capturedAt != null
                          ? formatTanggalWaktuWib(record.capturedAt!)
                          : 'Waktu tidak diketahui',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              // --- Foto besar (pinch-zoom) ---
              GestureDetector(
                onTap: () => _showFullscreenZoom(context, record.image),
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.feedDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.slateBorder),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CaptureImage(image: record.image, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Center(
                child: Text(
                  'Ketuk foto untuk memperbesar (pinch-zoom)',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
              // --- Perbandingan before/after ---
              if (previous != null && previous.image.networkUrl != null) ...[
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Perbandingan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.sectionLabel,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _CompareTile(
                        label: 'Sebelum',
                        time: previous.capturedAt != null
                            ? formatTanggalSingkat(previous.capturedAt!)
                            : null,
                        image: previous.image,
                        onTap: () =>
                            _showFullscreenZoom(context, previous.image),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _CompareTile(
                        label: 'Sekarang',
                        time: record.capturedAt != null
                            ? formatTanggalSingkat(record.capturedAt!)
                            : null,
                        image: record.image,
                        onTap: () => _showFullscreenZoom(context, record.image),
                        highlight: true,
                      ),
                    ),
                  ],
                ),
              ],
              // --- Rincian kondisi ---
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Kondisi saat foto diambil',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.sectionLabel,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.infoCardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.slateBorder),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.thermostat,
                      label: 'Suhu',
                      value: record.temperature != null
                          ? '${record.temperature!.toStringAsFixed(1)} °C'
                          : 'Tidak ada data',
                    ),
                    _InfoRow(
                      icon: Icons.water_drop_outlined,
                      label: 'Kelembapan',
                      value: record.humidity != null
                          ? '${record.humidity!.toStringAsFixed(1)} %RH'
                          : 'Tidak ada data',
                    ),
                    _InfoRow(
                      icon: record.lamp == true
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      label: 'Lampu pemanas',
                      value: record.lamp == null
                          ? 'Tidak ada data'
                          : (record.lamp! ? 'Menyala' : 'Mati'),
                      valueColor: record.lamp == true
                          ? AppColors.statusOnlineText
                          : AppColors.textSlate,
                    ),
                    _InfoRow(
                      icon: Icons.motion_photos_on,
                      label: 'Motor rotasi',
                      value: record.motor == null
                          ? 'Tidak ada data'
                          : (record.motor! ? 'Berputar' : 'Diam'),
                    ),
                    _InfoRow(
                      icon: Icons.save_outlined,
                      label: 'Ukuran foto',
                      value: record.sizeKb != null
                          ? '${record.sizeKb} KB'
                          : 'Tidak ada data',
                    ),
                    _InfoRow(
                      icon: Icons.egg_outlined,
                      label: 'Telur terdeteksi',
                      value: record.hasDetection
                          ? '${record.eggCount} butir'
                          : 'Belum dianalisis',
                      valueColor: record.hasDetection
                          ? AppColors.primary
                          : AppColors.textMuted,
                      subtitle: record.hasDetection
                          ? 'Konfiden rata-rata '
                                '${record.averageConfidencePercent ?? 0}% (YOLO)'
                          : 'Hanya foto terbaru yang dianalisis server',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFullscreenZoom(BuildContext context, IncubatorImage image) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CaptureImage(image: image, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widget kecil
// ---------------------------------------------------------------------------

class _CompareTile extends StatelessWidget {
  const _CompareTile({
    required this.label,
    required this.time,
    required this.image,
    required this.onTap,
    this.highlight = false,
  });

  final String label;
  final String? time;
  final IncubatorImage image;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: highlight ? AppColors.blueAccent : AppColors.slateBorder,
            width: highlight ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CaptureImage(image: image),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Flexible(
                  child: Text(
                    time ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: highlight
                          ? AppColors.blueAccent
                          : AppColors.textMuted,
                      fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: highlight
                        ? AppColors.blueAccent
                        : AppColors.textSlate,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.iconAccent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSlate,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? AppColors.textBody,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
