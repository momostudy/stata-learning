**  pvar2.ado - package for estimating VAR  (vector auto-regressions)
**
** pvar created by Inessa Love (Chevtchinskaia), March 2000, contact: ilove@worldbank.org

**************************** DECKER BUILD AUGUST 1, 2012 (afternoon)*****************************

** modified by Ryan Decker, with the following new features:
** 1) Users of Stata 9 or newer face no limit on the number of variables they can use (requires mata capability).
** Users of older versions of Stata can still use the program with six or fewer variables, but graphs won't work.
** 2) Users can now specify intervals at which they want variance decomposition output.
** 3) Enhanced numerical precision which avoids previous problems with some datasets.
** 4) Users can control both horizon and displayed interval for impulse response functions.
** 5) Users can obtain a dataset with reduced-form residuals
** 

**
** THIS IS SET UP TO DO PANEL DATA VAR (see notes below) 
**
** use of this package requires program sgmm2.ado (enclosed with the package)
** or, you can use your own system estimation program , but the estimates 
** must be in the same format as after my sgmm2.ado  
** 
** SYNTAX : 
** 
** pvar2 varlist [if exp], [lag(p) options]
** 
** where: varlist  is the list with variable names in desired order (order is important!)
**        p is optional number of lags in VAR, must be integer >0 (default=1) 
**        if is optional subsample indicator (using standard Stata's syntax)
**
** options are (must be low case):
**
** gmm  -  will estimate coefficients by gmm (this will call a separate program sgmm2.ado)
**        required option if new model is estimated (even if only the order changed!), 
**        otherwise the latest estimates are taken from the memory (left after previous run of 
**        the program);  gmm must be the first parameter for a new model; 
**
** impulse [max IRF] [IRF x-axis intervals] - will generate numerical impulse-responses without 
**			errors; first optional parameter after impulse is desired maximum IRF horizon,
**			default 6; second optional parameter after impulse is interval of IRF x-axis labels,
**			default 1.
**   list_imp - will list a table with impulse-responses (use after impulse)
**   gr_imp -  will graph impulses (witout errors ); if using monte for standard errors - no 
**           need to graph impulses separately
**
** monte [repetitions] [max IRF] [IRF x-axis intervals]- will generate errors for 
**		   impulse responses using monte-carlo simulation;
**         first optional parameter after monte is desired number of repetitions, default 200;
**		   second optional parameter after monte is desired maximum IRF horizon, default 6;
**		   third optional parameter after monte is interval of IRF x-axis labels, default 1;
**		   to specify third optional parameter, user must specificy second and first parameters
**		   (even if using defaults); to specify second optional parameter, user must specify first
**		   parameter (even if using defaults);
**         note that monte will call impulse - so no need to specify it separately;
**         monte will graph impulses with the bands automatically; 
**   list_mon - will list tables with impulses and error bands (use after monte)
**
** decomp [max horizon] [interval]- must appear after impulse or monte in option list. Will print 
**			out variance-decompositions; the first optional parameter is the max number of periods,
**			default is 20. The second optional parameter is the interval at which variance decompositions 
**			will be displayed, default is 10; for example, the user may want decompositions every 5 
**			periods up to 20. Do not use double quotes to specify these options (as was the case in 
**			older versions of the program).
**			For example, if the user wants decompositions every 5 periods up to 15, type decomp 15 5.
**			Note: If the user wants to specify intervals, the maximum period must also be specified
**			(even if using the default of 20).
**
** getresid - will save residuals (by equation and panel/time variables) in working directory with
**			filename pvar2_resid.dta.
** 
** for example, the common line to call the program would look like :
**
** pvar2 IK SK , lag(3) gmm impulse monte 500 decomp
**
** here number 500 (repetitions for monte-carlo) could be ommited (or changed)
** if errors on impulses are not needed, change monte for gr_imp (to graph without errors)
**
** Notes : 
**
** 1) this will do panel data VAR! That is, it assumes that fixed effects are removed
** using helmert transformation and transformed variables already exist in the dataset with 
** names h_y1, h_y2 ...( where y1 and y2 - are original names of the variables);
** it is advised that original variables are timedemeaned before helmert (for panel only);
** note that names in the startup line are original names, (i.e. if IK is original - variable 
** and h_IK is helmert transformed use IK and not h_IK in the startup line ! ;
** helmert transformation program is included with the package (or use your own) ;
** estimation is by gmm with untransformed variables used as instruments for helmert-
** transformed
** 2) to use different transformation (for ex. first difference) - the easiest way is to fool 
** the program and store transformed variables with names h_y1 h_y2 ...
** 3)  Alternatively, to use this program without fixed effects -  create a copy of original 
** variables  with names h_y1 h_y2... (the program will use original variables as both 
** regressors and instruments i.e. use gmm program to perform system OLS)
** 4) no constant is included at this time! (since var's are demeaned and helmert)
** 5) to run any of enclosed programs outside of pvar2.ado - need to create separate ado 
** files -i.e. copy program impulse into impulse.ado and so on
** 6) formulas are from Hamilton 1994 ch.11
** 7) Users of Stata 8 and older are limited to 6 variables. Users with newer versions face no limit.
** 8) before you can run these you must do the command tsset to tell Stata what is your panel data structure,
**   for example if your cross-section variable is named id and yur itme variable is named year 
**   do the command: tsset id year
**   also note that if you are using my program helm.ado your i and t variables must be named id and year
**
** The programs work to the best of my knowledge and ability, but please  - Use at your own risk ! 
** Please report all errors or modifications that you make to ilove@worldbank.org 
**
**


