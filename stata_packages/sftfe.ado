*! version 1.2.9 19oct2022

* See the end of the file for the versions story

program define sftfe, eclass byable(onecall) prop(xt svyb svyj swml)

    if _by() {
        local BY `"by `_byvars'`_byrc0':"'
    }
	`BY' _vce_parserun sftfe, panel mark(I T) : `0'
	if "`s(exit)'" != "" {
		version 11: ereturn local cmdline `"sftfe `0'"'
		exit
	}
    capt findfile sfcross.ado
    if _rc {
        di as error "-sfcross- is required; type {stata search st0315}"
        error 499
    }
    capt findfile lghk2.mlib
    if _rc {
        di as error "-ghk2()- is required; type {stata search ghk2}"
        error 499
    }

    version 11

        if replay() {
            if _by() {
                error 190
            }
            if "`e(cmd)'" != "sftfe" {
                error 301
            }
                DiSpLaY `0'
                exit
            }

    if _by() {
        by `_byvars' `_byrc0': sftfe_est `0'
    }
    else sftfe_est `0'
    version 11: ereturn local cmdline `"sftfe `0'"'
end



program define sftfe_est, eclass byable(recall) sortpreserve

version 11
syntax varlist(min=2 fv ts) [if] [in] [aweight fweight iweight/] , [ ESTimator(string) Alpha(string) Distribution(string) DYNamic POOLed NOCONS COST  ///
						SEED(string) ///
                        VCE(string) CLuster(string) Robust Level(cilevel) QUADpoints(integer 60) ///
						GHKDraws(string) CONSTRaints(numlist min=1) PAIRDistance(integer 1) ///
                        EMean(string) Usigma(string) Vsigma(string) ematrix(string) ///
						SVFRONTier(namelist) SVEMean(namelist) SVUsigma(namelist) SVVsigma(namelist) SVETA(namelist) SVRho(namelist)  ///
                        SIMTYPE(string) NSIMulations(string) BASE(integer 5)  ///
                        TECHnique(string) ITERate(integer 200) NOWARNing DIFFICULT NOLOG ///
                        TRace GRADient SHOWSTEP HESSian SHOWTOLerance TOLerance(real 1e-6) ///
                        LTOLerance(real 1e-7) NRTOLerance(real 1e-5) FDIFF ///
                        NOSEARCH REPEAT(integer 10) RESTART RESCale POSTSCORE POSTHESSian FORCEHOMO FORCETECHNIQUE *]


if "`seed'"!="" set seed `seed'

*** Is.MDPD
if "`alpha'"!="" scalar alpha = `alpha'
else scalar alpha = 0

*** Quad points
scalar quadpoints = `quadpoints'

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

*** Parsing estimator
ParseEst estimator : `"`estimator'"'


*** Parsing distributions
ParseDistr distribution : `"`distribution'"' `"`estimator'"'

*** Simulation type for MMSLE
ParseSimtype simtype : `"`simtype'"' `"`estimator'"'
if "`estimator'"=="mmsle" local add_crittype "simulated-"


*** Parsing vce options
local crittype "Log `add_crittype'likelihood"
if regexm("`vce'", "cluster") == 1 {
	local clustervar = trim(regexr("`vce'", "cluster", ""))
	local vce "cluster"
	local crittype "Log pseudo`add_crittype'likelihood"
}
if regexm("`vce'", "robust") == 1 {
	local vce "robust"
	local crittype "Log pseudo`add_crittype'likelihood"
}
if "`cluster'" != "" {
	local clustervar "`cluster'"
	local vce "cluster"
	local crittype "Log pseudo`add_crittype'likelihood"
}
if "`robust'" != "" {
	local vce "robust"
	local crittype "Log pseudo`add_crittype'likelihood"
}

*** Set the crtiitype local if MDPD
if "`alpha'"!="" local crittype "Criterion function"

*** Is the PDE pooled?
if "`estimator'" == "pde" {
	if "`distribution'"=="hnormal" | "`distribution'"=="tnormal" | "`distribution'"=="exponential" {
		if "`pooled'"!="" local pdetype "pooled"
		else local pdetype "panel"
	}
	/*
	else if "`distribution'"=="tnormal" {
		/// Da aggioungere la TNORMAL - facile da fare
		noi di as err "-tnormal- distribution not allowed for pooled PDE."
		error 198
		exit
	}*/
}

/// Fix crittype in the case of pde
if "`estimator'"=="pde" local crittype "Criterion function"
if "`estimator'"=="pde" & "`dynamic'"!="" & "`rescale'"=="" {

	di ""
	di in gr "Convergence problems? try using the -rescale- option."
	di in gr "It usually improves initial values reducing the number of subsequent iterations"
	di in gr "required by the optimization technique."

}

***********************************************************************************************************************
******* Assigns objects to correctly create _sftfe_InIt_OpTiMiZaTiOn() and _PoSt_ReSuLt_of_EsTiMaTiOn() structures **********
***********************************************************************************************************************

*** Locals
if "`technique'"=="" local technique "nr"
if "`difficult'"!="" local difficult "hybrid"
else local difficult "m-marquardt"
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
if "`r(wvar)'"!="" local InIt_svy "on"
else local InIt_svy "off"
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
scalar PairDistance = `pairdistance'

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


/** Force some options if user does not specify them
in particular cases */

if "`estimator'"=="pde" & "`distribution'"=="exponential" & "`u'"=="" & "`forcetechnique'"=="" {
	local technique "nr 5 bfgs 5"
	di in gr "Warning: to increase convergence probability,  optimization will switch between NR and BFGS methods."
	di in gr "	   Still convergence problems? try to increase the number of iterations or to add the -difficult- option."
}


************** Tokenize from varlist ***************
gettoken lhs rhs: varlist
local __erhs = trim(itrim("`rhs'"))
if "`usigma'"!="" gettoken u_rhs u_nocons: usigma, parse(",")
if "`vsigma'"!="" gettoken v_rhs v_nocons: vsigma, parse(",")
if "`emean'"!="" gettoken mu_rhs mu_nocons: emean, parse(",")
local u_nocons=rtrim(ltrim(regexr("`u_nocons'", ",", "")))
local v_nocons=rtrim(ltrim(regexr("`v_nocons'", ",", "")))
local mu_nocons=rtrim(ltrim(regexr("`mu_nocons'", ",", "")))
*if "`distribution'"=="tnormal" & "`emean'"!="" local mu_nocons "nocons"
****************************************************


*************** Errors *************
/* RIMETTERE QUESTO STOP
if "`ghkdraws'"!="" {
    noi di as err "-ghkdraws()- option not allowed."
    error 198
    exit
}
*/

if "`nocons'"!="" {
    noi di as err "-nocons- option not allowed in TFE models."
    error 198
    exit
}

if ("`estimator'"=="mmsle") & "`v'"=="v" {
    noi di as err "-vsigma()- is not allowed for -estimator(`estimator')-."
    error 198
    exit
}
if ("`estimator'"=="mmsle" | "`estimator'"=="pde") & ("`vce'"=="robust" | "`vce'"=="cluster" | "`postscore'"!="" | "`posthessian'"!="") {
    if ("`vce'"=="robust" | "`vce'"=="cluster") local whatiswrong "-vce(`vce')-"
	if ("`postscore'"!="" | "`posthessian'"!="") local whatiswrong "postscore and/or posthessian"
    noi di as err "`whatiswrong' is not allowed for -estimator(`estimator')-."
    error 198
    exit
}
if ("`estimator'"=="within" | "`estimator'"=="fdiff") & ("`v'"=="v" | "`u'"=="u") {
	if "`v'"=="v" local whatiswrong "vsigma()"
	if "`u'"=="u" local whatiswrong "usigma()"
    noi di as err "-`whatiswrong'- is not allowed for -estimator(`estimator')-."
    error 198
    exit
}
if (("`estimator'"=="within" | "`estimator'"=="fdiff" | "`estimator'"=="mmsle" | ("`estimator'"=="pde" & "`distribution'"=="exponential")) & "`dynamic'"!="") {
    if "`estimator'"=="pde" loc pdeexeption " and -dist(`distribution')-"
	noi di as err "-dynamic- is not allowed for -estimator(`estimator')-`pdeexeption'."
    error 198
    exit
}
if "`estimator'"=="within" & "`distribution'"!="hnormal" {
    noi di as err "-dist(`distribution')- is not allowed for -estimator(`estimator')-."
    error 198
    exit
}
if "`estimator'"=="mmsle" & "`distribution'"=="tnormal" {
    noi di as err "-dist(`distribution')- is not allowed for -estimator(`estimator')-."
    error 198
    exit
}
if "`estimator'"=="fdiff" & "`distribution'"=="exponential" {
    noi di as err "-dist(`distribution')- is not allowed for -estimator(`estimator')-."
    error 198
    exit
}

