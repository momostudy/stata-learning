 
*! S. HSIANG 6/2010: PROGRAM TO ESTIMATE SPATIAL HAC ERRORS FOR OLS REGRESSION MODEL [V3 UPDATE 6/2018]

/*-----------------------------------------------------------------------------

 v1 S. HSIANG 6/10 [SMH2137@COLUMBIA.EDU]

 v2 UPDATE 6/13 [SHSIANG@PRINCETON.EDU]:
	INTRODUCED 'DROPVAR' OPTION BASED ON CODE PROVIDED BY KYLE MENG
 
 V3 UPDATE 6/18 [SHSIANG@BERKELEY.EDU]: 
	CORRECTED ERROR (LINE 428) FOUND BY MATHIAS THOENIG THAT INCORRECTLY 
	COMPUTED WEIGHTS FOR INTER-TEMPORAL AUTOCORRELATION ESTIMATES WITHIN PANEL 
	UNITS. SIGN OF BIAS IN V2 IS INDETERMINATE, DEPENDS ON LAG LENGTH AND DATA 
	STRUCTURE.

 V4 UPDATE 3/20 [RAMIN.FOROUZANDEH@ROTMAN.UTORONTO.CA]:
	INTRODUCED THE OPTION OF INSTRUMENTAL VARIABLE REGRESSION AND ADDED WEIGHTS
 ------------------------------------------------------------------------------

 This may contain errors. Please notify me of any errors you find.
 
 ------------------------------------------------------------------------------

 Syntax:
 
 ols_spatial_HAC Yvar Xvarlist (ENDGvariable = EXGvarlist), lat(latvar) lon(lonvar) Timevar(tvar) Panelvar(pvar) [DISTcutoff(#) LAGcutoff(#) bartlett DISPlay star dropvar]

 Function calculates non-parametric (GMM) spatial and autocorrelation 
 structure using a panel data set.  Spatial correlation is estimated for all
 observations within a given period.  Autocorrelation is estimated for a
 given individual over multiple periods up to some lag length. Var-Covar
 matrix is robust to heteroskedasticity.
 
 A variable equal to 1 is required to estimate a constant term.
 
 Example commands:
 
 ols_spatial_HAC dep indep1 indep2 const, lat(C1) lon(C2) t(year) p(id) dist(300) lag(3) bartlett disp

 ols_spatial_HAC dep indep*, lat(C1) lon(C2) timevar(year) panelvar(id) dist(100) lag(2) star dropvar

 ------------------------------------------------------------------------------
 
 Requred arguments: 
 
 Yvar: dependent variable  
 Xvarlist: independnet variables (INCLUDE constant as column)
 latvar: variable containing latitude in DEGREES of each obs
 lonvar: same, but longitude
 tvar: varible containing time variable
 pvar: variable containing panel variable (must be numeric, see "encode")
 
 ------------------------------------------------------------------------------
 
 Optional arguments:
 
 distcutoff(#): {abbrev dist(#)} describes the distance cutoff in KILOMETERS for the spatial kernal (the distance at which spatial correlation is assumed to vanish). Default is 1 KM.
 
 lagcutoff(#): {abbrev lag(#)} describes the maximum number of temporal periods for the linear Bartlett window that weights serial correlation across time periods (the distance at which serial correlation is assumed to vanish). Default is 0 PERIODS (no serial correlation). {Note, Greene recommends at least T^0.25}  
 
 (ENDGvariable = EXGvarlist): uses EXGvarlist as an instrument for ENDGvariable and runs a 2sls instead of OLS in the main specification
 ------------------------------------------------------------------------------
 
 Options:
 
 bartlett: use a linear bartlett window for spatial correlations, instead of a uniform kernal
 
 display: {abbrev disp} display a table with estimated coeff and SE & t-stat using OLS, adjusting for spatial correlation and adjusting for both spatial and serial correlation. Can be used with star option. Ex:
 
 -----------------------------------------------
     Variable |   OLS      spatial    spatHAC   
 -------------+---------------------------------
       indep1 |    0.568      0.568      0.568  
              |    0.198      0.206      0.240  
              |    2.876      2.761      2.369  
        const |    6.415      6.415      6.415  
              |    0.790      1.176      1.340  
              |    8.119      5.454      4.786  
 -----------------------------------------------
                                  legend: b/se/t
 

 star: same as display, but uses stars to denote significance and does not show SE & t-stat. Can be used with display option. Ex:
 
 -----------------------------------------------------
     Variable |    OLS        spatial      spatHAC    
 -------------+---------------------------------------
       indep1 |   0.568***     0.568***     0.568**   
        const |   6.415***     6.415***     6.415***  
 -----------------------------------------------------
                   legend: * p<.1; ** p<.05; *** p<.01
                   
                   
 dropvar: Drops variables that Stata would drop due to collinearity. This requires that an additiona regression is run, so it slows the code down. For large datasets, if this function is called many times, it may be faster to ensure that colinear variables are dropped in advance rather than using the option dropvar. If Stata returns "estimates post: matrix has missing values", than including the option dropvar may solve the problem. (This option written by Kyle Meng).
 
 ------------------------------------------------------------------------------
 
 Implementation:
 
 The default kernal used to weight spatial correlations is a uniform kernal that
 discontinously falls from 1 to zero at length locCutoff in all directions (it is isotropic). This is the kernal recommented by Conley (2008). If the option "bartlett" is selected, a conical kernal that decays linearly with distance in all directions is used instead.
 
 Serial correlation bewteen observations of the same individual over multiple periods seperated by lag L are weighted by 

       w(L) = 1 - L/(lagCutoff+1)
       
 ------------------------------------------------------------------------------

 Notes:

 Location arguments should specify lat-lon units in DEGREES, however
 distcutoff should be specified in KILOMETERS. 

 distcutoff must exceed zero. CAREFUL: do not supply
 coordinate locations in modulo(360) if observations straddle the
 zero-meridian or in modulo(180) if they straddle the date-line. 

 Distances are computed by approximating the planet's surface as a plane
 around each observation.  This allows for large changes in LAT to be
 present in the dataset (it corrects for changes in the length of
 LON-degrees associated with changes in LAT). However, it does not account
 for the local curvature of the surface around a point, so distances will
 be slightly lower than true geodesics. This should not be a concern so
 long as locCutoff is < O(~2000km), probably.

 Each time-series for an individual observation in the panel is treated
 with Heteroskedastic and Autocorrelation Standard Errors. If lagcutoff =
 0, than this estimate is equivelent to White standard errors (with spatial correlations 
 accounted for). If lagcutoff = infinity, than this treatment is
 equivelent to the "cluster" command in Stata at the panel variable level.

 This script stores estimation results in standard Stata formats, so most "ereturn" commands should work properly.  It is also compatible with "outreg2," although I have not tested other programs.

 The R^2 statistics output by this function will differ from analogous R^2 stats
 computed using "reg" since this function omits the constant. 
 ------------------------------------------------------------------------------

 References:

      TG Conley "GMM Estimation with Cross Sectional Dependence" 
      Journal of Econometrics, Vol. 92 Issue 1(September 1999) 1-45
      http://www.elsevier.com/homepage/sae/econworld/econbase/econom/frame.htm
      
      and 

      Conley "Spatial Econometrics" New Palgrave Dictionary of Economics,
      2nd Edition, 2008

      and

      Greene, Econometric Analysis, p. 546

	  and

	  Modified from scripts written by Ruben Lebowski and Wolfram Schlenker and Jean-Pierre Dube and Solomon Hsiang
	  Debugging help provided by Mathias Thoenig.
 
 -----------------------------------------------------------------------------*/
