import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/features/history/domain/models/history_models.dart';
import 'package:hatch_care/features/history/presentation/providers/history_provider.dart';

/// Baris filter chip horizontal untuk menyaring daftar tangkapan kamera.
///
/// Chip: Semua | 💡 Lampu nyala | 🌙 Lampu mati.
/// Foto gelap umumnya diambil saat lampu mati, jadi filter ini membantu
/// memilah foto yang layak dilihat. Jumlah dihitung dari data.
class HistoryFilterChips extends ConsumerWidget {
  const HistoryFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(captureFilterProvider);
    final counts = ref.watch(captureFilterCountsProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in CaptureFilter.values) ...[
            if (filter != CaptureFilter.values.first)
              const SizedBox(width: AppSpacing.sm),
            _FilterChip(
              chipKey: Key('filter_${filter.name}'),
              label: filter.label,
              count: counts[filter] ?? 0,
              dotColor: filter == CaptureFilter.lampuNyala
                  ? AppColors.statusConnected
                  : filter == CaptureFilter.lampuMati
                  ? AppColors.textSlateLight
                  : null,
              isActive: currentFilter == filter,
              onTap: () =>
                  ref.read(captureFilterProvider.notifier).setFilter(filter),
            ),
          ],
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
