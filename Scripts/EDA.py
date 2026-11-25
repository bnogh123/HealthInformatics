# Data Profiling & Cleaning
# separate the profiling and cleaning portions

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
import os
import argparse

folder_path = Path("ingested_data/")

def parse():
    parser = argparse.ArgumentParser(description="Process some files.")
    parser.add_argument(
        "type",
        nargs="?",
        default="eda",
        choices=["eda", "clean"],
        help="Switch between eda and data cleanup",
    )
    return parser.parse_args().type

def record_counts():
    counts = {file.name: len(pd.read_csv(file, usecols=[0]))for file in folder_path.glob("*.csv")}

    summary_df = pd.DataFrame(list(counts.items()), columns=["File", "Record_Count"])
    print(summary_df)

def schema_documentation_null_analysis():
    for file_path in folder_path.glob("*.csv"):
        print(f"=== Schema for: {os.path.basename(file_path)} ===")
        df = pd.read_csv(file_path)
        df.info()
        print(df.isna().sum())
        print("\n")
    # s1_weightLogInfo_merged.csv & s2: Fat -- 31 null or missing values -- why? MNAR

def deduplication():
    # minuteSleep has 525 exact duplicate rows, so you need drop_duplicates() in Ingestion.py or the PK will reject them
    df1 = pd.read_csv('ingested_data/minuteSleep')
    df1 = df1.drop_duplicates()
    df1.to_csv('ingested_data/minuteSleep', index=False)

# type casting
# 1. To DATETIME: hourly* files + wide files --> ActivityHour
# 2. To DATETIME: minute*Narrow files --> ActivityMinute
# 3. to datetime: heartrate_seconds.Time
# 4. to datetime: minuteSleep.date
# 5. to datetime: weightLogInfo.Date
# 6. to date: dailyActivity.ActivityDate
# 7. to date: dailyCalories.ActivityDay, dailyIntensities.ActivityDay, dailySteps.ActivityDay
# 8. to date: sleepDay.SleepDay
# 9. to boolean: weightLogInfo.IsManualReport
def type_casting():
    df = pd.read_csv("ingested_data/s1_weightLogInfo_merged.csv", dtype={"IsManualReport": bool})
    df.to_csv("ingested_data/s1_weightLogInfo_merged.csv", index=False)


# imputation strategies
# drop the fat column in both s1 and s2 -- its not necessary when there are only four collected values in total
# it's most likely missing MNAR, so we could also replace the null values with a "missingness" value or perform sensitivity analysis
def imputation():
    df1 = pd.read_csv('ingested_data/s1_weightLogInfo_merged.csv')
    df2 = pd.read_csv('ingested_data/s2_weightLogInfo_merged.csv')
    df1 = df1.drop(columns=['Fat'], errors="ignore")
    df2 = df2.drop(columns=['Fat'], errors="ignore")
    df1.to_csv('ingested_data/s1_weightLogInfo_merged.csv', index=False)
    df2.to_csv('ingested_data/s2_weightLogInfo_merged.csv', index=False)

# statistical anomalies

# correlations


if __name__ == "__main__":
    condition = parse()

    match condition:
        case "eda":
            record_counts()
            schema_documentation_null_analysis()
        case "clean":
            deduplication()
            type_casting()
            imputation()
            print("Data cleanup successful!")
        case _:
            print("Unknown value: use the keywords eda or clean")
