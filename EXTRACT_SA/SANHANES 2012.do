******************************************************************************************************************************************************
* EXPOSE - DATA EXTRACTION                                                                                                                           *
* South Africa National Health And Nutrition Examination Survey 2012 (SANHANES 2012)                                                                 *
* Annibale Cois (acois@sun.ac.za) & Kafui Adjaye-Gbewonyo (k.adjayegbewonyo@greenwich.ac.uk)                                                         *
* Version 1.0                                                                                                                                        *
******************************************************************************************************************************************************

clear
set more off

******************************************************************************************************************************************************
* LOCATION OF FILES AND FOLDERS                                                                                                                      * 
******************************************************************************************************************************************************

* SOURCE FILES
global DATASET_1 "$BASEDIR/SANHANES/Datafiles/SANHANES Visiting point data_anon_MRC.dta"          // VISITING POINT (MRC) 
global DATASET_2 "$BASEDIR/SANHANES/Datafiles/SANHANES Individual clinical_anonymised_MRC.dta"    // BIOMARKERS (MRC)    
global DATASET_3 "$BASEDIR/SANHANES/Datafiles/SANHANES_WB_NEW_all_anonymised_MRC_SUBSET.dta"      // ADULT EXAMINATION (MRC)   
global DATASET_4 "$BASEDIR/SANHANES/Datafiles/SANHANES2011_12_Adult_Exam.csv"                     // ADULT EXAMINATION
global DATASET_5 "$BASEDIR/SANHANES/Datafiles/SANHANES2011_12_Adult_Questionnaire.dta"            // ADULT QUESTIONNAIRE 
global AUXILIARY_1 "$AUX/Geocoding/MNDC_2001_MATCH.dta"                     // GEOGRAPHICAL RECODING (MATCH EAS WITH DISTRICTS IN 2001)  

******************************************************************************************************************************************************
* MERGE DATASETS                                                                                                                                     * 
******************************************************************************************************************************************************

* VISITING POINT (1)

# delimit ;
use vpno
IQN_P1 IQN_P2 IQN_P3 IQN_P4 IQN_P5 IQN_P6 IQN_P7 IQN_P8 IQN_P9 IQN_P10 IQN_P11 IQN_P12 IQN_P13 IQN_P14 IQN_P15 IQN_P16 IQN_P17 IQN_P18 IQN_P19 IQN_P20  
A_P1_Q12 A_P2_Q12 A_P3_Q12 A_P4_Q12 A_P5_Q12 A_P6_Q12 A_P7_Q12 A_P8_Q12 A_P9_Q12 A_P10_Q12 A_P11_Q12 A_P12_Q12 A_P13_Q12 A_P14_Q12 A_P15_Q12 A_P16_Q12 
A_P17_Q12 A_P18_Q12 A_P19_Q12 A_P20_Q12 AGE_VQ_P1 AGE_VQ_P2 AGE_VQ_P3 AGE_VQ_P4 AGE_VQ_P5 AGE_VQ_P6 AGE_VQ_P7 AGE_VQ_P8 AGE_VQ_P9 AGE_VQ_P10 
AGE_VQ_P11 AGE_VQ_P12 AGE_VQ_P13 AGE_VQ_P14 AGE_VQ_P15 AGE_VQ_P16 AGE_VQ_P17 AGE_VQ_P18 AGE_VQ_P19 AGE_VQ_P20 vp_wgt EA_NO
using "$DATASET_1", clear;
# delimit cr 

* Identifiers
rename vpno hhid
label var hhid "Household ID"

* Socioeconomic
egen HSIZE = rownonmiss(IQN_P*)
rename IQN_P* iqn*
rename A_P*_Q12 EDU*	
rename AGE_VQ_P* AGE*	 
gen I=_n	
reshape long iqn EDU AGE, i(I) j(MEMBER)
drop if iqn>=.
drop if AGE<15
drop AGE
drop MEMBER
drop I
duplicates tag iqn, gen(DUP)
drop if DUP ==1
drop DUP
recode EDU (98=0)(0/6=1)(7=2)(8/11=3)(12=4)(15=3)(13=3)(14=5)(16/17=5)(18=9999), gen(EDUC)
drop EDU

* Administrative 
gen hweight = vp_wgt
label var hweight "Sampling weight - Household Questionnaire"

* Geographic 
  * Recover municipalities codes 
gen long ea_code = EA_NO
merge m:1 ea_code using "$AUXILIARY_1"
keep if _merge == 3
drop _merge
rename dc_pr_c dist2001
label var dist2001 "District (2001 boundaries)"
label val dist2001 vdist2001

* Save temporary 
save "$TEMP/TEMP_1A.dta", replace              

* VISITING POINT (2)

