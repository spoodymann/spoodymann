<#
  manual-run-daily-flow.ps1
  Tum gunluk akisi (22:00 gorevleri + site yukleme) manuel tetikler.
  Varsayilan: sadece komutlari listeler (guvenli).
  Gercek calistirma icin -Execute verin.
#>
param(
    [string]$Tarih = "",
    [switch]$Execute,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($Tarih)) {
    $Tarih = (Get-Date).AddDays(1).ToString('dd/MM/yyyy', [System.Globalization.CultureInfo]::InvariantCulture)
}

Write-Output "Hedef tarih: $Tarih"
Write-Output "Mod: $(if ($Execute) { 'EXECUTE' } else { 'DRY-RUN (komutlar listelenir)' })"
Write-Output ""

$steps = @(
    @{ Ad = 'Beyer full flow'; Cmd = 'cd "C:\Users\Monster\Documents\Codex\2026-05-25\tjk-org-sitesinden-son-1-y\tjk_beyer_project"; .\run_daily_full_flow.bat' },
    @{ Ad = 'Kilit yarış'; Cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Monster\Documents\Codex\kilit_yaris_projesi\run_daily_kilit_yaris_after_beyer.ps1"' },
    @{ Ad = 'İstatistik/galop'; Cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Monster\Documents\Codex\istatistik_projesi\run_daily_pipeline_serialized.ps1"' },
    @{ Ad = 'Gidişat/tempo'; Cmd = 'cd "C:\Users\Monster\Documents\Codex\2026-06-02\mevcut-tjk-beyer-accurace-sistemini-bozma\gidisat_avantaji"; python work\daily_gidisat_otomasyon.py' }
)

foreach ($s in $steps) {
    Write-Output "=== $($s.Ad) ==="
    Write-Output $s.Cmd
    if ($Execute) {
        Invoke-Expression $s.Cmd
        if ($LASTEXITCODE -ne 0) { Write-Output "HATA: $($s.Ad) (kod $LASTEXITCODE)"; exit $LASTEXITCODE }
    }
    Write-Output ""
}

$forceArg = if ($Force) { ' -Force' } else { '' }
$siteCmd = "powershell -NoProfile -ExecutionPolicy Bypass -File `"C:\Users\Monster\OneDrive\Belgeler\GitHub\spoodyman\scripts\site-yukle-22-30.ps1`" -Tarih $Tarih$forceArg"
Write-Output "=== Site yukleme ==="
Write-Output $siteCmd
if ($Execute) {
    Invoke-Expression $siteCmd
    if ($LASTEXITCODE -ne 0) { Write-Output "HATA: Site yukleme (kod $LASTEXITCODE)"; exit $LASTEXITCODE }
}

Write-Output ""
Write-Output "Bitti."