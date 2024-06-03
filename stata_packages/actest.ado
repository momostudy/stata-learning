*! actest 2.0.14 CFB/MES 25Jan2015
*! see end of file for version comments

if c(version) < 12 {
* livreg2 Mata library.
* Ensure Mata library is indexed if new install.
* Not needed for Stata 12+ since ssc.ado does this when installing.
	capture mata: mata drop m_calckw()
	capture mata: mata drop m_omega()
	capture mata: mata drop ms_vcvorthog()
	capture mata: mata drop s_vkernel()
	capture mata: mata drop s_cdsy()
	mata: mata mlib index
}

program define actest, rclass sortpreserve

	local lversion 02.0.14

* Minimum of version 9 required
	version 9
	if replay() {
* Replay = no arguments before comma
* Call to actest will either be for version, in which case there should be no other arguments,
* or a postestimation call, in which case control should pass to main program.
		syntax [, VERsion * ]
		if "`version'"~="" & "`options'"=="" {
* Call to actest is for version
			di in gr "`lversion'"
			return local version `lversion'
			exit	
		}
		else if "`version'"~="" & "`options'"~="" {
* Improper use of actest version option
di as err "invalid syntax - cannot combine version with other options"
			exit 198
		}
		else {
* Postestimation call, so put `options' macro (i.e. *) into `0' macro with preceding comma
			local 0 , `options'
		}
	}

* If calling version is < 11, pass control to actest9.
* Note that this means calls from version 11.0 won't pass version 11.2 below.
	if _caller() < 11 {
		actest9 `0'
		return add
		return local actestcmd "actest9"
		exit
	}
	version 11.2

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
		mata: s_vkernel("`kernel'", "`bw'", "`ivar'")
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

	return local actestcmd "actest"

end

cap version 11.2
mata:
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

	struct ms_vcvorthog scalar vcvo
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

	psi=m_omega(vcvo)

// psda option: Stock-Watson 2008 Econometrica, Remark 8, say replace neg EVs with abs(EVs).
	if (det(psi) < 0) {
// Use S-W approach to make PSD
		vcvo.psd = "psda"
		psi=m_omega(vcvo)
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
* 2.0.13 22Jan2015 Promotion to version 11; forks to actest9 if version<=10; requires
*                  capture before "version 11.2" in Mata section since must load before forking.
*                  Added version option.  Changed subroutine name from acstat to s_acstat.
* 2.0.14 25Jan2015 Minor reordering of version option so that fork to actest9 is after version check.
*                  Added actestcmd macro (="actest" or "actest9")