# delimit ;
use 
IQN_P1 IQN_P2 IQN_P3 IQN_P4 IQN_P5 IQN_P6 IQN_P7 IQN_P8 IQN_P9 IQN_P10 IQN_P11 IQN_P12 IQN_P13 IQN_P14 IQN_P15 IQN_P16 IQN_P17 IQN_P18 IQN_P19 IQN_P20  
B3Q14A D1Q_1 D1Q_2 D1Q_3 D1Q_4 D1Q_5 D1Q_6 D1Q_7 D1Q_8 D1Q_9 D2Q E1Q E1Q_SPECIFY E2Q_1 E2Q_2 E2Q_3 E2Q_4 E2Q_5 E2Q_6 E2Q_7 E2Q_8 E2Q_9 E2Q_10 E2Q_11 
E2Q_12 E2Q_13 E4Q E8Q E8Q_SPECIFY E11Q E11Q_SPECIFY E12Q E13Q E14Q E15Q E16Q E16Q_SPECIFY E17Q_1 E17Q_2 E17Q_3 E17Q_4 E17Q_5 E17Q_6 E17Q_7 E17Q_8 
E17Q_9 E17Q_10 E17Q_11 E17Q_12 E17Q_13 E17Q_14 AGE_VQ_P1 AGE_VQ_P2 AGE_VQ_P3 AGE_VQ_P4 AGE_VQ_P5 AGE_VQ_P6 AGE_VQ_P7 AGE_VQ_P8 AGE_VQ_P9 AGE_VQ_P10 
AGE_VQ_P11 AGE_VQ_P12 AGE_VQ_P13 AGE_VQ_P14 AGE_VQ_P15 AGE_VQ_P16 AGE_VQ_P17 AGE_VQ_P18 AGE_VQ_P19 AGE_VQ_P20 fvy fvm E16Q 
using "$DATASET_1", clear;                  
# delimit cr 

* Socioeconomic, administrative
rename IQN_P* iqn*
rename AGE_VQ_P* AGE*
gen I=_n	
reshape long iqn AGE, i(I) j(MEMBER)
drop if iqn>=.
drop if AGE<15
drop AGE
drop I
drop MEMBER
duplicates tag iqn, gen(DUP)
drop if DUP >=1
drop DUP

* Save temporary 
save "$TEMP/TEMP_1B.dta", replace            

* BIOMARKERS

# delimit ;
use IQN vpno individual_questionnaire_number labresults_entryid clinical_entryid
    indv_wgt_answ_qstn_bench indv_wgt_answ_phys_bench indv_wgt_answ_lab_bench
    cholesterols_res_edited cholhdls_res ldl_chol 
	triglycerideres_edited 
	glycatededited1 gly  
	HB_edited
	using "$DATASET_2", clear;

order IQN vpno individual_questionnaire_number labresults_entryid clinical_entryid
    indv_wgt_answ_qstn_bench indv_wgt_answ_phys_bench indv_wgt_answ_lab_bench
    cholesterols_res_edited cholhdls_res ldl_chol 
	triglycerideres_edited 
	glycatededited1 gly  
	HB_edited; 	
# delimit cr

* Identifier
rename IQN iqn

* Save temporary 
save "$TEMP/TEMP_2.dta", replace         

* ADULT EXAMINATION (1)

# delimit ;
use iqn e1_1_ac e1_2_ac e1_3_ac e2_1_ac e2_2_ac e2_3_ac e3_1_ac e3_2_ac e3_3_ac
    g2_1_ac g2_2_ac g2_3_ac g3_1_ac g3_2_ac g3_3_ac g4_1_ac g8_1_ac g8_2_ac g8_3_ac g9_1_ac g9_2_ac g9_3_ac
	using "$DATASET_3", clear;
# delimit cr

* Save temporary 
save "$TEMP/TEMP_3.dta", replace	      

* ADULT EXAMINATION (2)

import delimited "$DATASET_4", clear             
save "$TEMP/TEMP_4.dta", replace

* CONSOLIDATE 

use "$DATASET_5", clear                           // ADULT QUESTIONNAIRE 
keep if FRESP_AQ <= 3
merge 1:1 iqn using "$TEMP/TEMP_1A.dta"           // VISITING POINT  
drop if _merge != 3
drop _merge
merge 1:1 iqn using "$TEMP/TEMP_1B.dta"
drop if _merge != 3
drop _merge
merge 1:1 iqn using "$TEMP/TEMP_2.dta"            // BIOMARKERS 
drop if _merge != 3
drop _merge
merge 1:1 iqn using "$TEMP/TEMP_4.dta"            // CLINICAL EXAMINATION 
drop if _merge != 3
drop _merge
merge 1:1 iqn using "$TEMP/TEMP_3.dta"           
drop if _merge != 3
drop _merge

******************************************************************************************************************************************************
* EXTRACTION                                                                                                                                         * 
******************************************************************************************************************************************************

* Demographic
drop sex
rename A_3_AQ sex
label var sex "Sex"
label val sex vsex
rename A_1_AQ age
label var age "Age [years]"
recode race (1=1)(2=3)(3=2)(4=4)(5=9999)
*drop race
*recode A_4_AQ (1=1)(2=3)(3=2)(4=4)(5=9999), gen(race)
label var race "Population group"
rename HSIZE hsize 
label var hsize "Household size"

