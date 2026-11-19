/// DTO (Data Transfer Object) mentah dari backend Laravel untuk auth.
///
/// Semua field parsing tahan terhadap null dan field yang hilang.
/// Konversi ke model domain dilakukan di lapisan repository.
library;

int? _asInt(Object? value) => value is num ? value.toInt() : null;

String? _asString(Object? value) => value is String ? value : null;

/// Isi objek `user` dari response `/api/register` dan `/api/login`.
class AuthUserDto {
  const AuthUserDto({this.id, this.name, this.username, this.email});

  final int? id;
  final String? name;
  final String? username;
  final String? email;

  factory AuthUserDto.fromJson(Object? json) {
    if (json is! Map) return const AuthUserDto();
    return AuthUserDto(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      username: _asString(json['username']),
      email: _asString(json['email']),
    );
  }
}

/// Isi response `/api/register` dan `/api/login`: `user` + `token`.
class AuthSessionDto {
  const AuthSessionDto({this.user, this.token});

  final AuthUserDto? user;
  final String? token;

  factory AuthSessionDto.fromJson(Object? json) {
    if (json is! Map) return const AuthSessionDto();
    return AuthSessionDto(
      user: AuthUserDto.fromJson(json['user']),
      token: _asString(json['token']),
    );
  }
}

/// Isi objek `user` dari response `/api/user`.
class AuthMeDto {
  const AuthMeDto({this.user});

  final AuthUserDto? user;

  factory AuthMeDto.fromJson(Object? json) {
    if (json is! Map) return const AuthMeDto();
    return AuthMeDto(user: AuthUserDto.fromJson(json['user']));
  }
}
