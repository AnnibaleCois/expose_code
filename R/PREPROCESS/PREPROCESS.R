##########################################################################################################################################################################
# EXPOSE - PREPROCESS CORE VARIABLES                                                                                                                                     #
# acois@sun.ac.za, November 2022                                                                                                                                         #
##########################################################################################################################################################################

# CLEAN WORKSPACE

rm(list = ls())

# LOAD LIBRARIES

library(haven)
library(readxl)
library(psych)
library(stringr)
library(survey)
library(srvyr)
library(rrtable)
library(weights)
library(dplyr)
library(globorisk)

##########################################################################################################################################################################
# LOCATION OF FILES AND FOLDERS                                                                                                                                          #
##########################################################################################################################################################################

# OUTPUT DIRECTORY
OUT <- "./2 - PREPROCESS/OUT"

# INPUT DIRECTORY
IN_SA <- "./0 - EXTRACT_SA/OUT"
IN_EN <- "./0 - EXTRACT_EN/OUT"

# TEMP DIRECTORY
TEMP <- "./2 - PREPROCESS/TEMP"

# AUX DATA DIRECTORY
AUX <- "./DATA"

# CONSOLIDATED DATA

CONSOLIDATED_CORE_SA_FILE <- "HARMONISED_SOUTH_AFRICA.dta" # SOUTH AFRICA
CONSOLIDATED_CORE_EN_FILE <- "HSE1998-2017 recode3.dta" # ENGLAND

##########################################################################################################################################################################
# SETTINGS                                                                                                                                                               #
##########################################################################################################################################################################

COUNTRY <- c("South Africa", "England")
MODELS <- c("who_nonlab", "who_lab","globorisk_nonlab","globorisk_lab") 

##########################################################################################################################################################################
# FUNCTIONS                                                                                                                                                              #
##########################################################################################################################################################################

loadRData <- function(fileName) { # loads an RData file, and returns it
  load(fileName)
  get(ls()[ls() != "fileName"])
}

##########################################################################################################################################################################
# LOAD AND PREPROCESS DATA: SA                                                                                                                                           #
##########################################################################################################################################################################

DATA <- droplevels(as_factor(read_dta(paste(IN_SA, "/", CONSOLIDATED_CORE_SA_FILE, sep = ""))))

DATA$country_name <- "South Africa"
DATA$country_ISO <- "ZAF"

DATA <- subset(DATA, age >= 16)
DATA$agecat1 <- cut(DATA$age, breaks = c(0, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 120), right = FALSE,
                   labels = c("16-19", "20-24","25-29","30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79","80+")
)
DATA$agecat2 <- cut(DATA$age, breaks = c(0, 20, 30, 40, 50, 60, 70, 80, 120), right = FALSE,
                    labels = c("16-19", "20-29","30-39", "40-49", "50-59", "60-69", "70-79","80+")
)
DATA$age2 <- DATA$age

DATA$geolevel1_name <- DATA$prov2001_name 
DATA$geolevel1_code <- DATA$prov2001_code
DATA$geolevel2_name <- DATA$dist2001_name
DATA$geolevel2_code <- DATA$dist2001_code

DATA$vism <- DATA$intm
DATA$visq <- factor(DATA$vism)
DATA$visq <- factor(DATA$visq, labels = c("1",  "1",  "1",  "2",  "2",  "2",  "3",  "3",  "3",  "4", "4", "4"))
DATA$visq <- as.numeric(DATA$visq)

DATA$hh_size_cat <- DATA$hh_size
DATA[!is.na(DATA$hh_size_cat) & DATA$hh_size_cat >= 6,]$hh_size_cat <- 6
DATA$hh_size_cat <- factor(DATA$hh_size_cat)
DATA$hh_size_cat <- factor(DATA$hh_size_cat, labels = c("1", "2", "3", "4", "5", "6+"))
DATA$geotype2 = factor(DATA$geotype2, labels = c("Urban","Non-urban"))
DATA$self_health = factor(DATA$self_health, labels = c("Poor/bad","Average/fair","Good","Very good/excellent"))

DATA_SA <- sjlabelled::unlabel(data.frame(DATA)) 
DATA_SA %>% mutate(across(where(is.factor), as.character)) -> DATA_SA

##########################################################################################################################################################################
# LOAD AND PREPROCESS DATA: EN                                                                                                                                           #
##########################################################################################################################################################################

DATA <- read_dta(paste(IN_EN, "/", CONSOLIDATED_CORE_EN_FILE, sep = ""))
DATA <- data.frame(as_factor(DATA))
DATA %>% mutate(across(where(is.factor), as.character)) -> DATA

DATA$country_name <- "England"
DATA$country_ISO <- "GBR"
DATA$source <- paste("HSE", DATA$year, sex = " ")

DATA$sex <- as_factor(DATA$sex)
DATA$agecat1 <- droplevels(as_factor(DATA$Age16g5))
DATA$agecat1 <- factor(DATA$agecat1, labels = c("80+","80+","45-49","60-64","25-29","65-69","75-79","30-34","16-19","80+","40-44","70-74","50-54",
                                                "35-39","20-24","16-19","55-59"))
