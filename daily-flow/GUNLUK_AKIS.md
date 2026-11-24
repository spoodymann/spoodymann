# Günlük Akış (Tam Açıklama)

Bu dosya, Spoodyman sitesinin günlük otomatik akışını baştan sona açıklar. Yeni bir yapay zeka bu dosyayı okuyup aynı akışı yönetebilir.

## 1. Genel mantık

- Her gün için **yarının** yarış raporları üretilir ve siteye yüklenir.
- Sitede **yalnızca en güncel günün** raporları kalır; önceki günün raporları silinir.
- Ayrıca **önceki günün sonuç değerlendirmesi** (hız figürü metriklerinin doğruluk analizi) üretilir ve siteye eklenir.

## 2. Zaman çizelgesi

- **22:00** — 4 görev başlar (beyer, kilit yarış, istatistik, gidişat).
- **22:05** — Site yükleme görevi başlar, 4 görevin bitmesini bekler.
- **Cumartesi 23:59** — Tam akış (Diyarbakır dahil) + site yükleme `-Force`.

## 3. 22:00 görevleri ne üretir?

1. **Beyer (`run_daily_full_flow.bat`)**
   - TJK'dan program/sonuç verilerini çeker.
   - Hız figürü (beyer) raporlarını üretir.
   - `Desktop\beyer raporu\program_beyer_<sehir>_<tarih>_normal.html` vb. oluşturur.
   - Sonuç değerlendirmesi için DB'yi (`tjk_beyer_v2.db`) günceller.

2. **Kilit yarış (`run_daily_kilit_yaris_after_beyer.ps1`)**
   - `Desktop\kilit yarış arşivi\kilit_yaris_<sehir>_tum_kosular_<tarih>.html` oluşturur.

3. **İstatistik/galop (`run_daily_pipeline_serialized.ps1`)**
   - Program CSV, galop, idman istatistikleri.
   - `Desktop\istatistik ve galop\<sehir>.html` oluşturur (dosya adında tarih yok; içerikte tarih var).

4. **Gidişat/tempo (`daily_gidisat_otomasyon.py`)**
   - `Desktop\frontrunner\<tarih>_onde_giden_<sehir>.html` oluşturur.

5. **Sınıf düşme** (site yükleme sırasında eksikse otomatik üretilir)
   - `Desktop\sınıf düşme analizi\<tarih>_<sehir>_sinif_dusme_analizi.html`

## 4. Site yükleme adımları (`site-yukle-22-30.ps1`)

Script şu sırayla çalışır:

1. **Hedef tarihi belirle**: Kaynak klasörlerdeki en yeni tarihi al (veya `-Tarih` parametresi).
2. **Şehirleri belirle**: Beyer/kilit/sınıf kaynaklarından hedef tarihe ait şehirler.
3. **Sıralama**: `tjk-ilk-yaris-saati.ps1` ile en erken ilk yarışa göre şehir sırası.
4. **Rapor kopyalama** (`rapor/` klasörüne):
   - `<sehir>-<gun>-<ay>.html` (beyer)
   - `<sehir>-<gun>-<ay>-kilit-yaris.html`
   - `<sehir>-<gun>-<ay>-tempo.html`
   - `<sehir>-<gun>-<ay>-istatistik.html`
   - `<sehir>-<gun>-<ay>-sinif-dusme.html`
   - gtag bloğu `</head>` öncesine eklenir (yoksa).
   - Beyer raporlarında `Beyer 123` → `123`, ` Beyer ` → ` ` temizliği.
   - `match-notes` blokları silinir.
5. **Kulvar kolonu** (tempo): eksikse `inject_tempo_gate_stats.py` ile eklenir; hâlâ eksikse hata.
6. **Sınıf düşme onarımı**: kaynak eksikse `make_sinif_dusme_analizi.py --date <tarih>` çalıştırılır.
7. **Sınıf tik kontrolü**: `Son 6 Ay En Düşük` + `Son 1 Yıl En Düşük` + `class='tick'` aranır.
8. **Değerlendirme (önceki gün)**: `Desktop\günlük sonuç değerlendirme raporu\<onceki_tarih>_<sehir>_evaluation.html` → `rapor\<sehir>-<gun>-<ay>-degerlendirme.html` (general ve ayni_yuzey hariç).
9. **Aynı-yüzey temizliği**: `*ayni_yuzey*` dosyaları silinir.
10. **Eski gün temizliği**: `rapor/` içindeki eski tarihli raporlar silinir; sadece güncel gün + önceki günün değerlendirmesi kalır.
11. **Kaynak klasör temizliği**: Eski tarihli dosyalar kalıcı silinir; yalnızca en güncel gün kalır (istatistikte yeni günde olmayan şehirler silinir).
12. **Kartlar**: `raporlar.html` ve `index.html` içindeki tarihli kartlar silinir, yeni kartlar eklenir.
13. **Sitemap**: Eski gün URL'leri silinir, yeni gün URL'leri eklenir.
14. **Commit mesajı** dosyaya yazılır (`Desktop\spoodyman-commit-mesaji.txt`).
15. **Git commit + push** (`git add -A`, commit, push origin main).
16. **Pages deploy doğrulama**: Actions izlenir; düşerse boş commit ile en fazla 2 kez yeniden tetiklenir; canli dosya 200 dönmeli.
17. **Bildirim**: Toast ile özet gösterilir.