* Socioeconomic
recode A_6_AQ (1/4=0)(5=1)(6/7=0)(8/12=1)(13/14=0), gen(emp)
label var emp "Employment status"
label val emp vemp
rename EDUC edu1
label var edu1 "Education (6 categories)"
label val edu1 vedu1
recode edu1 (0=0)(1=1)(2=2)(3=3)(4/5=4)(6=4), gen(edu2)
label var edu2 "Education (5 categories)"
label val edu2 vedu2
recode  E13Q (1=1)(2=4)(3=5)(4=2)(5=3)(6=6)(7/8=9999)(9=9999)(99=9999),gen(cookingfuel)
label var cookingfuel "Main cooking fuel"
label var cookingfuel vcookingfuel
recode  E14Q (1=1)(2=4)(3=5)(4=2)(5=3)(6=6)(7/8=9999)(9=9999)(99=9999),gen(heatingfuel)
label var heatingfuel "Main heating fuel"
label var heatingfuel vheatingfuel

*Generating new indicators for cooking fuel, with 1 for main fuel and missing for all else and 0 for none, for harmonisation with 1998 DHS
tabulate cookingfuel, gen (cook)
rename cook1 cook_elec
replace cook_elec=. if cook_elec==0
replace cook_elec=0 if E13Q==9
rename cook2 cook_gas
replace cook_gas=. if cook_gas==0
replace cook_gas=0 if E13Q==9
rename cook3 cook_par
replace cook_par=. if cook_par==0
replace cook_par=0 if E13Q==9
rename cook4 cook_coal
replace cook_coal=. if cook_coal==0
replace cook_coal=0 if E13Q==9
rename cook5 cook_wood
replace cook_wood=. if cook_wood==0
replace cook_wood=0 if E13Q==9
rename cook6 cook_dung
replace cook_dung=. if cook_dung==0
replace cook_dung=0 if E13Q==9
rename cook7 cook_other
replace cook_other=. if cook_other==0
replace cook_other=0 if E13Q==9

label var cook_elec "Cooking fuel: Electricity"
label var cook_gas "Cooking fuel: Gas"
label var cook_par "Cooking fuel: Paraffin" 
label var cook_wood "Cooking fuel: Wood"
label var cook_coal "Cooking fuel: Coal"
label var cook_dung "Cooking fuel: Animal dung"
label var cook_other "Cooking fuel: Other"


recode E17Q_1 (1=1)(2=0), gen(ass_fridge)
label var ass_fridge "Assets: fridge"
label val ass_fridge vyesno
recode E17Q_2 (1=1)(2=0), gen(ass_stove)
label var ass_stove "Assets: electric/gas stove"
label val ass_stove vyesno
recode E17Q_3 (1=1)(2=0), gen(ass_vacuum)
label var ass_vacuum "Assets: vacuum cleaner"
label val ass_vacuum vyesno
recode E17Q_4 (1=1)(2=0), gen(ass_wmachine)
label var ass_wmachine "Assets: washing machine"
label val ass_wmachine vyesno
recode E17Q_5 (1=1)(2=0), gen(ass_computer)
label var ass_computer "Assets: computer"
label val ass_computer vyesno
recode E17Q_6 (1=1)(2=0), gen(ass_sat)
label var ass_sat "Assets: Satellite TV"
label val ass_sat vyesno
recode E17Q_7 (1=1)(2=0), gen(ass_video)
label var ass_video "Assets: video player"
label val ass_video vyesno
recode E17Q_8 (1=1)(2=0), gen(ass_car_truck)
label var ass_car_truck "Assets: car/truck" 
label val ass_car_truck vyesno
recode E17Q_9 (1=1)(2=0), gen(ass_tv)
label var ass_tv "Assets: TV"
label val ass_tv vyesno
recode E17Q_10 (1=1)(2=0), gen(ass_radio)
label var ass_radio "Assets: radio"
label val ass_radio vyesno
recode E17Q_11 (1=1)(2=0), gen(ass_phone)
label var ass_phone "Assets: telephone"
label val ass_phone vyesno
recode E17Q_12 (1=1)(2=0), gen(ass_cellphone)
label var ass_cellphone "Assets: cellphone"
label val ass_cellphone vyesno
rename E4Q sleeprooms
label var sleeprooms "Number of rooms for sleeping"
gen roof_wall_1 = 0
replace roof_wall_1 = 1 if E2Q_8<. | E2Q_10<. | E2Q_11<. 
label var roof_wall_1 "Roof, wall material: Mud/tatching/wattle and daub"
label val roof_wall_1 vyesno
gen roof_wall_2 = 0
replace roof_wall_2 = 1 if E2Q_7<. 
label var roof_wall_2 "Roof, wall material: Mud and cement mix"
label val roof_wall_2 vyesno
gen roof_wall_3 = 0
replace roof_wall_3 = 1 if E2Q_3<. 
label var roof_wall_3 "Roof, wall material: Corrugated iron/zinc"
label val roof_wall_3 vyesno
gen roof_wall_4 = 0
replace roof_wall_4 = 1 if E2Q_6<. | E2Q_5<.
label var roof_wall_4 "Roof, wall material: Plastic/cardboard"
label val roof_wall_4 vyesno
gen roof_wall_5 = 0
replace roof_wall_5 = 1 if E2Q_9<. | E2Q_2<. | E2Q_1<.
label var roof_wall_5 "Roof, wall material: Brick/cement/prefab/plaster"
label val roof_wall_5 vyesno
gen roof_wall_9999 = 0
replace roof_wall_9999 = 1 if E2Q_4<. | E2Q_12<. | E2Q_13<. 
label var roof_wall_9999 "Roof, wall material: other"
label val roof_wall_9999 vyesno
  * Manual recode of "other" for source of drinking water
