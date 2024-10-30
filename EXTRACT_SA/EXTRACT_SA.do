******************************************************************************************************************************************************
* EXPOSE - DATA EXTRACTION & CONSOLIDATION                                                                                                           *
*                                                                                                                                                    *
* INPUT: Datafiles for SADHS1998, SADHS2003, SADHS2016, NIDS wave 1-5, SAGE 2007, SAGE 2014, SANHNANES2012                                           *
* OUTPUT: Consolidated, harmonised EXPOSE SOUTH AFRICA DATASET (EXPOSE_SA.dta)                                                                       *
*                                                                                                                                                    *
* Annibale Cois (acois@sun.ac.za)                                                                                                                    *
* Version 1.1                                                                                                                                        *
******************************************************************************************************************************************************

clear
set more off

******************************************************************************************************************************************************
* LOCATION OF FILES AND FOLDERS                                                                                                                      *
*                                                                                                                                                    *
* [BASE DIRECTORY]                                                                                                                                   *
*      [DHS]                                                                                                                                         *                                                                                                                                                                                                                                                  
*        [Datafiles]                                                                                                                                 *
*  	 	 	ZAHR31FL.dta                                                                                                                             * 
*        	ZAAH33FL.dta                                                                                                                             *
*  		 	hholdout.dta                                                                                                                             *
*  		 	adultout.dta                                                                                                                             *
*        	personsout.dta                                                                                                                           *
*  		 	ZAPR71FL.dta                                                                                                                             *
*   	 	ZAAHM71FL.dta                                                                                                                            *
*    	 	ZAAHW71FL.dta                                                                                                                            *
*   	 	ZAIR71FL.dta                                                                                                                             *
*     	 	ZAHR71FL.dta                                                                                                                             *
*                                                                                                                                                    *
*       [NIDS]                                                                                                                                       *
*         [Datafiles]                                                                                                                                *
*        	Adult_W1_Anon_V7.0.0.dta                                                                                                                 *
*    		Adult_W1_Anon_V7.0.0.dta                                                                                                                 *
*   		indderived_W1_Anon_V7.0.0.dta                                                                                                            *
*   		HHQuestionnaire_W1_Anon_V7.0.0.dta                                                                                                       *
*    		hhderived_W1_Anon_V7.0.0.dta                                                                                                             *
*   		HouseholdRoster_W1_Anon_V7.0.0.dta                                                                                                       *
*   		Adult_W2_Anon_V4.0.0.dta                                                                                                                 *         
*   		indderived_W2_Anon_V4.0.0.dta                                                                                                            *     
*   		HHQuestionnaire_W2_Anon_V4.0.0.dta                                                                                                       *
*   		hhderived_W2_Anon_V4.0.0.dta                                                                                                             *     
*   		Link_File_W2_Anon_V4.0.0.dta                                                                                                             *       
*  			Adult_W3_Anon_V3.0.0.dta                                                                                                                 *           
*   		indderived_W3_Anon_V3.0.0.dta                                                                                                            *      
*   		HHQuestionnaire_W3_Anon_V3.0.0.dta                                                                                                       *
*   		hhderived_W3_Anon_V3.0.0.dta                                                                                                             *       
*   		Link_File_W3_Anon_V3.0.0.dta                                                                                                             *      
*   		Adult_W4_Anon_V2.0.0.dta                                                                                                                 *           
*  			indderived_W4_Anon_V2.0.0.dta                                                                                                            *      
*   		HHQuestionnaire_W4_Anon_V2.0.0.dta                                                                                                       *
*  			hhderived_W4_Anon_V2.0.0.dta                                                                                                             *       
*  			Link_File_W4_Anon_V2.0.0.dta                                                                                                             *      
*   		Adult_W5_Anon_V1.0.0.dta                                                                                                                 *          
*   		indderived_W5_Anon_V1.0.0.dta                                                                                                            *   
*  			HHQuestionnaire_W5_Anon_V1.0.0.dta                                                                                                       * 
*  			hhderived_W5_Anon_V1.0.0.dta                                                                                                             *
*  			Link_File_W5_Anon_V1.0.0.dta                                                                                                             * 
*       [SAGE]                                                                                                                                       *
*         [Datafiles]                                                                                                                                *
*         	SouthAfricaHHData.dta	                                                                                                                 *    
*   		SouthAfricaINDData.dta                                                                                                                   *         
*   		SouthAfricaINDDataW2.dta                                                                                                                 *
*       [SANHANES]                                                                                                                                   *
*         [Datafiles]                                                                                                                                *
*           SANHANES Visiting point data_anon.dta                                                                                                    *  
*  		    SANHANES Individual clinical_anonymised.dta	                                                                                             *
*   		SANHANES_WB_NEW_all_anonymised.dta                                                                                                       *  	
*    		SANHANES2011_12_Adult_Exam.csv                                                                                                           *
*                                                                                                                                                    *
******************************************************************************************************************************************************

* BASE DATA DIRECTORY 
*global BASEDIR "********************"      // Insert here the path of the base directory 
global BASEDIR "C:/Users/acois/Stellenbosch University/ExPoSE - Documents/General/Data"

* OUTPUT DIRECTORY
global OUT "./OUT"

* TEMP DIRECTORY 
global TEMP "./TEMP"	

* AUX DATA DIRECTORY
global AUX "./AUXILIARY"

******************************************************************************************************************************************************
* CLEANING PARAMETERS                                                                                                                                * 
******************************************************************************************************************************************************

global HEIGHT_MIN = 120
global HEIGHT_MAX = 220

global WEIGHT_MIN_MALES = 35
global WEIGHT_MIN_FEMALES = 25
global WEIGHT_MAX = 250

global WAIST_MIN = 30
global WAIST_MAX = 220

global HIP_MIN = 40
global HIP_MAX = 230

global ARM_MIN = 6
global ARM_MAX = 50

global SBP_MIN = 60
global SBP_MAX = 270

global DBP_MIN = 30
global DBP_MAX = 150

global BPDIFF_MIN = 15

global RHR_MIN = 20
global RHR_MAX = 250

global BMI_MIN = 10
global BMI_MAX = 131

global HBA1C_MIN = 3.5
global HBA1C_MAX = 200

global CHOLTOT_MIN = 1.75
global CHOLTOT_MAX = 20

global CHOLHDL_MIN = 0.4
global CHOLHDL_MAX = 5

global CHOLLDL_MIN = 0.1
global CHOLLDL_MAX = 16

global TRIG_MIN = 0.1
global TRIG_MAX = 16

global HB_MIN = 5
global HB_MAX = 20

******************************************************************************************************************************************************
* EXTRACT                                                                                                                                            * 
******************************************************************************************************************************************************

do "DHS 1998.do"
do "DHS 2003.do"
do "DHS 2016.do"
do "SANHANES 2012.do"
do "NIDS 2008.do"
do "NIDS 2010-11.do"
do "NIDS 2012.do"
do "NIDS 2014-15.do"
do "NIDS 2017.do"
do "SAGE 2007.do"
do "SAGE 2014.do"

******************************************************************************************************************************************************
* APPEND                                                                                                                                             * 
******************************************************************************************************************************************************

use "$TEMP/DHS1998.dta", clear 
append using "$TEMP/DHS2003.dta"
append using "$TEMP/DHS2016.dta"
append using "$TEMP/SANHANES2012.dta"
append using "$TEMP/NIDS2008.dta"
append using "$TEMP/NIDS2010-11.dta"
append using "$TEMP/NIDS2012.dta"
append using "$TEMP/NIDS2014-15.dta"
append using "$TEMP/NIDS2017.dta"
append using "$TEMP/SAGE2007.dta"
append using "$TEMP/SAGE2014.dta"

******************************************************************************************************************************************************
* CLEANING ANTHROPOMETRIC VARIABLES                                                                                                                  * 
******************************************************************************************************************************************************

* Height 
replace height1=. if height1<$HEIGHT_MIN | height1>$HEIGHT_MAX
replace height2=. if height2<$HEIGHT_MIN | height2>$HEIGHT_MAX 
replace height3=. if height3<$HEIGHT_MIN | height3>$HEIGHT_MAX

