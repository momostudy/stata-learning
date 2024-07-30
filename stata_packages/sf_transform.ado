*! version 3.0 13Mar2017 
*! by Hung-Jen Wang
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw


capture program drop sf_transform
program define sf_transform, rclass


version 8

local hastitle = 0

    local preest = "`e(user)'"
    local mydep "`e(depvar)'"
      tokenize "`mydep'"
      local mydep "`1'"
    local hjckmd = substr("`preest'", 1, 5)

***** single equation

    if   ("`preest'" == "sf_halfd") | ("`preest'" == "sf_half2") /*
    */ | ("`preest'" == "sf_trund") | ("`preest'" == "sf_trun2") /*
    */ | ("`preest'" == "sf_SWd") | ("`preest'" == "sf_SW2") /*
    */ | ("`preest'" == "sf_expo") | ("`preest'" == "sffix_dmean") | ("`preest'" == "mle_Cham") {

     di " "
     di in gre "      sigma_u_sqr = exp(usigmas); "
     di in gre "      sigma_v_sqr = exp(vsigmas). "
   if ("`preest'" == "mle_Cham") {
     di in gre "      sigma_e_sqr = exp(esigmas). "
   }

     di " "
     di in gre "   ---convert the parameters to original form---  "
     di " "



     tempname mat0 matu matv
     mat `mat0' = e(b)


    *** on sigma_u^2 *******

    if ("`preest'" == "sf_SWd") | ("`preest'" == "sf_SW2") {
        di in gre "   The transformation cannot be done for sigma_u^_sqr in the"
        di in gre "   scaling-property model since it is a function of variables."
        di in gre "   The transformation is done only if sigma_u^_sqr is constant."
        di " "
    }
    else {

      if ("`preest'" == "sf_expo") {
        local eqname etas
      }
      else {
        local eqname usigmas
      }

    mat `matu' = `mat0'[1, "`eqname':"]
    local nofu = colsof(`matu')

     if `nofu' > 1 {
          di in gre "   sigma_u_sqr appears to be a function of variables."
          di in gre "   The transformation is done only if sigma_u_sqr is constant."
          di " "
      }


      else if `nofu' == 1 {

          prttitle
          local hastitle = 1

       _diparm `eqname', label(sigma_u_sqr) prob exp
       ret local sigma_u_sqr = r(est)
      }
    }


     *** on sigma_v^2 ******

     mat `matv' = `mat0'[1, "vsigmas:"]
     local nofv = colsof(`matv')

    if `nofv' > 1 {
        di in gre "   sigma_v_sqr appears to be a function of variables."
        di in gre "   The transformation can be done only if sigma_v_sqr is constant."
    }

     else if `nofv' == 1 {

     if "`hastitle'" ~= "1" {
          prttitle
     }

        _diparm vsigmas, label(sigma_v_sqr) prob exp
        ret local sigma_v_sqr = r(est)
    }


    *** on sigma_e^2 ***************

    tempname mate
    capture mat `mate' = `mat0'[1, "esigmas:"]

    if _rc == 0 {

      _diparm esigmas, label(sigma_e_sqr) prob exp
      ret local sigma_e_sqr = r(est)

    }

    }

************** profit system ***************************