DATA$agecat1 <- factor(DATA$agecat1, levels = c("16-19","20-24","25-29","30-34","35-39","40-44","45-49","50-54","55-59","60-64","65-69","70-74","75-79","80+"))

DATA$agecat2 <- factor(DATA$agecat1, labels = c("16-19","20-29","20-29","30-39","30-39","40-49","40-49","50-59","50-59","60-69","60-69","70-79","70-79","80+")) 
DATA$agecat1a <- cut(DATA$age2, breaks = c(0, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 120), right = FALSE,
                    labels = c("16-19", "20-24","25-29","30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79","80+")
)
DATA$agecat2a <- cut(DATA$age2, breaks = c(0, 20, 30, 40, 50, 60, 70, 80, 120), right = FALSE, 
                     labels = c("16-19", "20-29","30-39", "40-49", "50-59", "60-69", "70-79","80+")
)
DATA[is.na(DATA$agecat1),]$agecat1 <- DATA[is.na(DATA$agecat1),]$agecat1a
DATA[is.na(DATA$agecat2),]$agecat2 <- DATA[is.na(DATA$agecat2),]$agecat2a

DATA$bpmed <- as_factor(DATA$bpmed)
DATA$currsmok <- as_factor(DATA$currsmok)
DATA$smokstatus <- as_factor(DATA$smokstatus)
DATA$psu <- as.numeric(DATA$psu)
DATA$aweight_rec <- DATA$aweight
DATA$aweight_rec_risk <- DATA$wt_nurse
DATA$weight1 <- DATA$weight
DATA$height1 <- DATA$height
DATA$race_imp <- DATA$race
DATA$geolevel1_code <- as.numeric(as.factor(DATA$geolevel1))
DATA$geolevel1_name <- factor(DATA$geolevel1)
DATA$geolevel1_name <- factor(DATA$geolevel1_name, labels = c("North East", "North West & Merseyside","Yorkshire & The Humberside", "West Midlands","East Midlands",
                                                              "Eastern", "London", "South East","South West"))
DATA$geolevel1_name <- as.character(DATA$geolevel1_name)
DATA$geolevel1_code <- paste("E",DATA$geolevel1_code, sep = "")
DATA[DATA$geolevel1_code == "ENA",]$geolevel1_code <- NA
DATA$edu3 <- DATA$edu_e
DATA[is.na(DATA$visq) & !is.na(DATA$wt_nurse) & !DATA$wt_nurse == 0,]$visq <- DATA[is.na(DATA$visq) &!is.na(DATA$wt_nurse) & !DATA$wt_nurse == 0,]$intq

DATA_EN <- sjlabelled::unlabel(data.frame(DATA))
DATA_EN %>% mutate(across(where(is.factor), as.character)) -> DATA_EN

##########################################################################################################################################################################
# SELECT VARIABLES, APPEND & STANDARDISE VARIABLES TYPE                                                                                                                  #
##########################################################################################################################################################################

COLSA <- c("country_name", "country_ISO",
"source", "year", "hhid", "pid", "psu", "stratum", 
"aweight", "aweight_rec", "aweight_rec_risk",

"geolevel1_name", "geolevel1_code", "geolevel2_name", "geolevel2_code", "geotype2", 

"intm", "inty", "vism", "visq",

"hh_size", "hh_size_cat", "hh_ownhome", "hh_totrooms", "hh_sleeprooms", "hh_ptotrooms", "hh_psleeprooms", "hh_dwellingtype", "hh_wallmaterial", 
"hh_floormaterial", "hh_roofmaterial", "hh_roof_wall_1", "hh_roof_wall_2", "hh_roof_wall_3", "hh_roof_wall_4", "hh_roof_wall_5", "hh_roof_wall_9999", 
"hh_cookingfuel", "hh_heatingfuel", "hh_cook_elec", "hh_cook_gas", "hh_cook_par", "hh_cook_wood", "hh_cook_coal", "hh_cook_dung", 
"hh_cook_other", "hh_water", "hh_toilet", "hh_sharedtoilet", "hh_refuseremoved", "hh_recgrant", "hh_govsupport", "hh_foodinsec", 
"hh_foodinsec_adult", "hh_foodinsec_child", "hh_ass_elec", "hh_ass_radio", "hh_ass_tv", "hh_ass_fridge", "hh_ass_bicycle", "hh_ass_motorcycle", 
"hh_ass_car_truck", "hh_ass_phone", "hh_ass_computer", "hh_ass_wmachine", "hh_ass_cellphone", "hh_ass_watch", "hh_ass_animalcart", "hh_ass_motorboat", 
"hh_ass_vacuum", "hh_ass_microwave", "hh_ass_stove", "hh_ass_sat", "hh_ass_video", "hh_ass_hifi", "hh_ass_camera", "hh_ass_smachine", 
"hh_ass_sofa", "hh_ass_boat", "hh_ass_plough", "hh_ass_tractor", "hh_ass_wheelbarrow", "hh_ass_mill", "hh_ass_tab", "hh_ass_sink", 
"hh_ass_hotw", "hh_ass_dishwasher", "hh_edu_deprived", "hh_unimp_toilet", "hh_unimp_water", "hh_unimp_cooking", "hh_dep1plus", "hh_dep2plus", 
"hh_dep3plus", "hh_dep4plus", "hh_income", "hh_income_quint", "hh_windex", "hh_windex_quint", "hh_cwi", "hh_deaths12mo", 

"sex", 
"age", "age2", "agecat1", "agecat2", 
"race", "race_imp", "marstatus", "edu1", "edu2", "emp", 

"smokstatus", "currsmok", "alcstatus", "curralc", "alcavg", "gpaq", "gpaqcat", "exercisefreq", 
"self_health", 

"diag_hbp", "diag_isch", "diag_stroke", "diag_chol", "diag_diab", "diag_emph", "diag_asth", "diag_tb", "diag_cancer", "diag_heart", 

"bpmed", "diabmed", "cholmed", "ischmed", 
"lungmed", "tbmed", "strokemed", "bpmed_coded", "diabmed_coded", "cholmed_coded", "ischmed_coded", "lungmed_coded", 
"tbmed_coded", "strokemed_coded", "parity", "currpreg", "everpreg", 

"height1", "height2", "height3", 
"height", "weight1", "weight2", "weight3", "weight", "waist1", "waist2", "waist3", 
"waist", "arm1", "arm2", "arm3", "arm", "hip1", "hip2", "hip3","hip", 
"sbp1", "sbp2", "sbp3", "sbp_mean1", "sbp_mean2",
"dbp1", "dbp2", "dbp3", "dbp_mean1", "dbp_mean2", 
"rhr1", "rhr2", "rhr3", "rhr_mean1", "rhr_mean2", 
"bmi", "bmicat", 

"hb", 
"HbA1c", "chol_tot", "chol_hdl", "chol_ldl", "trig", 

"medaid", "hcare12mo", "hcare1mo", 
"hcare1mo_public", "hcare1mo_private", "ohcare1mo", "ohcare1mo_public", "ohcare1mo_private", "hcare1mo_chem_nurse","hcare1mo_trad", "hcare1mo_other", 

"who_nonlab", "who_lab" 
)

