

#####################################
####  Loading needed libraries  #####
#####################################

library(haven) # to load data in SAS form
library(dplyr) # for data processing
library(readr)
library(autoEDA)
#####################################
########   Import dataset  ##########
#####################################
setwd("C:/Users/DELL/OneDrive - Politechnika Warszawska/STAR_SAS/STAR_SAS/SAS Dataset 202109/Liver")
df <- read_sas("liver_data.sas7bdat")

### Viewing dataset:
View(df)

#####################################
#####   Cleaning dataset  ###########
#####################################
liver_data <- df    %>% select("ALBUMIN_TX","ASCITES_TX","BW4","BW6","C1","C2",
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

liver_data$TRR_ID_CODE[liver_data$TRR_ID_CODE == ""]<- NA
sum(is.na(liver_data$TRR_ID_CODE))
dim(liver_data)


### Observing decoding table:
LIVER_FORMATS_FLATFILE <- read.delim("C:/Users/DELL/OneDrive - Politechnika Warszawska/STAR_SAS/STAR_SAS/CODE DICTIONARY - FORMATS 202109/Liver/LIVER_FORMATS_FLATFILE.DAT")
View(LIVER_FORMATS_FLATFILE)



#####################################
#####   Cleaning dataset II #########
#####################################

liver_data2 <- liver_data %>% filter( !is.na(TRR_ID_CODE) | REM_CD %in% c(8,13,21,23))


#####################################
#####   Define target column ########
#####################################
liver_data2 <- liver_data2 %>% mutate(Transplanted_perform = ifelse(!is.na(TRR_ID_CODE),1,0)) 



#####################################
##  Remove suprefluous features #####
#####################################
liver_data2 <- liver_data2 %>% select(-c(REM_CD,TRR_ID_CODE))

UNOS_liver <- liver_data2 %>% select(-FINAL_DIALYSIS_PRIOR_WEEK, 
                                      -FINAL_CTP_SCORE, 
                                      -FINAL_MELD_OR_PELD,
                                      -INIT_MELD_OR_PELD,
                                      -INIT_CTP_SCORE)




#####################################
#####   Exploratory   ###############
#####   Data Analysis  ##############
#####################################
library("ggvis")
library("tidyverse")
library("ggplot2")

head(UNOS_liver)   # data contains lots of NAs
class(UNOS_liver)  # class: data.frame
str(UNOS_liver)    # contains only numerical features
summary(UNOS_liver)


## Checking numbers of NAs:
x <- colSums(is.na(UNOS_liver))/nrow(UNOS_liver) # Some columns include over 40% of NAs.
                                            # except Transplanted_perform, all of
                                            # remained features having NAs.
x[x>0.3]

## We remove columns having higher 30% of NAs:
UNOS_liver <- UNOS_liver %>% select(-c("ASCITES_TX",
                                       "ENCEPH_TX",
                                       "FINAL_SERUM_SODIUM",
                                       "INIT_MELD_PELD_LAB_SCORE",
                                       "INIT_SERUM_SODIUM",
                                       "INR_TX"))
#write.csv(UNOS_liver,"C:/Users/DELL/OneDrive/Desktop/ML_Wd/UNOS_liver.csv" ,row.names = FALSE)

## AutoEDA
#  autoEDA::autoEDA(UNOS_liver, "Transplanted_perform")

# library(DataExplorer)
# DataExplorer::plot_density(UNOS_liver)


