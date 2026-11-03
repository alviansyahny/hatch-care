import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/features/dashboard/domain/models/dashboard_models.dart';

/// Daftar kartu "Fitur Utama" di bagian bawah dashboard.
///
/// Berdasarkan design/screens/09_dashboard_1.png.
/// Item dengan [MainFeature.isActive] == false ditampilkan non-interaktif
/// (direncanakan: Remote Control, belum ada layar tujuan).
class MainFeatureList extends StatelessWidget {
  const MainFeatureList({super.key, required this.features});

  final List<MainFeature> features;

  @override
  Widget build(BuildContext context) {
    if (features.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          for (int i = 0; i < features.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                color: AppColors.borderLight,
                indent: AppSpacing.lg,
              ),
            _FeatureItem(feature: features[i]),
          ],
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.feature});

  final MainFeature feature;

  @override
  Widget build(BuildContext context) {
    final isActive = feature.isActive;

    return Opacity(
      opacity: isActive ? 1.0 : 0.5,
      child: InkWell(
        // Hanya aktif jika isActive == true
        onTap: isActive && feature.route != null
            ? () {} // route navigasi akan ditambahkan saat layar tersedia
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              // Ikon fitur
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.fieldFill,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  feature.icon,
                  color: AppColors.iconAccent,
                  size: 20,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Judul, tag, dan deskripsi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris judul + tag
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.xs,
                      children: [
                        Text(
                          feature.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        _TagBadge(label: feature.tag),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      feature.subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              if (isActive)
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.iconAccent,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppColors.iconAccent,
        ),
      ),
    );
  }
}
