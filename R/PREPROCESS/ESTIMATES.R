##########################################################################################################################################################################
# EXPOSE - GROUP ESTIMATES                                                                                                                                               #
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

##########################################################################################################################################################################
# LOCATION OF FILES AND FOLDERS                                                                                                                                          #
##########################################################################################################################################################################
  
# OUTPUT DIRECTORY
OUT <- "2 - PREPROCESS/OUT"

# INPUT DIRECTORY
IN <- "2 - PREPROCESS/OUT"

# AUX DATA DIRECTORY
AUX <- "./DATA"

# CONSOLIDATED DATA 
MICRODATA_FILE <- "MICRODATA.RData"

##########################################################################################################################################################################
# SETTINGS                                                                                                                                                               #
##########################################################################################################################################################################

# SURVEY 
options(survey.lonely.psu = "certainty")

# SAVE INTERMEDIATE RESULTS 
SAVETEMP <- TRUE

##########################################################################################################################################################################
# FUNCTIONS                                                                                                                                                              #
##########################################################################################################################################################################

loadRData <- function(fileName){ #loads an RData file, and returns it
  load(fileName)
  get(ls()[ls() != "fileName"])
}

##########################################################################################################################################################################
# LOAD DATA                                                                                                                                                              #
##########################################################################################################################################################################

# CONSOLIDATED CORE DATASET

MDATA <- loadRData(paste(IN,"/",MICRODATA_FILE, sep = ""))

##########################################################################################################################################################################
# ESTIMATES: PREPROCESS                                                                                                                                                  #
##########################################################################################################################################################################

E_DESIGN <- c("psu", "stratum", "aweight", "aweight_rec", "aweight_rec_risk")
E_SUBSET <- c("country_name", "source", "year", "agecat1", "agecat2", "geolevel1_name", "geotype2","sex") 

E_SOCIO <- c("hh_windex","hh_cwi")
V_SOCIO <- c("c","c")

E_LIFESTYLE <- c("currsmok", "curralc", "alcavg", "gpaq")       
V_LIFESTYLE <- c("b", "b", "c", "c")  
names(E_LIFESTYLE) <- c(
  "Current smoking", 
  "Current alcohol use", 
  "Average daily alcohol consumption", 
  "GPAQ")

E_DIAGNOSES <- c("diag_hbp", "diag_isch", "diag_stroke", "diag_chol", "diag_diab", "diag_emph", "diag_asth", "diag_tb", "diag_cancer")              
V_DIAGNOSES <- rep("b", length(E_DIAGNOSES))      
names(E_DIAGNOSES) <- c(
  "Hypertension", 
  "Ischaemic heart disease", 
  "Stroke", 
  "Hypercholeterolaemia", 
  "Diabetes", 
  "Emphisema/bronchitis/COPD", 
  "Asthma", 
  "TB",
  "Cancer" 
)

E_MED <- c("bpmed", "diabmed", "cholmed", "ischmed","lungmed", "tbmed", "strokemed")
V_MED <- rep("b", length(E_MED))
names(E_MED) <- c(
  "Hypertension", 
  "Diabetes", 
  "Hypercholesterolaemia", 
  "Ischaemic heart disease", 
  "Emphisema/bronchitis/copd", 
  "TB", 
  "Stroke")

E_ANTHRO <- c("height", "weight", "waist", "arm", "hip", "sbp_mean1","sbp_mean2","dbp_mean1", "dbp_mean2","rhr_mean1", "rhr_mean2", "bmi")
V_ANTHRO <- rep("c",length(E_ANTHRO))
names(E_ANTHRO) <- c(
  "Height", "Weight",
  "Waist circumference", 
  "Arm circumference", 
  "Hip cirdumference", 
  "Systolic BP (all readings)",
  "Systolic BP (exclude first)",
  "Diastolic Blood pressure (all readings)",
  "Diastolic Blood pressure  (exclude first)",
  "Resting heart rate (all readings)", 
  "Resting heart rate (exclude first)", 
  "Body mass index"
)

