*! tvgc_boot v1.0 JOtero 01may2020
*! modified from NEWtvgc0.ado  cfb 18nov2020
*! remove prefix, matrix options
*! v1.1 cfb 23dec2020 added check for available obs

capture program drop tvgc_boot
// do not clear mata!
program tvgc_boot, rclass 
version 14

syntax varlist(min=2 numeric ts) [if] [in] [, ///
											TREND ///
											p(integer -1) ///
											d(integer -1) ///
											WINdow(integer -1) ///
											BOOT(integer -1) ///
											SEED(integer -1) ///
											SIZEcontrol(integer 12) ///
											ROBUST ///
											noPRINT]
										
marksample touse
markout `touse' `tvar'
quietly tsreport if `touse'
if r(N_gaps) {
	display in red "sample may not contain gaps"
	exit
}
if `p'==-1 {
   local p = 2
}
local pp1 = `p'+1
if `d'==-1 {
   local d = 1
}
loc vce 0
if "`robust'" != "" {
		loc vce 1
}

tempvar en trd

// apply touse
quietly gen `en' = _n if `touse'
quietly gen `trd' = sum(`touse') 
local lastobs  = `trd'[_N]    

if `window'<=0 {
	local wwid = floor(0.2*`lastobs')
}
else if `window'>0 {
	local wwid = `window'
}
/* RELOCATE BELOW
if `wwid'>`lastobs' {
	display in red "initial window exceeds available observations"
	exit
}
*/
// set in tvgc.ado
// if  `boot'!=-1 {
//    local bootrepl = 99 
// }
if `seed'!=-1 {
   local seednum = `seed'
   set seed `seednum'
}
if  `sizecontrol'!=-1 {
   local sizewin = `lastobs'-`wwid' 
}

local depvar : word 1 of `varlist'
local xvars : list varlist - depvar

local numvars  : word count `varlist'
local numxvars : word count `xvars'

local case = cond("`trend'" == "", 1, 2)

su `en' if `trd'>0 & !mi(`trd') & `touse', mean
loc first = `r(min)'
loc last = `r(max)' - `wwid'
loc full = `r(max)'

if (`d'>0) {
	local pp1 = `p' + 1
	local ppd = `p' + `d'
}
local ppd1 = `p' + `d' + 1

if `ppd1'+`wwid'+`sizecontrol'-1 >`lastobs' {
	display in red "initial window+sizecontrol exceeds available observations"
	error 498
}

local numvars : word count `varlist'

loc bootv
forv i=1/`numvars' {
	tempvar indx`i' beps`i' boot`i'
	qui {
	g `indx`i'' = .
	g `beps`i'' = .
	g `boot`i'' = .
	}
	loc bootv "`bootv' `boot`i''"
}

// set up BS return matrix
	loc nstat = 3 * (`numvars' - 1)
	mata: bsetup(`boot',`nstat')

forvalues i = 2/`numvars' {
	local lconstraints ""
	local gcvar : word `i' of `varlist'
	constraint drop
	forvalues ii = 1/`p' {
		local  lconstraints `lconstraints' `ii'
		constraint `ii' [`depvar'] l`ii'.`gcvar'
	}

// apply touse to sample

	qui sureg (`varlist' = l(1/`p').(`varlist')) if `touse', constraint("`lconstraints'") notable
	loc T = e(N)
	forv j=1/`numvars' {
		tempvar xb`j' e`j' 
		qui predict double `xb`j'', equation(#`j')
		qui predict double `e`j'', equation(#`j')
	}	

// bootstrap loop
	forvalues b = 1/`boot' {
		forv j=1/`numvars' {
			qui replace `indx`j'' = runiformint(`pp1',`T')
			qui replace `beps`j'' = `e`j''[`indx`j'']
// apply to only subset of obs 
			qui replace `boot`j'' = `xb`j'' + `beps`j'' in `ppd1'/`=`ppd1'+`wwid' + (`sizecontrol'-1)'
//			su `boot`j''
		}
// now do test on the obs specified in size option
		tvgc0 `bootv' if !mi(`boot1'), p(2) d(1) wind(`wwid') rhs(`i') rep(`b') `robust' // trend
	}
// end of bootstrap loop for one RHS var		
}
// end loop over RHS vars

end

mata:
void bsetup(real boot, real nstat)
{
 external real matrix bsmat
 bsmat = J(boot,nstat,.)
}
end

