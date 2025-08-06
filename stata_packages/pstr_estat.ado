
program pstr_estat, rclass
    version 16
    if "`e(cmd)'" != "pstr" {
        error 301
    }
    syntax anything , [ sxnum(integer 1)  * ]
    // gettoken anything rest : 0, parse(" ,")
    if "`anything'"=="linear" {
		if !mi("`rest'") gettoken comma sxalt : rest, parse(",")
		local sxalt = strtrim("`sxalt'")
		local ksxalt: word count `sxalt'
		local kstr = e(kstr)
		if !mi("`sxalt'") {
			if `ksxalt'!= `kstr' {
				dis as error "number of specified variables should be equal to number of transition variables"
				exit(198)
			}
		}

		local y = e(depvar)
		local ix = e(ix)
		local cst = e(cstlist)
		// expression used for linearity test
			forvalues i=1/`kstr' {
				local rx = e(rx`i')
				if mi("`sxalt'") {
					local sx = e(sx`i')
				}
				else {
					local sx: word `i' of `sxalt'
				}
				local c: word `i' of `cst'
				if `c'==0 {
					local vars1 "`vars1' c.`sx'"
				}
				local vars1 "`vars1' c.`sx'#c.(`rx') "
			}
			
			forvalues i=1/`kstr' {
				local rx = e(rx`i')
				if mi("`sxalt'") {
					local sx = e(sx`i')
				}
				else {
					local sx: word `i' of `sxalt'
				}
				local c: word `i' of `cst'
				if `c'==0 {
					local vars2 "`vars2' c.`sx' c.`sx'#c.`sx'"
				}
				local vars2 "`vars2' c.`sx'#c.(`rx')  c.`sx'#c.`sx'#c.(`rx')"
			}
			
			forvalues i=1/`kstr' {
				local rx = e(rx`i')
				if mi("`sxalt'") {
					local sx = e(sx`i')
				}
				else {
					local sx: word `i' of `sxalt'
				}
				local c: word `i' of `cst'
				if `c'==0 {
					local vars3 "`vars3' c.`sx' c.`sx'#c.`sx' c.`sx'#c.`sx'#c.`sx'"
				}
				local vars3 "`vars3' c.`sx'#c.(`rx')  c.`sx'#c.`sx'#c.(`rx') c.`sx'#c.`sx'#c.`sx'#c.(`rx')"
			}
			
			forvalues i=1/`kstr' {
				local rx = e(rx`i')
				if mi("`sxalt'") {
					local sx = e(sx`i')
				}
				else {
					local sx: word `i' of `sxalt'
				}
				local c: word `i' of `cst'
				if `c'==0 {
					local vars4 "`vars4' c.`sx' c.`sx'#c.`sx' c.`sx'#c.`sx'#c.`sx' c.`sx'#c.`sx'#c.`sx'#c.`sx'"
				}
				local vars4 "`vars4' c.`sx'#c.(`rx')  c.`sx'#c.`sx'#c.(`rx') c.`sx'#c.`sx'#c.`sx'#c.(`rx') c.`sx'#c.`sx'#c.`sx'#c.`sx'#c.(`rx')"
			}
			
		// test expression used for Escribano-Jorda test
			forvalues i=1/`kstr' {
				local rx = e(rx`i')
				if mi("`sxalt'") {
					local sx = e(sx`i')
				}
				else {
					local sx: word `i' of `sxalt'
				}
				local c: word `i' of `cst'
				if `c'==0 {
					local varshol "`varshol' c.`sx' c.`sx'#c.`sx'#c.`sx'"
					local varshoe "`varshoe' c.`sx'#c.`sx'  c.`sx'#c.`sx'#c.`sx'#c.`sx'"
				}
				local varshol "`varshol' c.`sx'#c.(`rx') c.`sx'#c.`sx'#c.`sx'#c.(`rx')"
				local varshoe "`varshoe' c.`sx'#c.`sx'#c.(`rx') c.`sx'#c.`sx'#c.`sx'#c.`sx'#c.(`rx')"
			}
			
		// test expression used for Terasvirta sequential test
			forvalues i=1/`kstr' {
				local rx = e(rx`i')
				if mi("`sxalt'") {
					local sx = e(sx`i')
				}
				else {
					local sx: word `i' of `sxalt'
				}
				local c: word `i' of `cst'
				if `c'==0 {
					local tseq2 "`tseq2' c.`sx'#c.`sx'"
					local tseq3 "`tseq3' c.`sx'#c.`sx'#c.`sx'"
				}
				local tseq2 "`tseq2' c.`sx'#c.`sx'#c.(`rx')"
				local tseq3 "`tseq3' c.`sx'#c.`sx'#c.`sx'#c.(`rx')"
			}

		tempname mod
		_est hold `mod'

		// linearity test
			tempname fmat 
			matrix `fmat' = J(4,4,.)
			forvalues i=1/4 {
				qui xtreg `y' `ix' `vars`i'', fe
				qui testparm `vars`i''
				matrix `fmat'[`i',1] = r(F)
				matrix `fmat'[`i',2] = r(df)
				matrix `fmat'[`i',3] = r(df_r)
				matrix `fmat'[`i',4] = r(p)				
			}
			matrix colnames `fmat' = chi2 df1 df2 prob
			matrix rownames `fmat' = b1=0 b1=b2=0 b1=b2=b3=0 b1=b2=b3=b4=0
			matlist `fmat', cspec(& %20s | %12.4f & %6.0f  & %6.0f & %12.4g &) rspec(--&&&-) rowtitle(Ho) title("Linearity (homegeneity) test for all nonlinear parts:")

		// Escribano-Jorda test
			tempname ejmat
			matrix `ejmat' = J(2,4,.)
			qui testparm `varshol'
			matrix `ejmat'[1,1] = r(F)
			matrix `ejmat'[1,2] = r(df)
			matrix `ejmat'[1,3] = r(df_r)
			matrix `ejmat'[1,4] = r(p)				
			qui testparm `varshoe'
			matrix `ejmat'[2,1] = r(F)
			matrix `ejmat'[2,2] = r(df)
			matrix `ejmat'[2,3] = r(df_r)
			matrix `ejmat'[2,4] = r(p)
			matrix colnames `ejmat' = chi2 df1 df2 prob
			matrix rownames `ejmat' = b1=b3=0(HoL) b2=b4=0(HoE)
			matlist `ejmat', cspec(& %20s | %12.4f & %6.0f  & %6.0f & %12.4g &) rspec(--&-) rowtitle(Ho) title("Escribano-Jorda linearity test (based on 4th Taylor expansion):")
			dis as txt "Note: HoL against LSTR, HoE against ESTR"

		// Terasvirta sequential test
			tempname tvmat
			matrix `tvmat' = J(3,4,.)
			matrix `tvmat'[1,1] = `fmat'[1,1..4] 
				qui xtreg `y' `ix' `vars2', fe
				qui testparm `tseq2'
				matrix `tvmat'[2,1] = r(F)
				matrix `tvmat'[2,2] = r(df)
				matrix `tvmat'[2,3] = r(df_r)
				matrix `tvmat'[2,4] = r(p)				
				qui xtreg `y' `ix' `vars3', fe
				qui testparm `tseq3'
				matrix `tvmat'[3,1] = r(F)
				matrix `tvmat'[3,2] = r(df)
				matrix `tvmat'[3,3] = r(df_r)
				matrix `tvmat'[3,4] = r(p)				
			matrix colnames `tvmat' = chi2 df1 df2 prob
			matrix rownames `tvmat' = b1=0|b2=b3=0 b2=0|b3=0 b3=0
			matlist `tvmat', cspec(& %20s | %12.4f & %6.0f  & %6.0f & %12.4g &) rspec(--&&-) rowtitle(Ho) title("Terasvirta sequential test:")

		_est unhold `mod'
    }
	
	// nonlinearity in residual, using th as transition variable, which multiplies with all rx=(rx1, rx2,...)
    if "`anything'"=="reslinear" {
		gettoken comma sx : rest, parse(",")
		local sx = strtrim("`sx'")
		if mi("`sx'") {
			local sxlist = e(sx)
			local sx: word 1 of `sxlist'
		}
		// set trace on
		tempvar y
		qui predict `y' if e(sample), e
		local ix = e(ix)
		local kstr = e(kstr)
		local cst = e(cstlist)

		// expression used for linearity test
			local rxlist ""
			forvalues i=1/`kstr' {
				local rx = e(rx`i')
				local rxlist "`rxlist' `rx'"
			}
			local rxlist: list uniq rxlist
			if strmatch("`cst'", "*1*") {			
				local vars1 "`vars1' c.`sx'"
			}
			local vars1 "`vars1' c.`sx'#c.(`rxlist') "
			local vars2 "`vars1' c.`sx'#c.`sx'#c.(`rxlist')"
			local vars3 "`vars2' c.`sx'#c.`sx'#c.`sx'#c.(`rxlist')"
			local vars4 "`vars3' c.`sx'#c.`sx'#c.`sx'#c.`sx'#c.(`rxlist')"			
			
		// test expression used for Escribano-Jorda test
			local rxlist ""
			forvalues i=1/`kstr' {
				local rx = e(rx`i')
				local rxlist "`rxlist' `rx'"
			}
			local rxlist: list uniq rxlist
			if strmatch("`cst'", "*1*") {
				local hol "c.`sx' c.`sx'#c.`sx'#c.`sx'"
				local hoe "c.`sx'#c.`sx' c.`sx'#c.`sx'#c.`sx'#c.`sx'"
			}
			local hol "`hol' c.`sx'#c.(`rxlist') c.`sx'#c.`sx'#c.`sx'#c.(`rxlist')"
			local hoe "`hoe' c.`sx'#c.`sx'#c.(`rxlist') c.`sx'#c.`sx'#c.`sx'#c.`sx'#c.(`rxlist')"
			
		// test expression used for Terasvirta sequential test
			if strmatch("`cst'", "*1*") {
				local tseq2 "`tseq2' c.`sx'#c.`sx'"
				local tseq3 "`tseq3' c.`sx'#c.`sx'#c.`sx'"
			}
			local tseq2 "`tseq2' c.`sx'#c.`sx'#c.(`rxlist')"
			local tseq3 "`tseq3' c.`sx'#c.`sx'#c.`sx'#c.(`rxlist')"

		tempname mod
		_est hold `mod'
		
		// linearity test
			tempname fmat 
			matrix `fmat' = J(4,4,.)
			forvalues i=1/4 {
				qui xtreg `y' `ix' `vars`i'', fe
				qui testparm `vars`i''
				matrix `fmat'[`i',1] = r(F)
				matrix `fmat'[`i',2] = r(df)
				matrix `fmat'[`i',3] = r(df_r)
				matrix `fmat'[`i',4] = r(p)				
			}
			matrix colnames `fmat' = chi2 df1 df2 prob
			matrix rownames `fmat' = b1=0 b1=b2=0 b1=b2=b3=0 b1=b2=b3=b4=0
			matlist `fmat', cspec(& %20s | %12.4f & %6.0f  & %6.0f & %12.4g &) rspec(--&&&-) rowtitle(Ho) title("Linearity (homegeneity) test for all nonlinear parts:")

		// Escribano-Jorda test
			tempname ejmat
			matrix `ejmat' = J(2,4,.)
			qui testparm `hol'
			matrix `ejmat'[1,1] = r(F)
			matrix `ejmat'[1,2] = r(df)
			matrix `ejmat'[1,3] = r(df_r)
			matrix `ejmat'[1,4] = r(p)				
			qui testparm `hoe'
			matrix `ejmat'[2,1] = r(F)
			matrix `ejmat'[2,2] = r(df)
			matrix `ejmat'[2,3] = r(df_r)
			matrix `ejmat'[2,4] = r(p)
			matrix colnames `ejmat' = chi2 df1 df2 prob
			matrix rownames `ejmat' = b1=b3=0(HoL) b2=b4=0(HoE)
			matlist `ejmat', cspec(& %20s | %12.4f & %6.0f  & %6.0f & %12.4g &) rspec(--&-) rowtitle(Ho) title("Escribano-Jorda linearity test (based on 4th Taylor expansion):")
			dis as txt "Note: HoL against LSTR, HoE against ESTR"

		// Terasvirta sequential test
			tempname tvmat
			matrix `tvmat' = J(3,4,.)
			matrix `tvmat'[1,1] = `fmat'[1,1..4] 
				qui xtreg `y' `ix' `vars2', fe
				qui testparm `tseq2'
				matrix `tvmat'[2,1] = r(F)
				matrix `tvmat'[2,2] = r(df)
				matrix `tvmat'[2,3] = r(df_r)
				matrix `tvmat'[2,4] = r(p)				
				qui xtreg `y' `ix' `vars3', fe
				qui testparm `tseq3'
				matrix `tvmat'[3,1] = r(F)
				matrix `tvmat'[3,2] = r(df)
				matrix `tvmat'[3,3] = r(df_r)
				matrix `tvmat'[3,4] = r(p)				
			matrix colnames `tvmat' = chi2 df1 df2 prob
			matrix rownames `tvmat' = b1=0|b2=b3=0 b2=0|b3=0 b3=0
			matlist `tvmat', cspec(& %20s | %12.4f & %6.0f  & %6.0f & %12.4g &) rspec(--&&-) rowtitle(Ho) title("Terasvirta sequential test:")

		_est unhold `mod'
	}
	
    if "`anything'"=="pconstant" {
		qui xtset
		tempvar y sx
		local pid = r(panelvar)
		qui bysort `pid': gen `sx' = _n if e(sample)
		qui xtset
		qui predict `y' if e(sample), e
		local ix = e(ix)
		local kstr = e(kstr)
		local cst = e(cstlist)

		// expression used for linearity test
			local rxlist ""
			forvalues i=1/`kstr' {
				local rx = e(rx`i')
				local rxlist "`rxlist' `rx'"
			}
			local rxlist: list uniq rxlist
			if strmatch("`cst'", "*1*") {			
				local vars1 "`vars1' c.`sx'"
			}
			local vars1 "`vars1' c.`sx'#c.(`rxlist') "
			local vars2 "`vars1' c.`sx'#c.`sx'#c.(`rxlist')"
			local vars3 "`vars2' c.`sx'#c.`sx'#c.`sx'#c.(`rxlist')"
			local vars4 "`vars3' c.`sx'#c.`sx'#c.`sx'#c.`sx'#c.(`rxlist')"			
			
		// test expression used for Escribano-Jorda test
			local rxlist ""
			forvalues i=1/`kstr' {
				local rx = e(rx`i')
				local rxlist "`rxlist' `rx'"
			}
			local rxlist: list uniq rxlist
			if strmatch("`cst'", "*1*") {
				local hol "c.`sx' c.`sx'#c.`sx'#c.`sx'"
				local hoe "c.`sx'#c.`sx' c.`sx'#c.`sx'#c.`sx'#c.`sx'"
			}
			local hol "`hol' c.`sx'#c.(`rxlist') c.`sx'#c.`sx'#c.`sx'#c.(`rxlist')"
			local hoe "`hoe' c.`sx'#c.`sx'#c.(`rxlist') c.`sx'#c.`sx'#c.`sx'#c.`sx'#c.(`rxlist')"
			
		// test expression used for Terasvirta sequential test
			if strmatch("`cst'", "*1*") {
				local tseq2 "`tseq2' c.`sx'#c.`sx'"
				local tseq3 "`tseq3' c.`sx'#c.`sx'#c.`sx'"
			}
			local tseq2 "`tseq2' c.`sx'#c.`sx'#c.(`rxlist')"
			local tseq3 "`tseq3' c.`sx'#c.`sx'#c.`sx'#c.(`rxlist')"

		tempname mod
		_est hold `mod'
		
		// linearity test
			tempname fmat 
			matrix `fmat' = J(4,4,.)
			forvalues i=1/4 {
				qui xtreg `y' `ix' `vars`i'', fe
				qui testparm `vars`i''
				matrix `fmat'[`i',1] = r(F)
				matrix `fmat'[`i',2] = r(df)
				matrix `fmat'[`i',3] = r(df_r)
				matrix `fmat'[`i',4] = r(p)				
			}
			matrix colnames `fmat' = chi2 df1 df2 prob
			matrix rownames `fmat' = b1=0 b1=b2=0 b1=b2=b3=0 b1=b2=b3=b4=0
			matlist `fmat', cspec(& %20s | %12.4f & %6.0f  & %6.0f & %12.4g &) rspec(--&&&-) rowtitle(Ho) title("Linearity (homegeneity) test for all nonlinear parts:")

		// Escribano-Jorda test
			tempname ejmat
			matrix `ejmat' = J(2,4,.)
			qui testparm `hol'
			matrix `ejmat'[1,1] = r(F)
			matrix `ejmat'[1,2] = r(df)
			matrix `ejmat'[1,3] = r(df_r)
			matrix `ejmat'[1,4] = r(p)				
			qui testparm `hoe'
			matrix `ejmat'[2,1] = r(F)
			matrix `ejmat'[2,2] = r(df)
			matrix `ejmat'[2,3] = r(df_r)
			matrix `ejmat'[2,4] = r(p)
			matrix colnames `ejmat' = chi2 df1 df2 prob
			matrix rownames `ejmat' = b1=b3=0(HoL) b2=b4=0(HoE)
			matlist `ejmat', cspec(& %20s | %12.4f & %6.0f  & %6.0f & %12.4g &) rspec(--&-) rowtitle(Ho) title("Escribano-Jorda linearity test (based on 4th Taylor expansion):")
			dis as txt "Note: HoL against LSTR, HoE against ESTR"

		// Terasvirta sequential test
			tempname tvmat
			matrix `tvmat' = J(3,4,.)
			matrix `tvmat'[1,1] = `fmat'[1,1..4] 
				qui xtreg `y' `ix' `vars2', fe
				qui testparm `tseq2'
				matrix `tvmat'[2,1] = r(F)
				matrix `tvmat'[2,2] = r(df)
				matrix `tvmat'[2,3] = r(df_r)
				matrix `tvmat'[2,4] = r(p)		
				qui xtreg `y' `ix' `vars3', fe
				qui testparm `tseq3'
				matrix `tvmat'[3,1] = r(F)
				matrix `tvmat'[3,2] = r(df)
				matrix `tvmat'[3,3] = r(df_r)
				matrix `tvmat'[3,4] = r(p)				
			matrix colnames `tvmat' = chi2 df1 df2 prob
			matrix rownames `tvmat' = b1=0|b2=b3=0 b2=0|b3=0 b3=0
			matlist `tvmat', cspec(& %20s | %12.4f & %6.0f  & %6.0f & %12.4g &) rspec(--&&-) rowtitle(Ho) title("Terasvirta sequential test:")

		_est unhold `mod'
	}

	if "`anything'"=="stplot" {
	/*
		if !mi("`rest'") {		
			gettoken comma kopts : rest, parse(",")
		}
		if !mi("`kopts'") {
			gettoken k options:  kopts
			capture confirm integer number `k'
			if _rc>0 {
				local k=1
				local options "`kopts'"
			}
		}
		else {
			local k=1
		}
		*/
		local kstr= e(kstr) 
		if (`sxnum'>`kstr' | `sxnum'==0) {
			dis as error "sxnum() should be >0 and <= number of transition variables"
			exit(198)
		}
		local k = `sxnum'
		local sx = e(sx`k')
		local stflist = e(stflist)
		local stf: word `k' of `stflist'
		local stf = strupper("`stf'")
		local clist = e(cnum)
		local kc: word `k' of `clist'
		local c1=_b[`sx':threshold1]
		local xexp "(x-`c1')"
		local csort "`c1'"
		forvalues i=2/`kc' {
			local c`i'=_b[`sx':threshold`i']
			local csort "`csort' `c`i''"
			local xexp "`xexp'*(x-`c`i'')"
		}
			
		local gamma = exp(_b[`sx':lngamma])
		if mi("`options'") {
			local csort: list sort csort
			local cmin : word 1 of `csort'
			local cmax : word `kc' of `csort'
			tempvar stpred
			qui predict `stpred' , stf sxnum(`k')
			if "`stf'"=="ESTR" {
				qui summ `sx' if `sx'<`cmin' & `stpred'>0.999999
				local min = r(max)
				if mi(`min') {
					qui summ `sx' if `sx'<`cmin' 
					local min = r(min)
				}
				if mi(`min') {
					qui summ `sx'
					local min = r(min)
				}
				qui summ `sx' if `sx'>`cmax' & `stpred'>0.999999
				local max = r(min)
				if mi(`max') {
					qui summ `sx' if `sx'>`cmax' 
					local max = r(max)
				}
				if mi(`max') {
					qui summ `sx'
					local max = r(max)
				}
			}
			else  {
				qui summ `sx' if `sx'<`cmin' & `stpred'<0.000001
				local min = r(max)
				if mi(`min') {
					qui summ `sx' if `sx'<`cmin' 
					local min = r(min)
				}
				if mi(`min') {
					qui summ `sx'
					local min = r(min)
				}
				qui summ `sx' if `sx'>`cmax' & `stpred'>0.999999
				local max = r(min)
				if mi(`max') {
					qui summ `sx' if `sx'>`cmax' 
					local max = r(max)
				}			
				if mi(`max') {
					qui summ `sx'
					local max = r(max)
				}
			}
			local options "range(`min' `max') xtitle(`sx')"
		}
		if "`stf'"=="LSTR" {
			twoway (function y=1/(1+exp(-`gamma'*`xexp')), `options')
		}
		else if "`stf'"=="ESTR" {
			twoway (function y=1-exp(-`gamma'*(`xexp')^2), `options')
		}
		else if "`stf'"=="NSTR" {
			twoway (function y=normal(`gamma'*`xexp'), `options')
		}
		/*
		tempvar xname
		qui gen `xname' = `sx' // sort() doesn't allow ts operator
		tempvar th
		qui predict `th', stf sxnum(`k')
		if mi("`options'") {
			twoway (line `th' `sx' if inrange(`sx', `min', `max'), sort(`xname') ytitle("`stf'") xtitle("`sx'"))
		}
		else {
			twoway (line `th' `sx' if inrange(`sx', `min', `max'), sort(`xname') `options')
		}
		*/		
    }
	
	if "`anything'"=="stcoef" {
		if !mi("`rest'") {
			gettoken comma levelexp : rest, parse(",")
			tokenize "`levelexp'", parse("()")
			local level = `3'
		}
		else {
			local level = 95
		}
		local crit = invnormal(1-(1-`level'/100)/2)
		local sx = e(sx)
		tempname crg coefmat b v
		local ksx: word count `sx'
		
		local r=1
		forvalues i=1/`ksx' {
			local sname: word `i' of `sx'
			qui nlcom exp(_b[`sname':lngamma]), level(`level')
			local c = el(r(b),1,1)
			local s = sqrt(el(r(V),1,1))
			local z = `c'/`s'
			local p = 2*(1-normal(abs(`z')))
			local conflow = `c' - `crit'*`s'
			local confupp = `c' + `crit'*`s'
			matrix `coefmat' = nullmat(`coefmat') \  (`c', `s', `z', `p', `conflow', `confupp')
			local cnames "`cnames' `sname':gamma"
			if `r'>1 local vs "`vs'&"
			local ++r
		}
		matrix rownames `coefmat' = `cnames'
		matrix colnames `coefmat' =  Coef   se  z  P>|z|  CILower CIUpper
		matlist `coefmat', cspec(& %16s | %9.4f & %9.4f &  %6.2f  & %6.4f & %9.4f & %9.4f &) rspec(--`vs'-) title("Transformed coefficient confidence interval (level=`level'):")
	}

	/* both c and gamma 
	if "`anything'"=="stcoef" {
		if !mi("`rest'") {
			gettoken comma levelexp : rest, parse(",")
			tokenize "`levelexp'", parse("()")
			local level = `3'
		}
		else {
			local level = 95
		}
		local crit = invnormal(1-(1-`level'/100)/2)
		local sx = e(sx)
		local cnum = e(cnum)
		tempname crg coefmat b v
		matrix `crg' = e(crange)
		local ksx: word count `sx'
		
		local r=1
		forvalues i=1/`ksx' {
			local sname: word `i' of `sx'
			local kc: word `i' of `cnum'
			local low = el(`crg', `i', 1)
			local upp = el(`crg', `i', 2)
			forvalues j=1/`kc' {
				qui nlcom invlogit(_b[`sname':threshold`j'])*(`upp'-`low')+`low', level(`level')
				local c = el(r(b),1,1)
				local s = sqrt(el(r(V),1,1))
				local z = `c'/`s'
				local p = 2*(1-normal(abs(`z')))
				local conflow = `c' - `crit'*`s'
				local confupp = `c' + `crit'*`s'
				matrix `coefmat' = nullmat(`coefmat') \  (`c', `s', `z', `p', `conflow', `confupp')
				local cnames "`cnames' `sname':threshold`j'"
				if `r'>1 local vs "`vs'&"
				local ++r
			}
			qui nlcom exp(_b[`sname':lngamma]), level(`level')
			local c = el(r(b),1,1)
			local s = sqrt(el(r(V),1,1))
			local z = `c'/`s'
			local p = 2*(1-normal(abs(`z')))
			local conflow = `c' - `crit'*`s'
			local confupp = `c' + `crit'*`s'
			matrix `coefmat' = nullmat(`coefmat') \  (`c', `s', `z', `p', `conflow', `confupp')
			local cnames "`cnames' `sname':gamma"
			if `r'>1 local vs "`vs'&"
			local ++r
		}
		matrix rownames `coefmat' = `cnames'
		matrix colnames `coefmat' =  Coef   se  z  P>|z|  CILower CIUpper
		matlist `coefmat', cspec(& %16s | %9.4g & %9.4g &  %6.2f  & %6.4f & %9.4g & %9.4g &) rspec(--`vs'-) title("Transformed coefficient confidence interval (level=`level'):")
	}
*/

	if "`anything'"=="summ" {
		local vlist "`e(depvar)' `e(ix)' `e(rx)' `e(sx)'"
		local vname ""
		foreach v of local vlist {
			local c = strpos("`v'",".")
			local c=`c'+1
			local vname = "`vname' " + substr("`v'",`c',.)
		}
		local vlist: list uniq vname
		summ `vlist' if e(sample)
    }
	
	if "`anything'"=="ic" {
		tempname ic
		matrix `ic' = J(1,6,.)
		matrix `ic'[1,1] = e(N)
		matrix `ic'[1,2] = e(ll)
		matrix `ic'[1,3] = e(rank)
		matrix `ic'[1,4] = e(aic)
		matrix `ic'[1,5] = e(bic)
		matrix `ic'[1,6] = e(hqic)
		local rname = e(depvar)
		matrix colnames `ic' = N ll df AIC BIC HQIC
		matrix rownames `ic' = `rname'
		matlist `ic'
    }
end

