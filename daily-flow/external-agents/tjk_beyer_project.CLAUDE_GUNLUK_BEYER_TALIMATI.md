# Claude Için Gunluk Beyer Iş Akisi

Bu talimati tek parca halinde uygula. Kullanici acikca istemedikce Beyer formulunu, par time/çıpa mantigini, rapor gorunumunu veya veritabani semasini degistirme.

## 1. Ana proje ve calisma ortami

- Ana proje: `C:\Users\Monster\Documents\Codex\2026-05-25\tjk-org-sitesinden-son-1-y\tjk_beyer_project`
- Ana veritabani: `C:\Users\Monster\Documents\Codex\2026-05-25\tjk-org-sitesinden-son-1-y\tjk_beyer_project\tjk_beyer_v2.db`
- Python: `C:\Users\Monster\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe`
- Kabuk: Windows PowerShell
- Deneme kopyasi: `C:\Users\Monster\Documents\Codex\tjk_beyer_project_kopya_20260810`

Kullanici "ana proje" demediyse hangi klasorde calistigini once kontrol et. Ana is akisi icin kopya klasoru kullanma. Ana veritabanini kopya veritabaniyla komple degistirme.

## 2. Istegin anlami

Kullanici "bugunun/dunun sonuclarini isle, yarina Beyer uygula" dediginde iki islem sirayla yapilir:

1. Sonuclanan gunun resmi TJK sonuclarini, Accurace verisini ve pist/hava bilgisini veritabanina isle.
2. Bir sonraki gunun program CSV dosyalarini indir; normal ve ayni yuzey Beyer HTML raporlarini uret.

Kullanici tarih verdiyse onu esas al. Tarihi tahmin ederek bir gun kaydirma. Ornek: `11 Agustos sonuclarini isle, 12 Agustosa Beyer uygula` demek sonuc tarihi `2026-08-11`, program tarihi `2026-08-12` demektir.

## 3. Sonuclari isleme

PowerShell'de once ana proje kokune gec:

```powershell
Set-Location 'C:\Users\Monster\Documents\Codex\2026-05-25\tjk-org-sitesinden-son-1-y\tjk_beyer_project'
```

Sonuc gununu isle:

```powershell
& 'C:\Users\Monster\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' src\daily_results_beyer.py --date YYYY-MM-DD
```

Bu komut sunlari birlikte yapar:

- TJK resmi sonuclarini indirir.
- At, kosu, derece ve siralama kayitlarini `tjk_beyer_v2.db` icine yazar.
- Accurace gecis ve bolum verilerini indirir.
- Kum/çim/sentetik pist durumunu ve hava bilgisini kaydeder.
- Beyer, erken hiz ve kapanis hizi figurlerini uretir.
- **Adana sentetik par time'larini otomatik gunceller** (Adana sentetik pisti yeni
  oldugu icin ornek azdir; o gun Adana sentetik kosusu varsa yalnizca ADANA SENTETIK
  par time'lari yeniden hesaplanir, diger par time'lar ve aylik kilit degismez).
- Hipodrom bazli sonuc degerlendirmelerini uretir (genel ve ayni yuzey uretimi kapali).
- Veri kalite ve duplicate kontrollerini calistirir.

Sonuc ozeti:

`reports\daily_beyer\YYYY-MM-DD_daily_beyer_summary.html`

Degerlendirmeler (yalniz hipodrom bazli; genel ve ayni yuzey uretimi kapali):

- `reports\daily_beyer\YYYY-MM-DD_HIPODROM_evaluation.html`

## 4. Ertesi gun program raporlarini uretme

Sonuc islemi tamamen bittikten sonra calistir:

```powershell
& 'C:\Users\Monster\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' src\daily_program_reports.py --date YYYY-MM-DD
```

Bu komut programi bulunan su hipodromlari tarar:

`adana, ankara, antalya, bursa, istanbul, izmir, kocaeli, elazig, diyarbakir, sanliurfa`

Elazig, Diyarbakir ve Sanliurfa da Beyer program raporuna dahildir. Bu hipodromlardaki gecmis figurler Son 3 hesabinda kullanilir ve raporda gosterilir.

Diyarbakir sonuclari 23:30'da bittigi icin ana 22:00 akisinda sonuc isleminden haric tutulur; 23:59'daki ayri gorev (`run_daily_diyarbakir_results.bat`) Diyarbakir sonuclarini isler.

Programi olmayan hipodromun TJK CSV adresinin `404 Not Found` vermesi normaldir; o hipodrom atlanir. Program bulunan her hipodrom icin iki ayri rapor zorunludur:

- Normal: `reports\program_beyer_HIPODROM_YYYYMMDD_normal.html`
- Ayni yuzey: `reports\program_beyer_HIPODROM_YYYYMMDD_ayni_yuzey.html`

Birlesik rapor uretme. Hipodromlari ayri yayinla.

Program ozeti:

