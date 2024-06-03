*! actest9 2.0.13 22Jan2015
*! based on actest 2.0.12 and livreg2 Mata library 1.1.07
*! see end of file for version comments

program define actest9, rclass sortpreserve
version 9.2
	syntax [varlist(default=none ts)] [if] [in] [aw fw pw iw]					///
		[, 	LAGs(numlist integer>0 sort) STRICTexog q0 bp small					///
			Robust CLuster(varlist) BW(string) kernel(string) psd(string) sw ]

************* START SETUP BLOCKS FOR UNIVARIATE AND POST-REGRESSION *************

	local univariate=("`varlist'"~="")

	if `univariate' {			// Start setup block for univariate test

* univariate implies strict exogeneity and (in effect) OLS
		local strictexog "strictexog"
		local ols=1

		local varcount :  word count `varlist'
		if `varcount' > 1 {
di as err "error - can specify at most one variable as argument to actest"
		exit 198
		}

		marksample touse

* Weight support
		tempvar wvar
		if "`weight'" ~= "" {
* exp has "= " as well as weight expression
			qui gen double `wvar' `exp' if `touse'
		}
		else {
			local weight ""
			qui gen byte `wvar'=1 if `touse'
		}

* For the univariate case, the "residuals" are just the demeaned variable
		tempvar uhat
		sum `varlist' if `touse' [`weight'`exp'], meanonly
		qui gen double `uhat'=`varlist'-r(mean) if `touse'
* Local varlists x and z are just a vector of 1s
		tempvar one
		qui gen byte `one'=1 if `touse'
		local x "`one'"
		local z "`one'"
* Local cons=1 (since it's the only "regressor"
		local cons=1

* dofminus used by ivreg2, needed by m_omega()
		local dofminus=0


	}							// End setup block for univariate test
	else {						// Start setup block for post-regression test

		if "`e(cmd)'" == "" {
			error 301			// error 301 = "last estimates not found"
		}
	
* Partialling-out not (yet) supported
		if "`e(fwlcons)'" != ""  | (e(partial_ct)>0 & e(partial_ct)<.) {
di as err "actest not allowed after ivreg2 with partialling-out option"
			error 499
		}
	
		tempvar touse
		gen byte `touse'=e(sample)
	
* Is previous estimation command supported?
		if									///
			"`e(cmd)'" ~= "ivreg2" &		///
			"`e(cmd)'" ~= "ivreg28" &		///
			"`e(cmd)'" ~= "ivreg29" &		///
			"`e(cmd)'" ~= "ivreg210" &		///
			"`e(cmd)'" ~= "ivreg" &			///
			"`e(cmd)'" ~= "regress" &		///
			"`e(cmd)'" ~= "ivregress" &		///
			"`e(cmd)'" ~= "newey" &			///
			"`e(cmd)'" ~= "newey2" {
di as err "`e(cmd)' not supported by actest"
			exit 198
		}
		local cmd `e(cmd)'
	
* Weights support
		if "`weight'" ~= "" {
di as err "[`weight'=`exp'] not allowed - cannot change weights used by original estimation"
			exit 198
		}
		local weight "`e(wtype)'"
		local exp    "`e(wexp)'"
		tempvar wvar
		if "`weight'" ~= "" {
* exp has "= " as well as weight expression
			qui gen double `wvar' `exp' if `touse'
		}
		else {
			qui gen byte `wvar'=1 if `touse'
		}

* define the x matrix, and check if constant appears
		local x : colnames(e(b))
		local x : subinstr local x "_cons" "", count(local cons)

* define the z matrix
		local z "`e(insts)'"
		local ols=("`z'"=="")
		if `ols' {
			local z "`x'"
		}
	
* add constant to both x and z if present in reglist	
		if `cons'==1 {
			tempvar one
			qui gen byte `one'=1 if `touse'
			local x "`x' `one'"
			local z "`z' `one'"
		}
		else {
			local noconstant "noconstant"
		}
/* cfb2.0.10
* Replace time-series ops with temp vars
		tsrevar `x'
		local x "`r(varlist)'"
		tsrevar `z'
		local z "`r(varlist)'"
*/

* Generate residuals
		tempvar uhat
		qui predict double `uhat' if `touse', resid
	
* dofminus used by ivreg2, needed by m_omega()
		if "`e(dofminus)'"=="" {
			local dofminus=0
		}
		else {
			local dofminus=`e(dofminus)'
		}
	}						// End setup block for post-regression test

//////// Start setup block shared by univariate and post-regression tests //////////

* Incompatible options
	if "`strictexog'"~="" & "`cluster'"~="" {
		di as err "Incompatible options: strictexog and cluster-robust"
		exit 198
	}
	if "`bp'"~="" & "`robust'`cluster'"~="" {
		di as err "Incompatible options: bp not allowed with robust/cluster-robust"
		exit 198
	}
* Other incompatibilities...?

* Box-Pierce (diagonal V_r) implies q0 (no s.c. under H0)
	if "`bp'"~="" {
		local q0 "q0"
	}

* Check tsset and create time and panel vars
	capture tsset
	local tvar "`r(timevar)'"
* If no time var, exit with error
	if "`tvar'"=="" {
		di as err "Data must be tsset"
		error 198
	}
	if "`r(tdelta)'" != "" {
		local tdelta = `r(tdelta)'
	}
	else {
		local tdelta=1
	}
* If not panel data, ivar will be empty
	local ivar "`r(panelvar)'"

* Default lags
	if "`lags'"=="" {
		local lags=1
	}
* Process lags
	local numlags : list sizeof lags
* tokenize and then take first and last element from lags
* If only one lag supplied, then 1st lag=1 and last lag=supplied
* If multiple lags supplied use lowest and highest
	if `numlags'==1 {
		local llo = 1
		local lhi = `lags'
	}
	else {
		tokenize `lags'
		local llo = `1'
		local lhi = ``numlags'' 
	}

* If bw specified, must provide kernel as well.
* If kernel specified, must provide bw as well.
	if	("`kernel'"~="" & "`bw'"=="") |	///
		("`kernel'"=="" & "`bw'"~="") {
		di as err "error: must supply both bandwidth and kernel with kernel-robust option"
		exit 198
	}

* Check valid bw and kernel and replace with unabbreviated kernel name
* and bw converted to scalar
	if "`kernel'" ~= "" {
* bw argument is string
* s_vkernel is in livreg2 mlib.
		mata: s_actest9_vkernel("`kernel'", "`bw'", "`ivar'")
		local kernel `r(kernel)'
		local bw = `r(bw)'
	}
* Otherwise convert bw string "0" to scalar 0
	else if "`bw'"=="0" | "`bw'"=="" {
		local bw = 0
	}
* Check bandwidth is legal
	sum `tvar' if `touse', meanonly
	local T = r(max)-r(min)+1
	if `bw' > (`T'-1)/`tdelta' {
di as err "invalid bandwidth in option bw() - cannot exceed timespan of data"
		exit 198
	}

* Default behavior: truncated kernel with bw=q=(min lag - 1).
* When min lag = 1, q=0 and no serial correlation assumed.
* Indicated by kernel="default".
* Overridden if kernel or cluster-robust specified
	if "`kernel'`cluster'"=="" {
		local kernel "default"
	}
