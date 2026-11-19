/// Status telur hasil proses candling.
///
/// Label tampilan diambil dari desain (design/screens/13_history.png).
/// Gunakan [label] untuk mendapatkan teks sesuai desain.
///
/// Catatan: "Ready" bukan hasil candling sehingga tidak termasuk di sini.
/// Gunakan `EggStatus?` dengan `null` = Ready jika diperlukan.
enum EggStatus {
  fertil,
  infertil,
  mortalitas;

  /// Label tampilan yang sesuai dengan desain.
  String get label {
    return switch (this) {
      EggStatus.fertil => 'Fertile',
      EggStatus.infertil => 'Infertile',
      EggStatus.mortalitas => 'Mortalitas',
    };
  }
}
