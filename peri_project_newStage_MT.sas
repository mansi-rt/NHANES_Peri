/*
use NHANES 2013-2014 data
Assign a permanent library to the folder where you want to save the .sas7bdat files 

/*
From PI
PERIODONTITIS is defined based on following criteria for ATTACHMENT LOSS, PROBING DEPTH:
•	Attachment loss of 1 mm or more on at least 2 teeth (even 1 surface/ tooth counts but only surfaces of interest are DF, MF, DL and ML) with PD (pocket depth) 4 mm or 
•	more on at least 2 teeth (even 1 surface/ tooth counts but only surfaces of interest are DF, MF, DL and ML)) is defined as periodontitis. 
•	Otherwise defined as no periodontitis (0 mm attachment loss on all teeth or less than 2 teeth have more than 0 mm attachment loss). 
•	Attachment loss and probing depth is measured on six surfaces (DF, MDF, MF, DL, MDL, ML) per tooth. 

NHANES peri questions are for age >=30
*/

/** set up missing **/; 
/* libname permdata 'T:\LinHY_project\NHANES\oral_health\data'; */

libname permdata '/home/u49748641/LSU/Peri Project';

/*============================================*/
/* SECTION 1 : MACROS TO SET UP DATA          */
/*============================================*/

%macro Vrecode(var,cutp,nvar);
     if &var.=. or &var.=99 then &nvar.=.;
	 else if &var. >= &cutp. then &nvar.=1;
     else  &nvar.= 0;
%mend vrecode;


/** define missing and rename */
%macro rename(var,nvar);

    if &var.=. or &var.=99 then &nvar.=.;
	else &nvar.=&var.;

%mend rename;

%macro rename_1t(tooth, df_al, mf_al, dl_al, ml_al, df_pd, mf_pd, dl_pd, ml_pd);
    %rename(&df_al., LOA_DF_&tooth);
	%rename(&mf_al., LOA_MF_&tooth);
	%rename(&dl_al., LOA_DL_&tooth);
	%rename(&ml_al., LOA_ML_&tooth);

	
	%rename(&df_pd., PD_DF_&tooth);
	%rename(&mf_pd., PD_MF_&tooth);
	%rename(&dl_pd., PD_DL_&tooth);
	%rename(&ml_pd., PD_ML_&tooth);
%mend rename_1t;

/******** Actually performing the analysis on all teeth ****/
/* Macro for creating periodontitis for individual teeth */
/* Creating a periodontitis variable for the specific tooth 
	Adding the missing variable value */

/** 
A tooth that follows both of the following 2 criteria will be considered a PERIODONTITIS symptom for this tooth. Is this correct? 
1. At least 1 out of the 4 surfaces (DF, MF, DL, and ML) with attachment loss >= 1 mm
2.  At least 1 out of the 4 surfaces (DF, MF, DL, and ML) with PD >= 4 mm
for a missing tooth, the LOA and PD statuses were treated as 0 
***/; 

%macro peri_1t(tooth, df_al, mf_al, dl_al, ml_al, df_pd, mf_pd, dl_pd, ml_pd);

	%vrecode(&df_al., 1, LOA_DF_ge1_&tooth);
	%vrecode(&mf_al., 1, LOA_MF_ge1_&tooth);
	%vrecode(&dl_al., 1, LOA_DL_ge1_&tooth);
	%vrecode(&ml_al., 1, LOA_ML_ge1_&tooth);

	%vrecode(&df_pd., 4, PD_DF_ge4_&tooth);
	%vrecode(&mf_pd., 4, PD_MF_ge4_&tooth);
	%vrecode(&dl_pd., 4, PD_DL_ge4_&tooth);
	%vrecode(&ml_pd., 4, PD_ML_ge4_&tooth);

If t&tooth.=. then LOA_4s_ge1_&tooth.=.;
Else if t&tooth.=0 then LOA_4s_ge1_&tooth.=0;
Else if t&tooth.=1 then do;
	if LOA_DF_ge1_&tooth.=1 or LOA_MF_ge1_&tooth.=1 or LOA_DL_ge1_&tooth.=1 or LOA_ML_ge1_&tooth.=1 then LOA_4s_ge1_&tooth.=1;
	else if LOA_DF_ge1_&tooth.=0 and LOA_MF_ge1_&tooth.=0 and LOA_DL_ge1_&tooth.=0 and LOA_ML_ge1_&tooth.=0 then LOA_4s_ge1_&tooth.=0;
	else LOA_4s_ge1_&tooth.=.;
end;

If t&tooth.=. then PD_4s_ge4_&tooth.=.;
else if t&tooth.=0 then PD_4s_ge4_&tooth.=0;
else if t&tooth.=1 then do;
	if PD_DF_ge4_&tooth.=1 or PD_MF_ge4_&tooth.=1 or PD_DL_ge4_&tooth.=1 or PD_ML_ge4_&tooth.=1 then PD_4s_ge4_&tooth.=1;
	else if PD_DF_ge4_&tooth.=0 and PD_MF_ge4_&tooth.=0 and PD_DL_ge4_&tooth.=0 and PD_ML_ge4_&tooth.=0 then PD_4s_ge4_&tooth.=0;
	else PD_4s_ge4_&tooth.=.;
end;

if  LOA_4s_ge1_&tooth.=. or  PD_4s_ge4_&tooth.=. then peri_t&tooth.=.;
else if LOA_4s_ge1_&tooth.=1 and PD_4s_ge4_&tooth.=1 then peri_t&tooth.=1;
else peri_t&tooth.=0;

%mend peri_1t;

/** count missing for the peri status of each tooth*/
%macro miss_ct(var);
  if &var.= . then &var._mis=1;
  else  &var._mis=0; 
%mend miss_ct;

	/** tooth present or not */
%macro t_count(var, tooth);
   if &var.=. or &var.=9 then t&tooth.=.;
   else if &var.=2 then t&tooth.=1;
   else t&tooth.=0;
%mend t_count;

/*============================================*/
/* SECTION 2 : MERGING AND CREATING PERI_ALL - CLEANING all main variables */
/*============================================*/

proc sort data=permdata.ohxper_h;
 by SEQN;
run;

proc sort data=permdata.ohxden_h;
 by SEQN;
run;

proc sort data=permdata.demo_h;
 by SEQN;
run;

proc sort data=permdata.csx_h;
 by SEQN;
run;

/*** 1/2/25, combine 4 datasets ***/
data merging_per_den;
    merge permdata.ohxper_h (in=a) permdata.ohxden_h (in=b) permdata.demo_h permdata.csx_h;
    by SEQN;
 *   if a; /* Keeps only observations that are in ohxper_h */
run;

/* Creating a dataset to calculate periodontitis for all relevant teeth */
data peri_all_teeth;
    set merging_per_den;
	%peri_1t(02, OHX02LAD, OHX02LAS, OHX02LAP, OHX02LAA, OHX02PCD, OHX02PCS, OHX02PCP, OHX02PCA);
run;


data peri_all;
    set merging_per_den;
rename RIDAGEYR=age;
	if OHDPDSTS=.  then peri_test=.;
	else if OHDPDSTS=1 or OHDPDSTS=2 then peri_test=1;
	else if OHDPDSTS=3 then peri_test=0;
	if OHDDESTS=.  then denti=.;
	else if OHDDESTS=1 or OHDDESTS=2 then denti=1;
	else if OHDDESTS=3 then denti=0;

/** indicate missing tooth status */
%t_count(OHX02TC, 02);
%t_count(OHX03TC, 03);
%t_count(OHX04TC, 04);
%t_count(OHX05TC, 05);
%t_count(OHX06TC, 06);
%t_count(OHX07TC, 07);
%t_count(OHX08TC, 08);
%t_count(OHX09TC, 09);
%t_count(OHX10TC, 10);
%t_count(OHX11TC, 11);
%t_count(OHX12TC, 12);
%t_count(OHX13TC, 13);
%t_count(OHX14TC, 14);
%t_count(OHX15TC, 15);


%t_count(OHX18TC, 18);
%t_count(OHX19TC, 19);
%t_count(OHX20TC, 20);
%t_count(OHX21TC, 21);
%t_count(OHX22TC, 22);
%t_count(OHX23TC, 23);
%t_count(OHX24TC, 24);
%t_count(OHX25TC, 25);
%t_count(OHX26TC, 26);
%t_count(OHX27TC, 27);
%t_count(OHX28TC, 28);
%t_count(OHX29TC, 29);
%t_count(OHX30TC, 30);
%t_count(OHX31TC, 31);

%t_count(OHX01TC, 01);
%t_count(OHX16TC, 16);
%t_count(OHX17TC, 17);
%t_count(OHX32TC, 32);

remaining_teeth=t01+ t02+ t03 + t04+ t05+ t06+ t07 + t08 +t09+ t10+ 
                 t11+ t12+ t13 + t14+ t15+ t16+ t17 + t18 +t19+ t20+
				 t21+ t22+ t23 + t24+ t25+ t26+ t27 + t28 +t29+ t30+ t31+ t32;

