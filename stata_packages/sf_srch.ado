*! version 3.0 13Mar2017 
*! by Hung-Jen Wang
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw



capture program drop sf_srch
program define sf_srch

*          sf_srch, n(2) frontier(x1 x2 x3) mu(z1 z2) usigmas(z1 z2) vsigmas() nograph

* version 10.1 /* cannot have this line */

syntax, N(string) [FRONTIER(string) INPUTs(string) LINEAR(string) MU(string) USIGMAS(string) VSIGMAS(string) ESIGMAS(string) /*
            */ ETAs(string) HSCALE(string) TAU CU /*
            */ SHARE1(string) SHARE2(string) SHARE3(string) SHARE4(string) /*
            */ GAMMA(string) SIGMAUV(string) S11(string) S22(string) S33(string) /*
            */ S44(string) S21(string) S31(string) S32(string) S41(string) S42(string) /*
            */ S43(string) M1(string) M2(string) M3(string) M4(string) M5(string) /*
            */ ZVAR(string)  /*
            */ PROBvar(string) NOGRAPH FAST]

if "`zvar'" ~= "" {  /* for the sf_fix model */
  local h1eq `zvar'
}


global hjckmd = substr("$ML_user_hj", 1, 5) /* check which type of ML ADO is used */




if "`inputs'"==""{
     global PD_search
}


local sfgphs : set graphics

if "`nograph'" ~= ""{
     set graphics off
}


if "`fast'" ~= "" {  /* fast */
  local fst _sf
  global hjw_srch_fast = 1
}
else {  /* not fast */
  local fst _sf  /* same as above; legacy reason. Now the real control of fast or not is on the following global. */
  global hjw_srch_fast = 0
}


********************************


if ("$hjckmd" == "sf_mi") | ("$hjckmd" == "cl_mi") {


local ii = 1

while `ii' <= `n' {

  foreach gp in g1 g2 g3 g4 g5 g6 g7 g8 g9  {
       foreach sfeqn in frontier mu usigmas vsigmas probvar {
          capture ml`fst' plot `sfeqn'_`gp':_cons
          capture for var ``sfeqn'': ml`fst' plot `sfeqn'_`gp':X
     }
 }
 local ii = `ii' + 1
}
capture set graphics `sfgphs'
exit
}



local ii = 1

while `ii' <= `n' {


  /* search constant */
foreach sfeqn in frontier linear m1 m2 m3 m4 m5 mu usigmas vsigmas esigmas /*
             */ etas hscale tau cu /*
             */ share1 share2 share3 share4 /*
             */ gamma sigmauv s11 s22 s33 /*
             */ s44 s21 s31 s32 s41 s42 /*
             */ s43 $PD_search   {
                   capture ml`fst' plot `sfeqn':_cons
             }

 /* search non-constant variables */
foreach sfeqn in frontier linear m1 m2 m3 m4 m5 mu usigmas vsigmas esigmas /*
             */ etas hscale  tau cu /*
             */ share1 share2 share3 share4 /*
             */ gamma sigmauv s11 s22 s33 /*
             */ s44 s21 s31 s32 s41 s42 /*
             */ s43 h1eq  {
                   capture for var ``sfeqn'': ml`fst' plot `sfeqn':X
             }

     local ii = `ii' + 1
}


****************


if ("$hjckmd" == "sffix") & ("`frontier'"~="") {

    local myvar
    foreach X of local frontier {
       local myvar `myvar'  _`X'_M
    }

  local ii = 1
  while `ii' <= `n' {
    foreach X of local myvar {
       capture  ml`fst' plot frontier:`X'
    }
    local ii = `ii' + 1
  }

}


capture set graphics `sfgphs'

end