if ("`hjckmd'" == "syspf") {

     local hastitle = 0

* ---------------- gamma + sigmauv, for no and partial correlation models

capture local dummy = [gamma]_b[_cons] + 1  /* trap error for full correlation model */
if _rc == 0 {

     di " "
     di in gre "      1/(1+exp(gamma)) = (sigma_u^2)/(sigma_u^2+sigma_v^2); "
     di in gre "      exp(sigmauv) = sqrt(sigma_v^2 + sigma_u^2). "
     di " "
     di in gre "   ---convert the parameters to the original form---  "
     di " "

     prttitle

     local hastitle = 1


_diparm gamma sigmauv, label(sigma_v_sqr) prob  ///
        function(exp(@1+2*@2)/(1+exp(@1))) ///
        deriv(exp(@1+2*@2)/(1+exp(@1))-exp(2*@1+2*@2)*(1+exp(@1))^(-2)  2*exp(@1+2*@2)/(1+exp(@1)))
 ret local sigma_v_sqr = r(est)


_diparm gamma sigmauv, label(sigma_u_sqr) prob  ///
        function(exp(2*@2)/(1+exp(@1))) ///
        deriv(-exp(2*@2+@1)*(1+exp(@1))^(-2)  2*exp(2*@2)/(1+exp(@1)) )
 ret local sigma_u_sqr = r(est)

}

* ------------------- usigmas, for full correlation models ------

capture local dummy = [usigmas]_b[_cons] + 1 /* model with full correlation */

if _rc == 0 {

     di " "
     di in gre "      sigma_u_sqr = exp(usigmas); "
     di " "
     di in gre "   ---convert the parameters to the original form---  "
     di " "

  if `hastitle' == 0 {

     prttitle

     local hastitle = 1
  }

        _diparm usigmas, label(sigma_u_sqr) prob exp
             ret local sigma_u_sqr = r(est)
}

* ---------------------------


  capture local dummy = [s11]_b[_cons] + 1
  if _rc == 0 {

  if `hastitle' == 0 {

     di " "
     di in gre "   ---convert the parameters to the original form---  "
     di " "

     prttitle

     local hastitle = 1
  }

     _diparm s11, label(sigma_1_sqr) function(exp(2*@))  deriv(2*exp(2*@)) prob
          ret local sigma_1_sqr = r(est)
  }

  capture local dummy = [s22]_b[_cons] + 1
  if _rc == 0 { /* meaning at least 2x2 */
    capture local dummy = [s21]_b[_cons] + 1
    if _rc ~= 0 { /* meaning only diagonal */

       if `hastitle' == 0 {

        di " "
        di in gre "   ---convert the parameters to the original form---  "
        di " "

          prttitle

          local hastitle = 1
       }

           _diparm s22, label(sigma_2_sqr) function(exp(2*@))  deriv(2*exp(2*@)) prob
                ret local sigma_2_sqr = r(est)
    }
    else { /* meaning off diagonal as well */

       if `hastitle' == 0 {

         di " "
         di in gre "   ---convert the parameters to the original form---  "
         di " "

          prttitle

          local hastitle = 1
       }
           _diparm s21 s22, label(sigma_2_sqr) function((@1)^2+exp(2*@2)) deriv(2*@1 2*exp(2*@2)) prob
               ret local sigma_2_sqr = r(est)
           _diparm s11 s21, label(sigma_21) function(exp(@1)*@2) deriv(exp(@1)*@2 exp(@1)) prob
               ret local sigma_21 = r(est)
    }
  }


  capture local dummy = [s33]_b[_cons] + 1
  if _rc == 0 { /* at least 3x3 */
     capture local dummy = [s31]_b[_cons]+1
     if _rc ~= 0 { /* diagonal matrix */

       if `hastitle' == 0 {

          di " "
          di in gre "   ---convert the parameters to the original form---  "
          di " "

          prttitle

          local hastitle = 1
       }


           _diparm s33, label(sigma_3_sqr) function(exp(2*@))  deriv(2*exp(2*@)) prob
               ret local sigma_3_sqr = r(est)
     }
     else {

       if `hastitle' == 0 {

          di " "
          di in gre "   ---convert the parameters to the original form---  "
          di " "

          prttitle

          local hastitle = 1
       }

         _diparm s31 s32 s33, label(sigma_3_sqr) function((@1)^2 + (@2)^2 + exp(2*@3)) deriv(2*@1 2*(@2) 2*exp(2*@3)) prob
               ret local sigma_3_sqr = r(est)
         _diparm s11 s31, label(sigma_31) function(exp(@1)*@2) deriv(exp(@1)*@2 exp(@1)) prob
               ret local sigma_31 = r(est)
         _diparm s21 s31 s22 s32, label(sigma_32) function(@1*@2 + exp(@3)*@4) deriv(@2 @1 @4*exp(@3) exp(@3)) prob
               ret local sigma_32 = r(est)
     }
  }



  capture local dummy = [s44]_b[_cons] + 1
  if _rc == 0 { /* 4x4 */
     capture local dummy = [s41]_b[_cons] + 1
     if _rc ~= 0 { /* diagonal matrix */

       if `hastitle' == 0 {

          di " "
          di in gre "   ---convert the parameters to the original form---  "
          di " "

          prttitle

          local hastitle = 1
       }
           _diparm s44, label(sigma_4_sqr) function(exp(2*@))  deriv(2*exp(2*@)) prob
                ret local sigma_4_sqr = r(est)
     }
     else {

       if `hastitle' == 0 {

          di " "
          di in gre "   ---convert the parameters to the original form---  "
          di " "

          prttitle

          local hastitle = 1
       }

         _diparm s41 s42 s43 s44, label(sigma_4_sqr) function((@1)^2+(@2)^2+(@3)^2+exp(2*@4)) deriv(2*@1 2*@2 2*@3 2*exp(2*@4)) prob
               ret local sigma_4_sqr = r(est)
         _diparm s11 s41, label(sigma_41) function(exp(@1)*@2) deriv(exp(@1)*@2 exp(@1)) prob
               ret local sigma_41 = r(est)
         _diparm s21 s41 s22 s42, label(sigma_42) function(@1*@2 + exp(@3)*@4) deriv(@2 @1 @4*exp(@3) exp(@3)) prob
               ret local sigma_42 = r(est)
         _diparm s31 s41 s32 s42 s33 s43, label(sigma_43) function(@1*@2 + @3*@4+ exp(@5)*@6) deriv(@2 @1 @4 @3 exp(@5)*@6 exp(@5)) prob
               ret local sigma_43 = r(est)
     }
  }

} /* profit system */

