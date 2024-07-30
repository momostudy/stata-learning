*! version 3.0 13Mar2017 
*! by Hung-Jen Wang
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw

capture program drop sf_cst_compare
program define sf_cst_compare


version 7.0


syntax, JLMS(string) ERROR(string) CD [V(real 0)]

if $CDorTL == 2 {
 di " "
 di in red "Apparently you have specified a translog production function in sfprim."
 di in red "The current program only supports models with Cobb-Douglas function."
 di " "
 exit 199
}

set seed 1235

global expu `jlms'

if "`cd'" == "" {
 di " "
 di in red "The current program only supports models with Cobb-Douglas function."
 di in red "If your model is Cobb-Douglas, please add the -cd- option to the command and run again."
 di " "
 exit 199
}


tempname method

if "`error'" == "tech" {
  scalar `method' = 1
  local cterm "technical"
}
else if "`error'" == "alloc" {
  scalar `method' = 2
  local cterm "allocative"
}
else if "`error'" == "both" {
  scalar `method' = 3
  local cterm "technical and allocative"
}
else {
  di in red "The -error()- has to be tech, alloc, or both."
  exit 119
}

local ninput = $ninput  /* number of total input */
local nvinput = $nvinput /* number of total variable input */
local nofshr = `nvinput' -1 /* number of shares */

forvalues i = 1/`nofshr' {
   capture drop epsi`i'b
   quie gen double epsi`i'b = .
}


foreach X in resid  fakey C_a C_o C_ratio shr123 {
     capture drop `X'
}


if `v' == 0 { /* assume the error v = 0, the default */
  quie gen double resid = 0
}
else if `v' == 1 { /* assume the error v = v, not 0 */
  quie gen double resid = v_u + $expu /* that is, v-u + u = v; need to get v-u first  */
}
else {
   di in red "Wrong value of -v()-. It should be either v(1) or v(0)."
   exit 198
}



getshare

forvalues i = 2/`nvinput' {
  local ii = `i' - 1
  tempvar epsi`ii'a
  quie gen double `epsi`ii'a' = ln(_shr`i'/_shr1) - ${w_c`i'} + $w_c1 - ${x_c`i'} + $x_c1
}


/* Get the optimal inputs; no tech, no alloc */

   quie replace resid = resid /* using the default (which is v-u=0 if v=0) */
     forvalues i = 1/`nofshr' {
         quie replace epsi`i'b = 0
     }

exactC

  forvalues i = 1/`nvinput' {
      capture drop optx`i'
      quie gen double optx`i' = myx`i'
  }


if `method' == 1 {
   quie replace resid = resid -$expu  /* v-u = -u */

     forvalues i = 1/`nofshr' {
         quie replace epsi`i'b = 0  /* xi = 0 */
     }
 exactC
}

if `method' == 2 {
   quie replace resid = resid  /* v-u = 0 */

     forvalues i = 1/`nofshr' {
         quie replace epsi`i'b = `epsi`i'a'  /* xi = xi */
     }
 exactC
}

if `method' == 3 {
   quie replace resid = resid -$expu /* v-u = -u */

     forvalues i = 1/`nofshr' {
         quie replace epsi`i'b = `epsi`i'a' /* xi = xi */
     }
 exactC
}


di " "
di in gre "The following is the summary statistics of excess cost as a ratio"
di in gre "of optimal cost. Excess cost is defined as the difference between"
di in gre "the cost with " in yel "`cterm'" in gre " inefficiency and the optimal (minimum)"
di in gre "cost. The optimal cost is the cost without technical and"
di in gre "allocative inefficiency."


   quie gen double C_o = exp($w_c1)*exp(optx1)
   quie gen double C_a = exp($w_c1)*exp(myx1)

  forvalues i = 2/`nvinput' {
    quie replace C_o = C_o + exp(${w_c`i'})*exp(optx`i')
    quie replace C_a = C_a + exp(${w_c`i'})*exp(myx`i')
  }

  quie gen double C_ratio = C_a/C_o -1
  sum C_ratio, detail


end
