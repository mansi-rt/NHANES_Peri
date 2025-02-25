/*************
**************
DATA CLEANING

for dietary markers (vit-A, C, E)  
     ues weight WTDRd1_14yr;

for lab markers (such as LBDSTBSI, LBDFERSI)
   weight wtmec14yr;

**************
*************/;


/************

## master data files 
  p1.hpv_ms
  p1.hpv_ms_v2 (2/7/2020, LinHY add Demo files)
  p1.hpv_ms_log (add log transformation to markers)
  p1.hpv_ms_v3 (3/24/2020, add sexual and drug)
  p1.hpv_ms_v4 (5/27/2020, add alcohol intake, smoking, general health and mental health)
  p1.hpv_ms_v5 (, add VD, folate)
  p1.hpv_ms_v6 (10/6/2020, revised cutpoint for 3-level markers)
*************/


/*Revise note: add DRITOTC/.../I AND DR2TOTC/.../I for vitamin data */


/****************
Title: antioxidant vs. HPV (vaginal & serum antibody) 
Data source: NHANES 2003-2016

data:
<<antioxidant data>>
    1. BILIRUBIN
    2. FERRITIN 
    3. ALBUMIN
    4. UIRC ACID

    5. VA
    6. VB2    
    7. VC 
    8. VE
    9. ALPHA-CAROTENE
    10. SELENIUM
    11. LYCOPENE
    12. LUTEIN+ZEAXANTHIN
    13. BETA-CRYPTOXANTHIN
    14. VD
    15. FOLATE


***********/;
libname NH "T:\LinHY_project\NHANES\antioxidant\qfu\data";      
libname h 'T:\LinHY_project\NHANES\antioxidant\data';

libname r 'T:\LinHY_project\NHANES\antioxidant\data\download'; 
libname p 'T:\LinHY_project\NHANES\antioxidant\data';
libname r1 'T:\LinHY_project\NHANES\antioxidant\qfu\rawData'; 
libname p1 'T:\LinHY_project\NHANES\antioxidant\qfu\proData';

libname d2 'O:\yi2015\NHANES\HPV_NHANES\data';


/*
proc print data=hpv_ms_log(obs=10);
var vit_A ln_vit_A;
run;
*/


/**

_C: 2003-04
_D: 2005-06

_E: 2007-08
_F: 2009-10
_G: 2011-12
_H: 2013-14
_I: 2015-16

****/;

/***
******************Create a master file for NHANES 2003-2016**************

Bilirubin: 03-16
Ferritin: 03-10 15-16
Albumin: 03-16(L40_C & BIOPRO_D/…/I: LBDSALSI LBXSAL||||| L16_C + ALB_CR_D/…/I: URXUMA URXUMASI) 03-04(SSAG_R)
           09-16(URDACT) 09-10(URDACT2 URDUMA2S URXUMA2) 15-16(URDUMALC)
Uric acid: 03-16 (L40_C & BIOPRO_D/…/I: LBDSUASI LBXSUA)




ALL BELOW FROM "DR1TOT_C/.../I & DR2TOT_C/.../I"

Va: DR1TVARA DR2IVARA
Vb2: DR1TVB2 DR2TVB2
Vc: DR1TVC DR2TVC
Ve: DR1TATOA DR2TATOA DR1TATOC DR2TATOC
Alpha-carotene: DR1TACAR DR2TACAR
Selenium: DR1TSELE DR2TSELE
Lycopene: DR1TLYCO DR2TLYCO
Lutein + zeaxanthin: DR1TLZ DR2TLZ
Beta-cryptoxanthin: DR1TCRYP DR2TCRYP





  
*****/;


%macro trans(dname);
libname r xport "T:\LinHY_project\NHANES\antioxidant\data\download\&dname..xpt"; 
 proc copy in=r out=p; 
 run;
%mend trans;


%macro trans1(dname);
libname r1 xport "T:\LinHY_project\NHANES\antioxidant\qfu\rawData\&dname..xpt"; 
 proc copy in=r1 out=p1; 
 run;
%mend trans1;
/** 
2/7/2020 LinHY
Demo (2003-2016 ***/

%trans1(DEMO_C);
%trans1(DEMO_D);
%trans1(DEMO_E);
%trans1(DEMO_F);
%trans1(DEMO_G);
%trans1(DEMO_H);
%trans1(DEMO_I);


data demo_0316;
set p1.DEMO_C p1.DEMO_D p1.DEMO_E p1.DEMO_F p1.DEMO_G p1.DEMO_H p1.DEMO_I;  
run;


/*height&weight (2003-2016 ***/

%trans1(WHQ_C);
%trans1(WHQ_D);
%trans1(WHQ_E);
%trans1(WHQ_F);
%trans1(WHQ_G);
%trans1(WHQ_H);
%trans1(WHQ_I);


data p1.WHQ_0316;
set p1.WHQ_C p1.WHQ_D p1.WHQ_E p1.WHQ_F p1.WHQ_G p1.WHQ_H p1.WHQ_I;  
run;



/****
Bilirubin (2003-16) 
 ***/;
%trans1(L40_C)
%trans1(BIOPRO_D);
%trans1(BIOPRO_E);
%trans1(BIOPRO_F);
%trans1(BIOPRO_G);
%trans1(BIOPRO_H);
%trans1(BIOPRO_I);

/****
Ferritin (2003-2010, 2015-16 (no 2011-14)
 ***/
%trans1(L06TFR_C);
%trans1(FERTIN_D);
%trans1(FERTIN_E);
%trans1(FERTIN_F);
%trans1(FERTIN_I);

/****
Albumin(2003-16) 

Albumin(03-16): LBDSALSI LBXSAL

***/
%trans1(L16_C);
%trans1(ALB_CR_D);
%trans1(ALB_CR_E);
%trans1(ALB_CR_F);
%trans1(ALB_CR_G);
%trans1(ALB_CR_H);
%trans1(ALB_CR_I);


/****
Nutritional antioxidant day1
***/
%trans1(DR1TOT_C);
%trans1(DR1TOT_D);
%trans1(DR1TOT_E);
%trans1(DR1TOT_F);
%trans1(DR1TOT_G);
%trans1(DR1TOT_H);
%trans1(DR1TOT_I);


/****
Nutritional antioxidant day2
***/
%trans1(DR2TOT_C);
%trans1(DR2TOT_D);
%trans1(DR2TOT_E);
%trans1(DR2TOT_F);
%trans1(DR2TOT_G);
%trans1(DR2TOT_H);
%trans1(DR2TOT_I);



/****
Vaccine
***/
%trans1(IMQ_E);
%trans1(IMQ_F);
%trans1(IMQ_G);
%trans1(IMQ_H);
%trans1(IMQ_I);




/*Combine selected datasets: */


/*Variables included: 
1) Bilirubin(03-16): LBDSTBSI
2) Albumin(03-16): LBDSALSI LBXSAL
3) 
4) Uric acid: LBDSUASI LBXSUA

5) Va: DR1TVARA DR2IVARA
6) Vb2: DR1TVB2 DR2TVB2
7) Vc: DR1TVC DR2TVC
8) Ve: DR1TATOA DR2TATOA DR1TATOC DR2TATOC
9) Alpha-carotene: DR1TACAR DR2TACAR
10)Selenium: DR1TSELE DR2TSELE
11)Lycopene: DR1TLYCO DR2TLYCO
12)Lutein + zeaxanthin: DR1TLZ DR2TLZ
13)Beta-cryptoxanthin: DR1TCRYP DR2TCRYP
*/
data biop_0316;
 set p1.L40_C p1.BIOPRO_D p1.BIOPRO_E p1.BIOPRO_F p1.BIOPRO_G p1.BIOPRO_H p1.BIOPRO_I;
 run;


/*Variables included: 
1) Ferritin[2003-2010, 2015-16 (no 2011-14)]: LBDFERSI */;

data fer_0316;
set p1.L06TFR_C p1.FERTIN_D p1.FERTIN_E p1.FERTIN_F p1.FERTIN_I;
run;

/*
data fer_0310;
set p1.L06TFR_C p1.FERTIN_D p1.FERTIN_E p1.FERTIN_F;
run;
*/

/*Variables included: 
1) Albumin(03-16): URXUMA*/

data alb_0316;
set p1.L16_C p1.ALB_CR_D p1.ALB_CR_E p1.ALB_CR_F p1.ALB_CR_G p1.ALB_CR_H p1.ALB_CR_I; 
run;



/****
Vaccine
***/
data vac_0716;
set p1.IMQ_E p1.IMQ_F p1.IMQ_G p1.IMQ_H p1.IMQ_I;
RUN;










/*Variables included: 
1) Va: DR1TVARA DR2IVARA
2) Vb2: DR1TVB2 DR2TVB2
3) Vc: DR1TVC DR2TVC
4) Ve: DR1TATOA DR2TATOA DR1TATOC DR2TATOC
5) Alpha-carotene: DR1TACAR DR2TACAR
6) Selenium: DR1TSELE DR2TSELE
7) Lycopene: DR1TLYCO DR2TLYCO
8) Lutein + zeaxanthin: DR1TLZ DR2TLZ
9) Beta-cryptoxanthin: DR1TCRYP DR2TCRYP*/

data nutr1_0316;
set p1.DR1TOT_C p1.DR1TOT_D p1.DR1TOT_E p1.DR1TOT_F p1.DR1TOT_G p1.DR1TOT_H p1.DR1TOT_I; 
run;

data nutr2_0316;
set p1.DR2TOT_C p1.DR2TOT_D p1.DR2TOT_E p1.DR2TOT_F p1.DR2TOT_G p1.DR2TOT_H p1.DR2TOT_I; 
run;


proc sort data=nutr1_0316;
by seqn;
run;

proc sort data=nutr2_0316;
by seqn;
run;

data nutr_0316;
merge nutr1_0316 nutr2_0316;
by seqn;
run;




/***********************
macro of average of 2-day vitamins 
******************************/

%macro nutr_mean(var, nvar);
  if DR1T&var.=. and DR2T&var.=. then &nvar.=.;
  else if DR1T&var. ne . and DR2T&var.=. then &nvar.=DR1T&var.;
  else if DR1T&var.=.  and DR2T&var. ne . then &nvar.=DR2T&var.;
  else &nvar.=(DR1T&var.+DR2T&var.)/2;
%mend nutr_mean;



data nutr_0316m;
set nutr_0316;

/*** if only 1 day missing, then use the valid value from the other day instead */

%nutr_mean(VARA, vit_A);
%nutr_mean(VB2, vit_B2);
%nutr_mean(VC, vit_C);
%nutr_mean(ATOA, vit_E_add);

%nutr_mean(ATOC, vit_E);
%nutr_mean(ACAR, A_caro);
%nutr_mean(SELE, sele);
%nutr_mean(LYCO, lyco);

%nutr_mean(LZ, lut_zeax);
%nutr_mean(CRYP, B_cryp);


label 
vit_A="average Vitamin A as retinol activity equivalents (mcg) "
vit_B2="average Riboflavin (Vitamin B2) (mg)"
vit_C="average Vitamin C (mg)"
vit_E_add="average Added alpha-tocopherol (Vitamin E) (mg)"
vit_E="average Vitamin E as alpha-tocopherol (mg)"
A_caro="average Alpha-carotene (mcg)"
sele="average Selenium (mcg)"
lyco="average Lycopene (mcg)"
lut_zeax="average Lutein + zeaxanthin (mcg)"
B_cryp="average Beta-cryptoxanthin (mcg)";

run;







proc means data=nutr_0316m;
* var DR1TVARA DR2TVARA vit_a vit_a1;
 *var
DR1TVB2 DR2TVB2 vit_B2
DR1TVC DR2TVC vit_C
DR1TATOA DR2TATOA vit_E_added
;
 var DR1TCRYP DR2TCRYP B_cryp;
 run;













 
/*combine: HPV & antioxidant, by SEQN*/

data hpv_vs_0316;
set p.hpv_vs_0316;
run;

proc sort data=hpv_vs_0316;
by seqn;
run;

proc sort data=alb_0316;
by seqn;
run;

proc sort data=biop_0316;
by seqn;
run;

proc sort data=fer_0316;
by seqn;
run;

proc sort data=vac_0716;
by seqn;

proc sort data=nutr_0316m;
by seqn;
run;

/** n=71058 data with HPV, OS and vitamin markers***/

data dcom;
merge hpv_vs_0316 alb_0316 biop_0316 fer_0316 vac_0716 nutr_0316m;
by seqn;
run;

/*
data h.hpv_vs_atb_191218;
  set dcom;
run;
*/;




/*hpv and antibod info*/;

data hpv_vs_atb_0316;
set h.hpv_vs_atb_191218;


rename ridageyr=age;

if LBDR06=1 then hpv_type06=1;
else if LBDR06=2 then hpv_type06=0;
else hpv_type06=.;

if LBDR11=1 then hpv_type11=1;
else if LBDR11=2 then hpv_type11=0;
else hpv_type11=.;

if LBDR16=1 then hpv_type16=1;
else if LBDR16=2 then hpv_type16=0;
else hpv_type16=.;

if LBDR18=1 then hpv_type18=1;
else if LBDR18=2 then hpv_type18=0;
else hpv_type18=.;

if LBDR26=1 then hpv_type26=1;
else if LBDR26=2 then hpv_type26=0;
else hpv_type26=.;

if LBDR31=1 then hpv_type31=1;
else if LBDR31=2 then hpv_type31=0;
else hpv_type31=.;

if LBDR33=1 then hpv_type33=1;
else if LBDR33=2 then hpv_type33=0;
else hpv_type33=.;

if LBDR35=1 then hpv_type35=1;
else if LBDR35=2 then hpv_type35=0;
else hpv_type35=.;

if LBDR39=1 then hpv_type39=1;
else if LBDR39=2 then hpv_type39=0;
else hpv_type39=.;

if LBDR40=1 then hpv_type40=1;
else if LBDR40=2 then hpv_type40=0;
else hpv_type40=.;

if LBDR42=1 then hpv_type42=1;
else if LBDR42=2 then hpv_type42=0;
else hpv_type42=.;

if LBDR45=1 then hpv_type45=1;
else if LBDR45=2 then hpv_type45=0;
else hpv_type45=.;

if LBDR51=1 then hpv_type51=1;
else if LBDR51=2 then hpv_type51=0;
else hpv_type51=.;

if LBDR52=1 then hpv_type52=1;
else if LBDR52=2 then hpv_type52=0;
else hpv_type52=.;

if LBDR53=1 then hpv_type53=1;
else if LBDR53=2 then hpv_type53=0;
else hpv_type53=.;

if LBDR54=1 then hpv_type54=1;
else if LBDR54=2 then hpv_type54=0;
else hpv_type54=.;

if LBDR55=1 then hpv_type55=1;
else if LBDR55=2 then hpv_type55=0;
else hpv_type55=.;

if LBDR56=1 then hpv_type56=1;
else if LBDR56=2 then hpv_type56=0;
else hpv_type56=.;

if LBDR58=1 then hpv_type58=1;
else if LBDR58=2 then hpv_type58=0;
else hpv_type58=.;

if LBDR59=1 then hpv_type59=1;
else if LBDR59=2 then hpv_type59=0;
else hpv_type59=.;

if LBDR61=1 then hpv_type61=1;
else if LBDR61=2 then hpv_type61=0;
else hpv_type61=.;

if LBDR62=1 then hpv_type62=1;
else if LBDR62=2 then hpv_type62=0;
else hpv_type62=.;

if LBDR64=1 then hpv_type64=1;
else if LBDR64=2 then hpv_type64=0;
else hpv_type64=.;

if LBDR66=1 then hpv_type66=1;
else if LBDR66=2 then hpv_type66=0;
else hpv_type66=.;

if LBDR67=1 then hpv_type67=1;
else if LBDR67=2 then hpv_type67=0;
else hpv_type67=.;

if LBDR68=1 then hpv_type68=1;
else if LBDR68=2 then hpv_type68=0;
else hpv_type68=.;

if LBDR69=1 then hpv_type69=1;
else if LBDR69=2 then hpv_type69=0;
else hpv_type69=.;

if LBDR70=1 then hpv_type70=1;
else if LBDR70=2 then hpv_type70=0;
else hpv_type70=.;

if LBDR71=1 then hpv_type71=1;
else if LBDR71=2 then hpv_type71=0;
else hpv_type71=.;

if LBDR72=1 then hpv_type72=1;
else if LBDR72=2 then hpv_type72=0;
else hpv_type72=.;

if LBDR73=1 then hpv_type73=1;
else if LBDR73=2 then hpv_type73=0;
else hpv_type73=.;

if LBDR81=1 then hpv_type81=1;
else if LBDR81=2 then hpv_type81=0;
else hpv_type81=.;

if LBDR82=1 then hpv_type82=1;
else if LBDR82=2 then hpv_type82=0;
else hpv_type82=.;

if LBDR83=1 then hpv_type83=1;
else if LBDR83=2 then hpv_type83=0;
else hpv_type83=.;

if LBDR84=1 then hpv_type84=1;
else if LBDR84=2 then hpv_type84=0;
else hpv_type84=.;

if LBDR89=1 then hpv_type89=1;
else if LBDR89=2 then hpv_type89=0;
else hpv_type89=.;

if LBDRPI=1 then hpv_IS39=1;
else if LBDRPI=2 then hpv_IS39=0;
else hpv_IS39=.;




if LBX06=1 then anti_06=1;
else if LBX06=2 then anti_06=0;
else anti_06=.;

if LBX11=1 then anti_11=1;
else if LBX11=2 then anti_11=0;
else anti_11=.;

if LBX16=1 then anti_16=1;
else if LBX16=2 then anti_16=0;
else anti_16=.;

if LBX18=1 then anti_18=1;
else if LBX18=2 then anti_18=0;
else anti_18=.;


label 

LBDR06='HPV6 DNA Vaginal Swab (Roche Linear Array), 1: pos, 2: Neg, 3: Inadequate'
LBDR11='HPV11 DNA Vaginal Swab (Roche Linear Array), 1: pos, 2: Neg, 3: Inadequate'

LBX06='HPV6 serum antibody, 1: pos, 2: Neg'
LBX11='HPV11 serum antibody, 1: pos, 2: Neg'

;

run;

proc contents data=hpv_vs_atb_0316;
run;




proc freq data=hpv_vs_atb_0316;
 *table LBDR06 hpv_type06 LBDR11  hpv_type11  LBDR16 hpv_type16 LBDR18 hpv_type18 LBDR26 hpv_type26 LBDR31 hpv_type31;
 *table LBDR33 hpv_type33 LBDR35 hpv_type35 LBDR39 hpv_type39 LBDR40 hpv_type40 LBDR42 hpv_type42 LBDR45 hpv_type45 LBDR51 hpv_type51;
 *table LBDR52 hpv_type52 LBDR53 hpv_type53 LBDR54 hpv_type54 LBDR55 hpv_type55 LBDR56 hpv_type56 LBDR58 hpv_type58 LBDR59 hpv_type59;
 *table LBDR61 hpv_type61 LBDR62 hpv_type62 LBDR64 hpv_type64 LBDR67 hpv_type67 LBDR68 hpv_type68 LBDR69 hpv_type69 LBDR70 hpv_type70;
 table LBDR71 hpv_type71 LBDR72 hpv_type72 LBDR73 hpv_type73 LBDR81 hpv_type81 LBDR82 hpv_type82 LBDR83 hpv_type83 LBDR84 hpv_type84 
LBDR89 hpv_type89 LBDRPI hpv_IS39;

table LBDRPI  hpv_IS39;
 *table LBX06 anti_06 LBX11 anti_11 LBX16 anti_16 LBX18 anti_18;
 run;

proc freq data=hpv_vs_atb_0316;
table hpv_type06*anti_06 ;
run;



/*define high and low risk hpv
12 HPV types (16, 18, 31, 33, 35, 39, 45, 51, 52, 56, 58, and 59) based on the International Agency for Research on Cancer (IARC) definition. 

*/
proc freq data=hpv_vs_atb_0316;
 *table hpv_type16 hpv_type18 hpv_type31 hpv_type33 hpv_type35 hpv_type39 
 hpv_type45 hpv_type51 hpv_type52 hpv_type56 hpv_type58 hpv_type59 
hpv_type73 hpv_type81 hpv_type83 hpv_type89 ;

table anti_06 anti_11 anti_16 anti_18;
run;

/*** master file ***/;

data hpv_ms;
set hpv_vs_atb_0316;


/***
Q: why HPV_IS39 missing some data?
A: 2009-10 (not sure why missing 774 data, but listed in summary)
    HPV_IS39 only 0.29% with pos


vaginal HPV 6-89: n=12634
        hpv_IS39: n=11860  (some with other HPV types without hpv_IS39)

HPV antibody: n=14478
***/


if hpv_type06=.  then HPV_v_data=0;
else HPV_v_data=1;

if anti_06 =. then HPV_anti_data=0;
else HPV_anti_data=1;


/********
LinHY, 12/13/2019
Eligibility criteria:
 1. Female
 2. Aged 18-59 years (vaginal HPV and HPV antibodies were only collected for this age range)
 3. Had valid HPV data  (create seperate dataset: one for vaginal HPV and the other for HPV antibodies) 
 4. No cancer  (mcq020: for aged 20-150)
 5. No HPV vaccination (only for year 2007-2016, females age 9-59)
*****/


/*Sex: female*/
if RIAGENDR=.  then female=.;
else if RIAGENDR=2 then female=1;
else female=0;


/*age: 18-59*/
if 18<=age<=59 then agelig=1;
else agelig=0;


/*cancer information*/
if mcq220=7 or mcq220=9 or mcq220=. then cancer=.;
else if mcq220=1 then cancer=1;
else cancer=0;


/*vaccine*/
if IMQ040=7 or IMQ040=9 or IMQ040=. then vac1=.;
else if IMQ040=1 then vac1=1;
else vac1=0;

if IMQ060=7 or IMQ060=9 or IMQ060=. then vac2=.;
else if IMQ060=1 then vac2=1;
else vac2=0;

if vac1=1 or vac2=1 then vac=1;
else if vac1=. and vac2=. then vac=.;
else vac=0;



/********************************************
ELIGIBILITY for vaginal HPV (regardless HPV antibody)

  elg_v=1 (n=11070)
  elg_v_a=1 (n=6120)
*******************************************/

if female=1 and agelig=1 and hpv_v_data=1 and cancer ne 1 and vac ne 1 then elg_v=1;
else elg_v=0;

if female=1 and agelig=1 and hpv_v_data=1 and hpv_anti_data=1 and cancer ne 1 and vac ne 1 then elg_v_a=1;
else elg_v_a=0;


/********************************************
sampling weights
    WTMEC2YR

*********************************************/;

/**** sampling weighting 
use 1-day wt for dietary becuase we use mean or 1-day if the other day had a missing value 
***/ 

 WTMEC14YR=1/7*WTMEC2YR; /** for year 2003-2016 (HPV)*/

 WTDRD1_14yr=1/7*WTDRD1;




/** HPV antibody, 2003-2010
Don't need sub-set weights,just use elg in code is fine?
 */

If sddsrvyr in (3,4,5,6) then WTMEC8YR=1/4*WTMEC2YR; 
else WTMEC8YR=. ;

If sddsrvyr in (3,4,5,6) then  WTDRD1_8yr=1/4*WTDRD1;
else WTDRD1_8yr=. ;


/* for eligilible subgroup*/
if elg_v=1 then WTmec_v=WTMEC14YR;  
else  WTmec_v=1e-6;

if elg_v=1 then WTdrd1_v=WTDRD1_14yr;  
else  WTdrd1_v=1e-6;

if elg_v_a=1 then WTmec_v_a=WTMEC8YR;  
else  WTmec_v_a=1e-6;

if elg_v_a=1 then WTdrd1_v=WTDRD1_8yr;  
else  WTdrd1_v=1e-6;

/** 12/18/19 LinHY, 
37 HPV types:
HPV_g3 and HPV_hr12 coding check, OK

T:\LinHY_project\NHANES\antioxidant\data\chk_hpv_use.xlsx
**/
if HPV_v_data=0 then hpv_g3=.;
else if hpv_type06=0 and hpv_type11=0 and hpv_type16=0 and hpv_type18=0 and hpv_type26=0 and hpv_type31=0 and hpv_type33=0 and 
	hpv_type35=0 and hpv_type39=0 and hpv_type40=0 and hpv_type42=0 and hpv_type45=0 and hpv_type51=0 and hpv_type52=0 and 
	hpv_type53=0 and hpv_type54=0 and hpv_type55=0 and hpv_type56=0 and hpv_type58=0 and hpv_type59=0 and hpv_type61=0 and 
	hpv_type62=0 and hpv_type64=0 and hpv_type66=0 and hpv_type67=0 and hpv_type68=0 and hpv_type69=0 and hpv_type70=0 and 
	hpv_type71=0 and hpv_type72=0 and hpv_type73=0 and hpv_type81=0 and hpv_type82=0 and hpv_type83=0 and hpv_type84=0 and 
	hpv_type89=0 and hpv_IS39=0 then hpv_g3=0; 
else if hpv_type16=1 or hpv_type18=1 or hpv_type31=1 or hpv_type33=1 or hpv_type35 =1
	or hpv_type39=1 or hpv_type45 =1 or hpv_type51 =1 or hpv_type52 =1 or hpv_type56 =1 or 
	hpv_type58 =1 or hpv_type59=1 then hpv_g3=2;
else hpv_g3=1;

if hpv_g3=. then hpv_hr12=.;
else if hpv_g3=2 then hpv_hr12=1;
else hpv_hr12=0;



/******
HPV antibody
anti_06 anti_11 anti_16 anti_18 
***********/

if HPV_anti_data=0 then anti_g3=.;
 else if anti_06=0 and anti_11=0 and anti_16=0 and anti_18=0 then anti_g3=0; 
 else if anti_16=1 or  anti_18=1 then  anti_g3=2;
 else anti_g3=1;



 
ln_B_cryp=log(B_cryp+0.001);

label 
 IMQ040='Received HPV vaccine (for female 9-59, yr 2007-2014), 1:yes, 2:no, 7, refused, 9, do not know'
 IMQ060='Received HPV vaccine (for female 9-59, yr 2015-2016), 1:yes, 2:no, 7, refused, 9, do not know'

 elg_v='eligiblity indicator for vaginal HPV regardless HPV antibody'
 elg_v_a='eligiblity indicator for vaginal HPV & HPV antibody'

 WTMEC14YR='MEC 14-year (2003-16) sampling weights'
 WTDR2D14yr='2-day dietary 14-year (2003-16) sampling weights'

 WTMEC8YR='MEC 8-year (2003-10) sampling weights' /** HPV antibody, 2003-2010 */
 WTDR2D8yr='2-day dietary 8-year (2003-10) sampling weights'

 wtMEC_v='MEC sample weights for vaginal HPV'
 wtMEC_v_a='MEC sample weights for vaginal HPV & HPV antibody'

 RIAGENDR='gender, 1:male, 2: female'
 female='gender, 1: female, 0: male'

  HPV_v_data='had vaginal HPV info, 1:yes, 0:no'
  HPV_anti_data='had HPV antibody info, 1:yes, 0:no'

  hpv_g3='vaginal HPV, 0:no for 37 types, 1: low-risk 25 types, 2: high-risk 12 type'
  hpv_hr12='vaginal HPV, 1: high-risk 12 type, 0: others'
 
  anti_g3='HPV antibody (types 6,11,16,18), 0: No, 2: high-risk (HPV16/18), 1: only HPV6/11'
  vac='HPV vaccination, 1:yes, 0:no'

