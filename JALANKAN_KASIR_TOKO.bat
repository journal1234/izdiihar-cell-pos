@echo off
title IZDIIHAR CELL - PUSAT KASIR & SERVER TOKO
color 0B
cls

echo ===================================================================
echo               IZDIIHAR CELL - SISTEM KASIR POS & CLOUD
echo ===================================================================
echo.
echo  [1/2] Menyalakan Server Toko...
echo  [2/2] Membuka Halaman Kasir di Laptop...
echo.
echo ===================================================================
echo  PANDUAN AKSES DI HP KASIR:
echo  1. Pastikan HP Kasir terhubung ke Wi-Fi yang sama dengan laptop.
echo  2. Buka Google Chrome di HP, lalu ketik alamat IP yang tertera
echo     pada baris "- Akses HP (WiFi Toko)" di bawah ini.
echo  3. Masukkan PIN Kasir untuk mulai transaksi.
echo ===================================================================
echo.
echo  PENTING: Jangan tutup jendela hitam ini selama toko masih buka!
echo ===================================================================
echo.

:: Buka halaman POS otomatis di browser laptop
start http://localhost:3000

:: Jalankan server node
node server.js

pause
