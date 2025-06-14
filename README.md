# ADEX Training Example

**Non-proprietary R script from GSK’s R training session** demonstrating how to build the ADEX (Exposure) analysis dataset.

---

## 📄 Overview

In March 2022, as part of GSK’s transition from SAS to R, we practiced deriving the ADEX domain (exposure analysis) from the raw EX (exposure) dataset. This script:

1. Reads the official ADEX specification from Excel.  
2. Imports the EX domain SAS dataset.  
3. Calculates each subject’s treatment **start date** (`ASTDT`) and **end date** (`AENDT`), then computes **duration** (`DURTRTD`).  
4. Computes **cumulative dose** (`CUMDOS`) per subject.  
5. Binds both parameters into the final ADEX table.  
6. Applies descriptive labels to each column for clarity.

---

## Quick Start

1. **Clone or download** this repo.  
2. Place the following files in the same directory as the script:  
   - `ADEX_spec.xlsx` (the specification workbook)  
   - `ex.sas7bdat` (the raw SAS EX domain dataset)  
3. **Run the script**:  
   ```bash
   Rscript ADEX_training_example.R

---

## Dependencies
Install these packages in R (version 4.x):

install.packages(c("dplyr", "readxl", "haven", "lubridate"))
# `gsktable` was a GSK-internal helper; 
# if unavailable, remove or replace its calls.

---

## 📂 File Structure

```

gsk-adex-training/
├── ADEX\_training\_example.R   # Main R script to build ADEX domain
├── ADEX\_spec.xlsx            # Excel spec for ADEX (must supply)
└── README.md                 # This documentation

````

> **Note:** You’ll need to place your own `ex.sas7bdat` (raw EX domain SAS file) in this folder before running the script.

---

## 🔍 Script Breakdown

```r
####------------------------------ GSK Header ------------------------------####
# Program Name: RCC_202203_aas99498
# Developer: aas99498 / Anjana Suresh
# Date: 09-Mar-2022
# Purpose: R Code Corners March 2022 (To develop ADEX dataset as per specs)
#-------------------------------------------------------------------------------

# 1. Load packages
library(gsktable)   # GSK helper (stub or remove if unavailable)
library(dplyr)
library(readxl)
library(haven)
library(lubridate)

# 2. Read ADEX specification
adex_spec <- read_excel("ADEX_spec.xlsx")

# 3. Import raw EX domain (you must supply ex.sas7bdat)
ex <- read_sas("ex.sas7bdat")

# 4. Compute start/end dates per subject
#    - ASTDT: first dosing date
#    - AENDT: last dosing date
# (uses dplyr grouping and lubridate::as_date)

# 5. Calculate analysis parameters
#    - DURTRTD: duration (AENDT – ASTDT + 1)
#    - CUMDOS:  cumulative dose (cumsum of EXDOSE)

# 6. Assemble ADEX table
#    - Bind rows of duration and dose tables
#    - Add labels via add_labels()

# 7. Inspect final dataset
View(adex)
````

```
```

