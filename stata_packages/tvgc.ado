*! tvgc v0.01 JOtero 01may2020
*! modified from NEWtvgc0.ado  cfb 18nov2020
*! v1.1 cfb 11dec2020 min #boot, validate prefix, graph options
*! v1.2 cfb 23dec2020 added preserve/restore to enable if qualifier
*! v1.3 cfb 24dec2020 added merge to retain prefix variables if selected
*! v1.4 cfb 17jan2021 added restab
*! v1.5 cfb 01mar2021 adjust handling of notitle
*! v1.5 cfb 24sep2022 remove mata clear
*! v1.5 cfb 18jan2024 requires v14 for runiformint()

capture program drop tvgc
// DISABLE mata: mata clear
program tvgc, rclass 
version 14

syntax varlist(min=2 numeric ts) [if] [in] [, ///
											TREND ///
											PREfix(string) ///
											P(integer -1) ///
											D(integer -1) ///
											WINdow(integer -1) ///
											MATRIX ///
											ROBUST ///
											BOOT(integer -1) ///
											SEED(integer -1) ///
											SIZEcontrol(integer 12) ///
											GRAPH EPS PDF ///
											noTITLE noPRINT RESTAB]

marksample touse
qui tsset
loc tsf `r(tsfmt)'
preserve
qui keep if `touse'
loc tvar `r(timevar)'
markout `touse' `tvar'
quietly tsreport if `touse'
if r(N_gaps) {
	display in red "sample may not contain gaps"
	exit
}
if `p'==-1 {
   local p = 2
}
if `d'==-1 {
   local d = 1
}
if `d' > 0 {
	loc la "LA-"
}
loc vce 0
if "`robust'" != "" {
		loc vce 1
}

tempvar en trd
quietly gen `en' = _n
quietly gen `trd' = sum(`touse')
local lastobs  = `trd'[_N] 

su `tvar' if `touse', mean
loc t1 = strofreal(`r(min)',"`tsf'")
loc t2 = strofreal(`r(max)',"`tsf'") 
   

if `window'>`lastobs' {
	display in red "initial window exceeds available observations"
	exit
}
if `window'<=0 {
	local wwid = floor(0.2*`lastobs')
}
else if `window'>0 {
	local wwid = `window'
}

// BS logic
// if  ( `boot'>0) {
local bootrepl = cond(`boot'==-1, 199, max(20,`boot')) 
// }
if `seed'!=-1 {
   local seednum = `seed'
   set seed `seednum'
}

local depvar : word 1 of `varlist'
local xvars : list varlist - depvar
local numvars  : word count `varlist'
local numxvars : word count `xvars'
local case = cond("`trend'" == "", 1, 2)

// test variable creation if selected
loc mmrg = cond("`prefix'" == "", 0, 1)
if "`prefix'" != "" {
	forvalues i = 2/`numvars' {
		local excli: word `i' of `varlist'
		confirm new var `prefix'forward_`excli'
		confirm new var `prefix'rolling_`excli' 
		confirm new var `prefix'recursive_`excli' 
	}
}

su `en' if `trd'>0 & !mi(`trd') & `touse', mean
loc first = `r(min)'
loc last = `r(max)' - `wwid'
loc full = `r(max)'

* generate the variables in the lag-augmented part

if (`d'>0) {
	local pp1 = `p' + 1
	local ppd = `p' + `d'
}
local ppd1 = `p' + `d' + 1
local numvars : word count `varlist'
forvalues i = 2/`numvars' {
	mata: mat_`i' = J(`last'+1,`last'+1,.)
}

	loc rhsv
	local lagvarlistx 
	local lagvarlistz 
	forvalues i = 1/`numvars' {
		tempvar tmpvarx`i'
		local var`i' : word `i' of `varlist'
		qui gen `tmpvarx`i'' = `var`i''
		if (`i' > 1) {
			loc rhsv "`rhsv' `var`i''"
		}
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
		forvalues i = 2/`numvars' {
			local var`i' : word `i' of `varlist'
			mata: mat_`i'[`t',(`tt'-`wwid'+1)] = Wstat[`i'] 
		}			
	}
}

