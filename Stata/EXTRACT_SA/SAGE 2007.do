******************************************************************************************************************************************************
* EXPOSE - DATA EXTRACTION                                                                                                                           *
* Study on global AGEing and adult health 2007 (SAGE 2007)                                                                                           *
* Annibale Cois (acois@sun.ac.za) & Kafui Adjaye-Gbewonyo (k.adjayegbewonyo@greenwich.ac.uk) & Meseret Mamo (mesistar.mamo@gmail.com)                *
* Version 1.0 - September 2022                                                                                                                       *
******************************************************************************************************************************************************

clear
set more off

******************************************************************************************************************************************************
* LOCATION OF FILES AND FOLDERS                                                                                                                      * 
******************************************************************************************************************************************************

* SOURCE FILES
global DATASET_1 "$BASEDIR/SAGE/Datafiles/SouthAfricaHHData.dta"                // HOUSEHOLD QUESTIONNAIRE  
global DATASET_2 "$BASEDIR/SAGE/Datafiles/SouthAfricaINDData.dta"               // INDIVIDUAL QUESTIONNAIRE
global AUXILIARY_1 "$AUX/Geocoding/MNDC_2001_MATCH.dta"                         // GEOGRAPHICAL RECODING (MATCH EAS WITH DISTRICTS IN 2001)  

******************************************************************************************************************************************************
* EXTRACTION                                                                                                                                         * 
******************************************************************************************************************************************************

// HOUSEHOLD QUESTIONNAIRE

use "$DATASET_1", clear

* Identifiers
drop hhid
rename q0002 hhid
label var hhid "Household ID"

rename hhid2ndwave hhid2
label var hhid "Household ID - wave 2"

* Administrative 
rename q0006_dd intd
label var intd "Day of interview"
rename q0006_mm intm
label var intm "Month of interview"
rename q0006_yyyy inty
label var inty "Year of interview"
rename q0101b psu
label var psu "Primary Sampling Unit"
gen hweight = hhweight
drop hhweight
label var hweight "Sampling weight - Household Questionnaire"
rename strata stratum 
label var stratum "Stratum"

* Geographic
rename q0104 geotype2 
label var geotype2 "Geotype (urban/rural)"
label val geotype2 vgeotype2
encode q0105a, gen(prov2001)
recode prov2001 (1=2)(2=4)(3=7)(4=5)(5=9)(6=8)(7=6)(8=3)(9=1)
label var prov2001 "Province (2001 boundaries)"
label val prov2001 vprov2001

   * Recover municipalities codes 

gen long ea_code = psu
merge m:1 ea_code using "$AUXILIARY_1"
keep if _merge == 3
drop _merge

rename dc_pr_c dist2001
label var dist2001 "District (2001 boundaries)"
label val dist2001 vdist2001

