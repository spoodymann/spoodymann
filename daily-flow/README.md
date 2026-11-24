# Günlük Akış Konsolidasyonu (Spoodyman)

Bu klasör, Spoodyman at yarışı sitesinin günlük otomatik akışını (beyer üretimi, 22:00 görevleri, site yükleme, rapor üretimi) tek yerde toplar.  
Amaç: OpenCode dışında başka bir yapay zeka bu klasörü okuyup günlük akışı aksatmadan sürdürebilsin.

## Klasör yapısı

- `GUNLUK_AKIS.md` — günlük akışın tam adımı adım açıklaması
- `YOLLAR.md` — tüm kaynak/dış proje/site yolları
- `GOREV_ZAMANLAYICI.md` — Windows Görev Zamanlayıcı tanımları
- `MANUEL_KOMUTLAR.md` — manuel çalıştırma komutları
- `SORUN_GIDERME.md` — sık hatalar ve çözümler
- `external-agents/` — dış projelerin `AGENTS.md` kopyaları
- `runners/` — giriş scriptlerinin kopyaları
- `scheduled-tasks/` — görev XML export'ları
- `manual-run-daily-flow.ps1` — tüm akışı manuel tetikleyen yardımcı script (varsayılan: sadece komutları gösterir)

## Temel kural

**Hiçbir kaynak silinmez/kopyalanmaz dışında ekleme yapılmaz.**  
Mevcut otomatik akış (görev zamanlayıcı + scriptler) aynı yollarla çalışmaya devam eder. Bu klasör referans + yedek amaçlıdır.

## Asıl website klasörü

`C:\Users\Monster\OneDrive\Belgeler\GitHub\spoodyman`

Tüm site güncellemeleri, commit ve push orada yapılır. `AGENTS.md` geçerli talimatları içerir.