replace E8Q = 1 if E8Q_SPECIFY == "TAP INSIDE THE HOUSE"
replace E8Q = 2 if E8Q_SPECIFY == "TAP IN THE YARD" | E8Q_SPECIFY == "PIPES BY OUTSIDE DWELLING"
replace E8Q = 3 if E8Q_SPECIFY == "PIPED WATER IN STREET" | E8Q_SPECIFY == "TAP HEARBY" | E8Q_SPECIFY == "COMMUNITY TAP" |  ///
                   E8Q_SPECIFY == "VILLAGE TAP"
replace E8Q = 7 if E8Q_SPECIFY == "RIVER"
  * Manual recode ends
recode E8Q (1=1)(2=2)(3=9999)(4=4)(5=6)(6=5)(7=7)(8=3)(9=9999)(99=.), gen(water)
label var water "Source of drinking water"
label val water vwater
recode E11Q (1/3=1)(4=2)(5/6=3)(8=4)(7=9999)(9=9999), gen(toilet)
label var toilet "Toilet facilities"
label val toilet vtoilet
recode E12Q (1=1)(2=0), gen(sharedtoilet)
label var sharedtoilet "Shared toilet facility"
label val sharedtoilet vyesno
recode B3Q14A (1=1)(2=0), gen(foodinsec) 
label var foodinsec "Food insecurity"
label val foodinsec vyesno
recode E1Q (1=1)(2=2)(3=3)(4/6=4)(7=5)(8=6)(9=7)(10=8)(11=9)(12/99=9999), gen(dwelling)
label var dwelling "Dwelling type"
label val dwelling vdwelling

* Health status
recode E1_1_AQ (1=4)(2=3)(3=2)(4/5=1), gen(self_health)
label var self_health "Self-perception of health status"
label val self_health vselfhealth
recode B_2A_AQ (1=1) (2=0) (3=.), gen(diag_hbp)
label var diag_hbp "Diagnosis: hypertension"
label val diag_hbp vyesno
recode B_2B_AQ (1=1) (2=0) (3=.), gen(diag_stroke)
label var diag_stroke "Diagnosis: stroke"
label val diag_stroke vyesno
recode B_3A_AQ (1=1) (2=0) (3=.), gen(diag_isch)
label var diag_isch "Diagnosis: heart attack/angina"
label val diag_isch vyesno
recode B_2C_AQ (1=1) (2=0) (3=.), gen(diag_heart)
recode B_5B_AQ (1=1) (2=0) (3=.), gen(diag_chol)
label var diag_chol "Diagnosis: hypercholesterolaemia"
label val diag_chol vyesno
recode B2_4_AQ (1=1) (2=0) (3=.), gen(diag_diab)
label var diag_diab "Diagnosis: diabetes"
label val diag_diab vyesno
recode C2_1_AQ (1=1) (2=0) (3=.), gen(diag_tb)
label var diag_tb "Diagnosis: tuberculosis"
label val diag_tb vyesno

* Medication use: self-reported
gen bpmed = 0
replace bpmed = 1 if a12_m7_ac == 7
label var bpmed "Current use of antihypertensive medication - self"
label val bpmed vyesno
gen diabmed = 0
replace diabmed = 1 if a12_m6_ac == 6
label var diabmed "Current use of diabetes medication - self"
label val diabmed vyesno
gen cholmed = 0
replace cholmed = 1 if a12_m11_ac == 11
label var cholmed "Current use of cholesterol medication - self"
label val cholmed vyesno

* Behavioural
recode B3_1_AQ (1/3=1)(4=0)(5=.), gen(smokstatus) 
replace smokstatus = 2 if (B3_3_AQ == 1 | B3_3_AQ == 2)  
label var smokstatus  "Smoking status"
label val smokstatus vsmokstatus
recode smokstatus (2=1)(0/1=0)(.=.), gen(currsmok)
label var currsmok "Current smoking"
label val currsmok vyesno
recode B7_1_AQ (0=0)(1/4=1), gen(curralc)
label var curralc "Current drinking"
label val curralc vyesno
recode B7_1_AQ (0=0)(1=6)(2=36)(3=130)(4=286), gen(alcf)
recode  B7_2_AQ (0=1.5)(1=3.5)(2=5.5)(3=8)(4=15), gen(alcq)
gen alcavg = alcf*alcq*12/365
replace alcavg = 0 if curralc == 0
label var alcavg "Average alcohol consumpion [g/d]"

