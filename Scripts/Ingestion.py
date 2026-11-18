# Ingestion.py - Ingest the code, profile, and transform the data for mySQL usage.

# take in info from the terminal parse_args()
# if blank, just use deeksha's address? lolz will discuss this later

import argparse
from pathlib import Path
import pandas as pd
import regex as re
import traceback

DEFAULT_FOLDER = "/Users/deeksha_dwarakanath/Downloads/Cloud-Native_Data_Engineering/Final_Project/fitbit"

def parse():
    parser = argparse.ArgumentParser(description="Process some files.")
    parser.add_argument(
        "foldername",
        nargs="?",
        default=DEFAULT_FOLDER,
        help="The input folder to read (defaults to the Fitbit project folder)",
    )
    return parser.parse_args().foldername

def main():
    fitbit_folder = Path(parse())
    try:
        files = [f for f in fitbit_folder.rglob("*") if f.is_file()]
        
        for f in files:
            if ".DS_Store" not in str(f):
                f = str(f)
                file_directory, file_name = f.rsplit("/", 1) # change to \ for windows
                _, dates = file_directory.rsplit("/", 1) # again, change to \ for windows
                dates = re.findall(r"\d+\.\d+\.\d+", dates)
                df = pd.read_csv(f, encoding="cp1252")
                df['date_collected_start'] = dates[0]
                df['date_collected_end'] = dates[1]
                session_num = 1 if dates[0] == '3.12.16' else 2
                output_path = Path(f"ingested_data/s{session_num}_{file_name}")
                output_path.parent.mkdir(parents=True, exist_ok=True)
                df.to_csv(output_path, index=False)
    except Exception as e:
        print(e)
        traceback.print_exc()


if __name__ == "__main__":
    main()