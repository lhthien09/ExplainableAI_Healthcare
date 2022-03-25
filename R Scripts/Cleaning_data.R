library(haven)
setwd("C:/Users/DELL/OneDrive - Politechnika Warszawska/STAR_SAS/STAR_SAS/SAS Dataset 202109/Liver/Waiting List History")


df <- read_sas("liver_wlhistory_data.sas7bdat")
summary(df)

View(df)

liver_data <- liver_data
table(liver_data[,"REM_CD"])
sum(table(liver_data[,"REM_CD"]))
sum(table(liver_data[,"COD_WL"]))
dim(na.omit(liver_data[,"REM_CD"]))
dim(na.omit(liver_data[,"COD_WL"]))

View(liver_data[,"REM_CD"])


###################### Read dat file ########################
library(readr)
library(dplyr)

allLines <- readLines(con = file('C:/Users/DELL/OneDrive - Politechnika Warszawska/STAR_SAS/STAR_SAS/CODE DICTIONARY - FORMATS 202109/Liver/LIVER_FORMATS_FLATFILE.DAT'), 'r')
grepB <- function(x) grepl('^B',x)
BLines <- filter(grepB, allLines)
df <- as.data.frame(strsplit(BLines, ";"))

dataframe <- liver_data %>% select("ALBUMIN_TX","ASCITES_TX","BW4","BW6","C1","C2",
                                   "CREAT_TX","DQ1","DQ2","DR51","DR51_2","DR52",
                                   "DR52_2","DR53","DR53_2","ENCEPH_TX",
                                   "FINAL_ALBUMIN","FINAL_ASCITES","FINAL_BILIRUBIN",
                                   "FINAL_CTP_SCORE","FINAL_DIALYSIS_PRIOR_WEEK",
                                   "FINAL_ENCEPH","FINAL_INR","FINAL_MELD_OR_PELD",
                                   "FINAL_MELD_PELD_LAB_SCORE","FINAL_SERUM_CREAT",
                                   "FINAL_SERUM_SODIUM", "INIT_ALBUMIN","INIT_ASCITES",
                                   "INIT_BILIRUBIN","INIT_CTP_SCORE", "INIT_ENCEPH","INIT_INR","INIT_MELD_OR_PELD"
                                   ,"INIT_MELD_PELD_LAB_SCORE",
                                   "INIT_SERUM_CREAT",
                                   "INIT_SERUM_SODIUM",
                                   "INR_TX",
                                   "NUM_PREV_TX",
                                   "REM_CD", "TBILI_TX", "TRR_ID_CODE")

dim(dataframe)


dataframe$TRR_ID_CODE[dataframe$TRR_ID_CODE == ""]<- NA
View(dataframe[,"TRR_ID_CODE"])

sum(is.na(dataframe$TRR_ID_CODE))
dim(dataframe)
View(dataframe[,"REM_CD"])
cleaned_data <- dataframe %>% filter( !is.na(TRR_ID_CODE) | REM_CD %in% c(8,13,21,23))
dim(cleaned_data)


cleaned_data <- cleaned_data %>% mutate(Transplanted_perform = ifelse(!is.na(TRR_ID_CODE),1,0)) 
cleaned_data_2 <- cleaned_data %>% select(-c(REM_CD,TRR_ID_CODE))
cleandata <- cleandata %>% select(-FINAL_DIALYSIS_PRIOR_WEEK, -FINAL_CTP_SCORE)
cleandata <- cleandata %>% select(-FINAL_MELD_OR_PELD,-INIT_MELD_OR_PELD)
UNOS_liver_transplant <- cleandata %>% select(-INIT_CTP_SCORE)