/// DTO (Data Transfer Object) mentah dari backend IoT untuk Egg Check.
///
/// Semua field parsing tahan terhadap null dan field yang hilang.
/// Konversi ke model domain dilakukan di lapisan repository.
library;

int? _asInt(Object? value) => value is num ? value.toInt() : null;

double? _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

Map<String, dynamic>? _asMap(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;

String? _asString(Object? value) => value is String ? value : null;

/// Isi response `GET /egg/status` — parsing tahan null/field hilang.
class EggDeviceStatusDto {
  const EggDeviceStatusDto({required this.online, this.rssi, this.lastSeenSec});

  final bool online;
  final int? rssi;
  final int? lastSeenSec;

  factory EggDeviceStatusDto.fromJson(Object? json) {
    if (json is! Map) {
      return const EggDeviceStatusDto(online: false);
    }
    return EggDeviceStatusDto(
      online: json['online'] == true,
      rssi: _asInt(json['rssi']),
      lastSeenSec: _asInt(json['last_seen_sec']),
    );
  }
}

/// Isi response `GET /egg/job/{id}` dan `POST /egg/capture`.
class EggJobDto {
  const EggJobDto({
    this.status,
    this.url,
    this.predictionLabel,
    this.confidence,
    this.probabilitas,
    this.visualisasi,
    this.llmAnalysis,
  });

  /// Status job: pending / taken / done / failed (null jika belum ada).
  final String? status;

  /// Foto utama: data-URI base64 (atau null saat job belum selesai).
  final String? url;

  final String? predictionLabel;
  final double? confidence;

  /// Breakdown probabilitas: fertil / infertil / mortal (0.0–1.0).
  final Map<String, dynamic>? probabilitas;

  /// Tahapan computer vision: citra_crop, citra_biner_roi, dst (base64).
  final Map<String, dynamic>? visualisasi;

  final String? llmAnalysis;

  factory EggJobDto.fromJson(Object? json) {
    if (json is! Map) return const EggJobDto();
    final pred = json['prediction_result'];
    final predMap = pred is Map ? pred : const {};
    return EggJobDto(
      status: _asString(json['status']),
      url: _asString(json['url']),
      predictionLabel:
          _asString(json['prediction_label']) ?? _asString(predMap['label']),
      confidence:
          _asDouble(json['confidence']) ?? _asDouble(predMap['keyakinan']),
      probabilitas: _asMap(predMap['probabilitas']),
      visualisasi: _asMap(predMap['visualisasi']),
      llmAnalysis: _asString(json['llm_analysis']),
    );
  }
}

/// Satu item pada response `GET /egg/history`.
class EggHistoryItemDto {
  const EggHistoryItemDto({
    required this.id,
    this.url,
    this.predictionLabel,
    this.confidence,
    this.at,
  });

  /// ID job untuk memuat detail; null jika id tidak valid (item dilewati).
  final int? id;
  final String? url;
  final String? predictionLabel;
  final double? confidence;
  final String? at;

  factory EggHistoryItemDto.fromJson(Object? json) {
    if (json is! Map) return const EggHistoryItemDto(id: null);
    return EggHistoryItemDto(
      id: _asInt(json['id']),
      url: _asString(json['url']),
      predictionLabel: _asString(json['prediction_label']),
      confidence: _asDouble(json['confidence']),
      at: _asString(json['at']),
    );
  }
}
