# Manuel Komutlar

## Site yükleme

Belirli tarih:
```
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Monster\OneDrive\Belgeler\GitHub\spoodyman\scripts\site-yukle-22-30.ps1" -Tarih 24/11/2026
```

WhatIf (değişiklik yapmadan):
```
powershell -NoProfile -ExecutionPolicy Bypass -File "...\scripts\site-yukle-22-30.ps1" -Tarih 24/11/2026 -WhatIf
```

Force (Cumartesi tam akışı):
```
powershell -NoProfile -ExecutionPolicy Bypass -File "...\scripts\site-yukle-22-30.ps1" -Tarih 24/11/2026 -Force
```

Tür atla:
```
powershell ... -SkipTur @('istatistik','tempo')
```

Wrapper (günlük):
```
powershell -NoProfile -ExecutionPolicy Bypass -File "...\daily-update.ps1" -Tarih 24/11/2026
```

## 22:00 görevleri manuel

Beyer:
```
cd C:\Users\Monster\Documents\Codex\2026-05-25\tjk-org-sitesinden-son-1-y\tjk_beyer_project
run_daily_full_flow.bat
```
veya
```
python run_daily_full_flow.py
```

Diyarbakır (Cumartesi tam akış):
```
run_daily_diyarbakir_results.bat
```

Kilit yarış:
```
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Monster\Documents\Codex\kilit_yaris_projesi\run_daily_kilit_yaris_after_beyer.ps1"
```

İstatistik:
```
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Monster\Documents\Codex\istatistik_projesi\run_daily_pipeline_serialized.ps1"
```

Gidişat/tempo:
```
cd C:\Users\Monster\Documents\Codex\2026-06-02\mevcut-tjk-beyer-accurace-sistemini-bozma\gidisat_avantaji
python work\daily_gidisat_otomasyon.py
```

## Yardımcı

İlk yarış saatleri:
```
powershell -NoProfile -ExecutionPolicy Bypass -File "...\spoodyman\scripts\tjk-ilk-yaris-saati.ps1" -Tarih 24/11/2026
```

Kulvar enjeksiyonu:
```
python "...\tjk_beyer_project\src\inject_tempo_gate_stats.py" --date 2026-11-24 --report-dir "...\frontrunner" --pattern "2026-11-24_onde_giden_*.html" --track ADANA --program-dir "...\tjk_beyer_project\data\programs"
```

Sınıf düşme onarımı:
```
cd C:\Users\Monster\Documents\Codex\2026-05-25\tjk-org-sitesinden-son-1-y\tjk_beyer_project
python work\make_sinif_dusme_analizi.py --date 2026-11-24
```

Sonuç değerlendirmesi (önceki gün):
```
cd C:\Users\Monster\Documents\Codex\2026-05-25\tjk-org-sitesinden-son-1-y\tjk_beyer_project
python src\daily_result_evaluation.py --date 2026-11-23 --split-tracks
```

Adana sentetik par time:
```
python src\daily_results_beyer.py --date 2026-11-24
```

## Tüm akışı tek seferde manuel

`daily-flow\manual-run-daily-flow.ps1` scriptini `-Execute` ile çalıştırın (varsayılan sadece komutları listeler).