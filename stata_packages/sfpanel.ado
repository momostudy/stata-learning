*! version 1.2.3 22may2015

* See versioning end of file

program define sfpanel, eclass byable(onecall) prop(xt svyb svyj swml)

    if _by() {
        local BY `"by `_byvars'`_byrc0':"'
    }
	`BY' _vce_parserun sfpanel, panel mark(I T) : `0'
	if "`s(exit)'" != "" {
		version 11: ereturn local cmdline `"sfpanel `0'"'
		exit
	}
    capt findfile sfcross.ado
    if _rc {
        di as error "-sfcross- is required; type {stata net install sfcross}"
        error 499
    }
  
    version 11
                
        if replay() {
            if _by() { 
                error 190 
            }
            if "`e(cmd)'" != "sfpanel" {
                error 301
            }
                DiSpLaY `0'
                exit
            }
		
    if _by() {
        by `_byvars' `_byrc0': sfpanel_est `0'
    }       
    else sfpanel_est `0'
    version 11: ereturn local cmdline `"sfpanel `0'"'
end



program define sfpanel_est, eclass byable(recall) sortpreserve

version 11
syntax varlist(min=2 fv ts) [if] [in] [aweight fweight iweight pweight/] , [ Model(string) Distribution(string) NOCONS COST  ///
                        VCE(passthru) CLuster(passthru) Robust Level(cilevel) ///
						CONSTRaints(numlist min=1) FESHOW ///
                        Emean(string) Usigma(string) Vsigma(string) BT(string) ///
						SVFRONTier(string) SVEMean(string) SVUsigma(string) SVVsigma(string) from(string) ///
						SVBT(string) SVSIGMA(string) SVGAMMA(string) SVETA(string) ///
                        SIMTYPE(string) NSIMulations(integer 250) BASE(integer 7) ///
                        TECHnique(string) ITERate(integer 100) NOWARNing DIFFICULT NOLOG ///
                        TRace GRADient SHOWSTEP HESSian SHOWTOLerance TOLerance(real 1e-6) ///
                        LTOLerance(real 1e-7) NRTOLerance(real 1e-5) ///
                        NOSEARCH REPEAT(integer 10) RESTART RESCale POSTSCORE POSTHESSian *] 


*** Is.estimation
local __PrEdIcT__ 0

*** Clear ereturn macro
ereturn clear

*** Check for Panel setup                             
_xt, trequired

*** Marksample:
marksample touse, strok

*** Parsing of display options
_get_diopts diopts options, `options'

*** Weights
tempvar usrwgt
local ivar: char _dta[_TSpanel]
if "`weight'" != "" {
	gen double `usrwgt' = `exp'
	cap by `ivar':assert `usrwgt' ==	///
		`usrwgt'[_n-1] if _n > 1
	if _rc {
		noi di as error 		///
		 "weight must be constant within `ivar'"
		exit 199
	}
	local __equal "="
}

*** Parsing vce options
local crittype "Log likelihood"

_vce_parse, argopt(CLuster) opt(OIM OPG Robust) old	///
: [`weight' `__equal' `exp'], `vce' `robust' `cluster'

local vce "`r(vce)'"
if "`vce'"=="cluster" {
	local vcetype "Robust"
	local clustervar "`r(cluster)'"
	local crittype "Log pseudolikelihood"
}
if "`vce'"=="robust" {
	local vce "cluster"
	local clustervar "`ivar'"
	local crittype "Log pseudolikelihood"
}
if "`vce'"=="oim" local vcetype "OIM"
if "`vce'"=="opg" local vcetype "OPG"	


*** Parsing model
ParseMod model : `"`model'"'

*** Parsing distributions
ParseDistr distribution : `"`distribution'"' `"`model'"'

*** Simulation type for TRE
ParseSimtype simtype : `"`simtype'"' `"`model'"'

**********************************************************
*** Cost or Production?

    if "`cost'" != "" {         
        scalar S_COST=-1
        local function "cost" 
    }
    else {
        scalar S_COST=1
        local function "production"
    } 

if "`usigma'"!="" local u "u"
if "`vsigma'"!="" local v "v"


*************** Errors *************  

if "`from'"!="" {
	noi di as err "Option from() not allowed. Use sv{it:eqnname}() options."
    error 198
    exit
}

if "`u'`v'"!="" & ("`model'"!="tfe" & "`model'"!="tre" & "`model'"!="bc95") {
	noi di as err "model(`model') cannot be heteroskedastic."
    error 198
    exit
}

if "`emean'"!="" & ("`model'"!="tfe" & "`model'"!="tre" & "`model'"!="bc95") {
	noi di as err "Conditional mean model is not allowed for model(`model')."
    error 198
    exit
}

if "`vce'"=="cluster" & "`constraints'"!="" {
	if "`model'"!="regls" { 
		noi di as err "option `vce' not allowed with option constraints()."
		error 198
		exit
	}
}


if "`model'"=="tfe" & "`nocons'"!="" {
    noi di as err "nocons option not allowed with tfe model."
    error 198
    exit
}

if ("`model'"=="regls" | "`model'"=="fe")  & "`nocons'"!="" {
    noi di as err "nocons option not allowed with `model' models."
    error 198
    exit
}

if ("`model'"=="regls" | "`model'"=="fels" | "`model'"=="css")  & "`weight'"!="" {
    noi di as err "`weight' not allowed with model(`model')."
    error 198
    exit
}

if ("`model'"=="fels" | "`model'"=="fecss" | "`model'"=="regls") & "`constraints'"!="" {
    di in gr "Warning: Option constraint(`constraints') will be ignored."
}

if ("`bt'"!="")  & "`model'"!="kumb90" {
    noi di as err "bt(`bt') option can be specified only with Kumbhakar (1990) model."
    error 198
    exit
}

if ("`sveta'"!="")  & "`model'"!="bc92" {
    noi di as err "`sveta' option can be specified only with Battese & Coelli (1992) model."
    error 198
    exit
}

if ("`svbt'"!="")  & "`model'"!="kumb90" {
    noi di as err "`svbt' option can be specified only with Kumbhakar (1990) model."
    error 198
    exit
}

noi di ""
*************************************

/// Fix crittype in the case of simulated models
if "`model'"=="tre" local crittype "Log simulated-likelihood"
if "`model'"=="fels" local crittype "Sum of squared errors"

***********************************************************************************************************************
******* Assigns objects to correctly create _InIt_OpTiMiZaTiOn() and _PoSt_ReSuLt_of_EsTiMaTiOn() structures **********
***********************************************************************************************************************

*** Locals 
if "`model'"=="bc95" & "`technique'"=="" local technique "bfgs"
else if "`technique'"=="" local technique "nr"
if "`difficult'"!="" local difficult "hybrid"
else local difficult "m-marquardt"
/// Hybrid default for these two models
if ("`model'"=="bc92" | "`model'"=="bc88") & "`difficult'"=="" local difficult "hybrid" 
if "`nowarning'"!="" local nowarning "on"
else local nowarning "off"
if "`nolog'"!="" local nolog "none"
else local nolog "value"
if "`trace'"!="" local trace "on"
else local trace "off"
if "`gradient'"!="" local gradient "on"
else local gradient "off"
if "`showstep'"!="" local showstep "on"
else local showstep "off"
if "`hessian'"!="" local hessian "on"
else local hessian "off"
if "`showtolerance'"!="" local showtolerance "on"
else local showtolerance "off"
if "`nosearch'"!="" local nosearch "off"
else local nosearch "on"
if "`restart'"!="" local restart "on"
else local restart "off"
if "`rescale'"!="" local rescale "on"
else local rescale "off"
/// Norescale default for these two models
if ("`model'"=="bc92" | "`model'"=="bc88") & "`rescale'"=="" local rescale "off"
/// Svy is currently disabled for panel data SF
//if "`r(wvar)'"!="" local InIt_svy "on"
//else local InIt_svy "off"
if "`exp'`weight'" != "" local weighted_est "on"
else local weighted_est "off"
if "`constraints'" != "" local constrained_est "on"
else local constrained_est "off"


*** Scalars
scalar TOLerance = `tolerance'
scalar LTOLerance = `ltolerance'
scalar NRTOLerance = `nrtolerance'
scalar MaXiterate = `iterate'
scalar REPEAT = `repeat'
scalar CILEVEL = `level'

*** Estimator specific:
** TRE
if "`model'"=="tre" {
	if "`simtype'"=="runiform" scalar Simtype = 1
	else if "`simtype'" == "halton" scalar Simtype = 2	
	else scalar Simtype = 3
	scalar Nsimulations = `nsimulations'
	scalar Base = `base'
}

************** Tokenize from varlist ***************
gettoken lhs rhs: varlist
local __erhs = trim(itrim("`rhs'"))
if "`usigma'"!="" gettoken u_rhs u_nocons: usigma, parse(",") 
if "`vsigma'"!="" gettoken v_rhs v_nocons: vsigma, parse(",")
if "`emean'"!="" gettoken e_rhs e_nocons: emean, parse(",")
if "`bt'"!="" gettoken bt_rhs bt_nocons: bt, parse(",")
local u_nocons=rtrim(ltrim(regexr("`u_nocons'", ",", "")))
local v_nocons=rtrim(ltrim(regexr("`v_nocons'", ",", "")))
local e_nocons=rtrim(ltrim(regexr("`e_nocons'", ",", "")))
local bt_nocons=rtrim(ltrim(regexr("`bt_nocons'", ",", "")))
****************************************************

********* Factor Variables check ****
_fv_check_depvar `lhs'

local fvops = "`s(fvops)'" == "true" | _caller() >= 11
if `fvops' {
    local vv : di "version " string(max(11,_caller())) ", missing:"
	local _noempty "noempty"
}

********* Factor Variables parsing ****
local fvars "rhs e_rhs u_rhs v_rhs bt_rhs"
foreach l of local fvars {
	if "`l'"!="rhs" & "`bt_rhs'"!="" {
		local nl = regexr("`l'","_","-") 
		gettoken _ok _garbage: nl, parse("-") quotes
		local fv_nocons "``_ok'_nocons'"	
	}
	if "`l'"=="rhs" local fv_nocons "`nocons'"
	if "``l''" != "" fvunab `l': ``l''
	fvexpand ``l''
	`vv' cap noi _rmcoll `r(varlist)' if `touse' [`weight' `__equal' `exp'], `fv_`nocons'' expand
	*** Get Names here
	local _`l'_names "`r(varlist)'"	
	foreach __var of local _`l'_names {
		_ms_parse_parts `__var'
		if `r(omit)' == 1 & "`r(type)'"=="factor" local _omit_ "o."
		else local _omit_ ""
		local new_`l' `new_`l'' `_omit_'`__var'
	}
	local `l' "`new_`l''"
}

*** update of esample
markout `touse' `u_rhs' `v_rhs' `e_rhs' `bt_rhs'

