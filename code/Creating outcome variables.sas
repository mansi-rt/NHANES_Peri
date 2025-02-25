/*Assign a permanent library to the folder where you want to save the .sas7bdat files */
libname permdata 'T:\LinHY_project\NHANES\oral_health\data';


data demo;
set permdata.demo_h;
run;

data ohxper;
set permdata.ohxper_h;
run;
/**** Experimenting and cretaing the periodontitis variable just for tooth 2M *************/
/* Creating a new dataset with the periodontitis variable */
data periodontitis_2m;
    set permdata.ohxper_h;

    /* Checking the condition for periodontitis based on attachment loss and probing depth */
    if 
        (OHX02LAD >= 1 or OHX02LAS >= 1 or OHX02LAP >= 1 or OHX02LAA >= 1) /* Attachment loss on DF, MF, DL, or ML surfaces */
        and
        (OHX02PCD >= 4 or OHX02PCS >= 4 or OHX02PCP >= 4 or OHX02PCA >= 4) /* Probing depth on DF, MF, DL, or ML surfaces */
    then periodontitis_2m = "Yes";
	    
    else periodontitis_2m = "No";

run;

/* Running proc freq to check the frequency of the new periodontitis variable */
proc freq data=periodontitis_2m;
    tables periodontitis_2m;
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
%macro create_periodontitis(tooth, df_al, mf_al, dl_al, ml_al, df_pd, mf_pd, dl_pd, ml_pd);

    /* Creating a periodontitis variable for the specific tooth 
	Adding the missing variable value */
    if (&df_al >= 1 or &mf_al >= 1 or &dl_al >= 1 or &ml_al >= 1) /* Attachment loss on DF, MF, DL, or ML surfaces */
        and
       (&df_pd >= 4 or &mf_pd >= 4 or &dl_pd >= 4 or &ml_pd >= 4) /* Probing depth on DF, MF, DL, or ML surfaces */
    then periodontitis_&tooth = 1;
	else if (&df_al = . & &mf_al = . & &dl_al = . & &ml_al = .) /* Attachment loss on DF, MF, DL, & ML surfaces */
        and
       (&df_pd = . & &mf_pd = . & &dl_pd = . & &ml_pd = .) /* Probing depth on DF, MF, DL, & ML surfaces */
    then periodontitis_&tooth = .;
    else periodontitis_&tooth = 0;

%mend;

data merging_per_den;
    merge permdata.ohxper_h (in=a) permdata.ohxden_h (in=b);
    by SEQN;
    if a; /* Keeps only observations that are in ohxper_h */
run;

