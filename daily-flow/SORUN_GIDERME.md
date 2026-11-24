# Sorun Giderme

## TJK 403 / Incapsula
- Scriptler tarayıcı User-Agent kullanır.
- Tekrar 403 olursa kullanıcıdan saat bilgisini iste ve manuel çalıştır.

## Git bulunamadı
- Tam yol kullan: `C:\Program Files\Git\cmd\git.exe`
- Kısayol: `C:\Users\Monster\AppData\Roaming\npm\git.cmd`

## Site güncellenmiyor (Pages deploy düştü)
- `site-yukle-22-30.ps1` push sonrası Actions'ı izler.
- Deploy düşerse boş commit ile en fazla 2 kez yeniden tetikler.
- Hâlâ yayınlanmazsa GitHub Desktop ile Commit to main → Push origin.

## Kulvar kolonu eksik
Kontrol sırası:
1. Tempo kaynağında `class="gate-chip"` var mı?
2. `data\programs\<tarih>_<sehir>_program_raw.csv` mevcut mu?
3. Python'da `bs4` yükleniyor mu? (proje içi `.codex-python-packages`)
4. Program CSV'sinde `St` kolonu `5 - DS` gibi ek notlu mu? (baştaki rakam alınır)
- Çıkış kodu 1 verir; bildirimde `KULVAR YOK`.

## Sınıf tik kolonları eksik
- Üreteç eski sürüme dönmüş olabilir.
- Manuel: `python work\make_sinif_dusme_analizi.py --date YYYY-MM-DD`
- Çıkış kodu 1; bildirimde `SINIF TIK YOK`.

## Sınıf düşme raporu yok
- Site yükleme sırasında otomatik üretilir.
- Üretilemezse bildirimde `SINIF DUSME YOK: <sehir>` ve çıkış kodu 1.

## İstatistik raporu üretilmedi (wait_for_results)
- `races.max(date) >= hedef - 1 gun` koşulu sağlanmalı.
- Onceki günün sonuçları DB'ye işlenmemiş olabilir.
- Manuel: `--allow-stale` ile çalıştır (önerilmez; veri eksik olur).
- Cumartesi 22:00 akışı atlanır (23:59 akışı kapsar).

## Değerlendirme dosyası yok
- Sonuçlar DB'de olmalı.
- `daily_result_evaluation.py --date <önceki_gün> --split-tracks` çalıştır.
- `general` ve `ayni_yuzey` dosyaları yüklenmez.

## Kulvar Python bulunamadı
- Adaylar: codex runtime python, sonra `python.exe` PATH.
- `BulKulvarPython` fonksiyonu kontrol eder.

## Kaynak klasör temizliği yanlışlıkla silme
- Yalnızca en güncel gün kalır; eski dosyalar kalıcı silinir.
- Geri dönüşüm kutusundan da silinir (Shift+Delete).
- WhatIf ile test et: `-WhatIf`.

## Cumartesi akışı
- 22:00 ana akış atlanır (`run_daily_full_flow.bat` Saturday kontrolü).
- 23:59 Diyarbakır tam akışı çalışır ve site yükleme `-Force` ile yapılır.