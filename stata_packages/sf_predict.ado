*! version 3.0 13Mar2017 
*! by Hung-Jen Wang
*!    Department of Economics, National Taiwan University
*!   wangh@ntu.edu.tw


capture program drop sf_predict
program define sf_predict

    version 8
    syntax [if] [in] , [BC(string) JLMS(string) CI(string) MULtiplier(string) MARGinal  ATMEAN MIXTURE NONWeight] /* LOGdep CONDition */

    global hj_syn "`0'" /* record the original input syntax for later use */

    marksample touse, nov


    local preest = "`e(user)'"  /* previous estimation command */
    local mydep "`e(depvar)'"   /* the dependent variable */
      tokenize "`mydep'"  /* in case of the cost system equations, multiple dep are returned */
      local mydep "`1'"
    local hjckmd = substr("`preest'", 1, 5) /* see whether it is system: scost or sprd_ */

   if ("`hjckmd'" == "sf_pa") | ("`hjckmd'" == "scst_") {

        if ("`hjckmd'" == "sf_pa") {
                  sf_pan_post
        }

        ETE_pan if e(sample) $hj_syn
        exit
   }


   if ("`hjckmd'" == "sffix") { /* true fixed effect panel data model of Wang and Ho (2010) */

       if ("`ci'" ~= "") | ("`marginal'" ~= "") {
          di in red "The options of -ci- and -marginal- are not supported for the true-fixed effect model of Wang and Ho~(2010) ."
          error 198
       }

       sf_effindex $hj_syn
       exit
   }

   if ("`hjckmd'" == "syspf")  { /* profit system (share only), after sfsystem_profitshare */
        syspf_eff $hj_syn
        exit
   }

  if ("`hjckmd'" == "sysco") {  /* cost system (including main), after sfsystem */
        sysct_eff $hj_syn
        exit
  }

   if ("`hjckmd'" == "mle_C")  { /* SF panel using Chamberlain method, fixed and random effects */

       if ("`jlms'"~="") | ("`ci'" ~= "") | ("`marginal'" ~= "") {
           di in red "Currently this panel data model only supports the" in yel " bc " in red "option."
           if "`bc'" ~= "" {
              di in gre "Now proceed to compute the" in yel " bc " in gre "index."
           }
       }
       if "`bc'" ~= "" {
        sfpredict_Cham  $hj_syn
       }
        exit
   }

    if "`hjckmd'" == "cl_mi" {
      di in red "Inefficiency measures are not applicable to the classical mixture model."
      exit 198
    }

    if "`hjckmd'" ~= "sf_mi" { /* if not a mixture model */
      if "`nonweight'" ~= "" {
       di in red "The -nonweight- option is only availabel after estimating a mixture model."
       exit 198
      }
    }


    if "`hjckmd'" == "sf_mi" { /* a mixture model */
      if "`ci'" ~= "" {
        di in red "Confidence intervals are not yet available for the mixture model."
        error 198
      }
     ExpTE_m $hj_syn /* redirect the program */
     exit
    }


    if ("`hjckmd'" == "scost") { /* if cost system */
       local hjckmd2 = substr("`preest'",7,1)  /* check H or T type */
       local hjckmd3 = substr("`preest'",9,1)   /* Full, partial (null), or no (S) correlation */
    }
    else if (("`hjckmd'" == "sprd_") | ("`hjckmd'" == "spft_")) { /* if primal production system */
       if "$mufun2" == "" { /* the global is from prodsys.ado, and is non-empty for truncated normal */
            local hjckmd2 = "H"
       }
       else if "$mufun2" == "mu"{
            local hjckmd2 = "T"
       }
       else {
            di in red "Something wrong about the distribution identification of the production system model."
            exit 198
       }
       local hjckmd3  /* currently do not need the info */
    }
    else {
       local hjckmd2
       local hjckmd3
    }

   if   ("`preest'" != "sf_halfd") & ("`preest'" != "sf_half2") /*
    */ & ("`preest'" != "sf_trund") & ("`preest'" != "sf_trun2") /*
    */ & ("`preest'" != "sf_SWd") & ("`preest'" != "sf_SW2") /*
    */ & ("`preest'" != "sf_expo") & ("`hjckmd'" != "scost") & ("`hjckmd'" != "sprd_") & ("`hjckmd'" != "spft_")  {
         di in red "The calculation for " "`preest'" " was not supported."
         exit 198
    }


   if (("`bc'" == "") & ("`jlms'"=="")) {
       di in red "option of bc(newvarname), jlms(newvarname), or both are required"
       exit 198
   }


   if "`atmean'" ~= "" {
        di " "
        di in gre "All the effects are valuated at the mean values of the variables."
        di " "
        unab xxvar: $xvar /* otherwise has problem in bootstrap program */
        tokenize $yvar `xxvar' $zvar $wvar
        local ii = 1
        while "`1'"~= "" {
             local type: type `1'
             tempvar _jen`ii'
             quie gen `type' `_jen`ii'' = `1' if `touse'
             quie sum `1' if `touse', meanonly
             quie replace `1' = r(mean) if `touse'
             local ii = `ii' + 1
             mac shift
        }
   }


   if "`ci'" ~= "" { /* need to calculate the confidence interval */
     if `ci' > 1 {
       local ci = `ci'/100
     }
   }


   ******* deal with multiplier option *******

   if "`multiplier'" ~= "" { /* the option is specified */

      capture confirm number `multiplier'
      if _rc { /* means it's not a number */
          di in red "The -multiplier- option needs to take a numerical value or a local of numeric."
          error 198
      }

      if "`bc'" ~= "" {
          di in red "The -bc- option is invalid when -multiplier- is specified."
          di in red "That is, the -bc- measure does not have to be adjusted by"
          di in red "multiplier. You can either specify -bc- without the "
          di in red "-multiplier- optioin, or specify -jlms- with the -multiplier-"
          di in red "option."
          error 198
      }

     if $PorC == 2 { /* production frontier, the multiplier is 1 over r */
      global mult = 1/(`multiplier')
     }
     else if $PorC == 1 { /* production frontier, the multiplier is r */
      global mult = `multiplier'
     }
   }
   else { /* the option is not specified */
     global mult = 1
   }




