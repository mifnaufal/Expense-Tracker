# Expense Tracker

Aplikasi pembelajaran Flutter untuk mencatat pemasukan dan pengeluaran. Data disimpan dalam berkas di dalam proyek, dan Shelf backend lokal memastikan setiap operasi CRUD (buat, baca, ubah, hapus) tersinkronisasi baik di platform mobile maupun web.

## Prasyarat

- Flutter SDK 3.19 atau lebih baru (otomatis menyertakan Dart 3.3+).
- Git terpasang pada sistem.
- Terminal PowerShell (Windows) atau shell sejenis.
- Browser modern (Chrome direkomendasikan) bila ingin menjalankan mode web.

## Langkah Menjalankan Proyek (setelah clone)

## Untuk langkah simpelnya, bisa scroll sampai bawah ya :))))

1. **Clone repository dan masuk ke folder proyek**

   ```powershell
   git clone https://github.com/mifnaufal/Expense-Tracker.git
   cd Expense-Tracker
   ```

2. **Pasang seluruh dependency Flutter**

   ```powershell
   flutter pub get
   ```

3. **Jalankan backend + aplikasi secara otomatis**

   ```powershell
   dart run tool/dev_launcher.dart
   ```

   Perintah ini akan:

   - Mengecek apakah backend Shelf sudah aktif di `http://localhost:8080`.
   - Menyalakannya bila belum ada, lalu menunggu hingga endpoint `/health` siap.
   - Menjalankan `flutter run -d chrome` dengan `--dart-define=EXPENSE_BACKEND_URL=http://localhost:8080`.

   Setelah Flutter berjalan, tekan `r` untuk hot reload, `R` untuk hot restart, dan `q` atau `CTRL+C` untuk keluar. Launcher akan mematikan backend secara otomatis saat Anda menghentikan Flutter.

4. **Menyesuaikan parameter (opsional)**

   Tambahkan argumen setelah `--` untuk meneruskan opsi apa pun ke `flutter run`. Contoh memaksa web server:

   ```powershell
   dart run tool/dev_launcher.dart -- -d web-server
   ```

   Opsi lain yang tersedia:

   - `--backend-port <port>`: mengganti port backend (mis. `--backend-port 9090`).
   - `--skip-flutter`: hanya menyalakan backend tanpa menjalankan Flutter (berguna bila ingin membuka beberapa terminal).

## Menjalankan Backend & Flutter Secara Manual (alternatif)

Jika ingin mengelola backend sendiri:

```powershell
cd backend
dart pub get
dart run bin/server.dart --port 8080
```

Biarkan proses tersebut aktif. Pada terminal baru, jalankan Flutter dengan `dart-define` yang sesuai:

```powershell
flutter run -d chrome --dart-define=EXPENSE_BACKEND_URL=http://localhost:8080
```

## Struktur Folder Penting

- `lib/` – kode utama aplikasi Flutter.
- `data/transactions.store` – berkas utama penyimpanan transaksi (format Base64 + pemisah pipa).
- `data/transactions.json` – data awal (seed) yang dimuat saat berkas utama kosong.
- `backend/` – proyek Shelf sederhana yang melayani permintaan CRUD.
- `tools/backend/` – varian backend untuk kebutuhan pengembangan.
- `tool/dev_launcher.dart` – skrip helper untuk menyalakan backend dan Flutter sekaligus.

## Lokasi Penyimpanan Data

Semua perubahan transaksi akan tersimpan ke `data/transactions.store` di dalam root proyek. Anda dapat meng-commit berkas ini untuk membagikan data contoh ke rekan lain.

## Menjalankan Tes

```powershell
flutter test
```

## Tips Troubleshooting

- Jika launcher gagal menyalakan backend, pastikan port 8080 (atau port kustom Anda) tidak dipakai aplikasi lain.
- Untuk mode web, pastikan browser mengizinkan akses ke `http://localhost:<port>`.
- Backend menulis log ke terminal dengan prefix `[backend]`; periksa bila terjadi error saat menyimpan data.
- Hapus `data/transactions.store` bila ingin mengulang data ke kondisi awal (seed dari `data/transactions.json`).

### Alternatif

Ini untuk para pengguna yang gak mau baca semuanya :)

step-by-step:

- flutter pub get
- flutter pub upgrade --major-versions
- cd backend (pastikan udah didalam projectnya rootnya)
- dart pub get
- dart run bin/server.dart
- buat terminal baru/keluar dari folder backend
- flutter run -d chrome (atau yang biasa kamu pake buat ngerun flutter)

note: tunggu processing dari dart shelfnya selesai setiap kali ngerun line ke 5

jadi deh :D
