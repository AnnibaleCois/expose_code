* Encoding: UTF-8.
******************************************************************************************************************************************************.
* EXPOSE - DATA HARMONISATION                                                                                                                        *.
*                                                                                                                                                    *.
* INPUT: HSE 1998-2017 datasets                                                                                                                      *.
* OUTPUT: Harmonised HSE1998-2017 datsets (Stata format, input to EXTRACT_EN_2 do file)                                                              *.
*                                                                                                                                                    *.
* Shaun Scholes (s.scholes@ucl.ac.uk)                                                                                                                *.
* Version 1.0 (17/11/2023)                                                                                                                           *.
******************************************************************************************************************************************************.

******************************************************************************************************************************************************.
* LOCATION OF FILES AND FOLDERS                                                                                                                      *.
*                                                                                                                                                    *.
* INPUT FILES:                                                                                                                                       *.
* [BASE_DIRECTORY]                                                                                                                                   *
*       └ hse98ai.sav                                                                                                                                *.
*         hse01ai.sav                                                                                                                                *.
*         hse02ai.sav                                                                                                                                *.
*         hse03ai.sav                                                                                                                                *.
*         hse05ai.sav                                                                                                                                *.
*         hse06ai.sav                                                                                                                                *.
*         hse07ai.sav                                                                                                                                *.
*         hse08ai.sav                                                                                                                                *.
*         hse09ai.sav                                                                                                                                *.
*         hse10ai.sav                                                                                                                                *.
*         hse2011ai.sav                                                                                                                              *.
*         hse2012ai.sav                                                                                                                              *.
*         hse2013ai.sav                                                                                                                              *.
*         hse2014ai.sav                                                                                                                              *.
*         hse_2015_sl_v1_protect.sav                                                                                                                 *.
*         hse2016_eul.sav                                                                                                                            *.
*         hse17i_eul_v1.sav                                                                                                                          *.                                                                                                                                            
*                                                                                                                                                    *.
* TEMP FILES: "TEMP"                                                                                                                                 *.
* OUT FILE: "OUT"                                                                                                                                    *.
*                                                                                                                                                    *.
******************************************************************************************************************************************************.

************************.
*1998.
************************.

DATASET CLOSE All.
GET FILE='BASE_DIRECTORY\hse98ai.sav'.
missing values all ().
exe.
sel if age>=16.
EXECUTE.
cro/tables = workactg by active.

rename variables (noutpat inpatnt = outpat inpat).
exe.
**Household id.
compute hid=hserial.
EXECUTE.
formats hid(F10.0).
EXECUTE.
*Time-of-interview.
compute qrtint=-99.
if any(mintb,1,2,3) qrtint=1.
if any(mintb,4,5,6) qrtint=2.
if any(mintb,7,8,9) qrtint=3.
if any(mintb,10,11,12) qrtint=4.
EXECUTE.
variable label qrtint "Quarter of Interview".
value labels qrtint 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
exe.
compute qrtnvis=-99.
if any(vismon,1,2,3) qrtnvis=1.
if any(vismon,4,5,6) qrtnvis=2.
if any(vismon,7,8,9) qrtnvis=3.
if any(vismon,10,11,12) qrtnvis=4.
EXECUTE.
variable label qrtnvis "Quarter of Nurse visit".
value labels qrtnvis 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".

*marital status.
compute mstatus_h=-2.
if marital=1 mstatus_h=1.
if marital=2 mstatus_h=2.
if marital=3 mstatus_h=3.
if marital=4 mstatus_h=4.
if marital=5 mstatus_h=5.
var label mstatus_h "marital status harmonised".
val labels mstatus_h 1 "single" 2 "married" 3 "separated" 4 "divorced" 5 "widowed" 9 "cohabitees".

*minority ethnic group.
compute origin5=-2.
if (nethnic=1) origin5=1.
if any(nethnic,2,3,4) origin5=2.
if any(nethnic,5,6,7) origin5=3.
if any(nethnic,8,9) origin5=5.
value labels origin5
1 "White" 2 "Black" 3 "Asian" 4 "Mixed" 5 "Any other".
missing values origin5 (-2).

*combined urban & suburban to achieve % comparable to later years.
compute urban_b=-2.
if any(urban,1,2) urban_b=1.
if urban=3 urban_b=0.
var label urban_b "Binary urban".
val labels urban_b 0 "Not urban" 1 "Urban".
exe.
*social class.
compute sclass_h=-2.
if sclass=1 sclass_h=1.
if sclass=2 sclass_h=2.
if sclass=3 sclass_h=3.
if sclass=4 sclass_h=4.
if sclass=5 sclass_h=5.
if sclass=6 sclass_h=6.
val labels sclass_h 1 "I" 2 "II" 3 "IIIN" 4 "IIIM" 5 "IV" 6 "V".
exe.

*smoking.
IF any(2,cigevr,smkevr) cigsta3=3.
RECODE cigreg (1=2)(2,3=3) INTO cigsta3.
IF cignow=1 cigsta3=1.
IF ANY(-9,smkevr,cignow,cigevr,cigreg) cigsta3=-9.
IF ANY(-8,smkevr,cignow,cigevr,cigreg) cigsta3=-8.
IF smkevr=-1 cigsta3=-1.
VARIABLE LABELS cigsta3 "(D) Cigarette Smoking Status: Current/Ex-Reg/Never-Reg".
VALUE LABELS cigsta3
1 "Current cigarette smoker"
2 "Ex-regular cigarette smoker"
3 "Never regular cigarette smoker".
missing values cigsta3 (-9 thru -1).
EXECUTE.

*general health.
RECODE genhelf (3=2)(1 thru 2=1)(4 thru 5=3)(ELSE=Copy) INTO genhelf2 .
VARIABLE LABELS genhelf2 "(D) Self-assessed general health - grouped" .
VALUE LABELS genhelf2
1 'Very good/good'
2 'Fair'
3 'Bad/very bad'.
exe.

*Alcohol.
**** dnoft2 (inc never drink).
compute dnoft2=dnoft.
recode dnany(2=8)(-9,-8=COPY) into dnoft2.
recode dnnow(-9,-8=COPY) into dnoft2.
variable labels dnoft2 "(D) Frequency drink alcohol in past 12 months: including non-drinkers".
value labels dnoft2
  1 "Almost every day"
  2 "Five or six days a week"
  3 "Three or four days a week"
  4 "Once or twice a week"
  5 "Once or twice a month"
  6 "Once every couple of months"
  7 "Once or twice a year"
  8 "Not at all in the last 12 months/Non-drinker".


compute d7many3=d7many.
if any(2,dnany,d7day) d7many3=0.
if dnoft2=8 d7many3=0.
variable labels d7many3 "(D) Number of days drank in last week, including none".
EXE.

**dnewutg.
recode d7unit (0 thru 2=1) (2 thru 3=2) (3 thru 4=3) (4 thru 5=4) (5 thru 6=5) (6 thru 8=6) (8 thru hi=7) (else=copy) into dnewutg.
variable label dnewutg "(D) ADJUSTED FOR WINE GLASSES - units drunk on heaviest day in last 7 (grouped)".
value labels dnewutg
 1 "Up to and including 2"
 2 "Over 2 and up to (& including) 3"
 3 "Over 3 and up to (& including) 4"
 4 "Over 4 and up to (& including) 5"
 5 "Over 5 and up to (& including) 6"
 6 "Over 6 and up to (& including) 8"
 7 "Over 8+".
exe.
missing values dnewutg (-1).

compute wdrink=-5.
DO if sex=2.
recode d7unit (6.01 thru hi=3)(3.01 thru 6=2)(0 thru 3=1) (else=copy) into wdrink.
recode d7many3 (0=0) into wdrink.
END if.
variable labels wdrink "women no of units".
value labels wdrink
-5 'Men'
0 'none'
1 'Up to and including 3 units'
2 'greater than 3 and less than or equal to 6 units'
3 'great than 6 units'.
execute.

compute mdrink=-5.
DO if sex=1.
recode d7unit (8.01 thru hi=3)(4.01 thru 8=2)(0 thru 4=1) (else=copy) into mdrink.
recode d7many3 (0=0) into mdrink.
END if.
variable labels mdrink "men no of units".
value labels mdrink
-5 'women'
0 'none'
1 'Up to and including 4 units'
2 'greater than 4 and less than or equal to 8 units'
3 'great than 8 units'.
execute.

missing values mdrink wdrink ().
COMPUTE alclimit2=-1. 
if (mdrink=0) alclimit2=0.
IF (mdrink=1) alclimit2=1. 
IF mdrink=2 alclimit2=2. 
IF mdrink=3 alclimit2=3. 
if (wdrink=0) alclimit2=0.
IF (wdrink=1) alclimit2=1. 
IF wdrink=2 alclimit2=2. 
IF wdrink=3 alclimit2=3. 
if ((wdrink=-8|wdrink=-9|wdrink=-1) and (mdrink=-1|mdrink=-9|mdrink=-8)) alclimit2=-1.
miss val alclimit2 (-9). 
VAR LAB alclimit2 "Alcohol units - limits based on units per day". 
VAL LAB alclimit2 
-1 'Not Applicable'
0 'None'
1 '<=4 units/day (men), <=3 (women)' 
2 '>4 and <= 8 (men), >3 and less than or equal to 6 (women)'
3 'greater than 8 units (men), greater than 6 units (women)'.
missing values alclimit2 (-9 thru -1).
exe.
rename variables (alclimit2=alclimit07b).
exe.

***Physical activity.
recode adsp30 (28 thru hi=28).
EXECUTE.
COMPUTE adtot30x=0.
IF range(adsp30,1,28) adtot30x=adtot30x+adsp30.
IF range(adwlk30,1,28) adtot30x=adtot30x+adwlk30.
IF range(adman30,1,28) adtot30x=adtot30x+adman30.
IF range(adhse30,1,28) adtot30x=adtot30x+adhse30.
IF workactg=2 AND ftptime=1 adtot30x=adtot30x+20.
IF workactg=2 AND ftptime <>1 adtot30x=adtot30x+12.
recode adtot30x (28 thru hi=28).
EXECUTE.
IF any(-8, adsp30, adwlk30, adman30, adhse30, workactg, ftptime) adtot30x=-8.
IF any(-9, adsp30, adwlk30, adman30, adhse30, workactg, ftptime) adtot30x=-9.
exe.
recode adtot30x (1 thru 3=1) (4 thru 11=2) (12 thru 19=3) (20 thru hi=4) (else=copy) INTO a30t06c.
value labels a30t06c
0 'None'
1 'Less than 1'
2 '1 or 2 a week'
3 '3 or 4 a week'
4 '5 or more a week'.
EXECUTE.

*Benefits.
compute benefit1=srcinc05.
compute benefit4=srcinc06.
compute benefit5=srcinc07.
compute benefit7=srcinc08.
compute benefit9=srcinc09.
exe.

*Use of services.

*talk to GP in last last month.
compute docmonth=-2.
if (ndoctalk=1) & (whendoc<0) docmonth=1.
if (ndoctalk=1) & (whendoc=1) docmonth=1.
if (ndoctalk=1) & any(whendoc,2,3,4,5,6) docmonth=0.
if (ndoctalk=2) & whendoc=1 docmonth=1.
if (ndoctalk=2) & any(whendoc,2,3,4,5,6) docmonth=0.
variable label docmonth "Talk to GP in last month".
value labels docmonth 0 "No" 1 "Yes".
*whether using (for those ever taken).
compute pill3=-2.
if (pillevr=2) pill3=1.
if (pillevr=1) & (pilluse=2) pill3=2.
if (pillevr=1) & (pilluse=1) pill3=3.
variable label pill3 "Current contraceptive use".
val labels pill3
    1 "Never taken"
    2 "Taken not current"
    3 "Current".
exe.
*Anthropometry.
compute bmival2=bmival.
compute wtval2=wtval.
EXECUTE.

*BP.
*Dinamap to Omron.
DO IF bprespc=1 & age>=16.
compute sys1om=(sys1*0.91)+8.90.
compute sys2om=(sys2*0.91)+8.90.
compute sys3om=(sys3*0.91)+8.90.
compute dias1om=(dias1*0.73)+19.78.
compute dias2om=(dias2*0.73)+19.78.
compute dias3om=(dias3*0.73)+19.78.
compute omsysval=(sysval*0.91)+8.90.
compute omdiaval=(newdiast*0.73)+19.78.
end if.
EXECUTE.
compute highbp=hyper140.
VALUE LABELS highbp 1 'Normotensive untreated' 2 'Normotensive treated' 3 'Hypertensive treated' 4 'Hypertensive untreated'.
exe.

*Taking drugs prescribed for high BP in the last 7 days (bpmedd).
*Taking drugs affecting in the last 7 days (bpmedc).
compute bpmedd_h=-2.
if (bpmedd=0)|(medcnjd=2) bpmedd_h=0.
if (bpmedd=1) bpmedd_h=1.
val labels bpmedd_h 0 "not on BP med" 1 "on BP med".
exe.
compute bpmedc_h=-2.
if (bpmedc=0)|(medcnjd=2) bpmedc_h=0.
if (bpmedc=1) bpmedc_h=1.
val labels bpmedc_h 0 "not on BP med" 1 "on BP med".
exe.
*Lipid.
compute lipid_h=-2.
if (lipid=0)|(medcnjd=2) lipid_h=0.
if (lipid=1) lipid_h=1.
val labels lipid_h 0 "not on lipid" 1 "lipid".
*Cholest includes lld.
compute raised=-2.
if range(cholest,0,4.9) raised=0.
if cholest>4.9 raised=1.
exe.
compute cholval13=cholest.
EXECUTE.
compute hdlval1a = hdlchol.
exe.
    
*switch missing values on.
missing values bprespc sys1om sys2om sys3om omsysval hyper140 highbp diabete2 cigsta3 (-9 thru -1).
compute CVD_Risk=-2.
if (cigsta3>0) & (bmival2>0) & (highbp>0) & (diabete2>0) CVD_Risk=1.
VARIABLE LABELS CVD_Risk "(D) Valid information for CVD_Risk" .


*medcnjd: includes contraceptives.
*medcnj: excludes contraceptives.
compute medtyp1_h=-2.
if (medcnj=2) medtyp1_h=0.
if (medtyp1=0) medtyp1_h=0.
if (medtyp1=1) medtyp1_h=1.
val labels medtyp1_h 0 "not on CVDmed" 1 "CVDmed".
compute year=1998.
EXECUTE.
compute id=pserial.
EXECUTE.
formats id(F10.0).
EXECUTE.
compute wt_int=1.
exe.
compute wt_nurse=1.
EXECUTE.
compute wt_blood=1.
EXECUTE.
compute psu99=area.
EXECUTE.
FORMAT psu99 (F4).
EXE.
string areastr (a4).
compute AREAstr = STRING(psu99,F4).
exe.
compute AREAstr = LTRIM(areastr).
exe.
string year1 (a4).
compute year1="1998".
exe.
STRING point1 (A8).
COMPUTE point1 = CONCAT(year1,areastr).
EXECUTE.
compute age_h=age.
exe.

*Diagnosed BP (regardless of diagnosed only if pregnant; missing not coded as no).
compute diag_hbp_h=-99.
if everbp=2|docnurbp=2 diag_hbp_h=0.
if everbp=1 & (docnurbp=1) diag_hbp_h=1.
value labels diag_hbp_h 0 "No" 1 "Yes".
fre diag_hbp_h.

*Diagnosed stroke (missing not coded as no).
compute diag_stroke_h=-99.
if everstro=2|docstro=2 diag_stroke_h=0.
if everstro=1 & (docstro=1) diag_stroke_h=1.
value labels diag_stroke_h 0 "No" 1 "Yes".
fre diag_stroke_h.

*Diagnosed angina (regardless of diagnosed only if pregnant; missing not coded as no).
compute diag_angi_h=-99.
if everangi=2|docangi=2 diag_angi_h=0.
if everangi=1 & (docangi=1) diag_angi_h=1.
value labels diag_angi_h 0 "No" 1 "Yes".
fre diag_angi_h.   

*Diagnosed MI (regardless of diagnosed only if pregnant; missing not coded as no).
compute diag_mi_h=-99.
if everhart=2|docheart=2 diag_mi_h=0.
if everhart=1 & (docheart=1) diag_mi_h=1.
value labels diag_mi_h 0 "No" 1 "Yes".
fre diag_mi_h.  

*Diagnosed diabetes (regardless of diagnosed only if pregnant; missing not coded as no).
compute diag_diab_h=-99.
if everdi=2|docinfo1=2 diag_diab_h=0.
if everdi=1 & (docinfo1=1) diag_diab_h=1.
value labels diag_diab_h 0 "No" 1 "Yes".
fre diag_diab_h. 
 
*Ischaemic heart disease.
compute diag_isch_h=-99.
if (diag_mi_h=0 & diag_angi_h=0) diag_isch_h=0.
if (diag_mi_h=1 | diag_angi_h=1) diag_isch_h=1.
value labels diag_isch_h 0 "No" 1 "Yes".
fre diag_isch_h. 
compute dimed_h = medcindi.
exe.

save outfile = "TEMP\HSE1998RF.sav"
/keep hid id year sex age age_h ag16g10 gor cigsta3 wt_int wt_nurse wt_blood point1 diabete2 topqual3 
nuroutc genhelf genhelf2
longill limitill highbp omsysval omdiaval cholval13 raised
wtval2 htval bmival2 adt30gp
mintb yintb vismon visyr
bprespc sys1om sys2om sys3om omsysval 
dias1om dias2om dias3om omdiaval
hyper140 bpmedd bpmedc bpmedd_h bpmedc_h 
CVD_Risk
origin5 sclass sclass_h hhsize tenureb car numcars
compm1 compm2 compm3 compm4 compm5 compm6 compm7 compm8 compm9 compm10
compm11 compm12 compm13 compm14 compm15
waist1 waist2 waist3 wstval 
hip1 hip2 hip3 hipval whval 
medcinbp dhano
urban urban_b airtemp 
everbp everangi everhart evermur everireg everoht everstro everdi
strodef angidef heartdef murmur1 iregdef ohtdef
docstro docangi docheart murdoc docireg docinfo1 docoht docnurbp bp1
marital mstatus_h medcnjd  ihdis cvdis
illsm1 illsm2 illsm3 illsm4 illsm5 illsm6 area 
pregnowb pregntj pillevr pilluse pill3 a30t06c hdlval1a totinc eqvinc eqv5
srcinc05 srcinc06 srcinc07 srcinc08 srcinc09 alclimit07b
benefit1 benefit4 benefit5 benefit7 benefit9 ndoctalk whendoc docmonth area lipid lipid_h
medtyp1 medtyp1_h medheart insulin  ghq12scr qrtint qrtnvis
diag_hbp_h diag_stroke_h diag_angi_h diag_mi_h diag_diab_h diag_isch_h dimed_h
outpat inpat dnnow dnany dnevr 
pulse1 pulse2 pulse3.



****************.
*2001.
****************.

DATASET CLOSE All.
GET FILE='BASE_DIRECTORY\hse01ai.sav'.
missing values all ().
exe.
sel if age>=16.
EXECUTE.
**Household id.
compute hid=hserial.
EXECUTE.
formats hid(F10.0).
EXECUTE.
compute id=pserial.
EXECUTE.
formats id(F10.0).
EXECUTE.
compute wt_int=1.
exe.
compute wt_nurse=1.
EXECUTE.
compute wt_blood=1.
EXECUTE.
compute qrtint=-99.
if any(mintb,1,2,3) qrtint=1.
if any(mintb,4,5,6) qrtint=2.
if any(mintb,7,8,9) qrtint=3.
if any(mintb,10,11,12) qrtint=4.
EXECUTE.
variable label qrtint "Quarter of Interview".
value labels qrtint 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
exe.
compute qrtnvis=-99.
if any(vismon,1,2,3) qrtnvis=1.
if any(vismon,4,5,6) qrtnvis=2.
if any(vismon,7,8,9) qrtnvis=3.
if any(vismon,10,11,12) qrtnvis=4.
EXECUTE.
variable label qrtnvis "Quarter of Nurse visit".
value labels qrtnvis 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".

*marital status.
compute mstatus_h=-2.
if marital=1 mstatus_h=1.
if marital=2 mstatus_h=2.
if marital=3 mstatus_h=3.
if marital=4 mstatus_h=4.
if marital=5 mstatus_h=5.
var label mstatus_h "marital status harmonised".
val labels mstatus_h 1 "single" 2 "married" 3 "separated" 4 "divorced" 5 "widowed" 9 "cohabitees".

*ethnic group.
compute origin5=-2.
if (ethnici=1) origin5=1.
if (ethnici=2) origin5=4.
if any(ethnici,3,4) origin5=2.
if any(ethnici,5,6) origin5=3.
if (ethnici=7) origin5=5.
value labels origin5
1 "White"
2 "Black"
3 "Asian"
4 "Mixed"
5 "Any other".
missing values origin5 (-2).
exe.

compute gor=-2.
if gora="A" gor=1.
if gora="B" gor=2.
if gora="D" gor=3.
if gora="E" gor=4.
if gora="F" gor=5.
if gora="G" gor=6.
if gora="H" gor=7.
if gora="J" gor=8.
if gora="K" gor=9.
exe.
formats gor(F8.2).
exe.
compute imd_h=nimd.
formats imd_h(F8.2).
exe.
compute urban_b=-2.
if any(urban,1,2) urban_b=1.
if urban=3 urban_b=0.
var label urban_b "Binary urban".
val labels urban_b 0 "Not urban" 1 "Urban".
*Benefits.
compute benefit1=srcinc05.
compute benefit4=srcinc06.
compute benefit5=srcinc07.
compute benefit7=srcinc08.
compute benefit9=srcinc09.
exe.
*Social class.
compute sclass_h=-2.
if sclass=1 sclass_h=1.
if sclass=2 sclass_h=2.
if sclass=3 sclass_h=3.
if sclass=4 sclass_h=4.
if sclass=5 sclass_h=5.
if sclass=6 sclass_h=6.
val labels sclass_h 1 "I" 2 "II" 3 "IIIN" 4 "IIIM" 5 "IV" 6 "V".

*Alcohol.
compute d7many3=d7many.
if any(2,dnany,d7day) d7many3=0.
if dnoft2=8 d7many3=0.
variable labels d7many3 "(D) Number of days drank in last week, including none".
EXE.
**dnewutg.
recode d7unit (0 thru 2=1) (2 thru 3=2) (3 thru 4=3) (4 thru 5=4) (5 thru 6=5) (6 thru 8=6) (8 thru hi=7) (else=copy) into dnewutg.
variable label dnewutg "(D) ADJUSTED FOR WINE GLASSES - units drunk on heaviest day in last 7 (grouped)".
value labels dnewutg
 1 "Up to and including 2"
 2 "Over 2 and up to (& including) 3"
 3 "Over 3 and up to (& including) 4"
 4 "Over 4 and up to (& including) 5"
 5 "Over 5 and up to (& including) 6"
 6 "Over 6 and up to (& including) 8"
 7 "Over 8+".
