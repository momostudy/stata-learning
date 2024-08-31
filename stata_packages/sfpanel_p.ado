*! version 1.2.2 30nov2015 
*! See the end of the file for versioning

program define sfpanel_p, sortpreserve
        version 8.2

    syntax [anything] [if] [in] [, SCores * ]
	
	if regexm("`0'","ci")!=0 {
		if regexm("`0'","ci\(")==1 {
			di as err `"Option -ci- incorrectly specified."'
		    exit 198		
		}		
	}
			
	if `"`scores'"' != ""  & ("`e(model)'"=="fels" | "`e(model)'"=="fecss" | "`e(model)'"=="fe" | "`e(model)'"=="regls") {
		noi di as error "Scores not allowed with model(`e(model)')."
		exit 198
	}
	if `"`scores'"' != "" {	
		
		mata: _go__ahead = "0"
		cap mata: _go__ahead = (_Results!="")
		mata: st_numscalar("_go__ahead",_go__ahead)
		if _go__ahead == 0 {
	        di as err `"Scores can be obtained only after a sfpanel estimation."'
	        exit 198
	    }
		cap scalar drop _go__ahead
		
		tempvar __esample
		qui gen `__esample' = (e(sample))
		
		mata: _Results = _ReSeT_eSaMpLe(_Results)
		mata: __ScOrE = moptimize_result_scores(_Results)
		
		if regexm("`e(ml_method)'","lf")==1 {
			_score_spec `0'
		}
		else {			
		    mata: st_numscalar("EqN_nUmB", cols(__ScOrE))
			local EqN_nUmB = EqN_nUmB
			scalar drop EqN_nUmB
			_stubstar2names `anything', nvars(`EqN_nUmB') single
		}
		
		local varn `s(varlist)'
		local vtyp `s(typlist)'
		       
		mata: st_view(__esample=., ., "`__esample'")
		mata: __rule = mm_which(__esample)
		
		local __i = 1
		foreach stubvar of local varn {
			qui gen `:word 1 of `vtyp'' `stubvar' = . if e(sample)==1
			mata: st_store(__rule, "`stubvar'", __ScOrE[.,`__i'] )
		local __i = `__i'+1	
		}
		__sfpanelpost_destructor
		exit
	}
	
    local S_COST = cond("`e(function)'"=="production", 1, -1) 


        /* Step 1:
            place command-unique options in local myopts
            Note that standard options are
            LR:
                Index XB Cooksd Hat 
                REsiduals RSTAndard RSTUdent
                STDF STDP STDR noOFFset
            SE:
                Index XB STDP noOFFset
        */

    local myopts "RES U U0 M BC JLMS MARGinal CI TRUNC(string)"

        /* Step 2:
            call _propts, exit if done, 
            else collect what was returned.
        */
	
    _pred_se "`myopts'" `0'
    if `s(done)' {
        exit
    }
    local vtyp  `s(typ)'
    local varn `s(varn)'
    local 0 `"`s(rest)'"'
		
	if regexm("`varn'", "marg")==1 & "`0'"=="" {
		tempname trickmarg
		local vtyp "double"
		local varn "`trickmarg'"
		local 0 ", marginal" 
		local stat "trickmarg"
	}
	
        /* Step 3:
            Parse your syntax.
        */

    syntax [if] [in] [, `myopts']

	if "`trunc'"!= "" {
		if ("`e(model)'"!="fels" & "`e(model)'"!="fecss" & "`e(model)'"!="regls" & "`e(model)'"!="fe") {
			di as err "Option trunc(`trunc') cannot be specified with model(`e(model)')."
			exit 198		
		}
		cap confirm integer number `trunc'
		if _rc!=0 {
			di as err "trunc() argument must be integer"
	        exit 198
		}
		else local trunc = `trunc'/100
	}
	else local trunc 0
	
    marksample touse
			
    local sumt = ("`u'"!="") + ("`u0'"!="") + ("`res'"!="") + ("`bc'"!="") + ("`m'"!="") + ("`jlms'"!="") 
    if `sumt' >1 {
        di as err "only one statistic may be specified"
        exit 198
    }
	else { 
		if `sumt' == 0 {
			if "`ci'"!="" {
				di as err "Confidence interval can be obtained only with option" in yel " u" in red ", " in yel "bc" in red" and " in yel "jlms" in red "." 
				exit 198
			}
			if "`marginal'" == "" {
				local stat "xb"
				di as txt "(option xb assumed; fitted values)"
			}
		}
		else local stat "`res'`u'`u0'`m'`bc'`jlms'"
			
		if "`marginal'" != "" local marg 1
		else local marg 0
	}
	
	if ("`stat'" == "" & `marg' == 1 & "`varn'"!="") {
		di as err "Option marginal can be specified together with either " in yel "u" in red "," in yel "jlms" in red "," in yel" bc" in red" or" in yel" m" in red " and alone without {newvar}."
		exit 198	
	}
	
	if ("`stat'" == "m" | "`stat'" == "bc")  &  ///
	("`e(model)'"=="fels" | "`e(model)'"=="fecss" | "`e(model)'"=="regls" | "`e(model)'"=="fe") {
		di as err "Option " in yel "`stat'" in red " cannot be specified with model(`e(model)')."
		exit 198		
	}
	
	if `"`u0'"' != "" & "`e(model)'"!="tre" {
		di as err "Inefficiency of type" in yel " u0" in red " can be obtained only with model(tre)."
        exit 198		
	}
	
	if `"`u'"' != "" & "`e(model)'"=="tre" & ("`ci'"!="" | `marg'==1) {
		di as err "Warning: Confidence interval and marginal effects can be obtained only if" in yel " u0" in red " is specified."
		exit 198
	}

	if "`stat'" == "bc" & "`ci'"!="" & "`e(model)'"=="bc92" & "`e(model)'"=="kumb90" {
		di as err "Confidence interval for E(exp(-u)|e) cannot be computed with model(`e(model)')."
		exit 198		
	}
	
	if "`ci'"!="" & ///
	("`e(model)'"=="fels" | "`e(model)'"=="fecss" | "`e(model)'"=="regls" | "`e(model)'"=="fe") {
		di in yel "Warning: Option `ci' will be ignored."
		local ci 		
	}
	
    Calc `"`vtyp'"' `varn' `stat' `S_COST' `touse' `marg' `trunc' `ci' 

end

program define Calc
        args vtyp varn stat S_COST cond marg trunc ci 
                        /* vtyp: type of new variable
                           varn: name of new variable
                           cond: if & in
                           stat: option specified 
                        */

if "`ci'" != "" local ci `e(cilevel)'

