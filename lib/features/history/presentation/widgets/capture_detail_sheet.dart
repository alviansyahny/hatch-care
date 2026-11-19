import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/core/utils/date_formatter.dart';
import 'package:hatch_care/features/history/domain/models/history_models.dart';
import 'package:hatch_care/features/history/presentation/widgets/capture_image.dart';
import 'package:hatch_care/features/live/domain/models/incubator_models.dart';
import 'package:hatch_care/features/live/presentation/widgets/live_detection_image.dart';

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
    builder: (context) => _CaptureDetailSheet(records: records, index: index),
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
                onTap: () => _showFullscreenZoom(context, record),
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.feedDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.slateBorder),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _CapturePhoto(record: record),
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
              // --- Hasil deteksi YOLO foto ini ---
              if (record.detectionStatus != null) ...[
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Hasil Deteksi YOLO',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.sectionLabel,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _DetectionPanel(record: record),
              ],
              // --- Perbandingan before/after ---
              if (previous != null && !previous.image.isEmpty) ...[
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
                        record: previous,
                        onTap: () => _showFullscreenZoom(context, previous),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _CompareTile(
                        label: 'Sekarang',
                        time: record.capturedAt != null
                            ? formatTanggalSingkat(record.capturedAt!)
                            : null,
                        record: record,
                        onTap: () => _showFullscreenZoom(context, record),
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
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFullscreenZoom(BuildContext context, CaptureRecord record) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: _CapturePhoto(record: record),
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
// Foto + panel hasil deteksi
// ---------------------------------------------------------------------------

class _CapturePhoto extends StatelessWidget {
  const _CapturePhoto({required this.record});

  final CaptureRecord record;

  @override
  Widget build(BuildContext context) {
    if (record.detections.any((detection) => detection.hasBox)) {
      return LiveDetectionImage(
        image: record.image,
        detections: record.detections,
        semanticLabel: 'Foto tray inkubator dengan bounding box YOLO',
      );
    }
    return CaptureImage(image: record.image);
  }
}

class _DetectionPanel extends StatelessWidget {
  const _DetectionPanel({required this.record});

  final CaptureRecord record;

  @override
  Widget build(BuildContext context) {
    if (record.detectionPending) {
      return _DetectionMessage(
        icon: Icons.hourglass_top,
        color: AppColors.blueAccent,
        message: 'Foto ini sedang dianalisis ulang oleh YOLO.',
      );
    }
    if (record.detectionFailed) {
      return _DetectionMessage(
        icon: Icons.error_outline,
        color: AppColors.statusOfflineText,
        message:
            'Deteksi YOLO gagal untuk foto ini. Coba periksa ulang dari '
            'menu Live.',
      );
    }
    if (!record.hasDetection) {
      return _DetectionMessage(
        icon: Icons.hourglass_empty,
        color: AppColors.textMuted,
        message: 'Foto ini belum punya hasil deteksi YOLO.',
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.infoCardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slateBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Total',
                  value: '${record.eggCount ?? 0}',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatTile(
                  label: 'Utuh',
                  value: '${record.intactEggCount}',
                  color: AppColors.statusOnlineText,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatTile(
                  label: 'Retak',
                  value: '${record.crackedEggCount}',
                  color: AppColors.statusOfflineText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.verified_outlined,
                size: 16,
                color: AppColors.iconAccent,
              ),
              const SizedBox(width: AppSpacing.xs),
              const Expanded(
                child: Text(
                  'Keyakinan rata-rata',
                  style: TextStyle(fontSize: 12, color: AppColors.textSlate),
                ),
              ),
              Text(
                record.averageConfidencePercent == null
                    ? '-'
                    : '${record.averageConfidencePercent}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (record.detections.isNotEmpty) ...[
            const Divider(height: AppSpacing.lg),
            const Text(
              'Skor keyakinan per telur',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.sectionLabel,
              ),
            ),
            for (final detection in record.detections)
              _EggConfidenceRow(detection: detection),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textSlate),
            ),
          ),
        ],
      ),
    );
  }
}

class _EggConfidenceRow extends StatelessWidget {
  const _EggConfidenceRow({required this.detection});

  final EggDetection detection;

  @override
  Widget build(BuildContext context) {
    final color = detection.isCracked
        ? AppColors.statusOffline
        : AppColors.statusConnected;
    final confidence = detection.confidence;
    final label = detection.label.isEmpty
        ? 'Telur'
        : '${detection.label[0].toUpperCase()}'
              '${detection.label.substring(1)}';
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  '#${detection.id ?? '-'} $label',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBody,
                  ),
                ),
              ),
              Text(
                detection.confidencePercent != null
                    ? '${detection.confidencePercent}%'
                    : '-',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: confidence == null ? 0 : confidence.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetectionMessage extends StatelessWidget {
  const _DetectionMessage({
    required this.icon,
    required this.color,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.infoCardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slateBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: AppColors.textSlate),
            ),
          ),
        ],
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
    required this.record,
    required this.onTap,
    this.highlight = false,
  });

  final String label;
  final String? time;
  final CaptureRecord record;
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
                child: _CapturePhoto(record: record),
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
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

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
              style: const TextStyle(fontSize: 12, color: AppColors.textSlate),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: valueColor ?? AppColors.textBody,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