exe.
missing values dnewutg (-1).
exe.
compute wdrink=-5.
DO if sex=2.
recode d7unit (6.01 thru hi=3)(3.01 thru 6=2)(0 thru 3=1)(else=copy) into wdrink.
recode d7many3 (0=0) into wdrink.
END if.
variable labels wdrink "women no of units".
value labels wdrink
-5 'Men'
0 'none'
1 'Up to and including 3 units'
2 'greater than 3 and less than or equal to 6 units'
3 'great than 6 units'.
execute.
compute mdrink=-5.
DO if sex=1.
recode d7unit (8.01 thru hi=3)(4.01 thru 8=2)(0 thru 4=1)(else=copy) into mdrink.
recode d7many3 (0=0) into mdrink.
END if.
variable labels mdrink "men no of units".
value labels mdrink
-5 'women'
0 'none'
1 'Up to and including 4 units'
2 'greater than 4 and less than or equal to 8 units'
3 'great than 8 units'.
execute.
missing values mdrink wdrink ().
COMPUTE alclimit2=-1. 
if (mdrink=0) alclimit2=0.
IF (mdrink=1) alclimit2=1. 
IF mdrink=2 alclimit2=2. 
IF mdrink=3 alclimit2=3. 
if (wdrink=0) alclimit2=0.
IF (wdrink=1) alclimit2=1. 
IF wdrink=2 alclimit2=2. 
IF wdrink=3 alclimit2=3. 
if ((wdrink=-8|wdrink=-9|wdrink=-1) and (mdrink=-1|mdrink=-9|mdrink=-8)) alclimit2=-1.
miss val alclimit2 (-9). 
VAR LAB alclimit2 "Alcohol units - limits based on units per day". 
VAL LAB alclimit2 
-1 'Not Applicable'
0 'None'
1 '<=4 units/day (men), <=3 (women)' 
2 '>4 and <= 8 (men), >3 and less than or equal to 6 (women)'
3 'greater than 8 units (men), greater than 6 units (women)'.
missing values alclimit2 (-9 thru -1).
rename variables (alclimit2=alclimit07b).
exe.

*talk to GP in last last month.
compute docmonth=-2.
if (ndoctalk=1) & (whendoc<0) docmonth=1.
if (ndoctalk=1) & (whendoc=1) docmonth=1.
if (ndoctalk=1) & any(whendoc,2,3,4,5,6) docmonth=0.
if (ndoctalk=2) & whendoc=1 docmonth=1.
if (ndoctalk=2) & any(whendoc,2,3,4,5,6) docmonth=0.
variable label docmonth "Talk to GP in last month".
value labels docmonth 0 "No" 1 "Yes".
exe.
compute pill3=-2.
if (pillevr=2) pill3=1.
if (pillevr=1) & (pilluse=2) pill3=2.
if (pillevr=1) & (pilluse=1) pill3=3.
variable label pill3 "Current contraceptive use".
val labels pill3
    1 "Never taken"
    2 "Taken not current"
    3 "Current".
exe.
compute bmival2=bmival.
compute wtval2=wtval.
exe.

compute bpmedd_h=-2.
if (bpmedd=0)|(medcnjd=2) bpmedd_h=0.
if (bpmedd=1) bpmedd_h=1.
val labels bpmedd_h 0 "not on BP med" 1 "on BP med".
exe.

compute bpmedc_h=-2.
if (bpmedc=0)|(medcnjd=2) bpmedc_h=0.
if (bpmedc=1) bpmedc_h=1.
val labels bpmedc_h 0 "not on BP med" 1 "on BP med".
exe.

*Dinamap to Omron.
DO IF bprespc=1 & age>=16.
compute sys1om=(sys1*0.91)+8.90.
compute sys2om=(sys2*0.91)+8.90.
compute sys3om=(sys3*0.91)+8.90.
compute dias1om=(dias1*0.73)+19.78.
compute dias2om=(dias2*0.73)+19.78.
compute dias3om=(dias3*0.73)+19.78.
compute omsysval=(sysval*0.91)+8.90.
compute omdiaval=(newdiast*0.73)+19.78.
end if.
EXECUTE.
compute highbp=hyper140.
VALUE LABELS highbp 1 'Normotensive untreated' 2 'Normotensive treated' 3 'Hypertensive treated' 4 'Hypertensive untreated'.
exe.
compute lipid_h=-2.
if (lipid=0)|(medcnjd=2) lipid_h=0.
if (lipid=1) lipid_h=1.
val labels lipid_h 0 "not on lipid" 1 "lipid".
compute medtyp1_h=-2.
if (medtyp1=0) medtyp1_h=0.
if (medtyp1=1) medtyp1_h=1.
val labels medtyp1_h 0 "not on CVDmed" 1 "CVDmed".
compute psu99=area.
EXECUTE.
FORMAT psu99 (F4).
EXE.
string areastr (a4).
compute AREAstr = STRING(psu99,F4).
exe.
compute AREAstr = LTRIM(areastr).
exe.
string year1 (a4).
compute year1="2001".
exe.
STRING point1 (A8).
COMPUTE point1 = CONCAT(year1,areastr).
EXECUTE.
compute age_h=age.
exe.
compute year=2001.
save outfile = "TEMP\HSE2001RF.sav"
    /keep id year age age_h ag16g10 sex hid yintb mintb vismon gor nimd imd_h wt_int wt_nurse wt_blood point1 nuroutc hhsize marital mstatus_h origin5
    sclass sclass_h topqual3 tenureb urban_b car numcars benefit1 benefit4 benefit5 benefit7 benefit9
    cigsta3 alclimit07b genhelf longill limitill 
    illsm1 illsm2 illsm3 illsm4 illsm5 illsm6
    compm1 compm2 compm3 compm4 compm5 compm6 compm7 compm8 compm9 compm10
compm11 compm12 compm13 compm14 compm15 bmival2 wtval2 htval
waist1 waist2 waist3 wstval 
hip1 hip2 hip3 hipval whval 
sys1om sys2om sys3om
dias1om dias2om dias3om
omsysval omdiaval highbp 
bpmedd bpmedc bpmedd_h bpmedc_h ndoctalk whendoc docmonth pregntj totinc eqvinc eqv5 airtemp
pillevr pilluse pill3 area porftvg lipid lipid_h medtyp1 medtyp1_h ghq12scr qrtint qrtnvis
medcnjd dnnow dnany dnevr pulse1 pulse2 pulse3.


****************.
*2002.
****************.

dataset close all.
GET FILE='BASE_DIRECTORY\hse02ai.sav'.
missing values all ().
exe.
sel if age>=16.
EXECUTE.
sel if samptype=2.
exe.
**Household id.
compute hid=hserial.
EXECUTE.
formats hid(F10.0).
EXECUTE.
compute id=pserial.
EXECUTE.
formats id(F10.0).
exe.
compute wt_int=1.
exe.
compute wt_nurse=1.
EXECUTE.
compute wt_blood=1.
EXECUTE.
compute qrtint=-99.
if any(mintb,1,2,3) qrtint=1.
if any(mintb,4,5,6) qrtint=2.
if any(mintb,7,8,9) qrtint=3.
if any(mintb,10,11,12) qrtint=4.
EXECUTE.
variable label qrtint "Quarter of Interview".
value labels qrtint 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
exe.
compute qrtnvis=-99.
if any(vismon,1,2,3) qrtnvis=1.
if any(vismon,4,5,6) qrtnvis=2.
if any(vismon,7,8,9) qrtnvis=3.
if any(vismon,10,11,12) qrtnvis=4.
EXECUTE.
variable label qrtnvis "Quarter of Nurse visit".
value labels qrtnvis 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
exe.
rename variables (gor=gora).
exe.
compute gor=-2.
if gora="A" gor=1.
if gora="B" gor=2.
if gora="D" gor=3.
if gora="E" gor=4.
if gora="F" gor=5.
if gora="G" gor=6.
if gora="H" gor=7.
if gora="J" gor=8.
if gora="K" gor=9.
exe.
formats gor(F8.2).
exe.

*talk to GP in last last month.
compute docmonth=-2.
if (ndoctalk=1) & (whendoc<0) docmonth=1.
if (ndoctalk=1) & (whendoc=1) docmonth=1.
if (ndoctalk=1) & any(whendoc,2,3,4,5,6) docmonth=0.
if (ndoctalk=2) & whendoc=1 docmonth=1.
if (ndoctalk=2) & any(whendoc,2,3,4,5,6) docmonth=0.
variable label docmonth "Talk to GP in last month".
value labels docmonth 0 "No" 1 "Yes".
compute imd_h=nimd.
formats imd_h(F8.2).
exe.
compute urban_b=-2.
if any(urban,1,2) urban_b=1.
if urban=3 urban_b=0.
var label urban_b "Binary urban".
val labels urban_b 0 "Not urban" 1 "Urban".
exe.
compute benefit1=srcinc05.
compute benefit4=srcinc06.
compute benefit5=srcinc07.
compute benefit7=srcinc08.
compute benefit9=srcinc09.
EXECUTE.
compute mstatus_h=-2.
if marstatb=1 mstatus_h=1.
if marstatb=2 mstatus_h=2.
if marstatb=3 mstatus_h=3.
if marstatb=4 mstatus_h=4.
if marstatb=5 mstatus_h=5.
if marstatb=6 mstatus_h=9.
var label mstatus_h "marital status harmonised".
val labels mstatus_h 1 "single" 2 "married" 3 "separated" 4 "divorced" 5 "widowed" 9 "cohabitees".
*minority ethnic group.
compute origin5=-2.
if (ethnici=1) origin5=1.
if (ethnici=2) origin5=4.
if any(ethnici,3,4) origin5=2.
if any(ethnici,5,6) origin5=3.
if (ethnici=7) origin5=5.
value labels origin5
1 "White"
2 "Black"
3 "Asian"
4 "Mixed"
5 "Any other".
missing values origin5 (-2).
exe.
*social class.
compute sclass_h=-2.
if sclass=1 sclass_h=1.
if sclass=2 sclass_h=2.
if sclass=3 sclass_h=3.
if sclass=4 sclass_h=4.
if sclass=5 sclass_h=5.
if sclass=6 sclass_h=6.
val labels sclass_h 1 "I" 2 "II" 3 "IIIN" 4 "IIIM" 5 "IV" 6 "V".
*alcohol.
compute d7many3=d7many.
if any(2,dnany,d7day) d7many3=0.
if dnoft2=8 d7many3=0.
variable labels d7many3 "(D) Number of days drank in last week, including none".
EXE.
**dnewutg.
recode d7unit (0 thru 2=1) (2 thru 3=2) (3 thru 4=3) (4 thru 5=4) (5 thru 6=5) (6 thru 8=6) (8 thru hi=7) (else=copy) into dnewutg.
variable label dnewutg "(D) ADJUSTED FOR WINE GLASSES - units drunk on heaviest day in last 7 (grouped)".
value labels dnewutg
 1 "Up to and including 2"
 2 "Over 2 and up to (& including) 3"
 3 "Over 3 and up to (& including) 4"
 4 "Over 4 and up to (& including) 5"
 5 "Over 5 and up to (& including) 6"
 6 "Over 6 and up to (& including) 8"
 7 "Over 8+".
exe.
missing values dnewutg (-1).
exe.
compute wdrink=-5.
DO if sex=2.
recode d7unit (6.01 thru hi=3)(3.01 thru 6=2)(0 thru 3=1)(else=copy) into wdrink.
recode d7many3 (0=0) into wdrink.
END if.
variable labels wdrink "women no of units".
value labels wdrink
-5 'Men'
0 'none'
1 'Up to and including 3 units'
2 'greater than 3 and less than or equal to 6 units'
3 'great than 6 units'.
execute.
compute mdrink=-5.
DO if sex=1.
recode d7unit (8.01 thru hi=3)(4.01 thru 8=2)(0 thru 4=1)(else=copy) into mdrink.
recode d7many3 (0=0) into mdrink.
END if.
variable labels mdrink "men no of units".
value labels mdrink
-5 'women'
0 'none'
1 'Up to and including 4 units'
2 'greater than 4 and less than or equal to 8 units'
3 'great than 8 units'.
execute.
missing values mdrink wdrink ().
COMPUTE alclimit2=-1. 
if (mdrink=0) alclimit2=0.
IF (mdrink=1) alclimit2=1. 
IF mdrink=2 alclimit2=2. 
IF mdrink=3 alclimit2=3. 
if (wdrink=0) alclimit2=0.
IF (wdrink=1) alclimit2=1. 
IF wdrink=2 alclimit2=2. 
IF wdrink=3 alclimit2=3. 
if ((wdrink=-8|wdrink=-9|wdrink=-1) and (mdrink=-1|mdrink=-9|mdrink=-8)) alclimit2=-1.
miss val alclimit2 (-9). 
VAR LAB alclimit2 "Alcohol units - limits based on units per day". 
VAL LAB alclimit2 
-1 'Not Applicable'
0 'None'
1 '<=4 units/day (men), <=3 (women)' 
2 '>4 and <= 8 (men), >3 and less than or equal to 6 (women)'
3 'greater than 8 units (men), greater than 6 units (women)'.
missing values alclimit2 (-9 thru -1).
rename variables (alclimit2=alclimit07b).
exe.
compute pill3=-2.
if (pillevr=2) pill3=1.
if (pillevr=1) & (pilluse=2) pill3=2.
if (pillevr=1) & (pilluse=1) pill3=3.
variable label pill3 "Current contraceptive use".
val labels pill3
    1 "Never taken"
    2 "Taken not current"
    3 "Current".
exe.
compute bmival2=bmival.
compute wtval2=wtval.
EXECUTE.

compute bpmedd_h=-2.
if (bpmedd=0)|(medcnjd=2) bpmedd_h=0.
if (bpmedd=1) bpmedd_h=1.
val labels bpmedd_h 0 "not on BP med" 1 "on BP med".
exe.
compute bpmedc_h=-2.
if (bpmedc=0)|(medcnjd=2) bpmedc_h=0.
if (bpmedc=1) bpmedc_h=1.
val labels bpmedc_h 0 "not on BP med" 1 "on BP med".
exe.

*Dinamap to Omron.
DO IF bprespc=1 & age>=16.
compute sys1om=(sys1*0.91)+8.90.
compute sys2om=(sys2*0.91)+8.90.
compute sys3om=(sys3*0.91)+8.90.
compute dias1om=(dias1*0.73)+19.78.
compute dias2om=(dias2*0.73)+19.78.
compute dias3om=(dias3*0.73)+19.78.
compute omsysval=(sysval*0.91)+8.90.
compute omdiaval=(newdiast*0.73)+19.78.
end if.
EXECUTE.
compute highbp=hyper140.
VALUE LABELS highbp 1 'Normotensive untreated' 2 'Normotensive treated' 3 'Hypertensive treated' 4 'Hypertensive untreated'.
*lipid.
compute lipid_h=-2.
if (lipid=0)|(medcnjd=2) lipid_h=0.
if (lipid=1) lipid_h=1.
val labels lipid_h 0 "not on lipid" 1 "lipid".
compute medtyp1_h=-2.
if (medtyp1=0) medtyp1_h=0.
if (medtyp1=1) medtyp1_h=1.
val labels medtyp1_h 0 "not on CVDmed" 1 "CVDmed".
exe.
compute psu99=area.
EXECUTE.
FORMAT psu99 (F4).
EXE.
string areastr (a4).
compute AREAstr = STRING(psu99,F4).
exe.
compute AREAstr = LTRIM(areastr).
exe.
string year1 (a4).
compute year1="2002".
exe.
STRING point1 (A8).
COMPUTE point1 = CONCAT(year1,areastr).
EXECUTE.
compute age_h=age.
exe.
compute year=2002.
save outfile = "TEMP\HSE2002RF.sav"
    /keep id year age age_h ag16g10 sex hid yintb mintb vismon gor ndoctalk whendoc docmonth pregntj
    wt_int wt_nurse wt_blood point1 imd_h hhsize sclass sclass_h tenureb urban_b
    car numcars benefit1 benefit4 benefit5 benefit7 benefit9 mstatus_h origin5
    cigsta3 topqual3 alclimit07b genhelf longill limitill
    illsm1 illsm2 illsm3 illsm4 illsm5 illsm6
    compm1 compm2 compm3 compm4 compm5 compm6 compm7 compm8 compm9 compm10
compm11 compm12 compm13 compm14 compm15 totinc eqvinc eqv5 htval wtval2 bmival2
waist1 waist2 waist3 wstval 
hip1 hip2 hip3 hipval whval
sys1om sys2om sys3om
dias1om dias2om dias3om
omsysval omdiaval highbp 
bpmedd bpmedc bpmedd_h bpmedc_h airtemp pillevr pilluse pill3 area porftvg lipid lipid_h
medtyp1 medtyp1_h ghq12scr qrtint qrtnvis medcnjd dnnow dnany dnevr nuroutc pulse1 pulse2 pulse3.


***********.
*2003.
***********.

DATASET CLOSE All.
GET FILE='BASE_DIRECTORY\hse03ai.sav'.
missing values all ().
exe.
select if age>=16.
EXECUTE.
**Household id.
compute hid=hserial.
EXECUTE.
formats hid(F10.0).
EXECUTE.
compute id=pserial.
EXECUTE.
formats id(F10.0).
exe.
formats gor(F8.2).
exe.
compute qrtint=-99.
if any(mintb,1,2,3) qrtint=1.
if any(mintb,4,5,6) qrtint=2.
if any(mintb,7,8,9) qrtint=3.
if any(mintb,10,11,12) qrtint=4.
EXECUTE.
variable label qrtint "Quarter of Interview".
value labels qrtint 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
exe.
compute qrtnvis=-99.
if any(vismon,1,2,3) qrtnvis=1.
if any(vismon,4,5,6) qrtnvis=2.
if any(vismon,7,8,9) qrtnvis=3.
if any(vismon,10,11,12) qrtnvis=4.
EXECUTE.
variable label qrtnvis "Quarter of Nurse visit".
value labels qrtnvis 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
exe.
compute imd_h=imd2004.
formats imd_h(F8.2).
exe.
*marital status.
compute mstatus_h=-2.
if marstatb=1 mstatus_h=1.
if marstatb=2 mstatus_h=2.
if marstatb=3 mstatus_h=3.
if marstatb=4 mstatus_h=4.
if marstatb=5 mstatus_h=5.
if marstatb=6 mstatus_h=9.
var label mstatus_h "marital status harmonised".
val labels mstatus_h 1 "single" 2 "married" 3 "separated" 4 "divorced" 5 "widowed" 9 "cohabitees".
exe.

*urban.
compute urban_b=-2.
if urindew="2"  urban_b=0.
if urindew="3"  urban_b=0.
if urindew="4"  urban_b=0.
if urindew="6"  urban_b=0.
if urindew="7"  urban_b=0.
if urindew="8"  urban_b=0.
if urindew="1"  urban_b=1.
if urindew="5"  urban_b=1.
var label urban_b "Binary urban".
val labels urban_b 0 "Not urban" 1 "Urban".
exe.
compute urban3=0.
if urindew="1" urban3=1.
if urindew="2" urban3=2.
if urindew="3" urban3=3.
if urindew="4" urban3=3.
if urindew="5" urban3=1.
if urindew="6" urban3=2.
if urindew="7" urban3=3.
if urindew="8" urban3=3.
value labels urban3 
1 "Urban"
2 "Town & Fringe"
3 "Village, Hamlet and Isolated Dwelling".
formats urban3 (F8.2).
EXECUTE.
*minority ethnic group.
compute origin5=-2.
if (ethnici=1) origin5=1.
if (ethnici=2) origin5=4.
if any(ethnici,3,4) origin5=2.
if any(ethnici,5,6) origin5=3.
if (ethnici=7) origin5=5.
value labels origin5
1 "White"
2 "Black"
3 "Asian"
4 "Mixed"
5 "Any other".
missing values origin5 (-2).
exe.
*Ethnicity.
compute origin1=-2.
if ethnici=1 origin1=1.
if any(ethnici,2,3,4,5,6,7) origin1=0.
exe.
value labels origin1 0 "non-white" 1 "white".
EXECUTE.
*social class.
compute sclass_h=-2.
if sclass=1 sclass_h=1.
if sclass=2 sclass_h=2.
if sclass=3 sclass_h=3.
if sclass=4 sclass_h=4.
if sclass=5 sclass_h=5.
if sclass=6 sclass_h=6.
val labels sclass_h 1 "I" 2 "II" 3 "IIIN" 4 "IIIM" 5 "IV" 6 "V".
exe.
compute pill3=-2.
if (pillevr=2) pill3=1.
if (pillevr=1) & (pilluse=2) pill3=2.
if (pillevr=1) & (pilluse=1) pill3=3.
variable label pill3 "Current contraceptive use".
val labels pill3
    1 "Never taken"
    2 "Taken not current"
    3 "Current".
exe.
*BMI.
compute bmival2=bmival.
compute wtval2=wtval.
exe.
compute bmivg52=-2.
if range(bmival2,0,18.4999) bmivg52=0.
if range(bmival2,18.5,24.9999) bmivg52=1.
if range(bmival2,25.000,29.9999) bmivg52=2.
if range(bmival2,30,34.9999) bmivg52=3.
if range(bmival2,35,100) bmivg52=4.
EXECUTE.
value labels bmivg52 0 "Underweight" 1 "Normal-weight" 2 "Overweight" 3 "Obese I" 4 "Obese II".

*physical activity.
rename variables (adhse30b=adhse30).
rename variables (adman30b=adman30).
rename variables (adsp30=adsp30).
rename variables (adwlk30b=adwlk30).
exe.
COMPUTE adtot30x=0.
IF range(adsp30,1,28) adtot30x=adtot30x+adsp30.
IF range(adwlk30,1,28) adtot30x=adtot30x+adwlk30.
IF range(adman30,1,28) adtot30x=adtot30x+adman30.
IF range(adhse30,1,28) adtot30x=adtot30x+adhse30.
IF workactg=2 AND ftptime=1 adtot30x=adtot30x+20.
IF workactg=2 AND ftptime <>1 adtot30x=adtot30x+12.
recode adtot30x (28 thru hi=28).
EXECUTE.
IF any(-8, adsp30, adwlk30, adman30, adhse30, workactg, ftptime) adtot30x=-8.
IF any(-9, adsp30, adwlk30, adman30, adhse30, workactg, ftptime) adtot30x=-9.
exe.
recode adtot30x (1 thru 3=1) (4 thru 11=2) (12 thru 19=3) (20 thru hi=4) (else=copy) INTO a30t06c.
value labels a30t06c
0 'None'
1 'Less than 1'
2 '1 or 2 a week'
3 '3 or 4 a week'
4 '5 or more a week'.
EXECUTE.
*alcohol.
compute d7many3=d7many.
if any(2,dnany,d7day) d7many3=0.
if dnoft2=8 d7many3=0.
variable labels d7many3 "(D) Number of days drank in last week, including none".
EXE.
**dnewutg.
recode d7unit (0 thru 2=1) (2 thru 3=2) (3 thru 4=3) (4 thru 5=4) (5 thru 6=5) (6 thru 8=6) (8 thru hi=7) (else=copy) into dnewutg.
variable label dnewutg "(D) ADJUSTED FOR WINE GLASSES - units drunk on heaviest day in last 7 (grouped)".
value labels dnewutg
 1 "Up to and including 2"
 2 "Over 2 and up to (& including) 3"
 3 "Over 3 and up to (& including) 4"
 4 "Over 4 and up to (& including) 5"
 5 "Over 5 and up to (& including) 6"
 6 "Over 6 and up to (& including) 8"
 7 "Over 8+".