**********************************************************
******** Create appropriate id and time variables ********
**********************************************************
local id: char _dta[_TSpanel]
local time: char _dta[_TStvar]
tempvar temp_id temp_t
qui egen `temp_id' = group(`id') if `touse'==1
qui egen `temp_t' = group(`time') if `touse'==1
local lxtset "`temp_id' `temp_t'"
qui xtdes, pattern(0) width(0)
local imax = r(N)

********************** Display info ********************** 
tempvar Ti T_new
tempname g_min g_avg g_max N_g N Tcon Tbar
sort `temp_id' `temp_t'
qui by `temp_id': gen long `Ti' = _N if _n==_N & `touse'==1
qui summ `Ti' if `touse'==1, mean

*** Check for number of time occasion in tfe, fe, fels and fecss models
if (r(min) == 1 & ("`model'"=="tfe" | "`model'"=="fe" | "`model'"=="fels" | "`model'"=="fecss")) {
	di in yel "Warning: only units with more than 1 time occasion will be considered"
	tempvar _newtouse _maxTi_
	qui by `temp_id': egen `_maxTi_' = max(`Ti')
	qui gen `_newtouse' = `touse' if `_maxTi_'!=1
	markout `touse' `_newtouse'
}

qui summ `Ti' if `touse'==1, mean
scalar `Tcon' = (r(min)==r(max))
scalar `g_min' = r(min)
scalar `g_avg' = r(mean)
scalar `g_max' = r(max)
qui count if `Ti'<. & `touse'==1
scalar `N_g' = r(N)
qui count if `touse'==1
scalar `N' = r(N)
qui by `temp_id' : gen double `T_new' = 1/_N if _n==_N & `touse'==1
qui summ `T_new'
scalar `Tbar' = 1/r(mean)
qui drop `T_new'

***************************************************************************

*********************************************************************************************
******************** Starting values, variable names and initialisation *********************
*********************************************************************************************

*************** Count of parameters for starting values *******************
if "`model'" != "tfe" {
    if "`nocons'" != "" local nsv_frontier: word count `rhs'
    else {
		local nsv_frontier: word count `rhs' _cons
		local _frontcons _cons
	}
}
else local nsv_frontier: word count `rhs'

if "`e_nocons'" != "" local nsv_emean: word count `e_rhs'
else {
	local nsv_emean :word count `e_rhs' _cons
	local _econs _cons
}
if "`u_nocons'" != "" local nsv_usigma: word count `u_rhs'
else {
	local nsv_usigma :word count `u_rhs' _cons
	local _usigmacons _cons
}
if "`v_nocons'" != "" local nsv_vsigma: word count `v_rhs'
else {
	local nsv_vsigma :word count `v_rhs' _cons
	local _vsigmacons _cons
}
if "`bt'" == "" local nsv_bt = 2
else {
	if "`bt_nocons'" != "" local nsv_bt: word count `bt_rhs'
	else {
		local nsv_bt :word count `bt_rhs' _cons
		local _btcons _cons
	}
}
local nsv_eta 1
local nsv_sigma 1
local nsv_gamma 1

** Check if user's starting values matrices are conformable
local _checklist "frontier emean usigma vsigma bt sigma gamma eta"
foreach _check of local _checklist {
	if "`sv`_check''" != "" {
		if regexm("`sv`_check''","=") {
			local lsv`_check' "`sv`_check''"
			tempname sv`_check'
			_mkvec `sv`_check'', from(`lsv`_check'')
		}	

		cap confirm matrix `sv`_check''
		if _rc == 0 local _check_usv_`_check' = colsof(`sv`_check'')
		else {
			cap confirm scalar `sv`_check''
			if _rc == 0 local _check_usv_`_check' = 1
			else {
				local sv`_check' = itrim("`sv`_check''")	
				if regexm("`sv`_check''",",")==0 local sv`_check': subinstr local sv`_check' " " ", ", all
				else {
					noi di as err "Starting values in " in yel "sv`_check'()" in red " requires a numlist with only blanks in between."
			    	error 198
			    	exit
				}
				local _check_usv_`_check': word count `sv`_check''			
			}
		}
		
		if `_check_usv_`_check'' != `nsv_`_check'' {
			if "`_check'" == "eta" | "`_check'" == "sigma" | "`_check'" == "gamma"  {
				noi di as err "Too many starting values in " in yel "sv`_check'()."
		    	error 198
		    	exit
			}
			else {
				noi di as err "User specified starting values in " in yel "sv`_check'()" in red " do not match " in yel "`_check''s" in red " regressors number"
		    	error 198
		    	exit
		    }
		}
	}
}

// Refresh in order to allow time-series variables
qui xtset

/// Wald test ///
local _rhs_wald ""
local rhs_count: word count `_rhs_names'
forvalues i=1/`rhs_count' {
    local _rhs_var`i': word `i' of `_rhs_names'
    local _rhs_wald "`_rhs_wald' `_rhs_var`i'' ="
}


***************************************************************************

