

###################################
######## PROJECT OF WTUM ##########
###################################

#########################################################################
################## Student's fullname: Hoang Thien Ly  ##################
################## Student's ID      : 308933          ##################
################## Project no.       : 14              ##################
################## Academic year     : 2022            ##################
#########################################################################


#####################################
####  Loading needed libraries  #####
#####################################
library(haven)    # to load data in SAS form
library(dplyr)    # for data processing
library(readr)
library(autoEDA)  # for autoEDA
# install.packages("devtools")
#devtools::install_github("ModelOriented/forester")
library(forester) # Automatically train models
library(ranger)   # Random Forest
library(xgboost)  # XGboost
library(lightgbm) # LightGBM
library(catboost) # catboost




#####################################
########   Import dataset  ##########
#####################################
setwd("C:/Users/DELL/OneDrive - Politechnika Warszawska/STAR_SAS/STAR_SAS/SAS Dataset 202109/Liver")
df <- read_sas("liver_data.sas7bdat")
# > dim(df)
# [1] 329468 426



#############################################
########   Import decoding table   ##########
#############################################
# Observing decoding table to understand features:
LIVER_FORMATS_FLATFILE <- read.delim("C:/Users/DELL/OneDrive - Politechnika Warszawska/STAR_SAS/STAR_SAS/CODE DICTIONARY - FORMATS 202109/Liver/LIVER_FORMATS_FLATFILE.DAT")
# > View(LIVER_FORMATS_FLATFILE)



##################################################
########   Extract important features   ##########
##################################################
data    <-    df    %>% select("ALBUMIN_TX","ASCITES_TX","BW4","BW6","C1","C2",
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
                               "REM_CD", "TBILI_TX", "TRR_ID_CODE",
                               "AGE_GROUP", "BMI_CALC",
                               "EDUCATION",
                               "GENDER")
# > This data contains also demographic information, about age_group, BMI_calc, Education, Gender
# > EDUCATION:
# 
# LIVER_FORMATS_FLATFILE %>% filter(ABO == "EDLEVEL")
# Null or missing: Not reported
# 1: NONE, 2: GRADE SCHOOL, 3: HIGHSCHOOL OR GED, 4: ATTENDED COLLEGE/TECHNICAL SCHOOL
# 5: ASSOCIATE/BSC, 6: POST_COLLEGE GRAD 996: N/A (<5 years) 998: Unknown, **OTHER**: Unknown
#
# AGE_GROUP: Recipient Age Group: A = Adult, P = PEDs
#
# GENDER: M- Male, F- Female.

data$TRR_ID_CODE[data$TRR_ID_CODE == ""]<- NA # Encrypted Transplant Identifier


# We will take only cases with outcomes: 8 - Died, 13-too sick to transplant, 21- died during 
# transplantation, 23- patient died during living donor Transplant procedure Or still waiting on 
# the list.

data <- data %>% filter(!is.na(TRR_ID_CODE) | REM_CD %in% c(8,13,21,23))




#####################################
#####   Define target column ########
#####################################
data <- data %>% mutate(Transplanted_perform = ifelse(!is.na(TRR_ID_CODE),1,0)) 


#####################################
##  Remove suprefluous features #####
#####################################
data <- data %>% select(-c(REM_CD,TRR_ID_CODE, FINAL_DIALYSIS_PRIOR_WEEK, 
                           FINAL_CTP_SCORE, FINAL_MELD_OR_PELD,
                           INIT_MELD_OR_PELD, INIT_CTP_SCORE))



#####################################
#####   Exploratory   ###############
#####   Data Analysis  ##############
#####################################
library("ggvis")
library("tidyverse")
library("ggplot2")

head(data)   # data contains lots of NAs
class(data)  # class: data.frame
str(data)    # contains only numerical features
summary(data)


## Checking numbers of NAs:
x <- colSums(is.na(data))/nrow(data) # Some columns include over 40% of NAs.
# except Transplanted_perform, all of
# remained features having NAs.
x[x>0.3]

## We remove columns having higher 30% of NAs:
data <- data %>% select(-c("ASCITES_TX",
                           "ENCEPH_TX",
                           "FINAL_SERUM_SODIUM",
                           "INIT_MELD_PELD_LAB_SCORE",
                           "INIT_SERUM_SODIUM",
                           "INR_TX"))

## AutoEDA
#  autoEDA::autoEDA(UNOS_liver, "Transplanted_perform")

# library(DataExplorer)
# DataExplorer::plot_density(UNOS_liver)


