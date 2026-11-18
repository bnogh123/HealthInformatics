# HealthInformatics

include step-by-step reproduction commands (formalize these)

## Resources To Download:
1. *Data Acquisition & Prep* -- VSCode/Pycharm & Python
2. *Core Relational Store* - MySQL (or PostgreSQL)
3. *Cloud Warehousing & Lakehouse* - Snowflake
4. *Packaging & Deployment* -- Docker containers
5. *CI/CD & Testing* - GitHub Actions (do not need to download)
6. *Interactive Delivery* - ?

## Setting Up The Dataset

1. Import the dataset from [here](https://www.kaggle.com/datasets/arashnic/fitbit).
2. Open the ZIP file.
3. Git clone this repository as such:

```python
git clone https://github.com/bnogh123/HealthInformatics.git
```

## Cleaning And Transforming The Dataset

4. Run Ingestion.py with the below command (replace {dataset_folder}) with where your fitbit/ folder is located in your local laptop.

```python
python Scripts/Ingestion.py {dataset_folder}
```

At this point, you should also have a folder in your directory called `ingested_data` that stores all the required data needed.

5. Switch over to mySQL / PostgreSQL and run the following DDL and DML scripts.