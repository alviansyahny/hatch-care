# Panduan Kontribusi HATCH-CARE

## Branch

- `main`: kode siap rilis. Dilarang push langsung.
- `develop`: gabungan semua fitur. Dilarang push langsung.
- `feature/nama-fitur`: fitur baru, dibuat dari `develop`
- `fix/nama-bug`: perbaikan bug
- `chore/nama-tugas`: urusan non-fitur (config, dokumen, dependency)

## Alur kerja

1. `git switch develop` lalu `git pull`
2. `git switch -c feature/nama-fitur`
3. Kerjakan, lalu commit
4. `git push -u origin feature/nama-fitur`
5. Buka Pull Request dengan base `develop`
6. Tunggu CI hijau dan minta review
7. Squash and merge, lalu hapus branch

## Format commit

`tipe(scope): deskripsi singkat`

Contoh:

- `feat(auth): add login page`
- `fix(home): resolve overflow on small screens`
- `docs(readme): update setup instructions`
- `chore(deps): add riverpod`

Tipe: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`, `perf`, `build`.

Aturan:

- Satu commit untuk satu perubahan.
- Deskripsi berbahasa Inggris, huruf kecil, diawali kata kerja, tanpa titik.
- Dilarang commit dengan pesan `update`, `fix`, `asdf`, atau `wip`.

## Sebelum membuka Pull Request

```bash
dart format .
flutter analyze
flutter test
```

Ketiganya harus lolos.

## Keamanan

Jangan commit password, API key, atau file `.env`.