exe.
compute wdrink=-5.
DO if sex=2.
recode d7unit (6.01 thru hi=3)(3.01 thru 6=2)(0 thru 3=1) (else=copy) into wdrink.
recode d7many3 (0=0) into wdrink.
END if.
variable labels wdrink "women no of units".
value labels wdrink
-5 'Men'
0 'none'
1 'Up to and including 3 units'
2 'greater than 3 and less than or equal to 6 units'
3 'great than 6 units'.
execute.
compute mdrink=-5.
DO if sex=1.
recode d7unit (8.01 thru hi=3)(4.01 thru 8=2)(0 thru 4=1)(else=copy) into mdrink.
recode d7many3 (0=0) into mdrink.
END if.
variable labels mdrink "men no of units".
value labels mdrink
-5 'women'
0 'none'
1 'Up to and including 4 units'
2 'greater than 4 and less than or equal to 8 units'
3 'great than 8 units'.
execute.
missing values mdrink wdrink ().
COMPUTE alclimit2=-1. 
if (mdrink=0) alclimit2=0.
IF (mdrink=1) alclimit2=1. 
IF mdrink=2 alclimit2=2. 
IF mdrink=3 alclimit2=3. 
if (wdrink=0) alclimit2=0.
IF (wdrink=1) alclimit2=1. 
IF wdrink=2 alclimit2=2. 
IF wdrink=3 alclimit2=3. 
if ((wdrink=-8|wdrink=-9|wdrink=-1) and (mdrink=-1|mdrink=-9|mdrink=-8)) alclimit2=-1.
miss val alclimit2 (-9). 
VAR LAB alclimit2 "Alcohol units - limits based on units per day". 
VAL LAB alclimit2 
-1 'Not Applicable'
0 'None'
1 '<=4 units/day (men), <=3 (women)' 
2 '>4 and <= 8 (men), >3 and less than or equal to 6 (women)'
3 'greater than 8 units (men), greater than 6 units (women)'.
missing values alclimit2 (-9 thru -1).
rename variables (alclimit2=alclimit07b).
exe.
*Benefits.
compute benefit1=srcin06a.
compute benefit4=srcin07a.
compute benefit5=srcin08a.
compute benefit7=srcin09a.
compute benefit9=srcin10a.
exe.

*Hypertension (meds PRESCRIBED for high BP).
compute bpmedd_h=-2.
if (bpmedd=0)|(medcnjd=2) bpmedd_h=0.
if (bpmedd=1) bpmedd_h=1.
val labels bpmedd_h 0 "not on BP med" 1 "on BP med".
exe.
compute bpmedc_h=-2.
if (bpmedc=0)|(medcnjd=2) bpmedc_h=0.
if (bpmedc=1) bpmedc_h=1.
val labels bpmedc_h 0 "not on BP med" 1 "on BP med".
exe.
compute highbp=hy140om.
VALUE LABELS highbp 1 'Normotensive untreated' 
2 'Normotensive treated' 
3 'Hypertensive treated' 
4 'Hypertensive untreated'.
exe.
*cholesterol.
compute hdlval1a = hdlchol.
exe.
* Cholest includes lld.
compute raised=-2.
if range(cholest,0,4.9) raised=0.
if cholest>4.9 raised=1.
exe.
compute cholval13=cholest.
exe.
*Lipid.
compute lipid_h=-2.
if (lipid=0)|(medcnjd=2) lipid_h=0.
if (lipid=1) lipid_h=1.
val labels lipid_h 0 "not on lipid" 1 "lipid".
exe.
compute medtyp1_h=-2.
if (medtyp1=0) medtyp1_h=0.
if (medtyp1=1) medtyp1_h=1.
val labels medtyp1_h 0 "not on CVDmed" 1 "CVDmed".
exe.
*Diabetes (6.5%).
compute diabete3=-11.
If (Glyhbval>0 & Glyhbval<6.5) & (diabete2=2) diabete3=1.
If (Glyhbval>0 & diabete2=1) diabete3=2.
If (Glyhbval>6.4) & (diabete2=2) diabete3=3.
If any(-9,diabete2) diabete3=-9.
If any(-8,diabete2) diabete3=-8.
If any(-1,diabete2) diabete3=-1.
Value labels diabete3
1 "No diabetes"
2 "Doctor diagnosed diabetes"
3 "Undiagnosed diabetes HbA1c>=6.5%".
Variable label diabete3 "(D) Diabetes from blood sample (>=6.5%) or doctor diagnosis (excluding pregnancy-only diabetes)".
missing values diabete3 (-9,-8,-1).
exe.

*switch missing values on.
compute CVD_Risk=-2.
if (cigsta3>0) & (bmival2>0) & (highbp>0) & (diabete2>0) CVD_Risk=1.
VARIABLE LABELS CVD_Risk "(D) Valid information for CVD_Risk" .
exe.
rename var(nurse_wt int_wt blood_wt = wt_nurse wt_int wt_blood).
exe.
compute psu99=area.
EXECUTE.
FORMAT psu99 (F4).
EXE.
string areastr (a4).
compute AREAstr = STRING(psu99,F4).
exe.
compute AREAstr = LTRIM(areastr).
exe.
string year1 (a4).
compute year1="2003".
exe.
STRING point1 (A8).
COMPUTE point1 = CONCAT(year1,areastr).
EXECUTE.
compute age_h=age.
exe.

*Diagnosed BP (regardless of diagnosed only if pregnant; missing not coded as no).
compute diag_hbp_h=-99.
if everbp=2|docnurbp=2 diag_hbp_h=0.
if everbp=1 & (docnurbp=1) diag_hbp_h=1.
value labels diag_hbp_h 0 "No" 1 "Yes".
fre diag_hbp_h.

*Diagnosed stroke (missing not coded as no).
compute diag_stroke_h=-99.
if everstro=2|docstro=2 diag_stroke_h=0.
if everstro=1 & (docstro=1) diag_stroke_h=1.
value labels diag_stroke_h 0 "No" 1 "Yes".
fre diag_stroke_h.

*Diagnosed angina (regardless of diagnosed only if pregnant; missing not coded as no).
compute diag_angi_h=-99.
if everangi=2|docangi=2 diag_angi_h=0.
if everangi=1 & (docangi=1) diag_angi_h=1.
value labels diag_angi_h 0 "No" 1 "Yes".
fre diag_angi_h.   

*Diagnosed MI (regardless of diagnosed only if pregnant; missing not coded as no).
compute diag_mi_h=-99.
if everhart=2|docheart=2 diag_mi_h=0.
if everhart=1 & (docheart=1) diag_mi_h=1.
value labels diag_mi_h 0 "No" 1 "Yes".
fre diag_mi_h.  

*Diagnosed diabetes (regardless of diagnosed only if pregnant; missing not coded as no).
compute diag_diab_h=-99.
if everdi=2|docinfo1=2 diag_diab_h=0.
if everdi=1 & (docinfo1=1) diag_diab_h=1.
value labels diag_diab_h 0 "No" 1 "Yes".
fre diag_diab_h. 
 
*Ischaemic heart disease.
if (diag_mi_h=0 & diag_angi_h=0) diag_isch_h=0.
if (diag_mi_h=1 | diag_angi_h=1) diag_isch_h=1.
value labels diag_isch_h 0 "No" 1 "Yes".
fre diag_isch_h. 

compute glyhb_h = glyhbval.
exe.
compute dimed_h = medcindi.
exe.
compute year=2003.
save outfile = "TEMP\HSE2003RF.sav"
/keep hid id year sex age age_h ag16g10  area cluster 
ethnici hhsize marital 
tenureb car numcars 
diabete2 bp1 genhelf genhelf2 porfv limitill longill limitact
illsm1 illsm2 illsm3 illsm4 illsm5 illsm6
bp1 
wtval2 htval bmival2 
topqual3 cigsta3 genhelf genhelf2
gor  point1 wt_int wt_nurse wt_blood
highbp cholval13 raised porfv
imd2004  imd_h adt30gp
mintb vismon
bprespc sys1om sys2om sys3om omsysval 
dias1om dias2om dias3om omdiaval
hy140om  CVD_Risk
origin5 sclass sclass_h hhsize tenureb
compm1 compm2 compm3 compm4 compm5 compm6 compm7 compm8 compm9 compm10
compm11 compm12 compm13 compm14 compm15
waist1 waist2 waist3 wstval 
hip1 hip2 hip3 hipval whval
medcinbp 
urban urban_b urban3 airtemp 
everbp everangi everhart evermur everireg everoht everstro everdi
strodef angidef heartdef murmur1 iregdef ohtdef
docstro docangi docheart murdoc docireg docinfo1 docoht docnurbp bp1
marstatb mstatus_h medcnjd bpmedd ihdis cvdis
illsm1 illsm2 illsm3 illsm4 illsm5 illsm6 diabtype
pregntj 
pillevr pilluse pill3
a30t06c hdlchol  hdlval1a totinc eqvinc eqv5
srcin06a srcin07a srcin08a srcin09a srcin10a alclimit07b
benefit1 benefit4 benefit5 benefit7 benefit9 nuroutc
bpmedd bpmedc bpmedd_h bpmedc_h 
diabete3 porftvg lipid lipid_h medtyp1 medtyp1_h ghq12scr qrtint qrtnvis 
diag_hbp_h diag_stroke_h diag_angi_h diag_mi_h diag_diab_h diag_isch_h dnnow dnany dnevr glyhb_h Glyhbval
dimed_h medheart insulin puls1om puls2om puls3om. 


**************************************.
* 2005: no selection on samptype.
**************************************.

DATASET CLOSE All.
GET FILE='BASE_DIRECTORY\hse05ai.sav'.
missing values all ().
exe.
select if age>=16.
EXECUTE.
**Household id.
compute hid=hserial.
EXECUTE.
formats hid(F10.0).
EXECUTE.
compute id=pserial.
EXECUTE.
formats id(F10.0).
exe.
compute qrtint=-99.
if any(mintb,1,2,3) qrtint=1.
if any(mintb,4,5,6) qrtint=2.
if any(mintb,7,8,9) qrtint=3.
if any(mintb,10,11,12) qrtint=4.
EXECUTE.
variable label qrtint "Quarter of Interview".
value labels qrtint 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
exe.
compute qrtnvis=-99.
if any(vismon,1,2,3) qrtnvis=1.
if any(vismon,4,5,6) qrtnvis=2.
if any(vismon,7,8,9) qrtnvis=3.
if any(vismon,10,11,12) qrtnvis=4.
EXECUTE.
variable label qrtnvis "Quarter of Nurse visit".
value labels qrtnvis 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
formats gor(F8.2).
compute imd_h=imd2004.
formats imd_h(F8.2).
exe.
compute mstatus_h=-2.
if marstatb=1 mstatus_h=1.
if marstatb=2 mstatus_h=2.
if marstatb=3 mstatus_h=3.
if marstatb=4 mstatus_h=4.
if marstatb=5 mstatus_h=5.
if marstatb=6 mstatus_h=9.
var label mstatus_h "marital status harmonised".
val labels mstatus_h 1 "single" 2 "married" 3 "separated" 4 "divorced" 5 "widowed" 9 "cohabitees".
exe.

*urban.
recode urindew (1=1) (2=2) (3=3) (4=3) (5=1) (6=2) (7 thru hi =3) (-9 thru -1 = COPY) into urban3.
var lab Urban3 "(D) Rurality of dwelling unit".
value labels urban3 
1 "Urban"
2 "Town & Fringe"
3 "Village, Hamlet and Isolated Dwelling".
formats urban3 (F8.2).
exe.
recode urindew (1=1) (2=0) (3=0) (4=0) (5=1) (6=0) (7 thru hi =0) (-9 thru -1 = COPY) into urban_b.
var label urban_b "Binary urban".
val labels urban_b 0 "Not urban" 1 "Urban".
EXECUTE.
*minority ethnic group.
compute origin5=-2.
if (ethinda=1) origin5=1.
if (ethinda=2) origin5=4.
if (ethinda=3)|(othcult1=1) origin5=3.
if (ethinda=4) origin5=2.
if (ethinda=5) origin5=5.
value labels origin5
1 "White"
2 "Black"
3 "Asian"
4 "Mixed"
5 "Any other".
missing values origin5 (-2).
exe.
*Ethnicity.
compute origin1=-2.
if ethinda=1 origin1=1.
if any(ethinda,2,3,4,5) origin1=0.
exe.
value labels origin1 0 "non-white" 1 "white".
exe.
*Social class.
compute sclass_h=-2.
if sclass=1 sclass_h=1.
if sclass=2 sclass_h=2.
if sclass=3 sclass_h=3.
if sclass=4 sclass_h=4.
if sclass=5 sclass_h=5.
if sclass=6 sclass_h=6.
val labels sclass_h 1 "I" 2 "II" 3 "IIIN" 4 "IIIM" 5 "IV" 6 "V".
exe.
compute pill3=-2.
if (pillevr=2) pill3=1.
if (pillevr=1) & (pilluse=2) pill3=2.
if (pillevr=1) & (pilluse=1) pill3=3.
variable label pill3 "Current contraceptive use".
val labels pill3
    1 "Never taken"
    2 "Taken not current"
    3 "Current".
exe.
*BMI.
compute bmival2=bmival.
compute wtval2=wtval.
exe.
compute bmivg52=-2.
if range(bmival2,0,18.4999) bmivg52=0.
if range(bmival2,18.5,24.9999) bmivg52=1.
if range(bmival2,25.000,29.9999) bmivg52=2.
if range(bmival2,30,34.9999) bmivg52=3.
if range(bmival2,35,100) bmivg52=4.
EXECUTE.
value labels bmivg52 0 "Underweight" 1 "Normal-weight" 2 "Overweight" 3 "Obese I" 4 "Obese II".
*alcohol.
compute d7many3=d7many.
if any(2,dnany,d7day) d7many3=0.
if dnoft2=8 d7many3=0.
variable labels d7many3 "(D) Number of days drank in last week, including none".
EXE.
**dnewutg.
recode d7unit (0 thru 2=1) (2 thru 3=2) (3 thru 4=3) (4 thru 5=4) (5 thru 6=5) (6 thru 8=6) (8 thru hi=7) (else=copy) into dnewutg.
variable label dnewutg "(D) - units drunk on heaviest day in last 7 (grouped)".
value labels dnewutg
 1 "Up to and including 2"
 2 "Over 2 and up to (& including) 3"
 3 "Over 3 and up to (& including) 4"
 4 "Over 4 and up to (& including) 5"
 5 "Over 5 and up to (& including) 6"
 6 "Over 6 and up to (& including) 8"
 7 "Over 8+".
exe.
missing values dnewutg (-1).

compute wdrink=-5.
DO if sex=2.
recode d7unit (6.01 thru hi=3)(3.01 thru 6=2)(0 thru 3=1) (else=copy) into wdrink.
recode d7many3 (0=0) into wdrink.
END if.
variable labels wdrink "women no of units".
value labels wdrink
-5 'Men'
0 'none'
1 'Up to and including 3 units'
2 'greater than 3 and less than or equal to 6 units'
3 'great than 6 units'.
execute.


compute mdrink=-5.
DO if sex=1.
recode d7unit (8.01 thru hi=3)(4.01 thru 8=2)(0 thru 4=1) (else=copy) into mdrink.
recode d7many3 (0=0) into mdrink.
END if.
variable labels mdrink "men no of units".
value labels mdrink
-5 'women'
0 'none'
1 'Up to and including 4 units'
2 'greater than 4 and less than or equal to 8 units'
3 'great than 8 units'.
execute.

missing values mdrink wdrink ().
COMPUTE alclimit2=-1. 
if (mdrink=0) alclimit2=0.
IF (mdrink=1) alclimit2=1. 
IF mdrink=2 alclimit2=2. 
IF mdrink=3 alclimit2=3. 
if (wdrink=0) alclimit2=0.
IF (wdrink=1) alclimit2=1. 
IF wdrink=2 alclimit2=2. 
IF wdrink=3 alclimit2=3. 
if ((wdrink=-8|wdrink=-9|wdrink=-1) and (mdrink=-1|mdrink=-9|mdrink=-8)) alclimit2=-1.
miss val alclimit2 (-9). 
VAR LAB alclimit2 "Alcohol units - limits based on units per day". 
VAL LAB alclimit2 
-1 'Not Applicable'
0 'None'
1 '<=4 units/day (men), <=3 (women)' 
2 '>4 and <= 8 (men), >3 and less than or equal to 6 (women)'
3 'greater than 8 units (men), greater than 6 units (women)'.
missing values alclimit2 (-9 thru -1).
exe.
rename variables (alclimit2=alclimit07b).
exe.
*Benefits.
compute benefit1=srcin06b.
compute benefit2=srcin07b.
compute benefit4=srcin08b.
compute benefit5=srcin09b.
compute benefit6=srcin10b.
compute benefit7=srcin11b.
compute benefit9=srcin12b.
exe.
*Diagnosed CVD (among those reporting ever).
*fre docinfo1 murdoc docstro docangi docheart docireg docoht.

*Hypertension.
compute bpmedd_h=-2.
if (bpmedd=0)|(medcnjd=2) bpmedd_h=0.
if (bpmedd=1) bpmedd_h=1.
val labels bpmedd_h 0 "not on BP med" 1 "on BP med".
exe.
compute bpmedc_h=-2.
if (bpmedc=0)|(medcnjd=2) bpmedc_h=0.
if (bpmedc=1) bpmedc_h=1.
val labels bpmedc_h 0 "not on BP med" 1 "on BP med".
exe.
compute highbp=hy140om.
VALUE LABELS highbp 1 'Normotensive untreated' 
2 'Normotensive treated' 
3 'Hypertensive treated' 
4 'Hypertensive untreated'.
exe.

*cholesterol.
compute cholval13=cholest.
exe.
compute hdlval1a = hdlchol.
exe.
*Lipid.
compute lipid_h=-2.
if (lipid=0)|(medcnjd=2) lipid_h=0.
if (lipid=1) lipid_h=1.
val labels lipid_h 0 "not on lipid" 1 "lipid".
exe.
compute medtyp1_h=-2.
if (medtyp1=0) medtyp1_h=0.
if (medtyp1=1) medtyp1_h=1.
val labels medtyp1_h 0 "not on CVDmed" 1 "CVDmed".
exe.

*CVD risk.
compute CVD_Risk=-2.
if (cigsta3>0) & (bmival2>0) & (highbp>0) & (diabete2>0) CVD_Risk=1.
VARIABLE LABELS CVD_Risk "(D) Valid information for CVD_Risk" .
exe.

*talk to GP in last last month.
compute docmonth=-2.
if (ndoctalk=1) & (whendoc<0) docmonth=1.
if (ndoctalk=1) & (whendoc=1) docmonth=1.
if (ndoctalk=1) & any(whendoc,2,3,4,5,6) docmonth=0.
if (ndoctalk=2) & whendoc=1 docmonth=1.
if (ndoctalk=2) & any(whendoc,2,3,4,5,6) docmonth=0.
variable label docmonth "Talk to GP in last month".
value labels docmonth 0 "No" 1 "Yes".
exe.
compute psu99=area.
EXECUTE.
FORMAT psu99 (F4).
EXE.
string areastr (a4).
compute AREAstr = STRING(psu99,F4).
exe.
compute AREAstr = LTRIM(areastr).
exe.
string year1 (a4).
compute year1="2005".
exe.
STRING point1 (A8).
COMPUTE point1 = CONCAT(year1,areastr).
EXECUTE.
*no blood wt.
compute wt_blood = wt_nurse.
exe.
compute age_h=age.
exe.
compute glyhb_h = glyhbval.
exe.
compute dimed_h = medcindi.
exe.
compute year=2005.
save outfile = "TEMP\HSE2005RF.sav"
/keep hid id year sex age age_h ag16g10 
ethinda hhsize marital
tenureb car numcars imd2004 imd_h
diabete2 bp1 genhelf genhelf2 porfv limitill longill limitact
illsm1 illsm2 illsm3 illsm4 illsm5 illsm6
bp1 
wtval2 htval bmival2 
topqual3 cigsta3 genhelf2
gor point1 wt_int wt_nurse wt_blood
highbp omsysval omdiaval porfv
mintb vismon
bprespc sys1om sys2om sys3om omsysval 
dias1om dias2om dias3om 
hy140om  CVD_Risk
origin5 sclass sclass_h hhsize
compm1 compm2 compm3 compm4 compm5 compm6 compm7 compm8 compm9 compm10
compm11 compm12 compm13 compm14 compm15 cholval13
waist1 waist2 waist3 wstval 
hip1 hip2 hip3 hipval whval cluster urban3 urban_b airtemp
marstatb mstatus_h medcnjd  ihdis cvdis
everbp everstro everangi everhart evermur everireg everoht everdi
strodef angidef heartdef murmur1 iregdef ohtdef diabtype docnurbp
area cluster 
pregntj pillevr pilluse pill3  
hdlchol hdlval1a totinc eqvinc eqv5
srcin06b srcin07b srcin08b srcin09b srcin10b srcin11b srcin12b alclimit07b
benefit1 benefit2 benefit4 benefit5 benefit6 benefit7 benefit9 nuroutc
bpmedd bpmedc bpmedd_h bpmedc_h porftvg lipid lipid_h medtyp1 medtyp1_h medheart insulin medcindi ghq12scr qrtint qrtnvis dimed_h
outpat inpat
docinfo1 murdoc docstro docangi docheart docireg docoht medcinbp
ndoctalk whendoc docmonth dnnow dnany dnevr glyhbval glyhb_h samptype
wt_intEL
wt_nurEL
wt_bldEL
wt_int puls1om puls2om puls3om.

****************************.
*2006.
*65+:CVD module (s1).
*65+:PA module (s2).
****************************.

DATASET CLOSE All.
GET FILE='BASE_DIRECTORY\hse06ai.sav'.
missing values all ().
exe.
select if age>=16.
EXECUTE.
**Household id.
compute hid=hserial.
EXECUTE.
formats hid(F10.0).
EXECUTE.
rename var (gor06 = gor).
EXECUTE.
compute id=pserial.
EXECUTE.
formats id(F10.0).
exe.
compute qrtint=-99.
if any(mintb,1,2,3) qrtint=1.
if any(mintb,4,5,6) qrtint=2.
if any(mintb,7,8,9) qrtint=3.
if any(mintb,10,11,12) qrtint=4.
EXECUTE.
variable label qrtint "Quarter of Interview".
value labels qrtint 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
exe.
compute qrtnvis=-99.
if any(vismon,1,2,3) qrtnvis=1.
if any(vismon,4,5,6) qrtnvis=2.
if any(vismon,7,8,9) qrtnvis=3.
if any(vismon,10,11,12) qrtnvis=4.
EXECUTE.
variable label qrtnvis "Quarter of Nurse visit".
value labels qrtnvis 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
exe.
formats gor(F8.2).
exe.
compute imd_h=imd2004.
formats imd_h(F8.2).
EXECUTE.
compute mstatus_h=-2.
if marstatc=1 mstatus_h=1.
if marstatc=2 mstatus_h=2.
if marstatc=3 mstatus_h=2.
if marstatc=4 mstatus_h=3.
if marstatc=5 mstatus_h=4.
if marstatc=6 mstatus_h=5.
if marstatc=7 mstatus_h=9.
var label mstatus_h "marital status harmonised".
val labels mstatus_h 1 "single" 2 "married" 3 "separated" 4 "divorced" 5 "widowed" 9 "cohabitees".
*minority ethnic group.
compute origin5=-2.
if (ethinda=1) origin5=1.
if (ethinda=2) origin5=4.
if (ethinda=3)|(othcult1=1) origin5=3.
if (ethinda=4) origin5=2.
if (ethinda=5) origin5=5.
value labels origin5
1 "White"
2 "Black"
3 "Asian"
4 "Mixed"
5 "Any other".
missing values origin5 (-2).
*Ethnicity.
compute origin1=-2.
if ethinda=1 origin1=1.
if any(ethinda,2,3,4,5) origin1=0.
exe.
value labels origin1 0 "non-white" 1 "white".
exe.
*Urban.
recode urindew (1=1) (2=2) (3=3) (4=3) (5=1) (6=2) (7 thru hi =3) (-9 thru -1 = COPY) into urban3.
var lab Urban3 "(D) Rurality of dwelling unit".
value labels urban3 
1 "Urban"
2 "Town & Fringe"
3 "Village, Hamlet and Isolated Dwelling".
formats urban3 (F8.2).

