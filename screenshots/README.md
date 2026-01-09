# Screenshots Folder

📸 **Cara mengambil screenshots:**

## Option 1: Dari Android Emulator (Recommended)

1. **Run aplikasi:**
   ```bash
   flutter run
   ```

2. **Ambil screenshot tiap screen:**
   - Tekan `Ctrl + S` di emulator
   - Atau klik icon 📷 (camera) di emulator toolbar
   - Screenshots auto-save ke: `C:\Users\YourName\Pictures\`

3. **Required Screenshots (6 total):**
   - `home_screen.png` - Home screen dengan list materi
   - `detail_screen.png` - Detail screen satu materi
   - `upload_screen.png` - Form upload materi baru
   - `favorites_screen.png` - List materi favorit
   - `downloads_screen.png` - Riwayat download
   - `statistics_screen.png` - Charts dan statistik

4. **Rename dan move ke folder ini:**
   ```bash
   # Copy dari Pictures ke screenshots/
   copy "C:\Users\YourName\Pictures\*.png" screenshots\
   
   # Rename sesuai nama di atas
   ```

## Option 2: Dari Physical Device

1. Navigate ke setiap screen
2. Screenshot (biasanya: Power + Volume Down)
3. Transfer ke PC via USB
4. Copy ke folder `screenshots/`
5. Rename sesuai list di atas

## Screenshot Guidelines

✅ **DO:**
- Screenshot dalam portrait mode
- Pastikan UI lengkap terlihat
- Gunakan data dummy yang menarik
- Screenshot dengan pencahayaan baik

❌ **DON'T:**
- Jangan screenshot dengan data kosong
- Jangan screenshot yang blur
- Jangan screenshot dengan error

## Setelah Screenshots Ready

Update README.md jika ukuran gambar terlalu besar/kecil:
```markdown
<img src="screenshots/home_screen.png" width="250" alt="Home Screen"/>
```

Adjust `width` value sesuai kebutuhan (200-300 recommended).
