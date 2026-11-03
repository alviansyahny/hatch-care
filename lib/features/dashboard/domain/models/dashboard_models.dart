import 'package:flutter/widgets.dart';

/// Model data untuk fitur dashboard HATCH-CARE.
///
/// Semua model bersifat immutable (field [final], konstruktor [const])
/// agar mudah diganti dengan data asli dari repository di tahap backend.

// ---------------------------------------------------------------------------
// Status inkubator
// ---------------------------------------------------------------------------

/// Status koneksi dan progres penetasan inkubator.
class IncubatorStatus {
  const IncubatorStatus({
    required this.statusText,
    required this.phaseLabel,
    required this.isConnected,
    required this.currentDay,
    required this.totalDays,
  });

  /// Teks ringkasan kondisi sistem (PID, sirkulasi, dll.).
  final String statusText;

  /// Label fase penetasan saat ini (mis. "Fase Vaskularisasi").
  final String phaseLabel;

  /// Apakah inkubator sedang terhubung ke perangkat.
  final bool isConnected;

  /// Hari penetasan saat ini.
  final int currentDay;

  /// Total hari penetasan (mis. 21 hari).
  final int totalDays;

  /// Progres hari penetasan (0.0–1.0).
  double get progress =>
      totalDays > 0 ? (currentDay / totalDays).clamp(0.0, 1.0) : 0.0;
}

// ---------------------------------------------------------------------------
// Kondisi inkubator (nilai sensor terkini)
// ---------------------------------------------------------------------------

/// Nilai sensor terkini inkubator.
class IncubatorCondition {
  const IncubatorCondition({
    required this.temperature,
    required this.humidity,
    required this.operationalHours,
    required this.rackRotationHours,
    required this.tempStatus,
    required this.humStatus,
  });

  /// Suhu terkini dalam °C.
  final double temperature;

  /// Kelembapan terkini dalam %RH.
  final int humidity;

  /// Total jam operasi inkubator.
  final int operationalHours;

  /// Interval rotasi rak dalam jam.
  final int rackRotationHours;

  /// Label status suhu (mis. "Stabil").
  final String tempStatus;

  /// Label status kelembapan (mis. "Ideal").
  final String humStatus;
}

// ---------------------------------------------------------------------------
// Titik data grafik tren 24 jam
// ---------------------------------------------------------------------------

/// Satu titik data untuk grafik tren kondisi inkubator.
///
/// Nilai [tempSeries] dan [humSeries] adalah nilai representasi visual
/// (skala 0–100) agar kedua garis tampil proporsional di sumbu yang sama.
/// Nilai sensor asli disimpan di [IncubatorCondition].
class ChartDataPoint {
  const ChartDataPoint({
    required this.hour,
    required this.tempSeries,
    required this.humSeries,
  });

  /// Jam dalam sehari (0, 4, 8, 12, 16, 20).
  final double hour;

  /// Nilai visual tren suhu (0–100), garis biru.
  final double tempSeries;

  /// Nilai visual tren kelembapan (0–100), garis kuning.
  final double humSeries;
}

// ---------------------------------------------------------------------------
// Statistik telur
// ---------------------------------------------------------------------------

/// Ringkasan jumlah telur berdasarkan status.
class EggStats {
  const EggStats({
    required this.total,
    required this.fertile,
    required this.infertile,
  });

  /// Total telur dalam inkubator.
  final int total;

  /// Jumlah telur fertil.
  final int fertile;

  /// Jumlah telur infertil.
  final int infertile;
}

// ---------------------------------------------------------------------------
// Item fitur utama
// ---------------------------------------------------------------------------

/// Satu item pada daftar "Fitur Utama" di dashboard.
class MainFeature {
  const MainFeature({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.icon,
    required this.isActive,
    this.route,
  });

  /// Judul fitur (mis. "Remote Control").
  final String title;

  /// Deskripsi singkat fitur.
  final String subtitle;

  /// Label teknologi (mis. "PID Relay").
  final String tag;

  /// Ikon yang ditampilkan.
  final IconData icon;

  /// Apakah item ini dapat diklik/navigasi.
  final bool isActive;

  /// Route tujuan; null jika [isActive] == false.
  final String? route;
}

// ---------------------------------------------------------------------------
// Agregat data dashboard
// ---------------------------------------------------------------------------

/// Seluruh data yang diperlukan layar dashboard.
class DashboardData {
  const DashboardData({
    required this.status,
    required this.condition,
    required this.chartPoints,
    required this.eggStats,
    required this.features,
  });

  final IncubatorStatus status;
  final IncubatorCondition condition;

  /// Titik-titik data untuk grafik tren 24 jam.
  final List<ChartDataPoint> chartPoints;

  final EggStats eggStats;

  /// Daftar item fitur utama yang ditampilkan di dashboard.
  final List<MainFeature> features;
}
