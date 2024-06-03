*********************************************************************************************************************************
*********************************************************************************************************************************
*     						ACREG: Program for computing corrected standard errors for Arbitrary Clustering		   				*
*		   		 					 Copyright: F. Colella, R. Lalive, S.O. Sakalli, M. Thoenig								    *
*																																*
*									Beta Version, please do not circulate - This Version: December 2020							*    
*																																*
* 									Before using this program, please read to our companion papers								*
*																																*
*  			"Acreg: arbirtrary correlation regression", F. Colella, R. Lalive, S.O. Sakalli, M. Thoenig (2020)					*
*																																*
*  	"Inference with Arbitrary Clustering", F. Colella, R. Lalive, S.O. Sakalli, M. Thoenig, (2019) IZA Discussion Papaer		*
*																																*
*********************************************************************************************************************************
*********************************************************************************************************************************

capt program drop acreg

*! Version December 2020  (1.1.0)
*! ACREG: Arbitrary Correlation Regression
*! Authors: F. Colella, R. Lalive, S.O. Sakalli, M. Thoenig


program acreg, eclass
	version 12
	if replay() {
	di "No Variables" 
	exit
	}
	else {
syntax [anything(name=0)]  [if] [in] [fweight pweight] [,  dist_mat(varlist) links_mat(varlist) ///
	weights(varlist) cluster(varlist)  ///
	latitude(varname) longitude(varname) id(varname) time(varname) ///
	LAGcutoff(integer -1) DISTcutoff(real -1) LAGDISTcutoff(integer -1) ///
	bartlett partial correction network spatial storeweights storedistances small ak0 ///
	pfe1(varname) pfe2(varname) hac correctr2 nbclust(integer -1) dropsingletons ]
	
	tempname b V weightsmat iddd_var
	
	local current_dir `c(pwd)'
	
			local n 0

		gettoken depvar1 0 : 0, parse(" ,[") match(paren)
		PEnd `depvar1'
		if `s(stop)' { 
			error 198 
		}
		while `s(stop)'==0 { 
			if "`paren'"=="(" {
				local n = `n' + 1
				if `n'>1 { 
capture noi error 198
di in red `"syntax is "(all instrumented variables = instrument variables)""'
exit 198
				}
				gettoken p depvar1 : depvar1, parse(" =")
				while "`p'"!="=" {
					if "`p'"=="" {
capture noi error 198 
di in red `"syntax is "(all instrumented variables = instrument variables)""'
di in red `"the equal sign "=" is required"'
exit 198 
					}
					local end1 `end1' `p'
					gettoken p depvar1 : depvar1, parse(" =")
				}
				local temp_ct  : word count `end1'
				if `temp_ct' > 0 {
	//				tsunab end1 : `end1'
					prog_fv_unab `end1' 
					local end1 `r(ts_varlist)'
				}
* Allow for empty instrument list
				local temp_ct  : word count `depvar1'
				if `temp_ct' > 0 {
	//				tsunab ivv1 : `depvar1'
					prog_fv_unab `depvar1'
					local ivv1 `r(ts_varlist)'
				}
			}
			else {
				local exog1 `exog1' `depvar1'
			}
			gettoken depvar1 0 : 0, parse(" ,[") match(paren)
			PEnd `depvar1'
		}
		local 0 `"`depvar1' `0'"'

	//	tsunab exog1 : `exog1'
		prog_fv_unab `exog1' 
		local exog1 `r(ts_varlist)'
		tokenize `exog1'
		local depvar1 "`1'"
		local 1 " " 
		local exog1 `*'
	
	capture drop touse
	marksample touse
	
}	


/*
*** CONSIDER THE POSSIBILITY TO USE XTSET: do we need FE?
xtset
local iddd = r(panelvar)
di "`iddd'"
*/

* drop repeated variables for each fo the the four groups  	
if "`exog1'"=="" {
}
else {
	local dupvars : list dups exog1	
}
if "`dupvars'"=="" {
}
else {
	local exog1 = subinstr("`exog1'","`dupvars' ","",1)
}

if "`depvar1'"=="" {
}
else {
	local dupvars : list dups depvar1
}
if "`dupvars'"=="" {
}
else {
	local depvar1 = subinstr("`depvar1'","`dupvars' ","",1)
}

if "`end1'"=="" {
}
else {
	local dupvars : list dups end1
}
if "`dupvars'"=="" {
}
else {
	local end1 = subinstr("`end1'","`dupvars' ","",1)
}

if "`ivv1'"=="" {
}
else {
	local dupvars : list dups ivv1
}
if "`dupvars'"=="" {
}
else {
	local ivv1 = subinstr("`ivv1'","`dupvars' ","",1)
}

* check for double inputs
	local allvars `exog1' `depvar1' `end1' `ivv1'
	local dupvars : list dups allvars
	verify "`dupvars'"=="", msg("Error: there are repeated variables: <`dupvars'>")
	

* check  other variables are non string
	local othervars `dist_mat' `links_mat' `weights' `cluster' `latitude' `longitude' 
	check_number `othervars'
	
* check for missing values 
	check_missing `othervars'
	
* check lat and lon are between -180 and 180
	check_lat_lon `latitude' `longitude'

* check links mat is made by 1 and 0
	check_links `links_mat'
	
* count number of factor variables
	prog_count_factor_variables  `depvar1' `exog1' `ivv1'
	mata: factor_variables = st_numscalar("factor_variables")
	
* check for ranktest installed
	capture which ranktest
	if (_rc==111) {
		disp as error  "please install raktest package by typing " in gr "ssc install ranktest"
		 disp as error  "OR install all required packages by typing " ///
		 in gr "acregpackcheck " 
		 disp as error  "and run acreg again"
		exit 498
	 }
	

	
if (`nbclust' < 0){
	local nbclust = 100
}
else {
	local nbclust = `nbclust'
}


******
***create signals for cutoffs
if (`distcutoff' < 0){
	local distcutoff_yn = 0
	local distcutoff = 0
}
else {
	local distcutoff_yn = 1
}


if (`lagcutoff' < 0){
	local lagcutoff_yn = 0
	local lagcutoff = 0
}
else {
	local lagcutoff_yn = 1
}

if (`lagdistcutoff' < 0){
	local lagdistcutoff_yn = 0
	local lagdistcutoff = 0
}
else {
	local lagdistcutoff_yn = 1
}

if ("`time'" == ""){
	local time_yn = 0
}
else {
	local time_yn = 1
}






