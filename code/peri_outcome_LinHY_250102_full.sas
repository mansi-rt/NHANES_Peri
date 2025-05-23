/*
use NHANES 2013-2014 data
Assign a permanent library to the folder where you want to save the .sas7bdat files 

## data set with peri status (peri_g2, peri_stage
 permdata.peri_all_250101;


*/

libname permdata 'T:\LinHY_project\NHANES\oral_health\data';

data demo;
set permdata.demo_h;
run;

data ohxper;
set permdata.ohxper_h;
run;
/**** Experimenting and cretaing the periodontitis variable just for tooth 2M *************/
/* Creating a new dataset with the periodontitis variable */

/*
LinHY, 12/21/2024
From PI
PERIODONTITIS is defined based on following criteria for ATTACHMENT LOSS, PROBING DEPTH:
�	Attachment loss of 1 mm or more on at least 2 teeth (even 1 surface/ tooth counts but only surfaces of interest are DF, MF, DL and ML) with PD (pocket depth) 4 mm or 
�	more on at least 2 teeth (even 1 surface/ tooth counts but only surfaces of interest are DF, MF, DL and ML)) is defined as periodontitis. 
�	Otherwise defined as no periodontitis (0 mm attachment loss on all teeth or less than 2 teeth have more than 0 mm attachment loss). 
�	Attachment loss and probing depth is measured on six surfaces (DF, MDF, MF, DL, MDL, ML) per tooth. 

NHANES peri questions are for age >=30
*/

/** LinHY, set up missing **/; 
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


data periodontitis_2m;
    set permdata.ohxper_h;


    /* Checking the condition for periodontitis based on attachment loss and probing depth */
    /* Attachment loss on DF, MF, DL, or ML surfaces */
	/* Probing depth on DF, MF, DL, or ML surfaces */


/**define missing & rename  variables */
 %rename_1t(02, OHX02LAD, OHX02LAS, OHX02LAP, OHX02LAA, OHX02PCD, OHX02PCS, OHX02PCP, OHX02PCA);


%vrecode(OHX02LAD, 1, LOA_DF_ge1);
%vrecode(OHX02LAS, 1, LOA_MF_ge1);
%vrecode(OHX02LAP, 1, LOA_DL_ge1);
%vrecode(OHX02LAA, 1, LOA_ML_ge1);

%vrecode(OHX02PCD, 4, PD_DF_ge4);
%vrecode(OHX02PCS, 4, PD_MF_ge4);
%vrecode(OHX02PCP, 4, PD_DL_ge4);
%vrecode(OHX02PCA, 4, PD_ML_ge4);

if LOA_DF_ge1=1 or LOA_MF_ge1=1 or LOA_DL_ge1=1 or LOA_ML_ge1=1 then LOA_4s_ge1=1;
else if LOA_DF_ge1=0 and LOA_MF_ge1=0 and LOA_DL_ge1=0 and LOA_ML_ge1=0 then LOA_4s_ge1=0;
else LOA_4s_ge1=.;

if PD_DF_ge4=1 or PD_MF_ge4=1 or PD_DL_ge4=1 or PD_ML_ge4=1 then PD_4s_ge4=1;
else if PD_DF_ge4=0 and PD_MF_ge4=0 and PD_DL_ge4=0 and PD_ML_ge4=0 then PD_4s_ge4=0;
else PD_4s_ge4=.;


if  LOA_4s_ge1=. or  PD_4s_ge4=. then peri_2m=.;
else if LOA_4s_ge1=1 and PD_4s_ge4=1 then peri_2m=1;
else peri_2m=0;

*/;
/*
if LOA_DF=. and LOA_MF=. and LOA_DL=. and LOA_ML=. then LOA_4s_gt1=.;
else if LOA_DF>=1 or LOA_MF>=1 or LOA_DL>=1 or LOA_ML >=1 then LOA_4s_gt1=1;
else LOA_4s_gt1=0;

if LOA_DF=. and LOA_MF=. and LOA_DL=. and LOA_ML=. and LOA_PD_DF=. and LOA_PD_MF=. and LOA_PD_DL=. and LOA_PD_ML=. then peri_2m=.;
else if (LOA_DF>=1 or LOA_MF>=1 or LOA_DL>=1 or LOA_ML >=1) and (LOA_PD_DF>=4 or LOA_PD_MF>=4 or LOA_PD_DL>=4 or LOA_PD_ML>=4) then peri_2m=1;
else peri_2m=0;

*/;
    if 
        (OHX02LAD >= 1 or OHX02LAS >= 1 or OHX02LAP >= 1 or OHX02LAA >= 1) 
        and
        (OHX02PCD >= 4 or OHX02PCS >= 4 or OHX02PCP >= 4 or OHX02PCA >= 4) 
    then periodontitis_2m = "Yes";
	    
    else periodontitis_2m = "No";


	label 
  OHDEXSTS='Overall Oral Health Exam Status, 1:Complete, 2:	Partial, 3:	Not done'
  OHDPDSTS='Periodontal Status Code, 1:Complete, 2:	Partial, 3:	Not done'

OHX02LAD='LOA: Max R(2M) DF calculated AL(mm), Loss of Attachment: Upper right 2nd molar (2M) distal - Calculation of : (FGM to CEJ measurement) - (FGM to sulcus base measurement) (mm)'
OHX02LAS='LOA: Max R(2M) MF calculated AL(mm)'
OHX02LAP='LOA: Max R(2M) DL calculated AL(mm)'
OHX02LAA='LOA: Max R(2M) ML calculated AL(mm)'

OHX02PCD='LOA: Max R(2M) DF FGM-sulcus(mm), pocket depth'
OHX02PCS='LOA: Max R(2M) MF FGM-sulcus(mm), pocket depth'
OHX02PCP='LOA: Max R(2M) DL FGM-sulcus(mm), pocket depth'
OHX02PCA='LOA: Max R(2M) ML FGM-sulcus(mm), pocket depth'

LOA_DF_ge1='LOA: Max R(2M) DF calculated AL(mm), 1:>=1, 0:else'
LOA_MF_ge1='LOA: Max R(2M) MF calculated AL(mm), 1:>=1, 0:else'
 LOA_DL_ge1='LOA: Max R(2M) DL calculated AL(mm), 1:>=1, 0:else'
LOA_ML_ge1='LOA: Max R(2M) ML calculated AL(mm), 1:>=1, 0:else'

