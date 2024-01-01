
#install.packages("tidyverse")
#install.packages("zoo")
library(data.table)
library(dplyr)
library(ggplot2)
library("lubridate")
library(tidyverse)
library(zoo)

#DT with eligible study IDs

eligible_ids = read.csv('/Users/ec3696/Documents/T2_demographic_characteristics/2Eligible_IDs.csv')
setDT(eligible_ids)


scir = read.csv('/Users/ec3696/Documents/T2_demographic_characteristics/T2CoachRCT-SelfCareInventory_DATA_2023-07-25_1434.csv')
setDT(scir)

#Variable names: sci_r_2, sci_r_4, sci_r_5, sci_r_6, sci_r_7, sci_r_9, sci_r_8, sci_r_10, sci_r_11, sci_r_12, sci_r_13, sci_r_14, sci_r_15

scir$full_score <- (scir$sci_r_2 + scir$sci_r_4 + scir$sci_r_5 + scir$sci_r_6 + scir$sci_r_7 + scir$sci_r_9 + scir$sci_r_8 + scir$sci_r_10 + scir$sci_r_11 + scir$sci_r_12 + scir$sci_r_13 + scir$sci_r_14 + scir$sci_r_15)
scir[, Study_ID := as.numeric(full_score)]

#get rid of test cases

scir[, record_id := as.factor(record_id)]
eligible_ids[, record_id := as.factor(record_id)]

#create DT with eligible study IDS

setkey(scir,record_id)
setkey(eligible_ids,record_id)

scir3 <- merge(eligible_ids,scir,by="record_id")
setDT(scir3)

#get rid of rows with NA values for total score (missing some questions)

scir2 <- scir3[-17,]
scir2 <- scir2[-258,]
scir2 <- scir2[-257,]
setDT(scir2)

mean(scir2$full_score)
median(scir2$full_score)
sd(scir2$full_score)

#Check that the date variable is actually a date
sapply(scir2, is.Date)
class(scir2$completion_date)

#completion_date is not DATE; convert from Character to Date; stored in a new column (not terribly efficient)
scir2$completion_date2 <- ymd(scir2$completion_date)
class(scir2$completion_date2)

#calculating rolling mean as a numeric variable

scir2a <- subset(scir2,select=c('record_id','full_score','completion_date2'))
df1 <- data.frame(scir2a)
df1$Rolling_Mean_7<-ave(df1$full_score,rep(1:(nrow(df1)/7),each=7),FUN=function(full_score){mean(full_score)})
df1
setDT(df1)
df1[, full_score := as.numeric(full_score)]

#combine rolling mean into scir2 DT

df1[, record_id := as.factor(record_id)]
setkey(df1,record_id)

scir2 <- merge(scir2,df1,by="record_id")
setDT(scir2)

#create time-series graphs

w <- ggplot(scir2, aes(x=completion_date2.x, y=full_score.x)) +
  geom_line() + 
  xlab("")
w

p <- w + scale_x_date(date_labels = "%Y %b %d") 

# Final Time-Series Plot
p <- p + ggtitle("Self-Care Inventory-Revised (SCI-R) Scores over T2 Study Duration") +
  xlab("Date") + ylab("SCI-R Score")

p<- p + geom_line(aes(y = Rolling_Mean_7), 
                  color = "red", 
                  size = .75)

## Make a histogram of SCI-R scores

e <- ggplot(scir2, aes(x=full_score)) + geom_histogram(binwidth=1, color="black", fill="white")
y <- e + geom_vline(aes(xintercept=mean(full_score)),
                    color="blue", linetype="dashed", size=1)
#Final Histogram
y + labs(title="SCI-R Score histogram plot",x="SCI-R Score", y = "Count")

#PAID Score Analysis
paid = read.csv('/Users/ec3696/Documents/T2_demographic_characteristics/T2CoachRCT-PAID_DATA_2023-07-25_1435.csv')
setDT(paid)

#get rid of test cases
paid[, record_id := as.factor(record_id)]

setkey(paid,record_id)
setkey(eligible_ids,record_id)

paid2 <- merge(eligible_ids,paid,by="record_id")
setDT(paid2)

#patient 283 (row 258) and patient 20 (row 14) missing data
paid2 <- paid2[-258,]
paid2 <- paid2[-14,]

#summary statistics
mean(paid2$paid_score)
median(paid2$paid_score)
sd(paid2$paid_score)

#format date
paid2$consent_date2 <- mdy(paid2$consent_date)

