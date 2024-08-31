##########################################################################################################################################################################
# EXPOSE                                                                                                                                                      #
# FINALISE EXPOSE DATASETS                                                                                                                                   #  
#                                                                                                                                                                        #
# 20240901, annibale.cois@mrc.ac.za                                                                                                                                              #
##########################################################################################################################################################################

# CLEAN WORKSPACE

rm(list = ls())

# LOAD LIBRARIES

library(haven)
library(readxl)

library(stringr)
library(plyr)
library(dplyr)

library(survey)
library(ReGenesees)

library(RStata)
library(globorisk)
library(CVrisk)

library(codebookr)

##########################################################################################################################################################################
# LOCATION OF FILES AND FOLDERS                                                                                                                                          #
##########################################################################################################################################################################

# INPUT DIRECTORY
IN_SA <- "EXTRACT_SA/OUT/"
IN_EN <- "EXTRACT_EN/OUT/"

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

DATA <- data.frame(droplevels(as_factor(read_dta(paste(IN_SA, CONSOLIDATED_SA_FILE, sep = "")))))
DATA$country_name <- "South Africa"
DATA$country_ISO <- "ZAF"

DATA$geolevel1_name <- DATA$prov2001_name 
DATA$geolevel1_code <- DATA$prov2001_code
DATA$geolevel2_name <- DATA$dist2001_name
DATA$geolevel2_code <- DATA$dist2001_code

DATA$intm <- factor(DATA$intm, levels = c("1","2","3","4","5","6","7","8","9","10","11","12"), 
                    labels = c("January","February","March","April","May","June","July","August","September","October","November","December"))
DATA$vism <- DATA$intm
DATA$visq <- factor(DATA$vism, levels = c("January","February","March","April","May","June","July","August","September","October","November","December"), 
                               labels = c("I","I","I","II","II","II","III","III","III","IV","IV","IV"))
DATA$hh_size_cat <- DATA$hh_size
DATA[!is.na(DATA$hh_size_cat) & DATA$hh_size_cat >= 6,]$hh_size_cat <- 6
DATA$hh_size_cat <- factor(DATA$hh_size_cat)
DATA$hh_size_cat <- factor(DATA$hh_size_cat, labels = c("1", "2", "3", "4", "5", "6+"))
DATA$geotype2 = factor(DATA$geotype2, labels = c("Urban","Non-urban"))
DATA$self_health = factor(DATA$self_health, labels = c("Poor/bad","Average/fair","Good","Very good/excellent"))
DATA$aweight_lab1 <- DATA$aweight_lab
DATA$aweight_lab <- NULL

DATA_SA <- sjlabelled::unlabel(data.frame(DATA)) 
DATA_SA %>% mutate(across(where(is.factor), as.character)) -> DATA_SA

# SELECT 

COLSA <- c("country_name", "country_ISO",
           "source", "year", "hhid", "pid", "psu", "stratum", 
           "aweight", "aweight_phys", "aweight_lab1",
           
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
           "age", "agecat1", "agecat2", 
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
           "hcare1mo_public", "hcare1mo_private", "ohcare1mo", "ohcare1mo_public", "ohcare1mo_private", "hcare1mo_chem_nurse","hcare1mo_trad", "hcare1mo_other"
)

DATA_SA <- DATA_SA[, COLSA]

##########################################################################################################################################################################
# LOAD AND PREPROCESS DATA: EN                                                                                                                                           #
##########################################################################################################################################################################

DATA <- data.frame(droplevels(as_factor(read_dta(paste(IN_EN, CONSOLIDATED_EN_FILE, sep = "")))))
DATA$country_name <- "England"
DATA$country_ISO <- "GBR"
DATA$source <- paste("HSE", DATA$year, sex = " ")

DATA$intm <- factor(DATA$intm, levels = c("1","2","3","4","5","6","7","8","9","10","11","12"), 
                    labels = c("January","February","March","April","May","June","July","August","September","October","November","December"))
DATA$vism <- factor(DATA$vism, levels = c("1","2","3","4","5","6","7","8","9","10","11","12"), 
                    labels = c("January","February","March","April","May","June","July","August","September","October","November","December"))
DATA$visq <- factor(DATA$visq, levels = c("First quarter of year","Second quarter of year","Third quarter of year","Fourth quarter of year"), 
                    labels = c("I","II","III","IV"))
DATA$sex <- as_factor(DATA$sex)
DATA$bpmed <- as_factor(DATA$bpmed)
DATA$currsmok <- as_factor(DATA$currsmok)
DATA$smokstatus <- as_factor(DATA$smokstatus)
DATA$weight1 <- DATA$weight
DATA$height1 <- DATA$height
DATA$race_imp <- DATA$race
DATA$geolevel1_code <- as.numeric(as.factor(DATA$geolevel1))
DATA$geolevel1_name <- factor(DATA$geolevel1)
DATA$geolevel1_name <- factor(DATA$geolevel1_name, labels = c("North East", "North West & Merseyside","Yorkshire & The Humberside", "West Midlands","East Midlands",
                                                              "Eastern", "London", "South East","South West"))
DATA$geolevel1_name <- as.character(DATA$geolevel1_name)
DATA$geolevel1_code <- paste("E",DATA$geolevel1_code, sep = "")
DATA$edu3 <- DATA$edu_e
DATA[is.na(DATA$visq) & !is.na(DATA$wt_nurse) & !DATA$wt_nurse == 0,]$visq <- DATA[is.na(DATA$visq) & !is.na(DATA$wt_nurse) & !DATA$wt_nurse == 0,]$intq

DATA$aweight_int <- as.numeric(as.character(DATA$aweight_int))  
DATA$aweight_nonlab <- as.numeric(as.character(DATA$aweight_nonlab))          
DATA$aweight_lab <- as.numeric(as.character(DATA$aweight_lab))             

DATA_EN <- sjlabelled::unlabel(data.frame(DATA))
DATA_EN %>% mutate(across(where(is.factor), as.character)) -> DATA_EN

COLEN <- c("country_name","country_ISO",
           "source", "year", "pid", "psu", "stratum", 
           "aweight_int_cvd","aweight_nonlab_cvd","aweight_lab_cvd","aweight_int","aweight_nonlab","aweight_lab", 
           
           "geolevel1_code", "geolevel1_name",
           
           "geotype2", 
           
           "intm", "intq", "vism", "inty", "visq",
           
           "hh_size", "hh_size_cat",
           "hh_ownhome", "hh_ass_car_truck", "hh_carnum",
           "hh_income", "hh_income_eq", "hh_income_quint","hh_recgrant", 
           
           "diag_diab", "diag_diab2", "diag_hbp2", "diag_hbp", "diag_angi", "diag_mi", "diag_isch", "diag_stroke", "diag_cancer", 
           "diag_heart", "diag_lung", "diag_mental", "diag_infectious", "diag_metabolic", "diag_nerve", "diag_blood", 
           
           "sex", 
           "age", "agecat1", "agecat2",
           "race_e", "occupation", "emp", "edu3","marstatus",
           
           "bpmed","bpmed_coded","diabmed","cholmed","contraceptives",
           
           "currpreg",
           
           "height", "weight",
           "hip1", "hip2", "hip3", "hip",
           "sbp1", "sbp2", "sbp3", "sbp_mean1", "sbp_mean2", 
           "dbp1", "dbp2", "dbp3", "dbp_mean1", "dbp_mean2",  
           "rhr1", "rhr2", "rhr3", "rhr_mean1", "rhr_mean2",
           "airtemp",           
           
           "bmi", "bmicat",
           "waist1", "waist2", "waist3", "waist",
           "weight1", 
           "height1", 
           
           "alcstatus","curralc","alcmax",
           "currsmok", "smokstatus", "self_health",
           "fruitveg",
           
           "chol_tot","chol_hdl"
)

DATA_EN <- DATA_EN[, COLEN]

##########################################################################################################################################################################
# LOAD AND PREPROCESS DATA: AUXILIARY                                                                                                                                    #
##########################################################################################################################################################################

# MODELLED POPULATION DATA (WIDER)
POPSA_13 <- loadRData("POPDATA/POPSA_13.RData") 

# URBAN/RURAL PROPORTION (WORLDBANK)
URSA <- loadRData("POPDATA/URSA.RData") 

##########################################################################################################################################################################
# (1) CONSOLIDATE: CREATE CONSOLIDATED FACTOR LEVELS                                                                                                                     #
##########################################################################################################################################################################

DATA <- rbind.fill(DATA_SA, DATA_EN)
DATA %>% mutate(across(where(is.character), as.factor)) -> DATA  # ALL CHARCTERS TO FACTORS
DATA$stratum <- factor(DATA$stratum)   # stratum as FACTOR (required by e.calibrate )

##########################################################################################################################################################################
# (2) ADD RISK SCORES (GLOBORISK, WHO/ISH, FHS)                                                                                                                          #
##########################################################################################################################################################################

DATA$ID <- c(1: nrow(DATA))

# GLOBORISK: 
#
# VALIDITY AGE RANGE: 40-75 
# PREDICTORS: (LAB) age, sex, smoking, blood pressure, diabetes, and total cholesterol; (NONLAB) age, sex, smoking, blood pressure, bmi
# OUTPUTS: (1) 10 years fatal CVD risk (deaths from IHD, sudden cardiac death or stroke (International Classification of Diseases [ICD] 10 codes I20–I25 and I60–I69));
#          (2) 10 years fatal and non-fatal CVD risk (deaths from IHD, sudden cardiac death or stroke (ICD-10 codes I20–I25 and I60–I69) and nonfatal myocardial 
#              infarction (ICD-10 codes I21–I22) and stroke (ICD-10 codes I60–I69)).
# REF: Ueda P et al. Laboratory-Based and Office-Based Risk Scores and Charts to Predict 10-Year Risk of Cardiovascular Disease in 182 Countries: A Pooled Analysis of 
#      Prospective Cohorts and Health Surveys. The Lancet Diabetes & Endocrinology 5, no. 3 (March 1, 2017): 196–213. 
#
# NOTES:
# GLOBORISK CONSIDERS THE FOLLOWING CUTOFFS FOR IMPLAUSIBLE VALUES OF BMI, SBP AND TOTAL CHOLESTEROL: 
# BMI: 10, 80 [Kg/m2] ; SBP: 70, 270 [mmHg] ; TOTAL CHOLESTEROL: 1.75, 20 [mmol/L]
# THERE WERE 17 RECORDS WITH SBP OUTSIDE LIMITS, 7 WITH BMI OUTSIDE LIMITS AND 1 WITH TOTAL CHOLESTEROL OUTSIDE LIMITS. THOISE RECORDS HAVE BEEN KEPT IN THE DATASET. 