if ("`id'" == ""){
	if (`time_yn' == 0){
		capt drop `iddd_var'
		tempvar iddd_var
		gen `iddd_var' = _n
		local id `iddd_var'
		if (`lagcutoff_yn' == 1){
			disp as error "Lagcutoff requires Id and Time to be specified"
			exit 498
		}
		if (`lagdistcutoff_yn' == 1){
			disp as error "Lagdistcutoff requires Id and Time to be specified"
			exit 498
		}
		if ("`hac'" == ""){
		}
		else {
			disp as error "Hac option requires Id and Time to be specified"
			exit 498
		}
	}
	else {
		disp as error "ID is required if Time dimension is specified"
		exit 498
	}
}
else {
	if (`time_yn' == 0){
		disp as error "Time dimesion is required if id is specified"
		exit 498
	}
	else {
	//	xtset `id' `time'
		if ("`hac'" == ""){
			if (`lagcutoff_yn' == 0){
				*local lagcutoff=10000000000 
				local lagcutoff=0
			}
			if (`lagdistcutoff_yn' == 0){
				*local lagdistcutoff=10000000000 
				local lagdistcutoff=0
			}
		}
		else {
			if (`lagcutoff_yn' == 0){
				disp as error "Lagcutoff required with the HAC option"
				exit 498 
			}
		}
	}
}

	
		
if ("`time'" == ""){
	qui sort `id' 
}
else { 
	qui sort `id' `time'
}	


if ("`cluster'" == ""){
	if ("`weights'" == ""){
		if ("`network'" == ""){
			if ("`spatial'" == ""){
//1) NO CLUSTERING
				if ("`links_mat'" == ""){
				}
				else {
					disp as error "Matrix of links requires Network Option to be specified"
					exit 498
				}
				if ("`dist_mat'" == ""){
				}
				else {
					disp as error "Matrix of Distances requires Network or Spatial Option"
					exit 498
				}
				if ("`latitude'" == ""){
				}
				else {
					disp as error "Latitude and Longitude require Spatial Option to be specified"
					exit 498
				}
				if ("`longitude'" == ""){
				}
				else {
					disp as error "Latitude and Longitude require Spatial Option to be specified"
					exit 498
				}
				if (`distcutoff_yn' == 1){
					disp as error "Distance cutoff requires Network or Spatial Option"
					exit 498
				}
				if (`lagdistcutoff_yn' == 1){
					disp as error "Lag Distance cutoff requires Network or Spatial Option"
					exit 498
				}
				if ("`storedistances'" == "") {
				}
				else {
				disp as error "Distances can be stored only with Network or Spatial Option"
				exit 498
				}
				if (`lagcutoff_yn' == 1){
					di in gr "TEMPORAL CORRECTION"
				}
				else {	
				di in gr "HETEROSKEDASTICITY ROBUST STANDARD ERRORS"
				}
				if ("`hac'" == ""){
					di in gr "No HAC Correction"
				}
				else {
					di in gr "HAC Correction "
				}
			}
			else {
//2) SPATIAL
				di in gr "SPATIAL CORRECTION"
				if ("`links_mat'" == ""){
				}
				else {
					disp as error "Matrix of Links may not be specified with the Spatial Option"
					exit 498
				}
				if ("`dist_mat'" == ""){
					if ("`latitude'" == ""){
						disp as error "Latitude and Longitude are required with the Spatial Option if Distance Matrix is not specified"
						exit 498
					}
					if ("`longitude'" == ""){
						disp as error "Latitude and Longitude are required with the Spatial Option if Distance Matrix is not specified"
						exit 498
					}
				}
				else {
					if ("`storedistances'" == "") {
					}
					else {
						disp as error "Distances can not be stored if they are given as input"
						exit 498
					}
					if ("`latitude'" == ""){
					}
					else {
						disp as error "Latitude may not be specified with the Spatial Option if Distance Matrix is specified"
						exit 498
					}
					if ("`longitude'" == ""){
					}
					else {
						disp as error "Longitude may not be specified with the Spatial Option  if Distance Matrix is specified"
						exit 498
					}
				}
				if (`distcutoff_yn' == 0){
					disp as error " Distance cutoff is required with the Spatial Option. Distcutoff must be a nonnegative real number"
					exit 498
				}
				di in gr "DistCutoff: " in ye "`distcutoff'"
				di in gr "LagCutoff:  " in ye "`lagcutoff'"
			//	di in gr "LagDistCutoff:  " in ye "`lagdistcutoff'"
				if ("`hac'" == ""){
					di in gr "No HAC Correction"
				}
				else {
				di in gr "HAC Correction"
		*			if ("`lagdistcutoff_yn'" == "0"){
		*			disp as error "Lag Distance cutoff required with HAC Option if Spatial is specified"
		*			exit 498
		*			}
				}
			}
		}
		else {
			if ("`spatial'" == ""){
//3) NETWORK
				di in gr  "NETWORK CORRECTION"
				if ("`latitude'" == ""){
				}
				else {
					disp as error "Latitude may not be specified with the Network Option"
					exit 498
				}
				if ("`longitude'" == ""){
				}
				else {
					disp as error "Longitude may not be specified with the Network Option"
					exit 498
				}
				if ("`dist_mat'" == ""){
					if ("`links_mat'" == ""){
						disp as error "Please specify the Links Matrix or the Distance Matrix when the Network Option is specified"
						exit 498
					}
					else {
						if (`distcutoff_yn' == 0){
							disp  "WARNING: Distance cutoff not Specified, only first degree links will be considered"
							local distcutoff=1
						}
					}
				}
				else {
					if ("`links_mat'" == ""){
						if (`distcutoff_yn' == 0){
							disp as error "Distance cutoff is required with the Network Option when Distance Matrix is specified. Distcutoff must be a nonnegative real number"
							exit 498
						}
					}
					else {
						disp as error "Distance Matrix may not be specified with the Network Option if Links Matrix is specified"
						exit 498
					}
					if ("`storedistances'" == "") {
					}
					else {
						disp as error "Distances can not be stored if they are given as input"
						exit 498
					}
				}
				di in gr "DistCutoff: " in ye "`distcutoff'"
				di in gr "LagCutoff:  " in ye "`lagcutoff'"
		//		di in gr "LagDistCutoff:  " in ye "`lagdistcutoff'"
				if ("`hac'" == ""){
					di in gr "No HAC Correction"
				}
				else {
					di in gr "HAC Correction "
		*			if ("`lagdistcutoff_yn'" == "0"){
		*			disp as error "Lag Distance cutoff required with HAC Option if Network is specified"
		*			exit 498
		*			}
				}	
			}
			else {
				disp as error "Only one option between network and spatial is allowed"
				exit 498 
			}
		}
	}
	else {
		if ("`spatial'" == "spatial"){
			disp as error "Spatial option with Weighting Matrix is not allowed"
			exit 498 
		}
		if ("`network'" == "network"){
			disp as error "Network option with Weighting Matrix is not allowed"
			exit 498 
		}
//4) WEIGHTS
		di in gr  "Correction using the Weighting Matrix  provided"
		if ("`time'" == ""){
		}
		else {
			disp as error "Panel Dimension not allowed with the Weighting Matrix""
			exit 498
		}
		if ("`latitude'" == ""){
		}
		else {
			disp as error "Latitude may not be specified with the Weighting Matrix"
			exit 498
		}
		if ("`longitude'" == ""){
		}
		else {
			disp as error "Longitude may not be specified with the Weighting Matrix"
			exit 498
		}
		if ("`links_mat'" == ""){
		}
		else {
			disp as error "Matrix of Links may not be specified with the Weighting Matrix"
			exit 498
		}
		if ("`dist_mat'" == ""){
		}
		else {
			disp as error "Distance Matrix may not be specified with the Weighting Matrix"
			exit 498
		}
		if (`distcutoff_yn' == 1){
			disp as error "Distcutoff may not be specified with the Weighting Matrix"
			exit 498
		}
		if (`lagcutoff_yn' == 1){
			disp as error "Lagcutoff may not be specified with the Weighting Matrix"
			exit 498
		}
		if ("`lagdistcutoff'" == ""){
			disp as error "Lagdistcutoff may not be specified with the Weighting Matrix"
			exit 498
		}
		if ("`hac'" == ""){
			di in gr "No HAC Correction"
		}
		else {
			di in gr "HAC Correction "
		}
	}
}
else {
//5) MULTIWAY CLUSTERING
	di in gr  "MULTIWAY CLUSTERING CORRECTION"
	di in gr "Cluster variable(s): " in ye "`cluster'"
	if ("`time'" == ""){
	}
	else {
		disp as error "Panel Settings not allowed with multiway clustering"
		exit 498
	}
	if ("`weights'" != ""){
		disp as error "Weights option with multiway clustering is not allowed"
		exit 498 
	}
	if ("`spatial'" == "spatial"){
		disp as error "Spatial option with multiway clustering is not allowed"
		exit 498 
	}
	if ("`network'" == "network"){
		disp as error "Network option with multiway clustering is not allowed"
		exit 498 
	}
	if ("`latitude'" == ""){
	}
	else {
		disp as error "Latitude may not be specified with multiway clustering"
		exit 498
	}
	if ("`longitude'" == ""){
	}
	else {
		disp as error "Longitude may not be specified with multiway clustering"
		exit 498
	}
	if ("`links_mat'" == ""){
	}
	else {
		disp as error "Matrix of Links may not be specified with multiway clustering"
		exit 498
	}
	if ("`dist_mat'" == ""){
	}
	else {
		disp as error "Distance Matrix may not be specified with multiway clustering"
		exit 498
	}
		if (`distcutoff_yn' == 1){
			disp as error "Distcutoff may not be specified with multiway clustering"
			exit 498
		}
		if ("`lagdistcutoff'" == ""){
			disp as error "Lagdistcutoff may not be specified with multiway clustering"
			exit 498
		}
		if ("`hac'" == ""){
			di in gr "No HAC Correction"
		}
		else {
			di in gr "HAC Correction"
		}
}

	if ("`small'" == ""){
		}
		else {
		di in gr "Small Sample Correction"
		}
	if ("`ak0'" == ""){
		}
		else {
		di in gr "ak0 SS Correction - Conservative SEs"
		}
	if ("`time'" == ""){
		qui sort `id' 
	}
	else { 
	qui sort `id' `time'
	}
*




if ("`correctr2'" == ""){
	scalar correctr2_yn = 0
} 
else {
	scalar correctr2_yn = 1

}

mata: correctr2_yn_s = st_numscalar("correctr2_yn")






********************************************************************************************


if ("`pfe1'"!=""){

preserve

 capture which hdfe 
 if (_rc==111) {
 disp as error  "please install hdfe command by typing " in gr "ssc install hdfe"
 disp as error  "OR install all required packages by typing " ///
 in gr "acregpackcheck " 
 disp as error  "and run acreg again"
 capt drop iddd_var
 exit 498
 }
 
 prog_fv_partial `depvar1' `end1' `exog1' `ivv1'
 
	if ("`pfe2'"!=""){
	di in gr "Absorbed FE:" in ye " `pfe1' " in gr "and" in ye " `pfe2'"
	local fe_1 "`pfe1'"
	local fe_2 "`pfe2'"
	}
	else {
	di in gr "Absorbed FE:" in ye " `pfe1' "
	local fe_1 "`pfe1'"
	local fe_2 "fake_fe2"
	tempvar  fake_fe2
	capt drop fake_fe2
	gen fake_fe2=0
	}

	
if ("`correctr2'" == ""){
} 
else {
	capture which ivreg2
	if (_rc==111) {
		disp as error  "please install ivreg2 command by typing " in gr "ssc install ivreg2"
		disp as error  "OR install all required packages by typing " ///
		in gr "acregpackcheck " 
		disp as error  "and run acreg again"
		capt drop iddd_var
		capt drop fake_fe2
		exit 498
	 }
*	preserve	
		capt cd "`current_dir'"
		
	if "`weight'" == "" {	
		if ("`pfe2'"==""){
			acreg_r2partial  `exog1' i.`pfe1' `if' `in' ,  depvar(`depvar1')  end(`end1') iv(`ivv1')
		}
		else {
			acreg_r2partial  `exog1' i.`pfe1' i.`pfe2' `if' `in' ,  depvar(`depvar1')  end(`end1') iv(`ivv1')
		}
	}
	else {
		if ("`pfe2'"==""){
			acreg_r2partial  `exog1' i.`pfe1'  `if' `in'  [`weight'`exp'],  depvar(`depvar1')  end(`end1') iv(`ivv1') 
		}
		else {
			acreg_r2partial  `exog1' i.`pfe1' i.`pfe2' `if' `in'  [`weight'`exp'],  depvar(`depvar1')  end(`end1') iv(`ivv1') 
		}
	}
*	restore	
}

mata: correctr2_yn_s = st_numscalar("correctr2_yn")

if "`dropsingletons'" == "" {
if "`weight'" == "" {
qui hdfe `depvar1' `end1' `exog1' `ivv1' `if' `in' ,  keepsingletons absorb(`fe_1' `fe_2') generate(po_) 
}
else {
qui hdfe `depvar1' `end1' `exog1' `ivv1' `if' `in' [`weight'`exp'] ,  keepsingletons  absorb(`fe_1' `fe_2') generate(po_) 
}
}
else {
qui reg `depvar1' `end1' `exog1' `ivv1' `if' `in' [`weight'`exp']
qui count if e(sample)==1
local count1 =  r(N) 
bys `fe_1':gen NN=_N
qui drop if NN==1
drop NN
if "`weight'" == "" {
qui hdfe `depvar1' `end1' `exog1' `ivv1' `if' `in' ,   absorb(`fe_1' `fe_2') generate(po_) 
}
else {
qui hdfe `depvar1' `end1' `exog1' `ivv1' `if' `in' [`weight'`exp'] ,   absorb(`fe_1' `fe_2') generate(po_) 
}
qui sum po_`depvar1'
local count2 =  r(N) 
if `count2'==`count1' {
di in ye "No singleton observations"
}
else {
local differe = `count1' - `count2'
di in ye "             `differe' singleton observations dropped"
}
}


local count_var = 1
local temp_countvars  : word count `depvar1'
	if `temp_countvars'>0 {
	tokenize `depvar1'
	while  `count_var' <= `temp_countvars' {
	local depvar2  `depvar2' po_``count_var''
	local count_var=`count_var'+1
	}
	}
	
local count_var = 1
local temp_countvars  : word count `end1'
	if `temp_countvars'>0 {
	tokenize `end1'
	while  `count_var' <= `temp_countvars' {
	local end2 `end2' po_``count_var''
	local count_var=`count_var'+1
	}
	}
	
local count_var = 1
local temp_countvars  : word count `exog1'
	if `temp_countvars'>0 {
	tokenize `exog1'
	while  `count_var' <= `temp_countvars' {
	local exog2  `exog2' po_``count_var''
	local count_var=`count_var'+1
	}
	}
	
local count_var = 1
local temp_countvars  : word count `ivv1'
	if `temp_countvars'>0 {
	tokenize `ivv1'
	while  `count_var' <= `temp_countvars' {
	local ivv2 `ivv2' po_``count_var''
	local count_var=`count_var'+1
	}
	}	


************************************************************
*** THIS WILL BE NEEDED TO IMPLEMENT THE TESTS ***

* Create group variable
//tempvar group
//qui makegps2, id1(`fe_1') id2(`fe_2') groupid(`group')

* Calculate Degrees of Freedom	
//qui count
//local N = r(N)
//local k : word count `end1' `exog1' `ivv1' //Check whether here I need also the instruments or not
//sort `fe_1'
//qui count if `id'!=`id'[_n-1]
//local G1 = r(N)
//sort `fe_2'
//qui count if `time'!=`time'[_n-1]
//local G2 = r(N)
//sort `group'
//qui count if `group'!=`group'[_n-1]
//local M = r(N)
//local kk = `k' + `G1' + `G2' - `M'
//local dof = `N' - `kk'	
//local G = `G2'-1
************************************************************
	
	
	drop `depvar1' `end1' `exog1' `ivv1'

	foreach var in `depvar2' `end2' `exog2' `ivv2' {
	local var2 = subinstr("`var'", "po_", "", .)
	rename `var' `var2'
	}
	

	
	capt cd "`current_dir'"
	
if "`weight'" == "" {
	acreg_core  `exog1' ,  depvar(`depvar1')  end(`end1') iv(`ivv1') ///
	dist_mat(`dist_mat') links_mat(`links_mat') weights(`weights') ///
	latitude(`latitude') longitude(`longitude') id(`id') time(`time')  ///
	lag(`lagcutoff') dist(`distcutoff') lagdist(`lagdistcutoff') ///
	cluster(`cluster') `hac' nbclust(`nbclust') ///
	`bartlett' `partial' `correction' `network' `spatial' `storeweights' `storedistances' `small' `ak0'
}
else {
	acreg_core  `exog1'  [`weight'`exp'],  depvar(`depvar1')  end(`end1') iv(`ivv1') ///
	dist_mat(`dist_mat') links_mat(`links_mat') weights(`weights') ///
	latitude(`latitude') longitude(`longitude') id(`id') time(`time')  ///
	lag(`lagcutoff') dist(`distcutoff') lagdist(`lagdistcutoff') ///
	cluster(`cluster') `hac' nbclust(`nbclust') ///
	`bartlett' `partial' `correction' `network' `spatial' `storeweights' `storedistances' `small' `ak0'
}

restore
}
else {
	if ("`pfe2'"!=""){
	disp as error "pfe2 requires pfe1." in ye " Please, specify pfe1 instead of pfe2 if you want to partial out only one fixed effect."
	exit 498
	}
}


mata {
if (correctr2_yn_s==0) {
RSSr2 =0
TSScr2 =0
TSSur2 =0
r2r2 =0
r2ur2 =0
}
st_numscalar("r(RSSr2)", RSSr2)
st_numscalar("r(TSScr2)", TSScr2)
st_numscalar("r(TSSur2)", TSSur2)
st_numscalar("r(r2r2)", r2r2)
st_numscalar("r(r2ur2)", r2ur2)
}


if ("`pfe1'"!=""){


if ("`correctr2'" == ""){

***output
di in gr _col(55) "Number of obs = " in ye %8.0f e(N)
*di in gr _c _col(55) "F(" %3.0f e(Fdf1) "," %6.0f e(Fdf2) ") = "
*		if e(F) < 99999 {
*di in ye %8.2f e(F)
*		}
*		else {
*di in ye %8.2e e(F)
*		}
*di in gr _col(55) "Prob > F      = " in ye %8.4f e(Fp)
di in gr "Total (centered) SS     = " in ye %12.0g e(tss) _continue
di in gr _col(55) "Centered R2   = " in ye %8.4f e(r2)
di in gr "Total (uncentered) SS   = " in ye %12.0g e(tssu) _continue
di in gr _col(55) "Uncentered R2 = " in ye %8.4f e(r2u)
di in gr "Residual SS             = " in ye %12.0g e(rss) // _continue
*di in gr _col(55) "Root MSE      = " in ye %8.4g e(rmse)
di

ereturn display

di in gr "nb: total SS, model and R2s are after partialling out." 
di in gr "To get the corrected ones use the option correctr2"

} 


else {

scalar 	MSSc = TSScr2 - RSSr2
scalar 	MSSu = TSSur2 - RSSr2
		
ereturn scalar rss=r(RSSr2)
ereturn scalar tss=r(TSScr2)
ereturn scalar tssu=r(TSSur2)
ereturn scalar r2=r(r2r2)
ereturn scalar r2u=r(r2ur2)
ereturn scalar mss=MSSc
ereturn scalar mssu=MSSu

***output
di in gr _col(55) "Number of obs = " in ye %8.0f e(N)
di in gr "Total (centered) SS     = " in ye %12.0g e(tss) _continue
di in gr _col(55) "Centered R2   = " in ye %8.4f e(r2)
di in gr "Total (uncentered) SS   = " in ye %12.0g e(tssu) _continue
di in gr _col(55) "Uncentered R2 = " in ye %8.4f e(r2u)
di in gr "Residual SS             = " in ye %12.0g e(rss) // _continue
*di in gr _col(55) "Root MSE      = " in ye %8.4g e(rmse)
di	
ereturn display
}


}
else {
preserve 

di in gr "No Absorbed FEs"

if "`weight'" == "" {
acreg_core  `exog1' `if' `in',  depvar(`depvar1') end(`end1') iv(`ivv1') ///
 dist_mat(`dist_mat') links_mat(`links_mat') weights(`weights') ///
	latitude(`latitude') longitude(`longitude') id(`id') time(`time')  ///
	lag(`lagcutoff') dist(`distcutoff') lagdist(`lagdistcutoff') ///
	cluster(`cluster')  `hac' nbclust(`nbclust') ///
	`bartlett' `partial' `correction' `network' `spatial' `storeweights' `storedistances' `small' `ak0'
}
else {
acreg_core  `exog1' `if' `in' [`weight'`exp'],  depvar(`depvar1') end(`end1') iv(`ivv1') ///
 dist_mat(`dist_mat') links_mat(`links_mat') weights(`weights') ///
	latitude(`latitude') longitude(`longitude') id(`id') time(`time')  ///
	lag(`lagcutoff') dist(`distcutoff') lagdist(`lagdistcutoff') ///
	cluster(`cluster')  `hac' nbclust(`nbclust') ///
	`bartlett' `partial' `correction' `network' `spatial' `storeweights' `storedistances' `small' `ak0'
}




***output
di in gr _col(55) "Number of obs = " in ye %8.0f e(N)
di in gr "Total (centered) SS     = " in ye %12.0g e(tss) _continue
di in gr _col(55) "Centered R2   = " in ye %8.4f e(r2)
di in gr "Total (uncentered) SS   = " in ye %12.0g e(tssu) _continue
di in gr _col(55) "Uncentered R2 = " in ye %8.4f e(r2u)
di in gr "Residual SS             = " in ye %12.0g e(rss) // _continue
*di in gr _col(55) "Root MSE      = " in ye %8.4g e(rmse)
di
ereturn display

restore
}

ereturn repost , esample(`touse')

********************************************************************************************

mata: st_numscalar("nofullrankXX", nofullrankXX)
mata: st_numscalar("nofullrankXZZZZX", nofullrankXZZZZX)

if nofullrankXX == 1 {
di in red "Warning: X'X matrix not of full rank. Some variables might be omitted."
di in red "Beta Coefficients and Standard Errors should be interpreted with caution."
}
if nofullrankXZZZZX == 1 {
di in red "Warning: X'PzX matrix not of full rank. Some variables might be omitted."
di in red "Beta Coefficients and Standard Errors should be interpreted with caution."
}

capt scalar drop nofullrankXX
capt scalar drop nofullrankXZZZZX
capt scalar drop factor_variables
capt scalar drop widstat
capt scalar drop hac_signal
capt scalar drop lagdistcutoff
capt scalar drop distcutoff
capt scalar drop lagcutoff 
capt scalar drop ntsq
capt scalar drop ntsize
capt scalar drop correctr2_yn

capt scalar drop MSSu
capt scalar drop MSSc
capt scalar drop r2ur2
capt scalar drop r2r2
capt scalar drop TSScr2
capt scalar drop TSSur2
capt scalar drop RSSr2
capt scalar drop sumweigh

capt drop `depvar2'
capt drop `end2' 
capt drop `exog2'
capt drop `ivv2'

capt drop fake_fe2
capt drop iddd_var

end
*
*******************************************************************************
*******************************************************************************
*				  **************** SUBROUTINES***************
*******************************************************************************
*******************************************************************************
*
capt program drop acreg_core
program acreg_core, eclass
	version 12	
	syntax   [anything(name=regs)]  [if] [in]  [pweight fweight] [, depvar(string)  end(string) iv(string) ///
	dist_mat(varlist) links_mat(varlist) weights(varlist) ///
	latitude(varname) longitude(varname) id(varname) time(varname) ///
	LAGcutoff(integer 0) DISTcutoff(real 1) LAGDISTcutoff(integer 0) ///
	cluster(varlist) hac nbclust(integer -1) ///
	bartlett partial correction network spatial storeweights storedistances small ak0 ]

		tempname b V weightsmat AVCVb_fs

if ("`nbclust'" < "0"){
	local N_clust = 100
}
else {
	local N_clust = `nbclust'
}
	
*subrutines	
*qui do acreg/acreg_no_correction.do 
*qui do acreg/acreg_netw_dist_no_bartlett.do 
*qui do acreg/acreg_netw_dist_bartlett.do 
*qui do acreg/acreg_netw_links_no_bartlett.do
*qui do acreg/acreg_netw_links_bartlett.do
*qui do acreg/acreg_spat_dist_bartlett.do
*qui do acreg/acreg_spat_dist_no_bartlett.do
*qui do acreg/acreg_spat_ll_bartlett.do
*qui do acreg/acreg_spat_ll_no_bartlett.do
*qui do acreg/acreg_weig.do
*qui do acreg/acreg_cluster.do
*qui do acreg/nwacRanktest.ado
*qui do acreg/acreg_ranktest.do

*-------------------------------------------------------
*A) Run reg to check for missing values and etc 

if "`weight'" == "" {
qui reg `depvar' `regs' `end' `iv'  `if' `in'
local wtexp = "" 
 }
 else {
qui reg `depvar' `regs' `end' `iv'  `if' `in' [`weight'`exp']
local wtexp = "[`weight'`exp']"
}

qui keep if e(sample)==1	



* check if links_mat or dist_mat is dimension N
check_n_dim `links_mat' , id(`id')
check_n_dim `dist_mat' , id(`id')

* check if weights_mat is dimension NT
check_nt_dim `weights' , id(`id')



tempvar wvar wf wff wvarfake

		if "`weight'" == "fweight" | "`weight'"=="aweight" {
			local wtexp `"[`weight' `exp']"'
			qui gen double `wvar' `exp'
			qui gen byte `wvarfake' = 1
		}
		if "`weight'" == "fweight" & "`kernel'" !="" {
			di in red "fweights not allowed (data are -tsset-)"
			exit 101
		}
		if "`weight'" == "fweight" & "`sw'" != "" {
			di in red "fweights currently not supported with -sw- option"
			exit 101
		}
		if "`weight'" == "iweight" {
			if "`robust'`cluster'`gmm2s'`kernel'" !="" {
				di in red "iweights not allowed with robust or gmm"
				exit 101
			}
			else {
				local wtexp `"[`weight' `exp']"'
				qui gen double `wvar' `exp'
			}
		}
		if "`weight'" == "pweight" {
			local wtexp `"[aweight `exp']"'
			qui gen double `wvar' `exp'
			qui gen double `wvarfake' `exp'
			local robust "robust"
		}
		if "`weight'" == "" {
* If no weights, define neutral weight variable
			qui gen byte `wvar'=1
			qui gen byte `wvarfake' = 1
		}

********************************************************************************
// weight factor and sample size
// Every time a weight is used, must multiply by scalar wf ("weight factor")
// wf=1 for no weights, fw and iw, wf = scalar that normalizes sum to be N if aw or pw

	qui sum `wvar' `wtexp', meanonly

// Weight statement
		if "`weight'" ~= "" {
di in gr "(sum of wgt is " %14.4e `r(sum_w)' ")"
scalar sumweigh = `r(sum_w)'
		}
		if "`weight'"=="" | "`weight'"=="fweight" | "`weight'"=="iweight" {
// Effective number of observations is sum of weight variable.
// If weight is "", weight var must be column of ones and N is number of rows
			scalar `wf'=1
			local NNN=r(sum_w)
		}
		else if "`weight'"=="aweight" | "`weight'"=="pweight" {
			scalar `wf'=r(N)/r(sum_w)
			local NNN=r(N)
		}
		else {
// Should never reach here
di as err " error - misspecified weights"
			exit 198
		}
		if `NNN'==0 {
di as err "no observations"
			exit 2000
		}
		 	
*-------------------------------------------------------
*B) Construct the matrices in Mata

//if `touse' == 1 {	
	if ("`time'" == ""){
		qui sort `id' 
	}
	else { 
	qui sort `id' `time'
	}
	
	scalar define ntsize = _N
	scalar define ntsq = ntsize*ntsize
	scalar lagcutoff = `lagcutoff'
	scalar distcutoff = `distcutoff'
	scalar lagdistcutoff = `lagdistcutoff'
	if ("`hac'" == ""){
		scalar hac_signal = 0
	}
	else {
		scalar hac_signal = 1
	}
	
	
* Destring ID (if needed)
local vartype: type `id'
	if substr("`vartype'",1,3)=="str" { 
		qui tempvar id_enc
		encode `id', generate(`id_enc')
	*	drop `id'
		qui tempvar id
		gen  `id'=`id_enc' 
	}
*
	mata {
	lagcutoff_s = st_numscalar("lagcutoff")
	distcutoff_s = st_numscalar("distcutoff")
	lagdistcutoff_s = st_numscalar("lagdistcutoff")
	hac_signal_s = st_numscalar("hac_signal")
	
	*st_view(id_vec=.,.,"`id_enc'")
	id_vec = st_data(., "`id'")	
	}
	if ("`time'" == ""){
	mata: time=J(rows(id_vec),1,1)
	}
	else { 
	mata: st_view(time=.,.,"`time'")
	}
	
//	qui sort `id' `time'
		
	scalar `wff' = `wf'^(1/2)	
	tempvar wvar2
	qui gen `wvar2' = `wf'*`wvar'
	qui	replace `wvar'  = sqrt(`wvar')
	qui	replace `wvar' = `wvar' * `wff'
	qui	replace `wvarfake'  = sqrt(`wvarfake')
	qui	replace `wvarfake' = `wvarfake' * `wff'

	mata {				
	ntsq = st_numscalar("ntsq")
	st_view(Y=., ., "`depvar'")
	st_view(X=., ., "`end' `regs'")
	st_view(Z=., ., "`iv' `regs'")
	st_view(KX=., ., "`regs'") 			// -------------------------- KP
	st_view(KZ=., ., "`iv'")			// -------------------------- KP
	st_view(KY=., ., "`end'")        	// -------------------------- KP
	st_view(wvar=., ., "`wvar'") 
	st_view(wvar2=., ., "`wvar2'")
	st_view(wvarfake=., ., "`wvarfake'") 
	}
	
*	qui drop id_enc 
mata {	
X=(X, J(rows(Y),1,1))
Z=(Z, J(rows(Y),1,1))
K = cols(X)

Yn = Y
Y=	Y:*wvar 
Zfake = Z:*wvarfake	
X=	X:*wvar 	
Z=	Z:*wvar 

//crossproducts
ZZ = quadcross(Z,Z)
ZZin = invsym(ZZ)
XZ = quadcross(X,Z)
ZX = quadcross(Z,X)
ZY = quadcross(Z,Y)

nofullrankXX=0
nofullrankXZZZZX=0


if (Z==X) {
// OLS: parameters
b=ZZin*ZY
P=ZZin*Z'
Pfake=ZZin*Zfake'

ranzz = rank(ZZ)
colzz = cols(ZZ) - factor_variables
if (ranzz == colzz) {
}
else {
nofullrankXX=1
}

}
else {
// 2SLS: parameters
XZZZZX = makesymmetric(XZ*ZZin*ZX)
XZZZZXin = invsym(XZZZZX)
XZZZZY = XZ*ZZin*ZY
b = XZZZZXin*XZZZZY
P = XZZZZXin*XZ*ZZin*Z'
Pfake = XZZZZXin*XZ*ZZin*Zfake'

ranxzx = rank(XZZZZX)
colxzx = cols(XZZZZX) - factor_variables
if (ranxzx == colxzx) {
}
else {
nofullrankXZZZZX=1
}
}


res = Y-X*b
N=rows(res)

Nend = cols(KY) 	// -------------------------- KP
Niv = cols(KZ) 		// -------------------------- KP
Nie = Nend*Niv		// -------------------------- KP 

*------------------------------------------------------------------------
*        -------------------------- KP --------------------------	 	*
* Partial out X, p refers to partialling out
KX = (KX, J(rows(Y),1,1))
//KX = (KX, J(rows(Y),1,1))

KX=	KX:*wvar 	// -------------------------- KP
KZ=	KZ:*wvar 	// -------------------------- KP
KY= KY:*wvar 	// -------------------------- KP

Zp1 = KX'*KZ
Zp2 = KX*invsym(KX'KX)*Zp1
Zp = KZ - Zp2

Yp1 = KX'*KY
Yp2 = KX*invsym(KX'KX)*Yp1
Yp = KY - Yp2

yp1 = KX'*Y
yp2 = KX*invsym(KX'KX)*yp1
yp = Y - yp2

* VCV first stage parameters
mata: u1 = (invsym(Zp'Zp)*Zp') * Yp

u1 = (invsym(Zp'Zp)*Zp') * Yp
u2 = Zp * u1
u = Yp - u2 

Sz = 1/sqrt(N)*Zp'
SzN = Sz

*------------------------------------------------------------------------
}




//}
*


//ak0 small sample correction
if ("`ak0'" == ""){
}
else {
mata: avgY = colsum(Y) :/ colnonmissing(Y)
mata: res = Y :- avgY
}


if ("`cluster'" == ""){
	if ("`weights'" == ""){
		if ("`network'" == ""){
			if ("`spatial'" == ""){
//1) NO CLUSTERING	
				if ("`time'" == ""){
					mata: P = Pfake
				}
				else {
					mata: P = P
				}
				acreg_no_corr
			}
			else {
//2) SPATIAL
			if ("`time'" == ""){
			if (`distcutoff'>0) {	
				mata: P = P
			}
			else {
				mata: P = Pfake
			}
			}
			else {
				mata: P = P
			}
				if ("`dist_mat'"==""){	 
					mata: st_view(lat=.,.,"`latitude'")                  
					mata: st_view(lon=.,.,"`longitude'")
					if ("`bartlett'"=="bartlett"){			
						acreg_spat_ll_bart ,  `storeweights' `storedistances'
					}
					else {			
						acreg_spat_ll_no_bart ,  `storeweights' `storedistances'
					}
			
				}
				else{
					mata: st_view(distance=., ., "`dist_mat'")		
					if ("`bartlett'"=="bartlett"){
						acreg_spat_dist_bart , `storeweights' `storedistances'	
					}	
					else {
						acreg_spat_dist_no_bart , `storeweights' `storedistances'	
					}
				}
					
			}
		}
		else {
//3) NETWORK
			if ("`time'" == ""){
			if (`distcutoff'>0) {	
				mata: P = P
			}
			else {
				mata: P = Pfake
			}
			}
			else {
				mata: P = P
			}
			if ("`dist_mat'"==""){	 
				mata: st_view(links=., ., "`links_mat'")
				if ("`bartlett'"=="bartlett"){
					acreg_netw_links_bart , `storeweights' `storedistances'
				}
				else {
					acreg_netw_links_no_bart , `storeweights' `storedistances'
				}			
			}
			else{
				mata: st_view(distance=., ., "`dist_mat'")	
				if ("`bartlett'"=="bartlett"){
					acreg_netw_dist_bart ,	 `storeweights' `storedistances'
				}
				else {
					acreg_netw_dist_no_bart , `storeweights' `storedistances'
				}
			}
		}
	}
	else {
//4) WEIGHTS
		mata: weig = st_data(., "`weights'")
		acreg_weig
	}
}
else {
//5) MULTIWAY CLUSTERING
mata: st_view(cluster_mat=., ., "`cluster'")	
acreg_cluster 	,	 `storeweights'
}


*if ("`correction'"=="correction"){	
*		mata: mean_nonzero = nonzero / ntsq
*		mata: Nclus = 1 / mean_nonzero
*		mata: AVCVb_fs = (Nclus/(Nclus -1)) * AVCVb_fs
*	}



// export
	local temp_ct  : word count `regs'
	if `temp_ct' > 0 {
		prog_fvexpand `regs'
		local regss `r(newfvvars)'
	di in gr "Included instruments:" in ye " `regss'"
	local fvops `r(fvops)'
	}
	local temp_ct  : word count `end'
	if `temp_ct' > 0 {
		prog_fvexpand `end'
		local ends `r(newfvvars)'
	di in gr "Instrumented:"in ye " `ends'"
	if "`fvops'" == "true" {
		}
		else {
		local fvops `r(fvops)'
		}
	}
	local temp_ct  : word count `iv'
	if `temp_ct' > 0 {	
		prog_fvexpand `iv'
		local ivs `r(newfvvars)'
	di in gr "Excluded instruments:" in ye " `ivs'"
	if "`fvops'" == "true" {
		}
		else {
		local fvops `r(fvops)'
		}
	}
	
	//small sample correction
if ("`small'" == ""){
local n_cluster=1000000
}
else {
	local iv_ct : word count `ivs'
	local sdofminus = 0
	local partial_ct : word count `regss'
	local partial_ct = `partial_ct' + 1
	local sdofminus =`sdofminus'+`partial_ct'
	mata: mean_nonzero = nonzero / ntsq
	mata: n_cluster = 1 / mean_nonzero
	mata: st_local("N", strofreal(N))
	mata: st_local("n_cluster", strofreal(n_cluster))
	local n_cluster `n_cluster'
	mata: rankxx = rows(W) - diag0cnt(W)
	mata: st_local("rankxx", strofreal(rankxx))
	local ss_corr = (`N'-1) / (`N'-`rankxx'-`sdofminus') *`n_cluster'/(`n_cluster'-1)
	mata ss_corr = st_numscalar("ss_corr")
	mata: V = V * `ss_corr' 
	mata: AVCVb_fs = (n_cluster/(n_cluster -1)) * AVCVb_fs
}


mata {	
	b=b'
	st_matrix("r(V)", V)
	st_matrix("r(b)", b)
	st_numscalar("r(N)", N)
	
	RSS=(res'res)
	//TSSc = sum((Y:-mean(Y)):^2)
	TSSc = sum(wvar2'*((Yn:-mean(Yn, wvar2)):^2))
	TSSu = sum((Y):^2)
	
	Rsqc = 1 - RSS/TSSc 
	Rsqu = 1 - RSS/TSSu 
	
	Fdf1 = K-1
	Fdf2 = N - K
	
	*Fsta = r(chi2)/`Fdf1' * `df_r'/(`N'-`dofminus')
	
	MSSc = TSSc - RSS
	MSSu = TSSu - RSS
	
	st_numscalar("r(RSS)", RSS)	
	
	st_numscalar("r(TSSc)", TSSc)
	st_numscalar("r(TSSu)", TSSu)
	
	st_numscalar("r(MSSc)", MSSc)
	st_numscalar("r(MSSu)", MSSu)
	
	st_numscalar("r(Rsqc)", Rsqc)
	st_numscalar("r(Rsqu)", Rsqu)
	
	st_numscalar("r(Fdf1)", Fdf1)
	st_numscalar("r(Fdf2)", Fdf2)
	
*	st_matrix("r(AVCVb_fs)", AVCVb_fs)
	
}
	
		
mat `b'=r(b)
mat `V'=r(V)

matname `V' `ends' `regss' "_cons" , e
mat colnames `b' = `ends' `regss' _cons

ereturn post `b' `V'
ereturn local depvar "`depvar'"

ereturn scalar N=r(N)
if ("`weight'" == "fweight") {
ereturn scalar N = sumweigh
}
ereturn local cmd "acreg"

ereturn scalar rss=r(RSS)

ereturn scalar tss=r(TSSc)
ereturn scalar tssu=r(TSSu)

ereturn scalar mss=r(MSSc)
ereturn scalar mssu=r(MSSu)

ereturn scalar r2=r(Rsqc)
ereturn scalar r2u=r(Rsqu)

ereturn scalar Fdf1=r(Fdf1)
ereturn scalar Fdf2=r(Fdf2)

*mat `AVCVb_fs'=r(AVCVb_fs)

*
*-------------------------------------------------------
*Z) KP TEST
********************************************************************


/*
if ("`iv'" == ""){
}
else {

acreg_ranktest , end(`end') iv(`iv')  


*	mata: st_matrix("r(AVCVb_fs)", AVCVb_fs)
*	mat AVCVb_fs=r(AVCVb_fs)

	*** We retrieve code for IVreg2

	* Stata convention is to exclude constant from instrument list
	* Need word option so that varnames with "_cons" in them aren't zapped
	qui count
	local N = r(N)
	local iv_ct : word count `ivs'
	local iv_ct  = `iv_ct' + 1
	local sdofminus = 0
	local partial_ct : word count `regs'
	local partial_ct = `partial_ct' + 1
	local sdofminus =`sdofminus'+`partial_ct'
	local N_clust=1000	// November 2017, beta version: this will become endogenous in the future
*	local N_clust "`n_cluster'"
	local exex1_ct     : word count `iv'
	*local noconstant "noconstant"
*	local noconstant ""
*	local robust "robust"
	*local robust ""
*	local CLUS="AVCVb_fs"

	* (line 1735 in ivreg2)
	*Need only test of full rank 
*	qui nwacRanktest (`end') (`iv') , vb("`CLUS'") partial(`regs') full wald `noconstant' `robust'
					/* `robust' `clopt' `bwopt' `kernopt'*/

	* sdofminus used here so that F-stat matches test stat from regression with no partial
	scalar rkf=chi2/(`N'-1) *(`N'-`iv_ct'-`sdofminus')  *(`N_clust'-1)/`N_clust' /`exex1_ct' 
					
	scalar widstat=rkf
	scalar KPstat=widstat

	di "Kleibergen Paap rk statistic =  " KPstat
	********************************************************************	
}
*/

*******************************************************************************************
* Rank identification and redundancy block
*******************************************************************************************
*Note:  included instruments (or included exogenous) = regs
*		endogenous = end
*		excluded exogenous = iv
	
	local iv_ct 		: word count `iv' `regs'
	local iv_ct  = `iv_ct' + 1
	local sdofminus = 0
	local partial_ct : word count `regs'
	local partial_ct = `partial_ct' + 1
	local sdofminus =`sdofminus'+`partial_ct'
	local dofminus = 0
	local exex_ct     : word count `iv'
	local endo1_ct     : word count `end'
	local N = r(N)
	
	*local N_clust = 100

	mata: st_matrix("r(AVCVb_fs)", AVCVb_fs)
	mat AVCVb_fs=r(AVCVb_fs)
	local AVCVb_fs="AVCVb_fs"
	
	
if ("`cluster'" == ""){
	if ("`weights'" == ""){
		if ("`network'" == ""){
			if ("`spatial'" == ""){
//1) NO CLUSTERING	
			local ncc = 1
			}
		}	
	}
//5) CLUSTERING	
local ncc = 0
}	
else {
//5) MULTIWAY CLUSTERING
local ncc = 0
}
	

	
if `endo1_ct' > 0  {
// id=underidentification statistic, wid=weak identification statistic
			tempname idrkstat widrkstat iddf idp
			tempname ccf cdf rkf cceval cdeval cd
			tempname idstat 

// WEAK IDENTIFICATION
// Weak id statistic is Cragg-Donald F stat, rk Wald F stat if not
// ranktest exits with error if not full rank so can use iv1_ct and rhs1_ct etc.
	//	if "`robust'`cluster'`kernel'"=="" {
	//			scalar `widstat'=`cdf'
	//		}
	//		else {
// Need only test of full rank
				cap  acreg_ranktest						///
								(`end')			///
								(`iv')			///
								,				///
								partial(`regs')	///
								full					///
								wald					///
								mat_clst("`AVCVb_fs'")	///
								robust						
								
							*	noconstant				///	
							*	`wtexp'					///
							*	`clopt'					///
							*	`bwopt'					///
							*	`kernopt'
// Canonical correlations returned in r(ccorr), sorted in descending order.
// If largest = 1, collinearities so enter error block.
				local rkerror		= _rc>0 | r(chi2)==.
				if ~`rkerror' {
					local rkerror	= el(r(ccorr),1,1)==1
				}
				if `rkerror' {
di in ye "warning: -ranktest- error in calculating KP weak identification test statistics;"
di in ye  "may be caused by collinearities or the presence of factor variables or weights"
					scalar `rkf'		= .
					scalar widstat	= .
				}
				else {
// sdofminus used here so that F-stat matches test stat from regression with no partial
					if `ncc' == 1 {
						scalar `rkf'=r(chi2)/r(N)*(`N'-`iv_ct'-`sdofminus'-`dofminus')/`exex_ct'
					}
					else {
						scalar `rkf' =	r(chi2)/(`N'-1) *				///
										(`N'-`iv_ct'-`sdofminus') *	///
										(`N_clust'-1)/`N_clust' /		///
										`exex_ct'
					}
					scalar widstat=`rkf'
				}
			
	//		}	// end weak-identification stat
		
		ereturn scalar widstat=widstat
	*	di "chi2 = " r(chi2)
	*	di "N = " r(N)
	*	di "N = " `N' 
	*	di "iv ct = " `iv_ct'
	*	di "sdof = "`sdofminus' 
	*	di "dof = "`dofminus' 
	*	di "ex = "`exex_ct'
	*	di "rkf = " `rkf'		
*di in gr "Kleibergen-Paap rk Wald F statistic:" in ye _col(71) %8.3f e(widstat)
di in gr "Kleibergen-Paap rk Wald F statistic:" in ye  %8.3f e(widstat)

		ereturn scalar widstat=e(widstat)
}	// end under- and weak-identification stats
end


**************************************************************************************
capt program drop PEnd
program define PEnd, sclass
	version 8.2
	if `"`0'"' == "[" {		
		sret local stop 1
		exit
	}
	if `"`0'"' == "," {
		sret local stop 1
		exit
	}
	if `"`0'"' == "if" {
		sret local stop 1
		exit
	}
	if substr(`"`0'"',1,3) == "if(" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "in" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "" {
		sret local stop 1
		exit
	}
	else	sret local stop 0
end


*******************************************************************************************
capt program drop prog_fvexpand
program prog_fvexpand, rclass
		syntax varlist(numeric fv)
		fvexpand `varlist'
		local fvops = r(fvops)
		if "`fvops'" == "true" {
		local newfvvarlist = "`r(varlist)'"
		return local newfvvars `"`newfvvarlist'"'
		return local fvops `"`fvops'"'
		}
		else {
		return local newfvvars `"`varlist'"'
		}
	end 
	
	
*******************************************************************************************	
capt program drop prog_fv_unab
program prog_fv_unab, rclass
	syntax varlist(numeric fv)
	local temp_vt  : word count `varlist'
	forval j=1/`temp_vt' {
		local this_var `: word `j' of `varlist''
		if substr("`this_var'", 1, 2) == "i." {
			fvrevar `this_var', list
			local this_var = "`r(varlist)'"
			return local this_var `"`this_var'"'
			tsunab this_var : `this_var'
			local this_var = "i.`this_var'"
		}
		else {
		tsunab this_var : `this_var'
		}
		local ts_varlist `ts_varlist' `this_var' 
	}
	return local ts_varlist `"`ts_varlist'"'
end 


*********************************************************************************************
capt program drop acreg_r2partial
program acreg_r2partial, eclass
	version 12
	syntax   [anything(name=regs)]  [if] [in]  [pweight] [, depvar(string)  end(string) iv(string) ] 

if "`weight'" == "" {
qui ivreg2 `depvar' `regs' (`end'=`iv')  `if' `in' 
 }
 else {
qui ivreg2  `depvar' `regs' (`end'=`iv')  `if' `in' [`weight'`exp']
}	

scalar RSSr2=e(rss)
scalar TSSur2= e(yy) 
scalar TSScr2= e(yyc) 

scalar r2r2=e(r2)
scalar r2ur2=e(r2u)


mata {
	RSSr2 = st_numscalar("RSSr2")
	TSScr2 = st_numscalar("TSScr2")
	TSSur2 = st_numscalar("TSSur2")
	r2r2 = st_numscalar("r2r2")
	r2ur2 = st_numscalar("r2ur2")
	}

end


*********************************************************************************************
capt program drop verify
program define verify
    syntax anything(everything equalok) [, MSG(string asis) RC(integer 198)]
    if !(`anything') {
        di as error `msg'
        exit 198 
    }
end
	
*********************************************************************************************
capt program drop check_missing
program define check_missing
syntax [anything(name=anything)] 
	if "`anything'" == "" {		
	}
	else {
		foreach cv of varlist `anything' {
			qui count if missing(`cv') 
			local missing_val = r(N)
			if (`missing_val' != 0) {
				di as error "`cv' contains missing values"
				exit 198 
			}		
		}
	}
end	
	
	
*********************************************************************************************
capt program drop check_number
program define check_number
syntax [anything(name=anything)] 
	if "`anything'" == "" {		
	}
	else {
		foreach cv of varlist `anything' {
			capture confirm numeric variable `cv'
			if !_rc {
			}
			else {
				di as error "`cv' is not a numeric variable"
				exit 198 
			}
		}
	}
end


*********************************************************************************************
capt program drop check_lat_lon
program define check_lat_lon
syntax [anything(name=anything)] 
	if "`anything'" == "" {		
	}
	else {
		foreach cv of varlist `anything' {
			qui sum `cv'
			local max_cv = r(max)
			local min_cv = r(min)			
			if (`max_cv' > 180 | `min_cv' < -180) {
				di as error "`cv' must be between -180 and 180"
				exit 198 
			}		
		}
	}
end	

*********************************************************************************************
capt program drop check_links
program define check_links
syntax [anything(name=anything)] 
	if "`anything'" == "" {		
	}
	else {
		foreach cv of varlist `anything' {
			qui sum `cv'
			local max_cv = r(max)
			local min_cv = r(min)			
			if (`max_cv' > 1 | `min_cv' < 0) {
				di as error "`cv' must be a binary variable"
				exit 198 
			}		
		}
	}
end	

*********************************************************************************************
capt program drop check_link_dim
program define check_link_dim
syntax [anything(name=anything)] , id(varname)
	if "`anything'" == "" {		
	}
	else {
		local nu_links = 0
		foreach cv of varlist `anything' {
			local nu_links = `nu_links' + 1
			}
		qui tab `id'
		local nu_ind = r(r)
		if (`nu_ind' !=  `nu_links') {
			di as error "number of link variables should coincide with number of individuals"
			di in ye "this can be due to if/in function"
			exit 198 
		}		
	}
end	

*********************************************************************************************
capt program drop check_n_dim
program define check_n_dim
syntax [anything(name=anything)] , id(varname)
	if "`anything'" == "" {		
	}
	else {
		local nu_vars = 0
		foreach cv of varlist `anything' {
			local nu_vars = `nu_vars' + 1
			}
		qui tab `id'
		local nu_ind = r(r)
		if (`nu_ind' !=  `nu_vars') {
			di as error "number of link/distance variables should coincide with number of individuals"
			di in ye "this can be due to if/in function"
			capt drop iddd_var
			exit 198 
		}		
	}
end

*********************************************************************************************
capt program drop check_nt_dim
program define check_nt_dim
syntax [anything(name=anything)] , id(varname)
	if "`anything'" == "" {		
	}
	else {
		local nu_vars = 0
		foreach cv of varlist `anything' {
			local nu_vars = `nu_vars' + 1
			}
		qui sum `id'
		local nu_ind = r(N)
		if (`nu_ind' !=  `nu_vars') {
			di as error "number of weight variables should coincide with number of observations"
			di in ye "this can be due to if/in function"
			capt drop iddd_var
			exit 198 
		}		
	}
end	


*******************************************************************************************	
capt program drop prog_fv_partial
program prog_fv_partial, rclass
	syntax varlist(numeric fv)
	local temp_vt  : word count `varlist'
	forval j=1/`temp_vt' {
		local this_var `: word `j' of `varlist''
		if substr("`this_var'", 1, 2) == "i." {
		di in red "factor variables not allowed with pfe1 option, please specify" in ye " xi: " in red "before acreg"	
		exit 198
		}	
	}
end 


*******************************************************************************************	
capt program drop prog_count_factor_variables
program prog_count_factor_variables, rclass
	syntax varlist(numeric fv)
	scalar factor_variables=0
	local temp_vt  : word count `varlist'
	forval j=1/`temp_vt' {
		local this_var `: word `j' of `varlist''
		if substr("`this_var'", 1, 2) == "i." {
		scalar factor_variables=factor_variables+1
		}	
	}
end 


*********************************************************************************************
*********************************************************************************************
*********************************************************************************************

*********************************************************************************************

capt program drop acreg_weig
program acreg_weig, eclass
	version 12
	syntax [, ] 
	
mata {	
weight_cols = cols(weig)
weight_rows = rows(weig)

st_local("N_o", strofreal(N))
st_local("weight_cols", strofreal(weight_cols))
st_local("weight_rows", strofreal(weight_rows))

}

if `N_o' != `weight_cols' {
	disp as error "The number of columns in the wights matrix is different than the number of observations"
exit 498
}


mata {

// 2SLS: VCV
V = J(K,K, 0)
nonzero = 0

AVCVb_fs = J(Nie,Nie, 0)   		// -------------------------- KP // -------------------------- KP

		V =  P * (res * res' :* weig) * P'
		weigz = weig :> 0
		nonzero = sum(weigz)

		AVCVb_fs = (I(Nend)#SzN) * ((vec(u) * (vec(u))') :* (J(Nend,Nend, 1)#weig)) * (I(Nend)#SzN)'		// -------------------------- KP
		
//*mata: V[1..5,1..5]

_makesymmetric(V)

}

end


*********************************************************************************************

capt program drop acreg_spat_ll_no_bart
program acreg_spat_ll_no_bart, eclass
	version 12
	syntax [,  storeweights storedistances ] // storedistances to be implemented 


*
/*
* First stage
mata: PZ=Z*invsym(Z'Z)*Z'
mata: MZ=I(rows(PZ))-PZ


mata: X1=Xe[.,1]
mata: X2=Xe[.,2]

mata: gamma1=PZ * X1
*mata: rows(gamma1)
mata: resX1 = MZ * X1

mata: VCV1 = PZ * (resX1 * resX1' :* cluster) * PZ'
mata: VCV1 = VCV1[|1,1\16,16|]

mata: F1 = (gamma1[.,1..Niv]'*invsym(VCV1)*gamma1[.,1..Niv])/Niv
*/

mata {

// 2SLS: VCV
V = J(K,K, 0)
nonzero = 0
ind = 0
pos = 0

AVCVb_fs_1 = J(Nie,Nie, 0) 		// -------------------------- KP 
AVCVb_fs = J(Nie,Nie, 0)   		// -------------------------- KP 

// values 
a = .01745329
c = 6371
pi = 3.141593

Idunique = uniqrows(id_vec)
NId = rows(Idunique)

*some vars for checks
**dist= J(N,NId, 0)
**adjj= J(N,N, 0)



if ("`storeweights'" == "storeweights"){
weigg = J(N,N, 0)
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			lon_scale = cos(lat[s,1]*pi()/180)*111 
			lat_scale = 111
			distance_i = ((lat_scale*(lat[s,1]:-lat[.,1])):^2 + /// 	
					  (lon_scale*(lon[s,1]:-lon[.,1])):^2):^0.5
		}
		
**dist[.,i] = distance_i // check
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		if (hac_signal_s==1) {
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)) :* (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)
		}
		else {
			weight_dis = (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)
		}
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		if (hac_signal_s==1) {
			weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		}
		else {
			weight = (time_gap_i :<= lagcutoff_s)
		}
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz) 
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		weigg[.,pos] = w[.,1]
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP // -------------------------- KP
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
		
**adjj[.,ind+1] = w[.,1] // check
	}
	
	ind = ind + t1
}

*
st_matrix("weightsmat", weigg)
}
else {

if ("`storedistances'" == "storedistances"){
distances = J(N,NId, 0)

for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			lon_scale = cos(lat[s,1]*pi()/180)*111 
			lat_scale = 111
			distance_i = ((lat_scale*(lat[s,1]:-lat[.,1])):^2 + /// 	
					  (lon_scale*(lon[s,1]:-lon[.,1])):^2):^0.5
		}
	
	distances[.,i] = distance_i[.,1]
		
	for (t = 1; t <= t1; t++){
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		if (hac_signal_s==1) {
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)) :* (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)
		}
		else {
			weight_dis = (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)
		}
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		if (hac_signal_s==1) {
			weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		}
		else {
			weight = (time_gap_i :<= lagcutoff_s)
		}
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz) 
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1 
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
		
**adjj[.,ind+1] = w[.,1] // check
	}
	
	ind = ind + t1
}

st_matrix("distancesmat", distances)
}
else {
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			lon_scale = cos(lat[s,1]*pi()/180)*111 
			lat_scale = 111
			distance_i = ((lat_scale*(lat[s,1]:-lat[.,1])):^2 + /// 	
					  (lon_scale*(lon[s,1]:-lon[.,1])):^2):^0.5
		}
		
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		if (hac_signal_s==1) {
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)) :* (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)
		}
		else {
			weight_dis = (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)
		}
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		if (hac_signal_s==1) {
			weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		}
		else {
			weight = (time_gap_i :<= lagcutoff_s)
		}
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz) 
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1 
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
		