`reports\daily_program\YYYY-MM-DD_daily_program_summary.html`

## 5. Mevcut hesap ve rapor kurallari

- Normal raporda Genel Hiz ve Son 3, atin son uc gecerli yarisi uzerinden hesaplanir.
- Ayni yuzey raporunda Genel Hiz ve Son 3, bugunku kosu yuzeyiyle ayni yuzeydeki son uc gecerli yaristan gelir.
- Erken hiz ve kapanis hizi her iki raporda da bugunku kosu yuzeyiyle ayni yuzeydeki gecmisten hesaplanir.
- Ayni hipodrom sarti yoktur; yalnizca ayni yuzey sarti vardir.
- Atin uygun yuzey yarisi yoksa erken/kapanis veya ayni yuzey figuru `-` kalir. Baska yuzeyden zorla doldurma.
- Gecersiz, hesaplanamayan veya anlamsiz dereceler `-` gosterilir ve ortalamayi etkilemez.
- Ilk kez kosacak atlari isim benzerligiyle baska atlara baglama.
- Son 3 siralamasi ve tablo satirlari birbirinden kaymamalidir.
- Normal ve ayni yuzey raporlarini daima birlikte uret.

## 6. Çıpa destegi

Gunluk program ureticisi kritik çıpa profillerini otomatik kontrol eder:

- Kullanilabilir kaynak kosu sayisi 5'in altindaysa TJK Kosu Sorgulama filtreli aramayla gecmise gider.
- Mumkunse kaynak havuzunu 20 kosuya tamamlar.
- Secilen par time yine uygun en iyi dereceler uzerinden hesaplanir; 20 sayisi secilecek derece sayisi degil, kaynak havuzudur.
- Destek kayitlari `data\anchor_support\cipa_anchor_supplement.db` icinde tutulur.
- TJK filtreli sorgu sayfasi 404 veya bos donerse mevcut çıpa/E.I.D. yedegi korunur; figur uydurma.
- Kullanici acikca istemedikce tum arsivi yeniden tarama. Yalnizca o gunun programinda gereken kritik profilleri tamamla.

## 7. Islem sonunda zorunlu kontrol

Sonuc komutunun ciktisinda sunlari bildir:

- Islenen hipodrom, kosu ve at sayisi
- Uretilen Beyer, erken hiz ve kapanis hizi sayisi
- Eksik Accurace sayisi
- Eksik pist/hava bilgisi sayisi
- Hata sayisi
- Duplicate durumu

Veritabanini ek olarak kontrol et:

```powershell
& 'C:\Users\Monster\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' -c "import sqlite3; c=sqlite3.connect('tjk_beyer_v2.db'); print(c.execute('pragma integrity_check').fetchone()[0])"
```

Beklenen sonuc `ok` olmalidir.

Accurace'in teknik nedenle yayinlanmadigi bir kosu varsa bunu acikca belirt; bu tek basina islemin basarisiz oldugu anlamina gelmez. Pist/hava bilgisi eksikse sessizce gecme. Kaynakta gercekten bulunamiyorsa mevcut kurala gore normal pist kabul edildigini raporla.

Program raporunda her HTML dosyasinin varligini, boyutunun sifirdan buyuk oldugunu, programdaki kosu ve at sayisini kontrol et.

## 8. Kullaniciya verilecek son cevap

Kisa ve Turkce yaz. Once sonuc isleminin rakamlarini, sonra ertesi gun hangi hipodrom raporlarinin uretildigini belirt. En alta tiklanabilir mutlak dosya baglantilarini koy.

Ornek baglanti bicimi:

```markdown
- [Istanbul Normal](C:/Users/Monster/Documents/Codex/2026-05-25/tjk-org-sitesinden-son-1-y/tjk_beyer_project/reports/program_beyer_istanbul_YYYYMMDD_normal.html)
- [Istanbul Ayni Yuzey](C:/Users/Monster/Documents/Codex/2026-05-25/tjk-org-sitesinden-son-1-y/tjk_beyer_project/reports/program_beyer_istanbul_YYYYMMDD.html)
- [Istanbul Ayni Yuzey Ayni Sehir](C:/Users/Monster/Documents/Codex/2026-05-25/tjk-org-sitesinden-son-1-y/tjk_beyer_project/reports/program_beyer_istanbul_YYYYMMDD_ayni_sehir.html)
```

## 9. Yapilmamasi gerekenler

- Ana veritabanini silme, sifirlama veya kopya DB ile komple ezme.
- Eski raporlari silme.
- Kullanici istemeden Beyer, par time, pist katsayisi, erken hiz veya kapanis hizi formulunu degistirme.
- V4/V5 gibi eski deneme sistemlerini yeniden etkinlestirme.
- Kilit yaris raporu uretme.
- Sonuc islemi bitmeden ertesi gun program raporunu uretme.
- Eksik veriyi sifir figur olarak yazma.
- Ana proje ile deneme kopyasini otomatik senkronize etme.

