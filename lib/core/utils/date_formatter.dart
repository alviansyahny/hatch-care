/// Utilitas format tanggal untuk tampilan bahasa Indonesia.
///
/// Digunakan untuk memformat [DateTime] menjadi string ringkas
/// seperti "18 Mei, 14:38" tanpa package tambahan.
library;

/// Daftar nama bulan pendek dalam bahasa Indonesia.
const _bulanPendek = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// Memformat [dateTime] menjadi string "d Mon, HH:mm" dalam bahasa Indonesia.
///
/// Contoh: `DateTime(2025, 5, 18, 14, 38)` → `"18 Mei, 14:38"`.
String formatTanggalSingkat(DateTime dateTime) {
  final hari = dateTime.day;
  final bulan = _bulanPendek[dateTime.month - 1];
  final jam = dateTime.hour.toString().padLeft(2, '0');
  final menit = dateTime.minute.toString().padLeft(2, '0');
  return '$hari $bulan, $jam:$menit';
}
