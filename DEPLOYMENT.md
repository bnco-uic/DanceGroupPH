# Deployment Guide

Hosting is **not decided yet**. This guide covers the local XAMPP setup used for development and the demo, then compares the online hosting options.

## Part 1: Local (XAMPP)

### 1. Database
1. Start **Apache** and **MySQL** in the XAMPP Control Panel.
2. Open `http://localhost/phpmyadmin`.
3. Click the **SQL** tab, paste the contents of `database/dance_troupph.sql`, and click **Go**.
4. Check: the database `dance_troupph` should have a table `dance_groups` with 12 rows.

> Already created the database yourself? Select `dance_troupph` on the left, then use `database/dance_troupph_hosting.sql`. It has no `CREATE DATABASE` or `USE` lines.

### 2. Backend
1. Copy `backend/config/config.example.php` to `backend/config/config.php`.
2. Fill in the values. For XAMPP: user `root`, password empty, database `dance_troupph`.
3. Make the API reachable at `http://localhost/api`. In PowerShell:
   ```powershell
   New-Item -ItemType Junction -Path C:\xampp\htdocs\api -Target C:\Users\<you>\DanceGroupPH\backend\api
   ```
   The junction points to the repo, so code changes are live right away. `config.php` is found through `backend/config/`.
4. Open `http://localhost/api/health.php`. You should see `"success": true`.

### 3. App
Run `run_app.bat` and choose:

| Option | Device | API URL used |
|---|---|---|
| 1 | Android emulator | `http://10.0.2.2/api` |
| 2 | Real phone (USB, same Wi-Fi) | `http://<PC Wi-Fi IP>/api` |
| 3 | Online server | your HTTPS URL |
| 4 | Chrome | `http://localhost/api` |

**Phone can't connect?**
- Check the IP with `ipconfig` (use the Wi-Fi adapter's IPv4 address).
- Make sure the phone is on the same Wi-Fi.
- Allow **Apache HTTP Server** through Windows Defender Firewall for private networks.
- Test in the phone's browser first: `http://<PC IP>/api/health.php`.

## Part 2: Online hosting options

The app only needs one thing online: a **PHP 8 + MySQL** server reachable over **HTTPS**. Then run the app with option 3 and that URL.

| Option | Cost | Pros | Cons |
|---|---|---|---|
| **Free PHP hosting** (InfinityFree, Freehostia Chocolate, etc.) | Free | phpMyAdmin included; upload files with the File Manager or FTP | May block PUT/DELETE (use the `_method` fallback); some add anti-bot pages that break app requests; Freehostia rejects DuckDNS subdomains as a domain |
| **Paid shared hosting** (Hostinger, etc.) | ~₱100–200 per month | Reliable, free SSL, phpMyAdmin, custom domain | Costs money |
| **VPS** (DigitalOcean, AWS Lightsail, etc.) | ~$4–6 per month | Full control, real PUT/DELETE | You install and secure Apache, PHP, and MySQL yourself; more work |
| **My PC + DuckDNS + port forwarding** | Free | Uses the XAMPP you already have | PC must stay on; router access needed; getting HTTPS takes extra setup; exposes your PC to the internet |

**Recommendation for a midterm demo:** record the demo on local XAMPP (emulator or phone). That's fully allowed by the rubric and has the fewest surprises. Add online hosting only if your professor requires it.

### General steps for any PHP host
1. Create a MySQL database in the host's control panel. Note the host, database name (often prefixed, e.g. `abc123_dance`), user, and password.
2. In phpMyAdmin, select that database and import `database/dance_troupph_hosting.sql`.
3. Upload `backend/api/` and `backend/config/` to the site so the structure is:
   ```
   public_html/api/dance_groups.php
   public_html/api/health.php
   public_html/config/db.php
   public_html/config/config.php   (created on the server with the real credentials)
   ```
4. Open `https://yourdomain/api/health.php` and check for `"success": true`.
5. Test PUT: if updating in the app fails with **405** or **403**, run with the fallback:
   ```
   flutter run --dart-define=API_BASE_URL=https://yourdomain/api --dart-define=USE_METHOD_OVERRIDE=true
   ```
   (`run_app.bat` option 3 asks you about this.)
6. Never upload `config.php` to GitHub. Create it only on the server.
