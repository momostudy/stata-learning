*==========================*
*  GMM PROGRAM             *
*==========================*
***************** DECKER BUILD AUGUST 1, 2012 ***************************************
* this will do system GMM for any number of equations (including 1 equation)
* 
* TO USE : must define global lists with all variables in equations 
*          dep.variables must be in lists y1 y2...
*          regressors must be in x1 x2 ... and instruments in z1 z2 ...
*          must define global macro G which has number of equations
* for example :
* global y1="ik"                             /* EQ 1: dep.var */
* global x1="const l.ik sk"                  /* EQ 1: rhs variables */
* global z1="const l.ik l.sk l2.ik l2.sk"    /* EQ 1: instruments (include exog vars here)  */  
* global G=1
*
* after exit this program will leave behind matrices: b2sls bgmm var std
* results will be posted to Stata so tests can be done using Stata's command
* for ex: test [eq1_]sk=[eq2_]h_sk   
*

capture program drop sgmm2
program define sgmm2
version 6.0
*set trace on

di "GMM started : $S_TIME  "
/* getting number of variables in each equation */
local l = 0       /* total number of instruments for the system */
local k = 0       /*                 regressors                 */
local g=1
while `g'<=$G {
  local l`g' : word count ${z`g'} 
  local k`g' : word count ${x`g'} 
  local l=`l'+`l`g''
  local k=`k'+`k`g''
  local g=`g'+1 
}
*di "locals l1=`l1' l2=`l2' k1=`k1' k2=`k2' total l= `l' k=`k'" 

/* accumultaing matrices */

tempname zy temp
di in b "accumulating matrices equation " _c
local g=1
while `g'<=$G {
di "`g'," _c
tempname zz`g' zx`g' zy`g'
qui mat accum `temp'= ${z`g'} ${x`g'}, nocon       /* equation g */
mat `zz`g''=`temp'[1..`l`g'', 1..`l`g'']
mat `zx`g''=`temp'[1..`l`g'', `l`g''+1...]
qui mat accum `temp'= ${y`g'} ${z`g'}, nocon
mat `zy`g''=`temp'[2...,1]
local listzx="`listzx' `zx`g''"   /* accumulate lists of all zx and zz matrices */
local listzz="`listzz' `zz`g''"
mat `zy'= nullmat(`zy') \ `zy`g''    /* accumulating ZY - it is not diagonal */
local g=`g'+1 
}

di in b "calculating b2sls"

/* System 2SLS - should be equal to equation by equation */

tempname zx zz invz
diag `zx' = `listzx'
diag `zz' = `listzz'
mat `invz'=invsym(`zz')
mat b2sls=invsym(`zx'' * `invz' * `zx' ) * `zx'' * `invz' * `zy'

*mat list b2sls
mat `temp'=b2sls

/* generating uhats for each equation g */

local g = 1
while `g'<=$G {
  tempname b`g'           /* extract coefficients for equation g into b`g' */
  tempvar t`g' u`g'
  mat `b`g''=`temp'[1..`k`g'',.]'           /* note bg's are row vectors! */
  capture mat `temp'=`temp'[`k`g''+1...,.]  /* leave coeficients for remaining 
                                             equations in temp */
  mat score `t`g''=`b`g''
  qui gen `u`g''=${y`g'}-`t`g''
  local listu "`listu' `u`g''" /* this is the list of all residuals */
  local g=`g'+1
}

/* calculating big ZuuZ matrix */

di in b "calculating big ZuuZ matrix"
local g=1                         /* equation indicator */
while `g' <=$G {
   tokenize ${z`g'}              /* get names of instruments in separate macros */
   local i=1                     /* instrument indicator */                 
   while "``i''" != "" {         /* go over list of instruments for  equation g */ 
    * di "g=`g' i=`i' zi=``i''"   /* ``i'' will put name of instrument variable */
      tempvar z`g'_`i'
      qui gen `z`g'_`i''=``i''*`u`g''      /* generating tempvar= Zi*u */
      local list "`list' `z`g'_`i''"  /* list of all instruments from all equations */
    * di "`list'" 
      local i = `i' + 1   }
   drop `u`g''                       /* do not need ug after all Zi *ug is calculated */
   local g=`g'+1
}

di in b "finished accumulating ZuuZ"

*di "`list'"
local nlist : word count `list'
*di "Number of instruments included in ZuuZ `nlist'"

tempname ZuuZ W tstat out output
qui mat accum `ZuuZ'=`list' , nocons    /* this is bigZ consists of all equation zuuz's */

mat ZuuZ=`ZuuZ'

drop `list'             /* do not need these variables anymore */
*drop `listu'            /* no, these errors are already dropped above */


local nused=_result(1)      /* number of obs used for this matrix is the 
                               number of obs for the system -when all 
                               variables in each equation are nonmissing*/
global T=`nused'
mat `W'=invsym((1/`nused')*`ZuuZ')
mat W=`W'
*mat list `ZuuZ'