E_LAB <- c("hb", "HbA1c", "chol_tot", "chol_hdl", "chol_ldl", "trig") 
V_LAB <- rep("c", length(E_LAB))
names(E_LAB) <- c(
  "Hb", 
  "HbA1c", 
  "Total cholesterol", 
  "HDL choleterol", 
  "LDL cholesterol", 
  "Triglicerides")

E_SCORE <- c("who_nonlab","who_lab","globorisk_nonlab","globorisk_lab")
V_SCORE <- rep("c",length(E_SCORE))
names(E_SCORE) <- c(
  "WHO (non lab)", 
  "WHO (lab)", 
  "Globorisk (non lab)", 
  "Globorisk (lab)")

E_LIST <- c(E_DESIGN, E_SUBSET, E_SOCIO, E_LIFESTYLE, E_DIAGNOSES, E_MED, E_ANTHRO, E_LAB, E_SCORE)
E_OUT <-  c(E_SOCIO, E_LIFESTYLE, E_DIAGNOSES, E_MED, E_ANTHRO, E_LAB, E_SCORE) 
E_TYPE <- c(V_SOCIO, V_LIFESTYLE, V_DIAGNOSES, V_MED, V_ANTHRO, V_LAB, V_SCORE)

GEOSA <- c("Gauteng","North West","Free State","Limpopo","KwaZulu Natal","Western Cape","Eastern Cape","Mpumalanga","Northern Cape")
GEOEN <- c("London","Eastern","South East","North East","North West & Merseyside","East Midlands","Yorkshire & The Humberside","South West","West Midlands")
 
# SURVEY DESIGNS

SDATAI <- svydesign(id = ~psu, weights = ~aweight_rec, strata = ~stratum, data = MDATA[,E_LIST], nest = TRUE)                                          # INTERVIEW WEIGHTS    
SDATAR <- svydesign(id = ~psu, weights = ~aweight_rec_risk, strata = ~stratum, data = subset(MDATA[,E_LIST], !is.na(aweight_rec_risk)), nest = TRUE)   # RISK WEIGHTS    

##########################################################################################################################################################################
# ESTIMATES 1: COUNTRY                                                                                                                                                   #
##########################################################################################################################################################################

EDATA <- data.frame(matrix(NA, ncol = 10, nrow = 0))
colnames(EDATA) <- c("country", "year", "agecat", "sex", "variable", "est", "se", "lb", "ub", "weights")

