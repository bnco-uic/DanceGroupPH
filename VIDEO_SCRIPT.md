# Demo Video Script (about 2:45)

**Before recording:**
- Start XAMPP (Apache + MySQL) and re-import `database/dance_troupph.sql` so the data is clean.
- Launch the app once so Google Fonts are cached.
- Open these browser tabs:
  1. `http://localhost/api/dance_groups.php`
  2. phpMyAdmin → `dance_troupph` → `dance_groups`
  3. the GitHub repo
- Screen: the emulator or a mirrored phone next to the browser.

| Time | Scene | What to show | What to say |
|---|---|---|---|
| 0:00–0:15 | **1. Intro** | App dashboard | "Hi, I'm ___. This is Sayaw Pilipinas, a Flutter app for managing Philippine dance groups. It uses my own PHP REST API with MySQL, and the Open-Meteo weather API." |
| 0:15–0:30 | **2. API JSON** | Browser tab: `dance_groups.php` | "This is my PHP API. A GET request returns every group as JSON, in a success, message, data envelope. The app reads this same endpoint." |
| 0:30–0:50 | **3. Dashboard + weather** | Stat cards, style bars, weather card; tap **refresh** on the weather card | "The dashboard counts the groups, total dancers, and active groups from the database. This card is the third-party API. The app turns the city into coordinates with the geocoding API, then gets live weather. I'll tap refresh to fetch it again." |
| 0:50–1:15 | **4. Grid, search, filter, detail** | Browse → grid; type "Davao" in search; clear; tap the **Festival** chip; tap a card | "Here's the responsive grid. I can search by name or city, and filter by dance style. Tapping a card opens the detail screen, and the avatar animates across with a Hero animation. It also shows the weather for this group's city." |
| 1:15–1:45 | **5. Create** | Add group → tap **Add group** with an empty form (red errors) → fill in: "Mindanao Pride Dancers", Cultural, Davao Region, Davao City, 2020, 35 → Save | "First I'll save an empty form: each field shows its own error, and the PHP API has the same rules. Now I'll fill it in properly and save. The new group appears at the top right away, with no manual refresh." |
| 1:45–2:05 | **6. Edit** | Open the new group → **Edit** → change members to 40 → **Save changes** | "Edit opens the same form, already filled in. I'll change the member count and save. The API receives a PUT request and the detail screen updates." |
| 2:05–2:20 | **7. Delete** | **Delete** → show the dialog → **Delete** | "Delete asks for confirmation first: 'This cannot be undone.' I'll confirm, and the group is removed from the list." |
| 2:20–2:35 | **8. phpMyAdmin proof** | phpMyAdmin → Browse `dance_groups` (refresh) | "In phpMyAdmin you can see the edit was saved, and the deleted group is gone. So the app really changes the database." (Tip: pause before step 7 to show the edited row first.) |
| 2:35–2:45 | **9. GitHub** | Repo page → README (Third-Party API line), `backend/` folder | "Everything is on GitHub: the Flutter app, the PHP backend, the SQL file, and the README with the Open-Meteo API URL. Thank you!" |

**Tips:**
- Keep it under 3 minutes; practice once with a timer.
- Zoom the browser to about 125% so the JSON is readable.
- If the weather card shows an error, tap Retry. That also demonstrates the error state.
