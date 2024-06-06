program define bayerhanck, eclass
version 10.0
local m1 = _N
syntax varname(ts numeric)  [if] [in] , Rhs(varlist) [Trend(string) Lags(numlist integer max=1 >=0 <`m1') Crit(numlist integer)]
marksample touse
*-------------------------------------------------------------------------------
* This ado-file carries out the Cointegration Test by Bayer and Hanck (2009).
* It requires a left-hand side variable and a set of right-hand side variables
* to be chosen. The syntax is: bayerhanck lhsvar, rhs(rhsvar).
*
* - Three trend specifications are possible: "none", "constant", and "trend".
*
* - lags(numlist) specifies the number of augmentation lags to be used in each 
* underlying test
* 
* - crit(1 5 10) specifies the critical values to be reported. 
*
* The code then runs as underlying cointegration tests the tests by Johansen, 
* Engle and Granger, Boswijk, and Banerjee.
* For details see:
* Christian Bayer and Christoph Hanck (2009): "Combining Non-Cointegration Tests",
* 	METEOR Reseacrh Memorandum 12/2009, Universty of Maastricht
*     http://edocs.ub.unimaas.nl/loader/file.asp?id=1391
*
* The Distributions under the Null of these tests are supplied in the File 
* NullDistributions.dta, which has to be in the same folder as the .ado file.
*
* Authors: 	Christian Bayer, Universität Bonn
*		Christoph Hanck, Universitaat Maastricht
* Version 0.9
* Date: 05 June 2009
* 
*--------------------------------------------------------------------------------

qui findfile bayerhanck.ado, path(UPDATES;BASE;SITE;.;PERSONAL;PLUS)
tempvar ort
qui gen `ort'="`r(fn)'"
qui replace `ort'=reverse(`ort')
qui replace `ort'=substr(`ort',15,.)
qui replace `ort'=reverse(`ort')
local ortaux=`ort' in 1


*-----------------------------------------------------------
* Check Syntax, Define Defaults
*-----------------------------------------------------------

if "`trend'"=="" {
	local trend="constant"
}
if "`lags'"=="" {
	local lags=1
} 
if "`trend'"!="none" & "`trend'"!="constant" & "`trend'"!="trend" {
	di as err "Trend cannot be specified as " as res "`trend'" 
	exit 198
}
if "`crit'"=="" {
	local crit=5
} 

*----------------------------------------------------------
* Code trendtypes
*----------------------------------------------------------
qui {

if "`trend'"=="none" {
	local ending = "if `touse', noc"
	local trendtype=1
}
else if "`trend'"=="constant" {
	local ending = "if `touse'"
	local trendtype=2
}
else if "`trend'"=="trend" {
	local ending="if `touse'"
	tsset
	local ending=" `r(timevar)' `ending'"
	local trendtype=3
}

mat stat=(0,0,0,0)

*-------------------------------------------------------
* 1) Run Underlying Tests
*-------------------------------------------------------
* 1.1) Engle Granger Test
*-------------------------------------------------------

