library(data.table)
library(dplyr)
library(ggplot2)
library("lubridate")
library(tidyverse)
library(zoo)

#eligible patients
eligible_ids = read.csv('/Users/ec3696/Documents/final_records_list2.csv')
setDT(eligible_ids)


#Misnamed my R script; this is actually the SCI-R analysis

scir = read.csv('/Users/ec3696/Documents/T2_demographic_characteristics/T2CoachRCT-SelfCareInventory_DATA_2023-07-25_1434.csv')
setDT(scir)

#create DT with SCI-R scores for eligible study IDS

scir[, record_id := as.factor(record_id)]
eligible_ids[, record_id := as.factor(record_id)]

setkey(scir,record_id)
setkey(eligible_ids,record_id)

scir2 <- merge(eligible_ids,scir,by="record_id")
setDT(scir2)

View(scir2)

## think about how to calculate this
## First: we will exclude responses from items 3, 13, and 15 since all patients have T2DM per the Khagram 2013 article

scir3 <- scir2[,c(1,2,3,6,8,9,11, 12, 13, 14, 15, 16, 17, 18, 20)]
setDT(scir3)

#tab counts so that I can get an idea of where the NA values are; Q 4, 5, and 10 have the NA

scir3[,.N, by=sci_r_4]
prop.table(table(scir3$sci_r_4))

scir3[,.N, by=sci_r_5]
prop.table(table(scir3$sci_r_5))

scir3[,.N, by=sci_r_10]
prop.table(table(scir3$sci_r_10))

#need to create DT with the patients who have q 4 and 5 as NA
#scir3_1 <- subset(scir3,sci_r_4 = 6, select=c(record_id, patient_study_id.x, consent_date, sci_r_1, sci_r_2, sci_r_4, sci_r_5, sci_r_6, sci_r_7, sci_r_9, sci_r_8, sci_r_10, sci_r_11, sci_r_12, sci_r_14))
scir3_1 <- subset(scir3, sci_r_4 == 6)
setDT(scir3_1)

#separate patients who have and do not have a value of 6 for q10

#(9 * 5 = 45)
scir3_1a <- subset(scir3_1, sci_r_10 == 6)
setDT(scir3_1a)
scir3_1a$full_score <- (scir3_1a$sci_r_1 + scir3_1a$sci_r_2 + scir3_1a$sci_r_6 + scir3_1a$sci_r_7 + scir3_1a$sci_r_9 + scir3_1a$sci_r_8 + scir3_1a$sci_r_11+ scir3_1a$sci_r_12 + scir3_1a$sci_r_14)
scir3_1a[, full_score := as.numeric(full_score)]
scir3_1a$full_score_normal <- ((scir3_1a$full_score *100)/45)

#(10 * 5 = 50)
scir3_1b <- subset(scir3_1, sci_r_10 == 2)
setDT(scir3_1b)
#scir$full_score <- (scir$sci_r_2 + scir$sci_r_4 + scir$sci_r_5 + scir$sci_r_6 + scir$sci_r_7 + scir$sci_r_9 + scir$sci_r_8 + scir$sci_r_10 + scir$sci_r_11 + scir$sci_r_12 + scir$sci_r_13 + scir$sci_r_14 + scir$sci_r_15)
#scir[, Study_ID := as.numeric(full_score)]
scir3_1b$full_score <- (scir3_1b$sci_r_1 + scir3_1b$sci_r_2 + scir3_1b$sci_r_6 + scir3_1b$sci_r_7 + scir3_1b$sci_r_9 + scir3_1b$sci_r_8 + scir3_1b$sci_r_10 + scir3_1b$sci_r_11 + scir3_1b$sci_r_12 + scir3_1b$sci_r_14)
scir3_1b[, full_score := as.numeric(full_score)]
scir3_1b$full_score_normal <- ((scir3_1b$full_score *100)/50)


