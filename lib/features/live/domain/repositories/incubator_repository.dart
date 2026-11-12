import 'package:hatch_care/features/live/domain/models/incubator_models.dart';

/// Repository data backend IoT untuk monitoring inkubator.
abstract interface class IncubatorRepository {
  /// Snapshot kondisi inkubator terkini (foto, telemetri, riwayat).
  Future<IncubatorSnapshot> fetchLatest();

  /// Riwayat foto 1 jam terakhir.
  Future<List<IncubatorHistoryEntry>> fetchHistory();
}
