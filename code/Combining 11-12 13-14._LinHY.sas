/* Assign a permanent library to the folder with .sas7bdat files */
libname permdata 'T:\LinHY_project\NHANES\oral_health\data';

data permdata.demographics;
set permdata.demo_g permdata.demo_h;
run;

data permdata.oral_health;
set permdata.ohq_g permdata.ohq_h;
run;

data permdata.chemical_senses;
set permdata.csq_g permdata.csq_h;
run;

data one;
set permdata.demographics;
keep seqn ridageyr;
set permdata.chemical_senses;
keep seqn CSQ202 CSQ120C;
merge permdata.oral_health;
by seqn;
keep seqn ohq030;
run;

data two;
set one;
if ridageyr > 40;
run;

data two2;
set permdata.demo_h;
if ridageyr > 40;
run;