regress `varlist'  `rhs' `ending'
tempvar error
predict `error', r
dfuller `error' if `touse', lags(`lags') nocon
mat stat[1,1]=`r(Zt)'
drop `error'

*-------------------------------------------------------
* 1.2) Johansen Test
*-------------------------------------------------------
local jlags=`lags'+1
vecrank `varlist' `rhs' if `touse', trend(`trend') lags(`jlags')
mat aux=e(max)
mat stat[1,2]=aux[1,1]
local nvar=`e(k_eq)'


*-------------------------------------------------------
* 1.3) Boswijk / Banerjee Tests
*-------------------------------------------------------
local Xlag = "`varlist' `rhs'"
local Ydif = "d.`varlist'" 
local W = "d.(`rhs')"

if `lags'>=1 {
	local W = "`W' l.(1/`lags').d.(`Xlag')"
}
local count=0
foreach rhv in `Xlag' {
	local count=`count'+1
	regress l.`rhv' `W' `ending'
	tempvar error`count'
	predict `error`count'', r
	
}
regress `Ydif' `W' `ending'
tempvar errLHV
predict `errLHV', r
regress `errLHV' `error1' - `error`count'' `ending'
mat betas= e(b)
mat var= e(V)
mat stat[1,3]=betas[1,1]/sqrt(var[1,1])
mat stat[1,4]=betas*inv(var)*betas'
capture drop `error1' - `error`count'' `errLHV'

*-------------------------------------------------------
* 2) Obtain P-Values
*-------------------------------------------------------
* 2.1) Load Null-Distribution
*-------------------------------------------------------
preserve
use "`ortaux'NullDistr.dta", clear
mat pval=stat
local basecase=44*(`trendtype'-1)+4*(`nvar'-2)


*---------------------------------------------
* 2.2) Calculate P-Values
*---------------------------------------------
forv j=1/4 {
	local case=`basecase'+`j'
	if `j'==1 | `j'==3 {
		count if stat[1,`j']>var`case'
		mat pval[1,`j']=`r(N)'/_N+.000000000001
	}
	else if `j'==2 | `j'==4 {
		count if stat[1,`j']<var`case'
		mat pval[1,`j']=`r(N)'/_N+.000000000001
	}
}

*-------------------------------------------------
* 2.3) Restore Original Data
*-------------------------------------------------
restore

*-------------------------------------------------
* 3) Calculate Bayer-Hanck Fisher Statistics
*-------------------------------------------------
local statistic1=-2*(log(pval[1,1])+log(pval[1,2]))
local statistic2=-2*(log(pval[1,1])+log(pval[1,2])+log(pval[1,3])+log(pval[1,4]))
*local statistic3=min(pval[1,1],pval[1,2])
*local statistic4=min(min(pval[1,1],pval[1,2]),min(pval[1,3],pval[1,4]))

