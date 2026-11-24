# Abacus AI Aktarım Talimatı

Bu proje TJK yerli yarışları için SQLite + pandas tabanlı Beyer/pace arşividir. Abacus AI tarafında aynı mantığı kurmak için önce veriyi tanıt, sonra bu talimatı sistem/proje talimatı olarak ekle.

## 1. Yüklenecek Ana Dosyalar

Öncelik sırası:

1. `tjk_beyer_v2.db`
   - Ana SQLite veritabanı.
   - Yaklaşık 1 GB olabilir; Abacus dosya limiti izin verirse doğrudan yükle.

2. `src/`
   - Hesaplama ve rapor üretme kodları.
   - Özellikle:
     - `src/report_program.py`
     - `src/update_results.py`
     - `src/beyer_drf_logic_v4.py`
     - `src/par_times.py`
     - `src/track_variant.py`
     - `src/speed_figures.py`
     - `src/parse_times.py`
     - `src/normalize.py`
     - `src/database.py`

3. CSV olarak aktarılacak temel tablolar
   - Eğer SQLite dosyası yüklenemiyorsa CSV export kullan.
   - Öncelikli tablolar:
     - `races`
     - `runners`
     - `speed_figures`
     - `par_times`
     - `track_variants`
     - `race_conditions`
     - `track_conditions_daily`
     - `sectional_times`
     - `sectional_details`

4. Program CSV dosyaları
   - `data/programs/`
   - Günlük program raporu için gerekir.

5. Accurace ham CSV dosyaları
   - `data/accurace/`
   - Veriyi tekrar hesaplamak veya doğrulamak için gerekir.

## 2. Büyük Dosyalar İçin Dikkat

Şu tablolar çok büyük olabilir:

- `sectional_times`
- `sectional_details`
- `speed_figures_archive`

Abacus dosya limiti varsa önce şu çekirdek tablolarla başla:

- `races`
- `runners`
- `speed_figures`
- `par_times`
- `track_variants`
- `race_conditions`
- `track_conditions_daily`

Accurace ayrıntı analizi veya son 600 / son 800 sorguları için ayrıca:

- `sectional_times`
- `sectional_details`

yüklenmelidir.

`speed_figures_archive` normal rapor için şart değildir; eski hesap versiyonlarını karşılaştırmak istemiyorsan yükleme.

## 3. Abacus AI İçin Ana Sistem Talimatı

Aşağıdaki metni Abacus AI proje talimatına ekle:

```text
Bu proje TJK yerli yarışları için Beyer tarzı hız figürü ve Accurace pace analizi yapar.

Kurallar:
1. Tahmin uydurma.
2. Sadece yüklenen SQLite/CSV verisini kullan.
3. Veri yoksa "—" yaz.
4. Eksik veriyi 0 kabul etme.
5. Yabancı/simulcast yarışları kullanma.
6. Son 3 yarış seçimi her zaman yarış tarihi/date alanına göre yapılsın; yükleme sırası veya processed_at kullanılmasın.
7. Günlük program analizinde programdaki atların son 3 yarışını kullan.
8. Genel Hız/Beyer, speed_figures.beyer_final_speed alanından okunur.
9. Early Speed ve Late Pace, speed_figures tablosundan okunur.
10. Accurace geçiş analizi için sectional_times ve sectional_details kullanılır.
11. Pist/hava bilgisi için race_conditions veya track_conditions_daily kullanılır.
12. Koşu bazlı raporda sadece gerçek veriden hesaplanan puanları göster.
13. Eksik veri varsa "—" göster.
14. Son 3 Genel Hız bölümünde son 3 Beyer değerini tarih sırasına göre göster; en yeni yarış solda olabilir ama bunu açıkça belirt.
15. Son 3 değeri peş peşe artıyorsa sola ✓ koy.
```

## 4. Beyer Mantığı

Mevcut aktif mantık:

- `calculation_version`: `beyer_drf_logic_v4`
- Par time hesabında koşu sınıfı kullanılmaz.
- Arap/İngiliz ayrımı korunur.
- Hipodrom + pist + mesafe + pist durumu esas alınır.
- Mesafe toleranslı best-time çıpası kullanılır.
- Ek HP/variant şişme freni şu anda aktif değildir.
- Final Speed / Beyer ana figürdür.
- Early Speed ve Late Pace Accurace geçişlerinden gelir.

## 5. Günlük Program Raporu Mantığı

Program CSV verildiğinde:

1. Programdaki yerli TJK koşularını oku.
2. Her atı normalize et.
3. Veritabanında aynı atın son 3 yarışını bul.
4. Şunları göster:
   - Erken Hız
   - Kapanış Hızı
   - Genel Hız
   - Son 3 Ort
   - Son 3 Beyer değeri
5. Uzun yorum yazma, tablo üret.
6. 1.lik ikramiyesi raporda gösterilmesin.

## 6. Accurace Tempo Analizi

Son 600 / son 800 gibi analizlerde:

1. `sectional_times` tablosundaki geçiş markerlarını kullan.
2. Son 600 için final marker veya resmi derece ile finalden 600 metre önceki marker arasındaki farkı hesapla.
3. Son 800 için aynı mantığı uygula.
4. Atın pozisyon kazancı varsa geçiş pozisyonlarından yaz.
5. Pozisyon yoksa uydurma yapma.

## 7. Veriyi CSV Olarak Hazırlama

SQLite yüklenemiyorsa şu komutla CSV export paketi oluştur:

```bash
python src/export_abacus_package.py --core
```

Accurace büyük tabloları da dahil etmek için:

```bash
python src/export_abacus_package.py --core --include-accurace
```

Çıktı klasörü:

```text
exports/abacus_ai/
```

## 8. Abacus'a Sorulabilecek Örnek Komutlar

```text
10 Haziran 2026 İstanbul programındaki atların son 3 Beyer figürünü koşu bazlı tablo yap.
```

```text
Bugünkü Bursa programında son yarışında son 600'ü en hızlı koşan ilk 3 atı koşu bazlı listele.
```

```text
Ankara 6. koşuda son 3 yarış Accurace verisine göre lider adayları, presçiler ve sprinterleri listele.
```

```text
Beyer tablosunda Son 3 değerleri peş peşe artan atların soluna ✓ koy.
```

