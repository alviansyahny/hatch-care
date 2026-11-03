import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/features/history/domain/models/history_models.dart';
import 'package:hatch_care/features/history/presentation/providers/history_provider.dart';

/// Baris filter chip horizontal untuk menyaring riwayat candling.
///
/// Chip: Semua | ● Fertile | ● Infertile | ● Mortalitas.
/// Chip aktif berwarna primary dengan teks putih; chip lain outline.
/// Jumlah dihitung dari data melalui [historyCountsProvider].
class HistoryFilterChips extends ConsumerWidget {
  const HistoryFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(historyFilterProvider);
    final counts = ref.watch(historyCountsProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            chipKey: const Key('filter_semua'),
            label: 'Semua',
            count: counts[null] ?? 0,
            isActive: currentFilter == null,
            onTap: () =>
                ref.read(historyFilterProvider.notifier).setFilter(null),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            chipKey: const Key('filter_fertil'),
            label: EggStatus.fertil.label,
            count: counts[EggStatus.fertil] ?? 0,
            dotColor: AppColors.statusConnected,
            isActive: currentFilter == EggStatus.fertil,
            onTap: () => ref
                .read(historyFilterProvider.notifier)
                .setFilter(EggStatus.fertil),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            chipKey: const Key('filter_infertil'),
            label: EggStatus.infertil.label,
            count: counts[EggStatus.infertil] ?? 0,
            dotColor: AppColors.badgeInfertileDot,
            isActive: currentFilter == EggStatus.infertil,
            onTap: () => ref
                .read(historyFilterProvider.notifier)
                .setFilter(EggStatus.infertil),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            chipKey: const Key('filter_mortalitas'),
            label: EggStatus.mortalitas.label,
            count: counts[EggStatus.mortalitas] ?? 0,
            dotColor: AppColors.badgeMortalitasDot,
            isActive: currentFilter == EggStatus.mortalitas,
            onTap: () => ref
                .read(historyFilterProvider.notifier)
                .setFilter(EggStatus.mortalitas),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Satu chip filter
// ---------------------------------------------------------------------------

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.chipKey,
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
    this.dotColor,
  });

  final Key chipKey;
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  /// Warna titik di depan label. `null` untuk chip "Semua".
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: chipKey,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.neutral,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.neutral : dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.neutral : AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.neutral : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