remaining_teeth_p28= t02+ t03 + t04+ t05+ t06+ t07 + t08 +t09+ t10+ 
                 t11+ t12+ t13 + t14+ t15+  t18 +t19+ t20+
				 t21+ t22+ t23 + t24+ t25+ t26+ t27 + t28 +t29+ t30+ t31;

    /* Calculate the number of remaining teeth based on 32 teeth */

	if remaining_teeth_p28=. then t_ls20=.;
	else if remaining_teeth_p28 ne . and remaining_teeth_p28< 20 then t_ls20=1;
	else t_ls20=0;


    /** NHANES only had peri data for 28 teeth, 
# from PI: Usually 3rd molars are excluded (#1,16,17,32) since it is missing for most people or out of position. 
****/;

   %rename_1t(02, OHX02LAD, OHX02LAS, OHX02LAP, OHX02LAA, OHX02PCD, OHX02PCS, OHX02PCP, OHX02PCA);
   %rename_1t(03, OHX03LAD, OHX03LAS, OHX03LAP, OHX03LAA, OHX03PCD, OHX03PCS, OHX03PCP, OHX03PCA);
   %rename_1t(04, OHX04LAD, OHX04LAS, OHX04LAP, OHX04LAA, OHX04PCD, OHX04PCS, OHX04PCP, OHX04PCA);
   %rename_1t(05, OHX05LAD, OHX05LAS, OHX05LAP, OHX05LAA, OHX05PCD, OHX05PCS, OHX05PCP, OHX05PCA);
   %rename_1t(06, OHX06LAD, OHX06LAS, OHX06LAP, OHX06LAA, OHX06PCD, OHX06PCS, OHX06PCP, OHX06PCA);
   %rename_1t(07, OHX07LAD, OHX07LAS, OHX07LAP, OHX07LAA, OHX07PCD, OHX07PCS, OHX07PCP, OHX07PCA);
   %rename_1t(08, OHX08LAD, OHX08LAS, OHX08LAP, OHX08LAA, OHX08PCD, OHX08PCS, OHX08PCP, OHX08PCA);
   %rename_1t(09, OHX09LAD, OHX09LAS, OHX09LAP, OHX09LAA, OHX09PCD, OHX09PCS, OHX09PCP, OHX09PCA);
   %rename_1t(10, OHX10LAD, OHX10LAS, OHX10LAP, OHX10LAA, OHX10PCD, OHX10PCS, OHX10PCP, OHX10PCA);
   %rename_1t(11, OHX11LAD, OHX11LAS, OHX11LAP, OHX11LAA, OHX11PCD, OHX11PCS, OHX11PCP, OHX11PCA);
   %rename_1t(12, OHX12LAD, OHX12LAS, OHX12LAP, OHX12LAA, OHX12PCD, OHX12PCS, OHX12PCP, OHX12PCA);
   %rename_1t(13, OHX13LAD, OHX13LAS, OHX13LAP, OHX13LAA, OHX13PCD, OHX13PCS, OHX13PCP, OHX13PCA);
   %rename_1t(14, OHX14LAD, OHX14LAS, OHX14LAP, OHX14LAA, OHX14PCD, OHX14PCS, OHX14PCP, OHX14PCA);
   %rename_1t(15, OHX15LAD, OHX15LAS, OHX15LAP, OHX15LAA, OHX15PCD, OHX15PCS, OHX15PCP, OHX15PCA);

   %rename_1t(18, OHX18LAD, OHX18LAS, OHX18LAP, OHX18LAA, OHX18PCD, OHX18PCS, OHX18PCP, OHX18PCA);
   %rename_1t(19, OHX19LAD, OHX19LAS, OHX19LAP, OHX19LAA, OHX19PCD, OHX19PCS, OHX19PCP, OHX19PCA);
   %rename_1t(20, OHX20LAD, OHX20LAS, OHX20LAP, OHX20LAA, OHX20PCD, OHX20PCS, OHX20PCP, OHX20PCA);
   %rename_1t(21, OHX21LAD, OHX21LAS, OHX21LAP, OHX21LAA, OHX21PCD, OHX21PCS, OHX21PCP, OHX21PCA);
   %rename_1t(22, OHX22LAD, OHX22LAS, OHX22LAP, OHX22LAA, OHX22PCD, OHX22PCS, OHX22PCP, OHX22PCA);
   %rename_1t(23, OHX23LAD, OHX23LAS, OHX23LAP, OHX23LAA, OHX23PCD, OHX23PCS, OHX23PCP, OHX23PCA);
   %rename_1t(24, OHX24LAD, OHX24LAS, OHX24LAP, OHX24LAA, OHX24PCD, OHX24PCS, OHX24PCP, OHX24PCA);
   %rename_1t(25, OHX25LAD, OHX25LAS, OHX25LAP, OHX25LAA, OHX25PCD, OHX25PCS, OHX25PCP, OHX25PCA);
   %rename_1t(26, OHX26LAD, OHX26LAS, OHX26LAP, OHX26LAA, OHX26PCD, OHX26PCS, OHX26PCP, OHX26PCA);
   %rename_1t(27, OHX27LAD, OHX27LAS, OHX27LAP, OHX27LAA, OHX27PCD, OHX27PCS, OHX27PCP, OHX27PCA);
   %rename_1t(28, OHX28LAD, OHX28LAS, OHX28LAP, OHX28LAA, OHX28PCD, OHX28PCS, OHX28PCP, OHX28PCA);
   %rename_1t(29, OHX29LAD, OHX29LAS, OHX29LAP, OHX29LAA, OHX29PCD, OHX29PCS, OHX29PCP, OHX29PCA);
   %rename_1t(30, OHX30LAD, OHX30LAS, OHX30LAP, OHX30LAA, OHX30PCD, OHX30PCS, OHX30PCP, OHX30PCA);
   %rename_1t(31, OHX31LAD, OHX31LAS, OHX31LAP, OHX31LAA, OHX31PCD, OHX31PCS, OHX31PCP, OHX31PCA);



    /* Running the macro for each tooth, specifying the relevant variables for each */

   %peri_1t(02, OHX02LAD, OHX02LAS, OHX02LAP, OHX02LAA, OHX02PCD, OHX02PCS, OHX02PCP, OHX02PCA);
   %peri_1t(03, OHX03LAD, OHX03LAS, OHX03LAP, OHX03LAA, OHX03PCD, OHX03PCS, OHX03PCP, OHX03PCA);
   %peri_1t(04, OHX04LAD, OHX04LAS, OHX04LAP, OHX04LAA, OHX04PCD, OHX04PCS, OHX04PCP, OHX04PCA);
   %peri_1t(05, OHX05LAD, OHX05LAS, OHX05LAP, OHX05LAA, OHX05PCD, OHX05PCS, OHX05PCP, OHX05PCA);
   %peri_1t(06, OHX06LAD, OHX06LAS, OHX06LAP, OHX06LAA, OHX06PCD, OHX06PCS, OHX06PCP, OHX06PCA);
   %peri_1t(07, OHX07LAD, OHX07LAS, OHX07LAP, OHX07LAA, OHX07PCD, OHX07PCS, OHX07PCP, OHX07PCA);
   %peri_1t(08, OHX08LAD, OHX08LAS, OHX08LAP, OHX08LAA, OHX08PCD, OHX08PCS, OHX08PCP, OHX08PCA);
   %peri_1t(09, OHX09LAD, OHX09LAS, OHX09LAP, OHX09LAA, OHX09PCD, OHX09PCS, OHX09PCP, OHX09PCA);
   %peri_1t(10, OHX10LAD, OHX10LAS, OHX10LAP, OHX10LAA, OHX10PCD, OHX10PCS, OHX10PCP, OHX10PCA);
   %peri_1t(11, OHX11LAD, OHX11LAS, OHX11LAP, OHX11LAA, OHX11PCD, OHX11PCS, OHX11PCP, OHX11PCA);
   %peri_1t(12, OHX12LAD, OHX12LAS, OHX12LAP, OHX12LAA, OHX12PCD, OHX12PCS, OHX12PCP, OHX12PCA);
   %peri_1t(13, OHX13LAD, OHX13LAS, OHX13LAP, OHX13LAA, OHX13PCD, OHX13PCS, OHX13PCP, OHX13PCA);
   %peri_1t(14, OHX14LAD, OHX14LAS, OHX14LAP, OHX14LAA, OHX14PCD, OHX14PCS, OHX14PCP, OHX14PCA);
   %peri_1t(15, OHX15LAD, OHX15LAS, OHX15LAP, OHX15LAA, OHX15PCD, OHX15PCS, OHX15PCP, OHX15PCA);

   %peri_1t(18, OHX18LAD, OHX18LAS, OHX18LAP, OHX18LAA, OHX18PCD, OHX18PCS, OHX18PCP, OHX18PCA);
   %peri_1t(19, OHX19LAD, OHX19LAS, OHX19LAP, OHX19LAA, OHX19PCD, OHX19PCS, OHX19PCP, OHX19PCA);
   %peri_1t(20, OHX20LAD, OHX20LAS, OHX20LAP, OHX20LAA, OHX20PCD, OHX20PCS, OHX20PCP, OHX20PCA);
   %peri_1t(21, OHX21LAD, OHX21LAS, OHX21LAP, OHX21LAA, OHX21PCD, OHX21PCS, OHX21PCP, OHX21PCA);
   %peri_1t(22, OHX22LAD, OHX22LAS, OHX22LAP, OHX22LAA, OHX22PCD, OHX22PCS, OHX22PCP, OHX22PCA);
   %peri_1t(23, OHX23LAD, OHX23LAS, OHX23LAP, OHX23LAA, OHX23PCD, OHX23PCS, OHX23PCP, OHX23PCA);
   %peri_1t(24, OHX24LAD, OHX24LAS, OHX24LAP, OHX24LAA, OHX24PCD, OHX24PCS, OHX24PCP, OHX24PCA);
   %peri_1t(25, OHX25LAD, OHX25LAS, OHX25LAP, OHX25LAA, OHX25PCD, OHX25PCS, OHX25PCP, OHX25PCA);
   %peri_1t(26, OHX26LAD, OHX26LAS, OHX26LAP, OHX26LAA, OHX26PCD, OHX26PCS, OHX26PCP, OHX26PCA);
   %peri_1t(27, OHX27LAD, OHX27LAS, OHX27LAP, OHX27LAA, OHX27PCD, OHX27PCS, OHX27PCP, OHX27PCA);
   %peri_1t(28, OHX28LAD, OHX28LAS, OHX28LAP, OHX28LAA, OHX28PCD, OHX28PCS, OHX28PCP, OHX28PCA);
   %peri_1t(29, OHX29LAD, OHX29LAS, OHX29LAP, OHX29LAA, OHX29PCD, OHX29PCS, OHX29PCP, OHX29PCA);
   %peri_1t(30, OHX30LAD, OHX30LAS, OHX30LAP, OHX30LAA, OHX30PCD, OHX30PCS, OHX30PCP, OHX30PCA);
   %peri_1t(31, OHX31LAD, OHX31LAS, OHX31LAP, OHX31LAA, OHX31PCD, OHX31PCS, OHX31PCP, OHX31PCA);

    /* Summing across all teeth to check if at least two teeth meet the periodontitis criteria 
	
	We decided to use sum for this instead of +
	*/
/** use "sum", any var with missing will still get a value 
Not correct. 
   */
/** count missing for the peri status of each tooth*/

%miss_ct(peri_t02);
%miss_ct(peri_t03);
%miss_ct(peri_t04);
%miss_ct(peri_t05);
%miss_ct(peri_t06);
%miss_ct(peri_t07);
%miss_ct(peri_t08);
%miss_ct(peri_t09);
%miss_ct(peri_t10);
%miss_ct(peri_t11);
%miss_ct(peri_t12);
%miss_ct(peri_t13);
%miss_ct(peri_t14);
%miss_ct(peri_t15);

%miss_ct(peri_t18);
%miss_ct(peri_t19);
%miss_ct(peri_t20);
%miss_ct(peri_t21);
%miss_ct(peri_t22);
%miss_ct(peri_t23);
%miss_ct(peri_t24);
%miss_ct(peri_t25);
%miss_ct(peri_t26);
%miss_ct(peri_t27);
%miss_ct(peri_t28);
%miss_ct(peri_t29);
%miss_ct(peri_t30);
%miss_ct(peri_t31);