#patients who don't have any NA values (12 * 5 = up to 60)
scir3_1c <- subset(scir3, sci_r_10 != 6)
scir3_1c <- subset(scir3_1c, sci_r_4 != 6)
setDT(scir3_1c)
scir3_1c$full_score <- (scir3_1c$sci_r_1 + scir3_1c$sci_r_2 + scir3_1c$sci_r_4 + scir3_1c$sci_r_5 + scir3_1c$sci_r_6 + scir3_1c$sci_r_7 + scir3_1c$sci_r_9 + scir3_1c$sci_r_8 + scir3_1c$sci_r_10 + scir3_1c$sci_r_11 + scir3_1c$sci_r_12 + scir3_1c$sci_r_14)
scir3_1c[, full_score := as.numeric(full_score)]
scir3_1c$full_score_normal <- ((scir3_1c$full_score *100)/60)

#patients with only 10 with NA (11 * 5 = up to 55)
scir3_1d <- subset(scir3, sci_r_10 == 6)
scir3_1d <- subset(scir3_1d, sci_r_4 != 6)
setDT(scir3_1d)
View(scir3_1d)
scir3_1d$full_score <- (scir3_1d$sci_r_1 + scir3_1d$sci_r_2 + scir3_1d$sci_r_4 + scir3_1d$sci_r_5 + scir3_1d$sci_r_6 + scir3_1d$sci_r_7 + scir3_1d$sci_r_9 + scir3_1d$sci_r_8 + scir3_1d$sci_r_11 + scir3_1d$sci_r_12 + scir3_1d$sci_r_14)
scir3_1d[, full_score := as.numeric(full_score)]
scir3_1d$full_score_normal <- ((scir3_1d$full_score *100)/55)


#after I get a SCI-R score for all patients, create a DT with the record ID, patient ID, consent date, and SCI-R score to create the histogram and time series graphs

scir3_1a_2 <- scir3_1a[,c(1,2,3,17)]
setDT(scir3_1a_2)

scir3_1b_2 <- scir3_1b[,c(1,2,3,17)]
setDT(scir3_1b_2)

scir3_1c_2 <- scir3_1c[,c(1,2,3,17)]
setDT(scir3_1c_2)

scir3_1d_2 <- scir3_1d[,c(1,2,3,17)]
setDT(scir3_1d_2)

#concatenate these 4 data tables
scir_final<- rbind(scir3_1a_2, scir3_1b_2, scir3_1c_2, scir3_1d_2)
setDT(scir_final)

#calculate 7-day rolling average
df1 <- data.frame(scir_final)
df1$Rolling_Mean_7<-ave(df1$full_score_normal,rep(1:(nrow(df1)/7),each=7),FUN=function(full_score_normal){mean(full_score_normal)})
df1
setDT(df1)
df1[, full_score_normal := as.numeric(full_score_normal)]

#combine rolling mean into scir2 DT

df1[, record_id := as.factor(record_id)]
setkey(df1,record_id)

scir_final <- merge(scir_final,df1,by="record_id")
setDT(scir_final)
scir_final$completion_date <- mdy(scir_final$consent_date.x)
class(scir_final$completion_date)


#create time-series graphs

#most basic
w <- ggplot(scir_final, aes(x= completion_date, y=full_score_normal.x)) +
  geom_line() + 
  xlab("")
w

#playing around with different graphs
p <- w + scale_x_date(date_labels = "%Y %b %d") 

# Final Time-Series Plot
p <- p + ggtitle("SCI-R Scores over T2 Study Duration") +
  xlab("Date") + ylab("SCI-R Score")

p<- p + geom_line(aes(y = Rolling_Mean_7), 
                  color = "red", 
                  size = .75)


## Make a histogram of SCI-R scores

e <- ggplot(scir_final, aes(x=full_score_normal.x)) + geom_histogram(binwidth=1, color="black", fill="white")
y <- e + geom_vline(aes(xintercept=mean(full_score_normal.x)),
                    color="blue", linetype="dashed", size=1)
#Final Histogram
y + labs(title="SCI-R Score histogram plot",x="SCI-R Score", y = "Count")

#Calculate summary statistics

mean(scir_final$full_score_normal.x)
median(scir_final$full_score_normal.x)
sd(scir_final$full_score_normal.x)

