/*
use NHANES 2013-2014 data
Assign a permanent library to the folder where you want to save the .sas7bdat files 

/*
LinHY, 12/21/2024
From PI
PERIODONTITIS is defined based on following criteria for ATTACHMENT LOSS, PROBING DEPTH:
•	Attachment loss of 1 mm or more on at least 2 teeth (even 1 surface/ tooth counts but only surfaces of interest are DF, MF, DL and ML) with PD (pocket depth) 4 mm or 
•	more on at least 2 teeth (even 1 surface/ tooth counts but only surfaces of interest are DF, MF, DL and ML)) is defined as periodontitis. 
•	Otherwise defined as no periodontitis (0 mm attachment loss on all teeth or less than 2 teeth have more than 0 mm attachment loss). 
•	Attachment loss and probing depth is measured on six surfaces (DF, MDF, MF, DL, MDL, ML) per tooth. 

NHANES peri questions are for age >=30
*/

/** LinHY, set up missing **/; 

libname permdata 'T:\LinHY_project\NHANES\oral_health\data';

/**********************************  MACROS *******************************/
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

/** 12/23/2024, LinHY 
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

proc sort data=permdata.ohxper_h;
 by SEQN;
run;

proc sort data=permdata.ohxper_h;
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
    if a; /* Keeps only observations that are in ohxper_h */
run;

/* Creating a dataset to calculate periodontitis for all relevant teeth */

data peri_all_teeth;
    set merging_per_den;
	%peri_1t(02, OHX02LAD, OHX02LAS, OHX02LAP, OHX02LAA, OHX02PCD, OHX02PCS, OHX02PCP, OHX02PCA);
run;


proc freq data=peri_all_teeth;
 table  peri_t02;
 run;

*

/****
1/1/2025, LinHY, verified "peri_g2"

                   periodontitis based on 28 teeth, 1:yes, 0:no

                                                      Cumulative    Cumulative
                  peri_g2    Frequency     Percent     Frequency      Percent
                  ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                        0         844       46.81           844        46.81
                        1         959       53.19          1803       100.00

                                    Frequency Missing = 2866

 *********/;

%macro peri_stage(tooth, df_al, mf_al, dl_al, ml_al);

    /* Initializing the stage variable for the specific tooth */
    if peri_t&tooth. = 1 then do;

   /* Stage 3: Attachment loss of 5 mm or more */
        if (&df_al >= 5) or 
                (&mf_al >= 5) or 
                (&dl_al >= 5) or 
                (&ml_al >= 5) then periodontitis_stage_&tooth = 3;

    /* Stage 2: Attachment loss of 3-4 mm */
        else if (&df_al >= 3 and &df_al <= 4) or 
                (&mf_al >= 3 and &mf_al <= 4) or 
                (&dl_al >= 3 and &dl_al <= 4) or 
                (&ml_al >= 3 and &ml_al <= 4) then periodontitis_stage_&tooth = 2;

        /* Stage 1: Attachment loss of 1-2 mm */
        else if (&df_al >= 1 and &df_al <= 2) or 
                (&mf_al >= 1 and &mf_al <= 2) or 
           		(&dl_al >= 1 and &dl_al <= 2) or 
           		(&ml_al >= 1 and &ml_al <= 2) then periodontitis_stage_&tooth = 1;
       
        else call missing(periodontitis_stage_&tooth); /* If no stage is applicable */
    end;
    else call missing(periodontitis_stage_&tooth); /* Not assessed if no periodontitis */
%mend peri_stage;



	/** tooth present or not */
%macro t_count(var, tooth);
   if &var.=. or &var.=9 then t&tooth.=.;
   else if &var.=2 then t&tooth.=1;
   else t&tooth.=0;