/**** LinHY, check for first 5 teeth (check code accuracy) ***/;
t5_all= peri_t02+ peri_t03+ peri_t04+ peri_t05+  peri_t06;
t5_any=sum(peri_t02, peri_t03, peri_t04, peri_t05,peri_t06);

t5_mis= peri_t02_mis+ peri_t03_mis+ peri_t04_mis+ peri_t05_mis + peri_t06_mis;

if t5_any>=2 then peri_try=1;
else if t5_all=0 or (t5_any=0 and  t5_mis=1) then peri_try=0;
else peri_try=.;

/*** define peri status for all 28 teeth ***/;
peri_total_all = 
    peri_t02 + peri_t03 + peri_t04 + peri_t05 + 
    peri_t06 + peri_t07 + peri_t08 + peri_t09 + 
    peri_t10 + peri_t11 + peri_t12 + peri_t13 + 
    peri_t14 + peri_t15 + peri_t18 + peri_t19 + 
    peri_t20 + peri_t21 + peri_t22 + peri_t23 + 
    peri_t24 + peri_t25 + peri_t26 + peri_t27 + 
    peri_t28 + peri_t29 + peri_t30 + peri_t31;

peri_total_any = 
    sum(peri_t02, peri_t03, peri_t04, peri_t05, 
    peri_t06, peri_t07, peri_t08, peri_t09, 
    peri_t10, peri_t11, peri_t12, peri_t13, 
    peri_t14, peri_t15, peri_t18, peri_t19, 
    peri_t20, peri_t21, peri_t22, peri_t23, 
    peri_t24, peri_t25, peri_t26, peri_t27, 
    peri_t28, peri_t29, peri_t30, peri_t31);


peri_total_mis = 
    peri_t02_mis + peri_t03_mis + peri_t04_mis + peri_t05_mis + 
    peri_t06_mis + peri_t07_mis + peri_t08_mis + peri_t09_mis + 
    peri_t10_mis + peri_t11_mis + peri_t12_mis + peri_t13_mis + 
    peri_t14_mis + peri_t15_mis + peri_t18_mis + peri_t19_mis + 
    peri_t20_mis + peri_t21_mis + peri_t22_mis + peri_t23_mis + 
    peri_t24_mis + peri_t25_mis + peri_t26_mis + peri_t27_mis + 
    peri_t28_mis + peri_t29_mis + peri_t30_mis + peri_t31_mis;


/*
# Step 1 (peri for a tootoh):
A tooth that follows both of the following 2 criteria will be considered a PERIODONTITIS symptom for this tooth.     
   (1)At least 1 out of the 4 surfaces (DF, MF, DL, and ML) with attachment loss >= 1 mm
       AND 
   (2) At least 1 out of the 4 surfaces (DF, MF, DL, and ML) with PD >= 4 mm

# Step 2 
At least 2 teeth with peri -> peri 
*/
/*** define peri for all 28 teeth */
if peri_total_any>=2 then peri_g2=1;
else if peri_total_all=1 or peri_total_all=0 or (peri_total_any=0 and peri_total_mis=1) then peri_g2=0;
else peri_g2=.;

/****************
define new peri-stage (3/30/2025)
***************/;
    /* calculate the max LOA for each tooth  */

/* for 28 teeth (2-15, 18-31)*/
   max_LOA_02=max(LOA_DF_02, LOA_MF_02, LOA_DL_02, LOA_ML_02);
   max_LOA_03=max(LOA_DF_03, LOA_MF_03, LOA_DL_03, LOA_ML_03);
   max_LOA_04=max(LOA_DF_04, LOA_MF_04, LOA_DL_04, LOA_ML_04);
   max_LOA_05=max(LOA_DF_05, LOA_MF_05, LOA_DL_05, LOA_ML_05);
   max_LOA_06=max(LOA_DF_06, LOA_MF_06, LOA_DL_06, LOA_ML_06);
   max_LOA_07=max(LOA_DF_07, LOA_MF_07, LOA_DL_07, LOA_ML_07);
   max_LOA_08=max(LOA_DF_08, LOA_MF_08, LOA_DL_08, LOA_ML_08);
   max_LOA_09=max(LOA_DF_09, LOA_MF_09, LOA_DL_09, LOA_ML_09);
   max_LOA_10=max(LOA_DF_10, LOA_MF_10, LOA_DL_10, LOA_ML_10);
   max_LOA_11=max(LOA_DF_11, LOA_MF_11, LOA_DL_11, LOA_ML_11);
   max_LOA_12=max(LOA_DF_12, LOA_MF_12, LOA_DL_12, LOA_ML_12);
   max_LOA_13=max(LOA_DF_13, LOA_MF_13, LOA_DL_13, LOA_ML_13);
   max_LOA_14=max(LOA_DF_14, LOA_MF_14, LOA_DL_14, LOA_ML_14);
   max_LOA_15=max(LOA_DF_15, LOA_MF_15, LOA_DL_15, LOA_ML_15);

   max_LOA_18=max(LOA_DF_18, LOA_MF_18, LOA_DL_18, LOA_ML_18);
   max_LOA_19=max(LOA_DF_19, LOA_MF_19, LOA_DL_19, LOA_ML_19);
   max_LOA_20=max(LOA_DF_20, LOA_MF_20, LOA_DL_20, LOA_ML_20);
   max_LOA_21=max(LOA_DF_21, LOA_MF_21, LOA_DL_21, LOA_ML_21);
   max_LOA_22=max(LOA_DF_22, LOA_MF_22, LOA_DL_22, LOA_ML_22);
   max_LOA_23=max(LOA_DF_23, LOA_MF_23, LOA_DL_23, LOA_ML_23);
   max_LOA_24=max(LOA_DF_24, LOA_MF_24, LOA_DL_24, LOA_ML_24);
   max_LOA_25=max(LOA_DF_25, LOA_MF_25, LOA_DL_25, LOA_ML_25);
   max_LOA_26=max(LOA_DF_26, LOA_MF_26, LOA_DL_26, LOA_ML_26);
   max_LOA_27=max(LOA_DF_27, LOA_MF_27, LOA_DL_27, LOA_ML_27);
   max_LOA_28=max(LOA_DF_28, LOA_MF_28, LOA_DL_28, LOA_ML_28);
   max_LOA_29=max(LOA_DF_29, LOA_MF_29, LOA_DL_29, LOA_ML_29);
   max_LOA_30=max(LOA_DF_30, LOA_MF_30, LOA_DL_30, LOA_ML_30);
   max_LOA_31=max(LOA_DF_31, LOA_MF_31, LOA_DL_31, LOA_ML_31);



    /*  max LOA per person */
   max_LOA_total=max(max_LOA_02, max_LOA_03, max_LOA_04, max_LOA_05, max_LOA_06, max_LOA_07, max_LOA_08, max_LOA_09, max_LOA_10,
      max_LOA_11, max_LOA_12, max_LOA_13, max_LOA_14, max_LOA_15, 
	  max_LOA_18, max_LOA_19, max_LOA_20, max_LOA_21, max_LOA_22, max_LOA_23, max_LOA_24, max_LOA_25, max_LOA_26,
	  max_LOA_27, max_LOA_28, max_LOA_29, max_LOA_30, max_LOA_31);


  if max_LOA_total=. then max_LOA_total_g3=.;
  else if max_LOA_total=1 or max_LOA_total=2 then max_LOA_total_g3=1;
  else if max_LOA_total=3 or max_LOA_total=4 then max_LOA_total_g3=2;
  else if max_LOA_total>=5 then max_LOA_total_g3=3;


 /* define peri-stage 
no missing for t_ls20 and max_LOA_total_g3 for 648 peri patients
  */

 if peri_g2 = .  or peri_g2=0 then peri_stage_N=.;
 else if peri_g2=1 then do;
	if t_ls20=. and  max_LOA_total_g3=. then peri_stage_N=.;
	else if max_LOA_total_g3=1 then peri_stage_N=1;
	else if max_LOA_total_g3=2 then peri_stage_N=2;
	else if max_LOA_total_g3=3 then do; 
       if t_ls20=0 then peri_stage_N=3;
	   else if t_ls20=1 then peri_stage_N=4;
    end;
end; 


    /* LinHY, define peri stage */
/*
	Stage 1: attachment loss of 1-2 mm (even 1 surface/ tooth counts but only surfaces of interest are DF, MF, DL and ML))
Stage 2: attachment loss of 3-4 mm (even 1 surface/ tooth counts but only surfaces of interest are DF, MF, DL and ML))
Stage 3: attachment loss of 5 or >5 mm (even 1 surface/ tooth counts but only surfaces of interest are DF, MF, DL and ML))
Stage 4: attachment loss with less than 20 remaining teeth (missing eleven teeth or more)

Ask? Stage 4:attachment loss of 5 or >5 mm?
	*/

/******************** 
 taste variables 
   *****************/

    /* Disability variables for salty taste */
    if CSXNAPT = . then disab_salty_tp = .; 
    else if CSXNAPT = 1 then disab_salty_tp = 0; 
    else if CSXNAPT in (2, 3, 4, 5) then disab_salty_tp = 1; 

	if CSXSLTST = . then disab_salty_wm = .; 
	else if CSXSLTST = 1 then disab_salty_wm= 0; 
    else if CSXSLTST in (2, 3, 4, 5) then disab_salty_wm = 1; 

    /* Disability variables for bitter taste */
	if CSXQUIPT = . then disab_bit_tp  = .;
    else if CSXQUIPT = 2 then disab_bit_tp  = 0;
    else if CSXQUIPT in (1, 3, 4, 5) then disab_bit_tp = 1;

    if CSXQUIST = . then disab_bit_wm = .;
    else if CSXQUIST = 2 then disab_bit_wm = 0;
    else if CSXQUIST in (1, 3, 4, 5) then disab_bit_wm= 1;


 /* Disability variables in general */

	if disab_salty_wm=. or disab_salty_tp=. then disab_salty_all=.;
	else if disab_salty_wm=1 or disab_salty_tp=1 then disab_salty_all=1;
	else disab_salty_all=0;

	if disab_bit_wm=. or disab_bit_tp=. then disab_bit_all=.;
	else if disab_bit_wm=1 or disab_bit_tp=1 then disab_bit_all=1;
	else disab_bit_all=0;

label 
	peri_total_all='teeth count of peri for all 28 teeth, missing: any missing' 
	peri_total_any='teeth count of peri for all 28 teeth, missing: ALL missing' 
	peri_total_mis='count for teeth with missing peri'  
	peri_g2='periodontitis based on available teeth (max 28), 1:yes, 0:no'
	peri_stage_N='periodontitis stage, 1-4'
	
