import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/features/notification/domain/models/notification_item.dart';

/// Kartu item notifikasi sesuai desain HATCH-CARE.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.item,
  });

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final borderColor = item.borderColor ?? const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Judul / Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Container
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: item.iconBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  item.icon,
                  color: item.iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Title and categories
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.category != null) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2EAF8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.category!,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (item.categorySubtitle != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              item.categorySubtitle!,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: item.category != null ? 14 : 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Pesan notifikasi
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              item.message,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSubtle,
                height: 1.45,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),
          const Divider(
            height: 1,
            thickness: 0.8,
            color: Color(0xFFF1F5F9),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Footer: Waktu & Aksi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Waktu
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.time,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),

              // Tombol / Status
              _buildAction(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAction(BuildContext context) {
    switch (item.actionStyle) {
      case NotificationActionStyle.filled:
        return SizedBox(
          height: 32,
          child: ElevatedButton(
            onPressed: () {
              // Navigasi ke Egg Check atau Live atau Dashboard
              context.push('/home/live');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tertiary,
              foregroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              item.actionLabel ?? 'Lihat',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );

      case NotificationActionStyle.outlined:
        return SizedBox(
          height: 32,
          child: OutlinedButton(
            onPressed: () {
              context.push('/home/egg-check');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: Color(0xFF8AA5D0), width: 1.2),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              item.actionLabel ?? 'Periksa',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );

      case NotificationActionStyle.statusOnly:
        return Row(
          children: [
            const Icon(
              Icons.check,
              size: 14,
              color: Color(0xFF60A5FA),
            ),
            const SizedBox(width: 4),
            Text(
              item.statusLabel ?? 'Selesai',
              style: const TextStyle(
                color: Color(0xFF60A5FA),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
    }
  }
}