********************
    tempname coe1
    tempvar mustar temxb temzd temsgv temsgv2 temsgw temsgw2 sigsta2 sigsta trunM
    tempvar fsterm seterm all1 mgef myb inecoe varcoe exp1 exp2 exp3 sigg compo1 temid
    tempvar muSWval c0val

    tempvar myrati  combi1 combi2 tmean asig _expus _varus alpha1 alpha2
    tempname _coe1 _coe12

/* ------ the frontier function -------------- */

    if (("`hjckmd'" == "sprd_") | ("`hjckmd'" == "spft_")) { /* system production function */
*       capture drop _front1c8 /*! new */
*       svmat double _front1c8m, names(_front1c8) /*! new */
*       quie gen double `temxb' = _front1c81 if `touse' /*! new */

*        if ("`hjckmd'" == "sprd_") {
             spft_sprd_post if `touse'
             quie gen double `temxb' = _front1c81 if `touse'
*        }

*        if ("`hjckmd'" == "spft_") {
*             di "not yet"
*             aaaaa
*        }


    }
    else {
       predict double `temxb'  if `touse', eq(frontier) xb
    }

/*  ------- The mean of the truncated distribution ---------- */


    if ("`preest'" == "sf_halfd") | ("`preest'" == "sf_half2") | /*
       */ ("`preest'" == "sf_expo") | ("`hjckmd2'"=="H") { /* half-normal and exponential */
      quie gen `temzd' = 0 if `touse'
      quie gen `trunM' = 0 if `touse'
    }
   else if ("`preest'" == "sf_trund") | ("`preest'" == "sf_trun2") | ("`hjckmd2'"=="T") { /* truncated normal */
      predict double `temzd'  if `touse', eq(mu) xb
      quie gen double `trunM' = ($mult)*(`temzd') if `touse'
   }
   else if ("`preest'" == "sf_SWd") | ("`preest'" == "sf_SW2") { /* SW model */
      predict double `temzd'  if `touse', eq(hscale) xb
      predict double `muSWval'  if `touse', eq(tau) xb
      quie gen double `trunM' = exp(ln($mult)+`temzd')*(`muSWval') if `touse' /*! if mult <0, does not work */
   }
   else {
      di in red "There is a problem. Look for chkpt1 in sf_predict.ado."
      exit 198
    }


   /* --- create temsgv2 for sigv2; the variance of the 2-sided normal --- */


      if ("`preest'" == "sf_halfd") | ("`preest'" == "sf_half2") /*
       */ | ("`preest'" == "sf_trund") | ("`preest'" == "sf_trun2") /*
       */ | ("`preest'" == "sf_expo") | ("`hjckmd'" == "sprd_") | ("`hjckmd'"=="spft_") /*
       */ |  ("`preest'" == "sf_SWd") | ("`preest'" == "sf_SW2") {  /* most models except SW */
          predict double `temsgv' if `touse', eq(vsigmas) xb
          quie gen double `temsgv2' = exp(`temsgv') if `touse'
      }
      else if ("`hjckmd'" == "scost") & ("`hjckmd3'" == "F") { /* system with full correlation */
          predict double `temsgv' if `touse', eq(s11) xb
          quie gen double `temsgv2' = exp(2* `temsgv') if `touse'
      }
      else if ("`hjckmd'" == "scost") & ("`hjckmd3'" ~= "F") { /* system with partial or no correlation */
          predict double `alpha1' if `touse', eq(gamma) xb
          predict double `alpha2' if `touse', eq(sigmauv) xb
          quie gen double `temsgv2' = exp(`alpha1' + 2*`alpha2')/(1 + exp(`alpha1')) if `touse'
      }
      else {
        di in red "There is a problem. Look for chkpt2 in sf_predict.ado."
        exit 198
      }



   /* --- create temsgw2 for sigw2; variance of the 1-sided normal --- */


      if ("`preest'" == "sf_halfd") | ("`preest'" == "sf_half2") /*
       */ | ("`preest'" == "sf_trund") | ("`preest'" == "sf_trun2") /*
       */ | ("`hjckmd'" == "sprd_") | ("`hjckmd'" == "spft_") { /* most models except SW and exponential */
          predict double `temsgw' if `touse', eq(usigmas) xb
          quie gen double `temsgw2' = exp( ln(($mult)^2) + `temsgw') if `touse'
      }
      else if ("`preest'" == "sf_expo") {
          predict double `temsgw' if `touse', eq(etas) xb
          quie gen double `temsgw2' = exp(ln(($mult)^2)+ `temsgw') if `touse'
      }
      else if ("`preest'" == "sf_SWd") | ("`preest'" == "sf_SW2") { /* SW models */
         predict double `c0val'  if `touse', eq(cu) xb
         quie gen double `temsgw2' = exp(`c0val'+ 2*`temzd') if `touse'
      }
      else if ("`hjckmd'" == "scost") & ("`hjckmd3'" == "F") { /* system with full correlation */
         predict double `temsgw' if `touse', eq(usigmas) xb
         quie gen double `temsgw2' = exp(ln(($mult)^2) + `temsgw') if `touse'
      }
      else if ("`hjckmd'" == "scost") & ("`hjckmd3'" ~= "F") { /* system with partial or no correlation */
          if $mult ~= 1 {
               di in red "The option -multiplier- is not feasible for this model."
               exit 198
          }
          quie gen double `temsgw2' = exp(2*`alpha2')/(1 + exp(`alpha1')) if `touse'
      }
      else {
        di in red "There is a problem. Look for chkpt3 in sf_predict.ado."
        exit 198
      }


/* --- create mu_star --- */

   quie gen double `mustar' = (( (`temsgv2')*(`trunM') - `temsgw2'*(`mydep' - `temxb') )/(`temsgv2' + `temsgw2')) if `touse'

if $PorC == 2 {
   quie replace `mustar' = (( (`temsgv2')*(`trunM') + `temsgw2'*(`mydep' - `temxb') )/(`temsgv2' + `temsgw2')) if `touse'
}

/* --- create sigma_star^2 --- */

   quie gen double `sigsta2' = ((`temsgv2'*`temsgw2')/(`temsgv2' + `temsgw2')) if `touse'
   quie gen double `sigsta'  = sqrt(`sigsta2') if `touse'


/* ---- modify if exponential distribution  --- */

if ("`preest'" == "sf_expo") { /* if it's exponential distribution */

   quie replace `mustar' = (- (`mydep' - `temxb') - `temsgv2'/sqrt(`temsgw2')) if `touse'
   quie replace `sigsta2' = (`temsgv2') if `touse'
   quie replace `sigsta'  = sqrt(`sigsta2') if `touse'

  if $PorC == 2 {
   quie replace `mustar' =  ((`mydep' - `temxb') - `temsgv2'/sqrt(`temsgw2')) if `touse'
   }

}


