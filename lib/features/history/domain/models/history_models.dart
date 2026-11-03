/// Model data untuk fitur riwayat candling HATCH-CARE.
///
/// Semua model bersifat immutable (field [final], konstruktor [const])
/// agar mudah diganti dengan data asli dari repository di tahap backend.
library;

// ---------------------------------------------------------------------------
// Status telur
// ---------------------------------------------------------------------------

/// Status telur hasil proses candling.
///
/// Label tampilan diambil dari desain (design/screens/13_history.png).
/// Gunakan [label] untuk mendapatkan teks sesuai Figma.
enum EggStatus {
  fertil,
  infertil,
  mortalitas;

  /// Label tampilan yang sesuai dengan desain Figma.
  String get label {
    return switch (this) {
      EggStatus.fertil => 'Fertile',
      EggStatus.infertil => 'Infertile',
      EggStatus.mortalitas => 'Mortalitas',
    };
  }
}

// ---------------------------------------------------------------------------
// Record riwayat candling
// ---------------------------------------------------------------------------

/// Satu baris riwayat hasil candling telur.
///
/// Field [dateTime] bertipe [DateTime]; format tampilan ("18 Mei, 14:38")
/// dihasilkan lewat [formatTanggalSingkat] di `lib/core/utils/date_formatter.dart`.
class CandlingRecord {
  const CandlingRecord({
    required this.eggNumber,
    required this.day,
    required this.status,
    required this.batchCode,
    required this.dateTime,
    required this.confidencePercent,
  });

  /// Nomor telur (mis. 7 → ditampilkan "Egg #07").
  final int eggNumber;

  /// Hari penetasan saat candling dilakukan (mis. 11 → "Hari 11").
  final int day;

  /// Status telur hasil candling.
  final EggStatus status;

  /// Kode batch telur (mis. "B04-EGG-07").
  final String batchCode;

  /// Waktu candling dilakukan.
  final DateTime dateTime;

  /// Persentase keyakinan AI (0–100).
  final int confidencePercent;
}