if `crit'==1 {
	mat critvals1 = (	16.948	,	17.304	,	17.289	\ ///
	16.651	,	16.679	,	16.720	\ ///
	16.236	,	16.259	,	16.263	\ ///
	15.871	,	15.845	,	15.973	\ ///
	15.626	,	15.701	,	15.666	\ ///
	15.412	,	15.348	,	15.467	\ ///
	15.312	,	15.313	,	15.184	\ ///
	15.183	,	15.000	,	15.016	\ ///
	14.960	,	15.007	,	15.069	\ ///
	14.893	,	14.853	,	14.788	\ ///
	14.690	,	14.826	,	14.745	)
	mat critvals2 = (	32.713	,	33.969	,	34.334	\ ///
	31.793	,	32.077	,	32.601	\ ///
	30.651	,	31.169	,	31.742	\ ///
	30.088	,	30.774	,	30.836	\ ///
	29.800	,	29.850	,	30.113	\ ///
	29.222	,	29.544	,	29.962	\ ///
	28.974	,	29.037	,	29.440	\ ///
	28.780	,	28.999	,	29.084	\ ///
	28.326	,	28.840	,	28.875	\ ///
	28.208	,	28.575	,	28.577	\ ///
	27.945	,	28.055	,	28.518	)
}
else if `crit'==5 {
	mat critvals1 = (	11.071, 11.229, 11.269 \ 10.838, 10.895, 10.858 \ /*
	*/		10.640, 10.637, 10.711 \ 10.516, 10.576, 10.532\ /*
	*/		10.406, 10.419, 10.448 \ 10.312, 10.352, 10.311 \ /*
	*/		10.218, 10.295, 10.222 \ 10.185, 10.181, 10.189 \ /*
	*/		10.162, 10.154, 10.164 \ 10.079, 10.109, 10.070 \ /*
	*/		10.057, 10.059, 10.134)
	mat critvals2 = (	21.352, 21.931, 22.215 \ 20.776, 21.106, 21.342 \ ///
			20.237, 20.486, 20.788 \ 19.951, 20.143, 20.440 \ ///
			19.747, 19.888, 20.170 \ 19.564, 19.761, 19.934 \ ///
			19.471, 19.688, 19.722 \ 19.471, 19.447, 19.678 \ ///
			19.365, 19.492, 19.582 \ 19.268, 19.365, 19.398 \ ///
			19.151, 19.345, 19.404)
}
else if `crit'==10 {
	mat critvals1 = (	8.612	,	8.678	,	8.686	\ ///
	8.457	,	8.479	,	8.451	\ ///
	8.350	,	8.363	,	8.352	\ ///
	8.290	,	8.301	,	8.272	\ ///
	8.221	,	8.242	,	8.276	\ ///
	8.165	,	8.200	,	8.199	\ ///
	8.125	,	8.169	,	8.146	\ ///
	8.106	,	8.134	,	8.146	\ ///
	8.067	,	8.108	,	8.096	\ ///
	8.081	,	8.067	,	8.095	\ ///
	8.084	,	8.053	,	8.084	)

	mat critvals2 = (	16.593	,	16.964	,	17.187	\ ///
	16.171	,	16.444	,	16.507	\ ///
	15.920	,	16.097	,	16.239	\ ///
	15.776	,	15.938	,	16.086	\ ///
	15.681	,	15.804	,	15.989	\ ///
	15.644	,	15.746	,	15.872	\ ///
	15.611	,	15.731	,	15.706	\ ///
	15.561	,	15.591	,	15.705	\ ///
	15.507	,	15.528	,	15.647	\ ///
	15.422	,	15.476	,	15.565	\ ///
	15.406	,	15.476	,	15.564	)
}

*mat critvals3 = (	0.031	,	0.033	,	0.033	\ ///
*	0.03	,	0.03	,	0.03	\ ///
*	0.029	,	0.029	,	0.029	\ ///
*	0.028	,	0.028	,	0.028	\ ///
*	0.028	,	0.028	,	0.028	\ ///
*	0.027	,	0.027	,	0.028	)


local nvar=`nvar'-1
local cv1=critvals1[`nvar',`trendtype'] 
local cv2=critvals2[`nvar',`trendtype'] 
*local cv3=critvals3[`nvar',`trendtype']   
} 

*-------------------------------------------------
* 4) Display Results
*-------------------------------------------------
di " "
di as txt "---------------------------------------------------"
di as txt "    Bayer-Hanck (2009) Test for Cointergration"
di as txt "---------------------------------------------------"
di " "

mat rownames pval = "P-Values"
mat colnames pval = "Engle-Granger" "Johansen" "Banerjee" "Boswijk"
mat rownames stat = "Test Statistics"
mat colnames stat = "Engle-Granger" "Johansen" "Banerjee" "Boswijk"
di as text "Underlying Tests:"
mat summary= (pval \ stat)
mat list summary, noheader f(%9.4f)
di " "
di as text "Fisher Type Test statistics, Bayer Hanck Test"
di as text "EG-J:       " as res `statistic1' as txt ///
	"     , `crit'% critical value: " as res `cv1'
di as text "EG-J-Ba-Bo- " as res `statistic2' as txt ///
	"     , `crit'% critical value: " as res `cv2'
di " "
*di "----------------------------------------------------- "
*di " "
*di as text "Min-Pval Type Test statistics, Bayer Hanck Test"
*di as text "EG-J:       " as res `statistic3' as txt ///
*	"     , `crit'% critical value: " as res `cv3'
*di as text "EG-J-Ba-Bo- " as res `statistic4' as txt ///
*	"     , `crit'% critical value: " as res `cv2'
*------------------------------------------------
* 5) Save Results for Output
*------------------------------------------------

eret clear
ret clear
eret scalar EJ = `statistic1'
eret scalar BECREJ = `statistic2'
eret scalar CRIT_EJ = `cv1'
eret scalar CRIT_BECREJ = `cv2'
eret scalar crit_lvl = `crit'
eret mat PV = pval
eret mat STAT = stat
end