D <- subset(DATA, agecat1 %in% c("40-44","45-49","50-54","55-59","60-64","65-69","70-74"))
D$SEX <- 2 - as.numeric(D$sex)
D$SMOK <- as.numeric(D$currsmok) - 1
D$SBP <- D$sbp_mean2
D$BMI <- D$bmi
D$AGE <- D$age
D$DM <- as.numeric(D$diag_diab) - 1
D[D$country_ISO == "GBR",]$DM <- as.numeric(D[D$country_ISO == "GBR",]$diag_diab2) - 1
D$TC <- D$chol_tot
D$BASELINE <- D$year
D[D$year < 2000,]$BASELINE <- 2000
D$ISO <- as.character(D$country_ISO)

D$globorisk_nonlab <- globorisk(sex = D$SEX, age = D$AGE, sbp = D$SBP, bmi = D$BMI, smk = D$SMOK, iso = D$ISO, year = D$BASELINE, version = "office") * 100
D$globorisk_lab <- globorisk(sex = D$SEX, age = D$AGE, sbp = D$SBP, tc = D$TC, dm = D$DM, smk = D$SMOK, iso = D$ISO, year = D$BASELINE, version = "lab") * 100
D$globorisk_lab_fatal <- globorisk(sex = D$SEX, age = D$AGE, sbp = D$SBP, tc = D$TC, dm = D$DM, smk = D$SMOK, iso = D$ISO, year = D$BASELINE, version = "fatal") * 100

D_GLOBORISK <- data.frame(D[,c("ID","globorisk_nonlab","globorisk_lab","globorisk_lab_fatal")])

# WHO/ISH (WORLD HEALTH ORGANIZATION/INTERNATIONAL SOCIETY OF HYPERTENSION): 
#
# VALIDITY AGE RANGE: 40-80 
# PREDICTORS: (LAB) age, sex, smoking, blood pressure, diabetes, and total cholesterol; (NONLAB) age, sex, smoking, blood pressure, bmi
# OUTPUTS: (1) 10 years fatal CVD risk (deaths from myocardial infarction or stroke. See reference for details.) 
#          (2) 10 years fatal and non-fatal CVD risk  (fatal or non-fatal myocardial infarction or stroke.See regerence for details.)         
# REF: Kaptoge S at Al. World Health Organization Cardiovascular Disease Risk Charts: Revised Models to Estimate Risk in 21 Global Regions. 
#      The Lancet Global Health 7, no. 10 (2019): e1332–45.

D <- subset(DATA, agecat1 %in% c("40-44","45-49","50-54","55-59","60-64","65-69","70-74","75-79"))[, 
                               c("ID", "country_ISO","year", "sex", "age", "diag_diab", "diag_diab2", "currsmok", "chol_tot", "bmi", "sbp_mean2")]
D$ccode <- as.character(D$country_ISO)
D$hxdiabbin <- as.numeric(D$diag_diab) - 1
D[D$country_ISO == "GBR",]$hxdiabbin <- as.numeric(D[D$country_ISO == "GBR",]$diag_diab2) - 1
D$smallbin <- as.numeric(D$currsmok) - 1
D$sex <- 3 - as.numeric(D$sex)
D$tchol <- D$chol_tot
D$sbp <- D$sbp_mean2
D$ages <- D$age

D <- stata("whocvdrisk", data.in = D, data.out = TRUE, stata.path = "\"C:\\Program Files (x86)\\Stata13\\StataMP-64\"", stata.version = 13, stata.echo = TRUE)
D$who_lab <- D$cal2_who_cvdx_m1*100
D$who_nonlab <- D$cal2_who_cvdx_m2*100

D_WHO <- data.frame(D[,c("ID","who_nonlab","who_lab")])

# FHS (FRAMINGHAM HEART STUDY): 
#
# VALIDITY AGE RANGE: 30-74 
# PREDICTORS: (LAB) age, race, sex, smoking, blood pressure, diabetes, total cholesterol, hdl cholesterol, blood pressure medication; 
#             (NONLAB) age, sex, smoking, blood pressure, bmi, diabetes, blood pressure medication.
# OUTPUTS: (1) 10 years fatal CVD risk (defined as first occurrence of non-fatal myocardial infarction (MI), congestive heart disease (CHD) death, or fatal or nonfatal stroke) 
# REF: D’Agostino R et Al. General Cardiovascular Risk Profile for Use in Primary Care. Circulation 117(6);2008:743–53. 

D <- subset(DATA, agecat1 %in% c("30-34","35-39","40-44","45-49","50-54","55-59","60-64","65-69","70-74"))[, 
                               c("ID", "year", "sex", "age", "diag_diab", "diag_diab2", "currsmok", "bmi", "sbp_mean2","bpmed")]

D$DIAB <- as.numeric(D$diag_diab) - 1
D[D$country_ISO == "GBR",]$DIAB <- as.numeric(D[D$country_ISO == "GBR",]$diag_diab2) - 1 
D$SMOKER <- as.numeric(D$currsmok) - 1
D$BP_MED <- as.numeric(D$bpmed) - 1

D$fhs_nonlab <- ascvd_10y_frs_simple(gender = D$sex, age = D$age, bmi = D$bmi, sbp = D$sbp_mean2, bp_med = D$BP_MED, smoker = D$SMOKER, diabetes = D$DIAB)

D_FHS <- data.frame(D[,c("ID","fhs_nonlab")])

# MERGE

DATA <- merge(DATA,D_GLOBORISK, all.x = TRUE, all.y = FALSE)
DATA <- merge(DATA,D_WHO, all.x = TRUE, all.y = FALSE)
DATA <- merge(DATA,D_FHS, all.x = TRUE, all.y = FALSE)
DATA$ID <- NULL

# SPLIT      

DATA_SA <- subset(DATA, country_ISO == "ZAF")
DATA_EN <- subset(DATA, country_ISO == "GBR")

##########################################################################################################################################################################
# (3A) REWEIGHTING SA DATA                                                                                                                                               #
# FINAL WEIGHT:                                                                                                                                                          #
#                                                                                                                                                                        #
# AWEIGHT_INT_BASE: ORIGINAL INTERVIEW WEIGHTS                                                                                                                           #
# AWEIGHT_PHYS_BASE: ORIGINAL PHYSICAL EXAMINATION WEIGHTS                                                                                                               #
# AWEIGHT_LAB_BASE: ORIGINAL LABORATORY WEIGHTS                                                                                                                          #
#                                                                                                                                                                        #
# AWEIGHT_INT: INTERVIEW WEIGHTS, RECALIBRATED, RESCALED TO SAMPLE SIZE                                                                                                  #
# AWEIGHT_PHYS: PHYSICAL EXAMINATION WEIGHTS, RECALIBRATED, RESCALED TO SAMPLE SIZE                                                                                      #
# AWEIGHT_LAB: LABORATORY WEIGHTS, RECALIBRATED, RESCALED TO SAMPLE SIZE                                                                                                 #
#                                                                                                                                                                        #
# AWEIGHT_NONLABSCORE: WEIGHTS FOR NON-LABORATORY RISK SCORES, RECALIBRATED, RESCALED TO SAMPLE SIZE                                                                     #
# AWEIGHT_LABSCORE: WEIGHTS FOR LABORATORY RISK SCORES, RECALIBRATED, RESCALED TO SAMPLE SIZE                                                                            #
#                                                                                                                                                                        #
##########################################################################################################################################################################

# CREATE AUXILIARY VARIABLES

DATA_SA$ID <- c(1:nrow(DATA_SA))

DATA_SA$a <- cut(DATA_SA$age, breaks = c(15,20,25,30,35,40,45,50,55,60,65,70,75,120), right = FALSE)
DATA_SA$r <- factor(DATA_SA$race_imp, levels = c("Black African","Asian","Coloured","White"), labels = c("African","Asian","Coloured","White"))
DATA_SA$s <- DATA_SA$sex
DATA_SA$g <- DATA_SA$geolevel1_code
DATA_SA$a1 <- cut(DATA_SA$age, breaks = c(15,35,55,60,65,70,75,120), right = FALSE)

YEAR <- aggregate(DATA_SA$year, by = list(source = DATA_SA$source), FUN = mean) %>% rename (year = x)
POPSA <- POPSA_13