**adjj[.,ind+1] = w[.,1] // check
	}
	
	ind = ind + t1
}

*
}
}
*

_makesymmetric(V)

}
end


*********************************************************************************************

capt program drop acreg_spat_ll_bart
program acreg_spat_ll_bart, eclass
	version 12
	syntax  [, storeweights storedistances ] // storedistances to be implemented

*
/*
* First stage
mata: PZ=Z*invsym(Z'Z)*Z'
mata: MZ=I(rows(PZ))-PZ


mata: X1=Xe[.,1]
mata: X2=Xe[.,2]

mata: gamma1=PZ * X1
*mata: rows(gamma1)
mata: resX1 = MZ * X1

mata: VCV1 = PZ * (resX1 * resX1' :* cluster) * PZ'
mata: VCV1 = VCV1[|1,1\16,16|]

mata: F1 = (gamma1[.,1..Niv]'*invsym(VCV1)*gamma1[.,1..Niv])/Niv
*/

mata {

// 2SLS: VCV
V = J(K,K, 0)
nonzero = 0
ind = 0
pos = 0

AVCVb_fs_1 = J(Nie,Nie, 0) 		// -------------------------- KP 
AVCVb_fs = J(Nie,Nie, 0)   		// -------------------------- KP 

// values 
a = .01745329
c = 6371
pi = 3.141593

Idunique = uniqrows(id_vec)
NId = rows(Idunique)

*some vars for checks
**dist= J(N,NId, 0)
**adjj= J(N,N, 0)

if ("`storeweights'" == "storeweights"){
weigg = J(N,N, 0)
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			lon_scale = cos(lat[s,1]*pi()/180)*111 
			lat_scale = 111
			distance_i = ((lat_scale*(lat[s,1]:-lat[.,1])):^2 + /// 	
					  (lon_scale*(lon[s,1]:-lon[.,1])):^2):^0.5
		}

	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		if (hac_signal_s==1) {
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)):*(1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s))	
		}
		else {
			weight_dis = (1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s))	
		}
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		if (hac_signal_s==1) {
			weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		}
		else {
			weight =  (time_gap_i :<= lagcutoff_s)
		}
		w[s..e,1] = weight
	}	
	else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz)
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		weigg[.,pos] = w[.,1]
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}	
	
	ind = ind + t1
}

