******************************************************************************************************************************************************
* EXPOSE - DATA EXTRACTION                                                                                                                           *
* National Income Dynamics Study Wave 2 (NIDS 2010-11)                                                                                               *
* Kafui Adjaye-Gbewonyo (k.adjayegbewonyo@greenwich.ac.uk) & Annibale Cois (acois@sun.ac.za)                                                         *
* Version 1.0 - July 2022                                                                                                                            *
******************************************************************************************************************************************************

clear
set more off

******************************************************************************************************************************************************
* LOCATION OF FILES AND FOLDERS                                                                                                                      *
******************************************************************************************************************************************************

* SOURCE FILES
global DATASET_1 "$BASEDIR/NIDS/Datafiles/Adult_W2_Anon_V4.0.0.dta"            // ADULT QUESTIONNAIRE
global DATASET_2 "$BASEDIR/NIDS/Datafiles/indderived_W2_Anon_V4.0.0.dta"       // INDIVIDUAL DERIVED 
global DATASET_3 "$BASEDIR/NIDS/Datafiles/HHQuestionnaire_W2_Anon_V4.0.0.dta"  // HOUSEHOLD QUESTIONNAIRE 
global DATASET_4 "$BASEDIR/NIDS/Datafiles/hhderived_W2_Anon_V4.0.0.dta"        // HOUSEHOLD DERIVED 
global DATASET_4A "$BASEDIR/NIDS/Datafiles/Link_File_W2_Anon_V4.0.0.dta"       // LINK FILE

******************************************************************************************************************************************************
* EXTRACTING VARIABLES                                                                                                                               * 
******************************************************************************************************************************************************

// ADULT QUESTIONNAIRE

use "$DATASET_1" , clear

keep  w2_hhid pid w2_a_intrv_d w2_a_intrv_m w2_a_intrv_y w2_a_phase w2_a_marstt w2_a_bhprg w2_a_bhbrth w2_a_bhcnt1con w2_a_hllfexer      ///
w2_a_hllfalc w2_a_hllfalcqnt w2_a_hllfsmk w2_a_hllfsmkreg w2_a_hllfsmklst w2_a_hllfsmkfrs w2_a_hllfsmkqnt w2_a_height_1 w2_a_height_2    ///
w2_a_height_3 w2_a_weight_1 w2_a_weight_2 w2_a_weight_3 w2_a_bpsys_1 w2_a_bpsys_2 w2_a_bpdia_1 w2_a_bpdia_2 w2_a_bppls_1 w2_a_bppls_2    ///
w2_a_waist_1 w2_a_waist_2 w2_a_waist_3 w2_a_hldes w2_a_hldia w2_a_hldia_stl w2_a_hlbp w2_a_hlbp_stl w2_a_hltb w2_a_hltb_stl w2_a_hlstrk  ///
w2_a_hlstrk_stl w2_a_hlast w2_a_hlast_stl w2_a_hlhrt w2_a_hlcan w2_a_hlbp_med w2_a_hldia_med w2_a_hltb_med w2_a_hlstrk_med w2_a_hlast_med /// 
w2_a_hlmedaid w2_a_hlcon w2_a_hlcontyp 

* Save temporary
save "$TEMP/TEMP_1.dta", replace

// INDIVIDUAL DERIVED  

use "$DATASET_2", clear  

keep w2_hhid pid w2_best_age_yrs w2_best_dob_m w2_best_dob_y w2_best_race w2_best_gen w2_best_edu w2_empl_stat 

* Save temporary
save "$TEMP/TEMP_2.dta", replace

// HOUSEHOLD QUESTIONNAIRE 

use "$DATASET_3", clear

keep  w2_hhid w2_h_dwlrms w2_h_dwlmatrwll w2_h_dwlmatflr w2_h_dwlmatroof w2_h_dwltyp w2_h_dwltyp_o w2_h_watsrc w2_h_watdis w2_h_toi w2_h_toi_o     ///
w2_h_toishr w2_h_enrgck w2_h_enrgck_o w2_h_enrgelec w2_h_ownrad w2_h_ownhif w2_h_owntel w2_h_ownsat w2_h_ownvid w2_h_owncom w2_h_owncam            ///
w2_h_owncel w2_h_ownelestv w2_h_owngasstv w2_h_ownparstv w2_h_ownmic w2_h_ownfrg w2_h_ownwsh w2_h_ownsew w2_h_ownlng w2_h_ownvehpri w2_h_ownvehcom ///
w2_h_ownmot w2_h_ownbic w2_h_ownboat w2_h_ownboatmot w2_h_owncrt w2_h_ownplg w2_h_owntra w2_h_ownwhl w2_h_ownmll w2_h_tellnd w2_h_telcel           /// 
w2_h_enrght w2_h_enrght_o w2_h_enrglght w2_h_enrglght_o w2_h_ownd w2_h_grn w2_h_refrem w2_h_mrt24mnth w2_h_mrtdod_m* w2_h_mrtdod_y* w2_h_ag        ///
w2_h_agcom w2_h_agls w2_h_aglscat w2_h_aglsshp w2_h_aglshrs w2_h_aglsdnk w2_h_aglscatown w2_h_aglsshpown w2_h_aglshrsown w2_h_aglsdnkown 

* Save temporary
save "$TEMP/TEMP_3.dta", replace

// HOUSEHOLD DERIVED 

use "$DATASET_4", clear

keep w2_hhid w2_wgt w2_dwgt w2_prov2011 w2_prov2001 w2_dc2011 w2_dc2001 w2_mdbdc2011 w2_geo2011 w2_geo2001 w2_hhsizer w2_hhincome

* Save temporary
save "$TEMP/TEMP_4.dta", replace

// LINK FILE

use "$DATASET_4A", clear

keep w2_hhid pid cluster csm 

* Save temporary
save "$TEMP/TEMP_4A.dta", replace

// MERGE HOUSEHOLD DATASETS INTO ONE FILE

use "$TEMP/TEMP_3.dta", clear       
merge 1:1 w2_hhid using "$TEMP/TEMP_4.dta"
keep if _merge==3
drop _merge

* Save temporary
save "$TEMP/TEMP_3A.dta", replace

// RECODING ASSETS FOR WEALTH INDEX CALCULATIONS

use "$TEMP/TEMP_3A.dta", clear

rename w2_h_enrgck cookingfuelw
replace cookingfuelw=. if cookingfuelw<0
replace cookingfuelw=11 if w2_h_enrgck_o=="Neighbour" 
replace cookingfuelw=7 if w2_h_enrgck_o=="Candle"
label variable cookingfuelw "Cooking fuel"

