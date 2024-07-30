*! version 3.0 13Mar2017 
*! by Hung-Jen Wang and Chia-Wen Ho
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw


capture program drop sf_effindex
program define sf_effindex
version 9.0
syntax  [if] [in],   [JLMS(string) BC(string)]

marksample todo

  quie _diparm usigmas, exp /* this gives sigma_u^2 */
  scalar sig_u2=r(est)
  quie _diparm vsigmas, exp /* this gives sigma_v^2 */
  scalar sig_v2=r(est)


if $h_dist == 1 {
  scalar mmu = 0
  }
else if $h_dist == 0 {
  scalar mmu = [mu]_b[_cons]
  }


   tempvar fun2 fun3 fun4 h_delta res_m
   quie predict double `fun2' if `todo', eq(frontier) xb
   quie predict double `fun3' if `todo', eq(h1eq) xb     /*z1_hat */

   tempvar fun3a
   quie gen double  `fun3a' = exp(`fun3')  if `todo'
   quie egen double `fun4' = mean(`fun3a')  if `todo', by($MY_panel)
   quie gen double  `h_delta' = `fun3a' - `fun4'   if `todo' /* h_{it.} or \tilde{h}_{i.}*/

   quie gen double `res_m'= $DM_yvar-`fun2'   if `todo'  /* residuals */

   quie tab $MY_panel  if `todo'
   local noffirm = _result(2)

     capture confirm numeric variable $MY_panel
     if _rc ~=0 {  /* not a numerical variable */
       tempvar id_num
       quie egen double `id_num' = group($MY_panel)  if `todo'
       global MY_panel `id_num'
     }

   mat_res_dmean  if `todo',  noffirm(`noffirm') id($MY_panel) epsilon(`res_m')  hfun(`h_delta')

   capture drop s1v1 s2v1 s3v1
   tempvar s1vv s2vv s3vv hit sigma2_star mu_star

   tempvar tem1
   sort $MY_panel $MY_time
   quie by $MY_panel: gen `tem1' = 1 if _n == 1 & `todo'
   sort `tem1' $MY_panel
   svmat double m1, names(s1v) /* it would create a variable called s1v1 */
   svmat double m2, names(s2v)
   svmat double m3, names(s3v)

   sort $MY_panel $MY_time
   quie by $MY_panel: egen double `s1vv' = mean(s1v1) if `todo'
   quie by $MY_panel: egen double `s2vv' = mean(s2v1) if `todo'
   quie by $MY_panel: egen double `s3vv' = mean(s3v1) if `todo'

   quie gen double  `sigma2_star' =  1/((`s2vv')+(1/(scalar(sig_u2))))  if `todo'
   if $PorC == 1 {
     quie gen double  `mu_star'     =  ((scalar(mmu)/((scalar(sig_u2)))) - `s1vv')* (`sigma2_star')  if `todo'
   }
   if $PorC == 2 { /* cost frontier */
     quie gen double  `mu_star'     =  ((scalar(mmu)/((scalar(sig_u2)))) + `s1vv')* (`sigma2_star')  if `todo'
   }
   quie gen double `hit' = exp(`fun3') if `todo'

   if "`jlms'" ~= "" {
       quie gen double `jlms' = `hit'*( `mu_star'+sqrt(`sigma2_star')*( normalden(`mu_star'/sqrt(`sigma2_star'))/norm(`mu_star'/sqrt(`sigma2_star')))) if `todo'
        label var `jlms' "index of E(u|e)"
    }


   if "`bc'" ~= "" {
        quie gen double `bc' =(norm(`mu_star'/sqrt(`sigma2_star')-`hit'*sqrt(`sigma2_star'))/norm(`mu_star'/sqrt(`sigma2_star')))*exp(-`hit'*`mu_star'+0.5*`hit'^2*`sigma2_star') if `todo'
        label var `bc' "index of E(exp(-u)|e)"
   }

   sort $MY_panel $MY_time
   capture drop s1v1 s2v1 s3v1


 *! ******************************* the usual jlms *****************

tempname s1
scalar `s1'  = exp(0.5*[usigmas]_b[_cons])



        ** mean of u_i; E(u_i) **

tempname Eofu
tempvar eff_uncond

scalar `Eofu' = scalar(`s1')*(normalden(scalar(mmu)/scalar(`s1'))/norm(scalar(mmu)/scalar(`s1')) + scalar(mmu)/scalar(`s1'))
quie gen double `eff_uncond' = exp(`fun3')*scalar(`Eofu')  if `todo'

  /* conditional expectation */


  tempvar sumofH Eepsi

  sort $MY_panel $MY_time
  quie by $MY_panel: egen double `sumofH' = mean(exp(`fun3'))  if `todo'
  quie gen double `Eepsi' = -`sumofH'*scalar(`Eofu')  if `todo' /* constant within each panel, differ across panels */

   ** recover the fixed effect: E(b0) = b0 = E(yit) - E(beta*xit) - E(eit)

  tempvar Eyit Exit beta0 epsi_it

  sort $MY_panel $MY_time
  quie by $MY_panel:  egen double `Eyit' = mean($DM_yvar) if `todo'
  quie by $MY_panel:  egen double `Exit' = mean(`fun2') if `todo'

  quie gen double `beta0' = `Eyit' - `Exit' - `Eepsi' if `todo'
  quie gen double `epsi_it' = $DM_yvar - `beta0' - `fun2' if `todo'


end


capture program drop outmean_w
program define outmean_w

version 6.0

syntax varlist [if] [in], I(string) NOMIS(string)

marksample touse, nov

local ivar "`i'"

if `nomis'== 1 {
   findmis `varlist', gen(_varmisw)
}
else if `nomis' == 0 {
   quie gen byte _varmisw = 0
}
else {
   di in red "Incorrect specification of -nomis()-."
   exit
}

tempvar process

quie gen byte `process' = 1 /* assume all samples are to be processed */
quie replace `process' = 0 if ~`touse' /* nullify if not in the specified sample */
quie replace `process' = 0 if _varmisw == 1 /* nullify if do not need those missings */
drop _varmisw

tokenize `varlist'

while "`1'" ~= ""{
   sort `ivar'
   quie egen double _meann = mean(`1') if `process' == 1 , by("`ivar'")
   quie replace `1' = `1' - _meann if `process' == 1
   drop _meann
   mac shift
}


end