capture program drop pvar2
program define pvar2
version 6.0
set matsize 400
set log l 100

syntax varlist [if] , [ Lag(integer 1) ] [ * ]

*di " number of lags entered is |`lag'|"
*di " remaining options are stored as |`options'|"
*di " IF is set to |`if'|"


global P=`lag'

preserve

xtset
local pdent=r(panelvar)
local tdent=r(timevar)
global dentifs="`pdent' `tdent'"

if "`if'"~="" { keep `if' }      /* if a subset of the data was specified */
global if="`if'"

***** separating options into local macros **************
tokenize `options' , parse(" """)   /* this will take options into separate macro arguments */
  local i=0        
  while "`1'"~="" {  
     * di "current option read is `1'" 
     local i=`i'+1
     local parm`i' "`1'"   /* assign the entered parameter to local macro parm1, parm2 ... */
     mac shift              
     }
  local parms `i'

if `parms'==0 { 
   di in red "at least one option is required"
   exit }



***** creating global lists Y, X, Z to call GMM **********************
tokenize `varlist'

local g=0        /* g is a counter of equations for GMM/variables in VAR */
global names=""
while "`1'"~="" {          /* read one input variable at a time */
   local g=`g'+1
   *drop if `1'==.             /* drop MISSING - OPTIONAL - uncomment  */ 
   global y`g'="h_`1'"        /* these will be Y1...YG to use in GMM */
   global name`g'="`1'"       /* this is a list of original names one by one */
   global names="$names `1'"  /* this is global list of all names */
   local p=1                  /* p is counter for lags */
   while `p'<=$P {            /* will generate x's and z'a for each lag */
     local x_`p' "`x_`p'' l`p'.h_`1'" 
     local z_`p' "`z_`p'' l`p'.`1'"
     local p=`p'+1 
     }
mac shift
} 

global G=`g'                /* total number of variables/equations */


** make x's and z's lists from separate lags:
local p=1   
while `p'<=$P {             /* join together separate lags */
   local x "`x' `x_`p''" 
   local z "`z' `z_`p''"
   local p=`p'+1 
   }
** now make all Xg and Zg to be the same as x and z - i.e. use same instruments for each eq.
local g=1
while `g'<=$G {
global x`g' "`x'"
global z`g' "`z'"
*helm ${name`g'}   /** optional is to call HELMERT HERE - after missing have been deleted **/
  local g=`g'+1 
}

*di " G= $G"
*di " y1=$y1, y2=$y2, x1=$x1, x2=$x2, z1=$z1, z2=$z2"
*di "$names"

** calling the routines that were requested  - OPTIONS after comma
local g=1  

