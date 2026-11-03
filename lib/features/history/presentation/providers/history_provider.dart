import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hatch_care/features/history/domain/models/history_models.dart';

// ---------------------------------------------------------------------------
// Filter state — NotifierProvider (bukan StateProvider yang sudah legacy)
// ---------------------------------------------------------------------------

/// Notifier untuk state filter riwayat candling.
///
/// Nilai `null` berarti "Semua" (tanpa filter).
class HistoryFilterNotifier extends Notifier<EggStatus?> {
  @override
  EggStatus? build() => null;

  /// Mengubah filter aktif. Kirim `null` untuk menampilkan semua.
  void setFilter(EggStatus? status) {
    state = status;
  }
}

/// Provider state filter riwayat. `null` = Semua.
final historyFilterProvider =
    NotifierProvider<HistoryFilterNotifier, EggStatus?>(
      HistoryFilterNotifier.new,
    );

// ---------------------------------------------------------------------------
// Data dummy — ganti dengan AsyncNotifierProvider + repository saat backend
// sudah tersedia. Widget tidak perlu diubah selama tipe List<CandlingRecord>
// sama.
// ---------------------------------------------------------------------------

final _dummyRecords = [
  CandlingRecord(
    eggNumber: 12,
    day: 11,
    status: EggStatus.fertil,
    batchCode: 'B04-EGG-12',
    dateTime: DateTime(2025, 5, 18, 15, 10),
    confidencePercent: 95,
  ),
  CandlingRecord(
    eggNumber: 11,
    day: 11,
    status: EggStatus.fertil,
    batchCode: 'B04-EGG-11',
    dateTime: DateTime(2025, 5, 18, 15, 2),
    confidencePercent: 93,
  ),
  CandlingRecord(
    eggNumber: 10,
    day: 11,
    status: EggStatus.infertil,
    batchCode: 'B04-EGG-10',
    dateTime: DateTime(2025, 5, 18, 14, 55),
    confidencePercent: 91,
  ),
  CandlingRecord(
    eggNumber: 9,
    day: 11,
    status: EggStatus.fertil,
    batchCode: 'B04-EGG-09',
    dateTime: DateTime(2025, 5, 18, 14, 48),
    confidencePercent: 97,
  ),
  CandlingRecord(
    eggNumber: 8,
    day: 11,
    status: EggStatus.mortalitas,
    batchCode: 'B04-EGG-08',
    dateTime: DateTime(2025, 5, 18, 14, 42),
    confidencePercent: 85,
  ),
  CandlingRecord(
    eggNumber: 7,
    day: 11,
    status: EggStatus.fertil,
    batchCode: 'B04-EGG-07',
    dateTime: DateTime(2025, 5, 18, 14, 38),
    confidencePercent: 96,
  ),
  CandlingRecord(
    eggNumber: 6,
    day: 11,
    status: EggStatus.fertil,
    batchCode: 'B04-EGG-06',
    dateTime: DateTime(2025, 5, 18, 14, 30),
    confidencePercent: 94,
  ),
  CandlingRecord(
    eggNumber: 5,
    day: 11,
    status: EggStatus.fertil,
    batchCode: 'B04-EGG-05',
    dateTime: DateTime(2025, 5, 18, 14, 22),
    confidencePercent: 98,
  ),
  CandlingRecord(
    eggNumber: 4,
    day: 11,
    status: EggStatus.mortalitas,
    batchCode: 'B04-EGG-04',
    dateTime: DateTime(2025, 5, 18, 14, 15),
    confidencePercent: 89,
  ),
  CandlingRecord(
    eggNumber: 3,
    day: 11,
    status: EggStatus.infertil,
    batchCode: 'B04-EGG-03',
    dateTime: DateTime(2025, 5, 18, 14, 5),
    confidencePercent: 97,
  ),
  CandlingRecord(
    eggNumber: 2,
    day: 11,
    status: EggStatus.fertil,
    batchCode: 'B04-EGG-02',
    dateTime: DateTime(2025, 5, 18, 13, 58),
    confidencePercent: 92,
  ),
  CandlingRecord(
    eggNumber: 1,
    day: 11,
    status: EggStatus.fertil,
    batchCode: 'B04-EGG-01',
    dateTime: DateTime(2025, 5, 18, 13, 50),
    confidencePercent: 90,
  ),
];

/// Provider seluruh data riwayat candling (dummy sinkron untuk saat ini).
///
/// Untuk mengganti dengan data asli:
/// 1. Ubah menjadi [AsyncNotifierProvider]
/// 2. Buat kelas notifier yang memanggil repository/API
/// 3. Widget sudah siap karena membaca [List<CandlingRecord>] tanpa tahu
///    sumbernya.
final allCandlingRecordsProvider = Provider<List<CandlingRecord>>(
  (ref) => _dummyRecords,
);

// ---------------------------------------------------------------------------
// Provider turunan: jumlah per status dan daftar terfilter
// ---------------------------------------------------------------------------

/// Jumlah record per status. Key `null` = total semua.
///
/// Dihitung dari data, bukan hardcode — otomatis berubah jika data berubah.
final historyCountsProvider = Provider<Map<EggStatus?, int>>((ref) {
  final records = ref.watch(allCandlingRecordsProvider);
  return {
    null: records.length,
    EggStatus.fertil: records.where((r) => r.status == EggStatus.fertil).length,
    EggStatus.infertil: records
        .where((r) => r.status == EggStatus.infertil)
        .length,
    EggStatus.mortalitas: records
        .where((r) => r.status == EggStatus.mortalitas)
        .length,
  };
});

/// Daftar record yang sudah difilter sesuai [historyFilterProvider].
///
/// Jika filter `null` (Semua), mengembalikan seluruh record.
final filteredCandlingRecordsProvider = Provider<List<CandlingRecord>>((ref) {
  final filter = ref.watch(historyFilterProvider);
  final records = ref.watch(allCandlingRecordsProvider);
  if (filter == null) return records;
  return records.where((r) => r.status == filter).toList();
});