COLEN <- c("country_name","country_ISO",
"source", "year", "pid", "psu", "stratum", 
"aweight", "aweight_rec", "aweight_rec_risk",
 
"geolevel1_code", "geolevel1_name",

"geotype2", 
 
"intm", "intq", "vism", "inty", "visq",
 
"hh_size", "hh_size_cat",
"hh_ownhome", "hh_ass_car_truck", "hh_carnum",


"diag_diab2", "diag_hbp2", "diag_hbp", "diag_angi", "diag_mi", "diag_isch", "diag_stroke", "diag_cancer", 
"diag_heart", "diag_lung", "diag_mental", "diag_infectious", "diag_metabolic", "diag_nerve", "diag_blood", 


"sex", 
"age", "age2", "agecat1", "agecat2",
"race_e", "occupation", "emp", "edu3",

 
"height", "weight",
"hip1", "hip2", "hip3", "hip",
"sbp1", "sbp2", "sbp3", "sbp_mean1", "sbp_mean2", 
"dbp1", "dbp2", "dbp3", "dbp_mean1", "dbp_mean2",  

"bmi", "bmicat",
"waist1", "waist2", "waist3", "waist",
"weight1", 
"height1", 

"currsmok", "smokstatus", "self_health",

"bpmed", 

"chol_tot",

"airtemp", 
 
"who_nonlab", "who_lab" 
 
)

DATA_SA <- DATA_SA[, COLSA]
DATA_EN <- DATA_EN[, COLEN]

# MICRODATA

DIFF1 <- colnames(DATA_SA)[!(colnames(DATA_SA) %in% colnames(DATA_EN))]
DIFF2 <- colnames(DATA_EN)[!(colnames(DATA_EN) %in% colnames(DATA_SA))]
DATA_EN[,DIFF1] <- NA
DATA_SA[,DIFF2] <- NA
DATA <- rbind(DATA_SA,DATA_EN)

DATA %>% mutate(across(where(is.character), as.factor)) -> DATA

##########################################################################################################################################################################
# ADD CVD RISK TO MICRODATA                                                                                                                                              #
##########################################################################################################################################################################

DATA$globorisk_nonlab <- NA
DATA$globorisk_lab <- NA
DATA$SEX <- 2 - as.numeric(DATA$sex)
DATA$DIAB <- as.numeric(DATA$diag_diab) - 1
DATA$SMOK <- as.numeric(DATA$currsmok) - 1
DATA$DM <- as.numeric(DATA$diag_diab) - 1

DATA[DATA$age2 >= 40 & DATA$age2 <= 80,]$globorisk_nonlab <- globorisk(sex = DATA[DATA$age2 >= 40 & DATA$age2 <= 80,]$SEX , 
                                                                     age = DATA[DATA$age2 >= 40 & DATA$age2 <= 80,]$age2, 
                                                                     sbp = DATA[DATA$age2 >= 40 & DATA$age2 <= 80,]$sbp_mean2, 
                                                                     tc = DATA[DATA$age2 >= 40 & DATA$age2 <= 80,]$chol_tot, 
                                                                     dm = DATA[DATA$age2 >= 40 & DATA$age2 <= 80,]$DM,
                                                                     bmi = DATA[DATA$age2 >= 40 & DATA$age2 <= 80,]$bmi, 
                                                                     smk = DATA[DATA$age2 >= 40 & DATA$age2 <= 80,]$SMOK, 
                                                                     iso = DATA[DATA$age2 >= 40 & DATA$age2 <= 80,]$country_ISO, 
                                                                     year = 2017, version = "office", type = "risk")*100   

