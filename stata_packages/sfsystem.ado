*! version 3.0 13Mar2017 
*! by Hung-Jen Wang
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw


capture program drop sfsystem
program define sfsystem

version 11
syntax varlist [if] [in], Distribution(string) FRONTIER(string) SHARE1(string) /*
                  */ CORR(string) CONSTRAINTS(string) [COST PROFIT GAMMA SIGMAUV USIGMAS SHARE2(string) /*
                  */ SHARE3(string) SHARE4(string) S11 S22 S33 S44 S21 S31 S32 S41 /*
                  */ S42 S43 MU(string) /* LARGE */ SHOW NOMESSAGE TECHnique(string)]

global hj_syn "`0'" /* record the original input syntax for later use */

marksample touse

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

global PorC = "Correct PorC Specification" /* offset previous values, so that errors are issued if a proper value is not given */

if "`profit'" ~= ""{
   global PorC = 1
}
else if "`cost'" ~= "" {
   global PorC = 2
}
else {
     /* default */
   global PorC = 2
}



/* --------------------------------------------------- */



foreach X in s11 s22 s33 s44 s21 s31 s32 s41 s42 s43 { /* in default, all are there */
   global `X' /`X'
}

global pghd  /* name of ADO program; nullify */
global hjmu  /* mu equation holder */
global sigmw /* the sigma_u^2 parameter in the model with full correlations */
global gamaetc /* the gamma and sigmauv in the models other than full correlations */
global shrado
global etaado
global ML_user_hj

/* ------- create macro for share equations ------- */


global shr1 (share1: `share1') /* nullify later if not needed */
global shr2 (share2: `share2')
global shr3 (share3: `share3')
global shr4 (share4: `share4')


/* -------- check for general errors ------- */

if ("`share4'" ~= "") & ("`corr'" == "full") {
     di in red "The program can have only up to 3 share equations (4 inputs)."
     di in red "So you cannot specify share4() equation."
     exit 198
   }


if (("`distribution'" == "h") | ("`distribution'" == "halfnormal") ) & ("`mu'" ~= "") {
   di in red "-mu()- cannot be specified for a half-normal model."
   exit 198
}



/* -------- get the number of equations ------------ */


if "`share4'" ~= "" { /* 4 share eqns */
   local nofs = 4
}
else if "`share3'" ~= ""{ /* 3 share eqns */
   local nofs = 3
   foreach X in  s44 s41 s42 s43 shr4 { /* nullify cov element regarding the 4th eqn */
    global `X'
   }
}
else if "`share2'" ~= ""{ /* 2 share eqns */
   local nofs = 2
   foreach X in s41 s42 s43 s44 s31 s32 s33 shr3 shr4 { /* nullify cov element regarding the 3rd and 4th eqn */
    global `X'
   }
}
else if "`share1'" ~= ""{ /* 1 share eqn */
   local nofs = 1
   foreach X in s41 s42 s43 s44 s31 s32 s33 s21 s22 shr2 shr3 shr4 { /* nullify cov element regarding the 2nd, 3rd, and 4th eqn */
    global `X'
   }
}
else {
   di in red "You didn't specify the share equation options correctly."
   exit 198
}


/* ------ retrieve the distribution assumption ------- */


if "`distribution'" == "" {
   di in red "You need to specifiy a distributional assumption in -distribution()-."
   exit 198
}


 if ("`distribution'" == "h") | ("`distribution'" == "halfnormal") {

    local dist "halfnormal"
    global pghd H
 }
 else if ("`distribution'" == "t") | ("`distribution'" == "truncated") {

    local dist "truncated"
    global pghd T
 }
 else {
    di in red "You didn't specification the -distribution()- option correctly."
    exit 198
 }



/* -------- retrieve the correlation assumption ------- */

   global sigmw /usigmas

if ("`corr'" == "partial") & (`nofs' == 1) {
      di in red "You cannot have corr=partial while has only one share equation."
      di in red "Need more than 1 share equation in order to allow corr=partial."
      di in red "Try using corr=no or corr=full."
      exit 198
}

local elem1 s11 s22 s33 s44 /* for no corr */
local elem2 s32 s42 s43
local elem3 s21 s31 s41


if "`corr'" == "no" {
 global covelmado `elem1'
 global scmtype = 1
}
else if "`corr'" == "partial" {
 global covelmado `elem1' `elem2'
 global scmtype = 2
}
else if "`corr'" == "full" {
 global covelmado `elem1' `elem2' `elem3'
 global scmtype = 3
}
else {
   di in red "You didn't specification the -corr()- option correctly."
   di in red "The admissibles are 'no', 'partial', or 'full'."
   exit 198
}

if `nofs' == 1 {    /* 1 main + 1 share */
  forvalues i = 3/4 { /* nullify some of the elements */
    forvalues j = 1/4 {
      capture global covelmado = subinstr("$covelmado", "s`i'`j'", "", .)
    }
  }
}

if `nofs' == 2 {    /* 1 main + 2 share */
  forvalues i = 4/4 {
    forvalues j=1/4 {
      capture global covelmado = subinstr("$covelmado", "s`i'`j'", "", .)
    }
  }
}



