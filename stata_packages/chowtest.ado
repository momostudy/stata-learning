*! version 2011-August-23, Q.wang@yahoo.cn
cap program drop chowtest
program define chowtest, rclass
version 11.2
syntax varlist(ts fv) [if] [in] , Group(varname) [ Restrict(varlist ts fv) Het Detail ] 
marksample touse 
markout `touse' `restrict'
gettoken dep indeps : varlist
if "`detail'"=="" local qui = "qui"
if ("`het'"!="") {
	qui  reg `varlist' `restrict' i.`group' i.`group'#c.(`indeps')
}
else {
	`qui' reg `varlist' `restrict' i.`group' i.`group'#c.(`indeps')
}
local n = e(N)
local k = e(rank) 

qui levelsof `group' if `touse', local(id)
if ("`het'"!="") {
	tempvar u v usq
	qui predict `u' if `touse', res
	qui gen `usq' = `u'^2 if `touse'
	qui gen `v' = .
	foreach i of numlist `id' {
		qui summ `usq' if (`group'==`i' & `touse')
		local s = r(sum)
		qui replace `v' = `s'/(`n'-`k') if (`group'==`i' & `touse')
	}
	`qui' reg `varlist' `restrict' i.`group' i.`group'#c.(`indeps') [aw=1/`v']
}

gettoken base ido: id


`qui' testparm i(`ido').`group' i(`ido').`group'#c.(`indeps')
local chow = r(F)
local chowp= r(p)
local df1  = r(df)
local df2  = r(df_r)

dis _n in g "Chow's Structural Change Test:" 
di as txt _col(3) "{bf:Ho: no Structural Change}"
di as txt _col(3) "Chow Test = " as res %6.2f `chow' _c
di _skip(8) as txt "P-Value > F(" `df1' " , " `df2' ") = "  as res %5.4f `chowp'

return scalar chow = r(F)
ret    scalar chowp= r(p)

end