DATA[DATA$age2 >= 40 & DATA$age2 <= 80,]$globorisk_lab <- globorisk(sex = DATA[DATA$age2 >= 40 & DATA$age2 <= 80,]$SEX , 
                                                                  age = DATA[DATA$age2 >= 40 & DATA$age2 <= 80,]$age2, 
                                                                  sbp = DATA[DATA$age2 >= 40 & DATA$age2 <= 80,]$sbp_mean2, 
                                                                  tc = DATA[DATA$age2 >= 40 & DATA$age2 <= 80,]$chol_tot, 
                                                                  dm = DATA[DATA$age2 >= 40 & DATA$age2 <= 80,]$DM,
                                                                  bmi = DATA[DATA$age2 >= 40 & DATA$age2 <= 80,]$bmi, 
                                                                  smk = DATA[DATA$age2 >= 40 & DATA$age2 <= 80,]$SMOK, 
                                                                  iso = DATA[DATA$age2 >= 40 & DATA$age2 <= 80,]$country_ISO, 
                                                                  year = 2017, version = "office", type = "risk")*100   
  
DATA$SEX <- NULL
DATA$DIAB <- NULL
DATA$SMOK <- NULL
DATA$DM <- NULL

##########################################################################################################################################################################
# VARIABLE LABELS                                                                                                                                                        #
##########################################################################################################################################################################

