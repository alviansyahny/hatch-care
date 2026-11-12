import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hatch_care/core/network/api_client.dart';
import 'package:hatch_care/core/network/api_exception.dart';
import 'package:hatch_care/features/live/data/repositories/incubator_repository_impl.dart';
import 'package:hatch_care/features/live/domain/models/incubator_models.dart';
import 'package:hatch_care/features/live/domain/repositories/incubator_repository.dart';

/// Provider repository inkubator — dibuat dari klien HTTP bersama.
final incubatorRepositoryProvider = Provider<IncubatorRepository>((ref) {
  return IncubatorRepositoryImpl(ref.watch(apiClientProvider));
});

// ---------------------------------------------------------------------------
// Polling data terkini (20 detik)
// ---------------------------------------------------------------------------

/// State polling `GET /incubator/latest` tiap 20 detik.
///
/// - Timer berhenti saat layar ditutup (autoDispose) dan saat app di
///   background.
/// - Saat kembali ke foreground: fetch langsung, lalu timer lanjut.
/// - Tick dilewati jika request sebelumnya belum selesai (tidak menumpuk).
/// - Semua kegagalan dipetakan ke pesan Indonesia.
class IncubatorLatestNotifier extends AsyncNotifier<IncubatorSnapshot> {
  static const _pollInterval = Duration(seconds: 20);

  Timer? _timer;
  bool _inFlight = false;
  AppLifecycleListener? _lifecycle;

  @override
  FutureOr<IncubatorSnapshot> build() {
    ref.onDispose(_stop);
    _lifecycle = AppLifecycleListener(
      onResume: () => _resume(),
      onShow: () => _resume(),
      onPause: _stopTimer,
      onHide: _stopTimer,
    );
    return _fetch();
  }

  /// Fetch manual (tombol refresh / periksa ulang).
  Future<void> refresh() => _fetch();

  Future<void> _resume() async {
    await _fetch();
    _startTimer();
  }

  Future<IncubatorSnapshot> _fetch() async {
    if (_inFlight) {
      return state.value ?? const IncubatorSnapshot.empty();
    }
    _inFlight = true;
    try {
      final snapshot = await ref
          .read(incubatorRepositoryProvider)
          .fetchLatest();
      state = AsyncData(snapshot);
      return snapshot;
    } on ApiException catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    } finally {
      _inFlight = false;
    }
  }

  void _startTimer() {
    _timer ??= Timer.periodic(_pollInterval, (_) => _fetch());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _stop() {
    _stopTimer();
    _lifecycle?.dispose();
    _lifecycle = null;
  }
}

/// Provider snapshot inkubator (autoDispose: berhenti saat layar ditutup).
final incubatorLatestProvider =
    AsyncNotifierProvider.autoDispose<
      IncubatorLatestNotifier,
      IncubatorSnapshot
    >(IncubatorLatestNotifier.new);