%mend t_count;

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
define stage 
***************/;
    /* Applying the stage macro for each tooth */

   %peri_stage(02, LOA_DF_02, LOA_MF_02, LOA_DL_02, LOA_ML_02);
   %peri_stage(03, LOA_DF_03, LOA_MF_03, LOA_DL_03, LOA_ML_03);
   %peri_stage(04, LOA_DF_04, LOA_MF_04, LOA_DL_04, LOA_ML_04);
   %peri_stage(05, LOA_DF_05, LOA_MF_05, LOA_DL_05, LOA_ML_05);
   %peri_stage(06, LOA_DF_06, LOA_MF_06, LOA_DL_06, LOA_ML_06);
   %peri_stage(07, LOA_DF_07, LOA_MF_07, LOA_DL_07, LOA_ML_07);
   %peri_stage(08, LOA_DF_08, LOA_MF_08, LOA_DL_08, LOA_ML_08);
   %peri_stage(09, LOA_DF_09, LOA_MF_09, LOA_DL_09, LOA_ML_09);
   %peri_stage(10, LOA_DF_10, LOA_MF_10, LOA_DL_10, LOA_ML_10);
   %peri_stage(11, LOA_DF_11, LOA_MF_11, LOA_DL_11, LOA_ML_11);
   %peri_stage(12, LOA_DF_12, LOA_MF_12, LOA_DL_12, LOA_ML_12);
   %peri_stage(13, LOA_DF_13, LOA_MF_13, LOA_DL_13, LOA_ML_13);
   %peri_stage(14, LOA_DF_14, LOA_MF_14, LOA_DL_14, LOA_ML_14);
   %peri_stage(15, LOA_DF_15, LOA_MF_15, LOA_DL_15, LOA_ML_15);

   %peri_stage(18, LOA_DF_18, LOA_MF_18, LOA_DL_18, LOA_ML_18);
   %peri_stage(19, LOA_DF_19, LOA_MF_19, LOA_DL_19, LOA_ML_19);
   %peri_stage(20, LOA_DF_20, LOA_MF_20, LOA_DL_20, LOA_ML_20);
   %peri_stage(21, LOA_DF_21, LOA_MF_21, LOA_DL_21, LOA_ML_21);
   %peri_stage(22, LOA_DF_22, LOA_MF_22, LOA_DL_22, LOA_ML_22);
   %peri_stage(23, LOA_DF_23, LOA_MF_23, LOA_DL_23, LOA_ML_23);
   %peri_stage(24, LOA_DF_24, LOA_MF_24, LOA_DL_24, LOA_ML_24);
   %peri_stage(25, LOA_DF_25, LOA_MF_25, LOA_DL_25, LOA_ML_25);   
   %peri_stage(26, LOA_DF_26, LOA_MF_26, LOA_DL_26, LOA_ML_26);
   %peri_stage(27, LOA_DF_27, LOA_MF_27, LOA_DL_27, LOA_ML_27);   
   %peri_stage(28, LOA_DF_28, LOA_MF_28, LOA_DL_28, LOA_ML_28);
   %peri_stage(29, LOA_DF_29, LOA_MF_29, LOA_DL_29, LOA_ML_29);   
   %peri_stage(30, LOA_DF_30, LOA_MF_30, LOA_DL_30, LOA_ML_30);
   %peri_stage(31, LOA_DF_31, LOA_MF_31, LOA_DL_31, LOA_ML_31);
   

    /* Calculating the overall periodontitis stage */
    array stages[*] periodontitis_stage_02-periodontitis_stage_31;

    /* Using the max function, but only for non-missing values */
    periodontitis_stage_max = max(of stages[*]);


    /* Calculate the number of remaining teeth */


	if remaining_teeth=. then t_ls20=.;
	else if remaining_teeth ne . and remaining_teeth< 20 then t_ls20=1;
	else t_ls20=0;

    /* LinHY, define peri stage */
/*
	Stage 1: attachment loss of 1-2 mm (even 1 surface/ tooth counts but only surfaces of interest are DF, MF, DL and ML))
Stage 2: attachment loss of 3-4 mm (even 1 surface/ tooth counts but only surfaces of interest are DF, MF, DL and ML))
Stage 3: attachment loss of 5 or >5 mm (even 1 surface/ tooth counts but only surfaces of interest are DF, MF, DL and ML))
Stage 4: attachment loss with less than 20 remaining teeth (missing eleven teeth or more)

Ask? Stage 4:attachment loss of 5 or >5 mm?
	*/

    /* Assign Stage 4 if remaining teeth are less than 20 */
   if peri_g2 = 1 then do;
      if periodontitis_stage_max=3 and t_ls20=1 then peri_stage= 4;
	  else peri_stage= periodontitis_stage_max;
	end;
   else peri_stage=.;

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
	peri_stage='periodontitis stage, 1-4'
	
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
t_ls20='<20 teeth'