*Urban.
recode urindew (1=1) (2=0) (3=0) (4=0) (5=1) (6=0) (7 thru hi =0) (-9 thru -1 = COPY) into urban_b.
var label urban_b "Binary urban".
val labels urban_b 0 "Not urban" 1 "Urban".
exe.
*Social class.
compute sclass_h=-2.
if sclass=1 sclass_h=1.
if sclass=2 sclass_h=2.
if sclass=3 sclass_h=3.
if sclass=4 sclass_h=4.
if sclass=5 sclass_h=5.
if sclass=6 sclass_h=6.
val labels sclass_h 1 "I" 2 "II" 3 "IIIN" 4 "IIIM" 5 "IV" 6 "V".
exe.
*BMI.
compute bmival2=bmival.
compute wtval2=wtval.
exe.
compute bmivg52=-2.
if range(bmival2,0,18.4999) bmivg52=0.
if range(bmival2,18.5,24.9999) bmivg52=1.
if range(bmival2,25.000,29.9999) bmivg52=2.
if range(bmival2,30,34.9999) bmivg52=3.
if range(bmival2,35,100) bmivg52=4.
EXECUTE.
value labels bmivg52 0 "Underweight" 1 "Normal-weight" 2 "Overweight" 3 "Obese I" 4 "Obese II".

*Alcohol.
compute d7many3=d7many.
if any(2,dnany,d7day) d7many3=0.
if dnoft2=8 d7many3=0.
variable labels d7many3 "(D) Number of days drank in last week, including none".
**dnewutg.
recode d7unit (0 thru 2=1) (2 thru 3=2) (3 thru 4=3) (4 thru 5=4) (5 thru 6=5) (6 thru 8=6) (8 thru hi=7) (else=copy) into dnewutg.
variable label dnewutg "(D) - units drunk on heaviest day in last 7 (grouped)".
value labels dnewutg
 1 "Up to and including 2"
 2 "Over 2 and up to (& including) 3"
 3 "Over 3 and up to (& including) 4"
 4 "Over 4 and up to (& including) 5"
 5 "Over 5 and up to (& including) 6"
 6 "Over 6 and up to (& including) 8"
 7 "Over 8+".
exe.
missing values dnewutg (-1).
EXE.
RECODE dnewutg (1 thru hi=COPY) INTO dnewutga.
RECODE d7many3(0=0) INTO dnewutga.
VARIABLE LABEL dnewutga "".
VALUE LABELS dnewutga
 0 "None" 
 1 "Up to and including 2"
 2 "Over 2 and up to (& including) 3"
 3 "Over 3 and up to (& including) 4"
 4 "Over 4 and up to (& including) 5"
 5 "Over 5 and up to (& including) 6"
 6 "Over 6 and up to (& including) 8"
 7 "Over 8+".
exe.
compute drink=0.
if dnewutga=0 & sex=1 drink=0.
if range(dnewutga,1,3) & sex=1 drink=1.
if range(dnewutga,4,6) & sex=1 drink=2.
if dnewutga=7 & sex=1 drink=3.
if dnewutga=0 & sex=2 drink=0.
if range(dnewutga,1,2) & sex=2 drink=1.
if range(dnewutga,3,5) & sex=2 drink=2.
if range(dnewutga,6,7) & sex=2 drink=3.
exe.
val labels drink
0 "None"
1 "Up to and including 3/4"
2 "More than 3/4, up to and including 6/8"
3 "More than 6/8".
exe.
rename var (drink=alclimit2).
exe.
rename variables (alclimit2=alclimit07b).
exe.
*Benefits.
compute benefit1=srcin06b.
compute benefit2=srcin07b.
compute benefit4=srcin08b.
compute benefit5=srcin09b.
compute benefit6=srcin10b.
compute benefit7=srcin11b.
compute benefit9=srcin12b.
exe.
compute pill3=-2.
if (pillevr=2) pill3=1.
if (pillevr=1) & (pilluse=2) pill3=2.
if (pillevr=1) & (pilluse=1) pill3=3.
variable label pill3 "Current contraceptive use".
val labels pill3
    1 "Never taken"
    2 "Taken not current"
    3 "Current".
exe.

*CVD.
*temp.
*sel if age>=65 & samptype=2.
*fre everbp everangi everhart evermur everireg everoht everstro everdi.

*Hypertension.
compute bpmedd_h=-2.
if (bpmedd=0)|(medcnjd=2) bpmedd_h=0.
if (bpmedd=1) bpmedd_h=1.
val labels bpmedd_h 0 "not on BP med" 1 "on BP med".
exe.

compute bpmedc_h=-2.
if (bpmedc=0)|(medcnjd=2) bpmedc_h=0.
if (bpmedc=1) bpmedc_h=1.
val labels bpmedc_h 0 "not on BP med" 1 "on BP med".
exe.

compute highbp=hy140om.
VALUE LABELS highbp 1 'Normotensive untreated' 
2 'Normotensive treated' 
3 'Hypertensive treated' 
4 'Hypertensive untreated'.
exe.

*cholesterol.
compute hdlval1a = hdlchol.
exe.
*Cholest includes lld.
compute raised=-2.
if range(cholest,0,4.9) raised=0.
if cholest>4.9 raised=1.
exe.
compute cholval13=cholest.
EXECUTE.
*Lipid.
compute lipid_h=-2.
if (lipid=0)|(medcnjd=2) lipid_h=0.
if (lipid=1) lipid_h=1.
val labels lipid_h 0 "not on lipid" 1 "lipid".
exe.
compute medtyp1_h=-2.
if (medtyp1=0) medtyp1_h=0.
if (medtyp1=1) medtyp1_h=1.
val labels medtyp1_h 0 "not on CVDmed" 1 "CVDmed".
exe.

*Diabetes.
compute diabete3=-11.
If (Glyhbval>0 & Glyhbval<6.5) & (diabete2=2) diabete3=1.
If (Glyhbval>0 & diabete2=1) diabete3=2.
If (Glyhbval>6.4) & (diabete2=2) diabete3=3.
If any(-9,diabete2) diabete3=-9.
If any(-8,diabete2) diabete3=-8.
If any(-1,diabete2) diabete3=-1.
Value labels diabete3
1 "No diabetes"
2 "Doctor diagnosed diabetes"
3 "Undiagnosed diabetes HbA1c>=6.5%".
Variable label diabete3 "(D) Diabetes from blood sample (>=6.5%) or doctor diagnosis (excluding pregnancy-only diabetes)".
missing values diabete3 (-9,-8,-1).
exe.
*CVD risk.
compute CVD_Risk=-2.
if (cigsta3>0) & (bmival2>0) & (highbp>0) & (diabete2>0) CVD_Risk=1.
VARIABLE LABELS CVD_Risk "(D) Valid information for CVD_Risk" .
exe.

compute psu99=psu.
EXECUTE.
FORMAT psu99 (F4).
EXE.
string areastr (a4).
compute AREAstr = STRING(psu99,F4).
exe.
compute AREAstr = LTRIM(areastr).
exe.
string year1 (a4).
compute year1="2006".
exe.
STRING point1 (A8).
COMPUTE point1 = CONCAT(year1,areastr).
EXECUTE.
compute age_h=age.
exe.

*Diagnosed BP (regardless of diagnosed only if pregnant; missing not coded as no).
compute diag_hbp_h=-99.
if everbp=2|docnurbp=2 diag_hbp_h=0.
if everbp=1 & (docnurbp=1) diag_hbp_h=1.
value labels diag_hbp_h 0 "No" 1 "Yes".
fre diag_hbp_h.

*Diagnosed stroke (missing not coded as no).
compute diag_stroke_h=-99.
if everstro=2|docstro=2 diag_stroke_h=0.
if everstro=1 & (docstro=1) diag_stroke_h=1.
value labels diag_stroke_h 0 "No" 1 "Yes".
fre diag_stroke_h.

*Diagnosed angina (regardless of diagnosed only if pregnant; missing not coded as no).
compute diag_angi_h=-99.
if everangi=2|docangi=2 diag_angi_h=0.
if everangi=1 & (docangi=1) diag_angi_h=1.
value labels diag_angi_h 0 "No" 1 "Yes".
fre diag_angi_h.   

*Diagnosed MI (regardless of diagnosed only if pregnant; missing not coded as no).
compute diag_mi_h=-99.
if everhart=2|docheart=2 diag_mi_h=0.
if everhart=1 & (docheart=1) diag_mi_h=1.
value labels diag_mi_h 0 "No" 1 "Yes".
fre diag_mi_h.  

*Diagnosed diabetes (regardless of diagnosed only if pregnant; missing not coded as no).
compute diag_diab_h=-99.
if everdi=2|docinfo1=2 diag_diab_h=0.
if everdi=1 & (docinfo1=1) diag_diab_h=1.
value labels diag_diab_h 0 "No" 1 "Yes".
fre diag_diab_h. 
 
*Ischaemic heart disease.
compute diag_isch_h=-99.
if (diag_mi_h=0 & diag_angi_h=0) diag_isch_h=0.
if (diag_mi_h=1 | diag_angi_h=1) diag_isch_h=1.
value labels diag_isch_h 0 "No" 1 "Yes".
fre diag_isch_h. 

compute glyhb_h = glyhbval.
exe.
compute dimed_h = medcindi.
exe.
compute year=2006.
save outfile = "TEMP\HSE2006RF.sav"
/keep hid id psu cluster  year sex age age_h ag16g10 
ethinda hhsize maritalb
tenureb car numcars imd2004 imd_h
diabete2 bp1 genhelf genhelf2 porfv limitill longill limitact
illsm1 illsm2 illsm3 illsm4 illsm5 illsm6
bp1 
wtval2 htval bmival2 
topqual3 cigsta3 genhelf2
gor point1 
samptype
wt_int wt_int_s1 wt_int_s2 
wt_nurse wt_nurse_s1  wt_nurse_s2 
wt_blood wt_blood_s1 wt_blood_s2
omsysval omdiaval highbp cholval13 raised porfv a30t06c
mintb vismon
bprespc sys1om sys2om sys3om 
dias1om dias2om dias3om omsysval hy140om  CVD_Risk
origin5 sclass sclass_h hhsize
compm1 compm2 compm3 compm4 compm5 compm6 compm7 compm8 compm9 compm10
compm11 compm12 compm13 compm14 compm15
waist1 waist2 waist3 wstval 
hip1 hip2 hip3 hipval whval medcinbp 
urban3 urban_b airtemp
marstatc mstatus_h medcnjd bpmedd ihdis cvdis
everbp everstro everangi everhart evermur everireg everoht everdi
strodef angidef heartdef murmur1 iregdef ohtdef
docstro docangi docheart murdoc docireg docinfo1 docoht diabtype docnurbp 
pregntj pillevr pilluse pill3 
a30t06c hdlchol hdlval1a totinc eqvinc eqv5
srcin06b srcin07b srcin08b srcin09b srcin10b srcin11b srcin12b alclimit07b
benefit1 benefit2 benefit4 benefit5 benefit6 benefit7 benefit9 nuroutc
bpmedd bpmedc bpmedd_h bpmedc_h 
 diabete3 porftvg lipid lipid_h medtyp1 medtyp1_h medheart insulin dimed_h ghq12scr qrtint qrtnvis
diag_hbp_h diag_stroke_h diag_angi_h diag_mi_h diag_diab_h diag_isch_h dnnow dnany dnevr glyhbval glyhb_h puls1om puls2om.


********
* 2007.
********

DATASET CLOSE All.
GET FILE='BASE_DIRECTORY\hse07ai.sav'.
missing values all ().
exe.
select if age>=16.
EXECUTE.
**Household id.
compute hid=hserial.
EXECUTE.
formats hid(F10.0).
EXECUTE.
compute id=pserial.
EXECUTE.
formats id(F10.0).
exe.
compute qrtint=-99.
if any(mintb,1,2,3) qrtint=1.
if any(mintb,4,5,6) qrtint=2.
if any(mintb,7,8,9) qrtint=3.
if any(mintb,10,11,12) qrtint=4.
EXECUTE.
variable label qrtint "Quarter of Interview".
value labels qrtint 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
exe.
compute qrtnvis=-99.
if any(vismon,1,2,3) qrtnvis=1.
if any(vismon,4,5,6) qrtnvis=2.
if any(vismon,7,8,9) qrtnvis=3.
if any(vismon,10,11,12) qrtnvis=4.
EXECUTE.
variable label qrtnvis "Quarter of Nurse visit".
value labels qrtnvis 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
exe.
rename var (gor07 hhsizeD = gor hhsize).
EXECUTE.
formats gor(F8.2).
EXECUTE.
compute imd_h=imd2007.
formats imd_h(F8.2).
exe.

*mstatus.
compute mstatus_h=-2.
if marstatc=1 mstatus_h=1.
if marstatc=2 mstatus_h=2.
if marstatc=3 mstatus_h=2.
if marstatc=4 mstatus_h=3.
if marstatc=5 mstatus_h=4.
if marstatc=6 mstatus_h=5.
if marstatc=7 mstatus_h=9.
var label mstatus_h "marital status harmonised".
val labels mstatus_h 1 "single" 2 "married" 3 "separated" 4 "divorced" 5 "widowed" 9 "cohabitees".
exe.

*urban.
recode urindew (1=1) (2=2) (3=3) (4=3) (5=1) (6=2) (7 thru hi =3) (-9 thru -1 = COPY) into urban3.
var lab Urban3 "(D) Rurality of dwelling unit".
value labels urban3 
1 "Urban"
2 "Town & Fringe"
3 "Village, Hamlet and Isolated Dwelling".
formats urban3 (F8.2).
exe.
recode urindew (1=1) (2=0) (3=0) (4=0) (5=1) (6=0) (7 thru hi =0) (-9 thru -1 = COPY) into urban_b.
var label urban_b "Binary urban".
val labels urban_b 0 "Not urban" 1 "Urban".
exe.
compute origin5=-2.
if (ethinda=1) origin5=1.
if (ethinda=2) origin5=4.
if (ethinda=3)|(othcult1=1) origin5=3.
if (ethinda=4) origin5=2.
if (ethinda=5) origin5=5.
value labels origin5
1 "White"
2 "Black"
3 "Asian"
4 "Mixed"
5 "Any other".
missing values origin5 (-2).

*Ethnicity.
compute origin1=-2.
if ethinda=1 origin1=1.
if any(ethinda,2,3,4,5) origin1=0.
exe.
value labels origin1 0 "non-white" 1 "white".
exe.
*Social class.
compute sclass_h=-2.
if sclass=1 sclass_h=1.
if sclass=2 sclass_h=2.
if sclass=3 sclass_h=3.
if sclass=4 sclass_h=4.
if sclass=5 sclass_h=5.
if sclass=6 sclass_h=6.
val labels sclass_h 1 "I" 2 "II" 3 "IIIN" 4 "IIIM" 5 "IV" 6 "V".
*BMI.
compute bmival2=bmival.
compute wtval2=wtval.
exe.
compute bmivg52=-2.
if range(bmival2,0,18.4999) bmivg52=0.
if range(bmival2,18.5,24.9999) bmivg52=1.
if range(bmival2,25.000,29.9999) bmivg52=2.
if range(bmival2,30,34.9999) bmivg52=3.
if range(bmival2,35,100) bmivg52=4.
EXECUTE.
value labels bmivg52 0 "Underweight" 1 "Normal-weight" 2 "Overweight" 3 "Obese I" 4 "Obese II".
*Benefits.
compute benefit1=srcin06b.
compute benefit2=srcin07b.
compute benefit4=srcin08b.
compute benefit5=srcin09b.
compute benefit6=srcin10b.
compute benefit7=srcin11b.
compute benefit9=srcin12b.
exe.


*Hypertension.
compute bpmedd_h=-2.
if (bpmedd=0)|(medcnjd=2) bpmedd_h=0.
if (bpmedd=1) bpmedd_h=1.
val labels bpmedd_h 0 "not on BP med" 1 "on BP med".
exe.

compute bpmedc_h=-2.
if (bpmedc=0)|(medcnjd=2) bpmedc_h=0.
if (bpmedc=1) bpmedc_h=1.
val labels bpmedc_h 0 "not on BP med" 1 "on BP med".
exe.

**Hypertension (PRESCRIBED for high BP).
compute highbp=hy140om.
VALUE LABELS highbp 1 'Normotensive untreated' 
2 'Normotensive treated' 
3 'Hypertensive treated' 
4 'Hypertensive untreated'.
exe.

*Lipid.
compute lipid_h=-2.
if (lipid=0)|(medcnjd=2) lipid_h=0.
if (lipid=1) lipid_h=1.
val labels lipid_h 0 "not on lipid" 1 "lipid".
exe.
compute medtyp1_h=-2.
if (medtyp1=0) medtyp1_h=0.
if (medtyp1=1) medtyp1_h=1.
val labels medtyp1_h 0 "not on CVDmed" 1 "CVDmed".
exe.
compute psu99=area.
EXECUTE.
FORMAT psu99 (F4).
EXE.
string areastr (a4).
compute AREAstr = STRING(psu99,F4).
exe.
compute AREAstr = LTRIM(areastr).
exe.
string year1 (a4).
compute year1="2007".
exe.
STRING point1 (A8).
COMPUTE point1 = CONCAT(year1,areastr).
EXECUTE.
compute age_h=age.
exe.
compute year=2007.
save outfile = "TEMP\HSE2007RF.sav"
/keep hid id year sex age age_h ag16g10 
ethinda marstat
tenureb car numcars 
genhelf genhelf2 porfv limitill longill limitact
illsm1 illsm2 illsm3 illsm4 illsm5 illsm6
wtval2 htval bmival2 
topqual3 cigsta3 genhelf2
gor imd2007 imd_h point1 wt_int wt_nurse
omsysval omdiaval highbp porfv
mintb vismon
bprespc sys1om sys2om sys3om omsysval 
dias1om dias2om dias3om
hy140om 
origin5 sclass sclass_h hhsize
compm1 compm2 compm3 compm4 compm5 compm6 compm7 compm8 compm9 compm10
compm11 compm12 compm13 compm14 compm15
waist1 waist2 waist3 wstval 
hip1 hip2 hip3 hipval whval 
urban3 urban_b airtemp
marstatc mstatus_h medcnjd bpmedd area cluster pregntj totinc eqvinc eqv5
srcin06b srcin07b srcin08b srcin09b srcin10b srcin11b srcin12b alclimit07b
benefit1 benefit2 benefit4 benefit5 benefit6 benefit7 benefit9 nuroutc
bpmedd bpmedc bpmedd_h bpmedc_h porftvg lipid lipid_h medtyp1 medtyp1_h qrtint qrtnvis dnnow dnany dnevr puls1om puls2om puls3om .


********
* 2008.
********