if "`model'"=="tfe" {

	local firms ""
	local NPANels = `N_g'
	forvalues f=1/`NPANels' {
		local firms "`firms' alpha`f'"
	}

	if "`distribution'"=="hnormal" {
		tempname init_beta init_usigma init_vsigma init_alpha alpha 
		if "`svfrontier'"=="" {
			tempname init_params
			cap qui sfcross `lhs' `rhs' if `touse'==1, d(hn) difficult `cost' u(`u_rhs' `u_nocons') v(`v_rhs' `v_nocons') iter(50)
			local _sfcross_conv "`e(converged)'"
			if _rc != 0 qui reg `lhs' `rhs'	if `touse'==1	
			mat `init_params'=e(b)
			scalar `alpha' = `init_params'[1,`nsv_frontier']
			mat `init_beta' = `init_params'[1,1..`nsv_frontier']
		}
		else mat `init_beta' = `svfrontier'
		mat colnames `init_beta' =`_rhs_names'
		mat coleq `init_beta' = "Frontier"
		
		if "`svusigma'"=="" {	
			if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_usigma' = `init_params'[1,`nsv_frontier'+1..`nsv_frontier'+`nsv_usigma']   
			else matrix `init_usigma' = J(1, `:word count `_u_rhs_names' `_usigmacons'', 1)  
		}
		else mat `init_usigma' = `svusigma'
		mat colnames `init_usigma' = `_u_rhs_names' `_usigmacons'
		mat coleq `init_usigma' = "Usigma"
		
		if "`svvsigma'"=="" {	
			if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_vsigma' = `init_params'[1,`nsv_frontier'+`nsv_usigma'+1..`nsv_frontier'+`nsv_usigma'+`nsv_vsigma']
			else matrix `init_vsigma' = J(1, `:word count `_v_rhs_names' `_vsigmacons'', 1)  
		}
		else mat `init_vsigma' = `svvsigma'				
		mat colnames `init_vsigma' = `_v_rhs_names' `_vsigmacons'
		mat coleq `init_vsigma' = "Vsigma"			
		
		if (("`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1") | "`e(cmd)'" =="regress") mat `init_alpha' = J(1,`N_g',`alpha')
		else matrix `init_alpha' = J(1,`N_g',.25)
		mat colnames `init_alpha' = `firms'
		mat coleq `init_alpha' = "Alpha"

		******************** This block MUST be included for each estimator ***********************
		local _params_list "init_beta init_usigma init_vsigma init_alpha"
		local _params_num = 1
		scalar InIt_nparams = wordcount("`_params_list'")
		/// Structure definition for initialisation
		mata: _SV = J(1, st_numscalar("InIt_nparams"), _starting_values())
		foreach _params of local _params_list {
			mata: _SV = _StArTiNg_VaLuEs("``_params''", `_params_num', _SV)	
			** The following to check the content of the structure ** Just for debugging
			*mata: liststruct(_SV)
			local _params_num = `_params_num' + 1
		}
		local InIt_evaluator "tv_tfe_hn"
		local InIt_evaluatortype "lf2"
		
		*** Parsing of constraints (if defined)
		_parse_constraints, constraintslist(`constraints') estparams(`init_beta', `init_usigma', `init_vsigma', `init_alpha')
	
		mata: _InIt_OpT = _InIt_OpTiMiZaTiOn()
		** The following to check the content of the structure ** Just for debugging
		*mata: liststruct(_InIt_OpT)
		*******************************************************************************************	
	} // Close distribution options

	if "`distribution'"=="exponential" {
		tempname init_beta init_usigma init_vsigma init_alpha alpha				

		if "`svfrontier'"=="" {
			tempname init_params
			cap qui sfcross `lhs' `rhs' if `touse'==1, d(e) `cost' u(`u_rhs' `u_nocons') v(`v_rhs' `v_nocons') iter(50)
			local _sfcross_conv "`e(converged)'"
			if _rc != 0 qui reg `lhs' `rhs' if `touse'==1
			mat `init_params'=e(b)
			scalar `alpha' = `init_params'[1,`nsv_frontier']
			mat `init_beta' = `init_params'[1,1..`nsv_frontier']
		}
		else mat `init_beta' = `svfrontier'
		mat colnames `init_beta' =`_rhs_names'
		mat coleq `init_beta' = "Frontier"
		
		if "`svusigma'"=="" {	
			if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_usigma' = `init_params'[1,`nsv_frontier'+1..`nsv_frontier'+`nsv_usigma']   
			else matrix `init_usigma' = J(1, `:word count `_u_rhs_names' `_usigmacons'', 1)  
		}
		else mat `init_usigma' = `svusigma'
		mat colnames `init_usigma' = `_u_rhs_names' `_usigmacons'
		mat coleq `init_usigma' = "Usigma"
		
		if "`svvsigma'"=="" {	
			if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_vsigma' = `init_params'[1,`nsv_frontier'+`nsv_usigma'+1..`nsv_frontier'+`nsv_usigma'+`nsv_vsigma']
			else matrix `init_vsigma' = J(1, `:word count `_v_rhs_names' `_vsigmacons'', 1)  
		}
		else mat `init_vsigma' = `svvsigma'				
		mat colnames `init_vsigma' = `_v_rhs_names' `_vsigmacons'
		mat coleq `init_vsigma' = "Vsigma"			
		
		if (("`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1") | "`e(cmd)'" =="regress") mat `init_alpha' = J(1,`N_g',`alpha')
		else matrix `init_alpha' = J(1,`N_g',.25)
		mat colnames `init_alpha' = `firms'
		mat coleq `init_alpha' = "Alpha"

		******************** This block MUST be included for each estimator ***********************
		local _params_list "init_beta init_usigma init_vsigma init_alpha"
		
		local _params_num = 1
		scalar InIt_nparams = wordcount("`_params_list'")
		/// Structure definition for initialisation
		mata: _SV = J(1, st_numscalar("InIt_nparams"), _starting_values())
		foreach _params of local _params_list {
			mata: _SV = _StArTiNg_VaLuEs("``_params''", `_params_num', _SV)	
			** The following to check the content of the structure ** Just for debugging
			*mata: liststruct(_SV)
			local _params_num = `_params_num' + 1
		}
		local InIt_evaluator "tv_tfe_exp"
		local InIt_evaluatortype "lf2"
		*** Parsing of constraints (if defined)
		_parse_constraints, constraintslist(`constraints') estparams(`init_beta', `init_usigma', `init_vsigma', `init_alpha')
	
		mata: _InIt_OpT = _InIt_OpTiMiZaTiOn()
		** The following to check the content of the structure ** Just for debugging
		*mata: liststruct(_InIt_OpT)
		*******************************************************************************************	
	} // Close distribution options
		
	if "`distribution'"=="tnormal" {
		
		local eqmu ""
		forvalues f=1/`nsv_emean' {
			local eqmu "`eqmu' Mu"
		}
		
		tempname init_beta init_emean init_usigma init_vsigma init_alpha alpha				
		
		if "`svfrontier'"=="" {
			tempname init_params
			cap qui sfcross `lhs' `rhs' if `touse'==1, d(tn) `cost' em(`emean' `e_nocons') u(`usigma' `u_nocons') v(`vsigma' `v_nocons') difficult iter(50)
			local _sfcross_conv "`e(converged)'"
			if _rc != 0 qui reg `lhs' `rhs' if `touse'==1
			mat `init_params' =e(b)
			scalar `alpha' = `init_params'[1,`nsv_frontier']
			mat `init_beta' = `init_params'[1,1..`nsv_frontier']
		}
		else mat `init_beta' = `svfrontier'
		mat colnames `init_beta' =`_rhs_names'
		mat coleq `init_beta' = "Frontier"
		
		if "`svemean'"=="" {
			if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_emean' = `init_params'[1,`nsv_frontier'+1..`nsv_frontier'+`nsv_emean']
			else matrix `init_emean' = J(1, `:word count `_e_rhs_names' `_econs'', .5)
		}
		else mat `init_emean' = `svemean'	
		mat colnames `init_emean' = `_e_rhs_names' `_econs'
		mat coleq `init_emean' = "Mu"
		if "`svusigma'"=="" {	
			if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_usigma' = `init_params'[1,`nsv_frontier'+`nsv_emean'+1..`nsv_frontier'+`nsv_emean'+`nsv_usigma']       
			else matrix `init_usigma' = J(1, `:word count `_u_rhs_names' `_usigmacons'', 1) 
		}
		else mat `init_usigma' = `svusigma'
		mat colnames `init_usigma' = `_u_rhs_names' `_usigmacons'
		mat coleq `init_usigma' = "Usigma"			
		if "`svvsigma'"=="" {	
			if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_vsigma' = `init_params'[1,`nsv_frontier'+`nsv_emean'+`nsv_usigma'+1..`nsv_frontier'+`nsv_emean'+`nsv_usigma'+`nsv_vsigma']
			else matrix `init_vsigma' = J(1, `:word count `_v_rhs_names' `_vsigmacons'', 1) 
		}
		else mat `init_vsigma' = `svvsigma'
		mat colnames `init_vsigma' = `_v_rhs_names' `_vsigmacons'
		mat coleq `init_vsigma' = "Vsigma"
		
		if (("`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1") | "`e(cmd)'" =="regress") mat `init_alpha' = J(1,`N_g',`alpha')
		else matrix `init_alpha' = J(1,`N_g',.25)
		mat colnames `init_alpha' = `firms'
		mat coleq `init_alpha' = "Alpha"

		******************** This block MUST be included for each estimator ***********************
		local _params_list "init_beta init_emean init_usigma init_vsigma init_alpha"
		local _params_num = 1
		scalar InIt_nparams = wordcount("`_params_list'")
		/// Structure definition for initialisation
		mata: _SV = J(1, st_numscalar("InIt_nparams"), _starting_values())
		foreach _params of local _params_list {
			mata: _SV = _StArTiNg_VaLuEs("``_params''", `_params_num', _SV)	
			** The following to check the content of the structure ** Just for debugging
			*mata: liststruct(_SV)
			local _params_num = `_params_num' + 1
		}
		local InIt_evaluator "tv_tfe_tn"
		local InIt_evaluatortype "lf2"
		*** Parsing of constraints (if defined)
		_parse_constraints, constraintslist(`constraints') estparams(`init_beta', `init_emean', `init_usigma', `init_vsigma', `init_alpha')
	
		mata: _InIt_OpT = _InIt_OpTiMiZaTiOn()
		** The following to check the content of the structure ** Just for debugging
		*mata: liststruct(_InIt_OpT)
		*******************************************************************************************	
	} // Close distribution option
	
} // Close model option
	
if "`model'"=="tre" {
	tempname init_theta
	mat `init_theta' = J(1,1,0.25)
	mat colnames `init_theta' =  _cons
	mat coleq `init_theta' = "Theta"
	
	if "`distribution'"=="hnormal" {
		tempname init_beta init_usigma init_vsigma 
	
		if "`svfrontier'"=="" {
			tempname init_params
			cap qui sfcross `lhs' `rhs' if `touse'==1, d(hn) `nocons' `cost' u(`u_rhs' `u_nocons') v(`v_rhs' `v_nocons') iter(30)
			local _sfcross_conv "`e(converged)'"
			if _rc != 0 qui reg `lhs' `rhs' if `touse'==1, `nocons'	
			mat `init_params'=e(b)
			mat `init_beta' = `init_params'[1,1..`nsv_frontier']
		}
		else mat `init_beta' = `svfrontier'
		mat colnames `init_beta' = `_rhs_names' `_frontcons'
		mat coleq `init_beta' = "Frontier"
		
		if "`svusigma'"=="" {	
			if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_usigma' = `init_params'[1,`nsv_frontier'+1..`nsv_frontier'+`nsv_usigma']   
			else matrix `init_usigma' = J(1, `:word count `_u_rhs_names' `_usigmacons'', 1) 
		}
		else mat `init_usigma' = `svusigma'	
		mat colnames `init_usigma' = `_u_rhs_names' `_usigmacons'
		mat coleq `init_usigma' = "Usigma"		
		
		if "`svvsigma'"=="" {	
			if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_vsigma' = `init_params'[1,`nsv_frontier'+`nsv_usigma'+1..`nsv_frontier'+`nsv_usigma'+`nsv_vsigma']
			else matrix `init_vsigma' = J(1, `:word count `_v_rhs_names' `_vsigmacons'', 1) 
		}
		else mat `init_vsigma' = `svvsigma'	
		mat colnames `init_vsigma' = `_v_rhs_names' `_vsigmacons'
		mat coleq `init_vsigma' = "Vsigma"
		
		******************** This block MUST be included for each estimator ***********************
		local _params_list "init_beta init_usigma init_vsigma init_theta"

		local _params_num = 1
		scalar InIt_nparams = wordcount("`_params_list'")
		/// Structure definition for initialisation
		mata: _SV = J(1, st_numscalar("InIt_nparams"), _starting_values())
		foreach _params of local _params_list {
			mata: _SV = _StArTiNg_VaLuEs("``_params''", `_params_num', _SV)	
			** The following to check the content of the structure ** Just for debugging
			*mata: liststruct(_SV)
			local _params_num = `_params_num' + 1
		}
		local InIt_evaluator "tv_tre_hn"
		local InIt_evaluatortype "gf0"
		*** Parsing of constraints (if defined)
		_parse_constraints, constraintslist(`constraints') estparams(`init_beta', `init_usigma', `init_vsigma', `init_theta')		

		mata: _InIt_OpT = _InIt_OpTiMiZaTiOn()
		** The following to check the content of the structure ** Just for debugging
		*mata: liststruct(_InIt_OpT)
		*******************************************************************************************	
	} // Close half-normal distribution option
	
	if "`distribution'"=="tnormal" {
		tempname init_beta init_emean init_usigma init_vsigma
		
		if "`svfrontier'"=="" {
			tempname init_params
			cap qui sfcross `lhs' `rhs' if `touse'==1, d(tn) `nocons' `cost' em(`e_rhs' `e_nocons') u(`usigma' `u_nocons') v(`vsigma' `v_nocons') difficult iter(30)
			local _sfcross_conv "`e(converged)'"
			if _rc != 0 qui reg `lhs' `rhs' if `touse'==1, `nocons'	
			mat `init_params'=e(b)
			mat `init_beta' = `init_params'[1,1..`nsv_frontier']
		}
		else mat `init_beta' = `svfrontier'
		mat colnames `init_beta' = `_rhs_names' `_frontcons'
		mat coleq `init_beta' = "Frontier"
		
		if "`svemean'"=="" {
			if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_emean' = `init_params'[1,`nsv_frontier'+1..`nsv_frontier'+`nsv_emean']
			else matrix `init_emean' = J(1, `:word count `_e_rhs_names' `_econs'', .5)
		}
		else mat `init_emean' = `svemean'	
		mat colnames `init_emean' = `_e_rhs_names' `_econs'
		mat coleq `init_emean' = "Mu"
			
		if "`svusigma'"=="" {	
			if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_usigma' = `init_params'[1,`nsv_frontier'+`nsv_emean'+1..`nsv_frontier'+`nsv_emean'+`nsv_usigma']   
			else matrix `init_usigma' = J(1, `:word count `_u_rhs_names' `_usigmacons'', 1) 
		}
		else mat `init_usigma' = `svusigma'	
		mat colnames `init_usigma' = `_u_rhs_names' `_usigmacons'
		mat coleq `init_usigma' = "Usigma"		
		
		if "`svvsigma'"=="" {	
			if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_vsigma' = `init_params'[1,`nsv_frontier'+`nsv_emean'+`nsv_usigma'+1..`nsv_frontier'+`nsv_emean'+`nsv_usigma'+`nsv_vsigma']
			else matrix `init_vsigma' = J(1, `:word count `_v_rhs_names' `_vsigmacons'', 1) 
		}
		else mat `init_vsigma' = `svvsigma'	
		mat colnames `init_vsigma' = `_v_rhs_names' `_vsigmacons'
		mat coleq `init_vsigma' = "Vsigma"		
	
		******************** This block MUST be included for each estimator ***********************
		local _params_list "init_beta init_emean init_usigma init_vsigma init_theta"	 
		
		local _params_num = 1
		scalar InIt_nparams = wordcount("`_params_list'")
		/// Structure definition for initialisation
		mata: _SV = J(1, st_numscalar("InIt_nparams"), _starting_values())
		foreach _params of local _params_list {
			mata: _SV = _StArTiNg_VaLuEs("``_params''", `_params_num', _SV)	
			** The following to check the content of the structure ** Just for debugging
			*mata: liststruct(_SV)
			local _params_num = `_params_num' + 1
		}
		local InIt_evaluator "tv_tre_tn"
		local InIt_evaluatortype "gf0"
		*** Parsing of constraints (if defined)
		_parse_constraints, constraintslist(`constraints') estparams(`init_beta', `init_emean', `init_usigma', `init_vsigma', `init_theta')

		mata: _InIt_OpT = _InIt_OpTiMiZaTiOn()
		** The following to check the content of the structure ** Just for debugging
		*mata: liststruct(_InIt_OpT)
		*******************************************************************************************	
	} // Close t-normal distribution option
				
	if "`distribution'"=="exponential" {
		tempname init_beta init_usigma init_vsigma 				
		if "`svfrontier'"=="" {
			tempname init_params			
			cap qui sfcross `lhs' `rhs' if `touse'==1, d(e) `cost' `nocons' u(`u_rhs' `u_nocons') v(`v_rhs' `v_nocons') iter(50)
			local _sfcross_conv "`e(converged)'"
			if _rc != 0 qui reg `lhs' `rhs' if `touse'==1, `nocons'	
			mat `init_params'=e(b)
			mat `init_beta' = `init_params'[1,1..`nsv_frontier']
		}
		else mat `init_beta' = `svfrontier'
		mat colnames `init_beta' = `_rhs_names' `_frontcons'
		mat coleq `init_beta' = "Frontier"
		
		if "`svusigma'"=="" {	
			if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_usigma' = `init_params'[1,`nsv_frontier'+1..`nsv_frontier'+`nsv_usigma']   
			else matrix `init_usigma' = J(1, `:word count `_u_rhs_names' `_usigmacons'', 1) 
		}
		else mat `init_usigma' = `svusigma'	
		mat colnames `init_usigma' = `_u_rhs_names' `_usigmacons'
		mat coleq `init_usigma' = "Usigma"		
		
		if "`svvsigma'"=="" {	
			if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_vsigma' = `init_params'[1,`nsv_frontier'+`nsv_usigma'+1..`nsv_frontier'+`nsv_usigma'+`nsv_vsigma']
			else matrix `init_vsigma' = J(1, `:word count `_v_rhs_names' `_vsigmacons'', 1) 
		}
		else mat `init_vsigma' = `svvsigma'	
		mat colnames `init_vsigma' = `_v_rhs_names' `_vsigmacons'
		mat coleq `init_vsigma' = "Vsigma"

		******************** This block MUST be included for each estimator ***********************
		local _params_list "init_beta init_usigma init_vsigma init_theta"
		local _params_num = 1
		scalar InIt_nparams = wordcount("`_params_list'")
		/// Structure definition for initialisation
		mata: _SV = J(1, st_numscalar("InIt_nparams"), _starting_values())
		foreach _params of local _params_list {
			mata: _SV = _StArTiNg_VaLuEs("``_params''", `_params_num', _SV)	
			** The following to check the content of the structure ** Just for debugging
			*mata: liststruct(_SV)
			local _params_num = `_params_num' + 1
		}
		local InIt_evaluator "tv_tre_exp"
		local InIt_evaluatortype "gf0"
		*** Parsing of constraints (if defined)
		_parse_constraints, constraintslist(`constraints') estparams(`init_beta', `init_usigma', `init_vsigma', `init_theta')

		mata: _InIt_OpT = _InIt_OpTiMiZaTiOn()
		** The following to check the content of the structure ** Just for debugging
		*mata: liststruct(_InIt_OpT)
		*******************************************************************************************	
	} // Close exponential distribution option						
		
} // Close tre model option
	
