-- Data Cleaning

SELECT *
FROM world_tech_layoff.layoffs;

-- Step 1: Remove duplicates if any
-- Step 2: Standardize the data
-- Step 3: Handle null or blank values 
-- Step 4: Remove any unnecessary columns

-- Create a staging table
CREATE TABLE layoff_staging
LIKE world_tech_layoff.layoffs;
INSERT layoff_staging
select * from layoffs;

-- Removing Duplicates
WITH duplicates as(
select *,
row_number() OVER
(partition by company,location,total_laid_off,`date`,percentage_laid_off,industry,stage,funds_raised,country) as row_num
FROM layoff_staging
)
select *
from duplicates
where row_num>1;

select * from world_tech_layoff.layoff_staging where company='Beyond Meat';

CREATE TABLE `layoff_staging2` (
  `company` text,
  `location` text,
  `total_laid_off` text,
  `date` text,
  `percentage_laid_off` text,
  `industry` text,
  `source` text,
  `stage` text,
  `funds_raised` text,
  `country` text,
  `date_added` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Create a new staging table to preserve original dataset. Insert a new column row_num to identify duplicates
select * from layoff_staging2;
insert into layoff_staging2
select *,
row_number() OVER
(partition by company,location,total_laid_off,`date`,percentage_laid_off,industry,stage,funds_raised,country) as row_num
FROM layoff_staging;

-- Delete duplicates
select * 
from layoff_staging2
where row_num>1;
delete 
from layoff_staging2
where row_num>1;

-- Standardizing the dataset
update layoff_staging2
set company= trim(company);
update layoff_staging2
set location=trim(location);
update layoff_staging2
set total_laid_off=trim(total_laid_off);
update layoff_staging2
set industry=trim(industry);
update layoff_staging2
set country=trim(country);

-- Updated the correct country name after qerying all country names to ensure consistency
UPDATE layoff_staging2
SET COUNTRY= 'United Aran Emirates'
where country like 'UAE';

-- Dropped column source
Alter table layoff_staging2
drop column source;

-- Create 2 new columns to be able to split the location column so as to obtain the correct location
Alter table layoff_staging2
ADD COLUMN US_NON_US varchar(20);
Alter table layoff_staging2
ADD COLUMN CITY varchar(20);

-- Split the location column to get the City names
update layoff_staging2
SET US_NON_US = SUBSTRING_INDEX(location, ',', -1);
update layoff_staging2
SET CITY = SUBSTRING_INDEX(location, ',', 1);

-- Dropped columns location and US NONUS after getting the correct City names
ALTER TABLE layoff_staging2
DROP COLUMN location;
ALTER TABLE layoff_staging2
DROP COLUMN US_NON_US;

-- Update the date to the correct format
update layoff_staging2
set `date`=str_to_date(`date`,'%m/%d/%Y');
update layoff_staging2
set `date`=str_to_date(`date`,'%m/%d/%Y');

-- Update the total_laid_off to the correct format
update layoff_staging2
set total_laid_off=0
where total_laid_off is null or total_laid_off='';

alter table layoff_staging2
modify column total_laid_off int;

-- Modify funds raised column to the correct format
update layoff_staging2
set funds_raised=0
where funds_raised is null or funds_raised='';

-- Drop the date_added column as it is not useful
alter table layoff_staging2
drop column date_added;

-- Update the data type of the date column to date
alter table layoff_staging2
modify column `date` DATE;

-- Place column Country as the first column
ALTER TABLE layoff_staging2
modify column country text
FIRST;

-- Place column City after column country for ease of readability
ALTER TABLE layoff_staging2
MODIFY COLUMN CITY varchar(20)
AFTER country;

-- Update country name where possible 
update layoff_staging2 as t1
join layoff_staging2 as t2 
on t1.CITY=t2.CITY
set t1.country=t2.country
where (t1.country IS NULL OR t1.country='')
	and t2.country IS NOT NULL;

-- Update stages where possible 
update layoff_staging2 as t1
join layoff_staging2 as t2
on t1.country=t2.country
and t1.CITY=t2.CITY
set t1.stage=t2.stage
where t1.stage is null or t1.stage=''
and t1.stage is not null;

-- Delete entries without data in both Total and percentage laid off columns as such entries are not useful
delete
from layoff_staging2
WHERE (total_laid_off is null or total_laid_off='')
And (percentage_laid_off IS NULL OR percentage_laid_off='');

-- Drop the row_num column since it has served its purpose already
Alter table layoff_staging2
drop column row_num;

-- Final Cleaned Dataset
select * from layoff_staging2;