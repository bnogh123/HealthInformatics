# Ingestion.py - Ingest the code, profile, and transform the data for mySQL usage.

# take in info from the terminal parse_args()
# if blank, just use deeksha's address? lolz will discuss this later

import argparse
from pathlib import Path
import pandas as pd
import regex as re
import traceback

# Localized Version of Ingestion
DEFAULT_FOLDER = (Path.home() / "Downloads" / "Cloud-Native_Data_Engineering" / "Final_Project" / "fitbit")
IGNORED_FILES = {".DS_Store", "Thumbs.db", "desktop.ini"}  # mac / Windows junk files

def parse():
    parser = argparse.ArgumentParser(description="Process some files.")
    parser.add_argument(
        "foldername",
        nargs="?",
        default=str(DEFAULT_FOLDER),
        help="The input folder to read (defaults to the Fitbit project folder)",
    )
    return parser.parse_args().foldername

def main():
    fitbit_folder = Path(parse()).expanduser()

    if not fitbit_folder.is_dir():
        print(f"Folder not found: {fitbit_folder}")
        return

    try:
        files = [f for f in fitbit_folder.rglob("*") if f.is_file() and f.name not in IGNORED_FILES]

        for f in files:
            file_name = f.name 
            dates_folder = f.parent.name

            dates = re.findall(r"\d+\.\d+\.\d+", dates_folder)
            if len(dates) < 2:
                print(f"Skipping {f}: could not find two dates in '{dates_folder}'")
                print("ERROR")
                break

            df = pd.read_csv(f, encoding="cp1252")
            df["date_collected_start"] = dates[0]
            df["date_collected_end"] = dates[1]
            session_num = 1 if dates[0] == "3.12.16" else 2
            output_path = Path("ingested_data") / f"s{session_num}_{file_name}"
            output_path.parent.mkdir(parents=True, exist_ok=True)
            df.to_csv(output_path, index=False)

    except Exception as e:
        print(e)
        traceback.print_exc()

if __name__ == "__main__":
    main()