PD_DF_ge4='LOA: Max R(2M) DF FGM-sulcus(mm), pocket depth, 1:>=4, 0:else'
PD_MF_ge4='LOA: Max R(2M) MF FGM-sulcus(mm), pocket depth, 1:>=4, 0:else'
PD_DL_ge4='LOA: Max R(2M) DL FGM-sulcus(mm), pocket depth, 1:>=4, 0:else'
PD_ML_ge4='LOA: Max R(2M) ML FGM-sulcus(mm), pocket depth, 1:>=4, 0:else'

 LOA_4s_ge1='Attachment loss, >=1 mm on at least 2 teeth (even 1 surface for surface DF, MF, DL and ML, 1: yes, 0:no'

;

run;

/* Running proc freq to check the frequency of the new periodontitis variable */


proc freq data=periodontitis_2m;
 *table OHX02LAD  LOA_DF_ge1 OHX02LAS LOA_MF_ge1 OHX02LAP LOA_DL_ge1 OHX02LAA LOA_ML_ge1;
 *table OHX02PCD PD_DF_ge4 OHX02PCS PD_MF_ge4 OHX02PCP PD_DL_ge4 OHX02PCA PD_ML_ge4;
 table peri_2m;
 
 run;

proc freq data=periodontitis_2m;
 *table OHX02LAD LOA_DF;
* table OHDEXSTS OHDPDSTS;
 *table OHX02LAD OHX02LAS;
 *   tables periodontitis_2m ;
 *table periodontitis_2m;
 *table  OHDPDSTS;
 *table PD_4s_ge4;
 *table OHX02LAD LOA_DF_02 LOA_DF_ge1;
 table OHX02LAA  LOA_ML_02 LOA_ML_ge1;
 *table OHX02PCA PD_ML_02 PD_ML_ge4;
run;
/** check LOA*/
proc freq data=periodontitis_2m;
 where LOA_4s_ge1=1;
 table LOA_DF_ge1* LOA_MF_ge1*  LOA_DL_ge1* LOA_ML_ge1 LOA_4s_ge1/list missing;
run;

proc freq data=periodontitis_2m;
 *table  LOA_DF LOA_MF  LOA_DL LOA_ML LOA_4s_ge1;
 table LOA_4s_ge1;
 run;
/** check PD*/
 proc freq data=periodontitis_2m;
 table PD_4s_ge4;
 run;

proc freq data=periodontitis_2m;
 where PD_4s_ge4=1;
 table PD_DF_ge4* PD_MF_ge4* PD_DL_ge4 * PD_ML_ge4 PD_4s_ge4 /list missing;

run;


 proc freq data=periodontitis_2m;
 table peri_2m LOA_4s_ge1*PD_4s_ge4 /missing ;
 run;



/*
                                                     Cumulative    Cumulative
                LOA_4s_gt1    Frequency     Percent     Frequency      Percent
                ���������������������������������������������������������������
                         0           1        0.04             1         0.04
                         1        2627       99.96          2628       100.00

                                    Frequency Missing = 2041


                                                       Cumulative    Cumulative
                 PD_4s_ge4    Frequency     Percent     Frequency      Percent
                 ��������������������������������������������������������������
                         0        2177       83.80          2177        83.80
                         1         421       16.20          2598       100.00

                                    Frequency Missing = 2071

*/

proc print data=periodontitis_2m;
 where LOA_4s_ge1=.;
 var LOA_DF LOA_MF  LOA_DL LOA_ML LOA_4s_ge1;
 run;

/* Creating the periodontitis stage variable using the periodontitis_2m dataset */
data periodontitis_stage_2m;
    set periodontitis_2m;

    /* Initializing the periodontitis stage variable to missing */
    periodontitis_stage_2m = .;


    /* Assigning stages only to participants who have periodontitis */
    if periodontitis_2m = "Yes" then do;

        /* Checking for Stage 1: Attachment loss of 1-2 mm on any DF, MF, DL, or ML surface */
        if (OHX02LAD >= 1 and OHX02LAD <= 2) or 
           (OHX02LAS >= 1 and OHX02LAS <= 2) or 
           (OHX02LAP >= 1 and OHX02LAP <= 2) or 
           (OHX02LAA >= 1 and OHX02LAA <= 2) then periodontitis_stage_2m = 1;

        /* Checking for Stage 2: Attachment loss of 3-4 mm on any DF, MF, DL, or ML surface */
        if (OHX02LAD >= 3 and OHX02LAD <= 4) or 
           (OHX02LAS >= 3 and OHX02LAS <= 4) or 
           (OHX02LAP >= 3 and OHX02LAP <= 4) or 
           (OHX02LAA >= 3 and OHX02LAA <= 4) then periodontitis_stage_2m = 2;

        /* Checking for Stage 3: Attachment loss of 5 mm or more on any DF, MF, DL, or ML surface */
        if (OHX02LAD >= 5) or 
           (OHX02LAS >= 5) or 
           (OHX02LAP >= 5) or 
           (OHX02LAA >= 5) then periodontitis_stage_2m = 3;

        /* Checking for Stage 4: Less than 20 remaining teeth (condition needs to be checked separately) */
        /*else periodontitis_stage_2m = 4; Need the tooth loss dataset for Stage 4*/
    end;

run;

/* Running proc freq to check the distribution of the new periodontitis stage variable */
proc freq data=periodontitis_stage_2m;
    tables periodontitis_stage_2m;
run;
/******** Actually performing the analysis on all teeth ****/
/* Macro for creating periodontitis for individual teeth */

  /* Creating a periodontitis variable for the specific tooth 
	Adding the missing variable value */

/** 12/23/2024, LinHY 

A tooth that follows both of the following 2 criteria will be considered a PERIODONTITIS symptom for this tooth. Is this correct? 
   (1)                 At least 1 out of the 4 surfaces (DF, MF, DL, and ML) with attachment loss >= 1 mm
       AND 
    (2)                At least 1 out of the 4 surfaces (DF, MF, DL, and ML) with PD >= 4 mm
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

	if LOA_DF_ge1_&tooth.=1 or LOA_MF_ge1_&tooth.=1 or LOA_DL_ge1_&tooth.=1 or LOA_ML_ge1_&tooth.=1 then LOA_4s_ge1_&tooth.=1;
else if LOA_DF_ge1_&tooth.=0 and LOA_MF_ge1_&tooth.=0 and LOA_DL_ge1_&tooth.=0 and LOA_ML_ge1_&tooth.=0 then LOA_4s_ge1_&tooth.=0;
else LOA_4s_ge1_&tooth.=.;

if PD_DF_ge4_&tooth.=1 or PD_MF_ge4_&tooth.=1 or PD_DL_ge4_&tooth.=1 or PD_ML_ge4_&tooth.=1 then PD_4s_ge4_&tooth.=1;
else if PD_DF_ge4_&tooth.=0 and PD_MF_ge4_&tooth.=0 and PD_DL_ge4_&tooth.=0 and PD_ML_ge4_&tooth.=0 then PD_4s_ge4_&tooth.=0;
else PD_4s_ge4_&tooth.=.;


if  LOA_4s_ge1_&tooth.=. or  PD_4s_ge4_&tooth.=. then peri_t&tooth.=.;
else if LOA_4s_ge1_&tooth.=1 and PD_4s_ge4_&tooth.=1 then peri_t&tooth.=1;
else peri_t&tooth.=0;

%mend peri_1t;




/** count missing for the peri status of each tooth*/
%macro miss_ct(var);
  if &var.= . then &var._mis=1;
  else  &var._mis=0; 
