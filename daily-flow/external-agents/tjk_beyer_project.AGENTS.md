# Beyer Hiz Figuru Projesi

Bu klasor Beyer hiz figuru hesaplama sistemi, ortak veri tabani ve yaris
arsivi icindir.

## Proje Ayrimi

- Istatistik projesi:
  `C:\Users\Monster\Documents\Codex\istatistik_projesi`
- Gidisat Avantaji projesi:
  `C:\Users\Monster\Documents\Codex\2026-06-02\mevcut-tjk-beyer-accurace-sistemini-bozma\gidisat_avantaji`
- Kilit Yaris projesi:
  `C:\Users\Monster\Documents\Codex\kilit_yaris_projesi`

Bu projeler ayri calisma alanlaridir fakat Beyer veri tabani ve arsivini ortak
kullanir. Beyer projesinde yalnizca hiz figuru ve ortak veri islemleri yap.

## Istatistik Ortakligi

- Istatistik gece gorevi: `TJKGunlukRapor_2200`
- Ayrik calistirici:
  `C:\Users\Monster\Documents\Codex\istatistik_projesi\run_daily_pipeline.py`
- Istatistik kaynaklari `src` ve `work` uzerinden bu projeye baglidir.
- Istatistik raporlari `reports\istatistik`, loglari `logs\otomatik`
  klasorlerinde ortak tutulur.
- Masaustu HTML hedefi:
  `C:\Users\Monster\OneDrive\Desktop\istatistik`

## Rapor Uretim Konvansiyonu (HER ZAMAN UYGULA)

Beyer ve Frontrunner raporlari hipodrom (pist) bazinda AYRI DOSYA olarak
uretilir; tum hipodromlar tek dosyada birlestirilmez.

- Beyer raporu her hipodrom icin UC dosya uretilir; hepsi TEK PANELLIDIR
  (yan yana / iki panel duzeni KULLANILMAZ):
  1. Ayni Yuzey: `program_beyer_<pist>_<tarih>_ayni_yuzey.html`. At gecmisi
     yalnizca ayni yuzey kosulariyla filtrelenir (`build_ayni_yuzey_html`).
  2. Normal: `program_beyer_<pist>_<tarih>_normal.html`. Sitede yayinlanan
     dosya budur; bu yuzden MOBIL gorunum (zoom/responsive) OZELLIKLE
     ONEMLIDIR.
  3. Ayni Yuzey Ayni Sehir: `program_beyer_<pist>_<tarih>_ayni_sehir.html`.
     At gecmisi yalnizca ayni hipodrom (sehir) + ayni yuzey kosulariyla
     filtrelenir (`TJK_REPORT_SAME_SURFACE=1` + `TJK_REPORT_SAME_TRACK=1`).
     Bu dosya SITEYE YUKLENMEZ; yalnizca masaustu/yerel inceleme icindir.
- Frontrunner raporu her hipodrom icin ayri dosya.
- Frontrunner raporunun ustunde ACIKLAMA METNI URETILMEZ: "Önde Giden
  figürü (0-100): ..." notu ve `<p class="note">` kaldirilmistir.
  `report_frontrunner.py` bu metni uretmemelidir.
