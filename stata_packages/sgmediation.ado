*! version 1.11 -- 2/14/12 -- implement prefix option
*! version 1.9 -- 10/28/11 -- (improve formatting)
*! version 1.8 -- 10/19/11 -- (bootstrap option removed)
*! version 1.7 -- 10/14/11 -- (ratio of total to direct)
*! version 1.6 -- 9/27/11 -- (bug fix in sgboot.ado)
*! version 1.5 -- 3/2/11 
*! version 1.4 -- 4/29/10 --  
*! version 1.3 -- 10/3/06 -- (bug fix)
*! version 1.2 -- 9/8/06 -- (bug fix)
*! version 1.1.1 -- 5/17/06 -- 
*! verion 1.0 -- 2/28/05 -- pbe
program define sgmediation, rclass
/* sobel-goodman mediation tests */
version 9.0
syntax varlist(max=1) [if] [in], iv(varlist numeric max=1) ///
   mv(varlist numeric max=1) [ cv(varlist numeric) quietly ///
   level(integer 95) prefix(string)]
marksample touse
markout `touse' `varlist' `mv' `iv' `cv'
tempname coef emat

display
`quietly' {
 display as text "Model with dv regressed on iv (path c)"
 `prefix' regress `varlist' `iv' `cv' if `touse'
 local ccoef=_b[`iv']
 local cse =_se[`iv']

 display
 display "Model with mediator regressed on iv (path a)"
 `prefix' regress `mv' `iv' `cv' if `touse'

 local acoef=_b[`iv']
 local ase  =_se[`iv']
 local avar =_se[`iv']^2

 display
 display "Model with dv regressed on mediator and iv (paths b and c')"
 `prefix' regress `varlist' `mv' `iv' `cv' if `touse'
}

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
display as txt "                     Coef         Std Err     Z           P>|Z|"
display as txt "Sobel               " as res `sobel' _skip(4) `serr'  %8.4g ///
`stest', _skip(5) 2*(1-norm(abs(`stest')))
display as txt "Goodman-1 (Aroian)  " as res `sobel' _skip(4) `g1err' %8.4g ///
`good1', _skip(5) 2*(1-norm(abs(`good1')))
display as txt "Goodman-2           " as res `sobel' _skip(4) `g2err' %8.4g ///
`good2', _skip(5) 2*(1-norm(abs(`good2')))
display
display as txt _col(21) "Coef" _col(31) "Std Err" _col(42) "Z" _col(53) "P>|Z|"
display as txt "a coefficient   = " as res %8.0g `acoef'  "  " %8.0g `ase' "  " %8.0g `acoef'/`ase'  _col(50) %8.0g 2*(1-norm(abs(`acoef'/`ase')))
display as txt "b coefficient   = " as res %8.0g `bcoef'  "  " %8.0g `bse' "  " %8.0g `bcoef'/`bse'  _col(50) %8.0g 2*(1-norm(abs(`bcoef'/`bse')))
display as txt "Indirect effect = " as res %8.0g `sobel'  "  " %8.0g `serr' "  " %8.0g `stest'       _col(50) %8.0g 2*(1-norm(abs(`stest')))
display as txt "  Direct effect = " as res %8.0g `direff' "  " %8.0g `dse' "  " %8.0g `direff'/`dse' _col(50) %8.0g 2*(1-norm(abs(`direff'/`dse')))
display as txt "   Total effect = " as res %8.0g `ccoef'  "  " %8.0g `cse' "  " %8.0g `ccoef'/`cse'  _col(50) %8.0g 2*(1-norm(abs(`ccoef'/`cse')))
display
display as txt "Proportion of total effect that is mediated: ", as res `toteff'
display as txt "Ratio of indirect to direct effect:          ", as res `ratio'
display as txt "Ratio of total to direct effect:             ", as res `t2d'

return scalar ind_eff = `sobel'
return scalar dir_eff = `direff'
return scalar tot_eff = `ccoef'
return scalar a_coef  = `acoef'
return scalar b_coef  = `bcoef'
return scalar ind2tot = `toteff'
return scalar ind2dir = `ratio'
return scalar tot2dir = `t2d'

end




