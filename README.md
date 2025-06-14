# ADEX Training Example

**Non-proprietary R script from GSK’s R training session** demonstrating how to derive the ADEX (Exposure Analysis) dataset from raw EX domain data.

---

## 📄 Overview

In March 2022, during GSK’s transition from SAS to R, this example script shows how to:

1. Load the official ADEX specification from an Excel workbook.
2. Read the raw EX domain SAS dataset (`ex.sas7bdat`).
3. Compute each subject’s treatment **start date** (`ASTDT`) and **end date** (`AENDT`).
4. Calculate **duration** (`DURTRTD`) and **cumulative dose** (`CUMDOS`) per subject.
5. Combine these parameters into a single ADEX analysis table.
6. Apply descriptive labels to each column for clarity.

> **Note:** This script is for training purposes. To run it, you must supply your own `ADEX_spec.xlsx` and `ex.sas7bdat` files in the working directory.

---

## ⚙️ File Structure

```
gsk-adex-training/
├── ADEX_training_example.R   # Main R script building the ADEX domain
├── ADEX_spec.xlsx            # Excel specification for ADEX (must supply)
├── ex.sas7bdat               # Raw EX domain SAS file (must supply)
└── README.md                 # This documentation
```

---

## 🔍 Script Breakdown

```r
####------------------------------ GSK Header ------------------------------####
# Program: RCC_202203_aas99498
# Developer: aas99498 / Anjana Suresh
# Date: 09-Mar-2022
# Purpose: R Code Corners March 2022 (ADEX dataset derivation)
#-------------------------------------------------------------------------------

# 1. Load required packages
library(gsktable)   # GSK-internal helper (remove or stub if unavailable)
library(dplyr)
library(readxl)
library(haven)
library(lubridate)

# 2. Read specification
adex_spec <- read_excel("ADEX_spec.xlsx")

# 3. Load EX domain data
ex <- read_sas("ex.sas7bdat")

# 4. Compute analysis start/end dates per subject
ex_start <- ex %>%
  arrange(USUBJID, EXSEQ) %>%
  group_by(USUBJID) %>%
  slice(1) %>%
  ungroup() %>%
  mutate(ASTDT = as_date(EXSTDTC)) %>%
  select(STUDYID, DOMAIN, USUBJID, ASTDT)

ex_end <- ex %>%
  arrange(USUBJID, desc(EXSEQ)) %>%
  group_by(USUBJID) %>%
  slice(1) %>%
  ungroup() %>%
  mutate(AENDT = as_date(EXENDTC)) %>%
  select(STUDYID, DOMAIN, USUBJID, AENDT)

# 5. Calculate duration and cumulative dose
ex_duration <- full_join(ex_start, ex_end, by = c("STUDYID","DOMAIN","USUBJID")) %>%
  mutate(
    PARAMCD = "DURTRTD",
    PARAM   = "Duration of treatment (Days)",
    AVAL    = as.numeric(AENDT - ASTDT + 1)
  )

ex_cumdose <- ex %>%
  group_by(USUBJID) %>%
  mutate(AVAL = cumsum(EXDOSE)) %>%
  arrange(USUBJID, desc(EXSEQ)) %>%
  slice(1) %>%
  ungroup() %>%
  mutate(
    PARAMCD = "CUMDOS",
    PARAM   = "Cumulative dose (mg)"
  ) %>%
  select(STUDYID, DOMAIN, USUBJID, PARAMCD, PARAM, AVAL)

# 6. Combine into ADEX domain
adex <- bind_rows(ex_duration, ex_cumdose) %>%
  arrange(USUBJID, PARAMCD) %>%
  add_labels(
    STUDYID="Study Identifier",
    DOMAIN="Domain",
    USUBJID="Unique Subject ID",
    PARAMCD="Parameter Code",
    PARAM="Parameter",
    AVAL="Analysis Value",
    ASTDT="Analysis Start Date",
    AENDT="Analysis End Date"
  )

# 7. Inspect the result
View(adex)
```

---

## 🔧 Dependencies

Install these R packages (version 4.x):

```r
install.packages(c("dplyr","readxl","haven","lubridate"))
# If gsktable is not publicly available, remove or replace its usage.
```

---

## ✉️ Contact

Anjana Suresh — jan3001