************ cost system ****************


  if  ("`hjckmd'" == "sysco") {

     local hastitle = 0

* ---------------- gamma + sigmauv, for no and partial correlation models

capture local dummy = [gamma]_b[_cons] + 1  /* trap error for full correlation model */
if _rc == 0 {

     di " "
     di in gre "      1/(1+exp(gamma)) = (sigma_u^2)/(sigma_u^2+sigma_v^2); "
     di in gre "      exp(sigmauv) = sqrt(sigma_v^2 + sigma_u^2). "
     di " "
     di in gre "   ---convert the parameters to the original form---  "
     di " "

     prttitle

     local hastitle = 1


_diparm gamma sigmauv, label(sigma_v_sqr) prob  ///
        function(exp(@1+2*@2)/(1+exp(@1))) ///
        deriv(exp(@1+2*@2)/(1+exp(@1))-exp(2*@1+2*@2)*(1+exp(@1))^(-2)  2*exp(@1+2*@2)/(1+exp(@1)))
 ret local sigma_v_sqr = r(est)


_diparm gamma sigmauv, label(sigma_u_sqr) prob  ///
        function(exp(2*@2)/(1+exp(@1))) ///
        deriv(-exp(2*@2+@1)*(1+exp(@1))^(-2)  2*exp(2*@2)/(1+exp(@1)) )
 ret local sigma_u_sqr = r(est)

}

* ------------------- Full or no correlation models ------

if ($scmtype == 1) | ($scmtype == 3) { /* for no- and full-correlation models */

     di " "
     di in gre "      sigma_u_sqr = exp(usigmas)."
     di in gre "      sigma_v_sqr = exp(vsigmas), the estiamted variance of v."
     di in gre "      sigma_i_sqr, the estimated variance of the ith share equation."
     di in gre "      sigma_iv: covariance of the ith share and the v."
     di in gre "      sigma_ij: covariance of the ith and the jth share equation."
     di " "
     di in gre "   ---convert the parameters to the original form---  "
     di " "

  if `hastitle' == 0 {

     prttitle

     local hastitle = 1
  }

        _diparm usigmas, label(sigma_u_sqr) prob exp
             ret local sigma_u_sqr = r(est)


* ---------------------------


  capture local dummy = [s11]_b[_cons] + 1
  if _rc == 0 {

  if `hastitle' == 0 {

     di " "
     di in gre "   ---convert the parameters to the original form---  "
     di " "

     prttitle

     local hastitle = 1
  }

     _diparm s11, label(sigma_v_sqr) function(exp(2*@))  deriv(2*exp(2*@)) prob
          ret local sigma_v_sqr = r(est)
  }

  capture local dummy = [s22]_b[_cons] + 1
  if _rc == 0 { /* meaning at least 2x2 */
    capture local dummy = [s21]_b[_cons] + 1
    if _rc ~= 0 { /* meaning only diagonal */

       if `hastitle' == 0 {

        di " "
        di in gre "   ---convert the parameters to the original form---  "
        di " "

          prttitle

          local hastitle = 1
       }

           _diparm s22, label(sigma_1_sqr) function(exp(2*@))  deriv(2*exp(2*@)) prob
                ret local sigma_1_sqr = r(est)
    }
    else { /* meaning off diagonal as well */

       if `hastitle' == 0 {

         di " "
         di in gre "   ---convert the parameters to the original form---  "
         di " "

          prttitle

          local hastitle = 1
       }
           _diparm s21 s22, label(sigma_1_sqr) function((@1)^2+exp(2*@2)) deriv(2*@1 2*exp(2*@2)) prob
               ret local sigma_1_sqr = r(est)
           _diparm s11 s21, label(sigma_1v) function(exp(@1)*@2) deriv(exp(@1)*@2 exp(@1)) prob
               ret local sigma_1v = r(est)
    }
  }


  capture local dummy = [s33]_b[_cons] + 1
  if _rc == 0 { /* at least 3x3 */
     capture local dummy = [s31]_b[_cons]+1
     if _rc ~= 0 { /* diagonal matrix */

       if `hastitle' == 0 {

          di " "
          di in gre "   ---convert the parameters to the original form---  "
          di " "

          prttitle

          local hastitle = 1
       }


           _diparm s33, label(sigma_2_sqr) function(exp(2*@))  deriv(2*exp(2*@)) prob
               ret local sigma_2_sqr = r(est)
     }
     else {

       if `hastitle' == 0 {

          di " "
          di in gre "   ---convert the parameters to the original form---  "
          di " "

          prttitle

          local hastitle = 1
       }

         _diparm s31 s32 s33, label(sigma_2_sqr) function((@1)^2 + (@2)^2 + exp(2*@3)) deriv(2*@1 2*(@2) 2*exp(2*@3)) prob
               ret local sigma_2_sqr = r(est)
         _diparm s11 s31, label(sigma_2v) function(exp(@1)*@2) deriv(exp(@1)*@2 exp(@1)) prob
               ret local sigma_2v = r(est)
         _diparm s21 s31 s22 s32, label(sigma_21) function(@1*@2 + exp(@3)*@4) deriv(@2 @1 @4*exp(@3) exp(@3)) prob
               ret local sigma_21 = r(est)
     }
  }



  capture local dummy = [s44]_b[_cons] + 1
  if _rc == 0 { /* 4x4 */
     capture local dummy = [s41]_b[_cons] + 1
     if _rc ~= 0 { /* diagonal matrix */

       if `hastitle' == 0 {

          di " "
          di in gre "   ---convert the parameters to the original form---  "
          di " "

          prttitle

          local hastitle = 1
       }
           _diparm s44, label(sigma_3_sqr) function(exp(2*@))  deriv(2*exp(2*@)) prob
                ret local sigma_3_sqr = r(est)
     }
     else {

       if `hastitle' == 0 {

          di " "
          di in gre "   ---convert the parameters to the original form---  "
          di " "

          prttitle

          local hastitle = 1
       }

         _diparm s41 s42 s43 s44, label(sigma_3_sqr) function((@1)^2+(@2)^2+(@3)^2+exp(2*@4)) deriv(2*@1 2*@2 2*@3 2*exp(2*@4)) prob
               ret local sigma_3_sqr = r(est)
         _diparm s11 s41, label(sigma_3v) function(exp(@1)*@2) deriv(exp(@1)*@2 exp(@1)) prob
               ret local sigma_3v = r(est)
         _diparm s21 s41 s22 s42, label(sigma_31) function(@1*@2 + exp(@3)*@4) deriv(@2 @1 @4*exp(@3) exp(@3)) prob
               ret local sigma_31 = r(est)
         _diparm s31 s41 s32 s42 s33 s43, label(sigma_32) function(@1*@2 + @3*@4+ exp(@5)*@6) deriv(@2 @1 @4 @3 exp(@5)*@6 exp(@5)) prob
               ret local sigma_32 = r(est)
     }
  }
 } /* full or no correlation */


