# 📱 IZDIIHAR CELL - Sistem Kasir POS & Pembukuan Konter Modern

Aplikasi Web Point of Sales (POS), Manajemen Stok Pulsa & Aksesoris, Buku Hutang Pelanggan, serta Pencatatan Buku Kas & Belanja Operasional Toko. Dirancang khusus untuk konter pulsa dan aksesoris HP dengan antarmuka modern (Dark & Light Theme), responsif untuk Laptop & HP (Mobile), dan mendukung cetak struk thermal 58mm.

---

## ✨ Fitur Utama

1. **Kasir POS & Transaksi Cepat**:
   - Transaksi penjualan pulsa, paket data, voucher, kartu perdana, dan aksesoris HP.
   - Metode pembayaran multi-channel: Tunai, QRIS, Transfer Bank, dan Catat Hutang Pelanggan.
   - Deteksi produk terlaris (*Hot / Best Seller*) dan filter kategori cepat.
   - Cetak struk kasir thermal 58mm & kirim nota rincian langsung ke WhatsApp pembeli.

2. **Manajemen Stok & Peringatan Habis**:
   - Pelacakan stok otomatis berkurang setiap transaksi.
   - Peringatan stok menipis (*low stock indicator*).
   - Fitur tambah stok / kulakan barang baru.

3. **Buku Hutang Pelanggan (Piutang)**:
   - Pencatatan nama pelanggan, nomor telepon, dan nominal hutang.
   - Fitur cicil hutang & pelunasan langsung tercatat ke uang kas masuk.

4. **Buku Kas & Belanja Operasional (Khusus Admin)**:
   - Pencatatan uang masuk operasional (tambahan modal, suntikan dana).
   - Pencatatan uang belanja operasional (token listrik PLN, transport/bensin, belanja stok voucher di grosir, konsumsi, kertas struk).
   - Rekap bulanan, grafik persentase kategori belanja, cetak rekap kas, dan ekspor ke CSV.

5. **Kontrol Laci Kasir (Cash Drawer & Shift)**:
   - Buka & tutup shift kasir dengan modal awal dan perhitungan sisa uang fisik di laci.
   - Bukti kas keluar dari laci langsung memotong saldo kasir secara real-time.

6. **Sinkronisasi Multi-Device (Real-Time)**:
   - Server Node.js ringan terhubung dengan `database.json`.
   - Dapat diakses bersamaan dari Laptop kasir dan HP Android/iPhone karyawan via Wi-Fi toko.

---

## 🚀 Cara Menjalankan Aplikasi

### Persyaratan:
- [Node.js](https://nodejs.org/) (versi 16 atau lebih baru)

### Menjalankan Server Lokal:
```bash
# Jalankan server
node server.js
```
Atau cukup klik dua kali file **`JALANKAN_KASIR_TOKO.bat`**.

Aplikasi akan aktif di:
- **Akses Laptop**: `http://localhost:3000`
- **Akses HP (WiFi Konter)**: `http://[IP-Laptop-Anda]:3000`

---

## 🔒 Hak Akses Pengguna
- **Pemilik Konter (Admin)**: PIN default `1234` (Akses penuh seluruh fitur, buku kas operasional, laba bersih, dan pengaturan).
- **Kasir Shift 1 (Pegawai)**: PIN default `1111` (Akses kasir POS, laci, dan pencatatan kas keluar toko).
- **Kasir Shift 2 (Pegawai)**: PIN default `2222` (Akses kasir POS, laci, dan pencatatan kas keluar toko).

---

## 📂 Struktur Berkas
- `index.html` : Halaman antarmuka utama (SPA)
- `app.js` : Logika aplikasi POS, laci kasir, dan pembukuan
- `styles.css` : Desain tema modern, Neo-Glassmorphism, animasi interaktif
- `server.js` : Backend server Node.js & sinkronisasi data real-time
- `database.json` : Berkas penyimpanan data lokal
- `sw.js` & `manifest.json` : Dukungan Progressive Web App (PWA) offline

