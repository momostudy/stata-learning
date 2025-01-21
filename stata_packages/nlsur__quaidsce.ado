*! version 1.1.1  25jan2021
* Not to be called alone; for use with -quaidsce-

program nlsur__quaidsce

	version 12
	
	syntax varlist if, at(name) lnexp(varname) lnp(varlist)		///
		cdfi(varlist) pdfi(varlist) a0(real) [ noQUADratic noCENSOR DEMOGRAPHICS(varlist) ]
	
	tempvar touse
	qui gen byte `touse' = 0
	qui replace `touse' = 1 `if'

	local neq : word count `varlist'
		if "`censor'" == "" {
		local neqn = `neq'
		}
		else {
		local neqn = `neq'+1
		}
	local ndemo : word count `demographics'
	
	mata:_quaidsce__expshrs("`varlist'", "`touse'", "`lnexp'",	///
		"`lnp'", "`cdfi'", "`pdfi'",  `neqn', `ndemo', `a0', "`quadratic'", "`censor'", "`at'",	///
		"`demographics'")
	
end
exit
