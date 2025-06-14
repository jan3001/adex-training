####------------------------------ Header ------------------------------####
# Program Name: RCC_202203_aas99498

# Developer: Anjana Suresh
# Current Version Number: 1
# Date: 09-Mar-2022
# OS / R Version: R version 4.1.1 (2021-08-10)
# Purpose: R Code Corners March 2022 (To develop ADEX dataset as per specs)
#-------------------------------------------------------------------------------

#get or set working directory 
getwd()

#loading required packages
library(gsktable)
library(dplyr)
library(readxl)
library(haven)
library(lubridate)

#reading the ADEX specification
adex_spec <- read_excel("./ADEX_spec.xlsx")

#reading the EX dataset
ex <- read_sas("./ex.sas7bdat")

#calculating durations
ex_durn_1 <- ex %>% arrange(USUBJID,EXSEQ) %>% group_by(USUBJID) %>% 
  slice(1) %>% ungroup() %>% mutate(ASTDT=as_date(EXSTDTC)) %>% 
  select(STUDYID, DOMAIN, USUBJID, ASTDT)

ex_durn_2 <- ex %>% arrange(USUBJID,desc(EXSEQ)) %>% group_by(USUBJID) %>% 
  slice(1) %>% ungroup() %>% mutate(AENDT=as_date(EXENDTC)) %>% 
  select(STUDYID, DOMAIN, USUBJID, AENDT)

ex_durn <- full_join(ex_durn_1, ex_durn_2, by=c("STUDYID","USUBJID","DOMAIN")) 

ex_param_1 <- ex_durn %>% mutate(PARAMCD="DURTRTD",
                                 PARAM="Duration of treatment (Days)",
                                 AVAL=as.numeric(AENDT-ASTDT+1))

#cumulative dose calculation
ex_param_2 <- ex %>% group_by(USUBJID) %>% mutate(AVAL=cumsum(EXDOSE)) %>% 
  arrange(USUBJID, desc(EXSEQ)) %>% slice(1) %>% ungroup() %>% 
  mutate(PARAMCD="CUMDOS",
         PARAM="Cumulative dose (mg)") %>% 
  select(STUDYID,DOMAIN,USUBJID,PARAMCD,PARAM,AVAL)              

#joining the 2 param tables together
ex_param <- bind_rows(ex_param_1, ex_param_2) %>% arrange(USUBJID,PARAMCD)

#adding labels 
adex <- ex_param %>% 
  select(STUDYID, DOMAIN, USUBJID, PARAMCD, PARAM, AVAL, ASTDT, AENDT) %>% 
  add_labels(STUDYID="Study Identifier",
             DOMAIN="Domain",
             USUBJID="Unique Subject Identifer",
             PARAMCD="Parameter Code",
             PARAM="Parameter",
             AVAL="Analysis Value",
             ASTDT="Analysis Start Date",
             AENDT="Analysis End Date")

#view the developed ADEX dataset       
View(adex)