%mend miss_ct;



/* MT version 
%macro create_periodontitis(tooth, df_al, mf_al, dl_al, ml_al, df_pd, mf_pd, dl_pd, ml_pd);

  
    if (&df_al >= 1 or &mf_al >= 1 or &dl_al >= 1 or &ml_al >= 1) 
        and
       (&df_pd >= 4 or &mf_pd >= 4 or &dl_pd >= 4 or &ml_pd >= 4) 
    then periodontitis_&tooth = 1;
	else if (&df_al = . & &mf_al = . & &dl_al = . & &ml_al = .)
        and
       (&df_pd = . & &mf_pd = . & &dl_pd = . & &ml_pd = .) 
    then periodontitis_&tooth = .;
    else periodontitis_&tooth = 0;

%mend;
*/


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
/*
data peri_all_teeth;
    set merging_per_den;
	%peri_1t(02, OHX02LAD, OHX02LAS, OHX02LAP, OHX02LAA, OHX02PCD, OHX02PCS, OHX02PCP, OHX02PCA);
run;
*/;

proc freq data=peri_all_teeth;
 table  peri_t02;
 run;

*

/****
1/1/2025, LinHY, verified "peri_g2"

                   periodontitis based on 28 teeth, 1:yes, 0:no

                                                      Cumulative    Cumulative
                  peri_g2    Frequency     Percent     Frequency      Percent
                  ������������������������������������������������������������
                        0         844       46.81           844        46.81
                        1         959       53.19          1803       100.00

                                    Frequency Missing = 2866

 *********/;
proc freq data=peri_all;
 table OHX02LAD OHX02LAS OHX02LAP;
 run;

*data periodontitis_all_teeth;
data peri_all;
    set merging_per_den;


rename RIDAGEYR=age;

    /** NHANES only had peri data for 28 teeth, 
# from PI: Usually 3rd molars are excluded (#1,16,17,32) since it is missing for most people or out of position. 
****/;

/* rename and define missing 
OHX02LAD -> LOA_DF_02
OHX02LAS-> LOA_MF_02
OHX02LAP -> LOA_DL_02
OHX02LAA -> LOA_ML_02
***/;

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



	/* Summing across all teeth to check if at least two teeth meet the periodontitis criteria */
	/*
total_teeth_with_periodontitis = 
    sum(peri_t02, peri_t03, peri_t04, peri_t05, 
    peri_t06, peri_t07, peri_t08, peri_t09, 
    peri_t10, peri_t11, peri_t12, peri_t13, 
    peri_t14, peri_t15, peri_t18, peri_t19, 
    peri_t20, peri_t21, peri_t22, peri_t23, 
    peri_t24, peri_t25, peri_t26, peri_t27, 
    peri_t28, peri_t29, peri_t30, peri_t31);
	*/
   /*
	total_teeth_with_periodontitis = 
    sum(periodontitis_02, periodontitis_03, periodontitis_04, periodontitis_05, 
    periodontitis_06, periodontitis_07, periodontitis_08, periodontitis_09, 
    periodontitis_10, periodontitis_11, periodontitis_12, periodontitis_13, 
    periodontitis_14, periodontitis_15, periodontitis_18, periodontitis_19, 
    periodontitis_20, periodontitis_21, periodontitis_22, periodontitis_23, 
    periodontitis_24, periodontitis_25, periodontitis_26, periodontitis_27, 
    periodontitis_28, periodontitis_29, periodontitis_30, periodontitis_31);
	*/

/* Checking if periodontitis is present based on at least two teeth having periodontitis 
	Adding the missing variable value */
/*
    if total_teeth_with_periodontitis >= 2 then periodontitis_overall = "Yes";
    else if missing(total_teeth_with_periodontitis) then call missing(periodontitis_overall);
    else periodontitis_overall = "No";
*/;

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




/******************** 
   count missing teeth for peri stage 
   *****************/

	if OHDDESTS=. or OHDDESTS=3 then denti=.;
	else if OHDDESTS=1 then denti=1;
	else denti=0;


    /* Count the number of missing teeth (code=4) */
    array teeth_status[28] OHX02TC OHX03TC OHX04TC OHX05TC OHX06TC OHX07TC OHX08TC 
                          OHX09TC OHX10TC OHX11TC OHX12TC OHX13TC OHX14TC OHX15TC 
                          OHX18TC OHX19TC OHX20TC OHX21TC OHX22TC OHX23TC OHX24TC 
                          OHX25TC OHX26TC OHX27TC OHX28TC OHX29TC OHX30TC OHX31TC;

    missing_teeth_count = 0;

    do i = 1 to dim(teeth_status);
        if teeth_status[i] = 4 then missing_teeth_count + 1;
    end;

	if denti=. then miss_teeth_ct=.;
	else miss_teeth_ct=missing_teeth_count;

    /* Calculate the number of remaining teeth */
    remaining_teeth = 32 -  miss_teeth_ct;

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

   /*
    if remaining_teeth < 20 then periodontitis_stage_max = 4;
    else periodontitis_stage_max = max(of periodontitis_stage_02-periodontitis_stage_31);

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

	/*
    if disability_bitter_whole = 'Yes' or disability_bitter_tip = 'Yes' then disability_bitter = 'Yes'; 
    else if disability_bitter_whole = 'No' and disability_bitter_tip = 'No' then disability_bitter = 'No';

    if disability_salty_whole = 'Yes' or disability_salty_tip = 'Yes' then disability_salty = 'Yes'; 
    else if disability_salty_whole = 'No' and disability_salty_whole = 'No' then disability_salty = 'No';
*/



label 
	peri_total_all='teeth count of peri for all 28 teeth, missing: any missing' 
	peri_total_any='teeth count of peri for all 28 teeth, missing: ALL missing' 
	peri_total_mis='count for teeth with missing peri'  
	peri_g2='periodontitis based on 28 teeth, 1:yes, 0:no'
	peri_stage='periodontitis stage, 1-4'
	
OHDDESTS='Dentition Status, 1:Complete, 2:Partial, 3:Not Done'
denti='Dentition Status, 1:Complete, 0:Partial'
OHX02TC='Tooth Count: #2, 1:Primary tooth present, 2:Permanent tooth present, 3:Dental implant, 
           4: Tooth not present, 5: Permanent dental root fragment present, 9:Could not assess'

