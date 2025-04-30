*! version 1.2.3     13may2018     C F Baum
*  from dfgls 1.2.0, 0405 and J.Barkoulas RATS procedure kpss.src
*  mod to use gen, predict double
*  0925: corr for missing initial obs (like dfgls)
*  0927: add Hobijn et al. auto bandwidth selection and alternative QS kernel
*  0A03: corr to use all available obs in autocorrel fn, validate vs N-P
*  1717: mod Schwert to use 12 for monthly (or undef), 4 otherwise
*  1.2.2: Stata 8 syntax, make byable(recall) and onepanel
*  1.2.3: add additional returns

program define kpss, rclass byable(recall)
	version 8.2

	syntax varname(ts) [if] [in] [ , Maxlag(integer -1) noTrend AUTO QS]  

   	marksample touse
			/* get time variables; enable onepanel */
//	_ts timevar, sort
	_ts timevar panelvar if `touse', sort onepanel
	markout `touse' `timevar'
	tsreport if `touse', report
	if r(N_gaps) {
		di in red "sample may not contain gaps"
		exit
	}
	qui tsset
	scalar schwert = 4
	if ( r(unit1) == "m" | r(unit1) == "." ) { 
		scalar schwert = 12 
	}
	tempvar trd y dty psum psum2 
	tempname nobs stat count kmax s20 sumst2 kpss0 A p1 p5 p10 yvar t2
	tempname nt qsk s0 s1 es2 gamma kernel ac
		
	if "`trend'"=="notrend" {
		local trend 0
		local stat "level stationary"
		local p1 0.739
		local p2h 0.574
		local p5 0.463
		local p10 0.347
	}
	else {
		local trend 1
		local stat "trend stationary"
		local p1 0.216
		local p2h 0.176
		local p5 0.146
		local p10 0.119
	}
	gen `count'=sum(`touse')
	local nobs=`count'[_N]
	if `maxlag'==-1 {
* set maxlag via Schwert criterion (Ng/Perron JASA 1995)
		local maxlag = int(schwert*(`nobs'/100)^0.25)
		local kmax = "Maxlag = `maxlag' chosen by Schwert criterion" 
	}
	else {
		local kmax "Maxlag = `maxlag'"
	}
* if auto, set maxlag from auto bandwidth selection
* using either Bartlett or Quadratic Spectral value (Hobijn et al 1998)
	local nt 0
	local qsk 0
	local kernel "Bartlett kernel"
	if "`qs'" == "qs" {
		local qsk 1
		local kernel "Quadratic Spectral kernel"
	}
	if "`auto'" == "auto" {
		if `qsk' == 1 {
			local nt = int(`nobs'^(2/25))
		}
		else {
			local nt = int(`nobs'^(2/9))
		}
	local maxlag = `nt'
	}
*
	if `trend' {
		gen `trd' = _n
	}
	qui {
		gen double `y' = `varlist' 
		local yvar  `varlist'
* run the OLS regression to detrend (or demean) the data, calc resids
		if `trend' {
			reg  `y'  `trd' if `touse'
		}
		else {
			reg `y' if `touse'
		}
		predict double `dty' if `touse',r
		local s20=e(df_r)/e(N)*e(rmse)^2
		local nobs=e(N)
* calculate partial sum series and its squares
		gen double `psum' = sum(`dty') if `touse'
		gen double `psum2' = `psum'^2  if `touse'
		summ `psum2', meanonly
* numerator: average value of squared partial sum series / T
		local sumst2 = r(mean)/`nobs'
		local kpss0=`sumst2'/`s20'
* auto bandwidth selection logic
		if `nt' > 0 {
			mat accum A = `dty' L(1/`nt').`dty',noc
			local l 1
			local s0 0
			local s1 0
			local es2 0
			while `l' <= `nt' {
				local s0 = `s0' + 2.0*A[`l'+1,1]
				local s1 = `s1' + 2.0*`l'*A[`l'+1,1]
				local es2 = `es2' + 2.0*`l'^2*A[`l'+1,1]
				local l = `l'+1
				}
			local s0 = `s0' + `s20'
* choice between Bartlett and QS kernel (Hobijn et al Table 3)
			local maxlag0 = `maxlag'
			if `qsk' == 0 {
			local gamma = 1.1447*((`s1'/`s0')^2)^(1/3)
			local maxlag = min(`nobs',int(`gamma'*`nobs'^(1/3)))
			}
			else {
			local gamma = 1.3221*((`es2'/`s0')^2)^(1/5)
			local maxlag = min(`nobs',int(`gamma'*`nobs'^(1/5)))
			}
			local kmax "Automatic bandwidth selection (maxlag) = `maxlag'"
			}
* end auto bandwidth selection logic	
		if `maxlag'>0 {
			mat AC=J(`maxlag',1,0)
			local l 1
* generate autocovariances from all available data
			while `l'<=`maxlag' {
				capt drop `ac'
				gen `ac'=sum(`dty'*L`l'.`dty')
				mat AC[`l',1]=`ac'[_N]
				local s2`l'=0
				local s 1
				while `s'<=`l' {
					if `qsk' == 0 {
						local w=1-(`s'/(`l'+1))
					}
					else {
						local w=(25/(12*_pi^2*(`s'/`l')^2))*(sin(6*_pi*(`s'/`l')/5)/(6*_pi*(`s'/`l')/5)-cos(6*_pi*(`s'/`l')/5))
					}
* denominator: accumulate long run variance 
					local s2`l'=`s2`l''+`w'*AC[`s',1]
					local s=`s'+1
				}
				local s2`l'=2.0*`s2`l''/`nobs'+`s20'
				local kpss`l'=`sumst2'/`s2`l''
				local l=`l'+1
			}
		}
	}
	di " "
	di in gr "KPSS test for `yvar'"
	di " "
	di in gr "`kmax'"
	di in gr "Autocovariances weighted by `kernel'"
	di " "
	di in gr "Critical values for H0: `yvar' is `stat'"
	di " "
	di in gr "10%: `p10'  5% : `p5'  2.5%: `p2h'  1% : `p1'"
	di " "
	di in gr "Lag order    Test statistic"
	if `nt'>0 & `maxlag'==0 | `nt'==0 {
		di       "    0       " %8.3g `kpss0'
	}
	return scalar N = `nobs'
	return scalar kpss0 = `kpss0'
	return scalar p01 = `p1'
	return scalar p025 = `p2h'
	return scalar p05 = `p5'
	return scalar p10 = `p10'
	if `maxlag'>0 {
		return scalar maxlag = `maxlag'
		local l 1
		while `l'<=`maxlag' {
		if `nt'>0 & `maxlag'==`l' | `nt'==0 {
			di  _col(4) %2.0f `l' _col(13) %8.3g `kpss`l''
		}
		return scalar kpss`l'=`kpss`l''
		local l=`l'+1
		}
	}
	end
	exit