if "`parms'"~="" {     
	while `g'<=`parms' { 
		if "`parm`g''"=="monte" {     /* this will figure out desired monte options */ 
			local temp=`g'+1 

			local mtemp 0
			local xtrap 0
	
			capture confirm integer number `parm`temp''   /* check if next parameter is integer */
			if !_rc {							/*if integer, user specified iteration count */
				local xtrap 1
				local mtemp 1
				local mparam1=`temp'
				local temp=`temp'+1
			}

			capture confirm integer number `parm`temp''
			if !_rc {					/*user specified max IRF horizon */
				local mtemp 2
				local mparam2=`temp'
				global mirf=`parm`temp''
				local temp=`temp'+1
			}
			else {global mirf=6}

			capture confirm integer number `parm`temp''
			if !_rc {					/* user specified IRF x-axis display interval*/
				global stirf=`parm`temp''
				local g=`g'+1
			}
			else {global stirf=1}

			if `xtrap'==1 {  /* yes, it is integer */
				if `mtemp'==1 {
					local g=`g'+1                     /* skip to the next parameter */
					monte `parm`mparam1''
				}
				else {
					local g=`g'+2
					monte `parm`mparam1'' `parm`mparam2''
				}
			}
			else { monte }                    /* otherwise call monte without parameter */
    
			local g=`g'+1
		}
		
		if "`parm`g''"=="impulse" {     /* this will figure out desired impulse options */ 
			local temp=`g'+1 

			local xtrap 0
	
			capture confirm integer number `parm`temp''
			if !_rc {					/*user specified max IRF horizon */
				local xtrap 1
				local iparm=`temp'
				global mirf=`parm`temp''
				local temp=`temp'+1
			}
			else {global mirf=1}

			capture confirm integer number `parm`temp''
			if !_rc {					/* user specified IRF x-axis display interval*/
				global stirf=`parm`temp''
				local g=`g'+1
			}
			else {global stirf=1}

			if `xtrap'==1 {
				local g=`g'+1                     /* skip to the next parameter */
				impulse `parm`iparm''
			}
			else { impulse }                    /* otherwise call impulse without parameter */
    
			local g=`g'+1
		}

		if "`parm`g''"=="decomp" {     /* this will figure out desired decomp options */ 
			local temp=`g'+1 
	
			local dtemp 0
			local xtrap 0
	
			capture confirm integer number `parm`temp''   /* check if next parameter is integer */
			if !_rc {							/*if integer, user specified max decomp */
				local xtrap 1
				local dtemp 1
				local dparam1=`temp'
				local temp=`temp'+1
			}

			capture confirm integer number `parm`temp''
			if !_rc {					/* user specified decomp reported interval */
				local dtemp 2
				local dparam2=`temp'
				local temp=`temp'+1
			}

			if `xtrap'==1 {  /* yes, it is integer */
				if `dtemp'==1 {
					local g=`g'+1                     /* skip to the next parameter */
					decomp `parm`dparam1''
				}
				else {
					local g=`g'+2
					decomp `parm`dparam1'' `parm`dparam2''
				}
			}
			else { decomp }                    /* otherwise call decomp without parameter */
    
			local g=`g'+1
		}
		else {
			if "`parm`g''"=="gmm"  { sgmm2 }  /* renamed gmm into system gmm */
			else {`parm`g'' }
			local g=`g'+1
		}
	}
}

capture erase pvarres_temp.dta

end

*************************************************
** Save data file with reduced-form residuals  **
*************************************************
capture program drop getresid
program define getresid

quietly use pvarres_temp, clear
quietly drop if u1==.
quietly save pvar2_resid, replace

end
*************************************************
** Monte-Carlo for errors on impulse-responses **
*************************************************
capture program drop monte
program define monte
** will perform Monte-Carlo simulation for errors, parameter 1 has the number of
** repetitions, default 200
set matsize 800
if "`2'"==""{global maxirf 6} /*maximum IRF horizon, default=6 */
else global maxirf `2'

impulse ${maxirf}                /* call  impulse - for the first pass */
if "`1'"==""{ global maxi 200}  /* number of iterations for MOnte-Carlo, default 200 */
 else global maxi `1'  

*** 1 generate E - sigma, var-cov matrix of errors uu
** Dn and Dnp used to transfrom vec into vech and back
maked $G               /* get appropriate matrix Dn corresponding to number of equations G */
mat Dnp=(invsym(Dn'*Dn) )*Dn'
vec uu vecu
mat vechu=Dnp* vecu
mat E=(1/$T)*2*Dnp*(uu # uu)*Dnp'  /* var-cov of elements of uu */
                         /* ask Charlie about T - degrees of freedom */

drop _all
use impulse
drop varname
qui save errors, replace   /* start with empty dataset */

di "Starting Monte-Carlo loop : $S_TIME , total $maxi repetitions requested"
set more off 
capture mat drop Di   /* this is big matrix containing impulses */

** loop around here :
global i = 1   /* number of iterations to use in impulse program */
while $i<=$maxi { 
***  generate random vectors for coefficients and uu
random bgmm var     /* random vector with coefficients, mean: bgmm var: var */
mat bgmmi=random
random vechu E      /* random vector vech with errors, mean: vecu, var: E*/
mat vecui=Dn*random    /* random vector vec with errors */
unvec vecui uui        /* uui is the random matrix with errors */
  mat rownames uui= $names
  mat colnames uui= $names
*comp i           /* generate companion matrix for simulation i -will be called from impulse*/
impulse ${maxirf} i
global i=$i+1 
}

di "finished Monte-Carlo loop : $S_TIME "


** create percentiles and merge with impulse data
local g = 1
while `g'<=$G { /* creating names of new variables for collapse */
  local list1 "`list1' ${name`g'}_5=${name`g'}"
  local list2 "`list2' ${name`g'}_95=${name`g'}"
  local g=`g'+1 }
*di "list1 `list1' list2 `list2'"


collapse (p5) `list1' (p95) `list2', by(order s)
sort order s
merge order s using impulse
qui save imp_$maxi,replace
gr_imp i
end

**
** this will graph impulses with monte-errors - it is done autumatically in monte ! ***
**
capture program drop gr_mon
program define gr_mon
 drop _all
 use imp_$maxi
 gr_imp i
end

*********************************
** graph of impulse-responses ***
*********************************

capture program drop gr_imp
program define gr_imp

* can graph with errors and without errors

if "`1'"=="i"{local i "i"}   /* in case of Monte-Carlo `i'="i" */
  else local i ""            /* normal case `i'is a blank     */

 set textsize 170

local g=1
while `g'<=$G {         /* row variable - the one that is recepient of respone */

  local j=1
  while `j'<=$G {      /* column variable - the one causing response */
     if "`i'"=="i" {   /* with errors */
       format ${name`j'}_5 ${name`j'} ${name`j'}_95 %7.4f
       version 9: twoway (line ${name`j'}_5 s, lcolor(gs1) lpattern(dash)) (line ${name`j'} s, lcolor(gs1) lpattern(solid)) /*
       */ (line ${name`j'}_95 s, lcolor(gs1) lpattern(dash)) if /* 
	   */  varname=="${name`g'}",name(gr`g'_`j',replace) /* 
       */ /*title("response of ${name`g'} to ${name`j'} shock")*/title("${name`j'} shock") ytitle("${name`g'}") scheme(s2manual) legend(off) ylabel(,angle(horizontal) format(%5.4f)) xlabel(0(${stirf})${mirf})
	   version 9: graph save gr`g'_`j' gr`g'_`j'.gph, replace
	}
     else {             /* without errors */
        format ${name`j'} %7.4f
		version 9: twoway (line ${name`j'} s, lcolor(gs1) lpattern(solid)) if varname=="${name`g'}", name(gr`g'_`j',replace) /*                         
        */  /*title("response of ${name`g'} to ${name`j'} shock")*/title("${name`j'} shock") ytitle("${name`g'}") scheme(s2manual) legend(off) ylabel(,angle(horizontal) format(%5.4f)) xlabel(0(${stirf})${mirf})
		version 9: graph save gr`g'_`j' gr`g'_`j'.gph, replace
	}
     local grlist "`grlist' gr`g'_`j'"   /* list of all graphs to put together */
     local j=`j'+1 
   }
local g=`g'+1 
}

 set textsize 100
*if length("   Impulse-responses for $P lag VAR of $names ")>80 { set textsize 90}

if "`i'"=="i"{ 
   local b2="note(Errors are 5% on each side generated by Monte-Carlo with $maxi reps)"}

if "$if"~="" { local t2="subtitle(Sample : $if)"}

if length("   Impulse-responses for $P lag VAR of $names ")<80 {
   version 9: gr combine `grlist', title(     Impulse-responses for $P lag VAR of $names ) `t2' `b2' scheme(s2gmanual) scale(.7) name(grcombine1,replace)
    }
else {
   version 9: gr combine `grlist', title( $P lag VAR of $names ) `t2' `b2' scheme(s2gmanual) scale(.7) name(grcombine2,replace)
   }
end



*********************************
** Impulse-response functions  **
*********************************
**
** these are responses to 1 std shock, formulas are:
** dXi/Dvj = A^s*P[.,j]   response of variable Xi to shock in variable j at time s
** take jth column of matrix P - cholesky decomposition of u'u
** unit matrix J=[I(GxG),0,0...,0] is used to extract the right portion 
** (first GxG block) of matrix A^s
**
** the data currently in memory will be save in a file temp_data
** impulse-responses will be save in a file impulse.dta 
**
** takes 2 parameters (optional)
** 1 is - maximum number of periods for response, default=6
** 2 = i if it is a Monte-Carlo simulation, note that in this case
**  first parameter must also be nonmissing
**

capture program drop impulse
program define impulse
*set trace on
        

if "`1'"==""{ local bigs 6}  /* number of periods for impulse response */
 else local bigs `1'         /* if parameter is not given, default=6 */   

if "`2'"=="i"{local i "i"}   /* in case of Monte-Carlo `i'="i" */
  else local i ""            /* normal case `i'is a blank     */

comp `i'

capture mat drop D        /* drop only in  a normal case, keep for MOnte-carlo */
matrix P=cholesky(uu`i')
global R=$P*$G               /* R is the dimension of the companion matrix #lags * #vars */
if $P>1 {mat J=I($G), J($G, $R-$G,0) } /* J matrix used to extract nesessary portion of A */
   else mat J=I($G)           /* if P=1 - one lag VAR, J==I - no need to extract anything */

order_           /* will return vector with order */
mat colnames order="order"
drop _all

if "`i'"=="i" {
        mat repeat=J(rowsof(order),1,$i)    /* the repetition number ofr MOnte-Carlo */
        mat colnames repeat="repeat"
        local rep "repeat,"}                /* this will add the number of the repetition for Monte only */
  else   local rep ""


mat AS=I($R)                 /* start with identity matrix - before the first product */

**** Creating impulses for each time s *******************

local s=0                 /* start with time zero AS=I */
while `s'<=`bigs' {       /* time s shock */
  tempname time DS
  mat `time'=J($G,1,`s')   /* will store time for graphing time==s */
  mat rownames `time'= $names
  mat colnames `time'= s

mat `DS' =J * AS * J'* P  /* one step creating impulses for all variables */

mat `DS'= `rep' `time',order, `DS'  /* add column of S - what time the shock is for */
mat D`i'=nullmat(D`i') \ `DS'  /* D is for all times all shocks */
mat AS=AS*A`i'           /* raise A to the power S for next round */
*mat list `DS'           /* i is for MOnte-Carlo, otherwise i=""   */

local s=`s'+1 
}

*mat list D

*drop order


if "`i'"=="i" {              /* for Monte-Carlo save in the errors dataset */
  local gs=(`bigs'+1)*$G     /* this is total number of new variables that will be created */
  local times=int(800/`gs')  /* number of times before saving errors to the disk */
  if $i/`times'==int($i/`times') | $i==$maxi { 
     /* only save every `times' times or at the end, otherwise -accumulate, to save time */
     di "i=$i, " _c
     qui svmat Di, name(col)   /* create variables for graphing/presentation */
     mat drop Di 
     append using errors
     qui save errors, replace
   }
}
else { 
  qui svmat D , name(col)   /* create variables for graphing/presentation */
  qui gen str6 varname=""  /* generate variable with names - for original impulses */
  local i = 1
  while `i'<=$G {
    qui replace varname="${name`i'}" if order==`i' 
     format ${name`i'} %7.4f
    local i=`i'+1 }
  order varname    /* put varname first variable -for printing*/
  sort order s

  qui save impulse, replace 
}

** variables show effect of column variable name on a row variable name
** i.e. column named Q contains effect of Q shock on variable names in varname
** for ex :
** s  varname  x1      
** 1  x1       1
** 1  x2       2     i.e. effect of x1 on x2 in period s=1 is equal to 2 
** 1  x3       3
** this is the best way to organize impulse-responses for graphing
** to graph :
**  gr ik s, by(varname) R c(l) sort ti(reponse to the shock in ik)
**  gr ik s if varname==Q, c(l) sort ti(reponse of Q to the shock in ik)

end


***********
** list  **
***********
** this program will list numbers for impulse-responses without bands  **
capture program drop list_imp
program define list_imp
  drop _all
  use impulse
  di "Impulse-responses of variable in varname to the shock in column variable"
  list  ,nod noobs
end

** this program will list impulsee with errors - one by one **
capture program drop list_mon
program define list_mon
  drop _all
  use imp_$maxi
  local j=1
  while `j'<=$G {      /* column variable - the one causing response */
     di "Impulse-responses of variable in varname to the shock in ${name`j'} "
     format ${name`j'}_5 ${name`j'} ${name`j'}_95 %7.4f
     list varname s ${name`j'}_5 ${name`j'} ${name`j'}_95 , nod
     local j=`j'+1 
  }
end


*************************************
** this will create companion form **
*************************************
** my notation ( Charlie's notation)
** G (nk) - number of variables == number of equations in VAR
** P (np) - number of lags in VAR
** r (nr) = G*P  is number of regressors in equation (now all equations have the same
**       number of regressors)  (number of variables* times number of lags)
** Input matrices (must exist) bgmm, output: A (companion form)
**
** takes one parameter (optional) in case it is used for monte-carlo
** first parameter must be i if it has to be used for monte-carlo

capture program drop comp
program define comp

*set trace on
*di "program COMP running"

if "`1'"=="i"{local i "i"}
  else local i ""

local r=$P*$G  /* number of regressors in each equation */

** will generate new matrix beta which consists of blocks -reshape bgmm ***
capture mat drop beta
tempname b
local g = 1
while `g'<=$G {    /* extract column vector of coefficients for equation g into b */
  mat `b'=bgmm`i'[1+(`g'-1)*`r'..`g'*`r',.]   
  mat colnames `b' = ${y`g'}     /* give name to the column */  
  mat beta=nullmat(beta),`b'
  local g=`g'+1}
*mat list beta

** generate A - companion matrix ****
capture mat drop A`i'
if $P>1 {
  tempname temp
  mat `temp'=I(`r'-$G), J(`r'-$G, $G,0)    
  mat A`i'=beta' \ `temp'   /* stack vertically */
  }
else mat A`i'=beta'
mat drop beta

end




*************************************************************************
** Program RANDOM
**
** generates random vector distributed with mean `1' and variance `2'
** first parameter is name of the vector with the mean of the resulting vector
** second parameter is the var-cov of the resulting vector
** length of the vector will be the same as length of vector with means
** resulting vector will be called random
*************************************************************************
capture program drop random
program define random
** first will generate independent random vector N(0,1)
local r=rowsof(`1')
if rowsof(`2')~=colsof(`2') | rowsof(`2')~=rowsof(`1') { 
   di in red "Program Random: Matrix `2' must be square with same # of rows as `1' "
   exit}
local i = 1
tempname P temp
while `i'<=`r' { /* create element by element and stack into the vector */
mat `temp'=nullmat(`temp') \ J(1,1,invnorm(uniform()) )
  local i=`i'+1 }

** transform to have mean `1' and variance `2'
mat `P'=cholesky(`2')
mat random=`1'+`P' * `temp'  /* resulting vector wiht mean `1' and variance `2' */

end


capture program drop order_
program define order_
** will generate a "sequence" vector with numbers 1,2,3,... $G,
** result is saved in vector order (use for impulse)
capture mat drop order
local i = 1
while `i'<=$G { /* create element by element and stack into the vector */
mat order=nullmat(order) \ J(1,1,`i')
  local i=`i'+1 }
end


*******************
** VEC and UNVEC **
*******************
**
** VEC - will create vector from the matrix, only symmetric for now
** parameter `1' - name of the input matrix, `2' - name of output vector
** `1' is square matrix, `2' is vector matrix
**

capture program drop vec
program define vec

if rowsof(`1')~=colsof(`1') { 
   di in red "Matrix `1' is not square - will not create vec"
   exit}
local r=rowsof(`1')     
capture mat drop `2' 
tempname b
local g = 1
while `g'<=`r' {    
  mat `b'=`1'[1...,`g']             /* extract column g */
  mat `2'=nullmat(`2') \ `b'      /* stack the columns vetrically */
 local g=`g'+1}
end

capture program drop unvec
program define unvec
**
** will create square matrix from the vector
** `1' is name of input vector, `2' name of output matrix
** for now only does square matrix, i.e. vector should be a vec of a square matrix
**
local r=sqrt(rowsof(`1'))       /* number of rows in resulting matrix */
tempname b
capture mat drop `2' 
local g = 1
while `g'<=`r' {                
  mat `b'=`1'[1+(`g'-1)*`r'..`g'*`r',.]  /* extract column g from the vector  */
  mat `2'=nullmat(`2'),`b'           /* stack columns horisontally */
  local g=`g'+1}

end

********************
** Make Dn matrix **
********************
** takes one parameter - the number of the matrix
** this will make Dn matrices to use for generating distribution of uu
** they all will be called Dn, whenre n =$G
** for now only works for up to 10

capture program drop maked
program define maked

capture drop Dn
if `1'==1 {
mat Dn = (1)
exit}
if `1'==2 {
mat Dn = (1, 0 ,0 \ 0, 1, 0 \ 0, 1, 0 \ 0, 0, 1)
exit}
if `1'==3 {
mat Dn = (1,0,0,0,0,0\0,1,0,0,0,0\0,0,1,0,0,0\0,1,0,0,0,0\0,0,0,1,0,0\0,0,0,0,1,0\0,0,1,0,0,0\0,0,0,0,1,0\0,0,0,0,0,1)
exit}
if `1'==4 {
*set trace on
tempname temp1 temp2 temp3 temp4
mat `temp1' =I(4),J(4,6,0)
mat `temp2' =(0,1,0,0,0,0,0,0,0,0)
mat `temp3' =J(3,4,0), I(3), J(3,3,0)
mat `temp4' =(0,0,1,0,0,0,0,0,0,0\0,0,0,0,0,1,0,0,0,0\0,0,0,0,0,0,0,1,0,0\0,0,0,0,0,0,0,0,1,0\0,0,0,1,0,0,0,0,0,0\0,0,0,0,0,0,1,0,0,0\0,0,0,0,0,0,0,0,1,0\0,0,0,0,0,0,0,0,0,1)
mat Dn=`temp1' \ `temp2' \ `temp3' \ `temp4'
exit}

if `1'==5 {
local e2_5="(0,1,0,0,0)"
local e3_5="(0,0,1,0,0)"
local e4_5="(0,0,0,1,0)"
local e5_5="(0,0,0,0,1)"
local e2_4="(0,1,0,0)"
local e3_4="(0,0,1,0)"
local e4_4="(0,0,0,1)"
local e2_3="(0,1,0)"
local e3_3="(0,0,1)"
tempname temp1 temp2 temp3 temp4 temp5
mat `temp1' =I(5),J(5,10,0)
mat `temp2'=`e2_5',J(1,10,0) \ J(4,5,0),I(4),J(4,6,0)
mat `temp3'=`e3_5',J(1,10,0) \ J(1,5,0), `e2_4', J(1,6,0) \ J(3,9,0), I(3), J(3,3,0)
mat `temp4'=`e4_5',J(1,10,0) \ J(1,5,0), `e3_4', J(1,6,0) \ J(1,9,0), `e2_3', J(1,3,0) \ J(2,12,0), I(2), J(2,1,0)
mat `temp5'=`e5_5',J(1,10,0) \ J(1,5,0), `e4_4', J(1,6,0) \ J(1,9,0), `e3_3', J(1,3,0) \ J(2,13,0), I(2)
mat Dn=`temp1' \ `temp2' \ `temp3' \ `temp4' \ `temp5'
exit}
if `1'==6 {
local e2_6="(0,1,0,0,0,0)"
local e3_6="(0,0,1,0,0,0)"
local e4_6="(0,0,0,1,0,0)"
local e5_6="(0,0,0,0,1,0)"
local e6_6="(0,0,0,0,0,1)"
local e2_5="(0,1,0,0,0)"
local e3_5="(0,0,1,0,0)"
local e4_5="(0,0,0,1,0)"
local e5_5="(0,0,0,0,1)"
local e2_4="(0,1,0,0)"
local e3_4="(0,0,1,0)"
local e4_4="(0,0,0,1)"
local e2_3="(0,1,0)"
local e3_3="(0,0,1)"
tempname temp1 temp2 temp3 temp4 temp5 temp6
mat `temp1' =I(6),J(6,15,0)
mat `temp2'=`e2_6',J(1,15,0) \ J(5,6,0),I(5),J(5,10,0)
mat `temp3'=`e3_6',J(1,15,0) \ J(1,6,0), `e2_5', J(1,10,0) \ J(4,11,0), I(4), J(4,6,0)
mat `temp4'=`e4_6',J(1,15,0) \ J(1,6,0), `e3_5', J(1,10,0) \ J(1,11,0), `e2_4', J(1,6,0) \ J(3,15,0), I(3), J(3,3,0)
mat `temp5'=`e5_6',J(1,15,0) \ J(1,6,0), `e4_5', J(1,10,0) \ J(1,11,0), `e3_4', J(1,6,0) \ J(1,15,0), `e2_3', J(1,3,0) \ J(2,18,0), I(2), J(2,1,0)
mat `temp6'=`e6_6',J(1,15,0) \ J(1,6,0), `e5_5', J(1,10,0) \ J(1,11,0), `e4_4', J(1,6,0) \ J(1,15,0), `e3_3', J(1,3,0) \ J(2,19,0), I(2)
mat Dn=`temp1' \ `temp2' \ `temp3' \ `temp4' \ `temp5' \ `temp6'
exit}
if `1'>6 {
version 9: mata: st_matrix("Dn",Dmatrix(`1'))
version 9: exit}
end



*********************************
** Variance decomposition      **
*********************************
**
** This will generate matrix D with variance decompositions
** algorithm:
** for each time s, for each variable j : first j loop generates MSEj as sum over t=0...s-1 
** of  At*pj*pj'*At (generated in the inside loop t) 
** then MSEs is sum over MSEj for time s (MSEs is formula (11.5.7) in Hamilton p.324)
** second j loop generates decompositions (ratios):
** Dj is a column of decompositions w.r.t variable j (each row in a column is decomposition 
** for each of the row variables), Ds is all Dj stacked horizontally and finally D is 
** the output matrix (stacked vertically all Ds for all times s.)
**
** takes two parameters - max periods to generate decomp for, and interval at which to display them
**
capture program drop decomp
program define decomp

capture mat drop D  
matrix P=cholesky(uu)
global R=$P*$G   /* R is the dimension of the companion matrix */

if $P>1 {
mat J=I($G), J($G, $R-$G,0) } /* J matrix used to extract nesessary portion of A */
   else mat J=I($G)           /* if P=1 - one lag VAR, J==I - no need to extract anything */

local bigs `1'                  /* total number of periods - given by the parameter */
if "`1'"==""{local bigs=20}     /* default=20    */
local r `2'/* intervals at which to display*/
if "`2'"==""{local r 10} /* default=10 */
if `r'>`bigs'{
	local r `bigs' /*If user chooses interval greater than total periods, set r=bigs */
	di "Variance decomposition interval chosen exceeds maximum period selection. Interval reset to `bigs'"
}

