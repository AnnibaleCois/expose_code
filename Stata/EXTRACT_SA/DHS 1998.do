******************************************************************************************************************************************************
* EXPOSE - DATA EXTRACTION                                                                                                                           *
* South Africa Demographic and Health Survey 1998 (DHS 1998)                                                                                         *
* Annibale Cois (acois@sun.ac.za) & Kafui Adjaye-Gbewonyo (k.adjayegbewonyo@greenwich.ac.uk)                                                         *
* Version 1 - September 2022                                                                                                                         *
******************************************************************************************************************************************************

clear
set more off

******************************************************************************************************************************************************
* LOCATION OF FILES AND FOLDERS                                                                                                                      *
******************************************************************************************************************************************************

* SOURCE FILES
global DATASET_1 "$BASEDIR/DHS/Datafiles/ZAHR31FL.dta"              // HOUSEHOLD
global DATASET_2 "$BASEDIR/DHS/Datafiles/ZAAH33FL.dta"              // ADULT HEALTH 
global AUXILIARY_1 "$AUX/Geocoding/IPUMS_GEO.dta"                   // GEOGRAPHICAL RECODING (IPUMS MATCHING DATASET) 
global AUXILIARY_2 "$AUX/Geocoding/DHS_1998_MATCH_B.dta"            // GEOGRAPHICAL RECODING (PROJECTIONS ON DISTRCITS BASED ON EA CENTROID) 
global AUXILIARY_3 "$AUX/Geocoding/DHS_1998_MATCH_A.dta"            // GEOGRAPHICAL RECODING (PROJECTIONS ON DISTRCITS BASED ON MD CENTROID) 

******************************************************************************************************************************************************
* EXTRACT                                                                                                                                            * 
******************************************************************************************************************************************************

* HOUSEHOLD 

use "$DATASET_1" , clear     

* Administrative 
gen hweight = hv005
label var hweight "Sampling weight - Household Questionnaire"

* Geographic (Import from IPUMS uniform geocoding)
gen sample = string(71001)
gen str idhshid = sample+hhid
merge 1:1 idhshid using "$AUXILIARY_1", keepusing(geo_za1998 geo_za2016)
keep if _merge == 3
drop _merge
rename geo_za1998 prov1996
label var prov1996 "Province (1996 boundaries)"
label val prov1996 vprov1996
rename geo_za2016 prov2011
label var prov2011 "Province (2011 boundaries)"
label val prov2011 vprov2011

* Demographic 
rename hv009 hsize 
label var hsize "Household size"

* Socioeconomic 
rename sh30a cook_elec 
label var cook_elec "Cooking fuel: Electricity"
label val cook_elec vyesno
rename sh30b cook_gas 
label var cook_gas "Cooking fuel: Gas"
label val cook_gas vyesno
rename sh30c cook_par 
label var cook_par "Cooking fuel: Paraffin" 
label val cook_par vyesno
rename sh30d cook_wood 
label var cook_wood "Cooking fuel: Wood"
label val cook_wood vyesno
rename sh30e cook_coal 
label var cook_coal "Cooking fuel: Coal"
label val cook_coal vyesno
rename sh30f cook_dung 
label var cook_dung "Cooking fuel: Animal dung"
label val cook_dung vyesno
rename sh30x cook_other 
label var cook_other "Cooking fuel: Other" 
label val cook_other vyesno
egen x = rowtotal(sh08_01 sh08_02 sh08_03  sh08_04 sh08_05 sh08_06 sh08_07 sh08_08 sh08_09 sh08_10 sh08_11 sh08_12 sh08_13  sh08_14 sh08_15  ///
                  sh08_16 sh08_17 sh08_18 sh08_19 sh08_20 sh08_21 sh08_22 sh08_23  sh08_24 sh08_25 sh08_26 sh08_27) 
egen y = anycount(sh08_01 sh08_02 sh08_03  sh08_04 sh08_05 sh08_06 sh08_07 sh08_08 sh08_09 sh08_10 sh08_11 sh08_12 sh08_13  sh08_14 sh08_15  /// 
                  sh08_16 sh08_17 sh08_18 sh08_19 sh08_20 sh08_21 sh08_22 sh08_23  sh08_24 sh08_25 sh08_26 sh08_27), values(0)