##################################################
#####   Train Model   ############################
#####   For data with non-demographic   ##########
#####   Features      ############################
##################################################
df_1 <- data %>% select(-c("AGE_GROUP", "BMI_CALC", "EDUCATION", "GENDER"))



#########################
### Train- Test split ###
#########################

# Spliting data into train & test in ratio 3:2
library(caret)
index <- createDataPartition(df_1$Transplanted_perform, p = 0.6, list = FALSE)
# create train & test set:
X_train1 <- df_1[index, ]
X_test1  <- df_1[-index, ]

# > Checking balance of data:
sum(X_train1$Transplanted_perform == 0)/nrow(X_train1)



##############################
###### Median Imputation #####
##############################

# getting median of each column using apply() 
median_train <- apply(X_train1, 2, median, na.rm=TRUE)
# imputing median value with NA 
for(i in colnames(X_train1))
  X_train1[,i][is.na(X_train1[,i])] <- median_train[i]

# getting median of each column using apply() 
median_test <- apply(X_test1, 2, median, na.rm=TRUE)
# imputing median value with NA 
for(i in colnames(X_test1))
  X_test1[,i][is.na(X_test1[,i])] <- median_test[i]


# > Train model: train: 5000 obs, test: 6000 obs
model1 <- forester(X_train1[sample(nrow(X_train1),5000), ], 
                   target= "Transplanted_perform",
                   data_test = X_test1[sample(nrow(X_test1), 6000), ],
                   typ = "classification", metric= "auc")

modelStudio::modelStudio(model1)



#####################################################################
#####   Train Model           #######################################
#####   For data with demographic: GENDER & BMI_CALC ################
#####   Features      ###############################################
#####################################################################

df_2 <- data
# > Checking balance of data:
df_2 <- df_2 %>% select(-c("AGE_GROUP", "EDUCATION"))
df_2$GENDER <- as.factor(df_2$GENDER)

library(caret)
dummy <- dummyVars(" ~ .", data=df_2)
df_2 <- data.frame(predict(dummy, newdata = df_2)) 
View(df_2)


# Spliting data into train & test in ratio 3:2
index <- createDataPartition(df_2$Transplanted_perform, p = 0.6, list = FALSE)
# create train & test set:
X_train2 <- df_2[index, ]
X_test2  <- df_2[-index, ]


# > Checking balance of data:
sum(X_train2$Transplanted_perform == 0)/nrow(X_train2)



##############################
###### Median Imputation #####
##############################

# getting median of each column using apply() 
median_train <- apply(X_train2, 2, median, na.rm=TRUE)
# imputing median value with NA 
for(i in colnames(X_train2))
  X_train2[,i][is.na(X_train2[,i])] <- median_train[i]

# getting median of each column using apply() 
median_test <- apply(X_test2, 2, median, na.rm=TRUE)
# imputing median value with NA 
for(i in colnames(X_test2))
  X_test2[,i][is.na(X_test2[,i])] <- median_test[i]


# > Train model: train: 5000 obs, test: 6000 obs
model2 <- forester(X_train2[sample(nrow(X_train2),5000), ], 
                   target= "Transplanted_perform",
                   data_test = X_test2[sample(nrow(X_test2), 6000), ],
                   typ = "classification", metric= "auc")

modelStudio::modelStudio(model2)



###########################################
####### Checking fairness of model ########
###########################################
library('fairmodels')

df_3 <- data
# > Checking balance of data:
df_3 <- df_3 %>% select(-c("AGE_GROUP", "EDUCATION"))
df_3$GENDER <- as.factor(df_3$GENDER)

# getting median of each column using apply() 
median_train <- apply(df_3[,! colnames(df_3) %in% c("GENDER")], 2, median, na.rm=TRUE)
# imputing median value with NA 
for(i in colnames(df_3)[! colnames(df_3) %in% c("GENDER")])
  df_3[,i][is.na(df_3[,i])] <- median_train[i]


data_cat <- df_3[sample(nrow(X_train2),5000), ]
View(data_cat)
rf_model <- ranger::ranger(Transplanted_perform ~.,
                           data = data_cat,
                           probability = TRUE,
                           max.depth = 3,
                           num.trees = 300,
                           seed = 1)

explainer_rf <- DALEX::explain(rf_model,
                               data = data_cat[,-ncol(data_cat)],
                               y = as.numeric(data_cat$Transplanted_perform),
                               label = "model with Catboost")

fobject <- fairness_check( explainer_rf,
                           protected = data_cat$GENDER,
                           privileged = "M")


plot(fobject)


# > Model is not fair!!!