OHDPDSTS='Overall Oral Health Exam Status,1:Complete, 2:Partial, 3:Not Done'
OHDDESTS='Dentition Status, 1:Complete, 2:Partial, 3:Not Done'

peri_test='peri test, 1: yes (Complete/partial), 0:no'
denti='Dentition Status, 1: yes (Complete/partial), 0:no'
OHX02TC='Tooth Count: #2, 1:Primary tooth present, 2:Permanent tooth present, 3:Dental implant, 
           4: Tooth not present, 5: Permanent dental root fragment present, 9:Could not assess'



CSXNAPT='taste, Tongue Tip, 1M NaCl, 1:Salty, 2:Bitter, 3: Something else, 4: No Taste, 5:Sour'
CSXSLTST='taste, Whole Mouth, 1 M NaCl,1:Salty, 2:Bitter, 3: Something else, 4: No Taste, 5:Sour'
CSXQUIPT='taste, Tongue Tip, 1mM Quinine, 1:Salty, 2:Bitter, 3: Something else, 4: No Taste, 5:Sour'
CSXQUIST='taste, Whole Mouth, 1mM Quinine, 1:Salty, 2:Bitter, 3: Something else, 4: No Taste, 5:Sour'

miss_teeth_ct='missing teeth count'
remaining_teeth='remaining teeth count based on 32 teeth'
remaining_teeth_p28='remaining teeth count based on 28 teeth'
t_ls20='<20 teeth based on 32 teeth'

disab_salty_tp='disability salty taste, Tongue Tip 1M NaCl, 1: yes, 0:no'
disab_salty_wm='disability salty taste, Whole Mouth 1M NaCl, 1: yes, 0:no'
disab_salty_all='disability salty taste, Tongue Tip or whole mouth, 1: yes, 0:no'

disab_bit_tp='disability bitter taste, Tongue 1mM Quinine, 1: yes, 0:no'
disab_bit_wm='disability bitter taste, Whole Mouth 1mM Quinine, 1: yes, 0:no'
disab_bit_all='disability bitter taste, Tongue Tip or whole mouth, 1: yes, 0:no'


  max_LOA_02='tooth_02, max attachment loss of 4 surfaces (DF, MF, DL and ML)'
  max_LOA_03='tooth_03, max attachment loss of 4 surfaces (DF, MF, DL and ML)'
  max_LOA_total='max attachment loss of 4 surfaces among the 28 teeth'
  max_LOA_total_g3='max attachment loss of 4 surfaces among the 28 teeth, 1: 1-2, 2: 3-4, 3:>=5 mm'
;

run;
/*
There are only 1 person in peri-stage 1. 
However, this person did not have taste variables, so was excluced from the analytical dataset. 
*/

/*============================================*/
/* SECTION 3: ELIGIBILITY CRITERIA & PERMANENT DATASET permdata.peri_taste_n2155_250414 */
/*============================================*/

/**** 
 1/2/2025
 Eligilbe study population 

 drop n=300 (298 with 0 teeth and 2 with 1 tooth based on the 28 teeth of peri check) 
 
 n=2155 with valid data in peri status and taste results 
 ********/;


******* USE THIS ONE FOR UNWEIGHTED WHERE WE HAVE SUBSET OF ELIGIBLE PEOPLE************;
/*
data pt;
 set peri_all;
  
 if age>=40;

 if disab_salty_all=. and disab_bit_all=. then delete;

 if peri_g2=. then delete;
 if remaining_teeth_p28>=2 ;
run;
*/

 
/*============================================*/
/* SECTION 5 : MEDICATIONS */
/*============================================*/

/* Create a medication flag per drug record 
data meds_flag;
    set permdata.rxq_rx_h;
 

	label ;
run;*/
/*
proc sql;
    create table meds_summary as
    select SEQN,
           max(medflag) as med_yn
    from meds_flag
    group by SEQN;
quit;
*/;

 /*
5/16/2025, LinHY, 
both files only have 1 row per person, so no need to collapse
 
permdata.rxq_rx_h, n=10175 
 meds_summary: n=10175
 ***/;
 /*
proc freq data=meds_flag;
 table medflag;
 run;
proc freq data=meds_summary;
 table med_yn;
 run;
proc sort data=meds_summary;
 by seqn;
 run;

 data chk;
  *set meds_summary;
  set meds_flag;
 by seqn;
 if first.seqn;
 run;

proc contents data=meds_summary;
run;
 */;

/*
data pt_2;
    merge pt_2(in=a) meds_summary(in=b);
    by SEQN;
    if a; 
run;
***/;
******* USE THIS ONE FOR WEIGHTED WHERE WE HAVE ALL PEOPLE WITH ELIG = 1 OR 0 ************;

data pt;
    set peri_all;

    if age >= 40 and 
       (disab_salty_all ne . or disab_bit_all ne .) and 
       peri_g2 ne . and 
       remaining_teeth_p28 >= 2 then elig = 1;
    else elig = 0;
run;

* SORTING *;
proc sort data=pt;
   by SEQN;
   run;

proc sort data=permdata.bmx_h;
   by SEQN;
   run;

proc sort data=permdata.diq_h;
   by SEQN;
   run;
proc sort data=permdata.alq_h;
   by SEQN;
   run;
proc sort data=permdata.smq_h;
   by SEQN;
   run;
   
proc sort data=permdata.csq_h;
 by seqn;
 run;

 proc sort data=permdata.ohq_h;
 by seqn;
 run;
 
 proc sort data=permdata.ohxper_h;
 by seqn;
 run;

  proc sort data=permdata.rxq_rx_h;
 by seqn;
 run;

 proc sort data=permdata.rxq_rx_h;
 by seqn;
 run;
 

/** Merge all required datasets **/;
data pt_2a;
    merge pt(in=a) permdata.bmx_h(in=b) permdata.alq_h(in=c) permdata.diq_h(in=d) permdata.smq_h(in=e)
            permdata.csq_h   permdata.ohq_h permdata.rxq_rx_h;
            * permdata.rxq_rx_h ;
    by SEQN;
    if a; /* Keep only those in pt */
run;


proc freq data=pt_2a;
 table peri_g2* peri_stage_n/missing;
 run;

/***
 <previous>
*data permdata.peri_taste_n2155_250414;
*permdata.peri_taste_n10175_250427;


 <New, n=10175, the whole dataset, add meds_flag>
 data permdata.peri_taste_n10175_250516;
 set pt_2a;
 run;

<use>
data pt_2a;
 set permdata.peri_taste_n10175_250516;
run;
*******/;


/*============================================*/
/* SECTION 4 : pt_2 Recoding & labeling peri_all with new coding methods */
/*============================================*/
/* Creating recoded dataset with new variables for demographic covariates */

	/* LinHY edited 5/1/2025 - Mansi reviewed - OK 5/6/2025 */
 data pt_2a_n;
  set pt_2a;
   rename  OHX02CTC= OHX2CTC OHX03CTC= OHX3CTC OHX04CTC= OHX4CTC OHX05CTC= OHX5CTC
       OHX06CTC= OHX6CTC OHX07CTC= OHX7CTC OHX08CTC= OHX8CTC  OHX09CTC= OHX9CTC
	   ;
	   run;



data pt_2;
 *   set permdata.peri_taste_n2155_250414;
	set pt_2a_n;

	*set permdata.peri_taste_n10175_250427;
    /* Recoding gender */
    if RIAGENDR = . then female = .;
    else if RIAGENDR = 2 then female = 1;
    else female = 0;

    /* Recoding education */
    if DMDEDUC2 in (., 7, 9) then edu = .;
    else if DMDEDUC2 = 1 then edu = 1;
    else if DMDEDUC2 in (2, 3) then edu = 2;
    else edu = 3;

    /* Recoding poverty index */
    if INDFMPIR = . then pirg4 = .;
    else if INDFMPIR <= 1 then pirg4 = 1;
    else if 1 < INDFMPIR <= 2 then pirg4 = 2;
    else if 2 < INDFMPIR <= 4 then pirg4 = 3;
    else pirg4 = 4;

    /* Recoding race */
    if RIDRETH1 = . then race = .;
    else if RIDRETH1 = 3 then race = 1;
    else if RIDRETH1 = 4 then race = 2;
    else if RIDRETH1 in (1, 2) then race = 3;
    else race = 4;

    /* Reducing race to 3 groups */
    if race = . then race3 = .;
    else if race in (3, 4) then race3 = 3;
    else race3 = race;
	
    /* Obesity: numeric recode in original variable name */
    if BMXBMI = . then BMI_category = .;
    else if BMXBMI <= 24.9 then BMI_category = 1;
    else if BMXBMI <= 29.9 then BMI_category = 2;
    else if BMXBMI >= 30 then BMI_category = 3;

    /* Diabetes */
    if DIQ010 = . then Diabetes_status = .;
    else if DIQ010 = 1 then Diabetes_status = 1; 
    else if DIQ010 = 2 or DIQ010 = 3 then Diabetes_status = 0;

    /* Smoking taken from LinHY code antiox */
 if smq020=7 or smq020=9 or smq020=. then Ever_Smoker=.;
 else if smq020=2 then Ever_Smoker=0;
 else Ever_Smoker=1;

 if smq040=7 or smq040=9 or smq040=. then Now_Smoker=.;
 else if smq040=3 then Now_Smoker=0;
 else Now_Smoker=1;

 if Ever_Smoker=0 then Smoker=0;
 else if Ever_Smoker=1 and Now_Smoker=0 then Smoker=1;
 else if Ever_Smoker=1 and Now_Smoker=1 then Smoker=2;
 else Smoker=.;

/* 5/6/25 MT make this in two parts. every smoker 1-0(above is correct) current smoker (1-0) and then smoker 1,2,3 - never former current */
/*	if SMQ020 = 2 then Smoker = 1;*/
/*    else if SMQ020 = 1 then  = 2; */
/*    else if SMQ040 in 1 then  = 3; */

    /* Binge Drinking */
	/*
LinHY: use wrong variable, should use (ALQ101, ALQ110 and ALQ160)

	https://www.niaaa.nih.gov/publications/brochures-and-fact-sheets/binge-drinking
The NIAAA defines binge drinking as a pattern of drinking alcohol that brings blood alcohol concentration (BAC) to 0.08%–or 0.08 grams of alcohol per deciliter
	–or higher. 
	For a typical adult, this pattern corresponds to consuming >=5 drinks (male), or >=4 drinks (female), in about two hours

	ALQ101 - Had at least 12 alcohol drinks/1 yr? 1: yes, 2: no, 7/9/. 
	ALQ110	Had at least 12 alcohol drinks/lifetime?
    ALQ160	# days have 4/5 or more drinks in 2 hrs

	***/;