* Socioeconomic
rename q0401 hsize
label var hsize "Household size"
rename q0503 totrooms
label var totrooms "Number of rooms"
gen ntotrooms = hsize/totrooms 
label var ntotrooms "People per room"
recode q0506 (1=1)(2=2)(3=3)(4/6=5)(7/8=7)(9=6)(11/12=4)(13=7)(87=9999)(88=.), gen(water)
label var water "Source of drinking water"
label val water vwater
recode q0508 (1/5=1)(6=2)(7/11=3)(12=4)(87=9999)(88=.), gen(toilet)
label var toilet "Toilet facilities"
label val toilet vtoilet
recode q0509 (1=1)(2=0)(8=.), gen(sharedtoilet)
label var sharedtoilet "Shared toilet facility"
label val sharedtoilet vyesno
recode q0510 (1=2)(2=1)(3=3)(4=4)(5=5)(7=6)(8=5)(87=9999)(88=.), gen(cookingfuel)
label var cookingfuel "Main cooking fuel"
label val cookingfuel vcookingfuel
recode q0501 (1=1)(2=0)(3=1)(4/7=0)(8/9=.), gen(ownhome)
label var ownhome "Home owned by a household member" 
label values ownhome vyesno
gen hhincome = q0724/12
label var hhincome "Household monthly income"
rename quintile_c hhincome_quint
label var hhincome_quint "Household montly income quintile"
label val hhincome_quint vwealth_quint
recode q0701 (0=0) (1/100=1), gen(ass_tv)
label var ass_tv "Assets: TV" 
label values ass_tv vyesno
recode q0702 (0=0) (1/100=1), gen(ass_tab)
label var ass_tab "Assets: table" 
label values ass_tab vyesno
recode q0703 (0=0) (1/100=1), gen(ass_car_truck)
label var ass_car_truck "Assets: car/truck" 
label values ass_car_truck vyesno
recode q0704 (1=1) (2=0) (8=.), gen(ass_elec)
label var ass_elec "Assets: electricity"
label values ass_elec vyesno
recode q0705 (1=1)(2=0)(8=.), gen(ass_bicycle)
label var ass_bicycle "Assets: bicycle"
label values ass_bicycle vyesno
recode q0706 (1=1)(2=0)(8=.), gen(ass_sink)
label var ass_sink "Assets: built-in kitchen sink"
label values ass_sink vyesno
recode q0707 (1=1)(2=0)(8=.), gen(ass_hotw)
label var ass_hotw "Assets: hot running water"
label values ass_hotw vyesno
recode q0708 (1=1)(2=0)(8=.), gen(ass_wmachine)
label var ass_wmachine "Assets: washing machine" 
label values ass_wmachine vyesno
recode q0709 (1=1)(2=0)(8=.), gen(ass_dishwasher)
label var ass_dishwasher "Assets: dishwasher" 
label values ass_dishwasher vyesno
recode q0710 (1=1)(2=0)(8=.), gen(ass_fridge)
label var ass_fridge "Assets: fridge" 
label values ass_fridge vyesno
recode q0711 (1=1)(2=0)(8=.), gen(ass_phone)
label var ass_phone "Assets: telephone"
label val ass_phone vyesno
recode q0712 (1=1)(2=0)(8=.), gen(ass_cellphone)
label var ass_cellphone "Assets: cellphone" 
label values ass_cellphone vyesno
recode q0713 (1=1)(2=0)(8=.), gen(ass_radio)
label var ass_radio "Assets: radio"
label values ass_radio vyesno
recode q0714 (1=1)(2=0)(8=.), gen(ass_computer)
label var ass_computer "Assets: computer" 
label values ass_computer vyesno
recode q0715 (1=1)(2=0)(8=.), gen(ass_hifi)
label var ass_hifi "Assets: hi-fi stereo, CD player, MP3 player" 
label values ass_hifi vyesno
recode q0716 (1=1)(2=0)(8=.), gen(ass_livestock)
label var ass_livestock "Assets: livestock" 
label values ass_livestock vyesno
recode q0717 (1=1)(2=0)(8=.), gen(ass_smachine)
label var ass_smachine "Assets: sewing machine" 
label values ass_smachine vyesno
recode q0718 (1=1)(2=0)(8=.), gen(ass_motorcycle)
label var ass_motorcycle "Assets: motorcycle" 
label values ass_motorcycle vyesno
recode q0719 (1=1)(2=0)(8=.), gen(ass_animalcart)
label var ass_animalcart "Assets: animal cart" 
label values ass_animalcart vyesno
recode q0607 (1=1)(2=0)(8=.), gen(govsupport)
label values govsupport vyesno
label variable govsupport "Household received government support"
recode q0504 (1=1)(2=2)(8/9=.), gen(floormaterial2)
label var floormaterial2 "Floor material (2 categories)" 
label val floormaterial2 vfloormaterial2
recode q0505 (1=1)(2=2)(3=3)(4=4)(5=5)(7=9999)(8=.), gen(wallmaterial2) 
label var wallmaterial2 "Wall material"
label val wallmaterial2 vwallmaterial2

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
rename cook7 cook_other
replace cook_other=. if cook_other==0

label var cook_elec "Cooking fuel: Electricity"
label var cook_gas "Cooking fuel: Gas"
label var cook_par "Cooking fuel: Paraffin" 
label var cook_wood "Cooking fuel: Wood"
label var cook_coal "Cooking fuel: Coal"
label var cook_dung "Cooking fuel: Animal dung"
label var cook_other "Cooking fuel: Other" 

* Variables for asset index 
	* Cooking fuel
tab q0510, gen(w_SAGE2007_cookfuel)
drop w_SAGE2007_cookfuel1
	* People per room
gen w_SAGE2007_troom = ntotrooms
	* Floor material