CSXNAPT='taste, Tongue Tip, 1M NaCl, 1:Salty, 2:Bitter, 3: Something else, 4: No Taste, 5:Sour'
CSXSLTST='taste, Whole Mouth, 1 M NaCl,1:Salty, 2:Bitter, 3: Something else, 4: No Taste, 5:Sour'
CSXQUIPT='taste, Tongue Tip, 1mM Quinine, 1:Salty, 2:Bitter, 3: Something else, 4: No Taste, 5:Sour'
CSXQUIST='taste, Whole Mouth, 1mM Quinine, 1:Salty, 2:Bitter, 3: Something else, 4: No Taste, 5:Sour'

miss_teeth_ct='missing teeth count'
remaining_teeth='remaining teeth count'
t_ls20='<20 teeth'

disab_salty_tp='disability salty taste, Tongue Tip 1M NaCl, 1: yes, 0:no'
disab_salty_wm='disability salty taste, Whole Mouth 1M NaCl, 1: yes, 0:no'
disab_salty_all='disability salty taste, Tongue Tip or whole mouth, 1: yes, 0:no'

disab_bit_tp='disability bitter taste, Tongue 1mM Quinine, 1: yes, 0:no'
disab_bit_wm='disability bitter taste, Whole Mouth 1mM Quinine, 1: yes, 0:no'
disab_bit_all='disability bitter taste, Tongue Tip or whole mouth, 1: yes, 0:no'
;

run;
proc means data=peri_all;
 var age;
 run;

proc freq data=peri_all;
 table peri_g2 peri_stage;
 run;


/**** 
 n=1160 with valid data in peri status and taste results 
 ********/;

data pt;
 set peri_all;
  
 if age>=40;

 if disab_salty_all=. and disab_bit_all=. then delete;
 if peri_g2=. then delete;

run;

/***
data permdata.peri_taste_all_250102;
 set peri_all;
run;

data permdata.peri_taste_n1160_250102;
 set pt;
run;
*****/;

proc freq data=pt;
 *table peri_g2* (disab_salty_all disab_bit_all)/chisq;
 *table peri_g2* (disab_salty_tp disab_bit_tp)/chisq;
  table peri_g2* (disab_salty_wm disab_bit_wm)/chisq;
 run;



/*
project outline 

Eligibility: 
  Age >=40  years 

 peri var(age >=30), Dentition (age, 1-150), taste (age >=40)

Outcome: 
   Taste grade (bitter and salty) and disability
  Tongue tip taste test grading and disability (salt and bitter), whole mouth taste test grading and disability (salt and bitter)

Primary predictor:
            Periodontitis (yes/no, severity)

Covariates: Sex, age, educational level, poverty index, obesity, diabetes, smoking, xerostomia, dental caries, missing teeth, alcohol consumption (>4 drinks/occasion for women and >5 drinks/occasion for men in the past 30 days), and medications related to mouth dryness (antihistamines, decongestants, antidepressants, antipsychotics, antihypertensives, and anticholinergics).
*/





proc freq data=peri_all;
 *table peri_t02 peri_t03 peri_t04 peri_t05 
    peri_t06 peri_t07 peri_t08 peri_t09 
    peri_t10 peri_t11 peri_t12 peri_t13 
    peri_t14 peri_t15 peri_t18 peri_t19 
    peri_t20 peri_t21 peri_t22 peri_t23 
    peri_t24 peri_t25 peri_t26 peri_t27 
    peri_t28 peri_t29 peri_t30 peri_t31;
 *table peri_t02 peri_t02_mis  peri_t03 peri_t03_mis  peri_t04 peri_t04_mis  peri_t05 peri_t05_mis  peri_t06 peri_t06_mis ;
 * table peri_try;
 * table remaining_teeth t_ls20;
  *table peri_g2 peri_stage ;
  *table CSXNAPT  disab_salty_tp CSXSLTST disab_salty_wm;
  *table CSXQUIPT disab_bit_tp  CSXQUIST disab_bit_wm;
  *table disab_salty_tp* disab_salty_wm disab_salty_all/missing ;
   table disab_bit_tp* disab_bit_wm disab_bit_all/missing ;
run;

proc freq data=peri_all;
 where  peri_g2=1;
 table periodontitis_stage_max* t_ls20/missing ;
 run;

proc freq data=peri_all;
 table peri_g2;
*table peri_g2 peri_g2a;
*table peri_t02 * peri_t03 *peri_t04 *peri_t05 *
    peri_t06* peri_t07* peri_t08* peri_t09* 
    peri_t10* peri_t11* peri_t12* peri_t13* 
    peri_t14* peri_t15* peri_t18* peri_t19* 
    peri_t20* peri_t21* peri_t22* peri_t23* 
    peri_t24* peri_t25* peri_t26* peri_t27* 
    peri_t28* peri_t29* peri_t30* peri_t31;
run;

proc freq data=peri_all;
 where peri_g2=0;
table peri_total_all* peri_total_any *peri_total_mis peri_g2 /list missing ;
 run;
/** check 5 teeth first */
proc freq  data=periodontitis_all_teeth;
 *where peri_try=0;
 table  peri_t02 *peri_t03* peri_t04* peri_t05 * peri_t06 t5_all t5_any peri_try/list missing ;
 table peri_try;
run;

proc print data=periodontitis_all_teeth (obs=100);
  *where peri_try=.;
 var peri_t02 peri_t03 peri_t04 peri_t05 peri_t06 t5_all t5_any t5_mis peri_try;
 var 
run;

proc freq  data=periodontitis_all_teeth;
 where peri_g2=.;
  table peri_total_all peri_total_any peri_g2;
  run;


/*** 
12/23/24, LinHY
Q: check tooth03 
A: OK! 
***/;


proc freq data=periodontitis_all_teeth;
 *table OHX03LAD  LOA_DF_ge1_03 OHX03LAS LOA_MF_ge1_03 OHX03LAP LOA_DL_ge1_03 OHX03LAA LOA_ML_ge1_03;
 *table OHX03PCD PD_DF_ge4_03 OHX03PCS PD_MF_ge4_03 OHX03PCP PD_DL_ge4_03 OHX03PCA PD_ML_ge4_03;
* table LOA_DF_ge1_03* LOA_MF_ge1_03* LOA_DL_ge1_03 *LOA_ML_ge1_03  LOA_4s_ge1_03/list missing;
 *table PD_DF_ge4_03* PD_MF_ge4_03* PD_DL_ge4_03 *PD_ML_ge4_03 PD_4s_ge4_03/list missing;
  *table LOA_4s_ge1_03*PD_4s_ge4_03 peri_t03/missing;
  table LOA_4s_ge1_02*PD_4s_ge4_02 peri_t02/missing;
 run;



