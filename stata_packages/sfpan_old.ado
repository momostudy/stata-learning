*! version 3.0 13Mar2017 
*! by Hung-Jen Wang
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw


capture program drop sfpan_old
program define sfpan_old


version 8
syntax varlist [if] [in], Distribution(string) FRONTIER(string)   ///
             [COST PRODuction MU(string) MU2 TECHnique(string) ROBust CLUSTER(passthru) ///
              I(string) /* T(string) */ USIGMAS(passthru) USIGMAS2  VSIGMAS2 VSIGMAS(passthru) ///
               GAMMA(string)  FIXed NOCHECK KUMBhakar INVariant ///
               TRUERANdom ID(varlist) TIME(varlist) Eta(real 1) GH(real 1) NODES(real 64) ///
               DROPMissing SHOW NOMESSAGE OLD]


global hj_syn "`0'" /* record the original input syntax for later use */

marksample touse

if "`truerandom'" ~= "" {
 *!  sfpanel_Cham $hj_syn
 *!  exit
  di in red "The -truerandom- option is currently unavailable."
  exit
}

/* ------------- message --------- */

if "`nomessage'" == "" {
di in red "  ***************************************************"
di in gre "    If you encounter error messages of" in red " model not defined " in green "or" in red " invalid syntax"
di in gre "    when executing this or the following" in yel " ml max " in gre "command, see the instruction in
di in yel "      https://sites.google.com/site/sfbook2014/home/version-control-issue"
di in gre "    to debug. You may turn off this message by adding the option -nomessage-.
di in red "  ****************************************************"
}


/* ------ checking the distribution assumption ------- */

if "`distribution'" == " " {
   di in red "You need to specifiy a distributional assumption in -distribution()-."
   error 198
}

if ("`distribution'" == "h") | ("`distribution'" == "halfnormal") {
   local dist "halfnormal"
}
else if ("`distribution'" == "t") | ("`distribution'" == "truncated") {
   local dist "truncated"
}
else if ("`distribution'" == "e") | ("`distribution'" == "exponential") {
   di in red "The exponential distribution of u is not avaiable for this model."
   error 198
}
else {
   di in red "You didn't specify the -distribution()- option correctly."
   exit 198
}


local countM = 0



/* ----- whether the Kumbhakar model ----- */

global Kumbhakar
if "`kumbhakar'"~= "" {
     if "`gamma'" == "" {
          di in red "You need to specifiy the -gamma()- option."
          error 198
     }
    global Kumbhakar = 1
    local countM = `countM' + 1


}

* ------ whether the time-invariant random effect MLE model ---- */

global invariant
if "`invariant'" ~= "" {

  if "`gamma'" ~= "" {
   di in red "The -gamma- option cannot be used together with the -invariant- option."
  }

   global invariant = 1
   local countM = `countM' + 1
}

/* --- check for wrong combination ----- */

if `countM' >= 2 {
    di in red "You can specifiy only one of the following options: -Kumbhakar-, -invariant-."
    error 198
}


if `countM' == 0 { /* i.e., the default, which is the decay type model */
  if "`gamma'" == "" {
    di in red "The -gamma()- option needs to be specified (unless -invariant- is specified).
    error 198
  }
}


/*  ------- about cluster --------- */