for (k in unique(MDATA$country_name)) {
  for (y in unique(MDATA$year)) {
    for (a in unique(MDATA$agecat1)) {
      for (s in unique(MDATA$sex)) {
        cat(paste("---- Country = ", k, ", Year = ", y, ", Agecat1 = ", a, "\n", sep = ""))
        SI <- subset(SDATAI, country_name == k & year == y & agecat1 == a & sex == s)
        SR <- subset(SDATAR, country_name == k & year == y & agecat1 == a & sex == s)
        if (nrow(SI$cluster) > 0) {
          for (v in c(1:length(E_OUT))) {
            cat(paste(E_OUT[v], ", ", sep = ""))
            if (E_TYPE[v] == "b") {
              x <- try(EST <- svyciprop(as.formula(paste("~", E_OUT[v], sep = "")), design = SI, method = "logit", na.rm = TRUE), silent = TRUE)
              if (is.numeric(x[1])) {
                E <- EDATA[0, ]
                E[1, ]$country <- k
                E[1, ]$year <- y
                E[1, ]$agecat <- a
                E[1, ]$sex <- s
                E[1, ]$variable <- E_OUT[v]
                E[1, c("est")] <- as.numeric(EST)
                E[1, c("lb", "ub")] <- attr(EST, "ci")
                E[1, c("se")] <- (E[1, ]$ub - E[1, ]$lb) / (2 * 1.96)
                E[1, ]$weights <- "Interview"
                EDATA <- rbind(EDATA, E)
              }
              
              x <- try(EST <- svyciprop(as.formula(paste("~", E_OUT[v], sep = "")), design = SR, method = "logit", na.rm = TRUE), silent = TRUE)
              if (is.numeric(x[1])) {  
                E <- EDATA[0, ]
                E[1, ]$country <- k
                E[1, ]$year <- y
                E[1, ]$agecat <- a
                E[1, ]$sex <- s
                E[1, ]$variable <- E_OUT[v]
                E[1, c("est")] <- as.numeric(EST)
                E[1, c("lb", "ub")] <- attr(EST, "ci")
                E[1, c("se")] <- (E[1, ]$ub - E[1, ]$lb) / (2 * 1.96)
                E[1, ]$weights <- "Risk"
                EDATA <- rbind(EDATA, E)
              }
            } else if (E_TYPE[v] == "c") {
              x <- try(EST <- svymean(as.formula(paste("~", E_OUT[v], sep = "")), design = SI, na.rm = TRUE), silent = TRUE)
              if (is.numeric(x[1])) {
                E <- EDATA[0, ]
                E[1, ]$country <- k
                E[1, ]$year <- y
                E[1, ]$agecat <- a
                E[1, ]$sex <- s
                E[1, ]$variable <- E_OUT[v]
                E[1, c("est")] <- EST[1]
                E[1, c("lb", "ub")] <- confint(EST)
                E[1, c("se")] <- sqrt(attr(EST, "var"))
                E[1, ]$weights <- "Interview"
                EDATA <- rbind(EDATA, E)
              }
              x <- try(EST <- svymean(as.formula(paste("~", E_OUT[v], sep = "")), design = SR, na.rm = TRUE), silent = TRUE)
              if (is.numeric(x[1])) {
                E <- EDATA[0, ]
                E[1, ]$country <- k
                E[1, ]$year <- y
                E[1, ]$agecat <- a
                E[1, ]$sex <- s
                E[1, ]$variable <- E_OUT[v]
                E[1, c("est")] <- EST[1]
                E[1, c("lb", "ub")] <- confint(EST)
                E[1, c("se")] <- sqrt(attr(EST, "var"))
                E[1, ]$weights <- "Risk"
                EDATA <- rbind(EDATA, E)
              }
            }
          }
        }
        cat("\n")
      }
    }
  }
}

if (SAVETEMP) {
  EDATA_A <- EDATA
  save(EDATA_A, file = paste(OUT, "/EDATA_A.RData", sep = ""))
}

