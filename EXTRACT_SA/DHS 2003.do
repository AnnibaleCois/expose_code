******************************************************************************************************************************************************
* EXPOSE - DATA EXTRACTION                                                                                                                           *
* South Africa Demographic and Health Survey 2003 (DHS 2003)                                                                                         *
* Annibale Cois (acois@sun.ac.za) & Kafui Adjaye-Gbewonyo (k.adjayegbewonyo@greenwich.ac.uk)                                                         *
* Version 1.0                                                                                                                                        *
******************************************************************************************************************************************************

clear
set more off

******************************************************************************************************************************************************
* LOCATION OF FILES AND FOLDERS                                                                                                                      * 
******************************************************************************************************************************************************

* SOURCE FILES
global DATASET_1 "$BASEDIR/DHS/Datafiles/hholdout.dta"         // HOUSEHOLD
global DATASET_2 "$BASEDIR/DHS/Datafiles/adultout.dta"         // ADULT HEALTH 
global DATASET_3 "$BASEDIR/DHS/Datafiles/personsout.dta"       // PERSONS 
global AUXILIARY_1 "$AUX/Geocoding/DHS_2001_MATCH.dta"         // GEOGRAPHICAL RECODING (MATCH MUNICIPALITIES WITH DISTRCT IN 2001)  

******************************************************************************************************************************************************
* EXTRACTION                                                                                                                                         * 
******************************************************************************************************************************************************

// HOUSEHOLD 

use "$DATASET_1", clear       

encode (HHID), gen(hhid)
label var hhid "Household ID"

gen rev = strreverse(HHID)
gen iid_3 = real(strreverse(substr(rev,1,2)))
gen iid_2 = real(strreverse(substr(rev,3,2)))
gen iid_1 = real(strreverse(substr(rev,5,.)))

* Socioeconomic
rename HV206 ass_elec
label var ass_elec "Assets: electricity"
label val ass_elec vyesno

* Save termporary
keep iid_1 iid_2 iid_3 hhid ass_elec
save "$TEMP/TEMP_1.dta", replace

// ADULT HEALTH

use "$DATASET_2" , clear     

* Administrative 
rename QINTD intd
label var intd "Day of interview"
rename QINTM intm
label var intm "Month of interview"
rename QINTY inty
label var inty "Year of interview"
rename QHCLUST psu
label var psu "Primary Sampling Unit"
egen stratum = group(QHPROV QHTYPE)
label var stratum "Stratum"
gen aweight = QWEIGHT
label var aweight "Sampling weight - Adult Questionnaire"
gen hweight = QHWEIGHT
label var hweight "Sampling weight - Household Questionnaire"

* Geographic
rename QHPROV prov2001
label var prov2001 "Province (2001 boundaries)"
label val prov2001 vprov2001

   * Recover municipalities codes 
replace QHDIST = QHDIST/10 
replace QHDIST = prov2001*100 + QHDIST   
rename QHDIST mn_pr_c

merge m:1 mn_pr_c using "$AUXILIARY_1"
keep if _merge == 3
drop _merge

rename dc_pr_c dist2001
label var dist2001 "District (2001 boundaries)"
label val dist2001 vdist2001

rename QHTYPE geotype2 
label var geotype2 "Geotype (urban/rural)"
label val geotype2 vgeotype2

* Demographic
rename sex sex
label var sex "Sex"
label val sex vsex
rename age age
label var age "Age [years]"
recode race (1=1)(2=2)(3=4)(4=3)(5=.)
label var race "Population group"
label val race vrace
rename QHMEMBER hsize 
label var hsize "Household size"

