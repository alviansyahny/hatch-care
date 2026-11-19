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
  static const _recaptureTimeout = Duration(seconds: 50);
  static const _recapturePollInterval = Duration(seconds: 2);

  Timer? _timer;
  bool _inFlight = false;
  bool _recapturing = false;
  bool _disposed = false;
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

  /// Meminta capture baru lalu menunggu foto + hasil YOLO terbaru.
  ///
  /// Return `true` bila foto baru sudah diterima server, `false` bila
  /// perintah terkirim tetapi foto baru belum masuk sampai batas waktu.
  Future<bool> recapture() async {
    if (_disposed || _recapturing) return false;
    _recapturing = true;
    _stopTimer();
    ref.read(incubatorRecaptureProvider.notifier).set(true);
    final previous = state.value;
    final previousKey = _imageKey(previous?.image);
    // Backend lama tidak mengirim status YOLO; jangan menunggu analisis.
    final expectsDetection =
        previous != null &&
        (previous.detectionStatus != null || previous.detections.isNotEmpty);
    var newImageReceived = false;
    try {
      await ref.read(incubatorRepositoryProvider).triggerCapture();
      final deadline = DateTime.now().add(_recaptureTimeout);
      while (DateTime.now().isBefore(deadline)) {
        if (_disposed) return false;
        await Future<void>.delayed(_recapturePollInterval);
        if (_disposed) return false;
        final snapshot = await ref
            .read(incubatorRepositoryProvider)
            .fetchLatest();
        if (_disposed) return false;
        if (_imageKey(snapshot.image) != previousKey) {
          newImageReceived = true;
        }
        state = AsyncData(snapshot);
        final analyzed =
            snapshot.detectionStatus == 'success' ||
            snapshot.detectionStatus == 'failed' ||
            (snapshot.detectionStatus == null &&
                (!expectsDetection || snapshot.detections.isNotEmpty));
        if (newImageReceived && analyzed) return true;
      }
      return newImageReceived;
    } finally {
      _recapturing = false;
      if (!_disposed) {
        ref.read(incubatorRecaptureProvider.notifier).set(false);
        _startTimer();
      }
    }
  }

  String? _imageKey(IncubatorImage? image) {
    if (image == null || image.isEmpty) return null;
    return image.isNetwork ? image.networkUrl : image.base64Data;
  }

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
      if (!_disposed) {
        state = AsyncData(snapshot);
      }
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
    _disposed = true;
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

/// Status tombol "Periksa Ulang Telur" sedang menunggu capture + YOLO.
class IncubatorRecaptureNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Mengubah status proses periksa ulang.
  void set(bool value) {
    state = value;
  }
}

final incubatorRecaptureProvider =
    NotifierProvider.autoDispose<IncubatorRecaptureNotifier, bool>(
      IncubatorRecaptureNotifier.new,
    );
