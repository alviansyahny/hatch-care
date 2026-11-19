/// Model domain hasil integrasi backend IoT untuk fitur Egg Check.
///
/// Berbeda dengan `egg_check_models.dart` (data dummy desain awal),
/// model di sini mewakili data nyata dari backend candling AI.
library;

/// Status koneksi perangkat ESP32-CAM.
class EggDeviceStatus {
  const EggDeviceStatus({required this.online, this.rssi, this.lastSeenSec});

  final bool online;
  final int? rssi;
  final int? lastSeenSec;
}

/// Parameter pengambilan foto candling yang dikirim ke backend.
class CaptureParams {
  const CaptureParams({
    this.exposure = 500,
    this.gain = 0,
    this.quality = 6,
    this.settleMs = 250,
  });

  final int exposure;
  final int gain;
  final int quality;
  final int settleMs;

  Map<String, dynamic> toJson() => {
    'exposure': exposure,
    'gain': gain,
    'quality': quality,
    'settle_ms': settleMs,
  };
}

/// Satu tahapan hasil computer vision (citra base64).
class CandlingStage {
  const CandlingStage({required this.title, required this.imageBase64});

  /// Judul tahapan (mis. "Crop Telur").
  final String title;

  /// Data-URI / base64 murni gambar tahapan.
  final String imageBase64;
}

/// Hasil analisis lengkap satu job candling.
class EggCaptureDetail {
  const EggCaptureDetail({
    this.status,
    this.mainImageBase64,
    this.label,
    this.confidence,
    this.probabilities = const {},
    this.llmAnalysis,
    this.stages = const [],
  });

  /// Status job: pending / taken / done / failed.
  final String? status;

  /// Foto asli candling (data-URI base64).
  final String? mainImageBase64;

  /// Label prediksi (Fertil / Infertil / Mortal).
  final String? label;

  /// Keyakinan model (0.0–1.0).
  final double? confidence;

  /// Probabilitas per label (0.0–1.0).
  final Map<String, double> probabilities;

  /// Penjelasan LLM Vision (Bahasa Indonesia).
  final String? llmAnalysis;

  /// Tahapan computer vision yang tersedia.
  final List<CandlingStage> stages;

  bool get hasPrediction => label != null || stages.isNotEmpty;
}

/// Ringkasan satu riwayat tangkapan candling.
class EggCaptureSummary {
  const EggCaptureSummary({
    required this.id,
    this.mainImageBase64,
    this.label,
    this.confidence,
    this.capturedAt,
  });

  final int id;
  final String? mainImageBase64;
  final String? label;
  final double? confidence;
  final DateTime? capturedAt;
}