attr(DATA$country_name,"label") <- "Country name"
attr(DATA$year,"label") <- "Year of data collection - Survey median"
attr(DATA$source,"label") <- "Data source"
attr(DATA$aweight_rec_risk,"label") <- "Sampling weight - CVD, recalibrated"
attr(DATA$geolevel1_name,"label") <- "Administrative level 1 - Name"
attr(DATA$geolevel1_code,"label") <- "Administrative level 1 - Code"
attr(DATA$geolevel2_name,"label") <- "Administrative level 2 - Name"
attr(DATA$geolevel2_code,"label") <- "Administrative level 2 - Code"
attr(DATA$geotype2,"label") <- "Urban/rural"
attr(DATA$vism,"label") <- "Anthropometry - Month"
attr(DATA$visq,"label") <- "Anthropometry - Quarter"
attr(DATA$hh_size_cat,"label") <- "Household size, categorical"
attr(DATA$hh_ownhome,"label") <- "Dwelling - Ownership"
attr(DATA$hh_dwellingtype,"label") <- "Dwelling - Type"
attr(DATA$hh_wallmaterial,"label") <- "Dwelling - Wall material"
attr(DATA$hh_floormaterial,"label") <- "Dwelling - Floor material"
attr(DATA$hh_roofmaterial,"label") <- "Dwelling - Wall material"
attr(DATA$hh_roof_wall_1,"label") <- "Dwelling - roof/wall material: mud/thaching/wattle and daub"
attr(DATA$hh_roof_wall_2,"label") <- "Dwelling - roof/wall material: mud and cement mix"
attr(DATA$hh_roof_wall_3,"label") <- "Dwelling - roof/wall material: corrugated iron/zinc"
attr(DATA$hh_roof_wall_4,"label") <- "Dwelling - roof/wall material: plastic/cardboard"
attr(DATA$hh_roof_wall_5,"label") <- "Dwelling - roof/wall material: brick/cement/prefab/plaster"
attr(DATA$hh_roof_wall_9999,"label") <- "Dwelling - roof/wall material: other"
attr(DATA$hh_cookingfuel,"label") <- "Main cooking fuel"
attr(DATA$hh_heatingfuel,"label") <- "Main heating fuel"
attr(DATA$hh_cook_elec,"label") <- "Cooking fuel: Electricity"
attr(DATA$hh_cook_gas,"label") <- "Cooking fuel: Gas"
attr(DATA$hh_cook_par,"label") <- "Cooking fuel: Paraffin"
attr(DATA$hh_cook_wood,"label") <- "Cooking fuel: Wood"
attr(DATA$hh_cook_coal,"label") <- "Cooking fuel: Coal"
attr(DATA$hh_cook_dung,"label") <- "Cooking fuel: Dung"
attr(DATA$hh_cook_other,"label") <- "Cooking fuel: Other"
attr(DATA$hh_water,"label") <- "Source of drinking water"
attr(DATA$hh_toilet,"label") <- "Toilet type"
attr(DATA$hh_sharedtoilet,"label") <- "Shared toilet"
attr(DATA$hh_refuseremoved,"label") <- "Refuse removal"
attr(DATA$hh_recgrant,"label") <- "Household member receives goverment grant"
attr(DATA$hh_govsupport,"label") <- "Household receives goverment support"
attr(DATA$hh_foodinsec,"label") <- "Food insecurity"
attr(DATA$hh_foodinsec_adult,"label") <- "Food insecurity: adult"
attr(DATA$hh_foodinsec_child,"label") <- "Food insecurity: child"
attr(DATA$hh_ass_elec,"label") <- "Household assets: Electricity"
attr(DATA$hh_ass_elec ,"label") <- "Household assets: Electricity"       
attr(DATA$hh_ass_radio ,"label") <- "Household assets: Radio"      
attr(DATA$hh_ass_tv ,"label") <- "Household assets: TV"         
attr(DATA$hh_ass_fridge ,"label") <- "Household assets: Fridge"     
attr(DATA$hh_ass_bicycle ,"label") <- "Household assets: Bicycle"    
attr(DATA$hh_ass_motorcycle ,"label") <- "Household assets: Motorcycle" 
attr(DATA$hh_ass_car_truck ,"label") <- "Household assets: Car/Truck" 
attr(DATA$hh_ass_phone ,"label") <- "Household assets: Phone (landline)"      
attr(DATA$hh_ass_computer ,"label") <- "Household assets: Computer"   
attr(DATA$hh_ass_wmachine ,"label") <- "Household assets: Washing Machine"   
attr(DATA$hh_ass_cellphone ,"label") <- "Household assets: Electricity"  
attr(DATA$hh_ass_watch ,"label") <- "Household assets: Phone (cellular)"      
attr(DATA$hh_ass_animalcart ,"label") <- "Household assets: Animal cart" 
attr(DATA$hh_ass_motorboat ,"label") <- "Household assets: Motorboat"  
attr(DATA$hh_ass_vacuum ,"label") <- "Household assets: Vacuum cleaner"    
attr(DATA$hh_ass_microwave ,"label") <- "Household assets: Microwave oven"  
attr(DATA$hh_ass_stove ,"label") <- "Household assets: Stove"      
attr(DATA$hh_ass_sat ,"label") <- "Household assets: Satellite TV"        
attr(DATA$hh_ass_video ,"label") <- "Household assets: Videoplayer"      
attr(DATA$hh_ass_hifi ,"label") <- "Household assets: hifi"       
attr(DATA$hh_ass_camera ,"label") <- "Household assets: Photocamera"     
attr(DATA$hh_ass_smachine ,"label") <- "Household assets: Sewing machine"   
attr(DATA$hh_ass_sofa ,"label") <- "Household assets: Sofa"      
attr(DATA$hh_ass_boat ,"label") <- "Household assets: Boat"       
attr(DATA$hh_ass_plough ,"label") <- "Household assets: Plough"     
attr(DATA$hh_ass_tractor ,"label") <- "Household assets: Tractor"    
attr(DATA$hh_ass_wheelbarrow ,"label") <- "Household assets: Weelbarrow"
attr(DATA$hh_ass_mill ,"label") <- "Household assets: Mill"       
attr(DATA$hh_ass_tab ,"label") <- "Household assets: Table"        
attr(DATA$hh_ass_sink ,"label") <- "Household assets: Sink"       
attr(DATA$hh_ass_hotw ,"label") <- "Household assets: Hot water"      
attr(DATA$hh_ass_dishwasher ,"label") <- "Household assets: Dishwasher"
attr(DATA$hh_edu_deprived ,"label") <- "Deprivation: education"
attr(DATA$hh_unimp_toilet ,"label") <- "Deprivation: sanitation"
attr(DATA$hh_unimp_cooking ,"label") <- "Deprivation: cooking fuel"
attr(DATA$hh_unimp_water ,"label") <- "Deprivation: water"
attr(DATA$hh_dep1plus ,"label") <- "Deprivation: 1+ indicator"
attr(DATA$hh_dep2plus ,"label") <- "Deprivation: 2+ indicators"
attr(DATA$hh_dep3plus ,"label") <- "Deprivation: 3+ indicators"
attr(DATA$hh_dep4plus ,"label") <- "Deprivation: 4+ indicators"
attr(DATA$hh_income_quint ,"label") <- "Household income quintile"
attr(DATA$hh_windex_quint ,"label") <- "Household wealth index quintile"
attr(DATA$hh_deaths12mo ,"label") <- "Death in teh household last 12 months"
attr(DATA$sex ,"label") <- "Sex"
attr(DATA$age2 ,"label") <- "Age, imputed [years]"
attr(DATA$agecat1 ,"label") <- "Age category (5 years)"
attr(DATA$agecat2 ,"label") <- "Age category (10 years)"
attr(DATA$race ,"label") <- "Population group"
attr(DATA$race_imp ,"label") <- "Population group, imputed"
attr(DATA$race_e ,"label") <- "Ethnicity"
attr(DATA$marstatus ,"label") <- "Marital status"
attr(DATA$edu1 ,"label") <- "Education: categorisation 1"
attr(DATA$edu2 ,"label") <- "Education: categorisation 2"
attr(DATA$edu3 ,"label") <- "Education: categorisation 3"
attr(DATA$emp ,"label") <- "Employment"
attr(DATA$smokstatus ,"label") <- "Smoking status"
attr(DATA$currsmok ,"label") <- "Current smoker"
attr(DATA$alcstatus ,"label") <- "Alcohol status"
attr(DATA$curralc ,"label") <- "Current drinker"
attr(DATA$gpaqcat ,"label") <- "GPAQ category"
attr(DATA$exercisefreq ,"label") <- "Exercise frequency"
attr(DATA$self_health ,"label") <- "Self-rated health"
attr(DATA$diag_hbp,"label") <- "Diagnosis: Hypertension"      
attr(DATA$diag_isch,"label") <- "Diagnosis: Heart attack/angina"      
attr(DATA$diag_stroke,"label") <- "Diagnosis: Stroke"    
attr(DATA$diag_chol,"label") <- "Diagnosis: Hypercholesterolaemia"      
attr(DATA$diag_diab,"label") <- "Diagnosis: Diabetes/hyperglicaemia"      
attr(DATA$diag_emph,"label") <- "Diagnosis: Emphisema/Chrinic bronchitis"      
attr(DATA$diag_asth,"label") <- "Diagnosis: Asthma"      
attr(DATA$diag_tb,"label") <- "Diagnosis: Tuberculosis"       
attr(DATA$diag_cancer,"label") <- "Diagnosis: Cancer"    
attr(DATA$diag_heart,"label") <- "Diagnosis: Heart problems"     
attr(DATA$bpmed,"label") <- "Medication: Hypertension"            
attr(DATA$diabmed,"label") <- "Medication: Diabetes/hyperglicaemia"            
attr(DATA$cholmed,"label") <- "Medication: Hypercholesterolaemia"            
attr(DATA$ischmed,"label") <- "Medication: Heart attack/angina"            
attr(DATA$lungmed,"label") <- "Medication: Respiratory problems"            
attr(DATA$tbmed,"label") <- "Medication: Tuberculosis"              
attr(DATA$strokemed,"label") <- "Medication: Stroke"         
attr(DATA$bpmed_coded,"label") <- "Medication: Hypertension, coded"        
attr(DATA$diabmed_coded,"label") <- "Medication: Diabetes/hyperglicaemia, coded"    
attr(DATA$cholmed_coded,"label") <- "Medication: Hypercholesterolaemia, coded"   
attr(DATA$ischmed_coded,"label") <- "Medication: Heart attack/angina, coded"    
attr(DATA$lungmed_coded,"label") <- "Medication: Respiratory problems, coded"    
attr(DATA$tbmed_coded,"label") <- "Medication: Tuberculosis, coded"     
attr(DATA$strokemed_coded,"label") <- "Medication: Stroke, coded"  
attr(DATA$currpreg ,"label") <- "Currently pregnant"
attr(DATA$everpreg ,"label") <- "Ever pregnant"
attr(DATA$bmicat ,"label") <- "BMI category"
attr(DATA$sbp_mean1 ,"label") <- "Systolic Blood Pressure [mmHg] - Average of available readings"
attr(DATA$sbp_mean2 ,"label") <- "Diastolic Blood Pressure [mmHg] - Average of available readings"
attr(DATA$dbp_mean1 ,"label") <- "Systolic Blood Pressure [mmHg] - Average of available readings"
attr(DATA$dbp_mean2 ,"label") <- "Diastolic Blood Pressure [mmHg] - Average of available readings excluding the first"
attr(DATA$medaid ,"label") <- "Covered by medical insurance"
attr(DATA$hcare12mo,"label") <- "Health consultation last 12 months"           
attr(DATA$hcare1mo,"label") <- "Healthcare consultations last month"              
attr(DATA$hcare1mo_public,"label") <- "Healthcare last month: public hospital/clinic"       
attr(DATA$hcare1mo_private,"label") <- "Healthcare last month: private hospital/clinic/doctor"     
attr(DATA$ohcare1mo,"label") <- "Outpatient consultations last month"             
attr(DATA$ohcare1mo_public,"label") <- "Outpatient healthcare last month: public hospital/clinic"      
attr(DATA$ohcare1mo_private,"label") <- "Outpatient healthcare last month: private hospital/clinic/doctor"     
attr(DATA$hcare1mo_chem_nurse,"label") <- "Healthcare last month: chemist/pharmacist/nurse"  
attr(DATA$hcare1mo_trad,"label") <- "Healthcare last month: traditional/faith healer"        
attr(DATA$hcare1mo_other,"label") <- "Healthcare last month: other"   
attr(DATA$hh_carnum ,"label") <- "Number of cars available"
attr(DATA$airtemp ,"label") <- "Air temperature during blood pressure measurment"
attr(DATA$globorisk_nonlab ,"label") <- "Globorisk cvd risk score: non laboratory"
attr(DATA$globorisk_lab ,"label") <- "Globorisk cvd risk score: laboratory"
attr(DATA$country_ISO ,"label") <- "Country ISO code"
attr(DATA$occupation ,"label") <- "Social class/occupation"
attr(DATA$diag_diab2 ,"label") <- "Diagnosis: diabetes, excluding pregnancy"      
attr(DATA$diag_hbp2 ,"label") <- "Diagnosis: hypertension, excluding pregnancy"           
attr(DATA$diag_angi ,"label") <- "Diagnosis: angina"           
attr(DATA$diag_mi ,"label") <- "Diagnosis: heart attack (myocardial infarction)"             
attr(DATA$diag_lung ,"label") <- "Diagnosis: Respiratory condition"          
attr(DATA$diag_mental ,"label") <- "Diagnosis: Mental disorder"         
attr(DATA$diag_infectious ,"label") <- "Diagnosis: Infectious disorder"    
attr(DATA$diag_metabolic ,"label") <- "Diagnosis: Endocrine/metabolic disorder"      
attr(DATA$diag_nerve ,"label") <- "Diagnosis: Nervous system disorder"          
attr(DATA$diag_blood ,"label") <- "Diagnosis: Blood disorder"    

