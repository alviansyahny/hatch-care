import 'package:hatch_care/core/enums/egg_status.dart';

/// Model data untuk pemantauan live candling telur.
class LiveMonitoringData {
  const LiveMonitoringData({
    required this.timestampText,
    required this.status,
    required this.morphologyTitle,
    required this.morphologyDescription,
    this.day = 11,
  });

  /// Teks waktu monitoring (contoh: "Hari ini, 14:15:22 WIB").
  final String timestampText;

  /// Status hasil analisis live (Fertil, Infertil, Mortalitas).
  final EggStatus status;

  /// Judul deskripsi morfologi (contoh: "Deskripsi Morfologi Vaskular").
  final String morphologyTitle;

  /// Penjelasan detail morfologi biologis telur.
  final String morphologyDescription;

  /// Hari ke inkubasi.
  final int day;
}