disab_salty_tp='disability salty taste, Tongue Tip 1M NaCl, 1: yes, 0:no'
disab_salty_wm='disability salty taste, Whole Mouth 1M NaCl, 1: yes, 0:no'
disab_salty_all='disability salty taste, Tongue Tip or whole mouth, 1: yes, 0:no'

disab_bit_tp='disability bitter taste, Tongue 1mM Quinine, 1: yes, 0:no'
disab_bit_wm='disability bitter taste, Whole Mouth 1mM Quinine, 1: yes, 0:no'
disab_bit_all='disability bitter taste, Tongue Tip or whole mouth, 1: yes, 0:no'
;

run;
/**
there are 354 msising for all tooth count (where denti with 354 mising)
however, there are 611 misisng for peri-test 

***/;

proc means data=peri_all;
  class t_ls20;
  var remaining_teeth;
  run;


proc freq data=peri_all;
 table peri_test *peri_g2/missing;
 table periodontitis_stage_max* t_ls20/missing;
run;

proc freq data=peri_all;
 where peri_g2=.;
 table peri_total_all* peri_total_any* peri_total_mis/list missing;
run;


proc freq data=peri_all;
 where peri_g2=1;
 table peri_g2 periodontitis_stage_max * t_ls20 peri_stage/missing ;
 run;

proc freq data=peri_all;
 where t02=1;
 table LOA_4s_ge1_02* pD_4s_ge4_02 peri_t02/missing ;
 run;

proc means data=peri_all n mean median std min max maxdec=2;
 var remaining_teeth peri_total_mis;
 run;

proc freq data=peri_all;
 table peri_g2 peri_stage;
 run;

proc freq data=peri_all;
 where t02=1;
  table LOA_DF_02 *LOA_MF_02* LOA_DL_02* LOA_ML_02 LOA_4s_ge1_02 /list missing ;
 run;

proc freq data=peri_all;
 where t02=1;
  table PD_DF_02 *PD_MF_02* PD_DL_02* PD_ML_02 PD_4s_ge4_02 /list missing ;
 run;

proc freq data=peri_all;
 where t03=1;
  table LOA_DF_03 *LOA_MF_03* LOA_DL_03* LOA_ML_03 LOA_4s_ge1_03 /list missing ;
 run;

proc freq data=peri_all;
 table peri_t02* t02/missing;
 table peri_t03* t03/missing;
 run;



/**** 
 1/2/2025
 Eligilbe study population 

 drop n=300 (298 with 0 teeth and 2 with 1 tooth based on the 28 teeth of peri check) 
 
 n=2155 with valid data in peri status and taste results 
 ********/;

data pt;
 set peri_all;
  
 if age>=40;

 if disab_salty_all=. and disab_bit_all=. then delete;

 if peri_g2=. then delete;
 if remaining_teeth_p28>=2 ;
run;


proc freq data=pt;
 table peri_g2 peri_stage;
 table disab_salty_tp disab_salty_wm disab_salty_all disab_bit_tp disab_bit_wm disab_bit_all;
 run;

proc means data=pt;
 var age;
 run;

proc means data=pt;
 where  peri_g2=0 and peri_test=0;
 var remaining_teeth;
 run;

/*2025 CODE USED TO CREATED NEW TABLES AND FREQUENCIES*/
 /*Main dataset = pt*/
 /*Main explanatory variables = peri_g2 & peri_stage*/
 /*Main response variables = disab_salty_all disab_bitter_all*/
 /*Extra response variables = disab_salty_tp disab_salty_wm disab_bit_wm disab_bit_tp*/

/* Creating the table for Bitter (disab_bit_all) */
proc freq data=pt;
    tables (peri_g2 peri_stage age) * disab_bit_all / chisq norow nocol nopercent;
    title "Table for disab_bit_all (Bitter)";
