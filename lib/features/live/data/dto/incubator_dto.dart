/// DTO mentah dari backend IoT untuk monitoring inkubator (fitur Live).
///
/// Parsing tahan null dan field hilang; konversi ke model domain dilakukan
/// di repository.
library;

/// Satu entri riwayat foto inkubator (dari `history` atau `/incubator/history`).
class IncubatorHistoryEntryDto {
  const IncubatorHistoryEntryDto({
    this.id,
    this.filename,
    this.url,
    this.timestamp,
    this.at,
    this.temperature,
    this.humidity,
    this.lamp,
    this.motor,
    this.sizeKb,
    this.detection,
  });

  /// ID foto dari server, mis. `20261118_225721_l2wt`.
  final String? id;
  final String? filename;
  final String? url;
  final int? timestamp;
  final String? at;
  final double? temperature;
  final double? humidity;
  final bool? lamp;
  final bool? motor;

  /// Ukuran file foto (KB) bila server melaporkannya.
  final int? sizeKb;

  /// Hasil inferensi YOLO untuk foto ini (null untuk data lama).
  final EggDetectionSummaryDto? detection;

  factory IncubatorHistoryEntryDto.fromJson(Object? json) {
    if (json is! Map) return const IncubatorHistoryEntryDto();
    return IncubatorHistoryEntryDto(
      id: _asId(json['id']),
      filename: json['filename'] is String ? json['filename'] as String : null,
      url: json['url'] is String ? json['url'] as String : null,
      timestamp: json['timestamp'] is num
          ? (json['timestamp'] as num).toInt()
          : null,
      at: json['at'] is String ? json['at'] as String : null,
      temperature: _asDouble(json['temperature']),
      humidity: _asDouble(json['humidity']),
      lamp: json['lamp'] is bool ? json['lamp'] as bool : null,
      motor: json['motor'] is bool ? json['motor'] as bool : null,
      sizeKb: json['size_kb'] is num ? (json['size_kb'] as num).toInt() : null,
      detection: EggDetectionSummaryDto.tryFromJson(json['detection']),
    );
  }

