import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hatch_care/features/dashboard/domain/models/dashboard_models.dart';

// ---------------------------------------------------------------------------
// Data dummy — ganti dengan AsyncNotifierProvider + repository saat backend
// sudah tersedia. Widget tidak perlu diubah selama tipe DashboardData sama.
// ---------------------------------------------------------------------------

const _dummyDashboard = DashboardData(
  status: IncubatorStatus(
    statusText:
        'Sistem PID aktif, parameter termal & sirkulasi udara beroperasi normal',
    phaseLabel: 'Fase Vaskularisasi',
    isConnected: true,
    currentDay: 11,
    totalDays: 21,
  ),
  condition: IncubatorCondition(
    temperature: 37.5,
    humidity: 55,
    operationalHours: 336,
    rackRotationHours: 4,
    tempStatus: 'Stabil',
    humStatus: 'Ideal',
  ),
  // Nilai tempSeries & humSeries adalah nilai visual (0–100) untuk grafik.
  // Garis suhu (biru) ≈ 70–90, garis kelembapan (kuning) ≈ 48–68
  // agar tampil terpisah dan proporsional di sumbu yang sama.
  chartPoints: [
    ChartDataPoint(hour: 0, tempSeries: 72, humSeries: 50),
    ChartDataPoint(hour: 4, tempSeries: 78, humSeries: 54),
    ChartDataPoint(hour: 8, tempSeries: 83, humSeries: 60),
    ChartDataPoint(hour: 12, tempSeries: 88, humSeries: 64),
    ChartDataPoint(hour: 16, tempSeries: 85, humSeries: 61),
    ChartDataPoint(hour: 20, tempSeries: 91, humSeries: 67),
  ],
  eggStats: EggStats(total: 20, fertile: 10, infertile: 10),
  features: [
    MainFeature(
      title: 'Remote Control',
      subtitle: 'Atur aktuator pemanas, kipas, & rotasi rak otomatis',
      tag: 'PID Relay',
      icon: Icons.tune,
      isActive: false,
      // route: null — belum ada layar Remote Control
    ),
  ],
);

/// Provider data dashboard. Saat ini mengembalikan data dummy sinkron.
///
/// Untuk mengganti dengan data asli:
/// 1. Ubah menjadi [AsyncNotifierProvider<DashboardNotifier, DashboardData>]
/// 2. Buat kelas notifier yang memanggil repository/API
/// 3. Widget sudah siap karena membaca [DashboardData] tanpa tahu sumbernya.
final dashboardProvider = Provider<DashboardData>((ref) => _dummyDashboard);