*Cooking fuel indicator variables*
tabulate cookingfuelw, generate(cook)
rename cook1 cookw_elec_main
rename cook2 cookw_elec_gen
rename cook3 cookw_gas
rename cook4 cookw_par
rename cook5 cookw_wood
rename cook6 cookw_coal
rename cook7 cookw_candle
rename cook8 cookw_dung
rename cook9 cookw_solar
rename cook10 cookw_none
label var cookw_gas "Cooking fuel: Gas"
label var cookw_par "Cooking fuel: Paraffin"
label var cookw_wood "Cooking fuel: Wood"
label var cookw_coal "Cooking fuel: Coal"
label var cookw_dung "Cooking fuel: Animal dung"
label var cookw_elec_main "Cooking fuel: Electricity from mains"
label var cookw_elec_gen "Cooking fuel: Electricity from generator"
label var cookw_solar "Cooking fuel: Solar"
label var cookw_none "Cooking fuel: None"
label var cookw_candle "Cooking fuel: Candles"

* Heating fuel
rename w2_h_enrght heatingfuelw
label var heatingfuelw "Heating fuel"
replace heatingfuelw=. if heatingfuel<0
tabulate heatingfuelw, generate(heat)
rename heat1 heat_elec_main
rename heat2 heat_elec_gen
rename heat3 heat_gas
rename heat4 heat_par
rename heat5 heat_wood
rename heat6 heat_coal
rename heat7 heat_dung
rename heat8 heat_solar
rename heat9 heat_other
rename heat10 heat_none

* Housing
rename w2_h_dwlrms totrooms
replace totrooms=. if totrooms<0
label var totrooms "Number of rooms"

* People per room
gen ntotrooms = w2_hhsizer/totrooms /*Number of household members per room*/
label var ntotrooms "People per room"

* Dwelling type
rename w2_h_dwltyp dwellingw
replace dwellingw=. if dwellingw<0
label var dwellingw "Dwelling type"
tabulate dwellingw, generate(dwell_)

* Wall material 
rename w2_h_dwlmatrwll wallmaterial
replace wallmaterial=. if wallmaterial<0
label variable wallmaterial "Wall material"
tabulate wallmaterial, generate(wall)
rename wall1 wall_brick
rename wall2 wall_cement
rename wall3 wall_corrugated_iron
rename wall4 wall_wood
rename wall5 wall_plastic
rename wall6 wall_cardboard
rename wall7 wall_mud_cement
rename wall8 wall_wattle_daub
rename wall9 wall_tile
rename wall10 wall_mud
rename wall11 wall_thatch_grass
rename wall12 wall_asbestos
rename wall13 wall_stone_rock
label variable wall_brick "Wall material: brick"
label variable wall_cement "Wall material: cement block/concrete"
label variable wall_corrugated_iron "Wall material: corrugated iron/zinc"
label variable wall_wood "Wall material: wood"
label variable wall_plastic "Wall material: plastic"
label variable wall_cardboard "Wall material: cardboard"
label variable wall_mud_cement "Wall material: mud/cement mix"
label variable wall_wattle_daub "Wall material: wattle and daub"
label variable wall_tile "Wall material: tile"
label variable wall_mud "Wall material: mud brick"
label variable wall_thatch_grass "Wall material: thatch"
label variable wall_asbestos "Wall material: asbestos"
label variable wall_stone_rock "Wall material: stone/rock"

* Roof material 
rename w2_h_dwlmatroof roofmaterial
replace roofmaterial=. if roofmaterial<0
label variable roofmaterial "Roof material"
tabulate roofmaterial, generate(roof)
rename roof1 roof_brick
rename roof2 roof_cement
rename roof3 roof_corrugated_iron
rename roof4 roof_wood
rename roof5 roof_plastic
rename roof6 roof_cardboard
rename roof7 roof_mud_cement
rename roof8 roof_wattle_daub
rename roof9 roof_tile
rename roof10 roof_mud
rename roof11 roof_thatch_grass
rename roof12 roof_asbestos
rename roof13 roof_stone_rock
label variable roof_brick "Roof material: brick"
label variable roof_cement "Roof material: cement block/concrete"
label variable roof_corrugated_iron "Roof material: corrugated iron/zinc"
label variable roof_wood "Roof material: wood"
label variable roof_plastic "Roof material: plastic"
label variable roof_cardboard "Roof material: cardboard"
label variable roof_mud_cement "Roof material: mud/cement mix"
label variable roof_wattle_daub "Roof material: wattle and daub"
label variable roof_tile "Roof material: tile"
label variable roof_mud "Roof material: mud brick"
label variable roof_thatch_grass "Roof material: thatch"
label variable roof_asbestos "Roof material: asbestos"
label variable roof_stone_rock "Roof material: stone/rock"

* Floor material 
rename w2_h_dwlmatflr floormaterial
replace floormaterial=. if floormaterial<0
label variable floormaterial "Floor material"
tabulate floormaterial, generate(floor)
rename floor1 floor_mud_earth
rename floor2 floor_concrete
rename floor3 floor_carpet
rename floor4 floor_tiles
rename floor5 floor_wood
rename floor6 floor_vinyl
label variable floor_mud_earth "Floor material: mud/earth"
label variable floor_concrete "Floor material: concrete"
label variable floor_carpet "Floor material: carpet"
label variable floor_tiles "Floor material: tiles"
label variable floor_wood "Floor material: wood"
label variable floor_vinyl "Floor material: linoleum/vinyl"

* Home ownership
recode w2_h_ownd (1=1) (2=0) (-3=.) (-8=.) (-9=.), gen(ownhome)
label var ownhome "A household member owns the home" 
label values ownhome vyesno
tab ownhome

* Refuse disposal
rename w2_h_refrem refuseremoved
replace refuseremoved=. if refuseremoved<0
replace refuseremoved=0 if refuseremoved==2
label var refuseremoved "Refuse removed weekly by local authorities"
label values refuseremoved vyesno

* Water and sanitation
tab w2_h_watsrc
rename w2_h_watsrc watersrc
replace watersrc=. if watersrc<0
label variable watersrc "Source of water"
tabulate watersrc, generate(water)
rename water1 water_pipe_dwell
rename water2 water_pipe_yard
rename water3 water_public_tap
rename water4 water_tanker
rename water5 water_bore_site
rename water6 water_bore_common
rename water7 water_rain_tank
rename water8 water_stream
rename water9 water_pool
rename water10 water_well
rename water11 water_spring
rename water12 water_neighbour
rename water13 water_other
rename w2_h_toi toiletw
replace toiletw=. if toiletw<0
label variable toiletw "Toilet type"
rename w2_h_toishr toilet_shared
replace toilet_shared=. if toilet_shared<0
generate toilet_combined=.
replace toilet_combined=1 if toiletw==1 & toilet_shared==2 /*Private flush to septic tank*/
replace toilet_combined=2 if toiletw==1 & toilet_shared==1 /*Shared flush to septic tank*/
replace toilet_combined=3 if toiletw==2 & toilet_shared==2 /*Private flush to sewer*/
replace toilet_combined=4 if toiletw==2 & toilet_shared==1 /*Shared flush to sewer*/
replace toilet_combined=5 if toiletw==3 & toilet_shared==2 /*Private chemical toilet*/
replace toilet_combined=6 if toiletw==3 & toilet_shared==1 /*Shared chemical toilet*/
replace toilet_combined=7 if toiletw==4 & toilet_shared==2 /*Private VIP latrine*/
replace toilet_combined=8 if toiletw==4 & toilet_shared==1 /*Shared VIP latrine*/
replace toilet_combined=9 if toiletw==5 & toilet_shared==2 /*Private unimproved pit latrine*/
replace toilet_combined=10 if toiletw==5 & toilet_shared==1 /*Shared unimproved pit latrine*/
replace toilet_combined=11 if toiletw==6 & toilet_shared==2 /*Private bucket toilet*/
replace toilet_combined=12 if toiletw==6 & toilet_shared==1 /*Shared bucket toilet*/
replace toilet_combined=13 if toiletw==9 & toilet_shared==2 /*Private other toilet*/
replace toilet_combined=14 if toiletw==9 & toilet_shared==1 /*Shared other toilet*/
replace toilet_combined=15 if toiletw==7 
label values toilet_combined vtoilet_combined
tabulate toilet_combined, generate(toilet_combined)

