import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' show Client;

import 'package:hatch_care/core/config/app_config.dart';
import 'package:hatch_care/core/network/api_exception.dart';
import 'package:hatch_care/features/egg_check/data/dto/egg_check_dto.dart';
import 'package:hatch_care/features/egg_check/domain/models/candling_job_models.dart';
import 'package:hatch_care/features/egg_check/domain/repositories/egg_check_repository.dart';

/// Implementasi [EggCheckRepository] memakai klien HTTP bersama.
///
/// Alur data dan status pesan mengikuti versi tim backend; alamat server
/// dibaca dari [AppConfig].
class EggCheckRepositoryImpl implements EggCheckRepository {
  EggCheckRepositoryImpl(this._client);

  final Client _client;

  String get _base => AppConfig.apiBaseUrl;

  @override
  Future<EggDeviceStatus> fetchDeviceStatus() async {
    try {
      final res = await _client
          .get(Uri.parse('$_base/egg/status'))
          .timeout(Duration(seconds: 4));
      if (res.statusCode != 200) {
        throw ApiException.serverError(res.statusCode);
      }
      return _toStatus(EggDeviceStatusDto.fromJson(jsonDecode(res.body)));
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  @override
  Future<List<EggCaptureSummary>> fetchCaptureHistory() async {
    try {
      final res = await _client
          .get(Uri.parse('$_base/egg/history'))
          .timeout(Duration(seconds: 8));
      if (res.statusCode != 200) {
        throw ApiException.serverError(res.statusCode);
      }
      final decoded = jsonDecode(res.body);
      if (decoded is! List) throw ApiException.dataTidakValid;
      final result = <EggCaptureSummary>[];
      for (final item in decoded) {
        final dto = EggHistoryItemDto.fromJson(item);
        if (dto.id == null) continue;
        result.add(
          EggCaptureSummary(
            id: dto.id!,
            mainImageBase64: dto.url,
            label: dto.predictionLabel,
            confidence: dto.confidence,
            capturedAt: _parseIso(dto.at),
          ),
        );
      }
      return result;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  @override
  Future<EggCaptureDetail> fetchJobDetail(int jobId) async {
    try {
      final res = await _client
          .get(Uri.parse('$_base/egg/job/$jobId'))
          .timeout(Duration(seconds: 10));
      if (res.statusCode != 200) {
        throw ApiException.serverError(res.statusCode);
      }
      return _toDetail(EggJobDto.fromJson(jsonDecode(res.body)));
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  @override
  Future<int> requestCapture(CaptureParams params) async {
    try {
      final res = await _client
          .post(
            Uri.parse('$_base/egg/capture'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(params.toJson()),
          )
          .timeout(Duration(seconds: 10));
      if (res.statusCode != 200) {
        throw ApiException.serverError(res.statusCode);
      }
      final decoded = jsonDecode(res.body);
      final jobId = decoded is Map && decoded['job'] is num
          ? (decoded['job'] as num).toInt()
          : null;
      if (jobId == null) throw ApiException.dataTidakValid;
      return jobId;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  // --- Mapper DTO -> domain -------------------------------------------------

  EggDeviceStatus _toStatus(EggDeviceStatusDto dto) => EggDeviceStatus(
    online: dto.online,
    rssi: dto.rssi,
    lastSeenSec: dto.lastSeenSec,
  );

  EggCaptureDetail _toDetail(EggJobDto dto) {
    final stages = <CandlingStage>[];
    final vis = dto.visualisasi ?? const {};
    const stageFields = [
      ('citra_crop', 'Crop Telur'),
      ('citra_biner_roi', 'ROI Biner'),
      ('citra_rekonstruksi_rgb', 'Masked RGB'),
      ('citra_peta_darah', 'Peta Darah'),
      ('citra_jaringan_darah', 'Vaskular'),
    ];
    for (final (field, title) in stageFields) {
      final value = vis[field];
      if (value is String && value.isNotEmpty) {
        stages.add(CandlingStage(title: title, imageBase64: value));
      }
    }

    final probabilities = <String, double>{};
    (dto.probabilitas ?? const {}).forEach((key, value) {
      if (value is num) probabilities[key] = value.toDouble();
    });

    return EggCaptureDetail(
      status: dto.status,
      mainImageBase64: dto.url,
      label: dto.predictionLabel,
      confidence: dto.confidence,
      probabilities: probabilities,
      llmAnalysis: dto.llmAnalysis,
      stages: stages,
    );
  }

  DateTime? _parseIso(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toLocal();
  }
}