*
st_matrix("weightsmat", weigg)
}
else {

if ("`storedistances'" == "storedistances"){
distances = J(N,NId, 0)

for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			lon_scale = cos(lat[s,1]*pi()/180)*111 
			lat_scale = 111
			distance_i = ((lat_scale*(lat[s,1]:-lat[.,1])):^2 + /// 	
					  (lon_scale*(lon[s,1]:-lon[.,1])):^2):^0.5
		}
	
	distances[.,i] = distance_i[.,1]
	
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		if (hac_signal_s==1) {
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)):*(1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s))	
		}
		else {
			weight_dis = (1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s))	
		}
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		if (hac_signal_s==1) {
			weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		}
		else {
			weight =  (time_gap_i :<= lagcutoff_s)
		}
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz)
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP	
	}	
	
	ind = ind + t1
}



st_matrix("distancesmat", distances)
}
else{
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			lon_scale = cos(lat[s,1]*pi()/180)*111 
			lat_scale = 111
			distance_i = ((lat_scale*(lat[s,1]:-lat[.,1])):^2 + /// 	
					  (lon_scale*(lon[s,1]:-lon[.,1])):^2):^0.5
		}

	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		if (hac_signal_s==1) {
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)):*(1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s))	
		}
		else {
			weight_dis = (1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s))	
		}
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		if (hac_signal_s==1) {
			weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		}
		else {
			weight =  (time_gap_i :<= lagcutoff_s)
		}
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz)
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP	
	}	
	
	ind = ind + t1
}