- FRONTRUNNER GORSEL FORMATI SABITTIR (kullanici onayladi, HER ZAMAN
  UYGULA): `src/report_frontrunner.py` su yapiyi degistirmeden korur,
  hep ayni formatta uretilir.
  - CSS: `_BEYER_REPORT_STYLE` + `_FRONTRUNNER_STYLE` (iki blok ust uste,
    ayri sabit); baska stil/duzen kullanilmaz.
  - Bilesenler: `_BEYER_ZOOM_BAR` (sag ust + / - / 0) ve
    `_BEYER_REPORT_SCRIPT` (zoom) korunur.
  - Sayfa duzeni: `h1` + her kosu icin `.race`/`table.rank.front-table`.
  - Tablo sutunlari sabit: `At | Puan | Erken Hız | Pozisyonlar | Tarih | Şehir | ham`
    (`Erken Hız` sutunu kullanici onayli, 2026-08-27; erken hiz figuru degerini gosterir).
  - `Pozisyonlar` hucreleri `table.mini` ic tablo: ustte marker etiketleri
    (200-400-600-800 veya 400-800, `-` ile ayrili), altta pozisyonlar.
  - Rozetler sabit: `E3`, `GÜÇLÜ`, `ZAYIF`, `★★★★★`, debut `Y`.
  - KACAK SUTUNU (kullanici onayladi, 2026-11-15, HER ZAMAN UYGULA):
    tablo sutunlari `At | Stil | K | Erken Hız | Pozisyonlar | Tarih | Şehir`
    (kulvar enjeksiyonundan sonra `K` ve `Pozisyonlar` arasina `Kulvar` girer).
    `K` sutunu sabit genisliklidir; rozet (`K2/6` = son 6 yarisin 2'sinde
    starttan lider) YALNIZCA bu sutunda durur. Rozet erken hiz hucresine
    KONMAZ; aksi halde sayilar alt alta hizasini kaybediyor (kullanici
    istegi). Rozeti olmayan atlarda hucre bos kalir, sutun yine durur.
    Rozet yok = at en az 2 kez onde gitmemis ya da kacak orani %10'un altinda.
    Iki sart BIRLIKTE aranir (`KACAK_MIN_COUNT=2`, `KACAK_MIN_RATE=0.10`).
    Stil zaten
    "Kaçak" ise rozet basilMAZ. Anlami `_FRONTRUNNER_INTRO` aciklamasinda
    (`K2/6` satiri) yazar; kosu basliginin altina ayri "Kaçak adaylari"
    satiri EKLENMEZ (kaldirildi).
  - `build_html` yapisinda `note = ""` BULUNUR (aciklama metni hicbir
    sekilde eklenmez).
- SINIF DUSME/YUKSELME analizi (`work/make_sinif_dusme_analizi.py`) TUM
  hipodromlarda calisir: hipodromlar `{date}_program_report.csv` icindeki
  `hipodrom` degerlerinden otomatik tespit edilir (hipodrom listesi
  sabitlenmez). Her hipodrom icin ayri dosya uretilir:
  `{date}_{slug}_sinif_dusme_analizi.html` ve `Desktop\gidişhat analizi`
  klasorune yazilir.
- Hedef klasorler:
  - Beyer: `C:\Users\Monster\OneDrive\Desktop\beyer raporu`
  - Frontrunner: `C:\Users\Monster\OneDrive\Desktop\frontrunner`
  - Sinif dusme: `C:\Users\Monster\OneDrive\Desktop\gidişhat analizi`
- Dosya adi ornekleri (tarih `2026-08-18`, pist `ankara`):
  - Beyer ayni yuzey:                    `program_beyer_ankara_20260818_ayni_yuzey.html`
  - Beyer normal (sitede yayinlanir):    `program_beyer_ankara_20260818_normal.html`
  - Beyer ayni yuzey ayni sehir:         `program_beyer_ankara_20260818_ayni_sehir.html`
  - Frontrunner:                         `2026-08-18_onde_giden_ankara.html`
- Yani her hipodrom icin `beyer raporu` klasorunde 3 dosya olmalidir
  (ayni yuzey, normal, ayni yuzey ayni sehir). Site yukleme `_normal.html`
  dosyasini tercih eder; `_ayni_sehir.html` siteye yuklenmez.
- Uc Beyer raporu da ayni tek-panel gorunumu kullanir: `_BEYER_REPORT_STYLE`,
  `_BEYER_ZOOM_BAR` ve `_BEYER_REPORT_SCRIPT`. Yeni raporlar
  `build_ayni_yuzey_html` / `build_ayni_sehir_html` ile uretilir; eski
  `build_yanyana_html` / `build_combined_html` gunluk akista KULLANILMAZ.
- Bursa-cezali (penalty) rapor uygulamasi IPTAL EDILDI. `work/make_bursa_penalty_report.py`
  ve `work/make_ist_penalty_report.py` kullanilmaz; Bursa enflasyon cezasi
  uygulanmaz.
