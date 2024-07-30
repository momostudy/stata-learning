*! version 3.0 13Mar2017 
*! by Hung-Jen Wang and Chia-Wen Ho
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw

* citation: Hung-Jen Wang and Chia-Wen Ho (2010). "Estimating fixed-effect panel
*           stochastic frontier models by model transformation", Journal of Econometrics,
*           Volume 157, Issue 2, August 2010, Pages 286-296.


capture program drop sf_fixeff
program define sf_fixeff
* version 9.0

version 11


syntax varlist [if] [in], FRONTIER(varlist) ZVAR(varlist) ID(varname) TIME(varname) Distribution(string) [MU USIGMAS VSIGMAS COST PRODuction SHOW NOMESSAGE]

marksample touse

local xvar `frontier'
local exovar `zvar'

/* ------------- message --------- */
/*
if "`nomessage'" == "" {
di in red "  ***************************************************"
di in gre "    If you encounter error messages of" in red " model not defined " in green "or" in red " invalid syntax"
di in gre "    when executing this or the following" in yel " ml max " in gre "command, see the instruction in
di in yel "      https://sites.google.com/site/sfbook2014/home/version-control-issue"
di in gre "    to debug. You may turn off this message by adding the option -nomessage-.
di in red "  ****************************************************"
}
*/

/* ------ checking the distribution assumption ------- */

if "`distribution'" == " " {
   di in red "You need to specifiy a distributional assumption in -distribution()-."
   error 198
}

if "`half'" ~= "" {
   global h_dist = 1 /* used in the follows and also in sf_effindex */
   }

if "`trun'" ~= "" {
   global h_dist = 0
    if "`mu'" == "" {
       di in red "With the -dist(t)- option, you also need to specify -mu-."
    }
   }

if ("`distribution'" == "h") | ("`distribution'" == "halfnormal") {
   global h_dist = 1
}
else if ("`distribution'" == "t") | ("`distribution'" == "truncated") {
   global h_dist = 0
}
else {
   di in red "You didn't specify the -distribution()- option correctly."
   exit 198
}

/* ----- check production or cost function -------- */

global PorC = "Correct PorC Specification" /* offset previous values, so that errors are issued if a proper value is not given */

if "`production'" ~= "" & "`cost'" ~= "" {
   di in red "You can specify only one of the -cost- or -prod-, not both."
}

if "`production'" ~= "" {
   global PorC = 1
}
else if "`cost'" ~= ""{
   global PorC = 2
}
else {
   di in red "You need to specify -cost- or -production-."
   exit 198
}

****************************************************



/* half or truncated dist. */

if $h_dist == 1 {
*   global mu_true = 0
   global mufun
   }
else if $h_dist == 0 {
   global mufun (mu: )
   }
else {
  di in red "Wrong specification of distribution."
  error 199
  exit
}


************************************************

foreach X in  $DM_yvar $DM_xvar {
  capture drop `X'
}


foreach X in DM_yvar DM_xvar {
  global `X'  /* nullify the macro */
}


*****************  demean case **************************


     unab allxvar : `xvar'
     unab allzvar : `exovar'


     local yvar `varlist'

     tempvar themiss
     findmis_w  `yvar' `allxvar' `allzvar'  if `touse', gen(`themiss') /*! note that this command will take care of sample selection by if and in */
*     quie drop if `themiss' == 1

     global DM_xvar
     foreach X in `allxvar' {
      quie gen double _`X'_M = `X' if `themiss' ==0  /* generate a copy of the variables */
      global DM_xvar $DM_xvar _`X'_M  /* a list of variables to be de-meaned */
     }

     global DM_yvar
     foreach Y in `yvar' {
      quie gen double _`Y'_M = `Y'   if `themiss' ==0 /* generate a copy of the variables */
      global DM_yvar $DM_yvar _`Y'_M  /* a list of variables to be de-meaned */
     }

     outmean_w $DM_yvar $DM_xvar if `themiss' == 0, i(`id') nomis(1)

     global MY_panel `id'
     global MY_time `time'

                 ml model d0 sffix_dmean (frontier: $DM_yvar = $DM_xvar, noconstant ) (h1eq: `allzvar' , noconstant) (vsigmas: ) $mufun (usigmas: )  if `themiss'==0
    global showM ml model d0 sffix_dmean (frontier: $DM_yvar = $DM_xvar, noconstant ) (h1eq: `allzvar' , noconstant) (vsigmas: ) $mufun (usigmas: )  if `themiss'==0
    global ML_user_hj sffix_dmean

if "`show'" ~= "" {
 di " "
 di in gre "  *** The sfmodel sets up the following model for ML estimation.***
 di "$showM"
 di " "
}

end



capture program drop outmean_w
program define outmean_w

version 6.0

syntax varlist [if] [in], I(string) NOMIS(string)

marksample touse, nov

local ivar "`i'"

if `nomis'== 1 {
   findmis_w `varlist', gen(_varmisw)
}
else if `nomis' == 0 {
   quie gen byte _varmisw = 0
}
else {
   di in red "Incorrect specification of -nomis()-."
   exit
}

tempvar process

* quie gen byte `process' = 1 /* assume all samples are to be processed */
* quie replace `process' = 0 if `touse' /* nullify if not in the specified sample */
* quie replace `process' = 0 if _varmisw == 1 /* nullify if do not need those missings */

quie gen byte `process' = 0 /* assume all samples are NOT to be processed */
quie replace `process' = 1 if `touse' /* those in the specified sample */
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


capture program drop findmis_w
program define findmis_w

  version 6.0
  syntax varlist [if] [in], GENerate(string)

   marksample touse, nov

  quie gen byte `generate' = 0

   tokenize `varlist'

   tempvar nouse
   quie gen `nouse' = 1 - `touse'

  while "`1'" ~= ""{

     quie replace `generate' = 1 if `nouse' | `1' == .

     mac shift
  }
end