*
}
}
*

_makesymmetric(V)

}
end

*********************************************************************************************

capt program drop acreg_spat_dist_no_bart
program acreg_spat_dist_no_bart, eclass
	version 12
	syntax [, storeweights  ]  


*
/*
* First stage
mata: PZ=Z*invsym(Z'Z)*Z'
mata: MZ=I(rows(PZ))-PZ


mata: X1=Xe[.,1]
mata: X2=Xe[.,2]

mata: gamma1=PZ * X1
*mata: rows(gamma1)
mata: resX1 = MZ * X1

mata: VCV1 = PZ * (resX1 * resX1' :* cluster) * PZ'
mata: VCV1 = VCV1[|1,1\16,16|]

mata: F1 = (gamma1[.,1..Niv]'*invsym(VCV1)*gamma1[.,1..Niv])/Niv
*/

mata {

// 2SLS: VCV
V = J(K,K, 0)
nonzero = 0
ind = 0
pos = 0

AVCVb_fs_1 = J(Nie,Nie, 0) 		// -------------------------- KP 
AVCVb_fs = J(Nie,Nie, 0)   		// -------------------------- KP 

// values 
a = .01745329
c = 6371
pi = 3.141593

Idunique = uniqrows(id_vec)
NId = rows(Idunique)
d_cols = cols(distance)

st_local("NId", strofreal(NId))
st_local("d_cols", strofreal(d_cols))

}

if `NId' != `d_cols' {
	disp as error "The number of columns in the distance matrix is different than the number of individuals"
exit 498
}

mata {

if ("`storeweights'" == "storeweights"){
weigg = J(N,N, 0)
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			distance_i = distance[.,i]		
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		if (hac_signal_s==1) {
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)) :* (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)
		}
		else {
			weight_dis = (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)
		}
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		if (hac_signal_s==1) {
			weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		}
		else {
			weight = (time_gap_i :<= lagcutoff_s)
		}
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz) 
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		weigg[.,pos] = w[.,1]
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}
	
	ind = ind + t1
}
*
st_matrix("weightsmat", weigg)
}
else {
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			distance_i = distance[.,i]
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		if (hac_signal_s==1) {
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)) :* (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)
		}
		else {
			weight_dis = (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)
		}
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		if (hac_signal_s==1) {
			weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		}
		else {
			weight = (time_gap_i :<= lagcutoff_s)
		}
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz) 
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}
	
	ind = ind + t1
}


*
}
*

_makesymmetric(V)

}

end

*********************************************************************************************

capt program drop acreg_spat_dist_bart
program acreg_spat_dist_bart, eclass
	version 12
	syntax  [,storeweights ]  

*
/*
* First stage
mata: PZ=Z*invsym(Z'Z)*Z'
mata: MZ=I(rows(PZ))-PZ


mata: X1=Xe[.,1]
mata: X2=Xe[.,2]

mata: gamma1=PZ * X1
*mata: rows(gamma1)
mata: resX1 = MZ * X1

mata: VCV1 = PZ * (resX1 * resX1' :* cluster) * PZ'
mata: VCV1 = VCV1[|1,1\16,16|]

mata: F1 = (gamma1[.,1..Niv]'*invsym(VCV1)*gamma1[.,1..Niv])/Niv
*/

mata {

// 2SLS: VCV
V = J(K,K, 0)
nonzero = 0
ind = 0
pos = 0

AVCVb_fs_1 = J(Nie,Nie, 0) 		// -------------------------- KP 
AVCVb_fs = J(Nie,Nie, 0)   		// -------------------------- KP 

// values 
a = .01745329
c = 6371
pi = 3.141593

Idunique = uniqrows(id_vec)
NId = rows(Idunique)
d_cols = cols(distance)

st_local("NId", strofreal(NId))
st_local("d_cols", strofreal(d_cols))

}

if `NId' != `d_cols' {
	disp as error "The number of columns in the distance matrix is different than the number of individuals"
exit 498
}

mata {

if ("`storeweights'" == "storeweights"){
weigg = J(N,N, 0)
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector			
			distance_i = distance[.,i]
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		if (hac_signal_s==1) {
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)):*(1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s))	
		}
		else {
			weight_dis = (1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s))	
		}
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		if (hac_signal_s==1) {
			weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		}
		else {
			weight =  (time_gap_i :<= lagcutoff_s)
		}
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz)
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		weigg[.,pos] = w[.,1]
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}	
	
	ind = ind + t1
}

*
st_matrix("weightsmat", weigg)
}
else {
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			
			distance_i = distance[.,i]
			
			*lon_scale = cos(lat[s,1]*pi()/180)*111 
			*lat_scale = 111
			*distance_i = ((lat_scale*(lat[s,1]:-lat[.,1])):^2 + /// 	
			*		  (lon_scale*(lon[s,1]:-lon[.,1])):^2):^0.5
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		if (hac_signal_s==1) {
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)):*(1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s))	
		}
		else {
			weight_dis = (1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s))	
		}
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		if (hac_signal_s==1) {
			weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		}
		else {
			weight =  (time_gap_i :<= lagcutoff_s)
		}
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz)
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}	
	
	ind = ind + t1
}

*
}
*
//*mata: V[1..5,1..5]

_makesymmetric(V)

}

end


*********************************************************************************************

capt program drop acreg_no_corr
program acreg_no_corr, eclass
	version 12
	syntax [,  storeweights  ] 


*
/*
* First stage
mata: PZ=Z*invsym(Z'Z)*Z'
mata: MZ=I(rows(PZ))-PZ


mata: X1=Xe[.,1]
mata: X2=Xe[.,2]

mata: gamma1=PZ * X1
*mata: rows(gamma1)
mata: resX1 = MZ * X1

mata: VCV1 = PZ * (resX1 * resX1' :* cluster) * PZ'
mata: VCV1 = VCV1[|1,1\16,16|]

mata: F1 = (gamma1[.,1..Niv]'*invsym(VCV1)*gamma1[.,1..Niv])/Niv
*/


mata {
// 2SLS: VCV
V = J(K,K, 0)
nonzero = 0
ind = 0
pos = 0

AVCVb_fs_1 = J(Nie,Nie, 0) 		// -------------------------- KP 
AVCVb_fs = J(Nie,Nie, 0)   		// -------------------------- KP 

Idunique = uniqrows(id_vec)
NId = rows(Idunique)

	if ("`storeweights'" == "storeweights"){
		weigg = J(N,N, 0)
		for (i = 1; i <= NId; i++){
			rows_ni = id_vec:==Idunique[i,1] 
			// __ Get subsets of variables for ID i (without changing original matrix)
			time1 = select(time, rows_ni)
			t1 = length(time1)
			// __ Weights ID i vector
			w = J(N,1, 0)
			// __ Indicator variables (start, end)
			s = ind + 1
			e = ind + t1

			for (t = 1; t <= t1; t++){
				// __ Indicator variables (position in the vector)
				pos  = ind + t		
				if (lagcutoff_s>0) {
				// __ Vector of weights (same ID)
					time_gap_i = abs(time1[t,1] :- time1)
					if (hac_signal_s==1) {
						weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
					}
					else {
						weight = (time_gap_i :<= lagcutoff_s)
					}
					w[s..e,1] = weight
				}
				else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
				}
				// __ VCV	
				wz = w :> 0
				nonzero = nonzero + sum(wz) 
				V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
				V = V + V1
				weigg[.,pos] = w[.,1]
				AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP // -------------------------- KP
				AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
			}
		ind = ind + t1
		}	
	*
		st_matrix("weightsmat", weigg)
	}
	else {
		for (i = 1; i <= NId; i++){
			rows_ni = id_vec:==Idunique[i,1] 
			// __ Get subsets of variables for ID i (without changing original matrix)
			time1 = select(time, rows_ni)
			t1 = length(time1)
			// __ Weights ID i vector
			w = J(N,1, 0)
			// __ Indicator variables (start, end)
			s = ind + 1
			e = ind + t1		
			
			for (t = 1; t <= t1; t++){
				// __ Indicator variables (position in the vector)
				pos  = ind + t		
		
				if (lagcutoff_s>0) {
					// __ Vector of weights (same ID)
					time_gap_i = abs(time1[t,1] :- time1)
					if (hac_signal_s==1) {
						weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
					}
					else {
						weight = (time_gap_i :<= lagcutoff_s)
					}
					w[s..e,1] = weight
				}
				else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
				}
				// __ VCV	
				wz = w :> 0
				nonzero = nonzero + sum(wz) 
				V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
				V = V + V1 
				AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP
				AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
			}
			ind = ind + t1
		}

	}
_makesymmetric(V)
}
end


*********************************************************************************************

capt program drop acreg_netw_links_no_bart
program acreg_netw_links_no_bart, eclass
	version 12
	syntax [, storeweights storedistances ] 

*
/*
* First stage
mata: PZ=Z*invsym(Z'Z)*Z'
mata: MZ=I(rows(PZ))-PZ


mata: X1=Xe[.,1]
mata: X2=Xe[.,2]

mata: gamma1=PZ * X1
*mata: rows(gamma1)
mata: resX1 = MZ * X1

mata: VCV1 = PZ * (resX1 * resX1' :* cluster) * PZ'
mata: VCV1 = VCV1[|1,1\16,16|]

mata: F1 = (gamma1[.,1..Niv]'*invsym(VCV1)*gamma1[.,1..Niv])/Niv
*/

mata {

// 2SLS: VCV
V = J(K,K, 0)
nonzero = 0
ind = 0
pos = 0

AVCVb_fs_1 = J(Nie,Nie, 0) 		// -------------------------- KP 
AVCVb_fs = J(Nie,Nie, 0)   		// -------------------------- KP 

// values 
a = .01745329
c = 6371
pi = 3.141593

Idunique = uniqrows(id_vec)
NId = rows(Idunique)
l_cols = cols(links)

st_local("NId", strofreal(NId))
st_local("l_cols", strofreal(l_cols))

}

if `NId' != `l_cols' {
	disp as error "The number of columns in the links matrix is different than the number of individuals"
exit 498
}

mata {


				//************************************************************
				// __ Creating Distances from links
				if (distcutoff_s>0) {
				// __ a) From NTxN to NxN
					
					distance = J(N,NId, 0)
					
					if (distcutoff_s==1) {
						distance = links		
					}
					else {
			
						B_ind = 0
						NN_dist = J(NId,NId, 0)
						NN_links = J(NId,NId, 0)

						for (i = 1; i <= NId; i++){
							B_rows_ni = id_vec:==Idunique[i,1] 
							
							B_time1 = select(time, B_rows_ni)
							B_t1 = length(B_time1)
							
							first_ind_line = B_ind + 1
							NN_links[i,.] = links[first_ind_line,.]
							
							B_ind = B_ind + B_t1	
						}
			
				// __ b) Taking power of a matrix
				
				
						NN_links_pow = NN_links
						NN_dist = NN_links
						for (k = 1; k <= 100; k++){
				//powers 	
							if (distcutoff_s>k) {
								NN_links_pow = NN_links_pow * NN_links 
								NN_links_pow_ind = (NN_links_pow:!= 0) :* (k+1) :* (NN_dist :== 0)
								NN_dist = NN_dist + NN_links_pow_ind 
							}
						}

					// __ c) Form NxN to NTxN 
						B_ind = 0
						for (i = 1; i <= NId; i++){
							B_rows_ni = id_vec:==Idunique[i,1] 
							B_time1 = select(time, B_rows_ni)
							B_t1 = length(B_time1)
							
							for (t = 1; t <= B_t1; t++){
								ind_line = B_ind + t
								distance[ind_line,.] = NN_dist[i,.]
							}
							B_ind = B_ind + B_t1	
						}
					}
				}
				//************************************************************

if ("`storeweights'" == "storeweights"){
weigg = J(N,N, 0)
				
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector		
			
			distance_i = distance[.,i]
			
			*lon_scale = cos(lat[s,1]*pi()/180)*111 
			*lat_scale = 111
			*distance_i = ((lat_scale*(lat[s,1]:-lat[.,1])):^2 + /// 	
			*		  (lon_scale*(lon[s,1]:-lon[.,1])):^2):^0.5
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		if (hac_signal_s==1) {
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)) :* (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s) :* (distance_i :!= 0)
		}
		else {
			weight_dis =  (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s) :* (distance_i :!= 0)
		}
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		if (hac_signal_s==1) {
			weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		}
		else {
			weight = (time_gap_i :<= lagcutoff_s)
		}
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz) 
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		weigg[.,pos] = w[.,1]
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}
	ind = ind + t1
}

*
st_matrix("weightsmat", weigg)
}
else {
if ("`storedistances'" == "storedistances"){
distances = J(N,NId, 0)

for (i = 1; i <= NId; i++){
	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			
			distance_i = distance[.,i]
			
			*lon_scale = cos(lat[s,1]*pi()/180)*111 
			*lat_scale = 111
			*distance_i = ((lat_scale*(lat[s,1]:-lat[.,1])):^2 + /// 	
			*		  (lon_scale*(lon[s,1]:-lon[.,1])):^2):^0.5
		}
		
	distances[.,i] = distance_i[.,1]	
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		if (hac_signal_s==1) {
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)) :* (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s) :* (distance_i :!= 0)
		}
		else {
			weight_dis =  (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s) :* (distance_i :!= 0)
		}
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		if (hac_signal_s==1) {
			weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		}
		else {
			weight = (time_gap_i :<= lagcutoff_s)
		}
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz) 
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1	
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}
	ind = ind + t1
}
*