- SICAK JOKEY / ANTRENOR ROZETLERI (2026-10-06, kullanici onayladi, HER ZAMAN UYGULA):
  Yalnizca NORMAL raporda gosterilir; Ayni Yuzey ve Ayni Yuzey Ayni Sehir
  raporlarinda bu sutun/istatistik YOKTUR. "Son Hiz" tablosunun basliklari `bos | Son Hiz | J/A Form`
  seklindedir; rozetler saga yaslidir.
Jokey ve antrenor icin AYRI AYRI, program gununden onceki son 14 / 30 / 90
gunluk GALIBIYET YUZDESINE gore ilk 5 hesaplanir (`src/hot_connections.py`,
DB `runners`+`races`, esitlikte galibiyet sayisi sonra start sayisi bozar,
en az 5 start sarti ve sifir galibiyetli liste disi). Yuzde + galibiyet +
start TAMAMEN esit olan kisiler AYNI dereceyi paylasir (or. hepsi 1. derece,
hepsi 5 alev); sonraki farkli grup kendi konumunu alir (1-1-3 standard
derecelendirme). Ilk 5'e giren atin Son Hiz figuru yaninda
rozet vardir: ustte dereceye gore ALEV (1. 5 alev, 5. 1 alev), altta kisa kod
  `J`/`A` + pencere (or. `J-14`, `A-90`). Rakam ve madalya emojisi rozette
  KULLANILMAZ; dereceye gore `.hot-r1`..`.hot-r5` zemin rengi korunur. Bir kisi birden cok pencerede ilk
  5'teyse en iyi derecesi gosterilir; detay (isim, kosu, birincilik, yuzde)
  rozet tooltip'indedir. Sayfa ustunde `hot-legend` LISTESI yalnizca Normal
  raporda vardir; Ayni Yuzey / Ayni Yuzey Ayni Sehir raporlarinda legend
  GOSTERILMEZ (kullanici istegi). Uste sari
  `alert-banner` baslik ("Jokey / Antrenor 14-30-90 gunluk kazanma oranlari",
  aciklama yazisi YOK), altta 14/30/90 gun icin ayri `period-card` ALTA ALTA
  (tek sutun grid; yana tasmaz), her kartta Jokey ve Antrenor bolumleri YAN
  YANA (mobilde alta alta), ilk 5 ALTA ALTA; her satirda isim + `kac kosu,
  kac birincilik`, yuzde rozetinin SOLUNDA dereceye gore alev (1. 5 alev,
  5. 1 alev) ve mavi yuzde rozeti (or. `65 kosu, 19 birincilik` + `%29,2`).
  Normal (tek panel) raporda legend genisligi kosu
  tablosuyla esittir (`width:930px` = panelgrid 910 + kenarlik/dolgu;
  panelgrid sutunlari degisirse guncelle; saga tasmaz).
  (`.hot{max-width:100%;overflow:hidden}`, `.hot-form{overflow:hidden}`).
  Program CSV'leri `jokey` + `antrenor` kolonu tasir (`fetch_program_csv.py`
  raw'daki "Jokey Adi"/"Antrenor Adi"ndan parse eder; apranti eki
  eslestirmede yok sayilir). Eski kolonsuz CSV'lerde rozet uretilmez, legend
  cikarilmaz (gorunum bozulmaz). Yeniden uretim:
  `python work/regen_reports_with_hot_form.py <tarih-YYYY-MM-DD> <pist...>`
  (ag yok, figur degistirmez, kararli isimlerle reports + Masaustune yazar).

Per-track uretim komutu:
  `python make_track_reports.py <tarih-YYYY-MM-DD>`
(Ankara ve Kocaeli icin Beyer birlesik + Beyer normal + Frontrunner ayri
dosyalari uretip Masaustu klasorlerine kopyalar. `make_track_reports.py`
proje kokundedir.)

- SON GALIBIYET HP raporu KALDIRILDI (kullanici istegi, 21.11.2026):
  `work/make_son_galibiyet_hp.py`, `reports/son_galibiyet_hp` klasoru ve
  masaustu `son_galibiyet_hp_*.html` dosyalari silindi. Yeniden uretilmez.

## GUNLUK OTOMASYON KURALLARI (HER ZAMAN UYGULA, kullanici onayladi)

