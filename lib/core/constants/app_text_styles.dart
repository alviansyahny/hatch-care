import 'package:flutter/material.dart';

/// Gaya teks khusus di luar theme standar.
abstract final class AppTextStyles {
  /// Judul brand "HATCH-CARE" — font Krona One.
  /// Gunakan `.copyWith(...)` untuk mengatur ukuran dan warna.
  static const TextStyle brandTitle = TextStyle(fontFamily: 'KronaOne');
}
