******************************************************************************************************************************************************
* EXPOSE - DATA EXTRACTION                                                                                                                           *
* South Africa Demographic and Health Survey 2016 (DHS 2016)                                                                                         *
* Annibale Cois (acois@sun.ac.za) & Kafui Adjaye-Gbewonyo (k.adjayegbewonyo@greenwich.ac.uk)                                                         *
* Version 1.0 - September 2022                                                                                                                       *
******************************************************************************************************************************************************

clear
set more off

******************************************************************************************************************************************************
* LOCATION OF FILES AND FOLDERS                                                                                                                      * 
******************************************************************************************************************************************************

* SOURCE FILES
global DATASET_1 "$BASEDIR/DHS/Datafiles/ZAPR71FL.dta"       // HOUSEHOLD MEMBERS
global DATASET_2M "$BASEDIR/DHS/Datafiles/ZAAHM71FL.dta"     // ADULT HEALTH (MALES)
global DATASET_2F "$BASEDIR/DHS/Datafiles/ZAAHW71FL.dta"     // ADULT HEALTH (FEMALES)
global DATASET_3 "$BASEDIR/DHS/Datafiles/ZAIR71FL.dta"       // WOMEN HEALTH
global DATASET_4 "$BASEDIR/DHS/Datafiles/ZAHR71FL.dta"       // HOUSEHOLD ROSTER
global AUXILIARY_1 "$AUX/Geocoding/IPUMS_GEO.dta"            // GEOGRAPHICAL RECODING (IPUMS MATCHING DATASET) 
global AUXILIARY_2 "$AUX/Geocoding/DHS_2016_MATCH.dta"       // GEOGRAPHICAL RECODING (PROJECTIONS ON DISTRCITS BASED ON CLUSTER CENTROIDS FORM IPUMS) 

******************************************************************************************************************************************************
* EXTRACTION                                                                                                                                         * 
******************************************************************************************************************************************************

// HOUSEHOLD MEMBER RECODE

use "$DATASET_1" , clear     
keep if hv105 >= 15        // Only adults
keep sh26 hhid

collapse (sum) sh26, by(hhid) 
gen recgrant = .
replace recgrant = 1 if sh26>=1
replace recgrant = 0 if sh26==0
label var recgrant "Household received government grant"
label val recgrant vyesno
drop sh26

* Save temporary
save "$TEMP/TEMP_1.dta", replace

// HOUSEHOLD MEMBER RECODE

use "$DATASET_1" , clear     
keep if hv105 >= 15        // Only adults
keep hhid 
duplicates drop

* Geographic
gen sample = string(71002)
gen str idhshid = sample+hhid
merge 1:1 idhshid using "$AUXILIARY_1", keepusing(geo_za1998 geo_za2016)
keep if _merge == 3
drop _merge
rename geo_za1998 prov1996
label var prov1996 "Province (1996 boundaries)"
label val prov1996 vprov1996
rename geo_za2016 prov2011
label var prov2011 "Province (2001 boundaries)"
label val prov2011 vprov2011

* Save temporary
keep  hhid prov1996 prov2011
save "$TEMP/TEMP_1A.dta", replace

// HOUSEHOLD MEMBER RECODE

use "$DATASET_1" , clear     
keep if hv105 >= 15        // Only adults
merge m:1 hhid using "$TEMP/TEMP_1.dta"
drop _merge
merge m:1 hhid using "$TEMP/TEMP_1A.dta"
drop _merge

* Administrative 
rename hv021 psu
label var psu "Primary Sampling Unit"
rename hv022 stratum 
label var stratum "Stratum"
rename hhid x
encode (x), gen(hhid)
label var hhid "Household ID"
gen hweight = hv005
label var hweight "Sampling weight - Household Questionnaire"

* Geographic
rename hv025 geotype2 
label var geotype2 "Geotype (urban/rural)"
label val geotype2 vgeotype2

* Demographic
rename hv104 sex
label var sex "Sex"
label val sex vsex
rename hv105 age
label var age "Age [years]"
rename hv009 hsize 
label var hsize "Household size"
recode hv116 (0=3)(1=1)(2=2),gen(marstatus)
label var marstatus "Marital status"
label val marstatus vmarstatus

