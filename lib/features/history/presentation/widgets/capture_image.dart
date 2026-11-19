import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/features/live/domain/models/incubator_models.dart';

/// Widget gambar tangkapan kamera inkubator yang menangani ketiga sumber
/// data: URL jaringan, data-URI base64, dan kondisi kosong.
///
/// Error muat gambar dan kondisi kosong dirender sebagai placeholder gelap —
/// foto tray memang berlatar gelap, jadi gagal muat tidak "putih pucat".
class CaptureImage extends StatelessWidget {
  const CaptureImage({
    super.key,
    required this.image,
    this.fit = BoxFit.cover,
  });

  final IncubatorImage image;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty) return const _DarkPlaceholder();
    if (image.isNetwork) {
      return Image.network(
        image.networkUrl!,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const _DarkPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const ColoredBox(
            color: AppColors.candlingDarkDeep,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.tertiary,
                ),
              ),
            ),
          );
        },
      );
    }
    return Image.memory(
      base64Decode(image.base64Data!),
      fit: fit,
      errorBuilder: (context, error, stackTrace) => const _DarkPlaceholder(),
    );
  }
}

class _DarkPlaceholder extends StatelessWidget {
  const _DarkPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.candlingDarkDeep,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.textSlateLight,
          size: 28,
        ),
      ),
    );
  }
}