run;

/* Creating the table for Salty (disab_salty_all) */
proc freq data=pt;
    tables (peri_g2 peri_stage age) * disab_salty_all / chisq norow nocol nopercent;
    title "Table for disab_salty_all (Salty)";
run;

/*******Frequency tables for secondary predictors! ******/
/* Merge additional datasets and recode variables */
data pt_2;
    merge pt(in=a) permdata.bmx_h(in=b) permdata.alq_h(in=c) permdata.diq_h(in=d) permdata.smq_h(in=e);
    by SEQN;
    if a; /* Keep only those in pt */

    /* Recode Gender */
    length Gender $10;
    if RIAGENDR = 1 then Gender = 'Male';
    else if RIAGENDR = 2 then Gender = 'Female';
    else Gender = '';

    /* Recode Education Level */
    length Education_Level $15;
    if DMDEDUC2 in (1,2) then Education_Level = '<High School';
    else if DMDEDUC2 = 3 then Education_Level = 'High School';
    else if DMDEDUC2 in (4,5) then Education_Level = '>High School';
    else Education_Level = '';

    /* Recode Poverty Index */
    length Poverty_Index $10;
    if INDFMPIR <= 1 then Poverty_Index = '<=1';
    else if INDFMPIR > 1 and INDFMPIR <= 2 then Poverty_Index = '1.1-2';
    else if INDFMPIR > 2 and INDFMPIR <= 4 then Poverty_Index = '2.1-4';
    else if INDFMPIR > 4 then Poverty_Index = '>4';
    else Poverty_Index = '';

    /* Recode Race */
    length Race_Grp $25;
    if RIDRETH3 = 3 then Race_Grp = 'Non-Hispanic White';
    else if RIDRETH3 = 4 then Race_Grp = 'Non-Hispanic Black';
    else Race_Grp = 'Hispanic or Others';

    /* Recode Obesity */
    length BMI_category $10;
    if BMXBMI <= 24.9 then BMI_category = '<25';
    else if BMXBMI <= 29.9 then BMI_category = '25-29.9';
    else if BMXBMI >= 30 then BMI_category = '>=30';
    else BMI_category = '';

    /* Recode Diabetes */
    length Diabetes_status $15;
    if DIQ010 = 1 then Diabetes_status = 'Yes';
    else if DIQ010 = 2 then Diabetes_status = 'No';
    else if DIQ010 = 3 then Diabetes_status = 'Borderline';
    else Diabetes_status = '';

    /* Recode Smoking */
    length Ever_Smoker $15;
    if SMQ020 = 1 then Ever_Smoker = 'Never Smoker';
    else if SMQ020 in (2,3) then Ever_Smoker = 'Ever Smoker';
    else Ever_Smoker = '';

    /* Recode Binge Drinking */
    length Binge_Drinking $10;
    if ALQ151 = 1 then Binge_Drinking = 'Yes';
    else if ALQ151 = 2 then Binge_Drinking = 'No';
    else Binge_Drinking = '';

    /* Recode Marital Status */
    length Marital_Status $30;
    if DMDMARTL in (1,6) then Marital_Status = 'Married or Living with Partner';
    else if DMDMARTL in (2,3,4,5) then Marital_Status = 'Widowed, Divorced, Separated';
    else Marital_Status = '';
run;

/* Frequency Tables for Bitter Taste Disability */
proc freq data=pt_2;
    tables peri_g2*disab_bit_all / chisq norow nocol nopercent;
    tables peri_stage*disab_bit_all / chisq norow nocol nopercent;
    tables Gender*disab_bit_all / chisq norow nocol nopercent;
    tables Education_Level*disab_bit_all / chisq norow nocol nopercent;
    tables Poverty_Index*disab_bit_all / chisq norow nocol nopercent;
    tables Race_Grp*disab_bit_all / chisq norow nocol nopercent;
    tables Marital_Status*disab_bit_all / chisq norow nocol nopercent;
    tables BMI_category*disab_bit_all / chisq norow nocol nopercent;
    tables Diabetes_status*disab_bit_all / chisq norow nocol nopercent;
    tables Ever_Smoker*disab_bit_all / chisq norow nocol nopercent;
    tables Binge_Drinking*disab_bit_all / chisq norow nocol nopercent;