* Socioeconomic
recode educ (0=0)(1/6=1)(7=2)(8/11=3)(12=4)(13/15=5)(98=.), gen(edu1)
label var edu1 "Education (6 categories)"
label val edu1 vedu1
recode edu1 (0=0)(1=1)(2=2)(3=3)(4/5=4)(6=4), gen(edu2)
label var edu2 "Education (5 categories)"
label val edu2 vedu2
recode QA140 (1=1)(2=0), gen(emp)
label var emp "Employment status"
label val emp vemp
recode QH28 (11=1)(12=2)(13=3)(61 = 4)(21/31=5)(51 = 6)(41/45 = 7)(71/96=9999), gen(water)
label var water "Source of drinking water"
label val water vwater
recode QH30 (11/12 = 1)(22=2)(21=3)(31 = 4)(96=9999), gen(toilet)
label var toilet "Toilet facilities"
label val toilet vtoilet
recode QH31 (1=1)(2=0), gen(sharedtoilet)
label var sharedtoilet "Shared toilet facility"
label val sharedtoilet vyesno
recode QH39 (11=1) (34=2)(35=3)(33=4)(21/31=5)(32=6)(96=9999), gen(floormaterial)
label var floormaterial "Floor material" 
label val floormaterial vfloormaterial
recode QH40 (12=1)(13=2)(21=3)(11=4)(22/31=5)(96=9999), gen(wallmaterial) 
label var wallmaterial "Wall material"
label val wallmaterial vwallmaterial
recode QH35A (1=1)(2=2)(3=3)(4=4)(6=5)(7=6), gen(cookingfuel)
label var cookingfuel "Main cooking fuel"
label val cookingfuel vcookingfuel
recode QH35B (1=1)(2=2)(3=3)(4=4)(6=5)(7=6)(96=9999), gen(heatingfuel)
label var heatingfuel "Main heating fuel"
label val heatingfuel vheatingfuel

*Generating new indicators for cooking fuel, with 1 for main fuel and missing for all else and 0 for none, for harmonisation with 1998 DHS
tabulate cookingfuel, gen (cook)
rename cook1 cook_elec
replace cook_elec=. if cook_elec==0
rename cook2 cook_gas
replace cook_gas=. if cook_gas==0
rename cook3 cook_par
replace cook_par=. if cook_par==0
rename cook4 cook_coal
replace cook_coal=. if cook_coal==0
rename cook5 cook_wood
replace cook_wood=. if cook_wood==0
rename cook6 cook_dung
replace cook_dung=. if cook_dung==0
label var cook_elec "Cooking fuel: Electricity"
label var cook_gas "Cooking fuel: Gas"
label var cook_par "Cooking fuel: Paraffin" 
label var cook_wood "Cooking fuel: Wood"
label var cook_coal "Cooking fuel: Coal"
label var cook_dung "Cooking fuel: Animal dung"

rename QH36 totrooms
label var totrooms "Number of rooms"
recode QH32A (1=1)(2=0), gen(ass_radio)
label var ass_radio "Assets: radio"
label val ass_radio vyesno
recode QH32B (1=1)(2=0), gen(ass_tv)
label var ass_tv "Assets: TV"
label val ass_tv vyesno
recode QH32D (1=1)(2=0), gen(ass_fridge)
label var ass_fridge "Assets: fridge"
label val ass_fridge vyesno
recode QH41A (1=1)(2=0), gen(ass_bicycle)
label var ass_bicycle "Assets: bicycle"
label val ass_bicycle vyesno
recode QH41B (1=1)(2=0), gen(ass_motorcycle)
label var ass_motorcycle "Assets: motorcycle"
label val ass_motorcycle vyesno
recode QH41C (1=1)(2=0), gen(ass_car_truck)
label var ass_car_truck "Assets: car, truck"
label val ass_car_truck vyesno
recode QH32E (1=1)(2=0), gen(ass_phone)
label var ass_phone "Assets: telephone"
label val ass_phone vyesno
recode QH32F (1=1)(2=0), gen(ass_cellphone)
label var ass_cellphone "Assets: cellphone"
label val ass_cellphone vyesno
recode QH32C (1=1)(2=0), gen(ass_computer)
label var ass_computer "Assets: computer"
label val ass_computer vyesno
recode QH41D (1=1)(2=0), gen(ass_donkey_horse)
label var ass_donkey_horse "Assets: donkey, horse"
label val ass_donkey_horse vyesno
recode QH41E (1=1)(2=0), gen(ass_sheep_cattle)
label var ass_sheep_cattle "Assets: sheep, cattle"
label val ass_sheep_cattle vyesno
recode QH27 (11=1)(12=4)(13=3)(14=2)(15=5)(16=6)(17=7)(18=8), gen(dwelling)
label var dwelling "Dwelling type"
label val dwelling vdwelling
* Behavioural
recode QA36 (2=0)(1=1), gen(smokstatus) 
replace smokstatus = 2 if (QA33A == 1)  
label var smokstatus  "Smoking status"
label val smokstatus vsmokstatus
recode smokstatus (2=1)(0/1=0)(.=.), gen(currsmok)
label var currsmok "Current smoking"
label val currsmok vyesno
recode QA42A (2=0)(1=1), gen(alcstatus)
replace alcstatus = 2 if (QA42B == 1)  
label var alcstatus  "Alcohol use status"
label val alcstatus valcstatus
recode alcstatus (2=1)(0/1=0)(.=.), gen(curralc)
label var curralc "Current drinking"
label val curralc vyesno
egen alcavg = rowtotal(QA44B1 QA44B2 QA44B3 QA44B4 QA44B5 QA44B6 QA44B7) 
replace alcavg = alcavg/7*12
label var alcavg "Average alcohol consumpion [g/d]"
recode QA43 (1=6)(2=3)(3=2)(4=0.5), gen(alcfreq)
label var alcfreq "Number drinking days per week"
recode QA44A (98=.), gen(alcqnt)
label var alcqnt "Number of drinks per drinking occasion"

	* GPAQ (coding as per manual)                                                  
		* Impute items according to skip patterns 
