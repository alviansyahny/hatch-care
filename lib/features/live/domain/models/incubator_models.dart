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
    this.id,
    this.capturedAt,
    this.temperature,
    this.humidity,
    this.lamp,
    this.motor,
    this.imageUrl,
    this.sizeKb,
    this.detectionStatus,
    this.totalEggs,
    this.detections = const [],
  });

  /// ID foto dari server, mis. `20261118_225721_l2wt`.
  final String? id;
  final DateTime? capturedAt;
  final double? temperature;
  final double? humidity;
  final bool? lamp;
  final bool? motor;
  final String? imageUrl;

  /// Ukuran file foto (KB) bila server melaporkannya.
  final int? sizeKb;

  /// Status inferensi YOLO foto ini: `success`, `pending`, `failed`.
  final String? detectionStatus;

  /// Jumlah telur hasil deteksi YOLO foto ini.
  final int? totalEggs;

  /// Deteksi per telur (bounding box + keyakinan) foto ini.
  final List<EggDetection> detections;

  /// `true` bila server sudah selesai menganalisis foto ini.
  bool get detectionSucceeded => detectionStatus == 'success';

  /// Jumlah telur retak pada foto ini.
  int get crackedEggCount =>
      detections.where((detection) => detection.isCracked).length;

  /// Jumlah telur utuh pada foto ini.
  int get intactEggCount =>
      detections.where((detection) => !detection.isCracked).length;
}

/// Satu telur yang terdeteksi YOLO pada foto tray.
class EggDetection {
  const EggDetection({
    this.id,
    this.label = 'telur',
    this.confidence,
    this.x = 0,
    this.y = 0,
    this.width = 0,
    this.height = 0,
  });

  /// Nomor urut deteksi dari server (1..N).
  final int? id;

  /// Kelas hasil model, mis. `utuh` atau `retak`.
  final String label;

  /// Tingkat keyakinan model (0.0–1.0); null jika server tidak mengirim.
  final double? confidence;

  /// Koordinat bounding box dalam piksel citra asli.
  final double x;
  final double y;
  final double width;
  final double height;

  /// `true` jika model mengklasifikasikan telur sebagai retak.
  bool get isCracked => label.toLowerCase() == 'retak';

  /// `true` jika koordinat box valid untuk digambar.
  bool get hasBox => width > 0 && height > 0;

  /// Keyakinan model dalam persen (0–100); null bila tidak dikirim server.
  int? get confidencePercent =>
      confidence == null ? null : (confidence! * 100).round();

  /// Label ringkas untuk badge di atas bounding box, mis. `#1 retak 54.2%`.
  String get displayLabel {
    final parts = <String>[
      if (id != null) '#$id',
      label,
      if (confidence != null) '${(confidence! * 100).toStringAsFixed(1)}%',
    ];
    return parts.join(' ');
  }
}

/// Snapshot kondisi inkubator terkini dari backend.
class IncubatorSnapshot {
  const IncubatorSnapshot({
    required this.online,
    this.statusLabel,
    required this.image,
    required this.totalEggs,
    required this.detections,
    this.detectionStatus,
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
      detections = const [],
      detectionStatus = null,
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

  /// Jumlah telur hasil deteksi YOLO.
  final int totalEggs;

  /// Daftar telur terdeteksi beserta bounding box-nya.
  final List<EggDetection> detections;

  /// Status inferensi YOLO untuk foto terbaru: `success`, `pending`, `failed`.
  final String? detectionStatus;

  /// Konfiden tiap deteksi (0.0–1.0) untuk kompatibilitas halaman History.
  List<double?> get detectionConfidences =>
      detections.map((detection) => detection.confidence).toList();

  /// Jumlah telur retak pada deteksi terbaru.
  int get crackedEggCount =>
      detections.where((detection) => detection.isCracked).length;

  /// Jumlah telur utuh pada deteksi terbaru.
  int get intactEggCount =>
      detections.where((detection) => !detection.isCracked).length;

  /// Rata-rata keyakinan YOLO (0–100); null bila belum ada deteksi.
  int? get averageConfidencePercent {
    final valid = detections
        .map((detection) => detection.confidence)
        .whereType<double>()
        .toList(growable: false);
    if (valid.isEmpty) return null;
    return ((valid.reduce((a, b) => a + b) / valid.length) * 100).round();
  }

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