/* Running proc freq to check the distribution of the overall periodontitis variable */
proc freq data=periodontitis_all_teeth;
    tables periodontitis_overall;
	tables total_teeth_with_periodontitis;
run;

/* Macro for assigning periodontitis stage for individual teeth */
/*
%macro assign_periodontitis_stage(tooth, df_al, mf_al, dl_al, ml_al);

    if periodontitis_&tooth = 1 then do;

        if (&df_al >= 1 and &df_al <= 2) or 
           (&mf_al >= 1 and &mf_al <= 2) or 
           (&dl_al >= 1 and &dl_al <= 2) or 
           (&ml_al >= 1 and &ml_al <= 2) then periodontitis_stage_&tooth = 1;

        else if (&df_al >= 3 and &df_al <= 4) or 
                (&mf_al >= 3 and &mf_al <= 4) or 
                (&dl_al >= 3 and &dl_al <= 4) or 
                (&ml_al >= 3 and &ml_al <= 4) then periodontitis_stage_&tooth = 2;

        else if (&df_al >= 5) or 
                (&mf_al >= 5) or 
                (&dl_al >= 5) or 
                (&ml_al >= 5) then periodontitis_stage_&tooth = 3;

        else call missing(periodontitis_stage_&tooth); 
    end;
    else call missing(periodontitis_stage_&tooth); 
%mend;
*/;

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

/* Creating a dataset for periodontitis stage */
data periodontitis_stage_all_teeth;
    *set periodontitis_all_teeth;

     set peri_all;

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
   

/*
    %assign_periodontitis_stage(02, OHX02LAD, OHX02LAS, OHX02LAP, OHX02LAA);
    %assign_periodontitis_stage(03, OHX03LAD, OHX03LAS, OHX03LAP, OHX03LAA);
    %assign_periodontitis_stage(04, OHX04LAD, OHX04LAS, OHX04LAP, OHX04LAA);
    %assign_periodontitis_stage(05, OHX05LAD, OHX05LAS, OHX05LAP, OHX05LAA);
    %assign_periodontitis_stage(06, OHX06LAD, OHX06LAS, OHX06LAP, OHX06LAA);
    %assign_periodontitis_stage(07, OHX07LAD, OHX07LAS, OHX07LAP, OHX07LAA);
    %assign_periodontitis_stage(08, OHX08LAD, OHX08LAS, OHX08LAP, OHX08LAA);
    %assign_periodontitis_stage(09, OHX09LAD, OHX09LAS, OHX09LAP, OHX09LAA);
    %assign_periodontitis_stage(10, OHX10LAD, OHX10LAS, OHX10LAP, OHX10LAA);
    %assign_periodontitis_stage(11, OHX11LAD, OHX11LAS, OHX11LAP, OHX11LAA);
    %assign_periodontitis_stage(12, OHX12LAD, OHX12LAS, OHX12LAP, OHX12LAA);
    %assign_periodontitis_stage(13, OHX13LAD, OHX13LAS, OHX13LAP, OHX13LAA);
    %assign_periodontitis_stage(14, OHX14LAD, OHX14LAS, OHX14LAP, OHX14LAA);
    %assign_periodontitis_stage(15, OHX15LAD, OHX15LAS, OHX15LAP, OHX15LAA);
    
    %assign_periodontitis_stage(18, OHX18LAD, OHX18LAS, OHX18LAP, OHX18LAA);
    %assign_periodontitis_stage(19, OHX19LAD, OHX19LAS, OHX19LAP, OHX19LAA);
    %assign_periodontitis_stage(20, OHX20LAD, OHX20LAS, OHX20LAP, OHX20LAA);
    %assign_periodontitis_stage(21, OHX21LAD, OHX21LAS, OHX21LAP, OHX21LAA);
    %assign_periodontitis_stage(22, OHX22LAD, OHX22LAS, OHX22LAP, OHX22LAA);
    %assign_periodontitis_stage(23, OHX23LAD, OHX23LAS, OHX23LAP, OHX23LAA);
    %assign_periodontitis_stage(24, OHX24LAD, OHX24LAS, OHX24LAP, OHX24LAA);
    %assign_periodontitis_stage(25, OHX25LAD, OHX25LAS, OHX25LAP, OHX25LAA);
    %assign_periodontitis_stage(26, OHX26LAD, OHX26LAS, OHX26LAP, OHX26LAA);
    %assign_periodontitis_stage(27, OHX27LAD, OHX27LAS, OHX27LAP, OHX27LAA);
    %assign_periodontitis_stage(28, OHX28LAD, OHX28LAS, OHX28LAP, OHX28LAA);
    %assign_periodontitis_stage(29, OHX29LAD, OHX29LAS, OHX29LAP, OHX29LAA);
    %assign_periodontitis_stage(30, OHX30LAD, OHX30LAS, OHX30LAP, OHX30LAA);
    %assign_periodontitis_stage(31, OHX31LAD, OHX31LAS, OHX31LAP, OHX31LAA);
*/
    /* Calculating the overall periodontitis stage */
    array stages[*] periodontitis_stage_02-periodontitis_stage_31;

    /* Using the max function, but only for non-missing values */
    periodontitis_stage_max = max(of stages[*]);


   if peri_g2 = 1 then peri_stage= periodontitis_stage_max;
   else peri_stage=.;

    /* If all stages are missing for a person with periodontitis, set overall stage to missing */
    *if periodontitis_overall = "Yes" and missing(periodontitis_stage_max) then call missing(periodontitis_stage_max);

  

run;
proc freq data=periodontitis_stage_all_teeth;
 proc freq data=peri_all;
 table peri_g2 peri_stage periodontitis_stage_max ;
 run;

proc print data=periodontitis_stage_all_teeth (obs=40);
 where periodontitis_stage_31 ne .;
* var seqn OHX02LAD  OHX02LAS OHX02LAP OHX02LAA peri_t02 periodontitis_stage_02;
 *var  seqn LOA_DF_02 LOA_MF_02 LOA_DL_02 LOA_ML_02 peri_t02 periodontitis_stage_02;
  var  seqn LOA_DF_31 LOA_MF_31 LOA_DL_31 LOA_ML_31 peri_t31 periodontitis_stage_31;
 run;

proc print data=periodontitis_stage_all_teeth (obs=80);
 var periodontitis_stage_max periodontitis_stage_02-periodontitis_stage_15 periodontitis_stage_18-periodontitis_stage_31;
 run;

proc freq data=periodontitis_stage_all_teeth;
 table peri_t02 periodontitis_stage_02;
