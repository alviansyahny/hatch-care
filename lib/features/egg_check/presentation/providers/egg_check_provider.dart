import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hatch_care/core/enums/egg_status.dart';
import 'package:hatch_care/features/egg_check/domain/models/egg_check_models.dart';

const _dummyEggCheck = EggCheckData(
  incubatorCode: 'E01',
  day: 11,
  isTorchOn: true,
  lumensLevel: 0.45,
  lumensStatus: 'Candle Lumens OK',
  batchTitle: 'Batch 4 (12 Eggs)',
  tipText:
      'Align the blunt pole upward against high-intensity LED. '
      'Check for visible vascular webbing or floating dark embryo eye-spot.',
  recentItems: [
    EggCheckTrayItem(
      eggNumber: 5,
      batchCode: 'B04-EGG-05',
      status: EggStatus.fertil,
      confidencePercent: 98,
    ),
    EggCheckTrayItem(
      eggNumber: 6,
      batchCode: 'B04-EGG-06',
      status: EggStatus.fertil,
      confidencePercent: 94,
    ),
    EggCheckTrayItem(
      eggNumber: 7,
      batchCode: 'B04-EGG-07',
      status: null,
      isLiveTarget: true,
    ),
    EggCheckTrayItem(
      eggNumber: 8,
      batchCode: 'B04-EGG-08',
      status: null,
    ),
  ],
);

class EggCheckNotifier extends Notifier<EggCheckData> {
  @override
  EggCheckData build() {
    return _dummyEggCheck;
  }

  /// Menyalakan / mematikan lampu senter candler (Torch).
  void toggleTorch() {
    state = state.copyWith(isTorchOn: !state.isTorchOn);
  }

  /// Memilih telur pada daftar tray sebagai target aktif.
  void selectTrayItem(int eggNumber) {
    final updated = state.recentItems.map((item) {
      return EggCheckTrayItem(
        eggNumber: item.eggNumber,
        batchCode: item.batchCode,
        status: item.status,
        confidencePercent: item.confidencePercent,
        isLiveTarget: item.eggNumber == eggNumber,
      );
    }).toList();

    state = state.copyWith(recentItems: updated);
  }

  /// Menstimulasikan penangkapan hasil candling untuk telur aktif.
  void captureCurrentEgg() {
    final updated = state.recentItems.map((item) {
      if (item.isLiveTarget) {
        return EggCheckTrayItem(
          eggNumber: item.eggNumber,
          batchCode: item.batchCode,
          status: EggStatus.fertil,
          confidencePercent: 96,
          isLiveTarget: false,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(recentItems: updated);
  }
}

/// Provider untuk state halaman Egg Check.
final eggCheckProvider =
    NotifierProvider<EggCheckNotifier, EggCheckData>(EggCheckNotifier.new);