if (FALSE) {

# ANALYSE ORIGINAL WEIGHTS: aweight  

SDATA1 <- e.svydesign(DATA_SA , ids = ~psu, strata = ~stratum, weights = ~aweight, fpc = NULL, self.rep.str = NULL, check.data = FALSE)
MARGINALS <- pop.template(SDATA1, calmodel = ~ s:r:a + s:g - 1, partition = ~source)
for (p in unique(MARGINALS$source)) {
  # PROVINCE MARGINALS 
  XM <- subset(POPSA, popgroup == "National" & geolevel1_code != "National" & sex == "Male" & year == YEAR[YEAR$source == p,]$year)
  YM <- aggregate(XM$POPSA, by = list(XM$geolevel1_code), FUN = sum)
  YM <- YM[order(YM$Group.1),]$x
  XF <- subset(POPSA, popgroup == "National" & geolevel1_code != "National" & sex == "Female" & year == YEAR[YEAR$source == p,]$year)
  YF <- aggregate(XF$POPSA, by = list(XF$geolevel1_code), FUN = sum)
  YF <- YF[order(YF$Group.1),]$x
  MARGINALS[MARGINALS$source == p,c(2,4,6,8,10,12,14,16,18)] <- YF
  MARGINALS[MARGINALS$source == p,(c(2,4,6,8,10,12,14,16,18)+1)] <- YM
  # CROSSCLASS MARGINALS
  X <- subset(POPSA, popgroup != "National" & geolevel1_code == "National" & year == YEAR[YEAR$source == p,]$year)
  Y <- X[order(X$agecat, X$popgroup, X$sex),]$POPSA
  MARGINALS[MARGINALS$source == p,c(20:123)] <- Y
}

#population.check(MARGINALS,SDATA1, ~ s:r:a + g - 1, partition = ~y)
#pop.desc(MARGINALS)
#bounds.hint(SDATA1, MARGINALS)

pop.plot(MARGINALS, SDATA1, xlab = "Original Estimates (aweight)", ylab = "Calibration Control Totals", lcol = c("red", "green", "blue"), lwd = c(1, 1, 1), lty = c(2, 1, 2),verbose = TRUE)

# ANALYSE ORIGINAL WEIGHTS: aweight_phys  

SDATA1 <- e.svydesign(subset(DATA_SA, !is.na(aweight_phys)) , ids = ~psu, strata = ~stratum, weights = ~aweight_phys, fpc = NULL, self.rep.str = NULL, check.data = FALSE)
MARGINALS <- pop.template(SDATA1, calmodel = ~ s:r:a + s:g - 1, partition = ~source)
for (p in unique(MARGINALS$source)) {
  # PROVINCE MARGINALS 
  XM <- subset(POPSA, popgroup == "National" & geolevel1_code != "National" & sex == "Male" & year == YEAR[YEAR$source == p,]$year)
  YM <- aggregate(XM$POPSA, by = list(XM$geolevel1_code), FUN = sum)
  YM <- YM[order(YM$Group.1),]$x
  XF <- subset(POPSA, popgroup == "National" & geolevel1_code != "National" & sex == "Female" & year == YEAR[YEAR$source == p,]$year)
  YF <- aggregate(XF$POPSA, by = list(XF$geolevel1_code), FUN = sum)
  YF <- YF[order(YF$Group.1),]$x
  MARGINALS[MARGINALS$source == p,c(2,4,6,8,10,12,14,16,18)] <- YF
  MARGINALS[MARGINALS$source == p,(c(2,4,6,8,10,12,14,16,18)+1)] <- YM
  # CROSSCLASS MARGINALS
  X <- subset(POPSA, popgroup != "National" & geolevel1_code == "National" & year == YEAR[YEAR$source == p,]$year)
  Y <- X[order(X$agecat, X$popgroup, X$sex),]$POPSA
  MARGINALS[MARGINALS$source == p,c(20:123)] <- Y
}

#population.check(MARGINALS,SDATA1, ~ s:r:a + g - 1, partition = ~y)
#pop.desc(MARGINALS)
#bounds.hint(SDATA1, MARGINALS)

pop.plot(MARGINALS, SDATA1, xlab = "Original Estimates (aweight_phys)", ylab = "Calibration Control Totals", lcol = c("red", "green", "blue"), lwd = c(1, 1, 1), lty = c(2, 1, 2),verbose = TRUE)

# ANALYSE ORIGINAL WEIGHTS: aweight_lab1  

SDATA1 <- e.svydesign(subset(DATA_SA, !is.na(aweight_lab1)) , ids = ~psu, strata = ~stratum, weights = ~aweight_lab1, fpc = NULL, self.rep.str = NULL, check.data = FALSE)
MARGINALS <- pop.template(SDATA1, calmodel = ~ s:r:a + s:g - 1, partition = ~source)
for (p in unique(MARGINALS$source)) {
  # PROVINCE MARGINALS 
  XM <- subset(POPSA, popgroup == "National" & geolevel1_code != "National" & sex == "Male" & year == YEAR[YEAR$source == p,]$year)
  YM <- aggregate(XM$POPSA, by = list(XM$geolevel1_code), FUN = sum)
  YM <- YM[order(YM$Group.1),]$x
  XF <- subset(POPSA, popgroup == "National" & geolevel1_code != "National" & sex == "Female" & year == YEAR[YEAR$source == p,]$year)
  YF <- aggregate(XF$POPSA, by = list(XF$geolevel1_code), FUN = sum)
  YF <- YF[order(YF$Group.1),]$x
  MARGINALS[MARGINALS$source == p,c(2,4,6,8,10,12,14,16,18)] <- YF
  MARGINALS[MARGINALS$source == p,(c(2,4,6,8,10,12,14,16,18)+1)] <- YM
  # CROSSCLASS MARGINALS
  X <- subset(POPSA, popgroup != "National" & geolevel1_code == "National" & year == YEAR[YEAR$source == p,]$year)
  Y <- X[order(X$agecat, X$popgroup, X$sex),]$POPSA
  MARGINALS[MARGINALS$source == p,c(20:123)] <- Y
}

#population.check(MARGINALS,SDATA1, ~ s:r:a + g - 1, partition = ~y)
#pop.desc(MARGINALS)
#bounds.hint(SDATA1, MARGINALS)

pop.plot(MARGINALS, SDATA1, xlab = "Original Estimates (aweight_lab)", ylab = "Calibration Control Totals", lcol = c("red", "green", "blue"), lwd = c(1, 1, 1), lty = c(2, 1, 2),verbose = TRUE)

}

# CALIBRATION 1 (INTERVIEW WEIGHTS)

{        # EXCLUDE SAGE 

DATA_SA1_1 <- subset(DATA_SA, source != "SAGE 2007-8" & source != "SAGE 2014")
DATA_SA1_1$w <- DATA_SA1_1$aweight

SDATA1 <- e.svydesign(droplevels(DATA_SA1_1), ids = ~psu, strata = ~stratum, weights = ~w, fpc = NULL, self.rep.str = NULL, check.data = FALSE)
MARGINALS <- pop.template(SDATA1, calmodel = ~ s:r:a + s:g - 1, partition = ~source)
for (p in unique(MARGINALS$source)) {
  # PROVINCE MARGINALS 
  XM <- subset(POPSA, popgroup == "National" & geolevel1_code != "National" & sex == "Male" & year == YEAR[YEAR$source == p,]$year)
  YM <- aggregate(XM$POPSA, by = list(XM$geolevel1_code), FUN = sum)
  YM <- YM[order(YM$Group.1),]$x
  XF <- subset(POPSA, popgroup == "National" & geolevel1_code != "National" & sex == "Female" & year == YEAR[YEAR$source == p,]$year)
  YF <- aggregate(XF$POPSA, by = list(XF$geolevel1_code), FUN = sum)
  YF <- YF[order(YF$Group.1),]$x
  MARGINALS[MARGINALS$source == p,c(2,4,6,8,10,12,14,16,18)] <- YF
  MARGINALS[MARGINALS$source == p,(c(2,4,6,8,10,12,14,16,18)+1)] <- YM
  # CROSSCLASS MARGINALS
  X <- subset(POPSA, popgroup != "National" & geolevel1_code == "National" & year == YEAR[YEAR$source == p,]$year)
  Y <- X[order(X$agecat, X$popgroup, X$sex),]$POPSA
  MARGINALS[MARGINALS$source == p,c(20:123)] <- Y
}

CDATA1 <- e.calibrate(design = SDATA1, df.population = MARGINALS, calfun = "linear", aggregate.stage = NULL, sigma2 = NULL, maxit = 100, epsilon = 1e-07, force = TRUE)
pop.plot(MARGINALS, CDATA1, xlab = "Current Estimates (aweight)", ylab = "Calibration Control Totals", lcol = c("red", "green", "blue"), lwd = c(1, 1, 1), lty = c(2, 1, 2), verbose = TRUE)
check.cal(CDATA1)
g.range(CDATA1)
}

DATA_SA1_1$aweight_rec <- weights(CDATA1)

{    # SAGE 

DATA_SA2_1 <- subset(DATA_SA, source %in% c("SAGE 2007-8", "SAGE 2014"))
DATA_SA2_1$w <- DATA_SA2_1$aweight

SDATA2 <- e.svydesign(droplevels(DATA_SA2_1), ids = ~psu, strata = ~stratum, weights = ~w, fpc = NULL, self.rep.str = NULL, check.data = FALSE)
MARGINALS <- pop.template(SDATA2, calmodel = ~ s:r:a1 + g:s - 1, partition = ~source)
POPSA2 <- POPSA
POPSA2$agecat <- factor(POPSA2$agecat, levels = c("15-19","20-24","25-29","30-34","35-39","40-44","45-49","50-54","55-59","60-64","65-69","70-74","75+"), 
                                       labels = c("15-34","15-34","15-34","15-34","35-54","35-54","35-54","35-54","55-59","60-64","65-69","70-74","75+"))
POPSA2 <- aggregate(POPSA2$POPSA, by = list(agecat = POPSA2$agecat, year = POPSA2$year, popgroup = POPSA2$popgroup, sex = POPSA2$sex, geolevel1_code = POPSA2$geolevel1_code), FUN = sum)
for (p in unique(MARGINALS$source)) {
  # PROVINCE MARGINALS 
  XM <- subset(POPSA2, popgroup == "National" & geolevel1_code != "National" & sex == "Male" & year == YEAR[YEAR$source == p,]$year)
  YM <- aggregate(XM$x, by = list(XM$geolevel1_code), FUN = sum)
  YM <- YM[order(YM$Group.1),]$x
  XF <- subset(POPSA2, popgroup == "National" & geolevel1_code != "National" & sex == "Female" & year == YEAR[YEAR$source == p,]$year)
  YF <- aggregate(XF$x, by = list(XF$geolevel1_code), FUN = sum)
  YF <- YF[order(YF$Group.1),]$x
  MARGINALS[MARGINALS$source == p,c(2,4,6,8,10,12,14,16,18)] <- YF
  MARGINALS[MARGINALS$source == p,(c(2,4,6,8,10,12,14,16,18)+1)] <- YM
  # CROSSCLASS MARGINALS
  X <- subset(POPSA2, popgroup != "National" & geolevel1_code == "National" & year == YEAR[YEAR$source == p,]$year)
  Y <- X[order(X$agecat, X$popgroup, X$sex),]$x
  MARGINALS[MARGINALS$source == p,c(20:75)] <- Y
}

CDATA2 <- e.calibrate(design = SDATA2, df.population = MARGINALS, calfun = "linear", aggregate.stage = NULL, sigma2 = NULL, maxit = 100, epsilon = 1e-07, force = TRUE)
pop.plot(MARGINALS, CDATA2, xlab = "Current Estimates (aweight)", ylab = "Calibration Control Totals", lcol = c("red", "green", "blue"),lwd = c(1, 1, 1),lty = c(2, 1, 2), verbose = TRUE)
check.cal(CDATA2)
g.range(CDATA2)
}

DATA_SA2_1$aweight_rec <- weights(CDATA2)

# CALIBRATION 2 (PHYSICAL EXAMINATION WEIGHTS)