* Cluster => robust
* Do here, after options are processed, since specifying just "robust" as option means no AC or HAC.
	if "`cluster'"~="" {
		local robust "robust"
	}

* Every time a weight is used, must multiply by scalar wf ("weight factor")
* wf=1 for no weights, fw and iw, wf = scalar that normalizes sum to be N if aw or pw
	sum `wvar' if `touse' [`weight'`exp'], meanonly
	if "`weight'"=="" | "`weight'"=="fweight" | "`weight'"=="iweight" {
* Effective number of observations is sum of weight variable.
* If weight is "", weight var must be column of ones and N is number of rows
		local wf=1
		local N=r(sum_w)
	}
	else {
		local wf=r(N)/r(sum_w)
		local N=r(N)
	}
	
// Replace TS operators with temp vars; tweak lists to deal with omitted regressors,
// as tsrevar does not cope with o. prefix
/*
	if `c(stata_version)'>=11 {
		foreach var in `x' `z' {
			_ms_parse_parts `var'
			
	di in red "`var'"
	ret li
	
			if `r(omit)' {
				local remove "`var'"
				local x : list x - remove
				local z : list z - remove
			}
		}
	}
*/
// tsrevar -> fvrevar in V11+ so that factor variables won't choke
	loc fix ts
	if `c(stata_version)'>=11 {
		loc fix fv
	} 
	`fix'revar `x'
	local x "`r(varlist)'"
	`fix'revar `z'
	local z "`r(varlist)'"

* tindex variable required by m_omega()
	tempvar tindex
	qui gen `tindex'=1 if `touse'
	qui replace `tindex'=sum(`tindex') if `touse'
	

************* END SETUP BLOCK *************

* Calculate ACs up to lhi for specified sample
	tempname ac regest
* If starting with a lag>1, fill out list of ACs with zeros
	if `llo'>1 {
		mat `ac' = J(1,`llo'-1,0)
	}
	forvalues lag = `llo'/`lhi' {
		tempvar luhat
* Generate required lags of residual vector.
* Lag=0 if uhat available but lag is not because it's a leading ob (e.g., before data start)
		qui gen double `luhat'=L`lag'.`uhat' if `touse'
		qui replace `luhat'=0 if `luhat'==. & `uhat'<. & `touse'
		local lagresids "`lagresids' `luhat'"
* capture in case this is a univariate version and there is nothing to hold/restore
		capture _estimates hold `regest', restore
		qui reg `luhat' `uhat' if `touse' [`weight'`exp'], `noconstant'
		mat `ac' = nullmat(`ac'), _b[`uhat']
		capture _estimates unhold `regest'
	}

* Code lifted from ivreg2. Last block of code before test stats.
********** CLUSTER SETUP **********************************************

* Mata code requires data are sorted on (1) the first var cluster if there
* is only one cluster var; (2) on the 3rd and then 1st if two-way clustering,
* unless (3) two-way clustering is combined with kernel option, in which case
* the data are tsset and sorted on panel id (first cluster variable) and time
* id (second cluster variable).
* Second cluster var is optional and requires an identifier numbered 1..N_clust2,
* unless combined with kernel option, in which case it's the time variable.
* Third cluster var is the intersection of 1 and 2, unless combined with kernel
* opt, in which case it's unnecessary.
* Sorting on "cluster3 cluster1" means that in Mata, panelsetup works for
* both, since cluster1 nests cluster3.
* Note that it is possible to cluster on time but not panel, in which case
* cluster1 is time, cluster2 is empty and data are sorted on panel-time.
* Note also that if data are sorted here but happen to be tsset, will need
* to be re-tsset after estimation code concludes.

		if "`cluster'"!="" {
			local clopt "cluster(`cluster')"
			tokenize `cluster'
			local cluster1 "`1'"
			local cluster2 "`2'"
			if "`kernel'"~="" {
* kernel requires either that cluster1 is time var and cluster2 is empty
* or that cluster1 is panel var and cluster2 is time var.
* Either way, data must be tsset and sorted for panel data.
				if "`cluster2'"~="" {
* Allow backwards order
					if "`cluster1'"=="`tvar'" & "`cluster2'"=="`ivar'" {
						local cluster1 "`2'"
						local cluster2 "`1'"
					}
					if "`cluster1'"~="`ivar'" | "`cluster2'"~="`tvar'" {
di as err "Error: cluster kernel-robust requires clustering on tsset panel & time vars."
di as err "       tsset panel var=`ivar'; tsset time var=`tvar'; cluster vars=`cluster1',`cluster2'"
						exit 198
					}
				}
				else {
					if "`cluster1'"~="`tvar'" {
di as err "Error: cluster kernel-robust requires clustering on tsset time variable."
di as err "       tsset time var=`tvar'; cluster var=`cluster1'"
						exit 198
					}
				}
			}
* Simple way to get quick count of 1st cluster variable without disrupting sort
* clusterid1 is numbered 1.._Nclust1.
			tempvar clusterid1
			qui egen `clusterid1'=group(`cluster1') if `touse'
			sum `clusterid1' if `touse', meanonly
			if "`cluster2'"=="" {
				local N_clust=r(max)
				local N_clust1=.
				local N_clust2=.
				if "`kernel'"=="" {
* Single level of clustering and no kernel-robust, so sort on single cluster var.
* kernel-robust already sorted via tsset.
					sort `cluster1'
				}
			}
			else {
				local N_clust1=r(max)
				if "`kernel'"=="" {
					tempvar clusterid2 clusterid3
* New cluster id vars are numbered 1..N_clust2 and 1..N_clust3
					qui egen `clusterid2'=group(`cluster2') if `touse'
					qui egen `clusterid3'=group(`cluster1' `cluster2') if `touse'
* Two levels of clustering and no kernel-robust, so sort on cluster3/nested in/cluster1
* kernel-robust already sorted via tsset.
					sort `clusterid3' `cluster1'
					sum `clusterid2' if `touse', meanonly
					local N_clust2=r(max)
				}
				else {
* Need to create this only to count the number of clusters
					tempvar clusterid2
					qui egen `clusterid2'=group(`cluster2') if `touse'
					sum `clusterid2' if `touse', meanonly
					local N_clust2=r(max)
* Now replace with original variable
					local clusterid2 `cluster2'
				}
				local N_clust=min(`N_clust1',`N_clust2')
			}
		}
		else {
* No cluster options but for Mata purposes, set N_clust=0
				local N_clust=0
		}
		
************************************************************************************************

