import 'package:flutter/material.dart';

/// Palet warna HATCH-CARE.
///
/// Diambil dari design/colors.md — jangan hardcode warna di widget,
/// selalu gunakan konstanta ini.
abstract final class AppColors {
  // --- Brand ---

  /// Biru tua — warna utama, teks heading, logo.
  static const Color primary = Color(0xFF023266);

  /// Biru muda — aksen sekunder, garis dashed.
  static const Color secondary = Color(0xFF8AA5D0);

  /// Kuning — background splash, highlight, tombol utama.
  static const Color tertiary = Color(0xFFFBDF65);

  /// Putih — background umum.
  static const Color neutral = Color(0xFFFDFDFD);

  // --- Teks ---

  /// Teks body / paragraf.
  static const Color textBody = Color(0xFF424242);

  /// Teks lebih halus (link sekunder, keterangan).
  static const Color textSubtle = Color(0xFF555555);

  /// Teks abu sedang (deskripsi muted).
  static const Color textMuted = Color(0xFF999999);

  /// Teks hint pada input field.
  static const Color textHint = Color(0xFF888888);

  // --- UI ---

  /// Ikon aksen (biru keabu-abuan).
  static const Color iconAccent = Color(0xFF496A9A);

  /// Background field input.
  static const Color fieldFill = Color(0xFFF2F2F2);

  /// Border tipis (card, outline button, divider).
  static const Color borderLight = Color(0xFFE0E0E0);

  /// Biru sangat tua — aksen nomor S&K.
  static const Color primaryDark = Color(0xFF0B1B3A);

  // --- Status ---

  /// Titik hijau "Terhubung" pada kartu status inkubator.
  /// Diambil secara visual dari design/screens/09_dashboard_1.png.
  static const Color statusConnected = Color(0xFF52C472);

  /// Teks badge sukses ("Stabil", "Ideal").
  /// Diambil secara visual dari design/screens/09_dashboard_1.png.
  static const Color badgeSuccessText = Color(0xFF1B6F40);

  /// Latar belakang badge sukses ("Stabil", "Ideal").
  /// Diambil secara visual dari design/screens/09_dashboard_1.png.
  static const Color badgeSuccessBg = Color(0xFFE8F7EE);
}