* Income
rename w2_hhincome hhincome
label var hhincome "Household income [ZAR]"
xtile hhincome_quint = hhincome [weight=w2_wgt], nq(5)
label val hhincome_quint vwealth_quint
label var hhincome_quint "Household income quintile, weighted sample"

* Assets
recode w2_h_enrgelec (1=1) (2=0) (-9/-2=.), gen(ass_elec)
label var ass_elec "Assets: electricity"
label values ass_elec vyesno
recode w2_h_ownrad (1=1) (2=0) (-9/-2=.), gen(ass_radio)
label var ass_radio "Assets: radio"
label values ass_radio vyesno
recode w2_h_ownhif (1=1) (2=0) (-9/-2=.), gen(ass_hifi)
label var ass_hifi "Assets: hi-fi stereo, CD player, MP3 player" 
label values ass_hifi vyesno
recode w2_h_owntel (1=1) (2=0) (-9/-2=.), gen(ass_tv)
label var ass_tv "Assets: TV" 
label values ass_tv vyesno
recode w2_h_ownsat (1=1) (2=0) (-9/-2=.), gen(ass_sat)
label var ass_sat "Assets: satellite TV" 
label values ass_sat vyesno
recode w2_h_ownvid (1=1) (2=0) (-9/-2=.), gen(ass_video)
label var ass_video "Assets: video player" 
label values ass_video vyesno
recode w2_h_owncom (1=1) (2=0) (-9/-2=.), gen(ass_computer)
label var ass_computer "Assets: computer" 
label values ass_computer vyesno
recode w2_h_owncam (1=1) (2=0) (-9/-2=.), gen(ass_camera)
label var ass_camera "Assets: camera" 
label values ass_camera vyesno
recode w2_h_owncel (1=1) (2=0) (-9/-2=.), gen(ass_cellphone)
label var ass_cellphone "Assets: cellphone" 
label values ass_cellphone vyesno
recode w2_h_ownelestv (1=1) (2=0) (-9/-2=.), gen(ass_elestv)
label var ass_elestv "Assets: electric stove" 
label values ass_elestv vyesno
recode w2_h_owngasstv (1=1) (2=0) (-9/-2=.), gen(ass_gasstv)
label var ass_gasstv "Assets: gas stove" 
label values ass_gasstv vyesno
recode w2_h_ownparstv (1=1) (2=0) (-9/-2=.), gen(ass_parstv)
label var ass_parstv "Assets: parrafin stove" 
label values ass_parstv vyesno
recode w2_h_ownmic (1=1) (2=0) (-9/-2=.), gen(ass_microwave)
label var ass_microwave "Assets: microwave oven" 
label values ass_microwave vyesno
recode w2_h_ownfrg (1=1) (2=0) (-9/-2=.), gen(ass_fridge)
label var ass_fridge "Assets: fridge" 
label values ass_fridge vyesno
recode w2_h_ownwsh (1=1) (2=0) (-9/-2=.), gen(ass_wmachine)
label var ass_wmachine "Assets: washing machine" 
label values ass_wmachine vyesno
recode w2_h_ownsew (1=1) (2=0) (-9/-2=.), gen(ass_smachine)
label var ass_smachine "Assets: sewing machine" 
label values ass_smachine vyesno
recode w2_h_ownlng (1=1) (2=0) (-9/-2=.), gen(ass_sofa)
label var ass_sofa "Assets: sofa" 
label values ass_sofa vyesno
recode w2_h_ownvehcom (1=1) (2=0) (-9/-2=.), gen(ass_com_veh)
label var ass_com_veh "Assets: commercial vehicle" 
label values ass_com_veh vyesno
recode w2_h_ownvehpri (1=1) (2=0) (-9/-2=.), gen(ass_car_truck)
label var ass_car_truck "Assets: car/truck" 
label values ass_car_truck vyesno
replace ass_car_truck = 1 if ass_com_veh == 1
drop ass_com_veh
recode w2_h_ownmot (1=1) (2=0) (-9/-2=.), gen(ass_motorcycle)
label var ass_motorcycle "Assets: motorcycle" 
label values ass_motorcycle vyesno
recode w2_h_ownbic (1=1) (2=0) (-9/-2=.), gen(ass_bicycle)
label var ass_bicycle "Assets: bicycle"
label values ass_bicycle vyesno
recode w2_h_ownboat (1=1) (2=0) (-9/-2=.), gen(ass_boat)
label var ass_boat "Assets: boat" 
label values ass_boat vyesno
recode w2_h_ownboatmot (1=1) (2=0) (-9/-2=.), gen(ass_motorboat)
label var ass_motorboat "Assets: motorboat" 
label values ass_motorboat vyesno
recode w2_h_owncrt (1=1) (2=0) (-9/-2=.), gen(ass_animalcart)
label var ass_animalcart "Assets: animal cart" 
label values ass_animalcart vyesno
recode w2_h_ownplg (1=1) (2=0) (-9/-2=.), gen(ass_plough)
label var ass_plough "Assets: plough" 
label values ass_plough vyesno
recode w2_h_owntra (1=1) (2=0) (-9/-2=.), gen(ass_tractor)
label var ass_tractor "Assets: tractor" 
label values ass_tractor vyesno
recode w2_h_ownwhl (1=1) (2=0) (-9/-2=.), gen(ass_wheelbarrow)
label var ass_wheelbarrow "Assets: wheelbarrow" 
label values ass_wheelbarrow vyesno
recode w2_h_ownmll (1=1) (2=0) (-9/-2=.), gen(ass_mill)
label var ass_mill "Assets: mill" 
label values ass_mill vyesno
recode w2_h_tellnd (1=1) (2/3=0) (-9/-2=.), gen(ass_phone)
label var ass_phone "Assets: telephone"
label values ass_phone vyseno