gen recgrant = . 
replace recgrant = 0 if y == hsize 
replace recgrant = 1 if x > 0 & x <. 
drop x y
label var recgrant "Household received government grant" 
label val recgrant vyesno

* Variables for asset index (1)
	* Cooking fuel
gen w_DHS1998_cook_elec = cook_elec
gen w_DHS1998_cook_gas = cook_gas
gen w_DHS1998_cook_par = cook_par
gen w_DHS1998_cook_wood = cook_wood 
gen w_DHS1998_cook_coal = cook_coal	
gen w_DHS1998_cook_dung = cook_dung 	
	* Grant
gen w_DHS1998_recgrant = recgrant
	* People per room
gen w_DHS1998_ntotroom = hv216/hsize
	* Floor material
tab hv213, gen(w_DHS1998_flo)
drop w_DHS1998_flo1
	* Wall material
tab hv214, gen(w_DHS1998_wal)
drop w_DHS1998_wal1
	* Water source
tab hv201, gen(w_DHS1998_wat)
drop w_DHS1998_wat1
	* Sanitation
tab hv205, gen(w_DHS1998_san)
drop w_DHS1998_san1

* Identifiers 
rename hv001 id_001
rename hv002 id_002
rename hv003 id_003
rename hhid x
encode(x), gen(hhid)
drop x
label var hhid "Household ID"

* Save temporary
keep hhid id_001 id_002 id_003 hweight hsize cook_elec cook_gas cook_par cook_wood cook_coal cook_dung cook_other recgrant prov* w_* 
save "$TEMP/TEMP_1.dta", replace

// ADULT HEALTH

use "$DATASET_2" , clear  

* Administrative 
rename qintd intd
label var intd "Day of interview"
rename qintm intm
label var intm "Month of interview"
rename qinty inty
label var inty "Year of interview"
rename qcluster psu
label var psu "Primary Sampling Unit"
egen stratum = group(qprovin qtype)
label var stratum "Stratum"
gen aweight = qaweight
label var aweight "Sampling weight - Adult Questionnaire"
rename qtype geotype2 
label var geotype2 "Geotype (urban/rural)"
label val geotype2 vgeotype2
label var qeanum "Enumeration area"
label var qdist "Magisterial district (1996)"

* Demographic
rename ahsex sex
label var sex "Sex"
label val sex vsex
rename ah66 age
replace age = . if age == 98
label var age "Age [years]"
rename ah66a race
label var race "Population group"
label val race vrace