gen alcfreq = alcf/52
label var alcfreq "Number drinking days per week"
gen alcqnt = alcq/52
label var alcqnt "Number of drinks per drinking occasion"

recode B7_3_AQ (0=0)(1/4=1), gen(alcbing)
label var alcbing "Binge drinking"
label val alcbing vyesno
	* GPAQ (coding as per manual)                                                  
		* Impute items according to skip patterns 
replace B5_IB_AQ=0 if B5_1A_AQ==2
replace B5_1C_HH_AQ=0 if B5_1A_AQ==2
replace B5_1C_MM_AQ=0 if B5_1A_AQ==2
replace B5_2B_AQ =0 if B5_2A_AQ==2
replace B5_2C_HH_AQ=0 if B5_2A_AQ==2
replace B5_2C_MM_AQ=0 if B5_2A_AQ==2
replace B5_4B_AQ=0 if  B5_4A_AQ==2
replace B5_4C_HH_AQ=0 if  B5_4A_AQ==2
replace B5_4C_MM_AQ=0 if  B5_4A_AQ==2 
replace B5_5B_AQ=0 if  B5_5A_AQ==2
replace B5_5C_HH_AQ=0 if  B5_5A_AQ==2
replace B5_5C_MM_AQ=0 if  B5_5A_AQ==2  
replace B5_6B_AQ =0 if B5_6A_AQ==2
replace B5_6C_HH_AQ =0 if B5_6A_AQ==2
replace B5_6C_MM_AQ  =0 if B5_6A_AQ==2  		  
		* Clean missing data in minutes/hours fields 
egen M1 = rowmiss(B5_1C_HH_AQ B5_1C_MM_AQ)  
egen M2 = rowmiss(B5_2C_HH_AQ B5_2C_MM_AQ)  
egen M4 = rowmiss(B5_4C_HH_AQ B5_4C_MM_AQ)  
egen M5 = rowmiss(B5_5C_HH_AQ B5_5C_MM_AQ) 
egen M6 = rowmiss(B5_6C_HH_AQ B5_6C_MM_AQ)         
replace B5_1C_HH_AQ=0 if B5_1C_HH_AQ>=. 
replace B5_1C_MM_AQ=0 if B5_1C_MM_AQ>=. 
replace B5_2C_HH_AQ=0 if B5_2C_HH_AQ>=. 
replace B5_2C_MM_AQ=0 if B5_2C_MM_AQ>=. 
replace B5_4C_HH_AQ=0 if B5_4C_HH_AQ>=. 
replace B5_4C_MM_AQ=0 if B5_4C_MM_AQ>=. 
replace B5_5C_HH_AQ=0 if B5_5C_HH_AQ>=. 
replace B5_5C_MM_AQ=0 if B5_5C_MM_AQ>=. 
replace B5_6C_HH_AQ=0 if B5_6C_HH_AQ>=. 
replace B5_6C_MM_AQ=0 if B5_6C_MM_AQ>=. 
replace B5_1C_HH_AQ=. if M1==2
replace B5_1C_MM_AQ=. if M1==2
replace B5_2C_HH_AQ=. if M2==2
replace B5_2C_MM_AQ=. if M2==2
replace B5_4C_HH_AQ=. if M4==2
replace B5_4C_MM_AQ=. if M4==2
replace B5_5C_HH_AQ=. if M5==2
replace B5_5C_MM_AQ=. if M5==2
replace B5_6C_HH_AQ=. if M6==2
replace B5_6C_MM_AQ=. if M6==2   
		* Check for hours columns = 15,30,45,60 