run;
/* Running proc freq to check the distribution of the periodontitis stage */
proc freq data=periodontitis_stage_all_teeth;
    where periodontitis_overall = "Yes"; /* Only considering those with periodontitis */
    tables periodontitis_stage_max;
run;

/************** Incorporating Stage 4 in perio stage variable **********************/
/* Defining formats for race and tooth status */
proc format;
    value race_fmt
        1 = 'Mexican American'
        2 = 'Other Hispanic'
        3 = 'Non-Hispanic White'
        4 = 'Non-Hispanic Black'
        6 = 'Non-Hispanic Asian'
        7 = 'Other Race - Including Multi-Racial';

    value tooth_status_fmt
        1 = 'Primary tooth (deciduous) present'
        2 = 'Permanent tooth present'
        3 = 'Dental implant'
        4 = 'Tooth not present'
        5 = 'Permanent dental root fragment present'
        9 = 'Could not assess'
        . = 'Missing';
run;
/**/
/*/* Calculating periodontitis stages including Stage 4 */*/
/*data periodontitis_stage_with_teeth;*/
/*    set periodontitis_stage_all_teeth;*/
/**/
/*    /* Count the number of missing teeth (code=4) */*/
/*    array teeth_status[32] OHX01TC OHX02TC OHX03TC OHX04TC OHX05TC OHX06TC OHX07TC OHX08TC */
/*                          OHX09TC OHX10TC OHX11TC OHX12TC OHX13TC OHX14TC OHX15TC OHX16TC */
/*                          OHX17TC OHX18TC OHX19TC OHX20TC OHX21TC OHX22TC OHX23TC OHX24TC */
/*                          OHX25TC OHX26TC OHX27TC OHX28TC OHX29TC OHX30TC OHX31TC OHX32TC;*/
/**/
/*    missing_teeth_count = 0;*/
/**/
/*    do i = 1 to dim(teeth_status);*/
/*        if teeth_status[i] = 4 then missing_teeth_count + 1;*/
/*    end;*/
/**/
/*    /* Calculate the number of remaining teeth */*/
/*    remaining_teeth = 32 - missing_teeth_count;*/
/**/
/*    /* Assign Stage 4 if remaining teeth are less than 20 */*/
/*    if remaining_teeth < 20 then periodontitis_stage_max = 4;*/
/*    else periodontitis_stage_max = max(of periodontitis_stage_02-periodontitis_stage_31);*/
/**/
/*run;*/
/**/
/*/* Running proc freq to check the distribution of the periodontitis stage */*/
/*proc freq data=periodontitis_stage_with_teeth;*/
/*    /* Applying the format to each OHX##TC variable individually */*/
/*    format OHX01TC OHX02TC OHX03TC OHX04TC OHX05TC OHX06TC OHX07TC OHX08TC */
/*           OHX09TC OHX10TC OHX11TC OHX12TC OHX13TC OHX14TC OHX15TC OHX16TC */
/*           OHX17TC OHX18TC OHX19TC OHX20TC OHX21TC OHX22TC OHX23TC OHX24TC */
/*           OHX25TC OHX26TC OHX27TC OHX28TC OHX29TC OHX30TC OHX31TC OHX32TC tooth_status_fmt.;*/
/**/
/*    /* Filtering to only include those with periodontitis */*/
/*    where periodontitis_overall = "Yes"; /* Only considering those with periodontitis */*/
/**/
/*    /* Creating a frequency table for the periodontitis stage */*/
/*    tables periodontitis_stage_max / norow nocol nopercent;*/
/*	tables remaining_teeth;*/
/*	tables missing_teeth_count;*/
/*run;*/
/**/;

/* Calculating periodontitis stages including Stage 4 without third molars */
data periodontitis_stage_with_teeth;
    set periodontitis_stage_all_teeth;

    /* Count the number of missing teeth (code=4) */
    array teeth_status[28] OHX02TC OHX03TC OHX04TC OHX05TC OHX06TC OHX07TC OHX08TC 
                          OHX09TC OHX10TC OHX11TC OHX12TC OHX13TC OHX14TC OHX15TC 
                          OHX18TC OHX19TC OHX20TC OHX21TC OHX22TC OHX23TC OHX24TC 
                          OHX25TC OHX26TC OHX27TC OHX28TC OHX29TC OHX30TC OHX31TC;

    missing_teeth_count = 0;

    do i = 1 to dim(teeth_status);
        if teeth_status[i] = 4 then missing_teeth_count + 1;
    end;

    /* Calculate the number of remaining teeth */
    remaining_teeth = 32 - missing_teeth_count;

    /* Assign Stage 4 if remaining teeth are less than 20 */
    if remaining_teeth < 20 then periodontitis_stage_max = 4;
    else periodontitis_stage_max = max(of periodontitis_stage_02-periodontitis_stage_31);

run;
/*****
LinHY version 
**********/;

data periodontitis_stage_with_teeth;
    set peri_all;

	if OHDDESTS=. or OHDDESTS=3 then denti=.;
	else if OHDDESTS=1 then denti=1;
	else denti=0;


    /* Count the number of missing teeth (code=4) */
    array teeth_status[28] OHX02TC OHX03TC OHX04TC OHX05TC OHX06TC OHX07TC OHX08TC 
                          OHX09TC OHX10TC OHX11TC OHX12TC OHX13TC OHX14TC OHX15TC 
                          OHX18TC OHX19TC OHX20TC OHX21TC OHX22TC OHX23TC OHX24TC 
                          OHX25TC OHX26TC OHX27TC OHX28TC OHX29TC OHX30TC OHX31TC;

    missing_teeth_count = 0;

    do i = 1 to dim(teeth_status);
        if teeth_status[i] = 4 then missing_teeth_count + 1;
    end;

	if denti=. then miss_teeth_ct=.;
	else miss_teeth_ct=missing_teeth_count;

    /* Calculate the number of remaining teeth */
    remaining_teeth = 32 -  miss_teeth_ct;

    /* Assign Stage 4 if remaining teeth are less than 20 */
    if remaining_teeth < 20 then periodontitis_stage_max = 4;
    else periodontitis_stage_max = max(of periodontitis_stage_02-periodontitis_stage_31);

	label 

OHDDESTS='Dentition Status, 1:Complete, 2:Partial, 3:Not Done'
denti='Dentition Status, 1:Complete, 0:Partial'
OHX02TC='Tooth Count: #2, 1:Primary tooth present, 2:Permanent tooth present, 3:Dental implant, 
           4: Tooth not present, 5: Permanent dental root fragment present, 9:Could not assess'
miss_teeth_ct='missing teeth count'
remaining_teeth='remaining teeth count'
	  ;

