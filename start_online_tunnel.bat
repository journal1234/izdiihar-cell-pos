@echo off
title IZDIIHAR CELL - JEMBATAN AKSES ONLINE HP (PAKET DATA)
color 0B
cls
echo ===================================================================
echo        IZDIIHAR CELL - AKSES ONLINE HP (PAKET DATA PRIBADI)
echo ===================================================================
echo.
echo Sedang membuat link internet aman untuk Kasir 1...
echo Mohon tunggu 5-10 detik...
echo.
echo ===================================================================
echo  PETUNJUK KASIR:
echo  1. Cari baris bertuliskan: https://xxxxxx.lhr.life di bawah ini.
echo  2. Salin link tersebut atau SCAN QR CODE yang muncul menggunakan
echo     kamera HP Kasir.
echo  3. Kasir dapat membuka aplikasi kasir dari HP dengan paket data
echo     pribadi di mana saja, tanpa harus konek ke Wi-Fi toko!
echo.
echo  PENTING: Jendela CMD ini HARUS TETAP DIBUKA selama kasir bertugas!
echo ===================================================================
echo.

:loop
echo [Menghubungkan ke server tunnel online...]
ssh -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o StrictHostKeyChecking=no -R 80:127.0.0.1:3000 nokey@localhost.run

echo.
echo [INFO] Koneksi terputus sementara. Menghubungkan ulang secara otomatis dalam 3 detik...
timeout /t 3 /nobreak >nul
goto loop

