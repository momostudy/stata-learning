

program pstr, eclass byable(onecall)
version 16
syntax varlist(numeric ts fv) [if] [in] , [ lstr(string) estr(string) nstr(string) mata(string) vce(string) noCONSTant noLOG * ]

 // mark sample
tempvar touse
qui mark `touse' `if' `in'

tempname thvec stvec cst kvec
local rxnames ""
if !mi("`lstr'") {
	local stflist "`stflist' lstr"
	tokenize "`lstr'", parse(",")
	local sx "`1'"
	local rx "`3'"
	local const `5'
	local cnum `7'
	if mi("`const'") {
		local const = 0
	}
	if !inlist(`const', 0, 1) {
		dis as error "the 3rd argument in lstr() should be 0 or 1"
		exit(198)
	}
	local cstlist "`cstlist' `const'"
	matrix `cst' = (nullmat(`cst'), `const')
	if mi("`cnum'") {
		local cnum = 1
	}
	if !inlist(`cnum', 1, 2) {
		dis as error "the 4th argument in lstr() should be 1 or 2"
		exit(198)
	}
	local cnumlist "`cnumlist' `cnum'"
	matrix `thvec' = (nullmat(`thvec'), `cnum')
	matrix `stvec' = (nullmat(`stvec'), 1)
		
	if `const'==1 {
		_rmcoll `rx'  if `touse', constant expand
	}
	else {
		_rmcoll `rx' if `touse',  expand
	}
	local vnames = r(varlist)
	local krx = 0
	foreach v of local vnames {
		if !strmatch("`v'", "*b.*") {
			local rxnames "`rxnames' `v'"
			local rxlist "`rxlist' `v'" 
			local ++krx
		}
	}
	local sxlist "`sxlist' `sx'" 
	local krlist "`krlist' `krx'"
	matrix `kvec' = (nullmat(`kvec'), `krx')
}
if !mi("`estr'") {
	local stflist "`stflist' estr"
	tokenize "`estr'", parse(",")
	local sx "`1'"
	local rx "`3'"
	local const "`5'"
	local cnum  `7'
	if mi("`const'") {
		local const = 0
	}
	if !inlist(`const', 0, 1) {
		dis as error "the 3rd argument in estr() should be 0 or 1"
		exit(198)
	}
	local cstlist "`cstlist' `const'"
	matrix `cst' = (nullmat(`cst'), `const')
	if mi("`cnum'") {
		local cnum = 1
	}
	if !inlist(`cnum', 1, 2) {
		dis as error "the 4th argument in lstr() should be 1 or 2"
		exit(198)
	}
	local cnumlist "`cnumlist' `cnum'"
	matrix `thvec' = (nullmat(`thvec'), `cnum')
	matrix `stvec' = (nullmat(`stvec'), 2)
	
	if `const'==1 {
		_rmcoll `rx'  if `touse', constant expand
	}
	else {
		_rmcoll `rx' if `touse',  expand
	}
	local vnames = r(varlist)
	local krx = 0 
	foreach v of local vnames {
		if !strmatch("`v'", "*b.*") {
			local rxnames "`rxnames' `v'"
			local rxlist "`rxlist' `v'" 
			local ++krx
		}
	}
	local sxlist "`sxlist' `sx'" 
	local krlist "`krlist' `krx'"
	matrix `kvec' = (nullmat(`kvec'), `krx')
}
if !mi("`nstr'") {
	local stflist "`stflist' nstr"
	tokenize "`nstr'", parse(",")
	local sx "`1'"
	local rx "`3'"
	local const `5'
	local cnum  `7'
	if mi("`const'") {
		local const = 0
	}
	if !inlist(`const', 0, 1) {
		dis as error "the 3rd argument in nstr() should be 0 or 1"
		exit(198)
	}
	local cstlist "`cstlist' `const'"
	matrix `cst' = (nullmat(`cst'), `const')
	if mi("`cnum'") {
		local cnum = 1
	}
	if !inlist(`cnum', 1, 2) {
		dis as error "the 4th argument in lstr() should be 1 or 2"
		exit(198)
	}
	local cnumlist "`cnumlist' `cnum'"
	matrix `thvec' = (nullmat(`thvec'), `cnum')
	matrix `stvec' = (nullmat(`stvec'), 3)

	if `const'==1 {
		_rmcoll `rx'  if `touse', constant expand
	}
	else {
		_rmcoll `rx' if `touse',  expand
	}
	local vnames = r(varlist)
	local krx = 0
	foreach v of local vnames {
		if !strmatch("`v'", "*b.*") {
			local rxnames "`rxnames' `v'"
			local rxlist "`rxlist' `v'" 
			local ++krx
		}
	}
	local sxlist "`sxlist' `sx'" 
	local krlist "`krlist' `krx'"
	matrix `kvec' = (nullmat(`kvec'), `krx')
}
if !mi("`options'") {
	tokenize "`options'", parse("(,)")
	local str = strtrim("`1'")
	local sx = strtrim("`3'")
	local rx = strtrim("`5'")
	local const `7'
	local cnum  `9'
	local stflist "`stflist' `str'"
	if "`str'"=="lstr" matrix `stvec' = (`stvec', 1)
	else if "`str'"=="estr" matrix `stvec' = (`stvec', 2)
	else if "`str'"=="nstr" matrix `stvec' = (`stvec', 3)
	if mi("`const'") {
		local const = 0
	}
	if !inlist(`const', 0, 1) {
		dis as error "the 3rd argument in `str'() should be 0 or 1"
		exit(198)
	}
	local cstlist "`cstlist' `const'"
	matrix `cst' = (nullmat(`cst'), `const')
	if mi("`cnum'") {
		local cnum = 1
	}
	if !inlist(`cnum', 1, 2) {
		dis as error "the 4th argument in lstr() should be 1 or 2"
		exit(198)
	}
	local cnumlist "`cnumlist' `cnum'"
	matrix `thvec' = (nullmat(`thvec'), `cnum')

	if `const'==1 {
		_rmcoll `rx'  if `touse', constant expand
	}
	else {
		_rmcoll `rx' if `touse',  expand
	}
	local vnames = r(varlist)
	local krx=0
	foreach v of local vnames {
		if !strmatch("`v'", "*b.*") {
			local rxnames "`rxnames' `v'"
			local rxlist "`rxlist' `v'" 
			local ++krx
		}
	}
	local sxlist "`sxlist' `sx'" 
	local krlist "`krlist' `krx'"
	matrix `kvec' = (nullmat(`kvec'), `krx')
}

