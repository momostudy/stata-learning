program clus_nway, eclass
 //
 // Paul Wolfson and Adam M. Kleinbaum
 // Tuck School at Dartmouth College
 // Version 1.0: November 1, 2012
 // Version 2.0: February 28, 2014
 // Version 3.0: October 10, 2017
 //
 // Freely available at http://bit.ly/clus_nway
 // Questions? Contact Adam.M.Kleinbaum@tuck.dartmouth.edu
 //
 //
 // ///////////////////////////////////////////////////////////////////////////////////////////////////
 // ///////////////                      Statement on Copyrights                          ///////////////
 // ///////////////////////////////////////////////////////////////////////////////////////////////////
 //
 // Copyright 2017 Paul Wolfson and Adam M. Kleinbaum
 // This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License (version 3)
 // as published by the Free Software Foundation.
 // 
 // This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 // MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 // 
 // A copy of the GNU General Public License is available at http://www.gnu.org/licenses/.
 // 
 // 
 // ///////////////////////////////////////////////////////////////////////////////////////////////////
 // ///////////////                          Citation Information                              ///////////////
 // ///////////////////////////////////////////////////////////////////////////////////////////////////
 //
 // When using this .ado file, please cite both of the following papers:
 //
 // Kleinbaum, Adam M., Toby E. Stuart, and Michael L. Tushman (2013). "Discretion within Constraint: Homophily and Structure 
 // in a Formal Organization." Organization Science 24(5): 1316-1336. 
 // Available at: http://faculty.tuck.dartmouth.edu/images/uploads/faculty/adam-kleinbaum/discretion_within_constraint.pdf
 //
 // Cameron, A. Colin, Jonah B. Gelbach, and Douglas L. Miller. 2011. "Robust Inference with Multi-way Clustering." 
 // Journal of Business and Economic Statistics 29(2): 238-49.
 // 
 // 
 // ///////////////////////////////////////////////////////////////////////////////////////////////////
 // ///////////////                        Description of Program                            ///////////////
 // ///////////////////////////////////////////////////////////////////////////////////////////////////
 //
 // Perform n-way clustering for variance-covariance matrix estimation for any estimation command for which Stata allows 1 way clustering.
 // Based on Cameron, Gelbach and Miller (JBES 4/2011), esp. equation 2.13
 //
 // The argument is the estimation command as it would normally be issued, except that instead of including only 1 clustering
 // variable, list them all.  Thus (e.g.):
 //
 // clus_nway regress y x if z, vce(cluster clus_1 clus_2)
 //
 // Note that clus_1 ... clus_n must be integer variables.  If your cluster variables are strings, the following lines will 
 // create integer versions, which can be entered into clus_nway:
 // 		. encode clus_1_string, generate(clus_1_int)
 // 		. encode clus_n_string, generate(clus_n_int)
 // 		. clus_nway regress y x if z, vce(cluster clus_1_int clus_n_int)
 //
 // Instead of running the regression once and using the residuals to calculate the appropriately clustered covariance matrix, this 
 // program uses combinatorix to determine all the ways in which the observations should be clustered, runs the regression
 // command for each, and combines the resulting cluster-based covariance matrices as appropriate. The underlying assumption
 // is that execution time is cheap.
 //
 // Code for dealing with covariance matrices that are not positive-semi-definite cribbed from cgmreg.ado by
 // Cameron, Gelbach and Miller (see below)
 //
 // The last regression run is the one-way clustering for the variable with the fewest number of clusters, because
 // (Miller to Wolfson in email dated 2011-06-02):
 //
 //    Since the asymptotics of this are in min(G,H)  [with G being # of clusters in one dimension, and H being
 //     # in the other], I think that I would use a T-distribution with min(G,H) - 1 
 //
 // After calculating and posting the correct cov matrix, the cmd 
 //    ereturn display
 // displays the results, and uses the dfs from the last run regression.
 //
 //
 ///////////////////////////////////////////////////////////////////////////////
 // 9 October 2017                                                            //
 //  Change from posting the variance-covariance matrix by                    //
 //                                                                           //
 //     ereturn post `b' `VCov'                                               //
 //                                                                           //
 //  to posting it by                                                         //
 //                                                                           //
 //     ereturn repost b=`b' V=`VCov'                                         //
 //                                                                           //
 //  The explanation for this requires details about the workings of the      //
 //  ereturn & test commands in Stata.                                        //
 //                                                                           //
 //  1) The test command calculates a Wald statistic using the VCOV matrix.   //
 //     Running the test command following clus_nway therefore relies on the  //
 //     clustered VCOV matrix (all well and good). Consider the following     //
 //     passage from the documentation (Methods & formulas) for the test      //
 //     command.                                                              //
 //                                                                           //
 //      test and testparm perform Wald tests. Let the estimated coefficient  //
 //      vector be b and the estimated variance–covariance matrix be V.       //
 //      Let Rb = r denote the set of q linear hypotheses to be tested        //
 //      jointly.                                                             //
 //        The Wald test statistic is (Judge et al. 1985, 20–28)              //
 //                             W = (Rb - r)'[(RVR')^-1](Rb - r)              //
 //        If the estimation command reports its significance levels using Z  //
 //      statistics, a chi-squared distribution with q degrees of freedom,    //
 //                             W ~ chi^2(q)                                  //
 //      is used for computation of the significance level of the hypothesis  //
 //      test.                                                                //
 //        If the estimation command reports its significance levels using t  //
 //      statistics with d degrees of freedom, an F statistic,                //
 //                             F = W *1/q                                    //
 //      is computed, and an F distribution with q numerator degrees of       //
 //      freedom and d denominator degrees of freedom computes the            //
 //      significance level of the hypothesis test.                           //
 //                                                                           //
 //  2) ereturn post allows for changing the coefficient vector and the       //
 //     VCOV matrix, but clears all existing e-class results.  (This last is  //
 //     the reason that when ereturn post was used, clus_nway posted not only //
 //     the clustered VCOV matrix, but the coefficient matrix as well.)       //
 //     Among the e-class results that are cleared is the # df.  As a result, //
 //     following ereturn post, the table of regression results labels the    //
 //     the coefficient SEs as Z statistics and uses the normal distribution  //
 //     to calculate their p-values.  The test command likewise uses the      //
 //     normal distribution for the p-values and displays the joint test      //
 //     statistic as a chi-squared statistic.                                 //
 //                                                                           //
 //  3) ereturn repost does not clear existing e-class results, but can be    //
 //     called only from within an estimation-class program, i.e. one defined //
 //     using the eclass option.                                              //
 //                                                                           //
 //  The p-values calculated using the t-distribution are typically larger    //
 //  than those based on the normal distribution.  The program has been       //
 //  changed to use repost rather than post so that p-values are based on     //
 //  the t (& F) distributions rather than the normal disribution.            //
 //  NB: probably no need to repost b, but at this point it requires fewer    //
 //      changes to the code to repost it along with VCOV.                    //
 ///////////////////////////////////////////////////////////////////////////////
 
 version 11
 * If the version statment is commented out, search below and uncomment the statements that include the word "version"
 
  *disp "0 `0'"

 * preliminary error checking
 local colon_found=0
 local comma_found=0
 local vce_found=0
 local cluster_found=0
 local rparen_found_m1=0
 local i=1
 *local version=c(version)
 while "``i''" != "" {
  *if `version' < 13 {
   local ilen: length local `i'
   if `ilen' > 244 {
    disp _n as error "**********************************************************************"
    disp as error "*                                                                    *"
    disp as error "* Tokens cannot be longer than 244 characters                        *"
    disp as error "* Tokens are strings of contiguous non-blank characters              *"
    disp as error "* The length of token `i' is `ilen'"
    disp as error "* Token # `i' is: " _n _n "``i''"
    disp as error "*                                                                    *"
    disp as error "* Figure out some way to insert blanks in the middle, so that it is  *"
    disp as error "* more than 1 token.                                                 *"
    disp as error "*                                                                    *"
    disp as error "**********************************************************************"
    exit
    }
  * } // if `version' < 13 {
  
  if `colon_found'==0 {
   if strpos("``i''","by")>0 {
    disp as error "clus_nway does not work when the 'by' prefix is used on the estimation command"
    exit
    }
   if strpos("``i''",":")>0 {
    local colon_found=`i'
    }
   }

  if `comma_found'==0 {
   if strpos("``i''",",")>0 {
    local comma_found=`i'
    }
   }
   
  * The relogit package is old and uses a different syntax for (1-way) clustering than standard stata syntax:
  *  standard - vce(cluster variable)
  *  relogit  - cluster(variable)
  if `vce_found'==0 {
   if strpos("``i''","vce")>0 {
    local vce_found=`i'
    }
   }
  if `cluster_found'==0 {
   if strpos("``i''","cluster")>0 {
    local cluster_found=`i'
    }
   }
  else {
   if `rparen_found_m1'==0 {
    if strpos("``i''",")")>0 {
     local rparen_found_m1=`i'-1
     }
	}
   }
  local i=1+`i'
  }

 if `comma_found' == 0 {
  display as error "No options specified"
  exit
  }
 if (`vce_found' == 0 & `cluster_found'==0) | (`cluster_found' < `vce_found') {
  display as error "No clustering specified"
  exit
  }

 // Reconstruct the command, the list of clustering variables, everything to the left of the list
 // including the "vce(cluster" term (or "cluster(" terms), and everything to the right of that list, including
 // the right parenthesis that terminates the list.  Call these three macros
 // command_1     (everything to the left), 
 // cluster_vars  the list of clustering variables, and
 // command_2     (everything to the right)
 
 local cluster_found_m1=`cluster_found'-1
 forval i=1/`cluster_found_m1' {
  local command_1 `command_1' ``i''
  }

 local next_arg=1+`cluster_found'
 local lparen_pos=strpos("``cluster_found''","(")
 local cluster_pos=strpos("``cluster_found''","cluster")
 if `lparen_pos'==0 {
  local command_1 `command_1' ``cluster_found''
  }
 else {
  local end_command_1=max(`lparen_pos',6+`cluster_pos')
  local temp=substr("``cluster_found''",1,`end_command_1')
  local command_1 `command_1' `temp'
  local cluster_vars=substr("``cluster_found''",1+`end_command_1',.)
  }

 if `next_arg' <= `rparen_found_m1' {
  forval i=`next_arg'/`rparen_found_m1' {
   local cluster_vars `cluster_vars' ``i''
   } 
  }
 if strpos("`cluster_vars'","(")==1 {
  local command_1 `command_1' (
  local cluster_vars=substr("`cluster_vars'",2,.)
  }
   
 local rparen_found=`rparen_found_m1'+1
 local rparen_pos=strpos("``rparen_found''",")")-1
 if `rparen_pos'>0 {
  local last_clustervar=substr("``rparen_found''",1,`rparen_pos')
  local cluster_vars `cluster_vars' `last_clustervar'
  local command_2=substr("``rparen_found''",`rparen_pos'+1,.)
  }
 else {
  local command_2 ``rparen_found''
  }

 local i=1+`rparen_found'
 while "``i''" != "" {
  local command_2 `command_2' ``i''
  local i=1+`i'
  }

  /*
    disp _n "command_1 = //`command_1'//" _n
    disp _n "command_2 = //`command_2'//" _n
    disp _n "cluster_vars =//`cluster_vars'//" _n
    */
	
 local ncluster_vars: word count `cluster_vars'
 
 // Determine the number of clusters in each cluster variable in the estimation sample
 // and stick it at the end.  Using tab for each cluster variable, and storing r(r) would 
 // be the obvious way to do this. Except, stata limits the number of categories for tab (2^16).
 // So for each cluster variable:
 //  1) create a 2 column matrix in mata, of the cluster variable and the estimation sample
 //  2) sort it by the first column, the cluster id
 //  3) count the number of clusters in the estimation sample, and store
 
 tempname fewest_clusters
 mat `fewest_clusters'=[.,_N]
 tempname numbclust
 tempname nrx
 
 mat `numbclust'=J(`ncluster_vars',1,0)
 forval i1=1/`ncluster_vars' {
  local cluster_v`i1' : word `i1' of `cluster_vars'
  if `i1'==1 {                                              // Determine the estimation sample
   tempname est_sample
   qui `command_1' `cluster_v1' `command_2'
   qui gen `est_sample'=e(sample)
   }
  mata: st_matrix("`nrx'",sum(uniqrows(st_data(.,("`cluster_v`i1''","`est_sample'")))[.,2]))
  local nr=`nrx'[1,1]
  mat `numbclust'[`i1',1]=`nr'
  if `nr' <= `fewest_clusters'[1,2] mat `fewest_clusters'=[`i1', `nr']
 //       <= so least rearranging
  }

 local smallest=`fewest_clusters'[1,1]
 if `smallest' < `ncluster_vars' {
  local cluster_vars : subinstr local cluster_vars "`cluster_v`smallest''" "", word
  local cluster_vars `cluster_vars' `cluster_v`smallest''
  mat `fewest_clusters'[1,1]=`ncluster_vars'
 
  local sm2=`smallest'+1
  if `smallest' > 1 {
   local sm1=`smallest'-1
   mat `numbclust' = `numbclust'[1..`sm1',1...] \ `numbclust'[`sm2'..`ncluster_vars',1...] \ `numbclust'[`smallest',1...]
   }
  else {
   mat `numbclust' = `numbclust'[`sm2'..`ncluster_vars',1...] \ `numbclust'[`smallest',1...]
   }

  forval i1=`smallest'/`ncluster_vars' {
   local cluster_v`i1' : word `i1' of `cluster_vars'
   }
  } 
  
 tempname VCov
 mat `VCov'=[.]
 tempname rho_VCov
 local rho_VCov = 1
 
 tempname nclusters
 tempname combinations
 tempname n_combinations
 tempname VCov0
 local n_comb_tot=0 	
 forval i1=`ncluster_vars'(-1)1 {                           // i1: # cluster variables in intersection
  combinatorix `ncluster_vars' `i1'
  mat `combinations'=r(combinations)
  sca `n_combinations'=rowsof(`combinations')
  local ncomb=`n_combinations'
  local n_comb_tot=`n_comb_tot'+`ncomb'
  tempname VCov`i1'
  mat `VCov`i1''=[.]
  local rho_VCov`i1'=1
  forval i2=1/`ncomb' {                                   // i2: # set of cluster variables in this intersection
   // Create single value clusters from `i1'-way clusters
   local c1=`combinations'[`i2',1]
   qui sum `cluster_v`c1'' if `est_sample'
   local cl_min=r(min)
   cap drop `nclusters'
   qui gen `nclusters' = `cluster_v`c1''-`cl_min'  if `est_sample'
   forval i3=2/`i1' {
    local c2=`combinations'[`i2',`i3']
    qui sum `cluster_v`c2'' if `est_sample'
    local cl_min=r(min)
	local cl_max=r(max)
    qui replace `nclusters' = `nclusters'*(1+`cl_max'-`cl_min') + `cluster_v`c2''-`cl_min'  if `est_sample'
    }                                                     // forval i3=2/`i1'
   qui `command_1' `nclusters' `command_2'
   
   if `rho_VCov`i1'' == 1 {
    mat `VCov`i1'' = e(V)
	local rho_VCov`i1' = 0
	}
   else {
    mat `VCov0' = e(V)
	mat `VCov`i1'' = `VCov`i1'' + `VCov0'
    }
   }                                                      // forval i2=1/`ncomb'

  mat `VCov`i1'' = (-1) ^ (`i1'-1) * `VCov`i1''
  if `rho_VCov' == 1 {
   mat `VCov' = `VCov`i1''
   local rho_VCov = 0
   }
  else {
   mat `VCov' = `VCov' + `VCov`i1''
   }
  }                                                       // forval i1=`ncluster_vars'(-1)1
 tempname Nobs
 sca `Nobs'=e(N)
 
 // Code from Cameron, Gelbach & Miller's program cgmreg.ado for modifying variance matrix if not positive semi-definite
 // Used with permission of Greg Miller
 // I have deleted some lines having to do with labelling and modified some others for the same reason
 
 	*checking/fixing non-psd variance estimate
	tempname eigenvalues eigenvectors
	*use mata to get eigenvalues after ensuring that variance matrix is (numerically) symmetric
	mata { 
		B = st_matrix("`VCov'") 
		A = makesymmetric(B) 
		symeigensystem(A, C=., lamda=.) 
  		st_matrix("`eigenvalues'", lamda) 
		st_matrix("`eigenvectors'", C)
	 }

	local rnames  : rownames `VCov'
	local roweq : roweq `VCov'
	local numcols = colsof(`VCov')
	local eigenfix "no"
	local warning_printed=0
	forvalues col=1/`numcols' { /* column number loop */
		if (`eigenvalues'[1,`col']<0) {
		 if "`eigenfix'"=="no" {
		  di
		  di " -> NOTE: Raw estimated variance matrix was non positive semi-definite."
		  di
		  local eigenfix "yes"
		  }
		 mat `eigenvalues'[1,`col']=0
		 }
	 } /* end column number loop */

	*now reconstruct variance matrix using spectral decomposition formula (e.g., Def A.16 in Greene, 6th)
	tempname raw_VCov
	mat `raw_VCov' = `VCov'	/* pre eigen-fix variance matrix */
	if "`eigenfix'" == "yes" {
	 mat `VCov' = `eigenvectors'*diag(`eigenvalues')*`eigenvectors''

     mat rownames `VCov' = `rnames'
	 mat colnames `VCov' = `rnames'
	 mat roweq `VCov' = `roweq'
	 mat coleq `VCov' = `roweq'
	 }

	/* end checking/fixing non-psd variance estimate */

 // End of code from Cameron, Gelbach & Miller's cgmreg.ado
 
 tempname b
 mat `b' = e(b)
 
 // To post the covariance matrix, it is also necessary to post the coefficients
 // They must have the same names (`rnames')
 // With poisson regression, there is a Freq: prefixed to them!  So, ...
 
 mat colnames `b' = `rnames'
 mat coleq `b' = `roweq'
 ereturn repost b=`b' V=`VCov'
 
 disp _n _n _n _n
 disp "                                                 Number of obs     =    " `Nobs' 
 disp "                                                 Num clusvars      =    " `ncluster_vars'
 disp "                                                 Num combinations  =    " `n_comb_tot' _n
 forval i1=1/`ncluster_vars' {
  local nc=`numbclust'[`i1',1]
  disp "                                                 G(`cluster_v`i1'') =     `nc'"
  }
 local depvar : word 2 of `command_1'
 disp "Dependent variable: `depvar'"
 ereturn display
 if `numbclust'[`ncluster_vars',1] < 42 {
  disp _n as error "      ****************************************************************************************"
     disp as error "     **                                                                                      **"
     disp as error "    *** Clustering in the dimension with the smallest number of clusters may be problematic. ***"
     disp as error "   ****                                                                                      ****"
     disp as error "  ***** Angrist and Pischke (2009, sec 8.2.3) are skeptical about the reliability            *****"
     disp as error " ****** of (1-way) clustered errors when the number of clusters is less than 42.             ******"
     disp as error "*******                                                                                      *******"
     disp as error "******* Bertrand, Duflo and Mullainathan (QJE 2004, Table VIII) present evidence             *******"
     disp as error " ****** that as few as 20 clusters may be sufficient.                                        ******"
     disp as error "  *****                                                                                      *****"
     disp as error "   **** Also see Hansen (2007, JEcts 140, pp. 670-604) and                                   ****"
     disp as error "    ***                 (2007, JEcts 141, pp. 597-620).                                      ***"
     disp as error "     **                                                                                      **"
     disp as error "      ****************************************************************************************" _n
      }
 end

 
 program combinatorix, rclass
 args n k
 // Return a matrix of all possibilities for n choose k
 // using the integers 1 through n 
 
 tempname combinations
 
 local n_choose_k = comb(`n', `k')
  
 mat `combinations' = J(`n_choose_k',`k',0)
 forval i=1/`k' {
  local c`i' = `i'
  }

 local cthis=`k'                      // current column
 forval row=1/`n_choose_k' {
  forval i=1/`k' {
   mat `combinations'[`row',`i']=`c`i''
   }
  if `row' >= `n_choose_k' continue, break
  local done2=0
  while `done2'==0 {
   local done1=0
   while `done1'==0 {
    if `c`cthis'' < `n' {            // if current column < `n'
     local ++c`cthis'                //  add 1 and continue
	 local done1=1
	 }
    else {
	 local clast=`k'                 // else add 1 to previous
     local cthis=`k'-1               //  column, and reset all
	 if `cthis'<=0 continue, break   // check not too far left, and continue
	 }
	}
   if `cthis' < `k' {
	local clast=`cthis'+1
    forval i=`clast'/`k' {
	 local j=`i'-1
	 local c`i' = `c`j''+1
	 }
	}
   if `c`k'' <= `n' local done2=1   // if last column <= `n', continue
   else {                           // else move 1 column left , check
	local --cthis                   // that it is not too far left, and
	if `cthis'<=0 continue, break   // continue
	}
   } 
  local cthis=`k'
  }
 return matrix combinations=`combinations'
 end 
