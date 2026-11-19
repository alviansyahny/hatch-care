import 'package:hatch_care/features/egg_check/domain/models/candling_job_models.dart';

/// Repository data backend IoT untuk fitur Egg Check.
///
/// Implementasi ada di lapisan `data` — layar tidak boleh memanggil HTTP
/// langsung.
abstract interface class EggCheckRepository {
  /// Mengambil status koneksi perangkat ESP32-CAM.
  Future<EggDeviceStatus> fetchDeviceStatus();

  /// Mengambil riwayat tangkapan candling (maksimal 20 job terakhir).
  Future<List<EggCaptureSummary>> fetchCaptureHistory();

  /// Mengambil detail satu job (status, hasil AI, tahapan CV).
  Future<EggCaptureDetail> fetchJobDetail(int jobId);

  /// Meminta job capture baru; mengembalikan ID job untuk dipolling.
  Future<int> requestCapture(CaptureParams params);
}