gen flag_1=0 	
gen flag_2=0 
gen flag_3=0 
gen flag_4=0 
gen flag_5=0 
replace flag_1=1 if B5_1C_HH_AQ==15 & B5_1C_MM_AQ==0   
replace flag_1=1 if B5_1C_HH_AQ==30 & B5_1C_MM_AQ==0 
replace flag_1=1 if B5_1C_HH_AQ==45 & B5_1C_MM_AQ==0 
replace flag_1=1 if B5_1C_HH_AQ==60 & B5_1C_MM_AQ==0 
replace flag_2=1 if B5_2C_HH_AQ==15 & B5_2C_MM_AQ==0
replace flag_2=1 if B5_2C_HH_AQ==30 & B5_2C_MM_AQ==0
replace flag_2=1 if B5_2C_HH_AQ==45 & B5_2C_MM_AQ==0
replace flag_2=1 if B5_2C_HH_AQ==60 & B5_2C_MM_AQ==0
replace flag_3=1 if B5_4C_HH_AQ==15 & B5_4C_MM_AQ==0
replace flag_3=1 if B5_4C_HH_AQ==30 & B5_4C_MM_AQ==0
replace flag_3=1 if B5_4C_HH_AQ==45 & B5_4C_MM_AQ==0
replace flag_3=1 if B5_4C_HH_AQ==60 & B5_4C_MM_AQ==0	 
replace flag_4=1 if B5_5C_HH_AQ==15 & B5_5C_MM_AQ==0
replace flag_4=1 if B5_5C_HH_AQ==30 & B5_5C_MM_AQ==0
replace flag_4=1 if B5_5C_HH_AQ==45 & B5_5C_MM_AQ==0
replace flag_4=1 if B5_5C_HH_AQ==60 & B5_5C_MM_AQ==0
replace flag_5=1 if B5_6C_HH_AQ==15 & B5_6C_MM_AQ==0
replace flag_5=1 if B5_6C_HH_AQ==30 & B5_6C_MM_AQ==0
replace flag_5=1 if B5_6C_HH_AQ==45 & B5_6C_MM_AQ==0
replace flag_5=1 if B5_6C_HH_AQ==60 & B5_6C_MM_AQ==0 
		* Substitute according to manual
replace B5_1C_MM_AQ=B5_1C_HH_AQ if flag_1==1 
replace B5_1C_HH_AQ=0 if flag_1==1 
replace B5_2C_MM_AQ=B5_2C_HH_AQ if flag_2==1 
replace B5_2C_HH_AQ=0 if flag_2==1 
replace B5_4C_MM_AQ=B5_4C_HH_AQ if flag_3==1 
replace B5_4C_HH_AQ=0 if flag_3==1 
replace B5_5C_MM_AQ=B5_5C_HH_AQ if flag_4==1 
replace B5_5C_HH_AQ=0 if flag_4==1 
replace B5_6C_MM_AQ=B5_6C_HH_AQ if flag_5==1 
replace B5_6C_HH_AQ=0 if flag_5==1  	 
		* Recode variables
 rename B5_IB_AQ WVIG_FREQ
 gen WVIG_DUR = B5_1C_HH_AQ*60+B5_1C_MM_AQ
 rename B5_2B_AQ WMOD_FREQ
 gen WMOD_DUR = B5_2C_HH_AQ*60+B5_2C_MM_AQ
 rename B5_4B_AQ TRA_FREQ
 gen TRA_DUR = B5_4C_HH_AQ*60+B5_4C_MM_AQ
 rename B5_5B_AQ NVIG_FREQ
 gen NVIG_DUR = B5_5C_HH_AQ*60+B5_5C_MM_AQ
 rename B5_6B_AQ NMOD_FREQ
 gen NMOD_DUR = B5_6C_HH_AQ*60+B5_6C_MM_AQ				 			 
		* GPAQ                                                                                                                                              			
gen D1 = WVIG_FREQ*WVIG_DUR*8 
gen D2 = WMOD_FREQ*WMOD_DUR*4
gen D3 = TRA_FREQ*TRA_DUR*4
gen D4 = NVIG_FREQ*NVIG_DUR*8
gen D5 = NMOD_FREQ*NMOD_DUR*4	
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
replace exercisefreq = 0 if (B5_5A_AQ == 2 & B5_6A_AQ == 2)
label var exercisefreq "Weekly frequency of exercise/leisure time physical activity"
label val exercisefreq vexercisefreq

* Reproductive health 
recode B8_1_AQ (1=1)(2=0), gen(everpreg) 
label var everpreg "Ever pregnant"
label val everpreg vyesno

* Healthcare Utilisation
recode D2Q (1/2=1)(3=0), gen(medaid) 
label var medaid "Covered by medical insurance" 
label val medaid vyesno 
gen x = F_2Y_AQ*12 + F_2M_AQ  
gen hcare1mo_public = 0
replace hcare1mo_public = 1 if x ==0 
label var hcare1mo_public "Healthcare last month: public hospital/clinic"
label val hcare1mo_public vyesno
drop x
gen x = F_1Y_AQ*12 + F_1M_AQ  
gen hcare1mo_private = 0
replace hcare1mo_private = 1 if x ==0 
label var hcare1mo_private "Healthcare last month: private hospital/clinic/doctor"
label val hcare1mo_private vyesno

* Geographic
rename province prov2001
label var prov2001 "Province (2001 boundaries)"
label val prov2001 vprov2001
rename geotype geotype4 
label var geotype4 "Geotype (4 categories)"
label val geotype4 vgeotype4
recode geotype4 (1/2=1)(3/4=2), gen(geotype2)
label var geotype2 "Geotype (urban/rural)"
label val geotype2 vgeotype2

* Administrative 
gen inty = 2012
label var inty "Year of interview"
rename fvm intm
label var intm "Month of interview"

rename ea psu
label var psu "Primary Sampling Unit"
gen stratum = prov2001
label var stratum "Stratum"
rename indv_wgt_answ_qstn_bench aweight            // Questionnaire weights 
rename indv_wgt_answ_phys_bench_new aweight_phys       // Physical examination weights
rename indv_wgt_answ_lab_bench_new aweight_lab        // Laboratory weights
label var aweight "Sampling weight - Adult Questionnaire"