run;
proc freq data=periodontitis_stage_with_teeth;
 *table OHDDESTS denti;
 table miss_teeth_ct miss_teeth_ct remaining_teeth ;
 run;

proc print data=periodontitis_stage_with_teeth;
 where denti=1;
 var OHX02TC OHX03TC OHX04TC OHX05TC OHX06TC OHX07TC OHX08TC 
                          OHX09TC OHX10TC OHX11TC OHX12TC OHX13TC OHX14TC OHX15TC 
                          OHX18TC OHX19TC OHX20TC OHX21TC OHX22TC OHX23TC OHX24TC 
                          OHX25TC OHX26TC OHX27TC OHX28TC OHX29TC OHX30TC OHX31TC miss_teeth_ct;
						  run;



/* Running proc freq to check the distribution of the periodontitis stage */
proc freq data=periodontitis_stage_with_teeth;
    /* Applying the format to each OHX##TC variable individually */
    format OHX01TC OHX02TC OHX03TC OHX04TC OHX05TC OHX06TC OHX07TC OHX08TC 
           OHX09TC OHX10TC OHX11TC OHX12TC OHX13TC OHX14TC OHX15TC OHX16TC 
           OHX17TC OHX18TC OHX19TC OHX20TC OHX21TC OHX22TC OHX23TC OHX24TC 
           OHX25TC OHX26TC OHX27TC OHX28TC OHX29TC OHX30TC OHX31TC OHX32TC tooth_status_fmt.;

    /* Filtering to only include those with periodontitis */
    where periodontitis_overall = "Yes"; /* Only considering those with periodontitis */

    /* Creating a frequency table for the periodontitis stage */
    tables periodontitis_stage_max / norow nocol nopercent;
	tables remaining_teeth;
	tables missing_teeth_count;
run;


/************************ FREQUENCY TABLES ***********************************/

/* Adding demographics data */
data periodontitis_withdemo;
set periodontitis_stage_with_teeth;
merge permdata.demo_h;
by seqn;
run;

proc sort data = periodontitis_withdemo;
by RIAGENDR;
run;
/* Defining a format to label the sex variable */
proc format;
    value sex_fmt
        1 = 'Male'
        2 = 'Female';
run;

proc freq data=periodontitis_withdemo;
    /* Applying the format to RIAGENDR for both tables */
    format RIAGENDR sex_fmt.;
	
	where periodontitis_overall = "Yes";

    /* Creating a crosstab for periodontitis_overall by sex */
    tables RIAGENDR*periodontitis_overall / norow nocol nopercent;
    tables RIAGENDR*periodontitis_stage_max / norow nocol nopercent;

    /* Creating a crosstab for total_teeth_with_periodontitis by sex */
    tables RIAGENDR*total_teeth_with_periodontitis / norow nocol nopercent;
run;

/* Defining a format to label the race variable */
proc format;
    value race_fmt
        1 = 'Mexican American'
        2 = 'Other Hispanic'
        3 = 'Non-Hispanic White'
        4 = 'Non-Hispanic Black'
        6 = 'Non-Hispanic Asian'
        7 = 'Other Race - Including Multi-Racial';
run;

/* Sorting the data to ensure "Yes" comes first */
proc sort data=periodontitis_withdemo;
    by descending periodontitis_overall;
run;

proc freq data=periodontitis_withdemo order=data;
    /* Applying the format to RIDRETH3 for the race distribution */
    format RIDRETH3 race_fmt.;
	where periodontitis_overall = "Yes";

    /* Creating a crosstab for race by periodontitis status with row percentages */
    tables RIDRETH3*periodontitis_overall / norow nocol nopercent;
	tables RIDRETH3*periodontitis_stage_max / norow nocol nopercent;
run;

/* Outcome var stats */

proc format;
value csx_fmt
1=	'Salty'
2=	'Bitter'
3=	'Something else'
4=	'No Taste'	
5=	'Sour';
run;
	
data csx;
set periodontitis_withdemo;
merge permdata.csx_h;
by seqn;
run;

proc freq data=csx;
format CSXQUIPT CSXNAPT CSXQUIST CSXSLTST CSXNAST csx_fmt.;
tables CSXQUIPT CSXNAPT CSXQUIST CSXSLTST CSXNAST ; 
where periodontitis_overall = "Yes";
proc format;
    value csx_fmt
        1 = 'Salty'
        2 = 'Bitter'
        3 = 'Something else'
        4 = 'No Taste'  
        5 = 'Sour';
run;

data new_dataset;
    set csx;
	length disability_salty_tip $3 disability_salty_whole $3 
           disability_bitter_tip $3 disability_bitter_whole $3;

    /* Disability variables for salty taste */
    if CSXNAPT = 1 then disability_salty_tip = 'No'; /* Salty */
    else if CSXNAPT in (2, 3, 4, 5) then disability_salty_tip = 'Yes'; /* Other tastes */

    if CSXSLTST = 1 then disability_salty_whole = 'No'; /* Salty */
    else if CSXSLTST in (2, 3, 4, 5) then disability_salty_whole = 'Yes'; /* Other tastes */

    /* Disability variables for bitter taste */
    if CSXQUIPT = 2 then disability_bitter_tip = 'No'; /* Bitter */
    else if CSXQUIPT in (1, 3, 4, 5) then disability_bitter_tip = 'Yes'; /* Other tastes */

    if CSXQUIST = 2 then disability_bitter_whole = 'No'; /* Bitter */
    else if CSXQUIST in (1, 3, 4, 5) then disability_bitter_whole = 'Yes'; /* Other tastes */

 /* Disability variables in general */
    if disability_bitter_whole = 'Yes' or disability_bitter_tip = 'Yes' then disability_bitter = 'Yes'; /* Bitter */
    else if disability_bitter_whole = 'No' and disability_bitter_tip = 'No' then disability_bitter = 'No';

    if disability_salty_whole = 'Yes' or disability_salty_tip = 'Yes' then disability_salty = 'Yes'; /* Bitter */
    else if disability_salty_whole = 'No' and disability_salty_whole = 'No' then disability_salty = 'No';


run;


proc freq data=new_dataset;
tables disability_bitter disability_salty disability_salty_tip disability_salty_whole disability_bitter_tip disability_bitter_whole ; 
where periodontitis_overall = "Yes";

Proc freq data=new_dataset;
  Table disability_bitter_tip * disability_bitter_whole/ missing;
  Table disability_salty_tip * disability_salty_whole/ missing;
Run; 














/* Creating a descriptive table for salty disability (tip) */
proc freq data=new_dataset;
    /* Applying the format to sex, race, and other variables if necessary */
    format RIAGENDR sex_fmt. RIDRETH3 race_fmt.;
   
    /* Descriptive table for salty disability (tip) */
    tables disability_salty_tip*(periodontitis_overall RIAGENDR RIDAGEYR periodontitis_stage_max) / chisq;