if "`cluster'" ~= "" {
 global cl_ster cluster(`cluster')
}

/*  ------- identify i and t ------- */

global pan_id /* nullify */
global tis


global pan_id : char _dta[iis] /* first, assuming it is from iis */

if ("`i'"=="") {
     if ("$pan_id"=="") {
          di in red "You didn't specifiy the variable identifying the panel."
          di in red "Use -i()- as an option in sfpatt or use Stata's -iis- command."
          error 198
     }
}
else {
     global pan_id `i' /* overwrite the previous iis by variable in -i()-. */
}



/* ----- check production or cost function -------- */

global PorC = "Correct PorC Specification"

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


/* --------- the maximization technique ------------ */

local thetech = lower("`technique'") /* change to lower cases */

if ("`thetech'" == "") | ("`thetech'" == "nr") { /* default, d2, NR */
   local mmethod = 1
}
else if ("`thetech'" == "dfp") | ("`thetech'" == "bfgs") | ("`thetech'" == "bhhh") {
   local mmethod = 2
}
else {
   di in red "You didn't specify the -technique- correctly."
   error 198
}


/* ------ the mu function ------------- */

global mufun  /* nullify  */
global mufun2

if "`dist'" == "truncated" {
     global mufun (mu:`mu')
     global mufun2 mu
}

/* ------ the gamma function ------------- */

global gamfun  /* nullify  */
global gamfun2

if "`gamma'" ~= "" {
     global gamfun (gamma:`gamma')
     global gamfun2 gamma
}



/* ---- whether including the fixed effects ---------- */

global extravar _musta _sigst2 _bt
global fixed = 0
global conss

if "`fixed'" ~= "" {

 global tmp_ `frontier'
 getvv
 local fronV "$tmp2_"
 *---------
 global tmp_ `gamma'
 getvv
 local gammV "$tmp2_"
 *---------
 global tmp_ `mu'
 getvv
 local muV "$tmp2_"
  *---------
 global tmp_ `usigmas'
 getvvv
 local usigV "$tmp2_"
 local usigmas `usigV'
  *---------
 global tmp_ `vsigmas'
 getvvv
 local vsigV "$tmp2_"
 local vsigmas `vsigV'


 global fixed = 1
 global conss , nocons
 quie reg `varlist' `fronV' `gammV' `muV' `usigV' `vsigV' if `touse'

 local ii = 1
 foreach X of varlist `varlist' `fronV' {
   capture drop `_tmp1'
   tempvar _tmp1
   sort $pan_id
   quie by $pan_id: egen double `_tmp1' = mean(`X') if e(sample)
   capture drop `X'_9
   quie gen double `X'_9 = `X' - `_tmp1' if e(sample)

   global extravar $extravar "`X'_9"

   if `ii' == 1 { /* the dependent variable */
     local varM `X'_9
   }
   if `ii' > 1 { /* the list of independent variables */
     local fronM `fronM' `X'_9
   }

   local ii = `ii' + 1

 }

 local varlist `varM'    /* give them the newer lists */
 local frontier "`fronM'"


}


/* ----  check whether the vars in usigmas and vsigmas are time invariant ----- */
         * Need to restrict the estimation sample, and the following algorithm could still be problematic.



if "`nocheck'"==""{ /* go ahead to check */

 /* get the true list of variables, get rid of -nocon- and other options */
 global tmp_ `frontier'
 getvv
 local fronV "$tmp2_"
 *---------
 global tmp_ `gamma'
 getvv
 local gammV "$tmp2_"
 *---------
 global tmp_ `mu'
 getvv
 local muV "$tmp2_"
  *---------
 global tmp_ `usigmas'
 getvvv
 local usigV "$tmp2_"
 local usigmas `usigV'
  *---------
 global tmp_ `vsigmas'
 getvvv
 local vsigV "$tmp2_"
 local vsigmas `vsigV'


 quie reg `varlist' `fronV' `gammV' `muV' `usigV' `vsigV' if `touse' /* in order to get estimation sample */

   if "`usigmas'" ~= "" { /* contains some variables, so check */
       chkinva `usigV' if e(sample)
   }
   if "`mu'" ~= "" {
        chkinva `mu' if e(sample)
   }


}



/* ---------------------------------------------- */
/* -------- setting up the ml model ------------- */
/* ---------------------------------------------- */



local checkvar `varlist' `frontier' `mu' `usigmas' `vsigmas' `gamma' $pan_id

local checkvar2 =  subinstr("`checkvar'", "noconstant", "", .)
local checkvar3 =  subinstr("`checkvar2'", "nocons", "", .)
local checkvar4 =  subinstr("`checkvar3'", ",", "", .)


if "`dropmissing'" ~= "" {
  tempvar ha1
  findmis `checkvar4', gen(`ha1')
  drop if `ha1' == 1
}
else {
  tempvar ha1
  findmis `checkvar4', gen(`ha1')
  quie sum `ha1'
  if r(mean) ~= 0 {
     di in red "Some observations contain missing values in the regression variables."
     di in red "The estimation of technical inefficiency will not work correctly if"
     di in red "observations have missing values."
     di in red "You may specify -dropmissing- option so that the program will drop"
     di in red "those observations for you."
     error 198
  }
}



/* --------- half normal ------------------------ */


ml model d0 sf_pan2 (frontier: `varlist'=`frontier' $conss)  $mufun $gamfun (usigmas:`usigmas') (vsigmas:`vsigmas')  if `touse', `robust' $cl_ster technique("`thetech'")

global showM ml model d0 sf_pan2 (frontier: `varlist'=`frontier' $conss) $mufun $gamfun (usigmas:`usigmas') (vsigmas:`vsigmas') if `touse', `robust' $cl_ster technique("`thetech'")

if "`show'" ~= "" {
 di " "
 di in gre "  *** The sfpan sets up the following model for ML estimation.***
 di "$showM"
 di " "
}


end


/* ---------- program to deal with the passthru option field ------------ */

capture program drop chkpt /* needed because of the compatibility with V6 */
program define chkpt

  global tmp2_ /* fresh piece */

  tokenize "$tmp_", parse("()")

  if "`3'" ~= ")"{
     global tmp2_ `3'
  }

  global tmp_ /* flush away previous value */

end


capture program drop chkinva /* check whether the variables are time-invariant within cross-sections */
program define chkinva

  syntax varlist [if] [in]
  marksample use2

  tokenize `varlist'
  while "`1'" ~= "" {
    tempvar tm1a tm2a
    sort $pan_id
    quie by $pan_id: egen double `tm1a' = mean(`1') if `use2'
    quie gen double `tm2a' = `tm1a' - `1' if `use2'
    quie sum `tm2a' if `use2'
    if r(max) > 10e-6 {
      di in red "The variable `1' is not time-invariant within one or more of the"
      di in red "cross-sections, therefore it cannot be used to parameterize"
      di in red "mu, usigmas, and vsigmas in this panel data model."
      error 198
    }
    capture drop `tm1a'
    mac shift
  }

end

capture program drop getvv /* get vars and purge out the nocons thing */
program define getvv


  global tmp2_ /* fresh piece */

  tokenize "$tmp_", parse(,) /* cannot contain space as a delimiter, since varlist can contain spaces */

  global tmp2_ `1'

  global tmp_ /* flush away previous value */

end


capture program drop getvvv /* get vars and purge out the nocons thing */
program define getvvv


  global tmp2_ /* fresh piece */

  tokenize "$tmp_", parse(,()) /* cannot contain space as a delimiter, since varlist can contain spaces */

  global tmp2_ `3'

  global tmp_ /* flush away previous value */

end