* Sheep & cattle ownership
gen ass_sheep_cattle_nc=.
replace ass_sheep_cattle_nc=1 if w2_h_aglscatown>0 & w2_h_aglscatown !=.
replace ass_sheep_cattle_nc=1 if w2_h_aglsshpown>0 & w2_h_aglsshpown !=. 
replace ass_sheep_cattle_nc=0 if w2_h_aglscatown==0 & w2_h_aglsshpown==0
replace ass_sheep_cattle_nc=0 if w2_h_aglscat==2 & w2_h_aglsshp==2
replace ass_sheep_cattle_nc=0 if w2_h_ag==2 | w2_h_agcom==1 | w2_h_agls==2
label values ass_sheep_cattle_nc vyesno
label var ass_sheep_cattle_nc "Assets: sheep/cattle (non-commercial)"

* Horse & donkey ownership
gen ass_donkey_horse_nc=.
replace ass_donkey_horse_nc=1 if w2_h_aglsdnkown !=. & w2_h_aglsdnkown !=-3 & w2_h_aglsdnkown !=-9 & w2_h_aglsdnkown !=0
replace ass_donkey_horse_nc=1 if w2_h_aglshrsown !=. & w2_h_aglshrsown !=-3 & w2_h_aglshrsown !=-9 & w2_h_aglshrsown !=0 
replace ass_donkey_horse_nc=0 if w2_h_aglsdnkown==0 & w2_h_aglshrsown==0
replace ass_donkey_horse_nc=0 if w2_h_aglsdnk==2 & w2_h_aglshrs==2
replace ass_donkey_horse_nc=0 if w2_h_ag==2 | w2_h_agcom==1 | w2_h_agls==2
label values ass_donkey_horse_nc vyesno
label var ass_donkey_horse_nc "Assets: donkey/horse"

* Save temporary
save "$TEMP/TEMP_3B.dta", replace

// DUPLICATING WEALTH INDICATORS FOR PCA 

use "$TEMP/TEMP_3B.dta", clear
keep ass_* cookw_* heat_* ntotrooms dwell_* ownhome wall_* roof_* water_* toilet_combined* refuseremoved w2_wgt w2_hhid

* Drop collinear dummy variables
drop cookw_elec_main heat_elec_main dwell_1 wall_brick roof_brick water_pipe_dwell toilet_combined toilet_combined1

* Rename
rename wall_corrugated_iron wall_corr_iron
rename roof_corrugated_iron roof_corr_iron
rename ass_sheep_cattle_nc ass_sheep_cat_nc
rename ass_donkey_horse_nc ass_donkey_hor_nc
rename * w_NIDS2010_* 
rename w_NIDS2010_w2_wgt w2_wgt
rename w_NIDS2010_w2_hhid w2_hhid

* Save temporary
save "$TEMP/TEMP_3B_PCA.dta", replace

* MERGING PCA INDICATORS TO HOUSEHOLD DATASET

use "$TEMP/TEMP_3B.dta", clear
merge 1:1 w2_hhid using "$TEMP/TEMP_3B_PCA.dta"
keep if _merge==3
drop _merge

* Save temporary
save "$TEMP/TEMP_3C.dta", replace

// MERGE INDIVIDUAL LEVEL DATA

use "$TEMP/TEMP_1.dta", clear       
merge 1:1 w2_hhid pid using "$TEMP/TEMP_2.dta"
keep if _merge==3
drop _merge
merge 1:1 w2_hhid pid using "$TEMP/TEMP_4A.dta"
keep if _merge==3
drop _merge

* Save temporary
save "$TEMP/TEMP_1B.dta", replace

// MERGE HOUSEHOLD DATA TO INDIVIDUAL LEVEL DATA

use "$TEMP/TEMP_1B.dta", clear  
merge m:1 w2_hhid using "$TEMP/TEMP_3C.dta"
keep if _merge==3
drop _merge

* Save temporary
save "$TEMP/TEMP_1C.dta", replace

// RECODING

use "$TEMP/TEMP_1C.dta", clear

* Recoding marital status into 3 categories
tab w2_a_marstt
generate marstatus=. 
replace marstatus=1 if w2_a_marstt==1
replace marstatus=1 if w2_a_marstt==2
replace marstatus=2 if w2_a_marstt==3
replace marstatus=2 if w2_a_marstt==4
replace marstatus=3 if w2_a_marstt==5 
replace marstatus=. if w2_a_marstt<0
label values marstatus vmarstatus
label var marstatus "Marital status"

* Recoding Education 
recode w2_best_edu (25=0) (0/6=1) (7=2) (8/11=3) (13/14=3) (16/17=3) (12=4) (15=4) (18/19=5) (20/23=5) (24=9999) (-9/-3=.), gen(edu1)	
label var edu1 "Education (6 categories)"  
label values edu1 vedu1
recode edu1 (0=0)(1=1)(2=2)(3=3)(4/5=4)(6=4), gen(edu2)
label var edu2 "Education (5 categories)"
label val edu2 vedu2

* Recoding employment status
tab w2_empl_stat
generate emp=.
replace emp=1 if w2_empl_stat==3 
replace emp=0 if w2_empl_stat==1
replace emp=0 if w2_empl_stat==2 
replace emp=0 if w2_empl_stat==0
replace emp=. if w2_empl_stat<0
label values emp vemp
label var emp "Employment status"

* Government grants/public assistance
recode w2_h_grn (-9/-3=.) (2=0), gen(recgrant)
label values recgrant vyesno
label variable recgrant "Household received government grant"

* Housing characteristics
recode toiletw (1/3=1) (4=2) (5/6=3) (7=4) (10=4) (9=9999), gen(toilet)
label values toilet vtoilet
label variable toilet "Toilet facilities"
generate sharedtoilet=toilet_shared
replace sharedtoilet=0 if toilet_shared==2
label values sharedtoilet vyesno
label var sharedtoilet "Shared toilet facility"
recode watersrc (1=1) (2=2) (3=3) (4=4) (5/6=5) (10=5) (7=6) (8/9=7) (11=7) (12/13=9999), gen(water)
label values water vwater
label variable water "Household's main source of water, recode"
recode wallmaterial (10/11=1) (8=1) (7=2) (3=3) (5/6=4) (1/2=5) (4=9999) (9=9999) (12/13=9999), generate(wall)
label values wall vwall
label variable wall "Wall material, recode"
recode roofmaterial (10/11=1) (8=1) (7=2) (3=3) (5/6=4) (1/2=5) (4=6) (12=7) (9=8) (13=9999), generate(roof)
label values roof vroof 
label variable roof "Roof material, recode"
recode floormaterial (1=1) (2=2) (3=3) (4=4) (5=5) (6=6), generate(floor)
label values floor vfloor
label variable floor "Floor material, recode"
recode cookingfuelw (1/2=1) (3=2) (4=3) (6=4) (5=5) (8=6) (7=9999) (9/11=9999), generate (cookingfuel)
label values cookingfuel vfuel
label variable cookingfuel "Household's main cooking fuel, recode"
recode heatingfuelw (1/2=1) (3=2) (4=3) (6=4) (5=5) (8=6) (7=9999) (9/11=9999), generate (heatingfuel)
label values heatingfuel vfuel
label variable heatingfuel "Household's main heating fuel, recode"