DATASET CLOSE All.
GET FILE='BASE_DIRECTORY\hse08ai.sav'.
missing values all ().
exe.
**Household id.
compute hid=hserial.
EXECUTE.
formats hid(F10.0).
EXECUTE.
compute id=pserial.
EXECUTE.
formats id(F10.0).
EXECUTE.
compute qrtint=-99.
if any(mintb,1,2,3) qrtint=1.
if any(mintb,4,5,6) qrtint=2.
if any(mintb,7,8,9) qrtint=3.
if any(mintb,10,11,12) qrtint=4.
EXECUTE.
variable label qrtint "Quarter of Interview".
value labels qrtint 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
exe.
compute qrtnvis=-99.
if any(vismon,1,2,3) qrtnvis=1.
if any(vismon,4,5,6) qrtnvis=2.
if any(vismon,7,8,9) qrtnvis=3.
if any(vismon,10,11,12) qrtnvis=4.
EXECUTE.
variable label qrtnvis "Quarter of Nurse visit".
value labels qrtnvis 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
exe.
formats gor(F8.2).
EXECUTE.
compute imd_h=qimd.
formats imd_h(F8.2).
exe.
select if age>=16.
EXECUTE.
*marital status.
compute mstatus_h=-2.
if marstatc=1 mstatus_h=1.
if marstatc=2 mstatus_h=2.
if marstatc=3 mstatus_h=2.
if marstatc=4 mstatus_h=3.
if marstatc=5 mstatus_h=4.
if marstatc=6 mstatus_h=5.
if marstatc=7 mstatus_h=9.
var label mstatus_h "marital status harmonised".
val labels mstatus_h 1 "single" 2 "married" 3 "separated" 4 "divorced" 5 "widowed" 9 "cohabitees".
*Binary Urban.
compute urban_b=-2.
if urban=1 urban_b=1.
if any(urban,2,3) urban_b=0.
var label urban_b "Binary urban".
val labels urban_b 0 "Not urban" 1 "Urban".
exe.
compute urban3=urban.
value labels urban3 
1 "Urban"
2 "Town & Fringe"
3 "Village, Hamlet and Isolated Dwelling".
exe.
*Ethnicity.
compute origin5=-2.
if (origin=1)|(origin=2)|(origin=3) origin5=1.
if (origin=12)|(origin=13)|(origin=14) origin5=2.
if (origin=8)|(origin=9)|(origin=10)|(origin=11)|(origin=15) origin5=3.
if (origin=4)|(origin=5)|(origin=6)|(origin=7) origin5=4.
if (origin=16) origin5=5.
value labels origin5
1 "White"
2 "Black"
3 "Asian"
4 "Mixed"
5 "Any other".
missing values origin5 (-2).
*Ethnicity.
compute origin1=-2.
if ANy(origin,1,2,3) origin1=1.
if any(origin,4,5,6,7,8,9,10,11,12,13,14,15,16) origin1=0.
exe.
value labels origin1 0 "non-white" 1 "white".
exe.
*Social class.
compute sclass_h=-2.
if sclass=1 sclass_h=1.
if sclass=2 sclass_h=2.
if sclass=3 sclass_h=3.
if sclass=4 sclass_h=4.
if sclass=5 sclass_h=5.
if sclass=6 sclass_h=6.
val labels sclass_h 1 "I" 2 "II" 3 "IIIN" 4 "IIIM" 5 "IV" 6 "V".
*BMI.
compute bmival2=bmival.
compute wtval2=wtval.
exe.
compute bmivg52=-2.
if range(bmival2,0,18.4999) bmivg52=0.
if range(bmival2,18.5,24.9999) bmivg52=1.
if range(bmival2,25.000,29.9999) bmivg52=2.
if range(bmival2,30,34.9999) bmivg52=3.
if range(bmival2,35,100) bmivg52=4.
EXECUTE.
value labels bmivg52 0 "Underweight" 1 "Normal-weight" 2 "Overweight" 3 "Obese I" 4 "Obese II".
*Benefits.
compute benefit1=srcin06b.
compute benefit2=srcin07b.
compute benefit4=srcin08b.
compute benefit5=srcin09b.
compute benefit6=srcin10b.
compute benefit7=srcin11b.
compute benefit9=srcin12b.
exe.
*Hypertension.
compute bpmedd_h=-2.
if (bpmedd=0)|(medcnjd=2) bpmedd_h=0.
if (bpmedd=1) bpmedd_h=1.
val labels bpmedd_h 0 "not on BP med" 1 "on BP med".
exe.
compute bpmedc_h=-2.
if (bpmedc=0)|(medcnjd=2) bpmedc_h=0.
if (bpmedc=1) bpmedc_h=1.
val labels bpmedc_h 0 "not on BP med" 1 "on BP med".
exe.
*Hypertension (PRESCRIBED FOR HIGH BP).
compute highbp=hy140om.
VALUE LABELS highbp 1 'Normotensive untreated' 
2 'Normotensive treated' 
3 'Hypertensive treated' 
4 'Hypertensive untreated'.
*Cholesterol.
compute cholval13=cholest.
EXECUTE.
compute hdlval1a = hdlchol.
exe.
*Lipid.
compute lipid_h=-2.
if (lipid=0)|(medcnjd=2) lipid_h=0.
if (lipid=1) lipid_h=1.
val labels lipid_h 0 "not on lipid" 1 "lipid".
exe.
*CVD med.
compute medtyp1_h=-2.
if (medtyp1=0) medtyp1_h=0.
if (medtyp1=1) medtyp1_h=1.
val labels medtyp1_h 0 "not on CVDmed" 1 "CVDmed".
exe.
compute psu99=psu.
EXECUTE.
FORMAT psu99 (F4).
EXE.
string areastr (a4).
compute AREAstr = STRING(psu99,F4).
exe.
compute AREAstr = LTRIM(areastr).
exe.
string year1 (a4).
compute year1="2008".
exe.
STRING point1 (A8).
COMPUTE point1 = CONCAT(year1,areastr).
EXECUTE.
compute age_h=age.
exe.
*Diabetes.
compute glyhb_h = glyhbval.
exe.
compute year=2008.
save outfile = "TEMP\HSE2008RF.sav"
/keep hid id psu year sex age age_h ag16g10  
origin hhsize maritalb
tenureb car numcars qimd imd_h
cholest cholval13
genhelf genhelf2 porfv limitill longill limitact
illsm1 illsm2 illsm3 illsm4 illsm5 illsm6
wtval2 htval bmival2 
topqual3 cigsta3 genhelf2
gor point1 wt_int wt_nurse wt_blood
omsysval omdiaval highbp porfv porftvg a30t06c
mintb vismon
bprespc sys1om sys2om sys3om omsysval 
dias1om dias2om dias3om hy140om 
whval wstval hipval origin5 sclass sclass_h hhsize
compm1 compm2 compm3 compm4 compm5 compm6 compm7 compm8 compm9 compm10
compm11 compm12 compm13 compm14 compm15
waist1 waist2 waist3 wstval 
hip1 hip2 hip3 hipval whval urban_b 
urban urban_b urban3 airtemp
marstatc mstatus_h medcnjd bpmedd cluster  pregntj a30t06c hdlchol hdlval1a totinc eqvinc eqv5
srcin06b srcin07b srcin08b srcin09b srcin10b srcin11b srcin12b alclimit07b
benefit1 benefit2 benefit4 benefit5 benefit6 benefit7 benefit9 nuroutc
bpmedd bpmedc bpmedd_h bpmedc_h  lipid lipid_h medtyp1 medtyp1_h ghq12scr qrtint qrtnvis dnnow dnany dnevr glyhbval glyhb_h
puls1om puls2om puls3om.




* 2009.
DATASET CLOSE All.
GET FILE='BASE_DIRECTORY\hse09ai.sav'.
missing values all ().
exe.
select if age>=16.
EXECUTE.
**Household id.
compute hid=hserial.
EXECUTE.
formats hid(F10.0).
EXECUTE.
compute id=pserial.
EXECUTE.
formats id(F10.0).
exe.
compute qrtint=-99.
if any(mintb,1,2,3) qrtint=1.
if any(mintb,4,5,6) qrtint=2.
if any(mintb,7,8,9) qrtint=3.
if any(mintb,10,11,12) qrtint=4.
EXECUTE.
variable label qrtint "Quarter of Interview".
value labels qrtint 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
exe.
compute qrtnvis=-99.
if any(vismon,1,2,3) qrtnvis=1.
if any(vismon,4,5,6) qrtnvis=2.
if any(vismon,7,8,9) qrtnvis=3.
if any(vismon,10,11,12) qrtnvis=4.
EXECUTE.
variable label qrtnvis "Quarter of Nurse visit".
value labels qrtnvis 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
exe.
*gor (string 3).
delete variables gor.
rename var (gor07 = gor).
EXECUTE.
formats gor(F8.2).
EXECUTE.
compute imd_h=imd2007.
formats imd_h(F8.2).
exe.
*marital status.
compute mstatus_h=-2.
if marstatc=1 mstatus_h=1.
if marstatc=2 mstatus_h=2.
if marstatc=3 mstatus_h=2.
if marstatc=4 mstatus_h=3.
if marstatc=5 mstatus_h=4.
if marstatc=6 mstatus_h=5.
if marstatc=7 mstatus_h=9.
var label mstatus_h "marital status harmonised".
val labels mstatus_h 1 "single" 2 "married" 3 "separated" 4 "divorced" 5 "widowed" 9 "cohabitees".
exe.

*Urban.
compute urban_b=-2.
if urban=1 urban_b=1.
if any(urban,2,3) urban_b=0.
var label urban_b "Binary urban".
val labels urban_b 0 "Not urban" 1 "Urban".
exe.
compute urban3=urban.
value labels urban3 
1 "Urban"
2 "Town & Fringe"
3 "Village, Hamlet and Isolated Dwelling".
formats urban3 (F8.2).
exe.

*Minority ethnic group.
compute origin5=-2.
if (origin=1)|(origin=2)|(origin=3) origin5=1.
if (origin=12)|(origin=13)|(origin=14) origin5=2.
if (origin=8)|(origin=9)|(origin=10)|(origin=11)|(origin=15) origin5=3.
if (origin=4)|(origin=5)|(origin=6)|(origin=7) origin5=4.
if (origin=16) origin5=5.
value labels origin5
1 "White"
2 "Black"
3 "Asian"
4 "Mixed"
5 "Any other".
missing values origin5 (-2).
*Ethnicity.
compute origin1=-2.
if ANy(origin,1,2,3) origin1=1.
if any(origin,4,5,6,7,8,9,10,11,12,13,14,15,16) origin1=0.
exe.
value labels origin1 0 "non-white" 1 "white".
exe.
*social class.
compute sclass_h=-2.
if sclass=1 sclass_h=1.
if sclass=2 sclass_h=2.
if sclass=3 sclass_h=3.
if sclass=4 sclass_h=4.
if sclass=5 sclass_h=5.
if sclass=6 sclass_h=6.
val labels sclass_h 1 "I" 2 "II" 3 "IIIN" 4 "IIIM" 5 "IV" 6 "V".
*BMI.
compute bmival2=bmival.
compute wtval2=wtval.
exe.
compute bmivg52=-2.
if range(bmival2,0,18.4999) bmivg52=0.
if range(bmival2,18.5,24.9999) bmivg52=1.
if range(bmival2,25.000,29.9999) bmivg52=2.
if range(bmival2,30,34.9999) bmivg52=3.
if range(bmival2,35,100) bmivg52=4.
EXECUTE.
value labels bmivg52 0 "Underweight" 1 "Normal-weight" 2 "Overweight" 3 "Obese I" 4 "Obese II".
*Benefits.
compute benefit1=srcin06b.
compute benefit2=srcin07b.
compute benefit4=srcin08b.
compute benefit5=srcin09b.
compute benefit6=srcin10b.
compute benefit7=srcin11b.
compute benefit9=srcin12b.
exe.
*Hypertension.
compute bpmedd_h=-2.
if (bpmedd=0)|(medcnjd=2) bpmedd_h=0.
if (bpmedd=1) bpmedd_h=1.
val labels bpmedd_h 0 "not on BP med" 1 "on BP med".
exe.
compute bpmedc_h=-2.
if (bpmedc=0)|(medcnjd=2) bpmedc_h=0.
if (bpmedc=1) bpmedc_h=1.
val labels bpmedc_h 0 "not on BP med" 1 "on BP med".
exe.
*Hypertension (meds PRESCRIBED for high BP).
compute highbp=hy140om.
VALUE LABELS highbp 1 'Normotensive untreated' 
2 'Normotensive treated' 
3 'Hypertensive treated' 
4 'Hypertensive untreated'.
exe.
*Cholesterol.
compute hdlval1a = hdlchol.
exe.
compute cholval13=cholest.
EXECUTE.

*Lipid.
compute lipid_h=-2.
if (lipid=0)|(medcnjd=2) lipid_h=0.
if (lipid=1) lipid_h=1.
val labels lipid_h 0 "not on lipid" 1 "lipid".
compute medtyp1_h=-2.
if (medtyp1=0) medtyp1_h=0.
if (medtyp1=1) medtyp1_h=1.
val labels medtyp1_h 0 "not on CVDmed" 1 "CVDmed".
exe.

*Diabetes.
compute diabete3=-11.
If (Glyhbval>0 & Glyhbval<6.5) & (diabete2=2) diabete3=1.
If (Glyhbval>0 & diabete2=1) diabete3=2.
If (Glyhbval>6.4) & (diabete2=2) diabete3=3.
If any(-9,diabete2) diabete3=-9.
If any(-8,diabete2) diabete3=-8.
If any(-1,diabete2) diabete3=-1.
Value labels diabete3
1 "No diabetes"
2 "Doctor diagnosed diabetes"
3 "Undiagnosed diabetes HbA1c>=6.5%".
Variable label diabete3 "(D) Diabetes from blood sample (>=6.5%) or doctor diagnosis (excluding pregnancy-only diabetes)".
missing values diabete3 (-9,-8,-1).
exe.
compute dimed_h = dimed.
EXECUTE.
compute glyhb_h = glyhbval.
EXECUTE.
*CVD risk.
compute CVD_Risk=-2.
if (cigsta3>0) & (bmival2>0) & (highbp>0) & (diabete2>0) CVD_Risk=1.
VARIABLE LABELS CVD_Risk "(D) Valid information for CVD_Risk" .
exe.
compute psu99=psu.
EXECUTE.
FORMAT psu99 (F4).
EXE.
string areastr (a4).
compute AREAstr = STRING(psu99,F4).
exe.
compute AREAstr = LTRIM(areastr).
exe.
string year1 (a4).
compute year1="2009".
exe.
STRING point1 (A8).
COMPUTE point1 = CONCAT(year1,areastr).
EXECUTE.
compute age_h=age.
exe.
compute year=2009.
save outfile = "TEMP\HSE2009RF.sav"
/keep hid id year sex age age_h ag16g10 year 
origin hhsize maritalb
tenureb car numcars imd2007 imd_h
cholest cholval13
genhelf genhelf2 porfv porftvg limitill longill limitact
illsm1 illsm2 illsm3 illsm4 illsm5 illsm6
diabete2 bp1
bp1 
wtval2 htval bmival2 
topqual3 cigsta3 genhelf2
gor point1 wt_int wt_nurse wt_blood
omsysval omdiaval highbp porfv
mintb vismon
bprespc sys1om sys2om sys3om omsysval 
dias1om dias2om dias3om
hy140om bpmedd CVD_Risk
origin5 sclass sclass_h hhsize
compm1 compm2 compm3 compm4 compm5 compm6 compm7 compm8 compm9 compm10
compm11 compm12 compm13 compm14 compm15
waist1 waist2 waist3 wstval 
hip1 hip2 hip3 hipval whval urban_b medbp 
urban urban_b urban3 airtemp
marstatc mstatus_h medcnjd  everbp everdi diabtype diabetes docbp psu cluster pregntj hdlval1a hdlchol totinc eqvinc eqv5
srcin06b srcin07b srcin08b srcin09b srcin10b srcin11b srcin12b alclimit07b
benefit1 benefit2 benefit4 benefit5 benefit6 benefit7 benefit9 nuroutc
bpmedd bpmedc bpmedd_h bpmedc_h diabete3 lipid lipid_h medtyp1 medtyp1_h insulin dimed_h ghq12scr qrtint qrtnvis dnnow dnany dnevr glyhbval glyhb_h
puls1om puls2om puls3om.



* 2010.
DATASET CLOSE All.
GET FILE='BASE_DIRECTORY\hse10ai.sav'.
select if age>=16.
EXECUTE.
missing values all ().
exe.
**Household id.
compute hid=hserial.
EXECUTE.
formats hid(F10.0).
EXECUTE.
compute qrtint=-99.
if any(mintb,1,2,3) qrtint=1.
if any(mintb,4,5,6) qrtint=2.
if any(mintb,7,8,9) qrtint=3.
if any(mintb,10,11,12) qrtint=4.
EXECUTE.
variable label qrtint "Quarter of Interview".
value labels qrtint 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
exe.
compute qrtnvis=-99.
if any(vismon,1,2,3) qrtnvis=1.
if any(vismon,4,5,6) qrtnvis=2.
if any(vismon,7,8,9) qrtnvis=3.
if any(vismon,10,11,12) qrtnvis=4.
EXECUTE.
variable label qrtnvis "Quarter of Nurse visit".
value labels qrtnvis 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
exe.
delete variables gor.
rename var (gor1 = gor).
EXECUTE.
formats gor(F8.2).
EXECUTE.
compute imd_h=imd2007.
formats imd_h(F8.2).
EXECUTE.
compute id=pserial.
EXECUTE.
formats id(F10.0).
exe.
compute mstatus_h=-2.
if marstatc=1 mstatus_h=1.
if marstatc=2 mstatus_h=2.
if marstatc=3 mstatus_h=2.
if marstatc=4 mstatus_h=3.
if marstatc=5 mstatus_h=4.
if marstatc=6 mstatus_h=5.
if marstatc=7 mstatus_h=9.
var label mstatus_h "marital status harmonised".
val labels mstatus_h 1 "single" 2 "married" 3 "separated" 4 "divorced" 5 "widowed" 9 "cohabitees".
exe.
*Urban.
compute urban_b=-2.
if urban=1 urban_b=1.
if any(urban,2,3) urban_b=0.
var label urban_b "Binary urban".
val labels urban_b 0 "Not urban" 1 "Urban".
exe.
compute urban3=urban.
value labels urban3 
1 "Urban"
2 "Town & Fringe"
3 "Village, Hamlet and Isolated Dwelling".
formats urban3 (F8.2).
*minority ethnic group.
compute origin5=-2.
if (origin=1)|(origin=2)|(origin=3) origin5=1.
if (origin=12)|(origin=13)|(origin=14) origin5=2.
if (origin=8)|(origin=9)|(origin=10)|(origin=11)|(origin=15) origin5=3.
if (origin=4)|(origin=5)|(origin=6)|(origin=7) origin5=4.
if (origin=16) origin5=5.
value labels origin5
1 "White"
2 "Black"
3 "Asian"
4 "Mixed"
5 "Any other".
missing values origin5 (-2).
*Ethnicity.
compute origin1=-2.
if ANy(origin,1,2,3) origin1=1.
if any(origin,4,5,6,7,8,9,10,11,12,13,14,15,16) origin1=0.
exe.
value labels origin1 0 "non-white" 1 "white".
EXECUTE.
*BMI.
compute bmival2=bmival.
compute wtval2=wtval.
exe.
compute bmivg52=-2.
if range(bmival2,0,18.4999) bmivg52=0.
if range(bmival2,18.5,24.9999) bmivg52=1.
if range(bmival2,25.000,29.9999) bmivg52=2.
if range(bmival2,30,34.9999) bmivg52=3.
if range(bmival2,35,100) bmivg52=4.
EXECUTE.
value labels bmivg52 0 "Underweight" 1 "Normal-weight" 2 "Overweight" 3 "Obese I" 4 "Obese II".
*Benefits.
compute benefit1=srcin06b.
compute benefit2=srcin07b.
compute benefit4=srcin08b.
compute benefit5=srcin09b.
compute benefit6=srcin10b.
compute benefit7=srcin11b.
compute benefit9=srcin12b.

*Hypertension.
compute bpmedd_h=-2.
if (bpmedd=0)|(medcnjd=2) bpmedd_h=0.
if (bpmedd=1) bpmedd_h=1.
val labels bpmedd_h 0 "not on BP med" 1 "on BP med".
exe.
compute bpmedc_h=-2.
if (bpmedc=0)|(medcnjd=2) bpmedc_h=0.
if (bpmedc=1) bpmedc_h=1.
val labels bpmedc_h 0 "not on BP med" 1 "on BP med".
exe.
**Hypertension (meds PRESCRIBED for high BP).
compute highbp=hy140om.
VALUE LABELS highbp 1 'Normotensive untreated' 
2 'Normotensive treated' 
3 'Hypertensive treated' 
4 'Hypertensive untreated'.
exe.
*Cholesterol.
compute cholval13=cholest.
EXECUTE.
*adjust downwards as new machinery = 0.1 higher.
if (cholflag=2) cholval13=(cholval13 - 0.1).
exe.
compute Hdlval1a = (hdlval1).
*adjust upwards as new machinery = 0.1 lower.
if (cholflag=2) Hdlval1a=(Hdlval1a + 0.1).
exe.

*Lipid.
compute lipid_h=-2.
if (lipid=0)|(medcnjd=2) lipid_h=0.
if (lipid=1) lipid_h=1.
val labels lipid_h 0 "not on lipid" 1 "lipid".
exe.
compute medtyp1_h=-2.
if (medtyp1=0) medtyp1_h=0.
if (medtyp1=1) medtyp1_h=1.
val labels medtyp1_h 0 "not on CVDmed" 1 "CVDmed".
exe.

*Diabetes.
compute diabete3=-11.
If (Glyhbval>0 & Glyhbval<6.5) & (diabete2=2) diabete3=1.
If (Glyhbval>0 & diabete2=1) diabete3=2.
If (Glyhbval>6.4) & (diabete2=2) diabete3=3.
If any(-9,diabete2) diabete3=-9.
If any(-8,diabete2) diabete3=-8.
If any(-1,diabete2) diabete3=-1.
Value labels diabete3
1 "No diabetes"
2 "Doctor diagnosed diabetes"
3 "Undiagnosed diabetes HbA1c>=6.5%".
Variable label diabete3 "(D) Diabetes from blood sample (>=6.5%) or doctor diagnosis (excluding pregnancy-only diabetes)".
missing values diabete3 (-9,-8,-1).
exe.
*CVD risk.
compute CVD_Risk=-2.
if (cigsta3>0) & (bmival2>0) & (highbp>0) & (diabete2>0) CVD_Risk=1.
VARIABLE LABELS CVD_Risk "(D) Valid information for CVD_Risk" .
compute psu99=psu.
EXECUTE.
FORMAT psu99 (F4).
EXE.
string areastr (a4).
compute AREAstr = STRING(psu99,F4).
exe.
compute AREAstr = LTRIM(areastr).
exe.
string year1 (a4).
compute year1="2010".
exe.
STRING point1 (A8).
COMPUTE point1 = CONCAT(year1,areastr).
EXECUTE.
compute age_h=age.
exe.
compute glyhb_h = glyhbval.
exe.
compute dimed_h = dimed.
EXECUTE.

compute year=2010.
save outfile = "TEMP\HSE2010RF.sav"
/keep hid id year sex age age_h ag16g10 
sex age origin hhsize maritalb
tenureb car numcars imd2007 imd_h
cholest cholval13
hdlval1 Hdlval1a
genhelf genhelf2 porfv limitill longill limitact
illsm1 illsm2 illsm3 illsm4 illsm5 illsm6
diabete2 
bp1 
wtval2 htval bmival2 
topqual3 cigsta3 genhelf2
gor point1 wt_int wt_nurse wt_blood
omsysval omdiaval highbp porfv porftvg
mintb vismon
bprespc sys1om sys2om sys3om omsysval 
dias1om dias2om dias3om
hy140om bpmedd CVD_Risk
origin5 hhsize
compm1 compm2 compm3 compm4 compm5 compm6 compm7 compm8 compm9 compm10
compm11 compm12 compm13 compm14 compm15
waist1 waist2 waist3 wstval 
hip1 hip2 hip3 hipval whval medbp 
urban urban_b urban3 airtemp
marstatc mstatus_h medcnjd  everbp everdi diabtype diabetes docbp psu cluster 
pregnowb pregntj totinc eqvinc eqv5
srcin06b srcin07b srcin08b srcin09b srcin10b srcin11b srcin12b alclimit07b
benefit1 benefit2 benefit4 benefit5 benefit6 benefit7 benefit9 nuroutc
bpmedd bpmedc bpmedd_h bpmedc_h diabete3 lipid lipid_h
medtyp1 medtyp1_h insulin dimed_h ghq12scr qrtint qrtnvis dnnow dnany dnevr  glyhbval glyhb_h
puls1om puls2om puls3om.



* 2011.
DATASET CLOSE All.
GET FILE='BASE_DIRECTORY\hse2011ai.sav'.
missing values all ().
exe.
select if age>=16.
EXECUTE.
**Household id.
compute hid=hserial.
EXECUTE.
formats hid(F10.0).
EXECUTE.
compute id=pserial.
EXECUTE.
formats id(F10.0).
exe.
compute qrtint=-99.
if any(mintb,1,2,3) qrtint=1.
if any(mintb,4,5,6) qrtint=2.
if any(mintb,7,8,9) qrtint=3.
if any(mintb,10,11,12) qrtint=4.
EXECUTE.
variable label qrtint "Quarter of Interview".
value labels qrtint 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
exe.
compute qrtnvis=-99.
if any(vismon,1,2,3) qrtnvis=1.
if any(vismon,4,5,6) qrtnvis=2.
if any(vismon,7,8,9) qrtnvis=3.
if any(vismon,10,11,12) qrtnvis=4.
EXECUTE.
variable label qrtnvis "Quarter of Nurse visit".
value labels qrtnvis 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
rename var (gor1 = gor).
EXECUTE.
formats gor(F8.2).
EXECUTE.
compute imd_h=qimd.
formats imd_h(F8.2).
exe.
compute mstatus_h=-2.
if marstatc=1 mstatus_h=1.
if marstatc=2 mstatus_h=2.
if marstatc=3 mstatus_h=2.
if marstatc=4 mstatus_h=3.
if marstatc=5 mstatus_h=4.
if marstatc=6 mstatus_h=5.
if marstatc=7 mstatus_h=9.
var label mstatus_h "marital status harmonised".
val labels mstatus_h 1 "single" 2 "married" 3 "separated" 4 "divorced" 5 "widowed" 9 "cohabitees".
*minority ethnic group.
compute origin5=-2.
if (origin=1)|(origin=2)|(origin=3)|(origin=4) origin5=1.
if (origin=13)|(origin=14)|(origin=15) origin5=2.
if (origin=9)|(origin=10)|(origin=11)|(origin=12) origin5=3.
if (origin=5)|(origin=6)|(origin=7)|(origin=8) origin5=4.
if (origin=16)|(origin=17)|(origin=18) origin5=5.
missing values origin5 (-2).
*Ethnicity.
compute origin1=-2.
if ANy(origin,1,2,3,4) origin1=1.
if any(origin,5,6,7,8,9,10,11,12,13,14,15,16,17,18) origin1=0.
exe.
value labels origin1 0 "non-white" 1 "white".
exe.
*Urban.
compute urban_b=-2.
if urban=1 urban_b=1.
if any(urban,2,3) urban_b=0.
var label urban_b "Binary urban".
val labels urban_b 0 "Not urban" 1 "Urban".
exe.
compute urban3=urban.
value labels urban3 
1 "Urban"
2 "Town & Fringe"
3 "Village, Hamlet and Isolated Dwelling".
formats urban3 (F8.2).
*BMI.
compute bmival2=bmival.
compute wtval2=wtval.
exe.
compute bmivg52=-2.
if range(bmival2,0,18.4999) bmivg52=0.
if range(bmival2,18.5,24.9999) bmivg52=1.
if range(bmival2,25.000,29.9999) bmivg52=2.
if range(bmival2,30,34.9999) bmivg52=3.
if range(bmival2,35,100) bmivg52=4.
EXECUTE.
value labels bmivg52 0 "Underweight" 1 "Normal-weight" 2 "Overweight" 3 "Obese I" 4 "Obese II".