replace QA19A=2 if QA18<=3 | QA18==5 
replace QA19B=0 if QA18<=3 | QA18==5 
replace QA19CH=0 if QA18<=3 | QA18==5 
replace QA19CM=0 if QA18<=3 | QA18==5 	
replace QA20A=2 if QA18<=3 | QA18==5  
replace QA20B=0 if QA18<=3 | QA18==5 
replace QA20CH=0 if QA18<=3 | QA18==5 
replace QA20CM=0 if QA18<=3 | QA18==5  
replace QA19B=0 if QA19A==2
replace QA19CH=0 if QA19A==2
replace QA19CM=0 if QA19A==2

replace QA20B=0 if QA20A==2
replace QA20CH=0 if QA20A==2
replace QA20CM=0 if QA20A==2

replace QA22B=0 if QA22A==2
replace QA22CH=0 if QA22A==2
replace QA22CM=0 if QA22A==2

replace QA24A=2 if QA23==2 
replace QA24B=0 if QA23==2 
replace QA24B=0 if QA24A==2
replace QA24CH=0 if QA23==2 
replace QA24CM=0 if QA23==2 

replace QA25A=2 if QA23==2 
replace QA25B=0 if QA23==2 
replace QA25B=0 if QA25A==2 
replace QA25CH=0 if QA23==2 
replace QA25CM=0 if QA23==2 

 	* Clean missing data in minutes/hours fields 
egen M1 = rowmiss(QA19CH QA19CM)  
egen M2 = rowmiss(QA20CH QA20CM)  
egen M3 = rowmiss(QA22CH QA22CM)  
egen M4 = rowmiss(QA24CH QA24CM)  
egen M5 = rowmiss(QA25CH QA25CM)       
replace QA19CH=0 if QA19CH>=. 
replace QA19CM=0 if QA19CM>=. 
replace QA20CH=0 if QA20CH>=. 
replace QA20CM=0 if QA20CM>=. 
replace QA22CH=0 if QA22CH>=. 
replace QA22CM=0 if QA22CM>=. 
replace QA24CH=0 if QA24CH>=. 
replace QA24CM=0 if QA24CM>=. 
replace QA25CH=0 if QA25CH>=. 
replace QA25CM=0 if QA25CM>=. 

replace QA19CH=. if M1==2
replace QA19CM=. if M1==2
replace QA20CH=. if M2==2
replace QA20CM=. if M2==2
replace QA22CH=. if M3==2
replace QA22CM=. if M3==2
replace QA24CH=. if M4==2
replace QA24CM=. if M4==2
replace QA25CH=. if M5==2
replace QA25CM=. if M5==2
		* Clean	 
replace QA19B=. if QA19B>7
replace QA20B=. if QA20B>7
replace QA22B=. if QA22B>7
replace QA24B=. if QA24B>7
replace QA25B=. if QA25B>7
		* Recode variables
rename QA19B WVIG_FREQ
gen WVIG_DUR = QA19CH*60+QA19CM
rename QA20B WMOD_FREQ
gen WMOD_DUR = QA20CH*60+QA20CM
rename QA22B TRA_FREQ
gen TRA_DUR = QA22CH*60+QA22CM
rename QA24B NVIG_FREQ
gen NVIG_DUR = QA24CH*60+QA24CM
rename QA25B NMOD_FREQ
gen NMOD_DUR = QA25CH*60+QA25CM	 	
		* GPAQ		
