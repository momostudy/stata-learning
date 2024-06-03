*! xtbcfe V3.0.3   23March2015
*! Ignace De Vos, SHERPPA, Ghent University, Belgium (ignace.devos@ugent.be)
*! Ilse Ruyssen, SHERPPA, Ghent University, Belgium (ilse.ruyssen@ugent.be)
*! Gerdie Everaert, SHERPPA, Ghent University, Belgium (gerdie.everaert@ugent.be)
// ==============================================================
// ====1/ THE MAIN ROUTINE
// ==============================================================
capture program drop xtbcfe
capture mata mata drop bcfe_ub()
capture mata mata drop bootstrap()
capture mata mata drop fe()
capture mata mata drop generate()
capture mata mata drop inference()
capture mata mata drop res_calc()
capture mata mata drop Ti_det()
capture mata mata drop mult()
capture mata mata drop cov_pos()

program define xtbcfe, eclass sort       
	version 11.0 
	syntax varlist [if] [,        					  ///
        Lags(integer 1)								  ///
        TE			 					  	  		  ///
        RESampling(string) 						  	  ///
        INItialization(string)					  	  ///
        BCIters(integer 250)						  /// 
        INFERence(string)							  ///
 		LEVEL(integer 95)						  	  ///
        INFIters(integer 0)							  ///
        CRITerion(real 0.005)						  ///
        PARAM										  ///
        DISTribution(string)]
        

 // Recode level
 	local level = 100-`level'
 
 
 // Set default values for infiters  
    if ("`inference'"=="") {
        local inf_se_iters 0
        local inf_appr_iters 0
   	}
    else if (("`inference'"=="inf_se" | "`inference'"=="inf_ci")  & `infiters'==0) {
        local inf_se_iters 250 					 
        local inf_appr_iters 0
    }
    else if ("`inference'"=="inf_se" & `infiters'>0) {
        local inf_se_iters `infiters'
        local inf_appr_iters 0
		if (`inf_se_iters' < 5) {
			di as err "Number of iterations infiters too low," /*
  	  		*/ as err " choose value >= 5"
  	  		exit 198
  	  	}
	}
	else if ("`inference'"=="inf_ci" & `infiters'>0) {
        local inf_se_iters `infiters'
        local inf_appr_iters 0
		if (`inf_se_iters' < 100) {
			di as err "Number of iterations infiters too low," /*
  	  		*/ as err " choose value >= 100"
  	  		exit 198
  	  	}
	}
	else if ("`inference'"=="inf_appr" & `infiters'==0) {
        local inf_se_iters 0
        local inf_appr_iters 1000
	}	
    else if ("`inference'"=="inf_appr" & `infiters'>0) {
        local inf_se_iters 0
        local inf_appr_iters `infiters'
		if (`inf_appr_iters' < 5) {
			di as err "Number of iterations infiters too low," /*
  	  		*/ as err " choose value >= 5"
  	  		exit 198
  	  	}
	}
// Parametric or Non-Parametric inference: 1 is parametric, non-parametric is the default
	if ("`param'"!="") {
		local PNP 1
	}
	else local PNP 0	

 // Display error message when wrong initialization and resampling scheme combination
    if ("`inference'"!="inf_se"&"`inference'"!="inf_ci"&"`inference'"!="inf_appr"&"`inference'"!="") {
        di as err "`inference' not allowed as an option for inference." /*
  	  	*/ as err " Choose either inf_se, inf_ci or inf_appr"
    	exit 198
    }      
    // if resampling or ini are left empty (needed for output)
    if ("`resampling'"=="") local resampling "iid"    
    if ("`initialization'"=="") local initialization "det"
    if ("`initialization'"!="det"&"`initialization'"!="bi"&"`initialization'"!="aho"&"`initialization'"!="ahe") {
        di as err "`initialization' not allowed as an option for initialization." /*
  	  	*/ as err " Choose either det, bi, aho or ahe."
    	exit 198
    }           

 // Display error message when number of bootstraps below treshold
	if `bciters' < 50 {
		di as err "Number of bootstrap iterations too low," /*
  	  	*/ as err " choose value >= 50"
  	  	exit 198
	}
// error when unrealistic number for level
	if (`level'>=100) {
		di as err "Specified value for level not allowed." 
  	  	exit 198
	}	
 
 // Mark data 
	quietly {               
    tempname touse
    mark `touse' `if'
    count if `touse'
    if r(N)<=1 {
    	error 2001
    }
    }
	preserve
	qui keep if `touse' 
	
	// Fill in missing years as missing    
    tsfill, full
	
 // Verify that data are xtset properly 
	capture xtset
    capture local ivar "`r(panelvar)'"
    if "`ivar'"=="" {
    	di as err "must xtset data and specify panelvar"
    	exit 459
    }
    capture local tvar "`r(timevar)'"
    if "`tvar'" == "" {
    	di as err "must xtset data and specify timevar"
		exit 459
    }
  	
 // read in cross-section size N
 	qui distinct `ivar', missing
 	local N = r(ndistinct)	
	
 // Unabbreviate varlist
  	unab varlist: `varlist'

 //	Get rid of time dummies in the exogenous regressor list 
	local varlist_old `varlist'
	foreach k in `varlist' {    
		egen sum_`k' = sum(`k') if `touse', by(`ivar') 
		capture assert (`k'==0 | `k'==1 | `k'==.) & (sum_`k'==1 | sum_`k'==1) if `touse'
        if _rc==0 { // time dummy found
            local dumvar `k'
            local varlist: list varlist-dumvar
        }
    }
	local varlist_new `varlist'
	local varlist_diff: list varlist_old-varlist_new
	local td: list sizeof varlist_diff

 // Create time dummies
	local TE 0
	if ("`te'"!="") {
		local TE 1
	}
	
 // Identify depvar and indepvars
	gettoken depvar indepvar: varlist

 //	Make sure panel variable is not part of varlist
	if subinword("`varlist'","`ivar'","",.) != "`varlist'" {
		di as err "the panel variable `ivar' may not be " /*
  	  	*/ as err "included as an independent variable"
  	  	exit 198
	}

 // Check if the dependent is time invariant
	capture assert D.`depvar'==0 if D.`depvar'!=. & `touse'
	if _rc==0 {
    	di as err "the dependent variable may not be time-invariant"
        exit 198 
    }
 //	Get rid of time invariant variables in the exogenous regressor list 
	foreach k in `indepvar' {   	
		capture assert D.`k'==0 if D.`k'!=. & `touse'
        if _rc==0 {
        	di as text "note: variable `k' is time-invariant over the estimation sample and" 
            di as text "      was discarded"
        }
    	else {
        	local xvar "`xvar' `k'"
        }
    }

 // Calculate lagged dependent   
    global ldeps 
    forvalues j=1(1)`lags' {
    	if `j'==1 {
    		global ldeps $ldeps L.`depvar'		
    	}
    	else {
    		global ldeps $ldeps L`j'.`depvar'
    	}
    }
	local ldeps $ldeps
	
 //	Check for perfect collinearity in the exogenous regressor list
	_rmcoll `xvar' if `touse', noconstant forcedrop
	
 // Check for perfect collinearity in the complete regressor list 
 // (excluding the constant term but including lagged dependent variables) 
	local rhsvars `ldeps' `r(varlist)' // Lagged dependent and non-collinear exogenous variables
	qui _rmcoll `rhsvars' if `touse', noconstant forcedrop
	local rhsvars1_ct: word count `r(varlist)' // List of non-collinear regressors (lagged dependent vars and exogenous)
	tokenize `r(varlist)'

 //Define xvar as the exogenous vars (without ldeps and the collinear ones)
	*Case 1: there is a collinear variable dropped but it is not the ldep
    if (`r(k_omitted)'>0 & "``lags''"=="L`lags'.`depvar'") {
    	_rmcoll `rhsvars' if `touse', noconstant forcedrop  
        local rvarlist `r(varlist)'
        local xvar: subinstr local rvarlist "`ldeps'" "", all word
		local colvar: list indepvar-xvar
    }    
	*Case 2: there is a collinear variable dropped and it concerns one or more of the ldeps
	else if (`r(k_omitted)'>0 & "``lags''"!="L`lags'.`depvar'") {
        di as error "One or more of the lagged dependent variables collinear with"
        di as error "the exogenous regressors. Consider alternative number of lags"
        exit 459
    }
	*Case 3: there are no collinear variables
	else {
        local rvarlist `r(varlist)'
        local xvar: subinstr local rvarlist "`ldeps'" "", all word
   }


 //Create numeric inputs for resampling and initialization
 	if ("`resampling'"=="mcho" | "`resampling'"=="") local resample 10 // Default
 	if ("`resampling'"=="mche") local resample 11
 	if ("`resampling'"=="mcthe") local resample 12 	
 	if ("`resampling'"=="iid") local resample 20 
 	if ("`resampling'"=="cshet") local resample 30
 	if ("`resampling'"=="cshet_r") local resample 35
 	if ("`resampling'"=="thet") local resample 50
 	if ("`resampling'"=="thet_r") local resample 51
 	if ("`resampling'"=="wboot") local resample 40
 	if ("`resampling'"=="wboot_r") local resample 41
 	if ("`resampling'"=="csd") local resample 31

 	if ("`initialization'"=="det" | "`initialization'"=="") local ini 1 // Default
 	if ("`initialization'"=="bi") local ini 2
 	if ("`initialization'"=="aho") local ini 31
 	if ("`initialization'"=="ahe") local ini 41
 	

 //Check which type of inference is requested
    if ("`inference'"=="inf_se") {
		local boot_se 101 
        local boot_appr 0
	}
	else if ("`inference'"=="inf_ci") {
		local boot_se `level'
        local boot_appr 0 
	}
	else if ("`inference'"=="inf_appr") {
		local boot_se 0
        local boot_appr `level'
	}
	else if ("`inference'"=="") {	
		local boot_se 0
        local boot_appr 0
    }
 	
 // BOOTSTRAP-BASED BIAS CORRECTION 
	ereturn clear
	local vars `depvar' `xvar' 
	if (`rhsvars1_ct' > `lags') {
		local ar "`rhsvars1_ct'"	 		
	}
	else {
		local ar "1"
	}
	
	mata: bcfe_ub("`vars'",`N',`lags',`criterion',`resample',`ini',`bciters',`boot_se',`boot_appr',`level',`inf_se_iters',`inf_appr_iters',`ar',`PNP',`TE')

 // ESTIMATION RESULTS
 	tempname b_bcfe V_bcfe res_bcfe dist_bcfe  
	matrix b_bcfe = r(b)		
	matrix res_bcfe = r(e)
	matrix V_bcfe = r(V)
	matrix dist_bcfe = r(dist_bcfe)	
	local nobs_bcfe = r(nobs)	
	local N = r(N)
	local T_full = r(T)
	local t_avg = r(t_avg)	
	local t_min = r(t_min)
	local t_max = r(t_max)
	local conv = r(conv)
	local level = 100-`level'
	local irr = r(irr)
	local se_term = r(se_terminate)
	if (`boot_se'!=0)&(`boot_se'!=101)&(`boot_appr'==0)&(`se_term'==0) {  
		matrix conf_tmp = r(conf) 
	}
		
	// Time dummies
    if (`TE'==1) {
    	local b_year = r(begin_year)
    	local e_year = r(end_year)
    	local rhsvars1_ct = `rhsvars1_ct' + `e_year'-`b_year'+1
    	forvalues j = 1(1)`T_full' {
    		capture confirm variable `tvar'`j'
    		if (_rc==0) drop `tvar'`j'
    	}
		qui tabulate `tvar', missing gen("`tvar'")
 		local TElist `tvar'`b_year'-`tvar'`e_year'
 		unab TElist: `TElist'
 		local varlist `varlist' `TElist'
 		local rhsvars `rhsvars' `TElist'
 		local xvar `rhsvars' `TElist'
 	}	
	
	matrix colnames b_bcfe = `rhsvars'	
 	matrix colnames V_bcfe = `rhsvars'
 	matrix rownames V_bcfe = `rhsvars'	
 	matrix colnames dist_bcfe = `rhsvars'
 	
 	
 	// Make coef histogram of the bootstrap distribution	
	if ((`boot_se'!=0)&(`boot_appr'==0)&(`conv'==1)&(`se_term'==0)&("`distribution'"!="")&("`distribution'"!="none")) {
		local Nold = _N	
		forvalues j = 1(1)`rhsvars1_ct' {
    		capture confirm variable bcfe_dist`j'
    		if (_rc==0) drop bcfe_dist`j'
    		tempvar bcfe_dist`j'
    	}
    	if (("`distribution'"=="all")|("`distribution'"=="sum")) {
    		capture confirm variable sum_ar_coef
    		if (_rc==0) drop sum_ar_coef
			qui svmat dist_bcfe, names(bcfe_dist)
			if (`lags'>1) {
				tempvar sum_ar_coef
				qui egen sum_ar_coef = rowtotal(bcfe_dist1-bcfe_dist`lags'), missing
				qui hist sum_ar_coef, xtitle("Sum of autoregressive coefficients") title("bootstrap distribution of the sum of AR coefs") name("h0",replace) norm normopts(lcolor(red) lpattern("..-..")) kdensity legend(on order(2 3) rows(1) lab(3 "normal dist") lab(2 "kernel fit"))
				drop sum_ar_coef
			}
			if (("`distribution'"=="sum")&(`lags'==1)) qui hist bcfe_dist1, xtitle("L.n") title("bootstrap distribution of L.`depvar'") name("h1",replace) norm normopts(lcolor(red) lpattern("..-..")) kdensity legend(on order(2 3) rows(1) lab(3 "normal dist") lab(2 "kernel fit"))
		}
		if ("`distribution'"=="all") {
			forvalues j = 1(1)`lags' {
				if (`j'==1)	qui hist bcfe_dist`j', xtitle("L.n") title("bootstrap distribution of L.`depvar'") name("h`j'",replace) norm normopts(lcolor(red) lpattern("..-..")) kdensity legend(on order(2 3) rows(1) lab(3 "normal dist") lab(2 "kernel fit"))
				else qui hist bcfe_dist`j', xtitle("L`j'.n") title("bootstrap distribution of L`j'.`depvar'") name("h`j'",replace) norm normopts(lcolor(red) lpattern("..-..")) kdensity legend(on order(2 3) rows(1) lab(3 "normal dist") lab(2 "kernel fit"))
			}
		}
		if (_N>`Nold') {
			local Nold = `Nold' + 1
			local Nnew = _N
			qui drop in `Nold'/`Nnew' 
		} 		
		drop bcfe_dist1
		if (`rhsvars1_ct'>1) drop bcfe_dist2-bcfe_dist`rhsvars1_ct'
	} 	
	
 // Warnings	
    if `nobs_bcfe'<=1 { 
    	error 2001 
    }  

 // Output tables
    if ((`boot_se'==0)&(`boot_appr'==0)|(`conv'==0)) {
		matrix se = J(`rhsvars1_ct',1,.)
		local df_r = `nobs_bcfe' - `N' - `rhsvars1_ct' 
		matrix tstat = J(`rhsvars1_ct',1,.)
		matrix pval = J(`rhsvars1_ct',1,.)
		matrix confidence = J(`rhsvars1_ct',2,.)
		matrix Results = (b_bcfe',se,tstat,pval,confidence)
    }
   	else if (`boot_se'==101)&(`boot_appr'==0) {
   		// Bootstrapped standard errors and normal confidence intervals
		if (`se_term'==0) {
			matrix se = vecdiag(cholesky(diag(vecdiag(V_bcfe))))
			local df_r = `nobs_bcfe' - `N' - `rhsvars1_ct' 
			matrix pval = J(`rhsvars1_ct',1,0)
			matrix tstat = J(`rhsvars1_ct',1,0)
			matrix confidence = J(`rhsvars1_ct',2,0)
			forvalues j = 1(1)`rhsvars1_ct' {
				matrix tstat[`j',1]= b_bcfe[1,`j']/se[1,`j']
				matrix pval[`j',1]= 2*ttail(`df_r', abs(tstat[`j',1]))
				matrix confidence[`j',1] = b_bcfe[1,`j'] - (invttail(`df_r',(100-`level')/200) * se[1,`j'])
				matrix confidence[`j',2] = b_bcfe[1,`j'] + (invttail(`df_r',(100-`level')/200) * se[1,`j'])
			}
			matrix Results = (b_bcfe',se',tstat,pval,confidence)
		}
		else {
			matrix se = J(`rhsvars1_ct',1,.)
			local df_r = `nobs_bcfe' - `N' - `rhsvars1_ct' 
			matrix tstat = J(`rhsvars1_ct',1,.)
			matrix pval = J(`rhsvars1_ct',1,.)
			matrix confidence = J(`rhsvars1_ct',2,.)
			matrix Results = (b_bcfe',se,tstat,pval,confidence)			
		}		
    }   
    else if (`boot_se'!=0)&(`boot_se'!=101)&(`boot_appr'==0) {
    // bootstrap confidence intervals from inference (inf_ci)   
    local df_r = `nobs_bcfe' - `N' - `rhsvars1_ct'
    	if (`se_term'==0) {
    		matrix confidence = J(`rhsvars1_ct',2,0) 
    		matrix colnames confidence = "`level'% Conf" "Interval"
			matrix rownames confidence = `rhsvars' 
 	    	matrix confidence = conf_tmp
			matrix se = vecdiag(cholesky(diag(vecdiag(V_bcfe))))			 
			matrix pval = J(`rhsvars1_ct',1,0)
			matrix tstat = J(`rhsvars1_ct',1,0)
			forvalues j = 1(1)`rhsvars1_ct' {
			matrix tstat[`j',1]= b_bcfe[1,`j']/se[1,`j']
			matrix pval[`j',1]= 2*ttail(`df_r', abs(tstat[`j',1]))
		}
		matrix Results = (b_bcfe',se',tstat,pval,confidence)
		}
		else {
			matrix se = J(`rhsvars1_ct',1,.)
			local df_r = `nobs_bcfe' - `N' - `rhsvars1_ct' 
			matrix tstat = J(`rhsvars1_ct',1,.)
			matrix pval = J(`rhsvars1_ct',1,.)
			matrix confidence = J(`rhsvars1_ct',2,.)
			matrix Results = (b_bcfe',se,tstat,pval,confidence)
		}			 				
    }
    else if (`boot_se'==0)&(`boot_appr'!=0) {
    // bootstrap approximated standard errors
    	if (`se_term'==0) {
			matrix se = vecdiag(cholesky(diag(vecdiag(V_bcfe))))
			local df_r = `nobs_bcfe' - `N' - `rhsvars1_ct' 
			matrix pval = J(`rhsvars1_ct',1,0)
			matrix tstat = J(`rhsvars1_ct',1,0)
			matrix confidence = J(`rhsvars1_ct',2,0)
			forvalues j = 1(1)`rhsvars1_ct' {
				matrix tstat[`j',1]= b_bcfe[1,`j']/se[1,`j']
				matrix pval[`j',1]= 2*ttail(`df_r', abs(tstat[`j',1]))
				matrix confidence[`j',1] = b_bcfe[1,`j'] - (invttail(`df_r',(100-`level')/200) * se[1,`j'])
				matrix confidence[`j',2] = b_bcfe[1,`j'] + (invttail(`df_r',(100-`level')/200) * se[1,`j'])
			}
			matrix Results = (b_bcfe',se',tstat,pval,confidence)
		}
		else {
			matrix se = J(`rhsvars1_ct',1,.)
			local df_r = `nobs_bcfe' - `N' - `rhsvars1_ct' 
			matrix tstat = J(`rhsvars1_ct',1,.)
			matrix pval = J(`rhsvars1_ct',1,.)
			matrix confidence = J(`rhsvars1_ct',2,.)
			matrix Results = (b_bcfe',se,tstat,pval,confidence)			
		}
    }

	keep `ivar' `tvar' `TElist'
	sort `ivar' `tvar'
	qui save TElist.dta, replace
	restore 
	qui merge m:m `ivar' `tvar' using TElist.dta
	drop _merge
	sort `ivar' `tvar'
	markout `touse' `depvar' `ldeps' `xvar'  

    *Obtain coefficient vector and varcov matrix
	ereturn post b_bcfe V_bcfe, depname(`depvar') obs(`nobs_bcfe') esample(`touse') dof(`df_r')
	ereturn local cmd = "xtbcfe"
	ereturn local predict = "xtbcfe_p"
	ereturn local ivar = "`ivar'" 
	ereturn local tvar = "`tvar'" 
	ereturn scalar N_g = `N' 
	ereturn scalar t_avg = `t_avg' 
	ereturn scalar t_min = `t_min' 
	ereturn scalar t_max = `t_max' 
	ereturn scalar conv = `conv' 
	ereturn scalar irr = `irr' 
    ereturn scalar k = `rhsvars1_ct' 
	ereturn matrix res_bcfe = res_bcfe
	// save the bootstap distribution coefficients only if requested
	if ((`boot_se'!=0)&(`boot_appr'==0)&(`conv'==1)&(`se_term'==0)&("`distribution'"!="")) {
		ereturn matrix dist_bcfe = dist_bcfe
	}

 // Display statistics
    display ""
    #delimit ;

		di _n in gr "Bootstrap corrected dynamic FE regression"
                 _col(49) in gr "Number of obs" _col(68) "="
                 _col(70) in ye %9.0f e(N) ;
        di in gr "Group variable : " in ye abbrev("`e(ivar)'",12) in gr
                 _col(49) "Number of groups" _col(68) "="
                 _col(70) in ye %9.0g e(N_g) _n ;
        if ("`resampling'" == "mcho") { ;
        	di in gr "Resample       :" _col(18) in gr %-25s "Monte Carlo homogeneous" 
        		 _col(49) in gr "Obs per group: min" _col(68) "="
                 _col(70) in ye %9.0g e(t_min) ;
		} ;
        else if ("`resampling'" == "mche") { ;
        	di in gr "Resample       :" _col(18) in gr %-25s "Monte Carlo heterogeneous" 
        		 _col(49) in gr "Obs per group: min" _col(68) "="
                 _col(70) in ye %9.0g e(t_min) ;
		} ;
		else if ("`resampling'" == "mcthe") { ;
        	di in gr "Resample       :" _col(18) in gr %-25s "Monte Carlo time-specific" 
        		 _col(49) in gr "Obs per group: min" _col(68) "="
                 _col(70) in ye %9.0g e(t_min) ;
		} ;
		else if ("`resampling'" == "iid") { ;
        	di in gr "Resample       :" _col(18) in gr %-25s "i.i.d." 
        		 _col(49) in gr "Obs per group: min" _col(68) "="
                 _col(70) in ye %9.0g e(t_min) ;
		} ;
		else if ("`resampling'" == "cshet") { ;
        	di in gr "Resample       :" _col(18) in gr %-25s "Cross-section heteroscedastic" 
        		 _col(49) in gr "Obs per group: min" _col(68) "="
                 _col(70) in ye %9.0g e(t_min) ;
		} ;
		else if ("`resampling'" == "cshet_r") { ;
        	di in gr "Resample       :" _col(18) in gr %-25s "random CS-heteroscedasticity" 
        		 _col(49) in gr "Obs per group: min" _col(68) "="
                 _col(70) in ye %9.0g e(t_min) ;
		} ;
		else if ("`resampling'" == "thet") { ;
        	di in gr "Resample       :" _col(18) in gr %-25s "Temporal Heteroscedasticity" 
        		 _col(49) in gr "Obs per group: min" _col(68) "="
                 _col(70) in ye %9.0g e(t_min) ;
		} ;
		else if ("`resampling'" == "thet_r") { ;
        	di in gr "Resample       :" _col(18) in gr %-25s "random T-Heteroscedasticity" 
        		 _col(49) in gr "Obs per group: min" _col(68) "="
                 _col(70) in ye %9.0g e(t_min) ;
		} ;
		else if ("`resampling'" == "csd") { ;
        	di in gr "Resample       :" _col(18) in gr %-25s "Cross-section dependence" 
        		 _col(49) in gr "Obs per group: min" _col(68) "="
                 _col(70) in ye %9.0g e(t_min) ;
		} ;
		else if ("`resampling'" == "wboot") { ;
        	di in gr "Resample       :" _col(18) in gr %-25s "Wild bootstrap" 
        		 _col(49) in gr "Obs per group: min" _col(68) "="
                 _col(70) in ye %9.0g e(t_min) ;
		} ;
		else if ("`resampling'" == "wboot_r") { ;
        	di in gr "Resample       :" _col(18) in gr %-25s "randomized Wild bootstrap" 
        		 _col(49) in gr "Obs per group: min" _col(68) "="
                 _col(70) in ye %9.0g e(t_min) ;
		} ;
        
        if ("`initialization'" == "det") { ;
        	di in gr "Initialization :" _col(18) in gr %-25s "Deterministic" 
        		 _col(64) in gr "avg" _col(68) "="
                 _col(70) in ye %9.1f e(t_avg) ;
		} ;
		else if ("`initialization'" == "bi") { ;
        	di in gr "Initialization :" _col(18) in gr %-25s "Burn-in" 
        		 _col(64) in gr "avg" _col(68) "="
                 _col(70) in ye %9.1f e(t_avg) ;
		} ;
		else if ("`initialization'" == "aho") { ;
        	di in gr "Initialization :" _col(18) in gr %-25s "Analytical homogeneous" 
        		 _col(64) in gr "avg" _col(68) "="
                 _col(70) in ye %9.1f e(t_avg) ;
		} ;
		else if ("`initialization'" == "ahe") { ;
        	di in gr "Initialization :" _col(18) in gr %-25s "Analytical heterogeneous" 
        		 _col(64) in gr "avg" _col(68) "="
                 _col(70) in ye %9.1f e(t_avg) ;
		} ;

        if ("`conv'" == "1") { ;
        	di in gr "Convergence    :" _col(18) in gr %-25s "Yes" 
        	     _col(64) in gr "max" _col(68) "="
                 _col(70) in ye %9.0g e(t_max) _n ;
		} ;
        else if ("`conv'" == "0"){ ;
        	di in gr "Convergence    :" _col(18) in gr %-25s "No" 
        	     _col(64) in gr "max" _col(68) "="
                 _col(70) in ye %9.0g e(t_max) _n ;
		} ;

   #delimit cr

 // Display coefficient table
    if (`boot_se'==0)&(`boot_appr'==0) {
 		estout matrix(Results, fmt(7 7 2 3 7 7)), collabels("Coefs." "Std. Err." "t" "P>|t|" "[`level'% Conf." "Interval]") ///
 		title("Dependent variable : `depvar'") modelwidth(10)
    }
   	else if (`boot_se'!=0)&(`boot_appr'==0) {
 		estout matrix(Results, fmt(7 7 2 3 7 7)), collabels("Coefs." "Std. Err." "t" "P>|t|" "[`level'% Conf." "Interval]") ///
 		title("Dependent variable : `depvar'") modelwidth(10)
    }
    else if (`boot_se'==0)&(`boot_appr'!=0) {
 		estout matrix(Results, fmt(7 7 2 3 7 7)), collabels("Coefs." "Std. Err." "t" "P>|t|" "[`level'% Conf." "Interval]") ///
 		title("Dependent variable : `depvar'") modelwidth(10)
    } 

// notes
    display as text "Notes:"
  	if `td'==1 { // User included time dummies in varlist
    	di as text "- Time dummy `varlist_diff' included by user has been discarded"
    }
  	else if `td'>1 { // User included time dummies in varlist
    	di as text "- Time dummies `varlist_diff' included by user have been discarded"
  	}
  	if `irr'>0 { 
    	di as text "- Removed `irr' cross-section(s) due to lack of observations"
    }	
    if (`conv' == 0) {
    	di as text "- WARNING: bootstrap algorithm did not converge. Estimates may be"
    	di as text "           unreliable and are unsuitable for the computation of"
    	di as text "           standard errors. Consider an alternative lag length." 
    }
    
    if ((`boot_se'==0)&(`boot_appr'==0)|(`conv'==0)) {
    	if (`conv'!=0) {
			di as text "- No standard errors computed" 
		}	
    }
   	else if (`boot_se'==101)&(`boot_appr'==0) {		
		if (`se_term'==0) {
			di as text "- Bootstrapped standard errors" 
			di as text "- Confidence bounds for the t- distribution calculated with bootstrapped"
			di as text "  standard errors "
		}
		else {
			di as text "- Too many non-convergence issues for standard error estimation. Algorithm "
			di as text "  was terminated. "			
		}		
    }
    else if (`boot_se'!=0)&(`boot_se'!=101)&(`boot_appr'==0) {		
		if (`se_term'==0) { 
			di as text "- Bootstrapped standard errors"
			di as text "- Bootstrap `level'% (percentile-based) confidence intervals"
		}
		else {
			di as text "- Bootstrap confidence intervals and standard errors failed (non-convergence)"			
		}		
    }
    else if (`boot_se'==0)&(`boot_appr'>0) {
    		di as text "- Standard errors approximated with the bootstrap LSDV distribution " 		
    }

    if (`PNP'==1)&(`boot_appr'==0)&(`conv'!=0)&(`boot_se'!=0)&(`se_term'==0)  {
    		di as text "- Inference performed with parametric bootstrap "
    }
    else if (`PNP'==0)&(`boot_appr'==0)&(`conv'!=0)&(`boot_se'!=0)&(`se_term'==0)  {
    		di as text "- Inference performed with non-parametric bootstrap "
    }
       

end


// ==============================================================
// ====2/ STATA SUBROUTINES
// ==============================================================
// None	
	
	
// ==============================================================
// ====3/ MATA SUBROUTINES
// ==============================================================
//version 11.0
mata:

// **************************
// *** Mata BCFE mata routine
// **************************
void bcfe_ub(string scalar vars,			///
		numeric scalar N,					///
 		numeric scalar lags,				///
 		numeric scalar criterion,			///
 		numeric scalar resample,			/// 					
 		numeric scalar ini,					///
 		numeric scalar bciters,				/// 					
		numeric scalar boot_se,				///
		numeric scalar boot_appr,			///
		numeric scalar level,				///
 		numeric scalar inf_se_iters,		///
 		numeric scalar inf_appr_iters,		///
 		numeric scalar ar,					///
 		numeric scalar PNP,					///
 		numeric scalar TE)



{	
 // Declarations
	real matrix 	M, x, x0, M_F, xx, xk, V_x, res_BCFE, b_BCFE, V, conf, res_FE, b_FE, TT, indexTN, irregular, xi, FE_perc, dist_BCFE
	real colvector  y, yk, v
	real scalar		nobs, k, T, i, h, j, ii, t, res_b, diff, crit, Ti, Bi, Ei, conv, l, t_min, t_max, t_avg, terminated, given_r, n_dums, dum

 // Read in variables
	M = xx = y = .
	st_view(M, ., tokens(vars))
	st_subview(y, M, ., 1)
	if (ar!=1) {
		st_subview(xx, M, ., (2\.))
	}
		
 // Reading global sample size
 	nobs=rows(y)
 	if (ar!=1) k=cols(xx)
	else k=0;
	T=nobs/N 
	
 // Reshape y and x
 	yk = y 
 	y = rowshape(yk,N)' //Reshape y to T*N matrix
 	if (ar!=1) {
		xk = J(T,N*k,0)
 		for (i=1; i<=k; i++) { //Reshape x to Tx(N*k) matrix
 			xk[.,(i-1)*N+1::i*N] = rowshape(xx[.,i],N)'
 		}
  		xx = xk
	}	
 	
 // Adding lagged dependent variable to matrix x		
	k=k+lags
	if (ar!=1) {
		x = J(T,N*k,.)
		for (l=1; l<=lags; l++) {
			x[l+1::T,N*(l-1)+1::l*N] = y[1::T-l,.]
    	}
  		x[.,lags*N+1::N*k] = xx
  	}
  	else {
  		x = J(T,N*k,.)
		for (l=1; l<=lags; l++) {
			x[l+1::T,N*(l-1)+1::l*N] = y[1::T-l,.]
    	}
  	}
  	
// Reading individual sample size and constructing bootstrap index for resampling scheme 20
	TT = J(3,N,.)
	indexTN = J(1,2,.)
	Ti_det(y,x,N,TT,indexTN,irregular)
	if (cols(irregular)>1) {
		v = J(1,cols(irregular),1)
		v[1,1] = 0
		irregular = select(irregular,v)
		v = J(1,N,1)
		v[1,irregular] = J(1,cols(irregular),0)
		y = select(y,v)
		v = mm_repeat(v,1,k)
		x = select(x,v)
		N = N - cols(irregular)
		irregular = cols(irregular)
	}

	nobs = sum(TT[1,.])
	t_min = min(TT[1,.])
	t_max = max(TT[1,.])
	t_avg = round(mean(TT[1,.]'),0.01)
	

	if (TE==1) {
		n_dums = max(TT[1,.])-1
		x = (x , J(rows(x),n_dums*N,0) )		
		for ( dum = 1 ; dum<=n_dums; dum++) {
			t = max(TT[3,.]) - n_dums + dum
			x[t,N*(k+dum-1)+1::N*(k+dum)] = J(1,N,1)
		}
		k = k + n_dums
	}	
	
	if (nobs<k+N) {
		errprintf("The specified model is (over-)saturated. Error terms needed for the bootstrap") 
		""
		errprintf("cannot be obtained.")
		""
		exit(error(3498))
	}

	if (t_max!=t_min & resample==31) {		
		errprintf("Resampling identically over cross-sections is not available for unbalanced data.")		
		""
		errprintf("Balance the data or select an alternative resampling scheme.")
		""
		exit(error(3498))
	}
	if (t_max!=t_min & resample==41) {		
		errprintf("Randomized wild bootstrap is not available for unbalanced data.")		
		""
		errprintf("Balance the data or select an alternative resampling scheme.")
		""
		exit(error(3498))
	}
	
 	// Demeaning the data 	
		if (ar!=1) {
			x0 = J(N,(k-lags)*lags,0)
		}
		else {
			x0 = J(N,1,0)
		}
 	for (i=1; i<=N; i++) { 
    	Ti=TT[1,i]
    	Bi=TT[2,i]
    	Ei=TT[3,i]
	 	
		xi = J(T,k,.)

	 // Save demeaned initial values for x
		for (j=1; j<=k; j++) { 
			xi[.,j] = x[.,(j-1)*N+i]
		}	
		if (ar!=1) {
			for (j=1; j<=k-lags; j++) { 				
				for (l=1; l<=lags; l++) { 
					if (hasmissing(xi[Bi-l,lags+j])==0) { 
						x0[i,(k-lags)*(l-1)+j]=xi[Bi-l,lags+j]-mean(xi[Bi::Ei,lags+j])
					}
					else {
						x0[i,J(1,lags-l+1,j)+J(1,lags-l+1,k-lags):*J(1,1,0::lags-l)']=J(1,lags-l+1,xi[Bi-l+1,lags+j]-mean(xi[Bi::Ei,lags+j]))
						break
					}
				}	
			}
		}	

     // Demean data according to individual sample size
    	M_F=I(Ti):-(1/Ti)
    	y[Bi::Ei,i]=M_F*y[Bi::Ei,i]
 		for (ii=1; ii<=k; ii++) { 
        	xi[Bi::Ei,ii]=M_F*xi[Bi::Ei,ii] 
    	}
  	 	
  	 // Remove values that will not be used
   	 	y[1::Bi-1,i]=J(Bi-1,1,.)
   	 	xi[1::Bi-1,.]=J(Bi-1,k,.) 	 	
   	 	if (Ei<rows(y)) {
   	 		y[Ei+1::rows(y),i] = J(rows(y)-Ei,1,.)
   	 		xi[Ei+1::rows(y),.] = J(rows(y)-Ei,k,.)
   	 	} 	
  	 	for (ii=1; ii<=k; ii++) { 
			x[.,(ii-1)*N+i] = xi[.,ii] 
  		}
  	}
	
 // Initialising procedure with FE estimation
	b_FE = res_FE = .	
	fe(y,x,N,TT,b_FE,res_FE)
	
 // Bootstrap-based bias correction
	uniformseed(1000)
	b_BCFE = res_BCFE = V_x =.
	if ((boot_se!=0)&(PNP==1)) inf_appr_iters = inf_se_iters
	bootstrap(y,x,x0,N,b_FE,res_FE,bciters,criterion,resample,ini,boot_appr,inf_appr_iters,lags,TT,indexTN,ar,0,PNP,b_BCFE,res_BCFE,V_x,conv,given_r,FE_perc)	

 // Inference
 	terminated = 0
 	dist_BCFE = J(1,k,.)
	if ((boot_se!=0)&(conv!=0)) {
    	inference(y,x,x0,N,b_BCFE,res_BCFE,bciters,criterion,resample,ini,inf_se_iters,boot_se,TT,indexTN,ar,lags,given_r,PNP,FE_perc,V,conf,dist_BCFE) 
    	if (hasmissing(V)) {
    		terminated = 1
    		V = J(k,k,0)
    		conf = J(k,2,0)
    	}
	}
	if ((boot_appr!=0)&(conv!=0)) {
		   	V = V_x 
	}	
	if (((boot_appr==0)&(boot_se==0))|(conv==0)) {
		V = J(k,k,0)
	}	

 // Save the mata matrices as Stata matrices
	st_eclear()
	st_matrix("r(b)", b_BCFE')
	st_matrix("r(e)", res_BCFE)
	st_matrix("r(V)", V)
	st_matrix("r(dist_bcfe)", dist_BCFE)
	st_numscalar("r(conv)", conv)
	st_numscalar("r(N)", N)
	st_numscalar("r(nobs)", nobs)
	st_matrix("r(conf)", conf)
	st_numscalar("r(irr)", irregular)
	st_numscalar("r(t_min)", t_min)
	st_numscalar("r(t_max)", t_max)
	st_numscalar("r(t_avg)", t_avg)
	st_numscalar("r(se_terminate)", terminated)
	st_numscalar("r(T)", T)
	st_numscalar("r(begin_year)", max(TT[3,.])-n_dums+1 )
	st_numscalar("r(end_year)", max(TT[3,.]))	
}	




// ==============================================================
// ====4/ MATA SUB-SUBROUTINES
// ==============================================================

// **************************
// *** Mata FE routine
// **************************
void fe(real matrix y, 			///
		real matrix x,			///
		numeric scalar N,		///
		real matrix TT,         ///
		b_FE,					///
		res_FE)
{	
 // Declarations
	real matrix 	M_F, xi, denom, xrs
	real colvector  F, yi, num, yrs
	real scalar		nobs, k, T, i, Ti, Bi, Ei, obs
	
 // Dimensions of the data
	k=cols(x)/N
	T=rows(x)
	
 // Reshape
    yrs = vec(y) 
 	xrs = J(N*T,k,0)
 	for (i=1; i<=k; i++) {
 		xrs[.,i] = vec(x[.,(i-1)*N+1::i*N])
 	} 
	
 // Demeaning procedure
	num = J(k,1,0)
	denom = J(k,k,0)
	for (i=1; i<=N; i++) {
		Ti = TT[1,i]
		Bi = TT[2,i]
		Ei = TT[3,i]
		M_F = I(Ti):-(1/Ti)
  	    xi = xrs[(i-1)*T+Bi::i*T-(T-Ei),.]
		yi = yrs[(i-1)*T+Bi::i*T-(T-Ei),.]
    	num = num + xi'*M_F*yi
    	denom = denom + xi'*M_F*xi
    }
 // Obtain FE coefficients	
	b_FE = (invsym(denom)*num)
	obs = sum(TT[1,.])
    res_FE = (yrs - xrs*b_FE)*sqrt(obs/(obs-k-N)) 
    res_FE = rowshape(res_FE,N)'
}




// **************************
// *** Bootstrap procedure
// **************************
void bootstrap(real matrix y, 				/// 
			   real matrix x,				///
			   real matrix x0,				///
			   numeric scalar N,		 	///
 			   real matrix b_FE,			///
 			   real matrix res_FE,			///
 			   numeric scalar bciters,		/// 
 			   numeric scalar criterion,    ///					
 			   numeric scalar resample,		/// 					
 			   numeric scalar ini,			///
			   numeric scalar boot_appr,	///
 			   numeric scalar inf_appr_iters,	///
 			   numeric scalar lags,			///
 			   real matrix TT,				///
 			   real matrix indexTN,			/// 
 			   numeric scalar ar,			///	
 			   numeric scalar given,		///
 			   numeric scalar PNP,			///				
			   b_BCFE,						///
			   res_BCFE,					///
			   V_x,							///
			   conv,						///
			   given_r,						///
			   coefs_bootstrap)			

{
 // Declarations
	real matrix 	x_b, temp, b_BCFE_vect, FE_perc
	real colvector  y_b, coefs_b, coefs_bootstrap_mean, b_BCFE_old
	real scalar		nobs, k, T, i, h, j, t, res_b, diff, crit1, crit2, scale
	
 // Dimensions of the data
	k=cols(x)/N
	T=rows(x)
	
 // Bootstrap-based bias correction
 	given_r = 0
 	scale = 10000*max(abs(y))  
	coefs_bootstrap = J(bciters,k,0)
	b_BCFE = b_FE 
	res_BCFE = res_FE
	V_x = J(k,2,0) 
	b_BCFE_vect = J(k,50,0)
	for (h=1; h<=50; h++) {	   
    	for (j=1; j<=bciters; j++) {
    		y_b = x_b = .
        	generate(y,x,x0,N,b_BCFE,res_BCFE,resample,ini,lags,TT,indexTN,ar,y_b,x_b) 
        	if (min(abs(y_b))>scale & given==0 & given_r==0) {
        		if (ini!=1) {	
					errprintf("WARNING: Generated initial conditions are far beyond the scale of the original data. ")
				}
				else {
					errprintf("WARNING: The generated data is far beyond the scale of the original dataset. ")
				}
				""
				errprintf("         The bootstrap algorithm may return errors or give unreliable results. Avoid this by" )
				""
				if (ini!=1) {
					errprintf("         choosing an alternative initialization scheme or a more parsimonious model.")
				}
				else {
					errprintf("         specifying a more parsimonious model. Note that the data must also be stationary.")
				}
				""				 				
				given_r = 1
			}
        	coefs_b = res_b = .
        	fe(y_b,x_b,N,TT,coefs_b,res_b) 
        	coefs_bootstrap[j,.] = coefs_b'
    	}
   		coefs_bootstrap_mean = mean(coefs_bootstrap) 
     	b_BCFE_old = b_BCFE
    	diff = b_BCFE - coefs_bootstrap_mean'
    	b_BCFE = b_FE + diff
    	b_BCFE_vect[.,h] = b_BCFE
     	res_BCFE = res_calc(y,x,N,b_BCFE,TT)
    	crit1 = abs(b_BCFE_old[1::lags,1] - b_BCFE[1::lags,1])
 		if (sum(abs(crit1))<criterion*lags) break
 		
 		if (h>8) {
 			crit2 = abs(mean(b_BCFE_vect[1::lags,h-3::h]')-mean(b_BCFE_vect[1::lags,h-7::h-4]'))
 			b_BCFE = mean(b_BCFE_vect[.,h-4::h]')'
 			if (sum(crit2)<criterion*lags) break
 		}
 		

	}
	// convergence diagnostics
	conv = 1
	if (h==51) {
		conv = 0	
	}
	// percentiles for inference or approximate standard errors
	if ((boot_appr!=0)|(PNP==1)) { 
		coefs_bootstrap = J(inf_appr_iters,k,0) 
    	for (j=1; j<=inf_appr_iters; j++) {   		
        	generate(y,x,x0,N,b_BCFE,res_BCFE,resample,ini,lags,TT,indexTN,ar,y_b,x_b) 
        	coefs_b = res_b = .
        	fe(y_b,x_b,N,TT,coefs_b,res_b) 
        	coefs_bootstrap[j,.] = coefs_b'
    	}     	
    	if (boot_appr!=0) V_x = variance(coefs_bootstrap)   
	}
}



// *********************************
// *** Generating bootstrap samples
// *********************************
void generate(real matrix y, 					/// 
			  real matrix x,					///
			  real matrix x0,					///
			  numeric scalar N,		 			///
 			  real matrix coefs,	 			///
 			  real matrix resid,				///
 			  numeric scalar resample,			/// 					
 			  numeric scalar ini,				///
 			  numeric scalar lags,				///
 			  real matrix TT,          			///
 			  real matrix indexTN,				///
 			  numeric scalar ar,				///
 			  y_b,								///
 			  x_b)	
{	
 // Declarations
	real scalar	 k, T, i, h, l, j, t, index, indexi, index_ini, res_b, burn_in, b, temp, y_star, x0_comp, Ba, Bi, Ei, obs, Ti, indexT, indexN, indexTi, indexNi, blocks
	real rowvector	var_res, res_bi, var_y_ini, s, per
	real matrix y0_b, x_comp, yl_b, tmp, var_resid, indic, r_nums, r_nums_in2, cholmt, range_t, ind, s_t, res_block, w_err, bi_var, burn_times
 		
 // Set burn-in when required
 	if (ini == 2) {
 		burn_in = 25
 		if (abs(sum(coefs[1::lags])>0.75)) burn_in = 50
 		if (abs(sum(coefs[1::lags])>0.90)) burn_in = 100
 		if (abs(sum(coefs[1::lags])>0.95)) burn_in = 250
    } 

 // Dimensions of the data
	k=cols(x)/N
	T=rows(x)
	
 // Constructing bootstrap indices according to resampling scheme  
if (resample==10) {
     var_res = mm_repeat(mean(mean(resid:^2)'),1,N)
   	 if (hasmissing(var_res)) {
     	for (i=1; i<=N; i++) {
    		var_res[1,i] = mean(resid[.,i]:^2)
    	}    	    	
    	var_res = mm_repeat(mean(var_res'),1,N)
     }
}
else if (resample==11) {      
    var_res = mean(resid:^2)
   	 if (hasmissing(var_res)) {
     	for (i=1; i<=N; i++) {
    		var_res[1,i] = mean(resid[.,i]:^2)
    	}
     } 
}
else if (resample==12) {     
     var_res = mean(resid':^2)'
   	 if (hasmissing(var_res)) {
     	for (t=1; t<=T; t++) {
    		var_res[t,1] = mean(resid[t,.]':^2)
    	}
     }
}
else if (resample==20) {
   obs = sum(TT[1,.])
   index = round(runiform(T,N)*obs:+0.5)    
    if (ini==2) {
        indexi = round(runiform(burn_in,N)*obs:+0.5)  
    }
}
else if (resample==30 | resample==35) {
    index = J(T,N,.)
    if (ini==2) {
    	indexi = J(burn_in,N,.)
    }
    Ba = 1
    for (i=1; i<=N; i++) {
    	Ti = TT[1,i]
    	index[.,i] = round(runiform(T,1)*Ti:+Ba-0.5)
    	if (ini==2) {
    		indexi[.,i] = round(runiform(burn_in,1)*Ti:+Ba-0.5)
    	}
    	Ba = Ba + Ti
    }
    if (resample==35) {
    	per = round(runiform(1,N)*(N-1):+1) 
        index = index[.,per] 
        if (ini==2) {
        	indexi = indexi[.,per] 
        }    
    } 
}
else if (resample==31) {
	Ti = TT[1,1] 
	index = J(T,N,.)
	if (ini==2) {
    	indexi = J(burn_in,N,.)
    	r_nums_in2 = round(runiform(burn_in,1)*Ti:+0.5)
    }
    r_nums = round(runiform(T,1)*Ti:+0.5)
	for (i=1; i<=N; i++) {    	
    	index[.,i] = r_nums:+Ti*(i-1)
    	if (ini==2) {
    		indexi[.,i] = r_nums_in2:+Ti*(i-1)
    	}
    } 
}
else if (resample==50) {
	index = J(T,N,1)
	range_t = (min(TT[2,.])::max(TT[3,.]))'
	for (t=1; t<=cols(range_t); t++) {
		ind = mm_which(indexTN[.,1]:==range_t[1,t])
		index[range_t[1,t],.] = ind[ round(runiform(1,N)*rows(ind):+0.5) , 1]'		
	}
	if (ini==2) {
		if (cols(range_t)>=burn_in) burn_times = range_t[1,1::burn_in]'
		else if (cols(range_t)<burn_in) {
			blocks = floor(burn_in/cols(range_t))
			if ( burn_in - blocks*cols(range_t) > 0 ) burn_times = ( range_t[1,1::(burn_in - blocks*cols(range_t))]' \ mm_repeat(range_t',blocks) )
			else burn_times = mm_repeat(range_t',blocks)
		}
		indexi = J(burn_in,N,.)
		for (t=1; t<=burn_in; t++) {
			ind = mm_which(indexTN[.,1]:==burn_times[t,1])
			indexi[t,.] = ind[ round(runiform(1,N)*rows(ind):+0.5) , 1]'
		}
	}
}
else if (resample==51) {
	index = J(T,N,.)
	range_t = (min(TT[2,.])::max(TT[3,.]))'
	s_t = range_t[1,round(runiform(1,T)*cols(range_t):+0.5)]
	for (t=1; t<=T; t++) {
		ind = mm_which(indexTN[.,1]:==s_t[1,t])
		index[t,.] = ind[ round(runiform(1,N)*rows(ind):+0.5) , 1]'		
	}
	if (ini==2) {
		indexi = J(burn_in,N,.)
		s_t = range_t[1,round(runiform(1,burn_in)*cols(range_t):+0.5)]
		for (t=1; t<=burn_in; t++) {
			ind = mm_which(indexTN[.,1]:==s_t[1,t])
			indexi[t,.] = ind[ round(runiform(1,N)*rows(ind):+0.5) , 1]'	
		}
	}
}    

 // Initializing data  
if (ini==1) {
 	y0_b = J(1,N*lags,0) 
 	for (i=1; i<=N; i++) {
 		for (l=1; l<=lags; l++) {  
 	 		y0_b[1,N*(l-1)+i] = x[TT[2,i],N*(l-1)+i]
 	 	}
	}
}
else if (ini==2) {
	temp = coefs[1::lags]
 	y0_b = J(1,N*lags,0)
    res_bi = J(1,N,0)    
    if (abs(sum(coefs[1::lags]))>=1) {
    	if (sum(coefs[1::lags])>=1) {
    		temp = temp :- (sum(temp) - 1 + 0.02)/lags
    	}
    	else if (sum(coefs[1::lags])<=-1) {
    		temp = temp :- (sum(temp) + 1 - 0.02)/lags
    	}
    }
    if (ar!=1) { 
    	x0_comp = coefs[lags+1::k]'*x0[.,1::(k-lags)]'	    
    }
    else {
    	x0_comp = J(1,N,0) 	    
    }
    if ( resample==12 ) {
    	res_block = var_res[min(TT[2,.])::max(TT[3,.]),1]
    	bi_var = J(burn_in,1,.)
    	if ( rows(res_block)>=burn_in ) bi_var = res_block[1::burn_in,1]
    	else if (rows(res_block)<burn_in) {
    		blocks = floor(burn_in/rows(res_block))
    		if (burn_in - blocks*rows(res_block)>0) bi_var = (res_block[ 1::(burn_in - blocks*rows(res_block)) , 1] \ mm_repeat(res_block,blocks) )
    		else bi_var = mm_repeat(res_block,blocks)
    	}
    }
    if ( resample==40 | resample==41 ) {
    	res_block = J(burn_in,N,.)
    	per = (1::N)'
    	if (resample==41) per = round( uniform(1,N)*N :+ 0.5 )
    	for (i=1; i<=N; i++) {
    		Ti = TT[1,i] 
    		w_err = J(Ti,1,.)
    		w_err = resid[TT[2,i]::TT[3,i],per[1,i]]
    		if (Ti>=burn_in) res_block[.,i] = w_err[1::burn_in,1] 
    		else if (burn_in>Ti) {
    			blocks = floor(burn_in/Ti)
    			if (burn_in - blocks*Ti>0) res_block[.,i] = (w_err[ 1::(burn_in - blocks*Ti) , 1] \ mm_repeat(w_err,blocks) )
    			else res_block[.,i] = mm_repeat(w_err,blocks)
    		}
    	}
    }	    
    for (b=1; b<=burn_in; b++) {  
    	if (b>burn_in-lags & lags>1 & ar!=1) x0_comp = coefs[lags+1::k]'*x0[.,(k-lags)*((burn_in-b+1)-1)+1::((k-lags)*(burn_in-b+1))]'     
        if (resample==10 | resample==11) res_bi = invnormal(uniform(1,N)):*sqrt(var_res)	
       	else if (resample==12) res_bi = invnormal(uniform(1,N)):*sqrt(bi_var[b,1])	      	
       	else if (resample==40 | resample==41) res_bi = res_block[b,.]:*(mm_rbinomial(mm_repeat(1,N)',0.5)*2:-1)
        else {
            for (i=1; i<=N; i++) {
            	res_bi[1,i] = resid[indexTN[indexi[b,i],1],indexTN[indexi[b,i],2]]
            }      
        }
        tmp = y0_b[1,1::N]    
		y0_b[1,1::N] = temp[1::lags,1]'*colshape(y0_b[1,1::N*lags],N) + x0_comp + res_bi[1,.]       
        if (lags>1) {
        	if (lags>2) {
        		y0_b[1,N*2+1::N*lags] = y0_b[1,N+1::N*(lags-1)] 
        	}
        y0_b[1,N+1::2*N] = tmp      		        		         		         	
        }
    }
}


else if (ini==31 | ini==41) { 
	y0_b = J(1,N*lags,0)
   	 if (sum(coefs[1::lags])^2>0.99) {
   	 	temp=0.99
   	 }
   	 else {
   	 	temp=sum(coefs[1::lags]) 
   	 }   
    	if (ini==31) {
    		if (ar!=1) {
    			y_star = y - mult(x[.,(N*lags+1)::k*N],(coefs[lags+1::k]:/(1-temp)),N)
    		}
    		else {
    			y_star = y
    		}
    		var_y_ini = cov_pos(y_star,N,lags,ini,TT)
    	}
    	else if (ini==41) { 
    		if (ar!=1) {
    			y_star = y - mult(x[.,(N*lags+1)::k*N],(coefs[lags+1::k]:/(1-temp)),N)
    		}
    		else {
    			y_star = y
    		}
    		var_y_ini = cov_pos(y_star,N,lags,ini,TT)
    	}    

 // construct initial condition
 	if (ini==31) {  
 		if (lags==1) cholmt = sqrt(var_y_ini[1,1]) 
 		else cholmt = cholesky(var_y_ini);	
	}	
	for (i=1; i<=N; i++) {		
		if (ini==41) { 
			if (lags==1) cholmt = sqrt(var_y_ini[i,1])				
			else cholmt = cholesky(var_y_ini[lags*(i-1)+1::i*lags,.]);
		}
		if (ar!=1) {
			y0_b[1,lags*(i-1)+1::lags*i] = mm_repeat((coefs[lags+1::k]:/(1-temp))'*x0[i,1::(k-lags)]',1,lags) + (cholmt*invnormal(uniform(lags,1)))'
		}
		else {
			y0_b[1,lags*(i-1)+1::lags*i] = (cholmt*invnormal(uniform(lags,1)))'		
		}
	}   
}

// Constructing data
res_b = J(1,N,0)
y_b = J(T,N,.)
yl_b = J(T+1,N*lags,.) 
x_b = x
x_comp = J(T,N,0) 
if (ar!=1) x_comp = mult(x[.,lags*N+1::N*k],coefs[lags+1::k],N)  
if ((resample==41)&(ini!=2)) per = J(1,N,.); per = round( uniform(1,N)*N :+ 0.5 ) 
for (i=1; i<=N; i++) {
	Bi = TT[2,i]
    Ei = TT[3,i]
	s = ((0::lags-1):*N:+i)'      
    yl_b[Bi,s] = y0_b[1,s]
    for (t=Bi; t<=Ei; t++) {   
    	// draw or resample errors depending on the chosen scheme
    	if (resample==10 | resample==11) res_b = invnormal(uniform(1,1))*sqrt(var_res[1,i])
        else if (resample==12) res_b = invnormal(uniform(1,1))*sqrt(var_res[t,1])       
		else if (resample==40) res_b = resid[t,i]*(mm_rbinomial(1,0.5)*2-1)	                  	 		
		else if (resample==41) res_b = resid[t,per[1,i]]*(mm_rbinomial(1,0.5)*2-1)  						 
		else res_b = resid[indexTN[index[t,i],1],indexTN[index[t,i],2]] ;
		       
    	y_b[t,i] = yl_b[t,s]*coefs[1::lags] + x_comp[t,i] + res_b
    	yl_b[t+1,i] = y_b[t,i]  
    	if (lags>1) {
			yl_b[t+1,s[2::lags]] = yl_b[t,s[1::lags-1]]        
		}
    }
}
x_b[1::T,1::N*lags] = yl_b[1::T,1::N*lags] 
}


// *******************************************
// *** Inference: calculating standard errors
// *******************************************
void inference(real matrix y, 			 		/// 
			  	       real matrix x,			 		///
			  	       real matrix x0,			 		///
			 	  	   numeric scalar N,		 		///
 			  		   real matrix coefs,	 	 		///
 			  		   real matrix resid,		 		///
 			  		   numeric scalar bciters,  		/// 
 			  		   numeric scalar criterion,        ///					
 			  		   numeric scalar resample,  		/// 					
 			  	   	   numeric scalar ini,   			///
 			  		   numeric scalar inf_se_iters,  	///
 			  		   numeric scalar boot_se,			///
 			  		   real matrix TT,			 		///
 			  		   real matrix indexTN,		 		///
 			  		   numeric scalar ar,		 		///
 			  		   numeric scalar lags,				///
 			  		   numeric scalar given,			///
 			  		   numeric scalar PNP,				///
 			  		   real matrix FE_perc,				///
 			  		   V,								///
 			  		   conf,							///
 			  		   coefs_distr_BCFE)					
{	
 // Declarations
	real matrix 	x_b, coefs_distr_FE, res_FE, res_BCFE, V_x, empt1, empt2, empt3, index, y_b, x0_b, TT_b, indexTN_b, irreg_b, temp
	real colvector	b_FE, b_BCFE
	real scalar		nobs, k, T, j, i, conv, no_save, terminate, given_r, w
 	
 // Dimensions of the data
	k=cols(x)/N
	T=rows(x)
	coefs_distr_FE = J(inf_se_iters,k,.)
	coefs_distr_BCFE = J(inf_se_iters,k,.)
	no_save = 0
	terminate = 0
	conf = J(k,2,.)
	w = 0
    j=1
    while (j<inf_se_iters+1) {
    	if (PNP==1) {
    		b_FE = coefs_distr_FE[j,.] = FE_perc[j,.]
    		res_FE = res_calc(y,x,N,b_FE',TT)
    		b_BCFE = empt1 = empt2 = empt3 = given_r = conv = .	
    		bootstrap(y,x,x0,N,b_FE',res_FE,bciters,criterion,resample,ini,0,0,lags,TT,indexTN,ar,given,0,b_BCFE,empt1,empt2,conv,given_r,empt3)
    		if (given_r==1) given=1     
    	}
    	else if (PNP==0) {
    		y_b = J(T,N,.)
    		x_b = J(T,N*k,.)
    		if (ar!=1) {
    			x0_b = J(N,(k-lags)*lags,.)
    		}
    		else {
    			x0_b = x0
    		}
		
    		for (i=1; i<=N; i++) {
    			index = round(uniform(1,1)*N+0.5)
    			y_b[.,i] = y[.,index]
    			x_b[.,J(1,1,0::k-1):*N:+i] = x[.,J(1,1,0::k-1):*N:+index]
    			if (ar!=1) {
    				x0_b[i,.] = x0[index,.]
    			}	
    		}
    		TT_b = J(3,N,.)
			indexTN_b = J(1,2,.)
    		Ti_det(y_b,x_b,N,TT_b,indexTN_b,irreg_b)
    		fe(y_b,x_b,N,TT_b,b_FE,res_FE)
    		coefs_distr_FE[j,.] = b_FE'
    		b_BCFE = empt1 = empt2 = empt3 = given_r = conv = .
        	bootstrap(y_b,x_b,x0_b,N,b_FE,res_FE,bciters,criterion,resample,ini,0,0,lags,TT_b,indexTN_b,ar,given,0,b_BCFE,empt1,empt2,conv,given_r,empt3)
        	if (given_r==1) given=1    
        }
        if (conv==0) {       
        	no_save = no_save + 1
        	if (no_save>inf_se_iters*2) {
        		terminate = 1
        		V = J(cols(coefs_distr_BCFE),cols(coefs_distr_BCFE),.)
        		break
        	}
        	continue
        }    
        coefs_distr_BCFE[j,.] = b_BCFE'
        j = j + 1
        
        if ((j>inf_se_iters*0.25)&(w==0)) {
        	display("25% of inference iterations performed...")
        	w = 1
        }
        if ((j>inf_se_iters*0.5)&(w==1)) {
        	display("50% of inference iterations performed...")
        	w = 2
        }
        if ((j>inf_se_iters*0.75)&(w==2)) {
        	display("75% of inference iterations performed...")
        	w = 3
        }
        if ((j>inf_se_iters*0.95)&(w==3)) {
        	display("95% of inference iterations performed...")
        	w = 4
        }
        
     }
    if (terminate!=1) {   	
		V = variance(coefs_distr_BCFE)
		if (boot_se!=101) {
			for (j=1; j<=k; j++) {
				temp = sort(coefs_distr_BCFE,j)
				conf[j,1] = temp[round((boot_se/200)*inf_se_iters),j]
				conf[j,2] = temp[round((1-boot_se/200)*inf_se_iters),j]
			}
		}	
	}
}

// **************************
// *** Matrix multiplication
// **************************
// Multiplies T*Nk matrix A with vector B
real matrix mult(real matrix A, 		 /// 
			     real matrix B,			 ///
			 	 numeric scalar N)			
{
 // Declarations
	real matrix 	AA, result
	real scalar		k, T, i
 	
 // Multiplication
	k=cols(A)/N
	T=rows(A)

 	AA = J(N*T,k,0)
 	for (i=1; i<=k; i++) { 
 		AA[.,i] = vec(A[.,(i-1)*N+1::i*N])
 	} 
    result = AA*B
    result = rowshape(result,N)'

 // Return result
	return(result)
}


// **************************
// *** Function to calculate rescaled residuals
// **************************
real matrix res_calc(real matrix y, 				/// 
			  real matrix x,			///
			  numeric scalar N,			///
			  real matrix coef,			///
			  real matrix TT)

{
 // Declarations
	real matrix 	xi, yi, res
	real scalar		Bi, Ei, Ti, i, j, k, T, obs

 // Dimensions of the data
	k=cols(x)/N
	T=rows(x)
	res = J(T,N,.)
	for (i=1; i<=N; i++) {
    	Ti=TT[1,i]
    	Bi=TT[2,i]
    	Ei=TT[3,i]
    	xi = J(Ti,k,0)
  	    for (j=1; j<=k; j++) {
  	    	xi[.,j] = x[Bi::Ei,(j-1)*N+i] 
    	}
    	yi=y[Bi::Ei,i]
    	res[Bi::Ei,i] = yi-xi*coef[.,1]
	}
	obs = sum(TT[1,.])
	res = res:*sqrt(obs/(obs-k-N))
	return(res)
}


// **************************************************
// *** Function to determine individual sample size
// **************************************************
void Ti_det(real matrix y, 				/// 
			  real matrix x,			///
			  numeric scalar N,			///
			  real matrix TT,			///
			  real matrix indexTN,		///
			  real matrix irregular)

{
 // Declarations
	real matrix 	xrs, xi, yi, Xi, v
	real scalar		Bi, Ei, Ti, i, j, k, T, no_obs, b, splitv, splits, ind, left

 // Dimensions of the data
	k=cols(x)/N
	T=rows(x)

 // initiate irregular vector (also used to remove CS without observations)
    irregular = 0

 // Reshape 
 	xrs = J(N*T,k,0)
 	for (i=1; i<=k; i++) {
 		xrs[.,i] = vec(x[.,(i-1)*N+1::i*N])
 	} 
	
	for (i=1; i<=N; i++) {
  	    xi = xrs[(i-1)*T+1::i*T,.]
   		yi = y[.,i]
    	Xi = (yi,xi)

    	// Start date
    	Bi=1
    	j=1
    	no_obs = 0
    	while (j==1) {                                           
   	    	if (hasmissing(Xi[1,.])==1) {
   	    		if (rows(Xi)==1) {
   	    			j = 0
   	    			no_obs = 1
   	    			Bi = .
   	    		}
   	    		else {
               		Xi=Xi[2::rows(Xi),.]
            		j=1
            		Bi=Bi+1
   	    		}
        	}
        	else {
            	j=0
        	}
   		}
   		
    	// End date
    	if (no_obs==0) {
    		Ei=T
    		j=1
    		while (j==1) {
        		if (hasmissing(Xi[rows(Xi),.])==1) { 
            		Xi=Xi[1::rows(Xi)-1,.]
            		j=1
            		Ei=Ei-1
        		}
        		else {
            		j=0
        		}
    		}	
    	}
    	else {
    		Ei = .
    	}

    	// Saving output
    	Ti=Ei-Bi+1
    	
    	// irregular spacing: retain the block with the largest sample size
    	if (hasmissing(Xi)==1 & no_obs!=1) {
    		splitv = J(Ti,1,1)
    		for (b=1; b<=Ti; b++) {
    			if (hasmissing(Xi[b,.])==1) splitv[b,1] = 0
    		}
    		splits = (0 , mm_which(splitv:-1)', Ti+1 )
    		j = 1
    		b = J(cols(splits)-1,1,.)
    		while (j<cols(splits)) {
    			b[j,1] = sum(splitv[splits[1,j]+1::splits[1,j+1]-1,1])
    			j = j + 1
    		}
    		ind = J(1,1,.)
    		left = J(1,1,.)
    		maxindex(b,1,ind,left)
    		Ti = b[ind[1,1],1]
    		Bi = Bi + splits[1,ind[1,1]]
    		Ei = Bi + b[ind[1,1],1]-1  		
    	} 	
    	TT[.,i]=(Ti\Bi\Ei)
    	
    	if ( no_obs==1 | Ti<=1)  {
    		irregular = (irregular, i)
    	}
    	else {
    		v = J(Ti,1,i-(cols(irregular)-1))
            indexTN = (indexTN \ ((Bi::Ei),v))      	
        }
	}
	
	if (cols(irregular)>1) {
		if (cols(irregular)-1==N) {
			errprintf("Insufficent number of useable observations for the currently specified model. Consider alternative lag length.")
			""
			exit(error(3498)) 
		}
		v = J(1,N,1)
		v[1,irregular[2::cols(irregular)]] = J(1,cols(irregular)-1,0)
		TT = select(TT,v)
	}
    indexTN = indexTN[2::rows(indexTN),.] 
}


// ******************************************************************
// *** Calculate (structured positive definite) covariance matrix ***
// ******************************************************************
real matrix cov_pos(real matrix x,
					   real matrix N,			 ///
 			  		   numeric scalar lags,	 	 ///
 			  		   numeric scalar ini,      ///
 			  		   real matrix TT
			 	  	   )			
{
 // Declarations
	real matrix 	covar_in, tmp_var, tmp_cov, tmp, chk, eig, temp 
	real scalar		i, Bi, Ei, l, d
 	
 // Calculations
 	covar_in = J(lags*N,lags,0)
 	for (i=1; i<=N; i++) { 	
 		Bi = TT[2,i]
 		Ei = TT[3,i]
 		tmp_var = variance(x[Bi::Ei,i])
 		covar_in[lags*(i-1)+1::i*lags,.] = diag(tmp_var*J(1,lags,1))
 		for (l=1; l<=lags-1; l++) {
 			tmp_cov = variance((x[Bi+l::Ei,i],x[Bi::Ei-l,i]))
 			if (hasmissing(tmp_cov)) {
 				break
 			}
 			else {
 				tmp = covar_in[lags*(i-1)+1::i*lags,.]
 				for (d=1; d<=rows(tmp)-l; d++) {
 					tmp[d,d+l] = tmp_cov[1,2]
 					tmp[d+l,d] = tmp_cov[1,2]
 				}
 				eig = eigenvalues(tmp) // saved as complex number
 				eig = Re(eig)  // resave as real numbers for all function
 				if (all(eig:>0)) {
 					covar_in[lags*(i-1)+1::i*lags,.] = tmp
 				}
 				else {
 					break
 				}				 	
 			} 			
 		}
 	}
 	if (ini==31) { 
 		temp = J(lags,lags,0)
 		for (l=1; l<=lags; l++) {
 			for (d=1; d<=lags; d++) {
 				temp[l,d] = mean(covar_in[((1::N):*lags:-lags:+l),d])
 			}
 		}	
 		covar_in = temp
 	}	
	return(covar_in)
}


end