if "`estimator'"=="pde" & "`u'"=="" & "`v'"=="" & "`forcehomo'"=="" {
    noi di as err "-estimator(`estimator')- is not allowed when u and v are homoskedastic."
	noi di as err "In this case, you should use -within-,-fdiff- or -mmsle- estimators."
    error 198
    exit
}

********* Factor Variables check ****
local fvops = "`s(fvops)'" == "true" | _caller() >= 11
if `fvops' {
    local vv : di "version " string(max(11,_caller())) ", missing:"
	local _noempty "noempty"
}

********* Factor Variables check for Schmidt et al. 2011 model ****
local fvops = regexm("`rhs'","i\.")
if `fvops'==1 & "`estimator'"=="within" {
	di as err `"estimator(`estimator') does not allow factor variables in the frontier funtion."'
	exit 198
}

*** Get Names
local fvars "rhs mu_rhs u_rhs v_rhs"
foreach l of local fvars {
	fvexpand ``l''
	local _`l'_names "`r(varlist)'"
	fvrevar ``l''
	local `l' "`r(varlist)'"
}

********************* remove collinearity ********************************
`vv' cap noi _rmcoll `rhs' if `touse' `wtopt', `nocons' `coll'
local rhs `r(varlist)'

if "`usigma'"!="" {
    `vv' cap noi _rmcoll `u_rhs' if `touse' `wtopt', `u_nocons' `coll'
    local u_rhs `r(varlist)'
}
if "`vsigma'"!="" {
    `vv' cap noi _rmcoll `v_rhs' if `touse' `wtopt', `v_nocons' `coll'
    local v_rhs `r(varlist)'
}
if "`emean'"!="" {
    `vv' cap noi _rmcoll `mu_rhs' if `touse' `wtopt', `mu_nocons' `coll'
    local mu_rhs `r(varlist)'
}

*** update of esample
markout `touse' `u_rhs' `v_rhs' `mu_rhs'

**********************************************************
******** Create appropriate id and time variables ********
**********************************************************
local id: char _dta[_TSpanel]
local time: char _dta[_TStvar]
tempvar temp_id temp_t
qui egen `temp_id'=group(`id') if `touse'==1
sort `temp_id' `time'
qui by `temp_id': g `temp_t' = _n if `temp_id'!=.
local lxtset "`temp_id' `temp_t'"

*** Check for at least 2 observations for each `temp_id'
tempvar checkpairs
qui by `temp_id': egen `checkpairs' = max(`temp_t')
qui replace `checkpairs' = . if `checkpairs'==1
markout `touse' `checkpairs'

qui xtdes, pattern(0) width(0)
local imax = r(N)

********************** Display info **********************
tempvar Ti
tempname S_E_T g_min g_avg g_max N_g N
qui by `temp_id': gen long `Ti' = _N if _n==_N & `touse'==1
qui summ `Ti' if `touse'==1
scalar `S_E_T' = r(max)
scalar `g_min' = r(min)
scalar `g_avg' = r(mean)
scalar `g_max' = r(max)
qui count if `Ti'<.
scalar `N_g' = r(N)
qui count if `touse'==1
scalar `N' = r(N)


*** Estimator specific:
** MMSLE
if "`estimator'"=="mmsle" {
	if "`simtype'"=="uniform" scalar Simtype = 1
	else if "`simtype'" == "halton" scalar Simtype = 2

	if "`nsimulations'"!="" scalar Nsimulations = `nsimulations'
	else {
		if "`simtype'"=="halton" {
			if "`usigma'"!="" {
				scalar Nsimulations = 30 * `N'
				loc nsimulations = 30 * `N'
			}
			else {
				scalar Nsimulations = 10 * `N'
				loc nsimulations = 10 * `N'
			}
		}
		else {
			if "`usigma'"!="" {
				scalar Nsimulations = 60 * `N'
				loc nsimulations = 60 * `N'
			}
			else {
				scalar Nsimulations = 30 * `N'
				loc nsimulations = 30 * `N'
			}
		}
	}

	scalar Base = `base'
}

/* This is useless since we realized that the mmsle works even when `v' is not constant within panel id */
/*
if "`estimator'"=="mmsle" & "`u_rhs'"!=""  {
	/* Check if usigma-->varlist is time constant within panel */
	sort `temp_id'
	foreach v of local u_rhs {
		tempvar __sd_`v'
		qui by `temp_id': egen `__sd_`v''=sd(`v')
		qui sum `__sd_`v''
		local `v'_sd_max=r(max)
		if ``v'_sd_max' != 0  {
			display as error "`v' is not constant within panel id. -usigma()- varlist must include only time-invariant variables with estimator(`estimator')."
			display as error "You may want to use estimator(pde) in this case."
			error 198
		}
	}
}
*/

***************************************************************************
*** GHK parsing (adapted from -cmp-)

if ("`ghkdraws'"=="" & "`distribution'"=="tnormal" & "`estimator'"=="fdiff") {
	//di in gr `"-`estimator'- estimator with `distribution' distribution requires the ghkdraws() specification."'
	//di in gr "ghkdraws(1000, type(halton)) has been set by default."
	loc ghkdraws `"1000, type(halton)"'
}

if "`ghkdraws'"!=""  {

	local 0 `ghkdraws'
	syntax [anything], [type(string) PIVOT ANTIthetics]
	if `"`type'"' != "" local ghktype `type'
	else local ghktype halton
	if `"`pivot'"' != "" scalar ghkpivot = 1
	else scalar ghkpivot = 0
	if `"`antithetics'"' != "" scalar ghkanti = 1
	else scalar ghkanti = 0

	local 0, ghkdraws(`anything')
	syntax, [ghkdraws(numlist integer>=1 max=1)]
	scalar ghkdraws = `ghkdraws'

	if inlist(`"`ghktype'"', "halton", "hammersley", "random") == 0 {
		di as error `"The {cmdab:ghkd:raws}' suboption {cmdab:t:ype()} must be "halton", "hammersley", or "random". It corresponds to the {cmd:ghk_init_method} option of {cmd:ghk()}. See help {help mf_ghk}."'
		error 198
	}
}
else scalar ghkdraws = .

if ("`ghkdraws'"=="" & "`distribution'"=="hnormal" & "`estimator'"=="fdiff" & ("`usigma'"!="" | "`vsigma'"!="")) {
	di as err `"-`estimator'- estimator with heteroskedastic `distribution' inefficiency distribution requires the ghkdraws() specification."'
	exit 198
}

*********************************************************************************************
******************** Starting values, variable names and initialisation *********************
*********************************************************************************************

*************** Count of parameters for starting values *******************

local nsv_frontier: word count `rhs'

if "`mu_nocons'" != "" {
	local nsv_emean: word count `mu_rhs'
	local mucommacons ","
}
else {
	local nsv_emean :word count `mu_rhs' _cons
	local _mucons _cons
}
if "`u_nocons'" != "" {
	local nsv_usigma: word count `u_rhs'
	local ucommacons ","
}
else {
	local nsv_usigma :word count `u_rhs' _cons
	local _usigmacons _cons
}
if "`v_nocons'" != "" {
	local nsv_vsigma: word count `v_rhs'
	local vcommacons ","
}
else {
	local nsv_vsigma :word count `v_rhs' _cons
	local _vsigmacons _cons
}

** Check if user's starting values matrices are conformable
local _checklist "frontier emean usigma vsigma"
foreach _check of local _checklist {
	if "`sv`_check''" != "" {
		local _check_usv_`_check' = colsof(`sv`_check'')
		if `_check_usv_`_check'' != `nsv_`_check'' {
			noi di as err "User specified starting values in " in yel "sv`_check'()" in red " do not match " in yel "`_check'()" in red " regressors number"
		    error 198
		    exit
		}
	}
}