run;

/* Creating a descriptive table for salty disability (tip) */
proc freq data=new_dataset;
    /* Applying the format to sex, race, and other categorical variables */
    format RIAGENDR sex_fmt. RIDRETH3 race_fmt.;
   
    /* Descriptive table for salty disability (tip) */
    tables disability_salty_tip*(periodontitis_overall RIAGENDR periodontitis_stage_max) / chisq;
run;

/* Calculating mean and standard deviation of age by periodontitis status */
proc means data=new_dataset mean std;
    class periodontitis_overall;
    var RIDAGEYR; /* Age variable */
    where not missing(disability_salty_tip); /* Include only relevant observations */
run;




/**************************** weighted sampling ////
/* Assign NHANES weights */
proc surveyfreq data=new_dataset;
    strata SDMVSTRA;  /* Stratification variable */
    cluster SDMVPSU;  /* Primary sampling unit */
    weight WTMEC2YR;  /* Sampling weight for MEC exam participants */
    
    /* Cross-tabulation for salty disability (tip) and predictors */
    tables disability_salty_tip*(periodontitis_overall RIAGENDR RIDRETH3 periodontitis_stage_max) / row col;
run;

/* Calculate weighted mean and SD for age by salty disability (tip) */
proc surveymeans data=new_dataset mean std;
    strata SDMVSTRA;  /* Stratification variable */
    cluster SDMVPSU;  /* Primary sampling unit */
    weight WTMEC2YR;  /* Sampling weight */
    class disability_salty_tip; /* Outcome variable */
    var RIDAGEYR; /* Age */
run;

/* Repeat the same for bitter disability */
proc surveyfreq data=new_dataset;
    strata SDMVSTRA;  /* Stratification variable */
    cluster SDMVPSU;  /* Primary sampling unit */
    weight WTMEC2YR;  /* Sampling weight */
    
    /* Cross-tabulation for bitter disability and predictors */
    tables disability_bitter*(periodontitis_overall RIAGENDR RIDRETH3 periodontitis_stage_max) / row col;
run;

/* Calculate weighted mean and SD for age by bitter disability */
proc surveymeans data=new_dataset mean std;
    strata SDMVSTRA;  /* Stratification variable */
    cluster SDMVPSU;  /* Primary sampling unit */
    weight WTMEC2YR;  /* Sampling weight */
    class disability_bitter; /* Outcome variable */
    var RIDAGEYR; /* Age */
run;


/************* Sample weighing - new outcome var *******************/

/* Creating new outcome variables for disability_salty and disability_bitter */
data new_outcome_dataset;
		length disability_salty $8 
           disability_bitter $8;
    set new_dataset;


    /* Define disability_salty as 'No' if both are No, otherwise 'Yes' */
    if disability_salty_tip = 'No' and disability_salty_whole = 'No' then disability_salty = 'No';
    else if disability_salty_tip = 'Yes' or disability_salty_whole = 'Yes' then disability_salty = 'Yes';

    /* Define disability_bitter with three levels: 'No', 'Any', 'Both' */
    if disability_bitter_tip = 'No' and disability_bitter_whole = 'No' then disability_bitter = 'No';
    else if disability_bitter_tip = 'Yes' and disability_bitter_whole = 'Yes' then disability_bitter = 'Both';
    else if disability_bitter_tip = 'Yes' or disability_bitter_whole = 'Yes' then disability_bitter = 'Any';
run;

/* Checking the distribution of the new outcome variables */
proc freq data=new_outcome_dataset;
    tables disability_salty disability_bitter;
run;


/* Weighted analysis for disability_salty */
proc surveyfreq data=new_outcome_dataset;
    strata SDMVSTRA;  /* Stratification variable */
    cluster SDMVPSU;  /* Primary sampling unit */
    weight WTMEC2YR;  /* Sampling weight for MEC exam participants */
    
    /* Crosstabulation for disability_salty with predictors */
    tables disability_salty*(periodontitis_overall RIAGENDR RIDRETH3 periodontitis_stage_max) / row chisq;
run;

/* Weighted analysis for disability_bitter */
proc surveyfreq data=new_outcome_dataset;
    strata SDMVSTRA;  /* Stratification variable */
    cluster SDMVPSU;  /* Primary sampling unit */
    weight WTMEC2YR;  /* Sampling weight for MEC exam participants */
    
    /* Crosstabulation for disability_bitter with predictors */
    tables disability_bitter*(periodontitis_overall RIAGENDR RIDRETH3 periodontitis_stage_max) / row chisq;
run;

/* Weighted means and standard deviation for age by disability_salty */
proc surveymeans data=new_outcome_dataset mean std;
    strata SDMVSTRA;  /* Stratification variable */
    cluster SDMVPSU;  /* Primary sampling unit */
    weight WTMEC2YR;  /* Sampling weight */
    class disability_salty; /* Outcome variable */
    var RIDAGEYR; /* Age */
run;

/* Weighted means and standard deviation for age by disability_bitter */
proc surveymeans data=new_outcome_dataset mean std;
    strata SDMVSTRA;  /* Stratification variable */
    cluster SDMVPSU;  /* Primary sampling unit */
    weight WTMEC2YR;  /* Sampling weight */
    class disability_bitter; /* Outcome variable */
    var RIDAGEYR; /* Age */
run;



/************* Sample weighing - with inclusion/exclusion *******************/


data new_outcome_dataset2;
    set new_outcome_dataset;

    /* Include participants with at least some data */
    if not missing(periodontitis_overall) or 
       not missing(disability_salty_tip) or 
       not missing(disability_salty_whole) or 
       not missing(disability_bitter_tip) or 
       not missing(disability_bitter_whole) then incl_yn = 1; /* Include */
    else incl_yn = 0; /* Exclude */
run;

proc freq data= new_outcome_dataset2;
tables periodontitis_overall disability_salty_tip disability_salty_whole disability_bitter_tip disability_bitter_whole incl_yn;
run; 


proc surveyfreq data=new_outcome_dataset2;
    strata SDMVSTRA;
    cluster SDMVPSU;
    weight WTMEC2YR;
    where incl_yn = 1; /* Include only eligible participants */
    tables disability_salty*(periodontitis_overall RIAGENDR RIDRETH3 periodontitis_stage_max) / row chisq;
run;

proc freq data=new_outcome_dataset2;
    tables incl_yn / missing;
run;

/*the numbers are changing somehwere because when this variable is made "perio overall" it does have 615 missing, but in our last proc freq, it doesnt have any - how is this happening*/
