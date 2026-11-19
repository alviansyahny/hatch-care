import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/features/dashboard/domain/models/dashboard_models.dart';

/// Kartu gelap berisi status koneksi dan progres penetasan inkubator.
///
/// Berdasarkan design/screens/09_dashboard_1.png — bagian teratas dashboard.
class IncubatorStatusCard extends StatelessWidget {
  const IncubatorStatusCard({super.key, required this.status});

  final IncubatorStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris judul + badge koneksi
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.egg_alt,
                  color: AppColors.tertiary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Judul boleh turun ke baris kedua kalau layar sempit
              const Expanded(
                child: Text(
                  'Status Inkubator',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ConnectionBadge(isConnected: status.isConnected),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Teks status singkat
          Text(
            status.statusText,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.secondary,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Baris hari + fase (badge fase turun ke baris baru kalau sempit)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: AppSpacing.sm,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.tertiary,
                    size: 14,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      'Hari ke-${status.currentDay} dari ${status.totalDays}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neutral.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.phaseLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.neutral,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Progress bar hari penetasan
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: status.progress,
              minHeight: 6,
              backgroundColor: AppColors.neutral.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({required this.isConnected});

  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutral.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isConnected
                  ? AppColors.statusConnected
                  : AppColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isConnected ? 'Terhubung' : 'Terputus',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.neutral,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
