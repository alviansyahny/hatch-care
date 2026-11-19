/// Model domain untuk fitur autentikasi HATCH-CARE.
library;

/// Data pengguna yang dikembalikan server setelah login/registrasi.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
  });

  final int id;
  final String name;
  final String username;
  final String email;
}

/// Sesi pengguna: data pengguna plus token API Sanctum.
class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final AuthUser user;
}
