*! version 3.0 13Mar2017 
*! by Hung-Jen Wang
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw

capture program drop sf_pft_get
program define sf_pft_get

version 7.0

*! Compute {y, x's} from the profit system of equations.
*! Solutions of y is recorded as y_s (ex, car -> car_s), and x is recorded as x_s (ex, labor -> labor_s).

syntax [if] [in], JLMS(string) ERROR(string)  [MESSage(string)  VTERM(real 0)]
marksample touse

if "`error'" == "none" {
   local uterm = 0
   local xiterm = 0
}
if "`error'" == "tech" {
   local uterm = 1
   local xiterm = 0
}
if "`error'" == "alloc" {
   local uterm = 0
   local xiterm = 1
}
if "`error'" == "both" {
   local uterm = 1
   local xiterm = 1
}


set seed 1235

* tempvar touse

*capture confirm var _touse06
*if _rc ~= 0 {
*  quie gen _touse06 = `touse'
*}

capture drop _touse06
quie gen _touse06 = `touse'

global expu `jlms'

/*
*! quie gen double _overallresid = $dep0z - _front1c81
global residA  _front1c81  /*! overall residual; v-u; taken from spft_sprd_post */
*/

* capture drop _overallresid
* quie gen double _overallresid = $dep0z - _front1c81 if _touse06
global residA _overallresid


capture drop residA

quie gen double residA = . if _touse06


capture confirm matrix _espft
if _rc ~= 0 {
 mat _espft = e(b) /* save the coefficient matrix to be used in the solving program */
}

local ee _espft

local nofe2 = $nofvvar + 1


if (`vterm' == 1) & (`uterm' == 1) {
 quie replace residA = $residA /* v - u */ if _touse06
}
if (`vterm' == 1) & (`uterm' == 0) {
 quie replace residA = $residA + $expu /* v - u + u = v */ if _touse06
}
if (`vterm' == 0) & (`uterm' == 1) {
 quie replace residA = -$expu if _touse06
}
if (`vterm' == 0) & (`uterm' == 0 ) {
 quie replace residA = 0 if _touse06
}


****************************************************************
******** for share residuals: get share (xb part) first ********
** borrowed from nlpftxy; variables may look the same **********

if `xiterm' == 1 { /* if the residuals are needed */

forvalues k = 1/$nofvvar  { /* loop over variable inputs */

  tempvar shr`k'

    ** the linear part **

   quie gen double `shr`k'' = `ee'[1, colnumb(`ee', "${x_c`k'}:_cons")] if _touse06



 if $CDorTL == 2 {


 ** the square and the cross product parts

  forvalues h = 1/$ninput { /* loop over all inputs */

     scalar bb = `ee'[1, colnumb(`ee', "${x_c`k'}${x_c`h'}:_cons")]

     if (scalar(bb) == .) {
        scalar bb =  `ee'[1, colnumb(`ee', "${x_c`h'}${x_c`k'}:_cons")]
     }

     quie replace `shr`k'' = `shr`k'' + scalar(bb)*${x_c`h'} if _touse06

   } /* forvalues h */

  } /* if CDorTL */

} /* forvalues k */


forvalues k = 1/$nofvvar {  /* generate residuals in single-equation form */
 tempvar e`k'A
 quie gen double `e`k'A' =  $yp + $dep0z + ln(`shr`k'') - ${x_c`k'} - ${w_c`k'} if _touse06
}

}

***** finish generating the residuals **************************
***************************************************************

forvalues k = 1/$nofvvar{
  tempvar epsi`k'b
  quie gen double `epsi`k'b' = .
}


if (`xiterm' == 0) {
   forvalues k = 1/$nofvvar {
    quie replace `epsi`k'b' = 0 if _touse06
   }
 }

if (`xiterm' == 1) {
   forvalues k = 1/$nofvvar {
     quie replace `epsi`k'b' = `e`k'A' if _touse06
   }
}

gsort /* -_touse06 */ $dep0z $x_c1

tempvar id
quie gen `id' = _n if _touse06

quie sum `id' if _touse06, meanonly
global nofobs = r(N)


capture drop fakey
capture drop ${dep0z}_s
capture drop conv_pbm

quie gen fakey = 0 if _touse06
quie gen double ${dep0z}_s  = .
quie gen double conv_pbm = .

forvalues k = 1/$nofvvar {
 capture drop ${x_c`k'}_s
 quie gen double ${x_c`k'}_s = .
}

global slist myya
forvalues k = 1/$nofvvar {
  global slist $slist myx`k'a
}


capture confirm var _linearpt06
if _rc ~= 0 {
  quie predict _linearpt06 if _touse06, xb equation(linear) /* the predicted value of the linear part */
}


forvalues i = 1/$nofobs {
     sort `id'
     quie replace fakey = 0 if _touse06
     quie replace fakey = 1 in 1/1

     sort `id'
     scalar yini  = $dep0z[1]
     scalar pini  = $yp[1]
     scalar residini = residA[1]
     scalar linearini = _linearpt06[1]

     forvalues k = 1/$nofvvar {  /* initials of variable inputs, the variable's wage, and residuals */
       sort `id'
       scalar x`k'ini = ${x_c`k'}[1]
       scalar w`k'ini = ${w_c`k'}[1]
       scalar e`k'ini = `epsi`k'b'[1]
     }

     if (`nofe2') <= $ninput {
     forvalues k = `nofe2'/$ninput {  /* initials of quasi-fixed inputs */
       sort `id'
       scalar qf`k'ini = ${x_c`k'}[1]
     }
     }


    capture nl pftxy fakey in 1/`nofe2', iterate(90) nrtol(0.00001)

     sort `id'

     if _rc==0 {
          quie replace ${dep0z}_s  = _b[myya]  in 1/1
          forvalues k = 1/$nofvvar {
            sort `id'
            quie replace ${x_c`k'}_s  = _b[myx`k'a] in 1/1
          }
     }
     if e(rss) > 1e-5 {
         quie replace conv_pbm = 1 in 1/1
     }


   if "`message'" ~= "" {
    local checki1 = int(`i'/`message')
    local checki2 = `i'/`message'

    if `checki1' == `checki2' {
       di "Solutions for `i' observations have been calculated."
    }
   }


     sort `id'
     quie replace `id' = . in 1/1
}

   if "`error'" == "none" {

         capture drop ${dep0z}_o
         quie gen double ${dep0z}_o = ${dep0z}_s
         label var ${dep0z}_o "optimal output"

         capture drop ${dep0z}_s

         forvalues k=1/$nofvvar {
             capture drop ${x_c`k'}_o
             quie gen double ${x_c`k'}_o = ${x_c`k'}_s
             label var ${x_c`k'}_o "optimal input"

             capture drop  ${x_c`k'}_s
         }
   }
   else {

         if "`error'" == "tech" {
            local ss u
         }
         if "`error'" == "alloc" {
            local ss xi
         }
         if "`error'" == "both" {
            local ss uxi
         }

         capture drop ${dep0z}_`ss'
         quie gen double ${dep0z}_`ss' = ${dep0z}_s
         label var ${dep0z}_`ss' "output with inefficiency"

         capture drop ${dep0z}_s

         forvalues k=1/$nofvvar {

             capture drop ${x_c`k'}_`ss'
             quie gen double ${x_c`k'}_`ss' = ${x_c`k'}_s
             label var ${x_c`k'}_`ss' "inputs with inefficiency"
             capture drop  ${x_c`k'}_s
         }
   }

end
