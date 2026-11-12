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
    return IncubatorSnapshot(
      online: dto.online,
      statusLabel: dto.status,
      image: _resolveImage(dto.imageUrl),
      totalEggs: dto.totalEggs,
      detectionConfidences: dto.detections,
      temperature: dto.temperature,
      humidity: dto.humidity,
      lamp: dto.lamp,
      motor: dto.motor,
      rssi: dto.rssi,
      lastCaptureAt: _parseTime(dto.timestamp, dto.lastUpdated),
      history: dto.history.map(_fromDto).toList(),
    );
  }

  IncubatorHistoryEntry _fromDto(IncubatorHistoryEntryDto dto) {
    return IncubatorHistoryEntry(
      capturedAt: _parseTime(dto.timestamp, dto.at),
      temperature: dto.temperature,
      humidity: dto.humidity,
      lamp: dto.lamp,
      motor: dto.motor,
      imageUrl: dto.url,
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
