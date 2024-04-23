/* Sobel-Goodman mediation tests */
// Original author: Phil Ender UCLA
// Revision author: Trenton Mize (tmize@purdue.edu)
// Last date revised: 2021-12-05
program define sgmediation2, rclass
version 11.0
syntax varlist(max=1) [if] [in], iv(varlist numeric max=1) ///
   mv(varlist numeric max=1) [ cv(varlist numeric fv) Quietly ///
   level(integer 95) PREfix(string) vce(string) OPTions(string) ///
   DECimals(numlist >0 <9 integer)]
marksample touse
markout `touse' `varlist' `mv' `iv' `cv'
tempname coef emat

*Set the options
if "`decimals'" == "" {
	local dec = "3"
	}
else {
	local dec = `"`decimals'"'
	}
	
display
`quietly' {
 display in green "Model with dv regressed on iv (path c)"
 di in white "`prefix' regress `varlist' `iv' `cv', vce(`vce') `options'"
 `prefix' regress `varlist' `iv' `cv' if `touse', vce(`vce') `options'
 
	local ccoef	= _b[`iv']
	local cse 	= _se[`iv']
	local cpval = 2*(1-normal(abs(`ccoef'/`cse')))

 display
 display in green "Model with mediator regressed on iv (path a)"
 di in white "`prefix' regress `mv' `iv' `cv', vce(`vce') `options'"
 `prefix' regress `mv' `iv' `cv' if `touse', vce(`vce') `options'

	local acoef=_b[`iv']
	local ase  =_se[`iv']
	local avar =_se[`iv']^2
	local apval = 2*(1-normal(abs(`acoef'/`ase')))
	
 display
 display in green "Model with dv regressed on mediator and iv (paths b and c')"
 di in white "`prefix' regress `varlist' `mv' `iv' `cv', vce(`vce') `options'"
 `prefix' regress `varlist' `mv' `iv' `cv' if `touse', vce(`vce') `options'

	local bcoef=_b[`mv']
	local bse  =_se[`mv']
	local bvar =_se[`mv']^2
	local bpval = 2*(1-normal(abs(`bcoef'/`bse')))
 }


local aXb =(`acoef'*`bcoef')
local s_err=sqrt((`bcoef')^2*`avar' + (`acoef')^2*`bvar')
local s_zstat=`aXb'/`s_err'
local s_pval = 2*(1-normal(abs(`s_zstat')))

local ar_err=sqrt((`bcoef')^2*`avar' + (`acoef')^2*`bvar' + `avar'*`bvar')
local ar_zstat=`aXb'/`ar_err'
local ar_pval = 2*(1-normal(abs(`ar_zstat')))

local g_err=sqrt((`bcoef')^2*`avar' + (`acoef')^2*`bvar' - `avar'*`bvar')
local g_zstat=`aXb'/`g_err'
local g_pval = 2*(1-normal(abs(`g_zstat')))

local direff = (`ccoef'-(`acoef'*`bcoef'))
local dse    = _se[`iv']
local dpval = 2*(1-normal(abs(`direff'/`dse')))

local toteff = `aXb'/`ccoef'
local ratio = `aXb'/`direff'
local t2d = ((`acoef'*`bcoef')+(`ccoef'-(`acoef'*`bcoef')))/`direff'

*Create matrix to display results
matrix  sgtests = J(3,4,.)
mat 	rownames sgtests = Sobel Aroian Goodman
mat 	colnames sgtests = Est Std_err z P>|z|
mat 	sgtests [1,1] = `aXb'
mat 	sgtests [1,2] = `s_err'
mat 	sgtests [1,3] = `s_zstat'
mat 	sgtests [1,4] = `s_pval'
mat 	sgtests [2,1] = `aXb'
mat 	sgtests [2,2] = `ar_err'
mat 	sgtests [2,3] = `ar_zstat'
mat 	sgtests [2,4] = `ar_pval'
mat 	sgtests [3,1] = `aXb'
mat 	sgtests [3,2] = `g_err'
mat 	sgtests [3,3] = `g_zstat'
mat 	sgtests [3,4] = `g_pval'

matlist sgtests, ///
	title("Sobel-Goodman Mediation Tests") format(%10.`dec'f) twidth(20)

matrix  effects = J(5,4,.)
mat 	rownames effects = a_coefficient b_coefficient Indirect_effect_aXb Direct_effect_c' Total_effect_c
mat 	colnames effects = Est Std_err z P>|z|
mat 	effects [1,1] = `acoef'
mat 	effects [1,2] = `ase'
mat 	effects [1,3] = `acoef'/`ase'
mat 	effects [1,4] = `apval'
mat 	effects [2,1] = `bcoef'
mat 	effects [2,2] = `bse'
mat 	effects [2,3] = `bcoef'/`bse''
mat 	effects [2,4] = `bpval'
mat 	effects [3,1] = `aXb'
mat 	effects [3,2] = `s_err'
mat 	effects [3,3] = `s_zstat'
mat 	effects [3,4] = `s_pval'
mat 	effects [4,1] = `direff'
mat 	effects [4,2] = `dse'
mat 	effects [4,3] = `direff'/`dse'
mat 	effects [4,4] = `dpval'
mat 	effects [5,1] = `ccoef'
mat 	effects [5,2] = `cse'
mat 	effects [5,3] = `ccoef'/`cse'
mat 	effects [5,4] = `cpval'

matlist effects, ///
	title("Indirect, Direct, and Total Effects") format(%10.`dec'f) twidth(20)
	
di _newline(1)	
display as txt "Proportion of total effect that is mediated: ", as res %10.`dec'f `toteff'
display as txt "Ratio of indirect to direct effect:          ", as res %10.`dec'f `ratio'
display as txt "Ratio of total to direct effect:             ", as res %10.`dec'f `t2d'

	
*Scalars to put in returns	
return scalar ind_eff = `aXb'
return scalar dir_eff = `direff'
return scalar tot_eff = `ccoef'
return scalar a_coef  = `acoef'
return scalar b_coef  = `bcoef'
return scalar ind2tot = `toteff'
return scalar ind2dir = `ratio'
return scalar tot2dir = `t2d'
return scalar szstat = `s_zstat'
return scalar g1zstat = `ar_zstat'
return scalar g2zstat = `g_zstat'

end

