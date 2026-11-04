import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/features/notification/domain/models/notification_item.dart';
import 'package:hatch_care/features/notification/presentation/widgets/notification_card.dart';

/// Halaman Notifikasi HATCH-CARE.
///
/// Menampilkan daftar peringatan dan informasi operasional inkubator.
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  static const List<NotificationItem> dummyNotifications = [
    NotificationItem(
      id: 'notif_1',
      title: 'Suhu Inkubator',
      message:
          'Suhu terdeteksi mencapai 38.8°C (batas atas 38.0°C). Sistem kipas otomatis diaktifkan untuk pendinginan.',
      time: '5 menit yang lalu',
      icon: Icons.device_thermostat,
      iconColor: Color(0xFFB45309),
      iconBgColor: Color(0xFFFEF3C7),
      borderColor: Color(0xFFFDE68A),
      actionLabel: 'Cek Inkubator',
      actionStyle: NotificationActionStyle.filled,
    ),
    NotificationItem(
      id: 'notif_2',
      title: 'Kelembapan Ruang Telur Menurun',
      category: 'Kelembapan',
      categorySubtitle: 'Ruang Telur A',
      message:
          'Kelembapan saat ini 48% RH (target ideal 55-60% RH). Pastikan baki penampung air terisi penuh.',
      time: '28 menit yang lalu',
      icon: Icons.water_drop_outlined,
      iconColor: AppColors.primary,
      iconBgColor: Color(0xFFE2EAF8),
      borderColor: Color(0xFFE2E8F0),
      actionLabel: 'Periksa Baki',
      actionStyle: NotificationActionStyle.outlined,
    ),
    NotificationItem(
      id: 'notif_3',
      title: 'Sistem',
      message:
          'Sinkronisasi sensor telemetri real-time berhasil dipulihkan secara normal.',
      time: 'Kemarin, 14:20',
      icon: Icons.sensors,
      iconColor: AppColors.primary,
      iconBgColor: Color(0xFFE8EEF7),
      borderColor: Color(0xFFE2E8F0),
      statusLabel: 'Selesai',
      actionStyle: NotificationActionStyle.statusOnly,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.tertiary,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: AppColors.tertiary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        itemCount: dummyNotifications.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          return NotificationCard(item: dummyNotifications[index]);
        },
      ),
    );
  }
}
