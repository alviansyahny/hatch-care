import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/features/history/presentation/providers/history_provider.dart';
import 'package:hatch_care/features/history/presentation/widgets/candling_record_card.dart';
import 'package:hatch_care/features/history/presentation/widgets/history_filter_chips.dart';

/// Layar riwayat candling telur (tab History di menu bawah).
///
/// Data diambil dari [filteredCandlingRecordsProvider] (dummy sinkron).
/// Berdasarkan design/screens/13_history.png.
///
/// TODO: Layar detail telur — desain menunjukkan chevron `>` di tiap kartu,
/// mengindikasikan navigasi ke halaman detail hasil candling per telur.
/// Akan diimplementasi di tugas selanjutnya.
class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(filteredCandlingRecordsProvider);

    return Scaffold(
      backgroundColor: AppColors.fieldFill,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.neutral,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Column(
        children: [
          // Filter chips (tetap di atas, scroll horizontal)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: const HistoryFilterChips(),
          ),

          // Daftar riwayat candling (scroll vertikal)
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: records.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.borderLight),
              itemBuilder: (_, index) =>
                  CandlingRecordCard(record: records[index]),
            ),
          ),
        ],
      ),
    );
  }
}