* Test description
	di _n as text "Cumby-Huizinga test for autocorrelation" _c
	if "`ivar'"=="" {											//  Time-series large-T tests
		if `univariate' & `ols' & "`bp'"~="" & "`small'"=="" {
			di as text " (Box-Pierce)"
		}
		else if `univariate' & `ols' & "`bp'"~="" & "`small'"~="" {
			di as text " (Ljung-Box)"
		}
		else if `ols' & "`bp'"~="" & "`small'"=="" {
			di as text " (Modified Box-Pierce)"
		}
		else if `ols' & "`bp'"~="" & "`small'"~="" {
			di as text " (Modified Ljung-Box)"
		}
		else if `ols' & "`strictexog'`robust'`cluster'"=="" & `bw'==0 {
			di as text " (Breusch-Godfrey)"
		}
		else {
			di
		}
	}
	else {														//  Panel large-N tests
		if "`cluster'"~="" {
			di as text " (Arellano-Bond)"
		}
		else {
			di
		}
	}
	
	if `univariate' {
		local testobj "disturbance"
	}
	else {
		local testobj "variable"
	}

	di as text "  H0: `testobj' is MA process up to order q"
	di as text "  HA: serial correlation present at specified lags >q"

	di as text "{hline 41}{c TT}{hline 35}"
	if "`q0'"~="" {
		di	as text "  H0: q=0 (serially uncorrelated)"			///
			as text _col(42) "{c |}"							///
			as text "  H0: q=0 (serially uncorrelated)"	
		di	as text "  HA: s.c. present at range specified"		///
			as text _col(42) "{c |}"							///
			as text "  HA: s.c. present at lag specified"
	}
	else if `llo'==1 {
		di	as text "  H0: q=0 (serially uncorrelated)"			///
			as text _col(42) "{c |}"							///
			as text "  H0: q=specified lag-1"
		di	as text "  HA: s.c. present at range specified"		///
			as text _col(42) "{c |}"							///
			as text "  HA: s.c. present at lag specified"
	}
	else {
		di	as text "  H0: `testobj' is MA(q), q=" `llo'-1		///
			as text _col(42) "{c |}"							///
			as text "  H0: q=specified lag-1"
		di	as text "  HA: s.c. present at range specified"		///
			as text _col(42) "{c |}"							///
			as text "  HA: s.c. present at lag specified"
	}

	di	as text "{hline 11}{c TT}{hline 29}{c +}{hline 5}{c TT}{hline 29}"
	di	as text _col(5) "lags"													///
		as text _col(12) "{c |}"												///
		as text _col(19) "chi2"													///
		as text _col(29) "df"													///
		as text _col(36) "p-val"												///
		as text _col(42) "{c |}"												///
		as text _col(44) "lag"													///
		as text _col(48) "{c |}"												///
		as text _col(55) "chi2"													///
		as text _col(65) "df"													///
		as text _col(72) "p-val"
	di	as text "{hline 11}{c +}{hline 29}{c +}{hline 5}{c +}{hline 29}"

* C-H notation:
* q=last lag BEFORE lags to be tested
* NB: q=0 if testing lags starting with lag 1
* Start testing at lag q+1
* s=number of ACs to be tested
* q+s=last lag to be tested

* Loop through lags
* local macro lag is highest lag being tested in that iteration
* Matrix m stores results
* Matrix r in loop is one row (lag set) of results
* Tokenize stored lagged resids; each time through loop,
* add to list (capuhat) and mac shift to next resid.
	tempname m vrhat vr
	tokenize `lagresids'
	forvalues lag = `llo'/`lhi' {
		tempname lqs lqsp r
		local uq "`1'"
		mac shift
		local capuhat "`capuhat' `uq'"

* Call to test set of lags starting at q+1
		local q=`llo'-1
		local s=`lag'-`q'
		if ("`kernel'"=="default" & ((`q'==0) | "`q0'"~="")) {
* q=0, serially uncorrelated under null => not AC or HAC
			local loopkernel ""
			local loopbw=0
		}
		else if ("`kernel'"=="default" & `q'>0) {
* q>0, serially correlated up to q => HAC, truncated kernel w/bw=q
			local loopkernel "Truncated"
			local loopbw=`q'
		}
		else {
* user-defined, including cluster-robust
			local loopkernel "`kernel'"
			local loopbw=`bw'
		}
		mata: s_acstat(						///
						"`x'",				///
						"`z'",				///
						`q',				///
						`s',				///
						"`uhat'",			///
						"`capuhat'",		///
						"`ac'",				///
						"`strictexog'",		///
						"`bp'",				///
						"`small'",			///
						"`touse'",			///
						"`weight'",			///
						"`wvar'",			///
						`wf',				///
						"`tvar'",			///
						`tdelta',			///
						"`ivar'",			///
						"`tindex'",			///
						"`robust'",			///
						"`clusterid1'",		///
						"`clusterid2'",		///
						"`clusterid3'",		///
						`loopbw',			///
						"`loopkernel'",		///
						"`psd'",			///
						`dofminus',			///
						"`sw'"				///
						)
		scalar `lqs'=r(lqs)
		scalar `lqsp'=chiprob(`s',`lqs')
		mat `r'=`llo',`lag',`lqs',`lqsp'
		mat `vrhat'=r(vrhat)
		mat `vr'=r(vr)

		di										///
			as result _col(2) %3.0f `llo'		///
			as text _col(6) "-"					///
			as result _col(7) %3.0f `lag'		///
			as text _col(12) "{c |}"			///
			as result _col(17) %7.3f `lqs' _c   ///
			as result _col(30) "`s'"			
		if `r(npsd)' {
			di as text "*" _c
			local npsdflag = "npsdflag"
		}
		di	as result _col(35) %5.4f `lqsp' _c

* Call to test at specified lag only
		local q=`lag'-1
		local s=1
		if ("`kernel'"=="default" & ((`q'==0) | "`q0'"~="")) {
* q=0, serially uncorrelated under null => not AC or HAC
			local loopkernel ""
			local loopbw=0
		}
		else if ("`kernel'"=="default" & `q'>0) {
* q>0, serially correlated up to q => truncated kernel w/bw=q
			local loopkernel "Truncated"
			local loopbw=`q'
		}
		else {
* user-defined, including cluster-robust
			local loopkernel "`kernel'"
			local loopbw=`bw'
		}
		mata: s_acstat(						///
						"`x'",				///
						"`z'",				///
						`q',				///
						`s',				///
						"`uhat'",			///
						"`uq'",				///
						"`ac'",				///
						"`strictexog'",		///
						"`bp'",				///
						"`small'",			///
						"`touse'",			///
						"`weight'",			///
						"`wvar'",			///
						`wf',				///
						"`tvar'",			///
						`tdelta',			///
						"`ivar'",			///
						"`tindex'",			///
						"`robust'",			///
						"`clusterid1'",		///
						"`clusterid2'",		///
						"`clusterid3'",		///
						`loopbw',			///
						"`loopkernel'",		///
						"`psd'",			///
						`dofminus',			///
						"`sw'"				///
						)
		scalar `lqs'=r(lqs)
		scalar `lqsp'=chiprob(1,`lqs')
		mat `r'=`r',`lag',`lqs',`lqsp'

		di										///
			as text _col(42) "{c |}"			///
			as result _col(44) %3.0f `lag'		///
			as text _col(48) "{c |}"			///
			as result _col(53) %7.3f `lqs' _c   ///
			as result _col(66) "1"				
		if `r(npsd)' {
			di as text "*" _c
			local npsdflag = "npsdflag"
		}
		di	as result _col(71) %5.4f `lqsp'

		matrix rownames `r' = lags_`llo'_`lag'
		mat `m'=nullmat(`m') \ `r'

	}

	noi di as text "{hline 11}{c BT}{hline 29}{c BT}{hline 5}{c BT}{hline 29}"
	matrix colnames `m' = lag_l lag_u chi2_lu p_lu lag chi2 p

* Footnotes
	if ~`univariate' {
		if "`strictexog'"=="" {
			di as text "  Test allows predetermined regressors/instruments"
		}
		else {
			di as text "  Test requires strictly exogenous regressors/instruments"
		}
	}
	if "`cluster'"~="" {
		di as text "  Test robust to heteroskedasticity and within-cluster autocorrelation"
	}
	else if "`robust'"~="" {
		di as text "  Test robust to heteroskedasticity"
	}
	else {
		di as text "  Test requires conditional homoskedasticity"
	}
	if "`npsdflag'" ~= "" {
		di as text "  * Eigenvalues adjusted to make matrix positive semidefinite"
	}

	tempname lqs lqsp
	local lastrow=rowsof(`m')
	return scalar df=(`m'[`lastrow',2]-`m'[`lastrow',1]+1)
	return scalar p=`m'[`lastrow',4]
	return scalar chi2=`m'[`lastrow',3]

	return scalar maxlag=`lhi'
	return scalar minlag=`llo'
	return local kernel = "`kernel'"
	return scalar bw=`bw'
	return matrix results=`m'
	
	return matrix vrhat=`vrhat'
	return matrix vr=`vr'

