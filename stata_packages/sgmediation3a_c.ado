cap program drop sgmediation3a_c
program define sgmediation3a_c, rclass

version 15.0
syntax varlist(max=1) [if] [in], iv(varlist numeric max=1) ///
   mv(varlist numeric max=1) [ cv(varlist numeric) quietly ///
   level(integer 95) prefix(string)]
marksample touse
markout `touse' `varlist' `mv' `iv' `cv'
tempname coef emat

gl a = "a(Stkcd year) cl(Stkcd)"
gl o = "tstat bd(3) td(2) addtext(Firm FE, Yes, Year FE, Yes) "
cap erase r.doc
cap erase r.txt

display
`quietly'{
display as text "Model with dv regressed on iv (path c)"
`prefix' reghdfe `varlist' `iv' `cv' if `touse', $a
local ccoef=_b[`iv']
local cse =_se[`iv']
outreg2 using r.doc, $o 

display
display "Model with mediator regressed on iv (path a)"
`prefix' reghdfe `mv' `iv' `cv' if `touse', $a
local acoef=_b[`iv']
local ase  =_se[`iv']
local avar =_se[`iv']^2
outreg2 using r.doc, $o 

display
display "Model with dv regressed on mediator and iv (paths b and c')"
`prefix' reghdfe `varlist' `mv' `iv' `cv' if `touse', $a
outreg2 using r.doc, $o sortvar(`iv' `mv')
}
shellout using `"r.doc"'

version 9.0	
local bcoef=_b[`mv']
local bse  =_se[`mv']
local bvar =_se[`mv']^2

local sobel =(`acoef'*`bcoef')
local serr=sqrt((`bcoef')^2*`avar' + (`acoef')^2*`bvar')
local stest=`sobel'/`serr'
local g1err=sqrt((`bcoef')^2*`avar' + (`acoef')^2*`bvar' + `avar'*`bvar')
local good1=`sobel'/`g1err'
local g2err=sqrt((`bcoef')^2*`avar' + (`acoef')^2*`bvar' - `avar'*`bvar')
local good2=`sobel'/`g2err'
local direff = (`ccoef'-(`acoef'*`bcoef'))
local dse    = _se[`iv']
local toteff = `sobel'/`ccoef'
local ratio = `sobel'/`direff'
local t2d = ((`acoef'*`bcoef')+(`ccoef'-(`acoef'*`bcoef')))/`direff'

display
display as txt "Sobel-Goodman Mediation Tests"
display
display as txt _col(21) "Coef" _col(31) "Std Err" _col(42) "Z" _col(53) "P>|Z|"
display as txt "Sobel               " as res %6.3f `sobel' _skip(4) %6.3f `serr'  %8.3f ///
`stest', _skip(5) %8.3f 2*(1-normal(abs(`stest')))
display as txt "Goodman-1 (Aroian)  " as res %6.3f `sobel' _skip(4) %6.3f `g1err' %8.3f ///
`good1', _skip(5) %8.3f 2*(1-normal(abs(`good1')))
display as txt "Goodman-2           " as res %6.3f `sobel' _skip(4) %6.3f `g2err' %8.3f ///
`good2', _skip(5) %8.3f 2*(1-normal(abs(`good2')))
display
display as txt _col(21) "Coef" _col(31) "Std Err" _col(42) "Z" _col(53) "P>|Z|"
display as txt "a coefficient   = " as res %8.3f `acoef'  "  " %8.3f `ase' "  " %8.3f `acoef'/`ase'  _col(50) %8.3f 2*(1-normal(abs(`acoef'/`ase')))
display as txt "b coefficient   = " as res %8.3f `bcoef'  "  " %8.3f `bse' "  " %8.3f `bcoef'/`bse'  _col(50) %8.3f 2*(1-normal(abs(`bcoef'/`bse')))
display as txt "Indirect effect = " as res %8.3f `sobel'  "  " %8.3f `serr' "  " %8.3f `stest'       _col(50) %8.3f 2*(1-normal(abs(`stest')))
display as txt "  Direct effect = " as res %8.3f `direff' "  " %8.3f `dse' "  " %8.3f `direff'/`dse' _col(50) %8.3f 2*(1-normal(abs(`direff'/`dse')))
display as txt "   Total effect = " as res %8.3f `ccoef'  "  " %8.3f `cse' "  " %8.3f `ccoef'/`cse'  _col(50) %8.3f 2*(1-normal(abs(`ccoef'/`cse')))
display
display as txt "Proportion of total effect that is mediated: ", as res %8.3f `toteff'
display as txt "Ratio of indirect to direct effect:          ", as res %8.3f `ratio'
display as txt "Ratio of total to direct effect:             ", as res %8.3f `t2d'

return scalar ind_eff = `sobel'
return scalar dir_eff = `direff'
return scalar tot_eff = `ccoef'
return scalar a_coef  = `acoef'
return scalar b_coef  = `bcoef'
return scalar ind2tot = `toteff'
return scalar ind2dir = `ratio'
return scalar tot2dir = `t2d'

end