*alcohol.
*weekly.
recode totalwug (0=0) (1 thru 4=1) (5=2) (6 thru 7=3) (8=4) (9=5) (else=copy).
exe.
*Benefits.
compute benefit1=srcin06b.
compute benefit2=srcin07b.
compute benefit4=srcin08b.
compute benefit5=srcin09b.
compute benefit6=srcin10b.
compute benefit7=srcin11b.
compute benefit9=srcin12b.
exe.

*Hypertension.
compute bpmedd_h=-2.
if (bpmedd=0)|(medcnjd=2) bpmedd_h=0.
if (bpmedd=1) bpmedd_h=1.
val labels bpmedd_h 0 "not on BP med" 1 "on BP med".
exe.
compute bpmedc_h=-2.
if (bpmedc=0)|(medcnjd=2) bpmedc_h=0.
if (bpmedc=1) bpmedc_h=1.
val labels bpmedc_h 0 "not on BP med" 1 "on BP med".
exe.

compute highbp=hy140om2.
VALUE LABELS highbp 1 'Normotensive untreated' 
2 'Normotensive treated' 
3 'Hypertensive treated' 
4 'Hypertensive untreated'.
exe.
*Cholesterol.
compute Hdlval1a = (hdlval1)+ 0.1.
*adjust upwards as new machinery = 0.1 lower.
compute raised=-2.
if range(cholval1old,0,4.9) raised=0.
if cholval1old>4.9 raised=1.
exe.
compute cholval13=cholval1old.
EXECUTE.

*Lipid.
compute lipid_h=-2.
if (lipid=0)|(medcnjd=2) lipid_h=0.
if (lipid=1) lipid_h=1.
val labels lipid_h 0 "not on lipid" 1 "lipid".
*CVD med.
compute medtyp1_h=-2.
if (medtyp1=0) medtyp1_h=0.
if (medtyp1=1) medtyp1_h=1.
val labels medtyp1_h 0 "not on CVDmed" 1 "CVDmed".
EXECUTE.

*Diabetes.
**** use 6.5 for 2011 (48+ after).
compute diabete3=-11.
If (Glyhbval>0 & Glyhbval<6.5) & (diabete2=2) diabete3=1.
If (Glyhbval>0 & diabete2=1) diabete3=2.
If (Glyhbval>6.4) & (diabete2=2) diabete3=3.
If any(-9,diabete2) diabete3=-9.
If any(-8,diabete2) diabete3=-8.
If any(-1,diabete2) diabete3=-1.
Value labels diabete3
1 "No diabetes"
2 "Doctor diagnosed diabetes"
3 "Undiagnosed diabetes HbA1c>=6.5%".
Variable label diabete3 "(D) Diabetes from blood sample (>=6.5%) or doctor diagnosis (excluding pregnancy-only diabetes)".
missing values diabete3 (-9,-8,-1).
EXECUTE.
*CVD risk.
compute CVD_Risk=-2.
if (cigsta3>0) & (bmival2>0) & (highbp>0) & (diabete2>0) CVD_Risk=1.
VARIABLE LABELS CVD_Risk "(D) Valid information for CVD_Risk" .
exe.
STRING point1 (A8).
COMPUTE point1 = STRING(psu, F7.0).
EXECUTE.
compute age_h=age.
exe.

*Diagnosed BP (regardless of diagnosed only if pregnant; missing not coded as no).
compute diag_hbp_h=-99.
if everbp=2|docnurbp=2 diag_hbp_h=0.
if everbp=1 & (docnurbp=1) diag_hbp_h=1.
value labels diag_hbp_h 0 "No" 1 "Yes".
fre diag_hbp_h.

*Diagnosed stroke (missing not coded as no).
compute diag_stroke_h=-99.
if everstro=2|docstro=2 diag_stroke_h=0.
if everstro=1 & (docstro=1) diag_stroke_h=1.
value labels diag_stroke_h 0 "No" 1 "Yes".
fre diag_stroke_h.

*Diagnosed angina (regardless of diagnosed only if pregnant; missing not coded as no).
compute diag_angi_h=-99.
if everangi=2|docangi=2 diag_angi_h=0.
if everangi=1 & (docangi=1) diag_angi_h=1.
value labels diag_angi_h 0 "No" 1 "Yes".
fre diag_angi_h.   

*Diagnosed MI (regardless of diagnosed only if pregnant; missing not coded as no).
compute diag_mi_h=-99.
if everhart=2|docheart=2 diag_mi_h=0.
if everhart=1 & (docheart=1) diag_mi_h=1.
value labels diag_mi_h 0 "No" 1 "Yes".
fre diag_mi_h.  

*Diagnosed diabetes (regardless of diagnosed only if pregnant; missing not coded as no).
compute diag_diab_h=-99.
if everdi=2|docinfo1=2 diag_diab_h=0.
if everdi=1 & (docinfo1=1) diag_diab_h=1.
value labels diag_diab_h 0 "No" 1 "Yes".
fre diag_diab_h. 
 
*Ischaemic heart disease.
compute diag_isch_h=-99.
if (diag_mi_h=0 & diag_angi_h=0) diag_isch_h=0.
if (diag_mi_h=1 | diag_angi_h=1) diag_isch_h=1.
value labels diag_isch_h 0 "No" 1 "Yes".
fre diag_isch_h. 

compute glyhb_h = glyhbval.
exe.
compute dimed_h = medcindi.
EXECUTE.

compute year=2011.
save outfile = "TEMP\HSE2011RF.sav"
/keep hid id year sex age age_h ag16g10 
sex age origin hhsize maritalb
tenureb car numcars qimd imd_h
cholval13
genhelf genhelf2 porfv limitill longill limitact
illsm1 illsm2 illsm3 illsm4 illsm5 illsm6
diabete2 bp1
wtval2 htval bmival2 
topqual3 cigsta3 genhelf2
gor point1 wt_int wt_nurse wt_blood
omsysval omdiaval highbp cholval13 
 hdlval1 Hdlval1a
raised porfv porftvg
mintb vismon
bprespc sys1om sys2om sys3om omsysval 
dias1om dias2om dias3om
hy140om2 CVD_Risk
origin5 hhsize
compm1 compm2 compm3 compm4 compm5 compm6 compm7 compm8 compm9 compm10
compm11 compm12 compm13 compm14 compm15
waist1 waist2 waist3 wstval 
hip1 hip2 hip3 hipval whval 
medcinbp 
urban urban_b urban3 airtemp
everbp everangi everhart evermur everireg everoht everstro everdi
strodef angidef heartdef murmur1 iregdef ohtdef
docstro docangi docheart murdoc docireg docinfo1 docoht docnurbp bp1
marstatc mstatus_h medcnjd bpmedd ihdis cvdis diabtype psu cluster 
pregnowb pregntj hdlval1 totinc eqvinc eqv5
srcin06b srcin07b srcin08b srcin09b srcin10b srcin11b srcin12b alclimit07b totalwug totalwu
benefit1 benefit2 benefit4 benefit5 benefit6 benefit7 benefit9 nuroutc
bpmedd bpmedc bpmedd_h bpmedc_h diabete3 lipid lipid_h medtyp1 medtyp1_h medheart insulin dimed_h qrtint qrtnvis
diag_hbp_h diag_stroke_h diag_angi_h diag_mi_h diag_diab_h diag_isch_h dnnow dnany dnevr  glyhbval glyhb_h puls1om puls2om puls3om.


* 2012.

DATASET CLOSE All.
GET FILE='BASE_DIRECTORY\hse2012ai.sav'.
missing values all ().
exe.
select if age>=16.
EXECUTE.
**Household id.
compute hid=hserial.
EXECUTE.
formats hid(F10.0).
EXECUTE.
compute id=pserial.
EXECUTE.
formats id(F10.0).
exe.
compute qrtint=-99.
if any(mintb,1,2,3) qrtint=1.
if any(mintb,4,5,6) qrtint=2.
if any(mintb,7,8,9) qrtint=3.
if any(mintb,10,11,12) qrtint=4.
EXECUTE.
variable label qrtint "Quarter of Interview".
value labels qrtint 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
exe.
compute qrtnvis=-99.
if any(vismon,1,2,3) qrtnvis=1.
if any(vismon,4,5,6) qrtnvis=2.
if any(vismon,7,8,9) qrtnvis=3.
if any(vismon,10,11,12) qrtnvis=4.
EXECUTE.
variable label qrtnvis "Quarter of Nurse visit".
value labels qrtnvis 1 "First quarter of year" 2 "Second quarter of year" 3 "Third quarter of year" 4 "Fourth quarter of year".
compute imd_h=qimd.
formats imd_h(F8.2).
exe.
rename var (gor1 sclass = gor sclass12).
EXECUTE.
formats gor(F8.2).
EXECUTE.
*marital status.
compute mstatus_h=-2.
if marstatc=1 mstatus_h=1.
if marstatc=2 mstatus_h=2.
if marstatc=3 mstatus_h=2.
if marstatc=4 mstatus_h=3.
if marstatc=5 mstatus_h=4.
if marstatc=6 mstatus_h=5.
if marstatc=7 mstatus_h=9.
var label mstatus_h "marital status harmonised".
val labels mstatus_h 1 "single" 2 "married" 3 "separated" 4 "divorced" 5 "widowed" 9 "cohabitees".
*minority ethnic group.
compute origin5=-2.
if (origin=1)|(origin=2)|(origin=3)|(origin=4) origin5=1.
if (origin=13)|(origin=14)|(origin=15) origin5=2.
if (origin=9)|(origin=10)|(origin=11)|(origin=12) origin5=3.
if (origin=5)|(origin=6)|(origin=7)|(origin=8) origin5=4.
if (origin=16)|(origin=17)|(origin=18) origin5=5.
missing values origin5 (-2).

*Ethnicity.
compute origin1=-2.
if ANy(origin,1,2,3,4) origin1=1.
if any(origin,5,6,7,8,9,10,11,12,13,14,15,16,17,18) origin1=0.
exe.
value labels origin1 0 "non-white" 1 "white".
EXECUTE.

*Urban.
compute urban_b=-2.
if urban=1 urban_b=1.
if any(urban,2,3) urban_b=0.
var label urban_b "Binary urban".
val labels urban_b 0 "Not urban" 1 "Urban".
compute urban3=urban.
value labels urban3 
1 "Urban"
2 "Town & Fringe"
3 "Village, Hamlet and Isolated Dwelling".
formats urban3 (F8.2).
*Social class.
compute sclass_h=-2.
if sclass12=1 sclass_h=1.
if sclass12=2 sclass_h=2.
if sclass12=3.1 sclass_h=3.
if sclass12=3.2 sclass_h=4.
if sclass12=4 sclass_h=5.
if sclass12=5 sclass_h=6.
val labels sclass_h 1 "I" 2 "II" 3 "IIIN" 4 "IIIM" 5 "IV" 6 "V".
exe.
*BMI.
compute bmivg52=-2.
if range(bmival2,0,18.4999) bmivg52=0.
if range(bmival2,18.5,24.9999) bmivg52=1.
if range(bmival2,25.000,29.9999) bmivg52=2.
if range(bmival2,30,34.9999) bmivg52=3.
if range(bmival2,35,100) bmivg52=4.
EXECUTE.
value labels bmivg52 0 "Underweight" 1 "Normal-weight" 2 "Overweight" 3 "Obese I" 4 "Obese II".

*Smoke.
compute smoke=-2.
if (cigsta3=2|cigsta3=3) smoke=0.
if cigsta3=1 smoke=1.
value labels smoke 0 "Non-smoke" 1 "Smoke".
EXECUTE.

*Alcohol.
*weekly.
recode totalwug (0=0) (1 thru 4=1) (5=2) (6 thru 7=3) (8=4) (9=5) (else=copy).
exe.
*Benefits.
compute benefit1=srcin05c.
compute benefit2=srcin08c.
compute benefit3=srcin06c.
compute benefit4=srcin07c.
compute benefit5=srcin09c.
compute benefit6=srcin10c.
compute benefit7=srcin12c.
compute benefit8=srcin13c.
compute benefit9=srcin14c.
exe.

*Hypertension.
compute highbp=hy140om2.
VALUE LABELS highbp 1 'Normotensive untreated' 
2 'Normotensive treated' 
3 'Hypertensive treated' 
4 'Hypertensive untreated'.
exe.
compute bpmedd_h=bpmedd2.
compute bpmedc_h=bpmedc2.
EXECUTE.

*Cholesterol.
compute Hdlval1a = (hdlval12)+ 0.1.
*adjust upwards as new machinery = 0.1 lower.
compute cholest2=cholest - 0.1.
EXECUTE.
compute raised=-2.
if range(cholest2,0,4.9) raised=0.
if cholest2>4.9 raised=1.
EXECUTE.
compute cholval13=cholest2.
EXECUTE.
compute lipid_h=lipid2.
EXECUTE.
*CVD med.
compute medtyp1_h=-2.
if (medtyp1=0) medtyp1_h=0.
if (medtyp1=1) medtyp1_h=1.
val labels medtyp1_h 0 "not on CVDmed" 1 "CVDmed".

*Diabetes.
compute diab3mmol=-11.
If (ifcca1>0 & ifcca1<48) & (diabete2=2) diab3mmol=1.
If (ifcca1>0 & diabete2=1) diab3mmol=2.
If (ifcca1>=48) & (diabete2=2) diab3mmol=3.
If any(-9,diabete2) diab3mmol=-9.
If any(-8,diabete2) diab3mmol=-8.
If any(-1,diabete2) diab3mmol=-1.
Value labels diab3mmol
1 "No diabetes"
2 "Doctor diagnosed diabetes"
3 "Undiagnosed diabetes HbA1c>=48mmol/l".
Variable label diab3mmol "(D) Diabetes from blood sample (48+mmol/mol) or doctor diagnosis (excluding pregnancy-only diabetes)".
missing values diab3mmol (-9,-8,-1).
EXECUTE.

compute diabete3=-11.
If (Glyhbval>0 & Glyhbval<6.5) & (diabete2=2) diabete3=1.
If (Glyhbval>0 & diabete2=1) diabete3=2.
If (Glyhbval>6.4) & (diabete2=2) diabete3=3.
If any(-9,diabete2) diabete3=-9.
If any(-8,diabete2) diabete3=-8.
If any(-1,diabete2) diabete3=-1.
Value labels diabete3
1 "No diabetes"
2 "Doctor diagnosed diabetes"
3 "Undiagnosed diabetes HbA1c>=6.5%".
Variable label diabete3 "(D) Diabetes from blood sample (>=6.5%) or doctor diagnosis (excluding pregnancy-only diabetes)".
missing values diabete3 (-9,-8,-1).

*CVD risk.
compute CVD_Risk=-2.
if (cigsta3>0) & (bmival2>0) & (highbp>0) & (diabete2>0) CVD_Risk=1.
VARIABLE LABELS CVD_Risk "(D) Valid information for CVD_Risk".

compute psu99=psu.
EXECUTE.
STRING point1 (A8).
COMPUTE point1 = STRING(psu99, F7.0).
EXECUTE.
compute year=2012.
exe.
compute age_h=age.
exe.
compute glyhb_h = glyhbval.
exe.
compute glyhb2_h = ifcca1.
exe.
compute dimed_h = dimed.
exe.

save outfile = "TEMP\HSE2012RF.sav"
/keep hid id year sex age age_h ag16g10  
sex age origin hhsize maritalb
tenureb car numcars qimd imd_h
cholval13 
genhelf genhelf2
ill12m ill12m1 ill12m2 ill12m3
ill12m4 ill12m5 ill12m6 limlast 
diabete2 
bp1  
wtval2 htval bmival2 
topqual3 cigsta3 genhelf2
gor point1 wt_int wt_nurse wt_blood
omsysval omdiaval highbp 
mintb vismon
bprespc sys1om sys2om sys3om omsysval 
dias1om dias2om dias3om
hy140om2  CVD_Risk
origin5 sclass12 sclass_h hhsize
complst1 complst2 complst3 complst4 complst5 complst6 complst7 complst8 complst9 complst10
complst11 complst12 complst13 complst14 complst15
waist1 waist2 waist3 wstval 
hip1 hip2 hip3 hipval whval urban_b medbp 
urban urban_b urban3
marstatc mstatus_h medcnjd  everbp everdi diabtype diabetes docbp area cluster ifcca1
pregnowb pregntj a30t06c  hdlval12 Hdlval1a
totinc eqvinc eqv5
srcin05c srcin08c srcin06c srcin07c srcin09c srcin10c srcin12c srcin13c srcin14c alclimit07b totalwug totalwu
benefit1 benefit2 benefit3 benefit4 benefit5 benefit6 benefit7 benefit8 benefit9 nuroutc
bpmedd2 bpmedc2 bpmedd_h bpmedc_h 
diabete3 diab3mmol lipid2 lipid_h medtyp1 medtyp1_h insulin dimed_h ghq12scr qrtint qrtnvis dnnow dnany dnevr
ifcca1 glyhbval glyhb_h glyhb2_h puls1om puls2om puls3om.


* 2013.
DATASET CLOSE All.
GET FILE='BASE_DIRECTORY\hse2013ai.sav'.
missing values all ().
exe.
select if age>=16.
EXECUTE.
**Household id.
compute hid=hserial.
EXECUTE.
formats hid(F10.0).
EXECUTE.
compute id=pserial.
EXECUTE.
formats id(F10.0).
exe.
rename var (gor1 sclass = gor sclass12).
EXECUTE.
formats gor(F8.2).
EXECUTE.
compute imd_h=qimd.
formats imd_h(F8.2).
exe.
*marital status.
compute mstatus_h=-2.
if marstatd=1 mstatus_h=1.
if marstatd=2 mstatus_h=2.
if marstatd=3 mstatus_h=3.
if marstatd=4 mstatus_h=4.
if marstatd=5 mstatus_h=5.
if marstatd=6 mstatus_h=9.
var label mstatus_h "marital status harmonised".
val labels mstatus_h 1 "single" 2 "married" 3 "separated" 4 "divorced" 5 "widowed" 9 "cohabitees".

*Urban.
compute urban_b=-2.
if urban=1 urban_b=1.
if any(urban,2,3) urban_b=0.
var label urban_b "Binary urban".
val labels urban_b 0 "Not urban" 1 "Urban".
compute urban3=urban.
value labels urban3 
1 "Urban"
2 "Town & Fringe"
3 "Village, Hamlet and Isolated Dwelling".
formats urban3 (F8.2).
*Social class.
compute sclass_h=-2.
if sclass12=1 sclass_h=1.
if sclass12=2 sclass_h=2.
if sclass12=3.1 sclass_h=3.
if sclass12=3.2 sclass_h=4.
if sclass12=4 sclass_h=5.
if sclass12=5 sclass_h=6.
val labels sclass_h 1 "I" 2 "II" 3 "IIIN" 4 "IIIM" 5 "IV" 6 "V".
*Ethnic group.
compute origin5=-2.
if (origin=1)|(origin=2)|(origin=3)|(origin=4) origin5=1.
if (origin=13)|(origin=14)|(origin=15) origin5=2.
if (origin=9)|(origin=10)|(origin=11)|(origin=12) origin5=3.
if (origin=5)|(origin=6)|(origin=7)|(origin=8) origin5=4.
if (origin=16)|(origin=17)|(origin=18) origin5=5.
missing values origin5 (-2).
*Ethnicity.
compute origin1=-2.
if ANy(origin,1,2,3,4) origin1=1.
if any(origin,5,6,7,8,9,10,11,12,13,14,15,16,17,18) origin1=0.
exe.
value labels origin1 0 "non-white" 1 "white".
EXECUTE.

*BMI.
compute bmivg52=-2.
if range(bmival2,0,18.4999) bmivg52=0.
if range(bmival2,18.5,24.9999) bmivg52=1.
if range(bmival2,25.000,29.9999) bmivg52=2.
if range(bmival2,30,34.9999) bmivg52=3.
if range(bmival2,35,100) bmivg52=4.
EXECUTE.
value labels bmivg52 0 "Underweight" 1 "Normal-weight" 2 "Overweight" 3 "Obese I" 4 "Obese II".

*Smoke.
compute smoke=-2.
if (cigsta3=2|cigsta3=3) smoke=0.
if cigsta3=1 smoke=1.
value labels smoke 0 "Non-smoke" 1 "Smoke".
EXECUTE.

*alcohol.
*weekly.
recode totalwug (0=0) (1 thru 4=1) (5=2) (6 thru 7=3) (8=4) (9=5) (else=copy).
exe.
*Benefits.
compute benefit1=srcin05c.
compute benefit2=srcin08c.
compute benefit3=srcin06c.
compute benefit4=srcin07c.
compute benefit5=srcin09c.
compute benefit6=srcin10c.
compute benefit7=srcin12c.
compute benefit8=srcin13c.
compute benefit9=srcin14c.
exe.
*talk to GP in last last month.
compute docmonth=-2.
if (ndoctalk=1) & (whendoc<0) docmonth=1.
if (ndoctalk=1) & (whendoc=1) docmonth=1.
if (ndoctalk=1) & any(whendoc,2,3,4,5,6) docmonth=0.
if (ndoctalk=2) & whendoc=1 docmonth=1.
if (ndoctalk=2) & any(whendoc,2,3,4,5,6) docmonth=0.
variable label docmonth "Talk to GP in last month".
value labels docmonth 0 "No" 1 "Yes".

*Hypertension.
compute highbp=hy140om2.
VALUE LABELS highbp 1 'Normotensive untreated' 
2 'Normotensive treated' 
3 'Hypertensive treated' 
4 'Hypertensive untreated'.
exe.
compute bpmedd_h=bpmedd2.
compute bpmedc_h=bpmedc2.
EXECUTE.