* Socioeconomic
recode aheduc (0=0)(1/4=1)(71/72=1)(5=2)(6/9=3)(10=4)(11/13=5)(98=.), gen(edu1)
label var edu1 "Education (6 categories)"
label val edu1 vedu1
recode edu1 (0=0)(1=1)(2=2)(3=3)(4/5=4)(6=4), gen(edu2)
label var edu2 "Education (5 categories)"
label val edu2 vedu2
recode ah39 (1=1)(2=0), gen(emp)
label var emp "Employment status"
label val emp vemp
gen sharedtoilet = .
replace sharedtoilet = 1 if qh28 ==12
replace sharedtoilet = 0 if qh28 ==11
label var sharedtoilet "Shared toilet facility"
label val sharedtoilet vyesno
recode qh28 (11/12=1)(22=3)(21=2)(31=4)(96=9999), gen(toilet)
label var toilet "Toilet facilities"
label val toilet vtoilet
recode qh25 (11=1)(12=2)(13=3)(21=4)(31=5)(41=6)(32=7)(51/96 = 9999), gen(water)
label var water "Source of drinking water"
label val water vwater
recode qh32 (11=1)(31=2)(33=3)(34=4)(21=5)(35=5)(32=6)(96=9999) , gen(floormaterial)
label var floormaterial "Floor material" 
label val floormaterial vfloormaterial
recode qh33 (12=1)(13=2)(21=3)(11=4)(22/31=5)(96=9999),gen(wallmaterial)
label var wallmaterial "Wall material"
label val wallmaterial vwallmaterial
rename qh31 sleeprooms
label var sleeprooms "Number of rooms for sleeping"
recode qh29a (1=1)(2=0), gen(ass_elec)
label var ass_elec "Assets: electricity"
label val ass_elec vyesno
recode qh29b (1=1)(2=0), gen(ass_radio)
label var ass_radio "Assets: radio"
label val ass_radio vyesno
recode qh29c (1=1)(2=0), gen(ass_tv)
label var ass_tv "Assets: TV"
label val ass_tv vyesno
recode qh29e (1=1)(2=0), gen(ass_fridge)
label var ass_fridge "Assets: fridge"
label val ass_fridge vyesno
recode qh35a (1=1)(2=0), gen(ass_bicycle)
label var ass_bicycle "Assets: bicycle"
label val ass_bicycle vyesno
recode qh35b (1=1)(2=0), gen(ass_motorcycle)
label var ass_motorcycle "Assets: motorcycle"
label val ass_motorcycle vyesno
recode qh35c (1=1)(2=0), gen(ass_car_truck)
label var ass_car_truck "Assets: car, truck"
label val ass_car_truck vyesno
recode qh29d (1=1)(2=0), gen(ass_phone)
label var ass_phone "Assets: telephone"
label val ass_phone vyesno
recode qh29f (1=1)(2=0), gen(ass_computer)
label var ass_computer "Assets: computer"
label val ass_computer vyesno
recode qh29g (1=1)(2=0), gen(ass_wmachine)
label var ass_wmachine "Assets: washing machine"
label val ass_wmachine vyesno
recode qh35d (1=1)(2=0), gen(ass_donkey_horse)
label var ass_donkey_horse "Assets: donkey, horse"
label val ass_donkey_horse vyesno
recode qh35e (1=1)(2=0), gen(ass_sheep_cattle)
label var ass_sheep_cattle "Assets: sheep, cattle"
label val ass_sheep_cattle vyesno
recode qh34 (1/3=1)(4=0), gen(foodinsec)
label var foodinsec "Food insecurity"
label val foodinsec vyesno

* Behavioural
recode ah73 (2=0)(1=1), gen(smokstatus) 
replace smokstatus = 2 if (ah79 == 1 | ah79 == 2)  
replace smokstatus = 0 if (ah71 == 2)  
label var smokstatus  "Smoking Status"
label val smokstatus vsmokstatus
recode smokstatus (2=1)(0/1=0)(.=.), gen(currsmok)
label var currsmok "Current smoking"
label val currsmok vyesno
recode ah86 (2=0)(1=1), gen(alcstatus)
replace alcstatus = 2 if (ah87 == 1)  
label var alcstatus  "Alcohol use status"
label val alcstatus valcstatus
recode alcstatus (2=1)(0/1=0)(.=.), gen(curralc)
label var curralc "Current drinking"
label val curralc vyesno
recode ah88 (1=0)(2=1.5)(3=3.5)(4=7.5)(5=2),gen(alcweek)     
recode ah89 (1=0)(2=1.5)(3=3.5)(4=7.5)(5=2),gen(alcwend)     
replace alcweek = alcweek*5
replace alcwend = alcwend*2 
egen alcavg = rowtotal(alcweek alcwend)
replace alcavg = alcavg * 52/365 * 12 
label var alcavg "Average alcohol consumpion [g/d]"
		
* Anthropometric
rename ah96 weight1
replace weight1 = weight1/10
label var weight1 "Weight [kg] - reading 1" 
rename ah97 height1
replace height1 = height1/10
label var height1 "Height [cm] - reading 1"
rename ah98 arm1
replace arm1 = arm1/10
label var arm "Arm circumference [cm] - reading 1"
rename ah99 waist1
replace waist1 = waist1/10
label var waist1 "Waist circumference [cm] - reading 1"
rename ah100 hip1
replace hip1 = hip1/10
label var hip1 "Hip circumference [cm] - reading 1"
rename ah101 sbp1
label var sbp1 "Systolic Blood Pressure [mmHg] - reading 1"
rename ah102 dbp1
label var dbp1 "Diastolic Blood Pressure [mmHg] - reading 1"
rename ah103 rhr1
label var rhr1 "Resting Heart Rate [bpm] - reading 1"
rename ah104 sbp2
label var sbp2 "Systolic Blood Pressure [mmHg] - reading 2"
rename ah105 dbp2
label var dbp2 "Diastolic Blood Pressure [mmHg] - reading 2"
rename ah106 rhr2
label var rhr2 "Resting Heart Rate [bpm] - reading 2"
rename ah107 sbp3
label var sbp3 "Systolic Blood Pressure [mmHg] - reading 3"
rename ah108 dbp3
label var dbp3 "Diastolic Blood Pressure [mmHg] - reading 3"
rename ah109 rhr3
label var rhr3 "Resting Heart Rate [bpm] - reading 3"

