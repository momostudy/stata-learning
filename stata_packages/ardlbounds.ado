*! version 1.0.6  06feb2023  sk dcs



program define ardlbounds , rclass

    version 11.2
    
    syntax , [TABle *]
    
    if "`table'"!="" {
        ardlbounds_table , `options'
		return add
        exit
    }

    syntax , Case(numlist min=1 max=1 >=1 <=5 int)       /// 
           [ Stat(passthru)                              /// 
             n(numlist min=1 max=1 >=1 int miss)         ///
             k(numlist min=1 max=1 >=0 int)              ///
             sr(numlist min=1 max=1 >=0 int)             ///
             SIGlevels(numlist min=1 descending >0 <100) ///
             PValue(numlist min=1 max=1)                 ///
             SIMVersion(numlist min=1 max=1 int >0)      ///
           ]
    
    _ardlbounds_parsestat , `stat' // does a c_local of `stat', which is then either F or t
	
	local case_orig `case'
    if "`stat'"=="t" & inlist(`case', 2, 4) local ++case
		// t-statistic unaffected by restrictions on deterministic model components
		// (display case 3 if c == 2 and display case 5 if c == 4)
	
	if "`n'"=="." local n ""
    local asymptotic = ("`n'"=="")
    if "`k'"==""  local k  0
    if "`sr'"=="" local sr 0
	
    if "`siglevels'"=="" {
		local numsiglevels 3
		local siglevels    "10 5 1"
		local siglevelsbig "1000 0500 0100"
	}
	else {
		local numsiglevels : word count `siglevels'
		foreach p of local siglevels {
			local siglevelsbig `siglevelsbig' `=`p'*100'
		}
	}
	
	local goodsiglevels "00.01 00.02 00.05 00.10(00.10)00.90 01.00(00.50)98.50 99.00(00.10)99.90 99.95 99.98 99.99"
	qui numlist "`goodsiglevels'"
	local expandsiglevels = r(numlist)
	local diff : list siglevels - expandsiglevels
	if "`diff'"!="" {
		disp as error `"Elements of option 'siglevels()' must be elements of the Stata {help numlist}"'
        disp as error `"  `goodsiglevels'"'
		disp as error `"Element(s) supplied but not in the above list: '`diff''"'
		exit 125
	}
    
    if inlist("`simversion'", "", "3") {
        local filename ardl_surfreg_coefs.dta
    }
    else {
        local simversion_fmt : disp %02.0f `simversion'
        local filename ardl_surfreg_coefs_simv`simversion_fmt'.dta
    }
	local coefsfile `"`c(sysdir_plus)'a/`filename'"'
    capture confirm file `"`coefsfile'"'
    if _rc {
        qui findfile `filename'
        local coefsfile `"`r(fn)'"'
    }
    
    loc df1 = 1+`k'+(`case'==2|`case'==4)                 // numerator   dof
    loc df2 = `n' - (1+`k'+`sr'+(`case'>=2)+(`case'>=4))  // denominator dof
	
	if !`asymptotic' {
		if `df2'<(`n'/2) {
			disp as error `"There must be at least twice as many observations than coefficients."'
			exit 198
		}
	}
	
	if "`pvalue'"!="" {
		tempname ardlres
		_estimates hold `ardlres' , restore nullok
			// -regress- necessary to calc p-values
	}
	
    preserve
    
    forvalues Iorder=0/1 {
		qui use `"`coefsfile'"' , clear
		qui keep if stat=="`stat'" & c==`case' & I==`Iorder'
		
        // predict critical values
        qui gen double cv = 0
        if !`asymptotic' {
            qui replace cv = cv + (theta_0_2_0 + theta_0_2_1 * `sr') / `n'^2 + (theta_0_3_0 + theta_0_3_1 * `sr') / `n'^3
        }
        forv j = 0/4 {
            qui replace cv = cv + theta_`j'_0_0 / (`k'+1)^`j'
            if !`asymptotic' {
                qui replace cv = cv + theta_`j'_1_0 / ((`k'+1)^`j' * `n')
                qui replace cv = cv + theta_`j'_1_1 * `sr' / ((`k'+1)^`j' * `n')
            }
        }
        foreach pbig of local siglevelsbig {
            sum cv if p == `pbig' , meanonly
            local `stat'crit`Iorder'_`pbig'    = r(mean)
        }
		
		if "`pvalue'"!="" {
			local statval = `pvalue'
			local pvalmsg " and approximate p-values"

            // check whether supplied value is in range of calculated CVs
            //   (bug fixed in v1.0.4)
            sum cv , meanonly
            if `statval' > r(max) {
                local setp`Iorder' 0
            }
            if `statval' < r(min) {
                local setp`Iorder' 1
            }
            if "`setp`Iorder''"!="" {
                local `stat'crit`Iorder' = .  // cv cannot be predicted by regression
                if "`stat'"=="t" local setp`Iorder' = 1 - `setp`Iorder''  // switch tails
                continue
            }
            
			// find 9 nearest quantiles to the observed test statistic
			qui gen double absdiff = abs(cv - `statval')
			sum absdiff, mean
			qui gen int minpos = _n if absdiff == r(min)
			sum minpos, mean
			qui gen byte touse = (_n >= r(mean) - 4) & (_n <= r(mean) + 4)

			// auxiliary regression to obtain approximate p-value
			//   MacKinnon (1996), page 610, equation (12)
			if !`asymptotic' {
				if "`stat'"=="F" qui gen double invtail =  invFtail(`df1', `df2', p / 10000)
				if "`stat'"=="t" qui gen double invtail = -invttail(`df2',        p / 10000)  // note the minus sign
			}
			else {
				if "`stat'"=="F" qui gen double invtail =  invchi2tail(`df1', p / 10000)
				if "`stat'"=="t" qui gen double invtail =  invnormal(         p / 10000)      // note the missing minus sign
			}
			qui reg invtail cv c.cv#c.cv if touse       // OLS
			local `stat'crit`Iorder' = _b[_cons] + _b[cv] * `statval' + _b[c.cv#c.cv] * (`statval')^2
		}
    }
    restore

    // output display and return values
	if c(noisily) {
		local col = c(linesize)-13
		local col = max(min(`col', 67), 28)  // 28: accounts for length of preceding string
		disp as txt _n "Kripfganz and Schneider (2020) critical values`pvalmsg'"
		disp as txt    "for the Pesaran, Shin, and Smith (2001) bounds test"
		disp as txt _n "Case " as res "`case_orig'"
		if `asymptotic' {
			disp as txt _n "Asymptotic (" as res "`k'" as txt " variables)"
		}
		else {
			disp as txt _n "Finite sample (" as res "`k'" as txt " variables, " as res "`n'" as txt " observations, " as res "`sr'" as txt " short-run coefficients)"
		}
	}
	
	local ncol = `numsiglevels'*2 + ("`pvalue'"!="")*2
    tempname cvmat
    matrix `cvmat' = J(1, `ncol', 0)
    forvalues j=1/`numsiglevels' {
        local pbig : word `j' of `siglevelsbig'
		local p    : word `j' of `siglevels'
        matrix `cvmat'[1, 2*`j'-1] = ``stat'crit0_`pbig''
        matrix `cvmat'[1, 2*`j'  ] = ``stat'crit1_`pbig''

		local dp 2
		if reldif(mod(100-`p', 0.1) , 0)<1e-6 local dp 1
		if reldif(mod(100-`p', 1  ) , 0)<1e-6 local dp 0
		
		local pdisp : disp %4.`dp'f `p'
        local matcolnames "`matcolnames' `pdisp'%:I(0) `pdisp'%:I(1)"
    }

	if "`pvalue'"!="" {
		if !`asymptotic' {
			if "`stat'"=="F" {
				matrix `cvmat'[1, `=`ncol'-1'] = Ftail(`df1', `df2', `Fcrit0')
				matrix `cvmat'[1,   `ncol'   ] = Ftail(`df1', `df2', `Fcrit1')
			}
			else {
				matrix `cvmat'[1, `=`ncol'-1'] = 1 - ttail(`df2', `tcrit0')
				matrix `cvmat'[1,   `ncol'   ] = 1 - ttail(`df2', `tcrit1')
			}
		}
		else {
			if "`stat'"=="F" {
				matrix `cvmat'[1, `=`ncol'-1'] = chi2tail(`df1', `Fcrit0')
				matrix `cvmat'[1,   `ncol'   ] = chi2tail(`df1', `Fcrit1')
			}
			else {
				matrix `cvmat'[1, `=`ncol'-1'] = normal( `tcrit0')
				matrix `cvmat'[1,   `ncol'   ] = normal( `tcrit1')
			}
		}
        if "`setp0'"!="" matrix `cvmat'[1, `=`ncol'-1'] = `setp0'
        if "`setp1'"!="" matrix `cvmat'[1,   `ncol'   ] = `setp1'
        
		local matcolnames "`matcolnames' p-value:I(0) p-value:I(1)"
	}

    matrix colnames `cvmat' = `matcolnames'
    matrix rownames `cvmat' = `stat'
    
	
    
	local cspec : disp _dup(`=`ncol'/2') "| %7.3f & %7.3f "
	if c(noisily) matlist `cvmat', cspec(& %2s `cspec' &) rspec(&|&)
    
	return local siglevels = "`siglevels'"
	return local stat      = "`stat'"

	if !`asymptotic' return scalar sr    = `sr'
	if !`asymptotic' return scalar N     = `n'
	return scalar case  = `case_orig'
	return scalar k     = `k'
	
	return matrix cvmat = `cvmat'
	
end

program define ardlbounds_table , rclass

		
    syntax , [noSURFreg *]

    if "`surfreg'"!="nosurfreg" {
        _ardlbounds_table_surfreg , `options'
		return add
        exit
    }
    
	local 0 `", `options'"'
    syntax , Case(numlist min=1 max=1 >=1 <=5 int)  /// 
           [ Stat(passthru)         /// 
             n Nfix(numlist min=1 max=1 >=1 int)    /// help file shows n[(numobs)], so user can specify both 'n' and 'n(50)', with 'n' using e(N)
           ]

    if "`nfix'"!="" local n `nfix'
    
    if `"`n'"'=="" {
        local nsource pssmith
    }
    else if `"`n'"'=="n" {
        if "`e(cmd)'"!="ardl" {
            disp as error `"Option 'n' without argument requires that {cmd:ardl} e()-results are present."'
            exit 301
        }
        local n = e(N)
        local nsource narayan
    }
    else {  // n has numobs
        if `n'>=83 {
            local n ""
            local nsource pssmith
        }
        else {
            local nsource narayan
        }    
    }
    
    _ardlbounds_parsestat , `stat' // does a c_local of `stat', which is then either F or t

    if "`nsource'"!="pssmith" & "`stat'"=="t" {
        disp as error `"t-statistics are only recorded for PSS 2001 critical values."'
        exit 198
    }
    
    if "`nsource'"!="pssmith" & `case'==1 {
        disp as error `"Case 1 critical values are only recorded for PSS 2001 critical values."'
        exit 198
    }
    
    if "`nsource'"=="pssmith" & "`n'"!="" {
        disp as error `"Option 'n()' is not allowed in combination with PSS 2001 critical values."'
        exit 198
    }
    
    if "`nsource'"=="narayan" {
        mata : st_local("ncrit", strofreal(_ardl_getn(`n')))  // maps integers passed to n of critical value tables, e.g. n=39 => 40, n=200 => 80
    }

    if "`nsource'"=="pssmith" {
        _ardl_getpsstable , case(`case') stat(`stat')
        tempname cvmat
        matrix `cvmat' = r(cvmat)
        if `c(noisily)' {
            matlist `cvmat' , title(Pesaran/Shin/Smith (2001) Critical Values (0.1-0.01), `stat'-statistic, Case `case')     /// 
                              cspec(& %5s | %6.2f & %6.2f | %6.2f & %6.2f | %6.2f & %6.2f | %6.2f & %6.2f &) ///
                              rspec(&|&&&&&&&&&&&)
        }
		return local siglevels = "10 5 2.5 1"
    }
    else if "`nsource'"=="narayan" {
        _ardl_getnartable , case(`case') ncrit(`ncrit')
        tempname cvmat
        matrix `cvmat' = r(cvmat)
        matlist `cvmat' , title(Narayan (2005) Critical Values (0.1-0.01), `stat'-statistic, Case `case' (N=`ncrit'))     /// 
                          cspec(& %5s | %6.2f & %6.2f | %6.2f & %6.2f | %6.2f & %6.2f &) ///
                          rspec(&|&&&&&&&&)
	    return local siglevels = "10 5 1"
    }
    
    return add
    if "`nsource'"=="narayan" return scalar Ncrit = `ncrit'

end

program define _ardlbounds_parsestat
    
    syntax , [ stat(string) ]
    
    if `"`stat'"'=="" {
        local stat F
    }
    else {
        if `"`stat'"'=="f" local stat F
        if `"`stat'"'=="T" local stat t
        if !inlist(`"`stat'"', "F", "t") {
            disp as error `"Argument of option 'stat()' invalid."'
            exit 198
        }
    }
    
    c_local stat `stat'

end

program define _ardlbounds_table_surfreg , rclass

    syntax , Case(passthru)      /// 
           [ Stat(passthru)      /// 
             n(passthru)       /// not necessary here to have n/nfix() (where n looks at e(N))
                              ///   since this routine is never used to help an -estat- routine
             LAgs(numlist min=1 max=1 >=1 int)  ///
			 kmax(numlist min=1 max=1 >=0 int)  ///
           ]
	
	if "`kmax'"  =="" local kmax 12
	if "`lags'"  =="" local lags 0
	
	tempname cvmat
	
	forvalues k=0/`kmax' {
		local sr = max(0, `lags'-1) + `lags' * `k'
		qui ardlbounds , `case' `stat' `n' k(`k') sr(`sr') siglevels(10 5 2.5 1)
		matrix `cvmat' = nullmat(`cvmat') \ r(cvmat)
	}
	
	local stat `r(stat)'
	local case `r(case)'
	local n    `r(N)'
	
	return add

	local npart " (N=`n')"
	if "`n'"=="" local npart " (Asymptotic)"

	mata : st_local("rnames", invtokens("k_" :+ strofreal(0..`kmax')))
    matrix rownames `cvmat' = `rnames'
    matrix colnames `cvmat' = [I_0]:L_1   [I_1]:L_1    [I_0]:L_05  [I_1]:L_05    [I_0]:L_025  [I_1]:L_025    [I_0]:L_01  [I_1]:L_01
	local rspec : disp _dup(`=`kmax'+1') "&"
	
	disp as text _n "Kripfganz and Schneider (2020) Critical Values (0.1-0.01)"
	disp            "`stat'-statistic, `lags' Lags, Case `case'`npart'"
	matlist `cvmat' , cspec(& %5s | %6.2f & %6.2f | %6.2f & %6.2f | %6.2f & %6.2f | %6.2f & %6.2f &) ///
					  rspec(&|`rspec')

	return matrix cvmat = `cvmat'
end

*** --------------------------------- SUBROUTINES -----------------------------------------

program define _ardl_getpsstable , rclass
// define and return critical value tables (PSS 2001, Narayan 2005)

    syntax , case(numlist min=1 max=1 int >=1 <=5) stat(string)

	local case_orig `case'
    if "`stat'"=="t" & inlist(`case', 2, 4) local ++case
    
    tempname cvmat
    
    if `"`=lower("`stat'")'"'=="f" {
        if `case'==1 {
            matrix `cvmat' =  (3.00, 3.00, 4.20, 4.20, 5.47, 5.47, 7.17, 7.17 \ ///
                               2.44, 3.28, 3.15, 4.11, 3.88, 4.92, 4.81, 6.02 \ ///
                               2.17, 3.19, 2.72, 3.83, 3.22, 4.50, 3.88, 5.30 \ ///
                               2.01, 3.10, 2.45, 3.63, 2.87, 4.16, 3.42, 4.84 \ ///
                               1.90, 3.01, 2.26, 3.48, 2.62, 3.90, 3.07, 4.44 \ ///
                               1.81, 2.93, 2.14, 3.34, 2.44, 3.71, 2.82, 4.21 \ ///
                               1.75, 2.87, 2.04, 3.24, 2.32, 3.59, 2.66, 4.05 \ ///
                               1.70, 2.83, 1.97, 3.18, 2.22, 3.49, 2.54, 3.91 \ ///
                               1.66, 2.79, 1.91, 3.11, 2.15, 3.40, 2.45, 3.79 \ ///
                               1.63, 2.75, 1.86, 3.05, 2.08, 3.33, 2.34, 3.68 \ ///
                               1.60, 2.72, 1.82, 2.99, 2.02, 3.27, 2.26, 3.60 )
        }
        else if `case'==2 {
            matrix `cvmat' =  (3.80, 3.80, 4.60, 4.60, 5.39, 5.39, 6.44, 6.44 \ ///
                               3.02, 3.51, 3.62, 4.16, 4.18, 4.79, 4.94, 5.58 \ ///
                               2.63, 3.35, 3.10, 3.87, 3.55, 4.38, 4.13, 5.00 \ ///
                               2.37, 3.20, 2.79, 3.67, 3.15, 4.08, 3.65, 4.66 \ ///
                               2.20, 3.09, 2.56, 3.49, 2.88, 3.87, 3.29, 4.37 \ ///
                               2.08, 3.00, 2.39, 3.38, 2.70, 3.73, 3.06, 4.15 \ ///
                               1.99, 2.94, 2.27, 3.28, 2.55, 3.61, 2.88, 3.99 \ ///
                               1.92, 2.89, 2.17, 3.21, 2.43, 3.51, 2.73, 3.90 \ ///
                               1.85, 2.85, 2.11, 3.15, 2.33, 3.42, 2.62, 3.77 \ ///
                               1.80, 2.80, 2.04, 3.08, 2.24, 3.35, 2.50, 3.68 \ ///
                               1.76, 2.77, 1.98, 3.04, 2.18, 3.28, 2.41, 3.61 )
        }
        else if `case'==3 {
            matrix `cvmat' =  (6.58, 6.58, 8.21, 8.21, 9.80, 9.80, 11.79, 11.79 \ ///
                               4.04, 4.78, 4.94, 5.73, 5.77, 6.68,  6.84,  7.84 \ ///
                               3.17, 4.14, 3.79, 4.85, 4.41, 5.52,  5.15,  6.36 \ ///
                               2.72, 3.77, 3.23, 4.35, 3.69, 4.89,  4.29,  5.61 \ ///
                               2.45, 3.52, 2.86, 4.01, 3.25, 4.49,  3.74,  5.06 \ ///
                               2.26, 3.35, 2.62, 3.79, 2.96, 4.18,  3.41,  4.68 \ ///
                               2.12, 3.23, 2.45, 3.61, 2.75, 3.99,  3.15,  4.43 \ ///
                               2.03, 3.13, 2.32, 3.50, 2.60, 3.84,  2.96,  4.26 \ ///
                               1.95, 3.06, 2.22, 3.39, 2.48, 3.70,  2.79,  4.10 \ ///
                               1.88, 2.99, 2.14, 3.30, 2.37, 3.60,  2.65,  3.97 \ ///
                               1.83, 2.94, 2.06, 3.24, 2.28, 3.50,  2.54,  3.86 )
        }
        else if `case'==4 {
            matrix `cvmat' =  (5.37, 5.37, 6.29, 6.29, 7.14, 7.14, 8.26, 8.26 \ ///
                               4.05, 4.49, 4.68, 5.15, 5.30, 5.83, 6.10, 6.73 \ ///
                               3.38, 4.02, 3.88, 4.61, 4.37, 5.16, 4.99, 5.85 \ ///
                               2.97, 3.74, 3.38, 4.23, 3.80, 4.68, 4.30, 5.23 \ ///
                               2.68, 3.53, 3.05, 3.97, 3.40, 4.36, 3.81, 4.92 \ ///
                               2.49, 3.38, 2.81, 3.76, 3.11, 4.13, 3.50, 4.63 \ ///
                               2.33, 3.25, 2.63, 3.62, 2.90, 3.94, 3.27, 4.39 \ ///
                               2.22, 3.17, 2.50, 3.50, 2.76, 3.81, 3.07, 4.23 \ ///
                               2.13, 3.09, 2.38, 3.41, 2.62, 3.70, 2.93, 4.06 \ ///
                               2.05, 3.02, 2.30, 3.33, 2.52, 3.60, 2.79, 3.93 \ ///
                               1.98, 2.97, 2.21, 3.25, 2.42, 3.52, 2.68, 3.84 )
        }
        else if `case'==5 {
            matrix `cvmat' =  (9.81, 9.81, 11.64, 11.64, 13.36, 13.36, 15.73, 15.73 \ ///
                               5.59, 6.26,  6.56,  7.30,  7.46,  8.27,  8.74,  9.63 \ ///
                               4.19, 5.06,  4.87,  5.85,  5.49,  6.59,  6.34,  7.52 \ ///
                               3.47, 4.45,  4.01,  5.07,  4.52,  5.62,  5.17,  6.36 \ ///
                               3.03, 4.06,  3.47,  4.57,  3.89,  5.07,  4.40,  5.72 \ ///
                               2.75, 3.79,  3.12,  4.25,  3.47,  4.67,  3.93,  5.23 \ ///
                               2.53, 3.59,  2.87,  4.00,  3.19,  4.38,  3.60,  4.90 \ ///
                               2.38, 3.45,  2.69,  3.83,  2.98,  4.16,  3.34,  4.63 \ ///
                               2.26, 3.34,  2.55,  3.68,  2.82,  4.02,  3.15,  4.43 \ ///
                               2.16, 3.24,  2.43,  3.56,  2.67,  3.87,  2.97,  4.24 \ ///
                               2.07, 3.16,  2.33,  3.46,  2.56,  3.76,  2.84,  4.10 )
        }
    
    }
    else if `"`=lower("`stat'")'"'=="t" {
        
        if `case'==1 {
            matrix `cvmat' =  (-1.62, -1.62, -1.95, -1.95, -2.24, -2.24, -2.58, -2.58 \ ///
                               -1.62, -2.28, -1.95, -2.60, -2.24, -2.90, -2.58, -3.22 \ ///
                               -1.62, -2.68, -1.95, -3.02, -2.24, -3.31, -2.58, -3.66 \ ///
                               -1.62, -3.00, -1.95, -3.33, -2.24, -3.64, -2.58, -3.97 \ ///
                               -1.62, -3.26, -1.95, -3.60, -2.24, -3.89, -2.58, -4.23 \ ///
                               -1.62, -3.49, -1.95, -3.83, -2.24, -4.12, -2.58, -4.44 \ ///
                               -1.62, -3.70, -1.95, -4.04, -2.24, -4.34, -2.58, -4.67 \ ///
                               -1.62, -3.90, -1.95, -4.23, -2.24, -4.54, -2.58, -4.88 \ ///
                               -1.62, -4.09, -1.95, -4.43, -2.24, -4.72, -2.58, -5.07 \ ///
                               -1.62, -4.26, -1.95, -4.61, -2.24, -4.89, -2.58, -5.25 \ ///
                               -1.62, -4.42, -1.95, -4.76, -2.24, -5.06, -2.58, -5.44 )
        }
        else if `case'==3 {
            matrix `cvmat' =  (-2.57, -2.57, -2.86, -2.86, -3.13, -3.13, -3.43, -3.43 \ ///
                               -2.57, -2.91, -2.86, -3.22, -3.13, -3.50, -3.43, -3.82 \ ///
                               -2.57, -3.21, -2.86, -3.53, -3.13, -3.80, -3.43, -4.10 \ ///
                               -2.57, -3.46, -2.86, -3.78, -3.13, -4.05, -3.43, -4.37 \ ///
                               -2.57, -3.66, -2.86, -3.99, -3.13, -4.26, -3.43, -4.60 \ ///
                               -2.57, -3.86, -2.86, -4.19, -3.13, -4.46, -3.43, -4.79 \ ///
                               -2.57, -4.04, -2.86, -4.38, -3.13, -4.66, -3.43, -4.99 \ ///
                               -2.57, -4.23, -2.86, -4.57, -3.13, -4.85, -3.43, -5.19 \ ///
                               -2.57, -4.40, -2.86, -4.72, -3.13, -5.02, -3.43, -5.37 \ ///
                               -2.57, -4.56, -2.86, -4.88, -3.13, -5.18, -3.42, -5.54 \ ///
                               -2.57, -4.69, -2.86, -5.03, -3.13, -5.34, -3.43, -5.68 )
        }
        else if `case'==5 {
            matrix `cvmat' =  (-3.13, -3.13, -3.41, -3.41, -3.65, -3.66, -3.96, -3.97 \ ///
                               -3.13, -3.40, -3.41, -3.69, -3.65, -3.96, -3.96, -4.26 \ ///
                               -3.13, -3.63, -3.41, -3.95, -3.65, -4.20, -3.96, -4.53 \ ///
                               -3.13, -3.84, -3.41, -4.16, -3.65, -4.42, -3.96, -4.73 \ ///
                               -3.13, -4.04, -3.41, -4.36, -3.65, -4.62, -3.96, -4.96 \ ///
                               -3.13, -4.21, -3.41, -4.52, -3.65, -4.79, -3.96, -5.13 \ ///
                               -3.13, -4.37, -3.41, -4.69, -3.65, -4.96, -3.96, -5.31 \ ///
                               -3.13, -4.53, -3.41, -4.85, -3.65, -5.14, -3.96, -5.49 \ ///
                               -3.13, -4.68, -3.41, -5.01, -3.65, -5.30, -3.96, -5.65 \ ///
                               -3.13, -4.82, -3.41, -5.15, -3.65, -5.44, -3.96, -5.79 \ ///
                               -3.13, -4.96, -3.41, -5.29, -3.65, -5.59, -3.96, -5.94 )
        }
    }
    
    matrix rownames `cvmat' = k_0 k_1 k_2 k_3 k_4 k_5 k_6 k_7 k_8 k_9 k_10
    matrix colnames `cvmat' = [I_0]:L_1   [I_1]:L_1    [I_0]:L_05  [I_1]:L_05 ///
                              [I_0]:L_025 [I_1]:L_025  [I_0]:L_01  [I_1]:L_01
                                
    return local  stat    `stat'
    return scalar case  = `case_orig'
    return matrix cvmat = `cvmat'
    
end

program define _ardl_getnartable , rclass
// define and return critical value tables (PSS 2001, Narayan 2005)

    syntax , case(numlist min=1 max=1 int >=1 <=5) ncrit(numlist min=1 max=1 >=1 int)
    
    tempname cvmat

    if `case'==2 {
        if `ncrit'==30 {
            matrix `cvmat' = (  4.025 ,  4.025 ,  5.070 ,  5.070 ,  7.595 ,  7.595 \ ///
                                3.303 ,  3.797 ,  4.090 ,  4.663 ,  6.027 ,  6.760 \ ///
                                2.915 ,  3.695 ,  3.538 ,  4.428 ,  5.155 ,  6.265 \ ///
                                2.676 ,  3.586 ,  3.272 ,  4.306 ,  4.614 ,  5.966 \ ///
                                2.525 ,  3.560 ,  3.058 ,  4.223 ,  4.280 ,  5.840 \ ///
                                2.407 ,  3.517 ,  2.910 ,  4.193 ,  4.134 ,  5.761 \ ///
                                2.334 ,  3.515 ,  2.794 ,  4.148 ,  3.976 ,  5.691 \ ///
                                2.277 ,  3.498 ,  2.730 ,  4.163 ,  3.864 ,  5.694 )
        }
        else if `ncrit'==35 {
            matrix `cvmat' = (  3.980 ,  3.980 ,  4.945 ,  4.945 ,  7.350 ,  7.350 \ ///
                                3.223 ,  3.757 ,  3.957 ,  4.530 ,  5.763 ,  6.480 \ ///
                                2.845 ,  3.623 ,  3.478 ,  4.335 ,  4.948 ,  6.028 \ ///
                                2.618 ,  3.532 ,  3.164 ,  4.194 ,  4.428 ,  5.816 \ ///
                                2.460 ,  3.460 ,  2.947 ,  4.088 ,  4.093 ,  5.532 \ ///
                                2.331 ,  3.417 ,  2.804 ,  4.013 ,  3.900 ,  5.419 \ ///
                                2.254 ,  3.388 ,  2.685 ,  3.960 ,  3.713 ,  5.326 \ ///
                                2.196 ,  3.370 ,  2.597 ,  3.907 ,  3.599 ,  5.230 )
        }
        else if `ncrit'==40 {
            matrix `cvmat' = (  3.955 ,  3.955 ,  4.960 ,  4.960 ,  7.220 ,  7.220 \ ///
                                3.210 ,  3.730 ,  3.937 ,  4.523 ,  5.593 ,  6.333 \ ///
                                2.835 ,  3.585 ,  3.435 ,  4.260 ,  4.770 ,  5.855 \ ///
                                2.592 ,  3.454 ,  3.100 ,  4.088 ,  4.310 ,  5.544 \ ///
                                2.427 ,  3.395 ,  2.893 ,  4.000 ,  3.967 ,  5.455 \ ///
                                2.306 ,  3.353 ,  2.734 ,  3.920 ,  3.657 ,  5.256 \ ///
                                2.218 ,  3.314 ,  2.618 ,  3.863 ,  3.505 ,  5.121 \ ///
                                2.152 ,  3.296 ,  2.523 ,  3.829 ,  3.402 ,  5.031 )
        }
        else if `ncrit'==45 {
            matrix `cvmat' = (  3.950 ,  3.950 ,  4.895 ,  4.895 ,  7.265 ,  7.265 \ ///
                                3.190 ,  3.730 ,  3.877 ,  4.460 ,  5.607 ,  6.193 \ ///
                                2.788 ,  3.540 ,  3.368 ,  4.203 ,  4.800 ,  5.725 \ ///
                                2.560 ,  3.428 ,  3.078 ,  4.022 ,  4.270 ,  5.412 \ ///
                                2.402 ,  3.345 ,  2.850 ,  3.905 ,  3.892 ,  5.173 \ ///
                                2.276 ,  3.297 ,  2.694 ,  3.829 ,  3.674 ,  5.019 \ ///
                                2.188 ,  3.254 ,  2.591 ,  3.766 ,  3.540 ,  4.931 \ ///
                                2.131 ,  3.223 ,  2.504 ,  3.723 ,  3.383 ,  4.832 )
        }
        else if `ncrit'==50 {
            matrix `cvmat' = (  3.935 ,  3.935 ,  4.815 ,  4.815 ,  7.065 ,  7.065 \ ///
                                3.177 ,  3.653 ,  3.860 ,  4.440 ,  5.503 ,  6.240 \ ///
                                2.788 ,  3.513 ,  3.368 ,  4.178 ,  4.695 ,  5.758 \ ///
                                2.538 ,  3.398 ,  3.048 ,  4.002 ,  4.188 ,  5.328 \ ///
                                2.372 ,  3.320 ,  2.823 ,  3.872 ,  3.845 ,  5.150 \ ///
                                2.259 ,  3.264 ,  2.670 ,  3.781 ,  3.593 ,  4.981 \ ///
                                2.170 ,  3.220 ,  2.550 ,  3.708 ,  3.424 ,  4.880 \ ///
                                2.099 ,  3.181 ,  2.457 ,  3.650 ,  3.282 ,  4.730 )
        }
        else if `ncrit'==55 {
            matrix `cvmat' = (  3.900 ,  3.900 ,  4.795 ,  4.795 ,  6.965 ,  6.965 \ ///
                                3.143 ,  3.670 ,  3.790 ,  4.393 ,  5.377 ,  6.047 \ ///
                                2.748 ,  3.495 ,  3.303 ,  4.100 ,  4.610 ,  5.563 \ ///
                                2.508 ,  3.356 ,  2.982 ,  3.942 ,  4.118 ,  5.200 \ ///
                                2.345 ,  3.280 ,  2.763 ,  3.813 ,  3.738 ,  4.947 \ ///
                                2.226 ,  3.241 ,  2.617 ,  3.743 ,  3.543 ,  4.839 \ ///
                                2.139 ,  3.204 ,  2.490 ,  3.658 ,  3.330 ,  4.708 \ ///
                                2.069 ,  3.148 ,  2.414 ,  3.608 ,  3.194 ,  4.562 )
        }
        else if `ncrit'==60 {
            matrix `cvmat' = (  3.880 ,  3.880 ,  4.780 ,  4.780 ,  6.960 ,  6.960 \ ///
                                3.127 ,  3.650 ,  3.803 ,  4.363 ,  5.383 ,  6.033 \ ///
                                2.738 ,  3.465 ,  3.288 ,  4.070 ,  4.558 ,  5.590 \ ///
                                2.496 ,  3.346 ,  2.962 ,  3.910 ,  4.068 ,  5.250 \ ///
                                2.323 ,  3.273 ,  2.743 ,  3.792 ,  3.710 ,  4.965 \ ///
                                2.204 ,  3.210 ,  2.589 ,  3.683 ,  3.451 ,  4.764 \ ///
                                2.114 ,  3.153 ,  2.456 ,  3.598 ,  3.293 ,  4.615 \ ///
                                2.044 ,  3.104 ,  2.373 ,  3.540 ,  3.129 ,  4.507 )
        }
        else if `ncrit'==65 {
            matrix `cvmat' = (  3.880 ,  3.880 ,  4.780 ,  4.780 ,  6.825 ,  6.825 \ ///
                                3.143 ,  3.623 ,  3.787 ,  4.343 ,  5.350 ,  6.017 \ ///
                                2.740 ,  3.455 ,  3.285 ,  4.070 ,  4.538 ,  5.475 \ ///
                                2.492 ,  3.350 ,  2.976 ,  3.896 ,  4.056 ,  5.158 \ ///
                                2.335 ,  3.252 ,  2.750 ,  3.755 ,  3.725 ,  4.940 \ ///
                                2.209 ,  3.201 ,  2.596 ,  3.677 ,  3.430 ,  4.721 \ ///
                                2.120 ,  3.145 ,  2.473 ,  3.583 ,  3.225 ,  4.571 \ ///
                                2.043 ,  3.094 ,  2.373 ,  3.519 ,  3.092 ,  4.478 )
        }
        else if `ncrit'==70 {
            matrix `cvmat' = (  3.875 ,  3.875 ,  4.750 ,  4.750 ,  6.740 ,  6.740 \ ///
                                3.120 ,  3.623 ,  3.780 ,  4.327 ,  5.157 ,  5.957 \ ///
                                2.730 ,  3.445 ,  3.243 ,  4.043 ,  4.398 ,  5.463 \ ///
                                2.482 ,  3.310 ,  2.924 ,  3.860 ,  3.916 ,  5.088 \ ///
                                2.320 ,  3.232 ,  2.725 ,  3.718 ,  3.608 ,  4.860 \ ///
                                2.193 ,  3.161 ,  2.564 ,  3.650 ,  3.373 ,  4.717 \ ///
                                2.100 ,  3.121 ,  2.451 ,  3.559 ,  3.180 ,  4.596 \ ///
                                2.024 ,  3.079 ,  2.351 ,  3.498 ,  3.034 ,  4.426 )
        }
        else if `ncrit'==75 {
            matrix `cvmat' = (  3.895 ,  3.895 ,  4.760 ,  4.760 ,  6.915 ,  6.915 \ ///
                                3.133 ,  3.597 ,  3.777 ,  4.320 ,  5.260 ,  5.957 \ ///
                                2.725 ,  3.455 ,  3.253 ,  4.065 ,  4.458 ,  5.410 \ ///
                                2.482 ,  3.334 ,  2.946 ,  3.862 ,  4.048 ,  5.092 \ ///
                                2.313 ,  3.228 ,  2.725 ,  3.718 ,  3.687 ,  4.842 \ ///
                                2.196 ,  3.166 ,  2.574 ,  3.641 ,  3.427 ,  4.620 \ ///
                                2.103 ,  3.111 ,  2.449 ,  3.550 ,  3.219 ,  4.526 \ ///
                                2.023 ,  3.068 ,  2.360 ,  3.478 ,  3.057 ,  4.413 )
        }
        else if `ncrit'==80 {
            matrix `cvmat' = (  3.870 ,  3.870 ,  4.725 ,  4.725 ,  6.695 ,  6.695 \ ///
                                3.113 ,  3.610 ,  3.740 ,  4.303 ,  5.157 ,  5.917 \ ///
                                2.713 ,  3.453 ,  3.235 ,  4.053 ,  4.358 ,  5.393 \ ///
                                2.474 ,  3.312 ,  2.920 ,  3.838 ,  3.908 ,  5.004 \ ///
                                2.303 ,  3.220 ,  2.688 ,  3.698 ,  3.602 ,  4.787 \ ///
                                2.303 ,  3.154 ,  2.550 ,  3.606 ,  3.351 ,  4.587 \ ///
                                2.088 ,  3.103 ,  2.431 ,  3.518 ,  3.173 ,  4.485 \ ///
                                2.017 ,  3.052 ,  2.336 ,  3.458 ,  3.021 ,  4.350 )
        }
    }    
    else if `case'==3 {
        if `ncrit'==30 {
            matrix `cvmat' = (  6.840 ,  6.840 ,  8.770 ,  8.770 , 13.680 , 13.680 \ ///
                                4.290 ,  5.080 ,  5.395 ,  6.350 ,  8.170 ,  9.285 \ ///
                                3.437 ,  4.470 ,  4.267 ,  5.473 ,  6.183 ,  7.873 \ ///
                                3.008 ,  4.150 ,  3.710 ,  5.018 ,  5.333 ,  7.063 \ ///
                                2.752 ,  3.994 ,  3.354 ,  4.774 ,  4.768 ,  6.670 \ ///
                                2.578 ,  3.858 ,  3.125 ,  4.608 ,  4.537 ,  6.370 \ ///
                                2.457 ,  3.797 ,  2.970 ,  4.499 ,  4.270 ,  6.211 \ ///
                                2.384 ,  3.728 ,  2.875 ,  4.445 ,  4.104 ,  6.151 )
        }
        else if `ncrit'==35 {
            matrix `cvmat' = (  6.810 ,  6.810 ,  8.640 ,  8.640 , 13.290 , 13.290 \ ///
                                4.225 ,  5.050 ,  5.290 ,  6.175 ,  7.870 ,  8.960 \ ///
                                3.393 ,  4.410 ,  4.183 ,  5.333 ,  6.140 ,  7.607 \ ///
                                2.958 ,  4.100 ,  3.615 ,  4.913 ,  5.198 ,  6.845 \ ///
                                2.696 ,  3.898 ,  3.276 ,  4.630 ,  4.590 ,  6.368 \ ///
                                2.508 ,  3.763 ,  3.037 ,  4.443 ,  4.257 ,  6.040 \ ///
                                2.387 ,  3.671 ,  2.864 ,  4.324 ,  4.016 ,  5.797 \ ///
                                2.300 ,  3.606 ,  2.753 ,  4.209 ,  3.841 ,  5.686 )
        }
        else if `ncrit'==40 {
            matrix `cvmat' = (  6.760 ,  6.760 ,  8.570 ,  8.570 , 13.070 , 13.070 \ ///
                                4.235 ,  5.000 ,  5.260 ,  6.160 ,  7.625 ,  8.825 \ ///
                                3.373 ,  4.377 ,  4.133 ,  5.260 ,  5.893 ,  7.337 \ ///
                                2.933 ,  4.020 ,  3.548 ,  4.803 ,  5.018 ,  6.610 \ ///
                                2.660 ,  3.838 ,  3.202 ,  4.544 ,  4.428 ,  6.250 \ ///
                                2.483 ,  3.708 ,  2.962 ,  4.338 ,  4.045 ,  5.898 \ ///
                                2.353 ,  3.599 ,  2.797 ,  4.211 ,  3.800 ,  5.643 \ ///
                                2.260 ,  3.534 ,  2.676 ,  4.130 ,  3.644 ,  5.464 )
        }
        else if `ncrit'==45 {
            matrix `cvmat' = (  6.760 ,  6.760 ,  8.590 ,  8.590 , 12.930 , 12.930 \ ///
                                4.225 ,  5.020 ,  5.235 ,  6.135 ,  7.740 ,  8.650 \ ///
                                3.330 ,  4.347 ,  4.083 ,  5.207 ,  5.920 ,  7.197 \ ///
                                2.893 ,  3.983 ,  3.535 ,  4.733 ,  4.983 ,  6.423 \ ///
                                2.638 ,  3.772 ,  3.178 ,  4.450 ,  4.394 ,  5.914 \ ///
                                2.458 ,  3.647 ,  2.922 ,  4.268 ,  4.030 ,  5.598 \ ///
                                2.327 ,  3.541 ,  2.764 ,  4.123 ,  3.790 ,  5.411 \ ///
                                2.238 ,  3.461 ,  2.643 ,  4.004 ,  3.595 ,  5.225 )
        }
        else if `ncrit'==50 {
            matrix `cvmat' = (  6.740 ,  6.740 ,  8.510 ,  8.510 , 12.730 , 12.730 \ ///
                                4.190 ,  4.940 ,  5.220 ,  6.070 ,  7.560 ,  8.685 \ ///
                                3.333 ,  4.313 ,  4.070 ,  5.190 ,  5.817 ,  7.303 \ ///
                                2.873 ,  3.973 ,  3.500 ,  4.700 ,  4.865 ,  6.360 \ ///
                                2.614 ,  3.746 ,  3.136 ,  4.416 ,  4.306 ,  5.874 \ ///
                                2.435 ,  3.600 ,  2.900 ,  4.218 ,  3.955 ,  5.583 \ ///
                                2.309 ,  3.507 ,  2.726 ,  4.057 ,  3.656 ,  5.331 \ ///
                                2.205 ,  3.421 ,  2.593 ,  3.941 ,  3.498 ,  5.149 )
        }
        else if `ncrit'==55 {
            matrix `cvmat' = (  6.700 ,  6.700 ,  8.390 ,  8.390 , 12.700 , 12.700 \ ///
                                4.155 ,  4.925 ,  5.125 ,  6.045 ,  7.435 ,  8.460 \ ///
                                3.280 ,  4.273 ,  3.987 ,  5.090 ,  5.707 ,  6.977 \ ///
                                2.843 ,  3.920 ,  3.408 ,  4.623 ,  4.828 ,  6.195 \ ///
                                2.578 ,  3.710 ,  3.068 ,  4.334 ,  4.244 ,  5.726 \ ///
                                2.393 ,  3.583 ,  2.848 ,  4.160 ,  3.928 ,  5.408 \ ///
                                2.270 ,  3.486 ,  2.676 ,  3.999 ,  3.636 ,  5.169 \ ///
                                2.181 ,  3.398 ,  2.556 ,  3.904 ,  3.424 ,  4.989 )
        }
        else if `ncrit'==60 {
            matrix `cvmat' = (  6.700 ,  6.700 ,  8.460 ,  8.460 , 12.490 , 12.490 \ ///
                                4.145 ,  4.950 ,  5.125 ,  6.000 ,  7.400 ,  8.510 \ ///
                                3.270 ,  4.260 ,  4.000 ,  5.057 ,  5.697 ,  6.987 \ ///
                                2.838 ,  3.923 ,  3.415 ,  4.615 ,  4.748 ,  6.188 \ ///
                                2.568 ,  3.712 ,  3.062 ,  4.314 ,  4.176 ,  5.676 \ ///
                                2.385 ,  3.565 ,  2.817 ,  4.097 ,  3.783 ,  5.338 \ ///
                                2.253 ,  3.436 ,  2.643 ,  3.939 ,  3.531 ,  5.081 \ ///
                                2.155 ,  3.353 ,  2.513 ,  3.823 ,  3.346 ,  4.895 )
        }
        else if `ncrit'==65 {
            matrix `cvmat' = (  6.740 ,  6.740 ,  8.490 ,  8.490 , 12.400 , 12.400 \ ///
                                4.175 ,  4.930 ,  5.130 ,  5.980 ,  7.320 ,  8.435 \ ///
                                3.300 ,  4.250 ,  4.010 ,  5.080 ,  5.583 ,  6.853 \ ///
                                2.843 ,  3.923 ,  3.435 ,  4.583 ,  4.690 ,  6.143 \ ///
                                2.574 ,  3.682 ,  3.068 ,  4.274 ,  4.188 ,  5.694 \ ///
                                2.397 ,  3.543 ,  2.835 ,  4.090 ,  3.783 ,  5.300 \ ///
                                2.256 ,  3.430 ,  2.647 ,  3.921 ,  3.501 ,  5.051 \ ///
                                2.156 ,  3.334 ,  2.525 ,  3.808 ,  3.310 ,  4.871 )
        }
        else if `ncrit'==70 {
            matrix `cvmat' = (  6.670 ,  6.670 ,  8.370 ,  8.370 , 12.240 , 12.240 \ ///
                                4.125 ,  4.880 ,  5.055 ,  5.915 ,  7.170 ,  8.405 \ ///
                                3.250 ,  4.237 ,  3.947 ,  5.020 ,  5.487 ,  6.880 \ ///
                                2.818 ,  3.880 ,  3.370 ,  4.545 ,  4.635 ,  6.055 \ ///
                                2.552 ,  3.648 ,  3.022 ,  4.256 ,  4.098 ,  5.570 \ ///
                                2.363 ,  3.510 ,  2.788 ,  4.073 ,  3.747 ,  5.285 \ ///
                                2.233 ,  3.407 ,  2.629 ,  3.906 ,  3.436 ,  5.044 \ ///
                                2.138 ,  3.325 ,  2.494 ,  3.786 ,  3.261 ,  4.821 )
        }
        else if `ncrit'==75 {
            matrix `cvmat' = (  6.720 ,  6.720 ,  8.420 ,  8.420 , 12.540 , 12.540 \ ///
                                4.150 ,  4.885 ,  5.140 ,  5.920 ,  7.225 ,  8.300 \ ///
                                3.277 ,  4.243 ,  3.983 ,  5.060 ,  5.513 ,  6.860 \ ///
                                2.838 ,  3.898 ,  3.408 ,  4.550 ,  4.725 ,  6.080 \ ///
                                2.558 ,  3.654 ,  3.042 ,  4.244 ,  4.168 ,  5.548 \ ///
                                2.380 ,  3.515 ,  2.802 ,  4.065 ,  3.772 ,  5.213 \ ///
                                2.244 ,  3.397 ,  2.637 ,  3.900 ,  3.496 ,  4.966 \ ///
                                2.134 ,  3.313 ,  2.503 ,  3.768 ,  3.266 ,  4.801 )
        }
        else if `ncrit'==80 {
            matrix `cvmat' = (  6.720 ,  6.720 ,  8.400 ,  8.400 , 12.120 , 12.120 \ ///
                                4.135 ,  4.895 ,  5.060 ,  5.930 ,  7.095 ,  8.260 \ ///
                                3.260 ,  4.247 ,  3.940 ,  5.043 ,  5.407 ,  6.783 \ ///
                                2.823 ,  3.885 ,  3.363 ,  4.515 ,  4.568 ,  5.960 \ ///
                                2.548 ,  3.644 ,  3.010 ,  4.216 ,  4.096 ,  5.512 \ ///
                                2.355 ,  3.500 ,  2.787 ,  4.015 ,  3.725 ,  5.163 \ ///
                                2.236 ,  3.381 ,  2.627 ,  3.864 ,  3.457 ,  4.943 \ ///
                                2.129 ,  3.289 ,  2.476 ,  3.746 ,  3.233 ,  4.760 )
        }
    }
    else if `case'==4 {
        if `ncrit'==30 {
            matrix `cvmat' = (  5.785 ,  5.785 ,  7.040 ,  7.040 , 10.200 , 10.200 \ ///
                                4.427 ,  4.957 ,  5.377 ,  5.963 ,  7.593 ,  8.350 \ ///
                                3.770 ,  4.535 ,  4.535 ,  5.415 ,  6.428 ,  7.505 \ ///
                                3.378 ,  4.274 ,  4.048 ,  5.090 ,  5.666 ,  6.988 \ ///
                                3.097 ,  4.118 ,  3.715 ,  4.878 ,  5.205 ,  6.640 \ ///
                                2.907 ,  4.010 ,  3.504 ,  4.743 ,  4.850 ,  6.473 \ ///
                                2.781 ,  3.941 ,  3.326 ,  4.653 ,  4.689 ,  6.358 \ ///
                                2.681 ,  3.887 ,  3.194 ,  4.604 ,  4.490 ,  6.328 )
        }
        else if `ncrit'==35 {
            matrix `cvmat' = (  5.690 ,  5.690 ,  6.900 ,  6.900 ,  9.975 ,  9.975 \ ///
                                4.380 ,  4.867 ,  5.233 ,  5.777 ,  7.477 ,  8.213 \ ///
                                3.698 ,  4.420 ,  4.433 ,  5.245 ,  6.328 ,  7.408 \ ///
                                3.290 ,  4.176 ,  3.936 ,  4.918 ,  5.654 ,  6.926 \ ///
                                3.035 ,  3.997 ,  3.578 ,  4.668 ,  5.147 ,  6.617 \ ///
                                2.831 ,  3.879 ,  3.353 ,  4.500 ,  4.849 ,  6.511 \ ///
                                2.685 ,  3.785 ,  3.174 ,  4.383 ,  4.629 ,  5.698 \ ///
                                2.578 ,  3.710 ,  3.057 ,  4.319 ,  4.489 ,  5.064 )
        }
        else if `ncrit'==40 {
            matrix `cvmat' = (  5.680 ,  5.680 ,  6.870 ,  6.870 ,  9.575 ,  9.575 \ ///
                                4.343 ,  4.823 ,  5.180 ,  5.733 ,  7.207 ,  7.860 \ ///
                                3.663 ,  4.378 ,  4.360 ,  5.138 ,  5.980 ,  6.973 \ ///
                                3.264 ,  4.094 ,  3.850 ,  4.782 ,  5.258 ,  6.526 \ ///
                                2.985 ,  3.918 ,  3.512 ,  4.587 ,  4.763 ,  6.200 \ ///
                                2.781 ,  3.813 ,  3.257 ,  4.431 ,  4.427 ,  5.837 \ ///
                                2.634 ,  3.719 ,  3.070 ,  4.309 ,  4.154 ,  5.699 \ ///
                                2.517 ,  3.650 ,  2.933 ,  4.224 ,  3.971 ,  5.486 )
        }
        else if `ncrit'==45 {
            matrix `cvmat' = (  5.625 ,  5.625 ,  6.750 ,  6.750 ,  9.555 ,  9.555 \ ///
                                4.300 ,  4.780 ,  5.130 ,  5.680 ,  7.133 ,  7.820 \ ///
                                3.625 ,  4.330 ,  4.335 ,  5.078 ,  5.878 ,  6.870 \ ///
                                3.226 ,  4.054 ,  3.822 ,  4.714 ,  5.150 ,  6.280 \ ///
                                2.950 ,  3.862 ,  3.470 ,  4.470 ,  4.628 ,  5.865 \ ///
                                2.750 ,  3.739 ,  3.211 ,  4.309 ,  4.251 ,  5.596 \ ///
                                2.606 ,  3.644 ,  3.025 ,  4.198 ,  3.998 ,  5.463 \ ///
                                2.484 ,  3.570 ,  2.899 ,  4.087 ,  3.829 ,  5.313 )
        }
        else if `ncrit'==50 {
            matrix `cvmat' = (  5.570 ,  5.570 ,  6.685 ,  6.685 ,  9.320 ,  9.320 \ ///
                                4.230 ,  4.740 ,  5.043 ,  5.607 ,  7.017 ,  7.727 \ ///
                                3.573 ,  4.288 ,  4.225 ,  5.030 ,  5.805 ,  6.790 \ ///
                                3.174 ,  4.004 ,  3.730 ,  4.666 ,  5.050 ,  6.182 \ ///
                                2.905 ,  3.822 ,  3.383 ,  4.432 ,  4.557 ,  5.793 \ ///
                                2.703 ,  3.697 ,  3.149 ,  4.293 ,  4.214 ,  5.520 \ ///
                                2.550 ,  3.609 ,  2.975 ,  4.143 ,  3.983 ,  5.345 \ ///
                                2.440 ,  3.523 ,  2.832 ,  4.012 ,  3.762 ,  5.172 )
        }
        else if `ncrit'==55 {
            matrix `cvmat' = (  5.570 ,  5.570 ,  6.660 ,  6.660 ,  9.300 ,  9.300 \ ///
                                4.230 ,  4.730 ,  5.013 ,  5.547 ,  6.893 ,  7.537 \ ///
                                3.553 ,  4.238 ,  4.183 ,  4.955 ,  5.678 ,  6.578 \ ///
                                3.132 ,  3.956 ,  3.692 ,  4.582 ,  4.990 ,  6.018 \ ///
                                2.868 ,  3.782 ,  3.358 ,  4.365 ,  4.455 ,  5.615 \ ///
                                2.674 ,  3.659 ,  3.131 ,  4.206 ,  4.111 ,  5.329 \ ///
                                2.538 ,  3.560 ,  2.946 ,  4.065 ,  3.870 ,  5.171 \ ///
                                2.420 ,  3.481 ,  2.791 ,  3.950 ,  3.643 ,  5.021 )
        }
        else if `ncrit'==60 {
            matrix `cvmat' = (  5.555 ,  5.555 ,  6.630 ,  6.630 ,  9.245 ,  9.245 \ ///
                                4.203 ,  4.693 ,  4.980 ,  5.527 ,  6.780 ,  7.377 \ ///
                                3.540 ,  4.235 ,  4.180 ,  4.938 ,  5.620 ,  6.503 \ ///
                                3.130 ,  3.968 ,  3.684 ,  4.584 ,  4.928 ,  5.950 \ ///
                                2.852 ,  3.773 ,  3.323 ,  4.333 ,  4.412 ,  5.545 \ ///
                                2.653 ,  3.637 ,  3.086 ,  4.154 ,  4.013 ,  5.269 \ ///
                                2.510 ,  3.519 ,  2.900 ,  3.999 ,  3.775 ,  5.086 \ ///
                                2.392 ,  3.444 ,  2.756 ,  3.892 ,  3.584 ,  4.922 )
        }
        else if `ncrit'==65 {
            matrix `cvmat' = (  5.510 ,  5.510 ,  6.550 ,  6.550 ,  8.960 ,  8.960 \ ///
                                4.187 ,  4.660 ,  4.950 ,  5.467 ,  6.707 ,  7.360 \ ///
                                3.535 ,  4.208 ,  4.123 ,  4.903 ,  5.545 ,  6.453 \ ///
                                3.122 ,  3.942 ,  3.626 ,  4.538 ,  4.848 ,  5.842 \ ///
                                2.848 ,  3.743 ,  3.300 ,  4.280 ,  4.347 ,  5.552 \ ///
                                2.647 ,  3.603 ,  3.063 ,  4.123 ,  4.020 ,  5.263 \ ///
                                2.499 ,  3.490 ,  2.880 ,  3.978 ,  3.758 ,  5.040 \ ///
                                2.379 ,  3.406 ,  2.730 ,  3.879 ,  3.557 ,  4.902 )
        }
        else if `ncrit'==70 {
            matrix `cvmat' = (  5.530 ,  5.530 ,  6.530 ,  6.530 ,  8.890 ,  8.890 \ ///
                                4.173 ,  4.647 ,  4.930 ,  5.457 ,  6.577 ,  7.313 \ ///
                                3.505 ,  4.198 ,  4.100 ,  4.900 ,  5.448 ,  6.435 \ ///
                                3.098 ,  3.920 ,  3.600 ,  4.512 ,  4.760 ,  5.798 \ ///
                                2.832 ,  3.738 ,  3.272 ,  4.272 ,  4.293 ,  5.460 \ ///
                                2.631 ,  3.589 ,  3.043 ,  4.100 ,  3.966 ,  5.234 \ ///
                                2.485 ,  3.473 ,  2.860 ,  3.951 ,  3.720 ,  5.004 \ ///
                                2.363 ,  3.394 ,  2.711 ,  3.842 ,  3.509 ,  4.808 )
        }
        else if `ncrit'==75 {
            matrix `cvmat' = (  5.530 ,  5.530 ,  6.580 ,  6.580 ,  8.905 ,  8.905 \ ///
                                4.193 ,  4.647 ,  4.937 ,  5.443 ,  6.613 ,  7.253 \ ///
                                3.505 ,  4.213 ,  4.120 ,  4.855 ,  5.505 ,  6.298 \ ///
                                3.110 ,  3.900 ,  3.624 ,  4.488 ,  4.808 ,  5.786 \ ///
                                2.832 ,  3.717 ,  3.298 ,  4.260 ,  4.300 ,  5.377 \ ///
                                2.636 ,  3.579 ,  3.054 ,  4.079 ,  3.984 ,  5.153 \ ///
                                2.486 ,  3.469 ,  2.874 ,  3.914 ,  3.728 ,  4.954 \ ///
                                2.372 ,  3.370 ,  2.718 ,  3.807 ,  3.511 ,  4.789 )
        }
        else if `ncrit'==80 {
            matrix `cvmat' = (  3.870 ,  3.870 ,  4.725 ,  4.725 ,  6.695 ,  6.695 \ ///
                                3.113 ,  3.610 ,  3.740 ,  4.303 ,  5.157 ,  5.917 \ ///
                                2.713 ,  3.453 ,  3.235 ,  4.053 ,  4.358 ,  5.393 \ ///
                                2.474 ,  3.312 ,  2.920 ,  3.838 ,  3.908 ,  5.004 \ ///
                                2.303 ,  3.220 ,  2.688 ,  3.698 ,  3.602 ,  4.787 \ ///
                                2.180 ,  3.154 ,  2.550 ,  3.606 ,  3.351 ,  4.587 \ ///
                                2.088 ,  3.103 ,  2.431 ,  3.518 ,  3.173 ,  4.485 \ ///
                                2.017 ,  3.052 ,  2.336 ,  3.458 ,  3.021 ,  4.350 )
        }
    }    
    else if `case'==5 {
        if `ncrit'==30 {
            matrix `cvmat' = ( 10.340 , 10.340 , 12.740 , 12.740 , 18.560 , 18.560 \ ///
                                6.010 ,  6.780 ,  7.360 ,  8.265 , 10.605 , 11.650 \ ///
                                4.577 ,  5.600 ,  5.550 ,  6.747 ,  7.977 ,  9.413 \ ///
                                3.868 ,  4.965 ,  4.683 ,  5.980 ,  6.643 ,  8.313 \ ///
                                3.430 ,  4.624 ,  4.154 ,  5.540 ,  5.856 ,  7.578 \ ///
                                3.157 ,  4.412 ,  3.818 ,  5.253 ,  5.347 ,  7.242 \ ///
                                2.977 ,  4.260 ,  3.576 ,  5.065 ,  5.046 ,  6.930 \ ///
                                2.843 ,  4.160 ,  3.394 ,  4.939 ,  4.779 ,  6.821 )
        }
        else if `ncrit'==35 {
            matrix `cvmat' = ( 10.240 , 10.240 , 12.580 , 12.580 , 18.020 , 18.020 \ ///
                                5.950 ,  6.680 ,  7.210 ,  8.055 , 10.365 , 11.295 \ ///
                                4.517 ,  5.480 ,  5.457 ,  6.570 ,  7.643 ,  9.063 \ ///
                                3.800 ,  4.888 ,  4.568 ,  5.795 ,  6.380 ,  7.730 \ ///
                                3.374 ,  4.512 ,  4.036 ,  5.304 ,  5.604 ,  7.172 \ ///
                                3.087 ,  4.277 ,  3.673 ,  5.002 ,  5.095 ,  6.770 \ ///
                                2.879 ,  4.114 ,  3.426 ,  4.790 ,  4.704 ,  6.537 \ ///
                                2.729 ,  3.985 ,  3.251 ,  4.640 ,  4.459 ,  6.206 )
        }
        else if `ncrit'==40 {
            matrix `cvmat' = ( 10.160 , 10.160 , 12.510 , 12.510 , 17.910 , 17.910 \ ///
                                5.915 ,  6.630 ,  7.135 ,  7.980 , 10.150 , 11.230 \ ///
                                4.477 ,  5.420 ,  5.387 ,  6.437 ,  7.527 ,  8.803 \ ///
                                3.760 ,  4.795 ,  4.510 ,  5.643 ,  6.238 ,  7.740 \ ///
                                3.334 ,  4.438 ,  3.958 ,  5.226 ,  5.376 ,  7.092 \ ///
                                3.032 ,  4.213 ,  3.577 ,  4.923 ,  4.885 ,  6.550 \ ///
                                2.831 ,  4.040 ,  3.327 ,  4.700 ,  4.527 ,  6.263 \ ///
                                2.668 ,  3.920 ,  3.121 ,  4.564 ,  4.310 ,  5.965 )
        }
        else if `ncrit'==45 {
            matrix `cvmat' = ( 10.150 , 10.150 , 12.400 , 12.400 , 17.500 , 17.500 \ ///
                                5.880 ,  6.640 ,  7.080 ,  7.910 ,  9.890 , 10.965 \ ///
                                4.437 ,  5.377 ,  5.360 ,  6.373 ,  7.317 ,  8.720 \ ///
                                3.740 ,  4.780 ,  4.450 ,  5.560 ,  6.053 ,  7.458 \ ///
                                3.298 ,  4.378 ,  3.890 ,  5.104 ,  5.224 ,  6.696 \ ///
                                3.012 ,  4.147 ,  3.532 ,  4.800 ,  4.715 ,  6.293 \ ///
                                2.796 ,  3.970 ,  3.267 ,  4.584 ,  4.364 ,  6.006 \ ///
                                2.635 ,  3.838 ,  3.091 ,  4.413 ,  4.109 ,  5.785 )
        }
        else if `ncrit'==50 {
            matrix `cvmat' = ( 10.020 , 10.020 , 12.170 , 12.170 , 17.530 , 17.530 \ ///
                                5.780 ,  6.540 ,  6.985 ,  7.860 ,  9.895 , 10.965 \ ///
                                4.380 ,  5.350 ,  5.247 ,  6.303 ,  7.337 ,  8.643 \ ///
                                3.673 ,  4.715 ,  4.368 ,  5.545 ,  5.995 ,  7.335 \ ///
                                3.240 ,  4.350 ,  3.834 ,  5.064 ,  5.184 ,  6.684 \ ///
                                2.950 ,  4.110 ,  3.480 ,  4.782 ,  4.672 ,  6.232 \ ///
                                2.750 ,  3.944 ,  3.229 ,  4.536 ,  4.310 ,  5.881 \ ///
                                2.590 ,  3.789 ,  3.039 ,  4.339 ,  4.055 ,  5.640 )
        }
        else if `ncrit'==55 {
            matrix `cvmat' = ( 10.110 , 10.110 , 12.170 , 12.170 , 17.480 , 17.480 \ ///
                                5.800 ,  6.515 ,  6.930 ,  7.785 ,  9.800 , 10.675 \ ///
                                4.370 ,  5.303 ,  5.190 ,  6.223 ,  7.227 ,  8.340 \ ///
                                3.640 ,  4.670 ,  4.313 ,  5.425 ,  5.955 ,  7.225 \ ///
                                3.210 ,  4.294 ,  3.794 ,  4.986 ,  5.108 ,  6.494 \ ///
                                2.927 ,  4.068 ,  3.442 ,  4.690 ,  4.608 ,  5.977 \ ///
                                2.724 ,  3.893 ,  3.197 ,  4.460 ,  4.230 ,  5.713 \ ///
                                2.573 ,  3.760 ,  2.989 ,  4.271 ,  3.955 ,  5.474 )
        }
        else if `ncrit'==60 {
            matrix `cvmat' = ( 10.030 , 10.030 , 12.200 , 12.200 , 17.020 , 17.020 \ ///
                                5.765 ,  6.500 ,  6.905 ,  7.735 ,  9.585 , 10.420 \ ///
                                4.350 ,  5.283 ,  5.190 ,  6.200 ,  7.057 ,  8.243 \ ///
                                3.645 ,  4.678 ,  4.298 ,  5.445 ,  5.835 ,  7.108 \ ///
                                3.200 ,  4.310 ,  3.772 ,  4.956 ,  5.066 ,  6.394 \ ///
                                2.912 ,  4.047 ,  3.407 ,  4.632 ,  4.505 ,  5.920 \ ///
                                2.709 ,  3.856 ,  3.137 ,  4.393 ,  4.117 ,  5.597 \ ///
                                2.551 ,  3.716 ,  2.956 ,  4.230 ,  3.870 ,  5.338 )
        }
        else if `ncrit'==65 {
            matrix `cvmat' = (  9.970 ,  9.970 , 11.960 , 11.960 , 16.850 , 16.850 \ ///
                                5.755 ,  6.470 ,  6.890 ,  7.660 ,  9.475 , 10.515 \ ///
                                4.353 ,  5.257 ,  5.137 ,  6.173 ,  7.013 ,  8.230 \ ///
                                3.638 ,  4.643 ,  4.268 ,  5.415 ,  5.795 ,  7.053 \ ///
                                3.196 ,  4.262 ,  3.732 ,  4.920 ,  4.974 ,  6.378 \ ///
                                2.897 ,  4.022 ,  3.372 ,  4.613 ,  4.482 ,  5.923 \ ///
                                2.690 ,  3.830 ,  3.137 ,  4.363 ,  4.111 ,  5.586 \ ///
                                2.531 ,  3.685 ,  2.924 ,  4.206 ,  3.835 ,  5.339 )
        }
        else if `ncrit'==70 {
            matrix `cvmat' = ( 10.020 , 10.020 , 12.000 , 12.000 , 16.660 , 16.660 \ ///
                                5.765 ,  6.455 ,  6.860 ,  7.645 ,  9.370 , 10.320 \ ///
                                4.330 ,  5.243 ,  5.110 ,  6.190 ,  6.873 ,  8.163 \ ///
                                3.615 ,  4.635 ,  4.235 ,  5.363 ,  5.663 ,  6.953 \ ///
                                3.182 ,  4.258 ,  3.720 ,  4.904 ,  4.922 ,  6.328 \ ///
                                2.893 ,  4.008 ,  3.368 ,  4.590 ,  4.428 ,  5.898 \ ///
                                2.683 ,  3.807 ,  3.107 ,  4.343 ,  4.070 ,  5.534 \ ///
                                2.519 ,  3.669 ,  2.913 ,  4.168 ,  3.774 ,  5.248 )
        }
        else if `ncrit'==75 {
            matrix `cvmat' = ( 10.030 , 10.030 , 12.080 , 12.080 , 16.610 , 16.610 \ ///
                                5.765 ,  6.470 ,  6.880 ,  7.675 ,  9.325 , 10.325 \ ///
                                4.323 ,  5.273 ,  5.140 ,  6.153 ,  6.930 ,  8.027 \ ///
                                3.618 ,  4.630 ,  4.253 ,  5.333 ,  5.698 ,  6.970 \ ///
                                3.182 ,  4.248 ,  3.724 ,  4.880 ,  4.932 ,  6.224 \ ///
                                2.890 ,  3.993 ,  3.382 ,  4.567 ,  4.393 ,  5.788 \ ///
                                2.681 ,  3.800 ,  3.111 ,  4.310 ,  4.060 ,  5.459 \ ///
                                2.530 ,  3.648 ,  2.915 ,  4.143 ,  3.768 ,  5.229 )
        }
        else if `ncrit'==80 {
            matrix `cvmat' = (  9.960 ,  9.960 , 12.060 , 12.060 , 16.600 , 16.600 \ ///
                                5.725 ,  6.450 ,  6.820 ,  7.670 ,  9.170 , 10.240 \ ///
                                4.307 ,  5.223 ,  5.067 ,  6.103 ,  6.730 ,  8.053 \ ///
                                3.588 ,  4.605 ,  4.203 ,  5.320 ,  5.620 ,  6.908 \ ///
                                3.160 ,  4.230 ,  3.678 ,  4.840 ,  4.890 ,  6.164 \ ///
                                2.867 ,  3.975 ,  3.335 ,  4.535 ,  4.375 ,  5.703 \ ///
                                2.657 ,  3.776 ,  3.077 ,  4.284 ,  4.000 ,  5.397 \ ///
                                2.504 ,  3.631 ,  2.885 ,  4.111 ,  3.728 ,  5.160 )
        }
    }

    matrix rownames `cvmat' = k_0 k_1 k_2 k_3 k_4 k_5 k_6 k_7
    matrix colnames `cvmat' = [I_0]:L_1   [I_1]:L_1    [I_0]:L_05  [I_1]:L_05    [I_0]:L_01  [I_1]:L_01

    return local  stat    F
    return scalar case  = `case'
    return matrix cvmat = `cvmat'
    
end

*** --------------------------------- MATA ------------------------------------------------

mata:
    mata set matastrict on
    
    real scalar _ardl_getn(real scalar n , | real vector nvec) {

        real matrix i , w

        if (args()==1) nvec = range(30, 80, 5)'
        minindex(abs(n:-(range(30, 80, 5)')), 1, i , w)
        return(nvec[i[1]])  // if there are ties between minimiums, returns first one (i.e. the smaller value in nvec)
    }

end



