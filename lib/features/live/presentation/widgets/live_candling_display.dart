import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/features/live/domain/models/incubator_models.dart';

/// Komponen visual tampilan live candling telur.
///
/// Menampilkan foto tray inkubator dari backend (URL atau base64) dengan
/// keadaan loading, offline, error, dan tombol "Perbesar Foto".
class LiveCandlingDisplay extends StatelessWidget {
  const LiveCandlingDisplay({
    super.key,
    required this.onZoomIn,
    this.image = const IncubatorImage.empty(),
    this.isLoading = false,
    this.hasError = false,
    this.isOnline = false,
  });

  final VoidCallback onZoomIn;

  /// Sumber gambar tray dari backend.
  final IncubatorImage image;

  /// Saat fetch pertama masih berjalan.
  final bool isLoading;

  /// Saat fetch gagal (server/error jaringan).
  final bool hasError;

  /// Status kamera ESP32-CAM.
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: AppColors.feedDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background gelap ruang candling
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.9,
                  colors: [AppColors.feedDarkSoft, AppColors.feedDark],
                ),
              ),
            ),
          ),

          // Gambar tray / keadaan placeholder
          Positioned.fill(child: _buildContent()),

          // Tombol "Perbesar Foto" di pojok kanan bawah
          Positioned(
            right: 14,
            bottom: 14,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: image.isEmpty ? null : onZoomIn,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search,
                        size: 15,
                        color: image.isEmpty
                            ? AppColors.textMuted
                            : AppColors.primaryDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Perbesar Foto',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: image.isEmpty
                              ? AppColors.textMuted
                              : AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading && image.isEmpty) {
      return Container(
        width: double.infinity,
        height: 280,
        color: AppColors.feedDark,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.tertiary,
              ),
              SizedBox(height: 10),
              Text(
                'Menghubungkan ke inkubator...',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    if (!image.isEmpty) {
      return SizedBox(
        width: double.infinity,
        height: 280,
        child: image.isNetwork
            ? Image.network(
                image.networkUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(),
              )
            : Image.memory(
                base64Decode(image.base64Data!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(),
              ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    final title = hasError
        ? 'Gagal memuat data dari server'
        : isOnline
        ? 'Menunggu Tangkapan Citra'
        : 'Inkubator Offline / Kamera Terputus';
    final subtitle = hasError
        ? 'Periksa koneksi internet lalu coba lagi'
        : isOnline
        ? 'Kamera ESP32-CAM sedang memproses frame'
        : 'ESP32 belum mengirim citra tray ke server';

    return Container(
      width: double.infinity,
      height: 280,
      color: AppColors.feedDark,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasError
                  ? Icons.cloud_off_outlined
                  : isOnline
                  ? Icons.camera_alt_outlined
                  : Icons.videocam_off_outlined,
              size: 42,
              color: Colors.white.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
