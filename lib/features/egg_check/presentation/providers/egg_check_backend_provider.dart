import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hatch_care/core/network/api_client.dart';
import 'package:hatch_care/core/network/api_exception.dart';
import 'package:hatch_care/features/egg_check/data/repositories/egg_check_repository_impl.dart';
import 'package:hatch_care/features/egg_check/domain/models/candling_job_models.dart';
import 'package:hatch_care/features/egg_check/domain/repositories/egg_check_repository.dart';

/// Provider repository egg check — dibuat dari klien HTTP bersama.
final eggCheckRepositoryProvider = Provider<EggCheckRepository>((ref) {
  return EggCheckRepositoryImpl(ref.watch(apiClientProvider));
});

// ---------------------------------------------------------------------------
// Status perangkat (polling 5 detik)
// ---------------------------------------------------------------------------

/// State polling status perangkat ESP32-CAM.
///
/// - Timer berhenti saat layar ditutup (autoDispose) dan saat app di
///   background.
/// - Saat kembali ke foreground: fetch langsung, lalu timer lanjut.
/// - Tick dilewati jika request sebelumnya belum selesai.
class EggDeviceStatusNotifier extends AsyncNotifier<EggDeviceStatus> {
  static const _pollInterval = Duration(seconds: 5);

  Timer? _timer;
  bool _inFlight = false;
  AppLifecycleListener? _lifecycle;

  @override
  FutureOr<EggDeviceStatus> build() {
    ref.onDispose(_stop);
    _lifecycle = AppLifecycleListener(
      onResume: () => _resume(),
      onShow: () => _resume(),
      onPause: _stopTimer,
      onHide: _stopTimer,
    );
    return _fetch();
  }

  /// Fetch manual (tombol refresh appbar).
  Future<void> refresh() => _fetch();

  Future<void> _resume() async {
    await _fetch();
    _startTimer();
  }