if "`model'"=="bc95" {
tempname init_beta init_emean init_usigma init_vsigma

	if "`svfrontier'"=="" {
		tempname init_params	
		cap qui sfcross `lhs' `rhs' if `touse'==1, d(tn) `nocons' `cost' em(`emean' `e_nocons') u(`usigma' `u_nocons') v(`vsigma' `v_nocons') difficult iter(50)
		local _sfcross_conv "`e(converged)'"
		if _rc != 0 qui reg `lhs' `rhs' if `touse'==1, `nocons'	
		mat `init_params'=e(b)
		mat `init_beta' = `init_params'[1,1..`nsv_frontier']
	}
	else mat `init_beta' = `svfrontier'
	mat colnames `init_beta' = `_rhs_names' `_frontcons'
	mat coleq `init_beta' = "Frontier"

	if "`svemean'"=="" {	
		if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_emean' = `init_params'[1,`nsv_frontier'+1..`nsv_frontier'+`nsv_emean']*.9
		else matrix `init_emean' = J(1, `:word count `_e_rhs_names' `_econs'', 1)
	}
	else mat `init_emean' = `svemean'
	mat colnames `init_emean' = `_e_rhs_names' `_econs'
	mat coleq `init_emean' = "Mu"

	if "`svusigma'"=="" {	
		if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_usigma' = `init_params'[1,`nsv_frontier'+`nsv_emean'+1..`nsv_frontier'+`nsv_emean'+`nsv_usigma']*.9      
		else matrix `init_usigma' = J(1, `:word count `_u_rhs_names' `_usigmacons'', 1) 
	}
	else mat `init_usigma' = `svusigma'
	mat colnames `init_usigma' = `_u_rhs_names' `_usigmacons'
	mat coleq `init_usigma' = "Usigma"
	
	if "`svvsigma'"=="" {	
		if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_vsigma' = `init_params'[1,`nsv_frontier'+`nsv_emean'+`nsv_usigma'+1..`nsv_frontier'+`nsv_emean'+`nsv_usigma'+`nsv_vsigma']*.9
		else matrix `init_vsigma' = J(1, `:word count `_v_rhs_names' `_vsigmacons'', 1)
	}
	else mat `init_vsigma' = `svvsigma'
	mat colnames `init_vsigma' = `_v_rhs_names' `_vsigmacons'
	mat coleq `init_vsigma' = "Vsigma"

	******************** This block MUST be included for each estimator ***********************
	local _params_list "init_beta init_emean init_usigma init_vsigma"
	local _params_num = 1
	scalar InIt_nparams = wordcount("`_params_list'")
	/// Structure definition for initialisation
	mata: _SV = J(1, st_numscalar("InIt_nparams"), _starting_values())
	foreach _params of local _params_list {
		mata: _SV = _StArTiNg_VaLuEs("``_params''", `_params_num', _SV)	
		** The following to check the content of the structure ** Just for debugging
		*mata: liststruct(_SV)
		local _params_num = `_params_num' + 1
	}
	local InIt_evaluator "tv_bc95"
	local InIt_evaluatortype "lf0"
	
	*** Parsing of constraints (if defined)
	_parse_constraints, constraintslist(`constraints') estparams(`init_beta', `init_emean', `init_usigma', `init_vsigma')

	mata: _InIt_OpT = _InIt_OpTiMiZaTiOn()
	** The following to check the content of the structure ** Just for debugging
	*mata: liststruct(_InIt_OpT)
	*******************************************************************************************		
}

if "`model'"=="bc92" {
tempname init_params init_beta init_emean init_sigma init_gamma init_eta

	if "`svfrontier'"=="" {
		qui reg `lhs' `rhs' if `touse'==1, `nocons'	
		mat `init_params'=e(b)
		mat `init_beta' = `init_params'[1,1..`nsv_frontier']
	}
	else mat `init_beta' = `svfrontier'
	mat colnames `init_beta' = `_rhs_names' `_frontcons'
	mat coleq `init_beta' = "Frontier"

	if "`svemean'"=="" {	
		matrix `init_emean' = J(1, `:word count `_e_rhs_names' `_econs'', 0)
	}
	else mat `init_emean' = `svemean'
	mat colnames `init_emean' = `_e_rhs_names' `_econs'
	mat coleq `init_emean' = "Mu"

	if "`svsigma'"=="" {	
		matrix `init_sigma' = J(1, `:word count `_u_rhs_names' `_usigmacons'', 3) 
	}
	else mat `init_sigma' = `svsigma'
	mat colnames `init_sigma' = `_u_rhs_names' `_usigmacons'
	mat coleq `init_sigma' = "Sigma"
	
	if "`svgamma'"=="" {	
		matrix `init_gamma' = J(1, `:word count `_v_rhs_names' `_vsigmacons'', -3)
	}
	else mat `init_gamma' = `svgamma'
	mat colnames `init_gamma' = `_vsigmacons'
	mat coleq `init_gamma' = "Gamma"
	
	if "`sveta'"=="" matrix `init_eta' = J(1, 1, 0.5)   
	else mat `init_eta' = `sveta' 
	mat colnames `init_eta' = _cons		
	mat coleq `init_eta' = "Eta"			

	******************** This block MUST be included for each estimator ***********************
	local _params_list "init_beta init_sigma init_gamma init_emean init_eta"
	local _params_num = 1
	scalar InIt_nparams = wordcount("`_params_list'")
	/// Structure definition for initialisation
	mata: _SV = J(1, st_numscalar("InIt_nparams"), _starting_values())
	foreach _params of local _params_list {
		mata: _SV = _StArTiNg_VaLuEs("``_params''", `_params_num', _SV)	
		** The following to check the content of the structure ** Just for debugging
		*mata: liststruct(_SV)
		local _params_num = `_params_num' + 1
	}
	local InIt_evaluator "tv_bc92"
	if "`weight'" == "" local InIt_evaluatortype "gf2"
	else local InIt_evaluatortype "gf1"
	
	*** Parsing of constraints (if defined)
	_parse_constraints, constraintslist(`constraints') estparams(`init_beta', `init_sigma', `init_gamma', `init_emean', `init_eta')
	mata: _InIt_OpT = _InIt_OpTiMiZaTiOn()
	** The following to check the content of the structure ** Just for debugging
	*mata: liststruct(_InIt_OpT)
	*******************************************************************************************		
}   