/// Initialize temp variables and names

tempname _b _temp_matrix ratio sigma_v sigma_u mu _b _c _d eta 
tempvar xb _xb res mres mu1 sigma1 A _uhat __sfpanel_esample mu  ///
		_alphahat _alphahat_max _alphahat_min _constant_ ym ratio xb_v xb_u  ///
		_alphahat_it _alphahat_it_max _alphahat_it_min __xi ///
		eta_e eta2 mu1 sigma1 T smpl tvar _jlms
	
local y `e(depvar)'
local ivar `e(ivar)'
local _tvar `e(tvar)'
qui fillin `ivar' `_tvar'
local by "by `ivar'"
qui `by': gen `tvar' = _n if _fillin != 1
cap drop if _fillin == 1
cap drop _fillin
_xt, trequired
	
/// We begin with xb regardless of the model estimated			
_predict double `xb' if `cond'==1, xb 

/// XB
if "`stat'"=="xb" {
	qui gen `vtyp' `varn' = `xb' if `cond'==1
	__sfpanelpost_destructor
	exit
}                            

/// for the remaining, we also need to know the full estimation subsample
qui gen byte `smpl' = e(sample)

/// Residuals for all models
if "`e(model)'" == "tre" | "`e(model)'" == "tfe"  {
	
	mata: _go__ahead = "0"
	cap mata: _go__ahead = (_DaTa!="" & _InIt_OpT!="")
	mata: st_numscalar("_go__ahead",_go__ahead)
	if _go__ahead == 0 {
        di as err `" "TRUE" models postestimation can be performed only after a sfpanel estimation."'
        exit 198
    }
	cap scalar drop _go__ahead
	local __PrEdIcT__ 1
	if "`e(model)'" == "tre"  local __PrEdIcTj__ 1
			
	/// Mark esample for true models (out of sample prediction is not allowed)
	qui gen `__sfpanel_esample' = .
	qui replace `__sfpanel_esample' = 1 if `smpl'==1
	markout `cond' `__sfpanel_esample'
	
	mat `_b' = e(b)
    
	_get_eqspec c_eqlist c_stub c_k :  `_b'
	scalar _k = `c_k'
	mata: _SV_predict = J(1, st_numscalar("_k"), _SV_predict())
	local _params_num  = 1

	foreach _params of local c_eqlist {
		mat `_temp_matrix' = `_b'[1,"`_params':"]
		mata: _SV_predict = _StArTiNg_VaLuEs_PrEd("`_temp_matrix'", `_params_num', _SV_predict)	
		** The following to check the content of the structure ** Just for debugging
		*mata: liststruct(_SV_predict)
		local _params_num = `_params_num' + 1
	}
	qui gen `res'=.
	if "`e(model)'" == "tre" qui gen `_jlms' = .
	mata: _InIt_OpT = _ReSeTi_EsAmPlE(_InIt_OpT)	
	mata: _PrEdIcT(_DaTa, _SV_predict, _InIt_OpT, "`res'", "`_jlms'")

}
else gen double `res' = `y'-`xb' if `cond'==1

if "`stat'"=="res" {
	gen double `varn' = `res' if `cond'==1
	__sfpanelpost_destructor
	exit
}

////// INEFFICIENCY POST-ESTIMATION BY MODEL ///////	

if "`e(model)'"=="fe" {	

		mat `_b' = e(b)
		local _covariates "`e(covariates)'"
		qui gen `_xb' = _b[_cons]
		local _covariates: list _covariates - _cons
		local __i = 1
		foreach _var of local _covariates {
			tempvar `_var'm
			qui egen ``_var'm' = mean(`_var') if `smpl'==1, by(`ivar')
			qui replace `_xb' = `_xb' + `_b'[1,`__i'] * ``_var'm'
			local __i = `__i'+1 
		}
		qui egen `ym' = mean(`y') if `smpl'==1, by(`ivar')
		qui gen `_alphahat' = `ym' - `_xb' if `smpl'==1
		
		if `trunc'>0 {  
			sort `tvar' `_alphahat'
			tempvar _truncated select mselect
			qui gen `_truncated' = .
			mata: __trunc("`ivar'","`tvar'","`_alphahat'","`smpl'","`_truncated'", `trunc')
			sort `ivar' `tvar'
			qui `by': gen `select'= (`_truncated'==.)
			qui `by': egen `mselect'= max(`select') if `smpl'==1
			qui replace `_alphahat' = . if `mselect'==1
		}
		
		if `S_COST' == 1 {
			qui egen `_alphahat_max' = max(`_alphahat')
			qui gen `vtyp' `_uhat' = `_alphahat_max' - `_alphahat' if `cond'==1 & `smpl'==1
		}
		else {
			qui egen `_alphahat_min' = min(`_alphahat')
			qui gen `vtyp' `_uhat' = `_alphahat' - `_alphahat_min' if `cond'==1 & `smpl'==1	
		}
}
else if "`e(model)'"=="regls" {	

		quietly {
			_predict double `_xb' if `smpl'==1, xb `offset'
			sort `ivar' `smpl'
			if e(Tcon)==0 {
				qui `by' `smpl': /*
				*/ gen double `ratio' = /*
				*/ scalar(e(sigma_u)^2/(_N*e(sigma_u)^2+e(sigma_v)^2)) /*
				*/ if `smpl'==1
			}
			else {
				scalar `ratio' = /*
				*/ scalar(e(sigma_u)^2/(e(Tbar)*e(sigma_u)^2+e(sigma_v)^2))
			}
			`by': gen double `_alphahat' = /*
			*/ `ratio'*sum(`y'-`_xb') if `smpl'==1
			`by': replace `_alphahat' = `_alphahat'[_N] if `cond'==1 
			
			if `trunc'>0 {  
				sort `tvar' `_alphahat'
				tempvar _truncated select mselect
				qui gen `_truncated' = .
				mata: __trunc("`ivar'","`tvar'","`_alphahat'","`smpl'","`_truncated'", `trunc')
				sort `ivar' `tvar'
				qui `by': gen `select'= (`_truncated'==.)
				qui `by': egen `mselect'= max(`select') if `smpl'==1
				qui replace `_alphahat' = . if `mselect'==1
			}
			
			if `S_COST' == 1 {
				qui egen `_alphahat_max' = max(`_alphahat')
				qui gen `vtyp' `_uhat' = `_alphahat_max' - `_alphahat' if `cond'==1 & `smpl'==1
			}
			else {
				qui egen `_alphahat_min' = min(`_alphahat')
				qui gen `vtyp' `_uhat' = `_alphahat' - `_alphahat_min' if `cond'==1 & `smpl'==1	
			}
		}						
} 
else if ("`e(model)'"=="tfe" | "`e(model)'"=="tre" | "`e(model)'"=="bc95") {
	if "`e(het)'" == "u" {
		scalar `sigma_v' = exp(0.5*[Vsigma]_cons)
		qui _predict double `xb_u' if `cond'==1, xb eq(Usigma)
		qui gen double `sigma_u' = exp(0.5*`xb_u')
	}
	else if "`e(het)'" == "v" {
		scalar `sigma_u' = exp(0.5*[Usigma]_cons)
		qui _predict double `xb_v' if `cond'==1, xb eq(Vsigma)
		qui gen double `sigma_v' = exp(0.5*`xb_v')
	}
	else if "`e(het)'" == "uv" {
		qui _predict double `xb_u' if `cond'==1, xb eq(Usigma)
		qui gen double `sigma_u' = exp(0.5*`xb_u')
		qui _predict double `xb_v' if `cond'==1, xb eq(Vsigma)
		qui gen double `sigma_v' = exp(0.5*`xb_v')
	}
	else if "`e(het)'" == "" {
			scalar `sigma_u' = exp(0.5*[Usigma]_cons)
			scalar `sigma_v' = exp(0.5*[Vsigma]_cons)					
	}
}
else if "`e(model)'"=="kumb90" | "`e(model)'"=="pl81" {			
	scalar `sigma_u' = sqrt([Usigma]_cons)
	scalar `sigma_v' = sqrt([Vsigma]_cons)		
}
else if "`e(model)'"=="bc88" | "`e(model)'"=="bc92" {			
	scalar `sigma_u' = e(sigma_u)
	scalar `sigma_v' = e(sigma_v)	
}
else if "`e(model)'"=="fecss" {	
		qui gen `_alphahat' = .
		noi mata: __css("`ivar'","`tvar'","`res'","`smpl'","`_alphahat'")
		
		if `trunc'>0 {  
			sort `tvar' `_alphahat'
			tempvar _truncated select mselect
			qui gen `_truncated' = .
			mata: __trunc("`ivar'","`tvar'","`_alphahat'","`smpl'","`_truncated'", `trunc')
			sort `ivar' `tvar'
			qui `by': gen `select'= (`_truncated'==.)
			qui `by': egen `mselect'= max(`select') if `smpl'==1
			qui replace `_alphahat' = . if `mselect'==1
		}
		
		if `S_COST' == 1 {
			qui egen `_alphahat_max' = max(`_alphahat'), by(`tvar')
			qui gen `vtyp' `_uhat' = `_alphahat_max' - `_alphahat' if `cond'==1 & `smpl'==1
		}
		else {
			qui egen `_alphahat_min' = min(`_alphahat'), by(`tvar')
			qui gen `vtyp' `_uhat' = `_alphahat' - `_alphahat_min' if `cond'==1 & `smpl'==1	
		}
}	
else if "`e(model)'"=="fels" {
		qui gen `_alphahat_it' = .
		mat `__xi' = e(b)
		mat `__xi' = `__xi'[1,"Time dummies:"]
		noi mata: __ls("`ivar'","`tvar'","`res'","`__xi'","`smpl'","`_alphahat_it'")
		
		if `trunc'>0 {  
			sort `tvar' `_alphahat_it'
			tempvar _truncated select mselect
			qui gen `_truncated' = .
			mata: __trunc("`ivar'","`tvar'","`_alphahat_it'","`smpl'","`_truncated'", `trunc')
			sort `ivar' `tvar'
			qui `by': gen `select'= (`_truncated'==.)
			qui `by': egen `mselect'= max(`select') if `smpl'==1
			qui replace `_alphahat_it' = . if `mselect'==1
		}
		
		if `S_COST' == 1 {
			qui egen `_alphahat_it_max' = max(`_alphahat_it'), by(`tvar')
			qui gen `vtyp' `_uhat' = `_alphahat_it_max' - `_alphahat_it' if `cond'==1 & `smpl'==1
		}
		else {
			qui egen `_alphahat_it_min' = min(`_alphahat_it'), by(`tvar')
			qui gen `vtyp' `_uhat' = `_alphahat_it' - `_alphahat_it_min' if `cond'==1 & `smpl'==1	
		}
}


/* truncated-normal (Regardless of the type of the model) */
if "`e(dist)'" == "tnormal" {
	mat `_b' = e(b)
	mat `_c' = `_b'[.,"Mu:"]
	scalar `_d' = colsof(`_c')
	if `_d'==1 scalar `mu' = `_c'[1,1]
	else qui _predict double `mu' if `cond'==1, eq(Mu) xb
}
		     