***************************************************************************

	if "`estimator'"=="pde" | "`estimator'"=="mmsle"  {

		if "`distribution'"=="hnormal" {
			tempname init_beta init_usigma init_vsigma
			if "`svfrontier'"=="" {
				tempname init_params
				cap qui sfcross `lhs' `rhs', d(hn) difficult `cost' u(`u_rhs' `ucommacons' `u_nocons') v(`v_rhs' `vcommacons' `v_nocons') iter(50)
				local _sfcross_conv "`e(converged)'"
				if "`_sfcross_conv'" == "0" qui reg `lhs' `rhs'
				mat `init_params'=e(b)
				mat `init_beta' = `init_params'[1,1..`nsv_frontier']
			}
			else mat `init_beta' = `svfrontier'
			mat colnames `init_beta' =`_rhs_names'
			mat coleq `init_beta' = "Frontier"
			*** Consider the constant term to get starting values, then increase nsv_frontier
			local nsv_frontier = `nsv_frontier'+1

			if "`svusigma'"=="" {
				if "`usigma'"!="" & "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_usigma' = `init_params'[1,`nsv_frontier'+1..`nsv_frontier'+`nsv_usigma']
				else if "`usigma'"=="" & "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_usigma' = e(sigma_u)
				else matrix `init_usigma' = J(1, `:word count `_u_rhs_names' `_usigmacons'', 0.25)
			}
			else mat `init_usigma' = `svusigma'
			mat colnames `init_usigma' = `_u_rhs_names' `_usigmacons'
			mat coleq `init_usigma' = "Usigma"

			if "`svvsigma'"=="" {
				if "`vsigma'"!="" & "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_vsigma' = `init_params'[1,`nsv_frontier'+`nsv_usigma'+1..`nsv_frontier'+`nsv_usigma'+`nsv_vsigma']
				else if "`vsigma'"=="" & "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_vsigma' = e(sigma_v)
				else matrix `init_vsigma' = J(1, `:word count `_v_rhs_names' `_vsigmacons'', 0.15)
			}
			else mat `init_vsigma' = `svvsigma'
			mat colnames `init_vsigma' = `_v_rhs_names' `_vsigmacons'
			mat coleq `init_vsigma' = "Vsigma"

			/**** PROVA
			tempname init_lambda
			mat `init_lambda' = 2
			mat colnames `init_lambda' = _cons
			mat coleq `init_lambda' = "Usigma"
			tempname init_sigma2
			mat `init_sigma2' = 1.2
			mat colnames `init_sigma2' = _cons
			mat coleq `init_sigma2' = "Vsigma"*/

			/**PROVA
			tempname init_mu
			mat `init_mu' = 1.5
			mat colnames `init_mu' = _cons
			mat coleq `init_mu' = "Mu"*/

			if "`dynamic'"!="" {
				tempname init_rho
				if "`svrho'" != "" mat `init_rho' = `svrho'
				else mat `init_rho' = .3
				mat colnames `init_rho' = _cons
				mat coleq `init_rho' = "Rho"
				local _init_rho "init_rho"
			}
			if "`ematrix'"!="" {
				tempname init_rho
				if "`svrho'" != "" mat `init_rho' = `svrho'
				else mat `init_rho' = .3
				mat colnames `init_rho' = _cons
				mat coleq `init_rho' = "Rho"
				local _init_rho "init_rho"
			}

			******************** This block MUST be included for each estimator ***********************
			local _params_list "init_beta init_usigma init_vsigma `_init_rho'"
			local _params_num = 1
			scalar InIt_nparams = wordcount("`_params_list'")
			/// Structure definition for initialisation
			mata: _sftfe_SV = J(1, st_numscalar("InIt_nparams"), _sftfe_starting_values())
			foreach _params of local _params_list {
				mata: _sftfe_SV = _sftfe_StArTiNg_VaLuEs("``_params''", `_params_num', _sftfe_SV)
				** The following to check the content of the structure ** Just for debugging
				*mata: liststruct(_sftfe_SV)
				local _params_num = `_params_num' + 1
			}

			if "`estimator'"=="pde" {
				if "`usigma'" == "" & "`vsigma'" == "" & "`dynamic'"=="" {
					local InIt_evaluator "_pde_hn"
					local InIt_evaluatortype "v0"
				}
				else {
					local InIt_evaluator "_pde_hn_het"
					local InIt_evaluatortype "v0"
				}
			}
			else if "`estimator'"=="mmsle" & "`ematrix'"=="" {
				if "`usigma'" == "" & "`vsigma'" == "" {
					local InIt_evaluator "_mmsle"
					local InIt_evaluatortype "gf2"
				}
				else if "`usigma'" != "" & "`vsigma'" == "" {
					local InIt_evaluator "_mmsle_het"
					local InIt_evaluatortype "gf0"
				}
			}
			else if "`estimator'"=="mmsle" & "`ematrix'"!="" {
				if "`usigma'" != "" & "`vsigma'" == "" {
					local InIt_evaluator "_mmsle_het_sem"
					local InIt_evaluatortype "gf0"
				}
			}

			*** Parsing of constraints (if defined)
			//_parse_constraints, constraintslist(`constraints') estparams(`=subinstr("`_params_list'", " ", ",",.)')
			if "`_init_rho'"=="" loc para_constr "`init_beta', `init_usigma', `init_vsigma'"
			else loc para_constr "`init_beta', `init_usigma', `init_vsigma', `init_rho'"
			_parse_constraints, constraintslist(`constraints') estparams(`para_constr')
			mata: _sftfe_InIt_OpT = _sftfe_InIt_OpTiMiZaTiOn()
			** The following to check the content of the structure ** Just for debugging
			*mata: liststruct(_sftfe_InIt_OpT)
			*******************************************************************************************
		} // Close distribution options

		if "`distribution'"=="tnormal" {
			tempname init_beta init_usigma init_vsigma init_emean

			local eqmu ""
			forvalues f=1/`nsv_emean' {
				local eqmu "`eqmu' Mu"
			}

			if "`svfrontier'"=="" {
				tempname init_params

				cap qui sfcross `lhs' `rhs',  d(tn) `cost' emean(`mu_rhs' `mucommacons' `mu_nocons') u(`u_rhs' `ucommacons' `u_nocons') v(`v_rhs' `vcommacons' `v_nocons') difficult iter(50)
				local _sfcross_conv "`e(converged)'"
				if _rc != 0 qui reg `lhs' `rhs'
				mat `init_params' =e(b)
				mat `init_beta' = `init_params'[1,1..`nsv_frontier']
			}
			else mat `init_beta' = `svfrontier'
			mat colnames `init_beta' =`_rhs_names'
			mat coleq `init_beta' = "Frontier"
			*** Consider the constant term to get starting values, then increase nsv_frontier
			local nsv_frontier = `nsv_frontier'+1

			if "`svemean'"=="" {
				if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_emean' = `init_params'[1,`nsv_frontier'+1..`nsv_frontier'+`nsv_emean']
				else matrix `init_emean' = J(1, `:word count `_mu_rhs_names' `_mucons'', .8)
			}
			else mat `init_emean' = `svemean'
			mat colnames `init_emean' = `_mu_rhs_names' `_mucons'
			mat coleq `init_emean' = "Mu"
			if "`svusigma'"=="" {
				if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_usigma' = `init_params'[1,`nsv_frontier'+`nsv_emean'+1..`nsv_frontier'+`nsv_emean'+`nsv_usigma']
				else matrix `init_usigma' = J(1, `:word count `_u_rhs_names' `_usigmacons'', 0)
			}
			else mat `init_usigma' = `svusigma'
			mat colnames `init_usigma' = `_u_rhs_names' `_usigmacons'
			mat coleq `init_usigma' = "Usigma"
			if "`svvsigma'"=="" {
				if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_vsigma' = `init_params'[1,`nsv_frontier'+`nsv_emean'+`nsv_usigma'+1..`nsv_frontier'+`nsv_emean'+`nsv_usigma'+`nsv_vsigma']
				else matrix `init_vsigma' = J(1, `:word count `_v_rhs_names' `_vsigmacons'', 0)
			}
			else mat `init_vsigma' = `svvsigma'
			mat colnames `init_vsigma' = `_v_rhs_names' `_vsigmacons'
			mat coleq `init_vsigma' = "Vsigma"

			/**** PROVA
			tempname init_lambda
			mat `init_lambda' = 2
			mat colnames `init_lambda' = _cons
			mat coleq `init_lambda' = "Usigma"
			tempname init_sigma2
			mat `init_sigma2' = 1.2
			mat colnames `init_sigma2' = _cons
			mat coleq `init_sigma2' = "Vsigma"*/

			/**PROVA
			tempname init_mu
			mat `init_mu' = 1.5
			mat colnames `init_mu' = _cons
			mat coleq `init_mu' = "Mu"*/

			if "`dynamic'"!="" {
				tempname init_rho
				mat `init_rho' = .1
				mat colnames `init_rho' = _cons
				mat coleq `init_rho' = "Rho"
				local _init_rho "init_rho"
			}

			******************** This block MUST be included for each estimator ***********************
			local _params_list "init_beta init_usigma init_vsigma init_emean `_init_rho'"
			local _params_num = 1
			scalar InIt_nparams = wordcount("`_params_list'")
			/// Structure definition for initialisation
			mata: _sftfe_SV = J(1, st_numscalar("InIt_nparams"), _sftfe_starting_values())
			foreach _params of local _params_list {
				mata: _sftfe_SV = _sftfe_StArTiNg_VaLuEs("``_params''", `_params_num', _sftfe_SV)
				** The following to check the content of the structure ** Just for debugging
				*mata: liststruct(_sftfe_SV)
				local _params_num = `_params_num' + 1
			}

			/*if "`usigma'" == "" {
				local InIt_evaluator "_pde_tn"
				local InIt_evaluatortype "v0"
			}
			else {
			*/
				local InIt_evaluator "_pde_tn_het"
				local InIt_evaluatortype "v0"
			*}

			*** Parsing of constraints (if defined)
			_parse_constraints, constraintslist(`constraints') estparams(`=subinstr("`_params_list'", " ", ",",.)')

			mata: _sftfe_InIt_OpT = _sftfe_InIt_OpTiMiZaTiOn()
			** The following to check the content of the structure ** Just for debugging
			*mata: liststruct(_sftfe_InIt_OpT)
			*******************************************************************************************
		} // Close distribution options

		if "`distribution'"=="exponential" {
			tempname init_beta init_usigma init_vsigma

			if "`svfrontier'"=="" {
				tempname init_params
				cap qui sfcross `lhs' `rhs', d(e) `cost' u(`u_rhs' `ucommacons' `u_nocons') v(`v_rhs' `vcommacons' `v_nocons') iter(50)
				local _sfcross_conv "`e(converged)'"
				if "`_sfcross_conv'" == "0" qui reg `lhs' `rhs'
				mat `init_params'=e(b)
				mat `init_beta' = `init_params'[1,1..`nsv_frontier']
			}
			else mat `init_beta' = `svfrontier'
			mat colnames `init_beta' =`_rhs_names'
			mat coleq `init_beta' = "Frontier"

			*** Consider the constant term to get starting values, then increase nsv_frontier
			local nsv_frontier = `nsv_frontier'+1

			if "`svusigma'"=="" {
				if "`usigma'"!="" {
					if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_usigma' = `init_params'[1,`nsv_frontier'+1..`nsv_frontier'+`nsv_usigma']
					else matrix `init_usigma' = J(1, `:word count `_u_rhs_names' `_usigmacons'', 0.1)
				}
				else {
					if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_usigma' = e(sigma_u)
					else matrix `init_usigma' = J(1, `:word count `_u_rhs_names' `_usigmacons'', 0.25)
				}
			}
			else mat `init_usigma' = `svusigma'
			mat colnames `init_usigma' = `_u_rhs_names' `_usigmacons'
			mat coleq `init_usigma' = "Usigma"

			if "`svvsigma'"=="" {
				if "`vsigma'"!="" {
					if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_vsigma' = `init_params'[1,`nsv_frontier'+`nsv_usigma'+1..`nsv_frontier'+`nsv_usigma'+`nsv_vsigma']
					else matrix `init_vsigma' = J(1, `:word count `_v_rhs_names' `_vsigmacons'', 0.1)
				}
				else {
					if "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_vsigma' = e(sigma_v)
					else matrix `init_vsigma' = J(1, `:word count `_v_rhs_names' `_vsigmacons'', 0.2)
				}
			}
			else mat `init_vsigma' = `svvsigma'
			mat colnames `init_vsigma' = `_v_rhs_names' `_vsigmacons'
			mat coleq `init_vsigma' = "Vsigma"

			******************** This block MUST be included for each estimator ***********************
			local _params_list "init_beta init_usigma init_vsigma"

			local _params_num = 1
			scalar InIt_nparams = wordcount("`_params_list'")
			/// Structure definition for initialisation
			mata: _sftfe_SV = J(1, st_numscalar("InIt_nparams"), _sftfe_starting_values())
			foreach _params of local _params_list {
				mata: _sftfe_SV = _sftfe_StArTiNg_VaLuEs("``_params''", `_params_num', _sftfe_SV)
				** The following to check the content of the structure ** Just for debugging
				*mata: liststruct(_sftfe_SV)
				local _params_num = `_params_num' + 1
			}
			if "`usigma'" == "" & "`vsigma'" == "" {
				if "`estimator'"=="pde" {
					local InIt_evaluator "_pde_exp"
					local InIt_evaluatortype "v1"
				}
				if "`estimator'"=="mmsle" {
					local InIt_evaluator "_mmsle"
					local InIt_evaluatortype "gf2"
				}
			}
			else if "`usigma'" != "" & "`vsigma'" == "" {
				if "`estimator'"=="pde" {
					local InIt_evaluator "_pde_exp_het"
					local InIt_evaluatortype "v1"
				}
				if "`estimator'"=="mmsle" {
					local InIt_evaluator "_mmsle_het"
					local InIt_evaluatortype "gf0"
				}
			}
			else if "`usigma'" == "" & "`vsigma'" != "" {
				if "`estimator'"=="pde" {
					local InIt_evaluator "_pde_exp_het"
					local InIt_evaluatortype "v0"
				}
			}
			else if "`usigma'" != "" & "`vsigma'" != "" {
				if "`estimator'"=="pde" {
					local InIt_evaluator "_pde_exp_het"
					local InIt_evaluatortype "v0"
				}
			}
			*** Parsing of constraints (if defined)
			_parse_constraints, constraintslist(`constraints') estparams(`=subinstr("`_params_list'", " ", ",",.)'')

			mata: _sftfe_InIt_OpT = _sftfe_InIt_OpTiMiZaTiOn()
			** The following to check the content of the structure ** Just for debugging
			*mata: liststruct(_sftfe_InIt_OpT)
			*******************************************************************************************
		} // Close distribution options

	}

	if "`estimator'"=="within" | "`estimator'"=="fdiff" {

		if "`distribution'"=="hnormal" {

			tempname init_beta init_sigma2 init_lambda
			if "`svfrontier'"=="" {
				tempname init_params
				cap qui sfcross `lhs' `rhs', d(hn) u(`usigma' `ucommacons' `u_nocons') v(`vsigma' `vcommacons' `v_nocons') `cost'  iter(50)
				if _rc != 0 qui reg `lhs' `rhs'
				mat `init_params'=e(b)
				mat `init_beta' = `init_params'[1,1..`nsv_frontier']
			}
			else mat `init_beta' = `svfrontier'
			mat colnames `init_beta' = `_rhs_names' `_frontcons'
			mat coleq `init_beta' = "Frontier"

			if "`estimator'"=="within" {
					if "`e(cmd)'" =="sfcross" mat `init_sigma2' = e(sigma_u)^2+e(sigma_v)^2
					if ("`e(cmd)'" =="regress" | "`e(cmd)'" =="") matrix `init_sigma2' = .2

					mat colnames `init_sigma2' = _cons
					mat coleq `init_sigma2' = "Sigma2"

					if "`e(cmd)'" =="sfcross" mat `init_lambda' = e(sigma_u)/e(sigma_v)
					if ("`e(cmd)'" =="regress" | "`e(cmd)'" =="") matrix `init_lambda' = 2
					mat colnames `init_lambda' = _cons
					mat coleq `init_lambda' = "Lambda"
			}
		    else {

				  if "`ghkdraws'"=="" {
					if "`e(cmd)'" =="sfcross" mat `init_sigma2' = e(sigma_u)^2+e(sigma_v)^2
					if ("`e(cmd)'" =="regress" | "`e(cmd)'" =="") matrix `init_sigma2' = .2

					mat colnames `init_sigma2' = _cons
					mat coleq `init_sigma2' = "Sigma2"

					if "`e(cmd)'" =="sfcross" mat `init_lambda' = e(sigma_u)/e(sigma_v)
					if ("`e(cmd)'" =="regress" | "`e(cmd)'" =="") matrix `init_lambda' = 2
					mat colnames `init_lambda' = _cons
					mat coleq `init_lambda' = "Lambda"
				  }
			      else {
					*** Consider the constant term to get starting valeus
					local nsv_frontier = `nsv_frontier'+1
					tempname init_sigma init_psi
					if "`svusigma'"=="" {
						if "`usigma'"=="" & "`e(cmd)'" =="sfcross" mat `init_sigma' = e(sigma_u)
						else if "`usigma'"!="" & "`e(cmd)'" =="sfcross" mat `init_sigma' = `init_params'[1,`nsv_frontier'+1..`nsv_frontier'+`nsv_usigma']
						else matrix `init_sigma' = J(1, `:word count `_u_rhs_names' `_usigmacons'', -.9)
					}
					else mat `init_sigma' = `svusigma'
					mat colnames `init_sigma' = `_u_rhs_names' `_usigmacons'
					mat coleq `init_sigma' = "Usigma"

					if "`svvsigma'"=="" {
						if "`vsigma'"=="" & "`e(cmd)'" =="sfcross" mat `init_psi' = e(sigma_v)
						else if "`vsigma'"!="" & "`e(cmd)'" =="sfcross" mat `init_psi' = `init_params'[1,`nsv_frontier'+`nsv_usigma'+1..`nsv_frontier'+`nsv_usigma'+`nsv_vsigma']
						else matrix `init_psi' = J(1, `:word count `_v_rhs_names' `_vsigmacons'', -1.5)
					}
					else mat `init_psi' = `svvsigma'
					mat colnames `init_psi' = `_v_rhs_names' `_vsigmacons'
					mat coleq `init_psi' = "Vsigma"

					if "`dynamic'"!="" {
						tempname init_rho
						mat `init_rho' = .5
						mat colnames `init_rho' = _cons
						mat coleq `init_rho' = "Rho"
						local _init_rho "init_rho"
					}
				}
			}

			******************** This block MUST be included for each estimator ***********************
			if "`estimator'"=="within"  local _params_list "init_beta init_sigma2 init_lambda"
			if "`estimator'"=="fdiff" {
				if "`ghkdraws'"==""  local _params_list "init_beta init_sigma2 init_lambda"
				else local _params_list "init_beta init_sigma init_psi `_init_rho'"
			}
			local _params_num = 1
			scalar InIt_nparams = wordcount("`_params_list'")
			/// Structure definition for initialisation
			mata: _sftfe_SV = J(1, st_numscalar("InIt_nparams"), _sftfe_starting_values())
			foreach _params of local _params_list {
				mata: _sftfe_SV = _sftfe_StArTiNg_VaLuEs("``_params''", `_params_num', _sftfe_SV)
				** The following to check the content of the structure ** Just for debugging
				*mata: liststruct(_sftfe_SV)
				local _params_num = `_params_num' + 1
			}
			if "`estimator'"=="within" local InIt_evaluator "_within_hn"
			if "`estimator'"=="fdiff" & ("`usigma'"=="" & "`vsigma'"=="") local InIt_evaluator "_fdiff_hn"
			if "`estimator'"=="fdiff" & ("`usigma'"!="" | "`vsigma'"!="")  local InIt_evaluator "_fdiff_hn_het2"
			local InIt_evaluatortype "gf0"
			*** Parsing of constraints (if defined)
			_parse_constraints, constraintslist(`constraints') estparams(`=subinstr("`_params_list'", " ", ",",.)')

			mata: _sftfe_InIt_OpT = _sftfe_InIt_OpTiMiZaTiOn()
			** The following to check the content of the structure ** Just for debugging
			*mata: liststruct(_sftfe_InIt_OpT)
			*******************************************************************************************
		}
		if "`distribution'"=="tnormal" {

			local eqmu ""
			forvalues f=1/`nsv_emean' {
				local eqmu "`eqmu' Mu"
			}

			tempname init_beta init_emean init_usigma init_vsigma init_sigma2 init_lambda

			if "`svfrontier'"=="" {
				tempname init_params

				cap qui sfcross `lhs' `rhs', nocons d(tn) `cost' emean(`mu_rhs' `mucommacons' `mu_nocons') u(`u_rhs' `ucommacons' `u_nocons') v(`v_rhs' `vcommacons' `v_nocons')  iter(50)
				local _sfcross_conv "`e(converged)'"
				if _rc != 0 qui reg `lhs' `rhs'
				mat `init_params' =e(b)
				mat `init_beta' = `init_params'[1,1..`nsv_frontier']
			}
			else mat `init_beta' = `svfrontier'
			mat colnames `init_beta' =`_rhs_names'
			mat coleq `init_beta' = "Frontier"

			if "`svemean'"=="" {
			    //*** Consider the constant term to get starting valeus
				//local nsv_frontier = `nsv_frontier'+1
				if "`emean'"!="" & "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_emean' = `init_params'[1,`nsv_frontier'+1..`nsv_frontier'+`nsv_emean']
				else matrix `init_emean' = J(1, `:word count `_mu_rhs_names' `_mucons'', 1)
			}
			else mat `init_emean' = `svemean'
			mat colnames `init_emean' = `_mu_rhs_names' `_mucons'
			mat coleq `init_emean' = "Mu"

			if "`ghkdraws'"=="" {
					if "`e(cmd)'" =="sfcross" mat `init_sigma2' = e(sigma_u)^2+e(sigma_v)^2
					if ("`e(cmd)'" =="regress" | "`e(cmd)'" =="") matrix `init_sigma2' = .2

					mat colnames `init_sigma2' = _cons
					mat coleq `init_sigma2' = "Sigma2"

					if "`e(cmd)'" =="sfcross" mat `init_lambda' = e(sigma_u)/e(sigma_v)
					if ("`e(cmd)'" =="regress" | "`e(cmd)'" =="") matrix `init_lambda' = 2
					mat colnames `init_lambda' = _cons
					mat coleq `init_lambda' = "Lambda"
			}
			else {

				if "`svusigma'"=="" {
					if "`usigma'"!="" & "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_usigma' = `init_params'[1,`nsv_frontier'+`nsv_emean'+1..`nsv_frontier'+`nsv_emean'+`nsv_usigma']
					else matrix `init_usigma' = J(1, `:word count `_u_rhs_names' `_usigmacons'', -.9)
				}
				else mat `init_usigma' = `svusigma'
				mat colnames `init_usigma' = `_u_rhs_names' `_usigmacons'
				mat coleq `init_usigma' = "Usigma"
				if "`svvsigma'"=="" {
					if "`vsigma'"!="" & "`e(cmd)'" =="sfcross" & "`_sfcross_conv'" =="1" mat `init_vsigma' = `init_params'[1,`nsv_frontier'+`nsv_emean'+`nsv_usigma'+1..`nsv_frontier'+`nsv_emean'+`nsv_usigma'+`nsv_vsigma']
					else matrix `init_vsigma' = J(1, `:word count `_v_rhs_names' `_vsigmacons'', -1.5)
				}
				else mat `init_vsigma' = `svvsigma'
				mat colnames `init_vsigma' = `_v_rhs_names' `_vsigmacons'
				mat coleq `init_vsigma' = "Vsigma"

				if "`dynamic'"!="" {
					tempname init_rho
					mat `init_rho' = .5
					mat colnames `init_rho' = _cons
					mat coleq `init_rho' = "Rho"
					local _init_rho "init_rho"
				}

			}

			******************** This block MUST be included for each estimator ***********************
			local _params_list "init_beta init_emean init_usigma init_vsigma `_init_rho'"


			local _params_num = 1
			scalar InIt_nparams = wordcount("`_params_list'")
			/// Structure definition for initialisation
			mata: _sftfe_SV = J(1, st_numscalar("InIt_nparams"), _sftfe_starting_values())
			foreach _params of local _params_list {
				mata: _sftfe_SV = _sftfe_StArTiNg_VaLuEs("``_params''", `_params_num', _sftfe_SV)
				** The following to check the content of the structure ** Just for debugging
				//mata: liststruct(_sftfe_SV)
				local _params_num = `_params_num' + 1
			}
			//if "`estimator'"=="fdiff" &  ("`usigma'"=="" & "`vsigma'"=="") local InIt_evaluator "_fdiff_tn"
			//if "`estimator'"=="fdiff" &  ("`usigma'"!="" | "`vsigma'"!="") local InIt_evaluator "_fdiff_tn_het2"
			if "`estimator'"=="fdiff"  local InIt_evaluator "_fdiff_tn"
			local InIt_evaluatortype "gf0"
			*** Parsing of constraints (if defined)
			_parse_constraints, constraintslist(`constraints') estparams(`init_beta', `init_emean', `init_usigma', `init_vsigma')

			mata: _sftfe_InIt_OpT = _sftfe_InIt_OpTiMiZaTiOn()

			** The following to check the content of the structure ** Just for debugging
			*mata: liststruct(_sftfe_InIt_OpT)
		} // Close distribution option
	}

local evarlist "`lhs' `rhs'"

///////////////////////////////////////////////////////////////////
////////////////////////// Estimation /////////////////////////////
///////////////////////////////////////////////////////////////////

	*** Collect post-results options
	mata: _sftfe_PoSt_OpT = _sftfe_PoSt_ReSuLt_of_EsTiMaTiOn()
	*** Get Data
	mata: _sftfe_DaTa = _sftfe_GeT_dAtA("`evarlist'", "`touse'", "`lxtset'", "`estimator'", "`distribution'","`nocons'", "`emean'", "`usigma'", "`vsigma'", "`mu_rhs'", "`u_rhs'", "`v_rhs'", "`mu_nocons'", "`u_nocons'", "`v_nocons'", "`fdiff'", "`dynamic'", "`pdetype'", _sftfe_InIt_OpT, &_sftfe_mmsle_util_funct(), `ematrix')
	*** Estimation
	/* This is to handle correctly mopt___struct version */
    local ver_call "`c(stata_version)'"
	**************************
	noi mata: _sftfe_Results = _sftfe_sf_est_ml("`estimator'", "`distribution'", _sftfe_DaTa, _sftfe_SV, _sftfe_InIt_OpT, _sftfe_PoSt_OpT, "`pdetype'", "`ver_call'")

///////////////// RePost VCE if needed /////////////////
if `g_max'>2 & "`estimator'" == "pde" eret repost V = __V_
if "`ematrix'"!="" eret repost V =  __V_

///////////////// Post and Display results /////////////////
*** Common post not in sf_est_ml()
eret local predict "sftfe_p"
eret local cmd "sftfe"
eret local depvar "`lhs'"
eret local estimator "`estimator'"
if "`ematrix'"!="" {
		eret local ematrix "`ematrix'"
		eret local upattern "sar"
		tempname __rho_
		scalar `__rho_' = [Rho]_cons
		//eret scalar rho = normal(`__rho_')
		eret scalar rho = `__rho_'
}
if "`dynamic'"!="" {
	eret local upattern "ar1"
	tempname __rho_
	scalar `__rho_' = [Rho]_cons
	eret scalar rho = (exp(2*`__rho_')-1)/(exp(2*`__rho_')+1)
}
if "`dynamic'"=="" & "`ematrix'"=="" eret local upattern "unstructured"
if "`ghkdraws'"!="" {
	eret local ghk_type "`ghktype'"
	eret scalar ghk_npts = ghkdraws
	eret local ghk_pivot = ghkpivot
	eret local ghk_anti = ghkanti
}
eret local crittype "`crittype'"
if "`e(estimator)'"=="mmsle" {
	eret local simtype "`simtype'"
	eret scalar nsim = `nsimulations'
}
eret local function "`function'"
eret local ivar `id'
eret local tvar `time'
eret local het "`u'`v'"
eret local dist "`distribution'"
eret local covariates "`__erhs'"
eret scalar g_min = `g_min'
eret scalar g_avg = `g_avg'
eret scalar g_max = `g_max'
eret scalar N_g = `N_g'
eret scalar N = `N'
eret scalar Q = _Cfv
eret scalar iterations = _iTeRn
if "`mu_rhs'"!="" eret local mu_rhs "`mu_rhs'"
if "`u_rhs'"!="" eret local u_rhs "`u_rhs'"
if "`v_rhs'"!="" eret local v_rhs "`v_rhs'"

if "`e(estimator)'"=="pde" {
	if "`e(het)'"=="" {
		if "`e(dist)'"=="exponential" {
			// Here due to the way in which gradient is computed the parametrization uses directly sigma_u and sigma_v
			eret scalar sigma_u = [Usigma]_cons
			eret scalar sigma_v = [Vsigma]_cons
		}
		else {
			eret scalar sigma_u = exp([Usigma]_cons)
			eret scalar sigma_v = exp([Vsigma]_cons)
		}
	}
	else {
		if "`e(dist)'"=="exponential" {
			tempvar xb_u sigma_uhet
			qui _predict double `xb_u' if `touse', xb eq(Usigma)
			qui gen double `sigma_uhet' = exp(`xb_u')
			sum `sigma_uhet',mean
			eret scalar sigma_u = r(mean)

			eret scalar sigma_v = exp([Vsigma]_cons)
		}
		if "`e(dist)'"=="hnormal" | "`e(dist)'"=="tnormal" {
			tempvar xb_u sigma_uhet xb_v sigma_vhet
			qui _predict double `xb_u' if `touse', xb eq(Usigma)
			qui gen double `sigma_uhet' = exp(`xb_u')
			sum `sigma_uhet',mean
			eret scalar sigma_u = r(mean)
			qui _predict double `xb_v' if `touse', xb eq(Vsigma)
			qui gen double `sigma_vhet' = exp(`xb_v')
			sum `sigma_vhet',mean
			eret scalar sigma_v = r(mean)
		}
	}
}

if "`e(estimator)'"=="mmsle" {
	if "`usigma'"==""  {
		// Here due to the way in which gradient is computed the parametrization uses directly sigma_u and sigma_v
		eret scalar sigma_u = [Usigma]_cons
	}
	if "`vsigma'"==""  {
		if "`usigma'"=="" {
			// Here due to the way in which gradient is computed the parametrization uses directly sigma_u and sigma_v
			eret scalar sigma_v = [Vsigma]_cons
		}
		else eret scalar sigma_v = exp([Vsigma]_cons)
	}

	if "`usigma'"!= "" {
		tempvar xb_u sigma_uhet
		qui _predict double `xb_u' if `touse', xb eq(Usigma)
		qui gen double `sigma_uhet' = exp(`xb_u')
		sum `sigma_uhet',mean
		eret scalar sigma_u = r(mean)
	}
	if "`vsigma'"!= "" {
		tempvar xb_v sigma_vhet
		qui _predict double `xb_v' if `touse', xb eq(Vsigma)
		qui gen double `sigma_vhet' = exp(`xb_v')
		noi sum `sigma_vhet',mean
		eret scalar sigma_v = r(mean)
	}
}

if "`e(estimator)'"=="within" | ("`e(estimator)'"=="fdiff" & "`e(dist)'"=="hnormal" & "`e(ghk_type)'"=="") {
	eret scalar sigma_u = sqrt(_b[Sigma2:_cons]/(1 + (1/_b[Lambda:_cons]^2)))
	eret scalar sigma_v = sqrt(_b[Sigma2:_cons]/(1+_b[Lambda:_cons]^2))
}
if ("`e(estimator)'"=="fdiff" & "`e(dist)'"=="hnormal" & "`e(ghk_type)'"!="" & "`e(het)'"=="") {
	eret scalar sigma_u = [Usigma]_cons
	eret scalar sigma_v = [Vsigma]_cons
}
if ("`e(estimator)'"=="fdiff" & "`e(dist)'"=="tnormal" & "`e(ghk_type)'"!="" & "`e(het)'"=="") {
	eret scalar sigma_u = exp([Usigma]_cons)
	eret scalar sigma_v = exp([Vsigma]_cons)
}
if ("`e(estimator)'"=="fdiff" & ("`e(dist)'"=="tnormal" | "`e(dist)'"=="hnormal") & ("`e(het)'"=="u" | "`e(het)'"=="uv") & "`e(ghk_type)'"!="") {
	tempvar xb_u sigma_uhet
	qui _predict double `xb_u' if `touse', xb eq(Usigma)
	qui gen double `sigma_uhet' = exp(`xb_u')
	sum `sigma_uhet',mean
	eret scalar sigma_u = r(mean)
	if "`vsigma'"==""  eret scalar sigma_v = exp([Vsigma]_cons)
	else {
		tempvar xb_v sigma_vhet
		qui _predict double `xb_v' if `touse', xb eq(Vsigma)
		qui gen double `sigma_vhet' = exp(`xb_v')
		noi sum `sigma_vhet',mean
		eret scalar sigma_v = r(mean)
	}
}

sftfe_DiSpLaY, level(`level') feshow(`tfeshow') `diopts' `_noempty'

__sftfe_destructor

end


**** ANCILLARY PROGS

program define sftfe_DiSpLaY, eclass
        syntax [, Level(cilevel) feshow(string) *]
		_get_diopts diopts, `options'


			if "`e(estimator)'"=="within" & "`e(dist)'"=="hnormal" eret local title "Within ML (Normal-Half Normal)"
			if "`e(estimator)'"=="fdiff" & "`e(dist)'"=="hnormal" eret local title "First-difference ML (Normal-Half Normal)"
			if "`e(estimator)'"=="fdiff" & "`e(dist)'"=="tnormal" eret local title "First-difference ML (Normal-Truncated Normal)"
			if "`e(estimator)'"=="pde" & "`e(dist)'"=="exponential" eret local title "Pairwise Difference (Normal-Exponential)"
			if "`e(estimator)'"=="pde" & "`e(dist)'"=="hnormal" eret local title "Pairwise Difference (Normal-Half Normal)"
			if "`e(estimator)'"=="pde" & "`e(dist)'"=="tnormal" eret local title "Pairwise Difference (Normal-Truncated Normal)"
			if "`e(estimator)'"=="mmsle" & "`e(dist)'"=="exponential" eret local title "Marginal MSL (Normal-Exponential)"
			if "`e(estimator)'"=="mmsle" & "`e(dist)'"=="hnormal" eret local title "Marginal MSL (Normal-Half Normal)"

        #delimit ;
		di as txt _n "`e(title)'", _continue;
		di in gr _col(54) "Number of obs " _col(68) "=" /*
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
                 _col(70) in ye %9.0g `e(g_max)';

		if "`e(function)'"=="production" {;
		di "";
		di in green "Production frontier";
		};
		if "`e(function)'"=="cost" {;
		di "";
		di in green "Cost frontier";
		};
		if "`e(upattern)'"=="ar1" {;
		di "";
		di in green "AR(1) inefficiency";
		};
        di "";
        di in green "`e(crittype)' = " in yellow %10.4f `e(Q)';
		#delimit cr
		if "`e(estimator)'"=="mmsle" {
			if "`e(simtype)'" == "runiform" di in green "Number of Pseudo Random Draws = " in yellow %9.0f "`e(nsim)'"
			if "`e(simtype)'" == "halton" di in green "Number of Halton Sequences = " in yellow %9.0f "`e(nsim)'"
		}
		if (("`e(estimator)'"=="pde" & "`e(dist)'"=="tnormal") | ("`e(estimator)'"=="pde" & "`e(dist)'"=="hnormal")  ///
		   | ("`e(estimator)'"=="within" & "`e(dist)'"=="hnormal")) & "`e(ghk_type)'"!="" {
			if "`e(ghk_type)'" == "random" di in green "Number of Pseudo Random Draws = " in yellow %9.0f "`e(ghk_npts)'"
			if "`e(ghk_type)'" == "halton" di in green "Number of Halton Sequences = " in yellow %9.0f "`e(ghk_npts)'"
			if "`e(ghk_type)'" == "hammersley" di in green "Number of Hammersley Sequences = " in yellow %9.0f "`e(ghk_npts)'"
		}

*** DISPLAY RESULTS
if ("`e(estimator)'"=="fdiff" & "`e(dist)'"=="tnormal" & "`e(het)'"=="" & "`e(mu_rhs)'"=="" ) {
	_coef_table, neq(1) level(`level') `diopts' plus
	_diparm Mu, level(`level') label(/mu) prob
    _diparm Usigma, level(`level') exp prob label(/sigma_u)
	_diparm Vsigma, level(`level') exp prob label(/sigma_v)
	_diparm __bot__
}
else if ("`e(estimator)'"=="mmsle" & "`e(het)'"=="") {
	_coef_table, neq(1) level(`level') `diopts' plus
	// Here due to the way in which gradient is computed the parametrization uses directly sigma_u and sigma_v
	_diparm Usigma, level(`level') prob label(/sigma_u)
	_diparm Vsigma, level(`level') prob label(/sigma_v)
	_diparm __bot__
}
else if ("`e(estimator)'"=="mmsle" & "`e(het)'"!="" & "`e(ematrix)'"=="") {
	_coef_table, neq(2) level(`level') `diopts' plus
	_diparm Vsigma, level(`level') exp prob label(/sigma_v)
	_diparm __bot__
}
else if ("`e(estimator)'"=="mmsle" & "`e(het)'"!="" & "`e(ematrix)'"!="") {
	_coef_table, neq(2) level(`level') `diopts' plus
	_diparm Vsigma, level(`level') exp prob label(/sigma_v)
	_diparm Rho, level(`level') function(normal(@)) derivative(-normalden(@)) prob label(/rho)
	_diparm __bot__
}
else if ("`e(estimator)'"=="pde" & "`e(het)'"=="" & "`e(upattern)'"=="unstructured") {
	if "`e(dist)'"=="tnormal" _coef_table, neq(2) level(`level') `diopts' plus
	else _coef_table, neq(1) level(`level') `diopts' plus
	if "`e(dist)'"=="exponential" {
		// Here due to the way in which gradient is computed the parametrization uses directly sigma_u and sigma_v
		_diparm Usigma, level(`level') prob label(/sigma_u)
		_diparm Vsigma, level(`level') prob label(/sigma_v)
	}
	else {
		_diparm Usigma, level(`level') exp prob label(/sigma_u)
		_diparm Vsigma, level(`level') exp prob label(/sigma_v)
	}
	_diparm __bot__
}
else if ("`e(estimator)'"=="pde" & "`e(het)'"=="u" & "`e(upattern)'"=="unstructured") {
	if "`e(dist)'"=="tnormal" _coef_table, neq(4) level(`level') `diopts' plus
	else _coef_table, neq(2) level(`level') `diopts' plus
	_diparm Vsigma, level(`level') exp prob label(/sigma_v)
	_diparm __bot__
}
else if ("`e(estimator)'"=="pde" & "`e(het)'"=="v" & "`e(upattern)'"=="unstructured") {
	if "`e(dist)'"=="tnormal" _coef_table, neq(4) level(`level') `diopts' plus
	else _coef_table, neq(3) level(`level') `diopts' plus
	_diparm Usigma, level(`level') exp prob label(/sigma_v)
	_diparm __bot__
}
else if ("`e(estimator)'"=="pde" & "`e(het)'"=="u" & "`e(upattern)'"=="ar1") {
	if "`e(dist)'"=="hnormal" {
		_coef_table, neq(2) level(`level') `diopts' plus
		_diparm Vsigma, level(`level') exp prob label(/sigma_v)
		_diparm Rho, level(`level') tanh prob label(/rho)
	}
	if "`e(dist)'"=="tnormal" {
		_coef_table, neq(4) level(`level') `diopts' plus
		_diparm Vsigma, level(`level') exp prob label(/sigma_v)
		_diparm Rho, level(`level') tanh prob label(/rho)
	}
	_diparm __bot__
}
else if ("`e(estimator)'"=="pde" & "`e(het)'"=="v" & "`e(upattern)'"=="ar1") {
	if "`e(dist)'"=="hnormal" {
		_coef_table, neq(3) level(`level') `diopts' plus
		_diparm Usigma, level(`level') exp prob label(/sigma_u)
		_diparm Rho, level(`level') tanh prob label(/rho)
	}
	if "`e(dist)'"=="tnormal" {
		_coef_table, neq(4) level(`level') `diopts' plus
		_diparm Usigma, level(`level') exp prob label(/sigma_u)
		_diparm Rho, level(`level') tanh prob label(/rho)
	}
	_diparm __bot__
}
else if ("`e(estimator)'"=="pde" & "`e(het)'"=="" & "`e(upattern)'"=="ar1") {
	if "`e(dist)'"=="hnormal" {
		_coef_table, neq(1) level(`level') `diopts' plus
		_diparm Usigma, level(`level') exp prob label(/sigma_u)
		_diparm Vsigma, level(`level') exp prob label(/sigma_v)
		_diparm Rho, level(`level') tanh prob label(/rho)
	}
	if "`e(dist)'"=="tnormal" {
		_coef_table, neq(4) level(`level') `diopts' plus
		_diparm Usigma, level(`level') exp prob label(/sigma_u)
		_diparm Vsigma, level(`level') exp prob label(/sigma_v)
		_diparm Rho, level(`level') tanh prob label(/rho)
	}
	_diparm __bot__
}
else if ("`e(estimator)'"=="pde" & "`e(het)'"=="uv" & "`e(upattern)'"=="ar1") {
	if "`e(dist)'"=="hnormal" {
		_coef_table, neq(3) level(`level') `diopts' plus
		_diparm Rho, level(`level') tanh prob label(/rho)
	}
	if "`e(dist)'"=="tnormal" {
		_coef_table, neq(4) level(`level') `diopts' plus
		_diparm Rho, level(`level') tanh prob label(/rho)
	}
	_diparm __bot__
}
else _coef_table, level(`level') `diopts'


if (("`e(estimator)'"=="fdiff" | "`e(estimator)'"=="within") & "`e(dist)'"=="hnormal" & "`e(het)'"=="") {
	tempname checklambda
	scalar `checklambda' = _b[Lambda:_cons]
	if `checklambda'<0 {
		if "`e(function)'"=="production" di in gr "Warning: A negative Lambda should mean that you have to estimate a cost frontier."
		if "`e(function)'"=="cost" di in gr "Warning: A negative Lambda should mean that you have to estimate a production frontier."
	}
}

/* INCLUDE WARNIONG ON SYMMETRY OF COST PROD WHEN LAMBDA < 0
if "`cost'"!="" & "`u'"=="" & "`estimator'"=="pde" & "`distribution'"=="exponential" {
    noi di in gr "WARNING: cost and production frontiers estimated using -estimator(`estimator')"
	noi di in gr "         and `distribution' distribution are numerically equivalent when the "
	noi di in gr "         inefficiency is assumed to be homoskedastic."
}
*/

end


program define _parse_constraints, eclass

syntax[, constraintslist(string asis) estparams(string asis)]

if "`constraintslist'"!="" {
tempname b
mat `b' = (`estparams')
eret post `b'
	foreach cns of local constraintslist {
		constraint get `cns'
		if `r(defined)' != 0 {
			makecns `cns'
			mat _CNS = (nullmat(_CNS) \ e(Cns))
		}
		else {
			noi di as err "Constraint `cns' is not defined."
		    error 198
		    exit
		}
	}
}

end

/* ----------------------------------------------------------------- */

program define ParseEst
	args returmac colon est

	local 0 ", `est'"
	syntax [, PDE MMSLE WITHIN MLDVE FDIFF * ]

	if `"`options'"' != "" {
		di as error "estimator(`options') not allowed"
		exit 198
	}

	local wc : word count `pde' `mmsle' `within' `mldve' `fdiff'

	if `wc' > 1 {
		di as error "estimator() invalid, only " /*
			*/ "one estimator can be specified"
		exit 198
	}

	if `wc' == 0 {
		c_local `returmac' pde
	}
	else c_local `returmac' `pde'`mmsle'`within'`mldve'`fdiff'

end

/* ----------------------------------------------------------------- */

program define ParseDistr
	args returnmac colon distribution est

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
		if "`est'"=="pde" {
			c_local `returnmac' exponential
			local __check exponential
		}
		if "`est'"=="within" {
			c_local `returnmac' hnormal
			local __check hnormal
		}
		if "`est'"=="mmsle" {
			c_local `returnmac' exponential
			local __check exponential
		}
		if "`est'"=="fdiff" {
			c_local `returnmac' hnormal
			local __check hnormal
		}
	}
	else {
		c_local `returnmac' `hnormal'`exponential'`tnormal'
		local __check `hnormal'`exponential'`tnormal'
	}

	if ("`__check'" != "hnormal" & "`__check'" != "exponential") & "`est'"=="mmsle" {
		di as error "Chen et al. (2011) within estimator requires distribution(" in yel "hnormal" in red ") or distribution(" in yel "exponential" in red ")"
		exit 198
	}
	if "`__check'" != "hnormal" & "`est'"=="within" {
		di as error "Chen et al. (2011) within estimator requires distribution(" in yel "hnormal" in red ")"
		exit 198
	}
	if ("`__check'" != "hnormal" & "`__check'" != "tnormal") & "`est'"=="fdiff" {
		di as error "Belotti and Ilardi (2018) first difference estimator requires distribution(" in yel "hnormal" in red ") or distribution(" in yel "tnormal" in red ")"
		exit 198
	}

end

/* ----------------------------------------------------------------- */

program define ParseSimtype
	args returnmacr colon simtype model

	local 0 ", `simtype'"
	syntax [, Uniform HAlton * ]

	if `"`options'"' != "" {
		di as error "simtype(`options') not allowed"
		exit 198
	}
	if "`model'"!="mmsle" & "`simtype'"!="" {
		di as error "Option simulation type requires model(" in yel "mmsle" in red ")"
		exit 198
	}
	local wc : word count `uniform' `halton'

	if `wc' > 1 {
		di as error "simtype() invalid, only " /*
			*/ "one type of simulation can be specified"
		exit 198
	}

	if `wc' == 0 {
		c_local `returnmacr' halton
	}
	else	c_local `returnmacr' `uniform'`halton'

end

program define __sftfe_destructor
syntax

// DROP compulsory scalars created for structures
capture scalar drop MaXiterate Simtype Nsimulations Base TOLerance ///
					LTOLerance NRTOLerance REPEAT InIt_nparams S_COST
// DROP compulsory matrix created for structures
capture matrix drop _CNS
// DROP structures
capture mata: mata drop _sftfe__PoSt_OpT _sftfe_SV __GHK_

end


exit

* version 1.0.1  10dec2011
* version 1.0.2  12jul2012
* version 1.1.0  13dec2013
* version 1.2.0  16jun2014
* version 1.2.1  11mar2015
* version 1.2.2  23mar2015 - Excluded pde when dist(exponential) and dynamic. Added inverse hyperbolic tangent parametrization for rho when model is dynamic.
* version 1.2.3  6may2015 - Fixed bug that prevented the use of mmsle with halton draws. Also set .1 as default starting value for rho in pde hn dyn
* version 1.2.4  8may2015 - Fixed bug the prevented to report the correct number of obsrvations and groups used in the estimation
* version 1.2.5  2mar2016 - Release compatible with Stata 11.2, added the undocumented -forcehomo- to allow -pde- also in the homoskedastic case (due to the way in which gradient is computed in the sftfe_pde_exp.mata, the parametrization uses directly sigma_u and sigma_v, this requires to check for negativeness of sigma_v). Now the -mmsle- default is to use simtype(halton) and nsim(n*10) in the homo and nsim(n*30) in the hetero case (due to the way in which gradient is computed in the sftfe_mmsle.mata, the parametrization uses directly sigma_u and sigma_v, this requires to check for negativeness of sigma_v). From now on, also -mmsle_het- works (more slowly since the gradient should be revised) with time-varying inefficiency factors
* version 1.2.6  6may2018 - From now on -sftfe- is compatible from Stata 14.2 onwards (not anymore from 11.2). This solves an issue with the mopt___struct of moptimize()
* version 1.2.7  6feb2020 - Fixed an issue with the generation of shuffled halton sequences in the case of half normal distributed inefficiency
* version 1.2.8  11feb2020 - Changed the way in which the command treats specifies the initial value of the random-number seed used by the random-number functions. Now the user needs to set the seed by him/herselves, using the -set seed #- command or the -seed()- option to ensure reproducibility of results when using estimators requiring the generation of random-numbers.
* version 1.2.9  19oct2022 - This solves an issue with the mopt___struct of moptimize(). See request by Pei-Chun Lai. The bug was generated by the "s = MMM.S.gradient_v" syntax when the mata functions are compiled under Stata 14.2. From now on -sftfe- is distributed under Stata/MP 15.1 - Revision 03 Feb 2020 (not anymore Stata 14.2).
