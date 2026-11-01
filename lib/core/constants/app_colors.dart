import 'package:flutter/material.dart';

/// Palet warna HATCH-CARE.
///
/// Diambil dari design/colors.md — jangan hardcode warna di widget,
/// selalu gunakan konstanta ini.
abstract final class AppColors {
  /// Biru tua — warna utama, teks heading, logo.
  static const Color primary = Color(0xFF023266);

  /// Biru muda — aksen sekunder, garis dashed.
  static const Color secondary = Color(0xFF8AA5D0);

  /// Kuning — background splash, highlight.
  static const Color tertiary = Color(0xFFFBDF65);

  /// Putih — background umum.
  static const Color neutral = Color(0xFFFDFDFD);
}