local fr = `full'-`last'-1

if "`trend'" == "" {
	display as res _n "Time-varying `la'VAR Granger causality test, `t1' - `t2'"
}
else if "`trend'" == "trend" {
	display as res _n "Time-varying `la'VAR Granger causality test including trend, `t1' - `t2'"
}
// set trace on

mata: gcres = J(`=`numvars'-1',3, .)

	loc wn =`sizecontrol' * 6
	tvgc_boot `varlist', `trend' p(`p') d(`d') boot(`bootrepl') window(`wn') sizecontrol(`sizecontrol')
	mata: tvgc_cv()

forvalues i = 2/`numvars' {
	local excli: word `i' of `varlist'
	loc i1 = `i'-1
	
	mata: tvgcres(`i1', mat_`i')
	
	if "`prefix'" != "" {
		qui gen `prefix'forward_`excli' = .
		qui gen `prefix'rolling_`excli' = .
		qui gen `prefix'recursive_`excli' = .
		loc vn `prefix'forward_`excli' `prefix'rolling_`excli' `prefix'recursive_`excli'
		mata: st_view(v`i'=.,((`fr'+1)::`full'),tokens(st_local("vn")))
		mata: v`i'[.,.]= mat_`i'[1,.]', diagonal(mat_`i'), colmax(mat_`i')'

//		set trace on
		
// graph only available with prefix
	if "`graph'" != "" {
		loc t1g "Forward expanding Wald test"
		loc t2g "Rolling Wald test"
		loc t3g "Recursive expanding Wald test"
        lab var `tvar' " "
        loc j 0
		tempvar l90 l95
		qui g `l90'=.
		qui g `l95'=.
		
//		di in r "title | `title' "
        foreach v of local vn {
			loc j = `j'+1
			loc rv : word `i' of `varlist'
			loc cv90 = cv90[`i1',`j']
			loc cv95 = cv95[`i1',`j']
			qui replace `l90' = `cv90' if !mi(`v')
			qui replace `l95' = `cv95' if !mi(`v')
			// loc t1txt ""
			// loc t2txt ""
			if "`title'" == "notitle" {
			tsline `v' `l90' `l95' if !mi(`v'), ylab(,angle(0) labs(small)) ///
			scheme(s2mono) graphregion(color(white)) yti(" ") ///
			xlab(#6, labs(small)) name(`v', replace) legend(off) 
			}
			if "`title'" != "notitle" {
			tsline `v' `l90' `l95' if !mi(`v'), ylab(,angle(0) labs(small)) ///
			scheme(s2mono) graphregion(color(white)) yti(" ") ///
			xlab(#6, labs(small)) ///	
			title("`t`j'g' for `depvar' G-caused by `rv', `t1' - `t2'", size(medium))  ///
			subtitle("with 90th (--) and 95th (-) percentiles of bootstrapped test statistics", size(small)) ///
            name(`v', replace)  legend(off) 
			//	loc t1txt "`t`j'' for `depvar' G-caused by `rv', `t1' - `t2'"
			//	loc t2txt "with 90th (--) and 95th (-) percentiles of bootstrapped test statistics"
			}
			if "`eps'" != "" {
				qui gr export `v'.eps, replace
				}
			if "`pdf'" != "" {
				qui gr export `v'.pdf, replace
				}
			}
		}
		// end of graph logic
	}
	// end of prefix logic
	
	if "`matrix'" != "" {
		mata: st_matrix("m_`excli'",mat_`i')
		return matrix m_`excli' = m_`excli'
	}
}
// end loop over RHS vars

	loc cn Max_Wald_forward Max_Wald_rolling Max_Wald_recursive
	mata: st_matrix("gcres",gcres)
	mat rownames gcres = `rhsv'
	mat colnames gcres = `cn'
	matlist gcres, for(%18.3f) tit("TVGC `robust' test statistics for H0: `depvar' is GC")
	mat gcres0 = gcres
	return matrix gcres = gcres	
	mata: st_local("T", strofreal(rows(mat_2)))
	foreach c in 90 95 99 {
		mat rownames cv`c' = `rhsv'
		mat colnames cv`c' = `cn'
		matlist cv`c', for(%18.3f) tit("`c'th percentile of test statistics [`bootrepl' replications]")
		mat gccv`c'0 = cv`c'
		
//		matlist gccv`c'0
		
		return matrix gccv`c' = cv`c'
	}
	
	if "`restab'" == "restab" {
// output of 95, 99
			loc nrow = (`numvars'-1) * 3
			mat restab = J(	`nrow',3, .)
			loc k 1
			forv i=2/`numvars' {
				forv j=1/3 {
					mat restab[`k',`j'] = gcres0[`=`i'-1',`j']
					mat restab[`=`k'+1',`j'] = gccv950[`=`i'-1',`j']
					mat restab[`=`k'+2',`j'] = gccv990[`=`i'-1',`j']
				}
			loc k = `k' + 3
			}
//		matlist restab, format(%9.3f)
// from outtable.tex
		tempname hh s1 s2 s3
		file open `hh' using restab.tex, write replace
		file write `hh'  "\begin{table}[htbp]" _n
		local hl "\hline"
		loc fmt %9.3f
		local l "l"
		local align "c"
		loc nc 4
		forv i=2/`nc' {
			local l "`l'`align'"
		}
		file write `hh' "\begin{tabular}{`l'}" _n  "\toprule" _n
		file write `hh' "Variable & Max Wald FE & Max Wald RO & Max Wald RE \\ [2pt] \midrule" _n
		loc k 1
		forv i=1/`=`numvars'-1' {
			loc vn: word `i' of `rhsv'
			file write `hh' "\$`vn'\$ & " `fmt' (restab[`k',1]) " & " `fmt' (restab[`k',2]) " & " `fmt' (restab[`k',3]) " \\" _n
			sca `s1' = "("+strofreal(restab[`=`k'+1',1],"`fmt'")+")"
			sca `s2' = "("+strofreal(restab[`=`k'+1',2],"`fmt'")+")"
			sca `s3' = "("+strofreal(restab[`=`k'+1',3],"`fmt'")+")"
			file write `hh' " & " (`s1') " & " (`s2') " & " (`s3') " \\" _n
			sca `s1' = "["+strofreal(restab[`=`k'+2',1],"`fmt'")+"]"
			sca `s2' = "["+strofreal(restab[`=`k'+2',2],"`fmt'")+"]"
			sca `s3' = "["+strofreal(restab[`=`k'+2',3],"`fmt'")+"]"
			file write `hh' " & " (`s1') " & " (`s2') " & " (`s3') " \\ [3pt] " _n
			loc k=`k'+3
		}
		file write `hh' "\bottomrule " _n "\end{tabular}" _n
		file write `hh' "\end{table}" _n
		file close `hh'
	} // end restab
	
	return local cmd "tvgc"
	return scalar T = `T'
	return scalar p = `p'
	return scalar d = `d'
	return scalar bootrepl = `bootrepl'
	return scalar window = `wwid'
	return scalar sizecontrol = `sizecontrol'
	return local depvar `depvar'
	return local rhsvars  `rhsv'
	return local tstart `t1'
	return local tend `t2'

	tempfile mm
	qui save "`mm'"
	restore
// merge in created variables if selected
	if `mmrg' == 1 {
		qui merge 1:1 `tvar' using "`mm'"
		drop _merge
	}	
end

mata:
void tvgcres(real rhs, real matrix gctest) 
{
	external real matrix gcres
	gcres[rhs,1] = max(gctest[1, ])
	gcres[rhs,2] = max(diagonal(gctest))
	gcres[rhs,3] = max(gctest)
}

void tvgc_cv()
{
// each triple of columns in bsmat refer to test stats for one RHS variable
	external real matrix bsmat
	rcv90 = mm_quantile(bsmat, 1, 0.90)
	rcv95 = mm_quantile(bsmat, 1, 0.95)
	rcv99 = mm_quantile(bsmat, 1, 0.99)	
	st_matrix("cv90",colshape(rcv90,3))
	st_matrix("cv95",colshape(rcv95,3))
	st_matrix("cv99",colshape(rcv99,3))
}	
	
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




