import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hatch_care/features/egg_check/domain/models/candling_job_models.dart';
import 'package:hatch_care/features/egg_check/presentation/providers/egg_check_backend_provider.dart';
import 'package:hatch_care/features/live/domain/models/incubator_models.dart';
import 'package:hatch_care/features/live/presentation/providers/incubator_provider.dart';

/// Fake state & helper untuk test widget TANPA koneksi jaringan asli.
/// Semua notifier di-override sehingga tidak ada timer polling berjalan.

const EggDeviceStatus kFakeDeviceStatus = EggDeviceStatus(
  online: true,
  rssi: -52,
  lastSeenSec: 3,
);

const List<EggCaptureSummary> kFakeCaptureHistory = [
  EggCaptureSummary(id: 2, label: 'fertil', confidence: 0.97),
  EggCaptureSummary(id: 1, label: 'infertil', confidence: 0.91),
];

/// PNG 1x1 valid agar Image.memory tidak error di test.
const String _kFakeImageBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk'
    'YPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

const IncubatorSnapshot kFakeIncubatorSnapshot = IncubatorSnapshot(
  online: true,
  statusLabel: 'online',
  image: IncubatorImage.base64(_kFakeImageBase64),
  totalEggs: 12,
  detectionConfidences: [0.95, 0.88],
  temperature: 37.6,
  humidity: 55.0,
  lamp: true,
  motor: false,
  rssi: -60,
  lastCaptureAt: null,
  history: [],
);

class _FakeEggDeviceStatusNotifier extends EggDeviceStatusNotifier {
  @override
  FutureOr<EggDeviceStatus> build() => kFakeDeviceStatus;
}

class _FakeEggCaptureHistoryNotifier extends EggCaptureHistoryNotifier {
  @override
  FutureOr<List<EggCaptureSummary>> build() => kFakeCaptureHistory;
}

class _FakeEggCaptureNotifier extends EggCaptureNotifier {
  @override
  FutureOr<EggCaptureState> build() => const EggCaptureState.initial();
}

class _FakeIncubatorLatestNotifier extends IncubatorLatestNotifier {
  @override
  FutureOr<IncubatorSnapshot> build() => kFakeIncubatorSnapshot;
}

/// Membungkus [child] dengan ProviderScope yang seluruh provider backend-nya
/// sudah di-override dengan data fake (tidak ada HTTP atau timer asli).
Widget backendOverriddenScope({required Widget child}) {
  return ProviderScope(
    overrides: [
      eggDeviceStatusProvider.overrideWith(_FakeEggDeviceStatusNotifier.new),
      eggCaptureHistoryProvider.overrideWith(
        _FakeEggCaptureHistoryNotifier.new,
      ),
      eggCaptureProvider.overrideWith(_FakeEggCaptureNotifier.new),
      incubatorLatestProvider.overrideWith(_FakeIncubatorLatestNotifier.new),
    ],
    child: child,
  );
}