// covariance 

   _vce_parse `touse' , optlist(Robust) argoptlist(CLuster) : , vce(`vce')
    local vce        "`r(vce)'"
    local clustervar "`r(cluster)'"
    if "`vce'" == "robust" | "`vce'" == "cluster" {
        local vcetype "Robust"
    }
    if "`clustervar'" != "" {
        capture confirm numeric variable `clustervar'
        if _rc {
            display in red "invalid vce() option"
            display in red "cluster variable {bf:`clustervar'} is " ///
                "string variable instead of a numeric variable"
            exit(198)
			
        }
        sort `clustervar'
    }
 
    gettoken depvar ix : varlist
    _fv_check_depvar `depvar'
 
	if mi("`constant'") {
		_rmcoll `varlist' if `touse', constant expand
	}
	else {
		_rmcoll `varlist' if `touse',  expand
	}
	local vnames = r(varlist)
	local yixnames ""
	foreach v of local vnames {
		if !strmatch("`v'", "*b.*") {
			local yixnames "`yixnames' `v'"
		}
	}
	gettoken y ix: yixnames

	// sample
 
if "`log'"=="" local iflog=1
else local iflog=0

if "`mata'"=="" local mata = "st"

 
// matrix names
local r=1
foreach v in `yixnames' {
	if `r'>1 local cnames "`cnames' Linear:`v'"
	local ++r
}

if mi("`constant'") {
	local cnames "`cnames' Linear:_cons"
}
local ksx: word count `sxlist'

local r=1
local k=1
foreach s of local sxlist {
	local sx`k' "`s'"
	local kr: word `k' of `krlist'
	forvalues i=1/`kr' {
		local v: word `r' of `rxlist' {
		local cnames "`cnames' `s':`v'"
		local rx`k' "`rx`k'' `v'"
		local ++r
	}
	local c = el(`cst',1,`k')
	if (`c'==1) {
		local cnames "`cnames' `s':_cons"
	}

	local f = el(`thvec',1,`k')
	forvalues i=1/`f' {
		local cnames "`cnames' `s':threshold`i'"
	}
	local cnames "`cnames' `s':lngamma"
	local ++k
}

qui xtset
local pid = r(panelvar)

if "`log'"=="" local iflog=1
else local iflog=0

if "`mata'"=="" local mata = "st"

// set trace on

markout `touse' `yixnames' `sxlist' `rxlist'

mata: `mata' = xtstregress("`pid'", "`yixnames'", "`constant'", "`sxlist'", "`rxlist'", "`kvec'",  "`cst'", "`stvec'", "`thvec'", "`touse'","`vectype'", "`clustervar'", `iflog') 