missing values docbp pregbp othbp ().
exe. 
RECODE docbp (-9 thru -2=COPY) (1=1) (2=2) (-1=2) INTO bp1.
IF (sex=2 & othbp=2) bp1=2.
IF (ANY(-9,docbp,pregbp,othbp)) bp1=-9.
IF (ANY(-8,docbp,pregbp,othbp)) bp1=-8.
VARIABLE LABEL bp1 "(D) Doctor diagnosed high blood pressure (excluding pregnant)".
VALUE LABELS bp1
1 "Yes"
2 "No".
missing values bp1 (-9,-8,-1).
exe. 

*Cholesterol.
compute Hdlval1a = (hdlval12)+ 0.1.
*adjust upwards as new machinery = 0.1 lower.
compute cholest2=cholest - 0.1.
EXECUTE.

compute raised=-2.
if range(cholest2,0,4.9) raised=0.
if cholest2>4.9 raised=1.
EXECUTE.
compute cholval13=cholest2.
EXECUTE.
compute lipid_h=lipid2.
EXECUTE.

compute medtyp1_h=-2.
if (medtyp1=0) medtyp1_h=0.
if (medtyp1=1) medtyp1_h=1.
val labels medtyp1_h 0 "not on CVDmed" 1 "CVDmed".

*Diabetes.
compute adjusted=-1.
if range(qrtnvis,1,3) adjusted=ifcca1.
if (qrtnvis=4) & range(ifcca1,15,44) adjusted=ifcca1+1.
if (qrtnvis=4) & range(ifcca1,45,74) adjusted=ifcca1+2.
if (qrtnvis=4) & range(ifcca1,75,168) adjusted=ifcca1+3.
exe.

compute iffcvala=-11.
if range(qrtnvis,1,3) iffcvala=ifcca1.
if (qrtnvis=4) & range(ifcca1,15,44) iffcvala=ifcca1+1.
if (qrtnvis=4) & range(ifcca1,45,74) iffcvala=ifcca1+2.
if (qrtnvis=4) & range(ifcca1,75,168) iffcvala=ifcca1+3.
exe.

compute glyhb2_h = iffcvala.
EXECUTE.
compute diab3mmol=-11.
If (adjusted>0 & adjusted<48) & (diabete2=2) diab3mmol=1.
If (adjusted>0 & diabete2=1) diab3mmol=2.
If (adjusted>=48) & (diabete2=2) diab3mmol=3.
If any(-9,diabete2) diab3mmol=-9.
If any(-8,diabete2) diab3mmol=-8.
If any(-1,diabete2) diab3mmol=-1.
Value labels diab3mmol
1 "No diabetes"
2 "Doctor diagnosed diabetes"
3 "Undiagnosed diabetes HbA1c>=48mmol/l".
Variable label diab3mmol "(D) Diabetes from blood sample (48+mmol/mol) or doctor diagnosis (excluding pregnancy-only diabetes)".
missing values diab3mmol (-9,-8,-1).

compute diabete3=-11.
If (Glyhbval>0 & Glyhbval<6.5) & (diabete2=2) diabete3=1.
If (Glyhbval>0 & diabete2=1) diabete3=2.
If (Glyhbval>6.4) & (diabete2=2) diabete3=3.
If any(-9,diabete2) diabete3=-9.
If any(-8,diabete2) diabete3=-8.
If any(-1,diabete2) diabete3=-1.
Value labels diabete3
1 "No diabetes"
2 "Doctor diagnosed diabetes"
3 "Undiagnosed diabetes HbA1c>=6.5%".
Variable label diabete3 "(D) Diabetes from blood sample (>=6.5%) or doctor diagnosis (excluding pregnancy-only diabetes)".
missing values diabete3 (-9,-8,-1).

*CVD risk.
compute CVD_Risk=-2.
if (cigsta3>0) & (bmival2>0) & (highbp>0) & (diabete2>0) CVD_Risk=1.
VARIABLE LABELS CVD_Risk "(D) Valid information for CVD_Risk" .

compute psu99=psu.
EXECUTE.
STRING point1 (A8).
COMPUTE point1 = STRING(psu99, F7.0).
EXECUTE.
compute age_h=age.
exe.
compute glyhb_h = glyhbval.
exe.
compute dimed_h = dimed.
exe.
compute year=2013.
save outfile = "TEMP\HSE2013RF.sav"
/keep hid id year sex age age_h ag16g10 
sex age origin hhsize marstatd
tenureb car numcars qimd imd_h
cholval13
genhelf genhelf2 porfv
ill12m ill12m1 ill12m2 ill12m3
ill12m4 ill12m5 ill12m6 limlast 
diabete2 EverBP DocBP
wtval2 htval bmival2 
topqual3 cigsta3 genhelf2
gor point1 wt_int wt_nurse wt_blood
omsysval omdiaval highbp porfv porftvg
mintb vismon
qrtint qrtnvis
bprespc sys1om sys2om sys3om omsysval 
dias1om dias2om dias3om
hy140om2  CVD_Risk
origin5 sclass12 sclass_h hhsize
complst1 complst2 complst3 complst4 complst5 complst6 complst7 complst8 complst9 complst10
complst11 complst12 complst13 complst14 complst15
waist1 waist2 waist3 wstval 
hip1 hip2 hip3 hipval whval urban_b bp1 medbp 
urban urban_b urban3 airtemp
marstatd mstatus_h medcnjd  everdi diabtype diabetes docbp area cluster iffcvala
pregnowb pregntj medtyp14  hdlval12 
Hdlval1a
totinc eqvinc eqv5
srcin05c srcin08c srcin06c srcin07c srcin09c srcin10c srcin12c srcin13c srcin14c alclimit07b totalwug totalwu
benefit1 benefit2 benefit3 benefit4 benefit5 benefit6 benefit7 benefit8 benefit9 nuroutc
bpmedd2 bpmedc2 bpmedd_h bpmedc_h
diabete3 diab3mmol ndoctalk whendoc  docmonth lipid2 lipid_h medtyp1 medtyp1_h insulin dimed_h
OutPat01 OutPat02 OutPat03 OutPat95 InPat dnnow dnany dnevr
ifcca1 iffcvala glyhbval glyhb_h glyhb2_h puls1om puls2om puls3om.



*2014.
*Urban variable is not right.
DATASET CLOSE All.
GET FILE='BASE_DIRECTORY\hse2014ai.sav'.
missing values all ().
select if ag16g10>=1.
EXECUTE.
compute age=age90.
exe.

**Household id.
compute hid=hserial.
EXECUTE.
formats hid(F10.0).
EXECUTE.
compute id=pserial.
EXECUTE.
formats id(F10.0).
exe.
rename var (gor1 sclass hhsize9 = gor sclass12 hhsize).
EXECUTE.
formats gor(F8.2).
EXECUTE.
compute imd_h=qimd.
formats imd_h(F8.2).
exe.

*marital status.
compute mstatus_h=-2.
if marstatd=1 mstatus_h=1.
if marstatd=2 mstatus_h=2.
if marstatd=3 mstatus_h=3.
if marstatd=4 mstatus_h=4.
if marstatd=5 mstatus_h=5.
if marstatd=6 mstatus_h=9.
var label mstatus_h "marital status harmonised".
val labels mstatus_h 1 "single" 2 "married" 3 "separated" 4 "divorced" 5 "widowed" 9 "cohabitees".
*Social class.
compute sclass_h=-2.
if sclass12=1 sclass_h=1.
if sclass12=2 sclass_h=2.
if sclass12=3.1 sclass_h=3.
if sclass12=3.2 sclass_h=4.
if sclass12=4 sclass_h=5.
if sclass12=5 sclass_h=6.
val labels sclass_h 1 "I" 2 "II" 3 "IIIN" 4 "IIIM" 5 "IV" 6 "V".
*Minority ethnic group.
compute origin5=origin2.
*Ethnicity.
compute origin1=-2.
if any(origin2,1) origin1=1.
if any(origin2,2,3,4,5) origin1=0.
exe.
value labels origin1 0 "non-white" 1 "white".
exe.
*Urban.
compute urban_b=-2.
if urban=1 urban_b=1.
if any(urban,2,3) urban_b=0.
var label urban_b "Binary urban".
val labels urban_b 0 "Not urban" 1 "Urban".
compute urban3=urban.
value labels urban3 
1 "Urban"
2 "Town & Fringe"
3 "Village, Hamlet and Isolated Dwelling".
formats urban3 (F8.2).

*talk to GP in last last month.
compute docmonth=-2.
if (ndoctalk=1) & (whendoc<0) docmonth=1.
if (ndoctalk=1) & (whendoc=1) docmonth=1.
if (ndoctalk=1) & any(whendoc,2,3,4,5,6) docmonth=0.
if (ndoctalk=2) & whendoc=1 docmonth=1.
if (ndoctalk=2) & any(whendoc,2,3,4,5,6) docmonth=0.
variable label docmonth "Talk to GP in last month".
value labels docmonth 0 "No" 1 "Yes".

*BMI.
compute bmivg52=-2.
if range(bmival2,0,18.4999) bmivg52=0.
if range(bmival2,18.5,24.9999) bmivg52=1.
if range(bmival2,25.000,29.9999) bmivg52=2.
if range(bmival2,30,34.9999) bmivg52=3.
if range(bmival2,35,100) bmivg52=4.
EXECUTE.
value labels bmivg52 0 "Underweight" 1 "Normal-weight" 2 "Overweight" 3 "Obese I" 4 "Obese II".

*Smoke.
compute smoke=-2.
if (cigsta3=2|cigsta3=3) smoke=0.
if cigsta3=1 smoke=1.
value labels smoke 0 "Non-smoke" 1 "Smoke".
EXECUTE.

*Alcohol.
*weekly.
recode totalwug (0=0) (1 thru 4=1) (5=2) (6 thru 7=3) (8=4) (9=5) (else=copy).
exe.
*Benefits.
compute benefit1=srcin05c.
compute benefit2=srcin08c.
compute benefit3=srcin06c.
compute benefit4=srcin07c.
compute benefit5=srcin09c.
compute benefit6=srcin10c.
compute benefit7=srcin12c.
compute benefit8=srcin13c.
compute benefit9=srcin14c.
exe.
    
*Hypertension.
compute highbp=hy140om2.
VALUE LABELS highbp 1 'Normotensive untreated' 
2 'Normotensive treated' 
3 'Hypertensive treated' 
4 'Hypertensive untreated'.
compute bpmedd_h=bpmedd2.
compute bpmedc_h=bpmedc2.
EXECUTE.

*Cholesterol.
compute Hdlval1a = (hdlval12)+ 0.1.
*adjust upwards as new machinery = 0.1 lower.
compute adjusted=cholest - 0.1.
EXECUTE.

compute raised=-2.
if range(adjusted,0,4.9) raised=0.
if adjusted>4.9 raised=1.
EXECUTE.
compute cholval13=adjusted.
EXECUTE.
compute lipid_h=lipid2.
EXECUTE.

*CVD meds.
compute medtyp1_h=-2.
if (medtyp1=0) medtyp1_h=0.
if (medtyp1=1) medtyp1_h=1.
val labels medtyp1_h 0 "not on CVDmed" 1 "CVDmed".

*Diabetes.
*Reproduce the new adjustment from the old.
compute iffcvala=-11.
if range(ifcca1,15,44) iffcvala=ifcca1+1.
if range(ifcca1,45,74) iffcvala=ifcca1+2.
if range(ifcca1,75,168) iffcvala=ifcca1+3.
exe.
desc var iffcvala.
compute glyhb2_h = iffcvala.
exe.

compute diab3mmol=-11.
If (iffcvala>0 & iffcvala<48) & (diabete2=2) diab3mmol=1.
If (iffcvala>0 & diabete2=1) diab3mmol=2.
If (iffcvala>=48) & (diabete2=2) diab3mmol=3.
If any(-9,diabete2,iffcvala) diab3mmol=-9.
If any(-8,diabete2,iffcvala) diab3mmol=-8.
If any(-1,diabete2,iffcvala) diab3mmol=-1.
Value labels diab3mmol
1 "No diabetes"
2 "Doctor diagnosed diabetes"
3 "Undiagnosed diabetes HbA1c>=48mmol/l".
Variable label diab3mmol "(D) Diabetes from blood sample (48+mmol/mol) or doctor diagnosis (excluding pregnancy-only diabetes)".
missing values diab3mmol (-9,-8,-1).

compute diabete3=-11.
If (Glyhbval>0 & Glyhbval<6.5) & (diabete2=2) diabete3=1.
If (Glyhbval>0 & diabete2=1) diabete3=2.
If (Glyhbval>6.4) & (diabete2=2) diabete3=3.
If any(-9,diabete2) diabete3=-9.
If any(-8,diabete2) diabete3=-8.
If any(-1,diabete2) diabete3=-1.
Value labels diabete3
1 "No diabetes"
2 "Doctor diagnosed diabetes"
3 "Undiagnosed diabetes HbA1c>=6.5%".
Variable label diabete3 "(D) Diabetes from blood sample (>=6.5%) or doctor diagnosis (excluding pregnancy-only diabetes)".
missing values diabete3 (-9,-8,-1).

*CVD risk.
compute CVD_Risk=-2.
if (cigsta3>0) & (bmival2>0) & (highbp>0) & (diabete2>0) CVD_Risk=1.
VARIABLE LABELS CVD_Risk "(D) Valid information for CVD_Risk" .

compute psu99=psu.
EXECUTE.

STRING point1 (A8).
COMPUTE point1 = STRING(psu99, F7.0).
EXECUTE.

compute age_h=age.
EXECUTE.
if age>=90 age_h=92.
exe.
compute glyhb_h = glyhbval.
exe.
compute dimed_h = dimed.
exe.

compute year=2014.
save outfile = "TEMP\HSE2014RF.sav"
/keep hid id year sex age age_h ag16g10  origin2  marstatd
tenureb car numcars qimd imd_h
genhelf2 porfv
ill12m ill12m1 ill12m2 ill12m3
ill12m4 ill12m5 ill12m6 limlast 
diabete2 
bp1 VisMon
qrtint QrtNvis
wtval2 htval bmival2 
topqual3 cigsta3 genhelf genhelf2
gor  point1 wt_int wt_nurse wt_blood
omsysval omdiaval highbp cholval13 raised porfv
mintb vismon
bprespc sys1om sys2om sys3om omsysval 
dias1om dias2om dias3om
hy140om2 CVD_Risk
origin5 sclass12 sclass_h hhsize
complst1 complst2 complst3 complst4 complst5 complst6 complst7 complst8 complst9 complst10
complst11 complst12 complst13 complst14 complst15
waist1 waist2 waist3 wstval 
hip1 hip2 hip3 hipval whval urban_b medbp 
urban urban_b urban3 airtemp
marstatd mstatus_h medcnjd 
everbp everdi diabtype diabetes docbp area cluster 
pregnowb pregntj medtyp14  hdlval12 Hdlval1a
totinc eqvinc eqv5
srcin05c srcin08c srcin06c srcin07c srcin09c srcin10c
srcin12c srcin13c srcin14c alclimit07b totalwug totalwu
benefit1 benefit2 benefit3 benefit4 benefit5 benefit6 benefit7 benefit8 benefit9 nuroutc
bpmedd2 bpmedc2 bpmedd_h bpmedc_h
diabete3 diab3mmol ndoctalk whendoc  docmonth lipid2 lipid_h medtyp1 medtyp1_h insulin dimed_h ghq12scr
OutPat01 OutPat02 OutPat03 OutPat95 InPat dnnow dnany dnevr
ifcca1 iffcvala glyhbval glyhb_h glyhb2_h puls1om puls2om puls3om.

*2015 Special License.
*2015.

DATASET CLOSE ALL.
GET FILE='S:\FPHS_EPH_HSE_Shared\Expose\UKDA-8372-spss\spss\spss24\hse_2015_sl_v1_protect.sav'.
select if ag16g10>=1.
exe.
compute age_h=age90.
EXECUTE.
if age_h>=90 age_h=92.
exe.
**Household id.
compute hid=hserial.
EXECUTE.
formats hid(F10.0).
EXECUTE.
rename var (gor1 = gor).
EXECUTE.
formats gor(F8.2).
EXECUTE.
compute id=pserial.
EXECUTE.
formats id(F10.0).
exe.
compute imd_h=qimd.
formats imd_h(F8.2).
exe.
*marital status.
compute mstatus_h=-2.
if marstatd=1 mstatus_h=1.
if marstatd=2 mstatus_h=2.
if marstatd=3 mstatus_h=3.
if marstatd=4 mstatus_h=4.
if marstatd=5 mstatus_h=5.
if marstatd=6 mstatus_h=9.
var label mstatus_h "marital status harmonised".
val labels mstatus_h 1 "single" 2 "married" 3 "separated" 4 "divorced" 5 "widowed" 9 "cohabitees".

*Urban.
compute urban_b=-2.
if urban14b=1 urban_b=1.
if any(urban14b,2,3) urban_b=0.
var label urban_b "Binary urban".
val labels urban_b 0 "Not urban" 1 "Urban".
rename var (sclass hhsize6 = sclass12 hhsize).
EXECUTE.
*Social class.
compute sclass_h=-2.
if sclass12=1 sclass_h=1.
if sclass12=2 sclass_h=2.
if sclass12=3.1 sclass_h=3.
if sclass12=3.2 sclass_h=4.
if sclass12=4 sclass_h=5.
if sclass12=5 sclass_h=6.
val labels sclass_h 1 "I" 2 "II" 3 "IIIN" 4 "IIIM" 5 "IV" 6 "V".
*Minority ethnic group.
compute origin5=origin2.
*Ethnicity.
compute origin1=-2.
if any(origin2,1) origin1=1.
if any(origin2,2,3,4,5) origin1=0.
exe.
value labels origin1 0 "non-white" 1 "white".
exe.

*Talk to GP in last last month.
compute docmonth=-2.
if (ndoctalk=1) & (whendoc<0) docmonth=1.
if (ndoctalk=1) & (whendoc=1) docmonth=1.
if (ndoctalk=1) & any(whendoc,2,3,4,5,6) docmonth=0.
if (ndoctalk=2) & whendoc=1 docmonth=1.
if (ndoctalk=2) & any(whendoc,2,3,4,5,6) docmonth=0.
variable label docmonth "Talk to GP in last month".
value labels docmonth 0 "No" 1 "Yes".

*BMI.
compute bmivg52=-2.
if range(bmival2,0,18.4999) bmivg52=0.
if range(bmival2,18.5,24.9999) bmivg52=1.
if range(bmival2,25.000,29.9999) bmivg52=2.
if range(bmival2,30,34.9999) bmivg52=3.
if range(bmival2,35,100) bmivg52=4.
EXECUTE.
value labels bmivg52 0 "Underweight" 1 "Normal-weight" 2 "Overweight" 3 "Obese I" 4 "Obese II".

*Smoke.
compute smoke=-2.
if (cigsta3=2|cigsta3=3) smoke=0.
if cigsta3=1 smoke=1.
value labels smoke 0 "Non-smoke" 1 "Smoke".
EXECUTE.

*Alcohol.
*weekly
recode totalwug (0=0) (1 thru 4=1) (5=2) (6 thru 7=3) (8=4) (9=5) (else=copy).
exe.
*Benefits.
compute benefit1=srcin05c.
compute benefit2=srcin08c.
compute benefit3=srcin06c.
compute benefit4=srcin07c.
compute benefit5=srcin09c.
compute benefit6=srcin10c.
compute benefit7=srcin12c.
compute benefit8=srcin13c.
compute benefit9=srcin14c.
exe
    
*Hypertension.
compute highbp=hy140om2.
VALUE LABELS highbp 1 'Normotensive untreated' 
2 'Normotensive treated' 
3 'Hypertensive treated' 
4 'Hypertensive untreated'.
exe.

compute bpmedd_h=bpmedd2.
compute bpmedc_h=bpmedc2.
EXECUTE.
compute cholest2=cholest - 0.1.
EXECUTE.
compute cholval13=cholest2.
EXECUTE.

compute raised=-2.
if range(cholest2,0,4.9) raised=0.
if cholest2>4.9 raised=1.
EXECUTE.
compute lipid_h=lipid2.
EXECUTE.

*CVD med.
compute medtyp1_h=-2.
if (medtyp1=0) medtyp1_h=0.
if (medtyp1=1) medtyp1_h=1.
val labels medtyp1_h 0 "not on CVDmed" 1 "CVDmed".

*Diabetes.
compute diab3mmol=-11.
If (iffcvala>0 & iffcvala<48) & (diabete2=2) diab3mmol=1.
If (iffcvala>0 & diabete2=1) diab3mmol=2.
If (iffcvala>=48) & (diabete2=2) diab3mmol=3.
If any(-9,diabete2,iffcvala) diab3mmol=-9.
If any(-8,diabete2,iffcvala) diab3mmol=-8.
If any(-1,diabete2,iffcvala) diab3mmol=-1.
Value labels diab3mmol
1 "No diabetes"
2 "Doctor diagnosed diabetes"
3 "Undiagnosed diabetes HbA1c>=48mmol/l".
Variable label diab3mmol "(D) Diabetes from blood sample (48+mmol/mol) or doctor diagnosis (excluding pregnancy-only diabetes)".
missing values diab3mmol (-9,-8,-1).
compute glyhb2_h = iffcvala.
exe.

*CVD risk.
compute CVD_Risk=-2.
if (cigsta3>0) & (bmival2>0) & (highbp>0) & (diabete2>0) CVD_Risk=1.
VARIABLE LABELS CVD_Risk "(D) Valid information for CVD_Risk" .

compute psu99=psu.
EXECUTE.
STRING point1 (A8).
COMPUTE point1 = STRING(psu99, F7.0).
EXECUTE.

compute glyhb_h = glyhbvala.
exe.
missing values dimed ().
EXECUTE.
compute dimed_h = dimed.
exe.

compute year=2015.
save outfile = "TEMP\HSE2015RF.sav"
/keep id hid year sex age_h age90 Age16g5 ag16g10 
origin2  marstatd
tenureb car numcars qimd imd_h
cholval13
genhelf2 porfv15 porftvg15
ill12m limlast 
diabete2 bp1 MVPAmWk
bp1 
wtval2 htval bmival2 
topqual3 cigsta3 genhelf genhelf2
gor point1 wt_int wt_nurse wt_blood
omsysval omdiaval highbp porfv15
qrtint qrtnvis
bprespc sys1om sys2om sys3om omsysval 
dias1om dias2om dias3om
hy140om2  CVD_Risk
origin5 sclass12 sclass_h hhsize
complst1 complst2 complst3 complst4 complst5 complst6 complst7 complst8 complst9 complst10
complst11 complst12 complst13 complst14 complst15
waist1 waist2 waist3 wstval 
hip1 hip2 hip3 hipval whval urban_b medbp 
urban14b urban_b airtemp
ill12m ill12m1 ill12m2 ill12m3
ill12m4 ill12m5 ill12m6 limlast
marstatd mstatus_h medcnjd everbp everdi diabtype diabetes docbp psu cluster cluster_adults 
pregnowb pregntj medtyp14  Hdlval1a totinc eqvinc eqv5
srcin05c srcin08c srcin06c srcin07c srcin09c srcin10c
srcin12c srcin13c srcin14c alclimit07b totalwug totalwu
benefit1 benefit2 benefit3 benefit4 benefit5 benefit6 benefit7 benefit8 benefit9 nuroutc 
bpmedd2 bpmedc2 bpmedd_h bpmedc_h
iffcvala  diab3mmol ndoctalk whendoc  docmonth lipid2 lipid_h medtyp1 medtyp1_h insulin dimed_h
OutPat01 OutPat02 OutPat03 OutPat95 InPat dnnow dnany dnevr
glyhb glyhbvala glyhb_h glyhb2_h ifcca1 iffcvala puls1om puls2om puls3om
/rename (porftvg15 = porftvg).