/** 5/13/2025, linhy added */

if ALQ101=. or ALQ101=7 or ALQ101=9 then alq_p1yr=.;
else if ALQ101=1 then alq_p1yr=1;
else alq_p1yr=0;

if ALQ110=. or ALQ110=7 or ALQ110=9 then alq_life=.;
else if ALQ110=1 then alq_life=1;
else alq_life=0;

if ALQ160=. or ALQ160=777 or ALQ160=999 then day_binge_g2=.;
else if alq160=0 then day_binge_g2=0;
else day_binge_g2=1;

if alq_p1yr=. then alq_g3=.;
else if alq_p1yr=1 then alq_g3=3;
else if alq_p1yr=0 then do;
   if alq_life=. then alq_g3=.;
  else if alq_life=0 then alq_g3=1;
  else if alq_life=1 then alq_g3=2;
end;

if alq_g3=. then binge_alq_g3=.;
else if alq_g3=1 then binge_alq_g3=1;
else do; 
  if day_binge_g2=. then binge_alq_g3=.;
  else if day_binge_g2=0 then binge_alq_g3=2;
  else binge_alq_g3=3;
 end;

 /* 
 ALQ141Q='# days have 4/5 drinks - past 12 mos, 777/999/.: mising'
ALQ141U='unit, 4/5 drinks past 12 mos, 1:week, 2:month, 3:year, 7/9/.: missing'
ALQ151='Ever have 4/5 or more drinks every day?, 1:yes, 2:no, 7/9/.: missing'

 if ALQ151 in (7, 9, .) then hvy_alq=.;
 else if ALQ151=1 then hvy_alq=1;
 else if ALQ151=2 then hvy_alq=0;

 Heavy Drinking

 */

 
/* Creating Heavy_Drinking 
 
NIAAA defines heavy drinking as follows:
For men, consuming >=5 drinks on any day or >=15 per week
For women, consuming >=4 on any day or >=8 drinks per week
 */



  if ALQ141Q in (777, 999, .) then ALQ141Q_n=.;
 else ALQ141Q_n= ALQ141Q ;

 if ALQ141U in (7, 9, .) then ALQ141U_n=.;
 else ALQ141U_n= ALQ141U ;

/** not consider never drinker */
 if ALQ141Q_n=.  then hvy_alq_12m=.;
 else if ALQ141Q_n=0  then hvy_alq_12m=0;
 else hvy_alq_12m=1;

 /** consider never drinker */
if alq_g3=. then hvy_alq_g3=.;
else if alq_g3=1 then hvy_alq_g3=1;
else do; 
  if hvy_alq_12m=. then hvy_alq_g3=.;
  else if hvy_alq_12m=0 then hvy_alq_g3=2;
  else hvy_alq_g3=3;
 end;

 /*
 <MT version>
if ALQ141Q in (777, 999, .) or ALQ141U in (7, 9, .) or RIAGENDR in (., 7, 9) then Heavy_Drinking = .;
else do;
    if RIAGENDR = 2 then do; 
        if (ALQ141U = 2 and ALQ141Q >= 8) or (ALQ141U = 1 and ALQ141Q >= 4) then Heavy_Drinking = 1;
        else Heavy_Drinking = 0;
    end;
    else if RIAGENDR = 1 then do; 
        if (ALQ141U = 2 and ALQ141Q >= 15) or (ALQ141U = 1 and ALQ141Q >= 5) then Heavy_Drinking = 1;
        else Heavy_Drinking = 0;
    end;
end;
*/

	/* Creating Binge_Drinking MT cross-check 5/6/25 */
	/* Also make a never, former, current ALQ variable 5/6/25*/
 /*
	if ALQ101 in (7, 9, .) then Binge_Drinking = .;
	else if ALQ101 = 1 and ALQ110 = 1 and ALQ160 >= 1 then Binge_Drinking = 1;
	else if ALQ101 = 1 and ALQ110 = 1 and ALQ160 = 0 then Binge_Drinking = 0;
	else Binge_Drinking = .;
*/;

    /* Marital Status */
    if DMDMARTL = . then Marital_Status = .;
    else if DMDMARTL in (1,6) then Marital_Status = 1; 
    else if DMDMARTL in (2,3,4,5) then Marital_Status = 2; 

    /* Xerostomia */
    if CSQ202 = . or CSQ202 = 9 then Xerostomia = .;
    else if CSQ202 = 1 then Xerostomia = 1;
    else if CSQ202 = 2 then Xerostomia = 0;

	/* LinHY edited 5/1/2025 - Mansi reviewed - OK 5/6/2025 */
	%macro cari_ct;
       
        %do i = 2 %to 15;
		    if OHX&i.CTC = ' ' then C_&i.=. ;
            else if OHX&i.CTC = 'Z' then C_&i.=1 ;
			else C_&i.=0; 
        %end;
        %do i = 18 %to 31;
           if OHX&i.CTC = ' ' then C_&i.=. ;
            else if OHX&i.CTC = 'Z' then C_&i.=1 ;
			else C_&i.=0; 
        %end;
    %mend  cari_ct;

%cari_ct;

c_count= c_2  + c_3 + c_4 + c_5  + c_6 + c_7 + c_8  + c_9 + c_10 + c_11+ c_12   + c_13 + c_14 + c_15 +
         c_18  + c_19 + c_20 + c_21+ c_22   + c_23 + c_24 + c_25 +c_26 + c_27 + c_28  + c_29 + c_30 + c_31 ;


        if C_Count=. then Caries_YN = .;
        else if C_Count >= 1 then Caries_YN = 1;
        else Caries_YN = 0;

	/* LinHY edited 5/1/2025 - Mansi reviewed - OK 5/6/2025 */
    /* --- Missing Teeth Yes/No --- */
   if remaining_teeth_p28=.  then Missing_Teeth_YN = .;
   else if remaining_teeth_p28 < 28 then Missing_Teeth_YN = 1;
   else if remaining_teeth_p28 = 28 then Missing_Teeth_YN = 0;

   rxdrug_upper = upcase(RXDDRUG); /* Convert drug names to uppercase for consistent matching */

/* medicine add a missing category where if they have RXDDRUG=. or the 555 7777 - it is missing 5/6/25*/
    /* Flagging if drug name matches any xerostomia-causing drug */
if rxdrug_upper in (' ', '55555','77777', '99999') then med_yn=.;
else if index(rxdrug_upper, "PSEUDOEPHEDRINE") > 0 or
       index(rxdrug_upper, "DIPHENHYDRAMINE") > 0 or
       index(rxdrug_upper, "AMITRIPTYLINE") > 0 or
       index(rxdrug_upper, "ATROPINE") > 0 or
       index(rxdrug_upper, "HYDROCHLOROTHIAZIDE") > 0 or
       index(rxdrug_upper, "FUROSEMIDE") > 0 or
       index(rxdrug_upper, "METOPROLOL") > 0 or
       index(rxdrug_upper, "AMLODIPINE") > 0 or
       index(rxdrug_upper, "FELODIPINE") > 0 or
       index(rxdrug_upper, "DILTIAZEM") > 0 or
       index(rxdrug_upper, "PROMETHAZINE") > 0 or
       index(rxdrug_upper, "HYDROXYZINE") > 0 or
       index(rxdrug_upper, "HYDRALAZINE") > 0 or
       index(rxdrug_upper, "CHLORPHENIRAMINE") > 0 or
       index(rxdrug_upper, "CITALOPRAM") > 0 or
       index(rxdrug_upper, "DULOXETINE") > 0 or
       index(rxdrug_upper, "FLUOXETINE") > 0 or
       index(rxdrug_upper, "PAROXETINE") > 0 or
       index(rxdrug_upper, "SERTRALINE") > 0 or
       index(rxdrug_upper, "VENLAFAXINE") > 0 or
       index(rxdrug_upper, "GABAPENTIN") > 0 or
       index(rxdrug_upper, "LITHIUM") > 0 or
       index(rxdrug_upper, "ALBUTEROL") > 0 or
       index(rxdrug_upper, "CYCLOBENZAPRINE") > 0 or
       index(rxdrug_upper, "TIZANIDINE") > 0 or
       index(rxdrug_upper, "AMPHETAMINE") > 0 or
       index(rxdrug_upper, "CLONIDINE") > 0 or
       index(rxdrug_upper, "BUPROPION") > 0 or
       index(rxdrug_upper, "OMEPRAZOLE") > 0 or
       index(rxdrug_upper, "TIMOLOL") > 0 or
       index(rxdrug_upper, "BACLOFEN") > 0 or
       index(rxdrug_upper, "ALENDRONATE") > 0 or
       index(rxdrug_upper, "ARIPIPRAZOLE") > 0 or
       index(rxdrug_upper, "ZOLPIDEM") > 0 or
       index(rxdrug_upper, "IMIPRAMINE") > 0 or
       index(rxdrug_upper, "ESCITALOPRAM") > 0 or
       index(rxdrug_upper, "BRIMONIDINE") > 0
    then med_yn = 1;
	else med_yn = 0;





   /* Labeling original variables used in recoding */
    label
        RIAGENDR = "Original Gender Variable (1=Male, 2=Female)"
        DMDEDUC2 = "Education level (Adults 20+), 1: <9th, 2: 9-11th, 3: High school/GED, 4: Some college/AA, 5: College+"
        INDFMPIR = "Family Income to Poverty Ratio"
        RIDRETH1 = "Race/Hispanic Origin, 1:Mexican Am, 2:Other Hisp, 3:White, 4:Black, 5:Other";

    /* Labels for recoded and derived variables, with value explanation */
    label
        female = "Binary gender recode: 1=Female, 0=Male"
        edu = "Education recode: 1=Less than HS, 2=Some HS, 3=HS graduate or more"
        pirg4 = "Poverty index recode: 1=<1.0, 2=1.01-2.0, 3=2.01-4.0, 4=>4.0"
        race = "Race recode: 1=White, 2=Black, 3=Hispanic, 4=Other"
        race3 = "Race recode 3-group: 1=White, 2=Black, 3=Hispanic/Other"
		BMI_category = "BMI Category: 1=<25, 2=25-29.9, 3=30+"
        Diabetes_status = "Diabetes Status: 1=Yes, 0=No/Borderline"
        Ever_Smoker = "Smoking Status Ever: 1=Yes, 0=No"
		Now_Smoker = "Smoking Status Current: 1=Yes, 0=No"
		Smoker = "Smoking Status: 0=Never, 1=Former, 2=Current"
        Marital_Status = "Marital Status: 1=Married/Partnered, 2=Widowed/Divorced/Separated"
        Xerostomia = "Xerostomia: 1=Yes, 0=No"
		C_Count = "Count of Teeth with Caries (Z code in OHX*CTC)"
        Missing_Teeth_YN = "Missing Teeth (Remaining < 28): 1 = Yes, 0 = No"
        Caries_YN = "Dental Caries Presence: 1=Yes, 0=No (from OHX*CTC='Z')"
		DMDMARTL="1 = Married, 2 = Widowed, 3 = Divorced, 4 = Separated, 5 = Never Married, 6 = Living with Partner"
