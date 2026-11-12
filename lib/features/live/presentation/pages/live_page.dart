import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/core/network/api_exception.dart';
import 'package:hatch_care/core/utils/date_formatter.dart';
import 'package:hatch_care/features/live/domain/models/incubator_models.dart';
import 'package:hatch_care/features/live/presentation/providers/incubator_provider.dart';
import 'package:hatch_care/features/live/presentation/widgets/live_candling_display.dart';

/// Halaman Live Monitoring inkubator — data nyata dari backend IoT
/// (polling 20 detik, otomatis berhenti saat background/layar ditutup).
class LivePage extends ConsumerWidget {
  const LivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSnapshot = ref.watch(incubatorLatestProvider);
    final snapshot = asyncSnapshot.value ?? const IncubatorSnapshot.empty();
    final isFirstLoading = asyncSnapshot.isLoading && !asyncSnapshot.hasValue;
    final hasError = asyncSnapshot.hasError && !asyncSnapshot.hasValue;
    final errorMessage = asyncSnapshot.error is ApiException
        ? (asyncSnapshot.error! as ApiException).message
        : 'Tidak dapat terhubung ke server inkubator.';

    final timestampText = snapshot.lastCaptureAt != null
        ? formatTanggalWaktuWib(snapshot.lastCaptureAt!)
        : 'Menunggu tangkapan kamera...';

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
        actions: [
          IconButton(
            tooltip: 'Segarkan',
            icon: asyncSnapshot.isRefreshing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.tertiary,
                    ),
                  )
                : const Icon(Icons.refresh, color: AppColors.tertiary),
            onPressed: asyncSnapshot.isRefreshing
                ? null
                : () => ref.read(incubatorLatestProvider.notifier).refresh(),
          ),
        ],
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
                timestampText,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Tampilan Feed Kamera Live
              LiveCandlingDisplay(
                onZoomIn: () => _showFullscreenZoom(context, snapshot.image),
                image: snapshot.image,
                isLoading: isFirstLoading,
                hasError: hasError,
                isOnline: snapshot.online,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Status Kamera (besar)
              Center(
                child: Text(
                  snapshot.online ? 'LIVE' : 'OFFLINE',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Card Informasi Monitoring
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.infoCardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.biotech, size: 20, color: AppColors.primary),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Monitoring Tray Inkubator',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
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
                      _buildMonitoringDescription(
                        hasError,
                        errorMessage,
                        snapshot,
                      ),
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

  String _buildMonitoringDescription(
    bool hasError,
    String errorMessage,
    IncubatorSnapshot snapshot,
  ) {
    if (hasError) {
      return '$errorMessage Periksa koneksi internet Anda lalu coba lagi.';
    }
    final buffer = StringBuffer(
      'Kamera overhead ESP32-CAM mengambil foto tray inkubator secara '
      'berkala dan memperbarui data otomatis tiap 20 detik.',
    );
    buffer.write(' Terakhir terdeteksi ${snapshot.totalEggs} butir telur.');
    if (!snapshot.online) {
      buffer.write(
        ' Inkubator sedang offline — data yang tampil kemungkinan '
        'sudah tidak terbaru.',
      );
    }
    return buffer.toString();
  }

  void _showFullscreenZoom(BuildContext context, IncubatorImage image) {
    if (image.isEmpty) return;
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
                child: image.isNetwork
                    ? Image.network(image.networkUrl!)
                    : Image.memory(
                        base64Decode(image.base64Data!),
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