Sonuc isleme ONCELIKLIDIR: Beyer ve diger raporlar, o gunun sonuclari
islenmeden URETILMEZ. `run_daily_full_flow.py` su sirali akisi izler:

0. SIRA (kullanici onayladi): ONCE bugunun sonuclari islenir, SONRA yarinin
   raporlari uretilir. Yani `result_date = bugun`, `program_date = yarin`.
1. ONCE sonuc isleme (SONUC adimi):
   - 22:00 ana akis: gunun sonuclari DIYARBAKIR HARIC islenir.
   - Eger SONUC adimi basarisiz olursa (cikis kodu != 0) ya da gunun
     programi varken sonuclar DB'ye girmediyse Beyer ve diger raporlar
     URETILMEZ (raporlar atlanir, islem durur).
2. BACKFILL: gecmiste program CSV'si olan ama DB'de sonucu girilmemis
   gunler tespit edilir ve islenir (son 90 gun). Kacirilan gun kalmasin.
3. Sonuc isleme basarili OLDUKTAN SONRA yarinin raporlari uretilir (CIPA,
   PROGRAM, ONDE_GIDEN, BEYAZ_BAYRAK, SINIF_DUSME).
4. **ADANA SENTETIK PAR TIME (HER GUN, kullanici onayladi):** Adana hipodromunda
   sentetik pist yeni oldugu icin par time ornegi azdir. Her sonuc islemede,
   o gun Adana SENTETIK kosusu varsa `rebuild_par_times` yalnizca
   ADANA+SENTETIK icin yeniden calistirilir (track/surface filtreli). Diger
   par time'lar ve aylik kilit DEGISMEZ. Bu, `daily_results_beyer.py` icinde
   otomatik yapilir; ozet raporunda "Adana sentetik par time guncelleme"
   satiri gorunur.

## DIYARBAKIR OZEL KURALI (kullanici onayladi, HER ZAMAN UYGULA)

- Diyarbakir yarisi SADECE CUMARTESI gunu yapilir ve sonuclari 22:00'den
  SONRA biter. Bu nedenle CUMARTESI ana akis 23:59'a ALINDI.
- Cumartesi 23:59'daki haftalik gorev artik TAM akisi calistirir:
  `run_daily_diyarbakir_results.bat` -> `run_daily_full_flow.py --saturday-full --site-upload`
  - `--saturday-full`: TUM sehirleri (Diyarbakir dahil) isler, yarinin raporlarini
    (CIPA + PROGRAM + ONDE_GIDEN + BEYAZ_BAYRAK + SINIF_DUSME) uretir.
  - Diyarbakir sonuclari eksikse 40 dk bekleyip yeniden dener (en fazla 3 kez;
    `--retry-minutes` / `--max-retries` ile ayarlanir). Ust sinirda hala eksikse
    mevcut verilerle devam edilir (rapor uretimi durmaz).
  - `--site-upload`: raporlar uretildikten SONRA `site-yukle-22-30.ps1 -Force`
    calistirilir (Diyarbakir dahil guncel raporlar siteye ciksin).
- Zamanlanmis gorevler:
  - `TJK Gunluk Beyer Sonuc ve Program` -> her gun 22:00; CUMARTESI ATLANIR
    (`run_daily_full_flow.bat` gunu kontrol eder, argumansiz cagrida atlar).
  - `TJK Gunluk Diyarbakir Beyer` -> haftalik CUMARTESI 23:59 (tam akis + site yukleme).
  - `SpoodymanSiteYukle2230` -> her gun 22:05; CUMARTESI ATLANIR
    (`site-yukle-22-30.ps1` gunu kontrol eder; `-Force` ile atlanmaz).
- Once sonuc isleme basarili olmali; aksi halde rapor uretilmez ve logda
  `SONUC BASARISIZ` mesaji yer alir.

## INCE CIPA / AGIR ZEMIN FIGUR KORUMASI (2026-09-23, kullanici onayladi)

Nadir mesafe (or. 2600 cim) ve agir/yumusak cimde figurler gecmise gore siskin
cikiyordu (or. Ankara 2600: 106.9). Kok nedenler: bayat program EID'si par
oluyordu, tam-mesafe cipa yoksa EID tek basina par yapiliyordu, kazananin ust
siniri yoktu, agir zemin marjlari sabit tahmini tablodaydi.