local gs=`bigs'*$G              /* size of the big D matrix */
if `gs'>200{set matsize `gs'}

tempname A0
mat AS=I($R)              /* Big RxR matrix -at each stage S it is A^s  */ 
mat `A0'=I($G)            /* this is GxG identity - before the first product */

***** loop over s *******
local s=1                 /* start with time one -need A0=I */
di "s=" _c

while `s'<=`bigs' {       /* time s shock */


*** this will only be calculated for round s (up to bigs)  s=10, 20, 30 etc ***
if `s'/`r'==int(`s'/`r') {
  di "`s'," _c
  mat MSEs=J($G,$G,0)            /* starting value for total MSE for period s */
  local j=1
  while `j'<=$G {              /* response to j's variable */
    mat pj=P[1... ,`j']          /* extract jth colimn of matrix P */
    mat MSE`j'=J($G,$G,0)        /* matrix of zeros - starting value for MSEj */
 
        local t=0                  
        while `t'<=`s'-1 {         /* loop over t=1.. s-1 */
                                   /* max t is always one period less then s, A0=I, A1=A^1 */
        mat temp=`A`t'' * pj * pj ' * `A`t'''  
        mat MSE`j'=MSE`j'+temp     /* sum variance over t periods */ 
        *di " t=`t' this is temp = A`t'* p`j'*p`j' '*A`t' "
        *mat list temp
        local t=`t'+1 
        }

    mat MSEs=MSEs+MSE`j'         /* accumulating MSEs as sum of MSEj; MSEs is GxG */
    mat MSE`j'=vecdiag(MSE`j')  /* keep only diagonal elements after pass j is finished */
    local j=`j'+1 
   }

  mat MSEs=vecdiag(MSEs)                 /* make a row vector of total MSEs */

*** generate decompositions for each j for current s, then stack together to get Ds ***

  mat time=J($G,1,`s')                   /* will store time for graphing time==s */
  mat rownames time= $names              /* name rows  of time with original variable names */ 
  mat Ds=time      /* Ds is staked decompositions for time s start with vector of time only*/


  local j=1
  while `j'<=$G {                     /* response to j's variable */
     element Dj = MSE`j' / MSEs       /* variance ratio wrt j th variable  */
     mat drop MSE`j'
     mat Dj=Dj'                       /* make it a column vector - to stack */
     mat Ds=Ds, Dj                   /* Ds is accumulating columns of Dj */
     local j=`j'+1 
   }
  mat D=nullmat(D) \ Ds                  /* stack vertically for all times */ 
} /* end  of IF */