/* ---------- put together the covariance elements --------- */


global covelm

foreach X in $covelmado {
 global covelm $covelm /`X'
}

/* ---------- get the mu equation ------------ */

if "`dist'" == "halfnormal" {
   global hjmu
}
if "`dist'" == "truncated" {
   global hjmu (mu: `mu')
}

/* ----------- get the share macro for ado -------- */

forvalues i=1/3 { /* the updated program can have only up to 3 shares (i.e., 4 inputs) for all full, partial, and no models */
 if "${shr`i'}" ~= "" {
    global shrado $shrado share`i'
    global etaado $etaado eta`i'
 }
}


/* ---------------------------------------------- */
/* -------- setting up the ml model ------------- */
/* ---------------------------------------------- */


ml model lf syscost${pghd} (frontier: `varlist' = `frontier') $shr1 $shr2 $shr3 $shr4 /*
   */ $sigmw $covelm $hjmu if `touse', constraints(`constraints') technique(`technique')
global showM "ml model lf syscost${pghd} (frontier: `varlist' = `frontier') $shr1 $shr2 $shr3 $shr4 $sigmw $covelm $hjmu if `touse', constraints(`constraints') technique(`technique')"
global ML_user_hj syscost${pghd}


if "`show'" ~= "" {
 di " "
 di in gre "  *** The sfsystem sets up the following model for ML estimation.***
 di "$showM"
 di " "
}



end


capture program drop syn_h
program define syn_h

syntax varlist [if] [in], Distribution(string) FRONTIER(string) SHARE1(string) /*
                  */ CORR(string) CONSTRAINTS(string) [GAMMA SIGMAUV SHARE2(string) /*
                  */ SHARE3(string) SHARE4(string) S11 S22 S33 S44 S21 S31 S32 S41 /*
                  */ S42 S43 LARGE COST PROFIT SHOW NOMESSAGE]
end

capture program drop syn_t
program define syn_t

syntax varlist [if] [in], Distribution(string) FRONTIER(string) SHARE1(string) /*
                  */ CORR(string) CONSTRAINTS(string) MU(string) [GAMMA SIGMAUV SHARE2(string) /*
                  */ SHARE3(string) SHARE4(string) S11 S22 S33 S44 S21 S31 S32 S41 /*
                  */ S42 S43 LARGE COST PROFIT SHOW NOMESSAGE]
end

   /* for models with full correlation */
capture program drop syn_hf
program define syn_hf

syntax varlist [if] [in], Distribution(string) FRONTIER(string) SHARE1(string) /*
                  */ CORR(string) CONSTRAINTS(string) [USIGMAS SHARE2(string) /*
                  */ SHARE3(string) SHARE4(string) S11 S22 S33 S44 S21 S31 S32 S41 /*
                  */ S42 S43 LARGE COST PROFIT SHOW NOMESSAGE]
end

capture program drop syn_tf
program define syn_tf

syntax varlist [if] [in], Distribution(string) FRONTIER(string) SHARE1(string) /*
                  */ CORR(string) CONSTRAINTS(string) MU(string) [USIGMAS SHARE2(string) /*
                  */ SHARE3(string) SHARE4(string) S11 S22 S33 S44 S21 S31 S32 S41 /*
                  */ S42 S43 LARGE COST PROFIT SHOW NOMESSAGE]
end
