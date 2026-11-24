# Istatistik Projesi

Bu klasor yalnizca gunluk TJK istatistik analizi ve rapor uretimi icindir.

## Calistirici

- Ana komut: `python run_daily_pipeline.py`
- Belirli tarih: `python run_daily_pipeline.py --date YYYYMMDD`
- Kontrol: `python run_daily_pipeline.py --date YYYYMMDD --dry-run`
- Windows gorevi: `TJKGunlukRapor_2200`

## Ortak Veri

Istatistik sistemi Beyer arsivini ve veritabanini ortak kullanir. Veriyi bu
klasore kopyalama. `src`, `work`, `reports` ve `logs` baglantilari ana Beyer
projesindeki gercek klasorlere gider.

Ana Beyer projesi:
`C:\Users\Monster\Documents\Codex\2026-05-25\tjk-org-sitesinden-son-1-y\tjk_beyer_project`

## Akis

1. Program CSV'lerini indir.
2. Galop ve idman sayfalarini al.
3. Idman istatistik havuzunu olustur.
4. Program istatistiklerini hesapla.
5. Galop analizini uret.
6. Galop ve genel istatistigi tek raporda birlestir.

Not: Son 800 analizi kaldirildi; artik uretilmiyor ve raporlara
birlestirilmiyor.

## Veri Hazirlik Kurali (HER ZAMAN UYGULA)

Rapor ust bilgisindeki "Not: Istatistik verileri ... tarih araligini kapsar."
satiri DB'deki gercek son sonuc tarihinden uretilir (`src/report_range_note.py`).
Bu yuzden rapor, **hedef gunden onceki gunun sonuclari DB'ye islenmeden
URETILMEZ**.

- `run_daily_pipeline.py` (Beyer kokundeki ortak calistirici) hedef tarihten
  once `wait_for_results()` ile onceki gunun sonucunu bekler:
  `races.max(date) >= hedef - 1 gun`.
- Onceki gun icin program CSV'si yoksa (o gun yaris yoksa) beklemez.
- Sonuc isleme gorevleri (`TJK Gunluk Beyer Sonuc ve Program`,
  `TJK Gunluk Diyarbakir Beyer`) calisiyorsa yarim veriyle baslamamak icin
  bitmesi beklenir.
- Sure dolarsa (`--max-wait-min`; varsayilan hafta ici 45 dk, Cumartesi 240 dk)
  rapor URETILMEZ, gorev hata kodu ile biter ve loga
  `HATA: ... Rapor URETILMEDI` yazilir. Elle uretmek icin: `--allow-stale`.
  Cumartesi 240 dk, 23:59 akisinin (Diyarbakir 3 deneme dahil) bitmesini kapsar.
- Uretim sonrasi `verify_notes()` her raporun tarih notunu DB ile karsilastirir;
  uyusmazsa Masaustune kopyalama yapilmaz ve hata kodu doner.
- `run_daily_pipeline_serialized.ps1` once iki sonuc gorevinin de bitmesini
  bekler (Cumartesi 23:59 akisi dahil), sonra pipeline'i calistirir.
- Cumartesi gunleri 22:00 istatistik akisi **atlanir**: Diyarbakir'in son
  yarisi 23:30'da kosuldugu icin sonuclar 22:00'de hazir olmaz. Bu hat
  `TJK Gunluk Diyarbakir Beyer` (23:59) tam akisinin sonunda
  `-CumartesiZorla -Tarih <yarin>` ile cagrilir; boylece 2 saat bos bekleme
  olmaz ve zincir gece yarisini gecse bile hedef tarih kaymaz.
- `run_daily_diyarbakir_results.bat` Cumartesi sirasi: (1) sonuclar + yarinin
  raporlari (site yukleme YOK), (2) istatistik+galop, (3) `site-yukle-22-30.ps1
  -Force` -> istatistik dosyalari da siteye cikar.

Gecmiste yasanan hata: Cumartesi 22:00 akisi, 24.10 sonuclari 23:59 akisinda
islendigi icin raporu 23.10 tarihiyle uretmisti (25.10 Istanbul/Adana raporu).
Kontrol bu tekrari onler.

## Ciktilar

- Ana raporlar: `reports/istatistik/`
- Gunluk loglar: `logs/otomatik/`
- HTML kopyalari: `C:\Users\Monster\OneDrive\Desktop\istatistik ve galop`

Bu proje acikken Beyer hiz figuru, gidisat avantaji veya kilit yaris kodunda
degisiklik yapma; yalnizca istatistik akisini yonet.
