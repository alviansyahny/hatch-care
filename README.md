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