/* Creating a dataset to calculate periodontitis for all relevant teeth */
data periodontitis_all_teeth;
    set merging_per_den;

    /* Running the macro for each tooth, specifying the relevant variables for each */
    %create_periodontitis(02, OHX02LAD, OHX02LAS, OHX02LAP, OHX02LAA, OHX02PCD, OHX02PCS, OHX02PCP, OHX02PCA);
    %create_periodontitis(03, OHX03LAD, OHX03LAS, OHX03LAP, OHX03LAA, OHX03PCD, OHX03PCS, OHX03PCP, OHX03PCA);
    %create_periodontitis(04, OHX04LAD, OHX04LAS, OHX04LAP, OHX04LAA, OHX04PCD, OHX04PCS, OHX04PCP, OHX04PCA);
    %create_periodontitis(05, OHX05LAD, OHX05LAS, OHX05LAP, OHX05LAA, OHX05PCD, OHX05PCS, OHX05PCP, OHX05PCA);
    %create_periodontitis(06, OHX06LAD, OHX06LAS, OHX06LAP, OHX06LAA, OHX06PCD, OHX06PCS, OHX06PCP, OHX06PCA);
    %create_periodontitis(07, OHX07LAD, OHX07LAS, OHX07LAP, OHX07LAA, OHX07PCD, OHX07PCS, OHX07PCP, OHX07PCA);
    %create_periodontitis(08, OHX08LAD, OHX08LAS, OHX08LAP, OHX08LAA, OHX08PCD, OHX08PCS, OHX08PCP, OHX08PCA);
    %create_periodontitis(09, OHX09LAD, OHX09LAS, OHX09LAP, OHX09LAA, OHX09PCD, OHX09PCS, OHX09PCP, OHX09PCA);
    %create_periodontitis(10, OHX10LAD, OHX10LAS, OHX10LAP, OHX10LAA, OHX10PCD, OHX10PCS, OHX10PCP, OHX10PCA);
    %create_periodontitis(11, OHX11LAD, OHX11LAS, OHX11LAP, OHX11LAA, OHX11PCD, OHX11PCS, OHX11PCP, OHX11PCA);
    %create_periodontitis(12, OHX12LAD, OHX12LAS, OHX12LAP, OHX12LAA, OHX12PCD, OHX12PCS, OHX12PCP, OHX12PCA);
    %create_periodontitis(13, OHX13LAD, OHX13LAS, OHX13LAP, OHX13LAA, OHX13PCD, OHX13PCS, OHX13PCP, OHX13PCA);
    %create_periodontitis(14, OHX14LAD, OHX14LAS, OHX14LAP, OHX14LAA, OHX14PCD, OHX14PCS, OHX14PCP, OHX14PCA);
    %create_periodontitis(15, OHX15LAD, OHX15LAS, OHX15LAP, OHX15LAA, OHX15PCD, OHX15PCS, OHX15PCP, OHX15PCA);

    %create_periodontitis(18, OHX18LAD, OHX18LAS, OHX18LAP, OHX18LAA, OHX18PCD, OHX18PCS, OHX18PCP, OHX18PCA);
    %create_periodontitis(19, OHX19LAD, OHX19LAS, OHX19LAP, OHX19LAA, OHX19PCD, OHX19PCS, OHX19PCP, OHX19PCA);
    %create_periodontitis(20, OHX20LAD, OHX20LAS, OHX20LAP, OHX20LAA, OHX20PCD, OHX20PCS, OHX20PCP, OHX20PCA);
    %create_periodontitis(21, OHX21LAD, OHX21LAS, OHX21LAP, OHX21LAA, OHX21PCD, OHX21PCS, OHX21PCP, OHX21PCA);
    %create_periodontitis(22, OHX22LAD, OHX22LAS, OHX22LAP, OHX22LAA, OHX22PCD, OHX22PCS, OHX22PCP, OHX22PCA);
    %create_periodontitis(23, OHX23LAD, OHX23LAS, OHX23LAP, OHX23LAA, OHX23PCD, OHX23PCS, OHX23PCP, OHX23PCA);
    %create_periodontitis(24, OHX24LAD, OHX24LAS, OHX24LAP, OHX24LAA, OHX24PCD, OHX24PCS, OHX24PCP, OHX24PCA);
    %create_periodontitis(25, OHX25LAD, OHX25LAS, OHX25LAP, OHX25LAA, OHX25PCD, OHX25PCS, OHX25PCP, OHX25PCA);
    %create_periodontitis(26, OHX26LAD, OHX26LAS, OHX26LAP, OHX26LAA, OHX26PCD, OHX26PCS, OHX26PCP, OHX26PCA);
    %create_periodontitis(27, OHX27LAD, OHX27LAS, OHX27LAP, OHX27LAA, OHX27PCD, OHX27PCS, OHX27PCP, OHX27PCA);
    %create_periodontitis(28, OHX28LAD, OHX28LAS, OHX28LAP, OHX28LAA, OHX28PCD, OHX28PCS, OHX28PCP, OHX28PCA);
    %create_periodontitis(29, OHX29LAD, OHX29LAS, OHX29LAP, OHX29LAA, OHX29PCD, OHX29PCS, OHX29PCP, OHX29PCA);
    %create_periodontitis(30, OHX30LAD, OHX30LAS, OHX30LAP, OHX30LAA, OHX30PCD, OHX30PCS, OHX30PCP, OHX30PCA);
    %create_periodontitis(31, OHX31LAD, OHX31LAS, OHX31LAP, OHX31LAA, OHX31PCD, OHX31PCS, OHX31PCP, OHX31PCA);

    /* Summing across all teeth to check if at least two teeth meet the periodontitis criteria 
	total_teeth_with_periodontitis = 
    periodontitis_02 + periodontitis_03 + periodontitis_04 + periodontitis_05 + 
    periodontitis_06 + periodontitis_07 + periodontitis_08 + periodontitis_09 + 
    periodontitis_10 + periodontitis_11 + periodontitis_12 + periodontitis_13 + 
    periodontitis_14 + periodontitis_15 + periodontitis_18 + periodontitis_19 + 
    periodontitis_20 + periodontitis_21 + periodontitis_22 + periodontitis_23 + 
    periodontitis_24 + periodontitis_25 + periodontitis_26 + periodontitis_27 + 
    periodontitis_28 + periodontitis_29 + periodontitis_30 + periodontitis_31;
	We decided to use sum for this instead of +
	*/

	/* Summing across all teeth to check if at least two teeth meet the periodontitis criteria */
	total_teeth_with_periodontitis = 
    sum(periodontitis_02, periodontitis_03, periodontitis_04, periodontitis_05, 
    periodontitis_06, periodontitis_07, periodontitis_08, periodontitis_09, 
    periodontitis_10, periodontitis_11, periodontitis_12, periodontitis_13, 
    periodontitis_14, periodontitis_15, periodontitis_18, periodontitis_19, 
    periodontitis_20, periodontitis_21, periodontitis_22, periodontitis_23, 
    periodontitis_24, periodontitis_25, periodontitis_26, periodontitis_27, 
    periodontitis_28, periodontitis_29, periodontitis_30, periodontitis_31);
	