*Generating new indicators for cooking fuel, with 1 for main fuel and missing for all else and 0 for none, for harmonisation with 1998 DHS
tabulate cookingfuel, gen (cook)
rename cook1 cook_elec
replace cook_elec=. if cook_elec==0
replace cook_elec=0 if cookingfuelw==11
rename cook2 cook_gas
replace cook_gas=. if cook_gas==0
replace cook_gas=0 if cookingfuelw==11
rename cook3 cook_par
replace cook_par=. if cook_par==0
replace cook_par=0 if cookingfuelw==11
rename cook4 cook_coal
replace cook_coal=. if cook_coal==0
replace cook_coal=0 if cookingfuelw==11
rename cook5 cook_wood
replace cook_wood=. if cook_wood==0
replace cook_wood=0 if cookingfuelw==11
rename cook6 cook_dung
replace cook_dung=. if cook_dung==0
replace cook_dung=0 if cookingfuelw==11
rename cook7 cook_other
replace cook_other=. if cook_other==0
replace cook_other=0 if cookingfuelw==11

label var cook_elec "Cooking fuel: Electricity"
label var cook_gas "Cooking fuel: Gas"
label var cook_par "Cooking fuel: Paraffin" 
label var cook_wood "Cooking fuel: Wood"
label var cook_coal "Cooking fuel: Coal"
label var cook_dung "Cooking fuel: Animal dung"
label var cook_other "Cooking fuel: Other" 

* Dwelling type
recode dwellingw (1=1) (2=2) (3=3) (4=4) (5=9999) (6=5) (7=6) (8=7) (9=8) (10=9) (11=9999), generate (dwelling)
label values dwelling vdwelling
label variable dwelling "Household's dwelling type, recode"

generate ass_stove=.
replace ass_stove=1 if ass_elestv==1 | ass_gasstv==1 
replace ass_stove=0 if ass_elestv==0 & ass_gasstv==0
label var ass_stove "Assets: electric/gas stove"
label values ass_stove yesno
tab ass_stove

* Reproductive variables
gen currpreg=.
replace currpreg=0 if w2_a_bhprg==2 
replace currpreg=0 if w2_a_bhprg==-9 
replace currpreg=1 if w2_a_bhprg==1 
label values currpreg vcurrpreg
label var currpreg "Currently pregnant"
gen everpreg=. 
replace everpreg=0 if w2_a_bhbrth==2
replace everpreg=1 if w2_a_bhbrth==1 
label values everpreg vyesno
label var everpreg "Ever pregnant"
gen parity=w2_a_bhcnt1con
replace parity=. if w2_a_bhcnt1con<0
label var parity "Parity"

* Alcohol use
generate alcstatus=.
replace alcstatus=0 if w2_a_hllfalc==1
replace alcstatus=1 if w2_a_hllfalc==2
replace alcstatus=2 if w2_a_hllfalc>2
replace alcstatus=. if w2_a_hllfalc<0
replace alcstatus=. if w2_a_hllfalc==.
label values alcstatus valcstatus
label variable alcstatus "Alcohol use status"
recode alcstatus (0/1=0) (2=1), generate(curralc)
label values curralc vcurralc
label variable curralc "Current drinker"
generate alcfreq=.
replace alcfreq=0 if w2_a_hllfalc==1 | w2_a_hllfalc==2
replace alcfreq=0.25 if w2_a_hllfalc==3
replace alcfreq=0.5 if w2_a_hllfalc==4
replace alcfreq=1.5 if w2_a_hllfalc==5
replace alcfreq=3.5 if w2_a_hllfalc==6
replace alcfreq=5.5 if w2_a_hllfalc==7
replace alcfreq=7 if w2_a_hllfalc==8
label var alcfreq "Number drinking days per week"
generate alcqnt=.
replace alcqnt=18 if w2_a_hllfalcqnt==1
replace alcqnt=10.5 if w2_a_hllfalcqnt==2
replace alcqnt=7.5 if w2_a_hllfalcqnt==3
replace alcqnt=5.5 if w2_a_hllfalcqnt==4
replace alcqnt=3.5 if w2_a_hllfalcqnt==5
replace alcqnt=1.5 if w2_a_hllfalcqnt==6
label var alcqnt "Number of drinks per drinking occasion"
generate alcwk=alcfreq*alcqnt*12 /*Converting drinks per week to grams per week*/
replace alcwk=0 if alcfreq==0
label var alcwk "Average weekly alcohol consumption [grams/week]"
generate alcavg=alcwk/7
label var alcavg "Average alcohol consumption [g/d]"

* Smoking 
generate smokstatus=.
replace smokstatus=2 if w2_a_hllfsmk==1 
replace smokstatus=1 if w2_a_hllfsmk==2 & w2_a_hllfsmkreg==1 
replace smokstatus=0 if w2_a_hllfsmk==2 & w2_a_hllfsmkreg==2 
label values smokstatus vsmokstatus
recode smokstatus (2=1) (1=0) (0=0) (.=.), gen(currsmok)
label var smokstatus "Smoking status"
label values currsmok vcurrsmok
label var currsmok "Current smoker"
*Physical activity
tab w2_a_hllfexer
recode w2_a_hllfexer (1=0) (2=1) (3=2) (4=3) (5=4) (-9/-2=.), generate(exercisefreq)
label values exercisefreq vexercisefreq
label variable exercisefreq "Weekly frequency of exercis/leisure time physical activity"

* Deaths in household 
generate housedeaths=.
	*No death in household in past 24 months
replace housedeaths=0 if w2_h_mrt24mnth==2 
	*Death in the household more than 12 months ago