* Biomarkers
rename cholesterols_res_edited chol_tot
label var chol_tot "Total cholesterol [mmol/l]"
rename cholhdls_res chol_hdl
destring chol_hdl, replace force
label var chol_hdl "Hdl cholesterol [mmol/l]"
rename ldl_chol chol_ldl 
label var chol_ldl "Ldl cholesterol [mmol/l]"
rename triglycerideres_edited trig
label var trig "Triglicerides [mmol/l]" 

*rename glycatededited1 HbA1c 
gen HbA1c = 10.929 * (gly - 2.15)

label var HbA1c "hb1ac [mmol/mol]"
rename HB_edited hb
label var hb "hb1ac [mmol/mol]"
						
* Anthropometric
rename g2_1_ac height1
label var height1 "Height [cm] - reading 1"
rename g2_2_ac height2
label var height2 "Height [cm] - reading 2"
rename g2_3_ac height3
label var height3 "Height [cm] - reading 3"
rename adult_weight weight1
label var weight1 "Weight [kg] - reading 1" 
rename g3_1_ac arm1
label var arm1 "Arm circumference [cm] - reading 1"
rename g3_2_ac arm2
label var arm2 "Arm circumference [cm] - reading 2"
rename g3_3_ac arm3
label var arm3 "Arm circumference [cm] - reading 3"
rename g8_1_ac waist1
label var waist1 "Waist circumference [cm] - reading 1"
rename g8_2_ac waist2
label var waist2 "Waist circumference [cm] - reading 2"
rename g8_3_ac waist3
label var waist3 "Waist circumference [cm] - reading 3"
rename g9_1_ac hip1
label var hip1 "Hip circumference [cm] - reading 1"
rename g9_2_ac hip2
label var hip2 "Hip circumference [cm] - reading 2"
rename g9_3_ac hip3
label var hip3 "Hip circumference [cm] - reading 3"
rename e1_1_ac sbp1
label var sbp1 "Systolic Blood Pressure [mmHg] - reading 1"
rename e2_1_ac dbp1
label var dbp1 "Diastolic Blood Pressure [mmHg] - reading 1"
rename e3_1_ac rhr1
label var rhr1 "Resting Heart Rate [bpm] - reading 1"
rename e1_2_ac sbp2
label var sbp2 "Systolic Blood Pressure [mmHg] - reading 2"
rename e2_2_ac dbp2
label var dbp2 "Diastolic Blood Pressure [mmHg] - reading 2"
rename e3_2_ac rhr2
label var rhr2 "Resting Heart Rate [bpm] - reading 2"
rename e1_3_ac sbp3
label var sbp3 "Systolic Blood Pressure [mmHg] - reading 3"
rename e2_3_ac dbp3
label var dbp3 "Diastolic Blood Pressure [mmHg] - reading 3"
rename e3_3_ac rhr3
label var rhr3 "Resting Heart Rate [bpm] - reading 3"

* Environmental
recode E16Q (1=1)(2/9 = 0), gen(refuseremoved)
label var refuseremoved "Refuse removed weekly by local authorities"
label val refuseremoved vyesno

* Variables for asset index 
	* Cooking fuel
tab E13Q, gen(w_SANHANES2012_cookfuel)
drop w_SANHANES2012_cookfuel1
	* heating fuel
tab E14Q, gen(w_SANHANES2012_heathfuel)
drop w_SANHANES2012_heathfuel1
	* People per room
gen w_SANHANES2012_proom = sleeprooms/hsize
	* Floor material
gen w_SANHANES2012_roof_wall_1 = roof_wall_1
gen w_SANHANES2012_roof_wall_2 = roof_wall_2
gen w_SANHANES2012_roof_wall_3 = roof_wall_3
gen w_SANHANES2012_roof_wall_4 = roof_wall_4
gen w_SANHANES2012_roof_wall_5 = roof_wall_5
    * Type of dwelling
tab	E1Q, gen(w_SANHANES2012_dwelling)
drop w_SANHANES2012_dwelling1
	* Water source
tab E8Q, gen(w_SANHANES2012_wat)
drop w_SANHANES2012_wat1
	* Sanitation
tab E11Q, gen(w_SANHANES2012_san)
drop w_SANHANES2012_san1
	* Refuse disposal
tab E16Q, gen(w_SANHANES2012_refusedisp)
drop w_SANHANES2012_refusedisp1
	* Durable Items 
gen w_SANHANES2012_ass_fridge = ass_fridge
gen w_SANHANES2012_ass_stove = ass_stove
gen w_SANHANES2012_ass_vacuum = ass_vacuum
gen w_SANHANES2012_ass_computer = ass_computer
gen w_SANHANES2012_ass_wmachine = ass_wmachine 
gen w_SANHANES2012_ass_sat = ass_sat
gen w_SANHANES2012_ass_video = ass_video 
gen w_SANHANES2012_ass_car_truck = ass_car_truck
gen w_SANHANES2012_ass_radio = ass_radio
gen w_SANHANES2012_ass_tv = ass_tv
gen w_SANHANES2012_ass_phone = ass_phone
gen w_SANHANES2012_ass_cellphone = ass_cellphone

