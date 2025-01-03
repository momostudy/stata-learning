/************************************************************************/
/* x_ols.ado										*/
/*OLS ESTIMATION FOR X-SECTIONAL DATA WITH LOCATION-BASED DEPENDENCE	*/
/*for STATA 6.0										*/
/*				by	Jean-Pierre Dube					*/
/*					Northwestern University				*/
/*					July 10, 1999					*/
/*												*/
/*			reference:								*/
/*												*/
/*	Conley, Timothy G.[1996].  "Econometric Modelling of Cross		*/
/*	Sectional Dependence." Northwestern University Working Paper.	*/
/*												*/
/************************************************************************/
/************************************************************************/
/*To invoke this command type:							*/
/*   >>x_ols coordlist cutofflist depvar regressorlist, xreg() coord()	*/
/*												*/
/*	(1)If you want a constant in the regression, specify one of the	*/
/*	input variables as a 1. (ie. include it in list of regressors).	*/
/*												*/
/*	(2) You MUST specify the xreg() and coord() options.			*/
/*												*/
/*	(3)	xreg() denotes # regressors						*/
/*		coord()	denotes dimension of coordinates			*/
/*												*/
/*	(4) Your cutofflist must correspond to coordlist (same order)	*/
/*												*/
/*												*/
/*OUTPUT: all the standard `reg' procedure matrices will be in memory.	*/
/*	There will also be a matrix cov_dep, the corrected variance-	*/
/*	covariance matrix.								*/
/************************************************************************/


program define x_ols
	version 6.0
#delimit ;				/*sets `;' as end of line*/

/*FIRST I TAKE INFO. FROM COMMAND LINE AND ORGANIZE IT*/
local varlist	"req ex min(1)";	/*must specify at least one variable...
					   all must be existing in memory*/
local options	"xreg(int -1) COord(int -1)";
		/* # indep. var, dimension of location coordinates*/

parse "`*'";				/*separate options and variables*/

if `xreg'<1{;
	if `xreg'==-1{;
		di in red "option xreg() required!!!";
		exit 198};
	di in red "xreg(`xreg') is invalid";
	exit 198};	

if `coord'<1{;
	if `coord'==-1{;
		di in red "option coord() required!!!";
		exit 198};
	di in red "coord(`coord') is invalid";
	exit 198};	


/*Separate input variables:
	coordinates, cutoffs, dependent, regressors*/

parse "`varlist'", parse(" ");	

local a=1;
while `a'<=`coord'{;
	tempvar coord`a';
	gen `coord`a''=``a'';	/*get coordinates*/
local a=`a'+1};

local aa=1;
while `aa'<=`coord'{;
	tempvar cut`aa';
	gen `cut`aa''=``a'';	/*get cutoffs*/
	local a=`a'+1;
local aa=`aa'+1};

tempvar Y;
gen `Y'=``a'';			/*get dep variable*/
local depend : word `a' of `varlist';

local a=`a'+1;

local b=1;
while `b'<=`xreg'{;
	tempvar X`b';
	local ind`b' : word `a' of `varlist';
	gen `X`b''= ``a'';
	local a=`a'+1;
local b=`b'+1};			/*get indep var(s)...rest of list*/

/*NOW I RUN THE REGRESSION AND COMPUTE THE COV MATRIX*/

quietly{;			/*so that steps are not printed on screen*/

	/*(1) RUN REGRESSION*/
	tempname XX XX_N invXX invN;
	scalar `invN'=1/_N;
	if `xreg'==1 {;
		reg `Y' `X1', noconstant robust;
		mat accum `XX'=`X1',noconstant;
		mat `XX_N'=`XX'*`invN';
		mat `invXX'=inv(`XX_N')};	/* creates (X'X/N)^(-1)*/
	else{;
		reg `Y' `X1'-`X`xreg'', noconstant;
		mat accum `XX'=`X1'-`X`xreg'',noconstant;
		mat `XX_N'=`XX'*`invN';
		mat `invXX'=inv(`XX_N')};	/* creates (X'X/N)^(-1)*/
	predict epsilon,residuals;	/* OLS residuals*/

	/*(2) COMPUTE CORRECTED COVARIANCE MATRIX*/
	tempname XUUX XUUX1 XUUX2 XUUXt;
	tempvar XUUk;
	mat `XUUX'=J(`xreg',`xreg',0);
	gen `XUUk'=0;
	gen window=1;			/*initializes mat.s/var.s to be used*/
	local i=1;
	while `i'<=_N{;			/*loop through all observations*/
		local d=1;
		replace window=1;
		while `d'<=`coord'{;	/*loop through coordinates*/
			if `i'==1{;
				gen dis`d'=0};
			replace dis`d'=abs(`coord`d''-`coord`d''[`i']);
			replace window=window*(1-dis`d'/`cut`d'');
			replace window=0 if dis`d'>=`cut`d'';
		local d=`d'+1};				/*create window*/
		capture mat drop `XUUX2';
		local k=1;
		while `k'<=`xreg'{;
			replace `XUUk'=`X`k''[`i']*epsilon*epsilon[`i']*window;
			mat vecaccum `XUUX1'=`XUUk' `X1'-`X`xreg'', noconstant;
			mat `XUUX2'=nullmat(`XUUX2') \ `XUUX1';
		local k=`k'+1};
		mat `XUUXt'=`XUUX2'';
		mat `XUUX1'=`XUUX2'+`XUUXt';
		scalar fix=.5;		/*to correct for double-counting*/
		mat `XUUX1'=`XUUX1'*fix;
		mat `XUUX'=`XUUX'+`XUUX1';
	local i=`i'+1};
	mat `XUUX'=`XUUX'*`invN';

};					/*end quietly command*/

tempname V VV;
mat `V'=`invXX'*`XUUX';
mat `VV'=`V'*`invXX';

matrix cov_dep=`VV'*`invN';		/*corrected covariance matrix*/


/*THIS PART CREATES AND PRINTS THE OUTPUT TABLE IN STATA*/
local z=1;
local v=`a';
di _newline(2) _skip(5)
"Results for Cross Sectional OLS corrected for Spatial Dependence";
di _newline	_col(35)	" number of observations=  "  _result(1);
di " Dependent Variable= " "`depend'";
di _newline
"variable" _col(13) "ols estimates" _col(29) "White s.e." _col(42) 
	"s.e. corrected for spatial dependence";
di 
"--------" _col(13) "-------------" _col(29) "----------" _col(42) 
	"-------------------------------------";

while `z'<=`xreg'{;
	tempvar se1`z' se2`z';
	local beta`z'=_b[`X`z''];
	local se`z'=_se[`X`z''];
	gen `se1`z''=cov_dep[`z',`z'];
	gen `se2`z''=sqrt(`se1`z'');
	di "`ind`z''" _col(13)  `beta`z''  _col(29)  `se`z'' _col(42) `se2`z'';
local z=`z'+1};

end;
exit;


