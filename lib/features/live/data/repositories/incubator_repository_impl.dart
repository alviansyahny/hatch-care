import 'dart:convert';

import 'package:http/http.dart' show Client;

import 'package:hatch_care/core/config/app_config.dart';
import 'package:hatch_care/core/network/api_exception.dart';
import 'package:hatch_care/features/live/data/dto/incubator_dto.dart';
import 'package:hatch_care/features/live/domain/models/incubator_models.dart';
import 'package:hatch_care/features/live/domain/repositories/incubator_repository.dart';

/// Implementasi [IncubatorRepository] memakai klien HTTP bersama.
class IncubatorRepositoryImpl implements IncubatorRepository {
  IncubatorRepositoryImpl(this._client);

  final Client _client;

  String get _base => AppConfig.apiBaseUrl;

  @override
  Future<IncubatorSnapshot> fetchLatest() async {
    try {
      final res = await _client
          .get(Uri.parse('$_base/incubator/latest'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) {
        throw ApiException.serverError(res.statusCode);
      }
      final dto = IncubatorLatestDto.fromJson(jsonDecode(res.body));
      return _toSnapshot(dto);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  @override
  Future<void> triggerCapture() async {
    try {
      final res = await _client
          .post(
            Uri.parse('$_base/incubator/control'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'triggerCapture': true}),
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) {
        throw ApiException.serverError(res.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  @override
  Future<List<IncubatorHistoryEntry>> fetchHistory() async {
    try {
      final res = await _client
          .get(Uri.parse('$_base/incubator/history'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) {
        throw ApiException.serverError(res.statusCode);
      }
      final decoded = jsonDecode(res.body);
      final rawHistory = decoded is Map ? decoded['history'] : null;
      if (rawHistory is! List) throw ApiException.dataTidakValid;
      return rawHistory
          .map((e) => _fromDto(IncubatorHistoryEntryDto.fromJson(e)))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  // --- Mapper ---------------------------------------------------------------

  IncubatorSnapshot _toSnapshot(IncubatorLatestDto dto) {
    final history = dto.history.map(_fromDto).toList(growable: false);
    final latest = _latestHistoryFor(dto.imageUrl, history);
    final latestHasDetection =
        latest != null &&
        (latest.detectionStatus != null ||
            latest.totalEggs != null ||
            latest.detections.isNotEmpty);
    final topLevelMatches = _detectionMatchesPhoto(
      dto.detectionPhotoId,
      latest?.id,
    );
    final useLatest = latest != null && latestHasDetection;
    final useTopLevel = !useLatest && topLevelMatches;
    final detections = useLatest
        ? latest.detections
        : useTopLevel
        ? dto.detections.map(_toDetection).toList(growable: false)
        : const <EggDetection>[];
    return IncubatorSnapshot(
      online: dto.online,
      statusLabel: dto.status,
      image: _resolveImage(dto.imageUrl),
      totalEggs: useLatest
          ? (latest.totalEggs ?? latest.detections.length)
          : useTopLevel
          ? dto.totalEggs
          : 0,
      detections: detections,
      detectionStatus: useLatest
          ? latest.detectionStatus
          : useTopLevel
          ? dto.detectionStatus
          : null,
      temperature: dto.temperature,
      humidity: dto.humidity,
      lamp: dto.lamp,
      motor: dto.motor,
      rssi: dto.rssi,
      lastCaptureAt: _parseTime(dto.timestamp, dto.lastUpdated),
      history: history,
    );
  }

  /// Entri riwayat yang cocok dengan foto utama.
  ///
  /// Bila nama foto utama tidak bisa dibaca (mis. base64), dipakai entri
  /// terbaru. Bila nama foto tidak ditemukan di riwayat, hasil `detection`
  /// teratas yang dipakai agar deteksi tidak tertukar dengan foto lama.
  IncubatorHistoryEntry? _latestHistoryFor(
    String? imageUrl,
    List<IncubatorHistoryEntry> history,
  ) {
    if (history.isEmpty) return null;
    final imageName = _photoName(imageUrl);
    if (imageName == null) return history.first;
    for (final entry in history) {
      if (_photoName(entry.imageUrl) == imageName) return entry;
    }
    return null;
  }

  /// `detection.photo_id` dianggap segar bila cocok dengan foto terbaru.
  bool _detectionMatchesPhoto(String? detectionPhotoId, String? photoId) {
    if (detectionPhotoId == null || photoId == null) return true;
    return detectionPhotoId == photoId;
  }

  String? _photoName(String? url) {
    if (url == null || url.isEmpty || url.startsWith('data:')) return null;
    final clean = url.split('?').first.split('#').first;
    final name = clean.split('/').last;
    return name.isEmpty || name.length > 100 ? null : name;
  }

  EggDetection _toDetection(EggDetectionDto dto) {
    final box = dto.box;
    final className = dto.className?.trim();
    return EggDetection(
      id: dto.id,
      label: className != null && className.isNotEmpty ? className : 'telur',
      confidence: dto.confidence,
      x: box?[0] ?? 0,
      y: box?[1] ?? 0,
      width: box?[2] ?? 0,
      height: box?[3] ?? 0,
    );
  }

  IncubatorHistoryEntry _fromDto(IncubatorHistoryEntryDto dto) {
    final detection = dto.detection;
    final detections = detection == null
        ? const <EggDetection>[]
        : detection.detections.map(_toDetection).toList(growable: false);
    return IncubatorHistoryEntry(
      id: dto.id,
      capturedAt: _parseTime(dto.timestamp, dto.at),
      temperature: dto.temperature,
      humidity: dto.humidity,
      lamp: dto.lamp,
      motor: dto.motor,
      imageUrl: dto.url,
      sizeKb: dto.sizeKb,
      detectionStatus: detection?.status,
      totalEggs:
          detection?.totalEggs ??
          (detection != null ? detections.length : null),
      detections: detections,
    );
  }

  /// Mengubah nilai field gambar menjadi sumber gambar yang bisa dipakai
  /// widget: URL absolut (path relatif digabung dengan base URL), atau
  /// base64 murni (prefix data-URI dibuang).
  IncubatorImage _resolveImage(String? raw) {
    if (raw == null || raw.isEmpty) return const IncubatorImage.empty();
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return IncubatorImage.network(raw);
    }
    if (raw.startsWith('/')) {
      return IncubatorImage.network('$_base$raw');
    }
    if (raw.contains(',')) raw = raw.split(',').last;
    return IncubatorImage.base64(raw);
  }

  DateTime? _parseTime(int? epochSeconds, String? iso) {
    if (epochSeconds != null && epochSeconds > 0) {
      return DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000).toLocal();
    }
    if (iso != null && iso.isNotEmpty) {
      return DateTime.tryParse(iso)?.toLocal();
    }
    return null;
  }
}