for (k in unique(MDATA$country_name)) {
  for (y in unique(MDATA$year)) {
    for (a in unique(MDATA$agecat2)) {
      for (s in unique(MDATA$sex)) {
        cat(paste("---- Country = ", k, ", Year = ", y, ", Agecat2 = ", a, "\n", sep = ""))
        SI <- subset(SDATAI, country_name == k & year == y & agecat2 == a & sex == s)
        SR <- subset(SDATAR, country_name == k & year == y & agecat2 == a & sex == s)
        if (nrow(SI$cluster) > 0) {
          for (v in c(1:length(E_OUT))) {
            cat(paste(E_OUT[v], ", ", sep = ""))
            if (E_TYPE[v] == "b") {
              x <- try(EST <- svyciprop(as.formula(paste("~", E_OUT[v], sep = "")), design = SI, method = "logit", na.rm = TRUE), silent = TRUE)
              if (is.numeric(x[1])) {
                E <- EDATA[0, ]
                E[1, ]$country <- k
                E[1, ]$year <- y
                E[1, ]$agecat <- a
                E[1, ]$sex <- s
                E[1, ]$variable <- E_OUT[v]
                E[1, c("est")] <- as.numeric(EST)
                E[1, c("lb", "ub")] <- attr(EST, "ci")
                E[1, c("se")] <- (E[1, ]$ub - E[1, ]$lb) / (2 * 1.96)
                E[1, ]$weights <- "Interview"
                EDATA <- rbind(EDATA, E)
              }
              x <- try(EST <- svyciprop(as.formula(paste("~", E_OUT[v], sep = "")), design = SR, method = "logit", na.rm = TRUE), silent = TRUE)
              if (is.numeric(x[1])) { 
                E <- EDATA[0, ]
                E[1, ]$country <- k
                E[1, ]$year <- y
                E[1, ]$agecat <- a
                E[1, ]$sex <- s
                E[1, ]$variable <- E_OUT[v]
                E[1, c("est")] <- as.numeric(EST)
                E[1, c("lb", "ub")] <- attr(EST, "ci")
                E[1, c("se")] <- (E[1, ]$ub - E[1, ]$lb) / (2 * 1.96)
                E[1, ]$weights <- "Risk"
                EDATA <- rbind(EDATA, E)
              }
            } else if ((E_TYPE[v] == "c")) {
              x <- try(EST <- svymean(as.formula(paste("~", E_OUT[v], sep = "")), design = SI, na.rm = TRUE), silent = TRUE)
              if (is.numeric(x[1])) {
                E <- EDATA[0, ]
                E[1, ]$country <- k
                E[1, ]$year <- y
                E[1, ]$agecat <- a
                E[1, ]$sex <- s
                E[1, ]$variable <- E_OUT[v]
                E[1, c("est")] <- EST[1]
                E[1, c("lb", "ub")] <- confint(EST)
                E[1, c("se")] <- sqrt(attr(EST, "var"))
                E[1, ]$weights <- "Interview"
                EDATA <- rbind(EDATA, E)
              }
              x <- try(EST <- svymean(as.formula(paste("~", E_OUT[v], sep = "")), design = SR, na.rm = TRUE), silent = TRUE)
              if (is.numeric(x[1])) {
                E <- EDATA[0, ]
                E[1, ]$country <- k
                E[1, ]$year <- y
                E[1, ]$agecat <- a
                E[1, ]$sex <- s
                E[1, ]$variable <- E_OUT[v]
                E[1, c("est")] <- EST[1]
                E[1, c("lb", "ub")] <- confint(EST)
                E[1, c("se")] <- sqrt(attr(EST, "var"))
                E[1, ]$weights <- "Risk"
                EDATA <- rbind(EDATA, E)
              }
            } 
          }
        }
        cat("/n")
      }
    }
  }
}

EDATA$geolevel1 <- "All"
EDATA_1 <- EDATA

if (SAVETEMP) {
  EDATA_B <- EDATA
  save(EDATA_B, file = paste(OUT, "/EDATA_B.RData", sep = ""))
}

##########################################################################################################################################################################
# ESTIMATES 2: GEOLEVEL1                                                                                                                                                 #
##########################################################################################################################################################################

EDATA <- data.frame(matrix(NA, ncol = 10, nrow = 0))
colnames(EDATA) <- c("geolevel1", "year", "agecat", "sex", "variable", "est", "se", "lb", "ub", "weights")

MDATA <- subset(MDATA, !is.na(geolevel1_name))