* Health status
recode ah09a (1=1) (2=0) (8=.), gen(diag_hbp)
label var diag_hbp "Diagnosis: hypertension"
label val diag_hbp vyesno
recode ah09c (1=1) (2=0) (8=.), gen(diag_isch)
label var diag_isch "Diagnosis: heart attack/angina"
label val diag_isch vyesno
recode ah09e (1=1) (2=0) (8=.), gen(diag_stroke)
label var diag_stroke "Diagnosis: stroke"
label val diag_stroke vyesno
recode ah09g (1=1) (2=0) (8=.), gen(diag_chol)
label var diag_chol "Diagnosis: hypercholesterolaemia"
label val diag_chol vyesno
recode ah09i (1=1) (2=0) (8=.), gen(diag_diab)
label var diag_diab "Diagnosis: diabetes"
label val diag_diab vyesno
recode ah09k (1=1) (2=0) (8=.), gen(diag_emph)
label var diag_emph "Diagnosis: emphysema/bronchitis"
label val diag_emph vyesno
recode ah09m (1=1) (2=0) (8=.), gen(diag_asth)
label var diag_asth "Diagnosis: asthma"
label val diag_asth vyesno
recode ah09o (1=1) (2=0) (8=.), gen(diag_tb)
label var diag_tb "Diagnosis: tuberculosis"
label val diag_tb vyesno
recode ah09q (1=1) (2=0) (8=.), gen(diag_cancer) 
label var diag_cancer "Diagnosis: cancer" 
label val diag_cancer vyesno

* Reproductive health
recode ahpreg (1=1) (2=0) (8=.),gen(currpreg)
replace currpreg=.a if sex == 1
label var currpreg "Currently pregnant" 
label val currpreg vcurrpreg

* Healthcare Utilisation
recode ah04 (1=1)(2=0), gen(medaid) 
drop ah04
label var medaid "Covered by medical insurance" 
label val medaid vyesno
gen hcare1mo_public = 0
replace hcare1mo_public = 1 if (ah01_02 == 1)
label var hcare1mo_public "Healthcare last month: public hospital/clinic"
label val hcare1mo_public vyesno
gen hcare1mo_private = 0
replace hcare1mo_private = 1 if (ah01_03 == 1 | ah01_05 == 1)
label var hcare1mo_private "Healthcare last month: private hospital/clinic/doctor"
label val hcare1mo_private vyesno
gen hcare1mo_chem_nurse = 0
replace hcare1mo_chem_nurse = 1 if (ah01_06 == 1)
label var hcare1mo_chem_nurse "Healthcare last month: chemist/pharmacist/nurse" 
label val hcare1mo_chem_nurse vyesno
gen hcare1mo_trad = 0
replace hcare1mo_trad = 1 if (ah01_07 == 1 | ah01_08 == 1)
label var hcare1mo_trad "Healthcare last month: traditional/faith healer"
label val hcare1mo_trad vyesno
gen hcare1mo_other = 0
replace hcare1mo_other = 1 if (ah01_04 == 1 | ah01_09 == 1 | ah01_10 == 1 | ah01_11 == 1 | ah01_12 == 1 | ah01_01 == 1)
label var hcare1mo_other "Healthcare last month: other" 
label val hcare1mo_other vyesno
gen hcare1mo = 0
replace hcare1mo = 1 if hcare1mo_public == 1 | hcare1mo_private == 1 | hcare1mo_chem_nurse == 1 | hcare1mo_trad == 1 | hcare1mo_other == 1
label var hcare1mo "Healthcare consultations last month"
label val hcare1mo vyesno

