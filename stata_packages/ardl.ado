*! version 1.0.6  06feb2023  sk dcs

program define ardl , eclass sortpreserve byable(recall)

    version 11.2

    local cmd = "ardl"
    local maxlag_default = 4
    local maxcombs_default       = 100000
    local maxcombs_defaultnofast = 500

    if replay() {

        capture syntax , [ FBounds(numlist min=1 max=1 int >=1 <=5) ///
                           TBounds(numlist min=1 max=1 int >=1 <=5) ///
                           * ] 

        // DISPLAY FULL CRITICAL VALUE TABLE (BACKWARD COMPATABILITY)
        if "`fbounds'`tbounds'"!="" {
            if "`options'"!="" {
                disp as error `"Options 'fbounds' and 'tbounds' cannot be combined with any other option."'
                exit 198
            }
            if "`fbounds'"!="" & "`tbounds'"!="" {
                disp as error `"You may specify only one of 'fbounds' and 'tbounds'."'
                exit 198
            }
            
            local case `fbounds'`tbounds'
            if "`fbounds'"!="" local stat F
            if "`tbounds'"!="" local stat t
            
            tempname cvmat
            ardlbounds , table nosurfreg case(`case') stat(`=lower("`stat'")')

            exit
        }

        // DISPLAY ESTIMATION OUTPUT
        if ("`e(cmd)'" != "ardl") error 301

        _ardl_display `0'
        exit
    }

    local cmdline_orig `"`0'"'  // may be changed slightly below, so save for returning e(cmdline)
    capture syntax anything [if] [in] , TRendvar [ * ]
    if !_rc {
        tsset , noquery
        local trendvar `r(timevar)'
        local 0 `"`anything' `if' `in' , `options'"'
    }
    else {
        local trendvaropt "TRendvar(varlist min=1 max=1 numeric)"
            // do not inlcude directly in -syntax-, as it would overwrite `trendvar' with nothing
    }

    syntax varlist(min=1 numeric) [if] [in] [, LAgs(numlist >=0 int miss)    ///
                                       Maxlags(numlist >=0 int miss)         ///
                                       MAXCombs(numlist min=1 max=1 >0 int)  ///
                                       MATCRit(name)                         ///
                                       ec                                    ///  default: run main regression in levels; -ec- will use 'first difference' form
                                       ec1                                   ///  like option -ec-, but express ec-term in t-1
                                       MINLag1                               ///
                                       AIC BIC                               ///
                                       Exog(varlist numeric ts)              ///
                                       noConstant                            ///
                                       `trendvaropt'                         ///
                                       REStricted                            ///  
                                       nofast                                ///  use -regress- instead of Mata code for optimal lag selection
                                       Regstore(namelist min=1 max=1)        ///  stores results from -regress-
                                       PERfect                               ///  do not check for collinearity
                                       noCTable                              ///  do not display coefficient table
                                       noHEader                              ///  do not display regression table header
                                       BTest                                 ///  (no longer documented) display bounds test
                                       DOTs                                  ///
                                       nlcom                                 ///  invisible to user
                                       /// nosign                                ///
                                       * ]                                   //   Stata display options

    // NOTE: all varlists are already in unabbreviated form

    local numvars  : word count `varlist'
    local numxvars = `numvars'-1 
    forvalues i = 1/`numvars' {
        local var`i' : word `i' of `varlist'
    }
    local depvar `var1'
    local xvars : list varlist - depvar  // preserves order of `varlist'

    // INPUT CHECKS AND PROCESSING
    
    * if c(stata_version)<12 local fast nofast
    
    if "`ec'"!="" & "`ec1'"!="" {
        disp as error `"Options 'ec' and 'ec1' are mutually exclusive."'
        exit 198
    }
    
    if `numvars'==1 & "`ec1'"!="" {  // no x-regs: treat option -ec1- as -ec-; there is no difference b/w the two in this case
        local ec1 ""
        local ec  ec
    }
    
    if "`ec'`ec1'"=="" {
        if "`btest'"!="" {
            disp as error "Option 'btest' is only allowed in combination with options 'ec' or 'ec1'."
            exit 198
        }
        
        if "`constant'"!="noconstant" local _cons _cons
        if "`restricted'"!="" {
            disp as error `"Option 'restricted' only allowed in conjunction with one of options 'ec' or 'ec1'."'
            exit 198
        }
    }
    else {
        if "`constant'"=="noconstant" {
            if "`trendvar'"!="" {
                disp as error `"Option 'trendvar' requires a constant in the model."'
                exit 198
            }
            if "`restricted'"!="" {
                disp as error `"Option 'restricted' requires deterministic terms in the model."'
                exit 198
            }
            local case 1
        }
        else {  // constant
            local _cons _cons  // needed later for matrix subscripting
            if "`trendvar'"=="" {
                local case 3
                if "`restricted'"!="" local case 2
            }
            else {
                local case 5
                if "`restricted'"!="" local case 4
            }
        }
    }

    local ic ""  // if non-empty, optimal lag order has to be determined
    if "`lags'" != "" {
        local numlagargs : word count `lags'
        if `numlagargs'==1 & `numvars'>1 {
            mata : st_local("lags", "`lags' " * `numvars')
        }
        else if `numlagargs' != `numvars' error 125

        forvalues i = 1/`numvars' {
            local lag`i' : word `i' of `lags'
        }
        if strpos("`lags'", ".") local ic "ic"
    }
    else {
        local ic = "ic"
        forvalues i = 1/`numvars' {
            local lag`i' "."
        }
    }

    if "`maxlags'" != "" {
        local nummaxlagsargs : word count `maxlags'
        if `nummaxlagsargs'==1 & `numvars'>1 {
            mata : st_local("maxlags", "`maxlags' " * `numvars')
        }
        else if `nummaxlagsargs' != `numvars' error 125
        forvalues i = 1/`numvars' {
            local maxlag`i' : word `i' of `maxlags'
            if "`maxlag`i''" == "." local maxlag`i' = `maxlag_default'
        }
    }
    else {
        local maxlag1 = `maxlag_default'
        if `numvars'>=2 {
            forvalues i = 2/`numvars' {
                local maxlag`i' = `maxlag_default'
            }
        }
    }

    if (`lag1'    == 0) error 125
    if (`maxlag1' == 0) error 125

    local zero 0
    if ("`minlag1'"!="" & `: list zero in lags') {
        disp as error `"Specifying a zero lag for a long-run regressor incompatible with option 'minlag1'."'
        exit 125
    }

    if "`maxcombs'"=="" local maxcombs `maxcombs_default`fast''
	
    local usenlcom 0
    if "`nlcom'"!="" local usenlcom 1

    //      MARK SAMPLE
    tsset , noquery
    
    marksample touse

    if `lag1'==. local markoutstr L(1/`maxlag1').`depvar'
    if `lag1'< . local markoutstr L(1/`lag1').`depvar'

    if `numvars'>=2 {
        forvalues i=2/`numvars' {
            if `lag`i''==. local markoutstr `markoutstr' L(0/`maxlag`i'').`: word `i' of `varlist''
            if `lag`i''< . local markoutstr `markoutstr' L(0/`lag`i'').`: word `i' of `varlist''
        }
    }
    
    markout `touse' `markoutstr' `exog'

    _ts timevar panelvar if `touse', onepanel sort
		// -_ts- puts the t/pvar into the macro names `timevar' and `panelvar'
		//   although this is not documented
		// data must be sorted according to tvar before -marksample- / -markout- is used
    
    //      COLLINEARITY ISSUES
    if "`trendvar'"!="" {
        qui _rmcoll `timevar' `trendvar'
        if `r(k_omitted)'==0 {
            disp as error `"Trend variable must be collinear with the time variable."'
            exit 9
        }
    }

    if "`perfect'"=="" {
        _rmcoll `trendvar' `markoutstr' `exog' if `touse', `constant'  // specify `trendvar' first so the _rmcoll error message
                                                                       // points to other variables collinear with the trend
        if `r(k_omitted)'>0 {
            disp as error `"Collinear variables detected."'
            exit 9
        }

    }
    
    _get_diopts diopts , `options'
    
    // -------------- OPTIMAL LAG SELECTION --------------------------------------------------
    if "`ic'" != "" | "`matcrit'"!="" {
        if ("`aic'" != "") & ("`bic'" != "") {
            disp as error `"Options 'aic' and 'bic' are mutually exclusive."'
            exit 198
        }
        
        if "`aic'" == "" local bic "bic" // BIC is the default information criterion
    }
    
    if "`ic'" != "" {
        local ic `bic'`aic'
        
        if "`dots'"!="" {
            disp as text _n "Optimal lag selection, % complete:"
            local progline "{c -}{c -}{c -}{c +}{c -}{c -}{c -}"
            local progend  "{c -}{c -}{c -}{c +}{c -}"
            local progline "{c -}`progline'20%`progline'40%`progline'60%`progline'80%`progend'100%"
            disp as text "`progline'"
        }

        local matalags    `lag1'
        local matamaxlags `maxlag1'
        if `numvars'>=2 {
            forvalues i=2/`numvars' {
                local matalags    `matalags' `lag`i''
                local matamaxlags `matamaxlags' `maxlag`i''
            }
        }

        mata : _ardl_optimlag()
            // pulls all information via "st_" interface functions
            // defines locals `optimlag`i''
            // defines local `numcombs'
            // defines matrix `matcrit' if option -matcrit- has been used

        if "`dots'"!="" disp as text _n `"`=upper("`ic'")' optimized over `numcombs' lag combinations"'

    }                           // -------------- END OPTIMAL LAG SELECTION --------------
    else {
        forvalues i = 1/`numvars' {
            local optimlag`i' = `lag`i''
            local maxlag`i' "."
        }
    }

    tempname N df_m df_r mss rss rmse r2 r2_a ll rank b V optimlags maxlags

    matrix `optimlags' = J(1, `numvars', 0)
    matrix `maxlags'   = J(1, `numvars', 0)
    forvalues i = 1/`numvars' {
        matrix `optimlags'[1, `i'] = `optimlag`i''
        matrix `maxlags'[1, `i']   = `maxlag`i''
    }
    matrix colnames `optimlags' = `varlist'
    matrix colnames `maxlags'   = `varlist'

    // ESTIMATION
    local indepvarset ""

    if "`ec'`ec1'"!="" {
        local model "ec"

        // ----- for ec/ec1: optimlag locals now in terms of differences! -----
        forvalues i = 1/`numvars' {
            local --optimlag`i'
        }
        
        if "`ec1'"!="" & `numvars'>1 { // treat option ec1 as ec+minlag1 if all x-regs have optimlag>=1
            forvalues i=1/`numvars' {
                if `optimlag`i''>=0 {
                    if `i'< `numvars' {
                        continue
                    }
                    else if `i'==`numvars' {
                        local ec      ec
                        local minlag1 minlag1
                        local ec1     ""
                    }
                }
                else {
                    continue , break
                }
            }
        }
       
        local regdepvar D.`depvar'

        if (`optimlag1' > 0)        local indepvarset "L(1/`optimlag1')D.`depvar'"
        forvalues i = 2/`numvars' {
            if (`optimlag`i'') >= 0 local indepvarset "`indepvarset' L(0/`optimlag`i'')D.`var`i''"
        }
        local srvars `indepvarset'
        if "`ec'"!="" & "`minlag1'"=="" {  // ec
            local lrvars      "L.`depvar' `xvars'"
            local lrxvars     "`xvars'"
            local indepvarset "`lrvars' `indepvarset'"
        }
        else if "`minlag1'"!="" {  // either -ec- + -minlag1-, or -ec1- and no 0-lag regressor
            tsunab lrvars  :  L.(`varlist')
            tsunab lrxvars :  L.(`xvars')
            local indepvarset "`lrvars' `indepvarset'"
        }
        else if "`ec1'"!="" {  // -ec1- was used and there is a 0-lag regressor
            local indepvarset_ec1 "L(1/`optimlag1')D.`depvar'"
            forvalues i = 2/`numvars' {
                if (`optimlag`i'') >=0 {
                    local lrxvars "`lrxvars' L.`var`i''"
                    local indepvarset_ec1 "`indepvarset_ec1' L(0/`optimlag`i'')D.`var`i''"
                }
                else {
                    local lrxvars "`lrxvars' `var`i''"
                    local indepvarset_ec1 "`indepvarset_ec1' D.`var`i''"
                    * local ec1pos `ec1pos' `: word count `indepvarset_ec1''
                }
            }
            local lrvars "L.`depvar' `lrxvars'"
            local indepvarset "`lrvars' `indepvarset'"
            local srvars `indepvarset_ec1'
        }
    }
    else {
        local model "level"

        local regdepvar `depvar'
* if (`optimlag1' > 0)        local indepvarset "`indepvarset' L(1/`optimlag1').`depvar'"
        local indepvarset "`indepvarset' L(1/`optimlag1').`depvar'"
        if `numvars'>=2 {
            forvalues i = 2/`numvars' {
* if (`optimlag`i'') >= 0 local indepvarset "`indepvarset' L(0/`optimlag`i'').`var`i''"
                local indepvarset "`indepvarset' L(0/`optimlag`i'').`var`i''"
            }
        }
    }

    qui regress `regdepvar' `indepvarset' `exog' `trendvar' if `touse' , `constant'
        // use `touse' and not `if' and `in' to remain consistent with lag selection
		// if ec/ec1 is not used, -regress- results are automatically included
		//   in e()-results returned  by -ardl- since there is no -erturn clear/post- statement
    tempname regtable
    matrix `regtable' = r(table)  // only works in Stata 12+; gives "." in Stata 11

    if "`regstore'"!="" {
        tempname regstore2
        _estimates hold `regstore2' , copy
        
        local cmdline `"`e(cmdline)'"'
        local cmdline : subinstr local cmdline "`touse'" "_est_`regstore'"
        ereturn local cmdline `"`cmdline'"'
        
        estimates store `regstore'
        ereturn clear
        _estimates unhold `regstore2'
    }
    
    // ERROR-CORRECTION FORM MANIPULATIONS
    if "`ec'`ec1'"!="" {
        //      save results for re-posting after -nlcom-
        scalar `N' = e(N)
        scalar `df_m' = e(df_m)
        scalar `df_r' = e(df_r)
        scalar `mss' = e(mss)
        scalar `rss' = e(rss)
        scalar `rmse' = e(rmse)
        scalar `r2' = e(r2)
        scalar `r2_a' = e(r2_a)
        scalar `ll' = e(ll)
        scalar `rank' = e(rank)

        local eregress `e(cmdline)'

        local lrdetvar ""
        if `case'==2 local lrdetvar  "_cons"
        if `case'==3 local   detvars "_cons"
        if `case'==4 local lrdetvar  "`trendvar'"
        if `case'==4 local   detvars "_cons"
        if `case'==5 local   detvars "`trendvar' _cons"

        // PSS t AND F-STATS
        tempname F_pss t_pss jnk F_critval t_critval
		if c(stata_version)>=12 {
			matrix `jnk' = `regtable'[`=rownumb(`regtable', "t")', colnumb(`regtable', "L.`depvar'")] 
		}
		else {
			matrix `jnk' = _b[L.`depvar'] / _se[L.`depvar']
		}
		scalar `t_pss' = `jnk'[1,1]
        qui test `lrvars' `lrdetvar'
        scalar `F_pss' = r(F)

        local k : word count `lrxvars'
 
		if `k'<=10 {  // only tabulated up to k=10
			qui ardlbounds , table nosurfreg case(`case') stat(f)
			matrix `F_critval' = r(cvmat)
			matrix `F_critval' = `F_critval'[`=`k'+1', 1...]
			qui ardlbounds , table nosurfreg case(`case') stat(t)
			matrix `t_critval' = r(cvmat)
			matrix `t_critval' = `t_critval'[`=`k'+1', 1...]
        }

      
        tempvar esample esample2
        qui gen byte `esample'  = e(sample)
        qui gen byte `esample2' = e(sample)  // need two esample vars if `ec1' is used: two -ereturn post- are necessary, and the first one removes `esample'

        // TRANSFORMING REGRESSION OUTPUT FROM EC TO EC1: ADDING COLLINEAR SR-COEFS
        if "`ec1'"!="" {

            local nlcomexp "(L_`depvar': _b[L.`depvar'])"
            foreach curvar in `lrxvars' {
                if substr("`curvar'", 1, 2)=="L." {
                    local curvar2 : subinstr local curvar "L." "L_"
                    local nlcomexp "`nlcomexp' (`curvar2': _b[`curvar'])"
                }
                else {
                    local nlcomexp "`nlcomexp' (L_`curvar': _b[`curvar'])"  // 0-lag regressors
                }
            }
            /*
            foreach curvar in `lrdetvar' {
                local nlcomexp "`nlcomexp' (`curvar': _b[`curvar'])"
            }
            */
            
            forvalues i = 1/`numvars' {
                if (`optimlag`i'') >=0 {
                    forvalues l=0/`optimlag`i'' {
                        if `i'==1 & `l'==0 continue // there is no lag 0 of the depvar
                        if `l'==0 local nlcomexp "`nlcomexp' (D_`var`i'': _b[D.`var`i''])"
                        if `l'!=0 local nlcomexp "`nlcomexp' (L`l'D_`var`i'': _b[L`l'D.`var`i''])"
                    }
                }
                else {
                    local nlcomexp "`nlcomexp' (D_`var`i'': _b[`var`i''])"  // 0-lag regressors
                }
            }
            local junk : subinstr local nlcomexp "(" "(" , all count(local ec1_numnondetexog)
            
            foreach curvar in `exog' `trendvar' `_cons' {
                if strpos("`curvar'", ".") {  // for exog vars with ts ops
                    local curvar2 : subinstr local curvar "." "_"
                    local nlcomexp "`nlcomexp' (`curvar2': _b[`curvar'])"
                }
                else {
                    local nlcomexp "`nlcomexp' (`curvar': _b[`curvar'])"
                }
            }

            capture nlcom `nlcomexp', level(`level') noheader iter(1000)
                // long-run coefficients and standard errors (delta method)
            if _rc {
                disp as error `"{bf:nlcom} exited with error."'
                if _rc==498 {
                    disp as error `"If your independent variables are on vastly different scales,"'
                    disp as error `"consider rescaling them before running {bf:ardl}."'
                }
                exit _rc
            }

            tempname b_ec1 V_ec1
            matrix `b_ec1' = r(b)
            matrix `V_ec1' = r(V)
            local cnames : colnames r(b)
            local i 1
			foreach cn of local cnames {
                // translate underscores back to dots for ts ops where appropriate
                if `i'<=`ec1_numnondetexog' {
                    // translate first underscore which separates the TS operator
                    // do this for all vars that are not exit or deterministics
					local cn2 : subinstr local cn "_" "."
				}
				else {  // exog vars and deterministics
                    // never translate underscore in _cons and trendvar (which does not allow for ts ops)
                    // exog vars that have ts ops need to get translated back
                    //   the condition is that the current colstripe differs from the orig exog var colstripe
                    //   (e.g. "L_myexogvar" is not found in "exog1 L.myexogvar"
                    if !inlist("`cn'", "_cons", "`trendvar'") & "`: list cn & exog'"=="" {
                        // for exog vars with ts ops
                        local cn2 : subinstr local cn "_" "."
                    }
                    else {
                        // deterministics or exog vars that do not have ts ops
                        local cn2 `cn'
                    }
				}
				local cnames2 `cnames2' `cn2'          //   not a problem if variable names contain underscores
                
                local ++i
			}
			local cnames `cnames2'

            matrix colnames `b_ec1' = `cnames'
            matrix rownames `V_ec1' = `cnames'
            matrix colnames `V_ec1' = `cnames'
            
            tsunab lrvars  :  L.(`varlist')
            tsunab lrxvars :  L.(`xvars')
            local indepvarset "`lrvars' `indepvarset_ec1'"
            
            local dof = `df_r'
            ereturn post `b_ec1' `V_ec1', esample(`esample') depname(D.`depvar') dof(`dof')
                // will be re-posted later to get error-correction form

        }

        // MOVE TO ERROR-CORRECTION FORM
        //   note: case II: _cons    gets moved to lr-relationship
        //         case IV: trendvar gets moved to lr-relationship
        local regvars : colnames e(b)

        local lrvarsfull `lrvars' `lrdetvar'
        local nonlrvars : list regvars - lrvarsfull
        local numnonlrvars : word count `nonlrvars'

        tempname b1 V1 V2 b_sr V_sr b_ec V_ec
        
        if `usenlcom' {
            local nlcomexp "(L_`depvar': _b[L.`depvar'])"
            foreach curvar in `lrxvars' `lrdetvar' {  //
                local curvar_ : subinstr local curvar "." "_"
                local nlcomexp "`nlcomexp' (`curvar_': -_b[`curvar'] / _b[L.`depvar'])"

            }

            foreach curvar in `nonlrvars' {
                local curvar_ : subinstr local curvar "." "_"
                local nlcomexp `nlcomexp' (`curvar_': _b[`curvar'])
            }

            capture nlcom `nlcomexp', level(`level') noheader iter(1000)
                // long-run coefficients and standard errors (delta method)
            if _rc {
                disp as error `"{bf:nlcom} exited with error."'
                if _rc==498 {
                    disp as error `"If your independent variables are on vastly different scales,"'
                    disp as error `"consider rescaling them before running {bf:ardl}."'
                }
                exit _rc
            }
            
            matrix `b_ec' = r(b)
            matrix `V_ec' = r(V)
        }
        else {
            mata : calc_nlcom("`b_ec'", "`V_ec'", `numxvars', "`lrdetvar'", `numnonlrvars')
                // defines matrices `b_ec', `V_ec'
        }

        local matlabels `lrvars' `lrdetvar' `nonlrvars'
        
        matrix colnames `b_ec' = `matlabels'
        matrix colnames `V_ec' = `matlabels'
        matrix rownames `V_ec' = `matlabels'

        local eqnames ADJ
        forvalues i=1/`: word count `lrxvars' `lrdetvar'' {
            local eqnames `eqnames' LR
        }
        forvalues i=1/`: word count `nonlrvars'' {
            local eqnames `eqnames' SR
        }

        matrix coleq `b_ec' = `eqnames'
        matrix coleq `V_ec' = `eqnames'
        matrix roweq `V_ec' = `eqnames'
    }
    
    // POST RESULTS
    if "`ec'`ec1'"!="" {
        local dof = `df_r'
        ereturn post `b_ec' `V_ec', esample(`esample2') depname(D.`depvar') dof(`dof')

        ereturn local lrxvars  "`lrxvars'"
        ereturn local lrdet    "`lrdetvar'"
        ereturn local srvars   "`srvars'"
        ereturn local exogvars "`exog'"
        ereturn local det      "`detvars'"

        ereturn scalar t_pss = `t_pss'
        ereturn scalar F_pss = `F_pss'
        ereturn scalar case  = `case'

        ereturn scalar N = `N'
        ereturn scalar df_m = `df_m'
        ereturn scalar df_r = `df_r'
        ereturn scalar mss = `mss'
        ereturn scalar rss = `rss'
        ereturn scalar rmse = `rmse'
        ereturn scalar r2 = `r2'
        ereturn scalar r2_a = `r2_a'
        ereturn scalar ll = `ll'
        ereturn scalar rank = `rank'
        
		if `k'<=10 {
			local hist ""
			if c(stata_version)>=12 local hist historical
			ereturn `hist' matrix t_critval = `t_critval'
			ereturn `hist' matrix F_critval = `F_critval'
		}
    }
    if "`numcombs'"!="" ereturn scalar numcombs = `numcombs'
    
    
    local regressors  `indepvarset' `exog' `trendvar' `_cons'
    ereturn local regressors : list clean regressors   // get rid of potentially uneven spacing

    qui tsreport if e(sample)
    local N_gaps `r(N_gaps)'
    local tsfmt : format `timevar'
    qui su `timevar' if e(sample) , meanonly
    local tmin `r(min)'
    local tmax `r(max)'
    ereturn scalar N_gaps = `N_gaps'
    ereturn scalar tmin = `tmin'
    ereturn scalar tmax = `tmax'

	ereturn local tmaxs : display `tsfmt' e(tmax)
	ereturn local tmins : display `tsfmt' e(tmin)
	ereturn local tvar  : char _dta[tis]
    ereturn local tsfmt       "`tsfmt'"

    ereturn matrix lags     = `optimlags' , copy
    ereturn matrix maxlags  = `maxlags'
    
    // matrix e(lagcombs) is no longer returned in versions >=0.7.0
    * if "`ic'"!="" ereturn matrix lagcombs = `lagcombs' , copy
        // strangely, -eret mat- w/o the -copy- option takes very long for large matrices, effectively freezing Stata

	// title/model ops
	forvalues j=1/`=colsof("`optimlags'")' {
		local lagstr `lagstr' `=`optimlags'[1,`j']'
	}
	local lagstr : subinstr local lagstr " " "," , all
	local title "ARDL(`lagstr') regression"
	if "`e(model)'" == "level" {
		ereturn local title "`title', level representation"
	}
	else if "`e(model)'" == "ec" {
		ereturn local title "`title', EC representation"
	}

	loc hid ""
	if c(stata_version)>=12 local hid hidden
	ereturn `hid' local crittype "log likelihood"  // for _coef_table_header
	
	ereturn local marginsok ""  // TODO: test/make it work w/ margins
	
    ereturn local predict     ardl_p
    ereturn local estat_cmd   ardl_estat
    ereturn local title      `"`title'"'
    ereturn local model      `"`model'"'
    ereturn local cmdversion  1.0.6
    ereturn local cmdline    `"`cmd' `cmdline_orig'"'
    ereturn local cmd         "`cmd'"
    
    // define matcrit
    if "`matcrit'"!="" {
        if "`ic'"=="" {
            // optim lag determination has NOT been performed
            local ic `bic'`aic'

            matrix `matcrit' = J(1, `=`numvars'+1', .)
            forvalues i = 1/`numvars' {
                matrix `matcrit'[1,`i'] = `lag`i''
            }
            // if ("`ic'"=="aic") matrix `matcrit'[1,`=`numvars'+1'] = -2*e(ll) + 2*k
            // else               matrix `matcrit'[1,`=`numvars'+1'] = -2*e(ll) + k*log(e(N))
            tempname icmat
            qui estat ic
            matrix `icmat' = r(S)
            matrix `matcrit'[1,`=`numvars'+1'] = `icmat'[1, colnumb(`icmat', upper("`ic'"))]
        }
        matrix colnames `matcrit' = `varlist' `ic'
    }
    

    _ardl_display , `diopts' `ctable' `header' `btest'

end // fold


*** --------------------------------- SUBROUTINES -----------------------------------------
program define _ardl_display

    syntax , * [noCTable noHEADer BTest]

    _get_diopts diopts , `options'

    * if (`e(N_gaps)'>0) local gapstring "(with gaps)"
    * local tstring : display `e(tsfmt)' `e(tmin)' " - " `e(tsfmt)' `e(tmax)' " `gapstring'"
	
	capture confirm scalar e(F)
	if _rc local nomodeltest nomodeltest
	
    _coef_table_header , `header' `nomodeltest'

	disp ""
	
	if "`ctable'"!="noctable" _coef_table , `options'

    if "`e(model)'"=="ec" & "`btest'"!="" estat btest  // for backward comp

end // fold

*** --------------------------------- MATA ------------------------------------------------

mata:
    mata set matastrict on

    void _ardl_optimlag() {
        
        real matrix lagcombs,
                    icmat,
                    X,
                    X_exogdet,
                    XX,
                    cX,
                    cXX,
                    y,
                    cy,
                    b_jnk
        real colvector e,
                       Xy,
                       cXy,
                       yy,
                       b
        real rowvector matalags,
                       matamaxlags,
                       matamx2lags,
                       Xidxstart,
                       Xselect
        real scalar numcombs,
                    ic_min,
                    i, j,
                    clags,
                    numvars,
                    numexogdet,
                    ic_val,
                    optimcomb,
                    rank,
                    ll,
                    N,
                    sigma2,
                    k,
                    dotintval, // disp dot every dotintval iterations when looping through lagcombs
                    dotnum,    // # of last dot displayed, in range 0-50 (0-100% is divided into 50 dots)
                    dotstrlen,  // # of dots displayed at a time; can be >1, e.g. with numcombs=10, dotstrlen=5 (".....")
                    ee
        string scalar depvar,
                      indepvarset,
                      ic,
                      cmdline,
                      fast,
                      dots,
                      dotstr
        string rowvector varlist
        
        varlist     = tokens(st_local("varlist"))
        depvar      = st_local("depvar")
        numvars     = strtoreal(st_local("numvars"))
        ic          = st_local("ic")
        matalags    = strtoreal(tokens(st_local("matalags")))
        matamaxlags = strtoreal(tokens(st_local("matamaxlags")))
        fast        = st_local("fast")
        dots        = st_local("dots")

        lagcombs = _ardl_lagcombs(matalags, matamaxlags)
        numcombs = rows(lagcombs)
        lagcombs = (lagcombs, J(numcombs, 1, .))
        
        dotintval = .
        if (dots!="") {
            dotnum = 0
            if (numcombs>50) { // more than 50 lagcombs => disp dot every dotintval iterations
                dotstrlen = 1
                dotintval = ceil(numcombs / 50)
                
            }
            else {             // less than 50 lagcombs => disp several dots at each iteration
                dotstrlen = floor(50 / numcombs)  // e.g. with numcombs=10, dotstr=".....": 5 dots are displayed at a time
                dotintval = 1
            }
            dotstr = "." * dotstrlen
        }

        if (fast!="nofast") {
            matamx2lags = matamaxlags  // matamx2lags is matamaxlags with values for fixed lags filled in
            for (i=1; i<=numvars; i++) {
                if (matalags[i]<.) matamx2lags[i]=matalags[i]
            }
            X = (st_data(., "L(0/" :+ strofreal(matamx2lags) :+ ")." :+ varlist , st_local("touse")))
            N = rows(X)
            X_exogdet = J(rows(X), 0, .)
            if (st_local("exog")!="")     X_exogdet = (X_exogdet , st_data(., st_local("exog") , st_local("touse")))
            if (st_local("trendvar")!="") X_exogdet = (X_exogdet , st_data(., st_local("trendvar"), st_local("touse")))
            if (st_local("_cons")!="")    X_exogdet = (X_exogdet , J(rows(X), 1, 1))
            numexogdet = cols(X_exogdet)
            y = X[.,1]
            X = (X_exogdet, X[., 2..cols(X)])  // note that X contains X_exogdet at the beginning
            if (hasmissing((y,X))) {
                _error(416, "Data passed to Mata has missing values.")
            }

            yy = cross(y,y)
            XX = cross(X,X)
            Xy = cross(X,y)

            // prepare algo for efficiently inverting matrices
            /*
            general idea:
            assume a maxlag = 2 5 3 4, with depvar=2 maxlags and indepvar1=5 lags fixed
            the matrix lagcombs will look like ("| #" indicates the rownum)
            1 5 0 0 | 1
            1 5 0 1 | 2
            1 5 0 2 | 3
            1 5 0 3 | 4
            1 5 0 4 | 5
            1 5 1 0 | 6
            1 5 1 1 | 7
            1 5 1 2 | 8
            ...     | 
            1 5 3 4 | 
            2 5 0 0 | 
            2 5 0 1 | 
            ...
            The algo calculates the inverse of 1 5 0 0, then successively calcs
            incremental inverses (i.e. adds a col to X) w/ lags 1-4 of indepvar3.
            Then it jumps back to the inverse 1 5 0 0 and adds lag 1
            of indepvar2, then it again adds cols 1-4 of indepvar3.
            That way, an inverse is calculated from scratch only once. Afterwards,
            all inverses are calculated using an updating algorithm that uses
            the previous inverse and the new column of X and its cross-products.
            This is based on the results for inverses of partitioned matrices.
            
            XXinvbase is a vector of pointers to inverses that the algo needs to
            jump back to. It jumps back
            to the leftmost col for which the lag index changes. Let's say that
            it is true for col c. Then the inverse stored in XXinvbase(c) is queried
            and updated by adding a new lag of var #c. The result is stored back
            in XXinvbase(c) and also in XXinvbase(d) for all d>c.
            
            For each new inverse calculation, the regression-based IC is recorded.
            */
            
			if (numvars==1) {
				Xidxstart = 1 + numexogdet
			} else {
				Xidxstart = ((1 , runningsum(matamx2lags[1::numvars-1]:+1)) :+ numexogdet)
                    // starting index of variables within  X
					// e.g. for matamx2lags =(3, 2, 5, 2) this is (1, 4, 7, 13)
					//   (if there are no exogdet cols), taking
					//   into account that x-vars start with a zero lag
			}

            pointer(real matrix) rowvector XXinvbase, XXbase, vXbase
            real rowvector curnumregs, vX, Xselectstart,  // Xselectstart: just matrix used to start the build up of the Xselect matrix within a loop
                           Xidxend, lagcombsi1
            real colvector XXnewcol
            real matrix cXXinv
            real scalar maxlagsum, maxregs, vv, colpos, vidx, cidx

			maxlagsum = sum(matamx2lags)

            maxregs = 3
                // maxregs is used to decide which algo is used
                // if numoptmodels>maxregs , updating (column addition to X) of XXinv
                // is performed; otherwise we have regular invsym() calculations
            
            cXX = cXy = cX = cXXinv = .

            if (numexogdet>0) Xselectstart = (1..numexogdet)
            else              Xselectstart = J( 1,0,.)

            for (i=1; i<=numcombs; i++) {
                if (i==1) vidx=.
                else      vidx = ds_firstindex(lagcombs[i-1,1..numvars]:!=lagcombs[i,1..numvars])[1]
                    // vidx: index of first variable that changes # of lags
					// do not use Mata's selectindex() here since it does not exist in versions <13

                lagcombsi1 = (lagcombs[i,1]-1, lagcombs[i,2..numvars])  // depvar does not have lag 0

                if (vidx==numvars) {
                    /*
                    implemented for efficiency:
                    when a column is appended to the previous XX (a lag is 
                    added to the last regressor) use this fact in the indexing operations; 
                    use the expensive Xselect calculation and indexing
                    only if the column selection is more complicated
                    */

					cidx = Xidxstart[numvars] + lagcombsi1[numvars]

					XXnewcol = XX[Xselect, cidx]

                    cXX = (cXX , XXnewcol \ XXnewcol' , XX[cidx, cidx])
                    cXy = (cXy \ Xy[cidx])

                    Xselect = (Xselect , cidx)
                }
                else {
                    Xselect = Xselectstart
                    for (j=1; j<=numvars; j++) {
                        Xselect = (Xselect , Xidxstart[j]..(Xidxstart[j]+lagcombsi1[j]))
                    }
                    cXX = XX[Xselect, Xselect]
                    cXy = Xy[Xselect]
                }

                k = cols(cXX)

                if (maxlagsum<maxregs) {
                    cXXinv = invsym(cXX)
                }
                else {
                    if (i==1) {
                        XXinvbase = J(1, numvars, &invsym(cXX))
                        XXbase    = J(1, numvars, &(1*cXX))
                        cXXinv = *(XXinvbase[1])
                    }
                    else {
                        if (vidx==numvars) {
                            vX = cXX[k,1..k-1]  // note: must leave out vv from vX
                            vv = cXX[k,k]
                            XXinvbase[numvars] = &(ds_updXXinv(*(XXbase[numvars]), *(XXinvbase[numvars]), vX, vv))
                            XXbase[numvars]    = &cXX[.,.]  // creates pointer to a copy of cXX
                            cXXinv = *(XXinvbase[numvars])
                        }
                        else {
                            if (vidx==1) colpos = numexogdet + lagcombs[i,1]
                            else         colpos = numexogdet + sum(lagcombsi1[1..vidx]:+1)
                            vX = cXX[colpos,(1..max((1,colpos-1)) , colpos+1..k)]
                            vv = cXX[colpos, colpos]
                            XXinvbase[vidx..numvars] = J(1, numvars-vidx+1, &(ds_updXXinv(*(XXbase[vidx]), *(XXinvbase[vidx]), vX, vv, colpos)))
                            XXbase[vidx..numvars]    = J(1, numvars-vidx+1, &cXX[.,.])
                            cXXinv = *(XXinvbase[vidx])
                        }
                    }
                }

                // calculate e'e = y'*Mx*y = y'y - y'X*XXinv*X'y
                ee = yy - cXy'*cXXinv*cXy
                sigma2 = ee/N
                ll = N*log(2*pi()) + N*log(sigma2) + N
                if (ic=="aic") ic_val = ll + 2*k
                else ic_val = ll + k*log(N)

                lagcombs[i, numvars+1] = ic_val
                if (ic_val<ic_min) {
                    ic_min = ic_val
                    optimcomb = i
                }

                if (mod(i,dotintval)==0) {  // does not execute if dotintval is not defined (dots=="")
                    printf(dotstr)
                    dotnum = dotnum + dotstrlen
                    displayflush()
                }
            }
        }
        else {  // option -nofast- was used
            for (i=1; i<=numcombs; i++) {

                clags = lagcombs[i,1]
                indepvarset = "L(1/" + strofreal(clags) + ")." + depvar
                if (numvars>=2) {
                    for (j=2; j<=numvars; j++) {
                        clags = lagcombs[i, j]
                        indepvarset = indepvarset + " L(0/" + strofreal(clags) + ")." + varlist[j]
                    }
                }

                // qui regress `depvar' `indepvarset' `exog' `trendvar' if `touse', `constant'
                cmdline = "qui regress " + depvar + " " + indepvarset + " " + st_local("exog") + " " + st_local("trendvar") + " if " + st_local("touse") + ", " + st_local("constant")
                stata(cmdline)
                if (st_numscalar("e(df_r)")==0) exit(error(2001))
                stata("qui estat ic")
                icmat = st_matrix("r(S)")
                if (ic=="aic") ic_val = icmat[1,5]
                else ic_val = icmat[1,6]
                lagcombs[i, numvars+1] = ic_val
                if (ic_val<ic_min) {
                    ic_min = ic_val
                    optimcomb = i
                }

                if (mod(i,dotintval)==0) {
                    printf(dotstr)
                    dotnum = dotnum + dotstrlen
                    displayflush()
                }
            }
        }

        if (dots!="") {  // fill up dots if 50 dots are not complete
            if (dotnum<50) {
                printf("." * (50-dotnum))
                displayflush()
            }    
        }

        // returning results
        if (st_local("matcrit")!="") st_matrix(st_local("matcrit"), lagcombs)
        st_local("numcombs", strofreal(numcombs))
        for (j=1; j<=numvars; j++) {
            st_local("optimlag" + strofreal(j), strofreal(lagcombs[optimcomb,j]))
        }
    }

    real matrix _ardl_lagcombs(real rowvector lags, real rowvector maxlags) {
    // calculates permutations of lags relevant for optimal lag order selection
    
        real scalar    numvars, i, minlag1, reqcombs, maxcombs
        real rowvector numlagvec, lagtemp
        real matrix    lagmat, lagcombs

        
        if (cols(lags)!=cols(maxlags)) error(3200)

        numvars = cols(lags)
        minlag1 = (st_local("minlag1")!="")

        numlagvec = ds_select(maxlags, lags:>=.)
			// do not use select() here, as it did not exist before Stata 13

        if (!minlag1) {
            // x-var lag selection is 0/maxlag if option minlag1 is not used, otherwise it is 1/maxlag
            // numlagvec: row vector whose elements denote the length of the searched lag length for each variable
            //            e.g. 3 for a lag length search specification 0/2
            // for y-var lags are from 1::maxlag
            numlagvec = numlagvec :+1
            if (lags[1]>=.) numlagvec[1] = numlagvec[1]-1
        }

        lagmat = J(max(numlagvec), numvars, .)

        for (i=1; i<=numvars; i++) {
            if (lags[i]<.) {
                lagmat[1,i] = lags[i]
            }
            else {
                if (i==1) {
                    lagmat[1::maxlags[i] ,i]   = 1::(maxlags[i])
                }
                else {
                    if (minlag1) {
                        lagmat[1::(maxlags[i])   ,i] = 1::(maxlags[i])
                    }
                    else {
                        lagmat[1::(maxlags[i]+1) ,i] = 0::(maxlags[i])
                    }
                }
            }
        }
        
        lagtemp = colsum(lagmat:!=.)
        reqcombs = 1
        for (i=1; i<=numvars; i++) {
            reqcombs = reqcombs * lagtemp[i]
        }
        maxcombs = strtoreal(st_local("maxcombs"))
        if (maxcombs<reqcombs) {
            display("{error:# of lag permutations (" + strofreal(reqcombs) +
                      ") exceeds setting of 'maxcombs' (" + strofreal(maxcombs) + ")}")
            exit(9)
        }

        /*
        if (st_numscalar("c(matsize)")<reqcombs) {
            _error(908, "matsize setting too small for number of lag combinations to be checked")
        }
        */

        lagcombs = ds_matcomb(lagmat)  // generates all possible combinations
        
        return(lagcombs)
    }
	
    real scalar ds_firstindex(real vector vecin) {
		// returns index of first nonzero elem in vecin
		real scalar i
		for (i=1;i<=length(vecin);i++) {
			if (vecin[i]!=0) return(i)
		}
	}
	
	real rowvector ds_select(real rowvector from , real rowvector cond) {
		
		real scalar i, sumtrue, j
		real rowvector vecout

		assert(length(from)==length(cond))
		sumtrue = sum(cond:!=0)
		vecout = J(1, sumtrue, .)
		
		j = 1
		for (i=1;i<=length(from);i++) {
			if (cond[i]!=0) {
				vecout[j] = from[i]
				j++
			}
		}
		return(vecout)
	}

    void calc_nlcom(string scalar b_ec_tmp, string scalar V_ec_tmp, real scalar numxvars, string scalar lrdetvar, real scalar numnonlrvars) {
        
        real scalar    numregs, numdiv, div
        real rowvector transvec
        real matrix    b, V
        
        b = st_matrix("e(b)")
        V = st_matrix("e(V)")

        if (lrdetvar!="") {
            // must reorder if deterministic terms go into LR
            // either trend or _cons goes into the LR (never both)
            // trend, if present, is in second but last pos, _cons is last
            
            // note: numxvars may be zero
            
            numregs = cols(b)
            
            lrdetpos = numregs
            if (lrdetvar!="_cons")
                lrdetpos = lrdetpos - 1
            pvec = (1..(numxvars+1) , lrdetpos)

            if (lrdetvar=="_cons") {
                if (numregs>(numxvars+2)) // not true if no trend, no exog, and all xvars have zero lags
                    pvec = (pvec , (numxvars+2)..(numregs-1))
            } else { // trend
                if (numregs==(numxvars+3)) { // _cons must be in the model, and is the only additional regressor
                    pvec = (pvec , numregs)
                } else {
                    pvec = (pvec , (numxvars+2)..(numregs-2), numregs)
                }
            }

            b = b[pvec]
            V = V[pvec', pvec]
        }


        numdiv = numxvars + (lrdetvar!="")
        if (numdiv>0) {
            div = -1 / b[1,1]
            transvec = (1, J(1, numdiv, div), J(1, numnonlrvars, 1))
            st_matrix(b_ec_tmp,  transvec :* b)

            G = diag(transvec)
            G[|2,1 \ numdiv+1,1|] = b[2..(numdiv+1)]' :/ b[1,1]^2
            st_matrix(V_ec_tmp,  G * V * G')
        }
        else {
            st_matrix(b_ec_tmp, b)
            st_matrix(V_ec_tmp, V)
        }
        
        return
    }


end // fold




mata:

matrix ds_twocomb(matrix v1, matrix v2) {
// forms all permutations of rows of v1 and rows of v2
// with the row index of v1 being slower than the one of v2
// e.g. v1 = (1 2  v2 = (2
//            3 5        3)
//            2 0)
// will return
//      (1 2 2
//       1 2 3
//       3 5 2
//       3 5 3
//       2 0 2
//       2 0 3)
//
// note: if you pass the vectors as row vectors, the result will probably not be
//       what you expected, e.g. passing (1 2) and (3 4) will return (1 2 3 4)
// note: inputs may also be string matrices

    if (eltype(v1)!=eltype(v2)) {
        exit(_error(3250,"ds_twocomb.mata: Input args must be of the same element type."))
    }
    if ( !any(eltype(v1):==("real","string")) ) {
        exit(_error(3250,"ds_twocomb.mata: Args must be either real or string."))
    }

    real scalar r1, r2, c1
    
    r1 = rows(v1)
    r2 = rows(v2)
    c1 = cols(v1)

    return( (colshape(J(1, r2, v1), c1) , J(r1, 1, v2) ) )

}

end


mata:
mata set matastrict on

real matrix ds_matcomb(real matrix matin) {
// forms all permutations of elements of columns of matin;
// with the row index of col i slower than the row index of col j if i < j 
// e.g. matin(1 2
//            3 5
//            2 .)
// will return
//      (1 2
//       1 5
//       3 2
//       3 5
//       2 2
//       2 5)
// 
// missing values may also occur in other rows than the last one
// if matin has all missings for a column, an error is issued
// if matin has all missings for a row, the row is ignored
//
// dependencies: ds_twocomb()

    real scalar numvec,
                i
    real matrix combmat

    real matrix in1
    real matrix in2
    
    if ( rows(matin)==(max(colmissing(matin))) ) {
        _error(504, "ds_matcomb.mata: at least one column of input matrix does not have a nonmissing value.")
    }
    
    combmat = J(0,0,.)
    numvec = cols(matin)
    if (numvec == 1) {
        return(select(matin, matin:!=.))
    }
    else {                          // create matrix of all element combinations
        for (i=2;i<=numvec; i++) {            
            if (combmat == J(0,0,.)) {
                in1 = select(matin[.,1], matin[.,1] :!= .)
                in2 = select(matin[.,2], matin[.,2] :!= .)
                combmat = ds_twocomb(in1, in2)
            }
            else {
                in2 = select(matin[.,i], matin[.,i] :!= .)
                combmat = ds_twocomb(combmat, in2)
            }
        }
        return(combmat)
    }
}


end



version 10

mata:
mata set matastrict on

real matrix ds_updXXinv(real matrix    XX,     // cross-prod matrix that needs to get updated
                        real matrix    XXi,    // inverse of XX
                        real rowvector vX,     // prod v' * X ; pass to avoid inner products of size N
                        real scalar    vv,     // same as for vX
                      | real scalar    pos) {  // v is added as col pos to X, not added as new last col
// 19oct2016  dcs
/*
 updates the inverse of a matrix for the addition of one column
 based on formulas in Lutkepohl (2005), p.660, (2) and (3)
 B = [ (X'
        v') *(X v) ]^-1 = [ X'X  X'v
                            v'X  v'v ]^-1
                                
    B11 = D = (X'X - v'X * (v'v)^-1 * X'v)^-1
            = (X'X)^-1 + (X'X)^-1 * X'v (v'v - v'X * (X'X)^-1 * X'v)^-1 * v'X * (X'X)^-1
    B12 = -DX'v * (v'v)^-1
    B21 = -(v'v)^-1 * v'XD
    B22 = (v'v)^-1 + (v'v)^-1 * v'XDX'v * (v'v)^-1
    
*/

    real rowvector vXXXi, p, k
    real colvector B12
    real matrix    D, B22, B

    vXXXi = vX * XXi
    D   = XXi + cross(vXXXi,vXXXi) * (1 / (vv - vX * vXXXi'))
    B12 = D * (vX' / vv)
    B22 = 1/vv + vX * (B12 / vv)
    _negate(B12)
    B = (D , B12 \ B12' , B22)

    if (pos<.) {
        // permute XXinv:
        // if v was in position pos instead of at the end of X, 
        //   it is as if we had used covariate matrix X*P instead of X (with P being a permutation matrix):
        //   ((XP)'XP)^-1 = (P'X'XP)^-1 = P^-1 * (X'X)^-1 * P'^-1 = P' * (X'X)^-1 * P
        //   Calculated was P' * (X'X)^-1 * P, so one must premult by P and postmult by P'
        //   in order to get (X'X)^-1
        //   Note that (XP)'XP = P'X'XP is symmetric, and X'X is symmetric, i.e.
        //     premult a symmetric matrix by P' and postmult by P yields again
        //     a symmetric matrix.
        //     In general if XP reorders the columns of X in a particular way,
        //     P'X reorders the rows in the same way, and likewise for XP' and PX.
        //   In terms of permutation vectors, the postmult by P' is done by by invorder(p), as expected.
        //     the premult by P is also done by invorder(p):
        //       if P = I(k+1)[.,p], then XP = X[.,p]
        //       but PX = X[invorder(p), .]        
        //     see also [M-1] permutation

        k = cols(XX)
        if (pos>(k+1)) _error(503)
        else if (pos<=k) {
            p = (1..(pos-1) , (pos+1)..(k+1), pos)
            B = B[invorder(p), invorder(p)]
        }
    }

    return( B )
}
end


