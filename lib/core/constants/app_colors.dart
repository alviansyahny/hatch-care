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

  // --- Badge status telur (History) ---

  /// Background badge status Fertile.
  /// Diambil secara visual dari design/screens/13_history.png.
  static const Color badgeFertileBg = Color(0xFFE8EEF7);

  /// Titik kuning badge/filter status Infertile.
  /// Diambil secara visual dari design/screens/13_history.png.
  static const Color badgeInfertileDot = Color(0xFFD4A843);

  /// Background badge status Infertile.
  /// Diambil secara visual dari design/screens/13_history.png.
  static const Color badgeInfertileBg = Color(0xFFEEF0F4);

  /// Teks badge status Mortalitas (merah).
  /// Diambil secara visual dari design/screens/13_history.png.
  static const Color badgeMortalitasText = Color(0xFF9B2D2D);

  /// Background badge status Mortalitas (pink muda).
  /// Diambil secara visual dari design/screens/13_history.png.
  static const Color badgeMortalitasBg = Color(0xFFFDEAEA);

  /// Titik merah badge/filter status Mortalitas.
  /// Diambil secara visual dari design/screens/13_history.png.
  static const Color badgeMortalitasDot = Color(0xFFD94444);

  // --- Layar Egg Check & Live (backend IoT) ---
  // Diambil dari tampilan versi tim backend yang sudah tergabung.

  /// Navy gelap — AppBar Egg Check, tombol utama, teks heading.
  static const Color deepNavy = Color(0xFF0D3158);

  /// Biru aksen — slider, keyakinan model, border aktif.
  static const Color blueAccent = Color(0xFF315F9B);

  /// Latar halaman Egg Check (abu kebiruan sangat muda).
  static const Color pageBackground = Color(0xFFF7F9FC);

  /// Latar kartu informasi di halaman Live.
  static const Color infoCardBackground = Color(0xFFF6F8FB);

  /// Border kartu abu kebiruan (slate).
  static const Color slateBorder = Color(0xFFE2E8F0);

  /// Teks sekunder abu kebiruan (slate).
  static const Color textSlate = Color(0xFF64748B);

  /// Teks paling redup (slate muda).
  static const Color textSlateLight = Color(0xFF94A3B8);

  /// Teks label slider/abu gelap.
  static const Color textSlateDark = Color(0xFF475569);

  /// Teks judul section abu kebiruan gelap.
  static const Color sectionLabel = Color(0xFF334155);

  /// Titik status perangkat online.
  static const Color statusOnline = Color(0xFF10B981);

  /// Teks status perangkat online.
  static const Color statusOnlineText = Color(0xFF047857);

  /// Titik status perangkat offline.
  static const Color statusOffline = Color(0xFFEF4444);

  /// Teks status perangkat offline.
  static const Color statusOfflineText = Color(0xFFB91C1C);

  /// Badge label hasil Fertil.
  static const Color badgeFertil = Color(0xFF2CA02C);

  /// Badge label hasil Infertil.
  static const Color badgeInfertil = Color(0xFF1F77B4);

  /// Badge label hasil Mortal.
  static const Color badgeMortal = Color(0xFFD62728);

  /// Latar gelap area citra candling.
  static const Color candlingDark = Color(0xFF0B132B);

  /// Latar gelap thumbnail rusak/tidak tersedia.
  static const Color candlingDarkDeep = Color(0xFF0F172A);

  /// Border abu terang di sekeliling area citra.
  static const Color candlingFrame = Color(0xFFCBD5E1);

  /// Latar kotak "Analisis Pakar AI (LLM)".
  static const Color expertBoxBackground = Color(0xFFF0FDF4);

  /// Border kotak "Analisis Pakar AI (LLM)".
  static const Color expertBoxBorder = Color(0xFFBBF7D0);

  /// Ikon/judul kotak "Analisis Pakar AI (LLM)".
  static const Color expertGreen = Color(0xFF15803D);

  /// Teks isi analisis LLM.
  static const Color expertText = Color(0xFF1F2937);

  /// Latar paling gelap area feed kamera Live.
  static const Color feedDark = Color(0xFF070B12);

  /// Warna atas gradien feed kamera Live.
  static const Color feedDarkSoft = Color(0xFF151C28);
}