{        # EXCLUDE SAGE 
  
  DATA_SA1_2 <- subset(DATA_SA, !is.na(aweight_phys) & source != "SAGE 2007-8" & source != "SAGE 2014")
  DATA_SA1_2$w <- DATA_SA1_2$aweight_phys
  
  SDATA1 <- e.svydesign(droplevels(DATA_SA1_2), ids = ~psu, strata = ~stratum, weights = ~w, fpc = NULL, self.rep.str = NULL, check.data = FALSE)
  MARGINALS <- pop.template(SDATA1, calmodel = ~ s:r:a + s:g - 1, partition = ~source)
  for (p in unique(MARGINALS$source)) {
    # PROVINCE MARGINALS 
    XM <- subset(POPSA, popgroup == "National" & geolevel1_code != "National" & sex == "Male" & year == YEAR[YEAR$source == p,]$year)
    YM <- aggregate(XM$POPSA, by = list(XM$geolevel1_code), FUN = sum)
    YM <- YM[order(YM$Group.1),]$x
    XF <- subset(POPSA, popgroup == "National" & geolevel1_code != "National" & sex == "Female" & year == YEAR[YEAR$source == p,]$year)
    YF <- aggregate(XF$POPSA, by = list(XF$geolevel1_code), FUN = sum)
    YF <- YF[order(YF$Group.1),]$x
    MARGINALS[MARGINALS$source == p,c(2,4,6,8,10,12,14,16,18)] <- YF
    MARGINALS[MARGINALS$source == p,(c(2,4,6,8,10,12,14,16,18)+1)] <- YM
    # CROSSCLASS MARGINALS
    X <- subset(POPSA, popgroup != "National" & geolevel1_code == "National" & year == YEAR[YEAR$source == p,]$year)
    Y <- X[order(X$agecat, X$popgroup, X$sex),]$POPSA
    MARGINALS[MARGINALS$source == p,c(20:123)] <- Y
  }
  
  CDATA1 <- e.calibrate(design = SDATA1, df.population = MARGINALS, calfun = "linear", aggregate.stage = NULL, sigma2 = NULL, maxit = 100, epsilon = 1e-07, force = TRUE)
  pop.plot(MARGINALS, CDATA1, xlab = "Current Estimates (aweight_phys)", ylab = "Calibration Control Totals", lcol = c("red", "green", "blue"), lwd = c(1, 1, 1), lty = c(2, 1, 2), verbose = TRUE)
  check.cal(CDATA1)
  g.range(CDATA1)
}

DATA_SA1_2$aweight_phys_rec <- weights(CDATA1)

{    # SAGE 
  
  DATA_SA2_2 <- subset(DATA_SA, !is.na(aweight_phys) & source %in% c("SAGE 2007-8", "SAGE 2014"))
  DATA_SA2_2$w <- DATA_SA2_2$aweight_phys
  
  SDATA2 <- e.svydesign(droplevels(DATA_SA2_2), ids = ~psu, strata = ~stratum, weights = ~w, fpc = NULL, self.rep.str = NULL, check.data = FALSE)
  MARGINALS <- pop.template(SDATA2, calmodel = ~ s:r:a1 + g:s - 1, partition = ~source)
  POPSA2 <- POPSA
  POPSA2$agecat <- factor(POPSA2$agecat, levels = c("15-19","20-24","25-29","30-34","35-39","40-44","45-49","50-54","55-59","60-64","65-69","70-74","75+"), 
                          labels = c("15-34","15-34","15-34","15-34","35-54","35-54","35-54","35-54","55-59","60-64","65-69","70-74","75+"))
  POPSA2 <- aggregate(POPSA2$POPSA, by = list(agecat = POPSA2$agecat, year = POPSA2$year, popgroup = POPSA2$popgroup, sex = POPSA2$sex, geolevel1_code = POPSA2$geolevel1_code), FUN = sum)
  for (p in unique(MARGINALS$source)) {
    # PROVINCE MARGINALS 
    XM <- subset(POPSA2, popgroup == "National" & geolevel1_code != "National" & sex == "Male" & year == YEAR[YEAR$source == p,]$year)
    YM <- aggregate(XM$x, by = list(XM$geolevel1_code), FUN = sum)
    YM <- YM[order(YM$Group.1),]$x
    XF <- subset(POPSA2, popgroup == "National" & geolevel1_code != "National" & sex == "Female" & year == YEAR[YEAR$source == p,]$year)
    YF <- aggregate(XF$x, by = list(XF$geolevel1_code), FUN = sum)
    YF <- YF[order(YF$Group.1),]$x
    MARGINALS[MARGINALS$source == p,c(2,4,6,8,10,12,14,16,18)] <- YF
    MARGINALS[MARGINALS$source == p,(c(2,4,6,8,10,12,14,16,18)+1)] <- YM
    # CROSSCLASS MARGINALS
    X <- subset(POPSA2, popgroup != "National" & geolevel1_code == "National" & year == YEAR[YEAR$source == p,]$year)
    Y <- X[order(X$agecat, X$popgroup, X$sex),]$x
    MARGINALS[MARGINALS$source == p,c(20:75)] <- Y
  }
  
  CDATA2 <- e.calibrate(design = SDATA2, df.population = MARGINALS, calfun = "linear", aggregate.stage = NULL, sigma2 = NULL, maxit = 100, epsilon = 1e-07, force = TRUE)
  pop.plot(MARGINALS, CDATA2, xlab = "Current Estimates (aweight_phys)", ylab = "Calibration Control Totals", lcol = c("red", "green", "blue"),lwd = c(1, 1, 1),lty = c(2, 1, 2), verbose = TRUE)
  check.cal(CDATA2)
  g.range(CDATA2)
}

DATA_SA2_2$aweight_phys_rec <- weights(CDATA2)

# CALIBRATION 3 (LABORATORY WEIGHTS)

{        # EXCLUDE SAGE 
  
  DATA_SA1_3 <- subset(DATA_SA, !is.na(aweight_lab1) & source != "SAGE 2007-8" & source != "SAGE 2014")
  DATA_SA1_3$w <- DATA_SA1_3$aweight_lab1
  
  SDATA1 <- e.svydesign(droplevels(DATA_SA1_3), ids = ~psu, strata = ~stratum, weights = ~w, fpc = NULL, self.rep.str = NULL, check.data = FALSE)
  MARGINALS <- pop.template(SDATA1, calmodel = ~ s:r:a + s:g - 1, partition = ~source)
  for (p in unique(MARGINALS$source)) {
    # PROVINCE MARGINALS 
    XM <- subset(POPSA, popgroup == "National" & geolevel1_code != "National" & sex == "Male" & year == YEAR[YEAR$source == p,]$year)
    YM <- aggregate(XM$POPSA, by = list(XM$geolevel1_code), FUN = sum)
    YM <- YM[order(YM$Group.1),]$x
    XF <- subset(POPSA, popgroup == "National" & geolevel1_code != "National" & sex == "Female" & year == YEAR[YEAR$source == p,]$year)
    YF <- aggregate(XF$POPSA, by = list(XF$geolevel1_code), FUN = sum)
    YF <- YF[order(YF$Group.1),]$x
    MARGINALS[MARGINALS$source == p,c(2,4,6,8,10,12,14,16,18)] <- YF
    MARGINALS[MARGINALS$source == p,(c(2,4,6,8,10,12,14,16,18)+1)] <- YM
    # CROSSCLASS MARGINALS
    X <- subset(POPSA, popgroup != "National" & geolevel1_code == "National" & year == YEAR[YEAR$source == p,]$year)
    Y <- X[order(X$agecat, X$popgroup, X$sex),]$POPSA
    MARGINALS[MARGINALS$source == p,c(20:123)] <- Y
  }
  
  CDATA1 <- e.calibrate(design = SDATA1, df.population = MARGINALS, calfun = "linear", aggregate.stage = NULL, sigma2 = NULL, maxit = 100, epsilon = 1e-07, force = TRUE)
  pop.plot(MARGINALS, CDATA1, xlab = "Current Estimates (aweight_lab)", ylab = "Calibration Control Totals", lcol = c("red", "green", "blue"), lwd = c(1, 1, 1), lty = c(2, 1, 2), verbose = TRUE)
  check.cal(CDATA1)
  g.range(CDATA1)
}

DATA_SA1_3$aweight_lab1_rec <- weights(CDATA1)

{    # SAGE 
  
  DATA_SA2_3 <- subset(DATA_SA, !is.na(aweight_lab1) & source %in% c("SAGE 2007-8", "SAGE 2014"))
  DATA_SA2_3$w <- DATA_SA2_3$aweight_lab1
  
  SDATA2 <- e.svydesign(droplevels(DATA_SA2_3), ids = ~psu, strata = ~stratum, weights = ~w, fpc = NULL, self.rep.str = NULL, check.data = FALSE)
  MARGINALS <- pop.template(SDATA2, calmodel = ~ s:r:a1 + g:s - 1, partition = ~source)
  POPSA2 <- POPSA
  POPSA2$agecat <- factor(POPSA2$agecat, levels = c("15-19","20-24","25-29","30-34","35-39","40-44","45-49","50-54","55-59","60-64","65-69","70-74","75+"), 
                          labels = c("15-34","15-34","15-34","15-34","35-54","35-54","35-54","35-54","55-59","60-64","65-69","70-74","75+"))
  POPSA2 <- aggregate(POPSA2$POPSA, by = list(agecat = POPSA2$agecat, year = POPSA2$year, popgroup = POPSA2$popgroup, sex = POPSA2$sex, geolevel1_code = POPSA2$geolevel1_code), FUN = sum)
  for (p in unique(MARGINALS$source)) {
    # PROVINCE MARGINALS 
    XM <- subset(POPSA2, popgroup == "National" & geolevel1_code != "National" & sex == "Male" & year == YEAR[YEAR$source == p,]$year)
    YM <- aggregate(XM$x, by = list(XM$geolevel1_code), FUN = sum)
    YM <- YM[order(YM$Group.1),]$x
    XF <- subset(POPSA2, popgroup == "National" & geolevel1_code != "National" & sex == "Female" & year == YEAR[YEAR$source == p,]$year)
    YF <- aggregate(XF$x, by = list(XF$geolevel1_code), FUN = sum)
    YF <- YF[order(YF$Group.1),]$x
    MARGINALS[MARGINALS$source == p,c(2,4,6,8,10,12,14,16,18)] <- YF
    MARGINALS[MARGINALS$source == p,(c(2,4,6,8,10,12,14,16,18)+1)] <- YM
    # CROSSCLASS MARGINALS
    X <- subset(POPSA2, popgroup != "National" & geolevel1_code == "National" & year == YEAR[YEAR$source == p,]$year)
    Y <- X[order(X$agecat, X$popgroup, X$sex),]$x
    MARGINALS[MARGINALS$source == p,c(20:75)] <- Y
  }
  
  CDATA2 <- e.calibrate(design = SDATA2, df.population = MARGINALS, calfun = "linear", aggregate.stage = NULL, sigma2 = NULL, maxit = 100, epsilon = 1e-07, force = TRUE)
  pop.plot(MARGINALS, CDATA2, xlab = "Current Estimates (aweight_lab)", ylab = "Calibration Control Totals", lcol = c("red", "green", "blue"),lwd = c(1, 1, 1),lty = c(2, 1, 2), verbose = TRUE)
  check.cal(CDATA2)
  g.range(CDATA2)
}

DATA_SA2_3$aweight_lab1_rec <- weights(CDATA2)

# COMBINE

