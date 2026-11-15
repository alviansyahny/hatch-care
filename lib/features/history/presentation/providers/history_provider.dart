import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hatch_care/core/config/app_config.dart';
import 'package:hatch_care/core/network/api_exception.dart';
import 'package:hatch_care/features/history/domain/models/history_models.dart';
import 'package:hatch_care/features/live/domain/models/incubator_models.dart';
import 'package:hatch_care/features/live/presentation/providers/incubator_provider.dart';

// ---------------------------------------------------------------------------
// Data riwayat tangkapan
// ---------------------------------------------------------------------------

/// State halaman History: daftar tangkapan kamera + kondisi terkini.
///
/// Satu panggilan `GET /incubator/latest` sudah memuat semuanya (history
/// 1 jam terakhir, deteksi YOLO foto terbaru, telemetri). Tidak ada polling —
/// data disegarkan saat layar dibuka dan lewat tombol refresh.
class IncubatorHistoryNotifier extends AsyncNotifier<CaptureHistoryData> {
  bool _inFlight = false;

  @override
  FutureOr<CaptureHistoryData> build() => _fetch();

  /// Fetch manual (tombol refresh / buka ulang layar).
  Future<void> refresh() => _fetch(manual: true);

  Future<CaptureHistoryData> _fetch({bool manual = false}) async {
    if (_inFlight) {
      return state.value ?? const CaptureHistoryData.empty();
    }
    _inFlight = true;
    if (manual) {
      ref.read(captureRefreshingProvider.notifier).set(true);
    }
    try {
      final snapshot = await ref
          .read(incubatorRepositoryProvider)
          .fetchLatest();
      final data = _toHistoryData(snapshot);
      state = AsyncData(data);
      return data;
    } on ApiException catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    } finally {
      _inFlight = false;
      if (manual) {
        ref.read(captureRefreshingProvider.notifier).set(false);
      }
    }
  }

  /// Memetakan snapshot Live menjadi data halaman History.
  ///
  /// URL foto di tiap entri history dinormalisasi menjadi URL absolut agar
  /// bisa dibandingkan dengan URL snapshot (untuk menempelkan hasil deteksi
  /// YOLO ke entri yang tepat — hanya foto terbaru yang dianalisis server).
  CaptureHistoryData _toHistoryData(IncubatorSnapshot snapshot) {
    final latestUrl = snapshot.image.networkUrl;
    final records = <CaptureRecord>[];
    for (final entry in snapshot.history) {
      final image = _resolveImage(entry.imageUrl);
      final isLatest =
          latestUrl != null &&
          image.networkUrl != null &&
          image.networkUrl == latestUrl;
      records.add(
        CaptureRecord(
          id: entry.imageUrl,
          filename: _filenameFrom(entry.imageUrl),
          image: image,
          capturedAt: entry.capturedAt,
          temperature: entry.temperature,
          humidity: entry.humidity,
          lamp: entry.lamp,
          motor: entry.motor,
          sizeKb: entry.sizeKb,
          eggCount: isLatest ? snapshot.totalEggs : null,
          detectionConfidences: isLatest
              ? snapshot.detectionConfidences
              : const [],
        ),
      );
    }
    return CaptureHistoryData(
      online: snapshot.online,
      records: records,
      temperature: snapshot.temperature,
      humidity: snapshot.humidity,
    );
  }

  /// Mengubah URL mentah (relatif/absolut/base64) menjadi [IncubatorImage].
  IncubatorImage _resolveImage(String? raw) {
    if (raw == null || raw.isEmpty) return const IncubatorImage.empty();
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return IncubatorImage.network(raw);
    }
    if (raw.startsWith('/')) {
      return IncubatorImage.network('${AppConfig.apiBaseUrl}$raw');
    }
    if (raw.contains(',')) raw = raw.split(',').last;
    return IncubatorImage.base64(raw);
  }

  String? _filenameFrom(String? url) {
    if (url == null || url.isEmpty) return null;
    final withoutQuery = url.split('?').first;
    final segments = withoutQuery.split('/');
    return segments.isEmpty ? null : segments.last;
  }
}

/// Provider data halaman History (autoDispose: berhenti saat layar ditutup).
final incubatorHistoryProvider =
    AsyncNotifierProvider.autoDispose<
      IncubatorHistoryNotifier,
      CaptureHistoryData
    >(IncubatorHistoryNotifier.new);

/// Status refresh manual sedang berjalan (untuk spinner tombol refresh).
class CaptureRefreshingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Mengubah status refresh.
  void set(bool value) {
    state = value;
  }
}

final captureRefreshingProvider =
    NotifierProvider<CaptureRefreshingNotifier, bool>(
      CaptureRefreshingNotifier.new,
    );

// ---------------------------------------------------------------------------
// Filter state
// ---------------------------------------------------------------------------

/// Notifier state filter daftar tangkapan.
class CaptureFilterNotifier extends Notifier<CaptureFilter> {
  @override
  CaptureFilter build() => CaptureFilter.semua;

  /// Mengubah filter aktif.
  void setFilter(CaptureFilter filter) {
    state = filter;
  }
}

/// Provider state filter daftar tangkapan.
final captureFilterProvider =
    NotifierProvider<CaptureFilterNotifier, CaptureFilter>(
      CaptureFilterNotifier.new,
    );

// ---------------------------------------------------------------------------
// Provider turunan
// ---------------------------------------------------------------------------

/// Jumlah tangkapan per filter (untuk label chip).
final captureFilterCountsProvider = Provider<Map<CaptureFilter, int>>((
  ref,
) {
  final records = ref
      .watch(incubatorHistoryProvider)
      .value
      ?.records;
  final list = records ?? const <CaptureRecord>[];
  return {
    CaptureFilter.semua: list.length,
    CaptureFilter.lampuNyala: list.where((r) => r.lamp == true).length,
    CaptureFilter.lampuMati: list.where((r) => r.lamp == false).length,
  };
});

/// Daftar tangkapan yang sudah difilter sesuai [captureFilterProvider].
final filteredCaptureRecordsProvider = Provider<List<CaptureRecord>>((ref) {
  final filter = ref.watch(captureFilterProvider);
  final data = ref.watch(incubatorHistoryProvider).value;
  final records = data?.records ?? const <CaptureRecord>[];
  return switch (filter) {
    CaptureFilter.semua => records,
    CaptureFilter.lampuNyala => records.where((r) => r.lamp == true).toList(),
    CaptureFilter.lampuMati => records.where((r) => r.lamp == false).toList(),
  };
});