tab q0504, gen(w_SAGE2007_flo)
drop w_SAGE2007_flo1
	* Wall material
tab q0505, gen(w_SAGE2007_wal)
drop w_SAGE2007_wal1
	* Water source
tab q0506, gen(w_SAGE2007_wat)
drop w_SAGE2007_wat1
	* Sanitation
tab q0508, gen(w_SAGE2007_san)
drop w_SAGE2007_san1
	* Durable Items 
gen w_SAGE207_ass_tv = ass_tv
gen w_SAGE207_ass_tab = ass_tab
gen w_SAGE207_ass_car_truck = ass_car_truck
gen w_SAGE207_ass_elec = ass_elec
gen w_SAGE207_ass_bicycle = ass_bicycle
gen w_SAGE207_ass_sink = ass_sink
gen w_SAGE207_ass_hotw = ass_hotw
gen w_SAGE207_ass_wmachine = ass_wmachine
gen w_SAGE207_ass_dishwasher = ass_dishwasher
gen w_SAGE207_ass_fridge = ass_fridge
gen w_SAGE207_ass_phone = ass_phone
gen w_SAGE207_ass_cellphone = ass_cellphone
gen w_SAGE207_ass_radio = ass_radio
gen w_SAGE207_ass_computer = ass_computer
gen w_SAGE207_ass_hifi = ass_hifi
gen w_SAGE207_ass_livestock = ass_livestock
gen w_SAGE207_ass_smachine = ass_smachine
gen w_SAGE207_ass_motorcycle = ass_motorcycle
gen w_SAGE207_ass_animalcart = ass_animalcart
gen w_SAGE207_govsupport = govsupport

* Psychosocial
recode q0421 (1=1)(2=0) (8=.), gen(housedeaths2)
label var housedeaths2 "Death in the household in last 24 months"
label values housedeaths2 vyesno

* Save temporary
drop s0* q0*
save "$TEMP/TEMP_1.dta", replace

// INDIVIDUAL QUESTIONNAIRE

use "$DATASET_2", clear

* Demographics & Geographics
rename q0406 sex
label var sex "Sex"
label val sex vsex	
rename q0407 age
label var age "Age [years]"
gen vmarital=.
replace vmarital=1 if q0408==2 | q0408==3
replace vmarital=2 if q0408==5 | q0408==4
replace vmarital=3 if q0408==1 
rename vmarital marstatus
label var marstatus "Marital status"
label values marstatus vmarstatus
gen vrace=.
replace vrace=1 if q1018==1
replace vrace=2 if q1018==3
replace vrace=3 if q1018==2
replace vrace=4 if q1018==4
replace vrace =9999 if q1018==87 
rename vrace race
label variable race "Population group"
rename q0104 geotype2
label var geotype2 "Geotype (urban/rural)"
label val geotype2 vgeotype2

* Administrative
gen aweight = pweight
label var aweight "Sampling weight - Adult Questionnaire"

* Identifiers
rename q0002 hhid
label var hhid "Household ID"
destring id, gen(pid)
label var pid "Individual ID"

* Socioeconomic
gen vedu=.
replace vedu=0 if q0409==0
replace vedu=1 if q0409==1
replace vedu=2 if q0409==2
replace vedu=3 if q0409==3
replace vedu=4 if q0409==4
replace vedu=5 if q0409==5 | q0409==6
gen edu2=vedu
replace edu2=4 if vedu==5
label values edu2 vedu2
label variable edu2 "Education (5 categories)"
gen vemp=.
replace vemp=0 if q1503==2
replace vemp=1 if q1503==1
replace vemp=0 if q1503==9 
rename vemp emp
label var emp "Employment status"
label val emp vemp