;
run;


/*
data p1.hpv_ms;
set hpv_ms;
run;
***/;



/** add demo **/

proc sort data=demo_0316;
 by seqn;

proc sort data=p1.hpv_ms;
 by seqn;
run;

proc sort data=p1.whq_0316;
 by seqn;
 run;


/*
data p1.hpv_ms_v2;
 merge p1.hpv_ms demo_0316 p1.whq_0316;
 by seqn;
run;
*/;



/*Revise note: add DRITOTC/.../I AND DR2TOTC/.../I for vitamin data */


/****************


***********/;


data hpv_ms;
set p1.hpv_ms_v2;  /* add demo */

*rename ridageyr=age;
/*age already defined at hpv_vs_atb_0316*/ 


   if  DMDEDUC2=7 or  DMDEDUC2=9 or  DMDEDUC2=. then edu=.;
   else if DMDEDUC2=1 then edu=1;
   else if DMDEDUC2=2 or DMDEDUC2=3 then edu=2;
   else edu=3;


 if indfmpir=. then pirg4=.;
 else if indfmpir=<1 then pirg4=1;
 else if indfmpir=<2 then pirg4=2;
 else if indfmpir=<4 then pirg4=3;
  else pirg4=4;
 
if ridreth1=. then race=.;
 else if  ridreth1=3 then race=1;
 else if  ridreth1=4 then race=2;
 else if  ridreth1=1 or  ridreth1=2 then race=3;
 else race=4;

 if race=. then race3=.;
 else if race=3 or race=4 then race3=3;
 else race3=race;

 
 if whd010=7777 or whd010=9999 or whd010=. then ht=.;
 else ht=whd010;

 if whd020=7777 or whd020=9999 or whd020=77777 or whd020=99999 or whd020=. then wt=.;
 else wt=whd020;
 
 bmi=(wt/ht**2)*703;  
 
 if bmi=. then bmig4=.;
 else if bmi<18.5 then bmig4=1;
 else if bmi>=18.5 and bmi<25 then bmig4=2;
 else if bmi>=25 and bmi<30 then bmig4=3;
 else bmig4=4;


 if bmig4=. then bmig3=.;
 else if bmig4=1 or bmig4=2 then bmig3=1;
 else if bmig4=3 then bmig3=2;
 else bmig3=3;

 label 
 bmig4='BMI, 1:underweight (<18.5), 2:normal(18.5-24.9), 3:overweight(25-29.9),4:obese (>=30)'
bmig3='BMI, 1:underweight or normal(<25), 2:overweight(25-29.9),3:obese (>=30)'
 
 label 
DMDEDUC2='Education for Adults 20+, 1:<9th grade, 2:9-11th grade, 3:High school graduate/GED or equivalent, 4:Some college or AA degree, 5:>=College, 7:Refused, 9: donot know'
edu='Education for Adults 20+, 1: <high school, 2: high school, 3: >high school'
race='1:White, 2:black, 3: Mexican American+ other Hispanic, 4:Others'
race3='1:White, 2:black, 3:Others'
pirg4='poverty income ratio, 1:<=1, 2:(1,2], 3:(2,4], 4:>4'
LBDR06='HPV6 DNA Vaginal Swab (Roche Linear Array), 1: pos, 2: Neg, 3: Inadequate'
LBDR11='HPV11 DNA Vaginal Swab (Roche Linear Array), 1: pos, 2: Neg, 3: Inadequate'

LBX06='HPV6 serum antibody, 1: pos, 2: Neg'
LBX11='HPV11 serum antibody, 1: pos, 2: Neg'
vit_A="average Vitamin A as retinol activity equivalents (mcg) "
vit_B2="average Riboflavin (Vitamin B2) (mg)"
vit_C="average Vitamin C (mg)"
vit_E_add="average Added alpha-tocopherol (Vitamin E) (mg)"
vit_E="average Vitamin E as alpha-tocopherol (mg)"
A_caro="average Alpha-carotene (mcg)"
sele="average Selenium (mcg)"
lyco="average Lycopene (mcg)"
lut_zeax="average Lutein + zeaxanthin (mcg)"
B_cryp="average Beta-cryptoxanthin (mcg)"
IMQ040='Received HPV vaccine (for female 9-59, yr 2007-2014), 1:yes, 2:no, 7, refused, 9, do not know'
IMQ060='Received HPV vaccine (for female 9-59, yr 2015-2016), 1:yes, 2:no, 7, refused, 9, do not know'

elg_v='eligiblity indicator for vaginal HPV regardless HPV antibody'
elg_v_a='eligiblity indicator for vaginal HPV & HPV antibody'

WTMEC14YR='MEC 14-year (2003-16) sampling weights'
WTDR2D14yr='2-day dietary 14-year (2003-16) sampling weights'

WTMEC8YR='MEC 8-year (2003-10) sampling weights' 
WTDR2D8yr='2-day dietary 8-year (2003-10) sampling weights'

wtMEC_v='MEC sample weights for vaginal HPV'
wtMEC_v_a='MEC sample weights for vaginal HPV & HPV antibody'

RIAGENDR='gender, 1:male, 2: female'
female='gender, 1: female, 0: male'

 HPV_v_data='had vaginal HPV info, 1:yes, 0:no'
 HPV_anti_data='had HPV antibody info, 1:yes, 0:no'

 hpv_g3='vaginal HPV, 0:no for 37 types, 1: no high-risk but with low-risk 25 types, 2: high-risk 12 type'
 hpv_hr12='vaginal HPV, 1: high-risk 12 type, 0: others'
 
 anti_g3='HPV antibody (types 6,11,16,18), 0: No, 2: high-risk (HPV16/18), 1: only HPV6/11'
 vac='HPV vaccination, 1:yes, 0:no'

 ;
 run;



proc print data=hpv_ms(obs=10);
var edu pirg4;
run;




/*********
for natural log trans
**********/

/** 
LinHY: 2/7/2020
revision
 1. use uniq var name 
 2. define missing first 
***/

%macro nlog(var);
if &var=. then ln_&var.=. ;
else ln_&var.=log(&var.+0.0001);
%mend nlog;

/*
Fu's version 

%macro nlog(var);
&var.=log(&var.);
%mend nlog;
*/

data p1.hpv_ms_v3;
set p1.hpv_ms_v3;
%nlog(vit_A);
%nlog(vit_b2);
%nlog(vit_C);
%nlog(vit_E_add);
%nlog(vit_E);
%nlog(A_caro);
%nlog(sele);
%nlog(lyco)
%nlog(lut_zeax);
%nlog(B_cryp);
%nlog(LBDSTBSI);
%nlog(LBDFERSI);
%nlog(LBDSALSI);
%nlog(LBXSAL);
%nlog(URXUMA);
%nlog(LBDSUASI);
%nlog(LBXSUA);
run;






/*****************
Persistent status 
and biomarkers
*****************/
%macro pers(no);
if hpv_type&no.=. or anti_&no.=. then pers_&no.=.;
else if hpv_type&no.=0 and anti_&no.=0 then pers_&no.=1;
else if hpv_type&no.=0 and anti_&no.=1 then pers_&no.=2;
else if hpv_type&no.=1 and anti_&no.=0 then pers_&no.=3;
else if hpv_type&no.=1 and anti_&no.=1 then pers_&no.=4;

if pers_&no.=. or pers_&no.=1 or pers_&no.=2 then pers_in_inf_&no.=.;
else if pers_&no.=3 then pers_in_inf_&no.=0;
else if pers_&no.=4 then pers_in_inf_&no.=1;

if pers_&no.=. then pers_g2_&no.=.;
else if pers_&no.=4 then pers_g2_&no.=1;
else pers_g2_&no.=0

%mend pers;

data hpv_ms_log;
set p1.hpv_ms_log;  


%pers(06);
%pers(11);
%pers(16);
%pers(18);


label 
pers_06='persistnet HPV-06 (vaginal, antibody), 1:neg,neg, 2:neg,pos, 3:transient inf, 4: persistent inf' 
pers_11='persistnet HPV-11 (vaginal, antibody), 1:neg,neg, 2:neg,pos, 3:transient inf, 4: persistent inf' 
pers_16='persistnet HPV-16 (vaginal, antibody), 1:neg,neg, 2:neg,pos, 3:transient inf, 4: persistent inf' 
pers_18='persistnet HPV-18 (vaginal, antibody), 1:neg,neg, 2:neg,pos, 3:transient inf, 4: persistent inf' 

pers_g2_06='persistnet HPV-16, 0: no persistent (negative + transicent), 1: persistent'
pers_g2_11='persistnet HPV-16, 0: no persistent (negative + transicent), 1: persistent'
pers_g2_16='persistnet HPV-16, 0: no persistent (negative + transicent), 1: persistent'
pers_g2_18='persistnet HPV-16, 0: no persistent (negative + transicent), 1: persistent'

pers_in_inf_06='persistnet HPV-16 for those with infection, 0:transient inf, 14: persistent inf' 
pers_in_inf_11='persistnet HPV-16 for those with infection, 0:transient inf, 14: persistent inf' 
pers_in_inf_16='persistnet HPV-16 for those with infection, 0:transient inf, 14: persistent inf' 
pers_in_inf_18='persistnet HPV-16 for those with infection, 0:transient inf, 14: persistent inf' 
  ;
  run;

/** 12/2/2020
verifed LinHY:
  hpv_type16  hpv_type18 
  anti_16 anti_18
  pers_16 pers_18  (4-group)
***/;

proc freq data=hpv_ms_log;
* table hpv_type16 * anti_16 pers_16/missing ;
 * table hpv_type18 * anti_18 pers_18/missing ;
*table LBX16 anti_16 LBX18 anti_18; 
table LBDR16 hpv_type16  LBDR18 hpv_type18;
 run;

/*
data p1.hpv_ms_log;
set hpv_ms_log; 
run;
  */







/*****************************************
******************************************
**************DATA ANALYSIS**************
******************************************
*****************************************/;

/*****************
LinHY,  2/7/2020
 demographic 

Paper 1, Table 1
 *************/;


data hpv_ms;
set p1.hpv_ms_v5;
run;

proc means data=hpv_ms;
 where  elg_v=1;
 var ridageyr age;
 run;



proc surveymeans data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v ;
 var age ;
run;

proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v* (race race3 edu)/row;
run;
/*
data hpv_ms;
set p1.hpv_ms_v3;
run;
*/

proc surveyfreq data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v * hpv_g3/row chisq;
run;

%macro sfreq(var);
proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v * &var. * hpv_g3/row chisq;
run;
%mend sfreq;

%sfreq(ag4);
%sfreq(edu);
%sfreq(race);
%sfreq(pirg4);
%sfreq(mari);
%sfreq(sex_p12 );
%sfreq(smk);
%sfreq(druglf);
%sfreq(au12);


proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v *race * hpv_g3/row chisq;
 where race in (1 2);
run;

proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v *race * hpv_g3/row chisq;
 *where race in (2 3);
run;

proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v * bmig3 * hpv_g3/row chisq;
run;

proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v * sex_p12 * hpv_g3/row chisq;
run;
proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v *race * hpv_g3/row chisq;
 where race in (2 4);
run;




proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v *race * hpv_type16/row chisq;
run;

proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v *race * hpv_type16/row chisq;
 where race in (1 2);
run;

proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v *race * hpv_type16/row chisq;
 where race in (2 3);
run;

proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v *race * hpv_type16/row chisq;
 where race in (2 4);
run;




proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v *race * hpv_type18/row chisq;
 *where race in (1 2);
run;

proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v *race * hpv_type18/row chisq;
 where race in (2 3);
run;

proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v *race * hpv_type18/row chisq;
 where race in (2 4);
run;


proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 tables elg_v_a *race * pers_16/row chisq;
run;


proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 tables elg_v_a *race* pers_g2_16/row chisq;
 *where race in (1 2);
run;

proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 tables elg_v_a *race3 * pers_g2_18/row chisq;
 where race in (2 3);
run;


proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 tables elg_v_a *race3 * pers_g2_18/row chisq;
 where race in (2 4);
run;

proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 tables elg_v_a *race * anti_16/row chisq;
run;


proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 tables elg_v_a *race * anti_18/row chisq;
 where race in (1 2);
run;

proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 tables elg_v_a *race * anti_18/row chisq;
 where race in (2 3);
run;


proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 tables elg_v_a *race * anti_18/row chisq;
 where race in (2 4);
run;

proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 tables elg_v *(race race3) * pers_18/row chisq;
run;


/*********
mean for markers by hpv: table2 in "use"
**********/

proc means data=p1.hpv_ms_v5;
where elg_v=1;
var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp 
LBDSTBSI LBDFERSI  LBDSALSI URXUMA  LBDSUASI vit_D folate;
run;

proc means data=p1.hpv_ms_v5;
where elg_v=1;
var vit_D folate;
run;



proc surveymeans data=p1.hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 domain elg_v ;
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp;
run;


proc surveymeans data=p1.hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v ;
 var LBDSTBSI LBDFERSI  LBDSALSI URXUMA  LBDSUASI;
run;





proc means data=p1.hpv_ms;
where elg_v_a=1;
var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp 
LBDSTBSI LBDFERSI  LBDSALSI URXUMA  LBDSUASI;
run;



proc surveymeans data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a ;
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp;
run;


proc surveymeans data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 domain elg_v_a ;
 var LBDSTBSI LBDFERSI  LBDSALSI  URXUMA  LBDSUASI;
run;




/*********
freq for hpv
**********/

*w/o weight;
proc freq data=hpv_ms;
where elg_v=1;
table hpv_g3 hpv_type06 hpv_type11 hpv_type16 hpv_type18 hpv_type26 hpv_type31 hpv_type33 hpv_type35 
hpv_type39 hpv_type40 hpv_type42 hpv_type45 hpv_type51 hpv_type52 hpv_type53 hpv_type54 
hpv_type55 hpv_type56 hpv_type58 hpv_type59 hpv_type61 hpv_type62 hpv_type64 hpv_type66 
hpv_type67 hpv_type68 hpv_type69 hpv_type70 hpv_type71 hpv_type72 hpv_type73 hpv_type81
hpv_type81 hpv_type82 hpv_type83 hpv_type84 hpv_type89;
run;


*w/ weight;
proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v*hpv_g3 
elg_v*hpv_type06 elg_v*hpv_type11 elg_v*hpv_type16 elg_v*hpv_type18 elg_v*hpv_type26 elg_v*hpv_type31 
elg_v*hpv_type33 elg_v*hpv_type35 elg_v*hpv_type39 elg_v*hpv_type40 elg_v*hpv_type42 elg_v*hpv_type45 
elg_v*hpv_type51 elg_v*hpv_type52 elg_v*hpv_type53 elg_v*hpv_type54 elg_v*hpv_type55 elg_v*hpv_type56 
elg_v*hpv_type58 elg_v*hpv_type59 elg_v*hpv_type61 elg_v*hpv_type62 elg_v*hpv_type64 elg_v*hpv_type66 
elg_v*hpv_type67 elg_v*hpv_type68 elg_v*hpv_type69 elg_v*hpv_type70 elg_v*hpv_type71 elg_v*hpv_type72
elg_v*hpv_type73 elg_v*hpv_type81 elg_v*hpv_type81 elg_v*hpv_type82 elg_v*hpv_type83 elg_v*hpv_type84
elg_v*hpv_type89/row;
run;



/*********
freq for antibody
**********/

*w/o weight;
proc freq data=hpv_ms;
where elg_v_a=1;
table anti_g3  anti_06 anti_11 anti_16 anti_18;
run;


*w/ weight;
proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 tables elg_v_a*anti_g3  elg_v_a*anti_06 elg_v_a*anti_11 elg_v_a*anti_16 elg_v_a*anti_18/row;
run;





/*********
for normality check of nureition markers
**********/


proc univariate data=hpv_ms;
   var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp 
       LBDSTBSI LBDFERSI LBDSALSI LBXSAL URXUMA LBDSUASI LBXSUA;
   histogram /normal;
run;






proc means data=hpv_ms_log;
 *var vit_A ln_vit_a vit_b2 vit_C vit_E_add A_caro;
 *var sele lyco lut_zeax B_cryp LBDSTBSI;
 var LBDFERSI LBXSAL URXUMA  LBDSUASI LBXSUA;
 run;

proc print data=hpv_ms_log;
 where vit_a ne . and vit_a<=0;
 var vit_a;
 run;


/*proc print data=hpv_ms(obs=5);
var vit_a;
run;
proc print data=hpv_ms_log(obs=5);
var vit_a;
run;*/

proc univariate data=hpv_ms_log;
   var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp 
       LBDSTBSI LBDFERSI LBDSALSI LBXSAL URXUMA LBDSUASI LBXSUA;
   histogram /normal;
run;


/** 
7/23/2020
LinHY: NHANES suggest not use "where" 
Q: Are theresults of using "where hpv_g3=" vs. "domain elg_v*hpv_g3" the same?
A: yes, they are the same. 

use HPV_g3 in doman for sub-group analyses 

Results: OK 

8/28/2020 verofoed results for Table 2 (continuous markers vs HPV_g3)
*****/;

/*********
mean for markers by HPV: Table 2/D3
**********/
data hpv_ms;
set p1.hpv_ms_v5;
run;

proc surveymeans data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 domain elg_v;
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp vit_d folate;
run;

proc surveymeans data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 domain elg_v;
 where hpv_g3=0;
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp vit_d folate;
run;

proc surveymeans data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 domain elg_v;
 where hpv_g3=1;
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp vit_d folate;
run;

proc surveymeans data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 domain elg_v;
 where hpv_g3=2;
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp vit_d folate;
run;


/*** markers with MEC weights ***/;

proc surveymeans data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v ;
 *where hpv_g3=0;
 var LBDSTBSI LBDFERSI  LBDSALSI URXUMA  LBDSUASI;
run;

proc surveymeans data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v ;
 where hpv_g3=0;
 var LBDSTBSI LBDFERSI  LBDSALSI URXUMA  LBDSUASI;
run;

proc surveymeans data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v ;
 where hpv_g3=1;
 var LBDSTBSI LBDFERSI  LBDSALSI URXUMA  LBDSUASI;
run;

proc surveymeans data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v ;
 where hpv_g3=2;
 var LBDSTBSI LBDFERSI  LBDSALSI URXUMA  LBDSUASI;
run;





/*********
p-value
**********/

%macro p_uni(var);
*proc surveylogistic data=p1.hpv_ms_v3;
proc surveylogistic data=hpv_ms;    /** 8/28/2020 LinHY change to hpv_ms=p1.hpv_ms_v5 */
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_hr12;
 domain elg_v ;
 model hpv_hr12(event='1')=&var.;
%mend p_uni;


%p_uni(ln_LBDSTBSI)
%p_uni(ln_LBDFERSI)
%p_uni(ln_LBDSALSI)
%p_uni(ln_URXUMA)
%p_uni(ln_LBDSUASI)
run;


/**04/28/20: fixed weight*/

%macro p_uni(var);
proc surveylogistic data=p1.hpv_ms_v3;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class hpv_hr12;
 domain elg_v ;
 model hpv_hr12(event='1')=&var.;
%mend p_uni;
%p_uni(ln_vit_A)
%p_uni(ln_vit_b2)
%p_uni(ln_vit_C)
%p_uni(ln_vit_E_add)
%p_uni(ln_vit_E)
%p_uni(ln_A_caro)
%p_uni(ln_sele)
%p_uni(ln_lyco)
%p_uni(ln_lut_zeax)
%p_uni(ln_B_cryp)
run;
     






/**************
8/28/2020 LInHY 
Table 2 & Table 3
************/;

*3-level: table2 HPV3g;

/** 8/28/2020 LinHY not sure about 'df=infinity', so did not use **/
/*
%macro p_unim1(var);
proc surveylogistic data=p1.hpv_ms_v3;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_g3(ref='0')/param=ref;
 domain elg_v ;
 model hpv_g3(event='0')=&var./link=glogit df=infinity;
%mend p_unim1;
**/;


*3-level: table2 HPV3g;
%macro p_unim1(var);
*proc surveylogistic data=p1.hpv_ms_v3;
proc surveylogistic data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_g3(ref='0')/param=ref;
 domain elg_v ;
 model hpv_g3(event='0')=&var./link=glogit;
%mend p_unim1;


%p_unim1(ln_LBDSTBSI);
%p_unim1(ln_LBDFERSI);
%p_unim1(ln_LBDSALSI);
%p_unim1(ln_URXUMA);
%p_unim1(ln_LBDSUASI);
run;

/*
%macro p_unim2(var);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class hpv_g3(ref='0')/param=ref;
 domain elg_v ;
 model hpv_g3(event='0')=&var./link=glogit df=infinity;
%mend p_unim2;
*/;


%macro p_unim2(var);
*proc surveylogistic data=p1.hpv_ms_v5;
proc surveylogistic data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class hpv_g3(ref='0')/param=ref;
 domain elg_v ;
 model hpv_g3(event='0')=&var./link=glogit ;
%mend p_unim2;
%p_unim2(ln_vit_A);
%p_unim2(ln_vit_b2)
%p_unim2(ln_vit_C)
%p_unim2(ln_vit_E_add)
%p_unim2(ln_vit_E)
%p_unim2(ln_A_caro)
%p_unim2(ln_sele)
%p_unim2(ln_lyco)
%p_unim2(ln_lut_zeax)
%p_unim2(ln_B_cryp)
%p_unim2(ln_vit_d)
%p_unim2(ln_folate)
run;
           






/*********
p-value
**********/

data p1.hpv_ms_v3;
set p1.hpv_ms_v3;

if anti_g3=. then anti_hr12=.;
else if anti_g3=2 then anti_hr12=1;
else anti_hr12=0;

label
anti_hr12='HPV antibody (types 6,11,16,18), 1: high-risk 2 type, 0: others'
;
run;

%macro p_uni(var);
proc surveylogistic data=p1.hpv_ms_v3;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 class anti_hr12;
 domain elg_v_a ;
 model anti_hr12(event='1')=&var.;
%mend p_uni;


%p_uni(ln_LBDSTBSI)
%p_uni(ln_LBDFERSI)
%p_uni(ln_LBDSALSI)
%p_uni(ln_URXUMA)
%p_uni(ln_LBDSUASI)
run;





%macro p_uni(var);
proc surveylogistic data=p1.hpv_ms_v3;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 class anti_hr12;
 domain elg_v_a ;
 model anti_hr12(event='1')=&var.;
%mend p_uni;
%p_uni(ln_vit_A)
%p_uni(ln_vit_b2)
%p_uni(ln_vit_C)
%p_uni(ln_vit_E_add)
%p_uni(ln_vit_E)
%p_uni(ln_A_caro)
%p_uni(ln_sele)
%p_uni(ln_lyco)
%p_uni(ln_lut_zeax)
%p_uni(ln_B_cryp)
run;
     






/*********
frequency for overall and persistent
**********/
proc freq data=hpv_ms_log;
where elg_v=1;
table hpv_hr;
run;

proc surveyfreq data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v*hpv_hr/row;
run;

proc surveyfreq data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 tables elg_v_a*hpv_type06*anti_06 elg_v_a*hpv_type11*anti_11 
        elg_v_a*hpv_type16*anti_16 elg_v_a*hpv_type18*anti_18/row;
run;



*type_specific_16;