* Weight
replace weight1=. if weight1<$WEIGHT_MIN_FEMALES & sex==2  
replace weight1=. if weight1<$WEIGHT_MIN_MALES & sex==1  
replace weight1=. if weight1>$WEIGHT_MAX  
replace weight2=. if weight2<$WEIGHT_MIN_FEMALES & sex==2  
replace weight2=. if weight2<$WEIGHT_MIN_MALES & sex==1  
replace weight2=. if weight2>$WEIGHT_MAX  
replace weight3=. if weight3<$WEIGHT_MIN_FEMALES & sex==2  
replace weight3=. if weight3<$WEIGHT_MIN_MALES & sex==1 
replace weight3=. if weight3>$WEIGHT_MAX  

* Waist circumference 
replace waist1=. if waist1<$WAIST_MIN | waist1>$WAIST_MAX
replace waist2=. if waist2<$WAIST_MIN | waist2>$WAIST_MAX 
replace waist3=. if waist3<$WAIST_MIN | waist3>$WAIST_MAX 

* Hip circumference 
replace hip1=. if hip1<$HIP_MIN | hip1>$HIP_MAX  
replace hip2=. if hip2<$HIP_MIN | hip2>$HIP_MAX  
replace hip3=. if hip3<$HIP_MIN | hip3>$HIP_MAX  

* Arm circumference 
replace arm1=. if arm1<$ARM_MIN | arm1>$ARM_MAX  
replace arm2=. if arm2<$ARM_MIN | arm2>$ARM_MAX 
replace arm3=. if arm3<$ARM_MIN | arm3>$ARM_MAX 

* Blood pressure 
replace sbp1=. if sbp1<$SBP_MIN | sbp1>$SBP_MAX 
replace sbp2=. if sbp2<$SBP_MIN | sbp2>$SBP_MAX 
replace sbp3=. if sbp3<$SBP_MIN | sbp3>$SBP_MAX
replace dbp1=. if dbp1<$DBP_MIN | dbp1>$DBP_MAX 
replace dbp2=. if dbp2<$DBP_MIN | dbp2>$DBP_MAX
replace dbp3=. if dbp3<$DBP_MIN | dbp3>$DBP_MAX 

gen diff1 = sbp1-dbp1
gen diff2 = sbp2-dbp2
gen diff3 = sbp3-dbp3
replace sbp1=. if diff1<$BPDIFF_MIN
replace dbp1=. if diff1<$BPDIFF_MIN
replace sbp2=. if diff2<$BPDIFF_MIN
replace dbp2=. if diff2<$BPDIFF_MIN
replace sbp3=. if diff3<$BPDIFF_MIN
replace dbp3=. if diff3<$BPDIFF_MIN
drop diff1 diff2 diff3

* Resting Heart Rate 
replace rhr1=. if rhr1<$RHR_MIN | rhr1>$RHR_MAX
replace rhr2=. if rhr2<$RHR_MIN | rhr2>$RHR_MAX 
replace rhr3=. if rhr3<$RHR_MIN | rhr3>$RHR_MAX  
		
* Laboratory	
	
replace hb=. if hb<$HB_MIN | hb>$HB_MAX
replace HbA1c=. if hb<$HBA1C_MIN | HbA1c>$HBA1C_MAX
replace chol_tot=. if chol_tot<$CHOLTOT_MIN | chol_tot>$CHOLTOT_MAX
replace chol_hdl=. if chol_hdl<$CHOLHDL_MIN | chol_hdl>$CHOLHDL_MAX

gen impdiff = 0
replace impdiff = 1 if (chol_tot < . & chol_hdl <.) & (chol_tot < chol_hdl) 
replace chol_tot = . if impdiff == 1
replace chol_hdl = . if impdiff == 1
drop impdiff

replace chol_ldl=. if chol_ldl<$CHOLLDL_MIN | chol_ldl>$CHOLLDL_MAX
replace trig=. if trig<$TRIG_MIN | trig>$TRIG_MAX
		
******************************************************************************************************************************************************
* DERIVED VARIABLES, FURTHER RECODE                                                                                                                  * 
******************************************************************************************************************************************************

* Encode source dataset
rename source x
encode x, gen(y)
recode y (1=1)(2=2)(9=3)(4=4)(5=5)(6=6)(11=7)(10=8)(7=9)(3=10)(8=11), gen(source)
label val source vsource
label var source "Source dataset"
drop x y

* Replace bpmed = 0 for people with no previous hypertension diagnosis
replace bpmed = 0 if diag_hbp == 0		

* Set pregnant = "no" for women outside resproductive age 
replace currpreg = 0 if age > 49 & sex == 2 & (source !=  2 & source !=  3 & source !=  7 & source !=  8)

* Impute race 
sort hhid race
by hhid: carryforward race, gen(race_imp) 
label var race_imp "Race - Imputed"
label val race_imp vrace

* Province (1996/2001 boundaries)
gen prov = prov1996
replace prov = prov2001 if prov>=.
label var prov "Province (1996/2001 boundaries)"

* Averaged anthropometric
egen height = rowmean(height1 height2 height3)
label var height "Height [cm] - Average of available readings"
egen weight = rowmean(weight1 weight2 weight3)
label var weight "Weight [cm] - Average of available readings"
egen hip = rowmean(hip1 hip2 hip3)
label var hip "Hip circumference [cm] - Average of available readings"
egen waist = rowmean(waist1 waist2 waist3)
label var waist "Waist circumference [cm] - Average of available readings"
egen arm = rowmean(arm1 arm2 arm3)
label var arm "Arm circumference [cm] - Average of available readings"
egen sbp = rowmean(sbp1 sbp2 sbp3)
label var sbp "Systolic Blood Pressure [mmHg] - Average of available readings"
egen dbp = rowmean(dbp1 dbp2 dbp3)
label var dbp "Distolic Blood Pressure [mmHg] - Average of available readings"
egen rhr = rowmean(rhr1 rhr2 rhr3)
label var rhr "Resting Heart Rate [bpm] - Average of available readings"
gen bmi = weight/(height/100)^2
replace bmi=. if bmi<$BMI_MIN | bmi>$BMI_MAX
label var bmi "Body Mass Index [kg/m2]"
egen bmicat = cut(bmi), at(0, 18.5, 25, 30, 35, 40, 45, 200) icodes
replace bmicat = bmicat + 1
label var bmicat "Body Mass Index categories"
label val bmicat vbmicat

egen lungmed=rowmax(asthmed emphmed)
label val lungmed vyesno
label var lungmed "Current use of asthma, emphysema, bronchitis or chronic lung disease medication - self"
drop asthmed emphmed

rename asthmed_coded lungmed_coded

* replace aweigjht_phys and aweight_lab with aweight for all surveys excluded SANHNANES

replace aweight_phys = aweight if source != 7
replace aweight_lab = aweight if source != 7

******************************************************************************************************************************************************
* ENSURE UNIQUE NUMBERING OF HHIDs, CLUSTERs AND STRATA ACROSS DATASETS                                                                              * 
* ENSURE UNIQUE PID NUMBER FOR UNIQUE INDIVIDUALS                                                                                                    *
* CREATE CONSISTENT NUMBERING SYSTEM                                                                                                                 *
******************************************************************************************************************************************************

* DHS 1998
tabstat pid hhid psu  stratum if source == 1, stats(min max)
replace hhid = hhid - 1 if source == 1

replace pid = pid + 1*100000 if source == 1
replace psu = psu + 1*100000 if source == 1
replace hhid = hhid + 1*100000 if source == 1
replace stratum = stratum + 1*100000 if source == 1

* DHS 2003
tabstat pid hhid psu  stratum if source == 2, stats(min max)
replace hhid = hhid - 4 if source == 2

replace pid = pid + 2*100000 if source == 2
replace psu = psu + 2*100000 if source == 2
replace hhid = hhid + 2*100000 if source == 2
replace stratum = stratum + 2*100000 if source == 2