D1 <- rbind(DATA_SA1_1, DATA_SA2_1)
D2 <- rbind(DATA_SA1_2, DATA_SA2_2)[c("ID","aweight_phys_rec")]
D3 <- rbind(DATA_SA1_3, DATA_SA2_3)[c("ID","aweight_lab1_rec")]

DATA_SA <- merge(D1, D2, all.x = TRUE)
DATA_SA <- merge(DATA_SA, D3, all.x = TRUE)

# DELETE AUXILIARY VARIABLES 

DATA_SA[,c("a","r","s","g","a1","w","ID")] <- NULL

# RESCALE ORIGINAL AND RECALIBRATED WEIGHTS TO SUM TO THE SAMPLE SIZE IN EACH SOURCE 

for (s in unique(DATA_SA$source)) {
  D <- subset(DATA_SA, source == s) 
  D1 <- table(!is.na(D$aweight))["TRUE"]
  D2 <- table(!is.na(D$aweight_rec))["TRUE"]  
  D3 <- table(!is.na(D$aweight_phys))["TRUE"]
  D4 <- table(!is.na(D$aweight_phys_rec))["TRUE"]
  D5 <- table(!is.na(D$aweight_lab1))["TRUE"] 
  D6 <- table(!is.na(D$aweight_lab1_rec))["TRUE"] 

  DATA_SA[DATA_SA$source == s,]$aweight <- DATA_SA[DATA_SA$source == s,]$aweight/sum(DATA_SA[DATA_SA$source == s,]$aweight, na.rm = TRUE)*D1
  DATA_SA[DATA_SA$source == s,]$aweight_rec <- DATA_SA[DATA_SA$source == s,]$aweight_rec/sum(DATA_SA[DATA_SA$source == s,]$aweight_rec, na.rm = TRUE)*D2
  
  DATA_SA[DATA_SA$source == s,]$aweight_phys <- DATA_SA[DATA_SA$source == s,]$aweight_phys/sum(DATA_SA[DATA_SA$source == s,]$aweight_phys, na.rm = TRUE)*D3
  DATA_SA[DATA_SA$source == s,]$aweight_phys_rec <- DATA_SA[DATA_SA$source == s,]$aweight_phys_rec/sum(DATA_SA[DATA_SA$source == s,]$aweight_phys_rec, na.rm = TRUE)*D4
  
  DATA_SA[DATA_SA$source == s,]$aweight_lab1 <- DATA_SA[DATA_SA$source == s,]$aweight_lab1/sum(DATA_SA[DATA_SA$source == s,]$aweight_lab1, na.rm = TRUE)*D5
  DATA_SA[DATA_SA$source == s,]$aweight_lab1_rec <- DATA_SA[DATA_SA$source == s,]$aweight_lab1_rec/sum(DATA_SA[DATA_SA$source == s,]$aweight_lab1_rec, na.rm = TRUE)*D6
  
}

##########################################################################################################################################################################
# (3B) RESCALE EN WEIGHTS TO SUM TO SAMPLE SIZE                                                                                                                          #
##########################################################################################################################################################################

for (s in unique(DATA_EN$source)) {
  D <- subset(DATA_EN, source == s)
  D1 <- table(!is.na(D$aweight_int_cvd))["TRUE"]
  D2 <- table(!is.na(D$aweight_nonlab_cvd))["TRUE"]
  D3 <- table(!is.na(D$aweight_lab_cvd))["TRUE"]
  D4 <- table(!is.na(D$aweight_int))["TRUE"]
  D5 <- table(!is.na(D$aweight_nonlab))["TRUE"]
  D6 <- table(!is.na(D$aweight_lab))["TRUE"]
  
  DATA_EN[DATA_EN$source == s,]$aweight_int_cvd <- D$aweight_int_cvd/sum(D$aweight_int_cvd, na.rm = TRUE)*D1
  DATA_EN[DATA_EN$source == s,]$aweight_nonlab_cvd <- D$aweight_nonlab_cvd/sum(D$aweight_nonlab_cvd, na.rm = TRUE)*D2
  DATA_EN[DATA_EN$source == s,]$aweight_lab_cvd <- D$aweight_lab_cvd/sum(D$aweight_lab_cvd, na.rm = TRUE)*D3
  DATA_EN[DATA_EN$source == s,]$aweight_int <- D$aweight_int/sum(D$aweight_int, na.rm = TRUE)*D4
  DATA_EN[DATA_EN$source == s,]$aweight_nonlab <- D$aweight_nonlab/sum(D$aweight_nonlab, na.rm = TRUE)*D5
  DATA_EN[DATA_EN$source == s,]$aweight_int_cvd <- D$aweight_lab/sum(D$aweight_lab, na.rm = TRUE)*D6
}

##########################################################################################################################################################################
# (4) RENAME SAMPLING WEIGHTS VARIABLES                                                                                                                                  #
##########################################################################################################################################################################

DATA <- rbind.fill(DATA_SA, DATA_EN)

DATA$aweight_sa_int_base <- DATA$aweight
DATA$aweight_sa_phys_base <- DATA$aweight_phys
DATA$aweight_sa_lab_base <- DATA$aweight_lab1
DATA$aweight_sa_int <- DATA$aweight_rec
DATA$aweight_sa_phys <- DATA$aweight_phys_rec
DATA$aweight_sa_lab <- DATA$aweight_lab1_rec

DATA$aweight_en_int <- DATA$aweight_int  
DATA$aweight_en_int_cvd <- DATA$aweight_int_cvd 
DATA$aweight_en_nonlab <- DATA$aweight_nonlab 
DATA$aweight_en_nonlab_cvd <- DATA$aweight_nonlab_cvd 
DATA$aweight_en_lab <- DATA$aweight_lab 
DATA$aweight_en_lab_cvd <- DATA$aweight_lab_cvd 

DATA[, c("aweight","aweight_phys","aweight_lab1","aweight_rec","aweight_phys_rec","aweight_lab1_rec",
         "aweight_int","aweight_int_cvd","aweight_nonlab","aweight_nonlab_cvd","aweight_lab","aweight_lab_cvd")] <- NULL

##########################################################################################################################################################################
# (5A) FINALISE SA                                                                                                                                                       #
##########################################################################################################################################################################

# SPLIT & SUBSET (KEEP ONLY NON_EMPTY COLUMNS IN EACH DATASET)    

DATA_SA <- subset(DATA, country_ISO == "ZAF")
UCOLSA <- c(NULL)   # NON-EMPTY COLUMNS IN SA DATASETS
for (i in c(1:ncol(DATA_SA))) {
  if (sum(as.numeric(DATA_SA[,i]), na.rm = TRUE) > 0) {
    UCOLSA <- c(UCOLSA, colnames(DATA_SA)[i])
  }
}
DATA_SA <- DATA_SA[, UCOLSA]
ORDSA <- c(
    "country_ISO", "country_name", "source", "year", "hhid", "pid", "psu", "stratum", 
    "aweight_sa_int_base", "aweight_sa_phys_base", "aweight_sa_lab_base", "aweight_sa_int", "aweight_sa_phys","aweight_sa_lab", 
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
    "hh_ass_mill", "hh_ass_tab", "hh_ass_sink", "hh_ass_hotw", "hh_ass_dishwasher", 
    "hh_edu_deprived", "hh_unimp_toilet", "hh_unimp_water", "hh_unimp_cooking", "hh_dep1plus", "hh_dep2plus", "hh_dep3plus", "hh_dep4plus", 
    "hh_income", "hh_income_quint", "hh_windex", "hh_windex_quint", "hh_cwi", "hh_deaths12mo", 
    "sex", "age", "agecat1", "agecat2", 
    "race", "race_imp", "marstatus", "edu1", "edu2", "emp", 
    "smokstatus", "currsmok", 
    "alcstatus", "curralc", "alcavg", 
    "gpaq", "gpaqcat", "exercisefreq", 
    "self_health", 
    "diag_hbp", "diag_isch", "diag_stroke", "diag_chol", "diag_diab", "diag_emph", "diag_asth", "diag_tb", 
    "diag_cancer", "diag_heart", 
    "bpmed", "diabmed", "cholmed", "ischmed", "lungmed", "tbmed", "strokemed", 
    "bpmed_coded", "diabmed_coded", "cholmed_coded", "ischmed_coded", "lungmed_coded", "tbmed_coded", "strokemed_coded", 
    "parity", "currpreg", "everpreg",
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
    "globorisk_nonlab","globorisk_lab","globorisk_lab_fatal","who_nonlab","who_lab", "fhs_nonlab"    
  )

DATA_SA <- DATA_SA[,ORDSA]

# AD-HOC CORRECTIONS
    # Set to NA laboratory measurments when the laboratory sampling weight is NA (only affects SANHNANES data)
DATA_SA[is.na(DATA_SA$aweight_sa_lab),c("hb","HbA1c","chol_tot","chol_hdl","chol_ldl","trig")] <- NA

   # Set to NA anthropometric measurements when the physical examination sampling weight is NA (only affects SANHNANES data)
DATA_SA[is.na(DATA_SA$aweight_sa_phys),c("height1", "height2", "height3", "height", 
                                         "weight1", "weight2", "weight3", "weight", 
                                         "waist1", "waist2", "waist3", "waist", 
                                         "arm1", "arm2", "arm3", "arm", 
                                         "hip1", "hip2", "hip3", "hip", 
                                         "sbp1", "sbp2", "sbp3", "sbp_mean1", "sbp_mean2", 
                                         "dbp1", "dbp2", "dbp3", "dbp_mean1", "dbp_mean2",
                                         "rhr1", "rhr2", "rhr3", "rhr_mean1", "rhr_mean2",
                                         "bmi", "bmicat")] <- NA

# LABELS 

attr(DATA_SA$country_ISO,"label") <- "Country ISO code"
attr(DATA_SA$country_name,"label") <- "Country name"
attr(DATA_SA$source,"label") <- "Data source"
attr(DATA_SA$year,"label") <- "Year of data collection - Survey median"
attr(DATA_SA$hhid,"label") <- "Household identifier"
attr(DATA_SA$pid,"label") <- "Individual identifier"
attr(DATA_SA$psu,"label") <- "Primary Sampling Unit"
attr(DATA_SA$stratum,"label") <- "Sampling stratum"
attr(DATA_SA$aweight_sa_int_base ,"label") <- "Sampling weight: Interview (original)"  
attr(DATA_SA$aweight_sa_phys_base ,"label") <- "Sampling weight: Physical examination (original)"  
attr(DATA_SA$aweight_sa_lab_base ,"label") <- "Sampling weight: Laboratory (original)"  
attr(DATA_SA$aweight_sa_int ,"label") <- "Sampling weight: Interview"  
attr(DATA_SA$aweight_sa_phys ,"label") <- "Sampling weight: Physical examination"  
attr(DATA_SA$aweight_sa_lab ,"label") <- "Sampling weight: Laboratory"  