tempname A`s'                            /* generate next As */
mat AS=AS*A                              /* this is big RxR - companion in power s (rolling)*/  
mat `A`s''=J * AS * J'                   /* this is GxG - extracted the right matrix -keep*/
local s=`s'+1 
}

di ""
di "** variance-decompositions: percent of variation in the row variable explained by column variable"
mat drop MSEs pj time Ds Dj temp AS J P
mat colnames D= s $names
mat list D

end

**********************
** program element  **
**********************

capture program drop element
program define element
 * this program will perform element by element operation on matricies
 * possible functions will be +, -, *, /
 * the format is
 * element  output = input1 * input2     - for multiplication
 * element  output = input1 / input2     - for division
 * where * is in place of the operation that is needed to perform
 /* parameters 1 - output matrix
                2 - equal sign, for better readability
                3 - input matrix 1
                4 - operation to perform 
                5 - input matrix 2  */
  * both input patricies must be same size - for now

local input1="`3'"    /* unload input vector into name input */
local input2="`5'"
local o="`4'"           /* operation */
local output="`1'"
local rows=rowsof(`input1')
local cols=colsof(`input1')
mat `output'=`input1'   /* create "dummy" matrix which then will be replaced */
local i=1
while `i'<=`rows'{
  local j=1
  while `j'<=`cols'{
        if "`o'"=="/" & `input2'[`i',`j']==0 { di in white "division by zero in `i' row `j' col" }
     mat `output'[`i',`j']=`input1'[`i',`j']`o'`input2'[`i',`j']
     local j=`j'+1
    }
  local i=`i'+1
}
end

