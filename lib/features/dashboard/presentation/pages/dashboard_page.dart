import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:hatch_care/features/dashboard/presentation/widgets/egg_stats_row.dart';
import 'package:hatch_care/features/dashboard/presentation/widgets/incubator_condition_card.dart';
import 'package:hatch_care/features/dashboard/presentation/widgets/incubator_status_card.dart';
import 'package:hatch_care/features/dashboard/presentation/widgets/main_feature_list.dart';

/// Layar dashboard utama HATCH-CARE.
///
/// Data diambil dari [dashboardProvider] (dummy sinkron untuk saat ini).
/// Berdasarkan design/screens/09_dashboard_1.png dan 10_dashboard_2.png.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.fieldFill,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Header: salam + ikon notifikasi
                  _DashboardHeader(),

                  const SizedBox(height: AppSpacing.md),

                  // Kartu status inkubator (gelap)
                  IncubatorStatusCard(status: data.status),

                  const SizedBox(height: AppSpacing.md),

                  // Kartu kondisi inkubator: teks sensor + grafik tren
                  IncubatorConditionCard(
                    condition: data.condition,
                    chartPoints: data.chartPoints,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Baris statistik telur
                  EggStatsRow(stats: data.eggStats),

                  const SizedBox(height: AppSpacing.md),

                  // Judul "Fitur Utama"
                  const Text(
                    'Fitur Utama',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Daftar fitur utama (hanya Remote Control, Live ada di tab Live)
                  MainFeatureList(features: data.features),

                  // Ruang ekstra di bawah daftar
                  const SizedBox(height: AppSpacing.md),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header dashboard
// ---------------------------------------------------------------------------

class _DashboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Selamat Datang!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Pantau kondisi inkubator dan perkembangan telur hari ini',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Tombol notifikasi
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.tertiary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ],
    );
  }
}