##########################################################################################################################################################################
# ORDER                                                                                                                                                                  #
##########################################################################################################################################################################

ORD <- c(

"country_ISO", "country_name", "source", "year", "hhid", "pid", "psu", "stratum", 
"aweight", "aweight_rec", "aweight_rec_risk", 
"geolevel1_name", "geolevel1_code", "geolevel2_name", "geolevel2_code", "geotype2", 

"intm", "inty", "vism", "visq", 

"hh_size", "hh_size_cat",
"hh_ownhome", "hh_totrooms", "hh_sleeprooms", "hh_ptotrooms", "hh_psleeprooms", 
"hh_dwellingtype", "hh_wallmaterial", "hh_floormaterial", "hh_roofmaterial", "hh_roof_wall_1", "hh_roof_wall_2", "hh_roof_wall_3", 
"hh_roof_wall_4", "hh_roof_wall_5", "hh_roof_wall_9999", 

"hh_water", "hh_toilet", "hh_sharedtoilet", "hh_refuseremoved", 

"hh_cookingfuel", "hh_heatingfuel", "hh_cook_elec", "hh_cook_gas", "hh_cook_par", "hh_cook_wood", "hh_cook_coal", "hh_cook_dung", 
"hh_cook_other", 

"hh_recgrant", "hh_govsupport", "hh_foodinsec", "hh_foodinsec_adult", "hh_foodinsec_child", 

"hh_ass_elec", "hh_ass_radio", "hh_ass_tv", 
"hh_ass_fridge", "hh_ass_bicycle", "hh_ass_motorcycle", "hh_ass_car_truck", "hh_ass_phone", "hh_ass_computer", "hh_ass_wmachine", "hh_ass_cellphone", 
"hh_ass_watch", "hh_ass_animalcart", "hh_ass_motorboat", "hh_ass_vacuum", "hh_ass_microwave", "hh_ass_stove", "hh_ass_sat", "hh_ass_video", 
"hh_ass_hifi", "hh_ass_camera", "hh_ass_smachine", "hh_ass_sofa", "hh_ass_boat", "hh_ass_plough", "hh_ass_tractor", "hh_ass_wheelbarrow",
"hh_ass_mill", "hh_ass_tab", "hh_ass_sink", "hh_ass_hotw", "hh_ass_dishwasher", "hh_carnum",

"hh_edu_deprived", "hh_unimp_toilet", "hh_unimp_water", "hh_unimp_cooking", "hh_dep1plus", "hh_dep2plus", "hh_dep3plus", "hh_dep4plus", 
"hh_income", "hh_income_quint", "hh_windex", "hh_windex_quint", "hh_cwi", "hh_deaths12mo", 

"sex", "age", "age2", "agecat1", "agecat2", 
"race", "race_imp", "race_e","marstatus", "edu1", "edu2", "edu3", "emp", "occupation",

"smokstatus", "currsmok", 
"alcstatus", "curralc", "alcavg", 
"gpaq", "gpaqcat", "exercisefreq", 

"self_health", 

"diag_hbp", "diag_isch", "diag_stroke", "diag_chol", "diag_diab", "diag_emph", "diag_asth", "diag_tb", 
"diag_cancer", "diag_heart", "diag_diab2", "diag_hbp2", "diag_angi", "diag_mi", "diag_lung", "diag_mental", "diag_infectious", 
"diag_metabolic", "diag_nerve", "diag_blood",

"bpmed", "diabmed", "cholmed", "ischmed", "lungmed", "tbmed", 
"strokemed", "bpmed_coded", "diabmed_coded", "cholmed_coded", "ischmed_coded", "lungmed_coded", "tbmed_coded", "strokemed_coded", 

"parity", "currpreg", "everpreg",

"airtemp",
"height1", "height2", "height3", "height", 
"weight1", "weight2", "weight3", "weight", 
"waist1", "waist2", "waist3", "waist", 
"arm1", "arm2", "arm3", "arm", 
"hip1", "hip2", "hip3", "hip", 
"sbp1", "sbp2", "sbp3", "sbp_mean1", "sbp_mean2", 
"dbp1", "dbp2", "dbp3", "dbp_mean1", "dbp_mean2",
"rhr1", "rhr2", "rhr3", "rhr_mean1", "rhr_mean2",
"bmi", "bmicat", 

"hb", "HbA1c", "chol_tot", "chol_hdl", "chol_ldl", "trig", 

"medaid", 
"hcare12mo", "hcare1mo", "hcare1mo_public", "hcare1mo_private", "ohcare1mo", "ohcare1mo_public", "ohcare1mo_private", "hcare1mo_chem_nurse",
"hcare1mo_trad", "hcare1mo_other", 

"who_nonlab", "who_lab", "globorisk_nonlab", "globorisk_lab" 
 
)