for (k in unique(MDATA$geolevel1_name)) {
  for (y in unique(MDATA$year)) {
    for (a in unique(MDATA$agecat1)) {
      for (s in unique(MDATA$sex)) {
            start_time <- Sys.time()
        cat(paste("---- Geolevel1 = ", k, ", Year = ", y, ", Agecat1 = ", a, "\n", sep = ""))
        SI <- subset(SDATAI, geolevel1_name == k & year == y & agecat1 == a & sex == s)
        SR <- subset(SDATAR, geolevel1_name == k & year == y & agecat1 == a & sex == s)
        if (nrow(SI$cluster) > 0) {
          for (v in c(1:length(E_OUT))) {
            cat(paste(E_OUT[v], ", ", sep = ""))
            if (E_TYPE[v] == "b") {
              x <- try(EST <- svyciprop(as.formula(paste("~", E_OUT[v], sep = "")), design = SI, method = "logit", na.rm = TRUE), silent = TRUE)
              if (is.numeric(x[1])) {
                E <- EDATA[0, ]
                E[1, ]$geolevel1 <- k
                E[1, ]$year <- y
                E[1, ]$agecat <- a
                E[1, ]$sex <- s
                E[1, ]$variable <- E_OUT[v]
                E[1, c("est")] <- as.numeric(EST)
                E[1, c("lb", "ub")] <- attr(EST, "ci")
                E[1, c("se")] <- (E[1, ]$ub - E[1, ]$lb) / (2 * 1.96)
                E[1, ]$weights <- "Interview"
                EDATA <- rbind(EDATA, E)
              }
              x <- try(EST <- svyciprop(as.formula(paste("~", E_OUT[v], sep = "")), design = SR, method = "logit", na.rm = TRUE), silent = TRUE)
              if (is.numeric(x[1])) {  
                E <- EDATA[0, ]
                E[1, ]$geolevel1 <- k
                E[1, ]$year <- y
                E[1, ]$agecat <- a
                E[1, ]$sex <- s
                E[1, ]$variable <- E_OUT[v]
                E[1, c("est")] <- as.numeric(EST)
                E[1, c("lb", "ub")] <- attr(EST, "ci")
                E[1, c("se")] <- (E[1, ]$ub - E[1, ]$lb) / (2 * 1.96)
                E[1, ]$weights <- "Risk"
                EDATA <- rbind(EDATA, E)
              }
            } else if ((E_TYPE[v] == "c")) {
              x <- try(EST <- svymean(as.formula(paste("~", E_OUT[v], sep = "")), design = SI, na.rm = TRUE), silent = TRUE)
              if (is.numeric(x[1])) {
                E <- EDATA[0, ]
                E[1, ]$geolevel1 <- k
                E[1, ]$year <- y
                E[1, ]$agecat <- a
                E[1, ]$sex <- s
                E[1, ]$variable <- E_OUT[v]
                E[1, c("est")] <- EST[1]
                E[1, c("lb", "ub")] <- confint(EST)
                E[1, c("se")] <- sqrt(attr(EST, "var"))
                E[1, ]$weights <- "Interview"
                EDATA <- rbind(EDATA, E)
              }
              x <- try(EST <- svymean(as.formula(paste("~", E_OUT[v], sep = "")), design = SR, na.rm = TRUE), silent = TRUE)
              if (is.numeric(x[1])) {
                E <- EDATA[0, ]
                E[1, ]$geolevel1 <- k
                E[1, ]$year <- y
                E[1, ]$agecat <- a
                E[1, ]$sex <- s
                E[1, ]$variable <- E_OUT[v]
                E[1, c("est")] <- EST[1]
                E[1, c("lb", "ub")] <- confint(EST)
                E[1, c("se")] <- sqrt(attr(EST, "var"))
                E[1, ]$weights <- "Risk"
                EDATA <- rbind(EDATA, E)
              }
            }
          }
        }
        cat("\n")
        end_time <- Sys.time()
        print(end_time - start_time)
      }
    }
  }
}

if (SAVETEMP) {
  EDATA_C <- EDATA
  save(EDATA_C, file = paste(OUT, "/EDATA_C.RData", sep = ""))
}

