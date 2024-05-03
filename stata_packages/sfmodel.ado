*! version 3.0 13Mar2017 
*! by Hung-Jen Wang
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw


capture program drop sfmodel
program define sfmodel

if c(stata_version) >= 11 & c(version) < 11 {

local ustata = c(version)

di in red "  ***************************************************"
di in gre "  Apparently you are running a recent version of Stata (version > 11)"
di in gre "  with the updated program of " in yel "sfmodel". in gre " Unlike the previous"
di in gre "  version of " in yel "sfmodel" in gre ", the updated one does not require a"
di in gre "  declaration of " in yel "version `ustata'". in gre " In fact, such a declaration"
di in gre "  would cause issues of incompatibility. If you wish to use the"
di in gre "  program, you should edit out the line "  in yel "version `ustata' " in gre "from your DO file."
di in red "  ***************************************************"

error 667
}


version 11


syntax varlist [if] [in], Distribution(string) FRONTIER(string) [COST PRODuction MU(passthru) MU2 /*
            */ USIGMAS(passthru) VSIGMAS(passthru) TECHnique(string)  /*
            */ ETAS(passthru) SCALing HSCALE(passthru)  TAU CU ROBust CLUSTER(passthru) SHOW NOMESSAGE]

global hj_syn "`0'" /* record the original input syntax for later use */

marksample touse

global cl_ster
global showM
global ML_user_hj

global tmp_ `usigmas'
chkpt
local usigmas "$tmp2_"
 *--------------------
global tmp_ `vsigmas'
chkpt
local vsigmas "$tmp2_"
 *-------------------
global tmp_ `mu'
chkpt
local mu "$tmp2_"
 *--------------------
global tmp_ `etas'
chkpt
local etas "$tmp2_"
 *--------------------
global tmp_ `hscale'
chkpt
local hscale "$tmp2_"
 *--------------------
global tmp_ `cluster'
chkpt
local cluster "$tmp2_"

/*  ------- about cluster --------- */

