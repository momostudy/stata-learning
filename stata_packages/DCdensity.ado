//Notes:
//  This ado file was created by Brian Kovak, a Ph.D. student at the University
//  of Michigan, under the direction of Justin McCrary.  McCrary made some
//  cosmetic alterations to the code, added some further error traps, and
//  ran some simulations to ensure that
//  there was no glitch in implementation.  This file is not the basis for
//  the estimates in McCrary (2008), however.

//  The purpose of the file is to create a STATA command, -DCdensity-, which
//  will allow for ready estimation of a discontinuous density function, as
//  outlined in McCrary (2008), "Manipulation of the Running Variable in the
//  Regression Discontinuity Design: A Density Test", Journal of Econometrics.

//  The easiest way to use the file is to put it in your ado subdirectory.  If
//  you don't know where that is, try using -sysdir- at the Stata prompt.

//  A feature of the program is that it is much faster than older STATA routines
//  (e.g., -kdensity-).  The source of the speed improvements is the use of
//  MATA for both looping and for estimation of the regressions, and the lack of
//  use of -preserve-.

// An example program showing how to use -DCdensity- is given in the file
// DCdensity_example.do

// JRM, 9/2008

// Update: Fixed bug that occurs when issuing something like
// DCdensity Z if female==1, breakpoint(0) generate(Xj Yj r0 fhat se_fhat) graphname(DCdensity_example.eps)

// Update 11.17.2009: Fixed bugs in XX matrix (see comments) and in hright (both code typos)
                                                                     

