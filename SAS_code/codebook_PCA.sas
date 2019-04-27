/*The macro is to produce graphs for the ith Principal Component*/

%macro PCA_plot(ith_PC=); 

/*Because the coding for the ith Principal Component is i-1 as the variable name*/
/*I use PCrank as the variable name in the original SAS dataset */
%let PCrank=%eval(&ith_PC -1);

/*This notation is for title in the plot*/
%if &ith_PC=2 %then %let notation=nd;
%else %if &ith_PC=3 %then %let notation=rd;
%else %let notation=th;

proc sql noprint; 
	create table PC as 
	select stock_name,fullname,sector,_&PCrank.
		from pre_data
		order by _&PCrank. desc;
quit;



data PC;

	set PC;
	obs=_n_;
run;

proc sql noprint;
	select stock_name into : positive_5_stocks separated by " "
		from PC
		where obs<=5
		;
	select stock_name into : negative_5_stocks separated by " "
		from PC
		where obs>=500;
		
quit;

%put &=positive_5_stocks &=negative_5_stocks;




title "Coefficient Values in the &ith_PC.&notation. Principal Component ";
proc sgplot data=PC;
	scatter X=obs Y=_&PCrank./group=sector markerattrs=(symbol=circlefilled );
	xaxis label="rank of coefficients";
	yaxis label="Coefficients";
run;

title "Histogram of Coefficient Values in the &ith_PC.&notation. Principal Component ";
proc sgplot data=PC;
	histogram _&PCrank.;
	xaxis label="Value of coefficients";
	yaxis label="Percentage";
run;


title "5 largest positive Coefficient Values in the &ith_PC.&notation. Principal Component ";
proc sgplot data=PC;
	scatter X=obs Y=_&PCrank./group=sector datalabel=fullname
							MARKERATTRS= (symbol=StarFilled  size=1 CM) DATASKIN=SHEEN;
	xaxis label="rank of coefficients";
	yaxis label="Coefficients";
	where obs<=5;
run;

title "5 smallest negative Coefficient Values in the &ith_PC.&notation. Principal Component";
proc sgplot data=PC;
	scatter X=obs Y=_&PCrank./group=sector datalabel=fullname
							MARKERATTRS= (symbol=StarFilled  size=1 CM) DATASKIN=SHEEN;
	xaxis label="rank of coefficients";
	yaxis label="Coefficients";
	where obs>=500;
run;



title "The return from the start date for the stocks with 5 largest coefficients";
proc sgplot data=stock.return_from_start;
	%do i=1 %to 5;
		%let var=%scan(&positive_5_stocks,&i);
			series Y=&var. X=date;
		%end;
	Yaxis label="Return";
run;

title "The return from the start date for the stocks with 5 smallest negative coefficients";
proc sgplot data=stock.return_from_start;
	%do i=1 %to 5;
		%let var=%scan(&negative_5_stocks,&i);
			series Y=&var. X=date;
		%end;
	Yaxis label="Return";
run;
%mend;

option mprint;




		
