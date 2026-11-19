import 'package:hatch_care/features/auth/domain/models/auth_models.dart';

/// Repository API autentikasi HATCH-CARE.
///
/// Implementasi ada di lapisan `data` — layar tidak boleh memanggil HTTP
/// langsung.
abstract interface class AuthRepository {
  /// Mendaftarkan akun baru; mengembalikan sesi (user + token).
  Future<AuthSession> register({
    required String name,
    required String username,
    required String email,
    required String password,
  });

  /// Login memakai email atau username; mengembalikan sesi (user + token).
  Future<AuthSession> login({required String login, required String password});

  /// Mengambil data pengguna berdasarkan token.
  Future<AuthUser> me({required String token});

  /// Menghapus (mencabut) token pada server.
  Future<void> logout({required String token});
}
