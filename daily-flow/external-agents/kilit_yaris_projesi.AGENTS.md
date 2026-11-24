# Kilit Yaris Gunluk Is Akisi

Bu proje gunluk kilit yaris raporlarini uretir. Kullanici rapor "nereye" yazilacagini sordugunda cevap her zaman masaustu arsividir.

## Kilit yaris hipodromlari

Kilit yaris analizine **bundan sonra** Elazig (`ELAZIG`), Sanliurfa
(`SANLIURFA`) ve Diyarbakir (`DIYARBAKIR`) da eklendi. Bunlar yalnizca analiz
edilen hipodromlar DEGIL; bulunan tum program hipodromlari islenir, bu uc
hipodrom da buna dahildir.

Gunluk surucu (`src\daily_kilit_yaris_driver.py`) program CSV'lerini
varsayilan olarak hic filtrelemeden isler. `KILIT_TRACKS` ortam degiskeni
(virgulle ayrilmis) set edilirse analiz yalnizca o hipodromlarla sinirlanir
(deneme icin; `src\config.py`).

## Cikti konumu (ZORUNLU)

- Raporlar **her zaman** su klasore yazilir: `C:\Users\Monster\OneDrive\Desktop\kilit yarış arşivi`
- Bu klasor `src\config.py` icindeki `DEFAULT_REPORT_DIR` ile eslesir; gerekirse `--report-dir` ile acikca verilir.
- Masaustu arsivine birlesik (tum kosular) HTML dosyalari yazilir:
  - `kilit_yaris_<hipodrom>_tum_kosular_YYYYMMDD.html` (her hipodrom icin; o
    gun hangilerinde kos varsa; Elazig, Sanliurfa, Diyarbakir da dahil)
- Gunde hipodromlar icin kisa yol olusturulur: `DD.MM.YYYY <HIPODROM> Kilit Yaris.lnk` -> birlesik HTML.

## Ana Beyer projesi

Kaynak veriler kopya Beyer klasorunden degil ana Beyer projesinden alinir:

`C:\Users\Monster\Documents\Codex\2026-05-25\tjk-org-sitesinden-son-1-y\tjk_beyer_project`

## Kaynak veriler

- Bugunun temiz program CSV'leri: `C:\Users\Monster\Documents\Codex\2026-05-25\tjk-org-sitesinden-son-1-y\tjk_beyer_project\data\programs\YYYY-MM-DD_<hipodrom>_program_report.csv`
- Sonuc veritabani: `C:\Users\Monster\Documents\Codex\2026-05-25\tjk-org-sitesinden-son-1-y\tjk_beyer_project\tjk_beyer_v2.db`
- Accurace arsivi (denetim): `C:\Users\Monster\Documents\Codex\2026-05-25\tjk-org-sitesinden-son-1-y\tjk_beyer_project\data\accurace`
- Program klasoru (ikramiye takviyesi): `C:\Users\Monster\Documents\Codex\2026-05-25\tjk-org-sitesinden-son-1-y\tjk_beyer_project\data\programs`

Bu yollarin tek merkezi tanimi `src\config.py` icindeki `MAIN_BEYER` sabitidir.

## Calistirma (toplu mod)

Gunluk surucu, her hipodromun tum kosularini **tek Python surecinde** uretir
(--races all). Sonuc veritabani ve accurace taramasi kosu basina degil,
hipodrom basina bir kez yapilir; bu yuzden gunluk uretim dakikalar yerine
~20 saniye surer. Surucu, bir kosu eksik kalirsa yalnizca o kosuyu tek tek
yeniden dener.

Tek kosu komutu (elle/deneme icin) hala gecerlidir:

```
python src\kilit_yaris_analysis.py "<program_csv>" --track <HIPODROM> --race-no <N> --db "<ana beyer db>" --results-dir "<ana beyer accurace>" --official-program-dir "<ana beyer programlar>" --report --report-dir "<proje reports\kilit_yaris>"
```

- Kosu raporlari (txt+html): `reports\kilit_yaris\kilit_yaris_<hipodrom>_kosu_<N>_YYYYMMDD.html/.txt`
- Kosu sayisi program CSV'sindeki "kosu no" gruplarindan alinir (genelde 9-10 kosu).
- Loglar: `logs\kilit_yaris\YYYY-MM-DD_generation.log`

## Birlesik rapor uretimi

`src\daily_kilit_yaris_driver.py` isi ucta bir yapar:
1. Tum kosulari hipodrom bazinda toplu modda (--races all) calistirir; eksik kosu kalirsa tek tek tamamlar.
2. Kosu bazli HTML'lerden her hipodrom icin `tum_kosular` HTML'sini birlestirir ve **masaustu arsivine kopyalar**.
3. Birlesik `kilit_yaris_tum_kosular_YYYYMMDD.html` ve `kilit_yaris_index_YYYYMMDD.html` uretir (`reports\kilit_yaris\`).

Kisa yollar da masaustu arsivinde olusturulur/guncellenir.

Gece gorevi: `run_daily_kilit_yaris_after_beyer.ps1` once ana Beyer gorevi
(`TJK Gunluk Beyer Sonuc ve Program`) tamamlanmasini bekler, ardindan
`src\daily_kilit_yaris_driver.py --date YARIN` komutuyla yarinin butun
hipodrom ve kosularini uretir. `--dry-run` bayragi rapor uretmeden plani
gosterir.

## Kurallar

- Raporu masaustu arsivine yazmadan is bitmis sayma.
- Konsol ciktisi Turkce karakterlerde bozuk gorunebilir; sorun degil, asil cikti dosyalardadir.
- Veri tarih araligi ana Beyer DB'sinin guncel durumuna gore degisir; eksik veri uyarilari varsa raporlarda "Kontrol ozeti" icinde belirtilir.