if "`bc'" ~= "" {

   tokenize "`bc'", parse(,)
   local bcvar = "`1'"  /* variable name */
   local tetype = "`3'" /* whether efficiency or inefficiency */

   if "`tetype'" == "" { /* if not specified, then it calculates efficiency by default */
     local tetype = "efficiency"
   }


   if $PorC == 1 { /* production frontier */
     if "`tetype'" == "efficiency"{
       quie gen double `bcvar' = exp(-(`mustar') + 0.5* `sigsta2')* /*
          */ normal(`mustar'/(`sigsta') - (`sigsta'))/ /*
          */ normal(`mustar'/(`sigsta')) if `touse'
       label var `bcvar' "tech efficiency index of E(exp(-u)|e)"
     }
     else if "`tetype'" == "inefficiency"{
       quie gen double `bcvar' = 1-(exp(-(`mustar') + 0.5* `sigsta2')* /*
          */ normal(`mustar'/(`sigsta') - (`sigsta'))/ /*
          */ normal(`mustar'/(`sigsta'))) if `touse'
       label var `bcvar' "tech inefficiency index of 1-E(exp(-u)|e)"
     }
     else {
      di  in red "You didn't specify -bc()- correctly."
      error 198
     }
   }

   if $PorC == 2 { /* cost frontier */
     if "`tetype'" == "efficiency"{
       quie gen double `bcvar' = exp(-(`mustar') + 0.5* `sigsta2')* /*
          */ normal(`mustar'/(`sigsta') - (`sigsta'))/ /*
          */ normal(`mustar'/(`sigsta')) if `touse'
       label var `bcvar' "tech efficiency index of E(exp(-u)|e)"
     }
     else if "`tetype'" == "inefficiency" { /* inefficiency */
       quie gen double `bcvar' = (exp((`mustar') + 0.5* `sigsta2')* /*
          */ normal(`mustar'/(`sigsta') + (`sigsta'))/ /*
          */ normal(`mustar'/(`sigsta'))) -1 if `touse'
      label var `bcvar' "tech inefficiency index of E(exp(u)|e)-1"
     }
     else {
      di  in red "You didn't specify -bc()- correctly."
      exit 198
     }
   }


 if "`ci'" ~= "" { /* need CI */
   local cia = `ci'*100 /* ex, 95 */
   local alp = 1-`ci' /* ex, 1-0.95 = 0.05 */

    quie gen double `bc'_`cia'U = exp(-(`mustar' + (invnorm( 1- (1-(`alp')/2)*normal((`mustar')/(`sigsta'))))*(`sigsta'))) if `touse'
    label var `bc'_`cia'U "upper bound of the `cia'% confidence interval of `bc'"

    quie gen double `bc'_`cia'L = exp(-(`mustar' + (invnorm( 1-((`alp')/2)*normal((`mustar')/(`sigsta'))))*(`sigsta'))) if `touse'
    label var `bc'_`cia'L "lower bound of the `cia'% confidence interval of `bc'"
  }

}


if "`jlms'" ~= "" {
   quie gen double `jlms' = ((`sigsta')*normalden((`mustar')/(`sigsta')))/(normal((`mustar')/(`sigsta'))) + `mustar' if `touse'
   label var `jlms' "conditional E(u|e)"

 if "`ci'" ~= "" { /* need CI */
   local cia = `ci'*100 /* ex, 95 */
   local alp = 1-`ci' /* ex, 1-0.95 = 0.05 */
   quie gen double `jlms'_`cia'L = `mustar' + (invnorm( 1- (1-(`alp')/2)*normal((`mustar')/(`sigsta'))))*(`sigsta') if `touse'
    label var `jlms'_`cia'L "lower bound of the `cia'% confidence interval of `jlms'"
   quie gen double `jlms'_`cia'U = `mustar' + (invnorm( 1-((`alp')/2)*normal((`mustar')/(`sigsta'))))*(`sigsta') if `touse'
    label var `jlms'_`cia'U "upper bound of the `cia'% confidence interval of `jlms'"
  }

}

/* ------------- calculate the tech cost and allo cost for primal models ------------- */


if (("`hjckmd'" == "sprd_") | ("`hjckmd'" == "spft_")) {

 getshare

}



/* ------------- whether to continue for marginal effects ------------ */

if ("`marginal'" ~= "") & ( ("`hjckmd'" == "scost") | ("`hjckmd'" == "sprd_") | ("`hjckmd'" == "spft_")) { /* no need to calculate marginal effects, or it is a system */
  di in gre "The marginal effect calculation is not supported for this model with systems of equations."
  exit
}


if ("`marginal'" == "")  { /* no need to calculate marginal effects, or it is a system */

  exit

}


if ("`preest'" == "sf_halfd") | ("`preest'" == "sf_half2") /*
     */ | ("`preest'" == "sf_trund") | ("`preest'" == "sf_trun2") /*
     */ | ("`preest'" == "sf_SWd") | ("`preest'" == "sf_SW2") | ("`preest'" == "sf_expo")  { /* half, truncated, and SW */

local halfno = 0

capture matrix drop `myb' `varcoe' `inecoe'
capture scalar drop dumy

matrix `myb' = e(b)

if ("`preest'" == "sf_trund") | ("`preest'" == "sf_trun2") { /* truncated normal */
   matrix `inecoe' = `myb'[1, "mu:"] /* ineff coe vector */
   matrix `inecoe' = `inecoe'*($mult)
   matrix `varcoe' = `myb'[1, "usigmas:"] /* variance coe vector */
   local nofine = colsof(`inecoe') /* # of ine var */
   local nofvar = colsof(`varcoe') /* # of variance var */
   matrix `varcoe'[1, `nofvar'] = `varcoe'[1, `nofvar']+ln(($mult)^2) /* for the variance expression exp(a + bZ), the multiplier makes it to exp(a + ln(r^2) + bZ) */
   local inevarn: coln `inecoe' /* var name of ine var */
   local varvarn: coln `varcoe' /* var name of variance var */

   if ((`nofine' == `nofvar') & ("`inevarn'" ~= "`varvarn'")) { /* same # of var but different vars; problematic */
      di in red "The program cannot calculate marginal effects if non-constant Z vector differs in the mu and the usigmas functions."
      exit 198
   }
   else if ((`nofine' > 1) & (`nofvar' == 1) & ("`varvarn'"=="_cons")) { /* no hetero in one-sided variance */
      scalar dumy = `varcoe'[1,1] /* the constant */
      matrix `varcoe' = J(1, `nofine', 0) /* a matrix of zero */
      matrix `varcoe'[1, `nofine'] = dumy /* replace the constant element */
      scalar hetero = 0
   }
   else if ((`nofine' == 1) & (`nofvar' > 1) & ("`inevarn'"=="_cons")) { /* no hetero in one-sided mean */
      scalar dumy = `inecoe'[1,1] /* the constant */
      matrix `inecoe' = J(1, `nofvar', 0) /* a matrix of zero */
      matrix `inecoe'[1, `nofvar'] = dumy /* replace the constant element */
      scalar hetero = 0
   }
   else {
      scalar hetero = 1
   }
}
else if ("`preest'" == "sf_halfd") | ("`preest'" == "sf_half2") { /* half normal */
   matrix `varcoe' = `myb'[1, "usigmas:"]
   local inevarn: coln `varcoe'
   local nofvar = colsof(`varcoe') /* # of variance var */
   matrix `varcoe'[1, `nofvar'] = `varcoe'[1, `nofvar']+ln(($mult)^2) /* for the variance expression exp(a + bZ), the multiplier makes it to exp(a + ln(r^2) + bZ). */
   matrix `inecoe' = J(1, `nofvar', 0) /* a vector of zero */
   scalar hetero = 0

   local varvarn: coln `varcoe' /* var name of variance var */
   if ("`varvarn'" == "_cons") &  (`nofvar' == 1) { /* half normal with no hetero var */
      local halfno = 1
   }
}
else if ("`preest'" == "sf_SWd") | ("`preest'" == "sf_SW2") { /* SW model */
   matrix `inecoe' = `myb'[1, "hscale:"] /* coeff vector of the hscale function */
   local nofine = colsof(`inecoe') /* # of vars */
   matrix `varcoe' = J(1, `nofine', 0) /* a dummy matrix to fool the program */
   local inevarn: coln `inecoe' /* var name of hscale var */
   local halfno = 0
}
else if ("`preest'" == "sf_expo") { /* exponential */
   matrix `inecoe' = `myb'[1, "etas:"] /* coeff vector of the eta function */
   local nofine = colsof(`inecoe') /* # of vars */
   matrix `varcoe' = J(1, `nofine', 0) /* a dummy matrix to fool the program */
   local inevarn: coln `inecoe' /* var name of eta var */
   local halfno = 0
}
else {
        di in red "There is a problem. Look for chkpt4 in sf_predict.ado."
        exit 198
      }

 /* The following is the marginal effect on unconditional E(u) based on FOC */


    di " "
    di "The following is the marginal effect on unconditional E(u)."
    di " "


     local ii = 1
     capture scalar `_coe1' = `inecoe'[1,`ii']
     capture scalar `_coe12' = `varcoe'[1,`ii']

    tokenize "`inevarn'"
    local thevar ``ii''


     while (`_coe1' != .) & (`halfno' ~= 1) & ("`thevar'"~="_cons") {

    if ("`preest'" == "sf_SWd") | ("`preest'" == "sf_SW2") { /* SW */
         quie gen double `myrati' = (`muSWval')/exp(0.5*`c0val') if `touse'
         quie gen double `_expus' =exp(0.5*`c0val')*(`myrati' + (normalden(`myrati'))/(normal(`myrati'))  ) if `touse' /* the E(U*) where U* is N^+(mu, sigma^2) */
         quie gen double `mgef' = (`_coe1')*exp(`temzd')*(`_expus') if `touse'
      }
    else if ("`preest'" == "sf_expo") { /* exponential */
         quie gen double `mgef' = 0.5*(`_coe1')*sqrt((`temsgw2')) if `touse'
    }
     else{ /* half, truncated */
          quie gen double `myrati' = (`trunM')/sqrt(`temsgw2') if `touse'
          quie gen double `fsterm' = normalden(`myrati')/normal(`myrati') if `touse'
          quie gen double `combi1' = `_coe1'*( 1 - (`myrati')*(`fsterm') - (`fsterm')^2) if `touse'
          quie gen double `combi2' = 0.5*(`_coe12')*( (sqrt(`temsgw2') + (`trunM')*(`myrati'))*(`fsterm') + (`trunM')*(`fsterm')^2) if `touse'
          quie gen double `mgef' = `combi1' + `combi2' if `touse'
     }
          quie egen double `tmean' = mean(`mgef') if `touse'
          capture drop `thevar'_M
          quie gen double `thevar'_M = `mgef' if `touse'
          label var `thevar'_M "the marginal effect of `thevar' on E(u)"

          quie gen `temid' = _n
          sort `tmean' /* so that it guarranteed to work even if "touse" may cause missings */
          di "The average marginal effect of `thevar' on uncond E(u) is " `tmean'[1] " (see `thevar'_M)."
          sort `temid'
          drop `temid'

      local ii = `ii' + 1

        foreach X in `myrati' `_expus' `mgef' `fsterm' `combi1' `combi2' `tmean' {
           capture drop `X'
        }

      scalar `_coe1' = `inecoe'[1,`ii']
      scalar `_coe12' = `varcoe'[1, `ii']

          tokenize "`inevarn'"
          local thevar ``ii''
     }

 /* The following is the marginal effect on unconditional V(u) based on FOC */


     local ii = 1
     capture scalar `_coe1' = `inecoe'[1,`ii']
     capture scalar `_coe12' = `varcoe'[1,`ii']


    di "  "
    di "The following is the marginal effect on uncond V(u)."
    di " "

    tokenize "`inevarn'"
    local thevar ``ii''

     while (`_coe1' != .) & (`halfno' ~= 1) & ("`thevar'"~= "_cons") {

      if ("`preest'" == "sf_SWd") | ("`preest'" == "sf_SW2") {
         quie gen double `myrati' = (`muSWval')/exp(0.5*`c0val') if `touse'
         quie gen double `fsterm' = normalden(`myrati')/normal(`myrati') if `touse'
         quie gen double `_varus' = exp(`c0val')*(1 - (`myrati')*(`fsterm') - (`fsterm')^2 ) if `touse' /* the V(U*) where U* is N^+(mu, sigma^2) */
         quie gen double `mgef' = 2*(`_coe1')* exp(2*(`temzd'))*(`_varus') if `touse'
      }
    else if ("`preest'" == "sf_expo") { /* exponential */
         quie gen double `mgef' = (`_coe1')*(`temsgw2') if `touse'
     }
      else {
          quie gen double `myrati' = (`trunM')/sqrt(`temsgw2') if `touse'
          quie gen double `fsterm' = normalden(`myrati')/normal(`myrati') if `touse'
          quie gen double  `asig' = sqrt(`temsgw2') if `touse'
          quie gen double `combi1' = (`fsterm')*((`trunM')^2 -(`temsgw2'))/(`asig') + (`fsterm')^2*3*(`trunM') + (`fsterm')^3*2*(`asig')  if `touse'
          quie gen double `combi2' = `temsgw2' - (`fsterm')*(((`temsgw2')*(`trunM') + (`trunM')^3)/(2*(`asig'))) - (`fsterm')^2*(`temsgw2' + 1.5*(`trunM')^2) - (`fsterm')^3*(`asig')*(`trunM')  if `touse'
          quie gen double `mgef' =  (`_coe1')*(`combi1') + (`_coe12')*(`combi2')  if `touse'
      }
          quie egen double `tmean' = mean(`mgef')  if `touse'
          capture drop `thevar'_V
          quie gen double `thevar'_V = `mgef'  if `touse'
          label var `thevar'_V "the marginal effect of `thevar' on V(u)"


          quie gen `temid' = _n
          sort `tmean'
          di "The average marginal effect of `thevar' on uncond V(u) is " `tmean'[1] " (see `thevar'_V)."
          sort `temid'
          drop `temid'

      local ii = `ii' + 1

        foreach X in `myrati' `fsterm' `_varus' `mgef' `myrati' `fsterm' `asig' `combi1' `combi2' `tmean'  {
           capture drop `X'
        }

      scalar `_coe1' = `inecoe'[1,`ii']
      scalar `_coe12' = `varcoe'[1, `ii']
      tokenize "`inevarn'"
      local thevar ``ii''
     }

}

else {
        di in red "There is a problem. Look for chkpt5 in sf_predict.ado."
        exit 198
}


*********************************************************

if "`atmean'" ~= "" {
        tokenize $yvar `xxvar' $zvar $wvar
        local ii = 1
        while "`1'" ~= "" {
           local var`ii' "`1'"
           local ii = `ii' + 1
           mac shift
        }
        local ii = `ii' -1
        while `ii' >= 1 {
             quie replace `var`ii'' = `_jen`ii'' if `touse'
             local ii = `ii' - 1
        }
}


**************

capture drop _front1c81 /*! new */ /* the variable from production system; no longer need */

end


capture program drop ETE_pan  /* for panel feature model */
program define ETE_pan

    version 8
    syntax [if] [in] , [BC(string) JLMS(string) CI(string) MARGinal ATMEAN MIXTURE NONWeight] /* LOGdep CONDition */

    global hj_syn "`0'" /* record the original input syntax for later use */

    marksample touse, nov


   if (("`bc'" == "") & ("`jlms'"=="")) {
       di in red "option of bc(newvarname), jlms(newvarname), or both are required"
       exit 198
   }



if "`jlms'" ~= "" {

   quie gen double `jlms' = (sqrt((_sigst2))*normalden((_musta)/(sqrt(_sigst2))))/(normal((_musta)/(sqrt(_sigst2)))) + _musta if `touse'

   tempvar tem1
   sort $pan_id
   quie by $pan_id: egen `tem1' = mean(`jlms')  if `touse'
   quie replace `jlms' = `tem1'  if `touse'
   label var `jlms' "conditional E(u_i|e)"

   quie sum _bt
   if r(mean) ~= 1 {
     quie gen double _`jlms' = `jlms'*(_bt)  if `touse'
     label var _`jlms' "conditional E(u_it|e) = E(B_t*u_i|e)"

     di " "
     di in yel "Note, both `jlms' and _`jlms' are created. The definitions are:"
     des `jlms' _`jlms'
   }

}





if "`bc'" ~= "" {

     if "$LeeSchmidt" ~= "" {
          di in red "The bc() option for this model (Lee Schmidt) is not supported yet."
          capture drop $extravar
          exit 198
     }

   tokenize "`bc'", parse(,)
   local bcvar = "`1'"  /* variable name */

   local tetype = "`3'"

     tempvar _tmp1 _tmp2

     sort $pan_id
     quie by $pan_id: egen double `_tmp1' = mean(_musta)
     quie replace _musta = `_tmp1'

     sort $pan_id
     quie by $pan_id: egen double `_tmp2' = mean(_sigst2)
     quie replace _sigst2 = `_tmp2'


 quie gen double `bc' = (normal(_musta/sqrt(_sigst2) - _bt*sqrt(_sigst2)  )/normal( _musta/sqrt(_sigst2) ))*exp(-_bt*_musta + 0.5*((_bt)^2)*_sigst2)

 label var `bc' "Tech efficiency index, E(exp(-u_{it})|e) = E(exp(-B_t*u_i) |e)"


}

capture drop $extravar

end