- `src/eid_anchor_beyer_trial.py`:
  - `refresh_eid_from_db(conn, date_iso=None)`: EID'yi DB'deki gerceklesmis en
    iyi derecelerle tazeler; IRK BAZINDA kovada, yalnizca yaris oncesi
    kazananlarla (gelecek sizintisi yok), sadece dusurur, asla yukseltmez.
    `update_results.process_date` hesaptan once gunun kosulari icin cagirir.
  - Bayat EID kurali: EID tarihsel cipa ortalamasindan toleranstan fazla
    yavassa yok sayilir (`_stale_eid_dropped`).
  - Tam-mesafe cipa n<3 ise EID'den once +-200m olcekli cipa denenir
    (`same_going_pm200m` / `all_going_pm200m`).
  - Zemin marji: `going_margin_measured` tablosundaki olculmus deger (ornek
    >= 15) sabit `*_GOING_PER_200` tablosuna tercih edilir. Olcum:
    `python src/measure_going_margins.py --apply`.
- `src/apply_anchor_safe_beyer.py`: tarihsel cipa yokken (n=0, EID-only par)
  kazanan 95 ile sinirlidir (`EID_ONLY_WINNER_CAP`) + review isareti.
- Anahtarlar (kapatilirsa onceki davranis): `USE_PM200_FALLBACK`,
  `USE_STALE_EID_DROP`, `USE_MEASURED_MARGINS`, `USE_EID_ONLY_WINNER_CAP`.
- Hedefli recalc: `python work/recalc_thin_anchor.py` — yalnizca duzeltmeden
  etkilenen kosulari (patched-vs-stored >= 5, arsiv-restore haric) gunceller;
  `speed_figures_archive`'a `thin_anchor_fix_YYYYMMDD` sebebiyle arsivler.
  Genel figur uretimi etkilenmez (saglikli ornekte fark 0-1 puan).

## ZAMANLANMIS GOREV PYTHON SIRASI

- `run_daily_full_flow.bat` ve `run_daily_diyarbakir_results.bat` oncelikle
  codex-runtime python'unu kullanir:
  `C:\Users\Monster\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe`
- Degilse Python313 (`C:\Users\Monster\AppData\Local\Programs\Python\Python313\python.exe`).
- `run_daily_full_flow.py` kok dizindedir ve `src/` importlarini kullanir
  (script basinda `src` sys.path'e eklenir).

## SINIF-DUSME GARANTISI (04.11.2026, HER ZAMAN UYGULA)

- `run_daily_full_flow.py` icinde **SINIF_DUSME, HORSE_EARNINGS'ten ONCE**
  calisir. Boylece TJK kazanc cekimi ag/zaman asimi nedeniyle uzasa veya
  basarisiz olsa bile sinif-dusme raporu her gun uretilir.
- `_run()` artik `subprocess.TimeoutExpired` yakalar ve 124 dondurur; akis
  kilitlenmez. HORSE_EARNINGS en fazla 10 dk, SINIF_DUSME en fazla 20 dk
  calisabilir.
- SINIF_DUSME sonrasi `Desktop\sinif dusme analizi\<tarih>_*_sinif_dusme_analizi.html`
  kontrol edilir; dosya yoksa bir kez yeniden denenir, yine yoksa akis
  `SinifDusme != 0` ile biter.
- `src/horse_earnings.py` global sure siniri tasir (`--max-seconds`, varsayilan
  540 sn) ve 403 tekrar denemeleri kisaltilmistir; tum gunu kilitleyemez.
- `scripts\site-yukle-22-30.ps1` (site reposu) sinif-dusme kaynagi eksikse
  yukleme sirasinda `work\make_sinif_dusme_analizi.py --date <tarih>` ile
  kendini onarir. Onarim sonrasi da yoksa cikis kodu 1 olur ve bildirimde
  "SINIF DUSME YOK" gecer.

Manuel kontrol/onarim:
```
python work\make_sinif_dusme_analizi.py --date YYYY-MM-DD
```
