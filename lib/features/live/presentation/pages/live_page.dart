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
import 'package:hatch_care/features/live/presentation/widgets/live_detection_image.dart';

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
    final isRecapturing = ref.watch(incubatorRecaptureProvider);
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
        foregroundColor: AppColors.neutral,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Live',
          style: TextStyle(
            color: AppColors.neutral,
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
                      color: AppColors.neutral,
                    ),
                  )
                : const Icon(Icons.refresh, color: AppColors.neutral),
            onPressed: asyncSnapshot.isRefreshing
                ? null
                : () => ref.read(incubatorLatestProvider.notifier).refresh(),
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
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
                onZoomIn: () => _showFullscreenZoom(
                  context,
                  snapshot.image,
                  snapshot.detections,
                ),
                image: snapshot.image,
                detections: snapshot.detections,
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
                  onPressed: isRecapturing
                      ? null
                      : () => _handleRecapture(context, ref),
                  icon: isRecapturing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.neutral,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.tertiary,
                          size: 20,
                        ),
                  label: Text(
                    isRecapturing
                        ? 'Memeriksa Ulang Telur...'
                        : 'Periksa Ulang Telur',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.7,
                    ),
                    disabledForegroundColor: Colors.white,
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
    if (snapshot.detectionStatus == 'success') {
      buffer.write(' YOLO mendeteksi ${snapshot.totalEggs} butir telur');
      final details = <String>[
        if (snapshot.intactEggCount > 0) '${snapshot.intactEggCount} utuh',
        if (snapshot.crackedEggCount > 0) '${snapshot.crackedEggCount} retak',
        if (snapshot.averageConfidencePercent != null)
          'keyakinan rerata ${snapshot.averageConfidencePercent}%',
      ];
      if (details.isNotEmpty) {
        buffer.write(' (${details.join(', ')})');
      }
      buffer.write(
        snapshot.detections.isEmpty
            ? '.'
            : '. Kotak deteksi dan skor keyakinan tiap telur ditampilkan '
                  'langsung pada foto.',
      );
    } else if (snapshot.detectionStatus == 'pending') {
      buffer.write(' Deteksi YOLO sedang diproses untuk foto terbaru.');
    } else if (snapshot.detectionStatus == 'failed') {
      buffer.write(
        ' Deteksi YOLO gagal pada foto terbaru; foto asli tetap ditampilkan.',
      );
    } else {
      buffer.write(' Terakhir terdeteksi ${snapshot.totalEggs} butir telur.');
    }
    if (!snapshot.online) {
      buffer.write(
        ' Inkubator sedang offline — data yang tampil kemungkinan '
        'sudah tidak terbaru.',
      );
    }
    return buffer.toString();
  }

  String _detectionCaption(List<EggDetection> detections) {
    if (detections.isEmpty) {
      return 'YOLO: tidak ada telur terdeteksi';
    }
    final intact = detections.where((d) => !d.isCracked).length;
    final cracked = detections.where((d) => d.isCracked).length;
    final confidences = detections
        .map((d) => d.confidence)
        .whereType<double>()
        .toList(growable: false);
    final average = confidences.isEmpty
        ? null
        : ((confidences.reduce((a, b) => a + b) / confidences.length) * 100)
              .round();
    final parts = <String>[
      'YOLO: ${detections.length} telur',
      '$intact utuh',
      if (cracked > 0) '$cracked retak',
      if (average != null) 'keyakinan rata-rata $average%',
    ];
    return parts.join(' • ');
  }

  Future<void> _handleRecapture(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final received = await ref
          .read(incubatorLatestProvider.notifier)
          .recapture();
      if (!context.mounted) return;
      final snapshot = ref.read(incubatorLatestProvider).value;
      final message = switch (snapshot?.detectionStatus) {
        _ when !received =>
          'Perintah sudah dikirim, tetapi foto baru belum masuk. Coba lagi.',
        'success' =>
          'Foto baru diterima: ${snapshot!.totalEggs} telur terdeteksi ulang.',
        'pending' => 'Foto baru diterima. Analisis YOLO masih berjalan.',
        'failed' => 'Foto baru diterima, tetapi deteksi YOLO gagal. Coba lagi.',
        _ => 'Foto baru diterima.',
      };
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } on ApiException catch (error) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  void _showFullscreenZoom(
    BuildContext context,
    IncubatorImage image,
    List<EggDetection> detections,
  ) {
    if (image.isEmpty) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: LiveDetectionImage(
                  image: image,
                  detections: detections,
                  semanticLabel: 'Foto tray inkubator dengan bounding box YOLO',
                ),
              ),
            ),
            if (detections.isNotEmpty)
              Positioned(
                left: 20,
                right: 20,
                bottom: 36,
                child: Text(
                  _detectionCaption(detections),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
