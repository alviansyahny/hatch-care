/// DTO mentah dari backend IoT untuk monitoring inkubator (fitur Live).
///
/// Parsing tahan null dan field hilang; konversi ke model domain dilakukan
/// di repository.
library;

/// Satu entri riwayat foto inkubator (dari `history` atau `/incubator/history`).
class IncubatorHistoryEntryDto {
  const IncubatorHistoryEntryDto({
    this.filename,
    this.url,
    this.timestamp,
    this.at,
    this.temperature,
    this.humidity,
    this.lamp,
    this.motor,
  });

  final String? filename;
  final String? url;
  final int? timestamp;
  final String? at;
  final double? temperature;
  final double? humidity;
  final bool? lamp;
  final bool? motor;

  factory IncubatorHistoryEntryDto.fromJson(Object? json) {
    if (json is! Map) return const IncubatorHistoryEntryDto();
    return IncubatorHistoryEntryDto(
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

  /// Konfiden tiap deteksi telur (0.0–1.0, bisa null).
  final List<double?> detections;

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
    final detections = <double?>[];
    final rawDetections = json['detections'];
    if (rawDetections is List) {
      for (final item in rawDetections) {
        if (item is Map) {
          detections.add(
            item['confidence'] is num
                ? (item['confidence'] as num).toDouble()
                : null,
          );
        } else if (item is num) {
          detections.add(item.toDouble());
        } else {
          detections.add(null);
        }
      }
    }
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
      totalEggs: json['total_eggs'] is num
          ? (json['total_eggs'] as num).toInt()
          : 0,
      detections: detections,
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

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