mat bgmm=invsym(`zx'' * `W' * `zx')*`zx'' * `W' * `zy'
mat var=`nused'*invsym(`zx'' * `W' * `zx')            /* variance-covariance matrix */

mat `temp'=vecdiag(var)'     
matroot `temp' std     /* calculate square root of vector var, place in std */
element `tstat' = bgmm / std    /* caclutating t-statistics */

mat tstat=`tstat'   /* temporary */

/* printing output */

*mat `out'=b2sls,bgmm,std,`tstat'
*mat colnames `out'=b_2SLS b_GMM se_GMM t_GMM

*mat drop b2sls
mat `out'=bgmm,std,`tstat'
mat colnames `out'= b_GMM se_GMM t_GMM

di in g "_______ Results of the Estimation by system GMM_________"
di in g "number of observations used : " in y  "`nused'" 

local g=1
while `g'<=$G {
  di in gr _dup(78) "-"
  di in g "EQ`g': dep.var     : " in y  "${y`g'}" 
 * di in g "     regressors  : " in y "${x`g'}"
 * di in g "     instruments : " in y "${z`g'}"
  mat `output'=`out'[1..`k`g'',.]          /* pick coefficients for equation g */
  capture mat `out'=`out'[`k`g''+1...,.]   /* matrix out is what is left for 
                                      the rest of equations if nothing is
                                      left returns error which I capture*/
  mat list `output', noh
  di in gr _dup(78) "-"
  local g=`g'+1
  }
/*
tempname temp2
mat `temp'=bgmm'      /* to post results to STATA for later use, if needed */
mat `temp2'=var
mat post `temp' `temp2'
*mat mlout       /* this can display results easily - but I already have that done */
*/

/* hansen test */

/* need to calculate new residuals from the gmm estiamtor - replace old ones */
mat `temp'=bgmm

local listu=""
local g = 1

while `g'<=$G {
  tempname b`g'           /* extract coefficients for equation g into b`g' */
  tempvar t`g' u`g'
  mat `b`g''=`temp'[1..`k`g'',.]'           /* note bg's are row vectors! */
  capture mat `temp'=`temp'[`k`g''+1...,.] 
  mat score `t`g''=`b`g''
  qui gen `u`g''=${y`g'}-`t`g''    
  capture drop u`g'
  qui gen u`g'=${y`g'}-`t`g''    /* NOTE - added permenent variable with residual */

*di " score for equation `g': and residual"
*sum `t`g'' `u`g'' ${y`g'}

local listu "`listu' `u`g''" /* this is the list of all residuals - use to calculate u'u */
local listup "`listup' u`g'"  /* list of permanent variables with residuals */
local nameu "`nameu' eq`g'"  /*  list of equation numbers - to name rows and columns of uu */
  local g=`g'+1
}

set trace off

if `k'<`l' {
tempname uZ H h prob
local g=1
while `g'<=$G {
  mat vecaccum `temp' = `u`g'' ${z`g'} , nocons
  mat `uZ'=nullmat(`uZ'),`temp'        /* uZ is long row of all uZi */
  local g=`g'+1 
}
mat `H'=(1/`nused')* `uZ' * `W' * `uZ''
scalar `h'=`H'[1,1]
local df=`l'-`k'
scalar `prob'=chiprob(`df',`h')
di in g "Hansen H = " in y `h' in g " with df of " in y "`df'" in g " and prob = " in y `prob'  
}
else di in g "just identified - Hansen statistic is not calculated "