end

version 9.2
mata:

// ********* struct ms_actest9_vcvorthog ******************* //
struct ms_actest9_vcvorthog {
	string scalar	ename, Znames, touse, weight, wvarname
	string scalar	robust, clustvarname, clustvarname2, clustvarname3, kernel
	string scalar	sw, psd, ivarname, tvarname, tindexname
	real scalar		wf, N, bw, tdelta, dofminus
	real matrix		ZZ
	pointer matrix	e
	pointer matrix	Z
	pointer matrix	wvar
}

void s_acstat(string scalar xvars, 
				string scalar zvars,
				real scalar q, 
				real scalar s, 
				string scalar uvars, 
				string scalar capuvars, 
				string scalar ac,
				string scalar strictexog,
				string scalar bp,
				string scalar small,
				string scalar touse,
				string scalar weight,
				string scalar wvarname,
				scalar wf,
				string scalar tvarname,
				scalar tdelta,
				string scalar ivarname,
				string scalar tindexname,
				string scalar robust,
				string scalar clustvarname,
				string scalar clustvarname2,
				string scalar clustvarname3,
				scalar bw,
				string scalar kernel,
				string scalar psd,
				scalar dofminus,
				string scalar sw)
{

	xv=tokens(xvars)
	vx= xv[|1,.|]
	zv=tokens(zvars)
	vz= zv[|1,.|]
	uv=tokens(uvars)
	vu= uv[|1,.|]
	capuv=tokens(capuvars)
	vg= capuv[|1,.|]
	wv=tokens(wvarname)
	vw= wv[|1,.|]

	st_view(X=.,.,vx,touse)
	st_view(Z=.,.,vz,touse)
	st_view(uhat=.,.,vu,touse)
	st_view(capuhat=.,.,vg,touse)

	T=rows(uhat)

	h=cols(Z)

	st_view(eta,.,(vz,vg),touse)
	st_view(wvar,   ., vw, touse)
	ZZ = quadcross(eta, wf*wvar, eta)
	XZ = quadcross(X, wf*wvar, Z)

	struct ms_actest9_vcvorthog scalar vcvo
	vcvo.ename			= uv[|1,1|]
	vcvo.Znames			= (zv,capuv)
	vcvo.touse			= touse
	vcvo.weight			= weight
	vcvo.wvarname		= wvarname
	vcvo.robust			= robust
	vcvo.clustvarname	= clustvarname
	vcvo.clustvarname2	= clustvarname2
	vcvo.clustvarname3	= clustvarname3
	vcvo.kernel			= kernel
	vcvo.sw				= sw
	vcvo.psd			= psd
	vcvo.ivarname		= ivarname
	vcvo.tvarname		= tvarname
	vcvo.tindexname		= tindexname
	vcvo.wf				= wf
	vcvo.N				= T
	vcvo.bw				= bw
	vcvo.tdelta			= tdelta
	vcvo.dofminus		= dofminus
	vcvo.ZZ				= ZZ

	vcvo.e		= &uhat
	vcvo.Z		= &eta
	vcvo.wvar	= &wvar

	psi=m_actest9_omega(vcvo)

// psda option: Stock-Watson 2008 Econometrica, Remark 8, say replace neg EVs with abs(EVs).
	if (det(psi) < 0) {
// Use S-W approach to make PSD
		vcvo.psd = "psda"
		psi=m_actest9_omega(vcvo)
		st_numscalar("r(npsd)", 1)
	}
	else if (vcvo.psd ~= "" ) {
// User had already supplied either psda or psd0 option to make PSD
		st_numscalar("r(npsd)", 1)
	}
	else {
		st_numscalar("r(npsd)",0)
	}

// Construct estimate of V_r (eqn 13)

	allr = st_matrix(ac)
	qmax = q + s
// (9)
	r = allr[|(q+1)\qmax|]'
// (22)
	sigma2 = quadcross(uhat, wf*wvar, uhat) / T

// s x s submatrix of psi is vr * sigma^4
	vr = psi[|(h+1,h+1)\(h+s,h+s)|] / (sigma2^2)

// Force vr to be identity matrix (Box-Pierce)
	if (bp~="") {
		vr = I(rows(vr))
	}


// Prop 1 - variance
	if (strictexog=="strictexog") {
// If strictly exogenous, Prop 1 simplifies: V_rhat = V_r
		vrhat = vr
	}
	else {
// Not strictly exogenous: Prop 1 is: V_rhat = V_r + BV_dB' + CD'B' + BDC'

// (5) construct A and Ainv 
		A = psi[|(1,1)\(h,h)|]
		Ainv = invsym(A)

// (24)
		dhat = T * invsym(XZ * Ainv * XZ') * XZ * Ainv

// (23) depends on capuhat
		bhat = - quadcross(capuhat, wf*wvar, X) / T / sigma2

		ul = bhat * dhat
		ur = J(s,s,0)
		ll = J(s,h,0)
		lr = I(s) / sigma2
		phi = (ul, ur \ ll, lr)

// (20)
		ppp = phi * psi * phi'

		bvb = ppp[|(1,1)\(s,s)|]
		bdc = ppp[|(1,s+1)\(s,2*s)|]
		cdb = bdc'
// Proposition 1, not strictly exogenous
		if (bp=="") {
// General case
			vrhat = vr + bvb + cdb + bdc
		}
		else {
// C-H case (iii) aka Hayashi "Modified Box-Pierce"
			vrhat = I(rows(vr)) - bvb
		}
	}

	vrhatinv = invsym(vrhat)

// Ljung-Box small-sample correction
	if (small~="") {
		for (i=1; i<=rows(r); i++) {
			r[i,1] = sqrt((T+2)/(T-(q+i))) * r[i,1]
		}
	}

// Proposition 2 test stat
	lqs = T * r' * vrhatinv * r	
	st_numscalar("r(lqs)",lqs)
	st_matrix("r(vrhat)",vrhat)
	st_matrix("r(vr)",vr)

}

// *********************************************************************** //
// **************** SUPPORT CODE (prev in livreg2.mlib ******************* //
// *********************************************************************** //


// ************************* s_actest9_vkernel ***************************** //
// Program checks whether kernel and bw choices are valid.
// s_actest9_vkernel is called from Stata.
// Arguments are the kernel name (req), bandwidth (req) and ivar name (opt).
// All 3 are strings.
// Returns results in r() macros.
// r(kernel) - name of kernel (string)
// r(bw) - bandwidth (scalar)

void s_actest9_vkernel(	string scalar kernel,
						string scalar bwstring,
						string scalar ivar
				)
{

// Check bandwidth
	if (bwstring=="auto") {
		bw=-1
	}
	else {
		bw=strtoreal(bwstring)
		if (bw==.) {
			printf("{err}bandwidth option bw() required for HAC-robust estimation\n")
			exit(102)
		}
		if (bw<=0) {
			printf("{err}invalid bandwidth in option bw() - must be real > 0\n")
			exit(198)
		}
	}
	
// Check ivar
	if (bwstring=="auto" & ivar~="") {
			printf("{err}Automatic bandwidth selection not available for panel data\n")
			exit(198)
	}

// Check kernel
// Valid kernel list is abbrev, full name, whether special case if bw=1
// First in list is default kernel = Barlett
	vklist = 	(	("", "bartlett", "0")
				\	("bar", "bartlett", "0")
				\	("bartlett", "bartlett", "0")
				\	("par", "parzen", "0")
				\	("parzen", "parzen", "0")
				\	("tru", "truncated", "1")
				\	("truncated", "truncated", "1")
				\	("thann", "tukey-hanning", "0")
				\	("tukey-hanning", "tukey-hanning", "0")
				\	("thamm", "tukey-hamming", "0")
				\	("tukey-hamming", "tukey-hamming", "0")
				\	("qua", "quadratic spectral", "1")
				\	("qs", "quadratic spectral", "1")
				\	("quadratic-spectral", "quadratic spectral", "1")
				\	("quadratic spectral", "quadratic spectral", "1")
				\	("dan", "danielle", "1")
				\	("danielle", "danielle", "1")
				\	("ten", "tent", "1")
				\	("tent", "tent", "1")
			)
	kname=strltrim(strlower(kernel))
	pos = (vklist[.,1] :== kname)

// Exit with error if not in list
	if (sum(pos)==0) {
		printf("{err}invalid kernel\n")
		exit(198)
		}

	vkname=strproper(select(vklist[.,2],pos))
	st_global("r(kernel)", vkname)
	st_numscalar("r(bw)",bw)

// Warn if kernel is type where bw=1 means no lags are used
	if (bw==1 & select(vklist[.,3],pos)=="0") {
		printf("{result}Note: kernel=%s", vkname)
		printf("{result} and bw=1 implies zero lags used.  Standard errors and\n")
		printf("{result}      test statistics are not autocorrelation-consistent.\n")
	}
}  // end of program s_actest9_vkernel


// ************************ m_actest9_omega ************************************** //

real matrix m_actest9_omega(struct ms_actest9_vcvorthog scalar vcvo) 
{
	if (vcvo.clustvarname~="") {
		st_view(clustvar, ., vcvo.clustvarname, vcvo.touse)
		info = panelsetup(clustvar, 1)
		N_clust=rows(info)
		if (vcvo.clustvarname2~="") {
			st_view(clustvar2, ., vcvo.clustvarname2, vcvo.touse)
			if (vcvo.kernel=="") {
				st_view(clustvar3, ., vcvo.clustvarname3, vcvo.touse) // needed only if not panel tsset
			}
		}
	}

	if (vcvo.kernel~="") {
		st_view(t,    ., st_tsrevar(vcvo.tvarname),  vcvo.touse)
		T=max(t)-min(t)+1
	}

	if ((vcvo.kernel=="Bartlett") | (vcvo.kernel=="Parzen") | (vcvo.kernel=="Truncated") ///
		 | (vcvo.kernel=="Tukey-Hanning")| (vcvo.kernel=="Tukey-Hamming")) {
		window="lag"
	}
	else if ((vcvo.kernel=="Quadratic Spectral") | (vcvo.kernel=="Danielle") | (vcvo.kernel=="Tent")) {
		window="spectral"
	}
	else if (vcvo.kernel~="") {
// Should never reach this point
printf("\n{error:Error: invalid kernel}\n")
		exit(error(3351))
	}

	L=cols(*vcvo.Z)
	K=cols(*vcvo.e)		// ivreg2 always calls with K=1; ranktest may call with K>=1.

// Covariance matrices
// shat * 1/N is same as estimated S matrix of orthog conditions

// Block for homoskedastic and AC.  dof correction if any incorporated into sigma estimates.
	if ((vcvo.robust=="") & (vcvo.clustvarname=="")) {
// ZZ is already calculated as an external
		ee = quadcross(*vcvo.e, vcvo.wf*(*vcvo.wvar), *vcvo.e)
		sigma2=ee/(vcvo.N-vcvo.dofminus)
		shat=sigma2#vcvo.ZZ
		if (vcvo.kernel~="") {
			if (window=="spectral") {
				TAU=T/vcvo.tdelta-1
			}
			else {
				TAU=vcvo.bw
			}
			tnow=st_data(., vcvo.tindexname)
			for (tau=1; tau<=TAU; tau++) {
				kw = m_actest9_calckw(tau, vcvo.bw, vcvo.kernel)
				if (kw~=0) {						// zero weight possible with some kernels
													// save an unnecessary loop if kw=0
													// remember, kw<0 possible with some kernels!
					lstau = "L"+strofreal(tau)
					tlag=st_data(., lstau+"."+vcvo.tindexname)
					tmatrix = tnow, tlag
					svar=(tnow:<.):*(tlag:<.)		// multiply column vectors of 1s and 0s
					tmatrix=select(tmatrix,svar)	// to get intersection, and replace tmatrix
// if no lags exist, tmatrix has zero rows.
					if (rows(tmatrix)>0) {
// col 1 of tmatrix has row numbers of all rows of data with this time period that have a corresponding lag
// col 2 of tmatrix has row numbers of all rows of data with lag tau that have a corresponding ob this time period.
// Should never happen that fweights or iweights make it here,
// but if they did the next line would be sqrt(wvari)*sqrt(wvari1) [with no wf since not needed for fw or iw]
						wv = (*vcvo.wvar)[tmatrix[.,1]]		///
									:* (*vcvo.wvar)[tmatrix[.,2]]*(vcvo.wf^2)	// inner weighting matrix for quadcross
						sigmahat = quadcross((*vcvo.e)[tmatrix[.,1],.],   wv ,(*vcvo.e)[tmatrix[.,2],.])	///
									/ (vcvo.N-vcvo.dofminus)					// large dof correction
						ZZhat    = quadcross((*vcvo.Z)[tmatrix[.,1],.], wv, (*vcvo.Z)[tmatrix[.,2],.])
						ghat = sigmahat#ZZhat
						shat=shat+kw*(ghat+ghat')
					}
				}	// end non-zero kernel weight block
			}	// end tau loop
		}  // end kernel code
// Note large dof correction (if there is one) has already been incorporated
	shat=shat/vcvo.N
	}  // end homoskedastic, AC code

// Block for robust HC and HAC but not Stock-Watson and single clustering.
// Need to enter for double-clustering if one cluster is time.
	if ( (vcvo.robust~="") & (vcvo.sw=="") & ((vcvo.clustvarname=="")		///
			| ((vcvo.clustvarname2~="") & (vcvo.kernel~="")))  ) {
		if (K==1) {										// simple/fast where e is a column vector
			if ((vcvo.weight=="fweight") | (vcvo.weight=="iweight")) {
				wv = (*vcvo.e:^2) :* *vcvo.wvar
			}
			else {
				wv = (*vcvo.e :* *vcvo.wvar * vcvo.wf):^2		// wf needed for aweights and pweights
			}
			shat=quadcross(*vcvo.Z, wv, *vcvo.Z)		// basic Eicker-Huber-White-sandwich-robust vce
		}
		else {											// e is a matrix so must loop
			shat=J(L*K,L*K,0)
			for (i=1; i<=rows(*vcvo.e); i++) {
				eZi=((*vcvo.e)[i,.])#((*vcvo.Z)[i,.])
				if ((vcvo.weight=="fweight") | (vcvo.weight=="iweight")) {
// wvar is a column vector. wf not needed for fw and iw (=1 by dfn so redundant).
					shat=shat+quadcross(eZi,eZi)*((*vcvo.wvar)[i])
				}
				else {
					shat=shat+quadcross(eZi,eZi)*((*vcvo.wvar)[i] * vcvo.wf)^2	//  **** ADDED *vcvo.wf
				}
			}
		}
		if (vcvo.kernel~="") {
// Spectral windows require looping through all T-1 autocovariances
			if (window=="spectral") {
				TAU=T/vcvo.tdelta-1
			}
			else {
				TAU=vcvo.bw
			}
			tnow=st_data(., vcvo.tindexname)
			for (tau=1; tau<=TAU; tau++) {
				kw = m_actest9_calckw(tau, vcvo.bw, vcvo.kernel)
				if (kw~=0) {						// zero weight possible with some kernels
													// save an unnecessary loop if kw=0
													// remember, kw<0 possible with some kernels!
					lstau = "L"+strofreal(tau)
					tlag=st_data(., lstau+"."+vcvo.tindexname)
					tmatrix = tnow, tlag
					svar=(tnow:<.):*(tlag:<.)		// multiply column vectors of 1s and 0s
					tmatrix=select(tmatrix,svar)	// to get intersection, and replace tmatrix

// col 1 of tmatrix has row numbers of all rows of data with this time period that have a corresponding lag
// col 2 of tmatrix has row numbers of all rows of data with lag tau that have a corresponding ob this time period.
// if no lags exist, tmatrix has zero rows
					if (rows(tmatrix)>0) {
						if (K==1) {										// simple/fast where e is a column vector
// wv is inner weighting matrix for quadcross
							wv   = (*vcvo.e)[tmatrix[.,1]] :* (*vcvo.e)[tmatrix[.,2]]		///
								:* (*vcvo.wvar)[tmatrix[.,1]] :* (*vcvo.wvar)[tmatrix[.,2]] * (vcvo.wf^2)
							ghat = quadcross((*vcvo.Z)[tmatrix[.,1],.], wv, (*vcvo.Z)[tmatrix[.,2],.])
						}
						else {										// e is a matrix so must loop
							ghat=J(L*K,L*K,0)
							for (i=1; i<=rows(tmatrix); i++) {
								wvari =(*vcvo.wvar)[tmatrix[i,1]]
								wvari1=(*vcvo.wvar)[tmatrix[i,2]]
								ei    =(*vcvo.e)[tmatrix[i,1],.]
								ei1   =(*vcvo.e)[tmatrix[i,2],.]
								Zi    =(*vcvo.Z)[tmatrix[i,1],.]
								Zi1   =(*vcvo.Z)[tmatrix[i,2],.]
								eZi =ei#Zi
								eZi1=ei1#Zi1
// Should never happen that fweights or iweights make it here, but if they did
// the next line would be ghat=ghat+eZi'*eZi1*sqrt(wvari)*sqrt(wvari1)
// [without *vcvo.wf since wf=1 for fw and iw]
								ghat=ghat+quadcross(eZi,eZi1)*wvari*wvari1 * (vcvo.wf^2)	// ADDED * (vcvo.wf^2)
							}
						}
						shat=shat+kw*(ghat+ghat')
					}	// end non-zero-obs accumulation block
				}	// end non-zero kernel weight block
			}	// end tau loop
		}  // end kernel code
// Incorporate large dof correction if there is one
	shat=shat/(vcvo.N-vcvo.dofminus)
	}  // end HC/HAC code

	if (vcvo.clustvarname~="") {
// Block for cluster-robust
// 2-level clustering: S = S(level 1) + S(level 2) - S(level 3 = intersection of levels 1 & 2)
// Prepare shat3 if 2-level clustering
		if (vcvo.clustvarname2~="") {
			if (vcvo.kernel~="") {	// second cluster variable is time
									// shat3 was already calculated above as shat
				shat3=shat*(vcvo.N-vcvo.dofminus)
			}
			else {					// calculate shat3
									// data were sorted on clustvar3-clustvar1 so
									// clustvar3 is nested in clustvar1 and Mata panel functions
									// work for both.
				info3 = panelsetup(clustvar3, 1)
				if (rows(info3)==rows(*vcvo.e)) {	// intersection of levels 1 & 2 are all single obs
													// so no need to loop through row by row
					if (K==1) {										// simple/fast where e is a column vector
						wv = (*vcvo.e :* *vcvo.wvar * vcvo.wf):^2
						shat3=quadcross(*vcvo.Z, wv, *vcvo.Z)		// basic Eicker-Huber-White-sandwich-robust vce
					}
					else {											// e is a matrix so must loop
						shat3=J(L*K,L*K,0)
						for (i=1; i<=rows(*vcvo.e); i++) {
							eZi=((*vcvo.e)[i,.])#((*vcvo.Z)[i,.])
							shat3=shat3+quadcross(eZi,eZi)*((*vcvo.wvar)[i] * vcvo.wf)^2	//  **** ADDED *vcvo.wf
							}
						}
				}
				else {								// intersection of levels 1 & 2 includes some groups of obs
					N_clust3=rows(info3)
					shat3=J(L*K,L*K,0)
					for (i=1; i<=N_clust3; i++) {
						esub=panelsubmatrix(*vcvo.e,i,info3)
						Zsub=panelsubmatrix(*vcvo.Z,i,info3)
						wsub=panelsubmatrix(*vcvo.wvar,i,info3)
						wv = esub :* wsub * vcvo.wf
						if (K==1) {							// simple/fast where e is a column vector
							eZ = quadcross(1, wv, Zsub)		// equivalent to colsum(wv :* Zsub)
						}
						else {
							eZ = J(1,L*K,0)
							for (j=1; j<=rows(esub); j++) {
								eZ=eZ+(esub[j,.]#Zsub[j,.])*wsub[j,.] * vcvo.wf	//  **** ADDED *vcvo.wf
							}
						}
						shat3=shat3+quadcross(eZ,eZ)
					}
				}
			}
		}

// 1st level of clustering, no kernel-robust
// Entered unless 1-level clustering and kernel-robust
		if (!((vcvo.kernel~="") & (vcvo.clustvarname2==""))) {
			shat=J(L*K,L*K,0)
			for (i=1; i<=N_clust; i++) {		// loop through clusters, adding Z'ee'Z
												// for indiv cluster in each loop
				esub=panelsubmatrix(*vcvo.e,i,info)
				Zsub=panelsubmatrix(*vcvo.Z,i,info)
				wsub=panelsubmatrix(*vcvo.wvar,i,info)
				if (K==1) {						// simple/fast if e is a column vector
					wv = esub :* wsub * vcvo.wf
					eZ = quadcross(1, wv, Zsub)		// equivalent to colsum(wv :* Zsub)
				}
				else {
					eZ=J(1,L*K,0)
					for (j=1; j<=rows(esub); j++) {
						eZ=eZ+(esub[j,.]#Zsub[j,.])*wsub[j,.]*vcvo.wf	//  **** ADDED *vcvo.wf
					}
				}
				shat=shat+quadcross(eZ,eZ)
			}	// end loop through clusters
		}

// 2-level clustering, no kernel-robust
		if ((vcvo.clustvarname2~="") & (vcvo.kernel=="")) {
			imax=max(clustvar2)					// clustvar2 is numbered 1..N_clust2
			shat2=J(L*K,L*K,0)
			for (i=1; i<=imax; i++) {			// loop through clusters, adding Z'ee'Z
												// for indiv cluster in each loop
				svar=(clustvar2:==i)			// mimics panelsubmatrix but doesn't require sorted data
				esub=select(*vcvo.e,svar)		// it is, however, noticably slower.
				Zsub=select(*vcvo.Z,svar)
				wsub=select(*vcvo.wvar,svar)
				if (K==1) {						// simple/fast if e is a column vector
					wv = esub :* wsub * vcvo.wf
					eZ = quadcross(1, wv, Zsub)		// equivalent to colsum(wv :* Zsub)
				}
				else {
					eZ=J(1,L*K,0)
					for (j=1; j<=rows(esub); j++) {
						eZ=eZ+(esub[j,.]#Zsub[j,.])*wsub[j,.]*vcvo.wf	//  **** ADDED *vcvo.wf
					}
				}
				shat2=shat2+quadcross(eZ,eZ)
			}
		}

// 1st level of cluster, kernel-robust OR
// 2-level clustering, kernel-robust and time is 2nd cluster variable
		if (vcvo.kernel~="") {
			shat2=J(L*K,L*K,0)
// First, standard cluster-robust, i.e., no lags.
			i=min(t)
			while (i<=max(t)) {  				// loop through all T clusters, adding Z'ee'Z
												// for indiv cluster in each loop
				eZ=J(1,L*K,0)
				svar=(t:==i)					// select obs with t=i
				if (colsum(svar)>0) {			// there are obs with t=i
					esub=select(*vcvo.e,svar)
					Zsub=select(*vcvo.Z,svar)
					wsub=select(*vcvo.wvar,svar)
					if (K==1) {						// simple/fast if e is a column vector
						wv = esub :* wsub * vcvo.wf
						eZ = quadcross(1, wv, Zsub)		// equivalent to colsum(wv :* Zsub)
					}
					else {
// MISSING LINE IS NEXT
						eZ=J(1,L*K,0)
						for (j=1; j<=rows(esub); j++) {
							eZ=eZ+(esub[j,.]#Zsub[j,.])*wsub[j,.]*vcvo.wf	//  **** ADDED *vcvo.wf
						}
					}
					shat2=shat2+quadcross(eZ,eZ)
				}
				i=i+vcvo.tdelta
			} // end i loop through all T clusters

// Spectral windows require looping through all T-1 autocovariances
			if (window=="spectral") {
				TAU=T/vcvo.tdelta-1
			}
			else {
				TAU=vcvo.bw
			}

			for (tau=1; tau<=TAU; tau++) {
				kw = m_actest9_calckw(tau, vcvo.bw, vcvo.kernel)	// zero weight possible with some kernels
															// save an unnecessary loop if kw=0
															// remember, kw<0 possible with some kernels!
				if (kw~=0) {
					i=min(t)+tau*vcvo.tdelta				// Loop through all possible ts (time clusters)
					while (i<=max(t)) {						// Start at earliest possible t
						svar=t[.,]:==i						// svar is current, svar1 is tau-th lag
						svar1=t[.,]:==(i-tau*vcvo.tdelta)	// tau*vcvo.tdelta is usually just tau
						if ((colsum(svar)>0)				// there are current & lagged obs
								& (colsum(svar1)>0))	 {
							wv  = select((*vcvo.e),svar)  :* select((*vcvo.wvar),svar)  * vcvo.wf
							wv1 = select((*vcvo.e),svar1) :* select((*vcvo.wvar),svar1) * vcvo.wf
							Zsub =select((*vcvo.Z),svar)
							Zsub1=select((*vcvo.Z),svar1)
							if (K==1) {						// simple/fast, e is column vector
								eZsub = quadcross(1, wv, Zsub)		// equivalent to colsum(wv :* Zsub)
								eZsub1= quadcross(1, wv1, Zsub1)	// equivalent to colsum(wv :* Zsub)
							}
							else {
								eZsub=J(1,L*K,0)
								for (j=1; j<=rows(Zsub); j++) {
									wvj =wv[j,.]
									Zj  =Zsub[j,.]
									eZsub=eZsub+(wvj#Zj)
								}
								eZsub1=J(1,L*K,0)
								for (j=1; j<=rows(Zsub1); j++) {
									wv1j =wv1[j,.]
									Z1j  =Zsub1[j,.]
									eZsub1=eZsub1+(wv1j#Z1j)
								}
							}
							ghat=quadcross(eZsub,eZsub1)
							shat2=shat2+kw*(ghat+ghat')
						}
						i=i+vcvo.tdelta
					}
				}	// end non-zero kernel weight block
			}	// end tau loop

// If 1-level clustering, shat2 just calculated above is actually the desired shat
			if (vcvo.clustvarname2=="") {
				shat=shat2
			}
		}

// 2-level clustering, completion
// Cameron-Gelbach-Miller/Thompson method:
// Add 2 cluster variance matrices and subtract 3rd
		if (vcvo.clustvarname2~="") {
			shat = shat+shat2-shat3
		}		

// Note no dof correction required for cluster-robust
	shat=shat/vcvo.N
	} // end cluster-robust code

	if (vcvo.sw~="") {
// Stock-Watson adjustment.  Calculate Bhat in their equation (6).  Also need T=panel length.
// They define for balanced panels.  Since T is not constant for unbalanced panels, need
// to incorporate panel-varying 1/T, 1/(T-1) and 1/(T-2) as weights in summation.

		st_view(ivar, ., st_tsrevar(vcvo.ivarname), vcvo.touse)
		info_ivar = panelsetup(ivar, 1)

		shat=J(L*K,L*K,0)
		bhat=J(L*K,L*K,0)
		N_panels=0
		for (i=1; i<=rows(info_ivar); i++) {
			esub=panelsubmatrix(*vcvo.e,i,info_ivar)
			Zsub=panelsubmatrix(*vcvo.Z,i,info_ivar)
			wsub=panelsubmatrix(*vcvo.wvar,i,info_ivar)
			Tsub=rows(esub)
			if (Tsub>2) {			// SW cov estimator defined only for T>2
				N_panels=N_panels+1
				sigmahatsub=J(K,K,0)
				ZZsub=J(L*K,L*K,0)
				shatsub=J(L*K,L*K,0)
				for (j=1; j<=rows(esub); j++) {
					eZi=esub[j,1]#Zsub[j,.]
					if ((vcvo.weight=="fweight") | (vcvo.weight=="iweight")) {
						shatsub=shatsub+quadcross(eZi,eZi)*wsub[j]*vcvo.wf
						sigmahatsub=sigmahatsub + quadcross(esub[j,1],esub[j,1])*wsub[j]*vcvo.wf
						ZZsub=ZZsub+quadcross(Zsub[j,.],Zsub[j,.])*wsub[j]*vcvo.wf
					}
					else {
						shatsub=shatsub+quadcross(eZi,eZi)*((wsub[j]*vcvo.wf)^2)
						sigmahatsub=sigmahatsub + quadcross(esub[j,1],esub[j,1])*((wsub[j]*vcvo.wf)^2)
						ZZsub=ZZsub+quadcross(Zsub[j,.],Zsub[j,.])*((wsub[j]*vcvo.wf)^2)
					}
				} // end loop through j obs of panel i
				shat=shat + shatsub*(Tsub-1)/(Tsub-2)
				bhat=bhat + ZZsub/Tsub#sigmahatsub/(Tsub-1)/(Tsub-2)
			}
		} // end loop through i panels

// Note that Stock-Watson incorporate an N-n-k degrees of freedom correction in their eqn 4
// for what we call shat.  We use only an N-n degrees of freedom correction, i.e., we ignore
// the k regressors.  This is because this is an estimate of S, the VCV of orthogonality conditions,
// independently of its use to obtain an estimate of the variance of beta.  Makes no diff aysmptotically.
// Ignore dofminus correction since this is explicitly handled here.
// Use number of valid panels in denominator (SW cov estimator defined only for panels with T>2).
		shat=shat/(vcvo.N-N_panels)
		bhat=bhat/N_panels
		shat=shat-bhat
	} // end Stock-Watson block

	_makesymmetric(shat)

// shat may not be positive-definite.  Use spectral decomposition to obtain an invertable version.
// Extract Eigenvector and Eigenvalues, replace EVs, and reassemble shat.
// psda option: Stock-Watson 2008 Econometrica, Remark 8, say replace neg EVs with abs(EVs).
// psd0 option: Politis (2007) says replace neg EVs with zeros.
	if (vcvo.psd~="") {
		symeigensystem(shat,Evec,Eval)
		if (vcvo.psd=="psda") {
			Eval = abs(Eval)
		}
		else {
			Eval = Eval + (abs(Eval) - Eval)/2
		}
		shat = Evec*diag(Eval)*Evec'
		_makesymmetric(shat)
	}

	return(shat)

} // end of program m_actest9_omega

// *********************************************************************** //
// *********************************************************************** //

real scalar m_actest9_calckw(	real scalar tau,
							real scalar bw,
							string scalar kernel) 
	{
				karg = tau / bw
				if (kernel=="Truncated") {
					kw=1
				}
				if (kernel=="Bartlett") {
					kw=(1-karg)
				}
				if (kernel=="Parzen") {
					if (karg <= 0.5) {
						kw = 1-6*karg^2+6*karg^3
					}
					else {
						kw = 2*(1-karg)^3
					}
				}
				if (kernel=="Tukey-Hanning") {
					kw=0.5+0.5*cos(pi()*karg)
				}
				if (kernel=="Tukey-Hamming") {
					kw=0.54+0.46*cos(pi()*karg)
				}
				if (kernel=="Tent") {
					kw=2*(1-cos(tau*karg)) / (karg^2)
				}
				if (kernel=="Danielle") {
					kw=sin(pi()*karg) / (pi()*karg)
				}
				if (kernel=="Quadratic Spectral") {
					kw=25/(12*pi()^2*karg^2) /*
						*/ * ( sin(6*pi()*karg/5)/(6*pi()*karg/5) /*
						*/     - cos(6*pi()*karg/5) )
				}
				return(kw)
	}  // end kw

// *********************************************************************** //
// *********************************************************************** //


end

* Version notes
* Cumby-Huizinga-Arellano-Bond general specification test of serial correlation after OLS/IV/GMM estimation
* Cumby-Huizinga, NBER Technical Working Paper 90, 1990.
* Cumby-Huizinga, Econometrica, 60:1, 1992, 185-195
* Arellano-Bond, Review of Economic Studies, 58:2, 1991, 277-297
* 1.0.0: 27Jan2007 
* 1.0.1: 31Jan2007 switch to Bartlett weights if Psi not p.d.;
*        allow for N=0 (regress without robust vce)
* 1.0.2: 02Feb2007 Fold in ivsc logic for i.i.d. errors
* 1.0.3: 04Feb2007 correct handling of A, disallow cluster
* 1.0.4: 14jul2007 guard against multiple panels, corrgram under if
* 1.0.5: 19Aug2007 Added trap for partialling-out by ivreg2
* 2.0.0: 22Dec2012 Complete rewrite
* 2.0.1: 30Dec2012 Explicit bw(0) allowed. Report if S-W eigenvalue adjustment used.
*                  2-way clustering support added.
* 2.0.2: 01Mar2013 Bug fix for capturing det(psi)<0 => use S-W method to force PSD
* 2.0.3: 24Jun2013 Redubbed actest. Support for univariate test added.
* 2.0.04 27Jun2013 Renaming/reconfigation of user-specified options and options inherited from estimation
* 2.0.05 03Jul2013 Added strictexog, q0, bp, small. Removed cmd arg to m_actest.  Restructured reporting, modified tests.
* 2.0.06 04Jul2013 Output indicates which test statistics required npsd adjustment
* 2.0.07 23Jul2013 Output cleanup
* 2.0.08 23Jul2013 Catch "last estimates not found" error
* 2.0.09 25Jul2013 Modify tsrevar calls to fvrevar calls
* 2.0.10 21Jan2014 Fixed reporting bug with 2-way clustering and kernel-robust
*                  that would give wrong count for 2nd cluster variable.
*                  Fixed bug that would cause crash if TS operators used with cluster.
*                  Tweaked output header so that BP, LB, BG, AB tests cited.
*                  Changed lags option to take lag as minimal abbreviation
* 2.0.11 22jan2014 Allow TS ops in depvar
* 2.0.12 24jan2014 Fixed minor bug in footnotes (wouldn't announce strict/weak exogeneity)
* 2.0.13 22Jan2013 First version of actest9. Mata library now internal with names incorporating "_actest9_".
*                  Changed subroutine name from acstat to s_acstat.

* Version notes for imported version of Mata library
* 1.1.01     First version of library.
*            Contains struct ms_vcvorthog, m_omega, m_calckw, s_vkernel.
*            Compiled in Stata 9.2 for compatibility with ranktest 1.3.01 (a 9.2 program).
* 1.1.02     Add routine cdsy. Standardized spelling/caps/etc. of QS as "Quadratic Spectral"
* 1.1.03     Corrected spelling of "Danielle" kernel in m_omega()
* 1.1.04     Fixed weighting bugs in robust and cluster code of m_omega where K>1
* 1.1.05     Added whichlivreg2(.) to aid in version control
* 1.1.06     Fixed remaining weighting bug (see 1.1.04) in 2-way clustering when interection
*            of clustering levels is groups
* 1.1.07     Fixed HAC bug that crashed m_omega(.) when there were no obs for a particular lag