if "`cluster'" ~= "" {
 global cl_ster cluster(`cluster')
}

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

if ("`robust'" ~= "")  {  /* with -robust-, it can only be evaluated using lf0, thus mmethod=2 */
   local mmethod = 2
}
else if ("`thetech'" == "") | ("`thetech'" == "nr") { /* default, d2, NR */
   local mmethod = 1
}
else if ("`thetech'" == "dfp") | ("`thetech'" == "bfgs") | ("`thetech'" == "bhhh") {
   local mmethod = 2
}
else {
   di in red "You didn't specify the -technique- correctly."
   error 198
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
   local dist "exponential"
}
else {
   di in red "You didn't specify the -distribution()- option correctly."
   exit 198
}


/* ---------------------------------------------- */
/* -------- setting up the ml model ------------- */
/* ---------------------------------------------- */

/* --------- half normal ------------------------ */

if "`dist'" == "halfnormal" {

   syn_h $hj_syn  /* check syntax of half normal model */


   if `mmethod' == 1 { /* d2; NR (default); -robust- not allowed */
     ml model d2 sf_halfd (frontier: `varlist'=`frontier') (usigmas:`usigmas') (vsigmas:`vsigmas') if `touse', `robust' $cl_ster
     global showM ml model d2 sf_halfd (frontier: `varlist'=`frontier') (usigmas:`usigmas') (vsigmas:`vsigmas') if `touse', `robust' $cl_ster
     global ML_user_hj sf_halfd
   }
   if `mmethod' == 2 { /* lf0; dfp, bfgs, bhhh; also allows for -robust- */
     ml model lf0 sf_half2 (frontier: `varlist'=`frontier') (usigmas:`usigmas') (vsigmas:`vsigmas') if `touse', technique("`thetech'") `robust' $cl_ster
     global showM ml model lf0 sf_half2 (frontier: `varlist'=`frontier') (usigmas:`usigmas') (vsigmas:`vsigmas') if `touse', technique(`thetech') `robust' $cl_ster
     global ML_user_hj sf_half2
   }


}


/* ---------- truncated normal ------------------- */

if "`dist'" == "truncated" {

    /* ________ without scaling property ________ */

   if "`scaling'" == ""{

    if "`hscale'" ~= "" {
         di in red "With -hscale-, you have to specify -scaling- as well."
         exit 198
    }


    syn_t $hj_syn /* check syntax */

     if `mmethod' == 1 { /* d2; NR, default; -robust- not allowed */
       ml model d2 sf_trund (frontier: `varlist'=`frontier') (mu:`mu') (usigmas:`usigmas') (vsigmas:`vsigmas') if `touse', `robust' $cl_ster
       global showM ml model d2 sf_trund (frontier: `varlist'=`frontier') (mu:`mu') (usigmas:`usigmas') (vsigmas:`vsigmas') if `touse', `robust' $cl_ster
       global ML_user_hj sf_trund
     }
     if `mmethod' == 2 { /* lf0; bfgs, dfp, bhhh, also allows for -robust */
       ml model lf0 sf_trun2 (frontier: `varlist'=`frontier') (mu:`mu') (usigmas:`usigmas') (vsigmas:`vsigmas') if `touse', technique("`thetech'") `robust' $cl_ster
       global showM ml model lf0 sf_trun2 (frontier: `varlist'=`frontier') (mu:`mu') (usigmas:`usigmas') (vsigmas:`vsigmas') if `touse', technique(`thetech') `robust' $cl_ster
       global ML_user_hj sf_trun2
     }
    }

     /* _________ with scaling property __________ */

   if "`scaling'" ~= ""{

    syn_sw $hj_syn /* check syntax */

     if `mmethod' == 1 {
       ml model d2 sf_SWd (frontier: `varlist'=`frontier') (hscale:`hscale', nocons) /tau /cu (vsigmas:`vsigmas') if `touse', `robust' $cl_ster
       global showM ml model d2 sf_SWd (frontier: `varlist'=`frontier') (hscale:`hscale', nocons) /tau /cu (vsigmas:`vsigmas') if `touse', `robust' $cl_ster
       global ML_user_hj sf_SWd
     }
     if `mmethod' == 2 {
       ml model lf0 sf_SW2 (frontier: `varlist'=`frontier') (hscale:`hscale', nocons) /tau /cu (vsigmas:`vsigmas') if `touse', technique("`thetech'")  `robust' $cl_ster
       global showM ml model lf0 sf_SW2 (frontier: `varlist'=`frontier') (hscale:`hscale', nocons) /tau /cu (vsigmas:`vsigmas') if `touse', technique(`thetech')  `robust' $cl_ster
       global ML_user_hj sf_SW2
     }

   }

}

/* ------------- exponential -------------------- */

if "`dist'" == "exponential" {

   syn_e $hj_syn /* check syntax */

      ml model lf0 sf_expo (frontier: `varlist'=`frontier') (etas:`etas') (vsigmas:`vsigmas') if `touse', technique("`thetech'")  `robust' $cl_ster
      global showM  ml model lf0 sf_expo (frontier: `varlist'=`frontier') (etas:`etas') (vsigmas:`vsigmas') if `touse',  technique(`thetech') `robust' $cl_ster
      global ML_user_hj sf_expo
}

if "`show'" ~= "" {
 di " "
 di in gre "  *** The sfmodel sets up the following model for ML estimation.***
 di "$showM"
 di " "
}


end


/* --------------------------------------------------- */
/* -- programs to check the syntax of different models -- */


capture program drop syn_h
program define syn_h
   syntax varlist [if] [in], Distribution(string) FRONTIER(string) [USIGMAS(passthru) VSIGMAS(passthru) COST PRODuction TECHnique(string) ROBust CLUSTER(passthru) SHOW NOMESSAGE]
end

capture program drop syn_t
program define syn_t
   syntax varlist [if] [in], Distribution(string) FRONTIER(string) [MU(passthru) MU2 USIGMAS(passthru) VSIGMAS(passthru) COST PRODuction TECHnique(string) ROBust CLUSTER(passthru) SHOW NOMESSAGE]
end


capture program drop syn_e
program define syn_e
   syntax varlist [if] [in], Distribution(string) FRONTIER(string) [ETAS(passthru) VSIGMAS(passthru) COST PRODuction TECHnique(string) ROBust CLUSTER(passthru) SHOW NOMESSAGE]
end

capture program drop syn_sw
program define syn_sw
   syntax varlist [if] [in], Distribution(string) SCALing FRONTIER(string) HSCALE(string) TAU CU [COST PRODuction VSIGMAS(passthru) TECHnique(string) ROBust CLUSTER(passthru) SHOW NOMESSAGE]
   if ("`distribution'"~= "t") & ("`distribution'" ~= "truncated") {
     di in red "With -scaling- option, the -distribution- must be t or truncated."
     exit 198
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

  global tmp_

end
