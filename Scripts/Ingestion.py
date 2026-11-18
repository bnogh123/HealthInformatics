# Ingestion.py - Ingest the code, profile, and transform the data for mySQL usage.

# take in info from the terminal parse_args()
# if blank, just use deeksha's address? lolz will discuss this later

import argparse
from pathlib import Path

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
        dirs = [d for d in fitbit_folder.rglob("*") if d.is_dir()]

        # each dir_name is the range in which the data was collected
        # for each file, add two folders of date_collected_start and date_collected_end
        # reformat; pull these files outside of their folders and into the main fitbit folder or create a folder in this repo with consolidated_dataset
        # once you consolidate that, transform/clean the data
        # maybe turn the above step into a separate file lolz
    except Exception as e:
        print(e)


if __name__ == "__main__":
    main()