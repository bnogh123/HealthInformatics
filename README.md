# HealthInformatics

include step-by-step reproduction commands (formalize these)

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