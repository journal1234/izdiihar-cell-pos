@echo off
title IZDIIHAR CELL - POS SERVER
echo ========================================================
echo         IZDIIHAR CELL - APLIKASI KASIR & PEMBUKUAN
echo ========================================================
echo.
echo Menjalankan server lokal...
echo Akses Laptop : http://localhost:3000
echo Akses HP     : http://192.168.1.24:3000
echo.
echo Membuka browser otomatis...
start http://localhost:3000
node server.js
pause