* SAGE 
tabstat pid hhid psu stratum if source == 3 | source == 8, stats(min max)
replace hhid = hhid - 1153 if source == 3 | source == 8
tostring hhid, gen(hhida)
encode hhida if source == 3 | source == 8, gen(hhidb)
label val hhidb
replace hhid = hhidb if source == 3 | source == 8
drop hhida
drop hhidb
replace psu = psu - 10200003 if source == 3 | source == 8
tostring psu, gen(psua)
encode psua if source == 3 | source == 8, gen(psub)
label val psub
replace psu = psub if source == 3 | source == 8
drop psua
drop psub
tostring pid, gen(pida)
encode pida if source == 3 | source == 8, gen(pidb)
label val pidb
replace pid = pidb if source == 3 | source == 8
drop pida
drop pidb

replace pid = pid + 3*100000 if source == 3 | source == 8
replace psu = psu + 3*100000 if source == 3 | source == 8
replace hhid = hhid + 3*100000 if source == 3 | source == 8
replace stratum = stratum + 3*100000 if source == 3 | source == 8

* NIDS
tabstat pid hhid psu  stratum if source == 4 | source == 5 | source == 6 | source == 9 | source == 11, stats(min max)
replace hhid = hhid - 101011 if source == 4 | source == 5 | source == 6 | source == 9 | source == 11
tostring hhid, gen(hhida)
encode hhida if source == 4 | source == 5 | source == 6 | source == 9 | source == 11, gen(hhidb)
label val hhidb
replace hhid = hhidb if source == 4 | source == 5 | source == 6 | source == 9 | source == 11
drop hhida
drop hhidb
replace psu = psu - 1000 if source == 4 | source == 5 | source == 6 | source == 9 | source == 11
replace pid = pid - 301011 if source == 4 | source == 5 | source == 6 | source == 9 | source == 11

replace pid = pid + 4*100000 if source == 4 | source == 5 | source == 6 | source == 9 | source == 11
replace psu = psu + 4*100000 if source == 4 | source == 5 | source == 6 | source == 9 | source == 11
replace hhid = hhid + 4*100000 if source == 4 | source == 5 | source == 6 | source == 9 | source == 11
replace stratum = stratum + 4*100000 if source == 4 | source == 5 | source == 6 | source == 9 | source == 11

* SANHANES 2012
tabstat pid hhid psu  stratum if source == 7, stats(min max)
replace hhid = hhid-10001 if source == 7
tostring psu, gen(psu5a)
encode psu5a if source == 7, gen(psu5b)
label val psu5b
replace psu = psu5b if source == 7
drop psu5a
drop psu5b
replace pid = pid + 5*100000 if source == 7
replace psu = psu + 5*100000 if source == 7
replace hhid = hhid + 5*100000 if source == 7
replace stratum = stratum + 5*100000 if source == 7

* DHS 2016
tabstat pid hhid psu  stratum if source == 10, stats(min max)
replace pid = pid + 6*100000 if source == 10
replace psu = psu + 6*100000 if source == 10
replace hhid = hhid + 6*100000 if source == 10
replace stratum = stratum + 6*100000 if source == 10

******************************************************************************************************************************************************
* DROP OBSERVATIONS WITH MISSING OR "OTHER" (IMPUTED) RACE                                                                                           * 
******************************************************************************************************************************************************

drop if race_imp == 9999 | race_imp>=.

save "$TEMP/PRECALIB.dta", replace

******************************************************************************************************************************************************
* ADD MEDIAN YEAR OF DATA COLLECTION                                                                                                                 * 
******************************************************************************************************************************************************
use "$TEMP/PRECALIB.dta", clear 

gen year = .

* Loop over surveys 
foreach s of numlist  1 2 3 4 5 6 7 8 9 10 11 {
preserve
	use "$TEMP/PRECALIB.dta", clear 
	keep if source == `s'								
	* Extract median year of data collection
	_pctile inty
	global YEAR = int(r(r1))
restore
replace year = $YEAR if source == `s'
}
    
* Add temporary unique record id
gen RID = _n

* Save intermediate dataset (2)
label data "Intermediate (2A)"
capture drop _*
save "$TEMP/BASE_CORE_2A.dta", replace

******************************************************************************************************************************************************
* ASSET INDEX                                                                                                                                        * 
******************************************************************************************************************************************************

* Loop over surveys 