* Medication use: coded from shown medication
rename ahmedic bpmed_coded
label var bpmed_coded "Current use of antihypertensive medication - coded" 
label val bpmed_coded vyesno

* Medication use: self-reported
recode ahsick_1 (1=1)(2=0)(8=.), gen(bpmed) 
replace bpmed = 0 if ah46 == 2
label var bpmed "Current use of antihypertensive medication - self"
label val bpmed vyesno
recode ahsick_2 (1=1)(2=0)(8=.), gen(diabmed) 
replace diabmed = 0 if ah46 == 2
label var diabmed "Current use of diabetes medication - self"
label val diabmed vyesno
recode ahsick_3 (1=1)(2=0)(8=.), gen(cholmed) 
replace cholmed = 0 if ah46 == 2
label var cholmed "Current use of cholesterol medication - self"
label val cholmed vyesno
recode ahsick_4 (1=1)(2=0)(8=.), gen(ischmed) 
replace ischmed = 0 if ah46 == 2
label var ischmed "Current use of angina/hearth attack medication - self"
label val ischmed vyesno
recode ahsick_5 (1=1)(2=0)(8=.), gen(heartmed)
replace heartmed = 0 if ah46 == 2
label var heartmed "Current use of heart conditions medication - self"
label val heartmed  vyesno
recode ahsick_6 (1=1)(2=0)(8=.), gen(asthmed) 
replace asthmed = 0 if ah46 == 2
label var asthmed "Current use of asthma, emphysema or bronchitis medication - self"
label val asthmed vyesno
recode ahsick_7 (1=1)(2=0)(8=.), gen(tbmed) 
replace tbmed = 0 if ah46 == 2
label var tbmed "Current use of tb medication - self"
label val tbmed vyesno 
recode ahsick_8 (1=1)(2=0)(8=.), gen(strokemed) 
replace strokemed = 0 if ah46 == 2
label var strokemed "Current use of stroke medication - self"
label val strokemed vyesno

