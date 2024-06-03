*! 3.2.2   : 17Apr2018, fixed a bug that would occur when IF and BYS were used together
*! 3.2.1   : 09Nov2017, added option qc (quantile criteria) for making qunatile boundaries on a given criteria
*! Author  : Attaullah Shah: attaullah.shah@imsciences.edu.pk
*! 3.0.0   : 1Apr2017 , Added speed efficiency
*! Version : 2.0.0 	12Mar2017
*! Version : 1.0.0	 27Jun2015

cap prog drop astile
prog astile, byable(onecall) sortpreserve
syntax namelist=/exp [if] [in] [, Nquantiles(string) by(varlist) QC(string)]
marksample touse
	if "`nquantiles'" == "" {
		local nquantiles 2
	}
if "`qc'"!=""{
tempvar touse2
gen `touse2' = `qc'
}
if "`by'"!=""{
	local _byvars "`by'"
}
if "`_byvars'"!="" {
tempvar numby n first
		qui bysort `_byvars': gen  `first' = _n == 1 
		qui gen `numby'=sum(`first')  
		drop `first'
}	


	mata: fastile("`exp'", "`_byvars'", "`numby'", "`namelist'",`nquantiles', "`touse2'",  "`touse'") 
	label var `namelist' "`nquantiles' quantiles of `exp'"
	end
	