if "`model'"=="bc88" {
	tempname init_params init_beta init_emean init_sigma init_gamma

		if "`svfrontier'"=="" {
			qui reg `lhs' `rhs' if `touse'==1, `nocons'	
			mat `init_params'=e(b)
			mat `init_beta' = `init_params'[1,1..`nsv_frontier']
		}
		else mat `init_beta' = `svfrontier'
		mat colnames `init_beta' = `_rhs_names' `_frontcons'
		mat coleq `init_beta' = "Frontier"

		if "`svemean'"=="" {	
			matrix `init_emean' = J(1, `:word count `_e_rhs_names' `_econs'', 0)
		}
		else mat `init_emean' = `svemean'
		mat colnames `init_emean' = `_e_rhs_names' `_econs'
		mat coleq `init_emean' = "Mu"

		if "`svsigma'"=="" {	
			matrix `init_sigma' = J(1, `:word count `_u_rhs_names' `_usigmacons'', 2) 
		}
		else mat `init_sigma' = `svsigma'
		mat colnames `init_sigma' = `_u_rhs_names' `_usigmacons'
		mat coleq `init_sigma' = "Sigma"

		if "`svgamma'"=="" {	
			matrix `init_gamma' = J(1, `:word count `_v_rhs_names' `_vsigmacons'', 2)
		}
		else mat `init_gamma' = `svgamma'
		mat colnames `init_gamma' = `_vsigmacons'
		mat coleq `init_gamma' = "Gamma"

		******************** This block MUST be included for each estimator ***********************
		local _params_list "init_beta init_sigma init_gamma init_emean"
		local _params_num = 1
		scalar InIt_nparams = wordcount("`_params_list'")
		/// Structure definition for initialisation
		mata: _SV = J(1, st_numscalar("InIt_nparams"), _starting_values())
		foreach _params of local _params_list {
			mata: _SV = _StArTiNg_VaLuEs("``_params''", `_params_num', _SV)	
			** The following to check the content of the structure ** Just for debugging
			*mata: liststruct(_SV)
			local _params_num = `_params_num' + 1
		}
		local InIt_evaluator "ti_bc88"
		local InIt_evaluatortype "gf2"

		*** Parsing of constraints (if defined)
		_parse_constraints, constraintslist(`constraints') estparams(`init_beta', `init_sigma', `init_gamma', `init_emean')
		mata: _InIt_OpT = _InIt_OpTiMiZaTiOn()
		** The following to check the content of the structure ** Just for debugging
		*mata: liststruct(_InIt_OpT)
		*******************************************************************************************		
}   

if "`model'"=="kumb90" {
	tempname init_beta init_bt init_usigma init_vsigma temp

		if "`svfrontier'"=="" {
			tempname init_params	
			cap qui sfcross `lhs' `rhs' if `touse'==1, d(hn) `nocons' `cost' iter(50) difficult
			local _sfcross_conv "`e(converged)'"
			if _rc != 0 qui reg `lhs' `rhs' if `touse'==1, `nocons'	
			mat `init_params'=e(b)
			mat `init_beta' = `init_params'[1,1..`nsv_frontier']
		}
		else mat `init_beta' = `svfrontier'
		mat colnames `init_beta' = `_rhs_names' `_frontcons'
		mat coleq `init_beta' = "Frontier"

		if "`svusigma'"=="" {	
			if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_usigma' = e(sigma_u)^2
			else matrix `init_usigma' = 0.5
		}
		else mat `init_usigma' = `svusigma'
		mat colnames `init_usigma' = `_u_rhs_names' `_usigmacons'
		mat coleq `init_usigma' = "Usigma"

		if "`svvsigma'"=="" {	
			if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_vsigma' = e(sigma_v)^2
			else matrix `init_vsigma' = 0.5
		}
		else mat `init_vsigma' = `svvsigma'
		mat colnames `init_vsigma' = `_v_rhs_names' `_vsigmacons'
		mat coleq `init_vsigma' = "Vsigma"
		
		if "`bt'"=="" {
			if "`svbt'"=="" matrix `init_bt' = (0.1, 0.1)   
			else mat `init_bt' = `svbt'
			mat colnames `init_bt' = b c
		}
		else {
			if "`svbt'"=="" matrix `init_bt' = J(1, `:word count `_bt_rhs_names' `_btcons'', 0.25)   
			else mat `init_bt' = `svbt'
			mat colnames `init_bt' = `_bt_rhs_names' `_btcons'
		}	
		mat coleq `init_bt' = "Bt"			

		******************** This block MUST be included for each estimator ***********************
		local _params_list "init_beta init_bt init_usigma init_vsigma"
		local _params_num = 1
		scalar InIt_nparams = wordcount("`_params_list'")
		/// Structure definition for initialisation
		mata: _SV = J(1, st_numscalar("InIt_nparams"), _starting_values())
		foreach _params of local _params_list {
			mata: _SV = _StArTiNg_VaLuEs("``_params''", `_params_num', _SV)	
			** The following to check the content of the structure ** Just for debugging
			*mata: liststruct(_SV)
			local _params_num = `_params_num' + 1
		}
		local InIt_evaluator "tv_kumb90"
		local InIt_evaluatortype "gf0"

		*** Parsing of constraints (if defined)
		_parse_constraints, constraintslist(`constraints') estparams(`init_beta', `init_bt', `init_usigma', `init_vsigma')

		mata: _InIt_OpT = _InIt_OpTiMiZaTiOn()
		** The following to check the content of the structure ** Just for debugging
		*mata: liststruct(_InIt_OpT)
		*******************************************************************************************		
}

if "`model'"=="pl81" {
	
		tempname init_beta init_usigma init_vsigma temp

			if "`svfrontier'"=="" {
				tempname init_params	
				cap qui sfcross `lhs' `rhs' if `touse'==1, d(hn) `nocons' `cost' iter(50)
				local _sfcross_conv "`e(converged)'"
				if _rc != 0 qui reg `lhs' `rhs' if `touse'==1, `nocons'	
				mat `init_params'=e(b)
				mat `init_beta' = `init_params'[1,1..`nsv_frontier']
			}
			else mat `init_beta' = `svfrontier'
			mat colnames `init_beta' = `_rhs_names' `_frontcons'
			mat coleq `init_beta' = "Frontier"

			if "`svusigma'"=="" {	
				if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" {
					mat `temp' = `init_params'[1,`nsv_frontier'+1..`nsv_frontier'+`nsv_usigma']
					mata: temp = exp(st_matrix("`temp'"))
					mata: st_matrix("`init_usigma'", temp)     
				}
				else matrix `init_usigma' = J(1, `:word count `_u_rhs_names' `_usigmacons'', 0.5) 
			}
			else mat `init_usigma' = `svusigma'
			mat colnames `init_usigma' = `_u_rhs_names' `_usigmacons'
			mat coleq `init_usigma' = "Usigma"

			if "`svvsigma'"=="" {	
				if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" {
					mat `temp' = `init_params'[1,`nsv_frontier'+`nsv_usigma'+1..`nsv_frontier'+`nsv_usigma'+`nsv_vsigma']
					mata: temp = exp(st_matrix("`temp'"))
					mata: st_matrix("`init_vsigma'", temp)		
				}
				else matrix `init_vsigma' = J(1, `:word count `_v_rhs_names' `_vsigmacons'', 0.5)
			}
			else mat `init_vsigma' = `svvsigma'
			mat colnames `init_vsigma' = `_v_rhs_names' `_vsigmacons'
			mat coleq `init_vsigma' = "Vsigma"
		

			******************** This block MUST be included for each estimator ***********************
			local _params_list "init_beta init_usigma init_vsigma"
			local _params_num = 1
			scalar InIt_nparams = wordcount("`_params_list'")
			/// Structure definition for initialisation
			mata: _SV = J(1, st_numscalar("InIt_nparams"), _starting_values())
			foreach _params of local _params_list {
				mata: _SV = _StArTiNg_VaLuEs("``_params''", `_params_num', _SV)	
				** The following to check the content of the structure ** Just for debugging
				*mata: liststruct(_SV)
				local _params_num = `_params_num' + 1
			}
			local InIt_evaluator "ti_pl81"
			local InIt_evaluatortype "gf0"

			*** Parsing of constraints (if defined)
			_parse_constraints, constraintslist(`constraints') estparams(`init_beta', `init_usigma', `init_vsigma')

			mata: _InIt_OpT = _InIt_OpTiMiZaTiOn()
			** The following to check the content of the structure ** Just for debugging
			*mata: liststruct(_InIt_OpT)
			*******************************************************************************************				
		
}

if "`model'"=="fels" {
	
		tempname init_beta init_xi
	
			cap qui xtreg `lhs' `rhs' if `touse'==1, fe
			mat `init_beta' = e(b)
			local _nregr: word count `rhs'
			mat `init_beta' = `init_beta'[1,1..`_nregr']
			mat colnames `init_beta' = `_rhs_names'
			mat coleq `init_beta' = "Frontier"
			
			local __maxT = `g_max'
			forvalues t=1/`__maxT' {
				local __xinames "`__xinames' xi`t'"
			}
			
			mat `init_xi' = J(1,`__maxT',0)
			mat colnames `init_xi' = `__xinames'
			mat coleq `init_xi' = "Time dummies"
			
			******************** This block MUST be included for each estimator ***********************
			local _params_list "init_beta init_xi"
			local _params_num = 1
			scalar InIt_nparams = wordcount("`_params_list'")
			/// Structure definition for initialisation
			mata: _SV = J(1, st_numscalar("InIt_nparams"), _starting_values())
			foreach _params of local _params_list {
				mata: _SV = _StArTiNg_VaLuEs("``_params''", `_params_num', _SV)	
				** The following to check the content of the structure ** Just for debugging
				*mata: liststruct(_SV)
				local _params_num = `_params_num' + 1
			}
			local InIt_evaluator "fe_ls"
			local InIt_evaluatortype "gf0"

			*** Parsing of constraints (if defined)
			_parse_constraints, constraintslist(`constraints') estparams(`init_beta', `init_xi')

			mata: _InIt_OpT = _InIt_OpTiMiZaTiOn()
			** The following to check the content of the structure ** Just for debugging
			*mata: liststruct(_InIt_OpT)
			*******************************************************************************************
}
	
if "`model'"=="fecss" {
	mata: _SV = J(1, 1, _starting_values())
	mata: _InIt_OpT = _InIt_OpTiMiZaTiOn()
}
	
local evarlist "`lhs' `rhs'"

///////////////////////////////////////////////////////////////////
////////////////////////// Estimation /////////////////////////////
///////////////////////////////////////////////////////////////////


