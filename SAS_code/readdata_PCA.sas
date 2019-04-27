/*Name: readdata_PCA*/
/*Aim: read some csv files from Python into SAS data file */

%let root=/folders/myshortcuts/D_DRIVE/biostat_2019_spring/Bios_669;
%LET job=Final Project;
%LET onyen=zying;
%LET dat=&root./&job/result_from_python;
%let outdir=&root./&job/SAS_dataset;

OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
FOOTNOTE "&job._&onyen run on &sysdate at &systime";
libname stock "&outdir.";


**read data from csv;
/*The eigenvalue of PCA*/
proc import datafile="&dat./eigenvalue.csv" out=stock.eigenvalue
           dbms=csv replace;   
           GUESSINGROWS=3000;
run;    

/*The eigenvector of PCA*/
proc import datafile="&dat./eigenvector.csv" out=stock.eigenvector 
           dbms=csv replace;         
           GUESSINGROWS=3000;
run; 

/*The daily return of first PC and SP500*/
proc import datafile="&dat./PC1_sp500.csv" out=stock.PC1_sp500
           dbms=csv replace;   
           GUESSINGROWS=3000;
run; 

/*The daily return(percentage) for all stocks: the adjusted price - one day before  adjusted price/one day before  adjusted price  */
proc import datafile="&dat./return_matrix.csv" out=stock.return_daily
           dbms=csv replace;  
           GUESSINGROWS=3000;
run;    


/*The  return (percentage)  for all stocks: the adjusted price - start date adjusted price/ start date adjusted price  */
proc import datafile="&dat./return_matrix_from_start.csv" out=stock.return_from_start
           dbms=csv replace; 
           GUESSINGROWS=3000;
run;    

/*The close price of SP 500  */

proc import datafile="&dat./sp500.csv" out=stock.sp500
           dbms=csv replace; 
           GUESSINGROWS=3000;
run; 

/*The all namelists of stocks SP 500 up to 2019/04/19 and the section of all stocks*/
proc import datafile="&dat./namelist.xlsx" out=stock.name_list
           dbms=xlsx replace;  
run; 


/*********************************************************************************
*********************************************************************************
***********************************************************************************
For the SP500 data, I will calculate the daily return and the return using the start date*/

data stock.sp500_add_return;
	set stock.sp500;
	keep close daily_return return_from_start_date date;
	retain first_date_adjclose;
	daily_return=(adj_close-lag(adj_close))/lag(adj_close)*100;
	if _n_=1 then first_date_adjclose=adj_close; 
	return_from_start_date=(adj_close-first_date_adjclose)/first_date_adjclose*100;
run;


/************************************************************/
/*Add the full name as the label in the dataset: return_matrix_from_start */
proc sql noprint;
  select catx('=',identifier,quote(trim(name))) 
    into :labels separated by ' '
    from stock.name_list
    where identifier ^="BRK.B";
  ;
quit;

%put &=labels;

/*change label for return_from_start dataset*/
proc datasets nolist lib=stock ;
  modify return_from_start;
  label &labels;
  run;
quit;

data stock.return_from_start;
	SET stock.return_from_start;
	label BRK_B ="Berkshire Hathaway Inc. Class B";
run;
	