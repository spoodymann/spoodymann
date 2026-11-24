"""
Gidişhat Avantajı günlük otomasyon runner'ı.

Her gece 22.00'de Windows Görev Zamanlayıcı ile çalıştırılır:
yarının yarış programlarını çekip gidişhat / tempo / koşu stili
raporlarını hipodrom ve koşu bazında üretir.

Çalıştırma örnekleri:
  python work/daily_gidisat_otomasyon.py                 # hedef = yarın
  python work/daily_gidisat_otomasyon.py --date 2026-08-15
  python work/daily_gidisat_otomasyon.py --dry-run       # planı göster, çalıştırma
"""

from __future__ import annotations

import argparse
import csv
import re
import shutil
import subprocess
import sys
from datetime import date, datetime, timedelta
from pathlib import Path

KOPYA_ROOT = Path(__file__).resolve().parents[1]
PROJECT = KOPYA_ROOT / "tjk_beyer_project"
PROGRAMS = PROJECT / "data" / "programs"
OUT_DIR = KOPYA_ROOT / "outputs"
LOG_DIR = KOPYA_ROOT / "logs" / "otomatik"
DEFAULT_DESKTOP = Path(r"C:\Users\Monster\OneDrive\Desktop\gidişhat analizi")

PYTHON = sys.executable

TRACKS = ["istanbul", "ankara", "bursa", "kocaeli", "izmir", "adana", "antalya"]

SRC = PROJECT / "src"
FETCH = SRC / "fetch_program_csv.py"
REPORT = SRC / "report_program.py"
GEN_TEMPO = KOPYA_ROOT / "work" / "generate_new_tempo_report.py"
GEN_COMBINED = KOPYA_ROOT / "work" / "generate_combined_report.py"

REPORT_CSV_FIELDS = [
    "program_date",
    "tarih",
    "hipodrom",
    "kosu no",
    "kosu sinifi",
    "pist",
    "mesafe",
    "birincilik ikramiyesi",
    "at no",
    "at adi",
]


def log_file_path(run_on: date) -> Path:
    return LOG_DIR / f"gunluk_{run_on.strftime('%Y%m%d')}.log"


def log(run_on: date, message: str) -> None:
    stamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"{stamp} | {message}"
    path = log_file_path(run_on)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as fh:
        fh.write(line + "\n")
    print(line)


