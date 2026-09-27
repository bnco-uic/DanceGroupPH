@echo off
REM ============================================================
REM  Sayaw Pilipinas - run helper
REM  Picks the right API_BASE_URL for where the app is running.
REM  "localhost" on the PC is NOT "localhost" on the phone:
REM    emulator  -> 10.0.2.2 (the emulator's name for your PC)
REM    real phone -> your PC's Wi-Fi IP (phone on the same Wi-Fi)
REM    online    -> your HTTPS hosting URL
REM ============================================================
cd /d "%~dp0"

echo.
echo  ==========================================
echo    Sayaw Pilipinas - choose where to run
echo  ==========================================
echo    1. Android emulator   (XAMPP on this PC)
echo    2. Android phone USB  (XAMPP on this PC, same Wi-Fi)
echo    3. Online server      (HTTPS hosting)
echo    4. Chrome             (XAMPP on this PC)
echo    5. Get packages only  (flutter pub get)
echo  ==========================================
set /p CHOICE="Enter 1-5: "

if "%CHOICE%"=="1" goto emulator
if "%CHOICE%"=="2" goto phone
if "%CHOICE%"=="3" goto online
if "%CHOICE%"=="4" goto chrome
if "%CHOICE%"=="5" goto pubget
echo Invalid choice.
goto end

:emulator
call flutter pub get
call flutter run -d emulator --dart-define=API_BASE_URL=http://10.0.2.2/api
goto end

:phone
echo.
echo Your PC's IPv4 addresses (use the Wi-Fi one, e.g. 192.168.1.5):
ipconfig | findstr /i "IPv4"
echo.
set /p PCIP="Enter your PC's Wi-Fi IP: "
echo Tip: if the phone cannot connect, allow Apache in Windows Firewall.
call flutter pub get
call flutter run --dart-define=API_BASE_URL=http://%PCIP%/api
goto end

:online
echo.
set /p ONLINEURL="Enter your API URL (e.g. https://yourdomain.com/api): "
set /p OVERRIDE="Does your host block PUT/DELETE? (y/n): "
set OVERRIDEFLAG=false
if /i "%OVERRIDE%"=="y" set OVERRIDEFLAG=true
call flutter pub get
call flutter run --dart-define=API_BASE_URL=%ONLINEURL% --dart-define=USE_METHOD_OVERRIDE=%OVERRIDEFLAG%
goto end

:chrome
call flutter pub get
call flutter run -d chrome --dart-define=API_BASE_URL=http://localhost/api
goto end

:pubget
call flutter pub get
goto end

:end
echo.
pause
