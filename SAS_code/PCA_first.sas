/*final Project*/


%let root=/folders/myshortcuts/D_DRIVE/biostat_2019_spring/Bios_669;
%LET job=Final Project;
%LET onyen=zying;
%LET dat=&root./&job/SAS_dataset;
ods graphics / noborder;
ods noproctitle;
option mprint;


OPTIONS NODATE MERGENOBY=WARN VARINITCHK=WARN ;
*FOOTNOTE "&job._&onyen run on &sysdate at &systime";
libname stock "&dat.";


ods pdf file="&root./&job/PCA_output.pdf" style=PEARL;

/*Step 1:
	Part 1.1*/
/*prepare the data add all full names and sector to the eigenvetor according to stock codes*/
proc sql;
create table pre_data as
	select a.*,b.Name as fullname, b.sector as sector
	from  stock.eigenvector as a full JOIN stock.name_list as b
	ON  A.STOCK_NAME=B.IDENTIFIER; 
quit;


/*	Part 1.2*/
/*make frequency table about the different sectors in S&P index*/
title "The count and percentage of sectors in SP 500 Index";
proc report data = pre_data nowd missing ;
	column sector n pctn;
	define sector/group id order = freq descending;
 	define n / format =8. "N" ;
	define pctn / "Percentage" format =percent7.1;
	
	/*add the background color to the frequency table*/
	 compute pctn;
     if pctn >0.1 then call define(_row_,"style","style={background=orange}");
     endcomp;
run; 

title "The daily return from 2009 to 2019";
proc sgplot data=stock.sp500_add_return;
	series X=Date Y=daily_return;
	yaxis label="daily return";
run;

/*Step 2:
	Part 2.1*/
/*Display the eigenvalue by plots */


data eigenvalue;
	set stock.eigenvalue(rename =(_0=eigenvalue ));
	retain cums;
	drop var1;
	rank=var1+1;	/*the rank of eigenvalue can be obtained by Var1*/
	if _n_=1 then cums=eigenvalue;
	else cums=cums+eigenvalue;	/*calculate the cumulative eigenvalues*/
	;
run;
/*get the percentage and cumulative percentage of eigenvalue*/
Proc SQL noprint;                                                       
  Create Table for_graph AS                                     
    Select *,(cums/SUM(eigenvalue)*100) AS cumPercent format=6.5 ,
    		(eigenvalue/SUM(eigenvalue)*100) AS Percent format=6.5
  	From eigenvalue    
  	order by rank;   

	SELECT  min(rank) into : num_ev_seventy_per 
		from for_graph
		where cumPercent le 71 and cumPercent ge 70;
Quit;

/*get the eigenvalue and their percentage for first 5 PCs*/
title "Eigenvalues and percentages of first 5 eigenvalues";
Proc report data=for_graph(where=(rank<=5));
	column rank  eigenvalue  percent  cumpercent;
	define rank/ "Rank" order;
 	define eigenvalue / format =6.2 ;
	define percent / "Percentage" ;
	define cumpercent / "Cumulative Percentage" ;
run;                                                                                          


/*Plot the percentage and cumulative percentage of all eigenvalues*/

title "The percentage and cumulative percentage of eigenvalues";
proc sgplot data=for_graph;
	series X=RANK Y=Percent;
	series X=RANK Y=cumPercent;

	refline 70 /axis=y lineattrs=(color=red pattern=2);
	refline &num_ev_seventy_per/axis=x lineattrs=(color=red pattern=2);
	inset ("X =" = "&num_ev_seventy_per")/position=topleft;
	inset ("Y=" = "70")/position=right;
	xaxis grid label="Eigenvalue Rank";
	yaxis grid ; 
run;

/*histogram of eigenvalues*/
title "Histogram of the percentage of eigenvalues";
proc sgplot data=for_graph;
	histogram Percent/binwidth=0.5;
	xaxis grid label="Eigenvalue Percentage";
	yaxis grid ; 
run;

title "Summary Table of the percentage eigenvalues";
proc means data=for_graph;
	var Percent;
run;

/*Step 2: Present the first eigenvector: the one stands for the market effect
	Part 2.2*/
proc sql; 
	create table PC0 as 
	select stock_name,fullname,sector,_0
	from pre_data
	order by _0 desc;
quit;

data PC0;
	set PC0;
	obs=_n_;
run;

/*plot all Coefficient Values in the first Principal Component by its rank*/
title "Coefficient Values in the first Principal Component ";
proc sgplot data=PC0;
	scatter X=obs Y=_0/group=sector markerattrs=(symbol=circlefilled );
	xaxis label="rank of coefficients";
	yaxis label="Coefficients";
run;

/*plot histogram of Coefficient Values in the first Principal Component*/
title "histogram of the coefficients in the first Principal Component";
proc sgplot data=PC0;
	histogram _0;
	xaxis label="Coefficients in the first PC";
	yaxis label="Percentage";
run;

/*get correlation of the daily return between PC1 and SP500*/
title "Correlation of the daily return between PC1 and SP500";
proc corr data=  stock.pc1_sp500;
	var SP500 PC1;
run;


/*Step 3:
	Part 3.1*/

%include "&root./&job/SAS_code/codebook_PCA.sas ";

%PCA_plot(ith_PC=2); /*Display the second eigenvector */
%PCA_plot(ith_PC=3); /*Display the third eigenvector */

ods pdf close;