attr(DATA_SA$geolevel1_name,"label") <- "Administrative level 1 - Name"
attr(DATA_SA$geolevel1_code,"label") <- "Administrative level 1 - Code"
attr(DATA_SA$geolevel2_name,"label") <- "Administrative level 2 - Name"
attr(DATA_SA$geolevel2_code,"label") <- "Administrative level 2 - Code"
attr(DATA_SA$geotype2,"label") <- "Urban/rural"

attr(DATA_SA$intm,"label") <- "Interview - Month"
attr(DATA_SA$inty,"label") <- "Interview - Year"
attr(DATA_SA$vism,"label") <- "Anthropometry - Month"
attr(DATA_SA$visq,"label") <- "Anthropometry - Quarter"

attr(DATA_SA$hh_size,"label") <- "Household size"
attr(DATA_SA$hh_size_cat,"label") <- "Household size, categorical"
attr(DATA_SA$hh_ownhome,"label") <- "Dwelling - Ownership"
attr(DATA_SA$hh_totrooms,"label") <- "Number of rooms in dwelling"
attr(DATA_SA$hh_sleeprooms,"label") <- "Number of rooms for sleeping in dwelling"
attr(DATA_SA$hh_ptotrooms,"label") <- "Number of rooms in dwelling, per household member"
attr(DATA_SA$hh_psleeprooms,"label") <- "Number of rooms used for sleeping, per household member"
attr(DATA_SA$hh_dwellingtype,"label") <- "Dwelling - Type"
attr(DATA_SA$hh_wallmaterial,"label") <- "Dwelling - Wall material"
attr(DATA_SA$hh_floormaterial,"label") <- "Dwelling - Floor material"
attr(DATA_SA$hh_roofmaterial,"label") <- "Dwelling - Wall material"
attr(DATA_SA$hh_roof_wall_1,"label") <- "Dwelling - roof/wall material: mud/thaching/wattle and daub"
attr(DATA_SA$hh_roof_wall_2,"label") <- "Dwelling - roof/wall material: mud and cement mix"
attr(DATA_SA$hh_roof_wall_3,"label") <- "Dwelling - roof/wall material: corrugated iron/zinc"
attr(DATA_SA$hh_roof_wall_4,"label") <- "Dwelling - roof/wall material: plastic/cardboard"
attr(DATA_SA$hh_roof_wall_5,"label") <- "Dwelling - roof/wall material: brick/cement/prefab/plaster"
attr(DATA_SA$hh_roof_wall_9999,"label") <- "Dwelling - roof/wall material: other"
attr(DATA_SA$hh_cookingfuel,"label") <- "Main cooking fuel"
attr(DATA_SA$hh_heatingfuel,"label") <- "Main heating fuel"
attr(DATA_SA$hh_cook_elec,"label") <- "Cooking fuel: Electricity"
attr(DATA_SA$hh_cook_gas,"label") <- "Cooking fuel: Gas"
attr(DATA_SA$hh_cook_par,"label") <- "Cooking fuel: Paraffin"
attr(DATA_SA$hh_cook_wood,"label") <- "Cooking fuel: Wood"
attr(DATA_SA$hh_cook_coal,"label") <- "Cooking fuel: Coal"
attr(DATA_SA$hh_cook_dung,"label") <- "Cooking fuel: Dung"
attr(DATA_SA$hh_cook_other,"label") <- "Cooking fuel: Other"
attr(DATA_SA$hh_water,"label") <- "Source of drinking water"
attr(DATA_SA$hh_toilet,"label") <- "Toilet type"
attr(DATA_SA$hh_sharedtoilet,"label") <- "Shared toilet"
attr(DATA_SA$hh_refuseremoved,"label") <- "Refuse removal"
attr(DATA_SA$hh_recgrant,"label") <- "Household member receives goverment grant"
attr(DATA_SA$hh_govsupport,"label") <- "Household receives goverment support"
attr(DATA_SA$hh_foodinsec,"label") <- "Food insecurity"
attr(DATA_SA$hh_foodinsec_adult,"label") <- "Food insecurity: adult"
attr(DATA_SA$hh_foodinsec_child,"label") <- "Food insecurity: child"
attr(DATA_SA$hh_ass_elec ,"label") <- "Household assets: Electricity"       
attr(DATA_SA$hh_ass_radio ,"label") <- "Household assets: Radio"      
attr(DATA_SA$hh_ass_tv ,"label") <- "Household assets: TV"         
attr(DATA_SA$hh_ass_fridge ,"label") <- "Household assets: Fridge"     
attr(DATA_SA$hh_ass_bicycle ,"label") <- "Household assets: Bicycle"    
attr(DATA_SA$hh_ass_motorcycle ,"label") <- "Household assets: Motorcycle" 
attr(DATA_SA$hh_ass_car_truck ,"label") <- "Household assets: Car/Truck" 
attr(DATA_SA$hh_ass_phone ,"label") <- "Household assets: Phone (landline)"      
attr(DATA_SA$hh_ass_computer ,"label") <- "Household assets: Computer"   
attr(DATA_SA$hh_ass_wmachine ,"label") <- "Household assets: Washing Machine"   
attr(DATA_SA$hh_ass_cellphone ,"label") <- "Household assets: Electricity"  
attr(DATA_SA$hh_ass_watch ,"label") <- "Household assets: Phone (cellular)"      
attr(DATA_SA$hh_ass_animalcart ,"label") <- "Household assets: Animal cart" 
attr(DATA_SA$hh_ass_motorboat ,"label") <- "Household assets: Motorboat"  
attr(DATA_SA$hh_ass_vacuum ,"label") <- "Household assets: Vacuum cleaner"    
attr(DATA_SA$hh_ass_microwave ,"label") <- "Household assets: Microwave oven"  
attr(DATA_SA$hh_ass_stove ,"label") <- "Household assets: Stove"      
attr(DATA_SA$hh_ass_sat ,"label") <- "Household assets: Satellite TV"        
attr(DATA_SA$hh_ass_video ,"label") <- "Household assets: Videoplayer"      
attr(DATA_SA$hh_ass_hifi ,"label") <- "Household assets: hifi"       
attr(DATA_SA$hh_ass_camera ,"label") <- "Household assets: Photocamera"     
attr(DATA_SA$hh_ass_smachine ,"label") <- "Household assets: Sewing machine"   
attr(DATA_SA$hh_ass_sofa ,"label") <- "Household assets: Sofa"      
attr(DATA_SA$hh_ass_boat ,"label") <- "Household assets: Boat"       
attr(DATA_SA$hh_ass_plough ,"label") <- "Household assets: Plough"     
attr(DATA_SA$hh_ass_tractor ,"label") <- "Household assets: Tractor"    
attr(DATA_SA$hh_ass_wheelbarrow ,"label") <- "Household assets: Weelbarrow"
attr(DATA_SA$hh_ass_mill ,"label") <- "Household assets: Mill"       
attr(DATA_SA$hh_ass_tab ,"label") <- "Household assets: Table"        
attr(DATA_SA$hh_ass_sink ,"label") <- "Household assets: Sink"       
attr(DATA_SA$hh_ass_hotw ,"label") <- "Household assets: Hot water"      
attr(DATA_SA$hh_ass_dishwasher ,"label") <- "Household assets: Dishwasher"
attr(DATA_SA$hh_edu_deprived ,"label") <- "Deprivation: education"
attr(DATA_SA$hh_unimp_toilet ,"label") <- "Deprivation: sanitation"
attr(DATA_SA$hh_unimp_cooking ,"label") <- "Deprivation: cooking fuel"
attr(DATA_SA$hh_unimp_water ,"label") <- "Deprivation: water"
attr(DATA_SA$hh_dep1plus ,"label") <- "Deprivation: 1+ indicator"
attr(DATA_SA$hh_dep2plus ,"label") <- "Deprivation: 2+ indicators"
attr(DATA_SA$hh_dep3plus ,"label") <- "Deprivation: 3+ indicators"
attr(DATA_SA$hh_dep4plus ,"label") <- "Deprivation: 4+ indicators"
attr(DATA_SA$hh_windex ,"label") <- "Household wealth index"
attr(DATA_SA$hh_windex_quint ,"label") <- "Household wealth index quintile"
attr(DATA_SA$hh_cwi ,"label") <- "Comparative wealth index"
attr(DATA_SA$hh_income ,"label") <- "Household income"
attr(DATA_SA$hh_income_quint ,"label") <- "Household income quintile"
attr(DATA_SA$hh_deaths12mo ,"label") <- "Death in the household last 12 months"

attr(DATA_SA$sex ,"label") <- "Sex"
attr(DATA_SA$age ,"label") <- "Age"
attr(DATA_SA$agecat1 ,"label") <- "Age category (5 years)"
attr(DATA_SA$agecat2 ,"label") <- "Age category (10 years)"
attr(DATA_SA$race ,"label") <- "Population group"
attr(DATA_SA$race_imp ,"label") <- "Population group, imputed"
attr(DATA_SA$marstatus ,"label") <- "Marital status"
attr(DATA_SA$edu1 ,"label") <- "Education: categorisation 1"
attr(DATA_SA$edu2 ,"label") <- "Education: categorisation 2"
attr(DATA_SA$emp ,"label") <- "Employment"

attr(DATA_SA$smokstatus ,"label") <- "Smoking status"
attr(DATA_SA$currsmok ,"label") <- "Current smoker"
attr(DATA_SA$alcstatus ,"label") <- "Alcohol status"
attr(DATA_SA$curralc ,"label") <- "Current drinker"
attr(DATA_SA$alcavg ,"label") <- "Average alcohol consumption [g/day]"
attr(DATA_SA$gpaq ,"label") <- "GPAQ"
attr(DATA_SA$gpaqcat ,"label") <- "GPAQ category"
attr(DATA_SA$exercisefreq ,"label") <- "Exercise frequency"
attr(DATA_SA$self_health ,"label") <- "Self-rated health"

