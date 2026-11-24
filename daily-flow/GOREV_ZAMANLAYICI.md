# Görev Zamanlayıcı (Scheduled Tasks)

Tüm görevler `Monster` kullanıcısıyla çalışır. XML export'ları `scheduled-tasks/` klasöründedir.

| Görev adı | Zaman | Amaç |
|---|---|---|
| `\TJK Gunluk Beyer Sonuc ve Program` | Her gün 22:00 | Beyer program/sonuç raporları + Desktop\beyer raporu |
| `\KilitYarisDailyReport` | Her gün 22:00 | Kilit yarış raporları |
| `\TJKGunlukRapor_2200` | Her gün 22:00 | İstatistik/galop raporları |
| `\GidisatOtomasyonGunluk2200` | Her gün 22:00 | Tempo (frontrunner) raporları |
| `\SpoodymanSiteYukle2230` | Her gün 22:05 | Siteye yükleme (kopyalama + kartlar + sitemap + commit/push) |
| `\TJK Gunluk Diyarbakir Beyer` | Cumartesi 23:59 (haftalık) | Cumartesi tam akışı (Diyarbakır son koşusu 23:30) |

## Çalışma sırası

1. 22:00'da 4 görev paralel başlar.
2. 22:05 site yükleme görevi başlar, önce 4 görevin bitmesini bekler (en fazla 2 saat).
3. Hepsi bitince site yükleme devam eder.
4. Cumartesi günü 22:00 akışı atlanır; 23:59 tam akışı (`--saturday-full --site-upload`) çalışır.

## Görev komutları (özet)

- `\TJK Gunluk Beyer Sonuc ve Program`:
  - `C:\Users\Monster\Documents\Codex\2026-05-25\tjk-org-sitesinden-son-1-y\tjk_beyer_project\run_daily_full_flow.bat`
- `\KilitYarisDailyReport`:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Monster\Documents\Codex\kilit_yaris_projesi\run_daily_kilit_yaris_after_beyer.ps1"`
  - Start in: `C:\Users\Monster\Documents\Codex\kilit_yaris_projesi`
- `\TJKGunlukRapor_2200`:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Monster\Documents\Codex\istatistik_projesi\run_daily_pipeline_serialized.ps1"`
  - Start in: `C:\Users\Monster\Documents\Codex\istatistik_projesi`
- `\GidisatOtomasyonGunluk2200`:
  - `C:\Users\Monster\AppData\Local\Programs\Python\Python313\python.exe "C:\Users\Monster\Documents\Codex\2026-06-02\mevcut-tjk-beyer-accurace-sistemini-bozma\gidisat_avantaji\work\daily_gidisat_otomasyon.py"`
  - Start in: `...\gidisat_avantaji`
- `\SpoodymanSiteYukle2230`:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Monster\OneDrive\Belgeler\GitHub\spoodyman\scripts\site-yukle-22-30.ps1"`
- `\TJK Gunluk Diyarbakir Beyer`:
  - `C:\Users\Monster\Documents\Codex\2026-05-25\tjk-org-sitesinden-son-1-y\tjk_beyer_project\run_daily_diyarbakir_results.bat`

Görevleri yeniden oluşturmak için XML'leri import edin:
`schtasks /Create /TN "GorevAdi" /XML "daily-flow\scheduled-tasks\GorevAdi.xml" /F`