MDATA <- DATA[,ORD]

MDATA$aweight <- as.numeric(as.character(MDATA$aweight))
MDATA$aweight_rec <- as.numeric(as.character(MDATA$aweight_rec))
MDATA$aweight_rec_risk <- as.numeric(as.character(MDATA$aweight_rec_risk))
MDATA$vism <- as.numeric(as.character(MDATA$vism))
MDATA$age <- as.numeric(as.character(MDATA$age))
MDATA$airtemp <- as.numeric(as.character(MDATA$airtemp))
MDATA$height1 <- as.numeric(as.character(MDATA$height1))
MDATA$height2 <- as.numeric(as.character(MDATA$height2))
MDATA$height3 <- as.numeric(as.character(MDATA$height3))
MDATA$height <- as.numeric(as.character(MDATA$height))
MDATA$weight1 <- as.numeric(as.character(MDATA$weight1))
MDATA$weight2 <- as.numeric(as.character(MDATA$weight2))    
MDATA$weight3 <- as.numeric(as.character(MDATA$weight3))
MDATA$weight <- as.numeric(as.character(MDATA$weight))
MDATA$waist1 <- as.numeric(as.character(MDATA$waist1))
MDATA$waist2 <- as.numeric(as.character(MDATA$waist2))
MDATA$waist3 <- as.numeric(as.character(MDATA$waist3))
MDATA$waist <- as.numeric(as.character(MDATA$waist))              
MDATA$arm1 <- as.numeric(as.character(MDATA$arm1))
MDATA$arm2 <- as.numeric(as.character(MDATA$arm2))
MDATA$arm3 <- as.numeric(as.character(MDATA$arm3)) 
MDATA$arm <- as.numeric(as.character(MDATA$arm))
MDATA$hip1 <- as.numeric(as.character(MDATA$hip1))
MDATA$hip2 <- as.numeric(as.character(MDATA$hip2))
MDATA$hip3 <- as.numeric(as.character(MDATA$hip3))              
MDATA$hip <- as.numeric(as.character(MDATA$hip))
MDATA$sbp1 <- as.numeric(as.character(MDATA$sbp1))
MDATA$sbp2 <- as.numeric(as.character(MDATA$sbp2))
MDATA$sbp3 <- as.numeric(as.character(MDATA$sbp3))
MDATA$sbp_mean1 <- as.numeric(as.character(MDATA$sbp_mean1))
MDATA$sbp_mean2 <- as.numeric(as.character(MDATA$sbp_mean2))
MDATA$dbp1 <- as.numeric(as.character(MDATA$dbp1))
MDATA$dbp2 <- as.numeric(as.character(MDATA$dbp2))
MDATA$dbp3 <- as.numeric(as.character(MDATA$dbp3))
MDATA$dbp_mean1 <- as.numeric(as.character(MDATA$dbp_mean1))
MDATA$dbp_mean2 <- as.numeric(as.character(MDATA$dbp_mean2))
MDATA$rhr1 <- as.numeric(as.character(MDATA$rhr1))
MDATA$rhr2 <- as.numeric(as.character(MDATA$rhr2)) 
MDATA$rhr3 <- as.numeric(as.character(MDATA$rhr3))
MDATA$rhr_mean1 <- as.numeric(as.character(MDATA$rhr_mean1)) 
MDATA$rhr_mean2 <- as.numeric(as.character(MDATA$rhr_mean2)) 
MDATA$bmi <- as.numeric(as.character(MDATA$bmi))
MDATA$hb <- as.numeric(as.character(MDATA$hb))
MDATA$HbA1c <- as.numeric(as.character(MDATA$HbA1c))
MDATA$chol_tot <- as.numeric(as.character(MDATA$chol_tot))
MDATA$chol_hdl <- as.numeric(as.character(MDATA$chol_hdl))
MDATA$chol_ldl <- as.numeric(as.character(MDATA$chol_ldl))
MDATA$trig <- as.numeric(as.character(MDATA$trig))            
MDATA$who_nonlab <- as.numeric(as.character(MDATA$who_nonlab))
MDATA$who_lab <- as.numeric(as.character(MDATA$who_lab))
MDATA$globorisk_nonlab <- as.numeric(as.character(MDATA$globorisk_nonlab))
MDATA$globorisk_lab <- as.numeric(as.character(MDATA$globorisk_lab))

##########################################################################################################################################################################
# SAVE                                                                                                                                                                   #
##########################################################################################################################################################################

save(MDATA, file = paste(OUT,"/MICRODATA.RData", sep = ""))
foreign::write.dta(MDATA, file = paste(OUT,"/MICRODATA.dta", sep = ""))
write.csv(MDATA, file = paste(OUT,"/MICRODATA.csv", sep = ""), col.names = TRUE)