  Future<EggDeviceStatus> _fetch() async {
    if (_inFlight) {
      return state.value ?? const EggDeviceStatus(online: false);
    }
    _inFlight = true;
    try {
      final status = await ref
          .read(eggCheckRepositoryProvider)
          .fetchDeviceStatus();
      state = AsyncData(status);
      return status;
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

/// Provider status perangkat (autoDispose: berhenti saat layar ditutup).
final eggDeviceStatusProvider =
    AsyncNotifierProvider.autoDispose<EggDeviceStatusNotifier, EggDeviceStatus>(
      EggDeviceStatusNotifier.new,
    );

// ---------------------------------------------------------------------------
// Riwayat tangkapan
// ---------------------------------------------------------------------------

/// Provider riwayat tangkapan candling dari backend (fetch saat dibuka).
final eggCaptureHistoryProvider =
    AsyncNotifierProvider.autoDispose<
      EggCaptureHistoryNotifier,
      List<EggCaptureSummary>
    >(EggCaptureHistoryNotifier.new);

class EggCaptureHistoryNotifier extends AsyncNotifier<List<EggCaptureSummary>> {
  bool _inFlight = false;

  @override
  FutureOr<List<EggCaptureSummary>> build() => _fetch();

  /// Fetch ulang (tombol refresh atau setelah capture selesai).
  Future<void> refresh() async {
    if (_inFlight) return;
    state = const AsyncLoading();
    await _fetch();
  }

  Future<List<EggCaptureSummary>> _fetch() async {
    if (_inFlight) {
      return state.value ?? const [];
    }
    _inFlight = true;
    try {
      final items = await ref
          .read(eggCheckRepositoryProvider)
          .fetchCaptureHistory();
      state = AsyncData(items);
      return items;
    } on ApiException catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    } finally {
      _inFlight = false;
    }
  }
}

// ---------------------------------------------------------------------------
// Proses capture (job polling 1,5 detik)
// ---------------------------------------------------------------------------

/// State proses pengambilan foto candling.
class EggCaptureState {
  const EggCaptureState({
    required this.isCapturing,
    required this.statusMessage,
    required this.elapsedSeconds,
    this.result,
  });

  const EggCaptureState.initial()
    : isCapturing = false,
      statusMessage = '',
      elapsedSeconds = 0,
      result = null;

  final bool isCapturing;
  final String statusMessage;
  final int elapsedSeconds;
  final EggCaptureDetail? result;

  EggCaptureState copyWith({
    bool? isCapturing,
    String? statusMessage,
    int? elapsedSeconds,
    EggCaptureDetail? result,
  }) {
    return EggCaptureState(
      isCapturing: isCapturing ?? this.isCapturing,
      statusMessage: statusMessage ?? this.statusMessage,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      result: result ?? this.result,
    );
  }
}

/// Provider alur capture: POST /egg/capture lalu polling /egg/job/{id}.
///
/// Semua timer berhenti otomatis saat layar ditutup (autoDispose) —
/// polling job tidak boleh melanjutkan di luar layar Egg Check.
final eggCaptureProvider =
    AsyncNotifierProvider.autoDispose<EggCaptureNotifier, EggCaptureState>(
      EggCaptureNotifier.new,
    );

class EggCaptureNotifier extends AsyncNotifier<EggCaptureState> {
  static const _pollInterval = Duration(milliseconds: 1500);
  static const _maxElapsedSeconds = 65;

  Timer? _pollTimer;
  Timer? _elapsedTimer;
  bool _pollInFlight = false;

  @override
  FutureOr<EggCaptureState> build() {
    ref.onDispose(_stopTimers);
    return const EggCaptureState.initial();
  }

  Future<void> start(CaptureParams params) async {
    if (state.value?.isCapturing ?? false) return;
    state = AsyncData(
      const EggCaptureState(
        isCapturing: true,
        statusMessage: 'Mengirim perintah ambil foto ke server...',
        elapsedSeconds: 0,
      ),
    );

    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state.value;
      if (current == null) return;
      state = AsyncData(
        current.copyWith(elapsedSeconds: current.elapsedSeconds + 1),
      );
    });

    final int jobId;
    try {
      jobId = await ref.read(eggCheckRepositoryProvider).requestCapture(params);
    } on ApiException catch (e) {
      _finish(success: false, message: e.message);
      return;
    } catch (e) {
      _finish(success: false, message: 'Kesalahan koneksi: silakan coba lagi.');
      return;
    }

    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll(jobId));
  }

  Future<void> _poll(int jobId) async {
    final elapsed = state.value?.elapsedSeconds ?? 0;
    if (elapsed > _maxElapsedSeconds) {
      _stopTimers();
      state = AsyncData(
        EggCaptureState(
          isCapturing: false,
          statusMessage: 'Waktu habis menunggu respons ESP32.',
          elapsedSeconds: elapsed,
        ),
      );
      return;
    }
    if (_pollInFlight) return; // request menumpuk? lewati tick ini.
    _pollInFlight = true;
    try {
      final detail = await ref
          .read(eggCheckRepositoryProvider)
          .fetchJobDetail(jobId);
      final current = state.value ?? const EggCaptureState.initial();
      switch (detail.status) {
        case 'pending':
          state = AsyncData(
            current.copyWith(
              statusMessage: 'Menunggu ESP32 mengambil tugas...',
            ),
          );
        case 'taken':
          state = AsyncData(
            current.copyWith(
              statusMessage: 'ESP32 sedang memotret & mengekstrak citra...',
            ),
          );
        case 'done':
          _stopTimers();
          state = AsyncData(
            EggCaptureState(
              isCapturing: false,
              statusMessage: 'Pengambilan Foto & Analisis AI Selesai!',
              elapsedSeconds: current.elapsedSeconds,
              result: detail,
            ),
          );
          await ref.read(eggCaptureHistoryProvider.notifier).refresh();
        case 'failed':
          _stopTimers();
          state = AsyncData(
            EggCaptureState(
              isCapturing: false,
              statusMessage:
                  'Proses pengambilan foto gagal di perangkat ESP32.',
              elapsedSeconds: current.elapsedSeconds,
            ),
          );
        default:
          // Status belum diketahui (server sibuk) — tunggu tick berikutnya.
          break;
      }
    } on ApiException catch (e) {
      _stopTimers();
      final current = state.value ?? const EggCaptureState.initial();
      state = AsyncData(
        EggCaptureState(
          isCapturing: false,
          statusMessage: 'Gagal memuat detail job #$jobId: ${e.message}',
          elapsedSeconds: current.elapsedSeconds,
        ),
      );
    } catch (e) {
      // Gangguan jaringan sesaat — tunggu tick berikutnya.
    } finally {
      _pollInFlight = false;
    }
  }

  void _finish({required bool success, required String message}) {
    _stopTimers();
    final current = state.value ?? const EggCaptureState.initial();
    state = AsyncData(
      EggCaptureState(
        isCapturing: false,
        statusMessage: message,
        elapsedSeconds: current.elapsedSeconds,
      ),
    );
  }

  void _stopTimers() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
  }
}