* Select variables
# delimit ;
keep                                                                                                                       
prov2001 psu age sex geotype4 hhid hsize edu1 edu2 intm sleeprooms refuseremoved aweight aweight_phys aweight_lab hweight chol_tot chol_hdl chol_ldl trig HbA1c hb weight1 height1 
height2 height3 waist1 waist2 waist3 arm1 arm2 arm3 hip1 hip2 hip3 sbp1 sbp2 sbp3 dbp1 dbp2 dbp3 rhr1 rhr2 rhr3 race emp cookingfuel heatingfuel 
ass_fridge ass_stove ass_vacuum ass_wmachine ass_computer ass_sat ass_video ass_car_truck ass_tv ass_radio ass_phone ass_cellphone roof_wall_1 
roof_wall_2 roof_wall_3 roof_wall_4 roof_wall_5 roof_wall_9999 water toilet sharedtoilet foodinsec self_health diag_hbp diag_stroke diag_isch  
diag_chol diag_diab diag_tb bpmed diabmed cholmed smokstatus currsmok curralc alcavg alcbing gpaq gpaqcat exercisefreq everpreg medaid 
hcare1mo_private hcare1mo_public geotype2 inty stratum dwelling alcfreq alcqnt dist* w_*; 
# delimit cr

* Save temporary
save "$TEMP/TEMP_4.dta", replace

******************************************************************************************************************************************************
* CONSOLIDATE                                                                                                                                        * 
******************************************************************************************************************************************************

use "$TEMP/TEMP_4.dta", clear

* Add derived
gen nsleeprooms = sleeprooms/hsize
label var nsleeprooms "People per sleeping room"

* Delete observations with missing sampling weights
keep if aweight <. & hweight <. & aweight > 0 & hweight > 0

* Delete observations with missing data on sex and/or age 
keep if age <. & sex <. 

* Add source identifier
gen source = "SANHNANES 2012"
label var source "Source"

* Add individual identifier
gen pid = _n
label var pid "Individual ID"

* Rescale sampling weights to sum to the sample size
sum aweight
local wmean = r(mean)
replace aweight = aweight/`wmean'

* Save temporary
save "$TEMP/TEMP_5.dta", replace

******************************************************************************************************************************************************
* ANCHOR POINTS FOR COMPARATIVE WEALTH INDEX                                                                                                         * 
******************************************************************************************************************************************************

use "$DATASET_1", clear 
 
forvalues i=1/20 {
	recode A_P`i'_Q12 (0/6=0) (7/17=1) (18=.) (98=0) (.=.), gen (primaryed_`i')
	label var primaryed_`i' "Completed primary school household member `i'"
	label values primaryed_`i' vyesno
}

egen edunum = rownonmiss(primaryed_*)
egen primaryed_hh = rowmax(primaryed_*)

* Recoding to missing if no household member has completed primary school but some household members have missing education.  
* Sum primaryed_hh if primaryed_hh==0 & edunum < LISTED_PERSONS

replace primaryed_hh=. if primaryed_hh==0 & edunum < LISTED_PERSONS

gen edu_deprived=.
replace edu_deprived=1 if primaryed_hh==0
replace edu_deprived=0 if primaryed_hh==1
label var edu_deprived "No household member has completed primary school"
label values edu_deprived vyesno

rename vpno hhid
keep edu_deprived hhid

* Save temporary
save "$TEMP/TEMP_6A.dta", replace

use "$TEMP/TEMP_5.dta", clear
/*The path for the recoded master household dataset needs to be added*/
duplicates drop hhid, force
merge 1:1 hhid using "$TEMP/TEMP_6A.dta"
keep if _merge==3
drop _merge

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
save "$TEMP/TEMP_6B.dta", replace

******************************************************************************************************************************************************
* SAVE & ERASE TEMPORARY FILES                                                                                                                       * 
******************************************************************************************************************************************************

use "$TEMP/TEMP_5.dta", clear
merge m:1 hhid using "$TEMP/TEMP_6B.dta"
keep if _merge == 3
drop _merge

* Delete value labels
label drop _all

* Label the datset
label data "SANHANES 2012 - Core Variables - $S_DATE"

* Save & erase temps  
save "$TEMP/SANHANES2012.dta", replace
erase "$TEMP/TEMP_1A.dta"
erase "$TEMP/TEMP_1B.dta"
erase "$TEMP/TEMP_2.dta"
erase "$TEMP/TEMP_3.dta"
erase "$TEMP/TEMP_4.dta"
erase "$TEMP/TEMP_5.dta"
erase "$TEMP/TEMP_6A.dta"
erase "$TEMP/TEMP_6B.dta"