replace housedeaths=0 if w2_h_mrt24mnth==1 & [((w2_a_intrv_y-w2_h_mrtdod_y1)>1 & (w2_a_intrv_y-w2_h_mrtdod_y1)!=.) | ((w2_a_intrv_y-w2_h_mrtdod_y1)==1 & ((w2_a_intrv_m-w2_h_mrtdod_m1)>0) & (w2_a_intrv_m-w2_h_mrtdod_m1)!=.)] ///
& [((w2_a_intrv_y-w2_h_mrtdod_y2)>1 & (w2_a_intrv_y-w2_h_mrtdod_y2)!=.) | ((w2_a_intrv_y-w2_h_mrtdod_y2)==1 & ((w2_a_intrv_m-w2_h_mrtdod_m2)>0 & (w2_a_intrv_m-w2_h_mrtdod_m2)!=.)) | w2_h_mrtdod_y2==.] ///
& [((w2_a_intrv_y-w2_h_mrtdod_y3)>1 & (w2_a_intrv_y-w2_h_mrtdod_y3)!=.) | ((w2_a_intrv_y-w2_h_mrtdod_y3)==1 & ((w2_a_intrv_m-w2_h_mrtdod_m3)>0 & (w2_a_intrv_m-w2_h_mrtdod_m3)!=.)) | w2_h_mrtdod_y3==.] ///
& [((w2_a_intrv_y-w2_h_mrtdod_y4)>1 & (w2_a_intrv_y-w2_h_mrtdod_y4)!=.) | ((w2_a_intrv_y-w2_h_mrtdod_y4)==1 & ((w2_a_intrv_m-w2_h_mrtdod_m4)>0 & (w2_a_intrv_m-w2_h_mrtdod_m4)!=.)) | w2_h_mrtdod_y4==.] ///
& [((w2_a_intrv_y-w2_h_mrtdod_y5)>1 & (w2_a_intrv_y-w2_h_mrtdod_y5)!=.) | ((w2_a_intrv_y-w2_h_mrtdod_y5)==1 & ((w2_a_intrv_m-w2_h_mrtdod_m5)>0 & (w2_a_intrv_m-w2_h_mrtdod_m5)!=.)) | w2_h_mrtdod_y5==.] 
replace housedeaths=1 if w2_h_mrt24mnth==1 & [(w2_a_intrv_y-w2_h_mrtdod_y1)==0 | (w2_a_intrv_y-w2_h_mrtdod_y2)==0 | (w2_a_intrv_y-w2_h_mrtdod_y3)==0 | (w2_a_intrv_y-w2_h_mrtdod_y4)==0 | (w2_a_intrv_y-w2_h_mrtdod_y5)==0] 
	*Death in household less than 12 months ago