%macro p_1601(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_type16;
 domain elg_v ;
 model hpv_type16(event='1')=&var.;
%mend p_1601;


%p_1601(ln_LBDSTBSI)
%p_1601(ln_LBDFERSI)
%p_1601(ln_LBDSALSI)
%p_1601(ln_URXUMA)
%p_1601(ln_LBDSUASI)
run;


%macro p_1602(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class hpv_type16;
 domain elg_v ;
 model hpv_type16(event='1')=&var.;
%mend p_1602;

%p_1602(ln_vit_A)
%p_1602(ln_vit_b2)
%p_1602(ln_vit_C)
%p_1602(ln_vit_E_add)
%p_1602(ln_vit_E)
%p_1602(ln_A_caro)
%p_1602(ln_sele)
%p_1602(ln_lyco)
%p_1602(ln_lut_zeax)
%p_1602(ln_B_cryp)
run;





*type_specific_18;

%macro p_1801(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_type18;
 domain elg_v ;
 model hpv_type18(event='1')=&var.;
%mend p_1801;


%p_1801(ln_LBDSTBSI)
%p_1801(ln_LBDFERSI)
%p_1801(ln_LBDSALSI)
%p_1801(ln_URXUMA)
%p_1801(ln_LBDSUASI)
run;


%macro p_1802(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class hpv_type18;
 domain elg_v ;
 model hpv_type18(event='1')=&var.;
%mend p_1802;

%p_1802(ln_vit_A)
%p_1802(ln_vit_b2)
%p_1802(ln_vit_C)
%p_1802(ln_vit_E_add)
%p_1802(ln_vit_E)
%p_1802(ln_A_caro)
%p_1802(ln_sele)
%p_1802(ln_lyco)
%p_1802(ln_lut_zeax)
%p_1802(ln_B_cryp)
run;



*type_specific_31;
*type_specific_31;

%macro p_3101(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_type31;
 domain elg_v ;
 model hpv_type31(event='1')=&var.;
%mend p_3101;


%p_3101(ln_LBDSTBSI)
%p_3101(ln_LBDFERSI)
%p_3101(ln_LBDSALSI)
%p_3101(ln_URXUMA)
%p_3101(ln_LBDSUASI)
run;


%macro p_3102(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class hpv_type31;
 domain elg_v ;
 model hpv_type31(event='1')=&var.;
%mend p_3102;

%p_3102(ln_vit_A)
%p_3102(ln_vit_b2)
%p_3102(ln_vit_C)
%p_3102(ln_vit_E_add)
%p_3102(ln_vit_E)
%p_3102(ln_A_caro)
%p_3102(ln_sele)
%p_3102(ln_lyco)
%p_3102(ln_lut_zeax)
%p_3102(ln_B_cryp)
run;


*type_specific_33;

%macro p_3301(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_type33;
 domain elg_v ;
 model hpv_type33(event='1')=&var.;
%mend p_3301;


%p_3301(ln_LBDSTBSI)
%p_3301(ln_LBDFERSI)
%p_3301(ln_LBDSALSI)
%p_3301(ln_URXUMA)
%p_3301(ln_LBDSUASI)
run;


%macro p_3302(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class hpv_type33;
 domain elg_v ;
 model hpv_type33(event='1')=&var.;
%mend p_3302;

%p_3302(ln_vit_A)
%p_3302(ln_vit_b2)
%p_3302(ln_vit_C)
%p_3302(ln_vit_E_add)
%p_3302(ln_vit_E)
%p_3302(ln_A_caro)
%p_3302(ln_sele)
%p_3302(ln_lyco)
%p_3302(ln_lut_zeax)
%p_3302(ln_B_cryp)
run;




*type_specific_35;

%macro p_3501(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_type35;
 domain elg_v ;
 model hpv_type35(event='1')=&var.;
%mend p_3501;


%p_3501(ln_LBDSTBSI)
%p_3501(ln_LBDFERSI)
%p_3501(ln_LBDSALSI)
%p_3501(ln_URXUMA)
%p_3501(ln_LBDSUASI)
run;


%macro p_3502(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class hpv_type35;
 domain elg_v ;
 model hpv_type35(event='1')=&var.;
%mend p_3502;

%p_3502(ln_vit_A)
%p_3502(ln_vit_b2)
%p_3502(ln_vit_C)
%p_3502(ln_vit_E_add)
%p_3502(ln_vit_E)
%p_3502(ln_A_caro)
%p_3502(ln_sele)
%p_3502(ln_lyco)
%p_3502(ln_lut_zeax)
%p_3502(ln_B_cryp)
run;





*type_specific_39;

%macro p_3901(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_type39;
 domain elg_v ;
 model hpv_type39(event='1')=&var.;
%mend p_3901;


%p_3901(ln_LBDSTBSI)
%p_3901(ln_LBDFERSI)
%p_3901(ln_LBDSALSI)
%p_3901(ln_URXUMA)
%p_3901(ln_LBDSUASI)
run;


%macro p_3902(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class hpv_type39;
 domain elg_v ;
 model hpv_type39(event='1')=&var.;
%mend p_3902;

%p_3902(ln_vit_A)
%p_3902(ln_vit_b2)
%p_3902(ln_vit_C)
%p_3902(ln_vit_E_add)
%p_3902(ln_vit_E)
%p_3902(ln_A_caro)
%p_3902(ln_sele)
%p_3902(ln_lyco)
%p_3902(ln_lut_zeax)
%p_3902(ln_B_cryp)
run;





*type_specific_45;

%macro p_4501(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_type45;
 domain elg_v ;
 model hpv_type45(event='1')=&var.;
%mend p_4501;


%p_4501(ln_LBDSTBSI)
%p_4501(ln_LBDFERSI)
%p_4501(ln_LBDSALSI)
%p_4501(ln_URXUMA)
%p_4501(ln_LBDSUASI)
run;


%macro p_4502(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class hpv_type45;
 domain elg_v ;
 model hpv_type45(event='1')=&var.;
%mend p_4502;

%p_4502(ln_vit_A)
%p_4502(ln_vit_b2)
%p_4502(ln_vit_C)
%p_4502(ln_vit_E_add)
%p_4502(ln_vit_E)
%p_4502(ln_A_caro)
%p_4502(ln_sele)
%p_4502(ln_lyco)
%p_4502(ln_lut_zeax)
%p_4502(ln_B_cryp)
run;









*type_specific_51;

%macro p_5101(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_type51;
 domain elg_v ;
 model hpv_type51(event='1')=&var.;
%mend p_5101;


%p_5101(ln_LBDSTBSI)
%p_5101(ln_LBDFERSI)
%p_5101(ln_LBDSALSI)
%p_5101(ln_URXUMA)
%p_5101(ln_LBDSUASI)
run;


%macro p_5102(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class hpv_type51;
 domain elg_v ;
 model hpv_type51(event='1')=&var.;
%mend p_5102;

%p_5102(ln_vit_A)
%p_5102(ln_vit_b2)
%p_5102(ln_vit_C)
%p_5102(ln_vit_E_add)
%p_5102(ln_vit_E)
%p_5102(ln_A_caro)
%p_5102(ln_sele)
%p_5102(ln_lyco)
%p_5102(ln_lut_zeax)
%p_5102(ln_B_cryp)
run;





*type_specific_52;

%macro p_5201(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_type52;
 domain elg_v ;
 model hpv_type52(event='1')=&var.;
%mend p_5201;


%p_5201(ln_LBDSTBSI)
%p_5201(ln_LBDFERSI)
%p_5201(ln_LBDSALSI)
%p_5201(ln_URXUMA)
%p_5201(ln_LBDSUASI)
run;


%macro p_5202(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class hpv_type52;
 domain elg_v ;
 model hpv_type52(event='1')=&var.;
%mend p_5202;

%p_5202(ln_vit_A)
%p_5202(ln_vit_b2)
%p_5202(ln_vit_C)
%p_5202(ln_vit_E_add)
%p_5202(ln_vit_E)
%p_5202(ln_A_caro)
%p_5202(ln_sele)
%p_5202(ln_lyco)
%p_5202(ln_lut_zeax)
%p_5202(ln_B_cryp)
run;






*type_specific_56;

%macro p_5601(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_type56;
 domain elg_v ;
 model hpv_type56(event='1')=&var.;
%mend p_5601;


%p_5601(ln_LBDSTBSI)
%p_5601(ln_LBDFERSI)
%p_5601(ln_LBDSALSI)
%p_5601(ln_URXUMA)
%p_5601(ln_LBDSUASI)
run;


%macro p_5602(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class hpv_type56;
 domain elg_v ;
 model hpv_type56(event='1')=&var.;
%mend p_5602;

%p_5602(ln_vit_A)
%p_5602(ln_vit_b2)
%p_5602(ln_vit_C)
%p_5602(ln_vit_E_add)
%p_5602(ln_vit_E)
%p_5602(ln_A_caro)
%p_5602(ln_sele)
%p_5602(ln_lyco)
%p_5602(ln_lut_zeax)
%p_5602(ln_B_cryp)
run;







*type_specific_58;

%macro p_5801(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_type58;
 domain elg_v ;
 model hpv_type58(event='1')=&var.;
%mend p_5801;


%p_5801(ln_LBDSTBSI)
%p_5801(ln_LBDFERSI)
%p_5801(ln_LBDSALSI)
%p_5801(ln_URXUMA)
%p_5801(ln_LBDSUASI)
run;


%macro p_5802(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class hpv_type58;
 domain elg_v ;
 model hpv_type58(event='1')=&var.;
%mend p_5802;

%p_5802(ln_vit_A)
%p_5802(ln_vit_b2)
%p_5802(ln_vit_C)
%p_5802(ln_vit_E_add)
%p_5802(ln_vit_E)
%p_5802(ln_A_caro)
%p_5802(ln_sele)
%p_5802(ln_lyco)
%p_5802(ln_lut_zeax)
%p_5802(ln_B_cryp)
run;






*type_specific_59;

%macro p_5901(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_type59;
 domain elg_v ;
 model hpv_type59(event='1')=&var.;
%mend p_5901;


%p_5901(ln_LBDSTBSI)
%p_5901(ln_LBDFERSI)
%p_5901(ln_LBDSALSI)
%p_5901(ln_URXUMA)
%p_5901(ln_LBDSUASI)
run;


%macro p_5902(var);
proc surveylogistic data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class hpv_type59;
 domain elg_v ;
 model hpv_type59(event='1')=&var.;
%mend p_5902;

%p_5902(ln_vit_A)
%p_5902(ln_vit_b2)
%p_5902(ln_vit_C)
%p_5902(ln_vit_E_add)
%p_5902(ln_vit_E)
%p_5902(ln_A_caro)
%p_5902(ln_sele)
%p_5902(ln_lyco)
%p_5902(ln_lut_zeax)
%p_5902(ln_B_cryp)
run;








/*persistent vs biomarker*/



%macro pers_0601(var);
/* Fu's version 
*proc surveyreg data=hpv_ms_log; 
*/;
proc surveyreg data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 class pers_06(ref='1');
 domain elg_v_a;
 model &var.=pers_06/ solution;
%mend pers_0601;


%pers_0601(ln_LBDSTBSI);
%pers_0601(ln_LBDFERSI);
%pers_0601(ln_LBDSALSI);
%pers_0601(ln_URXUMA);
%pers_0601(ln_LBDSUASI);
run;


%macro pers_0602(var);
proc surveyreg data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 class pers_06(ref='1');
 domain elg_v_a;
 model &var.=pers_06/ solution;
%mend pers_0602;

%pers_0602(ln_vit_A)
%pers_0602(ln_vit_b2)
%pers_0602(ln_vit_C)
%pers_0602(ln_vit_E_add)
%pers_0602(ln_vit_E)
%pers_0602(ln_A_caro)
%pers_0602(ln_sele)
%pers_0602(ln_lyco)
%pers_0602(ln_lut_zeax)
%pers_0602(ln_B_cryp)
run;











%macro pers_1101(var);
proc surveyreg data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 class pers_11(ref='1');
 domain elg_v_a;
 model &var.=pers_11/solution;
%mend pers_1101;


%pers_1101(ln_LBDSTBSI)
%pers_1101(ln_LBDFERSI)
%pers_1101(ln_LBDSALSI)
%pers_1101(ln_URXUMA)
%pers_1101(ln_LBDSUASI)
run;


%macro pers_1102(var);
proc surveyreg data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 class pers_11(ref='1');
 domain elg_v_a;
 model &var.=pers_11/solution;
%mend pers_1102;

%pers_1102(ln_vit_A)
%pers_1102(ln_vit_b2)
%pers_1102(ln_vit_C)
%pers_1102(ln_vit_E_add)
%pers_1102(ln_vit_E)
%pers_1102(ln_A_caro)
%pers_1102(ln_sele)
%pers_1102(ln_lyco)
%pers_1102(ln_lut_zeax)
%pers_1102(ln_B_cryp)
run;










%macro pers_1601(var);
proc surveyreg data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 class pers_16(ref='1');
 domain elg_v_a;
 model &var.=pers_16/solution;
%mend pers_1601;


%pers_1601(ln_LBDSTBSI)
%pers_1601(ln_LBDFERSI)
%pers_1601(ln_LBDSALSI)
%pers_1601(ln_URXUMA)
%pers_1601(ln_LBDSUASI)
run;


%macro pers_1602(var);
proc surveyreg data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 class pers_16(ref='1');
 domain elg_v_a;
 model &var.=pers_16/solution;
%mend pers_1602;

%pers_1602(ln_vit_A)
%pers_1602(ln_vit_b2)
%pers_1602(ln_vit_C)
%pers_1602(ln_vit_E_add)
%pers_1602(ln_vit_E)
%pers_1602(ln_A_caro)
%pers_1602(ln_sele)
%pers_1602(ln_lyco)
%pers_1602(ln_lut_zeax)
%pers_1602(ln_B_cryp)
run;







%macro pers_1801(var);
proc surveyreg data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 class pers_18(ref='1');
 domain elg_v_a;
 model &var.=pers_18/solution;
%mend pers_1801;


%pers_1801(ln_LBDSTBSI)
%pers_1801(ln_LBDFERSI)
%pers_1801(ln_LBDSALSI)
%pers_1801(ln_URXUMA)
%pers_1801(ln_LBDSUASI)
run;


%macro pers_1802(var);
proc surveyreg data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 class pers_18(ref='1');
 domain elg_v_a;
 model &var.=pers_18/solution;
%mend pers_1802;

%pers_1802(ln_vit_A)
%pers_1802(ln_vit_b2)
%pers_1802(ln_vit_C)
%pers_1802(ln_vit_E_add)
%pers_1802(ln_vit_E)
%pers_1802(ln_A_caro)
%pers_1802(ln_sele)
%pers_1802(ln_lyco)
%pers_1802(ln_lut_zeax)
%pers_1802(ln_B_cryp)
run;






/**********************
Marker VS antibody 3/12/20
**********************/

*Table M2;

*anti_06;

%macro a_0601(var);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 class anti_06;
 domain elg_v_a ;
 model anti_06(event='1')=&var.;
%mend a_0601;


%a_0601(ln_LBDSTBSI)
%a_0601(ln_LBDFERSI)
%a_0601(ln_LBDSALSI)
%a_0601(ln_URXUMA)
%a_0601(ln_LBDSUASI)
run;


%macro a_0602(var);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 class anti_06;
 domain elg_v_a ;
 model anti_06(event='1')=&var.;
%mend a_0602;

%a_0602(ln_vit_A)
%a_0602(ln_vit_b2)
%a_0602(ln_vit_C)
%a_0602(ln_vit_E_add)
%a_0602(ln_vit_E)
%a_0602(ln_A_caro)
%a_0602(ln_sele)
%a_0602(ln_lyco)
%a_0602(ln_lut_zeax)
%a_0602(ln_B_cryp)
%a_0602(ln_vit_d)
%a_0602(ln_folate)
run;


*anti_11;

%macro a_1101(var);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 class anti_11;
 domain elg_v_a ;
 model anti_11(event='1')=&var.;
%mend a_1101;


%a_1101(ln_LBDSTBSI)
%a_1101(ln_LBDFERSI)
%a_1101(ln_LBDSALSI)
%a_1101(ln_URXUMA)
%a_1101(ln_LBDSUASI)
run;


%macro a_1102(var);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 class anti_11;
 domain elg_v_a ;
 model anti_11(event='1')=&var.;
%mend a_1102;

%a_1102(ln_vit_A)
%a_1102(ln_vit_b2)
%a_1102(ln_vit_C)
%a_1102(ln_vit_E_add)
%a_1102(ln_vit_E)
%a_1102(ln_A_caro)
%a_1102(ln_sele)
%a_1102(ln_lyco)
%a_1102(ln_lut_zeax)
%a_1102(ln_B_cryp)
%a_1102(ln_vit_d)
%a_1102(ln_folate)
run;




*anti_16;

%macro a_1601(var);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 class anti_16;
 domain elg_v_a ;
 model anti_16(event='1')=&var.;
%mend a_1601;


%a_1601(ln_LBDSTBSI)
%a_1601(ln_LBDFERSI)
%a_1601(ln_LBDSALSI)
%a_1601(ln_URXUMA)
%a_1601(ln_LBDSUASI)
run;


%macro a_1602(var);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 class anti_16;
 domain elg_v_a ;
 model anti_16(event='1')=&var.;
%mend a_1602;

%a_1602(ln_vit_A)
%a_1602(ln_vit_b2)
%a_1602(ln_vit_C)
%a_1602(ln_vit_E_add)
%a_1602(ln_vit_E)
%a_1602(ln_A_caro)
%a_1602(ln_sele)
%a_1602(ln_lyco)
%a_1602(ln_lut_zeax)
%a_1602(ln_B_cryp)
%a_1602(ln_vit_d)
%a_1602(ln_folate)
run;




*anti_18;

%macro a_1801(var);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 class anti_18;
 domain elg_v_a ;
 model anti_18(event='1')=&var.;
%mend a_1801;


%a_1801(ln_LBDSTBSI)
%a_1801(ln_LBDFERSI)
%a_1801(ln_LBDSALSI)
%a_1801(ln_URXUMA)
%a_1801(ln_LBDSUASI)
run;


%macro a_1802(var);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 class anti_18;
 domain elg_v_a ;
 model anti_18(event='1')=&var.;
%mend a_1802;

%a_1802(ln_vit_A)
%a_1802(ln_vit_b2)
%a_1802(ln_vit_C)
%a_1802(ln_vit_E_add)
%a_1802(ln_vit_E)
%a_1802(ln_A_caro)
%a_1802(ln_sele)
%a_1802(ln_lyco)
%a_1802(ln_lut_zeax)
%a_1802(ln_B_cryp)
%a_1802(ln_vit_d)
%a_1802(ln_folate)
run;







*****Table D3a;


proc surveymeans data=p1.hpv_ms_log; 
 strata sdmvstra; 
 cluster sdmvpsu; 
 weight WTDRd1_8yr; 
 domain elg_v_a; 
 where anti_g3=0; 
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp vit_D folate; 
run;


proc surveymeans data=hpv_ms_log; 
 strata sdmvstra; 
 cluster sdmvpsu; 
 weight WTDRd1_8yr; 
 domain elg_v_a; 
 where anti_g3=1; 
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp vit_D folate; 
run;

proc surveymeans data=hpv_ms_log; 
 strata sdmvstra; 
 cluster sdmvpsu; 
 weight WTDRd1_8yr; 
 domain elg_v_a; 
 where anti_g3=2; 
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp vit_D folate; 
run;




proc surveymeans data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 domain elg_v_a ;
 where anti_g3=0;
 var LBDSTBSI LBDFERSI  LBDSALSI  URXUMA  LBDSUASI;
run;



proc surveymeans data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 domain elg_v_a ;
 where anti_g3=1;
 var LBDSTBSI LBDFERSI  LBDSALSI  URXUMA  LBDSUASI;
run;




proc surveymeans data=hpv_ms_log;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 domain elg_v_a ;
 where anti_g3=2;
 var LBDSTBSI LBDFERSI  LBDSALSI  URXUMA  LBDSUASI;
run;





%macro p_uni_anti_hr12(var);*TABLE D3A;
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 class anti_hr12;
 domain elg_v_a ;
 model anti_hr12(event='1')=&var.;
%mend p_uni_anti_hr1;
%p_uni_anti_hr12(ln_vit_D)
%p_uni_anti_hr12(ln_folate)
run;







/*update 03/22/2020
Adding new data to masterfile "hpv_ms_log"
Sexual behavior & Drug use
*****************/

/*transfer*/

%trans1(SXQ_C);
%trans1(SXQ_D);
%trans1(SXQ_E);
%trans1(SXQ_F);
%trans1(SXQ_G);
%trans1(SXQ_H);
%trans1(SXQ_I);


%trans1(DUQ_C);
%trans1(DUQ_D);
%trans1(DUQ_E);
%trans1(DUQ_F);
%trans1(DUQ_G);
%trans1(DUQ_H);
%trans1(DUQ_I);



/*manipulate*/
data SXQ_C;
set p1.SXQ_C;
*keep SXQ020 SXD030 SXQ100 SXQ120 SXQ130 SXQ150 s_lf1 s_lf2 s_lf;


if SXQ020 in (7,9,.) then p_lf1=.;
else if SXQ020=1 and SXQ100 in (., 77777, 99999) then p_lf1=.;
else if SXQ020=1 and SXQ100>=0 then p_lf1=SXQ100;
else if SXQ020=2 then p_lf1=0;

if SXQ020 in (7,9,.) then p_lf2=.;
else if SXQ020=1 and SXQ130 in (., 77777, 99999) then p_lf2=.;
else if SXQ020=1 and SXQ130>=0 then p_lf2=SXQ130;
else if SXQ020=2 then p_lf2=0;

if p_lf1 = p_lf2=. then p_lf=.;
else if p_lf1>=0 and p_lf2=. then p_lf=p_lf1;
else if p_lf2>=0 and p_lf1=. then p_lf=p_lf2;
else p_lf = p_lf1+p_lf2;


if p_lf=. then sex_lp=.;
else if p_lf in (0,1) then sex_lp=0;
else if p_lf>=6 then sex_lp=2;
else sex_lp=1;


run;





data SXQ_DE;
set p1.SXQ_D p1.SXQ_E;
*keep SXQ021 SXD031 SXQ101 SXQ450 SXQ130 SXQ490;
if SXQ021 in (7,9,.) then p_lf1=.;
else if SXQ021=1 and SXQ101 in (., 77777, 99999) then p_lf1=.;
else if SXQ021=1 and SXQ101>=0 then p_lf1=SXQ101;
else if SXQ021=2 then p_lf1=0;

if SXQ020 in (7,9,.) then p_lf2=.;
else if SXQ020=1 and SXQ130 in (., 77777, 99999) then p_lf2=.;
else if SXQ020=1 and SXQ130>=0 then p_lf2=SXQ130;
else if SXQ020=2 then p_lf2=0;

if p_lf1 = p_lf2=. then p_lf=.;
else if p_lf1>=0 and p_lf2=. then p_lf=p_lf1;
else if p_lf2>=0 and p_lf1=. then p_lf=p_lf2;
else p_lf = p_lf1+p_lf2;


if p_lf=. then sex_lp=.;
else if p_lf in (0,1) then sex_lp=0;
else if p_lf>=6 then sex_lp=2;
else sex_lp=1;


run;








data SXQ_FGHI;
set p1.SXQ_F p1.SXQ_G p1.SXQ_H p1.SXQ_I;
*keep SXD021 SXD031 SXD101 SXD450 SXQ130 SXQ490;
if SXD021 in (7,9,.) then p_lf1=.;
else if SXD021=1 and SXD101 in (., 77777, 99999) then p_lf1=.;
else if SXD021=1 and SXD101>=0 then p_lf1=SXD101;
else if SXD021=2 then p_lf1=0;

if SXQ020 in (7,9,.) then p_lf2=.;
else if SXQ020=1 and SXQ130 in (., 77777, 99999) then p_lf2=.;
else if SXQ020=1 and SXQ130>=0 then p_lf2=SXQ130;
else if SXQ020=2 then p_lf2=0;

if p_lf1 = p_lf2=. then p_lf=.;
else if p_lf1>=0 and p_lf2=. then p_lf=p_lf1;
else if p_lf2>=0 and p_lf1=. then p_lf=p_lf2;
else p_lf = p_lf1+p_lf2;


if p_lf=. then sex_lp=.;
else if p_lf in (0,1) then sex_lp=0;
else if p_lf>=6 then sex_lp=2;
else sex_lp=1;


run;


proc freq data=p1.hpv_ms_v3;
table sex_lp;
run;



/*combine*/
data p1.sexual_0316;
 set SXQ_C SXQ_DE SXQ_FGHI;
 run;


 data p1.drug_0316;
 set p1.DUQ_C p1.DUQ_D p1.DUQ_E p1.DUQ_F p1.DUQ_G p1.DUQ_H p1.DUQ_I;
 run;


 /*merge*/

proc sort data=p1.sexual_0316;
by seqn;
run;

proc sort data=p1.drug_0316;
by seqn;
run;


data p1.hpv_ms_v3;     *This version includes log transform;
merge p1.hpv_ms_log p1.sexual_0316 p1.drug_0316;
by seqn;
run;

/*
updated 06/02/2020: apply new cutpoints
*/

data p1.hpv_ms_v3;
set p1.hpv_ms_v3;



if SXQ120 in (77777, 99999, .) then sp_m1=.;
else sp_m1=SXQ120;

if SXQ450 in (77777, 99999, .) then sp_m2=.;
else sp_m2=SXQ450;

if SXD450 in (77777, 99999, .) then sp_m3=.;
else sp_m3=SXD450;




if SXQ150 in (77777, 99999, .) then sp_f1=.;
else sp_f1=SXQ150;

if SXQ490 in (77777, 99999, .) then sp_f2=.;
else sp_f2=SXQ490;



if sp_m1=sp_m2=sp_m3=. then p_male=.;
else if sp_m1>=0 then p_male=sp_m1;
else if sp_m2>=0 then p_male=sp_m2;
else if sp_m3>=0 then p_male=sp_m3;



if sp_f1=sp_f2=. then p_female=.;
else if sp_f1>=0 then p_female=sp_f1;
else if sp_f2>=0 then p_female=sp_f2;



if p_male=p_female=. then p_year=.;
else if p_male=. then p_year=p_female;
else p_year=p_male;


if p_year=. then sex_p12=.;
else if p_year=0 then sex_p12=0;
else if p_year=1 then sex_p12=1;
else sex_p12=2;

label
sp_m1='male sex partner for past 12 months: 2003-2004'
sp_m2='male sex partner for past 12 months: 2005-2008'
sp_m3='male sex partner for past 12 months: 2009-2016'


sp_f1='female sex partner for past 12 months: 2003-2004'
sp_f2='female sex partner for past 12 months: 2005-2016'

p_year='total sex partners for past 12 month'

Sex_p12='total sex partners for past 12 month: 0:no 1:1 2:>=2'




p_lf1='life sex partner male'
p_lf2='life sex partner female'
p_lf ='life sex partner total'

Sex_lp='total sex partners lifetime: 0:0-1 1:2-5 2:>=6'

;
run;




/*descriptive for demo*/


proc freq data=hpv_ms_v3;
table p_year p_lf;
run;


proc means data=hpv_ms_v3;
 where elg_v=1;
 var age bmi;
 run;

proc freq data=hpv_ms_v3;
where elg_v=1;
table race edu pirg4 bmig3 sex_p2;
run;



proc surveymeans data=hpv_ms_v3;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v ;
 var age sex_partner bmi;
run;











/*Multiple Analysis: 3-level hpv VS. each marker     (Table M3)*/

%macro p_uni01(var);
proc surveylogistic data=p1.hpv_ms_v3;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v ;
 model hpv_g3(ref='0')=&var./link=glogit df=infinity;
%mend p_uni01;


%p_uni01(ln_LBDSTBSI)
%p_uni01(ln_LBDFERSI)
%p_uni01(ln_LBDSALSI)
%p_uni01(ln_URXUMA)
%p_uni01(ln_LBDSUASI)
run;




%macro p_uni02(var);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 domain elg_v ;
 model hpv_g3(ref='0')=&var./link=glogit df=infinity;
%mend p_uni02;

%p_uni02(ln_vit_A)
%p_uni02(ln_vit_b2)
%p_uni02(ln_vit_C)
%p_uni02(ln_vit_E_add)
%p_uni02(ln_vit_E)
%p_uni02(ln_A_caro)
%p_uni02(ln_sele)
%p_uni02(ln_lyco)
%p_uni02(ln_lut_zeax)
%p_uni02(ln_B_cryp)
%p_uni02(ln_vit_d)
%p_uni02(ln_folate)

run;









/**************
Update 04/13/2020
make 3-level markers: low, medium, high, defined by 
'T:\LinHY_project\NHANES\antioxidant\document\ cutpoint_antioxidant_200408.docx'

Update 04/13/2020
make 3-level markers: low, medium, high: Data_based


***************/
data hpv_ms_v3;
set p1.hpv_ms_v3;
run;




*According to the U.S. National Library of Medicine, there are two suggestions:

For a random urine sample, normal values are 0 to 14 mg/dL (0 to 140 ug/ml).
For a 24-hour urine collection, the normal value is less than 80 mg per 24 hours (<800 ug/ml)
;
proc univariate data=hpv_ms_v3 noprint;
   var LBDSTBSI;
   output out=perc_bili pctlpre=P_ pctlpts=33 67;
run;
proc print data=perc_bili;
run;


proc univariate data=hpv_ms_v3 noprint;
   var LBDFERSI;
   output out=perc_fer pctlpre=P_ pctlpts=33 67;
run;
proc print data=perc_fer;
run;



proc univariate data=hpv_ms_v3 noprint;
   var  LBDSALSI;
   output out=perc_alb pctlpre=P_ pctlpts=33 67;
run;
proc print data=perc_alb;
run;


proc univariate data=hpv_ms_v3 noprint;
   var URXUMA;
   output out=perc_ualb pctlpre=P_ pctlpts=33 67;
run;
proc print data=perc_ualb;
run;


proc univariate data=hpv_ms_v3 noprint;
   var  LBDSUASI;
   output out=perc_ua pctlpre=P_ pctlpts=33 67;
run;
proc print data=perc_ua;
run;







proc univariate data=hpv_ms_v3 noprint;
   var vit_A;
   output out=perc_va pctlpre=P_ pctlpts=33 67;
run;
proc print data=perc_va;
run;


proc univariate data=hpv_ms_v3 noprint;
   var vit_b2;
   output out=perc_vb2 pctlpre=P_ pctlpts=33 67;
run;
proc print data=perc_vb2;
run;

proc univariate data=hpv_ms_v3 noprint;
   var vit_c;
   output out=perc_vc pctlpre=P_ pctlpts=33 67;
run;
proc print data=perc_vc;
run;


proc univariate data=hpv_ms_v3 noprint;
   var vit_e;
   output out=perc_ve pctlpre=P_ pctlpts=33 67;
run;
proc print data=perc_ve;
run;


/*How to deal with vit_e_a

data veacheck;
set hpv_ms_v3;
if vit_e_add=. then veac=.;
else if vit_e_add>0 then veac=1;
else veac=0;
run;

proc freq data=veacheck ;
   table veac;
run;

*/
proc univariate data=hpv_ms_v3 noprint;
   var vit_e_add;
   output out=perc_vea pctlpre=P_ pctlpts=33 67;
run;
proc print data=perc_vea;
run;




*
In addition, for Lycopene, safe up to 75 mg/day (75,000 mcg/day) 
and for Lutein + zeaxanthin, safe up to 20 mg/day (20,000 mcg/day).;

proc univariate data=hpv_ms_v3 noprint;
   var A_caro;
   output out=perc_a_caro pctlpre=P_ pctlpts=33 67;
run;
proc print data=perc_a_caro;
run;



proc univariate data=hpv_ms_v3 noprint;
   var sele;
   output out=perc_sele pctlpre=P_ pctlpts=33 67;
run;
proc print data=perc_sele;
run;


proc univariate data=hpv_ms_v3 noprint;
   var lyco;
   output out=perc_lyco pctlpre=P_ pctlpts=33 67;
run;
proc print data=perc_lyco;
run;



proc univariate data=hpv_ms_v3 noprint;
   var lut_zeax;
   output out=perc_lut_zeax pctlpre=P_ pctlpts=33 67;
run;
proc print data=perc_lut_zeax;
run;





proc univariate data=hpv_ms_v3 noprint;
   var b_cryp;
   output out=perc_b_cryp pctlpre=P_ pctlpts=33 67;
run;
proc print data=perc_b_cryp;
run;



/*round to close 5*/
data p1.hpv_ms_v3;
set p1.hpv_ms_v3;


if LBDSTBSI=. then bili_g3=.;
else if LBDSTBSI<10 then bili_g3=0;
else if LBDSTBSI>15 then bili_g3=2;
else bili_g3=1;


if LBDFERSI=. then ferr_g3=.;
else if LBDFERSI<25 then ferr_g3=0;
else if LBDFERSI>45 then ferr_g3=2;
else ferr_g3=1;


if LBDSALSI=. then alb_g3=.;
else if LBDSALSI<40 then alb_g3=0;
else if LBDSALSI>45 then alb_g3=2;
else alb_g3=1;



if URXUMA=. then albu_g3=.;
else if URXUMA<5 then albu_g3=0;
else if URXUMA>15 then albu_g3=2;
else albu_g3=1;


if LBDSUASI=. then ua_g3=.;
else if LBDSUASI<270 then ua_g3=0;
else if LBDSUASI>350 then ua_g3=2;
else ua_g3=1;


if vit_A =. then va_g3=.;
else if vit_A <380 then va_g3=0;
else if vit_A >650 then va_g3=2;
else va_g3=1;

if vit_b2 =. then vb2_g3=.;
else if vit_b2 <1 then vb2_g3=0;
else if vit_b2 >2 then vb2_g3=2;
else vb2_g3=1;

if vit_c =. then vc_g3=.;
else if vit_c <45 then vc_g3=0;
else if vit_c >100 then vc_g3=2;
else vc_g3=1;




if vit_e =. then ve_g3=.;
else if vit_e <5 then ve_g3=0;
else if vit_e >10 then ve_g3=2;
else ve_g3=1;

if vit_e_add =. then vea_g3=.;
else if vit_e_add =0 then vea_g3=0;
else if vit_e_add >0 then vea_g3=1;


if a_caro =. then a_caro_g3=.;
else if a_caro <25 then a_caro_g3=0;
else if a_caro >170 then a_caro_g3=2;
else a_caro_g3=1;

if sele =. then sele_g3=.;
else if sele <75 then sele_g3=0;
else if sele >110 then sele_g3=2;
else sele_g3=1;

if lyco =. then lyco_g3=.;
else if lyco <1000 then lyco_g3=0;
else if lyco >4500 then lyco_g3=2;
else lyco_g3=1;

if lut_zeax =. then lut_zeax_g3=.;
else if lut_zeax <425 then lut_zeax_g3=0;
else if lut_zeax >930 then lut_zeax_g3=2;
else lut_zeax_g3=1;

if b_cryp =. then b_cryp_g3=.;
else if b_cryp <20 then b_cryp_g3=0;
else if b_cryp >80 then b_cryp_g3=2;
else b_cryp_g3=1;



if age=. then ag4=.;
else if age<18 or age>59 then ag4=.;
else if 18<=age<=26 then ag4=1;
else if 27<=age<=35 then ag4=2;
else if 36<=age<=45 then ag4=3;
else ag4=4;


if DMDMARTL in (77 99 .) then mari=.;
else if DMDMARTL in(1 6) then mari=1;
else if DMDMARTL=5 then mari=2;
else mari=3;

label
ag4='age in 4 categories, 1:18-26  2:27-35  3:36-45  4:46-59'
mari='marital status,  1:arried or living with partner
                       2:Never married
                       3:Widowed, Divorced, Separated'


bili_g3='three level category of bilirubin, 0:low 1:medium 2:high'
ferr_g3='three level category of ferritin, 0:low 1:medium 2:high'
alb_g3='three level category of albumin, 0:low 1:medium 2:high'
albu_g3='three level category of albumin urine, 0:low 1:medium 2:high'
ua_g3='three level category of uric acid, 0:low 1:medium 2:high'

va_g3='three level category of vit a, 0:low 1:medium 2:high'
vb2_g3='three level category of vit b2, 0:low 1:medium 2:high'
vc_g3='three level category of vit c, 0:low 1:medium 2:high'
ve_g3='three level category of vit e, 0:low 1:medium 2:high'
vea_g3='three level category of vit e added, 0:low 1:high'
a_caro_g3='three level category of alpha carotene, 0:low 1:medium 2:high'
sele_g3='three level category of selenium, 0:low 1:medium 2:high'
lyco_g3='three level category of lycopene, 0:low 1:medium 2:high'
lut_zeax_g3='three level category of Lutein + zeaxanthin, 0:low 1:medium 2:high'
b_cryp_g3='three level category of Beta-cryptoxanthin, 0:low 1:medium 2:high'


;
run;





/*

proc freq data=hpv_ms_g3;
tables elg_v*(bili_g3 ferr_g3 alb_g3 albu_g3 ua_g3
va_g3 vb2_g3 vc_g3 ve_g3 vea_g3 a_caro_g3 sele_g3
lyco_g3 lut_zeax_g3 b_cryp_g3);
run;

*/







/*
proc surveymeans data=hpv_ms_v3;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v;
 where hpv_g3=0;
 var age p_year;
run;


proc means data=hpv_ms_v3;
var p_year;

*/


proc surveyfreq data=p1.hpv_ms_v3;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v*(bili_g3 ferr_g3 alb_g3 albu_g3 ua_g3)/row chisq;
run;

proc surveyfreq data=p1.hpv_ms_v3;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 tables elg_v*(va_g3 vb2_g3 vc_g3 ve_g3 vea_g3 a_caro_g3 sele_g3
lyco_g3 lut_zeax_g3 b_cryp_g3)/row chisq;
run;





proc surveyfreq data=p1.hpv_ms_v3;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v*(bili_g3 ferr_g3 alb_g3 albu_g3 ua_g3)*hpv_g3/row chisq;
run;

proc surveyfreq data=p1.hpv_ms_v3;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 tables elg_v*(va_g3 vb2_g3 vc_g3 ve_g3 vea_g3 a_caro_g3 sele_g3
lyco_g3 lut_zeax_g3 b_cryp_g3)*hpv_g3/row chisq;
run;









/*
data p1.hpv_ms_v3;
set hpv_ms_v3; 
run;
*/


















/*06/02/20: multinomial model hpv_g3 VS antioxidant 3_level*/




%macro p_reg(var);
proc surveylogistic data=p1.hpv_ms_v3;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v;
 class &var. hpv_hr12/param=ref ref=first;
 model hpv_hr12(event='0')=&var./link=glogit df=infinity;
%mend p_reg;


%p_reg(bili_g3)
%p_reg(ferr_g3)
%p_reg(alb_g3)
%p_reg(albu_g3)
%p_reg(ua_g3)

run;



%macro p_reg1(var);
proc surveylogistic data=p1.hpv_ms_v3;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 domain elg_v;
 class &var. hpv_hr12/param=ref ref=first;
 model hpv_hr12(event='0')=&var./link=glogit df=infinity;
%mend p_reg1;

%p_reg1(va_g3)
%p_reg1(vb2_g3)
%p_reg1(vc_g3)
%p_reg1(ve_g3)
%p_reg1(vea_g3)
%p_reg1(a_caro_g3)
%p_reg1(sele_g3)
%p_reg1(lyco_g3)
%p_reg1(lut_zeax_g3)
%p_reg1(b_cryp_g3)
run;







/**UPDATED 05/02/2020**/


*freq for 3 category antioxidant;

proc surveyfreq data=p1.hpv_ms_v3;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v* (bili_g3 ferr_g3 alb_g3 albu_g3 ua_g3)/row chisq;
run;



proc surveyfreq data=p1.hpv_ms_v3;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 tables elg_v* (va_g3 vb2_g3 vc_g3 ve_g3 vea_g3 a_caro_g3
sele_g3 lyco_g3 lut_zeax_g3 b_cryp_g3)/row chisq;
run;



proc print data=hpv_ms_v3(obs=10);
var vit_e_add vea_g3;
run;





/**
proc surveymeans data=p1.hpv_ms_v3; 
 strata sdmvstra; 
 cluster sdmvpsu; 
 weight WTDRd1_14yr; 
 domain elg_v; 
 where hpv_g3=0; 
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp; 
run;


proc surveymeans data=p1.hpv_ms_v3; 
 strata sdmvstra; 
 cluster sdmvpsu; 
 weight WTDRd1_14yr; 
 domain elg_v ; 
 where hpv_g3=1; 
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp; 
run;

proc surveymeans data=p1.hpv_ms_v3; 
 strata sdmvstra; 
 cluster sdmvpsu; 
 weight WTDRd1_14yr; 
 domain elg_v; 
 where hpv_g3=2; 
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp; 
run;




proc surveymeans data=p1.hpv_ms_v3;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v;
 where hpv_g3=0;
 var LBDSTBSI LBDFERSI  LBDSALSI  URXUMA  LBDSUASI;
run;



proc surveymeans data=p1.hpv_ms_v3;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v ;
 where hpv_g3=1;
 var LBDSTBSI LBDFERSI  LBDSALSI  URXUMA  LBDSUASI;
run;




proc surveymeans data=p1.hpv_ms_v3;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v;
 where hpv_g3=2;
 var LBDSTBSI LBDFERSI  LBDSALSI  URXUMA  LBDSUASI;
run;


*/








proc contents data=p1.hpv_ms_v3;
run;





/*update 03/22/2020
Adding new data to masterfile "hpv_ms_v3"
Alcohol intake, smoking, general health and mental health
*****************/

/*transfer*/

%trans1(ALQ_C);
%trans1(ALQ_D);
%trans1(ALQ_E);
%trans1(ALQ_F);
%trans1(ALQ_G);
%trans1(ALQ_H);
%trans1(ALQ_I);


%trans1(SMQ_C);
%trans1(SMQ_D);
%trans1(SMQ_E);
%trans1(SMQ_F);
%trans1(SMQ_G);
%trans1(SMQ_H);
%trans1(SMQ_I);

%trans1(HSQ_C);
%trans1(HSQ_D);
%trans1(HSQ_E);
%trans1(HSQ_F);
%trans1(HSQ_G);
%trans1(HSQ_H);
%trans1(HSQ_I);


%trans1(DPQ_D);
%trans1(DPQ_E);
%trans1(DPQ_F);
%trans1(DPQ_G);
%trans1(DPQ_H);
%trans1(DPQ_I);

%trans1(L03_C);
%trans1(HIV_D);
%trans1(HIV_E);
%trans1(HIV_F);
%trans1(HIV_G);
%trans1(HIV_H);
%trans1(HIV_I);



data p1.ALQ_0316;
set p1.ALQ_C p1.ALQ_D p1.ALQ_E p1.ALQ_F p1.ALQ_G p1.ALQ_H p1.ALQ_I; 
run;

data p1.SMQ_0316;
set p1.SMQ_C p1.SMQ_D p1.SMQ_E p1.SMQ_F p1.SMQ_G p1.SMQ_H p1.SMQ_I; 
run;

data p1.HSQ_0316;
set p1.HSQ_C p1.HSQ_D p1.HSQ_E p1.HSQ_F p1.HSQ_G p1.HSQ_H p1.HSQ_I; 
run;

data p1.DPQ_0516;
set p1.DPQ_D p1.DPQ_E p1.DPQ_F p1.DPQ_G p1.DPQ_H p1.DPQ_I; 
run;

data p1.HIV_0316;
set p1.L03_C p1.HIV_D p1.HIV_E p1.HIV_F p1.HIV_G p1.HIV_H p1.HIV_I; 
run;



proc sort data=p1.ALQ_0316;   *use: ALQ120Q ALQ120U;
by seqn;
run;


proc sort data=p1.SMQ_0316;   
by seqn;
run;

proc sort data=p1.HSQ_0316;
by seqn;
run;

proc sort data=p1.DPQ_0516;
by seqn;
run;

proc sort data=p1.HIV_0316;
by seqn;
run;

data p1.hpv_ms_v4;     *This version includes log transform;
merge p1.hpv_ms_v3 p1.ALQ_0316 p1.SMQ_0316 p1.HSQ_0316 p1.DPQ_0516 p1.HIV_0316;
by seqn;
run;



data p1.hpv_ms_v4; 
set p1.hpv_ms_v4; 

*for general health;
if hsd010 in (7, 9, .) then ghealth=.;
else if hsd010 in (1,2) then ghealth=0;
else if hsd010=3 then ghealth=1;
else ghealth=2;


*for mental health;
if dpq010 in (7, 9, .) then dq1=0;
else dq1=dpq010;

if dpq020 in (7, 9, .) then dq2=0;
else dq2=dpq020;

if dpq030 in (7, 9, .) then dq3=0;
else dq3=dpq030;

if dpq040 in (7, 9, .) then dq4=0;
else dq4=dpq040;

if dpq050 in (7, 9, .) then dq5=0;
else dq5=dpq050;

if dpq060 in (7, 9, .) then dq6=0;
else dq6=dpq060;

if dpq070 in (7, 9, .) then dq7=0;
else dq7=dpq070;

if dpq080 in (7, 9, .) then dq8=0;
else dq8=dpq080;

if dpq090 in (7, 9, .) then dq9=0;
else dq9=dpq090;

if dpq010=dpq020=dpq030=dpq040=dpq050=dpq060=dpq070=dpq080=dpq090=. then dpscore=.;
else dpscore=dq1+dq2+dq3+dq4+dq5+dq6+dq7+dq8+dq9;



*major depression;
if dpscore=. then depression=.;
else if dpscore<10 then depression=0;
else depression=1;


*0-4 none, 5-9 mild, 10-14 moderate, 15-19 moderately severe, 20-27 severe;
if dpscore=. then dep_severe=.;
else if 0<=dpscore<=4 then dep_severe=0;
else if 5<=dpscore<=14 then dep_severe=1;
else dep_severe=2;


*for smoking;
 if smq020=7 or smq020=9 or smq020=. then eversmk=.;
 else if smq020=2 then eversmk=0;
 else eversmk=1;

 if smq040=7 or smq040=9 or smq040=. then nowsmk=.;
 else if smq040=3 then nowsmk=0;
 else nowsmk=1;

 if eversmk=0 then smk=0;
 else if eversmk=1 and nowsmk=0 then smk=1;
 else if eversmk=1 and nowsmk=1 then smk=2;
 else smk=.;



*for alcohol: 2003-2010 doesnt have data for 18-19 yrs;

if alq120q in (777, 999, .) then dfreq=.;
 else dfreq=alq120q; *0-365;

 if alq120u in (7, 9, .) then dunit=.;
 else if alq120u=1 then dunit=52;
 else if alq120u=2 then dunit=12;
 else dunit=1;
 
drink12=dfreq*dunit;

if alq101=. and drink12=. then au12=.;
else if alq101=2 or drink12=0 then au12=0;
else if 1<=drink12<=25 then au12=1;
else if drink12>25 then au12=2;





* for hiv;

 if lbdhi in (.,3) then hiv1=.;
 else if lbdhi=1 then hiv1=1;
 else hiv1=0;

 if lbxhivc=lbxhnat=. and lbxhiv1 in (3,.) and lbxhiv2 in (3,.) then hiv2=.;
 else if lbxhivc=1 or lbxhiv1=1 or lbxhiv2=1 or lbxhnat=1 then hiv2=1;
 else hiv2=0;

 if hiv1=hiv2=. then hiv=.;
 else if hiv=1 or hiv2=1 then hiv=1;
 else hiv=0;



* For drug use: 05-16 for 30days, 03-16 for lifetime;



if duq100 in (7,9,.) then durglf1=.;
else if duq100=1 then druglf1=1;
else druglf1=0;

if duq200 in (7,9,.) then coclf=.;
else marilf=duq200;

if duq240 in (7,9,.) then otherlf=.;
else otherlf=duq240;

if marilf=otherlf=. then druglf2=.;
else if marilf=1 or otherlf=1 then druglf2=1;
else if marilf=2 and otherlf=2 then druglf=0;
else druglf2=.;

if druglf1=druglf2=. then drug_lf=.;
else if druglf1=1 or druglf2=1 then druglf=1;
else druglf=0;





if druglf2=. and duq230 in (77,99,.) and duq280 in (77,99,.) and duq320 in (77,99,.) 
and duq360 in (77,99,.) then drug30=.;
else if druglf2=0 then drug30=0;
else drug30=1;





*updated 200615, recategorized;
 label
 ghealth='general health condition: 0=Excellent/Very good, 1=Good,	
          2=Fair/Poor'
 dpscore='depression queationare total score'
 depression='depression status: 0=no, 1=yes'
 dep_severe='depression severity: 0=none, 1=mild/moderate, 2=moderately severe/=severe'

 eversmk='>=100 cigarettes in life time, 0:NO, 1:Yes'
 smk='smoking status, 0:never(<100 in life time), 1:former, 2:current'

 hiv='hiv status: 1=positive 0=nonpositive'

 dfreq='frequency of drinking'
 dunit='unit of drinking frequency'
 drink12='total drinking for past 12 months'
 au12='days of alcohol usage in paet 12 month: 0=no, 1=1-25days, 2=25 days and more'

 drug30='any drug use in past 30 days: 1=yes 0=no'
 druglf='any drug use in lifetime: 1=yes 0=no'
;

run;





/* data dc;
set p1.hpv_ms_v4;
keep duq100 duq200 DUQ240 druglf1 druglf2 druglf;
run;


 data dc;
set p1.hpv_ms_v4;
keep DUQ230 duq280 duq320 duq360 duq400Q DUQ400U;
run;


 data dc;
set p1.hpv_ms_v4;
keep druglf DUQ230 duq280 duq320 duq360 drug30;
run;

proc univariate data=p1.hpv_ms_v4;
var drink12;
histogram;
run;
*/

proc surveyfreq data=p1.hpv_ms_v4; *yields table2/0b/0c/0d (06/08);
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v_a*pers_18*(ag4 edu pirg4 bmig3 mari race sex_p12 sex_lp ghealth depression smk druglf drug30 dep_severe au12 )/col chisq;
run;

proc surveyfreq data=p1.hpv_ms_v4; 
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v*(ag4 race edu pirg4 mari bmig3 sex_p12 sex_lp ghealth depression dep_severe  smk druglf drug30 au12 )/row;
run;


proc surveyfreq data=p1.hpv_ms_v5; 
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 tables elg_v_a*pers_g3_18*(ag4 race edu pirg4 mari bmig3 sex_p12 sex_lp ghealth depression dep_severe  smk druglf drug30 au12 )/col chisq;
run;

proc surveyfreq data=p1.hpv_ms_v4; 
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 tables elg_v_a*(ag4 race edu pirg4 mari bmig3 sex_p12 sex_lp ghealth depression dep_severe  smk druglf drug30 au12 )/row;
run;




proc surveylogistic data=p1.hpv_ms_v4; *past combo ;
strata sdmvstra;
cluster sdmvpsu;
weight wtmec14yr;
domain elg_v;
class  ag4(ref='1') edu(ref='1') pirg4(ref='1') 
mari(ref='1') race(ref='1') sex_p12(ref='0')
sex_lp(ref='0') smk(ref='0') druglf(ref='0') drug30(ref='0') au12(ref='0')/param=ref;
model hpv_g3(event='2')= ag4 edu pirg4 mari race sex_p12 smk drug30 au12/link=glogit df=infinity;
run;


proc surveylogistic data=p1.hpv_ms_v4; *mix;
strata sdmvstra;
cluster sdmvpsu;
weight wtmec14yr;
domain elg_v;
class  ag4(ref='1') edu(ref='1') pirg4(ref='1') 
mari(ref='1') race(ref='1') sex_p12(ref='0')
sex_lp(ref='0') 
smk(ref='0') druglf(ref='0') au12(ref='0')/param=ref;
model hpv_g3(event='2')= ag4 edu pirg4 mari race sex_p12 smk druglf au12/link=glogit df=infinity;
run;


proc surveylogistic data=p1.hpv_ms_v4; *lfsex only;
strata sdmvstra;
cluster sdmvpsu;
weight wtmec14yr;
domain elg_v;
class  ag4(ref='1') edu(ref='1') pirg4(ref='1') 
mari(ref='1') race(ref='1') sex_p12(ref='0')
sex_lp(ref='0')
smk(ref='0') au12(ref='0')/param=ref;
model hpv_g3(event='2')= ag4 edu pirg4 mari race sex_lp smk au12/link=glogit df=infinity;
run;






proc logistic data=p1.hpv_ms_v4; *past combo: 6718/11070;
where elg_v=1;
class  ag4(ref='1') edu(ref='1') pirg4(ref='1') 
mari(ref='1') race(ref='1') sex_p12(ref='0')
sex_lp(ref='0') smk(ref='0') druglf(ref='0') drug30(ref='0') au12(ref='0')/param=ref;
model hpv_g3(event='2')= ag4 edu pirg4 mari race sex_p12 smk drug30 au12/link=glogit df=infinity;
run;




proc logistic data=p1.hpv_ms_v4; *mix: 7694/11070;
where elg_v=1;
class  ag4(ref='1') edu(ref='1') pirg4(ref='1') 
mari(ref='1') race(ref='1') sex_p12(ref='0')
sex_lp(ref='0') 
smk(ref='0') druglf(ref='0') au12(ref='0')/param=ref;
model hpv_g3(event='2')= ag4 edu pirg4 mari race sex_p12 smk druglf au12/link=glogit df=infinity;
run;




proc logistic data=p1.hpv_ms_v4; *lfsex only: 7698/11070;
where elg_v=1;
class  ag4(ref='1') edu(ref='1') pirg4(ref='1') 
mari(ref='1') race(ref='1') sex_p12(ref='0')
sex_lp(ref='0')
smk(ref='0') au12(ref='0')/param=ref;
model hpv_g3(event='2')= ag4 edu pirg4 mari race sex_lp smk au12/link=glogit df=infinity;
run;














data domain20;
set p1.hpv_ms_v4;
if elg_v=1 and age>20 then elg_v2=1;
else elg_v2=0;
run;





proc logistic data=domain20;*past combo: 6582/9989;
where elg_v2=1;
class  ag4(ref='1') edu(ref='1') pirg4(ref='1') 
mari(ref='1') race(ref='1') sex_p12(ref='0')
sex_lp(ref='0') smk(ref='0') druglf(ref='0') drug30(ref='0') au12(ref='0')/param=ref;
model hpv_g3(event='2')= ag4 edu pirg4 mari race sex_p12 smk drug30 au12/link=glogit df=infinity;
run;



proc logistic data=domain20; *mix: 7533/9989;
where elg_v2=1;
class  ag4(ref='1') edu(ref='1') pirg4(ref='1') 
mari(ref='1') race(ref='1') sex_p12(ref='0')
sex_lp(ref='0') 
smk(ref='0') druglf(ref='0') au12(ref='0')/param=ref;
model hpv_g3(event='2')= ag4 edu pirg4 mari race sex_p12 smk druglf au12/link=glogit df=infinity;
run;




proc logistic data=domain20;*lfsex only: 7537/9989;
where elg_v2=1;
class  ag4(ref='1') edu(ref='1') pirg4(ref='1') 
mari(ref='1') race(ref='1') sex_p12(ref='0')
sex_lp(ref='0')
smk(ref='0') au12(ref='0')/param=ref;
model hpv_g3(event='2')= ag4 edu pirg4 mari race sex_lp smk au12/link=glogit df=infinity;
run;












%macro nutr_mean(var, nvar);
  if DR1T&var.=. and DR2T&var.=. then &nvar.=.;
  else if DR1T&var. ne . and DR2T&var.=. then &nvar.=DR1T&var.;
  else if DR1T&var.=.  and DR2T&var. ne . then &nvar.=DR2T&var.;
  else &nvar.=(DR1T&var.+DR2T&var.)/2;
%mend nutr_mean;



data p1.hpv_ms_v5;   *vd only have 07-16 cycles;
set p1.hpv_ms_v4;

/*** if only 1 day missing, then use the valid value from the other day instead */
%nutr_mean(VD, vit_D);
%nutr_mean(FDFE, folate);

label 
vit_D="average Vitamin D as retinol activity equivalents (mcg) "
folate="average folate as retinol activity equivalents (mcg) ";
run;



/***descriptive***/

proc means data=p1.hpv_ms_v5;
where elg_v=1;
var vit_D folate;
run;

proc surveymeans data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 domain elg_v ;
 var vit_D folate;
run;



proc means data=p1.hpv_ms_v5;
where elg_v=1 and elg_v_a=1;
var vit_D folate vit_A;
run;

data v5;
set p1.hpv_ms_v5;
if elg_v=1 and elg_v_a=1 then elg_both=1;
else elg_both=0;
run;
proc surveymeans data=v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 domain elg_both ;
 var vit_D folate vit_A;
run;

/*
log transform
*/
%macro nlog(var);
if &var=. then ln_&var.=. ;
else ln_&var.=log(&var.+0.0001);
%mend nlog;



data p1.hpv_ms_v5;
set p1.hpv_ms_v5;
%nlog(vit_D);
%nlog(folate);
run;



proc surveymeans data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 domain elg_v;
 where hpv_g3=0;
 var vit_D folate;
run;

proc surveymeans data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 domain elg_v;
 where hpv_g3=1;
 var vit_D folate;
run;

proc surveymeans data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 domain elg_v;
 where hpv_g3=2;
 var vit_D folate;
run;





%macro p_uni_hpv_hr12(var);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class hpv_hr12;
 domain elg_v ;
 model hpv_hr12(event='1')=&var.;
%mend p_uni_hpv_hr12;

%p_uni_hpv_hr12(ln_vit_D)
%p_uni_hpv_hr12(ln_folate)
run;




/*
data p1.hpv_ms_v5;
set p1.hpv_ms_v5;

if anti_g3=. then anti_hr12=.;
else if anti_g3=2 then anti_hr12=1;
else anti_hr12=0;

label
anti_hr12='HPV antibody (types 6,11,16,18), 1: high-risk 2 type, 0: others'
;
run;

*/








/*** 
8/29/2020 LinHY
paper Table 3
**/
*07/08/2020: multinomial controled for demo for each marker: Table M4;
%macro p_multi09(var);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0')/param=ref;
 domain elg_v ;
 model hpv_g3=&var. ag4 edu pirg4 mari race sex_p12 smk druglf au12/link=glogit df=infinity;
%mend p_multi09;


%p_multi09(ln_LBDSTBSI)
%p_multi09(ln_LBDFERSI)
%p_multi09(ln_LBDSALSI);
%p_multi09(ln_URXUMA)
%p_multi09(ln_LBDSUASI)
run;


/* 
%macro p_multi09(var);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
  smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0')/param=ref;
 domain elg_v ;
 model hpv_g3=&var. ag4 edu pirg4 mari race sex_p12 smk druglf au12/link=glogit df=infinity ;
%mend p_multi09;
*/
/* drop  df=infinity */;

/*** why not bMI
In the 10-factor model, Bmi is not significant
****/;

proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
  smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') bmig3 (ref='1')/param=ref;
 domain elg_v ;
 model hpv_g3=ag4 edu pirg4 mari race sex_p12 smk druglf au12 bmig3/link=glogit   ;
run;
/* 9-factor, drop BMI, all other 9 factros were significant */
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
  smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') /param=ref;
 domain elg_v ;
 model hpv_g3=ag4 edu pirg4 mari race sex_p12 smk druglf au12 /link=glogit   ;
run;

%macro p_multi09a(var);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
  smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0')/param=ref;
 domain elg_v ;
 model hpv_g3=ag4 edu pirg4 mari race sex_p12 smk druglf au12 &var./link=glogit   ;
%mend p_multi09a;



%p_multi09a(ln_vit_A);
%p_multi09a(ln_vit_b2);
%p_multi09a(ln_vit_C)
%p_multi09a(ln_vit_E_add)
%p_multi09a(ln_vit_E);
%p_multi09a(ln_A_caro)
%p_multi09a(ln_sele)
%p_multi09a(ln_lyco)
%p_multi09a(ln_lut_zeax)
%p_multi09a(ln_B_cryp)
%p_multi09a(ln_vit_d)
%p_multi09a(ln_folate);

run;

/*** check for HPV16 infection only 

ln_vit_a is not associated with HPV_type16
***/;
/** 14 yr **/
proc surveylogistic data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
  smk(ref='0') druglf(ref='0') au12(ref='0') hpv_type16(ref='0')/param=ref;
 domain elg_v ;
 model hpv_type16=ag4 edu pirg4 mari race sex_p12 smk druglf au12 ln_vit_A/link=glogit   ;
run;
proc surveylogistic data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
  smk(ref='0') druglf(ref='0') au12(ref='0') hpv_type16(ref='0')/param=ref;
 domain elg_v ;
 model hpv_type18=ag4 edu pirg4 mari race sex_p12 smk druglf au12 ln_vit_A/link=glogit   ;
run;
/** 8 yr, elg_v_a=1 ***/;
  proc surveylogistic data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
  smk(ref='0') druglf(ref='0') au12(ref='0') hpv_type16(ref='0')/param=ref;
 domain elg_v_a ;
 model hpv_type16=ag4 edu pirg4 mari race sex_p12 smk druglf au12 ln_vit_A/link=glogit   ;
run;

proc contents data=hpv_ms;
 run;
proc print data=hpv_Ms (obs=20);
 where vit_d ne .;
 var ln_vit_d vit_D;
 run;

proc freq data=hpv_Ms;
 where elg_v=1;
 table vit_d;
 run;

 proc means data=hpv_ms;
 where elg_v=1;
  var vit_d ln_vit_d ln_vit_a;
  run;

     
/** check sample size of models
LBDSTBSI
LBDFERSI
LBDSALSI
URXUMA
LBDSUASI

 */
proc logistic data=p1.hpv_ms_v5;
class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0')/param=ref;
where elg_v=1;
model hpv_g3= ag4 edu pirg4 mari race sex_p12 smk druglf au12 ln_vit_d/link=glogit;
run;





*07/15/2020: multinomial controled for demo for each marker, age>20 as sensitivity test;
data hpv_ms_v5;
set p1.hpv_ms_v5;
if elg_v=1 and age>20 then elgv20=1;
else elgv20=0;
run;

%macro p_multi(var);
proc surveylogistic data=hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0')/param=ref;
 domain elgv20 ;
 model hpv_g3(event='0')=&var. ag4 edu pirg4 mari race sex_p12 smk druglf au12/
link=glogit df=infinity;
%mend p_multi;


%p_multi(ln_LBDSTBSI)
%p_multi(ln_LBDFERSI)
%p_multi(ln_LBDSALSI)
%p_multi(ln_URXUMA)
%p_multi(ln_LBDSUASI)
run;







%macro p_multi(var);
proc surveylogistic data=hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0')/param=ref;
 domain elgv20 ;
 model hpv_g3(event='0')=&var. ag4 edu pirg4 mari race sex_p12 smk druglf au12/
link=glogit df=infinity;
%mend p_multi;
%p_multi(ln_vit_A)
%p_multi(ln_vit_b2)
%p_multi(ln_vit_C)
%p_multi(ln_vit_E_add)
%p_multi(ln_vit_E)
%p_multi(ln_A_caro)
%p_multi(ln_sele)
%p_multi(ln_lyco)
%p_multi(ln_lut_zeax)
%p_multi(ln_B_cryp)
run;
     



*07/15/2020: multinomial controled for demo for each marker, delete cov with small sample size;



%macro p_multi06(var);
proc surveylogistic data=hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1')
smk(ref='0') hpv_g3(ref='0')/param=ref;
 domain elg_v ;
 model hpv_g3(event='0')=&var. ag4 edu pirg4 mari race  smk/link=glogit df=infinity;
%mend p_multi06;


%p_multi06(ln_LBDSTBSI)
%p_multi06(ln_LBDFERSI)
%p_multi06(ln_LBDSALSI)
%p_multi06(ln_URXUMA)
%p_multi06(ln_LBDSUASI)
run;







%macro p_multi06(var);
proc surveylogistic data=hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') 
 smk(ref='0') hpv_g3(ref='0')/param=ref;
 domain elg_v;
 model hpv_g3(event='0')=&var. ag4 edu pirg4 mari race  smk /link=glogit df=infinity;
%mend p_multi06;
%p_multi06(ln_vit_A)
%p_multi06(ln_vit_b2)
%p_multi06(ln_vit_C)
%p_multi06(ln_vit_E_add)
%p_multi06(ln_vit_E)
%p_multi06(ln_A_caro)
%p_multi06(ln_sele)
%p_multi06(ln_lyco)
%p_multi06(ln_lut_zeax)
%p_multi06(ln_B_cryp)
run;
     







proc surveyfreq data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 where elg_v=1;
table ag4 edu pirg4 mari race sex_p12 smk druglf au12/chisq;
run;




proc surveylogistic data=hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 sex_lp(ref='0') smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0')/param=ref;
 domain elgv20 ;
 model hpv_g3(event='0')=&var. ag4 edu pirg4 mari race sex_p12 smk druglf au12/link=glogit ;




 proc surveylogistic data=hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 sex_lp(ref='0') smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0')/param=ref;
 domain elgv20 ;
 model hpv_g3(event='0')=ln_vit_a ag4 edu pirg4 mari race sex_p12 smk druglf au12/link=glogit ;





/*exact p-value*/
 ods path sasuser.templat(update) sashelp.tmplmst(read); 
proc template; 
   edit Common.PValue; 
      notes "Default p-value column"; 
      just = r; 
      format = pvalue32.30; 
   end; 
run; 

 proc logistic data=hpv_ms_v5 ;
class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 sex_lp(ref='0') smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0')/param=ref;
 where elg_v=1 ;
 model hpv_g3(event='0')=ag4 edu pirg4 mari race sex_p12 smk druglf au12/link=glogit alpha=0.05;



 ods path sasuser.templat(update) sashelp.tmplmst(read); 
proc template; 
   edit Common.PValue; 
      notes "Default p-value column"; 
      just = r; 
      format = pvalue6.4; 
   end; 
run; 







*********************multinomial with 9 cov for 3-level markers*********************;

%macro p_multi09_g3(var);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') &var.(ref='0')/param=ref;
 domain elg_v ;
 model hpv_g3=&var. ag4 edu pirg4 mari race sex_p12 smk druglf au12/link=glogit df=infinity;
%mend p_multi09_g3;


%p_multi09_g3(bili_g3)
%p_multi09_g3(ferr_g3)
%p_multi09_g3(alb_g3)
%p_multi09_g3(albu_g3)
%p_multi09_g3(ua_g3)





%macro p_multi09_g3(var);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
  smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') &var.(ref='0')/param=ref;
 domain elg_v ;
 model hpv_g3=&var. ag4 edu pirg4 mari race sex_p12 smk druglf au12/link=glogit df=infinity;
%mend p_multi09_g3;

%p_multi09_g3(va_g3)
%p_multi09_g3(vb2_g3)
%p_multi09_g3(vc_g3)
%p_multi09_g3(ve_g3)
%p_multi09_g3(vea_g3)
%p_multi09_g3(a_caro_g3)
%p_multi09_g3(sele_g3)
%p_multi09_g3(lyco_g3)
%p_multi09_g3(lut_zeax_g3)
%p_multi09_g3(b_cryp_g3)
run;





%macro p_uni_g3(var);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_g3(ref='0') &var.(ref='0')/param=ref;
 domain elg_v ;
 model hpv_g3=&var. /link=glogit df=infinity;
%mend p_uni_g3;


%p_uni_g3(bili_g3)
%p_uni_g3(ferr_g3)
%p_uni_g3(alb_g3)
%p_uni_g3(albu_g3)
%p_uni_g3(ua_g3)





%macro p_uni_g3(var);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class hpv_g3(ref='0') &var.(ref='0')/param=ref;
 domain elg_v ;
 model hpv_g3=&var. /link=glogit df=infinity;
%mend p_uni_g3;

%p_uni_g3(va_g3)
%p_uni_g3(vb2_g3)
%p_uni_g3(vc_g3)
%p_uni_g3(ve_g3)
%p_uni_g3(vea_g3)
%p_uni_g3(a_caro_g3)
%p_uni_g3(sele_g3)
%p_uni_g3(lyco_g3)
%p_uni_g3(lut_zeax_g3)
%p_uni_g3(b_cryp_g3)
run;










/*****************
Persistent status 
and biomarkers: add label
*****************/


data p1.hpv_ms_v5;
set p1.hpv_ms_v5;  

drop pers_g3_08;

if pers_06=. then pers_g3_06=.;
else if pers_06 in (1,2) then pers_g3_06=0;
else if pers_06=3 then pers_g3_06=1;
else pers_g3_06=2;

if pers_11=. then pers_g3_11=.;
else if pers_11 in (1,2) then pers_g3_11=0;
else if pers_11=3 then pers_g3_11=1;
else pers_g3_11=2;

if pers_16=. then pers_g3_16=.;
else if pers_16 in (1,2) then pers_g3_16=0;
else if pers_16=3 then pers_g3_16=1;
else pers_g3_16=2;

if pers_18=. then pers_g3_18=.;
else if pers_18 in (1,2) then pers_g3_18=0;
else if pers_18=3 then pers_g3_18=1;
else pers_g3_18=2;

if pers_06=pers_11=pers_16=pers_18=. then pers_inf=.;
else if pers_06=4 or pers_11=4 or pers_16=4 or pers_18=4 then pers_inf=1;
else if pers_06=3 or pers_11=3 or pers_16=3 or pers_18=3 then pers_inf=0;
else pers_inf=.;


if pers_06=pers_11=pers_16=pers_18=. then pers=.;
else if pers_06=4 or pers_11=4 or pers_16=4 or pers_18=4 then pers=2;
else if pers_06=3 or pers_11=3 or pers_16=3 or pers_18=3 then pers=1;
else pers=0;



label 
pers_06='persistnet HPV-06 (vaginal, antibody), 1:neg,neg, 2:neg,pos, 3:transient inf, 4: persistent inf' 
pers_11='persistnet HPV-11 (vaginal, antibody), 1:neg,neg, 2:neg,pos, 3:transient inf, 4: persistent inf' 
pers_16='persistnet HPV-16 (vaginal, antibody), 1:neg,neg, 2:neg,pos, 3:transient inf, 4: persistent inf' 
pers_18='persistnet HPV-18 (vaginal, antibody), 1:neg,neg, 2:neg,pos, 3:transient inf, 4: persistent inf' 

pers_g2_06='persistnet HPV-06, 0: no persistent (negative + transicent), 1: persistent'
pers_g2_11='persistnet HPV-11, 0: no persistent (negative + transicent), 1: persistent'
pers_g2_16='persistnet HPV-16, 0: no persistent (negative + transicent), 1: persistent'
pers_g2_18='persistnet HPV-18, 0: no persistent (negative + transicent), 1: persistent'

pers_g3_06='persistnet HPV-06, 0: negative, 1:transicent, 2: persistent'
pers_g3_11='persistnet HPV-11, 0: negative, 1:transicent, 2: persistent'
pers_g3_16='persistnet HPV-16, 0: negative, 1:transicent, 2: persistent'
pers_g3_18='persistnet HPV-18, 0: negative, 1:transicent, 2: persistent'

pers_in_inf_06='persistnet HPV-06 for those with infection, 0:transient inf, 1: persistent inf' 
pers_in_inf_11='persistnet HPV-11 for those with infection, 0:transient inf, 1: persistent inf' 
pers_in_inf_16='persistnet HPV-16 for those with infection, 0:transient inf, 1: persistent inf' 
pers_in_inf_18='persistnet HPV-18 for those with infection, 0:transient inf, 1: persistent inf' 

pers_inf='persistnet for those with infection, 0:transient inf, 1: persistent inf'
pers='persistnet for all, 0: no inf 1:transient inf, 2: persistent inf';
  ;
  run;
  proc freq data=p1.hpv_ms_v5;
  tables pers_in_inf_06 pers_in_inf_11 pers_in_inf_16 pers_in_inf_18 ;
  run;




proc freq data=p1.hpv_ms_v5;
tables pers_inf pers;
run;


















%macro uni_pers1(var1,var2);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 domain elg_v_a ;
 model &var1.(ref='0')=&var2./link=glogit DF=INFINITY;
%mend uni_pers1;

%macro uni_pers2(var1,var2);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a ;
 model &var1.(ref='0')=&var2./link=glogit DF=INFINITY;
%mend uni_pers2;


%uni_pers1(pers_in_inf_06,ln_LBDSTBSI)
%uni_pers1(pers_in_inf_06,ln_LBDFERSI)
%uni_pers1(pers_in_inf_06,ln_LBDSALSI)
%uni_pers1(pers_in_inf_06,ln_URXUMA)
%uni_pers1(pers_in_inf_06,ln_LBDSUASI)
run;

%uni_pers1(pers_in_inf_16,ln_LBDSTBSI)
%uni_pers1(pers_in_inf_16,ln_LBDFERSI)
%uni_pers1(pers_in_inf_16,ln_LBDSALSI)
%uni_pers1(pers_in_inf_16,ln_URXUMA)
%uni_pers1(pers_in_inf_16,ln_LBDSUASI)
run;

%uni_pers1(pers_in_inf_18,ln_LBDSTBSI)
%uni_pers1(pers_in_inf_18,ln_LBDFERSI)
%uni_pers1(pers_in_inf_18,ln_LBDSALSI)
%uni_pers1(pers_in_inf_18,ln_URXUMA)
%uni_pers1(pers_in_inf_18,ln_LBDSUASI)
run;



%uni_pers2(pers_in_inf_06,ln_vit_A)
%uni_pers2(pers_in_inf_06,ln_vit_b2)
%uni_pers2(pers_in_inf_06,ln_vit_C)
%uni_pers2(pers_in_inf_06,ln_vit_E_add)
%uni_pers2(pers_in_inf_06,ln_vit_E)
%uni_pers2(pers_in_inf_06,ln_A_caro)
%uni_pers2(pers_in_inf_06,ln_sele)
%uni_pers2(pers_in_inf_06,ln_lyco)
%uni_pers2(pers_in_inf_06,ln_lut_zeax)
%uni_pers2(pers_in_inf_06,ln_B_cryp)
run;

%uni_pers2(pers_in_inf_16,ln_vit_A)
%uni_pers2(pers_in_inf_16,ln_vit_b2)
%uni_pers2(pers_in_inf_16,ln_vit_C)
%uni_pers2(pers_in_inf_16,ln_vit_E_add)
%uni_pers2(pers_in_inf_16,ln_vit_E)
%uni_pers2(pers_in_inf_16,ln_A_caro)
%uni_pers2(pers_in_inf_16,ln_sele)
%uni_pers2(pers_in_inf_16,ln_lyco)
%uni_pers2(pers_in_inf_16,ln_lut_zeax)
%uni_pers2(pers_in_inf_16,ln_B_cryp)
run;

%uni_pers2(pers_in_inf_18,ln_vit_A)
%uni_pers2(pers_in_inf_18,ln_vit_b2)
%uni_pers2(pers_in_inf_18,ln_vit_C)
%uni_pers2(pers_in_inf_18,ln_vit_E_add)
%uni_pers2(pers_in_inf_18,ln_vit_E)
%uni_pers2(pers_in_inf_18,ln_A_caro)
%uni_pers2(pers_in_inf_18,ln_sele)
%uni_pers2(pers_in_inf_18,ln_lyco)
%uni_pers2(pers_in_inf_18,ln_lut_zeax)
%uni_pers2(pers_in_inf_18,ln_B_cryp)
run;






***********Table D3b D3c: p-value part************;

%macro multinomial_uni_pers1(var1,var2);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 domain elg_v_a ;
 class &var1.(ref='0')/param=ref;
 model &var1.(event='0')=&var2./link=glogit DF=INFINITY;
%mend multinomial_uni_pers1;

%macro multinomial_uni_pers2(var1,var2);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a ;
 class &var1.(ref='0')/param=ref;
 model &var1.(event='0')=&var2./link=glogit DF=INFINITY;
%mend multinomial_uni_pers2;




%multinomial_uni_pers1(pers_g3_06,ln_LBDSTBSI)
%multinomial_uni_pers1(pers_g3_06,ln_LBDFERSI)
%multinomial_uni_pers1(pers_g3_06,ln_LBDSALSI)
%multinomial_uni_pers1(pers_g3_06,ln_URXUMA)
%multinomial_uni_pers1(pers_g3_06,ln_LBDSUASI)
run;


%multinomial_uni_pers2(pers_g3_06,ln_vit_A)
%multinomial_uni_pers2(pers_g3_06,ln_vit_b2)
%multinomial_uni_pers2(pers_g3_06,ln_vit_C)
%multinomial_uni_pers2(pers_g3_06,ln_vit_E_add)
%multinomial_uni_pers2(pers_g3_06,ln_vit_E)
%multinomial_uni_pers2(pers_g3_06,ln_A_caro)
%multinomial_uni_pers2(pers_g3_06,ln_sele)
%multinomial_uni_pers2(pers_g3_06,ln_lyco)
%multinomial_uni_pers2(pers_g3_06,ln_lut_zeax)
%multinomial_uni_pers2(pers_g3_06,ln_B_cryp)
%multinomial_uni_pers2(pers_g3_06,ln_vit_D)
%multinomial_uni_pers2(pers_g3_06,folate)
run;






%multinomial_uni_pers1(pers_g3_16,ln_LBDSTBSI)
%multinomial_uni_pers1(pers_g3_16,ln_LBDFERSI)
%multinomial_uni_pers1(pers_g3_16,ln_LBDSALSI)
%multinomial_uni_pers1(pers_g3_16,ln_URXUMA)
%multinomial_uni_pers1(pers_g3_16,ln_LBDSUASI)
run;
%multinomial_uni_pers2(pers_g3_16,ln_vit_A)
%multinomial_uni_pers2(pers_g3_16,ln_vit_b2)
%multinomial_uni_pers2(pers_g3_16,ln_vit_C)
%multinomial_uni_pers2(pers_g3_16,ln_vit_E_add)
%multinomial_uni_pers2(pers_g3_16,ln_vit_E)
%multinomial_uni_pers2(pers_g3_16,ln_A_caro)
%multinomial_uni_pers2(pers_g3_16,ln_sele)
%multinomial_uni_pers2(pers_g3_16,ln_lyco)
%multinomial_uni_pers2(pers_g3_16,ln_lut_zeax)
%multinomial_uni_pers2(pers_g3_16,ln_B_cryp)
%multinomial_uni_pers2(pers_g3_16,ln_vit_D)
%multinomial_uni_pers2(pers_g3_16,folate)
run;






%multinomial_uni_pers1(pers_g3_18,ln_LBDSTBSI)
%multinomial_uni_pers1(pers_g3_18,ln_LBDFERSI)
%multinomial_uni_pers1(pers_g3_18,ln_LBDSALSI)
%multinomial_uni_pers1(pers_g3_18,ln_URXUMA)
%multinomial_uni_pers1(pers_g3_18,ln_LBDSUASI)
run;

%multinomial_uni_pers2(pers_g3_18,ln_vit_A)
%multinomial_uni_pers2(pers_g3_18,ln_vit_b2)
%multinomial_uni_pers2(pers_g3_18,ln_vit_C)
%multinomial_uni_pers2(pers_g3_18,ln_vit_E_add)
%multinomial_uni_pers2(pers_g3_18,ln_vit_E)
%multinomial_uni_pers2(pers_g3_18,ln_A_caro)
%multinomial_uni_pers2(pers_g3_18,ln_sele)
%multinomial_uni_pers2(pers_g3_18,ln_lyco)
%multinomial_uni_pers2(pers_g3_18,ln_lut_zeax)
%multinomial_uni_pers2(pers_g3_18,ln_B_cryp)
%multinomial_uni_pers2(pers_g3_18,ln_vit_D)
%multinomial_uni_pers2(pers_g3_18,folate)
run;










*Combine levels of demo to avoid quasi-completion;


*
ag4(ref='1') edu(ref='1') pirg4(ref='1') 
mari(ref='1') race(ref='1') bmig3(ref='1') sex_p12(ref='0')
sex_lp(ref='0') ghealth(ref='0') depression(ref='0') dep_severe(ref='0')
smk(ref='0') druglf(ref='0') drug30(ref='0') au12(ref='0')/param=ref;

proc freq data=quasi_check;
 table ag4 y35  edu  college mari alone race white sex_p12 sex1;
 run;




data quasi_check;
*set p1.hpv_ms_v5;
set p1.hpv_ms_v6;

if ag4=. then y35=.;
else if ag4 in (1,2) then y35=0;
else y35=1;

if edu=. then college=.;
else if edu in (1,2) then college=0;
else college=1;
 
if pirg4=. then pirg2=.;
else if pirg4 in (1,2) then pirg2=0;
else pirg2=1;

if bmig3=. then overweight=.;
else if bmig3=1 then overweight=0;
else overweight=1;

if mari=. then alone=.;
else if mari=1 then alone=0;
else alone=1;

if race=. then white=.;
else if race=1 then white=1;
else white=0;

if sex_p12 =. then sex1=.;
else if sex_p12 in (0,1) then sex1=0;
else sex1=1;

*use eversmk to demonstrate smoke;

if au12=. then aupy=.;
else if au12=0 then aupy=0;
else aupy=1;

if ghealth=. then poorh=.;
else if ghealth=2 then poorh=1;
else poorh=0;


label 
y35='35 years or older, 0:no, 1:yes'
college='>high school, 0:no, 1:yes'
pirg2='poverty index ratio, 0:<=2; 1:>2'
overweight='bmi>25, 0:no; 1:yes'
alone='not married or live with partner, 0:no, 1:yes' 
white='white, 0:no, 1:yes' 
poorh='fair or poor health: 0:no, 1:yes'
aupy='alcohol use in past 12 month, 0:no, 1:yes'
sex1='have more than one sexual partner past year'
;

run;

proc freq data=quasi_check;
where elg_v_a=1;
table y35 college pirg2 overweight alone race3 poorh aupy;
run;


proc surveyfreq data=quasi_check; 
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 tables elg_v_a*pers_g3_18*(y35 college pirg2 overweight alone white poorh aupy)/col chisq;
run;

%macro pers_demo11(var1, var2);
proc surveylogistic data=quasi_check; 
strata sdmvstra;
cluster sdmvpsu;
weight wtmec8yr;
domain elg_v_a;
class  &var1. &var2./param=ref ref=first;
model &var1.(event='0')= &var2./link=glogit  DF=INFINITY;
%mend pers_demo11;

%pers_demo11(pers_g3_06,y35);
%pers_demo11(pers_g3_06,white);
%pers_demo11(pers_g3_06,college);
%pers_demo11(pers_g3_06,pirg2);
%pers_demo11(pers_g3_06,alone);
%pers_demo11(pers_g3_06,overweight);
%pers_demo11(pers_g3_06,sex_p12);
%pers_demo11(pers_g3_06,poorh);
%pers_demo11(pers_g3_06,depression);
%pers_demo11(pers_g3_06,eversmk);
%pers_demo11(pers_g3_06,druglf);
%pers_demo11(pers_g3_06,aupy);


%pers_demo11(pers_g3_16,y35);
%pers_demo11(pers_g3_16,white);
%pers_demo11(pers_g3_16,college);
%pers_demo11(pers_g3_16,pirg2);
%pers_demo11(pers_g3_16,alone);
%pers_demo11(pers_g3_16,overweight);
%pers_demo11(pers_g3_16,sex_p12);
%pers_demo11(pers_g3_16,poorh);
%pers_demo11(pers_g3_16,depression);
%pers_demo11(pers_g3_16,eversmk);
%pers_demo11(pers_g3_16,druglf);
%pers_demo11(pers_g3_16,aupy);


%pers_demo11(pers_g3_18,y35);
%pers_demo11(pers_g3_18,white);
%pers_demo11(pers_g3_18,college);
%pers_demo11(pers_g3_18,pirg2);
%pers_demo11(pers_g3_18,alone);
%pers_demo11(pers_g3_18,overweight);
%pers_demo11(pers_g3_18,sex_p12);
%pers_demo11(pers_g3_18,poorh);
%pers_demo11(pers_g3_18,depression);
%pers_demo11(pers_g3_18,eversmk);
%pers_demo11(pers_g3_18,druglf);
%pers_demo11(pers_g3_18,aupy);

run;





data hpv_ms;
set p1.hpv_ms_v5;

%macro wtmeans_pers_no(var);
proc surveymeans data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 domain elg_v_a ;
 where &var.=0;
 var LBDSTBSI LBDFERSI  LBDSALSI  URXUMA  LBDSUASI;
%mend wtmeans_pers_no;
run;

%wtmeans_pers_no(pers_g3_06);
%wtmeans_pers_no(pers_g3_11);
%wtmeans_pers_no(pers_g3_16);
%wtmeans_pers_no(pers_g3_18);
run;


%macro wtmeans_pers_trans(var);
proc surveymeans data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 domain elg_v_a ;
 where &var.=1;
 var LBDSTBSI LBDFERSI  LBDSALSI  URXUMA  LBDSUASI;
%mend wtmeans_pers_trans;
run;

%wtmeans_pers_trans(pers_g3_06);
%wtmeans_pers_trans(pers_g3_11);
%wtmeans_pers_trans(pers_g3_16);
%wtmeans_pers_trans(pers_g3_18);
run;


%macro wtmeans_pers_per(var);
proc surveymeans data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 domain elg_v_a ;
 where &var.=2;
 var LBDSTBSI LBDFERSI  LBDSALSI  URXUMA  LBDSUASI;
%mend wtmeans_pers_per;
run;


%wtmeans_pers_per(pers_g3_06);
%wtmeans_pers_per(pers_g3_11);
%wtmeans_pers_per(pers_g3_16);
%wtmeans_pers_per(pers_g3_18);
run;


proc surveymeans data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a ;
 class pers_g3_16;
 var vit_A;
run;

%macro wtmeans2_pers_no(var);
proc surveymeans data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a ;
 where &var.=0;
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp;
%mend wtmeans2_pers_no;
run;

%wtmeans2_pers_no(pers_g3_06);
%wtmeans2_pers_no(pers_g3_11);
%wtmeans2_pers_no(pers_g3_16);
%wtmeans2_pers_no(pers_g3_18);
run;


%macro wtmeans2_pers_trans(var);
proc surveymeans data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a ;
 where &var.=1;
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp;
%mend wtmeans2_pers_trans;
run;

%wtmeans2_pers_trans(pers_g3_06);
%wtmeans2_pers_trans(pers_g3_11);
%wtmeans2_pers_trans(pers_g3_16);
%wtmeans2_pers_trans(pers_g3_18);
run;


%macro wtmeans2_pers_per(var);
proc surveymeans data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a ;
 where &var.=2;
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp;
%mend wtmeans2_pers_per;
run;

%wtmeans2_pers_per(pers_g3_06);
%wtmeans2_pers_per(pers_g3_11);
%wtmeans2_pers_per(pers_g3_16);
%wtmeans2_pers_per(pers_g3_18);
run;


************Type specific mean&se: D3b D3c************;

data p0_16;
set p1.hpv_ms_v5;
where pers_g3_16=0;
run;

data p1_16;
set p1.hpv_ms_v5;
where pers_g3_16=0;
run;

data p2_16;
set p1.hpv_ms_v5;
where pers_g3_16=2;
run;


data p0_18;
set p1.hpv_ms_v5;
where pers_g3_18=0;
run;

data p1_18;
set p1.hpv_ms_v5;
where pers_g3_18=1;
run;

data p2_18;
set p1.hpv_ms_v5;
where pers_g3_18=2;
run;



proc surveymeans data=p0_16;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 domain elg_v_a ;
 var LBDSTBSI LBDFERSI  LBDSALSI  URXUMA  LBDSUASI;
run;

proc surveymeans data=p0_16;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a ;
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp vit_D folate;
run;




/***
Why ln_LBDSALSI vs. pers_g3_18 had wide CI: 15.32 (0.04->999.99) even for unadjsuted OR 
*****/;

proc means data=p1.hpv_ms_v6;
 where  elg_v_a=1 ;
 class pers_g3_18;
  var ln_LBDSALSI;
  run;

%macro p_uni_pers_g3(var1, var2);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight &var1.;
 *class pers_g3_06(ref='0')/param=ref;
 class pers_g3_18(ref='0')/param=ref;
 domain elg_v_a ;
 model pers_g3_18(event='2')=&var2./link=glogit df=infinity;
%mend p_uni_pers_g3;


%p_uni_pers_g3(wtmec8yr,ln_LBDSTBSI)
%p_uni_pers_g3(wtmec8yr,ln_LBDFERSI)
%p_uni_pers_g3(wtmec8yr,ln_LBDSALSI);
%p_uni_pers_g3(wtmec8yr,ln_URXUMA)
%p_uni_pers_g3(wtmec8yr,ln_LBDSUASI)

%p_uni_pers_g3(WTDRd1_8yr,ln_vit_A)
%p_uni_pers_g3(WTDRd1_8yr,ln_vit_b2)
%p_uni_pers_g3(WTDRd1_8yr,ln_vit_C)
%p_uni_pers_g3(WTDRd1_8yr,ln_vit_E_add)
%p_uni_pers_g3(WTDRd1_8yr,ln_vit_E)
%p_uni_pers_g3(WTDRd1_8yr,ln_A_caro)
%p_uni_pers_g3(WTDRd1_8yr,ln_sele)
%p_uni_pers_g3(WTDRd1_8yr,ln_lyco)
%p_uni_pers_g3(WTDRd1_8yr,ln_lut_zeax)
%p_uni_pers_g3(WTDRd1_8yr,ln_B_cryp)
%p_uni_pers_g3(WTDRd1_8yr,ln_vit_D)
%p_uni_pers_g3(WTDRd1_8yr,ln_folate)
run;


*
y35(ref='0') pirg2(ref='0') alone(ref='0') overweight(ref='0') 
sex1(ref='0') eversmk(ref='0') druglf(ref='0') aupy(ref='0')
pers_g3_16(ref='0') 

y35 pirg2 alone overweight sex1 eversmk druglf aupy 

;


proc surveylogistic data=quasi_check; 
strata sdmvstra;
cluster sdmvpsu;
weight wtmec8yr;
domain elg_v_a;
class y35(ref='0') alone(ref='0')  
      sex1(ref='0')  druglf(ref='0') 
      pers_g3_16(ref='0') /param=ref;
model pers_g3_16(event='0')=  y35 alone sex1 druglf 
/link=glogit  DF=INFINITY;
run;



proc surveylogistic data=quasi_check; 
strata sdmvstra;
cluster sdmvpsu;
weight wtmec8yr;
domain elg_v_a;
class y35(ref='0')   
sex1(ref='0') eversmk(ref='0') 
pers_g3_18(ref='0')  /param=ref;
model pers_g3_18(event='0')=  y35  sex1 eversmk 
/link=glogit  DF=INFINITY;
run;



proc surveylogistic data=quasi_check; 
strata sdmvstra;
cluster sdmvpsu;
weight wtmec8yr;
domain elg_v_a;
class y35(ref='0') alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') 
      pers_g3_16(ref='0') /param=ref;
model pers_g3_16(event='0')=  y35 alone sex1 druglf eversmk
/link=glogit  DF=INFINITY;
run;

proc surveylogistic data=quasi_check; 
strata sdmvstra;
cluster sdmvpsu;
weight wtmec8yr;
domain elg_v_a;
class y35(ref='0') alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') 
      pers_g3_18(ref='0') /param=ref;
model pers_g3_18(event='0')=  y35 alone sex1 druglf eversmk
/link=glogit  DF=INFINITY;
run;

data p1.quasi_check;
set quasi_check;
run;


******************Multivariate Multinomial: antibody 3-level*********************;
**************Table M6***************;

%macro p_multi05(var1, var2);
proc surveylogistic data=quasi_check;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v_a;
 class y35(ref='0') alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') 
      &var1. (ref='0') /param=ref;
model &var1.(event='0')= &var2. y35 alone sex1 druglf eversmk
/link=glogit  DF=INFINITY;
%mend p_multi05;


%p_multi05(pers_g3_16, ln_LBDSTBSI)
%p_multi05(pers_g3_16, ln_LBDFERSI)
%p_multi05(pers_g3_16, ln_LBDSALSI)
%p_multi05(pers_g3_16, ln_URXUMA)
%p_multi05(pers_g3_16, ln_LBDSUASI)
run;

%p_multi05(pers_g3_18, ln_LBDSTBSI)
%p_multi05(pers_g3_18, ln_LBDFERSI)
%p_multi05(pers_g3_18, ln_LBDSALSI)
%p_multi05(pers_g3_18, ln_URXUMA)
%p_multi05(pers_g3_18, ln_LBDSUASI)
run;


/*** Table m6e 
<Fu> wrong weighting: WTDRd1_14yr

***/;
%macro p_multi05a(var1, var2);
proc surveylogistic data=quasi_check;
 strata sdmvstra;
 cluster sdmvpsu;
 *weight WTDRd1_14yr;
 weight WTDRd1_8yr;
 domain elg_v_a;
 class y35(ref='0') alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') 
      &var1. (ref='0') /param=ref;
model &var1. (event='0')= &var2. y35 alone sex1 druglf eversmk
/link=glogit  DF=INFINITY;
%mend p_multi05a;



%p_multi05a(pers_g3_16, ln_vit_A);
%p_multi05a(pers_g3_16, ln_vit_b2);
%p_multi05a(pers_g3_16, ln_vit_C)
%p_multi05a(pers_g3_16, ln_vit_E_add)
%p_multi05a(pers_g3_16, ln_vit_E)
%p_multi05a(pers_g3_16, ln_A_caro)
%p_multi05a(pers_g3_16, ln_sele)
%p_multi05a(pers_g3_16, ln_lyco)
%p_multi05a(pers_g3_16, ln_lut_zeax)
%p_multi05a(pers_g3_16, ln_B_cryp)
%p_multi05a(pers_g3_16, ln_vit_d)
%p_multi05a(pers_g3_16, ln_folate)

run;

/* 4-group, LinHY */;
%macro p_multi05b(indata,var1, var2);
proc surveylogistic data=&indata.;
 strata sdmvstra;
 cluster sdmvpsu;
 *weight WTDRd1_14yr;
 weight WTDRd1_8yr;
 domain elg_v_a;
 class y35(ref='0') alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') 
      &var1. (ref='1') /param=ref;
model &var1. (event='4')= &var2. y35 alone sex1 druglf eversmk
/link=glogit  DF=INFINITY;
%mend p_multi05b;

%p_multi05b(quasi_check, pers_16, ln_vit_A);

proc freq data=quasi_check;
 where  elg_v_a=1;
 table  pers_16;
 run;


%p_multi05a(pers_g3_18, ln_vit_A);
%p_multi05a(pers_g3_18, ln_vit_b2)
%p_multi05a(pers_g3_18, ln_vit_C)
%p_multi05a(pers_g3_18, ln_vit_E_add)
%p_multi05a(pers_g3_18, ln_vit_E)
%p_multi05a(pers_g3_18, ln_A_caro)
%p_multi05a(pers_g3_18, ln_sele)
%p_multi05a(pers_g3_18, ln_lyco)
%p_multi05a(pers_g3_18, ln_lut_zeax)
%p_multi05a(pers_g3_18, ln_B_cryp)
%p_multi05a(pers_g3_18, ln_vit_d)
%p_multi05a(pers_g3_18, ln_folate)

run;





*****************Table M6c**********************;

%macro p_multi04(var);
proc surveylogistic data=quasi_check;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v_a;
 class y35(ref='0') alone(ref='0') 
      sex1(ref='0')  druglf(ref='0') 
      pers_g3_16 (ref='0') /param=ref;
model pers_g3_16 (event='0')= &var. y35 alone sex1 druglf 
/link=glogit  DF=INFINITY;
%mend p_multi04;


%p_multi04(ln_LBDSTBSI)
%p_multi04(ln_LBDFERSI)
%p_multi04(ln_LBDSALSI)
%p_multi04(ln_URXUMA)
%p_multi04(ln_LBDSUASI)
run;



%macro p_multi04a(var);
proc surveylogistic data=quasi_check;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 domain elg_v_a;
 class y35(ref='0') alone(ref='0')  
      sex1(ref='0')  druglf(ref='0') 
      pers_g3_16 (ref='0') /param=ref;
model pers_g3_16 (event='0')= &var. y35 alone sex1 druglf 
/link=glogit  DF=INFINITY;
%mend p_multi04a;



%p_multi04a(ln_vit_A);
%p_multi04a(ln_vit_b2)
%p_multi04a(ln_vit_C)
%p_multi04a(ln_vit_E_add)
%p_multi04a(ln_vit_E)
%p_multi04a(ln_A_caro)
%p_multi04a(ln_sele)
%p_multi04a(ln_lyco)
%p_multi04a(ln_lut_zeax)
%p_multi04a(ln_B_cryp)
%p_multi04a(ln_vit_d)
%p_multi04a(ln_folate)

run;



*****************Table M6d**********************;

%macro p_multi03(var);
proc surveylogistic data=quasi_check;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 domain elg_v_a;
 class y35(ref='0') sex1(ref='0') eversmk(ref='0') 
      pers_g3_18 (ref='0') /param=ref;
model pers_g3_18 (event='0')= &var. y35 sex1 eversmk 
/link=glogit  DF=INFINITY;
%mend p_multi03;


%p_multi03(ln_LBDSTBSI)
%p_multi03(ln_LBDFERSI)
%p_multi03(ln_LBDSALSI);
%p_multi03(ln_URXUMA)
%p_multi03(ln_LBDSUASI)
run;



%macro p_multi03a(var);
proc surveylogistic data=quasi_check;
 strata sdmvstra;
 cluster sdmvpsu;
 *weight WTDRd1_14yr;
 weight WTDRd1_8yr;
 domain elg_v_a;
class y35(ref='0') sex1(ref='0') eversmk(ref='0') 
      pers_g3_18 (ref='0') /param=ref;
model pers_g3_18 (event='0')= &var.  y35 sex1 eversmk
/link=glogit  DF=INFINITY;
%mend p_multi03a;



%p_multi03a(ln_vit_A);
%p_multi03a(ln_vit_b2)
%p_multi03a(ln_vit_C)
%p_multi03a(ln_vit_E_add)
%p_multi03a(ln_vit_E)
%p_multi03a(ln_A_caro)
%p_multi03a(ln_sele)
%p_multi03a(ln_lyco)
%p_multi03a(ln_lut_zeax)
%p_multi03a(ln_B_cryp)
%p_multi03a(ln_vit_d)
%p_multi03a(ln_folate)

run;




/*
proc surveylogistic data=quasi_check; 
strata sdmvstra;
cluster sdmvpsu;
weight wtmec8yr;
domain elg_v_a;
class y35(ref='0') college(ref='0') alone(ref='0') white(ref='0') 
eversmk(ref='0')  druglf(ref='0') aupy(ref='0') sex_p12(ref='0') depression(ref='0')
pers_in_inf_16(ref='0') /param=ref;
model pers_in_inf_16(event='0')= y35 college alone white eversmk depression druglf sex_p12 aupy 
/link=glogit  DF=INFINITY;
run;
;
 */;





*table D3b: multinomial p, marker by pers & mean+se ;

%macro p_multin_pers06(var1, var2);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight &var1.;
 class anti_hr12;
 domain elg_v_a ;
 model pers_g3_06(event='1')=&var2./link=glogit df=infinity;
%mend p_multin_pers06;


%p_multin_pers06(wtmec8yr,ln_LBDSTBSI)
%p_multin_pers06(wtmec8yr,ln_LBDFERSI)
%p_multin_pers06(wtmec8yr,ln_LBDSALSI)
%p_multin_pers06(wtmec8yr,ln_URXUMA)
%p_multin_pers06(wtmec8yr,ln_LBDSUASI)

%p_multin_pers06(WTDRd1_8yr,ln_vit_A)
%p_multin_pers06(WTDRd1_8yr,ln_vit_b2)
%p_multin_pers06(WTDRd1_8yr,ln_vit_C)
%p_multin_pers06(WTDRd1_8yr,ln_vit_E_add)
%p_multin_pers06(WTDRd1_8yr,ln_vit_E)
%p_multin_pers06(WTDRd1_8yr,ln_A_caro)
%p_multin_pers06(WTDRd1_8yr,ln_sele)
%p_multin_pers06(WTDRd1_8yr,ln_lyco)
%p_multin_pers06(WTDRd1_8yr,ln_lut_zeax)
%p_multin_pers06(WTDRd1_8yr,ln_B_cryp)
%p_multin_pers06(WTDRd1_8yr,ln_vit_D)
%p_multin_pers06(WTDRd1_8yr,ln_folate)
run;



%macro p_multin_pers11(var1, var2);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight &var1.;
 class anti_hr12;
 domain elg_v_a ;
 model pers_g3_11(event='1')=&var2./link=glogit df=infinity;
%mend p_multin_pers11;

%p_multin_pers11(wtmec8yr,ln_LBDSTBSI)
%p_multin_pers11(wtmec8yr,ln_LBDFERSI)
%p_multin_pers11(wtmec8yr,ln_LBDSALSI)
%p_multin_pers11(wtmec8yr,ln_URXUMA)
%p_multin_pers11(wtmec8yr,ln_LBDSUASI)

%p_multin_pers11(WTDRd1_8yr,ln_vit_A)
%p_multin_pers11(WTDRd1_8yr,ln_vit_b2)
%p_multin_pers11(WTDRd1_8yr,ln_vit_C)
%p_multin_pers11(WTDRd1_8yr,ln_vit_E_add)
%p_multin_pers11(WTDRd1_8yr,ln_vit_E)
%p_multin_pers11(WTDRd1_8yr,ln_A_caro)
%p_multin_pers11(WTDRd1_8yr,ln_sele)
%p_multin_pers11(WTDRd1_8yr,ln_lyco)
%p_multin_pers11(WTDRd1_8yr,ln_lut_zeax)
%p_multin_pers11(WTDRd1_8yr,ln_B_cryp)
%p_multin_pers11(WTDRd1_8yr,ln_vit_D)
%p_multin_pers11(WTDRd1_8yr,ln_folate)
run;


%macro p_multin_pers16(var1, var2);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight &var1.;
 class anti_hr12;
 domain elg_v_a ;
 model pers_g3_16(event='1')=&var2./link=glogit df=infinity;
%mend p_multin_pers16;
%p_multin_pers16(wtmec8yr,ln_LBDSTBSI)
%p_multin_pers16(wtmec8yr,ln_LBDFERSI)
%p_multin_pers16(wtmec8yr,ln_LBDSALSI)
%p_multin_pers16(wtmec8yr,ln_URXUMA)
%p_multin_pers16(wtmec8yr,ln_LBDSUASI)

%p_multin_pers16(WTDRd1_8yr,ln_vit_A)
%p_multin_pers16(WTDRd1_8yr,ln_vit_b2)
%p_multin_pers16(WTDRd1_8yr,ln_vit_C)
%p_multin_pers16(WTDRd1_8yr,ln_vit_E_add)
%p_multin_pers16(WTDRd1_8yr,ln_vit_E)
%p_multin_pers16(WTDRd1_8yr,ln_A_caro)
%p_multin_pers16(WTDRd1_8yr,ln_sele)
%p_multin_pers16(WTDRd1_8yr,ln_lyco)
%p_multin_pers16(WTDRd1_8yr,ln_lut_zeax)
%p_multin_pers16(WTDRd1_8yr,ln_B_cryp)
%p_multin_pers16(WTDRd1_8yr,ln_vit_D)
%p_multin_pers16(WTDRd1_8yr,ln_folate)
run;




%macro p_multin_pers18(var1, var2);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight &var1.;
 class anti_hr12;
 domain elg_v_a ;
 model pers_g3_18(event='1')=&var2./link=glogit df=infinity;
%mend p_multin_pers18;
%p_multin_pers18(wtmec8yr,ln_LBDSTBSI)
%p_multin_pers18(wtmec8yr,ln_LBDFERSI)
%p_multin_pers18(wtmec8yr,ln_LBDSALSI)
%p_multin_pers18(wtmec8yr,ln_URXUMA)
%p_multin_pers18(wtmec8yr,ln_LBDSUASI)

%p_multin_pers18(WTDRd1_8yr,ln_vit_A)
%p_multin_pers18(WTDRd1_8yr,ln_vit_b2)
%p_multin_pers18(WTDRd1_8yr,ln_vit_C)
%p_multin_pers18(WTDRd1_8yr,ln_vit_E_add)
%p_multin_pers18(WTDRd1_8yr,ln_vit_E)
%p_multin_pers18(WTDRd1_8yr,ln_A_caro)
%p_multin_pers18(WTDRd1_8yr,ln_sele)
%p_multin_pers18(WTDRd1_8yr,ln_lyco)
%p_multin_pers18(WTDRd1_8yr,ln_lut_zeax)
%p_multin_pers18(WTDRd1_8yr,ln_B_cryp)
%p_multin_pers18(WTDRd1_8yr,ln_vit_D)
%p_multin_pers18(WTDRd1_8yr,ln_folate)
run;



%macro wtmeans_pers_anti0(var1, var2);
data &var1.;
set p1.hpv_ms_v5;
where &var2.=0;

proc surveymeans data=&var1.;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a;
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp vit_d folate;

proc surveymeans data=&var1.;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 domain elg_v_a ;
 var LBDSTBSI LBDFERSI  LBDSALSI URXUMA  LBDSUASI;
run;
%mend wtmeans_pers_anti0;

%wtmeans_pers_anti0(p06,pers_g3_06)
%wtmeans_pers_anti0(p11,pers_g3_11)
%wtmeans_pers_anti0(p16,pers_g3_16)
%wtmeans_pers_anti0(p18,pers_g3_18)


data p18;
set p1.hpv_ms_v5;
where pers_g3_18=2;

proc surveymeans data=p18;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 domain elg_v_a ;
 var ln_LBDSALSI;
run;



%macro wtmeans_pers_anti1(var1, var2);
data &var1.;
set p1.hpv_ms_v5;
where &var2.=1;

proc surveymeans data=&var1.;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a;
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp vit_d folate;

proc surveymeans data=&var1.;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 domain elg_v_a ;
 var LBDSTBSI LBDFERSI  LBDSALSI URXUMA  LBDSUASI;
run;
%mend wtmeans_pers_anti1;


%wtmeans_pers_anti1(pers_g3_06)
%wtmeans_pers_anti1(pers_g3_11)
%wtmeans_pers_anti1(pers_g3_16)
%wtmeans_pers_anti1(pers_g3_18)






%macro wtmeans_pers_anti2(var1, var2);
data &var1.;
set p1.hpv_ms_v5;
where &var2.=2;

proc surveymeans data=&var1.;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a;
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp vit_d folate;

proc surveymeans data=&var1.;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 domain elg_v_a ;
 var LBDSTBSI LBDFERSI  LBDSALSI URXUMA  LBDSUASI;
run;
%mend wtmeans_pers_anti2;


%wtmeans_pers_anti2(pers_g3_06)
%wtmeans_pers_anti2(pers_g3_11)
%wtmeans_pers_anti2(pers_g3_16)
%wtmeans_pers_anti2(pers_g3_18)












proc contents data=p1.hpv_ms;
run;




proc freq data=p1.hpv_ms;
table id;
run;

data p1.hpv_ms_cutpoint;
set p1.hpv_ms_v5;
keep seqn hpv_g3 hpv_hr12  LBDSTBSI LBDFERSI  LBDSALSI URXUMA  LBDSUASI 
vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp vit_d folate;
run;


/**************
8/26/2020
LinHY
cut-point search
*****/;
data hpv_ms;
set p1.hpv_ms_v5;
run;

proc surveymeans data=hpv_ms PERCENTILE=(10 20 30 40 50 60 70 80 90);
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v ;
 var LBDSTBSI;  
run;


%macro cp(var1, var2);
proc surveymeans data=hpv_ms PERCENTILE=(10 20 30 40 50 60 70 80 90);
 strata sdmvstra;
 cluster sdmvpsu;
 weight &var1.;
 domain elg_v ;
 var &var2.;  
run;
%mend cp;

%cp(wtmec14yr, LBDSTBSI)
%cp(wtmec14yr, LBDFERSI)
%cp(wtmec14yr, LBDSALSI)
%cp(wtmec14yr, URXUMA)
%cp(wtmec14yr, LBDSUASI)


%cp(WTDRd1_14yr, vit_A)
%cp(WTDRd1_14yr, vit_b2)
%cp(WTDRd1_14yr, vit_C)
%cp(WTDRd1_14yr, vit_E_add)
%cp(WTDRd1_14yr, vit_E)
%cp(WTDRd1_14yr, A_caro)
%cp(WTDRd1_14yr, sele)
%cp(WTDRd1_14yr, lyco)
%cp(WTDRd1_14yr, lut_zeax)
%cp(WTDRd1_14yr, B_cryp)
%cp(WTDRd1_14yr, vit_d)
%cp(WTDRd1_14yr, folate)




proc surveymeans data=hpv_ms PERCENTILE=(10 20 30 40 50 60 70 80 90);
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 domain elg_v ;
 var vit_e;  
run;



%macro g10(var, p10,p20, p30,p40,p50,p60,p70,p80,p90);
  if &var.=. then &var._g10=.;
 else if &var.<&p10. then &var._g10=1;
 else if &var.>=&p10. and &var.<&p20. then &var._g10=2;
 else if &var.>=&p20. and &var.<&p30. then &var._g10=3;
 else if &var.>=&p30. and &var.<&p40. then &var._g10=4;
 else if &var.>=&p40. and &var.<&p50. then &var._g10=5;
 else if &var.>=&p50. and &var.<&p60. then &var._g10=6;
 else if &var.>=&p60. and &var.<&p70. then &var._g10=7;
 else if &var.>=&p70. and &var.<&p80. then &var._g10=8;
 else if &var.>=&p80. and &var.<&p90. then &var._g10=9;
 else if &var.>=&p90. then &var._g10=10;
%mend g10;

/*** low 10%, 20%, top 10%, 20% and middle **/;
%macro g5(var);
  if &var._g10=. then &var._g5=.;
  else if &var._g10=1 then &var._g5=1;
  else if &var._g10=2 then &var._g5=2;
  else if &var._g10>2 and &var._g10<=8 then &var._g5=3;
  else if &var._g10=9 then &var._g5=4;
  else if &var._g10=10 then &var._g5=5;
 
%mend g5;


proc freq data=hpv_try;
 table vit_a_g10 vit_a_g5;
 run;
 /*
 proc means data=hpv_try;
  class vit_a_g10;
  var vit_a;
  run;
*/;
data hpv_try;
 set hpv_ms;

%g10(LBDSTBSI, 5.1996,6.477803,7.688605,8.398848,9.283665,10.215678,11.345955,12.73587,15.097017)
*%g10(LBDSTBSI, 6.840000, 8.550000, 8.550000, 10.260000, 11.970000, 11.970000, 13.680000, 15.390000, 18.810000 );
%g10(LBDFERSI, 10,18,26,33,41,51,64,81,116)
%g10(LBDSALSI, 37,39,40,41,42,42,43,44,46)
%g10(URXUMA, 2,3,4,5,7,9,11,16,29)
%g10(LBDSUASI, 195,216,234,249,264,279,297,321,356)


%g10(vit_A, 172,259,335,410,491,577,686,828,1080)
%g10(vit_b2, 0.9,1.2,1.4,1.6,1.8,2,2.2,2.5,3)
%g10(vit_C, 13,22,33,46,58,75,95,124,165)
%g10(vit_E_add, 0,0,0,0,0,0,0,0,2)
%g10(vit_E, 3,4,4.8,5.5,6.3,7.3,8.4,10.1,12.8)
%g10(A_caro, 5,16,29,46,78,152,315,600,1155)
%g10(sele, 52,64,73,83,92,102,112,125,147)
%g10(lyco, 0.4,417,944,1612,2471,3635,5249,7792,12797) 
%g10(lut_zeax, 219,345,464,603,774,1002,1344,1995,3464)
%g10(B_cryp, 3,8,15,23,36,54,82,127,225)
%g10(vit_d, 0.7,1.2,1.8,2.4,3.1,3.8,4.7,6,8.3)
%g10(folate, 213,271,322,370,419,478,547,645,814)





%g5(LBDSTBSI)
%g5(LBDFERSI)
%g5(LBDSALSI)
%g5(URXUMA)
%g5(LBDSUASI)

%g5(vit_A)
%g5(vit_b2)
%g5(vit_C)
%g5(vit_E_add)
%g5(vit_E)
%g5(A_caro)
%g5(sele)
%g5(lyco)
%g5(lut_zeax)
%g5(B_cryp)
%g5(vit_d)
%g5(folate)

 /*
 if vit_A=. then vit_A_g10=.;
 else if vit_A<172 then vit_A_g10=1;
 else if vit_A>=172 and vit_A<259 then vit_A_g10=2;
 else if vit_A>=259 and vit_A<335 then vit_A_g10=3;
 else if vit_A>=335 and vit_A<410 then vit_A_g10=4;
 else if vit_A>=410 and vit_A<491 then vit_A_g10=5;
 else if vit_A>=491 and vit_A<577 then vit_A_g10=6;
 else if vit_A>=577 and vit_A<686 then vit_A_g10=7;
 else if vit_A>=686 and vit_A<828 then vit_A_g10=8;
 else if vit_A>=828 and vit_A<1080 then vit_A_g10=9;
 else if vit_A>=1080 then vit_A_g10=10;
*/

 run;






proc surveymeans data=hpv_ms PERCENTILE=(10 20 30 40 50 60 70 80 90);
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTmec14yr;
 domain elg_v ;
 var LBDSTBSI;  
run;





 proc means data=hpv_ms StackODSOutput P10 P20 P30 P40 P50 P60 P70 P80 P90;
 where elg_v=1;
 var LBDSTBSI;  
 ods output summary=pcts;
run;

proc print data=pcts noobs;run;




proc freq data=hpv_try;
table LBDSTBSI_g10;
run;

proc surveyfreq data=hpv_try;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
table elg_v*LBDSTBSI_g10 /row chisq;
run;







proc freq data=hpv_try;
 table vit_A_g10*hpv_hr12/chisq nopercent nocol;
 run;

 proc surveylogistic  data=hpv_try;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_g3(ref='0') ag4(ref='1') sex_p12(ref='0') mari(ref='1') vit_A_g10 (ref='5')/param=ref;
 domain elg_v ;
 model hpv_g3  = ag4 sex_p12 mari vit_A_g10/link=glogit ;
run;
/* 3-g, n=9803*/

 proc surveylogistic  data=hpv_try;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_g3(ref='0') ag4(ref='1') race(ref='1')  smk(ref='0') sex_p12(ref='0') mari(ref='1') vA_g3 (ref='1')/param=ref;
 domain elg_v ;
 model hpv_g3  = ag4 race smk sex_p12 mari vA_g3/link=glogit ;
run;

 proc surveylogistic  data=hpv_try;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_g3(ref='0') ag4(ref='1') race(ref='1')  smk(ref='0') sex_p12(ref='0') mari(ref='1') vA_g3 (ref='1')/param=ref;
 domain elg_v ;
 model hpv_g3  = ag4 race smk sex_p12 mari vA_g3/link=glogit ;
run;

 proc logistic  data=hpv_try;
 
 class hpv_g3(ref='0') ag4(ref='1') race(ref='1') sex_p12(ref='0') mari(ref='1') vA_g3 (ref='1')/param=ref;
  model hpv_g3  = ag4 race sex_p12 mari vA_g3/link=glogit ;
run;

proc freq data=hpv_ms;
 where elg_v=1;
 table ag4
edu
pirg4
mari
race
sex_p12
smk
druglf
au12
va_g3;
run;

proc surveylogistic  data=hpv_try;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class hpv_g3(ref='0') vit_A_g10 (ref='5')/param=ref;
 domain elg_v ;
 model hpv_g3  =  vit_A_g10/link=glogit ;
run;



proc surveyfreq data=hpv_try;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;

table elg_v* (LBDSTBSI_g10 LBDFERSI_g10  LBDSALSI_g10 URXUMA_g10  LBDSUASI_g10) *hpv_hr12 /row chisq;

run;



proc surveyfreq data=hpv_try;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;

table elg_v* (vit_A_g10 vit_b2_g10 vit_C_g10 vit_E_add_g10 vit_E_g10 A_caro_g10 
sele_g10 lyco_g10 lut_zeax_g10 B_cryp_g10 vit_d_g10 folate_g10 ) *hpv_hr12 /row chisq;

run;








proc surveyfreq data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v *(race race3) * hpv_g3/row chisq;
run;
/**
for dietary markers (vit-A, C, E)  
     ues weight WTDRd1_14yr;

for lab markers
   weight wtmec14yr;
****/;

/** 9 cov , vitA, n=8581*/
/* vit-A, continuous */
proc surveylogistic data=hpv_try;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') /param=ref;
 domain elg_v ;
 model hpv_g3 = ag4 edu pirg4 mari race sex_p12 smk druglf au12 ln_vit_A/link=glogit ;
run;



/* vit-A, g10  (check dose effect)*/
proc surveylogistic data=hpv_try;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') vit_A_g10 (ref='1')/param=ref;
 domain elg_v ;
 model hpv_g3 = ag4 edu pirg4 mari race sex_p12 smk druglf au12 vit_A_g10/link=glogit ;
run;

/* vit-A, g5 (check extreme effect with middle as ref) */
proc surveylogistic data=hpv_try;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') vit_A_g5 (ref='3')/param=ref;
 domain elg_v ;
 model hpv_g3 = ag4 edu pirg4 mari race sex_p12 smk druglf au12 vit_A_g5/link=glogit ;
run;

/* vit-E, g5 (check extreme effect with middle as ref) */
proc surveylogistic data=hpv_try;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') vit_E_g5 (ref='3')/param=ref;
 domain elg_v ;
 model hpv_g3 = ag4 edu pirg4 mari race sex_p12 smk druglf au12 vit_E_g5/link=glogit ;
run;

/* drop au12 druglf**/
proc surveylogistic data=hpv_try;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0')  hpv_g3(ref='0') vA_g3(ref='1')/param=ref;
 domain elg_v ;
 model hpv_g3 = ag4 edu pirg4 mari race sex_p12 smk  vA_g3/link=glogit ;
run;


proc logistic data=hpv_try;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') vA_g3 (ref='1')/param=ref;

 model hpv_g3 = ag4 edu pirg4 mari race sex_p12 smk druglf au12 vA_g3/link=glogit ;
run;



proc surveylogistic data=hpv_try;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') vA_g3 (ref='1')/param=ref;
 domain elg_v ;
 model hpv_g3 = ag4 edu pirg4 mari race sex_p12 smk druglf au12 vA_g3/link=glogit ;
run;

/** hpv_hr12 **/
proc surveylogistic data=hpv_try;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_hr12(ref='0') vit_A_g10 (ref='5')/param=ref;
 domain elg_v ;
 model hpv_hr12 = ag4 edu pirg4 mari race sex_p12 smk druglf au12 vit_A_g10/link=glogit ;
run;

proc logistic descnding data=hpv_ms;
 model HPV_hr12=ln_vit_A;
 run;

proc hpsplit data=hpv_ms maxdepth=5;
 class hpv_hr12 ;
 model HPV_hr12 =ln_vit_A;

   partition fraction(validate=0.3 seed=123);
 run;


proc means data=hpv_ms n mean std min p10 p20 p30 p40 p50 p60 p70 p80 p90 max;
  var vit_A;
  run;

























/*

  proc freq data=p1.hpv_ms_v6;
 table alb_cat;
 run;
proc freq data=ms_201102;
 *table LBDSALSI alb_cat;
 table vit_A va_cat;
 run;


data ms_201102;
*/;
data p1.hpv_ms_v6;
set p1.hpv_ms_v5;


if LBDSTBSI=. then bili_cat=.;
else if LBDSTBSI<10 then bili_cat=0;
else if LBDSTBSI>15 then bili_cat=2;
else bili_cat=1;


if LBDFERSI=. then ferr_cat=.;
else if LBDFERSI<25 then ferr_cat=0;
else if LBDFERSI>45 then ferr_cat=2;
else ferr_cat=1;



if LBDSALSI=. then alb_cat=.;
else if LBDSALSI=<30 then alb_cat=0;
else if 30<LBDSALSI=<35 then alb_cat=1;
else if LBDSALSI>40 then alb_cat=3;
else alb_cat=2;

if vit_A =. then va_cat=.;
else if vit_A =<390 then va_cat=0;
else if vit_A >520 then va_cat=2;
else va_cat=1;

if vit_e =. then ve_cat=.;
else if vit_e =<5 then ve_cat=0;
else if vit_e >8 then ve_cat=2;
else ve_cat=1;


if a_caro =. then a_caro_cat=.;
else if a_caro =<500 then a_caro_cat=0;
else a_caro_cat=1;


/**
Fu's version (wrong, missing "=" for some groups)

if LBDSALSI=. then alb_cat=.;
else if LBDSALSI<30 then alb_cat=0;
else if 30<=LBDSALSI<35 then alb_cat=1;
else if LBDSALSI>40 then alb_cat=3;
else alb_cat=2;

if vit_A =. then va_cat=.;
else if vit_A <390 then va_cat=0;
else if vit_A >520 then va_cat=2;
else va_cat=1;


if vit_e =. then ve_cat=.;
else if vit_e =<5 then ve_cat=0;
else if vit_e >8 then ve_cat=2;
else ve_cat=1;


if a_caro =. then a_caro_cat=.;
else if a_caro <500 then a_caro_cat=0;
else a_caro_cat=1;
*/;

if URXUMA=. then albu_cat=.;
else if URXUMA<5 then albu_cat=0;
else if URXUMA>15 then albu_cat=2;
else albu_cat=1;


if LBDSUASI=. then ua_cat=.;
else if LBDSUASI<270 then ua_cat=0;
else if LBDSUASI>350 then ua_cat=2;
else ua_cat=1;



if vit_b2 =. then vb2_cat=.;
else if vit_b2 <1 then vb2_cat=0;
else if vit_b2 >2 then vb2_cat=2;
else vb2_cat=1;

if vit_c =. then vc_cat=.;
else if vit_c <45 then vc_cat=0;
else if vit_c >100 then vc_cat=2;
else vc_cat=1;




if vit_e_add =. then vea_cat=.;
else if vit_e_add =0 then vea_cat=0;
else if vit_e_add >0 then vea_cat=1;



if sele =. then sele_cat=.;
else if sele <75 then sele_cat=0;
else if sele >110 then sele_cat=2;
else sele_cat=1;

if lyco =. then lyco_cat=.;
else if lyco <1000 then lyco_cat=0;
else if lyco >4500 then lyco_cat=2;
else lyco_cat=1;

if lut_zeax =. then lut_zeax_cat=.;
else if lut_zeax =<1150 then lut_zeax_cat=0;
else if lut_zeax >7950 then lut_zeax_cat=2;
else lut_zeax_cat=1;

if b_cryp =. then b_cryp_cat=.;
else if b_cryp <20 then b_cryp_cat=0;
else if b_cryp >80 then b_cryp_cat=2;
else b_cryp_cat=1;


label
bili_cat='three level category of bilirubin, 0:low 1:medium 2:high'
ferr_cat='three level category of ferritin, 0:low 1:medium 2:high'
albu_cat='three level category of albumin urine, 0:low 1:medium 2:high'
ua_cat='three level category of uric acid, 0:low 1:medium 2:high'
va_cat='three level category of vit a, 0:low 1:medium 2:high'
vb2_cat='three level category of vit b2, 0:low 1:medium 2:high'
vc_cat='three level category of vit c, 0:low 1:medium 2:high'
ve_cat='three level category of vit e, 0:low 1:medium 2:high'
vea_cat='three level category of vit e added, 0:low 1:high'
a_caro_cat='three level category of alpha carotene, 0:low 1:high'
sele_cat='three level category of selenium, 0:low 1:medium 2:high'
lyco_cat='three level category of lycopene, 0:low 1:medium 2:high'
lut_zeax_cat='three level category of Lutein + zeaxanthin, 0:low 1:medium 2:high'
b_cryp_cat='three level category of Beta-cryptoxanthin, 0:low 1:medium 2:high'

/** decision tree cut-points */;
alb_cat='Albumin(g/L), 0:low (=<30),1:medium low (31-35), 2:medium high (36-40), 3:high (>40)'
va_cat='Vitamin A (mcg), 0:=390, 1: 391-520, 2:>520'
ve_cat='Vitamin E (mg), 0: =5, 1: 5-8, 2: >8'
a_caro_cat='Alpha-carotene (mcg), 0: =500, 1: >500'
lut_zeax_cat='Lutein + zeaxanthin(mcg),0: =1150, 1:1150-7950, 2: >7950'

;
run;

proc freq data=p1.hpv_ms_v6;
 *table LBDSALSI alb_cat vit_a va_cat;
 *table vit_e ve_cat;
 *table a_caro a_caro_cat ;
 table lut_zeax lut_zeax_cat;
 run;





proc surveyfreq data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v*(alb_cat)*hpv_g3/row chisq;
run;

proc surveyfreq data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 tables elg_v*(va_cat ve_cat a_caro_cat lut_zeax_cat)*hpv_g3/row chisq;
run;


proc surveyfreq data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v*(bili_cat ferr_cat alb_cat albu_cat ua_cat)*hpv_g3/row chisq;
run;

proc surveyfreq data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 tables elg_v*(va_cat vb2_cat vc_cat ve_cat vea_cat a_caro_cat sele_cat
lyco_cat lut_zeax_cat b_cryp_cat)*hpv_g3/row chisq;
run;


/**********Yields Table4 (p-val) and Table5 in hpv_3g***********/

%macro p_reg_tree(var);
proc surveylogistic data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v;
 class &var. hpv_g3/param=ref ref=first;
 model hpv_g3(event='0')=&var./link=glogit df=infinity;
 run;
%mend p_reg_tree;

%p_reg_tree(alb_cat);


/**LinHY, 11/06/2020 change ref for alb_cat**/
proc surveylogistic data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v;
 class alb_cat (ref='1') hpv_g3 (ref='0')/param=ref ;
 model hpv_g3(event='0')=alb_cat/link=glogit df=infinity;
 run;

 proc surveylogistic data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') alb_cat (ref='1')/param=ref;
 domain elg_v ;
 model hpv_g3= ag4 edu pirg4 mari race sex_p12 smk druglf au12 alb_cat/link=glogit df=infinity;
 run;

%macro p_reg_tree1(var);
proc surveylogistic data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 domain elg_v;
 class &var. hpv_g3/param=ref ref=first;
 model hpv_g3(event='0')=&var./link=glogit df=infinity;
%mend p_reg_tree1;

%p_reg_tree1(va_cat)
%p_reg_tree1(ve_cat)
%p_reg_tree1(a_caro_cat)
%p_reg_tree1(lut_zeax_cat)

run;




************TABLE 5 hpv_3g***********;
%macro p_multi09t_g3(var);
proc surveylogistic data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') &var.(ref='0')/param=ref;
 domain elg_v ;
 model hpv_g3=&var. ag4 edu pirg4 mari race sex_p12 smk druglf au12/link=glogit df=infinity;
 run;
%mend p_multi09t_g3;



%p_multi09t_g3(alb_cat)
%p_multi09t_g3(albu_cat)
run;



%macro p_multi09t_g3a(var);
proc surveylogistic data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
  smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') &var.(ref='0')/param=ref;
 domain elg_v ;
 model hpv_g3= ag4 edu pirg4 mari race sex_p12 smk druglf au12 &var./link=glogit df=infinity;
 run;
%mend p_multi09t_g3a;

%p_multi09t_g3a(va_cat);
%p_multi09t_g3a(ve_cat);
%p_multi09t_g3a(a_caro_cat)
%p_multi09t_g3a(lut_zeax_cat)
run;




%macro p_unit_g3(var);
proc surveylogistic data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_g3(ref='0') &var.(ref='1')/param=ref;
 domain elg_v ;
 model hpv_g3=&var. /link=glogit df=infinity;
%mend p_unit_g3;



%p_unit_g3(alb_cat)
run;




%macro p_unit_g3a(var);
proc surveylogistic data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 class hpv_g3(ref='0') &var.(ref='1')/param=ref;
 domain elg_v ;
 model hpv_g3=&var. /link=glogit df=infinity;
%mend p_unit_g3a;

%p_unit_g3a(va_cat)
%p_unit_g3a(ve_cat)
%p_unit_g3a(a_caro_cat)
%p_unit_g3a(lut_zeax_cat)
run;




/*** 
11/6/2020 LinHY, 
check sample size for multi model 

n=7548, Alpha-carotene
for vit_a, ve_cat
****/;



proc logistic data=p1.hpv_ms_v6;
 where elg_v=1;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
  smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') alb_cat(ref='0')/param=ref;
 model hpv_g3= ag4 edu pirg4 mari race sex_p12 smk druglf au12 alb_cat;
run;

proc logistic data=p1.hpv_ms_v6;
 where elg_v=1;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
  smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') va_cat(ref='0')/param=ref;
 model hpv_g3= ag4 edu pirg4 mari race sex_p12 smk druglf au12 alb_cat;
run;

proc logistic data=p1.hpv_ms_v6;
 where elg_v=1;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
  smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') va_cat(ref='0')/param=ref;
 model hpv_g3= ag4 edu pirg4 mari race sex_p12 smk druglf au12 va_cat;
run;




proc logistic data=p1.hpv_ms_v6;
 where elg_v=1;
 class ag4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
  smk(ref='0')  au12(ref='0') hpv_g3(ref='0') va_cat(ref='0')/param=ref;
 model hpv_g3= ag4  mari race sex_p12 smk  au12 va_cat;
run;

proc logistic data=p1.hpv_ms_v6;
 where elg_v=1;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
  smk(ref='0')  hpv_g3(ref='0') va_cat(ref='0')/param=ref;
 model hpv_g3= ag4 edu pirg4 mari race sex_p12 smk  va_cat;
run;

proc freq data=p1.hpv_ms_v6;
 table ag4 edu pirg4 mari race sex_p12 smk druglf au12;
run;











************Type specific mean&se: D5a D5b************;


/*
pers_06='persistnet HPV-06 (vaginal, antibody), 1:neg,neg, 2:neg,pos, 3:transient inf, 4: persistent inf' 
pers_11='persistnet HPV-11 (vaginal, antibody), 1:neg,neg, 2:neg,pos, 3:transient inf, 4: persistent inf' 
pers_16='persistnet HPV-16 (vaginal, antibody), 1:neg,neg, 2:neg,pos, 3:transient inf, 4: persistent inf' 
pers_18='persistnet HPV-18 (vaginal, antibody), 1:neg,neg, 2:neg,pos, 3:transient inf, 4: persistent inf' */


data pers1_16; set p1.hpv_ms_v5; where pers_16=1; run;
data pers2_16; set p1.hpv_ms_v5; where pers_16=2; run;
data pers3_16; set p1.hpv_ms_v5; where pers_16=3; run;
data pers4_16; set p1.hpv_ms_v5; where pers_16=4; run;

data pers1_18; set p1.hpv_ms_v5; where pers_18=1; run;
data pers2_18; set p1.hpv_ms_v5; where pers_18=2; run;
data pers3_18; set p1.hpv_ms_v5; where pers_18=3; run;
data pers4_18; set p1.hpv_ms_v5; where pers_18=4; run;

/****
12/2/2020 LinHY 

q: Fu used the sub-group to get survey means
This is not follow the NHANES suggestion 
need to check whether the resutls are correct 

A: Surveymeans of sub-group analyses using the sub-group and domain are the same
Thus, it is fine to use sub-group analyes. 

**********/;



%macro pers4_meanse(var);
proc surveymeans data=&var.;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 domain elg_v_a ;
 var LBDSTBSI LBDFERSI  LBDSALSI  URXUMA  LBDSUASI;
run;
proc surveymeans data=&var.;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a ;
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp vit_D folate;
run;
%mend;

%pers4_meanse(pers1_16)
%pers4_meanse(pers2_16)
%pers4_meanse(pers3_16)
%pers4_meanse(pers4_16)

%pers4_meanse(pers1_18)
%pers4_meanse(pers2_18)
%pers4_meanse(pers3_18)
%pers4_meanse(pers4_18)

proc surveymeans data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 domain elg_v_a*pers_16 ;
 var LBDSTBSI LBDFERSI  LBDSALSI  URXUMA  LBDSUASI;
run;
/***
sub-group mean 
****/;
%macro submean2(indata,var);
proc surveymeans data=&indata.;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a * &var.;
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp vit_D folate;
run;
%mend submean2;

%submean2(p1.hpv_ms_v6,anti_16); 

%submean2(p1.hpv_ms_v6,hpv_type16  ); 
/** the whole group */
proc surveymeans data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a ;
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp vit_D folate;
run;


%macro multinomial_uni_pers4_1(var1,var2);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec8yr;
 domain elg_v_a ;
 class &var1.(ref='1')/param=ref;
 model &var1.(event='1')=&var2./link=glogit DF=INFINITY;
%mend multinomial_uni_pers4_1;

%macro multinomial_uni_pers4_2(var1,var2);
proc surveylogistic data=p1.hpv_ms_v5;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a ;
 class &var1.(ref='1')/param=ref;
 model &var1.(event='1')=&var2./link=glogit DF=INFINITY;
%mend multinomial_uni_pers4_2;



%multinomial_uni_pers4_1(pers_16,ln_LBDSTBSI)
%multinomial_uni_pers4_1(pers_16,ln_LBDFERSI)
%multinomial_uni_pers4_1(pers_16,ln_LBDSALSI)
%multinomial_uni_pers4_1(pers_16,ln_URXUMA)
%multinomial_uni_pers4_1(pers_16,ln_LBDSUASI)
run;
%multinomial_uni_pers4_2(pers_16,ln_vit_A);
%multinomial_uni_pers4_2(pers_16,ln_vit_b2);
%multinomial_uni_pers4_2(pers_16,ln_vit_C)
%multinomial_uni_pers4_2(pers_16,ln_vit_E_add)
%multinomial_uni_pers4_2(pers_16,ln_vit_E)
%multinomial_uni_pers4_2(pers_16,ln_A_caro)
%multinomial_uni_pers4_2(pers_16,ln_sele)
%multinomial_uni_pers4_2(pers_16,ln_lyco)
%multinomial_uni_pers4_2(pers_16,ln_lut_zeax)
%multinomial_uni_pers4_2(pers_16,ln_B_cryp)
%multinomial_uni_pers4_2(pers_16,ln_vit_D)
%multinomial_uni_pers4_2(pers_16,folate);
run;

/*** 4-groupr HPV, adjust for 9 covariates */
%macro adj_pers4_2(var1,var2);
proc surveylogistic data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a ;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') &var1.(ref='1')/param=ref;
 model &var1.(event='1')=ag4 edu pirg4 mari race sex_p12 smk druglf au12 &var2./link=glogit DF=INFINITY;
%mend adj_pers4_2;

%adj_pers4_2(pers_16,ln_vit_A);
%adj_pers4_2(pers_16,ln_vit_b2);
%adj_pers4_2(pers_16,ln_folate);


%adj_pers4_2(pers_18,ln_vit_A);
%adj_pers4_2(pers_18,ln_vit_b2);
%adj_pers4_2(pers_18,ln_folate);

proc freq data=p1.hpv_ms_v6;
 where elg_v_a=1;
 table pers_16;
 run;


/** LinHY 12/02/2020
check interaction of vaginal infection vs. antibody on antioxidants 
******/;

%macro int_iv2(outcome, type);
proc surveyreg data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a;
 model &outcome. =hpv_type&type. / solution;
run;

proc surveyreg data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a;
 model &outcome. = anti_&type.  / solution;
run;

proc surveyreg data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a;
 model &outcome. =hpv_type&type. anti_&type.  hpv_type&type.* anti_&type. / solution;
run;
%mend int_iv2;

%int_iv2(ln_vit_A, 16);
%int_iv2(ln_vit_b2, 16);
%int_iv2(ln_folate, 16);

%int_iv2(ln_vit_A, 18);
%int_iv2(ln_vit_b2, 18);
%int_iv2(ln_folate, 18);

proc surveyreg data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a;
 class pers_16 (ref='1') ;
 model ln_vit_A = pers_16 / solution;
run;

proc surveyreg data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a;
 class pers_16 (ref='1') ;
 model ln_vit_b2 = pers_16 / solution;
run;
proc surveyreg data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a;
 class pers_16 (ref='1') ;
 model ln_folate = pers_16 / solution;
run;
proc surveyreg data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a;
 class pers_16 (ref='1') ;
 model ln_sele = pers_16 / solution;
run;


proc surveyreg data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a;
 model ln_vit_A=hpv_type16 anti_16  hpv_type16*anti_16 / solution;
run;



%multinomial_uni_pers4_1(pers_18,ln_LBDSTBSI)
%multinomial_uni_pers4_1(pers_18,ln_LBDFERSI)
%multinomial_uni_pers4_1(pers_18,ln_LBDSALSI)
%multinomial_uni_pers4_1(pers_18,ln_URXUMA)
%multinomial_uni_pers4_1(pers_18,ln_LBDSUASI)
run;

%multinomial_uni_pers4_2(pers_18,ln_vit_A)
%multinomial_uni_pers4_2(pers_18,ln_vit_b2)
%multinomial_uni_pers4_2(pers_18,ln_vit_C)
%multinomial_uni_pers4_2(pers_18,ln_vit_E_add)
%multinomial_uni_pers4_2(pers_18,ln_vit_E)
%multinomial_uni_pers4_2(pers_18,ln_A_caro)
%multinomial_uni_pers4_2(pers_18,ln_sele)
%multinomial_uni_pers4_2(pers_18,ln_lyco)
%multinomial_uni_pers4_2(pers_18,ln_lut_zeax)
%multinomial_uni_pers4_2(pers_18,ln_B_cryp)
%multinomial_uni_pers4_2(pers_18,ln_vit_D)
%multinomial_uni_pers4_2(pers_18,folate)
run;

/****
11/2/2020
LinHY 

********/;

/* paper, Table 4 ***/;

proc surveyfreq data=ms_201102;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 tables elg_v*(alb_cat va_cat)*hpv_g3/row chisq;
run;

/** for MEC **/
%macro p_reg_tree1(indata, var);
proc surveylogistic data=&indata. ;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v;
 class &var. hpv_g3/param=ref ref=first;
 model hpv_g3(event='0')=&var./link=glogit df=infinity;
 run;
%mend p_reg_tree1;

%p_reg_tree(albu_cat)
%p_reg_tree1(ms_201102, alb_cat);
%p_reg_tree1(ms_201102, va_cat);

%p_reg_tree1(p1.hpv_ms_v6, alb_cat);
/*
Albumin(g/L) */;

proc surveylogistic data=ms_201102;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v;
 class alb_cat (ref='2') hpv_g3 (ref='0')/param=ref;
 model hpv_g3(event='0')=alb_cat/link=glogit df=infinity;
 run;

 proc surveylogistic data=ms_201102;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') alb_cat (ref='2')/param=ref;
 model hpv_g3(event='0')= ag4 edu pirg4 mari race sex_p12 smk druglf au12 alb_cat/link=glogit df=infinity;
 run;

 %macro LR_multi(indata, var);
proc surveylogistic data=&indata.;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') &var.(ref='0')/param=ref;
 domain elg_v ;
 model hpv_g3= ag4 edu pirg4 mari race sex_p12 smk druglf au12 &var./link=glogit df=infinity;
%mend LR_multi;

%LR_multi(ms_201102, va_cat);


/*** multi-vit model 
*/

/** MEC weight 

vit-a correlated with b2 and folate
*/
proc surveylogistic data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') /param=ref;
 domain elg_v ;
 model hpv_g3= ag4 edu pirg4 mari race sex_p12 smk druglf au12 ln_LBDSALSI ln_vit_A ln_vit_b2 ln_vit_e ln_folate/link=glogit df=infinity;
 run;

 proc surveylogistic data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') /param=ref;
 domain elg_v ;
 model hpv_g3= ag4 edu pirg4 mari race sex_p12 smk druglf au12 ln_LBDSALSI  ln_vit_e /link=glogit df=infinity;
 run;

proc corr data=p1.hpv_ms_v6;
 var ln_LBDSALSI ln_vit_A ln_vit_b2 ln_vit_e ln_folate;
 run;

proc freq data=p1.hpv_ms_v6;

 table elg_v *elg_v_a;
 run;


/***************
 11/8/2020
 PCA analyses

 only 1 PCs (69%) 


 *************/;
/* WARNING: 527 of 11070 observations in data set P1.HPV_MS_V6 omitted due to missing values.

 with std did not change the output

ln_LBDSALSI is differnt from the other 4

Pick only 1 PCA with Eigenvalue >1
  for vitamin intake contributed similar weights
 */;
 ods rtf file='O:\yi2015\NHANES\HPV_NHANES\results\pca_hpvg3_5var.rtf';
 proc princomp data=p1.hpv_ms_v6 std outstat=pca_v;
  where elg_v =1 ;
  var ln_LBDSALSI ln_vit_A ln_vit_b2 ln_vit_e ln_folate;
  run;
 ods rtf close;

 
 proc princomp data=p1.hpv_ms_v6 std n=1 outstat=pca_v out=pca_b;
  where elg_v =1 ;
  var ln_vit_A ln_vit_b2 ln_vit_e ln_folate;
    run;


/*
	SAS 'prin1' is a eigenvetor x standardize score, then standardize again with mean=0 and std=1
***/;
data pca_b1;
 set pca_b;


/** based on NIH recommend dose **/;
if LBDSALSI=. then albu_rg3=.;
else if LBDSALSI=<35 then albu_rg3=0;
else if LBDSALSI>50 then albu_rg3=2;
else albu_rg3=1;

if LBDSALSI=. then albu_g4=.;
else if LBDSALSI=<39 then albu_g4=1;
else if LBDSALSI>39 and LBDSALSI<=41 then albu_g4=2;
else if LBDSALSI>41 and LBDSALSI<=44 then albu_g4=3;
else albu_g4=4;

/*
normal range: Albumin:	35 to 50 g/L (or 3.5 to 5.0 g/dL)
**/;

if LBDSALSI=. then albu_g4s=.;
else if LBDSALSI<35 then albu_g4s=1;
else if LBDSALSI>=35 and LBDSALSI<40 then albu_g4s=2;
else if LBDSALSI>=40 and LBDSALSI<50 then albu_g4s=3;
else albu_g4s=4;



if LBDSALSI=. then albu_g6=.;
else if LBDSALSI<35 then albu_g6=1;
else if LBDSALSI>=35 and LBDSALSI<39 then albu_g6=2;
else if LBDSALSI>=39 and LBDSALSI<42 then albu_g6=3;
else if LBDSALSI>=42 and LBDSALSI<44 then albu_g6=4;
else if LBDSALSI>=44 and LBDSALSI<50 then albu_g6=5;
else albu_g6=6;


/*
if LBDSALSI=. then albu_g4s=.;
else if LBDSALSI<35 then albu_g4s=1;
else if LBDSALSI>=35 and LBDSALSI<40 then albu_g4s=2;
else if LBDSALSI>=40 and LBDSALSI<44 then albu_g4s=3;
else albu_g4s=4;
*/;

/* Q4
if LBDSALSI=. then albu_g4=.;
else if LBDSALSI=<39.4 then albu_g4=1;
else if LBDSALSI>39.4 and LBDSALSI<=41.6 then albu_g4=2;
else if LBDSALSI>41.6 and LBDSALSI<=44 then albu_g4=3;
else albu_g4=4;
*/

 ln_vit_A_sd=(ln_vit_A - 6.047)/0.828;
 ln_vit_b2_sd=(ln_vit_b2-0.486)/0.494;
 ln_vit_e_sd=(ln_vit_e-1.784)/0.618;
ln_folate_sd=(ln_folate-6.013)/0.576;


score4a=(0.502*ln_vit_A_sd+	0.528*ln_vit_b2_sd+	0.466*ln_vit_e_sd+	0.502*ln_folate_sd);


score4=(0.502*ln_vit_A_sd+	0.528*ln_vit_b2_sd+	0.466*ln_vit_e_sd+	0.502*ln_folate_sd)/1.6578155;


/** standardize var */
/*
 ln_vit_A_sd=(ln_vit_A - 6.047436858)/0.827745712;
 ln_vit_b2_sd=(ln_vit_b2-0.4855679111)/0.4944759598;
 ln_vit_e_sd=(ln_vit_e-1.783773722)/0.617514248;
ln_folate_sd=(ln_folate-6.013434663)/0.576226623;

pca1=(0.502013*ln_vit_A_sd+	0.527773*ln_vit_b2_sd+	0.465811*ln_vit_e_sd+	0.502453*ln_folate_sd)/1.6578155;
*/;

dif=score4-prin1;

/* 4-g, unweighted cut-points */
if score4=. then score4_g4=.;
else if score4<= -0.55 then score4_g4=1;
else if score4> -0.55 and score4<= 0.07 then score4_g4=2;
else if score4> 0.07 and score4<= 0.65 then score4_g4=3;
else score4_g4=4;

/* 4-g, weighted cut-points */
if score4=. then score4_wg4=.;
else if score4<= -0.46 then score4_wg4=1;
else if score4> -0.46 and score4<= 0.15 then score4_wg4=2;
else if score4> 0.15 and score4<= 0.72 then score4_wg4=3;
else score4_wg4=4;

/* 7-g, weighted cut-points */
if score4=. then score4_wg7=.;
else if score4<= -1.08 then score4_wg7=1;
else if score4> -1.08 and score4<= -0.62 then score4_wg7=2;
else if score4> -0.62 and score4<= -0.07 then score4_wg7=3;
else if score4> -0.07 and score4<= 0.38 then score4_wg7=4;
else if score4> 0.38 and score4<= 0.86 then score4_wg7=5;
else if score4> 0.86 and score4<= 1.20 then score4_wg7=6;
else score4_wg7=7;



score5=1.267*ln_LBDSALSI+ 0.0899*Prin1;

if score5=. then score5_g=.;
else if score5<=4.53 then score5_g=1;
else if score5>4.53 and score5<=4.63 then score5_g=2;
else if score5>4.63 and score5<=4.81 then score5_g=3;
else if score5>4.81 and score5<=4.89 then score5_g=4;
else score5_g=5;


if score5=. then score5_g4=.;
else if score5<=4.63 then score5_g4=1;
else if score5>4.63 and score5<=4.73 then score5_g4=2;
else if score5>4.73 and score5<=4.81 then score5_g4=3;
else score5_g4=4;


label prin1='principal component 1 genereated by SAS (standard dize score with mean=0, SD=1) with ln-transformed vit A, B2, E and folate'
albu_g4='albumin, log-transform albumin, 1: <=39, 2: (39,41], 3: (41, 44], 4:>44'
score4='PCA weighted score for 4 vitamins (vit-A, vit-B2, vit-E & folate)'
score4_wg4='4 nutrition score (vit-A, vit-B2, vit-E & folate), 4-group (weighted cutpoints), 1:<= -0.46, 2: (-0.46, 0.15], 3:(0.15, 0.72], 4:>0.72 '
  score4_wg7='4 nutrition score, 7-group (weighted cutpoints)'


;

 run;

proc freq data=pca_b1;
 where elg_v =1;
 *table score4 score4_g4;
 table albu_g4 albu_g4s;
 run;
 
proc means data=pca_b1;
 where elg_v =1;
 var prin1 score4 score4a;
 run;

proc means data=pca_b1 n mean std min q1 median q3 max;
 where elg_v =1;
 *class albu_g4;
 var LBDSALSI;
 run;

  proc surveymeans data=pca_b1 percentile=(25,50,75) ;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v ;
 var LBDSALSI;
run;




 proc means data=pca_b1;
  *var ln_vit_A ln_vit_A_sd ln_vit_b2 ln_vit_b2_sd ln_vit_e_sd ln_folate_sd;
  var prin1 score4 dif;
  run;
/* 4 g */
 proc means data=pca_b1 n mean std q1 median q3 min max;
  where elg_v =1 ;
  var score4;
  run;
    proc surveymeans data=pca_b1  ;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 domain elg_v ;
 var score4;
run;
  proc surveymeans data=pca_b1 percentile=(25, 50, 75) ;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 domain elg_v ;
 var score4;
run;
  proc surveymeans data=pca_b1 percentile=(0, 10, 20,40,60,80,90, 100) ;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 domain elg_v ;
 var score4;
run;


 proc means data=pca_b1 n mean std q1 median q3 min max;
  var score4;
  run;

 proc means data=pca_b;
   where elg_v =1 ;
  var prin1;
  *var ln_vit_A ln_vit_b2 ln_vit_e ln_folate;
  run;

proc univariate data=pca_b1;
 var score4;
 histogram score4;
 run;


 /******************
 nutritional antioxidant score (NAS)
 
 ****/
   proc surveylogistic data=pca_b;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') /param=ref;
 domain elg_v ;
 model hpv_g3= ag4 edu pirg4 mari race sex_p12 smk druglf au12 ln_LBDSALSI  prin1 /link=glogit df=infinity;
 run;
 
 proc surveylogistic data=pca_b1;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') score5_g4(ref='1')/param=ref;
 domain elg_v ;
 model hpv_g3= ag4 edu pirg4 mari race sex_p12 smk druglf au12 score5_g4/link=glogit df=infinity;
 run;




 /**************PCA Based**************/
 ods rtf file='O:\yi2015\NHANES\HPV_NHANES\results\pca_hpvg3.rtf';
 proc princomp data=p1.hpv_ms_v6 std outstat=pca_v;
  where elg_v =1 ;
  var ln_vit_A ln_vit_b2 ln_vit_e ln_folate;
  run;
 ods rtf close;


  proc princomp data=p1.hpv_ms_v6 std outstat=pca_v;
  where elg_v =1 ;
  var ln_LBDSALSI ln_vit_A ln_vit_b2 ln_vit_e ln_folate;
  run;


/*** 4-group (unweighted), the weighted sample size in the 4 groups are NOT similar */
 
proc surveyfreq data=pca_b1;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 tables elg_v*score4_g4 *hpv_g3/row chisq;
run;

/*** 4-group (weighted), the weighted sample size in the 4 groups are similar
should use weighted cut-points 
*/
 

/*** paper, Figure 1 **/;
proc surveyfreq data=pca_b1;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 tables elg_v*score4_wg4 *hpv_g3/row chisq;
run;

proc surveyfreq data=pca_b1;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 tables elg_v*score4_wg7 *hpv_g3/row chisq;
run;


 proc surveylogistic data=pca_b1;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') score4_wg4 (ref='1')/param=ref;
 domain elg_v ;
 model hpv_g3= ag4 edu pirg4 mari race sex_p12 smk druglf au12 ln_LBDSALSI  score4_wg4 /link=glogit df=infinity;
 run;

 /*** paper, Table 4 
albu_g4   score4_wg4 used for paper
**/;
/** ablu_g4 */

 proc surveylogistic data=pca_b1;
 strata sdmvstra;
 cluster sdmvpsu;
 weight  WTDRd1_14yr;
 *weight wtmec14yr;
 class hpv_g3(ref='0') score4_wg4 (ref='3')/param=ref;
 domain elg_v ;
 model hpv_g3=  score4_wg4 /link=glogit df=infinity;
 run;

 proc surveylogistic data=pca_b1;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_g3(ref='0') score4_wg4 (ref='1') albu_g4 (ref='1')/param=ref;
 domain elg_v ;
 model hpv_g3=  albu_g4   score4_wg4 /link=glogit df=infinity;
 run;

 /** 2/16/2021 reverse reference */;
 proc surveylogistic data=pca_b1;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class hpv_g3(ref='0') score4_wg4 (ref='4') albu_g4 (ref='4')/param=ref;
 domain elg_v ;
 model hpv_g3=  albu_g4   score4_wg4 /link=glogit df=infinity;
 run;

 proc surveylogistic data=pca_b1;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') score4_wg4 (ref='1') albu_g4 (ref='1')/param=ref;
 domain elg_v ;
 model hpv_g3= ag4 edu pirg4 mari race sex_p12 smk druglf au12 albu_g4  score4_wg4 /link=glogit df=infinity;
 run;

 /** 2/16/2021 reverse reference */;
 proc surveylogistic data=pca_b1;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') score4_wg4 (ref='4') albu_g4 (ref='4')/param=ref;
 domain elg_v ;
 model hpv_g3= ag4 edu pirg4 mari race sex_p12 smk druglf au12 albu_g4  score4_wg4 /link=glogit df=infinity;
 run;

  proc surveylogistic data=pca_b1;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') score4_wg4 (ref='4') albu_g6 (ref='4')/param=ref;
 domain elg_v ;
 model hpv_g3= ag4 edu pirg4 mari race sex_p12 smk druglf au12 albu_g6  score4_wg4 /link=glogit df=infinity;
 run;
 /** check n */;

 proc logistic data=pca_b1;
 where elg_v=1;
 class ag4(ref='1') edu(ref='1') pirg4(ref='1') mari(ref='1') race(ref='1') sex_p12(ref='0')
 smk(ref='0') druglf(ref='0') au12(ref='0') hpv_g3(ref='0') score4_wg4 (ref='1') albu_g4 (ref='1')/param=ref;
 model hpv_g3= ag4 edu pirg4 mari race sex_p12 smk druglf au12 albu_g4  score4_wg4 ;
 run;

 proc logistic data=pca_b1;
 where elg_v=1;
 class hpv_g3(ref='0') score4_wg4 (ref='1') albu_g4 (ref='1')/param=ref;
 model hpv_g3=  albu_g4  score4_wg4 ;
 run;
  proc surveymeans data=pca_b1  ;
*class hpv_g3;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 domain elg_v hpv_g3;
 var score4;
run;

proc freq data=p1.hpv_ms_v6;
 table (SXQ753 SXQ265)*pers_16/missing;
 run;

 /*
 <SXQ753: 2010-2016>
SXQ753	Ever told by doctor, you had HP (SXQ_F)	2009-2010 Questionnaire
 SXQ265 - Doctor ever told you had genital warts <1999-2016>
•	1: yes, 2: no
****/;


/*
class y35(ref='0') alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') 
      &var1. (ref='0') /param=ref;
model &var1. (event='0')= &var2. y35 alone sex1 druglf eversmk
*/;


%macro int_iv2_adj(indata,outcome, type);
proc surveyreg data=&indata.;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 class y35(ref='0') alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0')  ;
 domain elg_v_a;
 model &outcome. =y35 alone sex1 druglf eversmk hpv_type&type. / solution;
run;

proc surveyreg data=&indata.;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a;
 class y35(ref='0') alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') ;
 model &outcome. = y35 alone sex1 druglf eversmk anti_&type.  / solution;
run;

proc surveyreg data=&indata.;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a;
 class y35(ref='0') alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') ;
 model &outcome. =y35 alone sex1 druglf eversmk hpv_type&type. anti_&type.  hpv_type&type.* anti_&type. / solution;
run;
%mend int_iv2_adj;

%macro chk(vit, type);

proc surveyreg data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a;
 model &vit. = hpv_type&type. anti_&type.  hpv_type&type.* anti_&type. / solution;
run;
%mend chk;

%int_iv2_adj(quasi_check, ln_vit_a,16);
%int_iv2_adj(quasi_check, ln_vit_b2,16);

/******* 
12/3/2020
age sub-group 
Age is an important confunidng factor associated with HPV antibody/vaginal
+/+ high vitamin effect only significant for women with age<=35

*/
proc surveyreg data=quasi_check;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a;
 where y35=0;
 class alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') ;
 model ln_vit_b2 = alone sex1 druglf eversmk hpv_type16 anti_16  hpv_type16* anti_16 / solution;
run;
proc surveyreg data=quasi_check;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a;
 where y35=1;
 class alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') pers_16 (ref='1');
 model ln_vit_a = alone sex1 druglf eversmk pers_16 / solution;
run;

/** check without sampling weights */;
proc glm data=quasi_check;
 where elg_v_a=1;
 class y35(ref='0') alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') ;
 model ln_vit_b2 =y35 alone sex1 druglf eversmk hpv_type16 anti_16  hpv_type16* anti_16 / solution;
run;

/* young grup */;
proc glm data=quasi_check;
 where elg_v_a=1 and y35=1;
 class  alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') ;
 model ln_vit_b2 = alone sex1 druglf eversmk hpv_type16 anti_16  hpv_type16* anti_16 / solution;
run;

proc surveylogistic data=quasi_check;
 strata sdmvstra;
 cluster sdmvpsu;
 *weight WTDRd1_14yr;
 weight WTDRd1_8yr;
 domain elg_v_a;
 class y35(ref='0') alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') 
       /param=ref;
model pers_g3_16 (event='0')=  y35 alone sex1 druglf eversmk ln_vit_A/link=glogit  DF=INFINITY;
run;


proc freq data=quasi_check;
 table pers_g3_16;
 run;


proc surveylogistic data=quasi_check;
 strata sdmvstra;
 cluster sdmvpsu;
 *weight WTDRd1_14yr;
 weight WTDRd1_8yr;
 domain elg_v_a;
 class ag4(ref='1') alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') pers_g3_16 (ref='0')
       /param=ref;
model pers_g3_16 (event='2')=  ag4 alone sex1 druglf eversmk ln_vit_A/link=glogit  DF=INFINITY;
run;

proc surveylogistic data=quasi_check;
 where pers_g3_16 ne 0 and y35=0;
 strata sdmvstra;
 cluster sdmvpsu;
 *weight WTDRd1_14yr;
 weight WTDRd1_8yr;
 domain elg_v_a;
 class alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') pers_g3_16 (ref='1')
       /param=ref;
model pers_g3_16 (event='2')=  alone sex1 druglf eversmk ln_vit_A/link=glogit  DF=INFINITY;
run;

proc surveylogistic data=quasi_check;
 where pers_g3_16 ne 0 and y35=0;
 strata sdmvstra;
 cluster sdmvpsu;
 *weight WTDRd1_14yr;
 weight WTDRd1_8yr;
 domain elg_v_a;
* class alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') pers_g3_16 (ref='1')
       /param=ref;
model pers_g3_16 (event='2')=   ln_vit_A/link=glogit  DF=INFINITY;
run;

proc surveylogistic data=quasi_check;
 where ag4=3;
 strata sdmvstra;
 cluster sdmvpsu;
 *weight WTDRd1_14yr;
 weight WTDRd1_8yr;
 domain elg_v_a;
 class  alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') pers_g3_16 (ref='0')
       /param=ref;
model pers_g3_16 (event='2')=  alone sex1 druglf eversmk ln_vit_A/link=glogit  DF=INFINITY;
run;

/* age sub-group */
proc surveylogistic data=quasi_check;
 where y35=0;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a;
 class alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0')   pers_g3_16 (ref='0')     /param=ref;
model pers_g3_16 (event='0')=   alone sex1 druglf eversmk ln_vit_A/link=glogit  DF=INFINITY;
run;

/** just for antibody
12/3/2020

# vit-a & b2 did not impact on anti_16

<I found the potential answer>
# among active infection, vit-A increased antibody positivity (posible reason, prolong antibody positivity, or new/old infection>
**/
proc surveylogistic data=quasi_check;
 where hpv_type16=1;
 strata sdmvstra;
 cluster sdmvpsu;
 *weight WTDRd1_14yr;
 weight WTDRd1_8yr;
 domain elg_v_a;
 class y35(ref='0') alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') anti_16 (ref='0')       /param=ref;
model anti_16 (event='1')=  y35 alone sex1 druglf eversmk ln_vit_A/link=glogit  DF=INFINITY;
run;
/** continous age */
proc surveylogistic data=quasi_check;
 where hpv_type16=1;
 strata sdmvstra;
 cluster sdmvpsu;
 *weight WTDRd1_14yr;
 weight WTDRd1_8yr;
 domain elg_v_a;
 class  alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') anti_16 (ref='0')       /param=ref;
model anti_16 (event='1')=  age alone sex1 druglf eversmk ln_vit_A/link=glogit  DF=INFINITY;
run;

proc surveylogistic data=quasi_check;
  where hpv_type16=1;
 strata sdmvstra;
 cluster sdmvpsu;
 *weight WTDRd1_14yr;
 weight WTDRd1_8yr;
 domain elg_v_a;
 class y35(ref='0') alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') anti_16 (ref='0')
       /param=ref;
model anti_16 (event='1')=  y35 alone sex1 druglf eversmk ln_vit_b2/link=glogit  DF=INFINITY;
run;

proc surveylogistic data=quasi_check;
  where hpv_type16=1;
 strata sdmvstra;
 cluster sdmvpsu;
 *weight WTDRd1_14yr;
 weight WTDRd1_8yr;
 domain elg_v_a;
 class y35(ref='0') alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') anti_16 (ref='0')
       /param=ref;
model anti_16 (event='1')=  y35 alone sex1 druglf eversmk ln_folate/link=glogit  DF=INFINITY;
run;

/** How about HPV infecion **/
proc surveylogistic data=quasi_check;
   strata sdmvstra;
 cluster sdmvpsu;
 *weight WTDRd1_14yr;
 weight WTDRd1_8yr;
 domain elg_v_a;
 class y35(ref='0') alone(ref='0')  eversmk(ref='0')
      sex1(ref='0')  druglf(ref='0') hpv_type16 (ref='0')
       /param=ref;
model hpv_type18 (event='1')=  y35 alone sex1 druglf eversmk ln_vit_A/link=glogit  DF=INFINITY;
run;

proc freq data=quasi_check;
 where  elg_v_a=1;
 table (hpv_type16 anti_16) * y35/chisq;
 run;

proc means data=quasi_check;
 class y35;
 where  elg_v_a=1;
  var age;
run;

/***
12/4/2020
try to find confounding factor between ln_vit_A and anti_16 for those with infection 
***/;

proc freq data=p1.hpv_ms_v6;
 table ag4 sex_p12;
 run;

%macro reg(outcome, var, base);

proc surveyreg data=p1.hpv_ms_v6;
 where ag4=1;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 class &var. (ref="&base.");
 domain elg_v_a;
 model &outcome.= &var./ solution;
%mend reg;

%reg(ln_vit_a, ag4, 1);
%reg(ln_vit_a, sex_p12,0);
%reg(ln_vit_a, bmig3, 1);
%reg(ln_vit_a,mari,1);
%reg(ln_vit_a,race,1);

%sfreq(edu);
%sfreq(race);
%sfreq(pirg4);
%sfreq(mari);
%sfreq(smk);
%sfreq(druglf);
%sfreq(au12);


proc surveymeans data=p1.hpv_ms_v6;
 where ag4=1;
 strata sdmvstra; 
 cluster sdmvpsu; 
 weight WTDRd1_8yr; 
 domain elg_v_a*sex_p12; 
 var ln_vit_A ; 
run;


/***********
12/6/2020, LinHY
check 2x2 table for HPv16
****/;

%submean2(p1.hpv_ms_v6,anti_16); 
%submean2(p1.hpv_ms_v6,hpv_type16); 

proc freq data=p1.hpv_ms_v6;
 where elg_v_a=1 ; 
 table anti_16*hpv_type16 pers_16 pers_g3_16;
 run;

/** mean for the whole group */
proc surveymeans data=p1.hpv_ms_v6;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a ;
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp vit_D folate;
run;


/** model for checking anti or inf sub-groups */

%macro LR2(indata,var1, var2);

proc surveylogistic data=&indata.;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_8yr;
 domain elg_v_a;
 class y35(ref='0') alone(ref='0')  eversmk(ref='0')
      sex1(ref='0') druglf(ref='0') 
      &var1. (ref='0') /param=ref;
model &var1. (event='1')= y35 alone sex1 druglf eversmk &var2./link=glogit  DF=INFINITY;
run;

%mend LR2;

%LR2(quasi_check,hpv_type16, ln_vit_a); 
%LR2(quasi_check,anti_16, ln_vit_a); 

%LR2(quasi_check,hpv_type16, ln_vit_b2); 
%LR2(quasi_check,anti_16, ln_vit_b2); 

%LR2(quasi_check,hpv_type16, ln_folate); 
%LR2(quasi_check,anti_16, ln_folate); 

/**LR: 3-group comparrison **/;
%p_multi05a(pers_g3_16, ln_folate);


/**LR: 4-group comparrison **/;
%p_multi05b(quasi_check, pers_16, ln_vit_A);

%p_multi05b(quasi_check, pers_16, ln_vit_b2);

%p_multi05b(quasi_check, pers_16, ln_folate);

proc freq data=quasi_check;
 table hpv_type16;
 run;

 
/** check HR-HPV types ***/;
proc freq data=p1.hpv_ms_v6;
 *where  elg_v=1 ;
 where  elg_v=1 and hpv_g3=2;
  *table hpv_g3 hpv_type16* hpv_type18/list ;
  *table hpv_g3 *(hpv_type16 hpv_type18 hpv_type31 hpv_type33 hpv_type35 hpv_type39 hpv_type45 hpv_type51 hpv_type52 hpv_type56 
	hpv_type58 hpv_type59);
 table hpv_type16 hpv_type18 hpv_type31 hpv_type33 hpv_type35 hpv_type39 hpv_type45 hpv_type51 hpv_type52 hpv_type56 
	hpv_type58 hpv_type59;
  run;


  /*** 4/25/2022 check weighting */
proc means data=  p1.hpv_ms_v6 ;
 class elg_v ;
 var WTDRd1_14yr wtmec14yr;
  run;

/******************
  10/21/2024
  create a daaset for Anand for ML/AI method 

  ***********/;

data hpv_ms_elg;
 set d2.hpv_ms_v6;
 if  elg_v=1 and hpv_g3 ne . ; 

run;

/* n=11070 */

data d_HPV_NHANES_JID2021;
 set hpv_ms_elg;
 keep seqn HPV_g3 ag4 race edu mari pirg4 bmig3 smk au12 druglf sex_p12
   LBDSTBSI LBDFERSI  LBDSALSI URXUMA  LBDSUASI vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp vit_d folate ;
  run;

/***
  data d2.HPV_NHANES_JID2021;
   set d_HPV_NHANES_JID2021;
  run;
 ********/;


/***

proc freq data=hpv_ms_elg;
 table HPV_g3;
 run;

/***all correct */
proc freq data=hpv_ms;
 where  elg_v=1 and hpv_g3 ne . ; 
 table ag4 race edu mari pirg4 bmig3 smk au12 druglf sex_p12 ;
 run;

 /* table 2 */

 
proc surveymeans data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight wtmec14yr;
 domain elg_v ;
 *where hpv_g3=0;
 var LBDSTBSI LBDFERSI  LBDSALSI URXUMA  LBDSUASI;
run;


proc surveymeans data=hpv_ms;
 strata sdmvstra;
 cluster sdmvpsu;
 weight WTDRd1_14yr;
 domain elg_v;
 var vit_A vit_b2 vit_C vit_E_add vit_E A_caro sele lyco lut_zeax B_cryp vit_d folate;
run;
