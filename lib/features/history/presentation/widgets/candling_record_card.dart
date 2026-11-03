import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/core/utils/date_formatter.dart';
import 'package:hatch_care/features/history/domain/models/history_models.dart';

/// Kartu satu baris riwayat candling telur.
///
/// Berdasarkan design/screens/13_history.png.
/// Layout responsif: Wrap untuk badge, maxLines + ellipsis untuk teks panjang,
/// foto placeholder ukuran tetap kecil.
class CandlingRecordCard extends StatelessWidget {
  const CandlingRecordCard({super.key, required this.record});

  final CandlingRecord record;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto placeholder + badge confidence
          _EggPhotoPlaceholder(
            status: record.status,
            confidencePercent: record.confidencePercent,
          ),

          const SizedBox(width: AppSpacing.md),

          // Kolom info teks (Expanded agar responsif di layar kecil)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris 1: nama telur + badge hari + badge status (Wrap agar
                // tidak overflow di layar kecil / text scale tinggi).
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Egg #${record.eggNumber.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    _DayBadge(day: record.day),
                    _StatusBadge(status: record.status),
                  ],
                ),

                const SizedBox(height: AppSpacing.xs),

                // Baris 2: label status (warna teks beda untuk mortalitas)
                Text(
                  record.status.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: record.status == EggStatus.mortalitas
                        ? AppColors.badgeMortalitasText
                        : AppColors.primary,
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                // Baris 3: kode batch + tanggal. Wrap supaya tanggal turun ke
                // baris baru kalau layar sempit / font besar.
                Wrap(
                  spacing: AppSpacing.lg,
                  runSpacing: 2,
                  children: [
                    Text(
                      record.batchCode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      formatTanggalSingkat(record.dateTime),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.xs),

          // Chevron navigasi (layar detail belum diimplementasi)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.md),
            child: Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Foto placeholder telur dengan badge confidence
// ---------------------------------------------------------------------------

class _EggPhotoPlaceholder extends StatelessWidget {
  const _EggPhotoPlaceholder({
    required this.status,
    required this.confidencePercent,
  });

  final EggStatus status;
  final int confidencePercent;

  Color get _badgeColor {
    return switch (status) {
      EggStatus.fertil => AppColors.statusConnected,
      EggStatus.infertil => AppColors.secondary,
      EggStatus.mortalitas => AppColors.badgeMortalitasDot,
    };
  }

  IconData get _badgeIcon {
    return switch (status) {
      EggStatus.fertil => Icons.local_fire_department,
      EggStatus.infertil => Icons.remove,
      EggStatus.mortalitas => Icons.warning_amber_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        children: [
          // Placeholder foto
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.egg, color: AppColors.secondary, size: 32),
          ),

          // Badge confidence di pojok kiri bawah
          Positioned(
            left: 4,
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: _badgeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_badgeIcon, size: 10, color: AppColors.neutral),
                  const SizedBox(width: 2),
                  Text(
                    '$confidencePercent%',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Badge hari ("Hari 11")
// ---------------------------------------------------------------------------

class _DayBadge extends StatelessWidget {
  const _DayBadge({required this.day});

  final int day;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        'Hari $day',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textBody,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Badge status (● Fertile / ● Infertile / ● Mortalitas)
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final EggStatus status;

  Color get _backgroundColor {
    return switch (status) {
      EggStatus.fertil => AppColors.badgeFertileBg,
      EggStatus.infertil => AppColors.badgeInfertileBg,
      EggStatus.mortalitas => AppColors.badgeMortalitasBg,
    };
  }

  Color get _textColor {
    return switch (status) {
      EggStatus.fertil => AppColors.primary,
      EggStatus.infertil => AppColors.primary,
      EggStatus.mortalitas => AppColors.badgeMortalitasText,
    };
  }

  Color get _dotColor {
    return switch (status) {
      EggStatus.fertil => AppColors.statusConnected,
      EggStatus.infertil => AppColors.badgeInfertileDot,
      EggStatus.mortalitas => AppColors.badgeMortalitasDot,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: _dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }
}