* ------------------- partial correlation models ------

if ($scmtype == 2)  { /* for partial-correlation models */

     di " "
     di in gre "      sigma_u_sqr = exp(usigmas), the estiamted variance of u."
     di in gre "      sigma_v_sqr, the estiamted variance of v."
     di in gre "      sigma_i_sqr, the estimated variance of the ith share equation."
     di in gre "      sigma_iv: covariance of the ith share and the v."
     di in gre "      sigma_ij: covariance of the ith and the jth share equation."
     di " "
     di in gre "   ---convert the parameters to the original form---  "
     di " "

  if `hastitle' == 0 {

     prttitle

     local hastitle = 1
  }

        _diparm usigmas, label(sigma_u_sqr) prob exp
             ret local sigma_u_sqr = r(est)


* ---------------------------


  capture local dummy = [s11]_b[_cons] + 1
  if _rc == 0 {

  if `hastitle' == 0 {

     di " "
     di in gre "   ---convert the parameters to the original form---  "
     di " "

     prttitle

     local hastitle = 1
  }

     _diparm s11, label(sigma_v_sqr) function(exp(2*@))  deriv(2*exp(2*@)) prob
          ret local sigma_v_sqr = r(est)
  }

  capture local dummy = [s22]_b[_cons] + 1
  if _rc == 0 { /* meaning at least 2x2 */

       if `hastitle' == 0 {

        di " "
        di in gre "   ---convert the parameters to the original form---  "
        di " "

          prttitle

          local hastitle = 1
       }

           _diparm s22, label(sigma_1_sqr) function(exp(2*@))  deriv(2*exp(2*@)) prob
                ret local sigma_1_sqr = r(est)

  }


  capture local dummy = [s33]_b[_cons] + 1
  if _rc == 0 { /* at least 3x3 */
     capture local dummy = [s32]_b[_cons]+1
     if _rc ~= 0 { /* diagonal matrix */

       if `hastitle' == 0 {

          di " "
          di in gre "   ---convert the parameters to the original form---  "
          di " "

          prttitle

          local hastitle = 1
       }


           _diparm s33, label(sigma_2_sqr) function(exp(2*@))  deriv(2*exp(2*@)) prob
               ret local sigma_2_sqr = r(est)
     }
     else { /* off diagnoal as well */

       if `hastitle' == 0 {

          di " "
          di in gre "   ---convert the parameters to the original form---  "
          di " "

          prttitle

          local hastitle = 1
       }

         _diparm  s32 s33, label(sigma_2_sqr) function((@1)^2 + exp(2*@2)) deriv(2*(@1) 2*exp(2*@2)) prob
               ret local sigma_2_sqr = r(est)

         _diparm s22 s32, label(sigma_21) function(exp(@1)*@2) deriv(@2*exp(@1) exp(@1)) prob
               ret local sigma_21 = r(est)
     }
  }



  capture local dummy = [s44]_b[_cons] + 1
  if _rc == 0 { /* 4x4 */
     capture local dummy = [s42]_b[_cons] + 1
     if _rc ~= 0 { /* diagonal matrix */

       if `hastitle' == 0 {

          di " "
          di in gre "   ---convert the parameters to the original form---  "
          di " "

          prttitle

          local hastitle = 1
       }
           _diparm s44, label(sigma_3_sqr) function(exp(2*@))  deriv(2*exp(2*@)) prob
                ret local sigma_3_sqr = r(est)
     }
     else { /* off diagnoal as well */

       if `hastitle' == 0 {

          di " "
          di in gre "   ---convert the parameters to the original form---  "
          di " "

          prttitle

          local hastitle = 1
       }

         _diparm  s42 s43 s44, label(sigma_3_sqr) function((@1)^2+(@2)^2+exp(2*@3)) deriv(2*@1 2*@2 2*exp(2*@3)) prob
               ret local sigma_3_sqr = r(est)
         _diparm  s22 s42, label(sigma_31) function(exp(@1)*@2) deriv(@2*exp(@1) exp(@1)) prob
               ret local sigma_31 = r(est)
         _diparm  s32 s42 s33 s43, label(sigma_32) function(@1*@2+ exp(@3)*@4) deriv(@2 @1 exp(@3)*@4 exp(@3)) prob
               ret local sigma_32 = r(est)
     }
  }
 } /* partial correlation */

} /* cost system */

end


capture program drop prttitle
program define prttitle

          di in smcl in gr abbrev("variable",12) _col(14) "{c |}" /*
               */ _col(21) "Coef." _col(29) "Std. Err." _col(44) "t" /*
               */ _col(49) "P>|t|" _col(59) "[95% Conf. Interval]"
          di in smcl in gr "{hline 13}{c +}{hline 64}"

end
