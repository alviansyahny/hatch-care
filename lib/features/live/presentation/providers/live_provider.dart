import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hatch_care/core/enums/egg_status.dart';
import 'package:hatch_care/features/live/domain/models/live_models.dart';

const _dummyLiveData = LiveMonitoringData(
  timestampText: 'Hari ini, 14:15:22 WIB',
  status: EggStatus.fertil,
  morphologyTitle: 'Deskripsi Morfologi Vaskular',
  morphologyDescription:
      'Struktur pembuluh darah alantois (blood islands) tampak jelas menyebar '
      'dari embrio. Denyut kapiler dan batas transparansi kantung udara '
      'terdeteksi normal sesuai perkembangan fisiologis Hari ke-11.',
  day: 11,
);

final liveMonitoringProvider = Provider<LiveMonitoringData>((ref) {
  return _dummyLiveData;
});
