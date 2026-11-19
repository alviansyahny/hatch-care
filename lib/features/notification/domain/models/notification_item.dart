import 'package:flutter/material.dart';

/// Gaya tombol / aksi pada kartu notifikasi.
enum NotificationActionStyle {
  /// Tombol terisi (kuning, rounded pill).
  filled,

  /// Tombol outline (border biru/abu-abu).
  outlined,

  /// Hanya label status (misal: "✓ Selesai").
  statusOnly,
}

/// Model data item notifikasi HATCH-CARE.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.borderColor,
    this.category,
    this.categorySubtitle,
    this.actionLabel,
    this.actionStyle = NotificationActionStyle.statusOnly,
    this.statusLabel,
  });

  final String id;
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color? borderColor;
  final String? category;
  final String? categorySubtitle;
  final String? actionLabel;
  final NotificationActionStyle actionStyle;
  final String? statusLabel;
}
