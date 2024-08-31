*! version 3.0 13Mar2017 
*! by Hung-Jen Wang
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw


capture program drop sfsystem_profitshares
program define sfsystem_profitshares


version 11


syntax [if] [in], OUTPUT(varlist) INPUTs(varlist) PRICEs(varlist)  YPrice(varlist) ///
   [ Distribution(string)  /* SYSERROR LINEAR(string) */ USIGMAS(string) MU(string) CD  NOASK  ///
   TECHnique(string) CLASSical /* PROFit */ SHOW NOMESSAGE]

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

 ***** this block preceeds everything ****
global v_price
global v_input
global v_input0
global v_input1
global v_input2
global PD_search
global CDorTL
global sqrterm
global sqrterm2
global intterm
global intterm2
global tlmean
global funlist
global alist
global ninput
global mufun
global mufun2
global showM
global mltrick
global sterm /* the elements of var-cov matrix */
global sterm1 /* to be used in the ML function */
global syserror /* whether there is systmatic error in the FOC */
global concen /* whether concentrate the variance covariance matrix */
global tech /* optimization method */
global dep0z  /* for "getshare.ado" */
global usigterm
global usigterm1
global isClass
global pgm
global nofvvar
global f_input
global vput
global thelist
global fullTL

mac drop x_c*
mac drop w_c*
mac drop yp

global PorC = 1
global dep0z `output'


 ***** setup important parameters ******


if "`cd'" ~= "" {
   global CDorTL = 1
}
else {
   global CDorTL = 2
}



* ----------------------------

if "`classical'" == ""{ /* not a classical model */
     global isClass = 0
}
else { /* a classical model */
     global isClass = 1
}


if "`technique'" == ""{
     global tech
}
else {
     global tech , technique(`technique')
}


************ check the distribution about u ************


if ("`distribution'" == "") & ("`classical'"=="")  {
   di in red "You need to specifiy a distributional assumption about technical"
   di in red "inefficiency in -distribution()-. Admissibles are truncated and halfnormal."
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
else if ("`classical'" == "") {
   di in red "You didn't specify the -distribution()- option correctly."
   di in red "Only " in yel "halfnormal " in red "and " in yel "truncated " in red "normal are allowed."
   exit 198
}


*********** get the output price ******************

local nofyp: word count `yprice'
if `nofyp' ~= 1 {
     di in red "You have to specify 1 and only 1 output price in -yprice()-."
     exit 198
}

global yp `yprice'
local ypname `yprice'

 /* ----- deal with input prices; normalize them by output price ---------- */

tokenize `prices'
local jj = 1
while "`1'"~=""{
     capture drop w_c`jj'
     quie gen double w_c`jj' = `1' - $yp /* normalize the input price by output price. both in log, so take difference */
     global w_c`jj' w_c`jj'
     global v_price $v_price `1'
     local jj = `jj' + 1
     mac shift
}


/* ------ create a list for later process --------- */

capture unab inputs: `inputs'
local ninput: word count `inputs' /* the number of total inputs */
global ninput = `ninput' /* to be used in MLE function */

capture unab prices: `prices'
local nofvvar: word count `prices'
global nofvvar = `nofvvar'
local noffoc = `nofvvar'

local ii = 1
tokenize `inputs'
while "`1'"~= ""{

   if `ii' <= `nofvvar' {
    global vput $vput `1'
    }
   else if `ii' > `nofvvar' {
      local quasi `quasi' `1'
   }
   local ii = `ii' + 1
   mac shift
}

local thelist `prices' `quasi'
global thelist `thelist' /* to be used in getxb.ado */


/* ---- create a full list of variable specification ------ */

if $CDorTL == 1 {

global fullTL `thelist'

}


if $CDorTL == 2 {

tokenize `thelist'

local ii = 1
while `ii' <= `ninput' {
     local n_`ii' "`1'"
     local ii = `ii' + 1
     mac shift
}

forvalues ii = 1/`ninput' { /* 1st order term */
     global fullTL $fullTL `n_`ii''
}
forvalues ii = 1/`ninput' { /* square term */
     global fullTL $fullTL `n_`ii''`n_`ii''
}

local ii = 1
while `ii' <= `ninput' {

     local jj = `ii' + 1

     while `jj' <= `ninput' {
       global fullTL $fullTL `n_`ii''`n_`jj''
       local jj = `jj' + 1
     }

     local ii = `ii' + 1
}

}

 /* ---------- deal with inputs -------- */

tokenize `thelist' /* a list of prices and quasi-fixed quantities */
local ii = 1
while "`1'"~= ""{

     global x_c`ii'  `1' /* the inputs variable */
     local _xn`ii' `1' /* take variable name for later use */

     if `ii' <= `nofvvar' { /* accumulating the list of variable inputs */
       global v_input $v_input `1'
     }
     if `ii' > `nofvvar' { /* accumulating the list of quasi fixed inputs */
       global f_input $f_input `1'
     }
     global v_input1 $v_input1 `1' /* accumulating the list of all inputs */

   if `ii' == 1 {
     global v_input0 (`1': `output'=)

   }
   else if `ii' <= `nofvvar' {
     global v_input2 $v_input2 (`1':)
   }
     local ii = `ii' + 1
     mac shift
}