* Socioeconomic
recode sh124d (1=0)(2/5=1)(6=0), gen(foodinsec_adult)
label var foodinsec_adult "Food insecurity: adult"
label val foodinsec_adult vyesno
recode sh124e (1=0)(2/5=1)(6=0), gen(foodinsec_child) 
label var foodinsec_child "Food insecurity: child"
label val foodinsec_child vyesno
gen foodinsec = .
replace foodinsec = 1 if foodinsec_adult == 1 |  foodinsec_child == 1
replace foodinsec = 0 if foodinsec_adult == 0 &  foodinsec_child == 0
label var foodinsec "Food insecurity"
label val foodinsec vyesno
recode hv109 (8=.), gen(edu1) 
label var edu1 "Education (6 categories)"
label val edu1 vedu1
recode edu1 (0=0)(1=1)(2=2)(3=3)(4/5=4)(6=4), gen(edu2)
label var edu2 "Education (5 categories)"
label val edu2 vedu2
recode hv201 (11=1)(12=2)(13=9999)(14=3)(61/62=4)(21/32=5)(51=6)(41/43=7)(71/96=9999), gen(water)
label var water "Source of drinking water"
label val water vwater
recode hv205 (11/15=1)(44=1)(21/22=2)(23=3)(42=3)(31=4)(41=9999)(96=9999), gen(toilet)
label var toilet "Toilet facilities"
label val toilet vtoilet
rename hv225 sharedtoilet 
label var sharedtoilet "Shared toilet facility"
label val sharedtoilet vyesno
recode hv213 (11/12=1)(21/31=5)(32=6)(33=4)(34=2)(35=3)(96=9999), gen(floormaterial)
label var floormaterial "Floor material" 
label val floormaterial vfloormaterial
recode hv214 (11=9999)(12=1)(21=4)(22/23=1)(24=2)(25=4)(26=9999)(31/34=5)(36=9999)(37=3)(96=9999), gen(wallmaterial) 
label var wallmaterial "Wall material"
label val wallmaterial vwallmaterial
recode hv215 (11=9999)(12/13=1)(22=1)(21=4)(23=2)(24=5)(25=6)(26=4)(31=3)(32=6)(33=7)(34=8)(35=5)(96=9999), gen(roofmaterial) 
label var roofmaterial "Roof material"
label val roofmaterial vroofmaterial
rename hv206 ass_elec 
label var ass_elec "Assets: electricity"
label val ass_elec vyesno
rename hv207 ass_radio
label var ass_radio "Assets: radio"
label val ass_radio vyesno
rename hv208 ass_tv
label var ass_tv "Assets: TV"
label val ass_tv vyesno
rename hv221 ass_phone
label var ass_phone "Assets: telephone"
label val ass_phone vyesno
rename hv243e ass_computer
label var ass_computer "Assets: computer"
label val ass_computer vyesno
rename hv209 ass_fridge
label var ass_fridge "Assets: fridge"
label val ass_fridge vyesno
rename sh121g ass_vacuum
label var ass_vacuum "Assets: vacuum cleaner"
label val ass_vacuum vyesno
rename sh121h ass_microwave
label var ass_microwave "Assets: microwave oven"
label val ass_microwave vyesno
rename sh121j ass_wmachine
label var ass_wmachine "Assets: washing machine"
label val ass_wmachine vyesno
rename hv243b ass_watch
label var ass_watch "Assets: watch"
label val ass_watch vyesno
rename hv243a ass_cellphone
label var ass_cellphone "Assets: cellphone"
label val ass_cellphone vyesno
rename hv210 ass_bicycle
label var ass_bicycle "Assets: bicycle"
label val ass_bicycle vyesno
rename hv211 ass_motorcycle
label var ass_motorcycle "Assets: motorcycle"
label val ass_motorcycle vyesno
rename hv212 ass_car_truck
label var ass_car_truck "Assets: car, truck"
label val ass_car_truck vyesno
rename hv243c ass_animalcart
label var ass_animalcart "Assets: animal cart"
label val ass_animalcart vyesno
rename hv243d ass_motorboat
label var ass_motorboat "Assets: motorboat"
label val ass_motorboat vyesno
rename hv246 ass_livestock
label var ass_livestock "Assets: livestock"
label val ass_livestock vyesno
recode hv246c  (0=0)(1/43=1)(98=1), gen(ass_donkey_horse)
label var ass_donkey_horse "Assets: donkey, horse"
label val ass_donkey_horse vyesno
gen cattle  = .
replace cattle = 1 if hv246a > 0
replace cattle = 0 if hv246a == 0
gen sheep  = .
replace sheep = 1 if hv246e > 0
replace sheep = 0 if hv246e == 0
gen ass_sheep_cattle = .
replace ass_sheep_cattle = 1 if sheep == 1 | cattle == 1
replace ass_sheep_cattle = 0 if sheep == 0 & cattle == 0
label var ass_sheep_cattle "Assets: sheep, cattle"
label val ass_sheep_cattle vyesno
rename sh121i ass_stove
label var ass_stove "Assets: Stove" 
label values ass_stove vyesno
gen sleeprooms = hv216 
label var sleeprooms "Number of rooms for sleeping"
recode hv226 (1=1)(2=2)(5=3)(6=4)(8=5)(10=5)(11=6)(12/13=1)(14=9999)(96=9999)(95=9999), gen(cookingfuel)
label var cookingfuel "Main cooking fuel"
label val cookingfuel vcookingfuel
recode sh116a (1=1)(2=2)(5=3)(6=4)(8/10=5)(11=6)(12/13=1)(14=9999)(96=9999)(95=9999), gen(heatingfuel)
label var heatingfuel "Main heating fuel"
label val heatingfuel vheatingfuel