run;

proc means data=pt_2 mean;
    var age;
    class disab_bit_all;
run;

/* Frequency Tables for Salty Taste Disability */
proc freq data=pt_2;
    tables peri_g2*disab_salty_all / chisq norow nocol nopercent;
    tables peri_stage*disab_salty_all / chisq norow nocol nopercent;
    tables Gender*disab_salty_all / chisq norow nocol nopercent;
    tables Education_Level*disab_salty_all / chisq norow nocol nopercent;
    tables Poverty_Index*disab_salty_all / chisq norow nocol nopercent;
    tables Race_Grp*disab_salty_all / chisq norow nocol nopercent;
    tables Marital_Status*disab_salty_all / chisq norow nocol nopercent;
    tables BMI_category*disab_salty_all / chisq norow nocol nopercent;
    tables Diabetes_status*disab_salty_all / chisq norow nocol nopercent;
    tables Ever_Smoker*disab_salty_all / chisq norow nocol nopercent;
    tables Binge_Drinking*disab_salty_all / chisq norow nocol nopercent;
run;

proc means data=pt_2 mean;
    var age;
    class disab_salty_all;
run;

/* Cross-tabulation for Alcohol Consumption */
proc freq data=pt_2;
    tables ALQ101*ALQ151 / chisq norow nocol nopercent;
run;

/* Merge Additional Datasets for Dental and Medication Variables */

data pt_3;
    merge pt_2(in=a) permdata.csq_h(in=b) permdata.ohq_h(in=c) permdata.ohxper_h(in=d) permdata.rxq_rx_h(in=e);
    by SEQN;
    if a; /* Keep only those in pt_2 */

    /* Define Lengths for New Variables */
    length Xerostomia $15 Dental_Caries $10 Medication_Type $50 Missing_Teeth_YN $10;

    /* --- Xerostomia (Dry Mouth) --- */
    if CSQ200 in (1) then Xerostomia = 'Yes';
    else if CSQ200 in (2) then Xerostomia = 'No';
    else Xerostomia = ''; /* Missing */

    /* --- Macro to Check Caries Presence --- */
    %macro check_caries;
        Caries_Count = 0; /* Initialize count */

        /* Loop through 28 teeth (Excluding 3rd Molars) */
        %do i = 2 %to 15;
            if OHX&i.CTC = 'Z' then Caries_Count + 1;
        %end;
        %do i = 18 %to 31;
            if OHX&i.CTC = 'Z' then Caries_Count + 1;
        %end;

        /* Assign Binary Indicator */
        if Caries_Count >= 1 then Caries_YN = 1;
        else Caries_YN = 0;
    %mend check_caries;

    /* Execute Macro for Caries */
    %check_caries;

    /* --- Missing Teeth Yes/No --- */
    if remaining_teeth < 28 then Missing_Teeth_YN = 'Yes';
    else if remaining_teeth >= 28 then Missing_Teeth_YN = 'No';
    else Missing_Teeth_YN = ''; /* Missing */

run;

/* Frequency Tables for Newly Added Dental and Medication Variables */
proc freq data=pt_3;
    tables Xerostomia / missing;
    tables Caries_YN / missing;
    tables Caries_Count / missing;
    tables Missing_Teeth_YN / missing;
run;

/* Cross-tabulations with Periodontitis and Taste Disabilities */
proc freq data=pt_3;
    tables Xerostomia*peri_stage / chisq norow nocol nopercent;
    tables Xerostomia*disab_salty_all / chisq norow nocol nopercent;
    
    tables Caries_YN*peri_stage / chisq norow nocol nopercent;
    tables Caries_YN*disab_salty_all / chisq norow nocol nopercent;
    
    tables Missing_Teeth_YN*peri_stage / chisq norow nocol nopercent;
    tables Missing_Teeth_YN*disab_salty_all / chisq norow nocol nopercent;
    
run;

/*Medications analysis*/

proc freq data=pt_3 order=freq;
tables RXDDRUG;
run;