st_matrix("distancesmat", distances)
}
else{


for (i = 1; i <= NId; i++){
	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			
			distance_i = distance[.,i]
			
			*lon_scale = cos(lat[s,1]*pi()/180)*111 
			*lat_scale = 111
			*distance_i = ((lat_scale*(lat[s,1]:-lat[.,1])):^2 + /// 	
			*		  (lon_scale*(lon[s,1]:-lon[.,1])):^2):^0.5
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		if (hac_signal_s==1) {
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)) :* (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s) :* (distance_i :!= 0)
		}
		else {
			weight_dis =  (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s) :* (distance_i :!= 0)
		}
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		if (hac_signal_s==1) {
			weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		}
		else {
			weight = (time_gap_i :<= lagcutoff_s)
		}
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz) 
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1	
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}
	ind = ind + t1
}
*
}
}
*
//*mata: V[1..5,1..5]

_makesymmetric(V)

}

end


*********************************************************************************************

capt program drop acreg_netw_links_bart
program acreg_netw_links_bart, eclass
	version 12
	syntax  [, storeweights storedistances] 
*
/*
* First stage
mata: PZ=Z*invsym(Z'Z)*Z'
mata: MZ=I(rows(PZ))-PZ


mata: X1=Xe[.,1]
mata: X2=Xe[.,2]

mata: gamma1=PZ * X1
*mata: rows(gamma1)
mata: resX1 = MZ * X1

mata: VCV1 = PZ * (resX1 * resX1' :* cluster) * PZ'
mata: VCV1 = VCV1[|1,1\16,16|]

mata: F1 = (gamma1[.,1..Niv]'*invsym(VCV1)*gamma1[.,1..Niv])/Niv
*/

mata {

// 2SLS: VCV
V = J(K,K, 0)
nonzero = 0
ind = 0
pos = 0

AVCVb_fs_1 = J(Nie,Nie, 0) 		// -------------------------- KP 
AVCVb_fs = J(Nie,Nie, 0)   		// -------------------------- KP 

// values 
a = .01745329
c = 6371
pi = 3.141593

Idunique = uniqrows(id_vec)
NId = rows(Idunique)
l_cols = cols(links)

st_local("NId", strofreal(NId))
st_local("l_cols", strofreal(l_cols))

}

if `NId' != `l_cols' {
	disp as error "The number of columns in the links matrix is different than the number of individuals"
exit 498
}

mata {
				//************************************************************
				// __ Creating Distances from links
				if (distcutoff_s>0) {
				// __ a) Form NTxN to NxN
					
					distance = J(N,NId, 0)
					
					if (distcutoff_s==1) {
						distance = links		
					}
					else {
			
						B_ind = 0
						NN_dist = J(NId,NId, 0)
						NN_links = J(NId,NId, 0)

						for (i = 1; i <= NId; i++){
							B_rows_ni = id_vec:==Idunique[i,1] 
							
							B_time1 = select(time, B_rows_ni)
							B_t1 = length(B_time1)
							
							first_ind_line = B_ind + 1
							NN_links[i,.] = links[first_ind_line,.]
							
							B_ind = B_ind + B_t1	
						}
			
				// __ b) Taking power of a matrix
				
				
						NN_links_pow = NN_links
						NN_dist = NN_links
						for (k = 1; k <= 100; k++){
				//powers 	
							if (distcutoff_s>k) {
								NN_links_pow = NN_links_pow * NN_links 
								NN_links_pow_ind = (NN_links_pow:!= 0) :* (k+1) :* (NN_dist :== 0)
								NN_dist = NN_dist + NN_links_pow_ind 
							}
						}

					// __ c) Form NxN to NTxN 
						B_ind = 0
						for (i = 1; i <= NId; i++){
							B_rows_ni = id_vec:==Idunique[i,1] 
							B_time1 = select(time, B_rows_ni)
							B_t1 = length(B_time1)
							
							for (t = 1; t <= B_t1; t++){
								ind_line = B_ind + t
								distance[ind_line,.] = NN_dist[i,.]
							}
							B_ind = B_ind + B_t1	
						}
					}
				}
				//************************************************************


if ("`storeweights'" == "storeweights"){
weigg = J(N,N, 0)
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			distance_i = distance[.,i]
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		if (hac_signal_s==1) {
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)):*(1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)) :* (distance_i :!= 0)	
		}
		else {
			weight_dis = (1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)) :* (distance_i :!= 0)	
		}
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		if (hac_signal_s==1) {
			weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		}
		else {
			weight =  (time_gap_i :<= lagcutoff_s)
		}
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz)
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		weigg[.,pos] = w[.,1]
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}	
	
	ind = ind + t1
}

*
st_matrix("weightsmat", weigg)
}
else {
if ("`storedistances'" == "storedistances"){
distances = J(N,NId, 0)

for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			distance_i = distance[.,i]
		}
	
	distances[.,i] = distance_i[.,1]	
	
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		if (hac_signal_s==1) {
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)):*(1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)) :* (distance_i :!= 0)	
		}
		else {
			weight_dis = (1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)) :* (distance_i :!= 0)	
		}
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		if (hac_signal_s==1) {
			weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		}
		else {
			weight =  (time_gap_i :<= lagcutoff_s)
		}
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz)
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}	
	
	ind = ind + t1
}

st_matrix("distancesmat", distances)
}
else{
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			distance_i = distance[.,i]
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		if (hac_signal_s==1) {
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)):*(1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)) :* (distance_i :!= 0)	
		}
		else {
			weight_dis = (1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)) :* (distance_i :!= 0)	
		}
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		if (hac_signal_s==1) {
			weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		}
		else {
			weight =  (time_gap_i :<= lagcutoff_s)
		}
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz)
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}	
	
	ind = ind + t1
}

*
}
}
*
//*mata: V[1..5,1..5]

_makesymmetric(V)

}

end


*********************************************************************************************

capt program drop acreg_netw_dist_no_bart
program acreg_netw_dist_no_bart, eclass
	version 12
	syntax  [, storeweights ] 

*
/*
* First stage
mata: PZ=Z*invsym(Z'Z)*Z'
mata: MZ=I(rows(PZ))-PZ


mata: X1=Xe[.,1]
mata: X2=Xe[.,2]

mata: gamma1=PZ * X1
*mata: rows(gamma1)
mata: resX1 = MZ * X1

mata: VCV1 = PZ * (resX1 * resX1' :* cluster) * PZ'
mata: VCV1 = VCV1[|1,1\16,16|]

mata: F1 = (gamma1[.,1..Niv]'*invsym(VCV1)*gamma1[.,1..Niv])/Niv
*/

mata {

// 2SLS: VCV
V = J(K,K, 0)
nonzero = 0
ind = 0
pos = 0

AVCVb_fs_1 = J(Nie,Nie, 0) 		// -------------------------- KP 
AVCVb_fs = J(Nie,Nie, 0)   		// -------------------------- KP

// values 
a = .01745329
c = 6371
pi = 3.141593

Idunique = uniqrows(id_vec)
NId = rows(Idunique)
d_cols = cols(distance)

st_local("NId", strofreal(NId))
st_local("d_cols", strofreal(d_cols))

}

if `NId' != `d_cols' {
	disp as error "The number of columns in the distance matrix is different than the number of individuals"
exit 498
}

mata {

if ("`storeweights'" == "storeweights"){
weigg = J(N,N, 0)
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			
			distance_i = distance[.,i]
			
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		if (hac_signal_s==1) {
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)) :* (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s) :* (distance_i :!= 0)
		}
		else {
			weight_dis = (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s) :* (distance_i :!= 0)
		}
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		if (hac_signal_s==1) {
			weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		}
		else {
			weight = (time_gap_i :<= lagcutoff_s)
		}
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz) 
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		weigg[.,pos] = w[.,1]
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}
	ind = ind + t1
}

*
st_matrix("weightsmat", weigg)
}
else {
for (i = 1; i <= NId; i++){
	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			
			distance_i = distance[.,i]
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		if (hac_signal_s==1) {
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)) :* (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s) :* (distance_i :!= 0)
		}
		else {
			weight_dis =  (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s) :* (distance_i :!= 0)
		}
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		if (hac_signal_s==1) {
			weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		}
		else {
			weight = (time_gap_i :<= lagcutoff_s)
		}
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz) 
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1	
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}
	ind = ind + t1
}
*
}
*

_makesymmetric(V)

}

end


*********************************************************************************************

capt program drop acreg_netw_dist_bart
program acreg_netw_dist_bart, eclass 
	version 12
	syntax [,  storeweights ] 


*
/*
* First stage
mata: PZ=Z*invsym(Z'Z)*Z'
mata: MZ=I(rows(PZ))-PZ


mata: X1=Xe[.,1]
mata: X2=Xe[.,2]

mata: gamma1=PZ * X1
*mata: rows(gamma1)
mata: resX1 = MZ * X1

mata: VCV1 = PZ * (resX1 * resX1' :* cluster) * PZ'
mata: VCV1 = VCV1[|1,1\16,16|]

mata: F1 = (gamma1[.,1..Niv]'*invsym(VCV1)*gamma1[.,1..Niv])/Niv
*/

mata {

// 2SLS: VCV
V = J(K,K, 0)
nonzero = 0
ind = 0
pos = 0

AVCVb_fs_1 = J(Nie,Nie, 0) 		// -------------------------- KP 
AVCVb_fs = J(Nie,Nie, 0)   		// -------------------------- KP 

// values 
a = .01745329
c = 6371
pi = 3.141593

Idunique = uniqrows(id_vec)
NId = rows(Idunique)
d_cols = cols(distance)

st_local("NId", strofreal(NId))
st_local("d_cols", strofreal(d_cols))

}

if `NId' != `d_cols' {
	disp as error "The number of columns in the distance matrix is different than the number of individuals"
exit 498
}

mata {

if ("`storeweights'" == "storeweights"){
weigg = J(N,N, 0)
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			distance_i = distance[.,i]
			
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		if (hac_signal_s==1) {
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)):*(1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)) :* (distance_i :!= 0)	
		}
		else {
			weight_dis = (1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)) :* (distance_i :!= 0)	
		}
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		if (hac_signal_s==1) {
			weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		}
		else {
			weight =  (time_gap_i :<= lagcutoff_s)
		}
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz)
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		weigg[.,pos] = w[.,1]
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}	
	
	ind = ind + t1
}

*
st_matrix("weightsmat", weigg)
}
else {
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)
	distance_i = J(N,1, 0)
	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
		if (distcutoff_s>0) {
	
		// a) Computing Distance vector
			distance_i = distance[.,i]
			
		}
		
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
	if (distcutoff_s>0) {	
	// a) Computing Weights
		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
		if (hac_signal_s==1) {
			weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)):*(1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)) :* (distance_i :!= 0)	
		}
		else {
			weight_dis = (1:-abs(distance_i :/ distcutoff_s)) :* ( (time_dis_gap_i :<= lagdistcutoff_s) :* (distance_i :<= distcutoff_s)) :* (distance_i :!= 0)	
		}
		w[.,1] = weight_dis
	}
	if (lagcutoff_s>0) {
	// __ Vector of weights (same ID)
		time_gap_i = abs(time1[t,1] :- time1)
		if (hac_signal_s==1) {
			weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
		}
		else {
			weight =  (time_gap_i :<= lagcutoff_s)
		}
		w[s..e,1] = weight
	}
	else {
	w[s..e,1] = time1:==time[pos,1]
	//w[s..e,1] = J(t1,1,0)
	//w[pos,1] = 1
	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz)
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP 
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
	}	
	
	ind = ind + t1
}

*
}
*
//*mata: V[1..5,1..5]

_makesymmetric(V)

}

end


*********************************************************************************************

capt program drop acreg_cluster
program acreg_cluster, eclass
	version 12
	syntax [,  storeweights ] // storedistances to be implemented 


*
/*
* First stage
mata: PZ=Z*invsym(Z'Z)*Z'
mata: MZ=I(rows(PZ))-PZ


mata: X1=Xe[.,1] 
mata: X2=Xe[.,2]

mata: gamma1=PZ * X1
*mata: rows(gamma1)
mata: resX1 = MZ * X1

mata: VCV1 = PZ * (resX1 * resX1' :* cluster) * PZ'
mata: VCV1 = VCV1[|1,1\16,16|]

mata: F1 = (gamma1[.,1..Niv]'*invsym(VCV1)*gamma1[.,1..Niv])/Niv
*/

mata {

// 2SLS: VCV
V = J(K,K, 0)
nonzero = 0
ind = 0
pos = 0

AVCVb_fs_1 = J(Nie,Nie, 0) 		// -------------------------- KP 
AVCVb_fs = J(Nie,Nie, 0)   		// -------------------------- KP 


Idunique = uniqrows(id_vec)
NId = rows(Idunique)

if ("`storeweights'" == "storeweights"){
weigg = J(N,N, 0)
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)

	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
	
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
		// a) Computing link vector
		link_vec_temp = J(N,1, 0)
		link_vec_i = J(N,1, 0)
		cols_clus_mat = cols(cluster_mat)
		q=1
		for (q = 1; q <= cols_clus_mat; q++){
			link_vec_temp = link_vec_temp :+ (cluster_mat[pos,q] :== cluster_mat[.,q])
			link_vec_i = link_vec_temp:>0
		}

	
//	if (distcutoff_s>0) {	
	// a) Computing Weights
//		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
//		weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)) :* (time_dis_gap_i :<= lagdistcutoff_s) :* link_vec_i
//		w[.,1] = weight_dis
//	}
	w[.,1] = link_vec_i
//	if (lagcutoff_s>0) {
//	// __ Vector of weights (same ID)
//		time_gap_i = abs(time1[t,1] :- time1)
//		time_gap_cut_i = time_gap_i :<= lagcutoff_s
//		weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
//		w[s..e,1] = weight
//	}
//	else {
//	w[s..e,1] = J(t1,1,0)
	
	w[s..e,1] = time1:==time[pos,1]	
	*w[pos,1] = 1
	
//	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz) 
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1 
		weigg[.,pos] = w[.,1]
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
		
**adjj[.,ind+1] = w[.,1] // check
	}
	
	ind = ind + t1
}
st_matrix("weightsmat", weigg)
}
else {
for (i = 1; i <= NId; i++){

	rows_ni = id_vec:==Idunique[i,1] 
	
	// __ Get subsets of variables for ID i (without changing original matrix)
	time1 = select(time, rows_ni)
	t1 = length(time1)
	
	// __ Weights ID i vector
	w = J(N,1, 0)

	
	// __ Indicator variables (start, end)
	s = ind + 1
	e = ind + t1
	
	// __ Vector of weights (different ID)
	
	for (t = 1; t <= t1; t++){
	
	// __ Indicator variables (position in the vector)
	pos  = ind + t		
		// a) Computing link vector
		link_vec_temp = J(N,1, 0)
		link_vec_i = J(N,1, 0)
		cols_clus_mat = cols(cluster_mat)
		q=1
		for (q = 1; q <= cols_clus_mat; q++){
			link_vec_temp = link_vec_temp :+ (cluster_mat[pos,q] :== cluster_mat[.,q])
			link_vec_i = link_vec_temp:>0
		}

	
//	if (distcutoff_s>0) {	
	// a) Computing Weights
//		time_dis_gap_i = abs(time1[t,1] :- time[.,1])
//		weight_dis = (1 :- time_dis_gap_i :/ (lagdistcutoff_s +1)) :* (time_dis_gap_i :<= lagdistcutoff_s) :* link_vec_i
//		w[.,1] = weight_dis
//	}
	w[.,1] = link_vec_i
//	if (lagcutoff_s>0) {
//	// __ Vector of weights (same ID)
//		time_gap_i = abs(time1[t,1] :- time1)
//		time_gap_cut_i = time_gap_i :<= lagcutoff_s
//		weight = (1 :- time_gap_i :/ (lagcutoff_s +1)):* (time_gap_i :<= lagcutoff_s)
//		w[s..e,1] = weight
//	}
//	else {
//	w[s..e,1] = J(t1,1,0)
	
	w[s..e,1] = time1:==time[pos,1]	
	*w[pos,1] = 1
	
//	}
	// __ VCV	
		wz = w :> 0
		nonzero = nonzero + sum(wz) 
		V1 =  P * (res :* res[pos,1] * w[.,1]) * (P[.,pos])'
		V = V + V1 
		AVCVb_fs_1 = (I(Nend)#SzN) * ((vec(u) * u[pos,.]) :* (J(Nend,1, 1)# w[.,1])) * (I(Nend)#SzN[.,pos])' // -------------------------- KP
		AVCVb_fs =  AVCVb_fs + AVCVb_fs_1																	 // -------------------------- KP
		
**adjj[.,ind+1] = w[.,1] // check
	}
	
	ind = ind + t1
}
}

_makesymmetric(V)

}
end





