matrix colnames `b' = `cnames'	
matrix colnames `cov' = `cnames'
matrix rownames `cov' = `cnames'
local ifcons = cond(mi("`constant'"), 1, 0)

// ereturn post `b' `cov', esample(`hightouse') buildfvinfo depname(`y')

	local n = scalar(n)
	ereturn post `b' `cov', esample(`touse') obs(`n') buildfvinfo depname(`y')

	ereturn scalar rank  = rank
	ereturn scalar ll  = ll
	ereturn scalar aic = aic
	ereturn scalar bic = bic
	ereturn scalar hqic = hqic
	ereturn scalar rmse = rmse
	ereturn scalar corr = corr
	ereturn scalar r2w = r2w
	ereturn scalar r2b = r2b
	ereturn scalar r2o = r2o
	ereturn scalar ifcons = `ifcons'
	ereturn local  predict "pstr_p"
	ereturn local  estat_cmd "pstr_estat"
	ereturn local  cmd    "pstr"
	ereturn local  ix = strtrim("`ix'")
	ereturn local  mata = "`mata'"
	ereturn local depname "`y'"
    ereturn local  vce       "`vce'"
    ereturn local  vcetype   "`vcetype'"
    ereturn local  clustvar  "`clustervar'"	
local ks: word count `sxlist'
ereturn scalar kstr = `ks'
forvalues i=1/`ks' {
	ereturn local sx`i' = strtrim("`sx`i''")
	ereturn local rx`i' = strtrim("`rx`i''")
}
ereturn local rx = strtrim("`rxlist'")
ereturn local sx = strtrim("`sxlist'")
ereturn local cstlist = strtrim("`cstlist'")
ereturn local stflist = strtrim("`stflist'")
ereturn local cnum = strtrim("`cnumlist'")
ereturn matrix rxnum = `kvec'
ereturn matrix thnum = `thvec'
ereturn matrix stf = `stvec'
ereturn matrix cst = `cst'
ereturn matrix crange = `crange'

	xtstdisplay

end



program xtstdisplay
	syntax [, Level(cilevel) *]
	_get_diopts diopts, `options'
	dis ""
	local s=14
	local k=15
dis as txt "Smoothing transition regression (`e(stflist)')" _n

dis as txt %-20s "log-likelihood  =  " as res %`s'.4f e(ll)    _skip(`k')  as txt %-15s "Number of obs   = " as res %12.0f e(N)
dis as txt %-20s "AIC             =  " as res %`s'.4f e(aic)   _skip(`k')  as txt %-15s "R2-within       = " as res %12.4f e(r2w)
dis as txt %-20s "BIC             =  " as res %`s'.4f e(bic)   _skip(`k')  as txt %-15s "R2-between      = " as res %12.4f e(r2b)
dis as txt %-20s "HQIC            =  " as res %`s'.4f e(hqic)  _skip(`k')  as txt %-15s "R2-overall      = " as res %12.4f e(r2o)	
ereturn disp, level(`level') `diopts'
end