* Behavioural
recode q3010 (0=0)(1=6)(2=24)(3=130)(4=312)(8=.)(9=0), gen(alcf) // Alc freq per year
gen alcfreq=alcf/52
label var alcfreq "Number drinking days per week"
gen alcqnt=q3011
replace alcqnt =. if q3011<0 
label var alcqnt "Number of drinks per drinking occasion"
gen alcavg=alcfreq*alcqnt*12/7
replace alcavg=0 if alcfreq==0
replace alcavg=0 if q3007==2
label var alcavg "Average alcohol consumption [g/d]"
gen alcstatus=.
replace alcstatus=0 if q3007==2 
replace alcstatus=1 if alcfreq==0 & q3007==1 
replace alcstatus=2 if q3007==1 & alcfreq>0 & q3010<. 
label values alcstatus valcstatus
label variable alcstatus "Alcohol use status"
recode alcstatus (1=0) (2=1), gen(curralc)
label values curralc vyesno
label variable curralc "Current drinker"
gen smokstatus=.
replace smokstatus=0 if q3001==2 
replace smokstatus=1 if  q3001==1 & q3002==3 
replace smokstatus=2 if q3001==1 & (q3002==1 | q3002==2) 
label values smokstatus vsmokstatus
label variable smokstatus "Smoking status"
recode smokstatus (0/1=0) (2=1), gen(currsmok)
label values currsmok vyesno
label variable currsmok "Current smoker"

	* GPAQ (coding as per manual)                                                  
		* Impute items according to skip patterns 
replace q3017=0 if q3016==2
replace q3018h=0 if q3016==2
replace q3018m=0 if q3016==2
replace q3020=0 if q3019==2
replace q3021h=0 if q3019==2
replace q3021m=0 if q3019==2
replace q3023=0 if q3022==2
replace q3024h=0 if q3022==2
replace q3024m=0 if q3022==2
replace q3026=0 if q3025==2 
replace q3027h=0 if q3025==2 
replace q3027m=0 if q3025==2 
replace q3029=0 if q3028==2 
replace q3030h=0 if q3028==2 
replace q3030m=0 if q3028==2 
		* Clean missing data in minutes/hours fields 
egen M1 = rowmiss(q3018h q3018m)  
egen M2 = rowmiss(q3021h q3021m)  
egen M3 = rowmiss(q3024h q3024m)  
egen M4 = rowmiss(q3027h q3027m)  
egen M5 = rowmiss(q3030h q3030m)       
replace q3018h=0 if q3018h>=. 
replace q3018m=0 if q3018m>=. 
replace q3021h=0 if q3021h>=. 
replace q3021m=0 if q3021m>=. 
replace q3024h=0 if q3024h>=. 
replace q3024m=0 if q3024m>=. 
replace q3027h=0 if q3027h>=. 
replace q3027m=0 if q3027m>=. 
replace q3030h=0 if q3030h>=. 
replace q3030m=0 if q3030m>=. 
replace q3018h=. if M1==2
replace q3018m=. if M1==2
replace q3021h=. if M2==2
replace q3021m=. if M2==2
replace q3024h=. if M3==2
replace q3024m=. if M3==2
replace q3027h=. if M4==2
replace q3027m=. if M4==2
replace q3030h=. if M5==2
replace q3030m=. if M5==2
		* Clean	 
replace q3017=. if q3017>7
replace q3020=. if q3020>7
replace q3023=. if q3023>7
replace q3026=. if q3026>7
replace q3029=. if q3029>7
		* Recode variables
rename q3017 WVIG_FREQ
gen WVIG_DUR = q3018h*60+q3018m
rename q3020 WMOD_FREQ
gen WMOD_DUR = q3021h*60+q3021m
rename q3023 TRA_FREQ
gen TRA_DUR = q3024h*60+q3024m
rename q3026 NVIG_FREQ
gen NVIG_DUR = q3027h*60+q3027m
rename q3029 NMOD_FREQ
gen NMOD_DUR = q3030h*60+q3030m	 	
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
replace exercisefreq = 0 if q3025 == 2 & q3028 == 2
label var exercisefreq "Weekly frequency of exercise/leisure time physical activity"
label val exercisefreq vexercisefreq 

* Healthcare
gen hcare1mo_need=.
replace hcare1mo_need=1 if q5001yy==0 & (q5001mm==0 | q5001mm==1)
replace hcare1mo_need=0 if q5001yy==98
replace hcare1mo_need=0 if q5001mm==98
replace hcare1mo_need=0 if q5001yy>=1 & q5001yy<88
replace hcare1mo_need=0 if q5001mm>1 & q5001mm<88
tab hcare1mo_need
label var hcare1mo_need "Did you need health care within the last month?"
label values hcare1mo_need vyesno