;
/** 5/13/2025, linhy added */
label 
ALQ101='Had at least 12 alcohol drinks/1 yr?, 1:yes, 2: no, 7/9: missing'
ALQ110='Had at least 12 alcohol drinks/lifetime?, 1:yes, 2: no, 7/9: missing'
ALQ160='# days have 4/5 or more drinks in 2 hrs past 30 days, 0-30, 777/999:missing'
ALQ141Q='# days have 4/5 drinks - past 12 mos, 777/999/.: mising'
ALQ141U='unit, 4/5 drinks past 12 mos, 1:week, 2:month, 3:year, 7/9/.: missing'
CSQ202='Had persistent dry mouth in past 12 mth, 1:yes, 2: no, 7/9: missing'

alq_p1yr='Had at least 12 alcohol drinks/1 yr?, 1:yes, 0: no'
alq_life='Had at least 12 alcohol drinks/lifetime?, 1:yes, 0: no'
day_binge_g2='# days have 4/5 or more drinks in 2 hrs past 30 days, 0: 0, 1:>=1'
alq_g3='alcohol intake, 1: never, 2: former, 3: current drinker'
binge_alq_g3='alcohol binge, 1: never drinker, 2: non-binge, 3: binge'
hvy_alq_12m='Ever have >=4/5 drinks past 12 mos, 1:yes, 0:no'
hvy_alq_g3='heavy drink, >=4/5 drinks past 12 mos, 1: never drinker, 2: non-heavy, 3: heavy'
med_yn='xerostomia-causing drug, 1: yes, 0:no'
;
run;
/*

*/; 
proc freq data=pt_2;
*tables Binge_Drinking;
*table alq101 alq_p1yr alq110 alq_life alq160;
*table alq160 day_binge_g2;
*table alq_p1yr *alq_life alq_g3/missing;
*table alq_g3* day_binge_g2 binge_alq_g3 Binge_Drinking/missing;
*table DIQ010 Diabetes_status;
*table smq020 Ever_Smoker smq040 Now_Smoker;
* table Ever_Smoker* now_smoker Smoker/missing ;
 * table ALQ141Q ALQ141Q_n  ALQ141U ALQ141U_n ;
  *table ALQ141Q_n hvy_alq_12m;
  *table (hvy_alq_12m hvy_alq_g3 binge_alq_g3)* alq_g3/missing;
  *table hvy_alq_g3;
  *table CSQ202 Xerostomia ;
  table med_yn;
run;

/* proc freq data=permdata.peri_taste_n10175_250516; */
/*  table alq141q; */
/*  run; */
/*
           alcohol binge, 1: never drinker, 2: non-binge, 3: binge

                                                        Cumulative    Cumulative
               binge_alq_g3    Frequency     Percent     Frequency      Percent
               ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                          .        7373       72.46          7373        72.46
                          1         938        9.22          8311        81.68
                          2        1453       14.28          9764        95.96
                          3         411        4.04         10175       100.00
***/;

/********
LInHY, 5/1/2025 check 
All major variables are consistent with prvious version. 


                  periodontitis based on available teeth (max 28), 1:yes, 0:no

                                                      Cumulative    Cumulative
                  peri_g2    Frequency     Percent     Frequency      Percent
                  ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                        0        1507       69.93          1507        69.93
                        1         648       30.07          2155       100.00


                                    periodontitis stage, 1-4

                                                        Cumulative    Cumulative
               peri_stage_N    Frequency     Percent     Frequency      Percent
               ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                          2         122       18.83           122        18.83
                          3         345       53.24           467        72.07
                          4         181       27.93           648       100.00

                                    Frequency Missing = 1507

*********/;
proc freq data=pt_2;
 where elig=1;
  table peri_g2 peri_stage_N;
 table disab_salty_tp disab_salty_wm  disab_salty_all  disab_bit_tp disab_bit_wm disab_bit_all;
  run;


/* Task 3: Checking accuracy of recoded variables */

proc freq data=pt_2;
    tables female edu pirg4 race race3 / missing;
run;


proc freq data=pt_2;
    tables 
        BMI_category 
        Diabetes_status 
        Ever_Smoker 
        binge_alq_g3 
		alq_g3
        Marital_Status 
        Xerostomia 
        Missing_Teeth_YN 
        Caries_YN / missing list;
run;

/****
5/13/2025
ALQ101 = 1 and ALQ110 = 1 and ALQ160 >= 1 then binge_alq_g3
*****/;
proc freq data=pt_2;
 table ALQ101 *ALQ110 ALQ160/missing;
 run;

/* Gender: RIAGENDR vs. female */
proc freq data=pt_2;
    tables RIAGENDR*female / missing list;
    title 'Check Gender Recode: RIAGENDR vs. female 1=Female, 0=Male';
run;

/* Education: DMDEDUC2 vs. edu */
proc freq data=pt_2;
    tables DMDEDUC2*edu / missing list;
    title 'Check Education Recode: DMDEDUC2 vs. edu 1=Less than HS, 2=Some HS, 3=HS graduate or more';
run;

/* Poverty index: INDFMPIR vs. pirg4 */
proc freq data=pt_2;
    tables pirg4 / missing;
    title 'Check Poverty Grouping: pirg4 1=<1.0, 2=1.01-2.0, 3=2.01-4.0, 4=>4.0';
run;

/* Race: RIDRETH1 -> race and race3 */
proc freq data=pt_2;
    tables RIDRETH1*race3 / missing list;
    title 'Check Race Recode: RIDRETH1 vs. race3 3-group: 1=White, 2=Black, 3=Hispanic/Other';
run;

proc freq data=pt_2;
    tables med_yn / missing;
    title "Frequency of Xerostomia-causing Drug Use (med_yn)";
run;

proc freq data=pt_2;
    tables elig * med_yn / missing;
    title "Frequency of Xerostomia-causing Drug Use by Eligibility";
run;

/* New permanent dataset with all ineligible people also */
data permdata.peri_taste_n10175_250427;
	set pt_2;
	run;
	
/*============================================*/
/* SECTION 6 : WEIGHTING */
/*============================================*/

proc freq data=pt_2;
	tables elig;
run;

* The above works as elig (1) = 2155*;

/* Table 1 */
************************* ONLY ELIG STATS - NO OUTCOMES ***************************;
/* PROC SURVEYMEANS for continuous variables */
proc surveymeans data=pt_2 mean stderr clm;
    strata sdmvstra;
    cluster sdmvpsu;
    weight wtmec2yr;
    domain elig;
    var age; /* Add other continuous variables if needed later */
    title "Weighted Descriptive Statistics for Continuous Variables among Eligible Participants";
run;
proc freq data=pt_2;
 table elig;
 run;
/* PROC SURVEYFREQ for categorical variables */

/* Macro to automate surveyfreq for categorical variables */
%macro sfreq(var);
    proc surveyfreq data=pt_2;
        strata sdmvstra;
        cluster sdmvpsu;
        weight wtmec2yr;
        tables elig * &var. / row chisq;
        where elig = 1;
        title "Weighted Frequency of &var among Eligible Participants";
    run;
%mend sfreq;

/* Call macro separately for each categorical variable */
%sfreq(peri_g2);
%sfreq(female);
%sfreq(edu);
%sfreq(pirg4);
%sfreq(race);
%sfreq(race3);
%sfreq(BMI_category);
%sfreq(Diabetes_status);
%sfreq(Ever_Smoker);
%sfreq(Now_Smoker);
%sfreq(Smoker);
%sfreq(binge_alq_g3);
%sfreq(med_yn);
%sfreq(hvy_alq_g3);
%sfreq(Marital_Status);
%sfreq(Xerostomia);
%sfreq(Caries_YN);
%sfreq(Missing_Teeth_YN);

************************* ELIG STATS - WITH OUTCOMES ***************************;

/* Weighted Descriptive Statistics by Salty and Bitter Outcomes (using pt_2) */

proc freq data=pt_2;
where elig = 1;
 table disab_salty_all disab_bit_all;
 run;

/* PROC SURVEYMEANS for Continuous Variable (Age) by Salty Outcome */

%macro smean_salty(var);
proc surveymeans data=pt_2 mean stderr clm;
    strata sdmvstra;
    cluster sdmvpsu;
    weight wtmec2yr;
    domain elig*disab_salty_all;
    where elig = 1;
    var &var.;
    title "Weighted Means of &var by Salty Taste Disability (Eligible Participants)";
run;

proc surveyreg data=pt_2;
   strata sdmvstra;
   cluster sdmvpsu;
   weight wtmec2yr;
   where elig=1;
   model &var. = disab_salty_all;
run;
%mend(smean_salty);

%smean_salty(age);
%smean_salty(c_count);

/* PROC SURVEYMEANS for Continuous Variable (Age) by Bitter Outcome */

%macro smean_bitter(var);
proc surveymeans data=pt_2 mean stderr clm;
    strata sdmvstra;
    cluster sdmvpsu;
    weight wtmec2yr;
    domain elig*disab_bit_all;
    where elig = 1;
    var &var.;
    title "Weighted Means of &var by Bitter Taste Disability (Eligible Participants)";
run;

proc surveyreg data=pt_2;
   strata sdmvstra;
   cluster sdmvpsu;
   weight wtmec2yr;
   where elig=1;
   model &var. = disab_bit_all;
run;
%mend(smean_bitter);

%smean_bitter(age);
%smean_bitter(c_count);

/* Macros for Categorical Variables */

/* Macro for Categorical Variables by Salty Outcome */
%macro sfreq_salty(var);
    proc surveyfreq data=pt_2;
        strata sdmvstra;
        cluster sdmvpsu;
        weight wtmec2yr;
        tables elig * disab_salty_all * &var. /  col chisq;
        where elig = 1;
        title "Weighted Frequency of &var by Salty Taste Disability (Eligible Participants)";
    run;
%mend sfreq_salty;