* Medication use: coded from shown medication
gen diabmed_coded = 0
local code A10
foreach v in 01 02 03 04 05 06 07 08 09 10 11 12 {
  replace diabmed_coded = 1 if substr(ah65_`v',1,3) == "`code'" 
}
label var diabmed_coded "Current use of diabetes medication - coded"
label val diabmed_coded vyesno
gen cholmed_coded = 0
local code C10
foreach v in 01 02 03 04 05 06 07 08 09 10 11 12 {
  replace cholmed_coded = 1 if substr(ah65_`v',1,3) == "`code'" 
}
label var cholmed_coded "Current use of cholesterol medication - coded"
label val cholmed_coded vyesno
gen ischmed_coded = 0
local code C01D
foreach v in 01 02 03 04 05 06 07 08 09 10 11 12 {
  replace ischmed_coded = 1 if substr(ah65_`v',1,4) == "`code'" 
}
local code C01E
foreach v in 01 02 03 04 05 06 07 08 09 10 11 12 {
  replace ischmed_coded = 1 if substr(ah65_`v',1,4) == "`code'" 
}
label var ischmed_coded "Current use of angina/hearth attack medication - coded"
label val ischmed_coded vyesno
gen asthmed_coded = 0
local code R
foreach v in 01 02 03 04 05 06 07 08 09 10 11 12 {
  replace asthmed_coded = 1 if substr(ah65_`v',1,1) == "`code'" 
}
label var asthmed_coded "Current use of asthma, emphysema or bronchitis medication - coded"
label val asthmed_coded vyesno
gen tbmed_coded  = 0
local code J04A
foreach v in 01 02 03 04 05 06 07 08 09 10 11 12 {
  replace tbmed_coded  = 1 if substr(ah65_`v',1,4) == "`code'" 
}
label var tbmed_coded "Current use of tb medication - coded"
label val tbmed_coded vyesno 
gen strokemed_coded = 0
local code C04
foreach v in 01 02 03 04 05 06 07 08 09 10 11 12 {
  replace strokemed_coded = 1 if substr(ah65_`v',1,3) == "`code'" 
}
label var strokemed_coded "Current use of stroke medication - coded"
label val strokemed_coded vyesno

* Psychosocial
recode qh21 (1=1)(2=0), gen(housedeaths)
label var housedeaths "Death in household in last 12 months"
label val housedeaths vyesno

* Variables for asset index (2)
	* Durable Items 
gen w_DHS1998_ass_elec = ass_elec
gen w_DHS1998_ass_radio = ass_radio
gen w_DHS1998_ass_tv = ass_tv
gen w_DHS1998_ass_fridge = ass_fridge
gen w_DHS1998_ass_bicycle = ass_bicycle
gen w_DHS1998_ass_motorcycle = ass_motorcycle 
gen w_DHS1998_ass_car_truck = ass_car_truck
gen w_DHS1998_ass_phone = ass_phone
gen w_DHS1998_ass_computer = ass_computer
gen w_DHS1998_ass_wmachine = ass_wmachine
gen w_DHS1998_ass_donkey_horse = ass_donkey_horse
gen w_DHS1998_ass_sheep_cattle = ass_sheep_cattle

* Identifiers
gen id_001 = psu
rename qnumber id_002
rename qline id_003

* Save temporary
#delimit ;
keep id_001 id_002 id_003 qeanum qdist                                                                                                                 
     intd intm inty psu stratum aweight geotype2 sex age race edu1 edu2 emp water toilet floormaterial wallmaterial 
	 sleeprooms ass_elec ass_radio ass_tv ass_phone ass_fridge ass_wmachine ass_bicycle ass_motorcycle ass_computer ass_car_truck 
	 ass_donkey_horse ass_sheep_cattle smokstatus currsmok alcstatus curralc alcavg weight1 height1 arm1 waist1 hip1 sbp1 dbp1 rhr1 sbp2
	 dbp2 rhr2 sbp3 dbp3 rhr3 diag_hbp diag_isch diag_stroke diag_chol diag_diab diag_emph diag_asth diag_tb diag_cancer currpreg medaid 
	 hcare1mo hcare1mo_public hcare1mo_private hcare1mo_chem_nurse hcare1mo_trad hcare1mo_other housedeaths bpmed_coded bpmed diabmed cholmed ischmed 
	 heartmed asthmed tbmed strokemed diabmed_coded cholmed_coded ischmed_coded asthmed_coded tbmed_coded strokemed_coded hcare1mo sharedtoilet 
	 w_* ;
#delimit cr
save "$TEMP/TEMP_2.dta", replace

******************************************************************************************************************************************************
* CONSOLIDATE                                                                                                                                        * 
******************************************************************************************************************************************************

* Merge datasets
use "$TEMP/TEMP_2.dta", clear    
merge m:1 id_001 id_002 using ".\TEMP\TEMP_1.dta"
keep if _merge == 3
drop _*

* Merge geographical variables

rename prov2011 _prov2011

merge m:1 prov1996 qeanum using "$AUXILIARY_2"     
drop if _merge == 2
drop _merge
rename dist1996 _dist1996
rename dist2001 _dist2001
rename dist2011 _dist2011
rename prov2001 _prov2001
drop prov2011

merge m:1 qdist using "$AUXILIARY_3"  
drop if _merge == 2
drop _merge
replace _dist1996 = dist1996 if _dist1996 == ""
replace _dist2001 = dist2001 if _dist2001 == ""
replace _dist2011 = dist2011 if _dist2011 == ""

replace _prov2001 = prov2001 if _prov2001 >=.
drop prov2011

replace dist1996 = _dist1996 
replace dist2001 = _dist2001 
replace dist2011 = _dist2011
replace prov2001 = _prov2001 
rename _prov2011 prov2011 

drop _*

destring dist1996, replace
destring dist2001, replace
destring dist2011, replace

label var prov1996 "Province (1996 boundaries)"
label val prov1996 vprov1996
label var prov2001 "Province (2001 boundaries)"
label val prov2001 vprov2001
label var prov2011 "Province (2011 boundaries)"
label val prov2011 vprov2011

label var dist1996 "District (1996 boundaries)"
label val dist1996 vprov1996
label var dist2001 "District (2001 boundaries)"
label val dist2001 vprov2001
label var dist2011 "District (2011 boundaries)"
label val dist2011 vprov2011

* Add derived
gen nsleeprooms = sleeprooms/hsize
label var nsleeprooms "People per sleeping room"

* Delete observations with missing sampling weights
keep if aweight <. & hweight <. & aweight > 0 & hweight > 0

* Delete observations with missing data on sex and/or age 
keep if age <. & sex <. 

* Delete identifiers 
drop id_002 id_003 id_001

* Add individual identifier
gen pid = _n
label var pid "Individual ID"

* Add source identifier
gen source = "DHS 1998"
label var source "Source"

* Rescale sampling weights to sum to the sample size
sum aweight
local wmean = r(mean)
replace aweight = aweight/`wmean'

* Save temporary
save "$TEMP/TEMP_3.dta", replace

******************************************************************************************************************************************************
* ANCHOR POINTS FOR COMPARATIVE WEALTH INDEX                                                                                                         * 
******************************************************************************************************************************************************

use "$DATASET_1", clear

forvalues i = 1/9 {
	gen primaryed_`i'=.
	replace primaryed_`i'=1 if hv109_0`i'==2 | hv109_0`i'==3 | hv109_0`i'==4 | hv109_0`i'==5 
	replace primaryed_`i'=0 if hv109_0`i'==0 | hv109_0`i'==1
	label var primaryed_`i' "Completed primary school household member `i'"
	label values primaryed_`i' vyesno
}

forvalues i = 10/27 {
	gen primaryed_`i'=.
	replace primaryed_`i'=1 if hv109_`i'==2 | hv109_`i'==3 | hv109_`i'==4 | hv109_`i'==5 
	replace primaryed_`i'=0 if hv109_`i'==0 | hv109_`i'==1
	label var primaryed_`i' "Completed primary school household member `i'"
	label values primaryed_`i' vyesno
}


egen edunum = rownonmiss(primaryed_*)
egen primaryed_hh = rowmax(primaryed_*)

* Recoding to missing if no household member has completed primary school but some household members have missing education.  
* Sum primaryed_hh if primaryed_hh==0 & edunum < hv009

replace primaryed_hh=. if primaryed_hh==0 & edunum < hv009
gen edu_deprived=.
replace edu_deprived=1 if primaryed_hh==0
replace edu_deprived=0 if primaryed_hh==1
label var edu_deprived "No household member has completed primary school"
label values edu_deprived vyesno
keep edu_deprived hhid

* Save temporary
save "$TEMP/TEMP_4A.dta", replace

use "$TEMP/TEMP_3.dta", clear
duplicates drop hhid, force
rename hhid hhid_num
decode hhid_num, gen(hhid)
merge 1:1 hhid using "$TEMP/TEMP_4A.dta"
keep if _merge==3
drop _merge
drop hhid 
rename hhid_num hhid

*Unimproved sanitation
recode toilet (1/2=0) (3/9999=1), gen(unimp_toilet)
replace unimp_toilet=1 if sharedtoilet==1
label values unimp_toilet vyesno
label variable unimp_toilet "Unimproved sanitation"

*Unimproved water
recode water (1/3=0) (5/6=0) (4=1) (7/9999=1), gen(unimp_water)
label values unimp_water vyesno
label variable unimp_water "Unimproved water source"

*Solid cooking fuel
gen unimp_cooking = 0
replace unimp_cooking = 1 if cook_coal == 1
replace unimp_cooking = 1 if cook_dung == 1 
replace unimp_cooking = 1 if cook_wood == 1
label values unimp_cooking vyesno
label var unimp_cooking "Use of solid (unimproved) cooking fuels"

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
save "$TEMP/TEMP_4B.dta", replace

******************************************************************************************************************************************************
* SAVE & ERASE TEMPORARY FILES                                                                                                                       * 
******************************************************************************************************************************************************

use "$TEMP/TEMP_3.dta", clear
merge m:1 hhid using "$TEMP/TEMP_4B.dta"
keep if _merge == 3
drop _merge

* Delete value labels
label drop _all

* Label the dataset
label data "DHS 1998 - Core Variables - $S_DATE"

save "$OUT/DHS1998.dta", replace
erase "$TEMP/TEMP_1.dta"
erase "$TEMP/TEMP_2.dta"
erase "$TEMP/TEMP_3.dta"
erase "$TEMP/TEMP_4A.dta"
erase "$TEMP/TEMP_4B.dta"