capture program drop DCdensity
program DCdensity, rclass
{
  version 9.0
  set more off
  pause on
  syntax varname(numeric) [if/] [in/], breakpoint(real) GENerate(string) ///
    [ b(real 0) h(real 0) at(string) graphname(string) noGRaph]
  
  marksample touse
  
  //Advanced user switch
  //0 - supress auxiliary output  1 - display aux output
  local verbose 1 
 
  //Bookkeeping before calling MATA function
  //"running variable" in terminology of McCrary (2008)
  local R "`varlist'"

  tokenize `generate'
  local wc : word count `generate' 
  if (`wc'!=5) {
    //generate(Xj Yj r0 fhat se_fhat) is suggested
    di "Specify names for five variables in generate option"
    di "1. Name of variable in which to store cell midpoints of histogram"
    di "2. Name of variable in which to store cell heights of histogram"
    di "3. Name of variable in which to store evaluation sequence for local linear regression loop"
    di "4. Name of variable in which to store local linear density estimate"
    di "5. Name of variable in which to store standard error of local linear density estimate"
    error 198
  }
  else {
    local cellmpname = "`1'"
    local cellvalname = "`2'"
    local evalname = "`3'"
    local cellsmname = "`4'"
    local cellsmsename = "`5'"
    confirm new var `1'
    confirm new var `2'
    capture confirm new var `3'
    if (_rc!=0 & "`at'"!="`3'") error 198
    confirm new var `4'
    confirm new var `5'
  }

  //If the user does not specify the evaluation sequence, this it is taken to be the histogram midpoints
  if ("`at'" == "") {
    local at  = "`1'"
  }

  //Call MATA function
  mata: DCdensitysub("`R'", "`touse'", `breakpoint', `b', `h', `verbose', "`cellmpname'", "`cellvalname'", ///
                     "`evalname'", "`cellsmname'", "`cellsmsename'", "`at'")

  //Dump MATA return codes into STATA return codes 
  return scalar theta = r(theta)
  return scalar se = r(se)
  return scalar binsize = r(binsize)
  return scalar bandwidth = r(bandwidth)

  //if user wants the graph...
  if ("`graph'"!="nograph") { 
    tempvar hi
    quietly gen `hi' = `cellsmname' + 1.96*`cellsmsename'
    tempvar lo
    quietly gen `lo' = `cellsmname' - 1.96*`cellsmsename'
    gr twoway (scatter `cellvalname' `cellmpname', msymbol(circle_hollow) mcolor(gray))           ///
      (line `cellsmname' `evalname' if `evalname' < `breakpoint', lcolor(black) lwidth(medthick))   ///
        (line `cellsmname' `evalname' if `evalname' > `breakpoint', lcolor(black) lwidth(medthick))   ///
          (line `hi' `evalname' if `evalname' < `breakpoint', lcolor(black) lwidth(vthin))              ///
            (line `lo' `evalname' if `evalname' < `breakpoint', lcolor(black) lwidth(vthin))              ///
              (line `hi' `evalname' if `evalname' > `breakpoint', lcolor(black) lwidth(vthin))              ///
                (line `lo' `evalname' if `evalname' > `breakpoint', lcolor(black) lwidth(vthin)),             ///
                  xline(`breakpoint', lcolor(black)) legend(off)
    if ("`graphname'"!="") {
      di "Exporting graph as `graphname'"
      graph export `graphname', replace
    }
  }
}
end


mata:
mata set matastrict on

void DCdensitysub(string scalar runvar, string scalar tousevar, real scalar c, real scalar b, ///
                  real scalar h, real scalar verbose, string scalar cellmpname, string scalar cellvalname, ///
                  string scalar evalname, string scalar cellsmname, string scalar cellsmsename, ///
                  string scalar atname) {
  //   inputs: runvar - name of stata running variable ("R" in McCrary (2008))
  //             tousevar - name of variable indicating which obs to use
  //             c - point of potential discontinuity
  //             b - bin size entered by user (zero if default is to be used)
  //             h - bandwidth entered by user (zero if default is to be used)
  //             verbose - flag for extra messages printing to screen
  //             cellmpname - name of new variable that will hold the histogram cell midpoints
  //             cellvalname - name of new variable that will hold the histogram values
  //             evalname - name of new variable that will hold locations where the histogram smoothing was
  //                        evaluated
  //             cellsmname - name of new variable that will hold the smoothed histogram cell values
  //             cellsmsename - name of new variable that will hold standard errors for smoothed histogram cells
  //             atname - name of existing stata variable holding points at which to eval smoothed histogram

  //declarations for general use and histogram generation
  real colvector run						// stata running variable
  string scalar statacom					// string to hold stata commands
  real scalar errcode                                           // scalar to hold return code for stata commands
  real scalar rn, rsd, rmin, rmax, rp75, rp25, riqr     	// scalars for summary stats of running var
  real scalar l, r						// midpoint of lowest bin and highest bin in histogram
  real scalar lc, rc						// midpoint of bin just left of and just right of breakpoint
  real scalar j							// number of bins spanned by running var
  real colvector binnum						// each obs bin number
  real colvector cellval					// histogram cell values
  real scalar i							// counter
  real scalar cellnum						// cell value holder for histogram generation
  real colvector cellmp						// histogram cell midpoints

  //Set up histogram grid

  st_view(run, ., runvar, tousevar)     //view of running variable--only observations for which `touse'=1

  //Get summary stats on running variable
  statacom = "quietly summarize " + runvar + " if " + tousevar + ", det"
  errcode=_stata(statacom,1)
  if (errcode!=0) {
    "Unable to successfully execute the command "+statacom
    "Check whether you have given Stata enough memory"
  }
  rn = st_numscalar("r(N)")
  rsd = st_numscalar("r(sd)")
  rmin = st_numscalar("r(min)")
  rmax = st_numscalar("r(max)")
  rp75 = st_numscalar("r(p75)") 
  rp25 = st_numscalar("r(p25)")
  riqr = rp75 - rp25

  if ( (c<=rmin) | (c>=rmax) ) {
    printf("Breakpoint must lie strictly within range of running variable\n")
    _error(3498)
  }
  
  //set bin size to default in paper sec. III.B unless provided by the user
  if (b == 0) {
    b = 2*rsd*rn^(-1/2)
    if (verbose) printf("Using default bin size calculation, bin size = %f\n", b)
  }

  //bookkeeping
  l = floor((rmin-c)/b)*b+b/2+c  // midpoint of lowest bin in histogram
  r = floor((rmax-c)/b)*b+b/2+c  // midpoint of lowest bin in histogram
  lc = c-(b/2) // midpoint of bin just left of breakpoint
  rc = c+(b/2) // midpoint of bin just right of breakpoint
  j = floor((rmax-rmin)/b)+2

  //create bin numbers corresponding to run... See McCrary (2008, eq 2)
  binnum = round((((floor((run :- c):/b):*b:+b:/2:+c) :- l):/b) :+ 1)  // bin number for each obs

  //generate histogram 
  cellval = J(j,1,0)  // initialize cellval as j-vector of zeros
  for (i = 1; i <= rn; i++) {
    cellnum = binnum[i]
    cellval[cellnum] = cellval[cellnum] + 1
  }
  
  cellval = cellval :/ rn  // convert counts into fractions
  cellval = cellval :/ b  // normalize histogram to integrate to 1
  cellmp = range(1,j,1)  // initialize cellmp as vector of integers from 1 to j
  cellmp = floor(((l :+ (cellmp:-1):*b):-c):/b):*b:+b:/2:+c  // convert bin numbers into cell midpoints
  
  //place histogram info into stata data set
  real colvector stcellval					// stata view for cell value variable
  real colvector stcellmp					// stata view for cell midpoint variable

  (void) st_addvar("float", cellvalname)
  st_view(stcellval, ., cellvalname)
  (void) st_addvar("float", cellmpname)
  st_view(stcellmp, ., cellmpname)
  stcellval[|1\j|] = cellval
  stcellmp[|1\j|] = cellmp
  
  //Run 4th order global polynomial on histogram to get optimal bandwidth (if necessary)
  real matrix P							// projection matrix returned from orthpoly command
  real matrix betaorth4						// coeffs from regression of orthogonal powers of cellmp
  real matrix beta4						// coeffs from normal regression of powers of cellmp
  real scalar mse4						// mean squared error from polynomial regression
  real scalar hleft, hright					// bandwidth est from polynomial left of and right of breakpoint
  real scalar leftofc, rightofc	      			        // bin number just left of and just right of breakpoint
  real colvector cellmpleft, cellmpright			// cell midpoints left of and right of breakpoint
  real colvector fppleft, fppright				// fit second deriv of hist left of and right of breakpoint

  //only calculate optimal bandwidth if user hasn't provided one
  if (h == 0) {
    //separate cells left of and right of the cutoff
    leftofc =  round((((floor((lc - c)/b)*b+b/2+c) - l)/b) + 1) // bin number just left of breakpoint
    rightofc = round((((floor((rc - c)/b)*b+b/2+c) - l)/b) + 1) // bin number just right of breakpoint
    if (rightofc-leftofc != 1) {
      printf("Error occurred in optimal bandwidth calculation\n")
      _error(3498)
    }
    cellmpleft = cellmp[|1\leftofc|]
    cellmpright = cellmp[|rightofc\j|]

    //estimate 4th order polynomial left of the cutoff
    statacom = "orthpoly " + cellmpname + ", generate(" + cellmpname + "*) deg(4) poly(P)"
    errcode=_stata(statacom,1)
    if (errcode!=0) {
      "Unable to successfully execute the command "+statacom
      "Check whether you have given Stata enough memory"
    }
    P = st_matrix("P")
    statacom = "reg " + cellvalname + " " + cellmpname + "1-" + cellmpname + "4 if " + cellmpname + " < " + strofreal(c)
    errcode=_stata(statacom,1)
    if (errcode!=0) {
      "Unable to successfully execute the command "+statacom
      "Check whether you have given Stata enough memory"
    }
    mse4 = st_numscalar("e(rmse)")^2
    betaorth4 = st_matrix("e(b)")
    beta4 = betaorth4 * P
    fppleft = 2*beta4[2] :+ 6*beta4[3]:*cellmpleft + 12*beta4[4]:*cellmpleft:^2
    hleft = 3.348 * ( mse4*(c-l) / sum( fppleft:^2) )^(1/5)

    //estimate 4th order polynomial right of the cutoff
    P = st_matrix("P")
    statacom = "reg " + cellvalname + " " + cellmpname + "1-" + cellmpname + "4 if " + cellmpname + " > " + strofreal(c)
    errcode=_stata(statacom,1)
    if (errcode!=0) {
      "Unable to successfully execute the command "+statacom
      "Check whether you have given Stata enough memory"
    }
    mse4 = st_numscalar("e(rmse)")^2
    betaorth4 = st_matrix("e(b)")
    beta4 = betaorth4 * P
    fppright = 2*beta4[2] :+ 6*beta4[3]:*cellmpright + 12*beta4[4]:*cellmpright:^2
    hright = 3.348 * ( mse4*(r-c) / sum( fppright:^2) )^(1/5)
    statacom = "drop " + cellmpname + "1-" + cellmpname + "4"
    errcode=_stata(statacom,1)
    if (errcode!=0) {
      "Unable to successfully execute the command "+statacom
      "Check whether you have given Stata enough memory"
    }

    //set bandwidth to average of calculations from left and right
    h = 0.5*(hleft + hright)
    if (verbose) printf("Using default bandwidth calculation, bandwidth = %f\n", h)
  }

  //Add padding zeros to histogram (to assist smoothing)
  real scalar padzeros						// number of zeros to pad on each side of hist
  real scalar jp						// number of histogram bins including padded zeros

  padzeros = ceil(h/b)  // number of zeros to pad on each side of hist
  jp = j + 2*padzeros
  if (padzeros >= 1) {
    //add padding to histogram variables
    cellval = ( J(padzeros,1,0) \ cellval \ J(padzeros,1,0) )
    cellmp = ( range(l-padzeros*b,l-b,b) \ cellmp \ range(r+b,r+padzeros*b,b) )
    //dump padded histogram variables out to stata
    stcellval[|1\jp|] = cellval
    stcellmp[|1\jp|] = cellmp
  }

  //Generate point estimate of discontinuity
  real colvector dist						// distance from a given observation
  real colvector w						// triangle kernel weights
  real matrix XX, Xy						// regression matrcies for weighted regression
  real rowvector xmean, ymean					// means for demeaning regression vars
  real colvector beta						// regression estimates from weighted reg.
  real colvector ehat						// predicted errors from weighted reg.
  real scalar fhatr, fhatl					// local linear reg. estimates at discontinuity
                                                                //   estimated from right and left, respectively
  real scalar thetahat						// discontinuity estimate
  real scalar sethetahat					// standard error of discontinuity estimate
  
  //Estimate left of discontinuity
  dist = cellmp :- c  // distance from potential discontinuity
  w = rowmax( (J(jp,1,0), (1:-abs(dist:/h))) ):*(cellmp:<c)  // triangle kernel weights for left
  w = (w:/sum(w)) :* jp  // normalize weights to sum to number of cells (as does stata aweights)
  xmean = mean(dist, w)
  ymean = mean(cellval, w)
  XX = quadcrossdev(dist,xmean,w,dist,xmean)    //fixed error on 11.17.2009
  Xy = quadcrossdev(dist,xmean,w,cellval,ymean)
  beta = invsym(XX)*Xy
  beta = beta \ ymean-xmean*beta
  fhatl = beta[2,1]
  
  //Estimate right of discontinuity
  w = rowmax( (J(jp,1,0), (1:-abs(dist:/h))) ):*(cellmp:>=c)  // triangle kernel weights for right
  w = (w:/sum(w)) :* jp  // normalize weights to sum to number of cells (as does stata aweights)
  xmean = mean(dist, w)
  ymean = mean(cellval, w)
  XX = quadcrossdev(dist,xmean,w,dist,xmean)   //fixed error on 11.17.2009
  Xy = quadcrossdev(dist,xmean,w,cellval,ymean)
  beta = invsym(XX)*Xy
  beta = beta \ ymean-xmean*beta
  fhatr = beta[2,1]
  
  //Calculate and display discontinuity estimate
  thetahat = ln(fhatr) - ln(fhatl)
  sethetahat = sqrt( (1/(rn*h)) * (24/5) * ((1/fhatr) + (1/fhatl)) )
  printf("\nDiscontinuity estimate (log difference in height): %f\n", thetahat)
  printf("                                                   (%f)\n", sethetahat)

  loopover=1 //This is an advanced user switch to get rid of LLR smoothing
  //Can be used to speed up simulation runs--the switch avoids smoothing at
  //eval points you aren't studying
  
  //Perform local linear regression (LLR) smoothing
  if (loopover==1) {
    real scalar cellsm						// smoothed histogram cell values
    real colvector stcellsm					// stata view for smoothed values
    real colvector atstata					// stata view for at variable (evaluation points)
    real colvector at						// points at which to evaluate LLR smoothing
    real scalar evalpts						// number of evaluation points
    real colvector steval						// stata view for LLR smothing eval points

    // if evaluating at cell midpoints
    if (atname == cellmpname) {  
      at = cellmp[|padzeros+1\padzeros+j|]
      evalpts = j
    }
    else {
      st_view(atstata, ., atname)
      evalpts = nonmissing(atstata)
      at = atstata[|1\evalpts|]
    }
    
    if (verbose) printf("Performing LLR smoothing.\n")
    if (verbose) printf("%f iterations will be performed \n",j)
    
    cellsm = J(evalpts,1,0)  // initialize smoothed histogram cell values to zero
    // loop over all evaluation points
    for (i = 1; i <= evalpts; i++) {
      dist = cellmp :- at[i]
      //set weights relative to current bin - note comma below is row join operator, not two separate args
      w = rowmax( (J(jp,1,0), ///
        (1:-abs(dist:/h))):*((cellmp:>=c)*(at[i]>=c):+(cellmp:<c):*(at[i]<c)) )
      //manually obtain weighted regression coefficients
      w = (w:/sum(w)) :* jp  // normalize weights to sum to N (as does stata aweights)
      xmean = mean(dist, w)
      ymean = mean(cellval, w)
      XX = quadcrossdev(dist,xmean,w,dist,xmean)  //fixed error on 11.17.2009 
      Xy = quadcrossdev(dist,xmean,w,cellval,ymean)
      beta = invsym(XX)*Xy
      beta = beta \ ymean-xmean*beta
      cellsm[i] = beta[2,1]
      //Show dots
      if (verbose) {
        if (mod(i,10) == 0) {
          printf(".")
          displayflush()
          if (mod(i,500) == 0) {
            printf(" %f LLR iterations\n",i)
            displayflush()
          }
        }
      }
    }
    printf("\n")
  
    //set up stata variable to hold evaluation points for smoothed values
    (void) st_addvar("float", evalname)
    st_view(steval, ., evalname)
    steval[|1\evalpts|] = at

    //set up stata variable to hold smoothed values
    (void) st_addvar("float", cellsmname)
    st_view(stcellsm, ., cellsmname)
    stcellsm[|1\evalpts|] = cellsm
    
    //Calculate standard errors for LLR smoothed values
    real scalar m					// amount of kernel being truncated by breakpoint
    real colvector cellsmse				// standard errors of smoothed histogram
    real colvector stcellsmse				// stata view for cell midpoint variable
    cellsmse = J(evalpts,1,0)  // initialize standard errors to zero
    for (i = 1; i <= evalpts; i++) {
      if (at[i] > c) {
        m = max((-1, (c-at[i])/h))
        cellsmse[i] = ((12*cellsm[i])/(5*rn*h))* ///
          (2-3*m^11-24*m^10-83*m^9-72*m^8+42*m^7+18*m^6-18*m^5+18*m^4-3*m^3+18*m^2-15*m)/ ///
            (1+m^6+6*m^5-3*m^4-4*m^3+9*m^2-6*m)^2
        cellsmse[i] = sqrt(cellsmse[i])
      }
      if (at[i] < c) {
        m = min(((c-at[i])/h, 1))
        cellsmse[i] = ((12*cellsm[i])/(5*rn*h))* ///
          (2+3*m^11-24*m^10+83*m^9-72*m^8-42*m^7+18*m^6+18*m^5+18*m^4-3*m^3+18*m^2+15*m)/ ///
            (1+m^6-6*m^5-3*m^4+4*m^3+9*m^2+6*m)^2
        cellsmse[i] = sqrt(cellsmse[i])
      }
    }
    //set up stata variable to hold standard errors for smoothed values
    (void) st_addvar("float", cellsmsename)
    st_view(stcellsmse, ., cellsmsename)
    stcellsmse[|1\evalpts|] = cellsmse
  }
  //End of loop over evaluation points
  
  //Fill in STATA return codes
  st_rclear()
  st_numscalar("r(theta)", thetahat)
  st_numscalar("r(se)", sethetahat)
  st_numscalar("r(binsize)", b)
  st_numscalar("r(bandwidth)", h)
}
end