/* Macro for Categorical Variables by Bitter Outcome */
%macro sfreq_bitter(var);
    proc surveyfreq data=pt_2;
        strata sdmvstra;
        cluster sdmvpsu;
        weight wtmec2yr;
        tables elig * disab_bit_all * &var. /  col chisq;
        where elig = 1;
        title "Weighted Frequency of &var by Bitter Taste Disability (Eligible Participants)";
    run;
%mend sfreq_bitter;

/* Running All Categorical Variables */

/* Run for Salty Outcome */
%sfreq_salty(peri_g2);
%sfreq_salty(female);
%sfreq_salty(edu);
%sfreq_salty(pirg4);
%sfreq_salty(race);
%sfreq_salty(race3);
%sfreq_salty(BMI_category);
%sfreq_salty(Diabetes_status);
%sfreq_salty(Ever_Smoker);
%sfreq_salty(Now_Smoker);
%sfreq_salty(Smoker);
%sfreq_salty(binge_alq_g3);
%sfreq_salty(hvy_alq_g3)
%sfreq_salty(med_yn);
%sfreq_salty(Marital_Status);
%sfreq_salty(Xerostomia);
%sfreq_salty(Caries_YN);
%sfreq_salty(Missing_Teeth_YN);

/* Run for Bitter Outcome */
%sfreq_bitter(peri_g2);
%sfreq_bitter(female);
%sfreq_bitter(edu);
%sfreq_bitter(pirg4);
%sfreq_bitter(race);
%sfreq_bitter(race3);
%sfreq_bitter(BMI_category);
%sfreq_bitter(Diabetes_status);
%sfreq_bitter(Ever_Smoker);
%sfreq_bitter(Now_Smoker);
%sfreq_bitter(Smoker);
%sfreq_bitter(binge_alq_g3);
%sfreq_bitter(hvy_alq_g3)
%sfreq_bitter(med_yn);
%sfreq_bitter(Marital_Status);
%sfreq_bitter(Xerostomia);
%sfreq_bitter(Caries_YN);
%sfreq_bitter(Missing_Teeth_YN);

proc surveylogistic data=pt_2;
    strata sdmvstra;
    cluster sdmvpsu;
    weight wtmec2yr;
    domain elig;
    class female(ref='0') edu(ref='1') pirg4(ref='1') race(ref='1') race3(ref='1')
          BMI_category(ref='1') Diabetes_status(ref='0') Smoker(ref='0') 
          binge_alq_g3(ref='1') hvy_alq_g3(ref='1') Marital_Status(ref='1') Xerostomia(ref='0')
          Caries_YN(ref='0') Missing_Teeth_YN(ref='0') med_yn(ref='0') / param=ref;
    model disab_salty_all(event='1') = 
          age 
          female edu pirg4 race race3 BMI_category Diabetes_status 
          Ever_Smoker binge_alq_g3 hvy_alq_g3 Marital_Status Xerostomia 
          Caries_YN Missing_Teeth_YN med_yn/ link=logit df=infinity;;
    title "Survey Logistic Regression: Salty Taste Disability (Eligible Participants)";
run;

proc surveylogistic data=pt_2;
    strata sdmvstra;
    cluster sdmvpsu;
    weight wtmec2yr;
    domain elig;
    class female(ref='0') edu(ref='1') pirg4(ref='1') race(ref='1') race3(ref='1')
          BMI_category(ref='1') Diabetes_status(ref='0') Smoker(ref='0') 
          binge_alq_g3(ref='1') hvy_alq_g3(ref='1') Marital_Status(ref='1') Xerostomia(ref='0')
          Caries_YN(ref='0') Missing_Teeth_YN(ref='0') med_yn(ref='0') / param=ref;
    model disab_bit_all(event='1') = 
          age 
          female edu pirg4 race race3 BMI_category Diabetes_status 
          Ever_Smoker binge_alq_g3 hvy_alq_g3 Marital_Status Xerostomia 
          Caries_YN Missing_Teeth_YN med_yn/ link=logit df=infinity;;
    title "Survey Logistic Regression: Bitter Taste Disability (Eligible Participants)";
run;


/*============================================*/
/* SECTION 7 : LOGISTIC MODELS */
/*============================================*/

/* 06/11 NOTES: p(<0.1)surveylogistic multivariate model for salty and bitter only including the significant predictors*/
/* The below models don't show significant findings */
data logit_data;
    set PT_2;
    IF ELIG =1;
    /* Creating the 4 vs 2-3 periodontitis stage variable */
    if peri_stage_N in (2,3) then peri_stage_4vs23 = 0;
    else if peri_stage_N = 4 then peri_stage_4vs23 = 1;
    else peri_stage_4vs23 = .;
run;

proc freq data=logit_data;
 tables peri_g2 elig;
run;

proc contents data=logit_data;

/* Common CLASS statement for all models */
%let classvars = peri_g2 peri_stage_4vs23(ref='0') 
                 race3(ref='1') female(ref='0') binge_alq_g3(ref='1') Smoker(ref='0');

/* SET 1 - Salty disability ~ peri_g2 */
%macro univariate_logit(var=, ref=);

    %if %length(&ref) > 0 %then %do;
        proc surveylogistic data=logit_data;
            class &var(ref="&ref") / param=ref;
            model disab_salty_all(event='1') = &var;
            weight wtmec2yr;
            strata sdmvstra;
            cluster sdmvpsu;
            title "Univariate Model: &var (ref=&ref)";
        run;
    %end;
    %else %do;
        proc surveylogistic data=logit_data;
            model disab_salty_all(event='1') = &var;
            weight wtmec2yr;
            strata sdmvstra;
            cluster sdmvpsu;
            title "Univariate Model: &var (continuous)";
        run;
    %end;

%mend;


%univariate_logit(var=peri_g2, ref=0);
%univariate_logit(var=race3, ref=1);
%univariate_logit(var=female, ref=0);
%univariate_logit(var=binge_alq_g3, ref=1);
%univariate_logit(var=Smoker, ref=0);
%univariate_logit(var=age, ref=);   /* no reference, continuous */


proc surveylogistic data=logit_data;
    class &classvars / param=ref;
    model disab_salty_all(event='1') = peri_g2 age race3 female binge_alq_g3 Smoker;
    weight wtmec2yr;
    strata sdmvstra;
    cluster sdmvpsu;
    title "SET 1: Salty disability ~ peri_g2 adjusted for age, race, sex, binge, smoking";
run;

/* SET 2 - Salty disability ~ peri_stage_4vs23 */
%macro univariate_logit_step2(var=, ref=);
    %if %length(&ref) > 0 %then %do;
        proc surveylogistic data=logit_data;
            class &var(ref="&ref") / param=ref;
            model disab_salty_all(event='1') = &var;
            weight wtmec2yr;
            strata sdmvstra;
            cluster sdmvpsu;
            title "Step 2 Univariate Model: &var (ref=&ref)";
        run;
    %end;
    %else %do;
        proc surveylogistic data=logit_data;
            model disab_salty_all(event='1') = &var;
            weight wtmec2yr;
            strata sdmvstra;
            cluster sdmvpsu;
            title "Step 2 Univariate Model: &var (continuous)";
        run;
    %end;
%mend;

/* Run each predictor */
%univariate_logit_step2(var=age, ref=);
%univariate_logit_step2(var=race3, ref=1);
%univariate_logit_step2(var=female, ref=0);
%univariate_logit_step2(var=Smoker, ref=0);
%univariate_logit_step2(var=binge_alq_g3, ref=1);
%univariate_logit_step2(var=peri_stage_4vs23, ref=0);

proc surveylogistic data=logit_data;
    class race3(ref='1') female(ref='0') Smoker(ref='0') binge_alq_g3(ref='1') peri_stage_4vs23(ref='0') / param=ref;
    model disab_salty_all(event='1') = age race3 female Smoker binge_alq_g3 peri_stage_4vs23;
    weight wtmec2yr;
    strata sdmvstra;
    cluster sdmvpsu;
    title "Step 2 Multivariable Logistic Model: Salty Disability ~ Peri Stage (4 vs 2–3)";
run;

/* SET 3 - Bitter disability ~ peri_g2 */

%macro univariate_logit_step3(var=, ref=);
    %if %length(&ref) > 0 %then %do;
        proc surveylogistic data=logit_data;
            class &var(ref="&ref") / param=ref;
            model disab_bit_all(event='1') = &var;
            weight wtmec2yr;
            strata sdmvstra;
            cluster sdmvpsu;
            title "SET 3 Univariate Model: &var (ref=&ref)";
        run;
    %end;
    %else %do;
        proc surveylogistic data=logit_data;
            model disab_bit_all(event='1') = &var;
            weight wtmec2yr;
            strata sdmvstra;
            cluster sdmvpsu;
            title "SET 3 Univariate Model: &var (continuous)";
        run;
    %end;
%mend;

/* Call macro for each predictor */
%univariate_logit_step3(var=age, ref=);
%univariate_logit_step3(var=race3, ref=1);
%univariate_logit_step3(var=female, ref=0);
%univariate_logit_step3(var=Smoker, ref=0);
%univariate_logit_step3(var=binge_alq_g3, ref=1);
%univariate_logit_step3(var=peri_g2, ref=0);

proc surveylogistic data=logit_data;
    class race3(ref='1') female(ref='0') Smoker(ref='0') binge_alq_g3(ref='1') peri_g2(ref='0') / param=ref;
    model disab_bit_all(event='1') = age race3 female Smoker binge_alq_g3 peri_g2;
    weight wtmec2yr;
    strata sdmvstra;
    cluster sdmvpsu;
    title "SET 3 Multivariable Logistic Model: Bitter Disability ~ peri_g2 + covariates";
run;

/* SET 4 - Bitter disability ~ peri_stage_4vs23 */
%macro univariate_logit_step4(var=, ref=);
    %if %length(&ref) > 0 %then %do;
        proc surveylogistic data=logit_data;
            class &var(ref="&ref") / param=ref;
            model disab_bit_all(event='1') = &var;
            weight wtmec2yr;
            strata sdmvstra;
            cluster sdmvpsu;
            title "Step 4 Univariate Model: &var (ref=&ref)";
        run;
    %end;
    %else %do;
        proc surveylogistic data=logit_data;
            model disab_bit_all(event='1') = &var;
            weight wtmec2yr;
            strata sdmvstra;
            cluster sdmvpsu;
            title "Step 4 Univariate Model: &var (continuous)";
        run;
    %end;
%mend;

/* Run univariate models */
%univariate_logit_step4(var=age, ref=);
%univariate_logit_step4(var=race3, ref=1);
%univariate_logit_step4(var=female, ref=0);
%univariate_logit_step4(var=Smoker, ref=0);
%univariate_logit_step4(var=binge_alq_g3, ref=1);
%univariate_logit_step4(var=peri_stage_4vs23, ref=0);


