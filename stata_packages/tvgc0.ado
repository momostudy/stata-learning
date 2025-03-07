*! tvgc0 v0.01 JOtero 01may2020
*! modified from NEWtvgc0.ado  cfb 18nov2020
//  p, d, wind, rep, rhs mandatory
// remove other options; trend does not belong in DGP under H0

capture program drop tvgc0
// do not clear mata!
program tvgc0, rclass 
version 14

syntax varlist(min=2 numeric ts) [if] [in]  , ///
											P(integer) ///
											D(integer) ///
											WINdow(integer) ///
											REP(integer) ///
											RHS(integer) ///
											[ ROBUST ]
											
marksample touse
markout `touse' `tvar'

loc vce 0
if "`robust'" != "" {
		loc vce 1
}

tempvar en trd
quietly gen `en' = _n 
quietly gen `trd' = sum(`touse')
local lastobs  = `trd'[_N]    
local wwid = `window'
local depvar : word 1 of `varlist'
local xvars : list varlist - depvar
local numvars  : word count `varlist'
local numxvars : word count `xvars'
local case = cond("`trend'" == "", 1, 2)
su `en' if `trd'>0 & !mi(`trd') & `touse' , mean
loc first = 1
loc last = `r(max)' - `wwid' - `r(min)'
loc full = `r(max)' - `r(min)'

* This is to generate the variables in the lag-augmented part

if (`d'>0) {
	local pp1 = `p' + 1
	local ppd = `p' + `d'
//	local ppd1 = `ppd'+1
}
local ppd1 = `p' + `d' + 1
local numvars : word count `varlist'
mata: cmatn(`=`last'+1')

	local lagvarlistx 
	local lagvarlistz 
	forvalues i = 1/`numvars' {
		tempvar tmpvarx`i'
		local var`i' : word `i' of `varlist'
		qui gen `tmpvarx`i'' = `var`i''
	}	 	
	forvalues ii = 1/`p' {
	    forvalues i = 1/`numvars' {
			tempvar lagtmpvarx`i'_`ii'
			qui gen `lagtmpvarx`i'_`ii'' = l`ii'.`tmpvarx`i''
			local lagvarlistx `lagvarlistx' `lagtmpvarx`i'_`ii''
		}
	}
	if (`d'>0) {
		forvalues ii = `pp1'/`ppd' {
			forvalues i = 1/`numvars' {
			tempvar lagtmpvarz`i'_`ii'
				qui gen `lagtmpvarz`i'_`ii'' = l`ii'.`tmpvarx`i'' 
				local lagvarlistz `lagvarlistz' `lagtmpvarz`i'_`ii''
			}
		}
	}

loc en = `full'-`first'+1
forv t = `first'/`full' {	
	loc wo = `t' + `wwid' - 1
	forv tt = `wo'/`full' {
		mata: tvgcprep("`varlist'","`lagvarlistx'","`lagvarlistz'","`trd'",`case',`t',`tt',`ppd1',`numvars',`p',`d',`vce')
		loc i = `rhs'
		local var`i' : word `i' of `varlist'
		mata: mat_n[`t',(`tt'-`wwid'+1)] = Wstat[`i'] 			
	}
}
loc i = `rhs'
loc fc = (`rhs'-1) * 3 - 2
mata: bsload(`rep',`fc')
end

mata:

void cmatn(real dim)
{
	external real matrix mat_n
	mat_n = J(dim, dim, .)
}

void bsload(real rep, real fc) 
{
	external real matrix bsmat, mat_n
	bsmat[rep,fc] = max(mat_n[1, ])
	bsmat[rep,fc+1] = max(diagonal(mat_n))
	bsmat[rep,fc+2] = max(mat_n)
}

// tvgcprep must be defined here as well
void tvgcprep(string scalar varlist, 
              string scalar lagvarlistx,
			  string scalar lagvarlistz,
			  string scalar trend,
			  real kase,
			  real t, 
			  real tt, 
			  real ppd1, 
			  real numvars,
			  real p,
			  real d,
			  real vce)

{
	external real matrix Y, X, Z, Wstat
	external real scalar n
	st_view(Y=., ., tokens(varlist))
	Y = Y[t..tt,.]
	Y = Y[|ppd1,1 \ rows(Y),cols(Y)|]
	st_view(X=., ., tokens(lagvarlistx))
	X = X[t..tt,.]
	X = X[|ppd1,1 \ rows(X),cols(X)|]
	if (d>0) {
		st_view(Z=., ., tokens(lagvarlistz))
		Z = Z[t..tt,.]
		Z = Z[|ppd1,1 \ rows(Z),cols(Z)|]
	}
	st_view(trd=., ., tokens(trend))
	trd=trd[t..tt,.]
	trd = trd[|ppd1,1 \ rows(trd),cols(trd)|]
	n = rows(Y)
	iota=J(n,1,1)
	if (kase==1) {
		tau=iota
	} 
	else {
		tau= trd, iota
	}
	if (d==0) {
		X = X, tau
	}
	else {
		X = X, Z, tau
	}
	Wstat=J(numvars,1,.)
	y = Y[.,1]
	XpX  = quadcross(X, X)
	XpXi = invsym(XpX)
	bj = XpXi*quadcross(X, y)
	ej = y - X*bj
	ejsq = ej:^2
	sigmasq = quadsum(ejsq)/n
	if (vce==0) {
		omega = sigmasq :* XpXi
	}
	else {
		omega = XpXi * quadcross(X, ejsq, X) * XpXi
	}
	_makesymmetric(omega)
	for(j=2;j<=numvars;j++){
		R=J(p,rows(bj),0)
		R[1,j]=1
		if (p>1) {
			for(k=2;k<=p;k++) {
				R[k,(j+(k-1)*numvars)]=1
			}
		}	
	Wstat[j] = ((bj'*R')*invsym(R*omega*R')*(R*bj))	
	}
}
end