*********************************************************************************************

capt program drop  acreg_ranktest

* ranktest 1.4.01  18aug2015
* author mes, based on code by fk
* see end of file for version comments

*if c(version) < 12 {
* ranktest uses livreg2 Mata library.
* Ensure Mata library is indexed if new install.
* Not needed for Stata 12+ since ssc.ado does this when installing.
	capture mata: mata drop m_calckw()
	capture mata: mata drop m_omega()
	capture mata: mata drop ms_vcvorthog()
	capture mata: mata drop s_vkernel()
	capture mata: mata drop  acreg_s_rkstat()
	capture mata: mata drop acreg_cholqrsolve()
	mata: mata mlib index
*}

program define acreg_ranktest, rclass sortpreserve

	local lversion 01.4.01

*	if _caller() < 11 {
*		ranktest9 `0'
*		return add						//  otherwise all the ranktest9 results are zapped
*		return local ranktestcmd		ranktest9
*		return local cmd				ranktest
*		return local version			`lversion'
*		exit
*	}
	version 11.2

*	if substr("`1'",1,1)== "," {
*		if "`2'"=="version" {
*			di in ye "`lversion'"
*			return local version `lversion'
*			exit
*		}
*		else {
* 	di as err "invalid syntax"
*			exit 198
*		}
*	}

* If varlist 1 or varlist 2 have a single element, parentheses optional

	if substr("`1'",1,1)=="(" {
		acreg_GetVarlist `0'
		local y `s(varlist)'
		local 0 `"`s(rest)'"'
		sret clear
	}
	else {
		local y `1'
		mac shift 1
		local 0 `"`*'"'
	}

	if substr("`1'",1,1)=="(" {
		acreg_GetVarlist `0'
		local z `s(varlist)'
		local 0 `"`s(rest)'"'
		sret clear
	}
	else {
		local z `1'
		mac shift 1
* Need to reinsert comma before options (if any) for -syntax- command to work
		local 0 `", `*'"'
	}

// Note that y or z could be a varlist, e.g., "y1-y3", so they need to be unab-ed.
	tsunab y : `y'
	local K : word count `y'
	tsunab z : `z'
	local L : word count `z'

* Option version ignored here if varlists were provided
	syntax [if] [in] [aw fw pw iw/]				///
		[,										///
		partial(varlist ts)						///
		fwl(varlist ts)							///
		NOConstant								///
		wald									///
		ALLrank									///
		NULLrank								///
		FULLrank								///
		ROBust									///
		cluster(varlist)						///
		BW(string)								///
		kernel(string)							///
		Tvar(varname)							///
		Ivar(varname)							///
		sw										///
		psd0									///
		psda									///
		version									///
		dofminus(integer 0)						///
		mat_clst(string)						///
		]

	
	
	

		
	local partial		"`partial' `fwl'"
	local partial		: list retokenize partial

	local cons		= ("`noconstant'"=="")
	
	mat mat_clst=`mat_clst'
		

	if "`wald'"~="" {
		local LMWald "Wald"
	}
	else {
		local LMWald "LM"
	}
	
	local optct : word count `allrank' `nullrank' `fullrank'
	if `optct' > 1 {
di as err "Incompatible options: `allrank' `nullrank' `fullrank'"
		error 198
	}
	else if `optct' == 0 {
* Default
		local allrank "allrank"
	}

	local optct : word count `psd0' `psda'
	if `optct' > 1 {
di as err "Incompatible options: `psd0' `psda'"
		error 198
	}
	local psd	"`psd0' `psda'"
	local psd	: list retokenize psd

* Note that by tsrevar-ing here, subsequent disruption to the sort doesn't matter
* for TS operators.
	tsrevar `y'
	local vl1 `r(varlist)'
	tsrevar `z'
	local vl2 `r(varlist)'
	tsrevar `partial'
	local partial `r(varlist)'

	foreach vn of varlist `vl1' {
		tempvar tv
		qui gen double `tv' = .
		local tempvl1 "`tempvl1' `tv'"
	}
	foreach vn of varlist `vl2' {
		tempvar tv
		qui gen double `tv' = .
		local tempvl2 "`tempvl2' `tv'"
	}

	marksample touse
	markout `touse' `vl1' `vl2' `partial' `cluster', strok

* Stock-Watson and cluster imply robust.
	if "`sw'`cluster'" ~= "" {
		local robust "robust"
	}

	tempvar wvar
	if "`weight'" == "fweight" | "`weight'"=="aweight" {
		local wtexp `"[`weight'=`exp']"'
		gen double `wvar'=`exp'
	}
	if "`fsqrt(wf)*(wvar^0.5):*'" == "fweight" & "`kernel'" !="" {
		di in red "fweights not allowed (data are -tsset-)"
		exit 101
	}
	if "`weight'" == "fweight" & "`sw'" != "" {
		di in red "fweights currently not supported with -sw- option"
		exit 101
	}
	if "`weight'" == "iweight" {
		if "`robust'`cluster'`bw'" !="" {
			di in red "iweights not allowed with robust, cluster, AC or HAC"
			exit 101
		}
		else {
			local wtexp `"[`weight'=`exp']"'
			gen double `wvar'=`exp'
		}
	}
	if "`weight'" == "pweight" {
		local wtexp `"[aweight=`exp']"'
		gen double `wvar'=`exp'
		local robust "robust"
	}
	if "`weight'" == "" {
* If no weights, define neutral weight variable
		qui gen byte `wvar'=1
	}


* Every time a weight is used, must multiply by scalar wf ("weight factor")
* wf=1 for no weights, fw and iw, wf = scalar that normalizes sum to be N if aw or pw
		sum `wvar' if `touse' `wtexp', meanonly
* Weight statement
		if "`weight'" ~= "" {
di in gr "(sum of wgt is " %14.4e `r(sum_w)' ")"
		}
		if "`weight'"=="" | "`weight'"=="fweight" | "`weight'"=="iweight" {
* If weight is "", weight var must be column of ones and N is number of rows.
* With fw and iw, effective number of observations is sum of weight variable.
			local wf=1
			local N=r(sum_w)
		}
		else if "`weight'"=="aweight" | "`weight'"=="pweight" {
* With aw and pw, N is number of obs, unadjusted.
			local wf=r(N)/r(sum_w)
			local N=r(N)
		}
		else {
* Should never reach here
di as err "ranktest error - misspecified weights"
			exit 198
		}

* HAC estimation.
* If bw is omitted, default `bw' is empty string.
* If bw or kernel supplied, check/set `kernel'.
* Macro `kernel' is also used for indicating HAC in use.
	if "`bw'" == "" & "`kernel'" == "" {
		local bw=0
	}
	else {
* Need tvar for markout with time-series stuff
* Data must be tsset for time-series operators in code to work
* User-supplied tvar checked if consistent with tsset
		capture tsset
		if "`r(timevar)'" == "" {
di as err "must tsset data and specify timevar"
			exit 5
		}
		if "`tvar'" == "" {
			local tvar "`r(timevar)'"
		}
		else if "`tvar'"!="`r(timevar)'" {
di as err "invalid tvar() option - data already -tsset-"
			exit 5
		}
* If no panel data, ivar will still be empty
		if "`ivar'" == "" {
			local ivar "`r(panelvar)'"
		}
		else if "`ivar'"!="`r(panelvar)'" {
di as err "invalid ivar() option - data already -tsset-"
			exit 5
		}
		local tdelta `r(tdelta)'
		tsreport if `touse', panel
		if `r(N_gaps)' != 0 {
di in gr "Warning: time variable " in ye "`tvar'" in gr " has " /*
	*/ in ye "`r(N_gaps)'" in gr " gap(s) in relevant range"
		}

* Check it's a valid kernel and replace with unabbreviated kernel name; check bw.
* Automatic kernel selection allowed by ivreg2 but not ranktest so must trap.
* s_vkernel is in livreg2 mlib.
		if "`bw'"=="auto" {
di as err "invalid bandwidth in option bw() - must be real > 0"
			exit 198
		}
		mata: s_vkernel("`kernel'", "`bw'", "`ivar'")
		local kernel `r(kernel)'
		local bw = `r(bw)'
	}

* tdelta missing if version 9 or if not tsset			
	if "`tdelta'"=="" {
		local tdelta=1
	}

	if "`sw'"~="" {
		capture xtset
		if "`ivar'" == "" {
			local ivar "`r(panelvar)'"
		}
		else if "`ivar'"!="`r(panelvar)'" {
di as err "invalid ivar() option - data already tsset or xtset"
			exit 5
		}
* Exit with error if ivar is neither supplied nor tsset nor xtset
		if "`ivar'"=="" {
di as err "Must -xtset- or -tsset- data or specify -ivar- with -sw- option"
			exit 198
		}
		qui describe, short varlist
		local sortlist "`r(sortlist)'"
		tokenize `sortlist'
		if "`ivar'"~="`1'" {
di as err "Error - dataset must be sorted on panel var with -sw- option"
			exit 198
		}
	}

* Create variable used for getting lags etc. in Mata
	tempvar tindex
	qui gen `tindex'=1 if `touse'
	qui replace `tindex'=sum(`tindex') if `touse'

********** CLUSTER SETUP **********************************************

* Mata code requires data are sorted on (1) the first var cluster if there
* is only one cluster var; (2) on the 3rd and then 1st if two-way clustering,
* unless (3) two-way clustering is combined with kernel option, in which case
* the data are tsset and sorted on panel id (first cluster variable) and time
* id (second cluster variable).
* Second cluster var is optional and requires an identifier numbered 1..N_clust2,
* unless combined with kernel option, in which case it's the time variable.
* Third cluster var is the intersection of 1 and 2, unless combined with kernel
* opt, in which case it's unnecessary.
* Sorting on "cluster3 cluster1" means that in Mata, panelsetup works for
* both, since cluster1 nests cluster3.
* Note that it is possible to cluster on time but not panel, in which case
* cluster1 is time, cluster2 is empty and data are sorted on panel-time.
* Note also that if data are sorted here but happen to be tsset, will need
* to be re-tsset after estimation code concludes.


// No cluster options or only 1-way clustering
// but for Mata and other purposes, set N_clust vars =0
	local N_clust=0
	local N_clust1=0
	local N_clust2=0
	if "`cluster'"!="" {
		local clopt "cluster(`cluster')"
		tokenize `cluster'
		local cluster1 "`1'"
		local cluster2 "`2'"
		if "`kernel'"~="" {
* kernel requires either that cluster1 is time var and cluster2 is empty
* or that cluster1 is panel var and cluster2 is time var.
* Either way, data must be tsset and sorted for panel data.
			if "`cluster2'"~="" {
* Allow backwards order
				if "`cluster1'"=="`tvar'" & "`cluster2'"=="`ivar'" {
					local cluster1 "`2'"
					local cluster2 "`1'"
				}
				if "`cluster1'"~="`ivar'" | "`cluster2'"~="`tvar'" {
di as err "Error: cluster kernel-robust requires clustering on tsset panel & time vars."
di as err "       tsset panel var=`ivar'; tsset time var=`tvar'; cluster vars=`cluster1',`cluster2'"
					exit 198
				}
			}
			else {
				if "`cluster1'"~="`tvar'" {
di as err "Error: cluster kernel-robust requires clustering on tsset time variable."
di as err "       tsset time var=`tvar'; cluster var=`cluster1'"
					exit 198
				}
			}
		}
* Simple way to get quick count of 1st cluster variable without disrupting sort
* clusterid1 is numbered 1.._Nclust1.
		tempvar clusterid1
		qui egen `clusterid1'=group(`cluster1') if `touse'
		sum `clusterid1' if `touse', meanonly
		if "`cluster2'"=="" {
			local N_clust=r(max)
			local N_clust1=`N_clust'
			if "`kernel'"=="" {
* Single level of clustering and no kernel-robust, so sort on single cluster var.
* kernel-robust already sorted via tsset.
				sort `cluster1'
			}
		}
		else {
			local N_clust1=r(max)
			if "`kernel'"=="" {
				tempvar clusterid2 clusterid3
* New cluster id vars are numbered 1..N_clust2 and 1..N_clust3
				qui egen `clusterid2'=group(`cluster2') if `touse'
				qui egen `clusterid3'=group(`cluster1' `cluster2') if `touse'
* Two levels of clustering and no kernel-robust, so sort on cluster3/nested in/cluster1
* kernel-robust already sorted via tsset.
				sort `clusterid3' `cluster1'
				sum `clusterid2' if `touse', meanonly
				local N_clust2=r(max)
			}
			else {
* Need to create this only to count the number of clusters
				tempvar clusterid2
				qui egen `clusterid2'=group(`cluster2') if `touse'
				sum `clusterid2' if `touse', meanonly
				local N_clust2=r(max)
* Now replace with original variable
				local clusterid2 `cluster2'
			}

			local N_clust=min(`N_clust1',`N_clust2')

		}		// end 2-way cluster block
	}		// end cluster block

************************************************************************************************

* Note that bw is passed as a value, not as a string
	
	mata: acreg_s_rkstat(						///
					"`vl1'",			///
					"`vl2'",			///
					"`partial'",		///
					"`wvar'",			///
					"`weight'",			///
					`wf',				///
					`N',				///
					`cons',				///
					"`touse'",			///
					"`LMWald'",			///
					"`allrank'",		///
					"`nullrank'",		///
					"`fullrank'",		///
					"`robust'",			///
					"`clusterid1'",		///
					"`clusterid2'",		///
					"`clusterid3'",		///
					`bw',				///
					"`tvar'",			///
					"`ivar'",			///
					"`tindex'",			///
					`tdelta',			///
					`dofminus',			///
					"`kernel'",			///
					"`sw'",				///
					"`psd'",			///
					"`tempvl1'",		///
					"`tempvl2'",		///
					"`mat_clst'"		///
					) 

	tempname rkmatrix chi2 df df_r p rank ccorr eval mat_clst
	mat `rkmatrix'=r(rkmatrix)
	mat `ccorr'=r(ccorr)
	mat `eval'=r(eval)
	mat colnames `rkmatrix' = "rk" "df" "p" "rank" "eval" "ccorr"
	mat `mat_clst'=r(mat_clst)
	
di
di "Kleibergen-Paap rk `LMWald' test of rank of matrix"
	if "`robust'"~="" & "`kernel'"~= "" & "`cluster'"=="" {
di "  Test statistic robust to heteroskedasticity and autocorrelation"
di "  Kernel: `kernel'   Bandwidth: `bw'"
	}
	else if "`kernel'"~="" & "`cluster'"=="" {
di "  Test statistic robust to autocorrelation"
di "  Kernel: `kernel'   Bandwidth: `bw'"
	}
	else if "`cluster'"~="" {
di "  Test statistic robust to heteroskedasticity and clustering on `cluster'"
		if "`kernel'"~="" {
di "  and kernel-robust to common correlated disturbances"
di "  Kernel: `kernel'   Bandwidth: `bw'"
		}
	}
	else if "`robust'"~="" {
di "  Test statistic robust to heteroskedasticity"
	}
	else if "`LMWald'"=="LM" {
di "  Test assumes homoskedasticity (Anderson canonical correlations test)"
	}
	else {
di "  Test assumes homoskedasticity (Cragg-Donald test)"
	}
		
	local numtests = rowsof(`rkmatrix')
	forvalues i=1(1)`numtests' {
di "Test of rank=" %3.0f `rkmatrix'[`i',4] "  rk=" %8.2f `rkmatrix'[`i',1] /*
	*/	"  Chi-sq(" %3.0f `rkmatrix'[`i',2] ") pvalue=" %8.6f `rkmatrix'[`i',3]
	}
	scalar `chi2' = `rkmatrix'[`numtests',1]
	scalar `p' = `rkmatrix'[`numtests',3]
	scalar `df' = `rkmatrix'[`numtests',2]
	scalar `rank' = `rkmatrix'[`numtests',4]
	local N `r(N)'
	return scalar df = `df'
	return scalar chi2 = `chi2'
	return scalar p = `p'
	return scalar rank = `rank'
	if "`cluster'"~="" {
		return scalar N_clust = `N_clust'
	}
	if "`cluster2'"~="" {
		return scalar N_clust1 = `N_clust1'
		return scalar N_clust2 = `N_clust2'
	}
	return scalar N = `N'
	return matrix rkmatrix `rkmatrix'
	return matrix ccorr `ccorr'
	return matrix eval `eval'
	
	return matrix mat_clst `mat_clst'
	
	tempname S V Omega
	if `K' > 1 {
		foreach en of local y {
* Remove "." from equation name
			local en1 : subinstr local en "." "_", all
			foreach vn of local z {
				local cn "`cn' `en1':`vn'"
			}
		}
	}
	else {
		foreach vn of local z {
		local cn "`cn' `vn'"
		}
	}

	mat `V'=r(V)
	matrix colnames `V' = `cn'
	matrix rownames `V' = `cn'
	return matrix V `V'
	mat `S'=r(S)
	matrix colnames `S' = `cn'
	matrix rownames `S' = `cn'
	return matrix S `S'

	return local cmd		"ranktest"
	return local version	`lversion'