if $CDorTL == 2 { /* higher order terms for the translog function */

local ii = 1
while `ii' <= `nofvvar' {  /* accumulating square terms */
     local temp `_xn`ii''
     global sqrterm $sqrterm `temp'`temp'
     global sqrterm2 $sqrterm2 (`temp'`temp':)

     local ii = `ii' + 1
}

local ii = 1
while `ii'<= `nofvvar' { /* accumulating interaction terms */
     local temp `_xn`ii''
     local jj = `ii' + 1
     while `jj' <= `ninput' {
          local temp1 `_xn`jj''
          global intterm $intterm `temp'`temp1'
          global intterm2 $intterm2 (`temp'`temp1':)

          local jj = `jj' + 1
     }
     local ii = `ii' + 1
}

}


/* ------- re-take the quantity variables to make the x_c variables right ------ */


tokenize `inputs' /* what if they use lnx* ? */
local ii = 1
while "`1'"~= ""{
     global x_c`ii'  `1' /* the inputs variable */
     local _xn`ii' `1' /* take variable name for later use */

     local ii = `ii' + 1
     mac shift
}




 /* ---- creating the list to be used inside the ML function ----- */


local ii = 1
while `ii' <= `nofvvar' { /* cumulating the main terms */
     global alist $alist a`ii'
     local ii = `ii' + 1
}

if $CDorTL == 2 {
local ii = 1
while `ii' <= `nofvvar' { /*cumulating the square terms */
     global alist $alist a`ii'`ii'
     local ii = `ii' + 1
}
local ii = 1
while `ii' <= `nofvvar' { /* cumulating the interaction terms */
     local jj = `ii'+1
     while `jj' <= `ninput' {
        global alist $alist a`ii'`jj'
        local jj = `jj' + 1
     }
     local ii = `ii' + 1
}
}


  /* ---  dealing with the possible var-cov matrix elements ---- */


forvalues ii = 1/`nofvvar' { /* the square term */
     global sterm $sterm /s`ii'`ii'
     global sterm1 $sterm1 s`ii'`ii'
}


local ii = 2
while `ii' < = `nofvvar' {
  local jj = 1
  while `jj' < `ii' {
     global sterm $sterm /s`ii'`jj'
     global sterm1 $sterm1 s`ii'`jj'
     local jj = `jj' + 1
  }
  local ii = `ii' + 1
}



       /* building the search list */
global PD_search $v_input  $sqrterm $intterm /* note, the order is important */
       /* building the ML function list */
global funlist $v_input0 $v_input2 $sqrterm2 $intterm2 /* again, the order is important */

 /* ----- get the mu function ------------ */

if ("`dist'" == "truncated") & ($isClass == 1) {
   di in red "With -classical- option, there is no inefficiency in the model,"
   di in red "  so -dist()- is ignored."
}


if ("`dist'" == "halfnormal") & ($isClass == 1) {
   di in red "With -classical- option, there is no inefficiency in the model,"
   di in red "  so -dist()- is ignored."
}

if ("`dist'" == "exponential") & ($isClass == 1) {
   di in red "With -classical- option, there is no inefficiency in the model,"
   di in red "  so -dist()- is ignored."
}


if ("`dist'" =="truncated") & ($isClass == 0) { /* truncated distribution */
     global mufun (mu:`mu')
     global mufun2 mu /* to be used in the ML ado and also sf_predict */
}





************* then call the ML routine

***** print confirmation message *****


di " "
di in yel "-------------- Confirmation Message ----------------"
di " "
di in gre "(1) This model estimates the profit maximization behavior"
di in gre "    using share equations based on Kumbhakar (2001)."
di " "
di in gre "(2) The variable inputs' log prices are"
di in yel "    $v_price,"
di in gre "    with the corresponding log quantities being "
di in yel "    $vput;"
di in gre "    the log of quasi-fixed inputs (if any) are "
di in yel "    $f_input,"
di in gre "    and the price of output is"
di in yel "    $yp."
di " "
di in gre "(3) The full variable specification of the profit function"
di in gre "    contains the following variables:"
di in yel "    $fullTL."
if ("$f_input"~="") {
di in gre "    However, the FOC-based system profit model only estiamtes"
di in gre "    coefficients of the following variables:"
di in yel "    $PD_search."
di in gre "    That is, coefficients of the quasi-fiexed inputs ($f_input)"
di in gre "    and their square terms (if a translog model) are not estimated"
di in gre "    in this FOC-based system model, although they may be recovered"
di in gre "    after the estimation."
}
else {
di in gre "    These are also the variables included in the share equations.
}
if ($CDorTL == 1)  {
di in red "(4) You specified a Cobb-Douglas function, which will not"
di in red "    include the quasi-fixed input (if any) in the estimation,"
di in red "     and also that the model can not include the inefficiency effect."
}
if ($CDorTL == 2) & ($isClass==1) {
di in red "(4) You specified the -classical- option, so the model does not"
di in red "    include the inefficiency effect."
}
di " "
di " "
if "`noask'"==""{
pause on
di in yel "Press q to continue. (To turn off the confirmation prompt, specify the -noask- option in prodsys.)"
pause
pause off
}



********* whether has usigmas ***********

if ($CDorTL == 2) & ($isClass == 0) {  /* only models of TL with u term needs the usigmas */

 global usigterm  (usigmas: `usigmas')
 global usigterm1 usigmas

}

************ call the ML function ***********

  /* --- which distribution ---- */
  if "`dist'" == "halfnormal" {
     global pgm syspft_h
  }
  else if "`dist'" == "truncated" {
     global pgm syspft_t
  }
  else if "`dist'" == "exponential" {
     global pgm syspft_e
  }

 if $isClass == 1 {
    global pgm syspft_h  /* if classical model, no inefficiency, so we use the h model as the default */
 }

 ml model lf0 $pgm $funlist $mufun $sterm  $usigterm if `touse' $tech
 global showM ml model lf0 $pgm $funlist $mufun $sterm $usigterm   if `touse' $tech
 global ML_user_hj $pgm



if "`show'" ~= "" {
 di " "
 di in gre "  *** The sfsystem_profitshares sets up the following model for ML estimation.***
 di "$showM"
 di " "
}



end
