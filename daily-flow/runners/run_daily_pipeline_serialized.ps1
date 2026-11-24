param(
    [int]$MaxBeklemeDk = 200,
    [string]$Tarih = '',
    [switch]$CumartesiZorla
)

$ErrorActionPreference = 'Stop'

# Cumartesi: Diyarbakir son yarisi 23:30'da kosuldugu icin 22:00 akisi atlanir.
# Bu hat Cumartesi 23:59 tam akisinin sonunda -CumartesiZorla ile cagrilir.
if (-not $CumartesiZorla -and (Get-Date).DayOfWeek -eq 'Saturday') {
    Write-Output 'Cumartesi: 22:00 istatistik akisi atlandi (23:59 tam akisinda calisacak).'
    exit 0
}

$Py = 'C:\Users\Monster\AppData\Local\Programs\Python\Python313\python.exe'
$Pipeline = 'C:\Users\Monster\Documents\Codex\istatistik_projesi\run_daily_pipeline.py'
# Sonuc isleme gorevleri: normal gun 22:00 akisi + Cumartesi 23:59 tam akis.
# Rapor, gunun sonuclari DB'ye islenmeden URETILMEZ (tarih araligi notu geri kalmasin).
# -CumartesiZorla: sonuclar az once tam akista islendi; gorev beklemesi gerekmez
# (beklenirse kendi calistiran 23:59 gorevini bekleyip kilitlenir).
$OndeGorevler = @()
if (-not $CumartesiZorla) {
    $OndeGorevler = @(
        'TJK Gunluk Beyer Sonuc ve Program',
        'TJK Gunluk Diyarbakir Beyer'
    )
}

$baslangic = Get-Date
while ($true) {
    $calisan = @()
    foreach ($ad in $OndeGorevler) {
        try {
            $t = Get-ScheduledTask -TaskName $ad -ErrorAction Stop
            if ($t.State -eq 'Running') { $calisan += $ad }
        } catch {
            # gorev yoksa yok say
        }
    }
    if ($calisan.Count -eq 0) { break }
    if (((Get-Date) - $baslangic).TotalMinutes -ge $MaxBeklemeDk) {
        Write-Output "UYARI: sonuc gorevleri zaman asimi ($MaxBeklemeDk dk) - istatistik yine de baslatiliyor."
        break
    }
    Write-Output "Bekleniyor: $($calisan -join ', ') hala calisiyor ($(Get-Date -Format 'HH:mm:ss'))"
    Start-Sleep -Seconds 30
}

# Ek guvenlik: pipeline kendisi de onceki gunun sonuclarini DB'de bekler
# (Cumartesi 23:59 akisi gibi gec gelen sonuclar icin).
# Cumartesi 23:59 zincirinde gece yarisini gectigi icin hedef tarih acikca verilir.
$argList = @($Pipeline)
if ($Tarih -ne '') { $argList += @('--date', $Tarih) }
# Zincirden cagrildigimizda gorev "Running" gorunur; 45 dk bos bekleme olmasin.
if ($CumartesiZorla) { $argList += '--no-task-wait' }
& $Py @argList
exit $LASTEXITCODE