proc surveylogistic data=logit_data;
    class race3(ref='1') female(ref='0') Smoker(ref='0') binge_alq_g3(ref='1') peri_stage_4vs23(ref='0') / param=ref;
    model disab_bit_all(event='1') = age race3 female Smoker binge_alq_g3 peri_stage_4vs23;
    weight wtmec2yr;
    strata sdmvstra;
    cluster sdmvpsu;
    title "Step 4 Multivariable Model: Bitter Disability ~ Peri Stage + Covariates";
run;

/*============================================*/
/* SECTION 8 : FREQUENCY TABLES */
/*============================================*/

/**************************** FREQUENCY TABLES ***********************************/

proc freq data =  pt_2;
*table peri_g2* peri_stage_N/missing ;
table (disab_salty_all disab_bit_all)*peri_stage_N/missing ;
run;

/**
there are 354 msising for all tooth count (where denti with 354 mising)
however, there are 611 misisng for peri-test 

***/;


/* Creating the table for Bitter (disab_bit_all) */
proc freq data=pt_2;
    tables (peri_g2 peri_stage_N age) * disab_bit_all / chisq norow nocol nopercent;
    title "Table for disab_bit_all (Bitter)";
run;

/* Creating the table for Salty (disab_salty_all) */
proc freq data=pt_2;
    tables (peri_g2 peri_stage_N age) * disab_salty_all / chisq norow nocol nopercent;
    title "Table for disab_salty_all (Salty)";
run;


/* Cross-tabulations with Periodontitis and Taste Disabilities */
proc freq data=pt_2;
    tables Xerostomia*peri_stage_N / chisq norow nocol nopercent;
    tables Xerostomia*disab_salty_all / chisq norow nocol nopercent;
    
    tables Caries_YN*peri_stage_N / chisq norow nocol nopercent;
    tables Caries_YN*disab_salty_all / chisq norow nocol nopercent;
    
    tables Missing_Teeth_YN*peri_stage_N / chisq norow nocol nopercent;
    tables Missing_Teeth_YN*disab_salty_all / chisq norow nocol nopercent;
    
run;

/*Medications analysis*/
/*  */
/* proc freq data=permdata.rxq_rx_h; */
/*     tables RXDDRUG / nocum nopercent; */
/*     where index(upcase(RXDDRUG), 'ATENO') > 0; */
/* run; */
/*  */
/* proc freq data=pt_2 order=freq; */
/* tables RXDDRUG; */
/* run; */


 /*============================================*/
/* SECTION EXTRA1 : ANALYSIS FOR PI */
/*============================================*/

/* Getting all individual LOAs and LOA variables */

/*
Stages of Periodontitis:
Attachment loss and probing depth is measured on six surfaces (DF, MDF, MF, DL, MDL, ML) per tooth. 
If defined as periodontitis, following criteria is used to define as different stages (increasing stage means increasing severity).
Stage 1: attachment loss of 1-2 mm (even 1 surface/ tooth counts but only surfaces of interest are DF, MF, DL and ML))
Stage 2: attachment loss of 3-4 mm (even 1 surface/ tooth counts but only surfaces of interest are DF, MF, DL and ML))
Stage 3: attachment loss of 5 or >5 mm (even 1 surface/ tooth counts but only surfaces of interest are DF, MF, DL and ML))
Stage 4: attachment loss of 5 or >5 mm with less than 20 remaining teeth (missing eleven teeth or more)

remaining_teeth='remaining teeth count based on 32 teeth'
remaining_teeth_p28='remaining teeth count based on 28 teeth'
t_ls20='<20 teeth based on 32 teeth'
*/

/**
proc freq data=pt_2;
 *table LOA_DF_02 LOA_MF_02 LOA_DL_02 LOA_ML_02;
 table remaining_teeth t_ls20;
 run;

proc print data=pt_2s ;
 *var max_LOA_02 LOA_DF_02 LOA_MF_02 LOA_DL_02 LOA_ML_02;
var max_LOA_03 LOA_DF_03 LOA_MF_03 LOA_DL_03 LOA_ML_03;
* var  max_LOA_total max_LOA_02  max_LOA_03  max_LOA_04  max_LOA_05  max_LOA_06  max_LOA_07  max_LOA_08  max_LOA_09  max_LOA_10 
      max_LOA_11  max_LOA_12  max_LOA_13  max_LOA_14  max_LOA_15  
	  max_LOA_18  max_LOA_19  max_LOA_20  max_LOA_21  max_LOA_22  max_LOA_23  max_LOA_24  max_LOA_25  max_LOA_26 
	  max_LOA_27  max_LOA_28  max_LOA_29  max_LOA_30  max_LOA_31;
 run;

proc freq data=pt_2s;
 where peri_g2=1;
 *table max_LOA_02 max_LOA_03 max_LOA_31;
 table t_ls20 remaining_teeth;
 *table t_ls20  max_LOA_total max_LOA_total_g3;
 *table t_ls20*  max_LOA_total_g3 peri_stage_N;
 table peri_stage_N;
 run;
**/

/***************
 data set for PI to check (n=9, n=3 for each stage)
 **********/;
/**
data per_stage_PI  ;
   retain  seqn peri_stage_N max_LOA_total max_LOA_total_g3 t_ls20 remaining_teeth   max_LOA_02  max_LOA_03  max_LOA_04  
       max_LOA_05  max_LOA_06  max_LOA_07  max_LOA_08  max_LOA_09  max_LOA_10 
      max_LOA_11  max_LOA_12  max_LOA_13  max_LOA_14  max_LOA_15  
	  max_LOA_18  max_LOA_19  max_LOA_20  max_LOA_21  max_LOA_22  max_LOA_23  max_LOA_24  max_LOA_25  max_LOA_26 
	  max_LOA_27  max_LOA_28  max_LOA_29  max_LOA_30  max_LOA_31;

 set  pt_2;

  keep  seqn peri_stage_N max_LOA_total max_LOA_total_g3 t_ls20 remaining_teeth   max_LOA_02  max_LOA_03  max_LOA_04  
     max_LOA_05  max_LOA_06  max_LOA_07  max_LOA_08  max_LOA_09  max_LOA_10 
      max_LOA_11  max_LOA_12  max_LOA_13  max_LOA_14  max_LOA_15  
	  max_LOA_18  max_LOA_19  max_LOA_20  max_LOA_21  max_LOA_22  max_LOA_23  max_LOA_24  max_LOA_25  max_LOA_26 
	  max_LOA_27  max_LOA_28  max_LOA_29  max_LOA_30  max_LOA_31;

run;

proc sort data=per_stage_PI;
 by seqn;
 run;

data per_stage_PI_2;
 set per_stage_PI;
 if peri_stage_N=2;
run;

data per_stage_PI_2a;
 set per_stage_PI_2;
  by seqn;
  if _N_<=3;
 run;


data per_stage_PI_3;
 set per_stage_PI;
 if peri_stage_N=3;
run;

data per_stage_PI_3a;
 set per_stage_PI_3;
  by seqn;
  if _N_<=3;
 run;

data per_stage_PI_4;
 set per_stage_PI;
 if peri_stage_N=4;
run;

data per_stage_PI_4a;
 set per_stage_PI_4;
  by seqn;
  if _N_<=3;
 run;

data per_stage_PI_n9;
 set per_stage_PI_2a per_stage_PI_3a per_stage_PI_4a;
 run;
**/
/***
  data set for PI to check (n=9, n=3 for each stage)

  data permdata.per_stage_PI_n9;
  set per_stage_PI_n9;
 run;

 < label> 
    remaining_teeth='remaining teeth count based on 32 teeth'
    t_ls20='<20 teeth based on 32 teeth'

    max_LOA_02='tooth_02, max attachment loss of 4 surfaces (DF, MF, DL and ML)'
	max_LOA_03='tooth_03, max attachment loss of 4 surfaces (DF, MF, DL and ML)'

	max_LOA_total='max attachment loss of 4 surfaces among the 28 teeth'
	max_LOA_total_g3='max attachment loss of 4 surfaces among the 28 teeth, 1: 1-2, 2: 3-4, 3:>=5 mm'
	peri_stage_n='periodontitis stage, 1-4'
	;

 *************/;


/***********************
LinHY, 5/1/2025 check 
 *************************************/;
 
proc freq data=pt_2;
 where elig=1;
 *table RIAGENDR female DMDEDUC2 edu ;
 *table RIDRETH1  race race3;
*table DIQ010 Diabetes_status SMQ020 Ever_Smoker ALQ151 binge_alq_g3;
*table DMDMARTL Marital_Status;
table CSQ202 Xerostomia;
table C_Count Caries_YN;
 run;
proc means data=pt_2;
class pirg4;
var INDFMPIR  ;
run;
proc means data=pt_2;
 where elig=1;
 class BMI_category;
 var BMXBMI;
run;
 

/*** check carries status */

proc freq data=pt_2;
 where elig=1;
 *table OHX2CTC c_2  OHX3CTC  c_3;
 table c_count ;
 run;

proc print data= pt_2 (obs=50);
 var c_2   c_3  c_4 c_count; 
 run;

proc print data= pt_2 (obs=50);
 where c_count=.;
 var c_count c_2    c_3   c_4   c_5    c_6   c_7   c_8    c_9   c_10   c_11  c_12     c_13   c_14   c_15  
         c_18    c_19   c_20   c_21  c_22     c_23   c_24   c_25  c_26   c_27   c_28    c_29   c_30   c_31 ;
run; 
proc contents data=pt_2;
run;
/*
remaining_teeth='remaining teeth count based on 32 teeth'
remaining_teeth_p28='remaining teeth count based on 28 teeth'
*/

proc freq data=pt_2;
 where elig=1;
 table remaining_teeth remaining_teeth_p28 Missing_Teeth_YN;
 run;

/*
 ALQ101 - Had at least 12 alcohol drinks/1 yr? 1: yes, 2: no, 7/9/. 
	  
	ALQ141Q - # days have 4/5 drinks - past 12 mos
	ALQ151 - Ever have 4/5 or more drinks every day?
 ***/

 proc freq data=pt_2;
 *where elig=1;
  table  ALQ101 *ALQ141Q /missing;
  run;



  /*****
5/16/2025
  To Mansi,
#1. Move the medicine dataset to the top, so all datasets can merge once. 
    Recode medicine in the main data step 
    var name: med_yn

data pt_2a;
 set permdata.peri_taste_n10175_250516;
run;

#2. Revise alcohol-related factors. 
  Define missing values for each variable and then combine the processed variables to create a new variable 
  
 
*****/; 
