capture program drop reg2hdfespatial 
*! Thiemo Fetzer 4/2015: WRAPPER PROGRAM TO ESTIMATE SPATIAL HAC FOR OLS REGRESSION MODELS WITH HIGH DIMENSIONAL FIXED EFFECTS
*! The function uses the reg2hdfe procedure to demean the data by the time- and panel-variable you specify
*! This ensures that you do not compute large variance covariance matrices to compute
*! Spatial HAC errors for coefficients you do not actually care about.
*! Updates available on http://www.trfetzer.com
*! Please email me in case you find any bugs or have suggestions for improvement.
*! Please cite: Fetzer, T. (2014) "Can Workfare Programs Moderate Violence? Evidence from India", STICERD Working Paper.
*! Also credit Sol Hsiang.
*! Hsiang, S. M. (2010). Temperatures and cyclones strongly associated with economic production in the Caribbean and Central America. PNAS, 107(35), 15367–72.
*! The Use of the function is simple
*!  reg2hdfespatial Yvar Xvarlist, lat(latvar) lon(lonvar) Timevar(tvar) Panelvar(pvar) [DISTcutoff(#) LAGcutoff(#) bartlett DISPlay star dropvar demean altfetime(varname) altfepanel(varname)]
*!
*!
*! You can also specify other fixed effects:
*! reg2hdfespatial Yvar     Xvarlist   ,timevar(year) panelvar(district) altfetime(regionyear)  lat(y) lon(x) distcutoff(500) lagcutoff(20) 
*!
*! here I specify the time variable as the year, but I demean the data first
*! by region x year fixed effects.
*! This turns out to matter as the OLS_Spatial_HAC for the autocorrelation correction which you may want
*! to be done at a level different from the level at which you have the time fixed effects specified.


*! V2 UPDATE 2/20 :	ADEED WEIGHTS TO REGRESSION.
*! V3 UPDATE 3/20 :	ADEED IV REGRESSION.
/*-----------------------------------------------------------------------------

 Syntax:
 
 reg2hdfespatial Yvar Xvarlist (variable = iv_varlist), lat(latvar) lon(lonvar) Timevar(tvar) Panelvar(pvar) [weights] [DISTcutoff(#) LAGcutoff(#) bartlett DISPlay star dropvar demean altfetime(varname) altfepanel(varname)]

 -----------------------------------------------------------------------------*/

program reg2hdfespatial, eclass byable(recall)
preserve
//version 9.2
version 11
syntax [anything(name=0)] [if] [in] ///
				[aweight fweight pweight iweight/], ///
				lat(varname numeric) lon(varname numeric) ///
				Timevar(varname numeric) Panelvar(varname numeric)  ///
				[LAGcutoff(integer 0) DISTcutoff(real 1) ///
				DISPlay star bartlett dropvar altfetime(varname) altfepanel(varname) ]
				
/*--------PARSING COMMANDS AND SETUP-------*/

if "`if'"~="" {
	qui keep `if' 
}



capture drop touse 
marksample touse				// indicator for inclusion in the sample
gen touse = `touse'

* generate a weight of 1 for all observations if weights are not provided

tempvar wvar
if "`weight'" !="" {
	local wtexp `"[`weight'=`exp']"'
	qui gen double `wvar'=`exp'
}
else {
	qui gen long `wvar'=1
	loc weight = "aweight"
}


*keep if touse
//parsing variables

local n 0
local ivflag 0 
local varlist
while `n'==0 {
	gettoken vchar 0 : 0 ,parse(" (,")
	if "`vchar'"=="(" {
		local ivflag = 1
	}

	if `ivflag' == 1 & "`exog'"==""{
		gettoken endog 0 : 0 ,parse("=")  //instrumented variables
		gettoken equal_s 0 : 0 ,parse("=")
		gettoken exog 0 : 0 ,parse(")")  //instruments
	}

	if "`vchar'"!="(" & "`vchar'"!=")" {
		local varlist "`varlist' `vchar'"
	}
	if "`vchar'"==""{
		local n = `n' + 1
	}

}

loc Y = word("`varlist'",1)		
loc listing "`varlist' `endog' `exog'" 

loc X ""
scalar k_variables = 0

//make sure that Y, exog, and endog are not included in the other_var list
foreach i of loc listing {
	if "`i'" != "`Y'" & strpos("`endog'", "`i'")==0 & strpos("`exog'", "`i'")==0 {
		loc X "`X' `i'"
		scalar k_variables = k_variables + 1 // # indep variables
	}
}
foreach i of loc endog {
		scalar k_variables = k_variables + 1 // # indep variables
}

local wdir `c(pwd)'

tmpdir returns r(tmpdir):
local tdir  `r(tmpdir)'

markout `touse' `Y' `X' `exog' `endog'
di "keeping non-missing observations"
keep if `touse'
**clear temp folder of existing files
qui cd "`tdir'"
local tempfiles : dir . files "*.dta"
foreach f in `tempfiles' {
	erase `f'
}

quietly {

	if("`altfepanel'" !="" & "`altfetime'" !="") {
	di "CASE 1"
	hdfe `Y' `X' `exog' `endog' [`weight'=`wvar'],  a(`panelvar' `timevar') keepvars(`altfepanel' `altfetime' `panelvar' `timevar' `lat' `lon' ) clear
	}
	if("`altfepanel'" =="" & "`altfetime'" !="") {
	di "CASE 2"
	hdfe `Y' `X' `exog' `endog' [`weight'=`wvar'],  a(`panelvar' `timevar') keepvars(`altfetime' `panelvar' `timevar' `lat' `lon' ) clear
	}
	if("`altfepanel'" !="" & "`altfetime'" =="") {
	di "CASE 3" 
	hdfe `Y' `X' `exog' `endog' [`weight'=`wvar'],  a(`panelvar' `timevar') keepvars(`altfepanel' `panelvar' `timevar' `lat' `lon' ) clear
	loc iteratevarlist "`Y' `X' `exog' `endog' `lat' `lon' `panelvar' `wvar'"
	}
	if("`altfepanel'" =="" & "`altfetime'" =="") {
	di "CASE 4"
	hdfe `Y' `X' `exog' `endog' [`weight'=`wvar'],  a(`panelvar' `timevar') keepvars(`panelvar' `timevar' `lat' `lon' ) clear
}

loc droppedvar
	//ommitting collinear variables
	reg2hdfe `Y' `X' `exog' `endog' `lat' `lon',  id1(`panelvar') id2(`timevar') 
	foreach var of varlist `X' {
		lincom `var'	
		if `r(se)' != 0 {
			loc newVarList "`newVarList' `var'"
			scalar k_variables = k_variables + 1
		}
		else {
			loc droppedvar "`droppedvar' `var'"
		}
	}
	
	loc XX "`newVarList'"

}
if "`droppedvar'"!="" {
	di "variables omitted due to collinearity: `droppedvar'"
}
if `ivflag' == 1 {
	ols_spatial_HAC `Y' `XX' ( `endog' = `exog' ) [`weight'=`wvar'], lat(`lat') lon(`lon') timevar(`timevar') panelvar(`panelvar') lagcutoff(`lagcutoff') distcutoff(`distcutoff') `bartlett' `display' 
}
else if `ivflag' == 0 {
	ols_spatial_HAC `Y' `XX' [`weight'=`wvar'], lat(`lat') lon(`lon') timevar(`timevar') panelvar(`panelvar') lagcutoff(`lagcutoff') distcutoff(`distcutoff') `bartlett' `display' 
}
cd "`wdir'"
restore
end