## 5. Rapor adlandırma kuralları

- Taban: `<sehir>-<gun>-<ay>` (örn. `adana-24-kasim`)
- Ekler:
  - Kilit yarış: `-kilit-yaris`
  - Tempo: `-tempo`
  - İstatistik: `-istatistik`
  - Sınıf düşme: `-sinif-dusme`
  - Değerlendirme: `-degerlendirme`

Şehir adları küçük harf ASCII (istanbul, adana, elazig, ankara, kocaeli, izmir, bursa, diyarbakir, sanliurfa).

## 6. Özel zorunlu kurallar

### Beyer etiketi temizliği
- `Beyer\s+(\d+)` → `$1`
- ` Beyer ` → ` `
- `mesafe-fark-note` blokları ve mesafe başlıkları ASLA silinmez.
- `match-notes` blokları (`<div class="match-notes">`) SİLİNİR.

### Kulvar kolonu (tempo)
- Her tempo raporunda `class="gate-chip"` olmalı.
- Eksikse yükleme sırasında eklenir; hâlâ eksikse script çıkış kodu 1 verir.

### Sınıf düşme tik kolonları
- `Son 6 Ay En Düşük` ve `Son 1 Yıl En Düşük` başlıkları + `class='tick'` hücresi.
- Eksikse script çıkış kodu 1 verir.

### Aynı-yüzey değerlendirmeleri
- `*ayni_yuzey*` değerlendirme dosyaları ÜRETİLMEZ ve yüklenmez.
- `rapor/` içindeki `*ayni_yuzey*` dosyaları her yüklemede silinir.

### Rehber dosyaları
- `hiz-figur-rehberi`, `kilit-yaris-rehberi`, `istatistik-galop-rehberi`, `tempo-analizi-rehberi` günlük temizlikte SİLİNMEZ.

## 7. Değerlendirme (önceki gün)

Beyer projesinde çalıştırılır:
```
python src\daily_result_evaluation.py --date <YYYY-MM-DD> --split-tracks
```
- `--date`: önceki günün ISO tarihi.
- Sonuçlar DB'de olmalı; yoksa değerlendirme üretilemez.
- Çıktı: `reports\daily_beyer\<date>_<sehir>_evaluation.html`
- Sadece şehir başına değerlendirme dosyaları kullanılır (`general` yüklenmez).
- Değerlendirmede "Aynı Yüzey" kartları/sütunları ve "Kontrol edilmesi gereken yüksek Son Hız liderleri" notu ÜRETİLMEZ.

## 8. Adana sentetik par time

Adana sentetik koşusu varsa `daily_results_beyer.py` otomatik olarak Adana SENTETIK par time'larını yeniden hesaplar. Manuel:
```
python src\daily_results_beyer.py --date YYYY-MM-DD
```

## 9. Git / deploy

- Commit mesajı formatı: `dd.MM.yyyy raporlari eklendi, dd.MM raporlari silindi`
- Push: `git push origin main`
- Pages deploy doğrulaması 15 dk'ya kadar beklenir.
- Deploy düşerse boş commit ile en fazla 2 kez yeniden tetiklenir.
- Hâlâ yayınlanmazsa bildirimde `HATA: Pages deploy yayinlanmadi` geçer ve çıkış kodu 1.

## 10. Kaynak klasör temizliği (madde 11)

Yükleme sonrası masaüstü kaynak klasörlerde yalnızca en güncel gün kalır (Shift+Delete / kalıcı):
- `frontrunner\` → yalnızca `YYYY-MM-DD_*` en yeni tarih
- `beyer raporu\`, `kilit yarış arşivi\`, `sınıf düşme analizi\` → yalnızca yeni günün tarihi
- `istatistik ve galop\` → yeni günde yer almayan şehirlerin dosyaları silinir
- `günlük sonuç değerlendirme raporu\` → yalnızca en güncel değerlendirme tarihi

## 11. Cumartesi özel akışı

- Cumartesi 22:00 ana akışı atlanır.
- 23:59'da Diyarbakır tam akışı çalışır:
  1. Sonuçlar + yarının raporları (site yükleme yok)
  2. İstatistik/galop
  3. `site-yukle-22-30.ps1 -Force` → istatistik dosyaları da siteye çıkar

## 12. Manuel tetikleme

Bkz. `MANUEL_KOMUTLAR.md`.