if $G>1 {  /* correlation matrix is only calculated if more then 1 equation is specified */
**** generating U'U matrix of variance-covariance of resuduals *****
*di "these are summary  of residuals:"
*sum `listu' $names

qui mat accum uu=`listup' , nocons    /* this is u'u for all equations */
mat uu=(1/`nused')*uu
if "$names"~="" {       local nameu "$names"        } 
  * for VAR only - $names is the list of all Y variable names 
  * for others - make the list later using Y variables, for now will use eq1 eq2 ...
mat colnames uu = `nameu'     
mat rownames uu = `nameu'
mat list uu

di " "
di in g "Residuals correlation matrix "
pwcorr `listup' , sig
}


* Save residuals
keep $dentifs `listup'
quietly save pvarres_temp, replace

* drop `listup'   /* dropping permanent variables ug */

/*
di " "
di in g "Variance-covariance matrix of residuals (u'u):"
mat list uu
di " "

mat `temp'=vecdiag(uu)   /* vector of mean squared errors of regression */
mat `temp'=`temp'
matroot `temp' rmse
di in g "Mean squared errors of regression (sqrt of diagonal elements of u'u)"
mat list rmse
*/

di " "
di "GMM finished : $S_TIME"
di " "

end

*******************************************
*** Auxilary programs needed to run GMM ***
*******************************************


capture program drop diag
program define diag
** this will construct block diagonal matrix from the matrices supplied as list of parameters
** TO USE:  diag outname = zx1 zx2 zx3 
** outname will be the name of big block diagonal matrix 
local out `1'  /* get name of the output matrix into `out' local */
mac shift      /* skip next parameter - it is equal sign */ 
mac shift
tempname a temp1 temp2
mat `a'=`1'
mac shift
  local i 1      /* i is counter of equations - to use in naming columns and rows*/
*   matrix roweq `a' = eq1_
*   matrix coleq `a' = eq1_
while "`1'"~="" {
mat `temp1'=`a', J(rowsof(`a'),colsof(`1'),0)
mat `temp2'=J(rowsof(`1'),colsof(`a'),0), `1'
  local i=`i'+1                /* all idented lines  are just for*/
*   matrix roweq `1' = eq`i'_    /* corret labeling of variables and equations */
*   matrix coleq `1' = eq`i'_
  local cola : colnames(`a')
  local rowa : rownames(`a')
  local col1 : colnames(`1')
  local row1 : rownames(`1')
   local reqa : roweq(`a')
   local req1 : roweq(`1') 
   local ceqa : coleq(`a')
   local ceq1 : coleq(`1')   
mat `a'= `temp1' \ `temp2'
  mat colnames `a' = `cola' `col1' 
  mat rownames `a' = `rowa' `row1'
   mat roweq `a'=`reqa' `req1'
   mat coleq `a'=`ceqa' `ceq1'
mac shift
}
mat `out'=`a'
end



capture program drop matroot
program define matroot
 * this program calculates matrix with square roots of each element in the
 * incoming matrix
 * to use :  matroot input output
local input="`1'"    /* unload input vector into name input */
local output="`2'"
local rows=rowsof(`1')
local cols=colsof(`1')
mat `output'=`input'   /* create "dummy" matrix which then will be replaced */
local i=1
while `i'<=`rows'{
  local j=1
  while `j'<=`cols'{
     if sqrt(`input'[`i',`j'])==. { di in white "negative values in input matrix - cannot take sqrt" }
     mat `output'[`i',`j']=sqrt(`input'[`i',`j'])
     local j=`j'+1
    }
  local i=`i'+1
}
end


*capture program drop element
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


capture program drop correl
program define correl
 * this program will generate correlation matrix from the covariance matrix


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