* 2016.

DATASET CLOSE All.
GET FILE='BASE_DIRECTORY\hse2016_eul.sav'.
missing values all ().
select if ag16g10>=1.
exe.
*midpoint.
compute age_h=-99.
if (age16g5=1) age_h=16.5.
if (age16g5=2) age_h=18.5.
if (age16g5=3) age_h=22.
if (age16g5=4) age_h=27.
if (age16g5=5) age_h=32.
if (age16g5=6) age_h=37.
if (age16g5=7) age_h=42.
if (age16g5=8) age_h=47.
if (age16g5=9) age_h=52.
if (age16g5=10) age_h=57.
if (age16g5=11) age_h=62.
if (age16g5=12) age_h=67.
if (age16g5=13) age_h=72.
if (age16g5=14) age_h=77.
if (age16g5=15) age_h=82.
if (age16g5=16) age_h=87.
if (age16g5=17) age_h=92.
EXECUTE.
missing values all ().
exe.
compute id=seriala.
EXECUTE.
formats id(F10.0).
exe.
rename var (gor1 sclass hhsize6 tenureb2 = gor sclass12 hhsize tenureb).
EXECUTE.
formats gor(F8.2).
EXECUTE.
compute imd_h=qimd.
formats imd_h(F8.2).
exe.
*marital status.
compute mstatus_h=-2.
if marstatd=1 mstatus_h=1.
if marstatd=2 mstatus_h=2.
if marstatd=3 mstatus_h=3.
if marstatd=4 mstatus_h=4.
if marstatd=5 mstatus_h=5.
if marstatd=6 mstatus_h=9.
var label mstatus_h "marital status harmonised".
val labels mstatus_h 1 "single" 2 "married" 3 "separated" 4 "divorced" 5 "widowed" 9 "cohabitees".

*Urban.
compute urban_b=-2.
if urban14b=1 urban_b=1.
if any(urban14b,2,3) urban_b=0.
var label urban_b "Binary urban".
val labels urban_b 0 "Not urban" 1 "Urban".
*Social class.
compute sclass_h=-2.
if sclass12=1 sclass_h=1.
if sclass12=2 sclass_h=2.
if sclass12=3.1 sclass_h=3.
if sclass12=3.2 sclass_h=4.
if sclass12=4 sclass_h=5.
if sclass12=5 sclass_h=6.
val labels sclass_h 1 "I" 2 "II" 3 "IIIN" 4 "IIIM" 5 "IV" 6 "V".
*Minority ethnic group.
compute origin5=origin2.
*Ethnicity.
compute origin1=-2.
if any(origin2,1) origin1=1.
if any(origin2,2,3,4,5) origin1=0.
exe.
value labels origin1 0 "non-white" 1 "white".
*BMI.
compute bmivg52=-2.
if range(bmival2,0,18.4999) bmivg52=0.
if range(bmival2,18.5,24.9999) bmivg52=1.
if range(bmival2,25.000,29.9999) bmivg52=2.
if range(bmival2,30,34.9999) bmivg52=3.
if range(bmival2,35,100) bmivg52=4.
EXECUTE.
value labels bmivg52 0 "Underweight" 1 "Normal-weight" 2 "Overweight" 3 "Obese I" 4 "Obese II".

*Smoke.
compute smoke=-2.
if (cigsta3=2|cigsta3=3) smoke=0.
if cigsta3=1 smoke=1.
value labels smoke 0 "Non-smoke" 1 "Smoke".
EXECUTE.

*Alcohol.
*weekly.
recode totalwug (0=0) (1 thru 4=1) (5=2) (6 thru 7=3) (8=4) (9=5) (else=copy).
exe.
*Benefits.
compute benefit1=srcin05d.
compute benefit2=srcin08d.
compute benefit3=srcin06d.
compute benefit4=srcin07d.
compute benefit5=srcin09d.
compute benefit6=srcin10d.
compute benefit7=srcin12d.
compute benefit8=srcin13d.
compute benefit9=srcin15d.
compute benefit10=srcin14d.
exe.

*Hypertension.
compute highbp=hy140om2.
VALUE LABELS highbp 1 'Normotensive untreated' 
2 'Normotensive treated' 
3 'Hypertensive treated' 
4 'Hypertensive untreated'.
exe.
compute bpmedd_h=bpmedd2.
compute bpmedc_h=bpmedc2.
EXECUTE.

*Cholesterol.
compute cholest2=cholest - 0.1.
EXECUTE.
compute cholval13=cholest2.
EXECUTE.
compute raised=-2.
if range(cholest2,0,4.9) raised=0.
if cholest2>4.9 raised=1.
EXECUTE.
compute lipid_h=lipid2.
EXECUTE.

*CVD med.
compute medtyp1_h=-2.
if (medtyp1=0) medtyp1_h=0.
if (medtyp1=1) medtyp1_h=1.
val labels medtyp1_h 0 "not on CVDmed" 1 "CVDmed".

*Diabetes.
compute diab3mmol=-11.
If (iffcvala>0 & iffcvala<48) & (diabete2=2) diab3mmol=1.
If (iffcvala>0 & diabete2=1) diab3mmol=2.
If (iffcvala>=48) & (diabete2=2) diab3mmol=3.
If any(-9,diabete2,iffcvala) diab3mmol=-9.
If any(-8,diabete2,iffcvala) diab3mmol=-8.
If any(-1,diabete2,iffcvala) diab3mmol=-1.
Value labels diab3mmol
1 "No diabetes"
2 "Doctor diagnosed diabetes"
3 "Undiagnosed diabetes HbA1c>=48mmol/l".
Variable label diab3mmol "(D) Diabetes from blood sample (48+mmol/mol) or doctor diagnosis (excluding pregnancy-only diabetes)".
missing values  diab3mmol (-9,-8,-1).

compute glyhb2_h = iffcvala.
exe.

*CVD risk.
compute CVD_Risk=-2.
if (cigsta3>0) & (bmival2>0) & (highbp>0) & (diabete2>0) CVD_Risk=1.
VARIABLE LABELS CVD_Risk "(D) Valid information for CVD_Risk" .

compute psu99=psu.
EXECUTE.
STRING point1 (A8).
COMPUTE point1 = STRING(psu99, F7.0).
EXECUTE.
compute glyhb_h = glyhbvala.
exe.
compute dimed_h = dimed.
exe.
compute year=2016.
save outfile = "TEMP\HSE2016RF.sav"
/keep id year sex Age16g5 ag16g10 age_h
origin2 marstatd
tenureb car numcars qimd imd_h
cholval13
genhelf2 porfv15 porftvg15
ill12m limlast 
diabete2 
bp1 
wtval2 htval bmival2 
topqual3 cigsta3 genhelf genhelf2
gor point1 wt_int wt_nurse wt_blood
omsysval omdiaval highbp porfv15 a30t06c
qrtint qrtnvis 
bprespc sys1om sys2om sys3om omsysval 
dias1om dias2om dias3om
hy140om2 CVD_Risk
origin5 sclass12 sclass_h hhsize
complst1 complst2 complst3 complst4 complst5 complst6 complst7 complst8 complst9 complst10
complst11 complst12 complst13 complst14 complst15
waist1 waist2 waist3 wstval 
hip1 hip2 hip3 hipval whval urban_b 
urban14b urban_b airtemp
marstatd mstatus_h medcnjd everbp everdi diabtype diabetes docbp psu cluster iffcvala
pregnowb pregntj medtyp14 a30t06c GlyHb Hdlval1a eqv5
srcin05d srcin08d srcin06d srcin07d
srcin09d srcin10d srcin12d srcin13d srcin15d srcin14d alclimit07b totalwug totalwu
benefit1 benefit2 benefit3 benefit4 benefit5 benefit6 benefit7 benefit8 benefit9 benefit10 nuroutc
bpmedd2 bpmedc2 bpmedd_h bpmedc_h
 diab3mmol diabete3 lipid2 lipid_h medtyp1 medtyp1_h insulin dimed_h ghq12scr dnnow dnany dnevr
 ifcca1 iffcvala glyhb glyhbvala glyhb_h glyhb2_h puls1om puls2om puls3om
/rename (porftvg15 = porftvg).




*2017.
DATASET CLOSE All.
GET FILE='BASE_DIRECTORY\hse17i_eul_v1.sav'.
missing values all ().
exe.
select if ag16g10>=1.
exe.
compute age_h=-99.
if (age16g5=1) age_h=16.5.
if (age16g5=2) age_h=18.5.
if (age16g5=3) age_h=22.
if (age16g5=4) age_h=27.
if (age16g5=5) age_h=32.
if (age16g5=6) age_h=37.
if (age16g5=7) age_h=42.
if (age16g5=8) age_h=47.
if (age16g5=9) age_h=52.
if (age16g5=10) age_h=57.
if (age16g5=11) age_h=62.
if (age16g5=12) age_h=67.
if (age16g5=13) age_h=72.
if (age16g5=14) age_h=77.
if (age16g5=15) age_h=82.
if (age16g5=16) age_h=87.
if (age16g5=17) age_h=92.
EXECUTE.
compute id=seriala.
EXECUTE.
formats id(F10.0).
EXECUTE.

rename var (gor1 sclass hhsize6 = gor sclass12 hhsize).
EXECUTE.
formats gor(F8.2).
EXECUTE.
compute imd_h=qimd.
formats imd_h(F8.2).
exe.
*marital status.
compute mstatus_h=-2.
if marstatd=1 mstatus_h=1.
if marstatd=2 mstatus_h=2.
if marstatd=3 mstatus_h=3.
if marstatd=4 mstatus_h=4.
if marstatd=5 mstatus_h=5.
if marstatd=6 mstatus_h=9.
var label mstatus_h "marital status harmonised".
val labels mstatus_h 1 "single" 2 "married" 3 "separated" 4 "divorced" 5 "widowed" 9 "cohabitees".

*Urban.
compute urban_b=-2.
if urban14br=1 urban_b=1.
if any(urban14br,2,3) urban_b=0.
var label urban_b "Binary urban".
val labels urban_b 0 "Not urban" 1 "Urban".
*Social class.
compute sclass_h=-2.
if sclass12=1 sclass_h=1.
if sclass12=2 sclass_h=2.
if sclass12=3.1 sclass_h=3.
if sclass12=3.2 sclass_h=4.
if sclass12=4 sclass_h=5.
if sclass12=5 sclass_h=6.
val labels sclass_h 1 "I" 2 "II" 3 "IIIN" 4 "IIIM" 5 "IV" 6 "V".

rename variables (CVD1 CVD2 CVD3 CVD4 CVD5 CVD6 CVD7 CVD8 cdiabete = everbp everangi everhart evermur everireg everoht everstro everdi docinfo1).
exe.
*Minority ethnic group.
compute origin5=origin2.
*Ethnicity.
compute origin1=-2.
if any(origin2,1) origin1=1.
if any(origin2,2,3,4,5) origin1=0.
exe.
value labels origin1 0 "non-white" 1 "white".
*BMI.
compute bmivg52=-2.
if range(bmival2,0,18.4999) bmivg52=0.
if range(bmival2,18.5,24.9999) bmivg52=1.
if range(bmival2,25.000,29.9999) bmivg52=2.
if range(bmival2,30,34.9999) bmivg52=3.
if range(bmival2,35,100) bmivg52=4.
EXECUTE.
value labels bmivg52 0 "Underweight" 1 "Normal-weight" 2 "Overweight" 3 "Obese I" 4 "Obese II".

*Smoke.
compute smoke=-2.
if (cigsta3=2|cigsta3=3) smoke=0.
if cigsta3=1 smoke=1.
value labels smoke 0 "Non-smoke" 1 "Smoke".
EXECUTE.

*Benefits.
compute benefit1=srcin05d.
compute benefit2=srcin08d.
compute benefit3=srcin06d.
compute benefit4=srcin07d.
compute benefit5=srcin09d.
compute benefit6=srcin10d.
compute benefit7=srcin12d.
compute benefit8=srcin13d.
compute benefit9=srcin15d.
compute benefit10=srcin14d.
exe.

*Hypertension.
compute highbp=hy140om2.
VALUE LABELS highbp 1 'Normotensive untreated' 
2 'Normotensive treated' 
3 'Hypertensive treated' 
4 'Hypertensive untreated'.
compute bpmedd_h=bpmedd2.
compute bpmedc_h=bpmedc2.
EXECUTE.

*Cholesterol.
compute raised=-2.
if range(cholval13,0,4.9) raised=0.
if cholval13>4.9 raised=1.
exe.
compute lipid_h=lipid2.
EXECUTE.

*CVD med.
compute medtyp1_h=-2.
if (medtyp1=0) medtyp1_h=0.
if (medtyp1=1) medtyp1_h=1.
val labels medtyp1_h 0 "not on CVDmed" 1 "CVDmed".

*CVD risk.
compute CVD_Risk=-2.
if (cigsta3>0) & (bmival2>0) & (highbp>0) & (diabete2>0) CVD_Risk=1.
VARIABLE LABELS CVD_Risk "(D) Valid information for CVD_Risk" .

compute psu99=psu.
EXECUTE.
STRING point1 (A8).
COMPUTE point1 = STRING(psu99, F7.0).
EXECUTE.

*Diagnosed BP (regardless of diagnosed only if pregnant; missing not coded as no).
compute diag_hbp_h=-99.
if everbp=2|docbp=2 diag_hbp_h=0.
if everbp=1 & (docbp=1) diag_hbp_h=1.
value labels diag_hbp_h 0 "No" 1 "Yes".
fre diag_hbp_h.

*Diagnosed stroke (missing not coded as no).
compute diag_stroke_h=-99.
if everstro=2|docstro=2 diag_stroke_h=0.
if everstro=1 & (docstro=1) diag_stroke_h=1.
value labels diag_stroke_h 0 "No" 1 "Yes".
fre diag_stroke_h.

*Diagnosed angina (regardless of diagnosed only if pregnant; missing not coded as no).
compute diag_angi_h=-99.
if everangi=2|docangi=2 diag_angi_h=0.
if everangi=1 & (docangi=1) diag_angi_h=1.
value labels diag_angi_h 0 "No" 1 "Yes".
fre diag_angi_h.   

*Diagnosed MI (regardless of diagnosed only if pregnant; missing not coded as no).
compute diag_mi_h=-99.
if everhart=2|docheart=2 diag_mi_h=0.
if everhart=1 & (docheart=1) diag_mi_h=1.
value labels diag_mi_h 0 "No" 1 "Yes".
fre diag_mi_h.  

*Diagnosed diabetes (regardless of diagnosed only if pregnant; missing not coded as no).
compute diag_diab_h=-99.
if everdi=2|docinfo1=2 diag_diab_h=0.
if everdi=1 & (docinfo1=1) diag_diab_h=1.
value labels diag_diab_h 0 "No" 1 "Yes".
fre diag_diab_h. 
 
*Ischaemic heart disease.
compute diag_isch_h=-99.
if (diag_mi_h=0 & diag_angi_h=0) diag_isch_h=0.
if (diag_mi_h=1 | diag_angi_h=1) diag_isch_h=1.
value labels diag_isch_h 0 "No" 1 "Yes".

compute glyhb_h = glyhbvala.
exe.
compute glyhb2_h = iffcvala.
exe.
compute dimed_h = dimed.
exe.

compute year=2017.
save outfile = "TEMP\HSE2017RF.sav"
/keep id year 
psu cluster cluster_nurse cluster_blood 
sex Age16g5 ag16g10 age_h
origin2 marstatd
tenureb car numcars qimd imd_h
cholest
genhelf2 porfv15 porftvg15
ill12m limlast 
diabete2 MVPAmWk
bp1 
wtval2 htval bmival2 
topqual3 cigsta3 genhelf genhelf2 
gor point1 wt_int wt_nurse wt_blood
omsysval omdiaval highbp cholval13 HDLChol Hdlval1a raised 
qrtint qrtnvis 
bprespc sys1om sys2om sys3om omsysval 
dias1om dias2om dias3om
hy140om2 CVD_Risk
origin5 sclass12 sclass_h hhsize
complst1 complst2 complst3 complst4 complst5 complst6 complst7 complst8 complst9 complst10
complst11 complst12 complst13 complst14 complst15
waist1 waist2 waist3 wstval 
hip1 hip2 hip3 hipval whval 
medbp 
urban14br urban_b airtemp
everbp everangi everhart evermur everireg everoht everstro everdi
strodef angidef heartdef murmur1 iregdef ohtdef
docstro docangi docheart murdoc docireg docinfo1 docoht bp1
marstatd mstatus_h medcnjd ihdis cvdis diabtype docbp 
pregnowb pregntj 
medtyp14  eqv5
srcin05d srcin08d srcin06d srcin07d srcin09d
srcin10d srcin12d srcin13d srcin15d srcin14d alclimit07b totalwu totalwug2
benefit1 benefit2 benefit3 benefit4 benefit5 benefit6 benefit7 benefit8 benefit9 benefit10 nuroutc
bpmedd2 bpmedc2 bpmedd_h bpmedc_h
diabete3 diab3mmol lipid2 lipid_h medtyp1 medtyp1_h medheart cinsulin dimed_h
diag_hbp_h diag_stroke_h diag_angi_h diag_mi_h diag_diab_h diag_isch_h dnnow dnany dnevr
ifcca1 iffcvala glyhb glyhbvala glyhb_h glyhb2_h puls1om puls2om puls3om 
/rename (totalwug2 cinsulin porftvg15 =totalwug insulin porftvg).



*Put the datasets together.

dataset close all.
get file = "N:\Temp\HSE1998RF.sav".
add files/file=*/file = "N:\Temp\HSE2001RF.sav".
add files/file=*/file= "N:\Temp\HSE2002RF.sav".
add files/file=*/file= "N:\Temp\HSE2003RF.sav".
add files/file=*/file= "N:\Temp\HSE2005RF.sav".
add files/file=*/file= "N:\Temp\HSE2006RF.sav".
add files/file=*/file= "N:\Temp\HSE2007RF.sav".
add files/file=*/file= "N:\Temp\HSE2008RF.sav".
add files/file=*/file= "N:\Temp\HSE2009RF.sav".
add files/file=*/file= "N:\Temp\HSE2010RF.sav".
add files/file=*/file= "N:\Temp\HSE2011RF.sav".
add files/file=*/file= "N:\Temp\HSE2012RF.sav".
add files/file=*/file= "N:\Temp\HSE2013RF.sav".
add files/file=*/file= "N:\Temp\HSE2014RF.sav".
add files/file=*/file= "N:\Temp\HSE2015RF.sav".
add files/file=*/file= "N:\Temp\HSE2016RF.sav".
add files/file=*/file= "N:\Temp\HSE2017RF.sav".
add files/file=*/file= "N:\Temp\HSE2018RF.sav".
add files/file=*/file= "N:\Temp\HSE2019RF.sav".
exe.

*number of cars.
if car=2 numcars=0.
exe.

*BPmedicine.
compute BPmed=-2.
if any(highbp,1,4) BPmed=0.
if any(highbp,2,3) BPmed=1.
VARIABLE LABELS  BPmed "(D) Prescribed drugs for high BP" .
VALUE LABELS  BPmed 0 "No" 1 "Yes".

VARIABLE LABELS  
benefit1 "Jobseekers Allowance" 
benefit2 "Pension Credit" 
benefit3 "Employment and support" 
benefit4 "Income support" 
benefit5 "Family Credit" 
benefit6 "Child tax credit" 
benefit7 "Housing benefit" 
benefit8 "Council Tax benefit" 
benefit9 "Other state benefit" 
benefit10 "Universal credit".

value labels imd_h 1 "least deprived" 2 "2" 3 "3" 4 "4" 5 "most deprived".
exe.
value labels dimed_h 1 "Yes" 2 "No".
exe.
variable label diag_hbp_h "Diagnosed high bp".
variable label diag_stroke_h "Diagnosed stroke".
variable label diag_angi_h "Diagnosed angina".
variable label diag_mi_h "Diagnosed MI".
variable label diag_diab_h "Diagnosed diabetes".
variable label diag_isch_h "Diagnosed IHD".
variable label bpmedd_h "Taking BP medications for stated high bp".
variable label bpmedc_h "Taking BP medications".
variable label dimed_h "medications for diabetes".
variable label dimed_h "medications for CVD".
variable label lipid_h "lipids".
variable label glyhb_h "hba1c in %".
variable label glyhb2_h "hba1c in mmol/mol".

SAVE TRANSLATE OUTFILE='OUT\HSE1998-2017.dta'
  /TYPE=STATA
  /VERSION=14
  /EDITION=SE
  /MAP
  /REPLACE
  /keep id hid point1 year mintb vismon qrtint qrtnvis
wt_int wt_int_s1 wt_int_s2 
wt_nurse wt_nurse_s1 wt_nurse_s2
wt_blood wt_blood_s1 wt_blood_s2
CVD_risk sex age_h gor imd_h hhsize
  tenureb urban_b numcars mstatus_h
  origin5 sclass_h topqual3 eqv5
cigsta3 porftvg 
alclimit07b totalwug totalwu a30t06c
genhelf longill ill12m limitill limlast
illsm1 illsm2 illsm3 illsm4 illsm5 illsm6
ill12m1 ill12m2 ill12m3 ill12m4 ill12m5 ill12m6 ghq12scr
compm1 compm2 compm3 compm4 compm5 
compm6 compm7 compm8  compm9  compm10 
compm11 compm12  compm13  compm14  compm15 
complst1 complst2 complst3 complst4 complst5
complst6 complst7 complst8 complst9 complst10
complst11 complst12 complst13 complst14 complst15
ghq12scr
benefit1 benefit2 benefit3 benefit4 benefit5
benefit6 benefit7 benefit8 benefit9 benefit10
diag_hbp_h diag_stroke_h diag_angi_h diag_mi_h diag_diab_h diag_isch_h
everbp everstro everangi everhart evermur everireg everoht everdi
bp1 strodef angidef heartdef murmur1 iregdef ohtdef diabete2 ihdis cvdis
docnurbp docbp docstro docangi docheart murdoc docireg docinfo1 diabetes docoht
docmonth ndoctalk whendoc inpat outpat outpat01 outpat02 outpat03 outpat95
pregnowb pregntj pill3 pillevr pilluse medtyp14
htval wtval2 bmival2
wstval waist1 waist2 waist3
hipval hip1 hip2 hip3 whval
highbp bpmedd_h bpmedc_h
omsysval sys1om  sys2om sys3om
omdiaval dias1om dias2om dias3om
airtemp cholval13 hdlval1a
medheart insulin dimed_h medtyp1_h lipid_h
age age90 ag16g10 age16g5
totinc eqvinc diabtype
medcinbp medbp medcnjd bpmedd bpmedd2 dnnow dnany dnevr
glyhbval glyhbvala glyhb glyhb_h glyhb2_h 
ifcca1 iffcvala
sclass sclass12 car wt_intEL
wt_nurEL
wt_bldEL
wt_int samptype pulse1 pulse2 pulse3
puls1om puls2om puls3om.


    












