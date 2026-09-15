# 📚 Edushare

Edushare adalah sebuah aplikasi berbasis Flutter yang digunakan oleh mahasiswa untuk berbagi catatan mata kuliah. Aplikasi ini dikembangkan menggunakan state management **GetX** dan struktur pengembangan **GetCLI**.

---

## 📝 Deskripsi Aplikasi
Aplikasi **Edushare** memungkinkan mahasiswa untuk:
- Mengunggah dan berbagi catatan materi perkuliahan
- Melakukan kolaborasi catatan
- Menggunakan fitur Speech-to-Text untuk mencatat lebih cepat
- Berkomunikasi melalui chat mahasiswa

Aplikasi ini dibuat sebagai bentuk kolaborasi tim dalam mata kuliah Rekayasa Interaksi.

---

## 🏗 Arsitektur Proyek
Proyek ini mengikuti pola arsitektur modular berbasis fitur dengan struktur yang terorganisir dalam folder `lib/app`, sehingga setiap area utama aplikasi dipisahkan sesuai fungsi dan tanggung jawabnya.

Struktur utama proyek mencakup:
- `lib/main.dart` → entry point aplikasi, inisialisasi `GetMaterialApp`, serta setup layanan utama seperti `AuthService`.
- `lib/app/modules` → modul utama aplikasi, seperti `auth`, `chat`, `collaboration`, `homepage`, `notes`, `settings`, dan `speech`.
- `lib/app/routes` → konfigurasi navigasi aplikasi dengan `AppPages` dan `AppRoutes`.
- `lib/app/services` → layanan bisnis dan integrasi eksternal seperti autentikasi, chat, notes, room, dan download.
- `lib/app/data` → repository dan konfigurasi akses data API serta manajemen state terkait domain aplikasi.
- `lib/app/models` → model data yang digunakan untuk representasi objek aplikasi.

Secara umum, aplikasi menggunakan pendekatan berbasis modul dan state management `GetX`, sehingga pengelolaan route, state, dan dependency injection lebih terstruktur serta mudah dikembangkan lebih lanjut.

---

## 🧩 Stack Teknologi
Berikut teknologi dan library yang digunakan dalam pengembangan Edushare:

- **Flutter** → framework utama untuk pengembangan aplikasi multiplatform.
- **Dart** → bahasa pemrograman utama yang digunakan oleh Flutter.
- **GetX** → state management, routing, dan dependency injection.
- **GetCLI** → struktur pengembangan proyek yang membantu pengelolaan modul dan fitur.
- **HTTP / Dio** → komunikasi data dengan API backend.
- **Speech-to-Text** → fitur perekaman suara menjadi teks.
- **Image Picker / File Picker / Open File / Share Plus** → pengelolaan media, dokumen, dan berbagi file.
- **Permission Handler** → pengelolaan izin akses perangkat.
- **Path Provider** → manajemen file dan direktori lokal.
- **PDFX / Just Audio / URL Launcher** → dukungan untuk file PDF, audio, dan link eksternal.
- **Device Info Plus / Intl** → pengolahan info perangkat dan format tanggal.

Dengan kombinasi teknologi tersebut, aplikasi dapat mengelola fitur kolaborasi, catatan, chat, hingga integrasi media dan dokumentasi dengan lebih optimal.

---

## 👨‍💻 Tim Pengembang

| Nama | NIM | Kelas | Alias |
|------|------|-------|-------|
| **Tegar Putra Gaori** | 202210370311106 | C | Tegar04 |
| **Nanda Adela Larasati Kuncoro** | 202210370311080 | C | GlooMy03 |
| **Muh Farlan** | 202210370311106 | C | FarlanTuruu |

---

## 🎨 Figma Low/High Fidelity
Link desain prototipe:
🔗 https://www.figma.com/design/na1EaLJPPvhmvXlhZuR5YP/Desain-RI--2022-076--2022-080--2022-106-?node-id=8-2&t=XFGsTS0BRs7ZQsv0-1

---

## 🗂 Pembagian Tugas

| Anggota | Tugas |
|---------|--------|
| **Tegar Putra Gaori** | Notes, Settings |
| **Nanda Adela Larasati Kuncoro** | Page Speech, Page Chat |
| **Muh Farlan** | Page Collaboration, Page Auth (Login, Register, Reset Password), Homepage |

---

## 🛠 Teknologi yang Digunakan
- **Flutter**
- **Dart**
- **GetX State Management**
- **GetCLI Project Structure**

---

## 📦 Struktur Folder Utama
```text
lib/
├── main.dart
├── app/
│   ├── data/
│   ├── models/
│   ├── modules/
│   ├── routes/
│   └── services/
├── assets/
│   └── gambar/
└── ...
```

---

## Total Download
 - ![Downloads](https://img.shields.io/github/downloads/FarlanTuruu/Aplikasi-Edushare/total)
 - ![Latest Downloads](https://img.shields.io/github/downloads/FarlanTuruu/Aplikasi-Edushare/latest/total)
 - ![Latest Release](https://img.shields.io/github/v/release/FarlanTuruu/Aplikasi-Edushare)
 - ![Release Date](https://img.shields.io/github/release-date/FarlanTuruu/Aplikasi-Edushare)
 - ![APK Downloads](https://img.shields.io/github/downloads/FarlanTuruu/Aplikasi-Edushare/latest/app-release.apk)