foreach s of numlist 1/7 9 10 11 {
	di "**************** Calculating base asset index: source = `s'"	
	use "$TEMP/BASE_CORE_2A.dta", clear 
	keep if source == `s'						

	* Asset index at household level, with multiple imputation to deal with missing data)
	preserve
		keep hhid hweight w_*
		duplicates drop
	
		foreach v of var w_* {
			qui tab `v'
			if r(r) < 2 {
				drop `v'
			}
		}
	
	qui	misstable summarize w_* 
	local amiss =  r(N_eq_dot) <. | r(N_gt_dot) <.
	
	if (`amiss' > 0) {
	    * Multiple imputation settings
	    mi set mlong
		mi register imputed w_* 
		mi register regular hhid hweight 
	
		mi impute chained (pmm, knn(5)) w_* , add(5) rseed (270962) chaindots savetrace(trace,replace) 
		global nimp = r(M)
		label data "Imputed (1)"
		save "$TEMP/BASE_IMP.dta", replace 
    
		mi extract 1 
		qui pca w_*
		qui predict assindex_1, score
		keep hhid assindex_1
		save "$TEMP/BASE_ASSINDEX.dta", replace 
		
		foreach i of numlist 2(1)$nimp {
		di "`i'"
			use "$TEMP/BASE_IMP.dta", clear 
			mi extract `i' 
			qui pca w_*
			qui predict assindex_`i', score
			keep hhid assindex_`i'
			merge 1:1 hhid using "$TEMP/BASE_ASSINDEX.dta"
			drop _*
			save "$TEMP/BASE_ASSINDEX.dta", replace 
		}
		egen assindex = rowmean(assindex_*)
		drop assindex_*
		save "$TEMP/BASE_ASSINDEX.dta", replace 
	}
	else {
		qui pca w_*
		qui predict assindex, score
		keep hhid assindex
		save "$TEMP/BASE_ASSINDEX.dta", replace 
	}
restore
merge m:1 hhid using "$TEMP/BASE_ASSINDEX.dta"
	
	* Rename assindex
rename assindex hwindex	
    
	* Generate quintiles
xtile hwindex_quint = hwindex [weight=hweight], nq(5)
label val hwindex_quint vhwindex_quint

	* Save temporary
save "$TEMP/TEMP_`s'.dta", replace
}


* Subset SAGE 2014 (no asset index)
use "$TEMP/BASE_CORE_2A.dta", clear 
keep if source == 8	 
	* Save temporary
save "$TEMP/TEMP_8.dta", replace

* Append datasets 
use "$TEMP/TEMP_1.dta", clear
foreach s of numlist 2/11 {
  append using "$TEMP/TEMP_`s'.dta"
}

* Drop w_* assets 
drop w_*

* Delete temporary 
foreach s of numlist 1/11 {
 erase "$TEMP/TEMP_`s'.dta"
}
erase "$TEMP/BASE_ASSINDEX.dta"
erase "$TEMP/BASE_IMP.dta"
erase "trace.dta"
* Save intermediate dataset (3)
label data "Intermediate (3)"
capture drop _*
save "$TEMP/BASE_CORE_3.dta", replace

******************************************************************************************************************************************************
* HARMONIZE ASSET INDICES (generate CWI)                                                                                                             * 
******************************************************************************************************************************************************

use "$TEMP/BASE_CORE_3.dta", clear

duplicates drop hhid, force

* Anchor variables 

    * Low wealth
gen anchor_1 = dep1plus 
gen anchor_2 = dep2plus 
gen anchor_3 = dep3plus 
gen anchor_4 = dep4plus 
    * Middle/high wealth 
gen anchor_5 = ass_fridge
gen anchor_6 = ass_tv
gen anchor_7 = ass_car_truck
gen anchor_8 = ass_computer

gen cwi = .

* Baseline survey: NIDS 2008 

proportion anchor_4 [pweight = hweight] if source == 4
matrix EST = r(table)
local p4 = EST[1,2]*100

proportion anchor_3 [pweight = hweight] if source == 4
matrix EST = r(table)
local p3 = EST[1,2]*100

proportion anchor_2 [pweight = hweight] if source == 4
matrix EST = r(table)
local p2 = EST[1,2]*100

proportion anchor_1 [pweight = hweight] if source == 4
matrix EST = r(table)
local p1 = EST[1,2]*100

_pctile hwindex if source == 4, percentiles(`p4' `p3' `p2' `p1')

local a4 = r(r1)
local a3 = r(r2)
local a2 = r(r3)
local a1 = r(r4)

logit anchor_5 hwindex [pweight = hweight] if source == 4
matrix EST = r(table)
local a5 = -EST[1,2]/EST[1,1]

logit anchor_6 hwindex [pweight = hweight] if source == 4
matrix EST = r(table)
local a6 = -EST[1,2]/EST[1,1]

logit anchor_7 hwindex [pweight = hweight] if source == 4
matrix EST = r(table)
local a7 = -EST[1,2]/EST[1,1]

logit anchor_8 hwindex [pweight = hweight] if source == 4
matrix EST = r(table)
local a8 = -EST[1,2]/EST[1,1]


matrix CUTPOINTS_BASE = (`a1',0 \ `a2',0 \ `a3',0 \ `a4',0 \ `a5',0 \ `a6',0 \ `a7',0 \ `a8',0 )

replace cwi = hwindex if source == 4

* Rescale the index in the remaining surveys

foreach s of numlist 1/3 5/7 9/11 {
    di "******************* Adapting asset index for survey `s'"

	proportion anchor_4 [pweight = hweight] if source == `s'
	matrix EST = r(table)
	local p4 = EST[1,2]*100

	proportion anchor_3 [pweight = hweight] if source == `s'
	matrix EST = r(table)
	local p3 = EST[1,2]*100

	proportion anchor_2 [pweight = hweight] if source == `s'
	matrix EST = r(table)
	local p2 = EST[1,2]*100

	proportion anchor_1 [pweight = hweight] if source == `s'
	matrix EST = r(table)
	local p1 = EST[1,2]*100

	_pctile hwindex if source == 4, percentiles(`p4' `p3' `p2' `p1')

	local b4 = r(r1)
	local b3 = r(r2)
	local b2 = r(r3)
	local b1 = r(r4)

	logit anchor_5 hwindex [pweight = hweight] if source == `s'
	matrix EST = r(table)
	local b5 = -EST[1,2]/EST[1,1]

	logit anchor_6 hwindex [pweight = hweight] if source == `s'
	matrix EST = r(table)
	local b6 = -EST[1,2]/EST[1,1]

	logit anchor_7 hwindex [pweight = hweight] if source == `s'
	matrix EST = r(table)
	local b7 = -EST[1,2]/EST[1,1]
	
	logit anchor_8 hwindex [pweight = hweight] if source == `s'
	matrix EST = r(table)
	local b8 = -EST[1,2]/EST[1,1]

	matrix CUT = CUTPOINTS_BASE
	matrix CUT[1,2] = `b1'
	matrix CUT[2,2] = `b2'
	matrix CUT[3,2] = `b3'
	matrix CUT[4,2] = `b4'
	matrix CUT[5,2] = `b5'
	matrix CUT[6,2] = `b6'
	matrix CUT[7,2] = `b7'
    matrix CUT[8,2] = `b8'
		
	svmat CUT 
	regress CUT1 CUT2
	matrix EST = e(b)
	local beta = EST[1,1]
	local alpha = EST[1,2]

	replace cwi = hwindex*`beta' + `alpha' if source == `s'

	drop CUT1 CUT2
}

keep hhid cwi
* Save temp
save "$TEMP/CWI.dta", replace

* Merge
use "$TEMP/BASE_CORE_3.dta", clear
merge m:1 hhid using "$TEMP/CWI.dta"
erase "$TEMP/CWI.dta"

* Save intermediate dataset (4)
label data "Intermediate (4)"
capture drop _*
save "$TEMP/BASE_CORE_4.dta", replace

******************************************************************************************************************************************************
* OTHER DERIVED                                                                                                                                      * 
******************************************************************************************************************************************************

egen sbp_mean2 = rowmean(sbp2 sbp3)
egen dbp_mean2 = rowmean(dbp2 dbp3)
egen rhr_mean2 = rowmean(rhr2 rhr3)

rename sbp sbp_mean1
rename dbp dbp_mean1
rename rhr rhr_mean1

recode age (15/19=1) (20/24=2) (25/29=3) (30/34=4) (35/39=5) (40/44=6) (45/49=7) (50/54=8) (55/59=9) (60/64=10)(65/69=11) (70/74=12)  ///
             (75/79=13), gen(agecat1)
replace agecat1=14 if age>=80
replace agecat1=. if age==.
label val agecat1 vagecat1
 
recode age (15/19=1) (20/29=2) (30/39=3) (40/49=4) (50/59=5) (60/69=6) (70/79=7), gen(agecat2)
replace agecat2=8 if age>=80
replace agecat2=. if age==.
label val agecat2 vagecat2

******************************************************************************************************************************************************
* DROP UNUSED VARIABLES                                                                                                                              * 
******************************************************************************************************************************************************

drop intd ass_donkey_horse ass_sheep_cattle ass_livestock ass_elestv ass_gasstv ass_parstv ass_sheep_cattle_nc ass_donkey_horse_nc 
drop alcbing alcf alcq main_place
drop ea_code hhid2 income mdist1996 municipality prov qdist qeanum sub_place 
drop wallmaterial2 floormaterial2
drop housedeaths2
drop heartmed

******************************************************************************************************************************************************
* GEOGRAPHIC                                                                                                                                         * 
* CONSOLIDATE CODES OF CROSS_BORDER DISTRICTS (2001)                                                                                                 *
******************************************************************************************************************************************************

replace dist2001 = 76 if dist2001 == 676 | dist2001 == 776
replace dist2001 = 81 if dist2001 == 681 | dist2001 == 381
replace dist2001 = 82 if dist2001 == 782 | dist2001 == 882
replace dist2001 = 83 if dist2001 == 883 | dist2001 == 983
replace dist2001 = 84 if dist2001 == 884 | dist2001 == 984
replace dist2001 = 88 if dist2001 == 788 | dist2001 == 688
replace dist2001 = 9 if dist2001 == 389 | dist2001 == 689

******************************************************************************************************************************************************
* ADD PREFIXES AND FINAL CONSOLIDATION                                                                                                               * 
* HOUSEHOLD PROPERTIES: hh_                                                                                                                          *
******************************************************************************************************************************************************

rename totrooms hh_totrooms
rename sleeprooms hh_sleeprooms
rename ntotrooms hh_ptotrooms
rename nsleeprooms hh_psleeprooms 
rename dwelling hh_dwellingtype
rename wallmaterial hh_wallmaterial
rename floormaterial hh_floormaterial
rename roofmaterial hh_roofmaterial
rename roof_wall_1 hh_roof_wall_1
rename roof_wall_2 hh_roof_wall_2
rename roof_wall_3 hh_roof_wall_3
rename roof_wall_4 hh_roof_wall_4
rename roof_wall_5 hh_roof_wall_5
rename roof_wall_9999 hh_roof_wall_9999
rename cookingfuel hh_cookingfuel
rename heatingfuel hh_heatingfuel
rename cook_elec hh_cook_elec
rename cook_gas hh_cook_gas
rename cook_par hh_cook_par
rename cook_wood hh_cook_wood 
rename cook_coal hh_cook_coal 
rename cook_dung hh_cook_dung
rename cook_other hh_cook_other 
rename water hh_water
rename toilet hh_toilet 
rename sharedtoilet hh_sharedtoilet 
rename refuseremoved hh_refuseremoved
rename hsize hh_size
rename housedeaths hh_deaths12mo 
rename ass_* hh_ass_*
rename hwindex hh_windex
rename hwindex_quint hh_windex_quint
rename cwi hh_cwi
rename hhincome hh_income
rename hhincome_quint hh_income_quint
rename ownhome hh_ownhome
rename recgrant hh_recgrant
rename govsupport hh_govsupport
rename foodinsec hh_foodinsec
rename foodinsec_adult hh_foodinsec_adult
rename foodinsec_child hh_foodinsec_child

rename edu_deprived hh_edu_deprived 
rename unimp_toilet hh_unimp_toilet
rename unimp_water hh_unimp_water
rename unimp_cooking hh_unimp_cooking
rename dep1plus hh_dep1plus
rename dep2plus hh_dep2plus
rename dep3plus hh_dep3plus
rename dep4plus hh_dep4plus

label val hh_income_quint vquint
label val hh_windex_quint vquint
label val age 
label val hh_income
label val weight2 
label val weight3
label val hhid

notes drop _all

rename dist1996 dist1996_name
rename dist2001 dist2001_name
rename dist2011 dist2011_name
label val dist1996_name vdist1996_name
label val dist2001_name vdist2001_name
label val dist2011_name vdist2011_name

gen dist1996_code = dist1996_name
gen dist2001_code = dist2001_name
gen dist2011_code = dist2011_name
label val dist1996_code vdist1996_code
label val dist2001_code vdist2001_code
label val dist2011_code vdist2011_code
rename prov1996 prov1996_name
rename prov2001 prov2001_name
rename prov2011 prov2011_name
gen prov1996_code = prov1996_name
gen prov2001_code = prov2001_name
gen prov2011_code = prov2011_name
label val prov1996_code vprov1996_code
label val prov2001_code vprov2001_code
label val prov2011_code vprov2011_code
label val prov1996_name vprov1996_name
label val prov2001_name vprov2001_name
label val prov2011_name vprov2011_name

******************************************************************************************************************************************************
* VARIABLE LABELS                                                                                                                                    * 
******************************************************************************************************************************************************

* Data Source
label var source "Source dataset"

* Identification and sampling
label var hhid "Household unique identifier"
label var pid "Individual unique identifier"
label var psu "Primary Sampling Unit"
label var stratum "Stratum"
label var aweight "Sampling weight - Interview"
label var aweight_phys "Sampling weight - Physical examination"
label var aweight_lab "Sampling weight - Laboratory"

* Geographic
label var prov1996_name "Province - 1996 boundaries"
label var prov2001_name "Province - 2001 boundaries"
label var prov2011_name "Province - 2011 boundaries"
label var dist1996_name "District - 1996 boundaries"
label var dist2001_name "District - 2001 boundaries"
label var dist2011_name "District - 2011 boundaries"

label var prov1996_code "Province - 1996 boundaries"
label var prov2001_code "Province - 2001 boundaries"
label var prov2011_code "Province - 2011 boundaries"
label var dist1996_code "District Council - 1996 boundaries"
label var dist2001_code "District Council - 2001 boundaries"
label var dist2011_code "District Council - 2011 boundaries"

label var geotype2 "Geotype - urban/rural"
label var geotype4 "Geotype - 4 categories"

* Time
label var intm "Month of interview"
label var inty "Year of interview"

label var year "Year of data collection - survey median"

* Household characteristics
label var hh_size "Household size"
	* Dwelling
label var hh_totrooms "Number of rooms in dwelling"
label var hh_sleeprooms "Number of rooms for sleeping in dwelling"
label var hh_ptotrooms "People per room"
label var hh_psleeprooms "People per sleeping room"
label var hh_dwellingtype "Dwelling type"
label var hh_wallmaterial "Wall material"
label var hh_floormaterial "Floor material"
label var hh_roofmaterial "Roof material"
label var hh_roof_wall_1 "Roof, wall material: Mud/thatching/wattle and daub"
label var hh_roof_wall_2 "Roof, wall material: Mud and cement mix"
label var hh_roof_wall_3 "Roof, wall material: Corrugated iron/zinc"
label var hh_roof_wall_4 "Roof, wall material: Plastic/cardboard"
label var hh_roof_wall_5 "Roof, wall material: Brick/cement/prefab/plaster"
label var hh_roof_wall_9999 "Roof, wall material: other"
label var hh_cookingfuel "Main cooking fuel"
label var hh_heatingfuel "Main heating fuel"
label var hh_cook_elec "Cooking fuel: Electricity"
label var hh_cook_gas "Cooking fuel: Gas"
label var hh_cook_par "Cooking fuel: Paraffin"
label var hh_cook_wood "Cooking fuel: Wood"
label var hh_cook_coal "Cooking fuel: Coal"
label var hh_cook_dung "Cooking fuel: Animal dung"
label var hh_cook_other "Cooking fuel: Other"
label var hh_water "Source of drinking water"
label var hh_toilet "Toilet facilities"
label var hh_sharedtoilet "Shared toilet facility"
label var hh_refuseremoved "Refuse removed weekly by local authorities"
	* Psychosocial
label var hh_deaths12mo "Death in household in last 12 months"
	* Assets and Income
label var hh_ass_elec "Assets: electricity"
label var hh_ass_radio "Assets: radio"
label var hh_ass_tv "Assets: TV"
label var hh_ass_fridge "Assets: fridge"
label var hh_ass_bicycle "Assets: bicycle"
label var hh_ass_motorcycle "Assets: motorcycle"
label var hh_ass_car_truck "Assets: car, truck"
label var hh_ass_phone "Assets: landline telephone"
label var hh_ass_computer "Assets: computer"
label var hh_ass_wmachine "Assets: washing machine"
label var hh_ass_cellphone "Assets: cellphone"
label var hh_ass_watch "Assets: watch"
label var hh_ass_animalcart "Assets: animal cart"
label var hh_ass_motorboat "Assets: motorboat"
label var hh_ass_vacuum "Assets: vacuum cleaner"
label var hh_ass_microwave "Assets: microwave oven"
label var hh_ass_stove "Assets: stove"
label var hh_ass_sat "Assets: satellite TV"
label var hh_ass_video "Assets: video player"
label var hh_ass_hifi "Assets: hi-fi stereo, CD player, MP3 player"
label var hh_ass_camera "Assets: camera"
label var hh_ass_smachine "Assets: sewing machine"
label var hh_ass_sofa "Assets: sofa"
label var hh_ass_boat "Assets: boat"
label var hh_ass_plough "Assets: plough"
label var hh_ass_tractor "Assets: tractor"
label var hh_ass_wheelbarrow "Assets: wheelbarrow"
label var hh_ass_mill "Assets: mill"
label var hh_ass_tab "Assets: table"
label var hh_ass_sink "Assets: built-in kitchen sink"
label var hh_ass_hotw "Assets: hot running water"
label var hh_ass_dishwasher "Assets: dishwasher"
label var hh_income "Household income [ZAR]"
label var hh_income_quint "Household income quintile"
label var hh_windex "Household wealth index"
label var hh_windex_quint "Household wealth Quintile"
label var hh_cwi "Comparative Wealth Index"
label var hh_ownhome "Home owned by a household member"
label var hh_recgrant "Household received government grant"
label var hh_govsupport "Household received government support"
label var hh_foodinsec "Food insecurity"
label var hh_foodinsec_adult "Food insecurity: adult"
label var hh_foodinsec_child "Food insecurity: child"
	* Anchor variables for Comparative Wealth Index
label var hh_edu_deprived "No household member has completed primary school"
label var hh_unimp_toilet "Unimproved sanitation"
label var hh_unimp_water "Unimproved water source"
label var hh_unimp_cooking "Use of solid (unimproved) cooking fuels"
label var hh_dep1plus "Deprived in one or more basic needs"
label var hh_dep2plus "Deprived in two or more basic needs"
label var hh_dep3plus "Deprived in three or more basic needs"
label var hh_dep4plus "Deprived in four basic needs"	

* Individual Characteristics
	* Demographics
label var sex "Sex"
label var age "Age [years]"
label var race "Population group"
label var race_imp "Population group, imputed"
label var marstatus "Marital status"
label var edu1 "Education (6 categories)"
label var edu2 "Education (5 categories)"
label var emp "Employment status"
label var agecat1 "Age categories (5-year bands)"
label var agecat2 "Age categories (10-year bands)"
	* Lifestyle
label var smokstatus "Smoking Status"
label var currsmok "Current smoking"
label var alcstatus "Alcohol use status"
label var curralc "Current drinking"
label var alcavg "Average alcohol consumpion [g/d]"
label var gpaq "GPAQ [MET minutes per week]"
label var gpaqcat "GPAQ [Level of physical activity]"
label var exercisefreq "Weekly frequency of exercise/leisure time physical activity"
	* Self-perceived health status and diagnoses
label var self_health "Self-perception of health status"
label var diag_hbp "Diagnosis: hypertension"
label var diag_isch "Diagnosis: heart attack/angina"
label var diag_stroke "Diagnosis: stroke"
label var diag_chol "Diagnosis: hypercholesterolaemia"
label var diag_diab "Diagnosis: diabetes"
label var diag_emph "Diagnosis: emphysema/bronchitis"
label var diag_asth "Diagnosis: asthma"
label var diag_tb "Diagnosis: tuberculosis"
label var diag_cancer "Diagnosis: cancer"
label var diag_heart "Diagnosis: heart problems"
	* Medication use
label var bpmed "Current use of antihypertensive medication - self"
label var diabmed "Current use of diabetes medication - self"
label var cholmed "Current use of cholesterol medication - self"
label var ischmed "Current use of angina/heart attack medication - self"
label var lungmed "Current use of asthma, emphysema, bronchitis or chronic lung disease medication - self"
label var tbmed "Current use of tuberculosis medication - self"
label var strokemed "Current use of stroke medication - self"

label var bpmed_coded "Current use of antihypertensive medication - coded"
label var diabmed_coded "Current use of diabetes medication - coded"
label var cholmed_coded "Current use of cholesterol medication - coded"
label var ischmed_coded "Current use of angina/heart attack medication - coded"
label var lungmed_coded "Current use of asthma, emphysema or bronchitis medication - coded"
label var tbmed_coded "Current use of TB medication - coded"
label var strokemed_coded "Current use of stroke medication - coded"
	* Reproductive health
label var parity "Parity"
label var currpreg "Currently pregnant"
label var everpreg "Ever pregnant"
	* Anthropometry
label var height1 "Height [cm] - reading 1"
label var height2 "Height [cm] - reading 2"
label var height3 "Height [cm] - reading 3"
label var height "Height [cm] - Average of available readings"
label var weight1 "Weight [kg] - reading 1"
label var weight2 "Weight [kg] - reading 2"
label var weight3 "Weight [kg] - reading 3"
label var weight "Weight [cm] - Average of available readings"
label var waist1 "Waist circumference [cm] - reading 1"
label var waist2 "Waist circumference [cm] - reading 2"
label var waist3 "Waist circumference [cm] - reading 3"
label var waist "Waist circumference [cm] - Average of available readings"
label var arm1 "Arm circumference [cm] - reading 1"
label var arm2 "Arm circumference [cm] - reading 2"
label var arm3 "Arm circumference [cm] - reading 3"
label var arm "Arm circumference [cm] - Average of available readings"
label var hip1 "Hip circumference [cm] - reading 1"
label var hip2 "Hip circumference [cm] - reading 2"
label var hip3 "Hip circumference [cm] - reading 3"
label var hip "Hip circumference [cm] - Average of available readings"
label var sbp1 "Systolic Blood Pressure [mmHg] - reading 1"
label var sbp2 "Systolic Blood Pressure [mmHg] - reading 2"
label var sbp3 "Systolic Blood Pressure [mmHg] - reading 3"
label var sbp_mean1 "Systolic Blood Pressure [mmHg] - Average of available readings"
label var sbp_mean2 "Systolic Blood Pressure [mmHg] - Average of available readings excluding the first"
label var dbp1 "Diastolic Blood Pressure [mmHg] - reading 1"
label var dbp2 "Diastolic Blood Pressure [mmHg] - reading 2"
label var dbp3 "Diastolic Blood Pressure [mmHg] - reading 3"
label var dbp_mean1 "Diastolic Blood Pressure [mmHg] - Average of available readings"
label var dbp_mean2 "Diastolic Blood Pressure [mmHg] - Average of available readings excluding the first"
label var rhr1 "Resting Heart Rate [bpm] - reading 1"
label var rhr2 "Resting Heart Rate [bpm] - reading 2"
label var rhr3 "Resting Heart Rate [bpm] - reading 3"
label var rhr_mean1 "Resting Heart Rate [bpm] - Average of available readings"
label var rhr_mean2 "Resting Heart Rate [bpm] - Average of available readings excluding the first"
label var bmi "Body Mass Index [kg/m2]"
label var bmicat "Body Mass Index categories"
	* Laboratory
label var hb "Haemoglobin [g/dl]"
label var HbA1c "hb1ac [mmol/mol]"
label var chol_tot "Total cholesterol [mmol/l]"
label var chol_hdl "Hdl cholesterol [mmol/l]"
label var chol_ldl "Ldl cholesterol [mmol/l]"
label var trig "Triglycerides [mmol/l]"
	* Access to healthcare
label var medaid "Covered by medical insurance"
label var hcare12mo "Healthcare consultation last year"
label var hcare1mo "Healthcare consultations last month"
label var hcare1mo_public "Healthcare last month: public hospital/clinic"
label var hcare1mo_priv~e "Healthcare last month: private hospital/clinic/doctor"
label var ohcare1mo "Outpatient consultations last month"
label var ohcare1mo_pub~c "Outpatient healthcare last month: public hospital/clinic"
label var ohcare1mo_pri~e "Outpatient healthcare last month: private hospital/clinic/doctor"
label var hcare1mo_chem~e "Healthcare last month: chemist/pharmacist/nurse"
label var hcare1mo_trad "Healthcare last month: traditional/faith healer"
label var hcare1mo_other "Healthcare last month: other"

******************************************************************************************************************************************************
* VALUE LABELS                                                                                                                                       * 
******************************************************************************************************************************************************

* Value
label define vyesno 0 "No" 1 "Yes"
label define vgeotype2 1 "Urban"  2 "Rural" 
label define vgeotype4 1 "Urban formal"  2 "Urban informal" 3 "Rural informal (tribal)" 4 "Rural formal (Farms)"

label define vprov1996_name 1 "Western Cape" 2 "Eastern Cape" 3 "Northern Cape" 4 "Free State" 5 "KwaZulu Natal" 6 "North West" 7 "Gauteng"        /// 
                            8 "Mpumalanga" 9 "Northern Province" 
label define vprov2001_name 1 "Western Cape" 2 "Eastern Cape" 3 "Northern Cape" 4 "Free State" 5 "KwaZulu Natal" 6 "North West" 7 "Gauteng"        /// 
                            8 "Mpumalanga" 9 "Limpopo" 	
label define vprov2011_name 1 "Western Cape" 2 "Eastern Cape" 3 "Northern Cape" 4 "Free State" 5 "KwaZulu Natal" 6 "North West" 7 "Gauteng"        /// 
                            8 "Mpumalanga" 9 "Limpopo" 	

label define vprov1996_code 1 "WC" 2 "EC" 3 "NC" 4 "FS" 5 "KZN" 6 "NW" 7 "GT" 8 "MP" 9 "NP" 
label define vprov2001_code 1 "WC" 2 "EC" 3 "NC" 4 "FS" 5 "KZN" 6 "NW" 7 "GT" 8 "MP" 9 "LI" 
label define vprov2011_code 1 "WC" 2 "EC" 3 "NC" 4 "FS" 5 "KZN" 6 "NW" 7 "GT" 8 "MP" 9 "LI" 					   				   
					   
label define vsex 1 "Male" 2 "Female"
label define vrace 1 "Black African" 2 "Coloured" 3 "White" 4 "Asian" 9999 "Other"
label define vmarstatus 1 "Married/living with partner" 2 "Widowed/divorced/separated" 3 "Never married/single"
label define vedu1 0 "No education" 1 "Some primary" 2  "Completed primary" 3 "Some secondary" 4 "Completed secondary" 5 "Any higher education"    ///
                   9999 "Other"
label define vedu2 0 "No education" 1 "Some primary" 2  "Completed primary" 3 "Some secondary" 4 "Completed secondary/Any higher education"        ///
                   9999 "Other"			  	  
label define vemp 0 "Unemployed" 1 "Employed"
label define vtoilet 1 "Flush toilet/chemical toilet" 2 "Ventilated improved pit latrine" 3 "Traditional pit latrine/bucket"                       ///
                     4 "No facility/bush"  9999 "Other"
label define vwater 1 "Piped in dwelling" 2 "Piped on site or yard" 3 "Public tap" 4 "Water carrier/tanker" 5 "Borehole/well"                      ///
                    6 "Rainwater tank" 7 "Surface water" 9999 "Other"
label def vfloormaterial 1 "Mud/earth/dung" 2 "Concrete/cement" 3 "Carpet" 4 "Tiles" 5 "Wood" 6 "Linoleum/vinyl" 9999 "Other"
label def vfloormaterial2 1 "Hard floor" 2 "Earth floor"
label def vwallmaterial 1 "Mud/tatching/wattle and daub" 2 "Mud and cement mix" 3 "Corrugated iron/zinc" 4 "Plastic/cardboard"                     ///
                        5 "Brick/cement/prefab/plaster" 9999 "Other"
label def vwallmaterial2 1 "Durable material" 2 "Mud/adobe" 3 "Thatch etc." 4 "Plastic sheet"  5 "Metal sheet" 9999 "Other"						
label define vroofmaterial 1 "Mud/thatching/wattle and daub" 2 "Mud and cement mix" 3 "Corrugated iron/zinc" 4 "Plastic/cardboard"                 ///
						   5 "Brick/cement" 6 "Wood" 7 "Asbestos"  8 "Tile" 9999 "Other/No roof"
label define vcookingfuel 1 "Electricity" 2 "Gas" 3 "Paraffin" 4 "Coal" 5 "Wood/straw" 6 "Animal dung"  9999 "Other" 
label define vheatingfuel 1 "Electricity" 2 "Gas" 3 "Paraffin" 4 "Coal" 5 "Wood/straw" 6 "Animal dung" 9999 "Other" 			
label define vsmokstatus 0 "Never smoker" 1 "Former smoker" 2 "Current smoker" 
label define valcstatus 0 "Never drinker" 1 "Former drinker" 2 "Current drinker" 
label define vgpaqcat 1 "Inactive [0-600]" 2 "Low active [601-4000]" 3 "Moderately active [4001-8000]" 4 "Highly active [8001+]" 	  
label define vexercisefreq 0 "Never" 1 "Less than once a week" 2 "Once a week" 3 "Twice a week" 4 "Three or more times a week" 			  
label define vcurrpreg 0 "No/don't know" 1 "Yes"
label define vselfhealth 1 "Poor" 2 "Average" 3 "Good" 4 "Very good/excellent" 
label define vquint 1 "I (Lowest)" 2 "II" 3 "III" 4 "IV" 5 "V (Highest)"
label define vdwelling 1 "Structure (brick) on separate stand/yard" 2 "Traditional structure made of traditional materials"                        ///
                       3 "Flat/apartment in block" 4 "Town/cluster/semi-detached house in complex" 5 "Backyard dwelling"                           ///
					   6 "Informal backyard dwelling" 7 "Informal dwelling not in backyard" 8 "Room/flatlet" 9 "Caravan/tent" 9999 "Other"
label def vsource 1 "DHS 1998" 2 "DHS 2003" 3 "SAGE 2007-8" 4 "NIDS 2008" 5 "NIDS 2010-11" 6 "NIDS 2012" 7 "SANHANES 2012" 8 "SAGE 2014"             ///
                  9 "NIDS 2014-15" 10 "DHS 2016" 11 "NIDS 2017"
label define vbmicat 1 "Underweight" 2 "Healthy weight" 3 "Overweight" 4 "Obesity I" 5 "Obesity II" 6 "Obesity III"  7 "Obesity IV"  

label define vagecat1 1 "15-19" 2 "20-24" 3 "25-29" 4 "30-34" 5 "35-39" 6 "40-44" 7 "45-49" 8 "50-54" 9 "55-59" 10 "60-64" 11 "65-69" 12 "70-74"  ///
                      13 "75-79" 14 "80+" 
label define vagecat2 1 "15-19" 2 "20-29" 3 "30-39" 4 "40-49" 5 "50-59" 6 "60-69" 7 "70-79" 8 "80+" 

# delimit ;	
label define vdist1996_name 
7003 "Western Metropolitan Services Council"
5007 "uThungulu Regional Council"
4004 "Northern Free State District Council"
8001 "Eastvaal District Council"
5002 "Indlovu Regional Council"
2005 "Western Region District Council"
4002 "Eastern Free State District Council"
8002 "Highveld District Council"
7002 "Greater Johannesburg"
2006 "Wild Coast District Council"
4001 "Bloemfontein Area District Council"
6005 "Southern District Council (Klerksdorp)"
6003 "Eastern District Council"
5003 "Durban Metro"
8003 "Lowveld Escarpment District Council"
1003 "Cape Metro"
3004 "Lower Orange District Council"
4003 "Goldfields District Council"
3005 "Namaqualand District Council"
9002 "Northern District Council"
3006 "Upper Karoo District Council"
5008 "Zululand Regional Council"
6001 "Bophirima District Council(Huhudi)"
1007 "West Coast District Council"
2004 "Stormberg District Council"
3001 "Diamantveld District Council"
5004 "Mzinyathi Regional Council"
1008 "Winelands District Council"
5006 "Ugu Regional Council"
6004 "Rustenburg District Council"
2001 "Amatola District Council"
3002 "Hantam District Council"
9001 "Bushveld District Council"
5001 "iLembe Regional Council"
6002 "Central District Council"
7001 "Eastern Gauteng Metropolitan Services Council"
1004 "Overberg District Council"
2003 "Kei District Council"
1001 "Breede River District Council"
1006 "South Cape District Council"
2002 "Drakensberg District Council"
3003 "Kalahari District Council"
5005 "Thukela Regional Council"
1002 "Klein Karoo District Council"
1005 "Sentrale Karoo District Council"
;			
		   
label define vdist2001_name 
1 "West Coast District Municipality" 
2 "Boland District Municipality" 
3 "Overberg District Municipality" 
4 "Eden District Municipality" 
5 "Central Karoo District Municipality" 
6 "Namakwa District Municipality" 
7 "Karoo District Municipality" 
8 "Siyanda District Municipality" 
9 "Frances Baard District Municipality"
10 "Cacadu District Municipality" 
12 "Amatole District Municipality" 
13 "Chris Hani District Municipality" 
14 "Ukhahlamba District Municipality" 
15 "O.R. Tambo District Municipality" 
16 "Xhariep District Municipality" 
17 "Motheo District Municipality" 
18 "Lejweleputswa District Municipality"
19 "Thabo Mofutsanyane District Municipality" 
20 "Northern Free State District Municipality" 
21 "Ugu District Municipality" 
22 "UMgungundlovu District Municipality" 
23 "Uthukela District Municipality" 
24 "Umzinyathi District Municipality" 
25 "Amajuba District Municipality"  
26 "Zululand District Municipality" 
27 "Umkhanyakude District Municipality" 
28 "Uthungulu District Municipality" 
29 "iLembe District Municipality" 
30 "Govan Mbeki District Municipality" 
31 "Nkangala District Municipality" 
32 "Ehlanzeni District Municipality" 
33 "Mopani District Municipality"   					   
34 "Vhembe District Municipality" 
35 "Capricorn District Municipality" 
36 "Waterberg District Municipality" 
37 "Bojanala District Municipality" 
38 "Central District Municipality" 
39 "Bophirima District Municipality" 
40 "Southern District Municipality" 
42 "Sedibeng District Municipality"  
43 "Sisonke District Municipality" 
44 "Alfred Nzo District Municipality" 
76 "City of Tshwane Metropolitan Municipality" 
81 "Kgalagardi  District Municipality" 
82 "Metsweding District Municipality" 
83 "Sekhukhune Cross Boundary District Municipality" 
84 "Bohlabela District Municipality"					   
88 "West Rand District Municipality" 
171 "City of Cape Town Metropolitan Municipality" 
275 "Nelson Mandela Bay Metropolitan Municipality" 
572 "Ethekwini Metropolitan Municipality"
773 "Ekurhuleni Metropolitan Municipality" 
774 "City of Johannesburg Metropolitan Municipality"			
;

label define vdist2011_name 
101	"West Coast District Municipality" 
102 "Cape Winelands District Municipality" 
103	"Overberg District Municipality" 
104	"Eden District Municipality"  
105	"Central Karoo District Municipality" 
199	"City of Cape Town Metropolitan Municipality" 
210	"Cacadu District Municipality" 
212	"Amathole District Municipality" 
213	"Chris Hani District Municipality" 
214	"Joe Gqabi District Municipality" 
215	"O.R.Tambo District Municipality" 
244	"Alfred Nzo District Municipality" 
260	"Buffalo City Metropolitan Municipality" 
299	"Nelson Mandela Bay Metropolitan Municipality" 
306	"Namakwa District Municipality" 
307	"Pixley ka Seme District Municipality" 
308	"Siyanda District Municipality" 
309	"Frances Baard District Municipality" 
345	"John Taolo Gaetsewe District Municipality" 
416	"Xhariep District Municipality" 
556	"Zululand District Municipality"
559	"iLembe District Municipality" 
599	"eThekwini Metropolitan Municipality" 
637	"Bojanala District Municipality" 
638	"Ngaka Modiri Molema District Municipality" 
639	"Dr Ruth Segomotsi Mompati District Municipality" 
640	"Dr Kenneth Kaunda District Municipality" 
742	"Sedibeng District Municipality" 
748	"West Rand District Municipality" 
797	"City of Ekurhuleni Metropolitan Municipality" 
798	"City of Johannesburg Metropolitan Municipality" 
799	"City of Tshwane Metropolitan Municipality" 
830	"Gert Sibande District Municipality" 
831	"Nkangala District Municipality" 
832	"Ehlanzeni District Municipality" 
933	"Mopani District Municipality" 
934	"Vhembe District Municipality" 
935	"Capricorn District Municipality" 
936	"Waterberg District Municipality" 
947	"Greater Sekhukhune District Municipality" 
950 "Lejweleputswa District Municipality"
951 "Thabo Mofutsanyane District Municipality"
952 "Fezile Dabi District Municipality"
953 "Ugu District Municipality"
954 "Umgungundlovu District Municipality"
955 "Uthukela District Municipality"
956 "Umzinyathi District Municipality"
957 "Amajuba District Municipality"
958 "Umkhanyakude District Municipality"
959 "Uthungulu District Municipality"
960 "Sisonke District Municipality"
699 "Mangaung Metropolitan Municipality"
;
# delimit cr					   
	
			
# delimit ;		
label define vdist1996_code
7003 "DC713"
5007 "DC501"
4004 "DC401"
8001 "DC803"
5002 "DC505"
2005 "DC201"
4002 "DC402"
8002 "DC802"
7002 "JNB"
2006 "DC205"
4001 "DC403"
6005 "DC602"
6003 "DC605"
5003 "DUR"
8003 "DC801"
1003 "CPT"
3004 "DC301"
4003 "DC404"
3005 "DC306"
9002 "DC902"
3006 "DC304"
5008 "DC502"
6001 "DC601"
1007 "DC107"
2004 "DC202"
3001 "DC303"
5004 "DC503"
1008 "DC109"
5006 "DC506"
6004 "DC604"
2001 "DC202"
3002 "DC305"
9001 "DC901"
5001 "DC507"
6002 "DC603"
7001 "DC714"
1004 "DC110"
2003 "DC206"
1001 "DC108"
1006 "DC111"
2002 "DC204"
3003 "DC302"
5005 "DC504"
1002 "DC112"
1005 "DC105"
;	
			   
label define vdist2001_code 
1 "DC1"
2 "DC2"
3 "DC3"
4 "DC4"
5 "DC5"
6 "DC6"
7 "DC7"
8 "DC8"
9 "DC9"
10 "DC10"
12 "DC12"
13 "DC13"
14 "DC14"
15 "DC15"
16 "DC16"
17 "DC17"
18 "DC18"
19 "DC19"
20 "DC20"
21 "DC21"
22 "DC22"
23 "DC23"
24 "DC24"
25 "DC25"
26 "DC26"
27 "DC27"
28 "DC28"
29 "DC29"
30 "DC30"
31 "DC31"
32 "DC32"
33 "DC33"
34 "DC34"
35 "DC35"
36 "DC36"
37 "DC37"
38 "DC38"
39 "DC39"
40 "DC40"
42 "DC42"
43 "DC43"
44 "DC44"
76 "TSH"
81 "DC45"
82 "CBDC2"
83 "CBDC3"
84 "CBDC4"
88 "CBDC8"
171 "CPT"
275 "NMA"
572 "ETH"
773 "EKU"
774 "JHB"
;

label define vdist2011_code 
101 "DC1"
102 "DC2"
103 "DC3"
104 "DC4"
105 "DC5"
199 "CPT"
210 "DC10"
212 "DC12"
213 "DC13"
214 "DC14"
215 "DC15"
244 "DC44"
260 "BUF"
299 "NMA"
306 "DC6"
307 "DC7"
308 "DC8"
309 "DC9"
345 "DC45"
416 "DC16"
556 "DC26"
559 "DC29"
599 "ETH"
637 "DC37"
638 "DC38"
639 "DC39"
640 "DC40"
742 "DC42"
748 "DC48"
797 "EKU"
798 "JHB"
799 "TSH"
830 "DC30"
831 "DC31"
832 "DC32"
933 "DC33"
934 "DC34"
935 "DC35"
936 "DC36"
947 "DC47"
950 "DC18"
951 "DC19"
952 "DC20"
953 "DC21"
954 "DC22"
955 "DC23"
956 "DC24"
957 "DC25"
958 "DC27"
959 "DC28"
960 "DC43"
699 "MAN"
;
# delimit cr					   
	
******************************************************************************************************************************************************
* ORDER                                                                                                                                              * 
******************************************************************************************************************************************************

# delimit ;
order 
source 
year
hhid pid 
psu stratum aweight aweight_phys aweight_lab 
prov* dist* geotype*
intm inty
hh_size hh_ownhome hh_totrooms hh_sleeprooms hh_ptotrooms hh_psleeprooms 
hh_dwellingtype hh_wallmaterial hh_floormaterial hh_roofmaterial hh_roof_wall_* 
hh_cookingfuel hh_heatingfuel hh_cook_* 
hh_water hh_toilet hh_sharedtoilet hh_refuseremoved
hh_recgrant hh_govsupport hh_foodinsec hh_foodinsec_adult hh_foodinsec_child  
hh_ass_*
hh_edu_deprived hh_unimp_toilet hh_unimp_water hh_unimp_cooking hh_dep1plus hh_dep2plus hh_dep3plus hh_dep4plus 
hh_income hh_income_quint
hh_windex hh_windex_quint
hh_cwi
hh_deaths12mo 
sex age agecat1 agecat2 race race_imp marstatus edu1 edu2 emp
smokstatus currsmok alcstatus curralc alcavg gpaq gpaqcat exercise
self_health diag_*
bpmed diabmed cholmed ischmed lungmed tbmed strokemed
bpmed_coded diabmed_coded cholmed_coded ischmed_coded lungmed_coded tbmed_coded strokemed_coded
parity currpreg everpreg
height* weight* waist* arm* hip* sbp* dbp* rhr*
bmi bmicat
hb HbA1c chol_tot chol_hdl chol_ldl trig
medaid 
hcare12mo hcare1mo hcare1mo_public hcare1mo_private ohcare1mo ohcare1mo_public ohcare1mo_private hcare1mo_chem_nurse hcare1mo_trad hcare1mo_other
;
# delimit cr

******************************************************************************************************************************************************
* SURVEY SETTINGS                                                                                                                                    * 
******************************************************************************************************************************************************

svyset psu [pweight=aweight], strata(stratum) singleunit(certainty)

******************************************************************************************************************************************************
* CONSOLIDATE & SAVE                                                                                                                                 * 
******************************************************************************************************************************************************

* Label the datset
label data "EXPOSE SOUTH AFRICA - V. 1.1"

* Save   
save "$OUT/EXPOSE_SA.dta", replace

