# Kilit Yaris gece gorevi.
# 22:00'de baslar; ana Beyer gorevi (TJK Gunluk Beyer Sonuc ve Program) tamamlanana kadar,
# ayrica hedef gunun program CSV'leri diske yazilana kadar bekler, ardindan
# yarinin butun hipodrom ve kosulari icin kilit yaris raporlarini uretir.
# Rapor ciktisi masaustu arsivine yazilir.

param(
    [string]$Tarih = '',
    [switch]$Zorla
)

$ErrorActionPreference = 'Continue'

$root = 'C:\Users\Monster\Documents\Codex\kilit_yaris_projesi'
$python = 'C:\Users\Monster\AppData\Local\Programs\Python\Python313\python.exe'
$driver = Join-Path $root 'src\daily_kilit_yaris_driver.py'
$logDir = Join-Path $root 'logs\kilit_yaris'
if (-not (Test-Path -LiteralPath $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }
$taskLog = Join-Path $logDir ('kilit_yaris_task_' + (Get-Date -Format 'yyyyMMdd') + '.log')

function Log([string]$msg) {
    ("[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $msg) | Out-File -FilePath $taskLog -Append -Encoding utf8
}

Log '=== Kilit Yaris gorev baslangici ==='
Log ("Ana Beyer yolu: " + 'C:\Users\Monster\Documents\Codex\2026-05-25\tjk-org-sitesinden-son-1-y\tjk_beyer_project')
Log ("Driver: $driver")

# Cumartesi 22:00: ana akis 23:59'a alindi. Kilit yarisi da 23:59 tam
# akisinin sonunda (-Zorla) calisir; 22:00'de yarinin programi henuz yok.
if (-not $Zorla -and (Get-Date).DayOfWeek -eq 'Saturday') {
    Log 'Cumartesi: 22:00 kilit yaris gorevi atlandi (23:59 tam akisinda calisacak).'
    exit 0
}

# Ana Beyer gorevini bekle (max 6 saat).
$beyerName = 'TJK Gunluk Beyer Sonuc ve Program'
$beyerProgramsDir = 'C:\Users\Monster\Documents\Codex\2026-05-25\tjk-org-sitesinden-son-1-y\tjk_beyer_project\data\programs'
$deadline = (Get-Date).AddHours(6)
if ($Tarih -ne '') { $target = $Tarih } else { $target = (Get-Date).AddDays(1).ToString('yyyy-MM-dd') }
$beyerSeenRunning = $false
$beyerDone = $false

# Hedef gune ait en az bir program CSV'si diske yazilmissa hazir sayilir.
function Test-TargetProgramsReady {
    $found = Get-ChildItem -LiteralPath $beyerProgramsDir -Filter ($target + '_*_program_report.csv') -ErrorAction SilentlyContinue
    return ($null -ne $found -and @($found).Count -gt 0)
}

while (-not $Zorla -and (Get-Date) -lt $deadline) {
    try {
        $task = Get-ScheduledTask -TaskName $beyerName -ErrorAction Stop
        $state = $task.State.ToString()
        $info = Get-ScheduledTaskInfo -TaskName $beyerName
        $ranToday = ($info.LastRunTime -ge (Get-Date).Date)
        if ($state -eq 'Running') {
            $beyerSeenRunning = $true
            Log 'Beyer gorevi calisiyor, bekleniyor...'
            Start-Sleep -Seconds 60
            continue
        }
        if (($beyerSeenRunning -and $state -ne 'Running') -or
            ($ranToday -and $state -ne 'Running' -and $info.LastTaskResult -eq 0)) {
            if (Test-TargetProgramsReady) {
                $beyerDone = $true
                break
            }
            Log 'Beyer gorevi bitti ama hedef program CSV dosyalari henuz yok; bekleniyor...'
            Start-Sleep -Seconds 60
            continue
        }
        Start-Sleep -Seconds 60
    } catch {
        Log ('Beyer gorevi sorgulanamadi: ' + $_.Exception.Message)
        Start-Sleep -Seconds 60
    }
}

if ($Zorla) {
    $beyerDone = $true
    Log 'Zorla modu: Beyer gorevi beklenmedi (sonuclar ve program CSV tam akista hazir).'
}

if ($beyerDone) {
    Log 'Beyer gorevi tamamlandi ve program CSV dosyalari hazir; kilit yaris uretimine geciliyor.'
} else {
    Log 'UYARI: Beyer gorevi beklendi ama tamamlanmadi/zaman asimi; yine de suruluyor.'
}

Log ("Komut: $python $driver --date $target")

& $python $driver --date $target 2>&1 | Out-File -FilePath $taskLog -Append -Encoding utf8
Log ("=== Gorev bitti (exit=$LASTEXITCODE) ===")
exit $LASTEXITCODE