attr(DATA_SA$diag_hbp,"label") <- "Diagnosis: Hypertension"      
attr(DATA_SA$diag_isch,"label") <- "Diagnosis: Heart attack/angina"      
attr(DATA_SA$diag_stroke,"label") <- "Diagnosis: Stroke"    
attr(DATA_SA$diag_chol,"label") <- "Diagnosis: Hypercholesterolaemia"      
attr(DATA_SA$diag_diab,"label") <- "Diagnosis: Diabetes/hyperglicaemia"      
attr(DATA_SA$diag_emph,"label") <- "Diagnosis: Emphisema/Chrinic bronchitis"      
attr(DATA_SA$diag_asth,"label") <- "Diagnosis: Asthma"      
attr(DATA_SA$diag_tb,"label") <- "Diagnosis: Tuberculosis"       
attr(DATA_SA$diag_cancer,"label") <- "Diagnosis: Cancer"    
attr(DATA_SA$diag_heart,"label") <- "Diagnosis: Heart problems"     
attr(DATA_SA$bpmed,"label") <- "Medication: Hypertension"       
attr(DATA_SA$diabmed,"label") <- "Medication: Diabetes/hyperglicaemia"            
attr(DATA_SA$cholmed,"label") <- "Medication: Hypercholesterolaemia"            
attr(DATA_SA$ischmed,"label") <- "Medication: Heart attack/angina"            
attr(DATA_SA$lungmed,"label") <- "Medication: Respiratory problems"            
attr(DATA_SA$tbmed,"label") <- "Medication: Tuberculosis"              
attr(DATA_SA$strokemed,"label") <- "Medication: Stroke"       
attr(DATA_SA$bpmed_coded,"label") <- "Medication: Hypertension, coded"        
attr(DATA_SA$diabmed_coded,"label") <- "Medication: Diabetes/hyperglicaemia, coded"    
attr(DATA_SA$cholmed_coded,"label") <- "Medication: Hypercholesterolaemia, coded"   
attr(DATA_SA$ischmed_coded,"label") <- "Medication: Heart attack/angina, coded"    
attr(DATA_SA$lungmed_coded,"label") <- "Medication: Respiratory problems, coded"    
attr(DATA_SA$tbmed_coded,"label") <- "Medication: Tuberculosis, coded"     
attr(DATA_SA$strokemed_coded,"label") <- "Medication: Stroke, coded"  
attr(DATA_SA$parity ,"label") <- "Parity"
attr(DATA_SA$currpreg ,"label") <- "Currently pregnant"
attr(DATA_SA$everpreg ,"label") <- "Ever pregnant"

attr(DATA_SA$height1 ,"label") <- "Height [cm] - First reading"
attr(DATA_SA$height2 ,"label") <- "Height [cm] - Second reading"
attr(DATA_SA$height3 ,"label") <- "Height [cm] - Third reading"
attr(DATA_SA$height ,"label") <- "Height [cm] - Average of available readings "

attr(DATA_SA$weight1 ,"label") <- "Weight [Kg] - First reading"
attr(DATA_SA$weight2 ,"label") <- "Weight [Kg] - Second reading"
attr(DATA_SA$weight3 ,"label") <- "Weight [Kg] - Third reading"
attr(DATA_SA$weight ,"label") <- "Weight [Kg] - Average of available readings"

attr(DATA_SA$waist1 ,"label") <- "Waist circumference [cm] - First reading"
attr(DATA_SA$waist2 ,"label") <- "Waist circumference [cm] - Second reading"
attr(DATA_SA$waist3 ,"label") <- "Waist circumference [cm] - Third reading"
attr(DATA_SA$waist ,"label") <- "Waist circumference [cm] - Average of available readings"

attr(DATA_SA$arm1 ,"label") <- "Arm circumference [cm] - First reading"
attr(DATA_SA$arm2 ,"label") <- "Arm circumference [cm] - Second reading"
attr(DATA_SA$arm3 ,"label") <- "Arm circumference [cm] - Third reading"
attr(DATA_SA$arm ,"label") <- "Arm circumference [cm] - Average of available readings"

attr(DATA_SA$hip1 ,"label") <- "Hip circumference [cm] - First reading"
attr(DATA_SA$hip2 ,"label") <- "Hip circumference [cm] - Second reading"
attr(DATA_SA$hip3 ,"label") <- "Hip circumference [cm] - Third reading"
attr(DATA_SA$hip ,"label") <- "Hip circumference [cm] - Average of available readings"

attr(DATA_SA$sbp1 ,"label") <- "Systolic Blood Pressure [mmHg] - First reading"
attr(DATA_SA$sbp2 ,"label") <- "Systolic Blood Pressure [mmHg] - Second reading"
attr(DATA_SA$sbp3 ,"label") <- "Systolic Blood Pressure [mmHg] - Third reading"
attr(DATA_SA$sbp_mean1 ,"label") <- "Systolic Blood Pressure [mmHg] - Average of available readings"
attr(DATA_SA$sbp_mean2 ,"label") <- "Systolic Blood Pressure [mmHg] - Average of available readings excluding the first"

attr(DATA_SA$dbp1 ,"label") <- "Diastolic Blood Pressure [mmHg] - First reading"
attr(DATA_SA$dbp2 ,"label") <- "Diastolic Blood Pressure [mmHg] - Second reading"
attr(DATA_SA$dbp3 ,"label") <- "Diastolic Blood Pressure [mmHg] - Third reading"
attr(DATA_SA$dbp_mean1 ,"label") <- "Diastolic Blood Pressure [mmHg] - Average of available readings"
attr(DATA_SA$dbp_mean2 ,"label") <- "Diastolic Blood Pressure [mmHg] - Average of available readings excluding the first"

attr(DATA_SA$rhr1 ,"label") <- "Resting Heart Rate [ppm] - First reading"
attr(DATA_SA$rhr2 ,"label") <- "Resting Heart Rate [ppm] - Second reading"
attr(DATA_SA$rhr3 ,"label") <- "Resting Heart Rate [ppm] - Third reading"
attr(DATA_SA$rhr_mean1 ,"label") <- "Resting Heart Rate [ppm] - Average of available readings"
attr(DATA_SA$rhr_mean2 ,"label") <- "Resting Heart Rate [ppm] - Average of available readings excluding the first"
attr(DATA_SA$bmi ,"label") <- "BMI [kg/m2]"
attr(DATA_SA$bmicat ,"label") <- "BMI category"
attr(DATA_SA$hb ,"label") <- "Haemoglobin [g/dl]"                  
attr(DATA_SA$HbA1c ,"label") <- "Glycated Haemoglobin (HbAic) [mmol/mol]"               
attr(DATA_SA$chol_tot ,"label") <- "Total cholesterol [mmol/l]"           
attr(DATA_SA$chol_hdl ,"label") <- "High-density lipoprotein (HDL) cholesterol [mmol/l]"            
attr(DATA_SA$chol_ldl ,"label") <- "Low-density lipoprotein (LDL) cholesterol [mmol/l]" 
attr(DATA_SA$trig ,"label") <- "Triglycerides [mmol/l]" 

attr(DATA_SA$medaid ,"label") <- "Covered by medical insurance"
attr(DATA_SA$hcare12mo,"label") <- "Health consultation last 12 months"           
attr(DATA_SA$hcare1mo,"label") <- "Healthcare consultations last month"              
attr(DATA_SA$hcare1mo_public,"label") <- "Healthcare last month: public hospital/clinic"       
attr(DATA_SA$hcare1mo_private,"label") <- "Healthcare last month: private hospital/clinic/doctor"     
attr(DATA_SA$ohcare1mo,"label") <- "Outpatient consultations last month"             
attr(DATA_SA$ohcare1mo_public,"label") <- "Outpatient healthcare last month: public hospital/clinic"      
attr(DATA_SA$ohcare1mo_private,"label") <- "Outpatient healthcare last month: private hospital/clinic/doctor"     
attr(DATA_SA$hcare1mo_chem_nurse,"label") <- "Healthcare last month: chemist/pharmacist/nurse"  
attr(DATA_SA$hcare1mo_trad,"label") <- "Healthcare last month: traditional/faith healer"        
attr(DATA_SA$hcare1mo_other,"label") <- "Healthcare last month: other"   

attr(DATA_SA$globorisk_nonlab ,"label") <- "Globorisk CVD non laboratory risk score"  
attr(DATA_SA$globorisk_lab ,"label") <- "Globorisk CVD laboratory risk score"  
attr(DATA_SA$globorisk_lab_fatal ,"label") <- "Globorisk CVD fatal risk score"  
attr(DATA_SA$who_nonlab ,"label") <- "WHO/ISH CVD non laboratory risk score"  
attr(DATA_SA$who_lab ,"label") <- "WHO/ISH CVD non laboratory risk score"  
attr(DATA_SA$fhs_nonlab ,"label") <- "Framingham CVD non laboratory risk score"  

##########################################################################################################################################################################
# (5B) FINALISE EN                                                                                                                                                       #
##########################################################################################################################################################################

DATA_EN <- subset(DATA, country_ISO == "GBR")
UCOLEN <- c(NULL)   # NON-EMPTY COLUMNS IN EN DATASETS
for (i in c(1:ncol(DATA_EN))) {
  if (sum(as.numeric(DATA_EN[,i]), na.rm = TRUE) > 0) {
    UCOLEN <- c(UCOLEN, colnames(DATA_EN)[i])
  }
}
DATA_EN <- DATA_EN[, UCOLEN]

ORDEN <- c(
  "country_ISO", "country_name", "source", "year", "pid", "psu", "stratum", 
  "aweight_en_int","aweight_en_int_cvd","aweight_en_nonlab","aweight_en_nonlab_cvd","aweight_en_lab","aweight_en_lab_cvd",
  "geolevel1_name", "geolevel1_code", "geotype2", 
  "intm", "intq","inty", "vism", "visq", 
  "hh_size", "hh_size_cat",
  "hh_ownhome", 
  "hh_ass_car_truck", "hh_carnum",
  "hh_recgrant",
  "hh_income","hh_income_quint","hh_income_eq",
  "sex", "age", "agecat1", "agecat2", 
  "race_e", "marstatus", "edu3", "emp", "occupation",
  "smokstatus", "currsmok", 
  "alcstatus","curralc","alcmax",
  "fruitveg",
  "self_health", 
  "diag_hbp", "diag_isch", "diag_stroke", "diag_diab",  
  "diag_cancer", "diag_heart", "diag_diab2", "diag_hbp2", "diag_angi", "diag_mi", "diag_lung", "diag_mental", "diag_infectious", 
  "diag_metabolic", "diag_nerve", "diag_blood",
  "bpmed", "bpmed_coded","diabmed","cholmed","contraceptives",
  "currpreg",
  "height1", "height", 
  "weight1", "weight", 
  "waist1", "waist2", "waist3", "waist", 
  "hip1", "hip2", "hip3", "hip", 
  "sbp1", "sbp2", "sbp3", "sbp_mean1", "sbp_mean2", 
  "dbp1", "dbp2", "dbp3", "dbp_mean1", "dbp_mean2",
  "rhr1","rhr2","rhr3", "rhr_mean1", "rhr_mean2",
  "airtemp",
  "bmi", "bmicat", 
   "chol_tot", "chol_hdl",
  "globorisk_nonlab","globorisk_lab","globorisk_lab_fatal","who_nonlab","who_lab", "fhs_nonlab"
)

