*! version 1.0.0  01jul2010
*! version 1.0.2  15dec2010
*! version 1.1.1  16nov2011
*! version 1.1.2  25nov2011
*! version 1.2.0  19aug2012

program define sfcross, eclass byable(onecall) prop(svyb svyj svyr swml)

    if _by() {
        local BY `"by `_byvars'`_byrc0':"'
    }
	`BY' _vce_parserun sfcross: `0'
	if "`s(exit)'" != "" {
		version 11: ereturn local cmdline `"sfcross `0'"'
		exit
	}
	
    version 11
                
        if replay() {
            if _by() { 
                error 190 
            }
            if "`e(cmd)'" != "sfcross" {
                error 301
            }
                DiSpLaY `0'
                exit
            }
		
    if _by() {
        by `_byvars' `_byrc0': sfcross_est `0'
    }       
    else sfcross_est `0'
    version 11: ereturn local cmdline `"sfcross `0'"'
end



program define sfcross_est, eclass byable(recall) sortpreserve

version 11
syntax varlist(min=2 fv) [if] [in] [pweight fweight iweight aweight/] , [ Distribution_cs(string) NOCONStant_cs COST_cs  ///
                        		VCE_cs(passthru) CLuster_cs(passthru) Robust_cs Level(cilevel) ///
								CONSTRaints_cs(numlist min=1) SELECTion_cs(string) SCALING_cs ///
                        		Emean_cs(string) Usigma_cs(string) Vsigma_cs(string) ///
								SVFRONTier_cs(string) SVEmean_cs(string) SVUsigma_cs(string) SVVsigma_cs(string) from(string) ///
                        		SIMTYPE_cs(string) NSIMulations_cs(integer 250) BASE_cs(integer 7) ///
                        		TECHnique_cs(string) ITERate_cs(integer 100) NOWARNing_cs DIFFICULT_cs NOLOG_cs ///
                        		TRace_cs GRADient_cs SHOWSTEP_cs HESSian_cs SHOWTOLerance_cs TOLerance_cs(real 1e-6) ///
                        		LTOLerance_cs(real 1e-7) NRTOLerance_cs(real 1e-5) ///
                        		NOSEARCH_cs REPEAT_cs(integer 10) RESTART_cs RESCale_cs POSTSCORE_cs POSTHESSian_cs *] 

					

noi di ""

*** Is.estimation
local __PrEdIcT__cs 0

*** Clear ereturn macro
ereturn clear

*** Marksample:
marksample touse_cs, strok

*** Parsing of display options
_get_diopts diopts_cs options_cs, `options'

*** Parsing of nocons option
if "`noconstant_cs'" != "" local noconstant_cs "nocons"

*** Parsing vce options
local crittype_cs "Log likelihood"

if "`weight'"!="" local __equal "="
local vce_cs = regexr("`vce_cs'", "_cs", "")
local robust_cs = regexr("`robust_cs'", "_cs", "")
local cluster_cs = regexr("`cluster_cs'", "_cs", "")
_vce_parse, argopt(CLuster) opt(OIM OPG Robust) old	///
: [`weight' `__equal' `exp'], `vce_cs' `robust_cs' `cluster_cs'

local vce_cs "`r(vce)'"
if "`vce_cs'"=="cluster" {
	local vcetype_cs "Robust"
	local clustervar_cs "`r(cluster)'"
	local crittype_cs "Log pseudolikelihood"
}
if "`vce'"=="robust" {
	local vce_cs "robust"
	local vcetype_cs "Robust"
	local crittype_cs "Log pseudolikelihood"
}
if "`vce_cs'"=="oim" local vcetype_cs "OIM"
if "`vce_cs'"=="opg" local vcetype_cs "OPG"


*** Parsing distributions
ParseDist distribution_cs title_cs : `"`distribution_cs'"'

*** Simulation type for Gamma model
ParseSimtype simtype_cs : `"`simtype_cs'"' `"`distribution_cs'"'


*************** Errors *************  

if "`from'"!="" {
	noi di as err "Option from() not allowed. Use sv{it:eqnname}() options."
    error 198
    exit
}


if "`emean_cs'"!="" & "`distribution_cs'"!="tnormal" {
	noi di as err "Conditional mean model is allowed only for distribution(tnormal)."
    error 198
    exit
}

*************************************

/// Fix crittype in the case of the normal/gamma model
if "`distribution_cs'"=="gamma" local crittype_cs "Log simulated-likelihood"

***********************************************************************************************************************
******* Assigns objects to correctly create _InIt_OpTiMiZaTiOn() and _PoSt_ReSuLt_of_EsTiMaTiOn() structures **********
***********************************************************************************************************************

*** Locals 
if "`technique_cs'"=="" & "`distribution_cs'"!="gamma" local technique_cs "nr"
if "`technique_cs'"=="" & "`distribution_cs'"=="gamma" local technique_cs "bhhh"
if ("`distribution_cs'"=="hnormal" | "`distribution_cs'"=="tnormal") & "`difficult_cs'"=="" local difficult_cs "hybrid"
if "`difficult_cs'"!="" local difficult_cs "hybrid"
else local difficult_cs "m-marquardt"
if "`nowarning_cs'"!="" local nowarning_cs "on"
else local nowarning_cs "off"
if "`nolog_cs'"!="" local nolog_cs "none"
else local nolog_cs "value"
if "`trace_cs'"!="" local trace_cs "on"
else local trace_cs "off"
if "`gradient_cs'"!="" local gradient_cs "on"
else local gradient_cs "off"
if "`showstep_cs'"!="" local showstep_cs "on"
else local showstep_cs "off"
if "`hessian_cs'"!="" local hessian_cs "on"
else local hessian_cs "off"
if "`showtolerance_cs'"!="" local showtolerance_cs "on"
else local showtolerance_cs "off"
if "`nosearch_cs'"!="" local nosearch_cs "off"
else local nosearch_cs "on"
if "`restart_cs'"!="" local restart_cs "on"
else local restart_cs "off"
if "`rescale_cs'"!="" local rescale_cs "on"
else local rescale_cs "off"
if "`r(wvar)'"!="" local InIt_svy_cs "on"
else local InIt_svy_cs "off"
if "`exp'`weight'" != "" local weighted_est_cs "on"
else local weighted_est_cs "off"
if "`constraints_cs'" != "" local constrained_est_cs "on"
else local constrained_est_cs "off"


*** Scalars
scalar TOLerance_cs = `tolerance_cs'
scalar LTOLerance_cs = `ltolerance_cs'
scalar NRTOLerance_cs = `nrtolerance_cs'
scalar MaXiterate_cs = `iterate_cs'
scalar REPEAT_cs = `repeat_cs'
scalar CILEVEL_cs = `level'

*** Estimator specific:
** Gamma - Greene (2000)
if "`distribution_cs'"=="gamma" {
	if "`simtype_cs'"=="runiform" scalar Simtype_cs = 1
	else if "`simtype_cs'" == "halton" scalar Simtype_cs = 2	
	else scalar Simtype_cs = 3
	scalar Nsimulations_cs = `nsimulations_cs'
	scalar Base_cs = `base_cs'
}


**********************************************************
*** Cost or Production?

if "`cost_cs'" != "" {         
    scalar S_COST_cs=-1
    local function_cs "cost" 
}
else {
    scalar S_COST_cs=1
    local function_cs "production"
} 

if "`usigma_cs'"!="" local u_cs "u"
if "`vsigma_cs'"!="" local v_cs "v"

************** Tokenize from varlist ***************
gettoken lhs_cs rhs_cs: varlist
if "`usigma_cs'"!="" gettoken u_rhs_cs u_nocons_cs: usigma_cs, parse(",") 
if "`vsigma_cs'"!="" gettoken v_rhs_cs v_nocons_cs: vsigma_cs, parse(",")
if "`emean_cs'"!="" gettoken e_rhs_cs e_nocons_cs: emean_cs, parse(",")
local u_nocons_cs=rtrim(ltrim(regexr("`u_nocons_cs'", ",", "")))
local v_nocons_cs=rtrim(ltrim(regexr("`v_nocons_cs'", ",", "")))
local e_nocons_cs=rtrim(ltrim(regexr("`e_nocons_cs'", ",", "")))
****************************************************

********* Factor Variables check ****
_fv_check_depvar `lhs_cs'

local fvops_cs = "`s(fvops)'" == "true" | _caller() >= 11
if `fvops_cs' {
    local vv_cs : di "version " string(max(11,_caller())) ", missing:"
	local _noempty_cs "noempty"
}

********* Factor Variables parsing ****
local fvars_cs "rhs_cs e_rhs_cs u_rhs_cs v_rhs_cs"
foreach l of local fvars_cs {
	if "``l''" != "" fvunab `l': ``l''
	fvexpand ``l''
	`vv_cs' cap noi _rmcoll `r(varlist)' if `touse_cs' [`weight' `__equal' `exp'], `noconstant_cs' expand
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
markout `touse_cs' `u_rhs_cs' `v_rhs_cs' `e_rhs_cs'

*** The following is needed to get the first arg of _sim_gamma()
qui count if `touse_cs'==1
scalar _obs_gamma = r(N)

***************************************************************************

*********************************************************************************************
******************** Starting values, variable names and initialisation *********************
*********************************************************************************************

*************** Count of parameters for starting values *******************

if "`noconstant_cs'" != "" local nsv_frontier_cs: word count `rhs_cs'
else {
	local nsv_frontier_cs: word count `rhs_cs' _cons
	local _frcons_cs _cons
}
if "`e_nocons_cs'" != "" local nsv_emean_cs: word count `e_rhs_cs'
else  {
	local nsv_emean_cs :word count `e_rhs_cs' _cons
	local _econs_cs _cons
}
if "`u_nocons_cs'" != "" local nsv_usigma_cs: word count `u_rhs_cs'
else  {
	local nsv_usigma_cs :word count `u_rhs_cs' _cons
	local _ucons_cs _cons
}
if "`v_nocons_cs'" != "" local nsv_vsigma_cs: word count `v_rhs_cs'
else {
	local nsv_vsigma_cs :word count `v_rhs_cs' _cons
	local _vcons_cs _cons
}

** Check if user's starting values matrices are conformable
local _checklist "frontier_cs emean_cs usigma_cs vsigma_cs"
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
			noi di as err "User specified starting values in " in yel "sv`_check'()" in red " do not match " in yel "`_check''s" in red " regressors number"
		    error 198
		    exit
		}
	}
}



/// 3rd moment test ///
qui _regress `lhs_cs' `rhs_cs' [`weight' `__equal' `exp'] if `touse_cs'
tempvar __exp
if "`exp'"=="" qui gen `__exp'=1
else qui gen `__exp'=`exp'

local _nobs_cs = e(N)
tempvar _olsres _olsres2 _olsres3
tempname _m2 _m3 _b0 _m3t _p_m3t
matrix `_b0'=e(b) 
qui predict double `_olsres' if `touse_cs', res
qui gen double `_olsres2'=`_olsres'^2 if `touse_cs' 
qui sum `_olsres2' [iw=`__exp'] if `touse_cs', meanonly
scalar `_m2'=r(mean)
qui gen double `_olsres3'=`_olsres'^3 if `touse_cs' 
qui sum `_olsres3' [iw=`__exp'] if `touse_cs', meanonly
qui sum `_olsres3' if `touse_cs', meanonly
scalar `_m3'=r(mean)
scalar `_m3t'=`_m3'/sqrt(6*`_m2'^3/`_nobs_cs')
scalar `_p_m3t' = normal(S_COST_cs*`_m3t')
* correct 3rd moment to be negative *
scalar `_m3'=cond(S_COST_cs*r(sum)<0, `_m3', -.0001*S_COST_cs)

/// Wald test ///
local _rhs_wald_cs ""
local rhs_count_cs: word count `_rhs_cs_names'
forvalues i=1/`rhs_count_cs' {
    local _rhs_var`i': word `i' of `_rhs_cs_names'
    local _rhs_wald_cs "`_rhs_wald_cs' `_rhs_var`i'' ="
}

***************************************************************************

if "`distribution_cs'" == "tnormal" {
	local _init_vector "init_emean_cs"
	local _comma ","
}
local _init_vector1 "init_usigma_cs"
local _comma1 ","
if "`distribution_cs'" == "gamma" {
	local _init_vector2 "init_m_cs"
	local _comma1 ""
	local _comma2 ","
}

tempname init_beta_cs `_init_vector' `_init_vector1' init_vsigma_cs `_init_vector2'
	
if "`svfrontier_cs'"=="" {	
	qui reg `lhs_cs' `rhs_cs' if `touse_cs', `noconstant_cs'
	mat `init_beta_cs'=e(b)
}
else mat `init_beta_cs' = `svfrontier_cs'
	
	
mat colnames `init_beta_cs' = `_rhs_cs_names' `_frcons_cs'
mat coleq `init_beta_cs' = "Frontier"
    	
if "`svusigma_cs'"=="" mat `init_usigma_cs' = J(1, `:word count `u_rhs_cs' `_ucons_cs'', 0.25)
else  mat `init_usigma_cs' = (`svusigma_cs')
mat colnames `init_usigma_cs' = `_u_rhs_cs_names' `_ucons_cs'
mat coleq `init_usigma_cs' = "Usigma"

if "`distribution_cs'"=="tnormal" {
	if "`svemean_cs'"=="" mat `init_emean_cs' = J(1, `:word count `e_rhs_cs' `_econs_cs'', 0.25)
	else  mat `init_emean_cs' = (`svemean_cs')
	mat colnames `init_emean_cs' = `_e_rhs_cs_names' `_econs_cs'
	mat coleq `init_emean_cs' = "Mu"
}

if "`svvsigma_cs'"=="" mat `init_vsigma_cs' = J(1, `:word count `v_rhs_cs' `_vcons_cs'', 0.25)
else  mat `init_vsigma_cs' = (`svvsigma_cs')
mat colnames `init_vsigma_cs' = `_v_rhs_cs_names' `_vcons_cs'
mat coleq `init_vsigma_cs' = "Vsigma"


if "`distribution_cs'"=="gamma" {
    mat `init_m_cs' = 1.5
    mat colnames `init_m_cs' = m
    mat coleq `init_m_cs' = "Shape"	
}			

******************** INIT ***********************
local _params_list_cs "init_beta_cs `_init_vector' `_init_vector1' init_vsigma_cs `_init_vector2'"
local _params_num_cs = 1
scalar InIt_nparams_cs = wordcount("`_params_list_cs'")

/// Structure definition for initialisation
mata: _SV_cs = J(1, st_numscalar("InIt_nparams_cs"), _starting_values_cs())
foreach _params_cs of local _params_list_cs {
mata: _SV_cs = _StArTiNg_VaLuEs_cs("``_params_cs''", `_params_num_cs', _SV_cs)	
** The following to check the content of the structure ** Just for debugging
*mata: liststruct(_SV_cs)
local _params_num_cs = `_params_num_cs' + 1
}
if "`distribution_cs'"=="exponential" {
	local InIt_evaluator_cs "cross_exp"
	local InIt_evaluatortype_cs "lf2"
}
if "`distribution_cs'"=="hnormal" {
	local InIt_evaluator_cs "cross_hn"
	local InIt_evaluatortype_cs "lf2"
}
if "`distribution_cs'"=="tnormal" {
	local InIt_evaluator_cs "cross_tn"
	local InIt_evaluatortype_cs "lf2"
}
if "`distribution_cs'"=="gamma" {
	local InIt_evaluator_cs "cross_gamma"
	local InIt_evaluatortype_cs "gf0"
}	
*** Parsing of constraints (if defined)
_parse_constraints_cs, constraintslist(`constraints_cs') estparams(`init_beta_cs' `_comma' `init_emean_cs' `_comma1' `init_usigma_cs', `init_vsigma_cs' `_comma2' `init_theta_cs' `_comma2' `init_m_cs')
	
mata: _InIt_OpT_cs = _InIt_OpTiMiZaTiOn_cs()
** The following to check the content of the structure ** Just for debugging
*mata: liststruct(_InIt_OpT_cs)
*******************************************************************************************	

local evarlist_cs "`lhs_cs' `rhs_cs'"

///////////////////////////////////////////////////////////////////
////////////////////////// Estimation /////////////////////////////
///////////////////////////////////////////////////////////////////

*** Collect post-results options
mata: _PoSt_OpT_cs = _PoSt_ReSuLt_of_EsTiMaTiOn_cs()
*** Get Data
mata: _DaTa_cs = _GeT_dAtA_cs("`evarlist_cs'", "`touse_cs'", "`distribution_cs'", &_sim_gamma(),"`noconstant_cs'", "`emean_cs'", "`usigma_cs'", "`vsigma_cs'", "`e_rhs_cs'", "`u_rhs_cs'", "`v_rhs_cs'", "`e_nocons_cs'", "`u_nocons_cs'", "`v_nocons_cs'")
*** Estimation
noi di ""
noi mata: _Results_cs = sf_est_cs("`distribution_cs'", &_sim_gamma(), _DaTa_cs, _SV_cs, _InIt_OpT_cs, _PoSt_OpT_cs)


///////////////// Display results /////////////////
*** Common post not in sf_est_cs()
eret local predict "sfcross_p"
eret local cmd "sfcross"
eret local depvar "`lhs_cs'"
eret local function "`function_cs'"
eret local het "`u_cs'`v_cs'"                   
eret local dist "`distribution_cs'" 
eret local crittype "`crittype_cs'"       
eret local title "`title_cs'"
eret local marginsok "default xb"
eret local cilevel "`level'"
if "`weight'"!="" eret local wtype "`weight'"
if "`exp'"!="" eret local wexp "= `exp'"
if "`e(het)'"=="u" | "`e(het)'"=="uv" eret local Usigma "`_u_rhs_cs_names' `_ucons_cs'" 
if "`e(het)'"=="v" | "`e(het)'"=="uv" eret local Vsigma "`_v_rhs_cs_names' `_vcons_cs'" 
if "`emean_cs'"!="" eret local Emean "`_e_rhs_cs_names' `_econs_cs'"
eret local covariates "`_rhs_cs_names' `_frcons_cs'"
if "`e(dist)'"=="gamma" {
	eret local simtype "`simtype_cs'"
	eret scalar nsim = `nsimulations_cs'
	if "`simtype_cs'"!="runiform" eret scalar base = `base_cs'
	eret scalar g_shape = [Shape]_cons
}
///////////////// Wald test
`vv_cs' qui test `_rhs_wald_cs' 0
eret scalar chi2 = r(chi2)
eret scalar p = r(p)
eret scalar df_m = r(df)

if "`u_cs'`v_cs'`emean_cs'" == "" {
	eret scalar z = `_m3t'
	eret scalar p_z = `_p_m3t'
}

///////////////// Ancillary parameters /////////////////
if "`usigma_cs'"==""  eret scalar sigma_u = exp(0.5 * [Usigma]_cons)
if "`vsigma_cs'"==""  eret scalar sigma_v = exp(0.5 * [Vsigma]_cons)
if "`usigma_cs'"!= "" {
	tempvar xb_u sigma_uhet
	qui _predict double `xb_u' if `touse_cs', xb eq(Usigma)
	qui gen double `sigma_uhet' = exp(0.5*`xb_u')
	qui sum `sigma_uhet'
	eret scalar avg_sigmau = r(mean)
	local sigmau_se = r(sd)/sqrt(e(N))
}
if "`vsigma_cs'"!= "" {
	tempvar xb_v sigma_vhet
	qui _predict double `xb_v' if `touse_cs', xb eq(Vsigma)
	qui gen double `sigma_vhet' = exp(0.5*`xb_v')
	qui sum `sigma_vhet'
	eret scalar avg_sigmav = r(mean) 
	local sigmav_se = r(sd)/sqrt(e(N))
}
if "`e(het)'"=="" eret scalar lambda = e(sigma_u)/e(sigma_v)
	
*** Compulsory to get e(sample)
eret repost, esample(`touse_cs')

local diopts_cs "`diopts_cs' `_noempty_cs'"
DiSpLaY_cs, level(`level') use(`sigmau_se') vse(`sigmav_se') `diopts_cs'

__sfcross_destructor
        
end


program define DiSpLaY_cs, eclass
        syntax [, Level(cilevel) use(string) vse(string) *]

		_get_diopts diopts, `options' 
				
        #delimit ;
		di as txt _n "`e(title)'" _col(54) "Number of obs " _col(68) "=" /*
			*/ _col(70) as res %9.0g e(N);
	    di in green _col(54) "Wald chi2(" in yellow e(df_m) in green ")  = " /*
			*/ in yellow %9.2f e(chi2);                  
        di in green _col(54) "Prob > chi2   = " %9.4f in yellow e(p);
        di "";          
        di in green "`e(crittype)' = " in yellow %10.4f `e(ll)';
		#delimit cr   

		if "`e(dist)'"=="gamma" {
			if "`e(simtype)'" == "runiform" {
				di in green "Number of Pseudo Random Draws = " in yellow %9.0f "`e(nsim)'"
			}
			if "`e(simtype)'" == "halton" {
				di in green "Number of Halton Sequences = " in yellow %9.0f "`e(nsim)'"
				di in green "Base for Halton Sequences  = " in yellow %9.0f "`e(base)'" 
			}
			if "`e(simtype)'" == "genhalton" {
				di in green "Number of Randomized Halton Sequences = " in yellow %9.0f "`e(nsim)'"
				di in green "Base for Randomized Halton Sequences  = " in yellow %9.0f "`e(base)'" 
			}
		}
		
*** DISPLAY RESULTS

if "`e(het)'"=="" {
	if "`e(dist)'"=="tnormal" local __neq_ 4
	else local __neq_ 3
	
	_coef_table, level(`level') plus neq(`__neq_') `diopts'
 	_diparm Usigma, func( exp(0.5*@) ) /*
     */ der( 0.5*exp(0.5*@) ) level(`level') label(sigma_u) prob
	_diparm Vsigma, func( exp(0.5*@) ) /*
     */ der( 0.5*exp(0.5*@) ) level(`level') label(sigma_v) prob
	_diparm Vsigma Usigma, level(`level') /*
		*/ func( sqrt(exp(@2-@1))) /*
		*/ der( -0.5*exp(0.5*@1) 0.5*exp(0.5*@2) ) /*
		*/ label(lambda) prob    
	if "`e(dist)'" == "gamma" _diparm Shape, level(`level') label(g_shape) prob     
	di as text "{hline 13}{c BT}{hline 64}"	
}
if "`e(het)'"=="u" {
	if "`e(dist)'"=="tnormal" local __neq_ 4
	else local __neq_ 3	
	_coef_table, level(`level') plus neq(`__neq_') `diopts'	
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
	if "`e(dist)'" == "gamma" _diparm Shape, level(`level') label(g_shape) prob
	di as text "{hline 13}{c BT}{hline 64}"			
}
if "`e(het)'"=="v" {
	if "`e(dist)'"=="tnormal" local __neq_ 4
	else local __neq_ 3	
	_coef_table, level(`level') plus neq(`__neq_') `diopts'
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
	if "`e(dist)'" == "gamma" _diparm Shape, level(`level') label(g_shape) prob
	di as text "{hline 13}{c BT}{hline 64}"	
}
if "`e(het)'"=="uv" {
	if "`e(dist)'"=="tnormal" local __neq_ 4
	else local __neq_ 3	
	_coef_table, level(`level') plus neq(`__neq_') `diopts'
	local _ci_lev = (1 - 0.`level')/2
	local _t_su = e(avg_sigmau)/`use'
	local _pval_su = 2*ttail(e(N)-e(df_m), abs(`_t_su'))
	local _lb_su = e(avg_sigmau) - abs(invnormal(`_ci_lev'))*`use'
	local _ub_su = e(avg_sigmau) + abs(invnormal(`_ci_lev'))*`use'	
	local _t_sv = e(avg_sigmav)/`vse'
	local _pval_sv = 2*ttail(e(N)-e(df_m), abs(`_t_sv'))
	local _lb_sv = e(avg_sigmav) - abs(invnormal(`_ci_lev'))*`vse'
	local _ub_sv = e(avg_sigmav) + abs(invnormal(`_ci_lev'))*`vse'
	if "`e(dist)'" == "gamma" _diparm Shape, level(`level') label(g_shape) prob
	di in gr "  E(sigma_u) {c |}  " in ye %9.0g e(avg_sigmau) ///
			/*in yel	%9.0g _s(2) `use' %6.2f _s(3) `_t_su' ///
			_s(3) %4.3f `_pval_su'*/ _s(32) %9.0g `_lb_su' _s(3) %9.0g `_ub_su'
	di in gr "  E(sigma_v) {c |}  " in ye %9.0g e(avg_sigmav) ///
			/*in yel	%9.0g _s(2) `vse' %6.2f _s(3) `_t_sv' ///
			_s(3) %4.3f `_pval_sv'*/ _s(32) %9.0g `_lb_sv' _s(3) %9.0g `_ub_sv'
	di as text "{hline 13}{c BT}{hline 64}"
}
	
					/* 3rd moment test */
if "`e(dist)'" == "tnormal" & "`e(Emean)'" == "" & "`e(het)'"=="" {
	if `"`e(function)'"' == "cost" local sign ">"
	else local sign "<"		
	di as text "H0: No inefficiency component: " _c
	di as text _col(43) "z = " as res %7.3f e(z) _c
	di _col(64) as text "Prob`sign'=z = "  ///
		as result %5.3f e(p_z)
}

end


program define _parse_constraints_cs, eclass

syntax[, constraintslist(string asis) estparams(string asis)]

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

end


/* ----------------------------------------------------------------- */

program define ParseDist
	args retmac retmac_ti colon distribution

	local 0 ", `distribution'"
	syntax [, Hnormal Exponential Tnormal GAmma * ]

	if `"`options'"' != "" {
		di as error "distribution(`options') not allowed"
		exit 198
	}

	local wc : word count `hnormal' `exponential' `tnormal' `gamma'

	if `wc' > 1 {
		di as error "distribution() invalid, only " /*
			*/ "one distribution can be specified"
		exit 198
	}
	if `wc' == 0 {
		c_local `retmac' exponential
		local exponential exponential
	}
	else	c_local `retmac' `hnormal'`exponential'`tnormal'`gamma'

	c_local `retmac_ti' "Stoc. frontier normal/`hnormal'`exponential'`tnormal'`gamma' model"

end

/* ----------------------------------------------------------------- */

program define ParseSimtype
	args returnmacr colon simtype dist 

	local 0 ", `simtype'"
	syntax [, RUniform HAlton GENHAlton * ]

	if `"`options'"' != "" {
		di as error "simtype(`options') not allowed"
		exit 198
	}
	if "`dist'"!="gamma" & "`simtype'"!="" {
		di as error "Option simulation type requires distribution(" in yel "gamma" in red ")"
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
	else	c_local `returnmacr' `runiform'`halton'`genhalton'

end

program define __sfcross_destructor
syntax

// DROP compulsory scalars created for structures
local sclist "_obs_gamma MaXiterate_cs Simtype_cs Nsimulations_cs Base_cs TOLerance_cs LTOLerance_cs NRTOLerance_cs REPEAT_cs InIt_nparams_cs S_COST_cs CILEVEL_cs"
foreach s of local sclist { 
	capture scalar drop `s'
}
// DROP compulsory matrix created for structures
capture matrix drop _CNS
// DROP structures
local strlist "_PoSt_OpT_cs _SV_cs"
foreach s of local strlist { 
	capture mata: mata drop `s'
}

end



exit 
