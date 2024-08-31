*! version 3.0 13Mar2017 
*! by Hung-Jen Wang
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw



capture program drop sfprim
program define sfprim


syntax varlist [if] [in],  INPUTs(varlist) PRICEs(varlist) Distribution(string) [VSIGMAS(string) USIGMAS(string) YPrice(varlist) SYSERROR  MU(string) LINEAR(string) CD TRANSLOG NOASK MLTRICK NOTCONcentrated TECHnique(string) COST PROFIT NOCONFirm NOU SHOW NOMESSAGE]


global hj_syn "`0'" /* record the original input syntax for later use */

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


if ("`cost'"~="") & ("`profit'"~="") {
     di in red "Can only specify either -cost- or -profit-."
     exit 198
}

if ("`cost'"=="") & ("`profit'"=="") {
     di in red "Must specify either -cost- or -profit-."
     exit 198
}

 ************* important variable for sf_predict and sf_pf_compare (sf_pft_get), so drop to ensure new ********
 capture drop _front1c81

 ***** re-direct to the appropriate model handler ******

if "`cost'"~=""{ /* a cost minimization model via primal approach */
   costmin_D $hj_syn
 }

if "`profit'"~=""{ /* a profit maximization model via primal approach */
   profmax_D $hj_syn

}

end