capture program drop ols_spatial_HAC
program ols_spatial_HAC, eclass byable(recall)
version 11
syntax [anything(name=0)] [if] [in] [aweight fweight pweight iweight/], ///
				lat(varname numeric) lon(varname numeric) ///
				Timevar(varname numeric) Panelvar(varname numeric) [LAGcutoff(integer 0) DISTcutoff(real 1) ///
				DISPlay star bartlett dropvar]
				
/*--------PARSING COMMANDS AND SETUP-------*/

capture drop touse
marksample touse				// indicator for inclusion in the sample
gen touse = `touse'
//parsing variables

tempvar wvar
if "`weight'" !="" {
	qui gen double `wvar'=`exp'
}
else {
	qui gen long `wvar'=1
	loc weight = "aweight"
}

if "`weight'" == "aweight" | "`weight'" == "pweight" {
			qui summ `wvar' if `touse', mean
			qui replace `wvar' = r(N)*`wvar'/r(sum)
}

if "`geodist'"=="geodist" {
	//*install geodist package for calculating distance if it is not already installed
	capture which geodist
	if _rc==111 ssc install geodist
}

local m 0
local ivflag 0 
local varlist
while `m'==0 {
	gettoken vchar 0 : 0 ,parse(" (,")
	if "`vchar'"=="(" {
		local ivflag = 1
	}

	if `ivflag' == 1 & "`exog'"==""{
		gettoken endog 0 : 0 ,parse("=")  //instrumented variables
		gettoken equal_s 0 : 0 ,parse("=")
		gettoken exog 0 : 0 ,parse(")")  //instruments
	}

	if "`vchar'"!="(" & "`vchar'"!=")" {
		local varlist "`varlist' `vchar'"
	}
	if "`vchar'"==""{
		local m = `m' + 1
	}

}

loc Y = word("`varlist'",1)		

loc listing "`varlist'"

loc XX ""
scalar k = 0

//make sure that Y is not included in the other_var list
foreach i of loc listing {
	if "`i'" ~= "`Y'"{
		loc XX "`XX' `i'"
		scalar k = k + 1 // # indep variables
		
	}
}

loc X "`XX'"

markout `touse' `Y' `X' `exog' `endog'
qui keep if `touse'
//Kyle Meng's code to drop omitted variables that Stata would drop due to collinearity

if "`dropvar'" == "dropvar"{

	quietly reg `Y' `X' if `touse', nocons

	mat omittedMat=e(b)
	local newVarList=""
	local i=1
	scalar k = 0 //replace the old k if this option is selected
	
	foreach var of varlist `X'{
		if omittedMat[1,`i']!=0{
			loc newVarList "`newVarList' `var'"
			scalar k = k + 1
		}
		local i=`i'+1
	}
	
	loc X "`newVarList'"
}

