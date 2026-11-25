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

def merge_wide_narrow(narrow_path, wide_path, value_col):
    # narrow: Id, ActivityMinute, <value_col>
    narrow = pd.read_csv(narrow_path)
    narrow["ActivityMinute"] = pd.to_datetime(narrow["ActivityMinute"], format="%m/%d/%Y %I:%M:%S %p")

    # wide: Id, ActivityHour, <value_col>00 ... <value_col>59  ->  one row per minute
    wide = pd.read_csv(wide_path)
    wide["ActivityHour"] = pd.to_datetime(wide["ActivityHour"], format="%m/%d/%Y %I:%M:%S %p")
    long = wide.melt(id_vars=["Id", "ActivityHour"], var_name="minute", value_name=value_col)
    long["ActivityMinute"] = long["ActivityHour"] + pd.to_timedelta(
        long["minute"].str[len(value_col):].astype(int), unit="m")
    long = long[["Id", "ActivityMinute", value_col]]

    # stack, then keep one row per (Id, ActivityMinute)
    return (pd.concat([narrow, long], ignore_index=True).drop_duplicates(["Id", "ActivityMinute"]).sort_values(["Id", "ActivityMinute"], ignore_index=True))

def merge_all():
    calories = merge_wide_narrow("minuteCaloriesNarrow_merged.csv", "minuteCaloriesWide_merged.csv", "Calories")
    intensities = merge_wide_narrow("minuteIntensitiesNarrow_merged.csv", "minuteIntensitiesWide_merged.csv", "Intensity")
    steps = merge_wide_narrow("minuteStepsNarrow_merged.csv", "minuteStepsWide_merged.csv", "Steps")
    for df in (calories, intensities, steps):
        df["session_id"] = 2
    calories.to_csv("ingested_data/minuteCaloriesNarrow_merged.csv", index=False)
    intensities.to_csv("ingested_data/minuteIntensitiesNarrow_merged.csv", index=False)
    steps.to_csv("ingested_data/minuteStepsNarrow_merged.csv", index=False)

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
            merge_all()
            type_casting()
            imputation()
            print("Data cleanup successful!")
        case _:
            print("Unknown value: use the keywords eda or clean")