gen D1 = WVIG_FREQ*WVIG_DUR*8 
gen D2 = WMOD_FREQ*WMOD_DUR*4
gen D3 = TRA_FREQ*TRA_DUR*4
gen D4 = NVIG_FREQ*NVIG_DUR*8
gen D5 = NMOD_FREQ*NMOD_DUR*8
egen MM = rowmiss (D1 D2 D3 D4 D5)
replace D1 = 0 if D1>=. & MM<5 
replace D2 = 0 if D2>=. & MM<5 
replace D3 = 0 if D3>=. & MM<5 		
replace D4 = 0 if D4>=. & MM<5 		
replace D5 = 0 if D5>=. & MM<5 			
gen gpaq = D1+D2+D3+D4+D5   	   
		* Identify implausible values (duration > 16 for any of the subdomain) 
		* and set the GPAQ to missing     
replace gpaq=. if  (WVIG_DUR>960 | WMOD_DUR>960 | TRA_DUR>960 | NVIG_DUR>960 | NMOD_DUR>960)
label var gpaq "GPAQ [MET minutes per week]"   
egen gpaqcat = cut(gpaq), at(0,600,4000,8000,100000) icodes
replace gpaqcat = gpaqcat + 1
label var gpaqcat "Level of physical activity"
label val gpaqcat vgpaqcat
	* Leisure exercise frequency
egen exercisefreq = rowtotal(NVIG_FREQ NMOD_FREQ)
recode exercisefreq (0=1)(1=2)(2=3)(3/100=4)
replace exercisefreq = 0 if QA23 == 2
label var exercisefreq "Weekly frequency of exercise/leisure time physical activity"
label val exercisefreq vexercisefreq 

* Anthropometric
rename QA50 weight1
label var weight1 "Weight [kg] - reading 1" 
replace weight1 = weight1/10
rename QA51 height1
replace height1 = height1/10
label var height1 "Height [cm] - reading 1"
rename QA53 waist1
replace waist1 = waist1/10
label var waist1 "Waist circumference [cm] - reading 1"
rename QA54 hip1
replace hip1 = hip1/10
label var hip1 "Hip circumference [cm] - reading 1"
rename QA55 sbp1
label var sbp1 "Systolic Blood Pressure [mmHg] - reading 1"
rename QA56 dbp1
label var dbp1 "Systolic Blood Pressure [mmHg] - reading 1"
rename QA57 rhr1
label var rhr1 "Resting Heart Rate [bpm] - reading 1"
rename QA58 sbp2
label var sbp2 "Systolic Blood Pressure [mmHg] - reading 2"
rename QA59 dbp2
label var dbp2 "Systolic Blood Pressure [mmHg] - reading 2"
rename QA60 rhr2
label var rhr2 "Resting Heart Rate [bpm] - reading 2"
rename QA61 sbp3
label var sbp3 "Systolic Blood Pressure [mmHg] - reading 3"
rename QA62 dbp3
label var dbp3 "Systolic Blood Pressure [mmHg] - reading 3"
rename QA63 rhr3
label var rhr3 "Resting Heart Rate [bpm] - reading 3"

* Health status
rename QA10B self_health
label var self_health "Self-perception of health status"
label val self_health vselfhealth
recode QA11A (1=1) (2=0) (8=.), gen(diag_hbp)
label var diag_hbp "Diagnosis: hypertension" 
label val diag_hbp vyesno
recode QA11B (1=1) (2=0) (8=.), gen(diag_isch)
label var diag_isch "Diagnosis: heart attack/angina"	
label val diag_isch vyesno
recode QA11C (1=1) (2=0) (8=.), gen(diag_stroke)
label var diag_stroke "Diagnosis: stroke"
label val diag_stroke vyesno
recode QA11D (1=1) (2=0) (8=.), gen(diag_chol)
label var diag_chol "Diagnosis: hypercholesterolaemia"
label val diag_chol vyesno
recode QA11E (1=1) (2=0) (8=.), gen(diag_diab)
label var diag_diab "Diagnosis: diabetes"
label val diag_diab vyesno
recode QA11F (1=1) (2=0) (8=.), gen(diag_emph)
label var diag_emph "Diagnosis: emphysema/bronchitis"  
label val diag_emph vyesno
recode QA11G (1=1) (2=0) (8=.), gen(diag_asth)
label var diag_asth "Diagnosis: asthma"
label val diag_asth vyesno
recode QA11K (1=1) (2=0) (8=.), gen(diag_tb)
label var diag_tb "Diagnosis: tuberculosis"
label val diag_tb vyesno
recode QA11M (1=1) (2=0) (8=.), gen(diag_cancer) 
label var diag_cancer "Diagnosis: cancer" 
label val diag_cancer vyesno
rename bpdrug bpmed_coded

