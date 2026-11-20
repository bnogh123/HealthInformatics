import re
import traceback
from datetime import datetime
from pathlib import Path
import kagglehub
import pandas as pd

KAGGLE_DATASET = "arashnic/fitbit"
OUTPUT_DIR = Path("ingested_data")
DATE_RE = re.compile(r"\d{1,2}\.\d{1,2}\.\d{2}")

def find_dates(path):
    for parent in path.parents:
        dates = DATE_RE.findall(parent.name)
        if len(dates) >= 2:
            return dates[0], dates[1]
    return None

def to_iso(d):
    return datetime.strptime(d, "%m.%d.%y").strftime("%Y-%m-%d")

def main():
    folder = Path(kagglehub.dataset_download(KAGGLE_DATASET))

    jobs, skipped = [], []
    for f in sorted(folder.rglob("*.csv")):
        dates = find_dates(f)
        if dates is None:
            skipped.append(f)
        else:
            jobs.append((f, *dates))

    starts = sorted({to_iso(s) for _, s, _ in jobs})
    session_of = {s: i + 1 for i, s in enumerate(starts)}

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    done = 0
    for f, start, end in jobs:
        try:
            df = pd.read_csv(f, encoding="cp1252")
            df["date_collected_start"] = to_iso(start)
            df["date_collected_end"] = to_iso(end)
            out = OUTPUT_DIR / f"s{session_of[to_iso(start)]}_{f.name}"
            df.to_csv(out, index=False)
            done += 1
        except Exception as e:
            print(f"Failed on {f}: {e}")
            traceback.print_exc()

    print(f"Wrote {done}/{len(jobs)} files to {OUTPUT_DIR.resolve()}")
    for f in skipped:
        print(f"Skipped (no two dates in folder names): {f}")


if __name__ == "__main__":
    main()