gen hcare1mo=.
replace hcare1mo=1 if hcare1mo_need==1 & q5002==1
replace hcare1mo=0 if hcare1mo_need==1 & q5002==0
replace hcare1mo=0 if hcare1mo_need==0
label var hcare1mo "Healthcare consultations last month"
label values hcare1mo vyesno
 
gen hcare12mo_need=.
replace hcare12mo_need=1 if q5001yy==0 | q5001yy==1
replace hcare12mo_need=0 if q5001yy==98
replace hcare12mo_need=0 if q5001mm==98
replace hcare12mo_need=0 if q5001yy>1 & q5001yy<88
label var hcare12mo_need "Did you need health care within the last year?"
label values hcare12mo_need vyesno
tab hcare12mo_need
 
gen hcare12mo=.
replace hcare12mo=1 if hcare12mo_need==1 & q5002==1
replace hcare12mo=0 if hcare12mo_need==1 & q5002==0
replace hcare12mo=0 if hcare12mo_need==0
label var hcare12mo "Healthcare consultation last year"
label values hcare12mo vyesno
tab hcare12mo

*Healthcare consultation type
gen hcare1mo_type=.
replace hcare1mo_type=1 if ((q5004==4 | q5004==5) & hcare1mo==1) /*Public*/
replace hcare1mo_type=2 if ((q5004==1 | q5004==2 | q5004==3) & hcare1mo==1) /*Private*/
replace hcare1mo_type=3 if (q5004==9  & hcare1mo==1) /*Chemist/nurse*/
replace hcare1mo_type=4 if (q5004==8  & hcare1mo==1) /*Traditional*/
replace hcare1mo_type=9999 if ((q5004==6 | q5004==7 | q5004==87 ) & hcare1mo==1) /*Other, includes charity hospitals/clinics*/
replace hcare1mo_type=0 if hcare1mo==0
label variable hcare1mo_type "Health consultation type, 1 month"
label values hcare1mo_type vhvisit_type

*Generate indicator variable with 1 for yes and missing for all others, except for those who did not have a visit in the last month, for use with 1998 DHS
tabulate hcare1mo_type, gen(hcare1mo)
replace hcare1mo2=. if hcare1mo2==0
replace hcare1mo2=0 if hcare1mo==0
rename hcare1mo2 hcare1mo_public
label variable hcare1mo_public "Healthcare last month: public hospital/clinic"
label values hcare1mo_public vyesno
replace hcare1mo3=. if hcare1mo3==0
replace hcare1mo3=0 if hcare1mo==0
rename hcare1mo3 hcare1mo_private
label variable hcare1mo_private "Healthcare last month: private hospital/clinic/doctor"
label values hcare1mo_private vyesno
replace hcare1mo4=. if hcare1mo4==0
replace hcare1mo4=0 if hcare1mo==0
rename hcare1mo4 hcare1mo_chem_nurse
label variable hcare1mo_chem_nurse "Healthcare last month: chemist/pharmacist/nurse"
label values hcare1mo_chem_nurse vyesno
replace hcare1mo5=. if hcare1mo5==0
replace hcare1mo5=0 if hcare1mo==0
rename hcare1mo5 hcare1mo_trad
label variable hcare1mo_trad "Healthcare last month: traditional/faith healer"
label values hcare1mo_trad vyesno
replace hcare1mo6=. if hcare1mo6==0
replace hcare1mo6=0 if hcare1mo==0
rename hcare1mo6 hcare1mo_other
label variable hcare1mo_other "Healthcare last month: other" 
label values hcare1mo_other vyesno

* Diagnoses
recode q4010 (1=1) (2=0) (8=.), gen(diag_stroke)
label values diag_stroke vyesno
label variable diag_stroke "Diagnosis: stroke"

recode q4014 (1=1) (2=0) (8=.), gen(diag_isch)
label values diag_isch vyesno
label variable diag_isch "Diagnosis: angina/heart attack"

recode q4022 (1=1) (2=0) (8=.), gen(diag_diab)
label values diag_diab vyesno
label variable diag_diab "Diagnosis: diabetes"

recode q4025 (1=1) (2=0) (8=.), gen(diag_emph)
label values diag_emph vyesno
label variable diag_emph "Diagnosis: chronic lung disease"
tab diag_emph

tab q4033
recode q4033 (1=1) (2=0) (8=.), gen(diag_asth)
label values diag_asth vyesno
label variable diag_asth "Diagnosis: asthma"

