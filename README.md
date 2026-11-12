# HATCH-CARE

Aplikasi mobile untuk monitoring penetasan telur: candling, kondisi inkubator,
dan riwayat status telur (Fertil, Infertil, Mortal, Menetas).

## Tech stack

- Flutter 3.38.9 (stable)
- State management: Riverpod (direncanakan)
- Routing: go_router (direncanakan)

## Prasyarat

- Flutter SDK 3.38.9
- Git
- Android Studio (untuk Android SDK) atau HP Android dengan USB debugging
- Editor dengan ekstensi Dart dan Flutter (Antigravity atau VS Code)

## Cara menjalankan

```bash
git clone https://github.com/alviansyahny/hatch-care.git
cd hatch-care
flutter pub get
flutter run
```

## Konfigurasi alamat server (backend IoT)

Alamat server backend IoT hanya disimpan di SATU tempat:
`lib/core/config/app_config.dart`.

- Default (pengembangan): `https://iot.walker880.my.id` — TODO di file tersebut
  mencatat bahwa default ini harus dicabut sebelum rilis.
- Untuk memakai server lain, lewat `--dart-define` (tanpa mengubah kode):

```bash
flutter run --dart-define=API_BASE_URL=https://server-lain.com
```

Semua request jaringan melewati satu klien HTTP bersama
(`lib/core/network/api_client.dart`), dipakai oleh repository tiap fitur
(Egg Check, Live Monitoring, Dashboard) — layar tidak memanggil HTTP langsung.

## Struktur folder

```
lib/
├── app/        # setup aplikasi, router, theme
├── core/       # kode yang dipakai lintas fitur
└── features/   # satu folder per fitur
```

## Alur kerja tim

Baca [CONTRIBUTING.md](CONTRIBUTING.md) sebelum mulai mengerjakan apa pun.

## Tim

- alviansyahny