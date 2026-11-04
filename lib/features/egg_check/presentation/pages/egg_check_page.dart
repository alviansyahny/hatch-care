import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/features/egg_check/presentation/providers/egg_check_provider.dart';
import 'package:hatch_care/features/egg_check/presentation/widgets/egg_candling_viewfinder.dart';
import 'package:hatch_care/features/egg_check/presentation/widgets/egg_check_controls.dart';
import 'package:hatch_care/features/egg_check/presentation/widgets/egg_check_tray_list.dart';

/// Layar fitur Pengecekan Telur (Egg Check).
///
/// Mengacu pada desain Figma: design/screens/12_egg_check.png.
class EggCheckPage extends ConsumerWidget {
  const EggCheckPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(eggCheckProvider);
    final notifier = ref.read(eggCheckProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.neutral,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Pengecekan Telur',
          style: TextStyle(
            color: AppColors.tertiary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Baris informasi kode inkubator dan hari
              _EggCheckTopBar(
                code: data.incubatorCode,
                day: data.day,
              ),

              const SizedBox(height: AppSpacing.md),

              // Viewfinder Candling Telur
              EggCandlingViewfinder(
                data: data,
                onToggleTorch: () => notifier.toggleTorch(),
              ),

              const SizedBox(height: AppSpacing.md),

              // Kontrol Shutter & Galeri
              EggCheckControls(
                onCapture: () {
                  notifier.captureCurrentEgg();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Foto telur berhasil dipindai!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                onOpenGallery: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pilih foto telur dari galeri'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Daftar Telur Terkini pada Rak / Tray
              EggCheckTrayList(
                batchTitle: data.batchTitle,
                items: data.recentItems,
                onSelectItem: (eggNumber) => notifier.selectTrayItem(eggNumber),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _EggCheckTopBar extends StatelessWidget {
  const _EggCheckTopBar({
    required this.code,
    required this.day,
  });

  final String code;
  final int day;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Ikon mikroskop + kode inkubator
        Expanded(
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEF7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.biotech,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  code,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Badge Hari Inkubasi
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2B2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'Hari $day',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A4400),
            ),
          ),
        ),
      ],
    );
  }
}