recode q4060 (1=1) (2=0) (8=.), gen(diag_hbp)
label values diag_hbp vyesno
label variable diag_hbp "Diagnosis: hypertension"

* Medication
gen strokemed=.
replace strokemed=1 if q4011a==1 /*Yes*/
replace strokemed=0 if q4011a==2 /*No*/
replace strokemed=0 if diag_stroke==0 /*No*/
label values strokemed vyesno
label variable strokemed "Current use of stroke medication - self"
gen ischmed=.
replace ischmed=1 if q4015a==1 /*Yes*/
replace ischmed=0 if q4015a==2 /*No*/
replace ischmed=0 if diag_isch==0 /*No*/
label values ischmed vyesno
label variable ischmed "Current use of medication for ischemic heart disease - self"
gen diabmed=.
replace diabmed=1 if q4023a==1 /*Yes*/
replace diabmed=0 if q4023a==2 /*No*/
replace diabmed=0 if diag_diab==0 /*No*/
label values diabmed vyesno
label variable diabmed "Current use of diabetes medication - self"
gen emphmed=.
replace emphmed=1 if q4026a==1 /*Yes*/
replace emphmed=0 if q4026a==2 /*No*/
replace emphmed=0 if diag_emph==0 /*No*/
label values emphmed vyesno
label variable emphmed "Current use of medication for chronic lung disease - self"
gen asthmed=.
replace asthmed=1 if q4034a==1 /*Yes*/
replace asthmed=0 if q4034a==2 /*No*/
replace asthmed=0 if diag_asth==0 /*No*/
label values asthmed vyesno
label variable asthmed "Current use of asthma medication - self"
gen bpmed=.
replace bpmed=1 if q4061a==1 /*Yes*/
replace bpmed=0 if q4061a==2 /*No*/
replace bpmed=0 if diag_hbp==0 /*No*/
label values bpmed vyesno
label variable bpmed "Current use of antihypertensive medication - self"

* Self-rated health
recode q2000 (4/5=1) (3=2) (2=3) (1=4) (8/9=.), gen(self_health)
label var self_health "Perceived health status"
label values self_health vself_health

* Medical insurance
recode q0411 (1/3=1) (4=0) (8/9=.), gen(medaid)
label values medaid vyesno
label variable medaid "Covered by medical insurance"

*Anthropometrics
	*Blood pressure
rename q2501_s sbp1
replace sbp1=. if sbp1<0
label var sbp1 "Systolic Blood Pressure [mmHg] - reading 1"
rename q2502_s sbp2
replace sbp2=. if sbp2<0
label var sbp2 "Systolic Blood Pressure [mmHg] - reading 2"
rename q2503_s sbp3
replace sbp3=. if sbp3<0
label var sbp3 "Systolic Blood Pressure [mmHg] - reading 3"
rename q2501_d dbp1
label var dbp1 "Diastolic Blood Pressure [mmHg] - reading 1"
replace dbp1=. if dbp1<0
rename q2502_d dbp2
label var dbp2 "Diastolic Blood Pressure [mmHg] - reading 2"
replace dbp2=. if dbp2<0
rename q2503_d dbp3
replace dbp3=. if dbp3<0 
label var dbp3 "Diastolic Blood Pressure [mmHg] - reading 3"
 
	* Heart rate
rename q2501a_p rhr1
replace rhr1=. if rhr1<0
label var rhr1 "Resting Heart Rate [bpm] - reading 1"
rename q2502a_p rhr2
replace rhr2=. if rhr2<0
label var rhr2 "Resting Heart Rate [bpm] - reading 2"
rename q2503a_p rhr3
replace rhr3=. if rhr3<0 
label var rhr3 "Resting Heart Rate [bpm] - reading 3"

	* Height, weight, waist, hip
rename q2506 height1
replace height1=. if height1>996
label var height1 "Height [cm] - reading 1"
rename q2507 weight1
replace weight1=. if weight>996
label var weight1 "Weight [kg] - reading 1"
rename q2508 waist1
replace waist1=. if waist1>996
label var waist1 "Waist circumference [cm] - reading 1"
rename q2509 hip1
replace hip1=. if hip1>996
replace hip1=. if hip1<0
label var hip1 "Hip circumference [cm] - reading 1"
 
