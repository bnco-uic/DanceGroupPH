@echo off
REM ============================================================
REM  Sayaw Pilipinas - quick public demo from this PC
REM  1. Builds the web app (API on the same address: /api)
REM  2. Serves ONLY the app + API on 127.0.0.1:8090 (not phpMyAdmin)
REM  3. Opens a free Cloudflare quick tunnel -> public https link
REM  The link works only while this window stays open and the PC is on.
REM  Needs: XAMPP MySQL running, and cloudflared installed:
REM     winget install Cloudflare.cloudflared
REM ============================================================
cd /d "%~dp0"

REM Find cloudflared: on PATH, or in its default install folder
REM (VS Code only sees new PATH entries after a full restart).
set CLOUDFLARED=
where cloudflared >nul 2>nul && set CLOUDFLARED=cloudflared
if not defined CLOUDFLARED if exist "C:\Program Files (x86)\cloudflared\cloudflared.exe" set CLOUDFLARED="C:\Program Files (x86)\cloudflared\cloudflared.exe"
if not defined CLOUDFLARED if exist "C:\Program Files\cloudflared\cloudflared.exe" set CLOUDFLARED="C:\Program Files\cloudflared\cloudflared.exe"
if not defined CLOUDFLARED (
  echo cloudflared is not installed. Run this first, then reopen the terminal:
  echo     winget install Cloudflare.cloudflared
  goto end
)

echo Building the web app...
call flutter build web --dart-define=API_BASE_URL=/api
if errorlevel 1 goto end

echo Starting the app + API server on http://127.0.0.1:8090 ...
start "Sayaw demo server (keep open)" C:\xampp\php\php.exe -S 127.0.0.1:8090 -t build\web demo_server.php

echo.
echo Opening the public tunnel. Look for a line like:
echo     https://something-random.trycloudflare.com
echo Send that link to your teacher. Press Ctrl+C here to stop sharing.
echo.
%CLOUDFLARED% tunnel --url http://127.0.0.1:8090

:end
echo.
pause
