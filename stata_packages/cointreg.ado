*!version 2011-July-13, Qunyong Wang, brynewqy@nankai.edu.cn
program cointreg, eclass sortpreserve
version 11.0
if !replay() {
	syntax varlist(ts fv) [if] [in] ,  /// 
	[ est(string) noCONStant EQTrend(integer 0) EQDet(varlist) XTrend(integer 0) XDet(varlist) ///
	diff stage(integer 1) ///
	dlead(integer 1) dlag(integer 1) dic(string) DMAXorder(integer 0)  ///
		dvar(varlist ts fv) dvce(string) noDADJdof  ///
	noDIVN dof(integer 0) vic(string) vlag(integer 0) noVADJdof ///
	KERNel(string) BWIDth(real 0) bmeth(string) blag(integer 0) BTRUnc ///
	Level(real 95) ]

	marksample touse
	markout `touse' `dvar'
	if `eqtrend'>=1 {
		local eqnames "`eqnames' linear"
		if `eqtrend'>=2 {
			local eqnames "`eqnames' quadratic"
		}
	}
	if "`constant'"=="" local eqnames "`eqnames' _cons" 
	else local eqtrend = -1
	
	// extract names of independent
	* variable of dependent
	gettoken yname xnamea: varlist
	capture _fv_check_depvar `yname'
	if _rc==0 {
		tempvar y
		qui gen `y'=`yname'  if `touse'
	}
	else {
		fvrevar `yname' if `touse'
		local y "`r(varlist)'"
	}
	
	* variable of independent
	fvexpand `xnamea' if `touse'
	local vnames "`r(varlist)'"
	fvrevar `xnamea' if `touse'
	local vs "`r(varlist)'"
	qui _rmcoll `vs' , `constant' expand
	local vs2 "`r(varlist)'"
	local i=1
	foreach v of local vs2 {
		if !strmatch("`v'","*o.*") {
			local pos "`pos' 0"
			local vn: word `i' of `vnames'
			local xnames "`xnames' `vn'"
			local vx: word `i' of `vs'
			capture _fv_check_depvar `vx'
			if _rc==0 {
				tempvar x`i'
				qui gen `x`i''=`vx' if `touse'
				local xs "`xs' `x`i''"
			}
			else {
				fvrevar `vx' if `touse'
				local xs "`xs' `r(varlist)'"
			}
		}
		else {
			local pos "`pos' 1"  // 1 if omitted;
		}
		local i=`i'+1
	}	
	local kx: word count `xs'
			
	// default cases and error checking
	if ("`est'"=="") local est = "fmols"
	local est = lower("`est'")
	local elist = "fmols ccr dols"
	local ifev : list est in elist
	if (!`ifev') {
		dis as err "the estimation method in est() must be one of (fmols ccr dols)!"
		exit 198
	}

	if ("`est'"=="dols") {
		if (`dlag'>=0 & `dlead'<0) {
			dis as err "dlead() can't be negative for dols estimation"
			exit 198
		}
	}
	else {
		if (`xtrend'<`eqtrend') {
			local xtrend = `eqtrend'
		}
	}
	
	if ("`dvce'"=="") local dvce = "rescaled"
	local dvce = lower("`dvce'")
	local dlist = "rescaled hac ols"
	local ifdv : list dvce in dlist
	if (!`ifdv') {
		dis as err "the type of covariance matrix in dvce() is not specified correctly!"
		exit 198
	}

	// some options which may be place in the syntax
	local vconstant = "novconstant"  // VCONStant
	*local vadjdof = "novadjdof" // noDADJdof 
	*local dadjdof = "nodadjdof" // noDADJdof 
	*local divn = ""  // noDIVN, if division by obs

	local kernel = lower("`kernel'")
	if ("`kernel'"=="") local kernel="bartlett"
	local ifdiff = cond("`diff'"!="",1,0)  // first regress, then difference in FMOLS, CCR
	local ifdivn = cond("`divn'"!="",0,1)  // default: division by n
	local ifvcst = cond("`vconstant'"!="", 1, 0)  // default = 0, no constant in VAR
	local ifvadj = cond("`vadjdof'"!="",0,1) // default=1, adjust the dof of VAR
	local ifdadj = cond("`dadjdof'"!="",0,1) // default=1, adjust the dof in DOLS regression
	local ifbtru = cond("`btrunc'"!="", 1, 0)  // default=0, no truncation to integer

	// cointegration regression
	mata: cointreg("`y'","`xs'","`touse'", "`eqdet'", "`xdet'", `eqtrend', `xtrend', "`est'", `ifdiff', `stage', `dlead', `dlag', strlower("`dic'"), `dmaxorder', "`dvar'", "`dvce'", `ifdadj', `ifdivn', `dof', strlower("`vic'"), `vlag', `ifvcst', `ifvadj', strlower("`kernel'"), `bwidth', strlower("`bmeth'"), `blag', `ifbtru')
	local eqnames="`xnames' `eqnames'"
	matrix rownames `beta'=`yname'
	matrix colnames `beta'=`eqnames'
	matrix rownames `betav'=`eqnames'
	matrix colnames `betav'=`eqnames'

	// save results	
	ereturn post `beta' `betav', esample(`touse') depname(`yname')
	ereturn scalar N = `n'
	ereturn scalar r2 = `r2'
	ereturn scalar r2_a = `r2a'
	ereturn scalar rmse = `rmse'
	ereturn scalar lrse = `lrse'
	ereturn scalar rss = `rss'
	ereturn scalar tss = `tss'
	/*
	ereturn scalar mss = `mss'
	ereturn scalar df_r = `df_r'
	ereturn scalar df_m = `df_m'
	ereturn scalar F = `F'
	ereturn scalar Fprob = `Fprob'
	*/
	ereturn local eqdet = "`eqdet'"
	ereturn local xdet = "`xdet'"
	ereturn scalar eqtrend = `eqtrend'
	ereturn scalar xtrend = `xtrend'

	if "`est'"=="dols" {
		ereturn scalar dlead = `dlead'
		ereturn scalar dlag = `dlag'
		ereturn local vcetype = proper("`dvce'")
		if "`dic'"=="" {
			local dic="user"
		}
		ereturn local dic = "`dic'"
	}
	ereturn local kernel = "`kernel'"
	if "`kernel'"!="none" {
		ereturn local bmeth = "`bmeth'"
		ereturn scalar bwidth = `bwidth'
	}
	if ("`vic'"=="") {
		local vic="user"
	}
	ereturn local vic = "`vic'"
	ereturn scalar vlag = `vlag'
	ereturn local est "`est'"
	
	ereturn local cmdline "cointreg `0'"
	ereturn local cmd "cointreg"
}
else {
	if "`e(cmd)'"!="cointreg" error 301
	syntax [, Level(real 95) ]
}
_cointdisp, level(`level')

end

program _cointdisp
syntax [, level(real 95) ]
	if "`e(cmd)'"!="cointreg" {
		error 301
	}
	local eqc = 23
	local loc = 29
	dis ""
	if "`e(est)'"=="dols" local vm = "AR"
	else local vm = "VAR"
	dis in gr "Cointegration regression (" in gr upper("`e(est)'") in gr "):"_n
	dis in gr "`vm' lag(`e(vic)')"  _col(`eqc') " = " _col(`loc') in ye cond("`e(vlag)'"=="", ".", "`e(vlag)'")  ///
		_col(49) in gr "Number of obs" _col(67) "=" ///
		_col(70) in ye %9.0f e(N)
	dis in gr "Kernel" _col(`eqc') " = " _col(`loc') in ye cond("`e(kernel)'"=="", ".", "`e(kernel)'")   /// 
		_col(49) in gr "R2" _col(67) "=" ///
		_col(70) in ye %9.0g e(r2)
	if "`e(bmeth)'"!="" local bauto = "(`e(bmeth)')"
	dis in gr "Bandwidth`bauto'"  _col(`eqc') " = " _col(`loc')  in ye %-6.4f e(bwidth) ///
		_col(49) in gr "Adjusted R2" _col(67) "=" ///
		_col(70) in ye %9.0g e(r2_a) 
	if "`e(est)'"=="dols" {
		if (`e(dlag)'>=0) {
			dis in gr in gr "DOLS lag(`e(dic)')"  _col(`eqc') " = " _col(`loc') in ye %-4.0f e(dlag) _c
		}
		else {
			dis in gr in gr "DOLS lag(lead)"  _col(`eqc') " = " _col(`loc') in ye "static" _c
		}
	}
		dis _col(49) in gr "S.e." _col(67) "=" ///
			_col(70) in ye %9.0g e(rmse) 

	/*dis in gr _col(49) in gr "F(" in ye e(df_m) in gr "," ///
		in ye e(df_r) in gr")" _col(67) "=" _col(70) in ye %9.0g e(F) 
	*/
	if "`e(est)'"=="dols" {
		if (`e(dlag)'>=0) {
			dis in gr in gr "DOLS lead"  _col(`eqc') " = " _col(`loc')  in ye %-4.0f e(dlead) _c
		}
	}
	if ( "`est'"!="dols" | ("`est'"=="dols" & "`e(dvce)'"=="rescaled") ) {
		dis _col(49) in gr "Long run S.e." _col(67) "=" ///
			_col(70) in ye %9.0g e(lrse) 
	}
	/*dis in gr _col(49) in gr "Prob(F<stat)" _col(67) "=" ///
		_col(73) in ye %6.4f e(Fprob) 
	*/
	_coef_table, level(`level')
end