for (k in unique(MDATA$geolevel1_name)) {
  for (y in unique(MDATA$year)) {
    for (a in unique(MDATA$agecat2)) {
      for (s in unique(MDATA$sex)) {
        cat(paste("---- Geolevel1 = ", k, ", Year = ", y, ", Agecat2 = ", a, "\n", sep = ""))
        SI <- subset(SDATAI, geolevel1_name == k & year == y & agecat2 == a & sex == s)
        SR <- subset(SDATAR, geolevel1_name == k & year == y & agecat2 == a & sex == s)
        if (nrow(SI$cluster) > 0) {
          for (v in c(1:length(E_OUT))) {
            cat(paste(E_OUT[v], ", ", sep = ""))
            if (E_TYPE[v] == "b") {
              x <- try(EST <- svyciprop(as.formula(paste("~", E_OUT[v], sep = "")), design = SI, method = "logit", na.rm = TRUE), silent = TRUE)
              if (is.numeric(x[1])) {
                E <- EDATA[0, ]
                E[1, ]$geolevel1 <- k
                E[1, ]$year <- y
                E[1, ]$agecat <- a
                E[1, ]$sex <- s
                E[1, ]$variable <- E_OUT[v]
                E[1, c("est")] <- as.numeric(EST)
                E[1, c("lb", "ub")] <- attr(EST, "ci")
                E[1, c("se")] <- (E[1, ]$ub - E[1, ]$lb) / (2 * 1.96)
                E[1, ]$weights <- "Interview"
                EDATA <- rbind(EDATA, E)
              }
              x <- try(EST <- svyciprop(as.formula(paste("~", E_OUT[v], sep = "")), design = SR, method = "logit", na.rm = TRUE), silent = TRUE)
              if (is.numeric(x[1])) {  
                E <- EDATA[0, ]
                E[1, ]$geolevel1 <- k
                E[1, ]$year <- y
                E[1, ]$agecat <- a
                E[1, ]$sex <- s
                E[1, ]$variable <- E_OUT[v]
                E[1, c("est")] <- as.numeric(EST)
                E[1, c("lb", "ub")] <- attr(EST, "ci")
                E[1, c("se")] <- (E[1, ]$ub - E[1, ]$lb) / (2 * 1.96)
                E[1, ]$weights <- "Risk"
                EDATA <- rbind(EDATA, E)
              }
            } else if ((E_TYPE[v] == "c")) {
              x <- try(EST <- svymean(as.formula(paste("~", E_OUT[v], sep = "")), design = SI, na.rm = TRUE), silent = TRUE)
              if (is.numeric(x[1])) {
                E <- EDATA[0, ]
                E[1, ]$geolevel1 <- k
                E[1, ]$year <- y
                E[1, ]$agecat <- a
                E[1, ]$sex <- s
                E[1, ]$variable <- E_OUT[v]
                E[1, c("est")] <- EST[1]
                E[1, c("lb", "ub")] <- confint(EST)
                E[1, c("se")] <- sqrt(attr(EST, "var"))
                E[1, ]$weights <- "Interview"
                EDATA <- rbind(EDATA, E)
              }
              x <- try(EST <- svymean(as.formula(paste("~", E_OUT[v], sep = "")), design = SR, na.rm = TRUE), silent = TRUE)
              if (is.numeric(x[1])) {
                E <- EDATA[0, ]
                E[1, ]$geolevel1 <- k
                E[1, ]$year <- y
                E[1, ]$agecat <- a
                E[1, ]$sex <- s
                E[1, ]$variable <- E_OUT[v]
                E[1, c("est")] <- EST[1]
                E[1, c("lb", "ub")] <- confint(EST)
                E[1, c("se")] <- sqrt(attr(EST, "var"))
                E[1, ]$weights <- "Risk"
                EDATA <- rbind(EDATA, E)
              }
            }
          }
        }
        cat("\n")
      }
    }
  }
}

# ADD COUNTRY 

EDATA$country <- ""
EDATA[EDATA$geolevel1 %in% GEOSA, ]$country <- "South Africa"
EDATA[EDATA$geolevel1 %in% GEOEN, ]$country <- "England"

EDATA_2 <- EDATA

if (SAVETEMP) {
  EDATA_D <- EDATA
  save(EDATA_D, file = paste(OUT, "/EDATA_D.RData", sep = ""))
}

##########################################################################################################################################################################
# CONSOLIDATE                                                                                                                                                            #
##########################################################################################################################################################################

EDATA <- rbind(EDATA_1, EDATA_2)

# ADD INVERSE VARIANCE WEIGHTS

EDATA$ivw <- 1/EDATA$se^2

##########################################################################################################################################################################
# SAVE                                                                                                                                                                   #
##########################################################################################################################################################################

save(EDATA, file = paste(OUT,"/EDATA.RData", sep = ""))
save(E_DESIGN, E_SUBSET, 
     E_SOCIO, E_LIFESTYLE, E_DIAGNOSES, E_MED, E_ANTHRO, E_LAB, E_SCORE,
     V_SOCIO, V_LIFESTYLE, V_DIAGNOSES, V_MED, V_ANTHRO, V_LAB, V_SCORE,
     file = paste(OUT, "/EVARS.RData", sep = "")
)