def run(cmd: list[str], cwd: Path) -> tuple[str, int]:
    result = subprocess.run(
        cmd,
        cwd=str(cwd),
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    output = (result.stdout or "") + (result.stderr or "")
    return output.strip(), result.returncode


def fetch_track(run_on: date, target_date: str, track: str) -> Path | None:
    """Tek hipodromun program CSV'ini indirir; yoksa None döner."""
    cmd = [PYTHON, str(FETCH), "--date", target_date, "--tracks", track]
    output, code = run(cmd, PROJECT)
    path = PROGRAMS / f"{target_date}_{track}_program_report.csv"
    if code != 0 or not path.exists() or _csv_data_rows(path) < 1:
        log(run_on, f"fetch {track}: program yok / hata (code={code})")
        return None
    log(run_on, f"fetch {track}: OK -> {path.name}")
    return path


def _csv_data_rows(path: Path) -> int:
    with path.open(encoding="utf-8-sig") as fh:
        rows = list(csv.reader(fh))
    return max(0, len(rows) - 1)


def merge_program_csv(run_on: date, target_date: str, tracks: list[str]) -> Path | None:
    """Hipodrom program CSV'lerini birleştirip {date}_program_report.csv yazar."""
    rows: list[list[str]] = []
    fieldnames: list[str] = REPORT_CSV_FIELDS
    for track in tracks:
        path = PROGRAMS / f"{target_date}_{track}_program_report.csv"
        if not path.exists():
            continue
        with path.open(encoding="utf-8-sig") as fh:
            reader = csv.DictReader(fh)
            fieldnames = reader.fieldnames or fieldnames
            rows.extend(list(r.values()) for r in reader)
    if not rows:
        return None
    combined = PROGRAMS / f"{target_date}_program_report.csv"
    with combined.open("w", newline="", encoding="utf-8-sig") as fh:
        writer = csv.writer(fh)
        writer.writerow(fieldnames)
        writer.writerows(rows)
    log(run_on, f"combined program CSV: {len(rows)} at -> {combined.name}")
    return combined


def find_report_path(output: str) -> Path | None:
    match = re.search(r"HTML rapor:\s*(.+\.html)", output)
    return Path(match.group(1).strip()) if match else None


def run_layout_report(run_on: date, target_date: str, track_or_combined: str, path_csv: Path) -> Path | None:
    """report_program --layout tempo çalıştırır; çıktıyı outputs'a kopyalar."""
    out_html = REPORT_HTML_NAME(target_date, track_or_combined)
    cmd = [PYTHON, str(REPORT), str(path_csv), "--layout", "tempo"]
    output, code = run(cmd, PROJECT)
    if code != 0:
        log(run_on, f"tempo rapor {track_or_combined}: hata (code={code})")
        log(run_on, f"  -> {output[:2000]}")
        return None
    src = find_report_path(output)
    if src is None or not src.exists():
        log(run_on, f"tempo rapor {track_or_combined}: çıktı yolu bulunamadı")
        return None
    dest = OUT_DIR / out_html
    shutil.copy2(src, dest)
    log(run_on, f"tempo rapor {track_or_combined}: OK -> {dest.name}")
    return dest


def REPORT_HTML_NAME(target_date: str, track_or_combined: str) -> str:
    if track_or_combined == "combined":
        return f"{target_date}_gidisat_tempo_stil_raporu.html"
    return f"{target_date}_{track_or_combined}_gidisat_raporu.html"


def run_date_script(run_on: date, script: Path, target_date: str) -> None:
    cmd = [PYTHON, str(script), "--date", target_date]
    output, code = run(cmd, KOPYA_ROOT)
    if code != 0:
        log(run_on, f"{script.name}: hata (code={code})")
        log(run_on, f"  -> {output[:2000]}")
    else:
        log(run_on, f"{script.name}: OK")


def copy_to_desktop(run_on: date, dest: Path) -> None:
    if not DEFAULT_DESKTOP.exists():
        log(run_on, f"  desktop klasörü yok: {DEFAULT_DESKTOP}")
        return
    shutil.copy2(dest, DEFAULT_DESKTOP / dest.name)
    log(run_on, f"  kopya: {DEFAULT_DESKTOP / dest.name}")


def build_plan(target_date: str) -> list[str]:
    plan = [f"Çalışma klasörü: {KOPYA_ROOT}"]
    plan.append(f"Hedef tarih: {target_date}")
    plan.append("Kullanılacak scriptler:")
    plan.append(f"  - {FETCH} (program CSV indirme)")
    plan.append(f"  - {REPORT} --layout tempo (gidişhat/koşu stili raporu)")
    plan.append(f"  - {GEN_TEMPO} (tempo analizi raporu)")
    plan.append(f"  - {GEN_COMBINED} (gidişhat + tempo birleşik rapor)")
    plan.append("Veri kaynakları:")
    plan.append(f"  - TJK günlük yarış programı CSV (medya-cdn.tjk.org)")
    plan.append(f"  - {PROGRAMS} (indirilen program CSV arşivi)")
    plan.append(f"  - {PROJECT / 'tjk_beyer_v2.db'} (Beyer veritabanı, okuma amaçlı)")
    plan.append("Üretilecek HTML yolları (hipodrom ve koşu bazında):")
    for track in TRACKS:
        plan.append(f"  - {OUT_DIR / (target_date + '_' + track + '_gidisat_raporu.html')}")
        plan.append(f"  - {OUT_DIR / (target_date + '_' + track + '_tempo_analizi.html')}")
        plan.append(f"  - {OUT_DIR / (target_date + '_' + track + '_gidisat_ve_tempo.html')}")
    plan.append(f"  - {OUT_DIR / (target_date + '_gidisat_tempo_stil_raporu.html')} (birleşik)")
    plan.append(f"Log: {log_file_path(date.today())}")
    return plan


def main() -> None:
    parser = argparse.ArgumentParser(description="Gidişhat Avantajı günlük otomasyon runner")
    parser.add_argument("--date", help="Hedef tarih (YYYY-MM-DD). Varsayılan: yarın")
    parser.add_argument("--dry-run", action="store_true", help="Planı göster, hiçbir şey çalıştırma")
    parser.add_argument("--no-desktop", action="store_true", help="Masaüstü kopyasını atla")
    parser.add_argument("--gidishat", action="store_true",
                        help="Sehir bazli gidisat raporu da uret (varsayilan: uretme, 26.09.2026 karari)")
    args = parser.parse_args()

    run_on = date.today()
    target_date = args.date or (run_on + timedelta(days=1)).isoformat()

    if args.dry_run:
        for line in build_plan(target_date):
            print(line)
        return

    log(run_on, f"=== Gidişhat otomasyonu başladı | hedef: {target_date} ===")

    found_tracks: list[str] = []
    for track in TRACKS:
        path = fetch_track(run_on, target_date, track)
        if path is not None:
            found_tracks.append(track)

    if not found_tracks:
        log(run_on, "Hiçbir hipodromda program bulunamadı; işlem sonlandırıldı.")
        return

    # NOT (26.09.2026, kullanici karari): sehir bazli gidisat raporu
    # ({date}_{track}_gidisat_raporu.html) artik uretilmez ve masaustune
    # kopyalanmaz. Gerekirse --gidishat bayragi ile yeniden etkinlestirilebilir.
    if args.gidishat:
        for track in found_tracks:
            path = PROGRAMS / f"{target_date}_{track}_program_report.csv"
            dest = run_layout_report(run_on, target_date, track, path)
            if dest is not None and not args.no_desktop:
                copy_to_desktop(run_on, dest)
    else:
        log(run_on, "sehir gidisat raporu atlandi (--gidishat verilmedi)")

    combined = merge_program_csv(run_on, target_date, found_tracks)
    # NOT (26.09.2026, kullanici karari): birlesik gidisat/tempo-stil raporu
    # ({date}_gidisat_tempo_stil_raporu.html) artik uretilmez. CSV birlestirme
    # korunur (diger scriptler CSV'leri okur). --gidishat ile yeniden acilir.
    if combined is not None and args.gidishat:
        dest = run_layout_report(run_on, target_date, "combined", combined)
        if dest is not None and not args.no_desktop:
            copy_to_desktop(run_on, dest)
    elif combined is not None:
        log(run_on, "birlesik gidisat/tempo-stil raporu atlandi (--gidishat verilmedi)")

    run_date_script(run_on, GEN_TEMPO, target_date)
    run_date_script(run_on, GEN_COMBINED, target_date)

    log(run_on, f"=== Gidişhat otomasyonu tamamlandı | hedef: {target_date} ===")


if __name__ == "__main__":
    main()