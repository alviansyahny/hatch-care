import 'package:hatch_care/core/enums/egg_status.dart';

/// Model item candling telur pada baki (tray).
class EggCheckTrayItem {
  const EggCheckTrayItem({
    required this.eggNumber,
    required this.batchCode,
    this.status,
    this.confidencePercent,
    this.isLiveTarget = false,
  });

  /// Nomor urut telur (misal: 5 -> Egg #05).
  final int eggNumber;

  /// Kode batch (misal: B04-EGG-05).
  final String batchCode;

  /// Status hasil candling (null jika belum dicandling / Ready).
  final EggStatus? status;

  /// Persentase keyakinan deteksi (0-100, null jika Ready).
  final int? confidencePercent;

  /// Menandakan apakah telur ini adalah target candling yang sedang aktif.
  final bool isLiveTarget;

  /// Format nomor telur (contoh: "Egg #05").
  String get displayName => 'Egg #${eggNumber.toString().padLeft(2, '0')}';

  /// Label status tampilan.
  String get statusLabel => status?.label ?? 'Ready';
}

/// Model state utama untuk layar Egg Check.
class EggCheckData {
  const EggCheckData({
    required this.incubatorCode,
    required this.day,
    required this.isTorchOn,
    required this.lumensLevel,
    required this.lumensStatus,
    required this.batchTitle,
    required this.tipText,
    required this.recentItems,
  });

  /// Kode perangkat/posisi (contoh: "E01").
  final String incubatorCode;

  /// Hari inkubasi (contoh: 11 -> "Hari 11").
  final int day;

  /// Status lampu senter / candler LED torch aktif.
  final bool isTorchOn;

  /// Tingkat lumens visual (0.0 sampai 1.0).
  final double lumensLevel;

  /// Teks keterangan lumens (contoh: "Candle Lumens OK").
  final String lumensStatus;

  /// Label informasi batch (contoh: "Batch 4 (12 Eggs)").
  final String batchTitle;

  /// Pesan tips candling untuk panduan pengguna.
  final String tipText;

  /// Daftar telur pada baki candling terkini.
  final List<EggCheckTrayItem> recentItems;

  EggCheckData copyWith({
    String? incubatorCode,
    int? day,
    bool? isTorchOn,
    double? lumensLevel,
    String? lumensStatus,
    String? batchTitle,
    String? tipText,
    List<EggCheckTrayItem>? recentItems,
  }) {
    return EggCheckData(
      incubatorCode: incubatorCode ?? this.incubatorCode,
      day: day ?? this.day,
      isTorchOn: isTorchOn ?? this.isTorchOn,
      lumensLevel: lumensLevel ?? this.lumensLevel,
      lumensStatus: lumensStatus ?? this.lumensStatus,
      batchTitle: batchTitle ?? this.batchTitle,
      tipText: tipText ?? this.tipText,
      recentItems: recentItems ?? this.recentItems,
    );
  }
}