DATA_EN <- DATA_EN[,ORDEN]

# LABELS 

attr(DATA_EN$country_ISO,"label") <- "Country ISO code"
attr(DATA_EN$country_name,"label") <- "Country name"
attr(DATA_EN$source,"label") <- "Data source"
attr(DATA_EN$year,"label") <- "Year of data collection - Survey median"
attr(DATA_SA$pid,"label") <- "Individual identifier"
attr(DATA_EN$psu,"label") <- "Primary Sampling Unit"
attr(DATA_EN$stratum,"label") <- "Sampling stratum"
attr(DATA_EN$aweight_en_int ,"label") <- "Sampling weight: Interview"  
attr(DATA_EN$aweight_en_int_cvd ,"label") <- "Sampling weight: Interview, CVD analysis"  
attr(DATA_EN$aweight_en_nonlab ,"label") <- "Sampling weight: non-lab risk score"  
attr(DATA_EN$aweight_en_nonlab_cvd ,"label") <- "Sampling weight: non-lab risk score, CVD analysis"  
attr(DATA_EN$aweight_en_lab ,"label") <- "Sampling weight: aboratory risk score"  
attr(DATA_EN$aweight_en_lab_cvd ,"label") <- "Sampling weight: laboratory risk score, CVD analysis"  

attr(DATA_EN$geolevel1_name,"label") <- "Administrative level 1 - Name"
attr(DATA_EN$geolevel1_code,"label") <- "Administrative level 1 - Code"
attr(DATA_EN$geotype2,"label") <- "Urban/rural"

attr(DATA_EN$intm,"label") <- "Interview - Month"
attr(DATA_EN$intq,"label") <- "Interview - Quarter"
attr(DATA_SA$inty,"label") <- "Interview - Year"
attr(DATA_EN$vism,"label") <- "Anthropometry - Month"
attr(DATA_EN$visq,"label") <- "Anthropometry - Quarter"

attr(DATA_EN$hh_size,"label") <- "Household size"
attr(DATA_EN$hh_size_cat,"label") <- "Household size, categorical"
attr(DATA_EN$hh_ownhome,"label") <- "Dwelling - Ownership"
attr(DATA_EN$hh_ass_car_truck ,"label") <- "Household assets: Car/Truck" 
attr(DATA_EN$hh_carnum ,"label") <- "Number of cars available"
attr(DATA_EN$hh_recgrant,"label") <- "Household member receives goverment grant"
attr(DATA_EN$hh_income ,"label") <- "Household income"
attr(DATA_EN$hh_income_quint ,"label") <- "Household income quintile"
attr(DATA_EN$hh_income_eq ,"label") <- "Household income, equalised"

attr(DATA_EN$sex ,"label") <- "Sex"
attr(DATA_EN$age ,"label") <- "Age"
attr(DATA_EN$agecat1 ,"label") <- "Age category (5 years)"
attr(DATA_EN$agecat2 ,"label") <- "Age category (10 years)"
attr(DATA_EN$race_e ,"label") <- "Ethnicity"
attr(DATA_EN$marstatus ,"label") <- "Marital status"
attr(DATA_EN$edu3 ,"label") <- "Education: categorisation 3"
attr(DATA_EN$emp ,"label") <- "Employment"
attr(DATA$occupation ,"label") <- "Social class/occupation"

attr(DATA_EN$smokstatus ,"label") <- "Smoking status"
attr(DATA_EN$currsmok ,"label") <- "Current smoker"
attr(DATA_EN$alcstatus ,"label") <- "Alcohol status"
attr(DATA_EN$curralc ,"label") <- "Current drinker"
attr(DATA_EN$alcmax ,"label") <- "Alcohol consumption on heaviest day [units]"
attr(DATA_EN$fruitveg ,"label") <- "5+ portions of fruit/vegetables eaten yesterday"
attr(DATA_EN$self_health ,"label") <- "Self-rated health"

attr(DATA_EN$diag_hbp,"label") <- "Diagnosis: Hypertension"      
attr(DATA_EN$diag_isch,"label") <- "Diagnosis: Heart attack/angina"      
attr(DATA_EN$diag_stroke,"label") <- "Diagnosis: Stroke"    
attr(DATA_EN$diag_diab,"label") <- "Diagnosis: Diabetes/hyperglicaemia"      
attr(DATA_EN$diag_cancer,"label") <- "Diagnosis: Cancer"    
attr(DATA_EN$diag_heart,"label") <- "Diagnosis: Heart problems"     
attr(DATA_EN$diag_diab2 ,"label") <- "Diagnosis: diabetes, excluding pregnancy"      
attr(DATA_EN$diag_hbp2 ,"label") <- "Diagnosis: hypertension, excluding pregnancy"           
attr(DATA_EN$diag_angi ,"label") <- "Diagnosis: angina"           
attr(DATA_EN$diag_mi ,"label") <- "Diagnosis: heart attack (myocardial infarction)"             
attr(DATA_EN$diag_lung ,"label") <- "Diagnosis: Respiratory condition"          
attr(DATA_EN$diag_mental ,"label") <- "Diagnosis: Mental disorder"         
attr(DATA_EN$diag_infectious ,"label") <- "Diagnosis: Infectious disorder"    
attr(DATA_EN$diag_metabolic ,"label") <- "Diagnosis: Endocrine/metabolic disorder"      
attr(DATA_EN$diag_nerve ,"label") <- "Diagnosis: Nervous system disorder"          
attr(DATA_EN$diag_blood ,"label") <- "Diagnosis: Blood disorder"    

attr(DATA_EN$bpmed,"label") <- "Medication: Hypertension"       
attr(DATA_EN$bpmed_coded,"label") <- "Medication: Hypertension, coded" 
attr(DATA_EN$diabmed,"label") <- "Medication: Diabetes/hyperglicaemia"            
attr(DATA_EN$cholmed,"label") <- "Medication: Hypercholesterolaemia"  
attr(DATA_EN$contraceptives,"label") <- "Medication: Contraceptives"      
  
attr(DATA_EN$currpreg ,"label") <- "Currently pregnant"

attr(DATA_EN$height1 ,"label") <- "Height [cm] - First reading"
attr(DATA_EN$height ,"label") <- "Height [cm] - Average of available readings"

attr(DATA_EN$weight1 ,"label") <- "Weight [Kg] - First reading"
attr(DATA_EN$weight ,"label") <- "Weight [Kg] - Average of available readings"

attr(DATA_EN$waist1 ,"label") <- "Waist circumference [cm] - First reading"
attr(DATA_EN$waist2 ,"label") <- "Waist circumference [cm] - Second reading"
attr(DATA_EN$waist3 ,"label") <- "Waist circumference [cm] - Third reading"
attr(DATA_EN$waist ,"label") <- "Waist circumference [cm] - Average of available readings"

attr(DATA_EN$hip1 ,"label") <- "Hip circumference [cm] - First reading"
attr(DATA_EN$hip2 ,"label") <- "Hip circumference [cm] - Second reading"
attr(DATA_EN$hip3 ,"label") <- "Hip circumference [cm] - Third reading"
attr(DATA_EN$hip ,"label") <- "Hip circumference [cm] - Average of available readings"

attr(DATA_EN$sbp1 ,"label") <- "Systolic Blood Pressure [mmHg] - First reading"
attr(DATA_EN$sbp2 ,"label") <- "Systolic Blood Pressure [mmHg] - Second reading"
attr(DATA_EN$sbp3 ,"label") <- "Systolic Blood Pressure [mmHg] - Third reading"
attr(DATA_EN$sbp_mean1 ,"label") <- "Systolic Blood Pressure [mmHg] - Average of available readings"
attr(DATA_EN$sbp_mean2 ,"label") <- "Systolic Blood Pressure [mmHg] - Average of available readings excluding the first"

attr(DATA_EN$dbp1 ,"label") <- "Diastolic Blood Pressure [mmHg] - First reading"
attr(DATA_EN$dbp2 ,"label") <- "Diastolic Blood Pressure [mmHg] - Second reading"
attr(DATA_EN$dbp3 ,"label") <- "Diastolic Blood Pressure [mmHg] - Third reading"
attr(DATA_EN$dbp_mean1 ,"label") <- "Diastolic Blood Pressure [mmHg] - Average of available readings"
attr(DATA_EN$dbp_mean2 ,"label") <- "Diastolic Blood Pressure [mmHg] - Average of available readings excluding the first"

attr(DATA_EN$rhr1 ,"label") <- "Resting Heart Rate [ppm] - First reading"
attr(DATA_EN$rhr2 ,"label") <- "Resting Heart Rate [ppm] - Second reading"
attr(DATA_EN$rhr3 ,"label") <- "Resting Heart Rate [ppm] - Third reading"
attr(DATA_EN$rhr_mean1 ,"label") <- "Resting Heart Rate [ppm] - Average of available readings"
attr(DATA_EN$rhr_mean2 ,"label") <- "Resting Heart Rate [ppm] - Average of available readings excluding the first"

attr(DATA_EN$airtemp ,"label") <- "Air temperature during blood pressure measurement [C]"

attr(DATA_EN$bmi ,"label") <- "BMI [kg/m2]"
attr(DATA_EN$bmicat ,"label") <- "BMI category"
attr(DATA_EN$chol_tot ,"label") <- "Total cholesterol [mmol/l]"           
attr(DATA_EN$chol_hdl ,"label") <- "High-density lipoprotein (HDL) cholesterol [mmol/l]"            

attr(DATA_EN$globorisk_nonlab ,"label") <- "Globorisk CVD non laboratory risk score"  
attr(DATA_EN$globorisk_lab ,"label") <- "Globorisk CVD laboratory risk score"  
attr(DATA_EN$globorisk_lab_fatal ,"label") <- "Globorisk CVD fatal risk score"  
attr(DATA_EN$who_nonlab ,"label") <- "WHO/ISH CVD non laboratory risk score"  
attr(DATA_EN$who_lab ,"label") <- "WHO/ISH CVD non laboratory risk score"  
attr(DATA_EN$fhs_nonlab ,"label") <- "Framingham CVD non laboratory risk score"  


##########################################################################################################################################################################
# (7) SAVE                                                                                                                                                               #
##########################################################################################################################################################################

save(DATA_SA, file = "EXPOSE_SA_1.0.RData")
save(DATA_EN, file = "EXPOSE_EN_1.0.RData")

