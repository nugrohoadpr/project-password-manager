3. FITUR UTAMA
3.1 Autentikasi & Keamanan
•	Master Password: Satu password utama untuk mengakses semua data
•	Auto-Lock: Otomatis terkunci setelah periode inaktif
•	Enkripsi: AES-256 bit encryption untuk semua data
3.2 Password Management
•	Password Vault: Penyimpanan password terorganisir
•	Password Generator: Generator password kuat dengan customizable options
•	Password Strength Checker: Analisis kekuatan password
•	Duplicate Detection: Deteksi password yang digunakan berulang
•	Secure Notes: Simpan catatan sensitif
3.3 Item Types
•	Login Credentials (username & password)
•	Secure Notes
3.4 Search & Filter
•	Quick Search dengan real-time results
•	Filter berdasarkan kategori
•	Recently Used items
•	Favorites/Starred items
3.5 Security Features
•	Weak Password Alert: Peringatan password lemah
•	Reused Password Alert: Peringatan password yang dipakai berulang
3.6 Backup & Sync
•	Local Backup
•	Import from other password managers
•	Export data (encrypted)

3.7 Fitur premium
- Pambatasn 50 password, jika lebih bisa bayar
- Fitur MFA
- export import to another device

4. Technical Specifications 
Technology Stack: 
1.	Framework yang akan digunakan (Flutter) 
2.	database (SQLite)
5. Timeline & Milestones Aplikasi Password Saver (7 Minggu)
1.	Minggu 1: Persiapan dan Desain (4-10 November 2025)
Apa yang dikerjakan	 : Menyelesaikan dokumen PRD (rencana produk), membuat sketsa tampilan aplikasi (wireframe) untuk semua halaman, membuat desain warna dan tampilan final untuk halaman utama.
Setup Teknis	: Install Flutter di komputer, buat folder project baru, rencanakan struktur folder dan file, setup database SQLite.
Target Selesai	: Desain sudah disetujui, struktur project sudah siap untuk dikoding.
2.	Minggu 2: Sistem Login (11-17 November 2025)
Apa yang dikerjakan	: Buat halaman untuk daftar akun baru dengan master password, buat sistem cek kekuatan password (lemah/kuat), buat halaman login, simpan password master di database dengan aman.
Halaman yang dibuat	: Halaman welcome (onboarding 3 layar), halaman buat password master, halaman login.
Testing	: Cek apakah password tersimpan dengan aman, cek apakah bisa login dengan benar.
Target Selesai		: User sudah bisa daftar dan login menggunakan master password.
3.	Minggu 3: Vault Password Utama (18-24 November 2025)
Apa yang dikerjakan	: Buat fitur untuk menyimpan password baru, tampilkan daftar password yang sudah disimpan, buat fitur edit dan hapus password, enkripsi semua password dengan AES-256, Halaman yang dibuat: Dashboard/beranda dengan daftar password, halaman tambah password baru, halaman edit password, halaman detail password.
Testing	: Cek apakah password tersimpan dengan enkripsi, cek apakah bisa tambah/edit/hapus password.
Target Selesai	: User sudah bisa menyimpan dan mengelola password dengan aman.
4.	Minggu 4: Generator Password & Pencarian (25 Nov - 1 Desember 2025)
Apa yang dikerjakan	:Buat generator password otomatis dengan pilihan panjang karakter, tambahkan pilihan huruf besar/kecil/angka/simbol, buat fitur pencarian password, buat filter berdasarkan kategori, tambahkan fitur favorite (bintang).
Halaman yang dibuat	: Halaman generator password dengan slider, halaman search dengan hasil pencarian, halaman kategori dalam bentuk grid.
Testing	: Cek apakah password yang digenerate kuat, cek kecepatan pencarian.
Target Selesai	: User bisa generate password kuat dan mencari password dengan cepat.
5.	Minggu 5: Fitur Keamanan & Auto-Lock (2-8 Desember 2025)
Apa yang dikerjakan	: Buat sistem deteksi password lemah, buat sistem deteksi password yang sama dipakai berulang, buat sistem auto-lock (kunci otomatis) setelah beberapa waktu tidak dipakai, buat fitur secure notes (catatan rahasia).
Halaman yang dibuat 	: Halaman security insights (tampilkan berapa password lemah/duplikat/kuat), halaman settings dengan pilihan auto-lock, halaman untuk secure notes.
Testing	: Cek apakah deteksi password lemah akurat, cek apakah auto-lock berfungsi sesuai waktu yang dipilih.
Target Selesai	: Fitur keamanan aktif, app bisa auto-lock, secure notes berfungsi.
6.	Minggu 6: Backup & Finishing (9-15 Desember 2025)
Apa yang dikerjakan	: Buat fitur backup lokal (simpan data ke file), buat fitur import dari file CSV, buat fitur export data, tambahkan dark mode (tema gelap), tambahkan animasi dan transisi antar halaman, perbaiki tampilan yang masih kurang bagus.
Penyempurnaan	:Tambah loading animation, perbaiki error handling (tampilan saat ada error), optimasi kecepatan aplikasi, gesture swipe untuk copy/delete.
Testing	: Test backup dan restore data, test dark mode, test performa aplikasi di berbagai ukuran layar.
Target Selesai	: Backup berfungsi, tampilan sudah sempurna, aplikasi cepat dan responsif.
7.	Minggu 7: Testing Final & Persiapan Launch (16-22 Desember 2025)
Apa yang dikerjakan	: Test semua fitur dari awal sampai akhir, test keamanan aplikasi, coba di berbagai versi Android dan ukuran layar, perbaiki semua bug yang ditemukan.
Persiapan Launch	:Buat screenshot untuk Play Store, tulis deskripsi aplikasi, buat icon aplikasi, buat privacy policy dan terms of service, sign aplikasi untuk release, submit ke Play Store.
Testing 	: Test dengan pengguna asli (beta testing), cek apakah ada crash atau error, cek kecepatan di device berbeda.
Target Selesai	: Aplikasi siap diluncurkan, sudah disubmit ke Play Store, materi marketing siap