# calculate rolling average
paid2a <- subset(paid2,select=c('record_id','paid_score','consent_date2'))
df2 <- data.frame(paid2a)
df2$Rolling_Mean_7<-ave(df2$paid_score,rep(1:(nrow(df2)/7),each=7),FUN=function(paid_score){mean(paid_score)})
df2
setDT(df2)
df2[, paid_score := as.numeric(paid_score)]

#combine rolling mean into paid DT

df2[, record_id := as.factor(record_id)]
setkey(df2,record_id)

paid2 <- merge(paid2,df2,by="record_id")
setDT(paid2)


#time series plot for PAID
v <- ggplot(paid2, aes(x=consent_date2.x, y=paid_score.x)) +
  geom_line() + 
  xlab("")
v <- v + scale_x_date(date_labels = "%Y %b %d") 
v <- v + ggtitle("Problem Areas in Diabetes (PAID) Scores over T2 Study Duration") +
  xlab("Date") + ylab("PAID Score")

v + geom_line(aes(y = Rolling_Mean_7), 
              color = "red", 
              size = .75)

#create histogram
e2 <- ggplot(paid2, aes(x=paid_score)) + geom_histogram(binwidth=1, color="black", fill="white")
y2 <- e2 + geom_vline(aes(xintercept=mean(paid_score)),
                      color="blue", linetype="dashed", size=1)
#Final Histogram
y2 + labs(title="PAID Score Histogram",x="PAID Score", y = "Count")


#add the scores into the full demographic baseline dataset; need to figure out if we drop or retain people 
#with incomplete self management data

## Self Efficacy Analysis

self_efficacy = read.csv('/Users/ec3696/Documents/T2_demographic_characteristics/T2CoachRCT-SelfEfficacy_DATA_2023-07-25_1434.csv')
setDT(self_efficacy)

#get rid of test cases

self_efficacy[, record_id := as.factor(record_id)]

setkey(self_efficacy,record_id)

self_efficacy <- merge(eligible_ids,self_efficacy,by="record_id")
setDT(self_efficacy)

#Variable names: self_efficacy_q11, self_efficacy_q2, self_efficacy_q3, self_efficacy_q4, self_efficacy_q5, self_efficacy_q6, self_efficacy_q7, self_efficacy_q8

self_efficacy$full_score <- (self_efficacy$self_efficacy_q11 + self_efficacy$self_efficacy_q2 + self_efficacy$self_efficacy_q3 + self_efficacy$self_efficacy_q4 + self_efficacy$self_efficacy_q5 + self_efficacy$self_efficacy_q6 + self_efficacy$self_efficacy_q7 + self_efficacy$self_efficacy_q8)
self_efficacy[, full_score := as.numeric(full_score)]

#patient 283 (row 258)  missing data
self_efficacy <- self_efficacy[-258,]

#summary statistics
mean(self_efficacy$full_score)
median(self_efficacy$full_score)
sd(self_efficacy$full_score)

#format date
self_efficacy$consent_date2 <- mdy(self_efficacy$consent_date)

# calculate rolling average
self_efficacy2 <- subset(self_efficacy,select=c('record_id','full_score','consent_date2'))
df3 <- data.frame(self_efficacy2)
df3$Rolling_Mean_7<-ave(df3$full_score,rep(1:(nrow(df3)/7),each=7),FUN=function(full_score){mean(full_score)})
df3
setDT(df3)
df3[, full_score := as.numeric(full_score)]

#combine rolling mean into scir2 DT

df3[, record_id := as.factor(record_id)]
setkey(df3,record_id)

self_efficacy <- merge(self_efficacy,df3,by="record_id")
setDT(self_efficacy)


a <- ggplot(self_efficacy, aes(x=consent_date2.x, y=full_score.x)) +
  geom_line() + 
  xlab("")
a

z <- a + scale_x_date(date_labels = "%Y %b %d") 

# Final Time-Series Plot
z <- z + ggtitle("Self-Efficacy Scores over T2 Study Duration") +
  xlab("Date") + ylab("Self-Efficacy Score")

z <- z + geom_line(aes(y = Rolling_Mean_7), 
                   color = "red", 
                   size = .75)

## Make a histogram of self-efficacy scores

k <- ggplot(self_efficacy, aes(x=full_score.x)) + geom_histogram(binwidth=1, color="black", fill="white")
q <- k + geom_vline(aes(xintercept=mean(full_score.x)),
                    color="blue", linetype="dashed", size=1)
#Final Histogram
q + labs(title="Self-Efficacy Score histogram plot",x="Self-Efficacy Score", y = "Count")


