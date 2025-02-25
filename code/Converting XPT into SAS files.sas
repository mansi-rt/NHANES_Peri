
/* Step 1: Assign a permanent library to the folder where you want to save the .sas7bdat files */
libname permdata 'T:\LinHY_project\NHANES\oral_health\data';

/* Step 2: Convert each XPT file and save it permanently in the "permdata" library */

/* Convert CSQ_H.XPT */
libname xptdata xport 'T:\LinHY_project\NHANES\oral_health\data\CSQ_H.XPT';
proc copy in=xptdata out=permdata;
run;

/* Convert CSX_H.XPT */
libname xptdata xport 'T:\LinHY_project\NHANES\oral_health\data\CSX_H.XPT';
proc copy in=xptdata out=permdata;
run;

/* Convert DEMO_G.XPT */
libname xptdata xport 'T:\LinHY_project\NHANES\oral_health\data\DEMO_G.XPT';
proc copy in=xptdata out=permdata;
run;

/* Convert DEMO_H.XPT */
libname xptdata xport 'T:\LinHY_project\NHANES\oral_health\data\DEMO_H.XPT';
proc copy in=xptdata out=permdata;
run;

/* Convert OHQ_G.XPT */
libname xptdata xport 'T:\LinHY_project\NHANES\oral_health\data\OHQ_G.XPT';
proc copy in=xptdata out=permdata;
run;

/* Convert OHQ_H.XPT */
libname xptdata xport 'T:\LinHY_project\NHANES\oral_health\data\OHQ_H.XPT';
proc copy in=xptdata out=permdata;
run;

/* Convert CSQ_G.XPT */
libname xptdata xport 'T:\LinHY_project\NHANES\oral_health\data\CSQ_G.XPT';
proc copy in=xptdata out=permdata;
run;

/* Convert OHXPER_H.XPT */
libname xptdata xport 'T:\LinHY_project\NHANES\oral_health\data\OHXPER_H.XPT';
proc copy in=xptdata out=permdata;
run;

/* Convert OHXDEN_H.XPT */
libname xptdata xport 'T:\LinHY_project\NHANES\oral_health\data\OHXDEN_H.XPT';
proc copy in=xptdata out=permdata;
run;

/* Convert BMX_H.XPT */
libname xptdata xport 'T:\LinHY_project\NHANES\oral_health\data\BMX_H.XPT';
proc copy in=xptdata out=permdata;
run;

/* Convert ALQ_H.XPT */
libname xptdata xport 'T:\LinHY_project\NHANES\oral_health\data\ALQ_H.XPT';
proc copy in=xptdata out=permdata;
run;

/* Convert DIQ_H.XPT */
libname xptdata xport 'T:\LinHY_project\NHANES\oral_health\data\DIQ_H.XPT';
proc copy in=xptdata out=permdata;
run;

/* Convert SMQ_H.XPT */
libname xptdata xport 'T:\LinHY_project\NHANES\oral_health\data\SMQ_H.XPT';
proc copy in=xptdata out=permdata;
run;

/* Convert RXQ_RX_H.XPT */
libname xptdata xport 'T:\LinHY_project\NHANES\oral_health\data\RXQ_RX_H.XPT';
proc copy in=xptdata out=permdata;
run;