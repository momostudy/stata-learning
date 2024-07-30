*! version 3.0 13Mar2017 
*! by Hung-Jen Wang
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw


capture program drop sf_init
program define sf_init


* version 8
* version 12

syntax,  [FRONTIER(string) INPUTs(string) LINEAR(string)  MU(string) USIGMAS(string) VSIGMAS(string) ESIGMAS(string) /*
            */ ETAs(string) HSCALE(string) TAU(string) CU(string) /*
            */ SHARE1(string) SHARE2(string) SHARE3(string) SHARE4(string) /*
            */ GAMMA(string) SIGMAUV(string) S11(string) S22(string) S33(string) /*
            */ S44(string) S21(string) S31(string) S32(string) S41(string) S42(string) /*
            */ S43(string) M1(string) M2(string) M3(string) M4(string) M5(string) /*
            */ ZVAR(string)   /*
            */ PROBvar(string) SHOW]


global hjckmd = substr("$ML_user_hj", 1, 5) /* check which type of ML ADO is used */


if "`inputs'" ~="" {
     di in red "Init for the duality-based system model hasn't implemented yet."
     di in red "Maybe this is the time to do it?"
}


if "$hjckmd" == "scost"{ /* the ML is from sfsysC construct */
 ml init `frontier' `share1' `share2' `share3' `share4' `gamma' `sigmauv' `usigmas' /*
   */ `s11' `s22' `s33' `s44' `s21' `s31' `s32' `s41' `s42' `s43' `mu', copy

 global showI ml init `frontier' `share1' `share2' `share3' `share4' `gamma' `sigmauv' `usigmas' /*
   */ `s11' `s22' `s33' `s44' `s21' `s31' `s32' `s41' `s42' `s43' `mu', copy

}

local elem1 s11 s22 s33 s44 /* for no corr */
local elem2 s32 s42 s43
local elem3 s21 s31 s41

if "$hjckmd" == "sysco"{ /* the ML is from the new cost system construct */

 ml init `frontier' `share1' `share2' `share3' `share4' `gamma' `sigmauv' `usigmas' /*
   */ `s11' `s22' `s33' `s44' `s32' `s42' `s43' `s21' `s31' `s41' `mu', copy

 global showI ml init `frontier' `share1' `share2' `share3' `share4' `gamma' `sigmauv' `usigmas' /*
   */ `s11' `s22' `s33' `s44' `s32' `s42' `s43' `s21' `s31' `s41' `mu', copy
}


else if "$hjckmd" == "sf_pa" { /* the sfpan (panel) function */
 ml init `frontier' `mu' `gamma'  `usigmas' `vsigmas', copy
 global showI  ml init `frontier' `mu' `gamma'  `usigmas' `vsigmas', copy
}

else if "$hjckmd" == "mle_C" { /* the sfpanel_Cham, panel model with Chamberlain method */
  ml init `frontier' `mu' `usigmas' `vsigmas' `esigmas', copy
  global showI ml init `frontier' `mu' `usigmas' `vsigmas' `esigmas', copy
}

else if ("$hjckmd" == "sf_mi") | ("$hjckmd" == "cl_mi") { /* the mixture model */


global inilist


forvalues i = 1/$nofg {

  if "$mufun" ~= "" { /* truncated normal */
      global mu_ini0 `mu'
  }
  else {
      global mu_ini0
  }

  if `i' < $nofg {
      global pb_ini0 `probvar'
  }
  else { /* the last group does not have prob fun */
       global pb_ini0
  }

  global inilist $inilist `frontier' $mu_ini0 `usigmas' `vsigmas' $pb_ini0


 }

 ml init $inilist, copy
 global showI ml init $inilist, copy

} /* end of mixture model ini construction */

else if "$hjckmd" == "sffix" { /* the ML from sf_fixeff */

  if "`mu'" ~= "" {
    local mmu=`mu'
  }

  else{
   local mmu=""
  }

    ml init `frontier' `zvar'  `vsigmas'  `usigmas'  `mu', copy
    global showI ml init `frontier' `zvar'  `vsigmas'  `usigmas'  `mu', copy

}
else if "$hjckmd" ~= "scost"{ /* the ML is from sfmodel construct */

  ml init `frontier' `mu' `etas' `hscale' `tau' `cu' `usigmas' `vsigmas', copy
  global showI ml init `frontier' `mu' `etas' `hscale' `tau' `cu' `usigmas' `vsigmas', copy

}


if "`show'"~="" {
 di " "
 di in gre "  *** The sf_init sets up the following model for ML estimation.***
 di "$showI"
 di " "
}


end