*Generating new indicators for cooking fuel, with 1 for main fuel and missing for all else and 0 for none, for harmonisation with 1998 DHS
tabulate cookingfuel, gen (cook)
rename cook1 cook_elec
replace cook_elec=. if cook_elec==0
replace cook_elec=0 if hv226==95
rename cook2 cook_gas
replace cook_gas=. if cook_gas==0
replace cook_gas=0 if hv226==95
rename cook3 cook_par
replace cook_par=. if cook_par==0
replace cook_par=0 if hv226==95
rename cook4 cook_coal
replace cook_coal=. if cook_coal==0
replace cook_coal=0 if hv226==95
rename cook5 cook_wood
replace cook_wood=. if cook_wood==0
replace cook_wood=0 if hv226==95
rename cook6 cook_dung
replace cook_dung=. if cook_dung==0
replace cook_dung=0 if hv226==95
rename cook7 cook_other
replace cook_other=. if cook_other==0
replace cook_other=0 if hv226==95

label var cook_elec "Cooking fuel: Electricity"
label var cook_gas "Cooking fuel: Gas"
label var cook_par "Cooking fuel: Paraffin" 
label var cook_wood "Cooking fuel: Wood"
label var cook_coal "Cooking fuel: Coal"
label var cook_dung "Cooking fuel: Animal dung"
label var cook_other "Cooking fuel: Other"

recode sh124a (1=1)(3=1)(2=0) (4/100=0), gen(refuseremoved)
label var refuseremoved "Refuse removed weekly by local authorities"
label val refuseremoved vyesno
recode sh141a (1=1)(2=2)(3=3)(4/6=4)(7=5)(8=6)(9=7)(10=8)(11=9)(96=9999), gen(dwelling)
label var dwelling "Dwelling type"
label val dwelling vdwelling

* Anthropometric
recode sh218 sh318 ha2 hb2 ha3 hb3 sh206a sh306a (9000/10000 = .)
egen arm1 = rowtotal(sh218 sh318), missing
label var arm1 "Arm circumference [cm] - reading 1"
egen weight1 = rowtotal(ha2 hb2), missing
replace weight1 = weight1/10
label var weight1 "Weight [kg] - reading 1"
egen height1 = rowtotal(ha3 hb3), missing
replace height1 = height1/10
label var height1 "Height [cm] - reading 1"
egen waist1 = rowtotal(sh206a sh306a), missing
replace waist1 = waist1/10
label var waist1 "Waist circumference [cm] - reading 1"
recode sh221a sh321a sh221b sh321b sh221c sh321c sh228a sh328a sh228b sh328b sh228c sh328c sh232a sh332a sh232b sh332b sh232c sh232c (500/1000 =.)  
egen sbp1 = rowtotal(sh221a sh321a), missing
label var sbp1 "Systolic Blood Pressure [mmHg] - reading 1"
egen dbp1 = rowtotal(sh221b sh321b), missing
label var dbp1 "Diastolic Blood Pressure [mmHg] - reading 1"
egen rhr1 = rowtotal(sh221c sh321c), missing
label var rhr1 "Resting Heart Rate [bpm] - reading 1"
egen sbp2 = rowtotal(sh228a sh328a), missing
label var sbp2 "Systolic Blood Pressure [mmHg] - reading 2"
egen dbp2 = rowtotal(sh228b sh328b), missing  
label var dbp2 "Diastolic Blood Pressure [mmHg] - reading 2"
egen rhr2 = rowtotal(sh228c sh328c), missing
label var rhr2 "Resting Heart Rate [bpm] - reading 2" 
egen sbp3 = rowtotal(sh232a sh332a), missing 
label var sbp3 "Systolic Blood Pressure [mmHg] - reading 3"
egen dbp3 = rowtotal(sh232b sh332b), missing
label var dbp3 "Diastolic Blood Pressure [mmHg] - reading 3"
egen rhr3 = rowtotal(sh232c sh232c), missing
label var rhr3 "Resting Heart Rate [bpm] - reading 3"

* Biomarkers
recode shmhba1c shwhba1c (90000/. =.)  
egen hb = rowtotal(ha56 hb56), missing
replace hb = hb/10
label var hb "Haemoglobin [g/dl]"
egen HbA1c  = rowtotal(shmhba1c shwhba1c), missing
replace HbA1c = 10.93*HbA1c/1000 - 22.5
label var HbA1c "hb1ac [mmol/mol]"

* Reproductive health
rename ha54 currpreg
label var currpreg "Currently pregnant" 

* Medication use: self-reported
gen bpmed = .
replace bpmed = sh324 if sex == 1
replace bpmed = sh224 if sex == 2
replace bpmed = 0 if sh323 == 0 & sex == 1 
replace bpmed = 0 if sh223 == 0 & sex == 2 
label var bpmed "Current use of antihypertensive medication - self"
label val bpmed vyesno