gen veatless=.
replace veatless=0 if q3014==5
replace veatless=1 if q3014==1 | q3014==2 | q3014==3 | q3014==4
gen vhungry=.
replace vhungry=0 if q3015==5
replace vhungry=1 if q3015==1 | q3015==2 | q3015==3 | q3015==4 

* Save temporary
save "$TEMP/TEMP_2.dta", replace

collapse (max) foodinsec_adult=veatless foodmoney=vhungry, by(hhid) 
label values foodinsec_adult vyesno
label values foodmoney vyesno
label var foodinsec_adult "Food insecurity: adult"

* Save temporary
save "$TEMP/TEMP_3.dta", replace

// Merging household food insecurity to individual 

use "$TEMP/TEMP_2.dta", clear

merge m:1 hhid using "$TEMP/TEMP_3.dta"
keep if _merge==3
drop _merge

replace foodmoney=. if foodmoney==0 & vhungry==.
replace foodinsec_adult=. if foodinsec_adult==0 & veatless==.

* Save temporary
keep sex geotype2 marstatus edu2 race emp alcstatus curralc smokstatus currsmok hcare1mo hcare12mo hcare1mo_public hcare1mo_private   ///
      hcare1mo_chem_nurse hcare1mo_trad hcare1mo_other diag_* *med sbp* dbp* rhr* height weight waist hip self_health age aweight pid  ///
	  foodinsec_adult alcfreq alcqnt hhid 
save "$TEMP/TEMP_3.dta", replace

******************************************************************************************************************************************************
* CONSOLIDATE                                                                                                                                        * 
******************************************************************************************************************************************************

* Merge datasets
use "$TEMP/TEMP_3.dta", clear  
merge m:1 hhid using ".\TEMP\TEMP_1.dta"
keep  if _merge == 3
drop _*

* Delete observations with missing sampling weights
keep if aweight <. & hweight <. & aweight > 0 & hweight > 0 & psu<.

* Delete observations with missing data on sex and/or age 
keep if age <. & sex <. 

* Delete identifiers 
     *  drop id iid_1 iid_2 iid_3

* Add source identifier
gen source = "SAGE 2007"
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

use "$DATASET_1", clear

forvalues i = 1/9 {
	gen primaryed_`i'=.
	replace primaryed_`i'=1 if q0409_0`i'==2 | q0409_0`i'==3 | q0409_0`i'==4 | q0409_0`i'==5 | q0409_0`i'==6
	replace primaryed_`i'=0 if q0409_0`i'==0 | q0409_0`i'==1
	label var primaryed_`i' "Completed primary school household member `i'"
	label values primaryed_`i' vyesno
}

forvalues i = 10/25 {
	gen primaryed_`i'=.
	replace primaryed_`i'=1 if q0409_`i'==2 | q0409_`i'==3 | q0409_`i'==4 | q0409_`i'==5 | q0409_`i'==6
	replace primaryed_`i'=0 if q0409_`i'==0 | q0409_`i'==1
	label var primaryed_`i' "Completed primary school household member `i'"
	label values primaryed_`i' vyesno
}

egen edunum = rownonmiss(primaryed_*)
egen primaryed_hh = rowmax(primaryed_*)
replace primaryed_hh=. if primaryed_hh==0 & edunum < q0401

gen edu_deprived=.
replace edu_deprived=1 if primaryed_hh==0
replace edu_deprived=0 if primaryed_hh==1
label var edu_deprived "No household member has completed primary school"
label values edu_deprived vyesno

drop hhid
rename q0002 hhid

keep edu_deprived hhid

* Save temporary
save "$TEMP/TEMP_5A.dta", replace


use "$TEMP/TEMP_4.dta", clear
duplicates drop hhid, force
merge 1:1 hhid using "$TEMP/TEMP_5A.dta"
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
label data "SAGE 2007 - Core Variables - $S_DATE"

save "$OUT/SAGE2007.dta", replace
erase "$TEMP/TEMP_1.dta"
erase "$TEMP/TEMP_2.dta"
erase "$TEMP/TEMP_3.dta"
erase "$TEMP/TEMP_4.dta"
erase "$TEMP/TEMP_5A.dta"
erase "$TEMP/TEMP_5B.dta"