replace housedeaths=1 if w2_h_mrt24mnth==1 & [((w2_a_intrv_y-w2_h_mrtdod_y1)==1 & (w2_a_intrv_m-w2_h_mrtdod_m1)<=0) | ((w2_a_intrv_y-w2_h_mrtdod_y2)==1 & (w2_a_intrv_m-w2_h_mrtdod_m2)<=0) | ((w2_a_intrv_y-w2_h_mrtdod_y3)==1 & (w2_a_intrv_m-w2_h_mrtdod_m3)<=0) | ((w2_a_intrv_y-w2_h_mrtdod_y4)==1 & (w2_a_intrv_m-w2_h_mrtdod_m4)<=0) | ((w2_a_intrv_y-w2_h_mrtdod_y5)==1 & (w2_a_intrv_m-w2_h_mrtdod_m5)<=0)] 
	*Death in household a year ago, including those with missing month of death - (No observations
replace housedeaths=1 if w2_h_mrt24mnth==1 & [((w2_a_intrv_y-w2_h_mrtdod_y1)==1 & w2_h_mrtdod_m1==.) | ((w2_a_intrv_y-w2_h_mrtdod_y2)==1 & w2_h_mrtdod_m2==.) | ((w2_a_intrv_y-w2_h_mrtdod_y3)==1 & w2_h_mrtdod_m3==.) | ((w2_a_intrv_y-w2_h_mrtdod_y4)==1 & w2_h_mrtdod_m4==.) | ((w2_a_intrv_y-w2_h_mrtdod_y5)==1 & w2_h_mrtdod_m5==.)]  
	*Death in household a year ago, including those with missing month of interview - (No observations)
replace housedeaths=1 if w2_h_mrt24mnth==1 & [((w2_a_intrv_y-w2_h_mrtdod_y1)==1 & (w2_a_intrv_m==.)) | ((w2_a_intrv_y-w2_h_mrtdod_y2)==1 & (w2_a_intrv_m==.)) | ((w2_a_intrv_y-w2_h_mrtdod_y3)==1 & (w2_a_intrv_m==.)) | ((w2_a_intrv_y-w2_h_mrtdod_y4)==1 & (w2_a_intrv_m==.)) | ((w2_a_intrv_y-w2_h_mrtdod_y5)==1 & (w2_a_intrv_m==.))] 
	*If death in household in past 24 months but missing year of death, then coded as missing for household death in past 12 months
replace housedeaths=. if w2_h_mrt24mnth==1 & [(w2_h_mrtdod_y1==3333 | w2_h_mrtdod_y1==9999 | w2_h_mrtdod_y1==8888) & (w2_h_mrtdod_y2==3333 | w2_h_mrtdod_y2==9999 | w2_h_mrtdod_y2==8888) & (w2_h_mrtdod_y3==3333 | w2_h_mrtdod_y3==9999 | w2_h_mrtdod_y3==8888) & (w2_h_mrtdod_y4==3333 | w2_h_mrtdod_y4==9999 | w2_h_mrtdod_y4==8888) & (w2_h_mrtdod_y5==3333 | w2_h_mrtdod_y5==9999 | w2_h_mrtdod_y5==8888)]   
label var housedeaths "Death in the household in last year"
label values housedeaths vyesno

* Height 
rename w2_a_height_1 height1
replace height1=. if height1<0 
label var height1 "Height [cm] - reading 1"
rename w2_a_height_2 height2
replace height2=. if height2<0 
label var height2 "Height [cm] - reading 2"
rename w2_a_height_3 height3
replace height3=. if height3<0 
label var height3 "Height [cm] - reading 3"

* Weight
rename w2_a_weight_1 weight1
replace weight1=. if weight1<0 
label var weight1 "Weight [kg] - reading 1"
rename w2_a_weight_2 weight2
replace weight2=. if weight2<0 
label var weight2 "Weight [kg] - reading 2"
rename w2_a_weight_3 weight3
replace weight3=. if weight3<0 
label var weight3 "Weight [kg] - reading 3"

* Waist circumference 
rename w2_a_waist_1 waist1
replace waist1=. if waist1<0 
label var waist1 "Waist circumference [cm] - reading 1"
rename w2_a_waist_2 waist2
replace waist2=. if waist2<0 
label var waist2 "Waist circumference [cm] - reading 2"
rename w2_a_waist_3 waist3
replace waist3=. if waist3<0 
label var waist3 "Waist circumference [cm] - reading 3"

* Blood pressure 
rename w2_a_bpsys_1 sbp1
replace sbp1=. if sbp1<0 
label var sbp1 "Systolic Blood Pressure [mmHg] - reading 1"
rename w2_a_bpsys_2 sbp2
replace sbp2=. if sbp2<0 
label var sbp2 "Systolic Blood Pressure [mmHg] - reading 2"
rename w2_a_bpdia_1 dbp1
replace dbp1=. if dbp1<0 
label var dbp1 "Diastolic Blood Pressure [mmHg] - reading 1"
rename w2_a_bpdia_2 dbp2
replace dbp2=. if dbp2<0 
label var dbp2 "Diastolic Blood Pressure [mmHg]- reading 2"

* Heart rate
rename w2_a_bppls_1 rhr1
replace rhr1=. if rhr1<0 
label var rhr1 "Resting Heart Rate [bpm] - reading 1"
rename w2_a_bppls_2 rhr2
replace rhr2=. if rhr2<0 
label var rhr2 "Resting Heart Rate [bpm] - reading 2"

* Self-rated health
tab w2_a_hldes
recode w2_a_hldes (5=1) (4=2) (3=3) (1/2=4) (-9/-3=.), generate(self_health)
label var self_health "Perceived health status"
label values self_health vself_health

*Medical care in the last year
recode w2_a_hlcon (1/3=1) (4/8=0) (-9/-2=.), gen(hcare12mo)
label values hcare12mo vyesno
label variable hcare12mo "Health consultation last year"


*Medical care in the last month
recode w2_a_hlcon (1=1) (2/8=0) (-9/-2=.), gen(hcare1mo)
label values hcare1mo vyesno
label variable hcare1mo "Health consultation last month"
generate hcare1mo_type=.
replace hcare1mo_type=1 if ((w2_a_hlcontyp==1 | w2_a_hlcontyp==3) & hcare1mo==1) /*Public*/
replace hcare1mo_type=2 if ((w2_a_hlcontyp==2 | w2_a_hlcontyp==4 | w2_a_hlcontyp==5) & hcare1mo==1) /*Private*/
replace hcare1mo_type=3 if (w2_a_hlcontyp==6  & hcare1mo==1) /*Chemist/nurse*/
replace hcare1mo_type=4 if (w2_a_hlcontyp==7  & hcare1mo==1) /*Traditional*/
label variable hcare1mo_type "Health visit type, 1 month"
label values hcare1mo_type vhvisit_type
tabulate hcare1mo_type, gen(hcare1mo)
replace hcare1mo1=. if hcare1mo1==0
replace hcare1mo1=0 if hcare1mo==0
rename hcare1mo1 hcare1mo_public
label variable hcare1mo_public "Visited a public health facility for care in the last month"
label values hcare1mo_public vyesno
replace hcare1mo2=. if hcare1mo2==0
replace hcare1mo2=0 if hcare1mo==0
rename hcare1mo2 hcare1mo_private
label variable hcare1mo_private "Visited a private health facility for care in the last month"
label values hcare1mo_private vyesno
replace hcare1mo3=. if hcare1mo3==0
replace hcare1mo3=0 if hcare1mo==0
rename hcare1mo3 hcare1mo_chem_nurse
label variable hcare1mo_chem_nurse "Visited a chemist/nurse for care in the last month"
label values hcare1mo_chem_nurse vyesno
replace hcare1mo4=. if hcare1mo4==0
replace hcare1mo4=0 if hcare1mo==0
rename hcare1mo4 hcare1mo_trad
label variable hcare1mo_trad "Visited a traditional/faith healer or herbalist for care in the last month"
label values hcare1mo_trad vyesno

* Medical aid
tab w2_a_hlmedaid
generate medaid=w2_a_hlmedaid
replace medaid=. if w2_a_hlmedaid<0
replace medaid=0 if w2_a_hlmedaid==2 /*No*/
label values medaid vyesno
label variable medaid "Covered by medical insurance"

* Conditions
recode w2_a_hlbp (-9/-3=.) (2=0), gen(diag_hbp)
label values diag_hbp vyesno
label variable diag_hbp "Diagnosis: hypertension"
recode w2_a_hltb (-9/-3=.) (2=0), gen(diag_tb)
label values diag_tb vyesno
label variable diag_tb "Diagnosis: tuberculosis"
recode w2_a_hlstrk (-9/-3=.) (2=0), gen(diag_stroke)
label values diag_stroke vyesno
label variable diag_stroke "Diagnosis: stroke"
recode w2_a_hlast (-9/-3=.) (2=0), gen(diag_asth)
label values diag_asth vyesno
label variable diag_asth "Diagnosis: asthma"
recode w2_a_hlhrt (-9/-3=.) (2=0), gen(diag_heart)
label values diag_heart vyesno
label variable diag_heart "Diagnosis: heart problem"
recode w2_a_hlcan (-9/-3=.) (2=0), gen(diag_cancer)
label values diag_cancer vyesno
label variable diag_cancer "Diagnosis: cancer"
recode w2_a_hldia (-9/-3=.) (2=0), gen(diag_diab)
label values diag_diab vyesno
label variable diag_diab "Diagnosis: diabetes"

* Medication
gen bpmed=.
replace bpmed=1 if w2_a_hlbp_med==1 /*Yes*/
replace bpmed=0 if w2_a_hlbp_med==2
replace bpmed=0 if diag_hbp==0
label values bpmed vyesno
label variable bpmed "Current use of antihypertensive medication - self"
gen diabmed=.
replace diabmed=1 if w2_a_hldia_med==1 /*Yes*/
replace diabmed=0 if w2_a_hldia_med==2
replace diabmed=0 if diag_diab==0
label values diabmed vyesno
label variable diabmed "Current use of diabetes medication - self"
gen tbmed=.
replace tbmed=1 if w2_a_hltb_med==1 /*Yes*/
replace tbmed=0 if w2_a_hltb_med==2 /*No*/
replace tbmed=0 if diag_tb==0 /*No*/
label values tbmed vyesno
label variable tbmed "Current use of TB medication - self"
gen strokemed=.
replace strokemed=1 if w2_a_hlstrk_med==1 /*Yes*/
replace strokemed=0 if w2_a_hlstrk_med==2 /*No*/
replace strokemed=0 if diag_stroke==0 /*No*/
label values strokemed vyesno
label variable strokemed "Current use of stroke medication - self"
gen asthmed=.
replace asthmed=1 if w2_a_hlast_med==1 /*Yes*/
replace asthmed=0 if w2_a_hlast_med==2 /*No*/
replace asthmed=0 if diag_asth==0 /*No*/
label values asthmed vyesno
label variable asthmed "Current use of asthma medication - self"

* Administrative
rename w2_hhid hhid
rename w2_a_intrv_d intd
label var intd "Day of interview"
rename w2_a_intrv_m intm
label var intm "Month of interview"
rename w2_a_intrv_y inty
label var inty "Year of interview"
rename cluster psu
label var psu "Primary Sampling Unit"
gen stratum = w2_dc2011
label var stratum "Stratum"
rename w2_wgt aweight
label var aweight "Sampling weight - Adult Questionnaire"
gen hweight=aweight
label var hweight "Sampling weight - Household Questionnaire"

* Demographic and geographic
rename w2_best_gen sex
replace sex=. if sex<0
label var sex "Sex"
label val sex vsex
rename w2_best_age_yrs age
label var age "Age [years]"
replace age=. if age<0
rename w2_best_race race
replace race=. if race<0
recode race (1=1) (2=2) (4=3) (3=4)
label values race vrace
label var race "Population group"
sum w2_hhsizer
rename w2_hhsizer hsize
label var hsize "Household size"
recode w2_geo2001 (3=1) (4=2) (2=3)(1=4) (-9/-3=.), gen(geotype4)
label values geotype4 vgeotype4
label variable geotype4 "Geotype (4 categories)"
recode w2_geo2011 (2=1) (1=2) (3=2) (-9/-3=.), gen(geotype2)
label values geotype2 vgeotype2
label variable geotype2 "Geotype (urban/rural)"
rename w2_prov2011 prov2011
replace prov2011=. if prov2011<0
label variable prov2011 "Province (2011 boundaries)"
label val prov2011 vprov2011
rename w2_prov2001 prov2001
replace prov2001=. if prov2001<0
label variable prov2001 "Province (2001 boundaries)"
label val prov2001 vprov2001

rename w2_dc2011 dist2011
replace dist2011=. if dist2011<0
label variable dist2011 "District (2011 boundaries)"
label val dist2011 vdist2011

rename w2_dc2001 dist2001
replace dist2001=. if dist2001<0
label variable dist2001 "District (2001 boundaries)"
label val dist2001 vdist2001

******************************************************************************************************************************************************
* FINALISE                                                                                                                                           * 
******************************************************************************************************************************************************

* Delete observations with missing/null sampling weights
drop if aweight==0 | aweight>=. | hweight==0 | hweight>=. 

* Delete observations with missing data on sex and/or age 
keep if age <. & sex <. & age>=15

* Drop unused variables
drop w2_*
drop toilet_combined* water_* heat_* dwell_* wall_* roof_* cookw_* floor_* csm
drop toiletw dwellingw watersrc cookingfuelw toilet_shared heatingfuelw
drop hcare1mo_type alcwk
drop wallmaterial roofmaterial floormaterial

* Label pid
label var pid "Individual ID"

* label variables used for creating asset index, save total number of assets
local n = 1
	foreach asset of varlist w_* {
	label var `asset' "NIDS2010-11 - Asset index indicator - `n'"
	local n = `n' + 1
}

* Rename variables for coherence with other datasets
rename wall wallmaterial 
label var wallmaterial "Wall material"
rename roof roofmaterial
label var roofmaterial "Roof material"
rename floor floormaterial
label var floormaterial "Roof material"

* Add source identifier
gen source = "NIDS 2010-11"
label var source "Source"

* Rescale sampling weights to sum to the sample size
sum aweight
local wmean = r(mean)
replace aweight = aweight/`wmean'

* Save temporary
save "$TEMP/TEMP_5.dta", replace

******************************************************************************************************************************************************
* ANCHOR POINTS FOR COMPARATIVE WEALTH INDEX                                                                                                         * 
******************************************************************************************************************************************************

use "$TEMP/TEMP_3B.dta", clear

recode toiletw (1/3=1) (4=2) (5/6=3) (7=4) (10=4) (9=9999), gen(toilet)
label values toilet vtoilet
label variable toilet "Toilet facilities"

generate sharedtoilet=toilet_shared
replace sharedtoilet=0 if toilet_shared==2
label values sharedtoilet vyesno
label variable sharedtoilet "Is your household's toilet facility shared?"
tab sharedtoilet
drop toilet_shared

recode watersrc (1=1) (2=2) (3=3) (4=4) (5/6=5) (10=5) (7=6) (8/9=7) (11=7) (12/13=9999), gen(water)
label values water vwater
label variable water "Household's main source of water, recode"

recode cookingfuelw (1/2=1) (3=2) (4=3) (6=4) (5=5) (8=6) (7=9999) (9/11=9999), generate (cookingfuel)
label values cookingfuel vfuel
label variable cookingfuel "Household's main cooking fuel, recode"
tab cookingfuel

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

* Save temporary
save "$TEMP/TEMP_6A.dta", replace

use "$DATASET_2", clear

* Recoding Education
recode w2_best_edu (25=0) (0/6=1) (7=2) (8/11=3) (13/14=3) (16/17=3) (12=4) (15=4) (18/19=5) (20/23=5) (24=9999) (-9/-3=.), gen(edu1)	 
label values edu1 vedu1
label var edu1 "Education (6 categories)"
tab edu1

recode edu1 (0=0)(1=1)(2=2)(3=3)(4/5=4)(6=4), gen(edu2)
label var edu2 "Education (5 categories)"
label val edu2 vedu2

*Household education
gen primaryed=.
replace primaryed=1 if edu2==2 | edu2==3 | edu2==4
replace primaryed=0 if edu2==0 | edu2==1
label var primaryed "Completed primary school"
label values primaryed vyesno

collapse (max) primaryed_hh=primaryed (count) edunum=primaryed, by(w2_hhid)
label var primaryed_hh "A household member completed primary school"
label values primaryed_hh vyesno

* Save temporary
save "$TEMP/TEMP_6B.dta", replace

*Merging household education indicator variables to dataset*

use "$TEMP/TEMP_6A.dta", clear
merge 1:1 w2_hhid using "$TEMP/TEMP_6B.dta"
keep if _merge==3
drop _merge

replace primaryed_hh=. if primaryed_hh==0 & edunum < w2_hhsizer

gen edu_deprived=.
replace edu_deprived=1 if primaryed_hh==0
replace edu_deprived=0 if primaryed_hh==1
label var edu_deprived "No household member has completed primary school"
label values edu_deprived vyesno

tab edu_deprived
tab primaryed_hh

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

* Save temporary
rename w2_hhid hhid
keep hhid edu_deprived unimp_toilet unimp_water unimp_cooking dep1plus dep2plus dep3plus dep4plus
save "$TEMP/TEMP_6C.dta", replace

******************************************************************************************************************************************************
* SAVE & ERASE TEMPORARY FILES                                                                                                                       * 
******************************************************************************************************************************************************

use "$TEMP/TEMP_5.dta", clear
merge m:1 hhid using "$TEMP/TEMP_6C.dta"
keep if _merge == 3
drop _merge

* Delete value labels
label drop _all

* Label the dataset
label data "NIDS 2010-11 - Core Variables - $S_DATE"

save "$OUT/NIDS2010-11.dta", replace
erase "$TEMP/TEMP_1.dta"
erase "$TEMP/TEMP_1B.dta"
erase "$TEMP/TEMP_1C.dta"
erase "$TEMP/TEMP_2.dta"
erase "$TEMP/TEMP_3.dta"
erase "$TEMP/TEMP_3A.dta"
erase "$TEMP/TEMP_3B.dta"
erase "$TEMP/TEMP_3B_PCA.dta"
erase "$TEMP/TEMP_3C.dta"
erase "$TEMP/TEMP_4.dta"
erase "$TEMP/TEMP_4A.dta"
erase "$TEMP/TEMP_5.dta"
erase "$TEMP/TEMP_6A.dta"
erase "$TEMP/TEMP_6B.dta"
erase "$TEMP/TEMP_6C.dta"
	 
