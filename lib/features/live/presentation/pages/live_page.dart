import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/features/egg_check/presentation/widgets/egg_candling_custom_painter.dart';
import 'package:hatch_care/features/live/presentation/providers/live_provider.dart';
import 'package:hatch_care/features/live/presentation/widgets/live_candling_display.dart';

/// Halaman Live Monitoring Candling Telur.
///
/// Mengacu pada desain Figma: design/screens/11_live.png.
class LivePage extends ConsumerWidget {
  const LivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(liveMonitoringProvider);

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
          'Live',
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
              // Timestamp Header
              Text(
                data.timestampText,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Tampilan Feed Kamera Live
              LiveCandlingDisplay(
                onZoomIn: () => _showFullscreenZoom(context),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Status Analisis Besar
              Center(
                child: Text(
                  data.status.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Card Deskripsi Morfologi Vaskular
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.biotech,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            data.morphologyTitle,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      data.morphologyDescription,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textBody,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Tombol Periksa Ulang Telur
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.go('/home/egg-check');
                  },
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.tertiary,
                    size: 20,
                  ),
                  label: const Text(
                    'Periksa Ulang Telur',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullscreenZoom(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: const SizedBox(
                  width: 320,
                  height: 400,
                  child: CustomPaint(
                    painter: EggCandlingPainter(isTorchOn: true),
                  ),
                ),
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