* Medication use: coded from shown medication
gen bpmed_coded = 0
local code C02
foreach v in a b c d e f g h i j k l {
  replace bpmed_coded = 1 if substr(sh277`v',1,3) == "`code'" 
  replace bpmed_coded = 1 if substr(sh377`v',1,3) == "`code'" 
}
label var bpmed_coded "Current use of diabetes medication - coded"
label val bpmed_coded vyesno
gen diabmed_coded = 0
local code A10
foreach v in a b c d e f g h i j k l {
  replace diabmed_coded = 1 if substr(sh277`v',1,3) == "`code'" 
  replace diabmed_coded = 1 if substr(sh377`v',1,3) == "`code'" 
}
label var diabmed_coded "Current use of diabetes medication - coded"
label val diabmed_coded vyesno
gen cholmed_coded = 0
local code C10
foreach v in a b c d e f g h i j k l {
  replace cholmed_coded = 1 if substr(sh277`v',1,3) == "`code'" 
  replace cholmed_coded = 1 if substr(sh377`v',1,3) == "`code'" 
}
label var cholmed_coded "Current use of cholesterol medication - coded"
label val cholmed_coded vyesno
gen ischmed_coded = 0
local code C01D
foreach v in a b c d e f g h i j k l {
  replace ischmed_coded = 1 if substr(sh277`v',1,4) == "`code'" 
  replace ischmed_coded = 1 if substr(sh377`v',1,4) == "`code'" 
}
local code C01E
foreach v in a b c d e f g h i j k l {
  replace ischmed_coded = 1 if substr(sh277`v',1,4) == "`code'" 
  replace ischmed_coded = 1 if substr(sh377`v',1,4) == "`code'" 
}
label var ischmed_coded "Current use of angina/hearth attack medication - coded"
label val ischmed_coded vyesno
gen asthmed_coded = 0
local code R
foreach v in a b c d e f g h i j k l {
  replace asthmed_coded = 1 if substr(sh277`v',1,1) == "`code'" 
  replace asthmed_coded = 1 if substr(sh377`v',1,1) == "`code'" 
}
label var asthmed_coded "Current use of asthma, emphysema or bronchitis medication - coded"
label val asthmed_coded vyesno
gen tbmed_coded  = 0
local code J04A
foreach v in a b c d e f g h i j k l {
  replace tbmed_coded = 1 if substr(sh277`v',1,4) == "`code'" 
  replace tbmed_coded = 1 if substr(sh377`v',1,4) == "`code'" 
}
label var tbmed_coded "Current use of tb medication - coded"
label val tbmed_coded vyesno 
gen strokemed_coded = 0
local code C04
foreach v in a b c d e f g h i j k l {
  replace strokemed_coded = 1 if substr(sh277`v',1,3) == "`code'" 
  replace strokemed_coded = 1 if substr(sh377`v',1,3) == "`code'" 
}
label var strokemed_coded "Current use of stroke medication - coded"
label val strokemed_coded vyesno

* Variables for asset index 
    * Grant
gen w_DHS2016_grant = recgrant
	* Cooking fuel
tab hv226, gen(w_DHS2016_cookfuel)
drop w_DHS2016_cookfuel1
	* heating fuel
tab sh116a, gen(w_DHS2016_heathfuel)
drop w_DHS2016_heathfuel1
	* People per room
gen w_DHS2016_proom = hv216/hsize
	* Floor material
tab hv213, gen(w_DHS2016_flo)
drop w_DHS2016_flo1
	* Wall material
tab hv214, gen(w_DHS2016_wal)
drop w_DHS2016_wal1
	* Roof material
tab hv215, gen(w_DHS2016_rof)
drop w_DHS2016_rof1
    * Type of dwelling
tab	sh141a, gen(w_DHS2016_dwelling)
drop w_DHS2016_dwelling1
	* Water source
tab hv201, gen(w_DHS2016_wat)
drop w_DHS2016_wat1
	* Sanitation
tab hv205, gen(w_DHS2016_san)
drop w_DHS2016_san1
	* Refuse disposal
tab sh124a, gen(w_DHS2016_refusedisp)
drop w_DHS2016_refusedisp1
	* Durable Items 
gen w_DHS2016_ass_elec = ass_elec
gen w_DHS2016_ass_radio = ass_radio
gen w_DHS2016_ass_tv = ass_tv
gen w_DHS2016_ass_phone = ass_phone
gen w_DHS2016_ass_computer = ass_computer
gen w_DHS2016_ass_fridge = ass_fridge
gen w_DHS2016_ass_vacuum = ass_vacuum
gen w_DHS2016_ass_microwave = ass_microwave
gen w_DHS2016_ass_wmachine = ass_wmachine 
gen w_DHS2016_ass_watch = ass_watch
gen w_DHS2016_ass_cellphone = ass_cellphone
gen w_DHS2016_ass_bicycle = ass_bicycle
gen w_DHS2016_ass_motorcycle = ass_motorcycle
gen w_DHS2016_ass_car_truck = ass_car_truck
gen w_DHS2016_ass_animalcart = ass_animalcart
gen w_DHS2016_ass_motorboat = ass_motorboat
gen w_DHS2016_ass_donkey_horse = ass_donkey_horse 
gen w_DHS2016_ass_sheep_cattle = ass_sheep_cattle 

* Identifiers
rename hv001 id_1
rename hv002 id_2
rename hvidx id_3

* Save temporary
#delimit ;
keep id_1 id_2 id_3 
psu stratum prov2011 prov1996 geotype2 sex age hsize marstatus edu1 edu2 dwelling water toilet sharedtoilet floormaterial wallmaterial roofmaterial hhid   ///
hweight ass_elec ass_radio ass_tv ass_phone ass_cellphone ass_computer ass_fridge ass_vacuum ass_microwave ass_wmachine ass_watch ass_cell        ///
ass_bicycle ass_motorcycle ass_car_truck ass_animalcart ass_motorboat ass_donkey_horse ass_sheep_cattle ass_stove recgrant sleeprooms             ///
cookingfuel heatingfuel refuseremoved arm1 weight1 height1 waist1 sbp1 dbp1 rhr1 sbp2 dbp2 rhr2 sbp3 dbp3 rhr3 currpreg HbA1c hb bpmed            ///
bpmed_coded diabmed_coded cholmed_coded ischmed_coded asthmed_coded tbmed_coded strokemed_coded cook_elec cook_gas cook_par cook_wood cook_coal   ///
cook_dung cook_other ass_livestock foodinsec foodinsec_adult foodinsec_child w_*;
#delimit cr
save "$TEMP/TEMP_2.dta", replace

// ADULT HEALTH (MALES)

use "$DATASET_2M" , clear     

* Administrative 
rename mv016 intd 
label var intd "Day of interview"
rename mv006 intm
label var intm "Month of interview"
rename mv007 inty
label var inty "Year of interview"
rename smweight aweight
label var aweight "Sampling weight - Adult Questionnaire"	

* Demographic
recode mv131 (1=1)(2=3)(3=2)(4=4)(996=9999), gen(race)
label var race "Population group"
label val race vrace

* Socioeconomic
recode mv731 (0=0)(1/2=1),gen(emp)
label var emp "Employment status"

* Behavioural
recode mv463ad (0=0)(1/2=1), gen(smokstatus) 
replace smokstatus = 2 if (mv463aa == 1 | mv463aa == 2)  
label var smokstatus  "Smoking status"
recode smokstatus (2=1)(0/1=0)(.=.), gen(currsmok)
label var currsmok "Current smoking"
label val currsmok vyesno
rename sm916 alcstatus
replace alcstatus = 2 if (sm917 == 1)  
label var alcstatus  "Alcohol use status"
recode alcstatus (2=1)(0/1=0)(.=.), gen(curralc)
label var curralc "Current drinking"
label val curralc vyesno
egen alcavg = rowtotal(sm919a sm919b sm919c sm919d sm919e sm919f sm919g) 
replace alcavg = alcavg/7*12
label var alcavg "Average alcohol consumpion [g/d]"
rename sm924 alcbing
label var alcbing "Binge drinking"
label val alcbing vyesno
recode sm918 (1=6)(2=3)(3=2)(4=0.5), gen(alcfreq)
label var alcfreq "Number drinking days per week"

* Health status
rename sm901 self_health
label var self_health "Self-perception of health status"
label val self_health vselfhealth
recode sm1108a (0=0)(1=1)(8=.), gen(diag_hbp)
label var diag_hbp "Diagnosis: hypertension" 
label val diag_hbp vyesno

recode sm1108b (0=0)(1=1)(8=.), gen(diag_isch)
label var diag_isch "Diagnosis: heart attack/angina"	
label val diag_isch vyesno
recode sm1108d (0=0)(1=1)(8=.), gen(diag_stroke)
label var diag_stroke "Diagnosis: stroke"
label val diag_stroke vyesno
recode sm1108e (0=0)(1=1)(8=.), gen(diag_chol)
label var diag_chol "Diagnosis: hypercholesterolaemia"
label val diag_chol vyesno
recode sm1108f (0=0)(1=1)(8=.), gen(diag_diab)
label var diag_diab "Diagnosis: diabetes"
label val diag_diab vyesno
recode sm1108g (0=0)(1=1)(8=.), gen(diag_emph)
label var diag_emph "Diagnosis: emphysema/bronchitis"  
label val diag_emph vyesno
recode sm1108h (0=0)(1=1)(8=.), gen(diag_asth)
label var diag_asth "Diagnosis: asthma"
label val diag_asth vyesno
recode sm1105 (0=0)(1=1)(8=.), gen(diag_tb)
label var diag_tb "Diagnosis: tuberculosis"
label val diag_tb vyesno
recode sm1108c (0=0)(1=1)(8=.), gen(diag_cancer) 
label var diag_cancer "Diagnosis: cancer" 
label val diag_cancer vyesno
 
* Healthcare Utilisation
rename sm1101 medaid 
label var medaid "Covered by medical insurance"  
label val medaid vyesno
gen ohcare1mo_public = .
replace ohcare1mo_public = 1 if (sm1103a == 1 | sm1103b == 1)
replace ohcare1mo_public = 0 if (sm1103a == 0 & sm1103b == 0)
label var ohcare1mo_public "Outpatient healthcare last month: public hospital/clinic"
label val ohcare1mo_public vyesno
gen ohcare1mo_private = .
replace ohcare1mo_private = 1 if (sm1103d == 1)
replace ohcare1mo_private = 0 if (sm1103d == 0)
label var ohcare1mo_private "Outpatient healthcare last month: private hospital/clinic/doctor"
label val ohcare1mo_private vyesno
gen hcare1mo_chem_nurse = .
replace hcare1mo_chem_nurse = 1 if (sm1103e == 1)
replace hcare1mo_chem_nurse = 0 if (sm1103e == 0)
label var hcare1mo_chem_nurse "Healthcare last month: chemist/pharmacist/nurse" 
label val hcare1mo_chem_nurse vyesno
gen hcare1mo_trad = .
replace hcare1mo_trad = 1 if (sm1103i == 1 | sm1103j == 1 | sm1103k == 1)
replace hcare1mo_trad = 0 if (sm1103i == 0 | sm1103j == 0 & sm1103k == 0)
label var hcare1mo_trad "Healthcare last month: traditional/faith healer"
label val hcare1mo_trad vyesno
gen hcare1mo_other = .
replace hcare1mo_other = 1 if (sm1103f == 1 | sm1103c == 1 | sm1103g == 1 | sm1103h == 1 | sm1103x == 1 | sm1104 == 1)
replace hcare1mo_other = 0 if (sm1103f == 0 & sm1103c == 0 & sm1103g == 0 & sm1103h == 0 & sm1103x == 0 & sm1104 == 0)
label var hcare1mo_other "Healthcare last month: other" 
label val hcare1mo_other vyesno

replace ohcare1mo_public = 0 if sm1102 == 0
replace ohcare1mo_private= 0 if sm1102 == 0 
replace hcare1mo_chem_nurse= 0 if sm1102 == 0
replace hcare1mo_trad= 0 if sm1102 == 0
replace hcare1mo_other= 0 if sm1102 == 0

gen ohcare1mo = .
replace ohcare1mo = 1 if ohcare1mo_public == 1 | ohcare1mo_private == 1 | hcare1mo_chem_nurse == 1 | hcare1mo_trad == 1 | hcare1mo_other == 1
replace ohcare1mo = 0 if ohcare1mo_public == 0 & ohcare1mo_private == 0 & hcare1mo_chem_nurse == 0 & hcare1mo_trad == 0 & hcare1mo_other == 0
label var ohcare1mo "Outpatient consultations last month"
label val ohcare1mo vyesno

* Identifiers
rename mv001 id_1
rename mv002 id_2
rename mv003 id_3

* Save temporary
#delimit ;
keep id_1 id_2 id_3 
intd intm inty aweight race emp smokstatus currsmok alcstatus alcavg alcbing self_health curralc diag_hbp diag_isch diag_stroke diag_chol diag_diab 
diag_asth diag_tb diag_cancer diag_emph medaid alcfreq ohcare1mo ohcare1mo_public ohcare1mo_private hcare1mo_chem_nurse hcare1mo_trad hcare1mo_other;
#delimit cr
save "$TEMP/TEMP_2M.dta", replace

// ADULT HEALTH (FEMALES)

use "$DATASET_2F" , clear     

* Administrative 
rename v016 intd 
label var intd "Day of interview"
rename v006 intm
label var intm "Month of interview"
rename v007 inty
label var inty "Year of interview"	
rename sweight aweight
label var aweight "Sampling weight - Adult Questionnaire"
	
* Demographic
recode v131 (1=1)(2=3)(3=2)(4=4)(996=.), gen(race)
label var race "Population Group"
label val race vrace

* Socioeconomic
recode v731 (0=0)(1/3=1),gen(emp)
label var emp "Employment status"
label val emp vemp

* Behavioural
recode v463ad (0=0)(1/2=1), gen(smokstatus) 
replace smokstatus = 2 if (v463aa == 1 | v463aa == 2)  
label var smokstatus  "Smoking status"
label val smokstatus vsmokstatus
recode smokstatus (2=1)(0/1=0)(.=.), gen(currsmok)
label var currsmok "Current smoking"
label val currsmok vyesno
rename s1224 alcstatus
replace alcstatus = 2 if (s1225 == 1)  
label var alcstatus  "Alcohol use status"
recode alcstatus (2=1)(1/2=0)(.=.), gen(curralc)  
label var curralc "Current drinking"
label val curralc vyesno
egen alcavg = rowtotal(s1227a s1227b s1227c s1227d s1227e s1227f s1227g) 
replace alcavg = alcavg/7*12
label var alcavg "Average alcohol consumpion [g/d]"
rename s1232 alcbing
label var alcbing "Binge drinking"
label val alcbing vyesno
recode s1226 (1=6)(2=3)(3=2)(4=0.5), gen(alcfreq)
label var alcfreq "Number drinking days per week"

* Health status
rename s1202 self_health
label var self_health "Self-perception of health status"
label val self_health vselfhealth
recode s1413a (0=0)(1=1)(8=.), gen(diag_hbp)
label var diag_hbp "Diagnosis: hypertension" 
label val diag_hbp vyesno
recode s1413b (0=0)(1=1)(8=.), gen(diag_isch)
label var diag_isch "Diagnosis: heart attack/angina"	
label val diag_isch vyesno
recode s1413d (0=0)(1=1)(8=.), gen(diag_stroke)
label var diag_stroke "Diagnosis: stroke"
label val diag_stroke vyesno
recode s1413e (0=0)(1=1)(8=.), gen(diag_chol)
label var diag_chol "Diagnosis: hypercholesterolaemia"
label val diag_chol vyesno
recode s1413f (0=0)(1=1)(8=.), gen(diag_diab)
label var diag_diab "Diagnosis: diabetes"
label val diag_diab vyesno
recode s1413g (0=0)(1=1)(8=.), gen(diag_emph)
label var diag_emph "Diagnosis: emphysema/bronchitis"  
label val diag_emph vyesno
recode s1413h (0=0)(1=1)(8=.), gen(diag_asth)
label var diag_asth "Diagnosis: asthma"
label val diag_asth vyesno
recode s1410 (0=0)(1=1)(8=.), gen(diag_tb)
label var diag_tb "Diagnosis: tuberculosis"
label val diag_tb vyesno
recode s1413c (0=0)(1=1)(8=.), gen(diag_cancer) 
label var diag_cancer "Diagnosis: cancer" 
label val diag_cancer vyesno

* Healthcare Utilisation
rename s1402 medaid 
label var medaid "Covered by medical insurance"  
label val medaid vyesno
gen ohcare1mo_public = .
replace ohcare1mo_public = 1 if (s1405a == 1 | s1405b == 1 | s1405c == 1)
replace ohcare1mo_public = 0 if (s1405a == 0 & s1405b == 0 & s1405c == 0)
label var ohcare1mo_public "Outpatient healthcare last month: public hospital/clinic"
label val ohcare1mo_public vyesno
gen ohcare1mo_private = .
replace ohcare1mo_private = 1 if (s1405d == 1)
replace ohcare1mo_private = 0 if (s1405d == 0)
label var ohcare1mo_private "Outpatient healthcare last month: private hospital/clinic/doctor"
label val ohcare1mo_private vyesno
gen hcare1mo_chem_nurse = .
replace hcare1mo_chem_nurse = 1 if (s1405e == 1)
replace hcare1mo_chem_nurse = 0 if (s1405e == 0)
label var hcare1mo_chem_nurse "Healthcare last month: chemist/pharmacist/nurse" 
label val hcare1mo_chem_nurse vyesno
gen hcare1mo_trad = .
replace hcare1mo_trad = 1 if (s1405i == 1 | s1405i == 1 | s1405k == 1)
replace hcare1mo_trad = 0 if (s1405i == 0 & s1405i == 0 & s1405k == 0)
label var hcare1mo_trad "Healthcare last month: traditional/faith healer"
label val hcare1mo_trad vyesno
gen hcare1mo_other = .
replace hcare1mo_other = 1 if (s1405f == 1 | s1405c == 1 | s1405g == 1 | s1405h == 1 | s1405x == 1 | s1406 == 1)
replace hcare1mo_other = 0 if (s1405f == 0 & s1405c == 0 & s1405g == 0 & s1405h == 0 & s1405x == 0 & s1406 == 1)
label var hcare1mo_other "Healthcare last month: other" 
label val hcare1mo_other vyesno
replace ohcare1mo_public = 0 if s1404 == 0
replace ohcare1mo_private= 0 if s1404 == 0 
replace hcare1mo_chem_nurse= 0 if s1404 == 0
replace hcare1mo_trad= 0 if s1404 == 0
replace hcare1mo_other= 0 if s1404 == 0

gen ohcare1mo = .
replace ohcare1mo = 1 if ohcare1mo_public == 1 | ohcare1mo_private == 1 | hcare1mo_chem_nurse == 1 | hcare1mo_trad == 1 | hcare1mo_other == 1
replace ohcare1mo = 0 if ohcare1mo_public == 0 & ohcare1mo_private == 0 & hcare1mo_chem_nurse == 0 & hcare1mo_trad == 0 & hcare1mo_other == 0
label var ohcare1mo "Outpatient consultations last month"
label val ohcare1mo vyesno

* Identifiers
rename v001 id_1
rename v002 id_2
rename v003 id_3

* Save temporary
#delimit ;
keep id_1 id_2 id_3 
intd intm inty aweight race emp smokstatus currsmok alcstatus curralc alcavg alcbing self_health diag_hbp diag_isch diag_stroke diag_chol 
diag_diab diag_asth diag_tb diag_cancer diag_emph medaid alcfreq 
ohcare1mo ohcare1mo_public ohcare1mo_private hcare1mo_chem_nurse hcare1mo_trad hcare1mo_other;
#delimit cr
save "$TEMP/TEMP_2F.dta", replace

// WOMEN HEALTH

use v001 v002 v003 v201-v207 v012 using "$DATASET_3", clear       

* Reproductive health
rename v201 parity 
label var parity "Parity"

* Identifiers
rename v001 id_1
rename v002 id_2
rename v003 id_3

* Save temporary
keep id_1 id_2 id_3 parity 
save "$TEMP/TEMP_3.dta", replace

******************************************************************************************************************************************************
* CONSOLIDATE                                                                                                                                        * 
******************************************************************************************************************************************************

use "$TEMP/TEMP_2M.dta", clear 
append using "$TEMP/TEMP_2F.dta"
merge 1:1 id_1 id_2 id_3 using ".\TEMP\TEMP_2.dta"
keep if _merge==3
drop _*
merge 1:1 id_1 id_2 id_3 using ".\TEMP\TEMP_3.dta"
drop _*

* Merge geographical variables

rename prov2011 _prov2011
rename prov1996 _prov1996

merge m:1 psu using "$AUXILIARY_2"     
drop if _merge == 2
drop _merge
rename _prov2011 prov2011
rename _prov1996 prov1996

destring dist1996, replace
destring dist2001, replace
destring dist2011, replace
destring prov2001, replace


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
drop id_1 id_2 id_3

* Add individual identifier
gen pid = _n
label var pid "Individual ID"

* Add source identifier
gen source = "DHS 2016"
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

use hv109_* hv009 hhid using "$DATASET_4", clear

* Using household roster educational attainment variable. Max number of household members in DHS2016 is 24.

forvalues i=1/9 {
	gen primaryed_`i'=.
	replace primaryed_`i'=1 if hv109_0`i'==2 | hv109_0`i'==3 | hv109_0`i'==4 | hv109_0`i'==5 
	replace primaryed_`i'=0 if hv109_0`i'==0 | hv109_0`i'==1
	label var primaryed_`i' "Completed primary school household member `i'"
	label values primaryed_`i' vyesno
}

forvalues i=10/24 {
	gen primaryed_`i'=.
	replace primaryed_`i'=1 if hv109_`i'==2 | hv109_`i'==3 | hv109_`i'==4 | hv109_`i'==5 
	replace primaryed_`i'=0 if hv109_`i'==0 | hv109_`i'==1
	label var primaryed_`i' "Completed primary school household member `i'"
	label values primaryed_`i' vyesno
}


egen edunum = rownonmiss(primaryed_*)
egen primaryed_hh = rowmax(primaryed_*)

* Recoding to missing if no household member has completed primary school but some household members have missing education. 
* hv009 is number of houshold members. 

replace primaryed_hh=. if primaryed_hh==0 & edunum < hv009
gen edu_deprived=.
replace edu_deprived=1 if primaryed_hh==0
replace edu_deprived=0 if primaryed_hh==1
label var edu_deprived "No household member has completed primary school"
label values edu_deprived vyesno
keep edu_deprived hhid

* Save temporary
save "$TEMP/TEMP_5A.dta", replace

use "$TEMP/TEMP_4.dta", clear
duplicates drop hhid, force
rename hhid hhid_num
decode hhid_num, gen(hhid)
merge 1:1 hhid using "$TEMP/TEMP_5A.dta"
keep if _merge==3
drop _merge
drop hhid
rename hhid_num hhid 

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

* Delete value labels
label drop _all

* Label the datset
label data "DHS 2016 - Core Variables - $S_DATE"


* Save & erase temporary files  
save "$OUT/DHS2016.dta", replace
erase "$TEMP/TEMP_1.dta"
erase "$TEMP/TEMP_1A.dta"
erase "$TEMP/TEMP_2.dta"
erase "$TEMP/TEMP_2M.dta"
erase "$TEMP/TEMP_2F.dta"
erase "$TEMP/TEMP_3.dta"
erase "$TEMP/TEMP_4.dta"
erase "$TEMP/TEMP_5A.dta"
erase "$TEMP/TEMP_5B.dta"
