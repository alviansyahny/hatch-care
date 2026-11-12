/// Model domain monitoring inkubator (fitur Live).
library;

/// Sumber gambar tray inkubator.
class IncubatorImage {
  const IncubatorImage.network(this.networkUrl)
    : base64Data = null,
      isNetwork = true;

  const IncubatorImage.base64(this.base64Data)
    : networkUrl = null,
      isNetwork = false;

  const IncubatorImage.empty()
    : networkUrl = null,
      base64Data = null,
      isNetwork = false;

  /// URL absolut gambar (path relatif sudah digabung dengan base URL).
  final String? networkUrl;

  /// Data-URI / base64 gambar (didekode di widget, bukan di provider).
  final String? base64Data;

  final bool isNetwork;

  bool get isEmpty => networkUrl == null && base64Data == null;
}

/// Satu entri riwayat foto inkubator (1 jam terakhir).
class IncubatorHistoryEntry {
  const IncubatorHistoryEntry({
    this.capturedAt,
    this.temperature,
    this.humidity,
    this.lamp,
    this.motor,
    this.imageUrl,
  });

  final DateTime? capturedAt;
  final double? temperature;
  final double? humidity;
  final bool? lamp;
  final bool? motor;
  final String? imageUrl;
}

/// Snapshot kondisi inkubator terkini dari backend.
class IncubatorSnapshot {
  const IncubatorSnapshot({
    required this.online,
    this.statusLabel,
    required this.image,
    required this.totalEggs,
    required this.detectionConfidences,
    this.temperature,
    this.humidity,
    this.lamp,
    this.motor,
    this.rssi,
    this.lastCaptureAt,
    required this.history,
  });

  /// Snapshot kosong (belum ada data dari backend).
  const IncubatorSnapshot.empty()
    : online = false,
      statusLabel = null,
      image = const IncubatorImage.empty(),
      totalEggs = 0,
      detectionConfidences = const [],
      temperature = null,
      humidity = null,
      lamp = null,
      motor = null,
      rssi = null,
      lastCaptureAt = null,
      history = const [];

  /// Online menurut backend (server memperhitungkan interval capture).
  final bool online;

  /// Status versi backend: online / idle / no_data (null jika tidak ada).
  final String? statusLabel;

  /// Foto tray terkini (null / kosong saat belum ada).
  final IncubatorImage image;

  /// Jumlah telur hasil deteksi YOLOv8.
  final int totalEggs;

  /// Konfiden tiap deteksi (0.0–1.0).
  final List<double?> detectionConfidences;

  /// Suhu terkini dalam °C.
  final double? temperature;

  /// Kelembapan terkini dalam %RH.
  final double? humidity;

  /// Status lampu/pemanas; null jika sensor belum melapor.
  final bool? lamp;

  /// Status motor rotasi; null jika sensor belum melapor.
  final bool? motor;

  /// Kekuatan sinyal WiFi ESP32 (dBm).
  final int? rssi;

  /// Waktu tangkapan terakhir.
  final DateTime? lastCaptureAt;

  /// Riwayat tangkapan 1 jam terakhir (terbaru di depan).
  final List<IncubatorHistoryEntry> history;
}
