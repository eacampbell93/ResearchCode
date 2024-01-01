library(data.table)
library(dplyr)
library(ggplot2)
library("lubridate")
#install.packages("tidyverse")
#install.packages("zoo")
library(tidyverse)
library(zoo)
library(incidence)

#read in available IDs

available_ids = read.csv('/Users/ec3696/Documents/Available_Patient_IDs.csv')
setDT(available_ids)

#read in final IDs

final_ids = read.csv('/Users/ec3696/Documents/Patient_Study_IDs_final.csv')
setDT(final_ids)

#get record IDs 
final_ids[, patient_study_id := as.factor(patient_study_id)]
available_ids[, patient_study_id := as.factor(patient_study_id)]

setkey(final_ids,patient_study_id)
setkey(available_ids,patient_study_id)

final_records_list <- merge(final_ids,available_ids,by="patient_study_id")

setDT(final_records_list)

View(final_records_list)

write.csv(final_records_list, "/Users/ec3696/Documents/final_records_list.csv", row.names=FALSE)

