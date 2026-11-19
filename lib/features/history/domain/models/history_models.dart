/// Model data untuk fitur riwayat tangkapan kamera inkubator (menu History).
///
/// Sumber data: `GET /incubator/latest` (backend IoT) — field `history`
/// berisi daftar foto 1 jam terakhir beserta telemetri saat foto diambil.
/// Setiap entri membawa hasil deteksi YOLO miliknya sendiri (`detection`),
/// jadi analisis bounding box + keyakinan tetap tersimpan per foto.
library;

import 'package:hatch_care/features/live/domain/models/incubator_models.dart';

// ---------------------------------------------------------------------------
// Filter tampilan
// ---------------------------------------------------------------------------

/// Filter daftar tangkapan berdasarkan kondisi lampu saat foto diambil.
///
/// Foto gelap umumnya terjadi saat lampu inkubator mati, jadi filter ini
/// membantu memisahkan foto yang terang dan yang gelap.
enum CaptureFilter {
  /// Semua foto.
  semua,

  /// Hanya foto yang diambil saat lampu/pemanas menyala.
  lampuNyala,

  /// Hanya foto yang diambil saat lampu/pemanas mati.
  lampuMati;

  /// Label tampilan untuk chip filter.
  String get label {
    return switch (this) {
      CaptureFilter.semua => 'Semua',
      CaptureFilter.lampuNyala => 'Lampu nyala',
      CaptureFilter.lampuMati => 'Lampu mati',
    };
  }
}

// ---------------------------------------------------------------------------
// Record tangkapan
// ---------------------------------------------------------------------------

/// Satu tangkapan foto kamera inkubator beserta kondisi tray saat itu.
class CaptureRecord {
  const CaptureRecord({
    this.id,
    this.filename,
    required this.image,
    this.capturedAt,
    this.temperature,
    this.humidity,
    this.lamp,
    this.motor,
    this.sizeKb,
    this.eggCount,
    this.detectionStatus,
    this.detections = const [],
  });

  /// ID unik tangkapan dari backend (mis. "20261115_135019_xiu7").
  final String? id;

  /// Nama file foto di server (mis. "inc_20261115_135019_xiu7.jpg").
  final String? filename;

  /// Sumber gambar (URL absolut atau base64).
  final IncubatorImage image;

  /// Waktu foto diambil (sudah dikonversi ke waktu lokal).
  final DateTime? capturedAt;

  /// Suhu tray saat foto diambil (°C).
  final double? temperature;

  /// Kelembapan tray saat foto diambil (%RH).
  final double? humidity;

  /// Status lampu/pemanas saat foto diambil.
  final bool? lamp;

  /// Status motor rotasi saat foto diambil.
  final bool? motor;

  /// Ukuran file foto (KB) bila server melaporkannya.
  final int? sizeKb;

  /// Jumlah telur hasil deteksi YOLO. `null` = foto belum dianalisis.
  final int? eggCount;

  /// Status inferensi YOLO foto ini: `success`, `pending`, `failed`.
  final String? detectionStatus;

  /// Deteksi per telur (bounding box + keyakinan) foto ini.
  final List<EggDetection> detections;

  /// Konfiden tiap deteksi (0.0–1.0), hanya jika tersedia.
  List<double?> get detectionConfidences =>
      detections.map((detection) => detection.confidence).toList();

  /// `true` jika server sudah selesai menganalisis foto ini.
  bool get hasDetection => detectionStatus == 'success';

  /// `true` jika foto ini masih menunggu hasil YOLO.
  bool get detectionPending => detectionStatus == 'pending';

  /// `true` jika inferensi YOLO foto ini gagal.
  bool get detectionFailed => detectionStatus == 'failed';

  /// Jumlah telur retak pada foto ini.
  int get crackedEggCount =>
      detections.where((detection) => detection.isCracked).length;

  /// Jumlah telur utuh pada foto ini.
  int get intactEggCount =>
      detections.where((detection) => !detection.isCracked).length;

  /// Rata-rata konfiden deteksi (0–100), `null` jika tidak ada deteksi.
  int? get averageConfidencePercent {
    final valid = detectionConfidences.whereType<double>().toList();
    if (valid.isEmpty) return null;
    return ((valid.reduce((a, b) => a + b) / valid.length) * 100).round();
  }
}

// ---------------------------------------------------------------------------
// Data halaman
// ---------------------------------------------------------------------------

/// Data gabungan halaman History: daftar tangkapan + kondisi terkini.
class CaptureHistoryData {
  const CaptureHistoryData({
    required this.online,
    required this.records,
    this.temperature,
    this.humidity,
  });

  /// Snapshot kosong (belum ada data dari backend).
  const CaptureHistoryData.empty()
    : online = false,
      records = const [],
      temperature = null,
      humidity = null;

  /// Kamera online menurut backend.
  final bool online;

  /// Daftar tangkapan, terbaru di depan.
  final List<CaptureRecord> records;

  /// Suhu terkini (°C) dari snapshot terbaru.
  final double? temperature;

  /// Kelembapan terkini (%RH) dari snapshot terbaru.
  final double? humidity;
}