* Medication use: coded from shown medication
label var bpmed_coded "Current use of antihypertensive medication - coded"
gen diabmed_coded = 0
local code A10
foreach v in 01 02 03 04 05 06 07 08 09 10 11 {
  replace diabmed_coded = 1 if substr(QA16DC_`v',1,3) == "`code'" 
}
label var diabmed_coded "Current use of diabetes medication - coded"
label val diabmed_coded vyesno
gen cholmed_coded = 0
local code C10
foreach v in 01 02 03 04 05 06 07 08 09 10 11 {
  replace cholmed_coded = 1 if substr(QA16DC_`v',1,3) == "`code'" 
}
label var cholmed_coded "Current use of cholesterol medication - coded"
label val cholmed_coded vyesno
gen ischmed_coded = 0
local code C01D
foreach v in 01 02 03 04 05 06 07 08 09 10 11 {
  replace ischmed_coded = 1 if substr(QA16DC_`v',1,4) == "`code'" 
}
local code C01E
foreach v in 01 02 03 04 05 06 07 08 09 10 11 {
  replace ischmed_coded = 1 if substr(QA16DC_`v',1,4) == "`code'" 
}
label var ischmed_coded "Current use of angina/hearth attack medication - coded"
label val ischmed_coded vyesno
gen asthmed_coded = 0
local code R
foreach v in 01 02 03 04 05 06 07 08 09 10 11 {
  replace asthmed_coded = 1 if substr(QA16DC_`v',1,1) == "`code'" 
}
label var asthmed_coded "Current use of asthma, emphysema or bronchitis medication - coded"
label val asthmed_coded vyesno
gen tbmed_coded  = 0
local code J04A
foreach v in 01 02 03 04 05 06 07 08 09 10 11 {
  replace tbmed_coded = 1 if substr(QA16DC_`v',1,4) == "`code'" 
}
label var tbmed_coded "Current use of tb medication - coded"
label val tbmed_coded vyesno 
gen strokemed_coded = 0
local code C04
foreach v in 01 02 03 04 05 06 07 08 09 10 11 {
  replace strokemed_coded = 1 if substr(QA16DC_`v',1,3) == "`code'" 
}
label var strokemed_coded "Current use of stroke medication - coded"
label val strokemed_coded vyesno

* Medication use: self-reported
egen bpmed = anymatch(QA16DB_01 QA16DB_02 QA16DB_03 QA16DB_04 QA16DB_05 QA16DB_06 QA16DB_07 QA16DB_08 QA16DB_09 QA16DB_10 QA16DB_11), values(1)  
label var bpmed "Current use of antihypertensive medication - self"
label val bpmed vyesno
egen diabmed = anymatch(QA16DB_01 QA16DB_02 QA16DB_03 QA16DB_04 QA16DB_05 QA16DB_06 QA16DB_07 QA16DB_08 QA16DB_09 QA16DB_10 QA16DB_11), values(5)  
label var diabmed "Current use of diabetes medication - self"
label val diabmed vyesno
egen cholmed = anymatch(QA16DB_01 QA16DB_02 QA16DB_03 QA16DB_04 QA16DB_05 QA16DB_06 QA16DB_07 QA16DB_08 QA16DB_09 QA16DB_10 QA16DB_11), values(4)   
label var cholmed "Current use of cholesterol medication - self"
label val cholmed vyesno
egen ischmed = anymatch(QA16DB_01 QA16DB_02 QA16DB_03 QA16DB_04 QA16DB_05 QA16DB_06 QA16DB_07 QA16DB_08 QA16DB_09 QA16DB_10 QA16DB_11), values(2)  
label var ischmed "Current use of angina/hearth attack medication - self"
label val ischmed vyesno
egen asthmed =  anymatch(QA16DB_01 QA16DB_02 QA16DB_03 QA16DB_04 QA16DB_05 QA16DB_06 QA16DB_07 QA16DB_08 QA16DB_09 QA16DB_10 QA16DB_11), values(6 7)  
label var asthmed "Current use of asthma, emphysema or bronchitis medication - self"
label val asthmed vyesno
egen tbmed = anymatch(QA16DB_01 QA16DB_02 QA16DB_03 QA16DB_04 QA16DB_05 QA16DB_06 QA16DB_07 QA16DB_08 QA16DB_09 QA16DB_10 QA16DB_11), values(10)   
label var tbmed "Current use of tb medication - self"
label val tbmed vyesno 
egen strokemed =  anymatch(QA16DB_01 QA16DB_02 QA16DB_03 QA16DB_04 QA16DB_05 QA16DB_06 QA16DB_07 QA16DB_08 QA16DB_09 QA16DB_10 QA16DB_11), values(3)  
label var strokemed "Current use of stroke medication - self"
label val strokemed vyesno

* Healthcare Utilisation
recode QA5 (1=1)(2=0), gen(medaid) 
label var medaid "Covered by medical insurance"  
label val medaid vyesno
gen hcare1mo_public = 0
replace hcare1mo_public = 1 if (QA12_01 == 1 | QA12_02 == 1)
label var hcare1mo_public "Healthcare last month: public hospital/clinic"
label val hcare1mo_public vyesno
gen hcare1mo_private = 0
replace hcare1mo_private = 1 if (QA12_03 == 1 | QA12_04 == 1)
label var hcare1mo_private "Healthcare last month: private hospital/clinic/doctor"
label val hcare1mo_private vyesno
gen hcare1mo_chem_nurse = 0
replace hcare1mo_chem_nurse = 1 if (QA12_05 == 1)
label var hcare1mo_chem_nurse "Healthcare last month: chemist/pharmacist/nurse" 
label val hcare1mo_chem_nurse vyesno
gen hcare1mo_trad = 0
replace hcare1mo_trad = 1 if (QA13_05 == 1 | QA12_07 == 1)
label var hcare1mo_trad "Healthcare last month: traditional/faith healer"
label val hcare1mo_trad vyesno
gen hcare1mo_other = 0
replace hcare1mo_other = 1 if (QA12_08 == 1 | QA12_09 == 1 | QA12_10 == 1 | QA12_11 == 1 | QA12_12 == 1)
label var hcare1mo_other "Healthcare last month: other" 
label val hcare1mo_other vyesno
gen hcare1mo = 0
replace hcare1mo = 1 if hcare1mo_public == 1 | hcare1mo_private == 1 | hcare1mo_chem_nurse == 1 | hcare1mo_trad == 1 | hcare1mo_other == 1
label var hcare1mo "Healthcare consultations last month"
label val hcare1mo vyesno

* Environmental
recode QH42 (11=1)(12/16=0), gen(refuseremoved)
label var refuseremoved "Refuse removed weekly by local authorities"
label val refuseremoved vyesno

* Variables for asset index 
	* Cooking fuel
tab QH35A, gen(w_DHS2003_cookfuel)
drop w_DHS2003_cookfuel1
	* heating fuel
tab QH35B, gen(w_DHS2003_heathfuel)
drop w_DHS2003_heathfuel1
	* People per room
gen w_DHS2003_troom = totrooms/hsize
	* Floor material
tab QH39, gen(w_DHS2003_flo)
drop w_DHS2003_flo1
	* Wall material
tab QH40, gen(w_DHS2003_wal)
drop w_DHS2003_wal1
    * Type of dwelling
tab	QH27, gen(w_DHS2003_dwelling)
drop w_DHS2003_dwelling1
	* Water source
tab QH28, gen(w_DHS2003_wat)
drop w_DHS2003_wat1
	* Sanitation
tab QH30, gen(w_DHS2003_san)
drop w_DHS2003_san1
	* Refuse disposal
tab QH42, gen(w_DHS2003_refusedisp)
drop w_DHS2003_refusedisp1
	* Durable Items 
gen w_DHS2003_ass_radio = ass_radio
gen w_DHS2003_ass_tv = ass_tv
gen w_DHS2003_ass_fridge = ass_fridge
gen w_DHS2003_ass_bicycle = ass_bicycle
gen w_DHS2003_ass_motorcycle = ass_motorcycle
gen w_DHS2003_ass_car_truck = ass_car_truck
gen w_DHS2003_ass_phone = ass_phone
gen w_DHS2003_ass_cellphone = ass_cellphone
gen w_DHS2003_ass_computer = ass_computer
gen w_DHS2003_ass_donkey_horse = ass_donkey_horse
gen w_DHS2003_ass_sheep_cattle = ass_sheep_cattle

* Identifiers 
rename idnumber id
gen iid_1 = psu
gen iid_2 = QHSTAND
gen iid_3 = QHNUMBER

* Save temporary
#delimit ;
keep id iid_1 iid_2 iid_3
intd intm inty psu stratum aweight hweight prov2001 dist2001 geotype2 sex age race sex edu1 edu2 emp dwelling water toilet floormaterial wallmaterial curralc
cookingfuel heatingfuel totrooms ass_radio ass_tv ass_computer ass_phone ass_cellphone ass_fridge ass_bicycle ass_motorcycle ass_car_truck 
ass_donkey_horse ass_sheep_cattle smokstatus currsmok alcstatus alcavg hsize self_health gpaq gpaqcat exercisefreq weight1 height1 waist1 
hip1 sbp1 dbp1 rhr1 sbp2 dbp2 rhr2 sbp3 dbp3 rhr3 diag_hbp diag_isch diag_stroke diag_chol diag_diab diag_emph diag_asth diag_tb diag_cancer  
bpmed_coded medaid bpmed diabmed cholmed ischmed asthmed tbmed strokemed hcare1mo hcare1mo_public hcare1mo_private hcare1mo_chem_nurse hcare1mo_trad 
hcare1mo_other refuseremoved diabmed_coded cholmed_coded ischmed_coded asthmed_coded tbmed_coded strokemed_coded hcare1mo sharedtoilet   
alcfreq alcqnt cook_elec cook_gas cook_par cook_wood cook_coal cook_dung w_*;
#delimit cr
save "$TEMP/TEMP_2.dta", replace

// PERSONS  
use "$DATASET_3", clear 
keep SH21 HVIDX HHID HV009
encode HHID, gen(hhid)
recode SH21 (1=1)(2=0)
reshape wide SH21, i(hhid) j(HVIDX)
egen zeros = anycount(SH211- SH2122), values(0)
egen ones = anycount(SH211- SH2122), values(1)
gen recgrant = .
replace recgrant = 1 if ones > 0 
replace recgrant = 0 if (zeros == HV009)

* Add identifiers 
gen rev = strreverse(HHID)
gen iid_3 = real(strreverse(substr(rev,1,2)))
gen iid_2 = real(strreverse(substr(rev,3,2)))
gen iid_1 = real(strreverse(substr(rev,5,.)))

* Save temporary
keep iid_1 iid_2 iid_3 recgrant
save "$TEMP/TEMP_3.dta", replace

******************************************************************************************************************************************************
* CONSOLIDATE                                                                                                                                        * 
******************************************************************************************************************************************************

* Merge datasets
use "$TEMP/TEMP_2.dta", clear  
merge m:1 iid_1 iid_2 iid_3 using ".\TEMP\TEMP_1.dta"
keep if _merge == 3
drop _*
merge m:1 iid_1 iid_2 iid_3 using ".\TEMP\TEMP_3.dta"
keep if _merge == 3
drop _*

* Add derived
gen ntotrooms = totrooms/hsize
label var ntotrooms "People per room"

* Delete observations with missing sampling weights
keep if aweight <. & hweight <. & aweight > 0 & hweight > 0

* Delete observations with missing data on sex and/or age 
keep if age <. & sex <. 

* Delete identifiers 
drop id iid_1 iid_2 iid_3

* Add individual identifier
gen pid = _n
label var pid "Individual ID"

* Add source identifier
gen source = "DHS 2003"
label var source "Source"

* Rescale sampling weights to sum to the sample size
sum aweight
local wmean = r(mean)
replace aweight = aweight/`wmean'

* Save temporary
save "$TEMP/TEMP_4.dta", replace

******************************************************************************************************************************************************
* ANCHOR POINTS FOR COMPARATIVE WEALTH INDEX                                                                                                         * 
******************************************************************************************************************************************************

use "$DATASET_3", clear

recode HV108 (0/6=0) (7/15=1) (98=.), gen(primaryed)	 
label var primaryed "Completed primary school"
label values primaryed vyesno
tab primaryed

collapse (max) primaryed_hh=primaryed (count) edunum=primaryed (count) hsize=HV001, by(HHID)
label var primaryed_hh "A household member completed primary school"
 * Recoding to missing if no household member has completed primary school but some household members have missing education 
replace primaryed_hh=. if primaryed_hh==0 & edunum < hsize 
label values primaryed_hh vyesno
rename HHID hhid

* Save temporary
save "$TEMP/TEMP_5A.dta", replace

use "$TEMP/TEMP_4.dta", clear
duplicates drop hhid, force
rename hhid hhid_num
decode hhid_num, gen(hhid)
merge 1:1 hhid using "$TEMP/TEMP_5A.dta"
keep if _merge == 3
drop _merge
drop hhid
rename hhid_num hhid

gen edu_deprived=.
replace edu_deprived=1 if primaryed_hh==0
replace edu_deprived=0 if primaryed_hh==1
label var edu_deprived "No household member has completed primary school"
label values edu_deprived vyesno

* Anchoring points (poverty)

* Unimproved sanitation
recode toilet (1/2=0) (3/9999=1), gen(unimp_toilet)
replace unimp_toilet=1 if sharedtoilet==1
label values unimp_toilet vyesno
label variable unimp_toilet "Unimproved sanitation"
tab unimp_toilet

* Unimproved water
recode water (1/3=0) (5/6=0) (4=1) (7/9999=1), gen(unimp_water)
label values unimp_water vyesno
label variable unimp_water "Unimproved water source"

* Solid cooking fuel
recode cookingfuel (1/3=0) (4/9999=1), gen(unimp_cooking)
label values unimp_cooking vyesno
label var unimp_cooking "Use of solid (unimproved) cooking fuels"
tab unimp_cooking

egen depnum = anycount(edu_deprived unimp_toilet unimp_water unimp_cooking), values(1)

gen dep1plus=.
replace dep1plus=1 if depnum==1 | depnum==2 | depnum==3 | depnum==4
replace dep1plus=0 if depnum==0
label var dep1plus "Deprived in one or more basic needs"
label values dep1plus vyesno

gen dep2plus=.
replace dep2plus=1 if depnum==2 | depnum==3 | depnum==4
replace dep2plus=0 if depnum==0 | depnum==1
label var dep2plus "Deprived in two or more basic needs"
label values dep2plus vyesno

gen dep3plus=.
replace dep3plus=1 if depnum==3 | depnum==4
replace dep3plus=0 if depnum==0 | depnum==1 | depnum==2
label var dep3plus "Deprived in three or more basic needs"
label values dep3plus vyesno

gen dep4plus=.
replace dep4plus=1 if depnum==4
replace dep4plus=0 if depnum==0 | depnum==1 | depnum==2 | depnum==3
label var dep4plus "Deprived in four basic needs"
label values dep4plus vyesno

keep hhid edu_deprived unimp_toilet unimp_water unimp_cooking dep1plus dep2plus dep3plus dep4plus

* Save temporary
save "$TEMP/TEMP_5B.dta", replace 

******************************************************************************************************************************************************
* SAVE & ERASE TEMPORARY FILES                                                                                                                       * 
******************************************************************************************************************************************************

use "$TEMP/TEMP_4.dta", clear
merge m:1 hhid using "$TEMP/TEMP_5B.dta"
keep if _merge == 3
drop _merge

* Delete value labels
label drop _all
 
* Label the datset
label data "DHS 2003 - Core Variables - $S_DATE" 
 
save "$TEMP/DHS2003.dta", replace
erase "$TEMP/TEMP_1.dta"
erase "$TEMP/TEMP_2.dta"
erase "$TEMP/TEMP_3.dta"
erase "$TEMP/TEMP_4.dta"
erase "$TEMP/TEMP_5A.dta"
erase "$TEMP/TEMP_5B.dta"