/* Checking if periodontitis is present based on at least two teeth having periodontitis 
	Adding the missing variable value */
    if total_teeth_with_periodontitis >= 2 then periodontitis_overall = "Yes";
    else if missing(total_teeth_with_periodontitis) then call missing(periodontitis_overall);
    else periodontitis_overall = "No";
run;

/* Running proc freq to check the distribution of the overall periodontitis variable */
proc freq data=periodontitis_all_teeth;
    tables periodontitis_overall;
	tables total_teeth_with_periodontitis;
run;

/* Macro for assigning periodontitis stage for individual teeth */
%macro assign_periodontitis_stage(tooth, df_al, mf_al, dl_al, ml_al);

    /* Initializing the stage variable for the specific tooth */
    if periodontitis_&tooth = 1 then do;

        /* Stage 1: Attachment loss of 1-2 mm */
        if (&df_al >= 1 and &df_al <= 2) or 
           (&mf_al >= 1 and &mf_al <= 2) or 
           (&dl_al >= 1 and &dl_al <= 2) or 
           (&ml_al >= 1 and &ml_al <= 2) then periodontitis_stage_&tooth = 1;

        /* Stage 2: Attachment loss of 3-4 mm */
        else if (&df_al >= 3 and &df_al <= 4) or 
                (&mf_al >= 3 and &mf_al <= 4) or 
                (&dl_al >= 3 and &dl_al <= 4) or 
                (&ml_al >= 3 and &ml_al <= 4) then periodontitis_stage_&tooth = 2;

        /* Stage 3: Attachment loss of 5 mm or more */
        else if (&df_al >= 5) or 
                (&mf_al >= 5) or 
                (&dl_al >= 5) or 
                (&ml_al >= 5) then periodontitis_stage_&tooth = 3;

        else call missing(periodontitis_stage_&tooth); /* If no stage is applicable */
    end;
    else call missing(periodontitis_stage_&tooth); /* Not assessed if no periodontitis */
%mend;

/* Creating a dataset for periodontitis stage */
data periodontitis_stage_all_teeth;
    set periodontitis_all_teeth;

    /* Applying the stage macro for each tooth */
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

    /* Calculating the overall periodontitis stage */
    array stages[*] periodontitis_stage_02-periodontitis_stage_31;

    /* Using the max function, but only for non-missing values */
    periodontitis_stage_max = max(of stages[*]);

    /* If all stages are missing for a person with periodontitis, set overall stage to missing */
    if periodontitis_overall = "Yes" and missing(periodontitis_stage_max) then call missing(periodontitis_stage_max);

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