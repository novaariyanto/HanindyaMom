# HanindyaMom 👶💕

Aplikasi mobile terbaik untuk memantau perkembangan dan aktivitas bayi, dirancang khusus untuk ibu-ibu Indonesia.

## 🌟 Fitur Utama

### 📱 Autentikasi
- Login dengan email & password
- Registrasi akun baru
- Desain modern dengan ilustrasi ibu & bayi

### 🏠 Halaman Home
- Daftar profil bayi dengan foto, nama, dan umur otomatis
- Floating Action Button untuk menambah bayi baru
- Edit dan hapus profil bayi

### 👶 Manajemen Profil Bayi
- Input nama, tanggal lahir, foto, berat, dan tinggi
- Upload foto dengan Image Picker (kamera/galeri)
- Perhitungan umur otomatis

### 📊 Dashboard
- Ringkasan aktivitas harian (feeding, diaper, tidur)
- Grafik aktivitas 7 hari terakhir menggunakan Syncfusion Charts
- Tombol aksi cepat untuk menambah aktivitas

### 📅 Timeline
- Semua aktivitas bayi berurutan dari terbaru
- Filter berdasarkan kategori (feeding, diaper, tidur)
- Edit dan hapus aktivitas
- Tampilan card dengan ikon dan informasi detail

### 🍼 Pencatatan Feeding
- Jenis feeding: ASI Kiri, ASI Kanan, Formula, Pompa
- Input waktu mulai dan durasi
- Jumlah formula (untuk jenis formula)
- Catatan opsional

### 👶 Pencatatan Diaper
- Jenis: Pipis, Pup, Campuran
- Warna dan tekstur (untuk pup)
- Waktu ganti popok
- Catatan opsional

### 😴 Pencatatan Tidur
- Waktu mulai dan selesai tidur
- Perhitungan durasi otomatis
- Mode "sedang tidur" untuk bayi yang masih tidur
- Catatan kualitas tidur

### ⚙️ Settings
- Pengaturan bahasa (Indonesia/English)
- Unit pengukuran (ml/oz)
- Auto-detect timezone
- Notifikasi pengingat
- Backup dan export data
- Kebijakan privasi & bantuan

## 🎨 Desain UI

- **Tema Warna**: Pink pastel (#F8BBD0) + Putih dengan aksen abu soft
- **Typography**: Google Fonts Poppins untuk keterbacaan optimal
- **Material Design 3**: Komponen modern dan user-friendly
- **Bottom Navigation**: Home, Timeline, Dashboard, Settings
- **Card UI**: Setiap log aktivitas menggunakan card yang clean
- **Responsive**: Optimized untuk berbagai ukuran layar

## 🚀 Teknologi

- **Flutter**: Framework UI cross-platform
- **Material Design 3**: Design system terbaru
- **Google Fonts**: Typography Poppins
- **Syncfusion Flutter Charts**: Grafik interaktif
- **Image Picker**: Upload foto dari kamera/galeri
- **Intl**: Internationalization dan format tanggal
- **Shared Preferences**: Local storage

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  google_fonts: ^6.1.0
  syncfusion_flutter_charts: ^24.2.9
  image_picker: ^1.0.4
  provider: ^6.1.1
  intl: ^0.19.0
  shared_preferences: ^2.2.2
```

## 🏗️ Struktur Proyek

```
lib/
├── main.dart                 # Entry point aplikasi
├── theme/
│   └── app_theme.dart       # Tema dan styling
├── models/
│   ├── baby.dart            # Model data bayi
│   ├── feeding.dart         # Model data feeding
│   ├── diaper.dart          # Model data diaper
│   └── sleep.dart           # Model data tidur
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── baby/
│   │   └── baby_form_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── timeline/
│   │   └── timeline_screen.dart
│   ├── activities/
│   │   ├── feeding_form_screen.dart
│   │   ├── diaper_form_screen.dart
│   │   └── sleep_form_screen.dart
│   ├── settings/
│   │   └── settings_screen.dart
│   └── main_screen.dart     # Bottom navigation
```

## 🚀 Cara Menjalankan

1. **Clone repository**
```bash
git clone <repository-url>
cd hanindyamom
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Jalankan aplikasi**
```bash
flutter run
```

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web (responsive)
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🎯 Target Pengguna

Aplikasi ini dirancang khusus untuk:
- Ibu muda di Indonesia
- Orang tua baru yang ingin memantau perkembangan bayi
- Keluarga yang peduli dengan kesehatan dan pola bayi

## 🔮 Roadmap

- [ ] Integrasi backend API
- [ ] Sinkronisasi cloud
- [ ] Notifikasi push
- [ ] Export data ke PDF
- [ ] Grafik pertumbuhan bayi
- [ ] Milestone perkembangan
- [ ] Konsultasi dengan dokter
- [ ] Komunitas ibu

## 🤝 Kontribusi

Kontribusi sangat diterima! Silakan buat issue atau pull request.

## 📄 Lisensi

MIT License - lihat file [LICENSE](LICENSE) untuk detail.

---

**Dibuat dengan ❤️ untuk ibu-ibu Indonesia**
