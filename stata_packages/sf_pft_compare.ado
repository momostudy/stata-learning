*! version 3.0 13Mar2017 
*! by Hung-Jen Wang
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw

capture program drop sf_pft_compare
program define sf_pft_compare

version 7.0

syntax [if] [in], JLMS(string) ERROR(string)  [MESSage(string)  VTERM(real 0)]
marksample touse


   global hj_synt "`0'" /* record the original input syntax for later use */

if "`error'" == "tech" {
  local cterm "technical"
}
else if "`error'" == "alloc" {
  local cterm "allocative"
}
else if "`error'" == "both" {
  local cterm "technical and allocative"
}
else {
  di in red "The -error()- has to be tech, alloc, or both."
  exit 119
}

**** get _front1c81 ******

capture confirm var _front1c81
if _rc ~= 0 {
  spft_sprd_post if `touse'
}

*************************

capture drop _overallresid
quie gen double _overallresid = $dep0z - _front1c81 if `touse'


sf_pft_get if `touse', jlms(`jlms') error(none) vterm(`vterm')

   capture drop _pft_o  /* optimal profit */

   quie gen double _pft_o =  exp($yp)*exp(${dep0z}_o) if `touse'
   label var _pft_o "optimal profit"

        forvalues k=1/$nofvvar {
             quie replace _pft_o = _pft_o - exp(${w_c`k'})*exp(${x_c`k'}_o) if `touse'
         }


sf_pft_get if `touse' $hj_synt

         if "`error'" == "tech" {
            local ss u
         }
         if "`error'" == "alloc" {
            local ss xi
         }
         if "`error'" == "both" {
            local ss uxi
         }

   capture drop _pft_`ss'  /* sub-optimal profit */

   quie gen double _pft_`ss' = exp($yp)*exp(${dep0z}_`ss') if `touse'
    label var _pft_`ss' "profit with inefficiency"


         forvalues k=1/$nofvvar {
             quie replace _pft_`ss' = _pft_`ss' - exp(${w_c`k'})*exp(${x_c`k'}_`ss')  if `touse'
         }

    capture drop _pft_diff_`ss'

    quie gen double _pft_diff_`ss' = (_pft_o - _pft_`ss')/_pft_o  if `touse'
    label var _pft_diff_`ss' "percentage of profit loss due to inefficiency"

di " "
di in gre "The following is the summary statistics of profit loss as a ratio"
di in gre "of optimal profit. Profit loss is defined as the difference between"
di in gre "the optimal profit and the profit with " in yel "`cterm'"
di in gre "inefficiency. The optimal profit is the profit without technical and"
di in gre "allocative inefficiency."

    sum _pft_diff_`ss', detail

end
