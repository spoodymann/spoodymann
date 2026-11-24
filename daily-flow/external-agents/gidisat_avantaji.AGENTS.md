# Proje Varsayılanları

> NOT (2026-09-23): Gidişhat avantajı raporu İPTAL edildi. Kullanıcı talimatıyla artık üretilmeyecek.

## Gidişhat Analizi Rapor Konumu

Bu projede oluşturulan tüm Gidişhat Analizi rapor linklerini ve rapor kısayollarını şu klasöre yaz:
`C:\Users\Monster\OneDrive\Desktop\gidişhat analizi`

Bu yol proje varsayılanıdır.

## Gidişhat Analizi Üretim Şekli

"Gidişhat analizi yap" dendiğinde aşağıdaki yöntem kullanılır:

1. `daily_program_reports.py` ÇALIŞTIRILMAZ. Bu script CIPa ile yarış programlarına yeni beyer figürü uygular; bu sohbette bu yapılmaz.
2. Mevcut arşiv verisiyle `report_program.py --layout tempo` kullanılır (11 Ağustos 2026 rapORLARında olduğu gibi):
   ```
   python src/report_program.py data/programs/YYYY-MM-DD_{hipodrom}_program_report.csv --layout tempo
   ```
   Bu, "Lider adayları / Ön grup-presçiler / En geri bekler-sprinterler" tablolarını içeren tempo layout raporu üretir.
   NOT: `work/generate_new_tempo_report.py` (tempo_analizi) ve `work/generate_combined_report.py` (birleşik rapor) ÜRETİLMEZ; bu çıktılar kullanılmıyor.
3. RapOR kopyaları `outputs/` klasörüne `YYYY-MM-DD_{hipodrom}_gidisat_raporu.html` adıyla ve Desktop'taki gidişhat analizi klasörüne yazılır.

Not: Aynı gün birden fazla hipodrom için `report_program.py --layout tempo` çalıştırılırken çıktı dosyalarının üst üste yazılmaması için işlemler sırayla çalıştırılmalıdır.

## Elazığ / Şanlıurfa / Diyarbakır Gidişhat Analizi

Bu üç hipodrom (ELAZIG, DIYARBAKIR, SANLIURFA) Beyer figürü hesaplamasının dışındadır (`BEYER_EXCLUDED_TRACKS`), ancak bundan sonra Gidişhat Analizi'ne DAHİLDİR. `report_program.py --layout tempo` bu hipodromları da kapsar:

- `normalize.py`: `GIDISHAT_INCLUDED_TRACKS = {"ELAZIG", "DIYARBAKIR", "SANLIURFA"}` ve `is_gidishat_track()` bu üç hipodromu gidişhat için kabul eder.
- `report_program.py`: `--layout tempo` kullanıldığında `include_gidishat=True` olur; program okuma ve son koşu geçmişi bu hipodromları da dahil eder. Beyer hesaplamasına dokunulmaz.
- `fetch_program_csv.py`: `TRACKS` sözlüğünde `diyarbakir`, `elazig`, `sanliurfa` anahtarları vardır; bu hipodromların günlük programları indirilebilir.

Bu hipodromların program dosyası yoksa önce `fetch_program_csv.py --date YYYY-MM-DD --tracks elazig sanliurfa diyarbakir` ile indirilir, sonra yukarıdaki tempo komutu çalıştırılır.

## Galop (İdman) Analizi Kuralı (2026-08-19 itibarıyla)

Galop analizi (`galop_analysis_20260819.py` ve sonrasındaki günlük kopyaları) şu kurallara göre yapılır; bu kural kalıcıdır:

1. **Pencere: son 10 gün.** `WINDOW_DAYS = 10`, `WINDOW_START = PROGRAM_DAY - timedelta(days=10)`. Rapor başlık notunda "son 10 gün" yazar.
2. **Pencere dışı galoplar analize girmez.** `latest_workouts_only()` içinde `row_date is None or not (WINDOW_START <= row_date <= PROGRAM_DAY)` kontrolü uygulanır; 10 günden eski galoplar (örn. 2 Ağustos galobu) aday listesine alınmaz.
3. **İdman istatistik havuzu TÜM hipodromlar için indirilir.** `fetch_idman_stats_pool_*.py` içinde `all_tracks = sorted(TRACK_DISPLAY.values())` ile tüm şehirlerin (Ankara, İstanbul, Bursa, İzmir, Kocaeli, Adana, Antalya, Elazığ, Şanlıurfa, Diyarbakır) idman istatistikleri `start = PROGRAM_DAY - 10 gün` tarihinden itibaren çekilir. Sadece o gün yarış olan hipodromlar değil.
4. **Kıyaslama AYNI ŞEHİR bazındadır.** `rank_rows()` içinde anahtar `(breed, age_bucket, dist, track_key)` olarak korunur; `track_key = ascii_key(work_track)` yani aynı idman hipodromundaki son 10 gün galoplarıyla kıyaslanır. Tüm şehir havuzu (TUM_HIPODROMLAR) KULLANILMAZ.
5. **Rapor notları:** meta notta "…idman hipodromunda son 10 gün TJK idman havuzuna göre hesaplandı", kontrol notunda "aynı idman hipodromunda son 10 gün TJK idman istatistikleri havuzuna göre yapıldı" ifadeleri yer alır.
6. Rapor çıktıları `reports/istatistik/` altına yazılır; masaüstündeki `C:\Users\Monster\OneDrive\Desktop\istatistik` klasörüne **yalnızca birleşik** `{Şehir}.html` (`{Şehir}_rapor.html`) kopyalanır. Ayrı `{Şehir}_galop_analizi.html` dosyaları masaüstüne kopyalanmaz (birleşik raporda zaten var).

## Günlük Sonuç Değerlendirme Raporu Konumu

`daily_result_evaluation.py` ve `daily_result_evaluation_same_surface.py` tarafından üretilen hipodrom bazlı değerlendirme HTML dosyaları her zaman şu klasöre yazılır:
`C:\Users\Monster\OneDrive\Desktop\günlük sonuç değerlendirme raporu`

Bu dosyalar Desktop'taki gidişhat analizi klasörüne yazılmaz.