if ("`e(model)'"=="tfe" | "`e(model)'"=="tre" | "`e(model)'"=="bc95") {
	if "`e(dist)'" == "hnormal" {
		qui gen double `mu1' = -`S_COST'*`res'*`sigma_u'^2/(`sigma_u'^2+`sigma_v'^2) if `cond'==1
		qui gen double `sigma1' = `sigma_u'*`sigma_v'/sqrt(`sigma_u'^2+`sigma_v'^2) if `cond'==1
	}
	if "`e(dist)'" == "exponential" {
		qui gen double `mu1' = -`S_COST'*`res'-(`sigma_v'^2/`sigma_u') if `cond'==1
		qui gen `sigma1'     = `sigma_v' if `cond'==1
		qui gen `A'          =  -`mu1'/`sigma1' if `cond'==1
	}
	if "`e(dist)'" == "tnormal" {
		qui gen double `mu1' = (-`S_COST'*`res'*`sigma_u'^2 + ///
		                     `mu'*`sigma_v'^2)/(`sigma_u'^2+`sigma_v'^2) if `cond'==1
		qui gen double `sigma1' = `sigma_u'*`sigma_v'/ ///
			                    sqrt(`sigma_u'^2+`sigma_v'^2) if `cond'==1
	}	
}
else if "`e(model)'"=="bc88" | "`e(model)'"=="bc92" {    
	      
	if "`e(model)'" == "bc92" {
		scalar `eta' = [Eta]_cons
		qui `by': egen double `T' = max(`tvar') if `smpl'==1
		local td `:char _dta[_TSdelta]'
		if "`td'" == "" local td 1
		local eta_it (exp(-`eta'*(`tvar'-`T')/`td'))
	}
	else local eta_it 1     
	quietly {
		`by': gen double `eta_e' = cond( _n==_N, /*
    		*/ sum(`eta_it'*`res'), . )
	    `by': gen double `eta2' = cond( _n==_N, /*
	     */ sum(`eta_it'^2), . ) 

	    gen double `mu1' = (`mu'*`sigma_v'^2 /*
	    */ - `S_COST'*`eta_e'*`sigma_u'^2)/(`sigma_v'^2 /*
	    */ + `eta2'*`sigma_u'^2) 

	    gen double `sigma1' = `sigma_v'*`sigma_u' /*
	    */ /sqrt(`sigma_v'^2 + `eta2'*`sigma_u'^2) 
	    `by': replace `mu1' = `mu1'[_N] if `cond'==1
	    `by': replace `sigma1' = `sigma1'[_N] if `cond'==1  
	}
}	
else if "`e(model)'"=="kumb90" {
	
	if "`e(Bt)'" != "" qui _predict double `eta', xb eq(Bt)
	else if "`e(BT)'" != "" {
		cap qui gen b = `tvar'
		if _rc != 0 {
			noi di as error "Notice that you already have a variable called" in yel "b" as error "in your dataset. You have to rename it in order to use sfpanel post-estimation."
			error 101
			exit
		}
		cap qui gen c = `tvar'^2
		if _rc != 0 {
			noi di as error "Notice that you already have a variable called" in yel "b" as error "in your dataset. You have to rename it in order to use sfpanel post-estimation."
			error 101
			exit
		}
		qui _predict double `eta', xb eq(Bt) 
		cap drop b c 
	}
	local eta_it ((1 + exp(`eta'))^-1)
	quietly {
		`by': gen double `eta_e' = cond( _n==_N, /*
    	*/ sum(`eta_it'*`res'), . )
		`by': gen double `eta2' = cond( _n==_N, /*
    	*/ sum(`eta_it'^2), . ) 
    	gen double `mu1' = -(`sigma_u'^2 /*
    	*/ * `S_COST'*`eta_e')/(`sigma_v'^2 /*
    	*/ + `eta2'*`sigma_u'^2)
		gen double `sigma1' = `sigma_v'*`sigma_u' /*
    	*/ /sqrt(`sigma_v'^2 + `eta2'*`sigma_u'^2) 
    	`by': replace `mu1' = `mu1'[_N] if `cond'==1
    	`by': replace `sigma1' = `sigma1'[_N] if `cond'==1
	}
}
else if "`e(model)'" == "pl81" {
	qui {
	local eta_it 1
	`by': egen double `T' = max(`tvar') if `cond'==1
    `by': gen double `mres' = cond( _n == _N, sum(`res')/`T', .)
    gen double `mu1' = - (`S_COST'*`T'*`sigma_u'^2*`mres') / (`sigma_v'^2  + `sigma_u'^2*`T')  if `cond'==1
    gen double `sigma1' = `sigma_v'*`sigma_u'/sqrt(`sigma_v'^2+`sigma_u'^2*`T') if `cond'==1
    `by': replace `mu1'  = `mu1'[_N] if `cond'==1
    `by': replace `sigma1' = `sigma1'[_N] if `cond'==1
	}
}

////////* Get estimates for u=E(u|e) via Jondrow-Lovell-Materov-Schmidt (1982) *////////
local z (`mu1'/`sigma1')

if "`e(dist)'" == "hnormal" | "`e(dist)'" == "tnormal" {
	if "`e(model)'" == "tre" & ("`stat'"=="u" | "`stat'"=="jlms") gen `_uhat'= `_jlms' if `cond'==1
	else qui gen double `_uhat' = `mu1'+`sigma1'*(normalden(-`z')/normal(`z')) if `cond'==1
}
if "`e(dist)'" == "exponential" {
	if "`e(model)'" == "tre" & ("`stat'"=="u" | "`stat'"=="jlms") gen `_uhat'= `_jlms' if `cond'==1
	else qui gen double `_uhat' = `sigma1'*((normalden(`A')/(1-normal(`A')))-`A') if `cond'==1
}

/* Store estimates for E(u|e) */
if "`stat'"=="u" | "`stat'"=="u0" {
	
	if "`e(model)'"=="kumb90" | "`e(model)'"=="bc92" local _tvarying `eta_it'*
	else local _tvarying  

	gen `vtyp' `varn' = `_tvarying'`_uhat' if `cond'==1
	
	if "`e(model)'"!="fecss" & "`e(model)'"!="fels" & "`e(model)'"!="fe" & "`e(model)'"!="regls" {
		
		if `S_COST' == 1 label var `varn' "Technical inefficiency via E(u|e)"
		else label var `varn' "Cost inefficiency via E(u|e)"
		
		/* Get CI for Technical Inefficiency */
		if  "`ci'"!="" {
			// See Bera&Sharma and Horrace&Schmidt
			tempvar zl zu
			tempname alpha
			scalar `alpha' = (1-.`ci')
			qui gen `zu' = invnormal(1 - (`alpha'/2) * norm(`z'))
			qui gen `zl' = invnormal((`alpha'/2) + (1 - (`alpha'/2)) * norm(-`z'))
			local cin = `ci'
			gen `varn'_LB`cin' = `_tvarying'(`mu1' + `zl' * `sigma1')
			lab var `varn'_LB`cin' "`cin'% lower bound of E(`stat'|e)"
			gen `varn'_UB`cin' = `_tvarying'(`mu1' + `zu' * `sigma1')
			lab var `varn'_UB`cin' "`cin'% upper bound of E(`stat'|e)"
		}
	}
	else {
		if `S_COST' == 1 label var `varn' "Technical inefficiency via CB (Comparison with the best)"
		else label var `varn' "Cost inefficiency via CB (Comparison with the best)"		
	}
}
	
/* Store estimates for M(u|e) */
if "`stat'"=="m" {
	gen `vtyp' `varn' = cond(`mu1'>=0, `mu1', 0) if `cond'==1
	if `S_COST' == 1 label var `varn' "Technical inefficiency via M(u|e)"
	else label var `varn' "Cost inefficiency via M(u|e)"
}

/* Get estimates for Technical Efficiency (TE) via Jondrow-Lovell-Materov-Schmidt (1982)*/
if "`stat'"=="jlms" {
	gen `vtyp' `varn' = exp(-`_uhat') if `cond'==1
	if `S_COST' == 1 label var `varn' "Technical efficiency via exp(-E(u|e))"
	else label var `varn' "Cost efficiency via exp(-E(u|e))"
	/* Get CI for Technical Efficiency (TE) */
	if  "`ci'"!=""  {
		// See Bera&Sharma and Horrace&Schmidt
		tempvar zl zu
		tempname alpha
		scalar `alpha' = (1-.`ci')
		qui gen `zl' = invnormal(1 - (`alpha'/2) * norm(`z'))
		qui gen `zu' = invnormal((`alpha'/2) + (1 - (`alpha'/2)) * norm(-`z'))
		local cin = `ci'
		gen `varn'_LB`cin' = exp(-`_tvarying'(`mu1' + `zl' * `sigma1'))
		lab var `varn'_LB`cin' "`cin'% lower bound of exp(-E(u|e))"
		gen `varn'_UB`cin' = exp(-`_tvarying'(`mu1' + `zu' * `sigma1'))
		lab var `varn'_UB`cin' "`cin'% upper bound of exp(-E(u|e))"
	}
}

/* Get estimates for Technical or Cost Efficiency via Battese-Coelli (1988)*/
if "`stat'"=="bc" {
	if ("`e(model)'"=="tre" | "`e(model)'"=="tfe" | "`e(model)'"=="bc95") {
		gen `vtyp' `varn'= (normal(-`sigma1'+`z'))/ ///
			normal(`z') *exp(-`mu1'+.5*`sigma1'^2) if `cond'==1	
	}
	else if ("`e(model)'"=="pl81" | "`e(model)'"=="bc88" | "`e(model)'"=="bc92" | "`e(model)'"=="kumb90") {
		gen `vtyp' `varn' = /*
	        */ (1-normal(`eta_it'*`sigma1' /*
	        */ - (`mu1'/`sigma1'))) /*
	        */ /(1-normal(-`mu1'/`sigma1')) /*
	        */ *exp(-`eta_it'*`mu1' /*
	        */ +0.5*`eta_it'^2*`sigma1'^2) /*
	        */ if `cond'==1
	}
	if `S_COST' == 1 label var `varn' "Technical efficiency via E(exp(-u)|e)"
	else label var `varn' "Cost efficiency via E(exp(-u)|e)"
	/* Get CI for Technical Efficiency (TE) */
	
	if ("`e(model)'"=="bc92" | "`e(model)'"=="kumb90") {
		di in gr "Warning: Confidence interval for E(exp(-u)|e) cannot be computed when model(`e(model)')" 
	}
	else {
		if  "`ci'"!=""  {
			// See Bera&Sharma and Horrace&Schmidt
			tempvar zl zu
			tempname alpha
			scalar `alpha' = (1-.`ci')
			qui gen `zl' = invnormal(1 - (`alpha'/2) * norm(`z'))
			qui gen `zu' = invnormal((`alpha'/2) + (1 - (`alpha'/2)) * norm(-`z'))
			local cin = `ci'
			gen `varn'_LB`cin' = exp(-`mu1' - `zl' * `sigma1')
			lab var `varn'_LB`cin' "`cin'% lower bound of E(exp(-u)|e)"
			gen `varn'_UB`cin' = exp(-`mu1' - `zu' * `sigma1')
			lab var `varn'_UB`cin' "`cin'% upper bound of E(exp(-u)|e)"
    	
		}
	}
}


if (`marg'==1 & "`e(dist)'"=="tnormal" & ("`e(model)'"=="tfe" | "`e(model)'"=="tre" | "`e(model)'"=="bc95")) {

	    tempname margb mucoeffs sigmaucoeffs _hetero _ratio fsterm combi1 combi2 _coe1 _coe12 mgef
		matrix `margb' = e(b)
		
			matrix `mucoeffs' = `margb'[1, "Mu:"] 
			matrix `sigmaucoeffs' = `margb'[1, "Usigma:"] 
			local muvarn: coln `mucoeffs' 
			local uvarn: coln `sigmaucoeffs'
			local _k_mu: word count `muvarn'
			local _k_u: word count `uvarn'
			
			if ((`_k_mu' > 1) & (`_k_u' == 1) & ("`uvarn'"=="_cons")) local _check_case1 "1"
			if ((`_k_mu' == 1) & (`_k_u' > 1) & ("`muvarn'"=="_cons")) local _check_case2 "1"
			
			if `_k_mu' == 1 & `_k_u' == 1 & "`muvarn'" == "_cons" & "`uvarn'"== "_cons" di in gr "Warning: Cannot compute marginal effects if no covariates are included in emean() and usigma()."		
			if ((`_k_mu' == `_k_u') & ("`muvarn'" != "`uvarn'")) { 
			   di in red "Cannot compute marginal effects if emean() and usigma() variables are not the same."
			   exit 198
			}
			else if (`_k_mu' != `_k_u') & "`_check_case1'"=="" & "`_check_case2'"=="" {
			   di in red "Cannot compute marginal effects if emean() and usigma() variables are not the same."
			   exit 198
			}
			else if "`_check_case1'"=="1" { 
			   scalar _sost = `sigmaucoeffs'[1,1] 
			   matrix `sigmaucoeffs' = J(1, `_k_mu', 0) 
			   matrix `sigmaucoeffs'[1, `_k_mu'] = _sost 
			   scalar `_hetero' = 0
			}
			else if "`_check_case1'"=="2" { 
			   scalar _sost = `mucoeffs'[1,1] 
			   matrix `mucoeffs' = J(1, `_k_u', 0) 
			   matrix `mucoeffs'[1, `_k_u'] = _sost 
			   scalar `_hetero' = 0
			}
			else scalar `_hetero' = 1
	

		/* The following is the marginal effect on unconditional E(u) based on Wang (2002) */

		local ii = 1
		cap scalar `_coe1' = `mucoeffs'[1,`ii']
		cap scalar `_coe12' = `sigmaucoeffs'[1,`ii']

		tokenize "`muvarn'"
		local _thevar ``ii''

		while (`_coe1' != .) & ("`_thevar'"!="_cons") {

   			          quie gen double `_ratio' = (`mu')/`sigma_u' if `cond'==1
   			          quie gen double `fsterm' = normalden(`_ratio')/normal(`_ratio') if `cond'==1
   			          quie gen double `combi1' = `_coe1'*( 1 - (`_ratio')*(`fsterm') - (`fsterm')^2) if `cond'==1
   			          quie gen double `combi2' = 0.5*(`_coe12')*( (`sigma_u' + (`mu')*(`_ratio'))*(`fsterm') + (`mu')*(`fsterm')^2) if `cond'==1
					  quie gen double `mgef' = `combi1' + `combi2' if `cond'==1

   			          *capture drop `_thevar'_M
					  if regexm("`_thevar'", "\.")==1 {
							gettoken _fp_thevar _sp_thevar: _thevar, parse(".")
							local _fp_thevar = subinstr("`_fp_thevar'",".","_",.)
							local _sp_thevar = subinstr("`_sp_thevar'",".","",1)
							local _sp_thevar = subinstr("`_sp_thevar'",".","_",.)
							local _fp_thevar = subinstr("`_fp_thevar'","(","_",.)
							local _sp_thevar = subinstr("`_sp_thevar'","(","_",.)
							local _fp_thevar = subinstr("`_fp_thevar'",")","_",.)
							local _sp_thevar = subinstr("`_sp_thevar'",")","_",.)
							local _fp_thevar = subinstr("`_fp_thevar'","#","_",.)
							local _sp_thevar = subinstr("`_sp_thevar'","#","_",.)
							local _thevar "`_sp_thevar'_`_fp_thevar'"
					  }
   			          gen double `_thevar'_M = `mgef' if `cond'==1
   			          label var `_thevar'_M "Marginal effect of `_thevar' on E(u)"

   			      local ii = `ii' + 1

   			        foreach X in `_ratio' `mgef' `fsterm' `combi1' `combi2' {
   			           capture drop `X'
   			        }

   			      scalar `_coe1' = `mucoeffs'[1,`ii']
   			      scalar `_coe12' = `sigmaucoeffs'[1, `ii']

   			      tokenize "`muvarn'"
   			      local _thevar ``ii''
		}

   		/* The following is the marginal effect on unconditional V(u) based on Wang (2002) */


   		local ii = 1
   		capture scalar `_coe1' = `mucoeffs'[1,`ii']
   		capture scalar `_coe12' = `sigmaucoeffs'[1,`ii']

   		tokenize "`uvarn'"
   		local _thevar ``ii''

   		while (`_coe1' != .) & ("`_thevar'"!= "_cons") {
    
			        quie gen double `_ratio' = (`mu')/`sigma_u' if `cond'==1
			        quie gen double `fsterm' = normalden(`_ratio')/normal(`_ratio') if `cond'==1
			        quie gen double `combi1' = (`fsterm')*((`mu')^2 -(`sigma_u'^2))/(`sigma_u') + (`fsterm')^2*3*(`mu') + (`fsterm')^3*2*(`sigma_u')  if `cond'==1
			        quie gen double `combi2' = `sigma_u'^2 - (`fsterm')*(((`sigma_u'^2)*(`mu') + (`mu')^3)/(2*(`sigma_u'))) - (`fsterm')^2*(`sigma_u'^2 + 1.5*(`mu')^2) - (`fsterm')^3*(`sigma_u')*(`mu')  if `cond'==1
			        quie gen double `mgef' =  (`_coe1')*(`combi1') + (`_coe12')*(`combi2')  if `cond'==1
			
			        *capture drop `_thevar'_V
					if regexm("`_thevar'", "\.")==1 {
							gettoken _fp_thevar _sp_thevar: _thevar, parse(".")
							local _fp_thevar = subinstr("`_fp_thevar'",".","_",.)
							local _sp_thevar = subinstr("`_sp_thevar'",".","",1)
							local _sp_thevar = subinstr("`_sp_thevar'",".","_",.)
							local _fp_thevar = subinstr("`_fp_thevar'","(","_",.)
							local _sp_thevar = subinstr("`_sp_thevar'","(","_",.)
							local _fp_thevar = subinstr("`_fp_thevar'",")","_",.)
							local _sp_thevar = subinstr("`_sp_thevar'",")","_",.)
							local _fp_thevar = subinstr("`_fp_thevar'","#","_",.)
							local _sp_thevar = subinstr("`_sp_thevar'","#","_",.)
							local _thevar "`_sp_thevar'_`_fp_thevar'"
					}
			        gen double `_thevar'_V = `mgef'  if `cond'==1
			        label var `_thevar'_V "Marginal effect of `_thevar' on V(u)"

			    local ii = `ii' + 1

			      foreach X in `_ratio' `fsterm' `mgef' `combi1' `combi2' {
			         capture drop `X'
			      }

			    scalar `_coe1' = `mucoeffs'[1,`ii']
			    scalar `_coe12' = `sigmaucoeffs'[1, `ii']
				tokenize "`uvarn'"
				local _thevar ``ii''
		}


}
else if (`marg'==1 & ("`e(model)'"=="tfe" | "`e(model)'"=="tre")) {
	 if "`e(dist)'"!="tnormal" di in yel "Warning: Cannot compute marginal effects if distribution is different from tnormal."		
}
else if (`marg'==1 & ("`e(model)'"!="tfe" & "`e(model)'"!="tre" & "`e(model)'"!="bc95")) {
	 di in yel "Warning: Cannot compute marginal effects for model(`e(model)')."		
}

__sfpanelpost_destructor

end

program define __sfpanelpost_destructor
syntax

// DROP compulsory scalars created for structures
local sclist "_k"
foreach s of local sclist { 
	capture scalar drop `s'
}
// DROP compulsory matrix created for structures
capture matrix drop _CNS
// DROP structures
local strlist "_SV_predict _go__ahead"
foreach s of local strlist { 
	capture mata: mata drop `s'
} 

end


exit



*! version 1.0.1  23aug2010
*! version 1.1.1  22sep2011
*! version 1.2 19aug2012
*! version 1.2.1 30sep2013 * fix the issue on the -fe-,-regls-,-fecss- and -fels- inefficiency computation
*! version 1.2.2 30nov2015 * fix a bug affecting -fe- and -regls- inefficiency computation