if ("`model'" == "fe") {
	
	if "`constraints'" == "" {	
		if "`clustervar'"!="" local clustervar " `clustervar'"	
		qui xtreg `lhs' `rhs' [`weight' `__equal' `exp'] if `touse'==1, fe vce(`vce'`clustervar')
		tempname __Fe __FeV s_u s_v
		mat `__Fe' = e(b)
		mat `__FeV' = e(V)
		scalar `s_v' = e(sigma_e)
		scalar `s_u' = e(sigma_u)
		eret post `__Fe' `__FeV', o(`e(N)') esample(`touse')
		eret scalar sigma_v = `s_v'
		eret scalar sigma_u = `s_u'
	}
	else {
		_parse_constraints, constraintslist(`constraints') feregls(`evarlist')
		foreach __var of local evarlist {
			tempvar __copy`__var' __m`var' __gm`var'
			qui gen `__copy`__var'' = `__var'
		    qui bys `temp_id': egen `__m`var''= mean(`__var') if `touse'
			qui egen `__gm`var''= mean(`__var') if `touse'
		    qui replace `__var' = (`__var' - `__m`var'') + `__gm`var'' if `touse'
		    qui cap drop `__m`var'' `__gm`var''
		}
		
		/// Temp variables and names
		tempname ___DF __UtU __s2w __XtX __iXtX __Fe __FeV s_v
		tempvar __res _U _XB

		qui cnsreg `lhs' `rhs' [`weight' `__equal' `exp'] if `touse'==1, cons(`constraints')
				
		mat `__Fe' = e(b)
		scalar `___DF' = (e(N)-`N_g'-e(rank)) 
		qui predict `__res', res
		
		/// VAR-COV matrix correction
		if "`vce'" == "robust" {
			mata: __FeV = __RoBuSt_within("`rhs'","`temp_id'","`temp_t'","`__res'","`touse'","`nocons'")
			mata: st_matrix("`__FeV'",__FeV)
			mat colnames `__FeV' =`_rhs_names' `_frontcons'
			mat rownames `__FeV' =`_rhs_names' `_frontcons'	
		}
		else {
			qui replace `__res' = `__res'^2
			qui sum `__res'
			scalar `__UtU' = r(sum)
			scalar `__s2w' = `__UtU'/`___DF'
			qui mat accum `__XtX' = `rhs'
			mat `__iXtX' = invsym(`__XtX')
			mat `__FeV' = `__s2w'*`__iXtX'
		}
		
		scalar `s_v' = sqrt(`__UtU'/(e(N)-e(rank)-(`N_g'-1)))		
		eret post `__Fe' `__FeV' _CNS_feregls, o(`e(N)') esample(`touse')
		eret scalar sigma_v = `s_v'
	
		tempvar touseafterpost
		qui gen `touseafterpost' = (e(sample)==1) 
		
		/// Restore dataset
		foreach __var of local evarlist {
		    qui replace `__var' = `__copy`__var''
		    qui cap drop `__copy`__var''
		}
		
		qui _predict double `_XB' if `touseafterpost'==1, xb
		sort `temp_id' `touseafterpost'
		qui by `temp_id' `touseafterpost': gen double `_U' = /*
			*/ cond(`touseafterpost' & _n==_N, /*
			*/ sum(`lhs')/_n-sum(`_XB')/_n,.) /*
			*/ if `touseafterpost'==1
		qui summ `_U'
		eret scalar sigma_u = sqrt(r(Var))
	}
	
}
else if ("`model'" == "regls") {
	
	*if "`constraints'" == "" {
		if "`clustervar'"!="" local clustervar " `clustervar'"
		qui xtreg `lhs' `rhs' if `touse'==1, re vce(`vce'`clustervar')
		tempname __GlS __GlSV s_v s_u
		mat `__GlS' = e(b)
		mat `__GlSV' = e(V)
		scalar `s_v' = e(sigma_e)
		scalar `s_u' = e(sigma_u)
		eret post `__GlS' `__GlSV', o(`e(N)') esample(`touse')
		eret scalar sigma_v = `s_v'
		eret scalar sigma_u = `s_u'
	
	/* Regls constrained estimation must be chcked before published
	}
	else {
		_parse_constraints, constraintslist(`constraints') feregls(`evarlist')
		tempname ___DF __UtU __s2w __s2b __arm_m __GlS __GlSV s_v s_u
		tempvar __res __t __t1 __ti1 __psihat __thetav __cons_fgls
		 
		/// 1st step: within
		foreach __var of local evarlist {
			tempvar __copy`__var' __m`var' __gm`var'
			qui gen `__copy`__var'' = `__var'
		    qui bys `temp_id': egen `__m`var''= mean(`__var') if `touse'
			qui egen `__gm`var''= mean(`__var') if `touse'
		    qui replace `__var' = (`__var' - `__m`var'') + `__gm`var'' if `touse'
		    qui cap drop `__m`var'' `__gm`var''
		}
		
		*qui cnsreg `lhs' `rhs' if `touse', cons(`constraints')
		qui reg `lhs' `rhs' if `touse'==1
		scalar `___DF' = (e(N)-`N_g'-e(rank)) 
		qui predict `__res', res
		qui replace `__res' = `__res'^2
		qui sum `__res'
		scalar `__UtU' = r(sum)
		scalar `s_v' = sqrt(`__UtU'/(e(N)-e(rank)-(`N_g'-1)))
		scalar `__s2w' = `__UtU'/`___DF'
		
		/// Restore dataset
		foreach __var of local evarlist {
		    qui replace `__var' = `__copy`__var''
		    qui cap drop `__copy`__var''
		}
		
		/// 2nd step: between
		preserve
		qui gen `__t' = 1
		qui collapse `lhs' `rhs' (sum) `__t' if `touse'==1, by(`temp_id')	
		qui gen `__t1' = 1 / `__t'
		qui sum `__t1'
		*Harmonic mean of T_i
		qui scalar `__arm_m' = `N_g'/r(sum) 
		*qui cnsreg `lhs' `rhs', cons(`constraints')
		qui reg `lhs' `rhs'
		qui scalar `___DF' = (`N_g'-e(rank))
		qui cap drop `__res'
		qui predict `__res', res
		qui replace `__res' = (`__res'^2)
		qui sum `__res'
		qui scalar `__UtU' = r(sum)

		scalar `s_u' = sqrt((e(rmse)^2) -`s_v'^2/`Tbar')
		scalar `__s2b' = (`__UtU'/`___DF') - (`__s2w'/`__arm_m')	
		restore
			
		/// 3rd step: feasible gls
		
		qui egen `__ti1' = max(`temp_t') if `touse'==1, by(`temp_id')
		qui gen `__psihat' = 1 - sqrt(`__s2w'/(`__s2w' + `__ti1'*`__s2b'))
		noi sum  `__psihat',d
		
		foreach __var of local evarlist {
			tempvar __copy`__var' __m`var'
			qui gen `__copy`__var'' = `__var'
		    qui egen `__m`var''= mean(`__var') if `touse'==1, by(`temp_id')
		    qui replace `__var' = (`__var' - (`__m`var''*`__psihat'))  if `touse'==1
		    qui cap drop `__m`var'' `__gm`var''
		}

		qui gen `__cons_fgls' = 1 - `__psihat' if `touse'==1
		*qui cnsreg `lhs' `rhs' `__cons_fgls' if `touse'==1, nocons cons(`constraints') vce(`vce')
		qui reg `lhs' `rhs' `__cons_fgls' if `touse'==1, nocons vce(`vce')
		
		mat `__GlS' = e(b)
		mat `__GlSV' = e(V)
		
		/// INSERIRE CORREZIONE STD ERRORS ROBUST COME WITHIN
		mat colnames `__GlS' =`_rhs_names' `_frontcons'
		mat colnames `__GlSV' =`_rhs_names' `_frontcons'
		mat rownames `__GlSV' =`_rhs_names' `_frontcons'
		
		eret post `__GlS' `__GlSV' _CNS_feregls, o(`e(N)') esample(`touse')
		eret scalar sigma_v = `s_v'
		eret scalar sigma_u = `s_u'
		
		/// Restore dataset
		foreach __var of local evarlist {
		    qui replace `__var' = `__copy`__var''
		    qui cap drop `__copy`__var''
		}	
	}
	*/
}
else {
	
	*** Collect post-results options
	mata: _PoSt_OpT = _PoSt_ReSuLt_of_EsTiMaTiOn()
	*** Get Data
	mata: _DaTa = _GeT_dAtA("`evarlist'", "`touse'", "`lxtset'", "`model'", "`distribution'", &_sim_tre(),"`nocons'", "`emean'", "`usigma'", "`vsigma'", "`bt'", "`e_rhs'", "`u_rhs'", "`v_rhs'", "`bt_rhs'", "`e_nocons'", "`u_nocons'", "`v_nocons'", "`bt_nocons'")
	*** Estimation
	noi di ""
	if ("`model'" == "fecss") noi mata: sf_est_fe_css_ls("`model'",_SV, _DaTa, _InIt_OpT, _PoSt_OpT,  `iterate')
	else if ("`model'" == "fels") {
		noi mata: sf_est_fe_css_ls("`model'", _SV, _DaTa, _InIt_OpT, _PoSt_OpT,  `iterate')
		noi mata: _fels_hessian_eval(_DaTa, "_ls_estimates", _SV, _InIt_OpT, _PoSt_OpT)
	}
	else noi mata: _Results = sf_est_ml("`model'", "`distribution'", &_sim_tre(), _DaTa, _SV, _InIt_OpT, _PoSt_OpT)
}

///////////////// Display results /////////////////

if ("`model'" == "fecss") {
	*** Nocons option is not allowed here
	mat colnames _b = `_rhs_names'
	mat colnames _V = `_rhs_names' 
	mat rownames _V = `_rhs_names' 
	mat coleq _b = "Frontier"
	mat coleq _V = "Frontier"
	mat roweq _V = "Frontier"
	local ___n = `N'
	eret post _b _V, obs(`___n') esample(`touse')
	eret scalar sigma_v = _sigmav
	eret scalar sigma_u = _sigmau
	eret local vce "`vce'"
	if "`vce'"== "cluster" {
		eret local vcetype "Robust"
		eret local clustvar "`clustervar'"
	}
}

if ("`model'" == "fels") {
	*** Nocons option is not allowed here
	local ___n = `N'
	eret post __b_ __V_, obs(`___n') esample(`touse')
	eret scalar cf = _ls_cf
	eret scalar iterations = _ls_iter
	eret scalar sigma_v = _sigmav
	eret scalar sigma_u = _sigmau
	eret local vce "`vce'"
	if "`vce'"== "cluster" {
		eret local vcetype "Robust"
		eret local clustvar "`clustervar'"
	}
}


if ("`model'" == "fe" | "`model'" == "regls") {
	eret local vce "`vce'"
	if "`vce'"== "cluster" {
		eret local vcetype "Robust"
		eret local clustvar "`clustervar'"
	}
}
	

*** Common post not in sf_est_ml()
eret local predict "sfpanel_p"
eret local cmd "sfpanel"
eret local depvar "`lhs'"
eret local model "`model'"
eret local crittype "`crittype'" 
eret local marginsok "default xb"
if "`e(model)'"=="tre" {
	eret local simtype "`simtype'"
	eret scalar nsim = `nsimulations'
	eret scalar base = `base'
}
/// Watch-out: Bt and BT are different because we need them
/// in post-estimation to distinguish bt=="" vs bt!=""
if "`bt'"!="" & "`e(model)'"=="kumb90" eret local Bt "`_bt_rhs_names' `_btcons'"
if "`bt'"=="" & "`e(model)'"=="kumb90" eret local BT "t t2"
eret local function "`function'"
eret local ivar `id'
eret local tvar `time'
eret local het "`u'`v'" 
eret local cilevel `level'
if "`e(het)'"=="u" | "`e(het)'"=="uv" eret local Usigma "`_u_rhs_names' `_usigmacons'" 
if "`e(het)'"=="v" | "`e(het)'"=="uv" eret local Vsigma "`_v_rhs_names' `_vsigmacons'" 
if "`emean'"!="" eret local Emean "`_e_rhs_names' `_econs'"                  
eret local dist "`distribution'"  
eret local covariates "`_rhs_names' `_frontcons'" 
eret scalar Tbar = `Tbar'
eret scalar Tcon = `Tcon'
eret scalar g_min = `g_min'
eret scalar g_avg = `g_avg'
eret scalar g_max = `g_max'
eret scalar N_g = `N_g'
if "`weight'"!="" eret local wtype "`weight'"
if "`exp'"!="" eret local wexp "= `exp'"

if "`e(model)'"=="tfe" | "`e(model)'"=="tre" | "`e(model)'"=="bc95" {
   if "`usigma'"==""  eret scalar sigma_u = exp(0.5 * [Usigma]_cons)
   if "`vsigma'"==""  eret scalar sigma_v = exp(0.5 * [Vsigma]_cons)
   if "`e(model)'"=="tre" eret scalar theta = [Theta]_cons
   if "`usigma'"!= "" {
   		tempvar xb_u sigma_uhet
   		qui _predict double `xb_u' if `touse', xb eq(Usigma)
   		qui gen double `sigma_uhet' = exp(0.5*`xb_u')
   		qui sum `sigma_uhet'
   		eret scalar avg_sigmau = r(mean) 
   		local sigmau_se = r(sd)/sqrt(e(N))
   }
   if "`vsigma'"!= "" {
   		tempvar xb_v sigma_vhet
   		qui _predict double `xb_v' if `touse', xb eq(Vsigma)
   		qui gen double `sigma_vhet' = exp(0.5*`xb_v')
   		qui sum `sigma_vhet'
   		eret scalar avg_sigmav = r(mean) 
   		local sigmav_se = r(sd)/sqrt(e(N))
   }
}

if "`e(model)'"=="kumb90" | "`e(model)'"=="pl81" {
	eret scalar sigma_u = sqrt([Usigma]_cons)
	eret scalar sigma_v = sqrt([Vsigma]_cons)
}
if "`e(model)'"=="bc92" | "`e(model)'"=="bc88" {
	eret scalar sigma2 = exp([Sigma]_cons)
    eret scalar gamma = exp([Gamma]_cons)/(1+exp([Gamma]_cons))
    eret scalar sigma_u = sqrt(`e(gamma)'*`e(sigma2)')
    eret scalar sigma_v = sqrt((1-`e(gamma)')*`e(sigma2)')	
}
if "`e(model)'"!="fels" {
	*** Wald test
	`vv' qui test `_rhs_wald' 0
	eret scalar chi2 = r(chi2)
	eret scalar p = r(p)
	eret scalar df_m = r(df)
}


local diopts "`_noempty' `diopts'"
DiSpLaY, level(`level') use(`sigmau_se') vse(`sigmav_se') `feshow' `diopts' 

__sfpanel_destructor
        
end


program define DiSpLaY, eclass
        syntax [, Level(cilevel) use(string) vse(string) feshow *]
		_get_diopts diopts, `options' 
		
		/// Title
		if "`e(model)'"=="fels" eret local title "Time-varying fixed-effects model (Iterative LS)"
		if "`e(model)'"=="fecss" eret local title "Time-varying fixed-effects model (CSS Modified-LSDV)"
		if "`e(model)'"=="fe" eret local title "Time-invariant fixed-effects model (LSDV)"
		if "`e(model)'"=="regls" eret local title "Time-invariant Random-effects model (FGLS)"	
		if "`e(model)'"=="bc95" eret local title "Inefficiency effects model (truncated-normal)"
		if "`e(model)'"=="bc92" eret local title "Time-varying decay model (truncated-normal)"
		if "`e(model)'"=="bc88" eret local title "Time-invariant model (truncated-normal)"
		if "`e(model)'"=="kumb90" eret local title "Time-varying parametric model (half-normal)"
		if "`e(model)'"=="tfe" {
			if "`e(dist)'"=="hnormal" eret local title "True fixed-effects model (half-normal)"
			if "`e(dist)'"=="exponential" eret local title "True fixed-effects model (exponential)"
			if "`e(dist)'"=="tnormal" eret local title "True fixed-effects model (truncated-normal)"
		}
		else if "`e(model)'"=="tre" {
			if "`e(dist)'"=="hnormal" eret local title "True random-effects model (half-normal)"
			if "`e(dist)'"=="exponential" eret local title "True random-effects model (exponential)"
			if "`e(dist)'"=="tnormal" eret local title "True random-effects model (truncated-normal)"
		}
		if "`e(model)'"=="pl81" & "`e(dist)'"=="hnormal" eret local title "Time-invariant model (half-normal)"	
        
		#delimit ;
		di as txt _n "`e(title)'" _col(54) "Number of obs " _col(68) "=" /*
				*/ _col(70) as res %9.0g e(N);
        di in gr "Group variable: " in ye abbrev("`e(ivar)'",12) 
           in gr _col(51) "Number of groups" _col(68) "="
                 _col(70) in ye %9.0g `e(N_g)';
        di in gr "Time variable: " in ye abbrev("`e(tvar)'",12)                    
           in gr _col(49) in gr "Obs per group: min" _col(68) "="
                 _col(70) in ye %9.0g `e(g_min)' ;
        di       _col(64) in gr "avg" _col(68) "="
                 _col(70) in ye %9.1f `e(g_avg)' ;
        di       _col(64) in gr "max" _col(68) "="
                 _col(70) in ye %9.0g `e(g_max)' _n;				                            
		#delimit cr
		if "`e(model)'"!="fe" & "`e(model)'"!="regls" & "`e(model)'"!="fecss" & "`e(model)'"!="fels" {
			di in green _col(54) "Prob > chi2   = " %9.4f in yellow e(p)
			di in green "`e(crittype)' = " in yellow %10.4f `e(ll)' /// 
			in green _col(54) "Wald chi2(" in yellow e(df_m) in green ")  = " in yellow %9.2f e(chi2) _n
		}
		if "`e(model)'"=="tre" {
			if "`e(simtype)'" == "runiform" {
				di in green "Number of Pseudo Random Draws = " in yellow %9.0f "`e(nsim)'"
			}
			else if "`e(simtype)'" == "halton" {
				di in green "Number of Halton Sequences = " in yellow %9.0f "`e(nsim)'"
				di in green "Base for Halton Sequences  = " in yellow %9.0f "`e(base)'" 
			}
			else if "`e(simtype)'" == "genhalton" {
				di in green "Number of Randomized Halton Sequences = " in yellow %9.0f "`e(nsim)'"
				di in green "Base for Randomized Halton Sequences  = " in yellow %9.0f "`e(base)'" 
			}
		}         

*** DISPLAY RESULTS

if "`e(model)'"=="fe" | "`e(model)'"=="regls" | "`e(model)'"=="fecss" {
	_coef_table, level(`level') `diopts' plus
	di in smcl in gr "     sigma_u {c |} " in ye %10.0g e(sigma_u)
	di in smcl in gr "     sigma_v {c |} " in ye %10.0g e(sigma_v)
}
else if "`e(model)'"=="tfe" | "`e(model)'"=="tre" | "`e(model)'"=="bc95" {	
	
	if "`e(model)'"=="tfe" & "`feshow'"!="" local __neq = e(k_eq)
	else if "`e(model)'"=="tfe" & "`feshow'"=="" local __neq = e(k_eq)-1
	else local __neq = e(k_eq)
	
	_coef_table, level(`level') plus neq(`__neq') `diopts'

	if "`e(het)'"=="" {
		_diparm Usigma, func( exp(0.5*@) ) /*
		*/ der( 0.5*exp(0.5*@) ) level(`level') label(sigma_u) prob
		_diparm Vsigma, func( exp(0.5*@) ) /*
		*/ der( 0.5*exp(0.5*@) ) level(`level') label(sigma_v) prob
		_diparm Vsigma Usigma, level(`level') /*
		*/ func( sqrt(exp(@2-@1))) /*
		*/ der( -0.5*exp(0.5*@1) 0.5*exp(0.5*@2) ) /*
		*/ label(lambda) prob           
	}
	if "`e(het)'"=="u" {		
		local _ci_lev = (1 - 0.`level')/2
		local _t_su = e(avg_sigmau)/`use'
		local _pval_su = 2*ttail(e(N)-e(df_m), abs(`_t_su'))
		local _lb_su = e(avg_sigmau) - abs(invnormal(`_ci_lev'))*`use'
		local _ub_su = e(avg_sigmau) + abs(invnormal(`_ci_lev'))*`use'
		di in gr "  E(sigma_u) {c |}  " in ye %9.0g e(avg_sigmau) ///
				/*in yel	%9.0g _s(2) `use' %6.2f _s(3) `_t_su' ///
				_s(3) %4.3f `_pval_su'*/ _s(32) %9.0g `_lb_su' _s(3) %9.0g `_ub_su'
		_diparm Vsigma, func( exp(0.5*@) ) /*
			     */ der( 0.5*exp(0.5*@) ) level(`level') label(sigma_v) prob
	}
	if "`e(het)'"=="v" {
		local _ci_lev = (1 - 0.`level')/2
		local _t_sv = e(avg_sigmav)/`vse'
		local _pval_sv = 2*ttail(e(N)-e(df_m), abs(`_t_sv'))
		local _lb_sv = e(avg_sigmav) - abs(invnormal(`_ci_lev'))*`vse'
		local _ub_sv = e(avg_sigmav) + abs(invnormal(`_ci_lev'))*`vse'
		di in gr "  E(sigma_v) {c |}  " in ye %9.0g e(avg_sigmav) ///
				/*in yel	%9.0g _s(2) `vse' %6.2f _s(3) `_t_sv' ///
				_s(3) %4.3f `_pval_sv'*/ _s(32) %9.0g `_lb_sv' _s(3) %9.0g `_ub_sv'
		_diparm Usigma, func( exp(0.5*@) ) /*
			     */ der( 0.5*exp(0.5*@) ) level(`level') label(sigma_u) prob
	}
	if "`e(het)'"=="uv" {
		local _ci_lev = (1 - 0.`level')/2
		local _t_su = e(avg_sigmau)/`use'
		local _pval_su = 2*ttail(e(N)-e(df_m), abs(`_t_su'))
		local _lb_su = e(avg_sigmau) - abs(invnormal(`_ci_lev'))*`use'
		local _ub_su = e(avg_sigmau) + abs(invnormal(`_ci_lev'))*`use'	
		local _t_sv = e(avg_sigmav)/`vse'
		local _pval_sv = 2*ttail(e(N)-e(df_m), abs(`_t_sv'))
		local _lb_sv = e(avg_sigmav) - abs(invnormal(`_ci_lev'))*`vse'
		local _ub_sv = e(avg_sigmav) + abs(invnormal(`_ci_lev'))*`vse'
		di in gr "  E(sigma_u) {c |}  " in ye %9.0g e(avg_sigmau) ///
				/*in yel	%9.0g _s(2) `use' %6.2f _s(3) `_t_su' ///
				_s(3) %4.3f `_pval_su'*/ _s(32) %9.0g `_lb_su' _s(3) %9.0g `_ub_su'
		di in gr "  E(sigma_v) {c |}  " in ye %9.0g e(avg_sigmav) ///
				/*in yel	%9.0g _s(2) `vse' %6.2f _s(3) `_t_sv' ///
				_s(3) %4.3f `_pval_sv'*/ _s(32) %9.0g `_lb_sv' _s(3) %9.0g `_ub_sv'
	}	
}
else if ("`e(model)'"=="kumb90" | "`e(model)'"=="pl81") {

	if "`e(model)'"=="kumb90" _coef_table, level(`level') neq(2) `diopts' plus
	if "`e(model)'"=="pl81" _coef_table, level(`level') neq(1) `diopts' plus
	_diparm Usigma, level(`level') label(/sigmau_2) prob
	_diparm Vsigma, level(`level') label(/sigmav_2) prob
	
	di as text "{hline 13}{c +}{hline 64}"
	_diparm Usigma, func( @^0.5 ) /*
	*/ der( 0.5*(@^-0.5) ) level(`level') label(sigma_u) prob
	_diparm Vsigma, func( @^0.5 ) /*
	*/ der( 0.5*(@^-0.5) ) level(`level') label(sigma_v) prob
	_diparm Usigma Vsigma, level(`level') /*
	*/ func( (@1^0.5)/(@2^0.5)) /*
	*/ der( 0.5*(@1^-0.5) 0.5*(@2^-0.5) ) /*
	*/ label(lambda) prob           			
}
else if ("`e(model)'"=="bc92" | "`e(model)'"=="bc88") {
	_coef_table, level(`level') neq(1) `diopts' plus
	_diparm Sigma, label(/lnsigma2) prob
    _diparm Gamma, label(/ilgtgamma) prob
	_diparm Mu, level(`level') label(/mu) prob 
	if ("`e(model)'"=="bc92") _diparm Eta, level(`level') label(/eta) prob
	_diparm __sep__
	_diparm Sigma, exp label(sigma2)
    _diparm Gamma, ilogit label(gamma)
    _diparm Sigma Gamma, /*
            */ func( exp(@1)*exp(@2)/(1+exp(@2)) ) /*
            */ der( exp(@1)*exp(@2)/(1+exp(@2)) /*
            */ exp(@1)*(exp(@2)/(1+exp(@2))-(exp(@2)/(1+exp(@2)))^2) ) /*
            */ label(sigma_u2)
    _diparm Sigma Gamma, /*
            */ func( exp(@1)*(1-exp(@2)/(1+exp(@2))) ) /*
            */ der( exp(@1)*(1-exp(@2)/(1+exp(@2)))  /*
            */ (-exp(@1))*(exp(@2)/(1+exp(@2))-(exp(@2)/(1+exp(@2)))^2))/*
            */ label(sigma_v2)
	
}

if "`e(model)'"=="fels" {
	_coef_table, neq(1) level(`level') `diopts' plus
	di in smcl in gr "     sigma_u {c |} " in ye %10.0g e(sigma_u)
	di in smcl in gr "     sigma_v {c |} " in ye %10.0g e(sigma_v)
	di as text "{hline 13}{c BT}{hline 64}"
}
else di as text "{hline 13}{c BT}{hline 64}"
	

				
end


program define _parse_constraints, eclass

syntax[, constraintslist(string asis) estparams(string asis) feregls(string)]

if "`feregls'" != "" {

qui _regress `feregls'
	foreach cns of local constraintslist {
		constraint get `cns'
		if `r(defined)' != 0 {
			makecns `cns'
			if "`r(clist)'" == "" continue
			mat _CNS_feregls = (nullmat(_CNS_feregls) \ e(Cns))	
		}
		else {
			noi di as err "Constraint `cns' is not defined."
		    error 198
		    exit
		}
	}		
}
else {
	if "`constraintslist'"!="" {
	tempname b
	mat `b' = (`estparams')
	eret post `b'
		foreach cns of local constraintslist {
			constraint get `cns'
			if `r(defined)' != 0 {
				makecns `cns'
				if "`r(clist)'" == "" continue
				mat _CNS = (nullmat(_CNS) \ e(Cns))	
			}
			else {
				noi di as err "Constraint `cns' is not defined."
			    error 198
			    exit
			}
		}
	}
}

end

/*
program define ParseEff
	args retumac colon efftype

	local 0 ", `efftype'"
	syntax [, TVarying TInvariant * ]

	if `"`options'"' != "" {
		di as error "efftype(`options') not allowed"
		exit 198
	}

	local wc : word count `tvarying' `tinvariant' 

	if `wc' > 1 {
		di as error "efftype() invalid, only " /*
			*/ "one efficiency type can be specified"
		exit 198
	}

	if `wc' == 0 {
		c_local `retumac' tvarying
	}
	else	c_local `retumac' `tvarying'`tinvariant' 

end
*/

/* ----------------------------------------------------------------- */

program define ParseMod
	args returmac colon model

	local 0 ", `model'"
	syntax [, FE REGLS FECSS FELS KUMB90 PL81 BC88 BC92 BC95 TFE TRE * ]

	if `"`options'"' != "" {
		di as error "model(`options') not allowed"
		exit 198
	}
	
	local wc : word count `tfe' `tre' `bc95' `bc92' `bc88' `kumb90' `pl81' `fecss' `fels' `fe' `regls' 

	if `wc' > 1 {
		di as error "model() invalid, only " /*
			*/ "one model can be specified"
		exit 198
	}

	if `wc' == 0 {
		c_local `returmac' bc92
	}
	else	c_local `returmac' `tfe'`tre'`bc95'`bc92'`bc88'`kumb90'`pl81'`fecss'`fels'`fe'`regls' 

end

/* ----------------------------------------------------------------- */

program define ParseDistr
	args returnmac colon distribution model 

	local 0 ", `distribution'"
	syntax [, Hnormal Exponential Tnormal * ]

	if `"`options'"' != "" {
		di as error "distribution(`options') not allowed"
		exit 198
	}

	local wc : word count `hnormal' `exponential' `tnormal'

	if `wc' > 1 {
		di as error "distribution() invalid, only " /*
			*/ "one distribution can be specified"
		exit 198
	}

	if `wc' == 0 {
		// Default distribution is model specific
		if "`model'"=="bc95" | "`model'"=="bc92" | "`model'"=="bc88" {
			c_local `returnmac' tnormal
			local __check tnormal
		}
		if "`model'"=="tfe" | "`model'" =="tre" {
			c_local `returnmac' exponential
			local __check exponential
		}
		if "`model'"=="kumb90" | "`model'" =="pl81" {
			c_local `returnmac' hnormal
			local __check hnormal
		}
	}
	else {
		c_local `returnmac' `hnormal'`exponential'`tnormal'
		local __check `hnormal'`exponential'`tnormal'
	}
	if "`__check'" != "tnormal" & ("`model'"=="bc88" | "`model'"=="bc92" | "`model'"=="bc95") {
		local _ymdl = regexr("`model'", "bc", "")
		di as error "Battese & Coelli (`_ymdl') model requires distribution(" in yel "tnormal" in red ")"
		exit 198
	}
	if "`__check'" != "hnormal" & ("`model'"=="kumb90" | "`model'"=="pl81") {
		if "`model'"=="kumb90" local _mdl "Kumbhakar (1990)"
		if "`model'"=="pl81" local _mdl "Pitt and Lee (1981)"
		di as error "`_mdl' model requires distribution(" in yel "hnormal" in red ")"
		exit 198
	}

end

/* ----------------------------------------------------------------- */

program define ParseSimtype
	args returnmacr colon simtype model 

	local 0 ", `simtype'"
	syntax [, RUniform HAlton GENHAlton * ]

	if `"`options'"' != "" {
		di as error "simtype(`options') not allowed"
		exit 198
	}
	if "`model'"!="tre" & "`simtype'"!="" {
		di as error "Option simulation type requires model(" in yel "tre" in red ")"
		exit 198
	}
	local wc : word count `runiform' `halton' `genhalton'

	if `wc' > 1 {
		di as error "simtype() invalid, only " /*
			*/ "one type of simulation can be specified"
		exit 198
	}

	if `wc' == 0 {
		c_local `returnmacr' runiform
	}
	else c_local `returnmacr' `runiform'`halton'`genhalton'

end

program define __sfpanel_destructor
syntax

// DROP compulsory scalars created for structures
local sclist "MaXiterate Simtype Nsimulations Base TOLerance LTOLerance NRTOLerance REPEAT InIt_nparams S_COST CILEVEL eta"
foreach s of local sclist { 
	capture scalar drop `s'
}
// DROP compulsory matrix created for structures
capture matrix drop _CNS
// DROP structures
local strlist "_PoSt_OpT _SV __GHK_"
foreach s of local strlist { 
	capture mata: mata drop `s'
} 

end


exit 

*! version 1.0.1  23aug2010
*! version 1.0.2  15dec2010
*! version 1.1.0  15sep2011
*! version 1.1.1  22sep2011
*! version 1.1.2  20dec2011
*! version 1.2.0  30mar2012
*! version 1.2.1  20may2012
*! version 1.2.2  19aug2012
*! version 1.2.3  25may2015 Corrected a bug that caused different results depending wether the -if var==1- restriction was in the command syntax or the obs were selected using a -keep if var==1- before the command syntax
