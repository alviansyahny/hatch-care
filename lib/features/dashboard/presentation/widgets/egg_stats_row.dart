import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/features/dashboard/domain/models/dashboard_models.dart';

/// Baris tiga kolom: Total Telur, Fertil, Infertil.
///
/// Berdasarkan design/screens/09_dashboard_1.png — bagian tengah dashboard.
class EggStatsRow extends StatelessWidget {
  const EggStatsRow({super.key, required this.stats});

  final EggStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _EggStatItem(
                icon: Icons.grid_view_rounded,
                iconBg: AppColors.fieldFill,
                iconColor: AppColors.primary,
                label: 'Total Telur',
                count: stats.total,
              ),
            ),
            const VerticalDivider(width: 1, color: AppColors.borderLight),
            Expanded(
              child: _EggStatItem(
                icon: Icons.lightbulb,
                iconBg: AppColors.tertiary.withValues(alpha: 0.25),
                iconColor: AppColors.tertiary,
                label: 'Fertil',
                count: stats.fertile,
              ),
            ),
            const VerticalDivider(width: 1, color: AppColors.borderLight),
            Expanded(
              child: _EggStatItem(
                icon: Icons.psychology_alt_outlined,
                iconBg: AppColors.secondary.withValues(alpha: 0.2),
                iconColor: AppColors.iconAccent,
                label: 'Infertil',
                count: stats.infertile,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EggStatItem extends StatelessWidget {
  const _EggStatItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  height: 1.1,
                ),
              ),
              const SizedBox(width: 3),
              const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Text(
                  'butir',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
