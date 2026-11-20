# Data Profiling

import pandas as pd
import numpy as np
import matplotplib.pyplot as plt
from pathlib import Path
import os

folder_path = Path("ingested_data/")

# record counts
counts = {
    file.name: len(pd.read_csv(file, usecols=[0]))
    for file in folder_path.glob("*.csv")
}

summary_df = pd.DataFrame(list(counts.items()), columns=["File", "Record_Count"])
print(summary_df)

# schema documentation & null value analysis
for file_path in folder_path:
    print(f"=== Schema for: {os.path.basename(file_path)} ===")
    df = pd.read_csv(file_path)
    df.info()
    print(df.isna().sum())
    print("\n")

# deduplication
# type casting
# imputation strategies
# statistical anomalies
# correlations
