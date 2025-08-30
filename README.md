# SQL_DATA_CLEANING_WORLD_TECH_LAYOFF
This repository uses My SQL to clean Kaggle's world layoff dataset

# DATA
- The dataset for this project is obtained from Kaggle [here](layoffs_original_dataset.csv).
- The dataset contains `11 columns` and `4136 rows`

# TOOLS
- My SQL

**My SQL**:
- Create a new schema
- Import the file from tables, `Table Data Import Wizard`. Import the csv file as it is.
- Create a staging table to preserve the initial table data as it is.
  - **Step 1: Remove Duplicates if any:** Using CTEs(Common Table Expressions) and windows functions like `rownum()`, identify duplicates and remove them.
  - **Step 2: Standardize the dataset** by removing any beginning or trailing spaces, ensure consitency of names, deal with any multiple versions of any data using `update`,`set`,`where`,`trim` among others, ensure the date is in the correct format use `str_to_date`.
  - **Step 3: Handle null and blank values:** Using `update`, `Joins`, `is null`,`is not null` to update any nulls and blank spaces.
  - **Step 4:Delete any unnecessary rows and columns:** In this dataset, I deleted all entries that had total_paid_off and percentage paid off as blank. I also dropped some columns date added, Source. This can be achieved using `Alter`,`Drop` and `Delete`

# HOW TO RUN
- Run the [Data Cleaning Sql Script](Data_Cleaning%20Full%20Script.sql) on `MYSQL WORKBENCH`