//generating a function of the included obs
quietly count if `touse'		
scalar n = r(N)					// # obs
scalar n_obs = r(N)

/*--------FIRST DO OLS/2SLS, STORE RESULTS-------*/
if `ivflag' == 0 {
	quietly: regress `Y' `X' [`weight'=`wvar'] if `touse', nocons
	estimates store OLS
}
else if `ivflag' == 1 {
	qui regress `Y' `XX'
	//qui xtivreg2 `Y'  ( `endog' = `exog' ) `XX' [`weight'=`wvar'] if `touse' , fe i(`panelvar') 
	qui ivregress 2sls `Y' `XX' ( `endog' = `exog' ) [`weight'=`wvar'] if `touse' ,nocons 
	estimates store twoSLS 
}
//est tab OLS, stats(N r2)

//generate matrices X and Z such that X includes all indep variables and `endog'
//and Z includes all indep variables and `exog'. matrix X_hat contains predicted
//first stage values

if `ivflag' == 1 {
	loc Z "`XX'"
	foreach var of varlist `exog' {
		loc Z "`var' `Z'"
		scalar k = k + 1
	}
	loc X "`endog' `XX'"
}
else if `ivflag' == 0 {
	loc Z "`X'"
}


/*--------SECOND, IMPORT ALL VALUES INTO MATA-------*/
mata{

Y_var = st_local("Y") //importing variable assignments to mata
X_var = st_local("X")
Z_var = st_local("Z")
endog_var = st_local("endog")
exog_var = st_local("exog")
lat_var = st_local("lat")
lon_var = st_local("lon")
time_var = st_local("timevar")
panel_var = st_local("panelvar")
wvar_var = st_local("wvar")
ivflag = st_local("ivflag")
//NOTE: values are all imported as "views" instead of being copied and pasted as Mata data because it is faster, however none of the matrices are changed in any way, so it should not permanently affect the data. 

st_view(Y=.,.,tokens(Y_var),"touse") //importing variables vectors to mata
st_view(X=.,.,tokens(X_var),"touse")
st_view(Z=.,.,tokens(Z_var),"touse")
st_view(lat=.,.,tokens(lat_var),"touse")
st_view(lon=.,.,tokens(lon_var),"touse")
st_view(time=.,.,tokens(time_var),"touse")
st_view(panel=.,.,tokens(panel_var),"touse")
st_view(endog=.,.,tokens(endog_var),"touse")
st_view(wvar=.,.,tokens(wvar_var),"touse")
st_view(exog=.,.,tokens(exog_var),"touse")

k = st_numscalar("k")				//importing other parameters
n = st_numscalar("n")
b = st_matrix("e(b)")				// (estimated coefficients, row vector)
lag_var = st_local("lagcutoff")
lag_cutoff = strtoreal(lag_var)
dist_var = st_local("distcutoff")
dist_cutoff = strtoreal(dist_var)

ZeeZ = J(k, k, 0) 				//set variance-covariance matrix equal to zeros
	
W = sqrt(wvar)					//getting the square root of weights for further calculations

Y = Y:*W						//adjust for weights
X = X:*W
Z = Z:*W

/*--------THIRD, CORRECT VCE FOR SPATIAL CORR-------*/

timeUnique = uniqrows(time)
Ntime = rows(timeUnique) 		// # of obs. periods

for (ti = 1; ti <= Ntime; ti++){	

	// 1 if in year ti, 0 otherwise:

	rows_ti = time:==timeUnique[ti,1] 	

	//get subsets of variables for time ti (without changing original matrix)

	Y1 = select(Y, rows_ti) 	
	X1 = select(X, rows_ti)
	Z1 = select(Z, rows_ti)

	lat1 = select(lat, rows_ti)
	lon1 = select(lon, rows_ti)
	
	e1 = Y1 - X1*b'
	
	
	
	n1 = length(Y1) 			// # obs for period ti

	//loop over all observations in period ti

	for (i = 1 ; i <=n1; i++){		

		//----------------------------------------------------------------
        // step a: get non-parametric weight

			//This is a Euclidean distance scale IN KILOMETERS specific to i
			
			lon_scale = cos(lat1[i,1]*pi()/180)*111 
			lat_scale = 111
			

			// Distance scales lat and lon degrees differently depending on
			// latitude.  The distance here assumes a distortion of Euclidean
			// space around the location of 'i' that is approximately correct for 
			// displacements around the location of 'i'
			//
			//	Note: 	1 deg lat = 111 km
			// 			1 deg lon = 111 km * cos(lat)

			distance_i = ((lat_scale*(lat1[i,1]:-lat1)):^2 + /// 	
						  (lon_scale*(lon1[i,1]:-lon1)):^2):^0.5

		
		// this sets all observations beyon dist_cutoff to zero, and weights all nearby observations equally [this kernal is isotropic]
		
		window_i = distance_i :<= dist_cutoff

		//----------------------------------------------------------------
        // adjustment for the weights if a "bartlett" kernal is selected as an option
 
		if ("`bartlett'"=="bartlett"){
			if (dist_cutoff > 0) {
				// this weights observations as a linear function of distance
				// that is zero at the cutoff distance
				
				weight_i = 1:- distance_i:/dist_cutoff

				window_i = window_i:*weight_i
			}
		}

        //----------------------------------------------------------------
        // step b: construct Z'e'eZ for the given observation
		// note that without instruments, this will be the same as X'e'eX
		
 		ZeeZh = ((Z1[i,.]'*J(1,n1,1)*e1[i,1]):*(J(k,1,1)*e1':*window_i'))*Z1

		//add each new k x k matrix onto the existing matrix (will be symmetric)
		
		ZeeZ = ZeeZ + ZeeZh

	} //i
} // ti


// -----------------------------------------------------------------
// generate the VCE for only cross-sectional spatial correlation, 
// return it for comparison

invZX = luinv(Z'*X) * n
			
ZeeZ_spatial = ZeeZ / n

V = invZX * ZeeZ_spatial * invZX' / n

// Ensures that the matrix is symmetric 
// in theory, it should be already, but it may not be due to rounding errors for large datasets

V = (V+V')/2 

st_matrix("V_spatial", V)

} // mata

//------------------------------------------------------------------
// storing old statistics about the estimate so postestimation can be used

matrix beta = e(b)


scalar r2_old = e(r2)
scalar df_m_old = e(df_m)
scalar df_r_old = e(df_r)
scalar rmse_old = e(rmse)
scalar mss_old = e(mss)
scalar rss_old = e(rss)
scalar r2_a_old = e(r2_a)

// the row and column names of the new VCE must match the vector b
local colnms: colnames e(V)
local rownms: rownames e(V)

matrix colnames V_spatial = `colnms'
matrix rownames V_spatial = `rownms'

// this sets the new estimates as the most recent model

ereturn post beta V_spatial, esample(`touse')

// then filling back in all the parameters for postestimation

ereturn local cmd = "ols_spatial"

ereturn scalar N = n_obs

ereturn scalar r2 = r2_old
ereturn scalar df_m = df_m_old
ereturn scalar df_r = df_r_old
ereturn scalar rmse = rmse_old
ereturn scalar mss = mss_old
ereturn scalar rss = rss_old
ereturn scalar r2_a = r2_a_old

ereturn local title = "Linear regression"
ereturn local depvar = "`Y'"
ereturn local predict = "regres_p"
ereturn local model = "ols"
ereturn local estat_cmd = "regress_estat"

//storing these estimates for comparison to OLS and the HAC estimates

estimates store spatial



/*--------FOURTH, CORRECT VCE FOR SERIAL CORR-------*/

mata{

panelUnique = uniqrows(panel)
Npanel = rows(panelUnique) 		// # of panels

for (pi = 1; pi <= Npanel; pi++){
	
	// 1 if in panel pi, 0 otherwise:

	rows_pi = panel:==panelUnique[pi,1] 	

	//get subsets of variables for panel pi (without changing original matrix)
	
	Y1 = select(Y, rows_pi)
	X1 = select(X, rows_pi)
	Z1 = select(Z, rows_pi)
	time1 = select(time, rows_pi)

	e1 = Y1 - X1*b'


	n1 = length(Y1) 			// # obs for panel pi
	
	//loop over all observations in panel pi

	for (t = 1; t <=n1; t++){

   		// ----------------------------------------------------------------
        // step a: get non-parametric weight
        
        // this is the weight for Newey-West with a Bartlett kernal
        
        //weight = (1:-abs(time1[t,1] :- time1))/(lag_cutoff+1) // correction: need to removing parentheses to compute inter-temporal  (6/10/18)
        weight = 1:-abs(time1[t,1] :- time1)/(lag_cutoff+1)

        
        // obs var far enough apart in time are prescribed to have no estimated
        // correlation (Greene recomments lag_cutoff >= T^0.25 {pg 546})
        
        window_t = (abs(time1[t,1]:- time1) :<= lag_cutoff) :* weight
        
        //this is required so diagonal terms in var-covar matrix are not
        //double counted (since they were counted once above for the spatial
        //correlation estimates:
        
        window_t = window_t :* (time1[t,1] :!= time1)                   
        
  		// ----------------------------------------------------------------
        // step b: construct Z'e'eZ for given observation
         
       	ZeeZh = ((Z1[t,.]'*J(1,n1,1)*e1[t,1]):*(J(k,1,1)*e1':*window_t'))*Z1
        

		//add each new k x k matrix onto the existing matrix (will be symmetric)
		        
        ZeeZ = ZeeZ + ZeeZh

	} // t
} // pi



// -----------------------------------------------------------------
// generate the VCE for x-sectional spatial correlation and serial correlation

ZeeZ_spatial_HAC = ZeeZ / n


V = invZX * ZeeZ_spatial_HAC * invZX' / n

// Ensures that the matrix is symmetric 
// in theory, it should be already, but it may not be due to rounding errors for large datasets

V = (V+V')/2 

st_matrix("V_spatial_HAC", V)

} // mata

//------------------------------------------------------------------

matrix beta = e(b)

// the row and column names of the new VCE must match the vector b
local colnms: colnames e(V)
local rownms: rownames e(V)

matrix colnames V_spatial_HAC = `colnms'
matrix rownames V_spatial_HAC = `rownms'

// this sets the new estimates as the most recent model

//marksample touse				// indicator for inclusion in the sample

ereturn post beta V_spatial_HAC, esample(touse)

// then filling back in all the parameters for postestimation

ereturn local cmd = "ols_spatial_HAC"

ereturn scalar N = n_obs
ereturn scalar r2 = r2_old
ereturn scalar df_m = df_m_old
ereturn scalar df_r = df_r_old
ereturn scalar rmse = rmse_old
ereturn scalar mss = mss_old
ereturn scalar rss = rss_old
ereturn scalar r2_a = r2_a_old

ereturn local title = "Linear regression"
ereturn local depvar = "`Y'"
ereturn local predict = "regres_p"
ereturn local model = "ols"
ereturn local estat_cmd = "regress_estat"

//storing these estimates for comparison to OLS and the HAC estimates

estimates store spatHAC

//-----------------------------------------------------------------
//displaying results

disp as txt " "
if `ivflag' == 1 {
disp as txt "2SLS REGRESSION"
}
else if `ivflag' == 0 {
	disp as txt "OLS REGRESSION"
}
disp as txt " "
disp as txt "SE CORRECTED FOR CROSS-SECTIONAL SPATIAL DEPENDANCE"
disp as txt "             AND PANEL-SPECIFIC SERIAL CORRELATION"
disp as txt " "
disp as txt "DEPENDANT VARIABLE: `Y'"
disp as txt "INDEPENDANT VARIABLES: `X'"
disp as txt " "
if `ivflag' == 1 {
	disp as txt "INSTRUMENTED VARIABLES: `endog'"
	disp as txt "INSTRUMENTAL VARIABLES: `exog'"
	disp as txt " "
}
disp as txt "SPATIAL CORRELATION KERNAL CUTOFF: `distcutoff' KM"

if "`bartlett'" == "bartlett" {
	disp as txt "(NOTE: LINEAR BARTLETT WINDOW USED FOR SPATIAL KERNAL)"
}
	
disp as txt "SERIAL CORRELATION KERNAL CUTOFF: `lagcutoff' PERIODS"

ereturn display // standard Stata regression table format

// displaying different SE if option selected

if "`display'" == "display"{
	disp as txt " "
	disp as txt "STANDARD ERRORS UNDER OLS/2SLS, WITH SPATIAL CORRECTION AND WITH SPATIAL AND SERIAL CORRECTION:"
if `ivflag' == 0 {
	estimates table OLS spatial spatHAC, b(%7.3f) se(%7.3f) t(%7.3f) stats(N r2) 	
}
else if `ivflag' == 1 {
	estimates table twoSLS spatial spatHAC, b(%7.3f) se(%7.3f) t(%7.3f) stats(N r2) 		
}
}

if "`star'" == "star"{
	disp as txt " "
	disp as txt "STANDARD ERRORS UNDER OLS/2SLS, WITH SPATIAL CORRECTION AND WITH SPATIAL AND SERIAL CORRECTION:"
if `ivflag' == 0 {
	estimates table OLS spatial spatHAC, b(%7.3f) star(0.10 0.05 0.01)
}
else if `ivflag' == 1 {
	estimates table twoSLS spatial spatHAC, b(%7.3f) star(0.10 0.05 0.01)
}
}

//------------------------------------------------------------------
// cleaning up Mata environment

capture mata mata drop V invZX  ZeeZ ZeeZh ZeeZ_spatial_HAC window_t window_i weight t i ti pi Z1 X1 Y1 e1 time1 n1 lat lon lat1 lon1 lat_scale lon_scale rows_ti rows_pi timeUnique panelUnique Ntime Npanel Z Z_var X X_var ZeeZ_spatial Y Y_var b dist_cutoff dist_var distance_i k lag_cutoff lag_var lat_var lon_var n panel panel_var time time_var weight_i


if "`bartlett'" == "bartlett" {
	capture mata mata drop weight_i			
}

end



