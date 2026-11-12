import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';

/// Baris kontrol utama aksi candling:
/// - Tombol Gallery di sisi kiri
/// - Tombol Shutter besar di tengah untuk scan / candling
/// - Elemen penyeimbang di sisi kanan
class EggCheckControls extends StatelessWidget {
  const EggCheckControls({
    super.key,
    required this.onCapture,
    this.onOpenGallery,
  });

  final VoidCallback onCapture;
  final VoidCallback? onOpenGallery;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tombol Gallery
          InkWell(
            onTap: onOpenGallery,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.primary,
                    size: 26,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Gallery',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tombol Shutter Utama
          GestureDetector(
            onTap: onCapture,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(color: AppColors.primary, width: 3.5),
              ),
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tertiary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.camera, color: AppColors.primary, size: 28),
                ),
              ),
            ),
          ),

          // Placeholder penyeimbang agar tombol shutter tetap presisi di tengah
          const SizedBox(width: 52, height: 52),
        ],
      ),
    );
  }
}
