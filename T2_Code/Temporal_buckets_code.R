library(data.table)
library(dplyr)
library(ggplot2)
library("lubridate")
#install.packages("tidyverse")
#install.packages("zoo")
library(tidyverse)
library(zoo)
library(incidence)

study_pop_dem = read.csv('/Users/ec3696/Documents/T2CoachRCT-BaselineDemographic_DATA_2023-08-01_1416.csv')
setDT(study_pop_dem)

#include only data for final patient population

eligible_ids = read.csv('/Users/ec3696/Documents/final_records_list.csv')
setDT(eligible_ids)

eligible_ids[, record_id := as.factor(record_id)]
study_pop_dem[, record_id := as.factor(record_id)]

setkey(eligible_ids,record_id)
setkey(study_pop_dem,record_id)

study_pop_dem <- merge(eligible_ids,study_pop_dem,by="record_id")

setDT(study_pop_dem)


#temporal bucketing
class(study_pop_dem$consent_date)

#convert from Character to Date; stored in a new column
study_pop_dem$consent_date2 <- mdy(study_pop_dem$consent_date)
class(study_pop_dem$consent_date2)

#figuring out how to make date intervals (example; not T2 data)
vDates <- as.Date(c("2013-06-01","2013-05-01", "2013-06-13", "2013-05-11", "2013-07-08", "2013-07-18","2013-09-01", "2013-09-15"))
vDates.bymonth <- cut(vDates, breaks = "month")
dfDates <- data.frame(vDates, vDates.bymonth)

to.interval <- function(anchor.date, future.date, interval.days){
  round(as.integer(future.date - anchor.date) / interval.days, 0)}

dfDates$interval <- to.interval(as.Date('2013-05-01'), 
                                dfDates$vDates, 90 )


#store record id and conset date into a DF
dates <- subset(study_pop_dem,select=c('record_id','consent_date2'))
dates <- data.frame(dates)

#make date intervals for t2 data

# 90 day buckets
to.interval <- function(anchor.date, future.date, interval.days){
  round(as.integer(future.date - anchor.date) / interval.days, 0)}

dates$interval <- to.interval(as.Date('2020-01-28'), 
                                dates$consent_date2, 90 )

# 180 day buckets

dates$interval2 <- to.interval(as.Date('2020-01-28'), 
                              dates$consent_date2, 180 )

setDT(dates)

#combine the date info with the full dataset

study_pop_dem[, record_id := as.factor(record_id)]
dates[, record_id := as.factor(record_id)]

#create DT with eligible study IDS

setkey(study_pop_dem,record_id)
setkey(dates,record_id)

study_pop_dem <- merge(study_pop_dem,dates,by="record_id")
setDT(study_pop_dem)

#tab interval info (90 days)

study_pop_dem[,.N, by=interval]
prop.table(table(study_pop_dem$interval))

#tab interval info (180 days)

study_pop_dem[,.N, by=interval2]
prop.table(table(study_pop_dem$interval2))