end


* Adopted from -canon-
capt program drop acreg_GetVarlist
program define acreg_GetVarlist, sclass 
	version 11.2
	sret clear
	gettoken open 0 : 0, parse("(") 
	if `"`open'"' != "(" {
		error 198
	}
	gettoken next 0 : 0, parse(")")
	while `"`next'"' != ")" {
		if `"`next'"'=="" { 
			error 198
		}
		local list `list'`next'
		gettoken next 0 : 0, parse(")")
	}
	sret local rest `"`0'"'
	tokenize `list'
	local 0 `*'
	sret local varlist "`0'"
end


********************* EXIT IF STATA VERSION < 11 ********************************

* When do file is loaded, exit here if Stata version calling program is < 11.
* Prevents loading of rest of program file (would cause e.g. Stata 10 to crash at Mata).

if c(stata_version) < 11 {
	exit
}

******************** END EXIT IF STATA VERSION < 9 *****************************

*******************************************************************************
*************************** BEGIN MATA CODE ***********************************
*******************************************************************************

version 11.2
mata:

// ********* MATA CODE SHARED BY ivreg2 AND ranktest       *************** //
// ********* 1. struct ms_vcvorthog                        *************** //
// ********* 2. m_omega                                    *************** //
// ********* 3. m_calckw                                   *************** //
// ********* 4. s_vkernel                                  *************** //
// *********************************************************************** //

// For reference:
 struct ms_vcvorthog {
 	string scalar	ename, Znames, touse, weight, wvarname
 	string scalar	robust, clustvarname, clustvarname2, clustvarname3, kernel
 	string scalar	sw, psd, ivarname, tvarname, tindexname
 	real scalar		wf, N, bw, tdelta, dofminus
    real scalar		center
 	real matrix		ZZ
 	pointer matrix	e
 	pointer matrix	Z
 	pointer matrix	wvar
 }

void acreg_s_rkstat(	string scalar vl1,
				string scalar vl2,
				string scalar partial,
				string scalar wvarname,
				string scalar weight,
				scalar wf,
				scalar N,
				scalar cons,
				string scalar touse,
				string scalar LMWald,
				string scalar allrank,
				string scalar nullrank,
				string scalar fullrank,
				string scalar robust,
				string scalar clustvarname,
				string scalar clustvarname2,
				string scalar clustvarname3,
				bw,
				string scalar tvarname,
				string scalar ivarname,
				string scalar tindexname,
				tdelta,
				dofminus,
				string scalar kernel,
				string scalar sw,
				string scalar psd,
				string scalar tempvl1,
				string scalar tempvl2,
				string scalar mat_clst)
{

// iid flag used below
	iid = ((kernel=="") & (robust=="") & (clustvarname==""))

// tempx, tempy and tempz are the Stata names of temporary variables that will be changed by acreg_s_rkstat
	tempy=tokens(tempvl1)
	tempz=tokens(tempvl2)
	tempx=tokens(partial)

	st_view(y=.,.,tokens(vl1),touse)
	st_view(z=.,.,tokens(vl2),touse)
	st_view(yhat=.,.,tempy,touse)
	st_view(zhat=.,.,tempz,touse)
	if (partial~="") {
		st_view(x=.,.,tempx,touse)
	}
	st_view(mtouse=.,.,tokens(touse),touse)
	st_view(wvar=.,.,tokens(wvarname),touse)
	noweight=(st_vartype(wvarname)=="byte")

	K=cols(y)							//  count of vars in first varlist
	L=cols(z)							//  count of vars in second varlist
	P=cols(x)							//  count of vars to be partialled out (excluding constant)

// Note that we now use wf*wvar instead of wvar
// because wvar is raw weighting variable and
// wf*wvar normalizes so that sum(wf*wvar)=N.

// Partial out the X variables.
// Note that this includes demeaning if there is a constant,
//   i.e., variables are centered.
	if (cons & P>0) {					//  Vars to partial out including constant
		ymeans = mean(y,wf*wvar)
		zmeans = mean(z,wf*wvar)
		xmeans = mean(x,wf*wvar)
		xy = quadcrossdev(x, xmeans, wf*wvar, y, ymeans)
		xz = quadcrossdev(x, xmeans, wf*wvar, z, zmeans)
		xx = quadcrossdev(x, xmeans, wf*wvar, x, xmeans)
	}
	else if (!cons & P>0) {				//  Vars to partial out NOT including constant
		xy = quadcross(x, wf*wvar, y)
		xz = quadcross(x, wf*wvar, z)
		xx = quadcross(x, wf*wvar, x)
	}
	else {								//  Only constant to partial out = demean
		ymeans = mean(y,wf*wvar)
		zmeans = mean(z,wf*wvar)
	}
//	Partial-out coeffs. Default Cholesky; use QR if not full rank and collinearities present.
//	Not necessary if no vars other than constant
	if (P>0) {
		by = acreg_cholqrsolve(xx, xy)
		bz = acreg_cholqrsolve(xx, xz)
	}
//	Replace with residuals
	if (cons & P>0) {					//  Vars to partial out including constant
		yhat[.,.] = (y :- ymeans) - (x :- xmeans)*by
		zhat[.,.] = (z :- zmeans) - (x :- xmeans)*bz
	}
	else if (!cons & P>0) {				//  Vars to partial out NOT including constant
		yhat[.,.] = y - x*by
		zhat[.,.] = z - x*bz
	}
	else if (cons) {					//  Only constant to partial out = demean
		yhat[.,.] = (y :- ymeans)
		zhat[.,.] = (z :- zmeans)
	}
	else {								//  no transformations required
		yhat[.,.] = y
		zhat[.,.] = z
	}

	zhzh = quadcross(zhat, wf*wvar, zhat)
	zhyh = quadcross(zhat, wf*wvar, yhat)
	yhyh = quadcross(yhat, wf*wvar, yhat)

//	pihat = invsym(zhzh)*zhyh
	pihat = acreg_cholqrsolve(zhzh, zhyh)

// rzhat is F in paper (p. 103)
// iryhat is G in paper (p. 103)
	ryhat=cholesky(yhyh)
	rzhat=cholesky(zhzh)
	iryhat=luinv(ryhat')
	irzhat=luinv(rzhat')
	that=rzhat'*pihat*iryhat

// cc is canonical correlations.  Squared cc is eigenvalues.
	fullsvd(that, ut, cc, vt)
	vt=vt'
	vecth=vec(that)
	ev = cc:^2
// S matrix in paper (p. 100).  Not used in code below.
//	smat=fullsdiag(cc, rows(that)-cols(that))

	if (abs(1-cc[1,1])<1e-10) {
printf("\n{text:Warning: collinearities detected between (varlist1) and (varlist2)}\n")
	}
	if ((missing(ryhat)>0) | (missing(iryhat)>0) | (missing(rzhat)>0) | (missing(irzhat)>0)) {
printf("\n{error:Error: non-positive-definite matrix. May be caused by collinearities.}\n")
		exit(error(3351))
	}

// If Wald, yhat is residuals
	if (LMWald=="Wald") {
		yhat[.,.]=yhat-zhat*pihat
		yhyh = quadcross(yhat, wvar, yhat)
	}

// Covariance matrices
// vhat is W in paper (eqn below equation 17, p. 103)
// shat is V in paper (eqn below eqn 15, p. 103)


	
// ************************************************************************************* //
// shat calculated using struct and programs m_omega, m_calckw shared with ivreg2        //

	struct ms_vcvorthog scalar vcvo


	vcvo.ename			= tempy		// ivreg2 has = ename //
	vcvo.Znames			= tempz		// ivreg2 has = Znames //
	vcvo.touse			= touse
	vcvo.weight			= weight
	vcvo.wvarname		= wvarname
	vcvo.robust			= robust
	vcvo.clustvarname	= clustvarname
	vcvo.clustvarname2	= clustvarname2
	vcvo.clustvarname3	= clustvarname3
	vcvo.kernel			= kernel
	vcvo.sw				= sw
	vcvo.psd			= psd
	vcvo.ivarname		= ivarname
	vcvo.tvarname		= tvarname
	vcvo.tindexname		= tindexname
	vcvo.wf				= wf
	vcvo.N				= N
	vcvo.bw				= bw
	vcvo.tdelta			= tdelta
	vcvo.dofminus		= dofminus
	vcvo.ZZ				= zhzh		// ivreg2 has = st_matrix(ZZmatrix) //
	
	vcvo.e		= &yhat				// ivreg2 has = &e	//
	vcvo.Z		= &zhat				// ivreg2 has = &Z //
	vcvo.wvar	= &wvar

	shat=m_omega(vcvo)

	mat_clst=st_matrix(mat_clst)

	shat = mat_clst
	
// ***************************************************************************************

// prepare to start collecting test stats
	if (allrank~="") {
		firstrank=1
		lastrank=min((K,L))
	}
	else if (nullrank~="") {
		firstrank=1
		lastrank=1
	}
	else if (fullrank~="") {
		firstrank=min((K,L))
		lastrank=min((K,L))
	}
	else {
// should never reach this point
printf("ranktest error\n")
		exit
	}

// where results will go
	rkmatrix=J(lastrank-firstrank+1,6,.)

// ***************************************************************************************
// Calculate vector of canonical correlations test statistics.
// All we need if iid case.
	rkvec = ev									//  Initialize vector with individual eigenvalues.
	if (LMWald~="LM") {							//  LM is sum of min evals, Wald is sum of eval/(1-eval)
		rkvec = rkvec :/ (1 :- rkvec)
	}
	for (i=(rows(rkvec)-1); i>=1; i--) {		//  Now loop through and sum the eigenvalues.
		rkvec[i,1] = rkvec[i+1,1] + rkvec[i,1]
	}
	rkvec = N*rkvec								//  Multiply by N to get the test statistics.

// ***************************************************************************************

// Finally, calcluate vhat	
	if ((LMWald=="LM") & (iid)) {
// Homoskedastic, iid LM case means vcv is identity matrix
// Generates canonical correlation stats.  Default.
		vhat=I(L*K,L*K)/N
	}
	else {
		vhat=(iryhat'#irzhat')*shat*(iryhat'#irzhat')' * N
		_makesymmetric(vhat)
// Homoskedastic iid Wald case means vcv has block-diag identity matrix structure.
// Enforce this by setting ~0 entries to 0.  If iid, vhat not used in calcs, for reporting only.
		if ((LMWald=="Wald") & (iid)) {
			vhat = vhat :* (J(K,K,1)#I(L))
		}
	}

// ***************************************************************************************
// Loop through ranks and collect test stats, dfs, p-values, ranks, evs and ev^2 (=ccs)

	for (i=firstrank; i<=lastrank; i++) {
		if (iid) {							//  iid case = canonical correlations test
			rk = rkvec[i,1]
			}
		else {								//  non-iid case
			if (i>1) {
				u12=ut[(1::i-1),(i..L)]
				v12=vt[(1::i-1),(i..K)]
			}
			u22=ut[(i::L),(i..L)]
			v22=vt[(i::K),(i..K)]
			
			symeigensystem(u22*u22', evec, eval)
			u22v=evec
			u22d=diag(eval)
			u22h=u22v*(u22d:^0.5)*u22v'
	
			symeigensystem(v22*v22', evec, eval)
			v22v=evec
			v22d=diag(eval)
			v22h=v22v*(v22d:^0.5)*v22v'
	
			if (i>1) {
				aq=(u12 \ u22)*luinv(u22)*u22h
				bq=v22h*luinv(v22')*(v12 \ v22)'
			}
			else {
				aq=u22*luinv(u22)*u22h
				bq=v22h*luinv(v22')*v22'
			}
	
// lab is lambda_q in paper (eqn below equation 21, p. 104)
// vlab is omega_q in paper (eqn 19 in paper, p. 104)
			lab=(bq#aq')*vecth
			vlab=(bq#aq')*vhat*(bq#aq')'
	
// Symmetrize if numerical inaccuracy means it isn't
			_makesymmetric(vlab)
			vlabinv=invsym(vlab)
// rk stat Assumption 2: vlab (omega_q in paper) is nonsingular.  Detected by a zero on the diagonal,
// since when returning a generalized inverse, Stata/Mata choose the generalized inverse that
// sets entire column(s)/row(s) to zeros.
			if (diag0cnt(vlabinv)>0) {
				rk = .
printf("\n{text:Warning: covariance matrix omega_%f}", i-1)
printf("{text: not full rank; test of rank %f}", i-1)
printf("{text: unavailable}\n")
			}
// Note not multiplying by N - already incorporated in vhat.
			else {
				rk=lab'*vlabinv*lab
			}
		}												//  end non-iid case
// at this point rk has value of test stat
// fill out rest of row of rkmatrix
// save df, rank, etc. even if test stat not available.
		df=(L-i+1)*(K-i+1)
		pvalue=chi2tail(df, rk)
		rkmatrix[i-firstrank+1,1]=rk
		rkmatrix[i-firstrank+1,2]=df
		rkmatrix[i-firstrank+1,3]=pvalue
		rkmatrix[i-firstrank+1,4]=i-1
		rkmatrix[i-firstrank+1,5]=ev[i-firstrank+1,1]
		rkmatrix[i-firstrank+1,6]=cc[i-firstrank+1,1]
// end of test loop
	}

// ***************************************************************************************
// Finish up and return results

	st_matrix("r(rkmatrix)", rkmatrix)
	st_matrix("r(ccorr)", cc')
	st_matrix("r(eval)",ev')
// Save V matrix as in paper, without factor of 1/N
	vhat=N*vhat*wf
	st_matrix("r(V)", vhat)
// Save S matrix as in ivreg2, with factor of 1/N
	st_matrix("r(S)", shat)
	st_numscalar("r(N)", N)
	if (clustvarname~="") {
		st_numscalar("r(N_clust)", N_clust)
	}
	if (clustvarname2~="") {
		st_numscalar("r(N_clust2)", N_clust2)
	}
// end of program
	st_matrix("r(mat_clst)", mat_clst)



}

// Mata utility for sequential use of solvers
// Default is cholesky;
// if that fails, use QR;
// if overridden, use QR.

function acreg_cholqrsolve (	numeric matrix A,
						numeric matrix B,
						| real scalar useqr)
{
	if (args()==2) useqr = 0
	
	real matrix C

	if (!useqr) {
		C = cholsolve(A, B)
		if (C[1,1]==.) {
			C = qrsolve(A, B)
		}
	}
	else {
		C = qrsolve(A, B)
	}

	return(C)

}

end



