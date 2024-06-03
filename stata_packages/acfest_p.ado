*! version jul2015
* M. Manjon & J. Mañez
* Created: 20150302
*! version 1.0.0 20150524                                     
*  predict after acfest (based on levpet_p)

capture program drop acfest_p
program define acfest_p
version 13
      
	syntax newvarname [if] [in], omega
	tempname beta
	mat `beta' = e(b)
	tempvar rhs lhs1
	mat score double `rhs' = `beta'
	local lhs `e(depvar)'
	qui gen double `lhs1' = `lhs' if `lhs'!=. 
	qui gen double `varlist' = `lhs1' - `rhs' `if' `in'
   
end
   

