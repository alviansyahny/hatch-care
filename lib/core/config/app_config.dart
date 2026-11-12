/// Konfigurasi aplikasi HATCH-CARE.
///
/// Satu-satunya tempat menyimpan alamat server backend IoT.
/// Jangan tulis URL di widget atau repository — selalu baca dari sini.
abstract final class AppConfig {
  /// Alamat dasar server backend IoT (dipakai Egg Check dan Live).
  ///
  /// Bisa dioverride saat menjalankan aplikasi:
  /// `flutter run --dart-define=API_BASE_URL=https://host-lain.com`
  // TODO(api-base-url): defaultValue ini hanya untuk pengembangan dan harus
  // dicabut sebelum rilis (tanpa default, aplikasi gagal jelas daripada
  // diam-diam memakai server dev).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://iot.walker880.my.id',
  );

  /// Alamat dasar server API autentikasi (register/login/logout).
  ///
  /// Bisa dioverride saat menjalankan aplikasi:
  /// `flutter run --dart-define=AUTH_API_BASE_URL=https://host-lain.com`
  static const String authApiBaseUrl = String.fromEnvironment(
    'AUTH_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}