  static String? _asId(Object? value) {
    if (value is String && value.isNotEmpty) return value;
    if (value is num) return value.toString();
    return null;
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

/// Ringkasan inferensi YOLO untuk satu foto (`detection`).
class EggDetectionSummaryDto {
  const EggDetectionSummaryDto({
    this.status,
    this.totalEggs,
    this.detections = const [],
    this.photoId,
  });

  /// Status inferensi: `success`, `pending`, atau `failed`.
  final String? status;

  /// Jumlah telur hasil hitung server.
  final int? totalEggs;

  /// Deteksi per telur beserta bounding box dan keyakinan.
  final List<EggDetectionDto> detections;

  /// ID foto yang dianalisis (bila dikirim server).
  final String? photoId;

  bool get hasData =>
      status != null ||
      totalEggs != null ||
      detections.isNotEmpty ||
      photoId != null;

  factory EggDetectionSummaryDto.fromJson(Object? json) {
    if (json is! Map) return const EggDetectionSummaryDto();
    final detections = <EggDetectionDto>[];
    final rawDetections = json['detections'];
    if (rawDetections is List) {
      for (final item in rawDetections) {
        if (item is num) {
          detections.add(EggDetectionDto(confidence: item.toDouble()));
          continue;
        }
        final detection = EggDetectionDto.fromJson(item);
        if (detection.className != null ||
            detection.confidence != null ||
            detection.box != null) {
          detections.add(detection);
        }
      }
    }
    return EggDetectionSummaryDto(
      status: json['status'] is String ? json['status'] as String : null,
      totalEggs: json['total_eggs'] is num
          ? (json['total_eggs'] as num).toInt()
          : null,
      detections: detections,
      photoId: json['photo_id'] is String ? json['photo_id'] as String : null,
    );
  }

  /// Null jika objek `detection` tidak ada di response (data lama).
  static EggDetectionSummaryDto? tryFromJson(Object? json) {
    if (json is! Map) return null;
    final summary = EggDetectionSummaryDto.fromJson(json);
    return summary.hasData ? summary : null;
  }
}

/// Satu deteksi telur dari model YOLO (`detections[]`).
class EggDetectionDto {
  const EggDetectionDto({this.id, this.className, this.confidence, this.box});

  final int? id;
  final String? className;
  final double? confidence;

  /// Koordinat `[x, y, width, height]` dalam piksel citra asli.
  final List<double>? box;

  factory EggDetectionDto.fromJson(Object? json) {
    if (json is! Map) return const EggDetectionDto();
    final rawBox = json['box'];
    List<double>? box;
    if (rawBox is List &&
        rawBox.length == 4 &&
        rawBox.every((value) => value is num)) {
      box = rawBox
          .map((value) => (value as num).toDouble())
          .toList(growable: false);
    }
    return EggDetectionDto(
      id: json['id'] is num ? (json['id'] as num).toInt() : null,
      className: json['class'] is String ? json['class'] as String : null,
      confidence: _asDouble(json['confidence']),
      box: box,
    );
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

/// Isi response `GET /incubator/latest`.
class IncubatorLatestDto {
  const IncubatorLatestDto({
    this.status,
    required this.online,
    this.imageUrl,
    required this.totalEggs,
    required this.detections,
    this.detectionStatus,
    this.detectionPhotoId,
    this.temperature,
    this.humidity,
    this.lamp,
    this.motor,
    this.rssi,
    this.lastUpdated,
    this.timestamp,
    this.lastSeenSec,
    required this.history,
  });

  /// Status versi backend terbaru: online / idle / no_data.
  final String? status;

  final bool online;

  /// Foto tray — bisa path relatif ("/incubator/photo/x.jpg"),
  /// URL absolut (http/https), atau data-URI base64.
  final String? imageUrl;

  final int totalEggs;

  /// Deteksi telur terbaru beserta bounding box dari YOLO.
  final List<EggDetectionDto> detections;

  /// Status inferensi YOLO: `success`, `pending`, atau `failed`.
  final String? detectionStatus;

  /// ID foto yang dianalisis YOLO pada `detection` teratas (bila dikirim).
  final String? detectionPhotoId;

  final double? temperature;
  final double? humidity;
  final bool? lamp;
  final bool? motor;
  final int? rssi;
  final String? lastUpdated;
  final int? timestamp;
  final int? lastSeenSec;

  final List<IncubatorHistoryEntryDto> history;

  factory IncubatorLatestDto.fromJson(Object? json) {
    if (json is! Map) {
      return const IncubatorLatestDto(
        online: false,
        totalEggs: 0,
        detections: [],
        history: [],
      );
    }
    final detection = EggDetectionSummaryDto.tryFromJson(json['detection']);
    final rawDetections = json['detections'];
    final detections = rawDetections is List
        ? EggDetectionSummaryDto.fromJson({
            'detections': rawDetections,
          }).detections
        : detection?.detections ?? const <EggDetectionDto>[];
    final rawTotalEggs = json['total_eggs'] ?? detection?.totalEggs;
    final history = <IncubatorHistoryEntryDto>[];
    final rawHistory = json['history'];
    if (rawHistory is List) {
      for (final item in rawHistory) {
        history.add(IncubatorHistoryEntryDto.fromJson(item));
      }
    }
    return IncubatorLatestDto(
      status: json['status'] is String ? json['status'] as String : null,
      online: json['online'] == true,
      imageUrl: _imageUrl(json),
      totalEggs: rawTotalEggs is num ? rawTotalEggs.toInt() : detections.length,
      detections: detections,
      detectionStatus: detection?.status,
      detectionPhotoId: _asId(json['photo_id']) ?? detection?.photoId,
      temperature: _asDouble(json['temperature']),
      humidity: _asDouble(json['humidity']),
      lamp: json['lamp'] is bool ? json['lamp'] as bool : null,
      motor: json['motor'] is bool ? json['motor'] as bool : null,
      rssi: json['rssi'] is num ? (json['rssi'] as num).toInt() : null,
      lastUpdated: json['last_updated'] is String
          ? json['last_updated'] as String
          : null,
      timestamp: json['timestamp'] is num
          ? (json['timestamp'] as num).toInt()
          : null,
      lastSeenSec: json['last_seen_sec'] is num
          ? (json['last_seen_sec'] as num).toInt()
          : null,
      history: history,
    );
  }

  static String? _imageUrl(Object? json) {
    final image = (json as Map)['image'] ?? json['url'];
    return image is String && image.isNotEmpty ? image : null;
  }

  static String? _asId(Object? value) {
    if (value is String && value.isNotEmpty) return value;
    if (value is num) return value.toString();
    return null;
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
