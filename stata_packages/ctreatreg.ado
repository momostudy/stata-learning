*! ctreatreg v4 GCerulli 25/10/2017
program ctreatreg, eclass
version 13
#delimit ;     
syntax varlist [if] [in] [fweight pweight iweight] [,
hetero(varlist numeric)
estype(string)
ct(varlist numeric)
s(numlist max=1)
delta(numlist max=1)
m(numlist max=1 integer)
ci(numlist max=1)
vce(string) 
beta 
graphate
graphdrf
const(string) 
head(string) 
conf(numlist max=1)
iv_t(varlist numeric)
iv_w(varlist numeric)
model(string)
heckvce(string)];
#delimit cr
***********************************************************************
* DROP OUTCOME VARIABLES GENERATED LATER ON
***********************************************************************
foreach var of local hetero{
capture drop _ws_`var'
}
foreach var of local hetero{
capture drop _ps_`var'
}
foreach var of local hetero{
capture drop _z_`var'
}
capture drop ATE_x ATET_x ATENT_x 
***********************************************************************
* START BY ASKING IF A SPECIFIC MODEL HAS BEEN CHOSEN 
***********************************************************************
*
if "`model'"==""{
break
di _newline(2)
di as result in red "********************************************************"
di as result in red "Warning: at least one of the following models must be   "
di as result in red "declared into the option 'model()': ct-ols, ct-iv"
di as result in red "********************************************************"
}
*
else if "`model'"=="ct-iv" & "`estype'"==""{
break
di _newline(2)
di as result in red "****************************************************************"
di as result in red "Warning: when using IV, at least one of the following estimating"
di as result in red "models must be declared into the option 'estype()': twostep, ml "
di as result in red "****************************************************************"
}
*
else if "`ct'"==""{
break
di _newline(2)
di as result in red "*********************************************************"
di as result in red "Warning: the continuos treatment variable (i.e. the dose)"
di as result in red "must be declared into the option 'ct()'"
di as result in red "*********************************************************"
}
*
else if "`m'"==""{  
break
di _newline(2)
di as result in red "******************************************************************"
di as result in red "Warning: the option m(#), with # indicating the polynomial degree,"  
di as result in red "must be declared" 
di as result in red "******************************************************************"
} 
*
else if "`graphdrf'"=="graphdrf" & "`ci'"=="" {
break
di _newline(2)
di as result in red "**********************************************************"
di as result in red "Warning: option 'ci()' is compulsory with option 'graphdrf'"
di as result in red "**********************************************************"
}
*
else if "`graphdrf'"=="graphdrf" & "`delta'"=="" {
break
di _newline(2)
di as result in red "*************************************************************"
di as result in red "Warning: option 'delta()' is compulsory with option 'graphdrf'"
di as result in red "*************************************************************"
}
*
else if "`s'"==""{
break
di _newline(2)
di as result in red "******************************************************************"
di as result in red "Warning: the option s(#), with # indicating a number in [0;100],"  
di as result in red "must be declared" 
di as result in red "******************************************************************"
}
***********************************************************************
* -> MODEL: ct-ols
***********************************************************************
else if "`model'"=="ct-ols"{
marksample touse
markout `touse' `iv_t' `iv_w'
tokenize `varlist'
local y `1'
local w `2'
macro shift
macro shift
local xvars `*'
foreach var of local hetero{
tempvar m_`var' 
tempvar s_`var' 
tempvar ws_`var' 
egen `m_`var'' = mean(`var')  if `touse'
gen `s_`var'' = (`var' - `m_`var'') if `touse'
gen _ws_`var'=`w'*`s_`var'' if `touse'
}
foreach var of local hetero{
local xvar2 `xvar2' _ws_`var'
}
***********************************************************************
* Use the sub-command "polyn" to:
* - generate the arguments of the polynomial function
* - demean the arguments and generate the regressors "T*w"
* - put them into the local macro "treat" and run the basic regression
***********************************************************************
*****************************************************
* First: generate T_`j' as variables (j=1,...,m)
*****************************************************

forvalues j=0/`m'{
tempvar t_`j'
}
forvalues j=0/`m'{
gen `t_`j''=(`ct')^(`j') if `touse'  
}
forvalues j=1/`m'{
tempvar mean_t_`j'
}
forvalues j=1/`m'{
egen `mean_t_`j''=mean(`t_`j'') if `ct'!=. & `touse'
}
forvalues j=1/`m'{
cap drop T_`j'
}
forvalues j=1/`m'{
gen T_`j'=`t_`j''-`mean_t_`j'' if `touse' 
}

******************************************************
* Use the sub-command "polyn"
******************************************************
polyn `ct' `w' , m(`m') 
return list
local treat `r(output)'
*************************************************
* Estimate the regression model and calculate ATE
*************************************************
regress `y' `w' `xvars' `xvar2' `treat' if `touse' [`weight'`exp'] , vce(`vce') `beta' `const' `head' level(`conf') 
ereturn scalar ate = _b[`w']
capture drop ATE
gen ATE=_b[`w']
foreach var of local xvar2{
scalar d`var' = _b[`var']
}
tempvar k
generate `k' = 0 
foreach var of local hetero{
replace `k' = `k' + (`s_`var'' * d_ws_`var') 
}
*********************************************************
* PUT THE PARAMETERS OF Tw_1, Tw_2,..., Tw_m INTO SCALARS
*********************************************************
forvalues j=1/`m'{
scalar dTw_`j'=_b[Tw_`j']
}
****************************************************
* GENERATE THE POLYNOMIAL FUNCTION: h(t) 
****************************************************
tempvar h
gen `h' = 0
forvalues j=1/`m'{
replace `h'=`h'+ dTw_`j'*`ct'^`j' if `touse'
} 
qui sum `h' if `touse' 
tempvar mean_h
gen `mean_h'=r(mean)
*****************************************************
* DEMEAN h(t)
*****************************************************
tempvar h_t_h_mean
gen `h_t_h_mean' = `h' - `mean_h' if `touse'

*****************************************************
* CALCULATE: ATE(x;t), ATET(x;t) e ATENT(x;t) 
*****************************************************
* GENERATE "ATE_x_t"
capture drop ATE_x_t
gen ATE_x_t=ATE+`k'+`h_t_h_mean'
qui sum ATE_x_t
* GENERATE "ATET_x_t"
capture drop ATET_x_t 
gen ATET_x_t=ATE+`k'+`w'*`h_t_h_mean' if `touse' & `w'==1
qui sum ATET_x_t if `touse' & `w'==1
capture drop ATET
gen ATET=r(mean) if `touse' & `w'==1
* GENERATE "ATENT_x_t"
capture drop ATENT_x_t  
gen ATENT_x_t=ATE-`mean_h'+`k' if `touse' & `w'==0
qui sum ATENT_x_t
capture drop ATENT
gen ATENT=r(mean) if `touse' & `w'==0
* REPEAT GENERATE "ATET_x_t"
capture drop ATET_x_t 
gen ATET_x_t=ATE+`k'+`w'*`h_t_h_mean' if `touse' & `w'==1
qui sum ATET_x_t if `touse' & `w'==1
capture drop ATET
gen ATET=r(mean) if `touse' & `w'==1
* REPEAT GENERATE "ATENT_x_t"
capture drop ATENT_x_t  
gen ATENT_x_t=ATE-`mean_h'+`k' if `touse' & `w'==0
qui sum ATENT_x_t
capture drop ATENT
gen ATENT=r(mean) if `touse' & `w'==0
************************************************************************
* ereturn SAMPLE SIZES
************************************************************************
qui sum ATE_x_t
ereturn scalar N_tot=r(N)
qui sum ATET_x_t
ereturn scalar atet=r(mean)
ereturn scalar N_treat=r(N)
qui sum ATENT_x_t
ereturn scalar atent=r(mean)
ereturn scalar N_untreat=r(N)
*****************************************************
* CALCULATE: ATE(t), ATET(t) e ATENT(t) 
*****************************************************
* CALCULATE FIRST [h(t)-E(h(t)] FOR t>0: 
tempvar h2
gen `h2' = 0
forvalues j=1/`m'{
replace `h2'=`h2'+ dTw_`j'*`ct'^`j' if `touse' & `w'==1
} 
qui sum `h2' if `touse' & `w'==1 
tempvar mean_h2
gen `mean_h2'=r(mean)
tempvar h_t_h_mean2
gen `h_t_h_mean2' = `h2'-`mean_h2' if `touse' & `w'==1
* GENERATE ATE(t)
capture drop ATE_t
gen ATE_t = ATET + `h_t_h_mean2' if `touse' & `w'==1 
replace ATE_t = ATENT if `touse' & `w'==0
qui sum ATE_t
* GENERATE ATET(t)
capture drop ATET_t
gen ATET_t = ATE_t if `ct'>0 & `touse'
qui sum ATET_t
* GENERATE ATENT(t)
capture drop ATENT_t
gen ATENT_t = ATE_t if `ct'==0 & `touse'
qui sum ATENT_t
*********************************************************************
* GENERATE THE "DOSE-RESPONSE FUNCTION" = ATE(t) 
* GENERATE "ATE(t;delta)" 
*********************************************************************
* WE DEFINE A NEW CAUSAL PARAMETER, ATE(t, delta), 
* DEFINED AS: ATE(t; delta)=E [y(t + delta)-y(t)]. 
* IT MEASURES THE DIFFERENCE IN AVERAGE OUTCOME 
* FOR TWO DIFFERENT SITUATIONS: THE ONE WHERE THE 
* UNIT IS TREATED WITH A DOSE EQUAL TO "t + delta" 
* AND THAT IN WHICH THE SAME UNIT IS TREATED 
* WITH A DOSE "t". ATE(t, delta) IS 'A FUNCTION OF "t" 
* GIVEN "delta". IN PARTICULAR, FOR VERY SMALL "delta" (delta -> 0), 
* THE "ATE(t, delta)" IS EQUAL TO THE DERIVATIVE IF THE 
* "DOSE-RESPONSE-FUNCTION ATE(t)" (DEFINED ON ALL THE SUPPORT OF "t"):
**********************************************************************
*****************************************************
* First: generate t_delta`j' as variables (j=1,...,m)
*****************************************************
if "`delta'"!=""{  // allows option for "delta"
local delta = `delta'
forvalues j=1/`m'{
cap drop t_delta`j'
}
forvalues j=1/`m'{
gen t_delta`j'=(`ct'+`delta')^(`j') if `touse'  
}
capture drop ATE_t_delta
gen ATE_t_delta = 0 if `touse'
forvalues j=1/`m'{
replace ATE_t_delta = ATE_t_delta + dTw_`j' * (`t_`j''-t_delta`j')  if `touse'
} 
qui sum ATE_t_delta if `touse'
ereturn scalar ate_t_delta=r(mean) 
} // close option for "delta"
***********************************************
* CALCULATE THE DERIVATIVE OF "ATE(t)" IN "t":
***********************************************
capture drop der_ATE_t
gen der_ATE_t = dTw_1 if `touse' & `w'==1
forvalues j=2/`m'{
local k =`j'-1
replace der_ATE_t = der_ATE_t +`j'*dTw_`j'*`t_`k'' if `touse' & `w'==1
} 
replace der_ATE_t = 0 if `touse' & `w'==0
*******************************************************************
* Calculate the scalar ATE(s) and define it as an ereturn element:
*******************************************************************
*****************************************************
* CALCULATE: ATE(s)
*****************************************************
* CALCULATE FIRST [h(s)-E(h(s)] FOR t>0: 
tempvar s2
tempvar tc
gen `s2' = 0
gen `tc'=`s'
forvalues j=1/`m'{
replace `s2'=`s2'+ dTw_`j'*`tc'^`j' if `touse' & `w'==1
} 
tempvar s_t_s_mean2
gen `s_t_s_mean2' = `s2'-`mean_h2' if `touse' & `w'==1
* GENERATE ATE(s)
cap drop ATE_s
gen ATE_s = ATET + `s_t_s_mean2' if `touse' & `w'==1 
replace ATE_s = ATENT if `touse' & `w'==0
sum ATE_s if `ct'>0
ereturn scalar ate_s=r(mean) 
*******************************************************************
* PLOTTING THE ATE(t) AND ITS DERIVATIVE FOR t>0 ON THE SAME GRAPH,
* NEEDS "STANDARDIZING" THEIR VALUES:
*******************************************************************
capture drop std_ATE_t
egen std_ATE_t=std(ATE_t)
capture drop std_der_ATE_t
egen std_der_ATE_t=std(der_ATE_t)
******************
* DRAW THE GRAPHS:
******************
if "`hetero'"!="" & "`graphate'"=="graphate"{
graph_ct `model' `y'
}     // CLOSE MODEL "ct-ols"
if "`graphdrf'"=="graphdrf"{
graph_ctic `ct' `model' `y' `delta' `ci' `m'
}
}
***********************************************************************
* -> MODEL: ct-fe
***********************************************************************
else if "`model'"=="ct-fe"{
marksample touse
markout `touse' `iv_t' `iv_w'
tokenize `varlist'
local y `1'
local w `2'
macro shift
macro shift
local xvars `*'
foreach var of local hetero{
tempvar m_`var' 
tempvar s_`var' 
tempvar ws_`var' 
egen `m_`var'' = mean(`var')  if `touse'
gen `s_`var'' = (`var' - `m_`var'') if `touse'
gen _ws_`var'=`w'*`s_`var'' if `touse'
}
foreach var of local hetero{
local xvar2 `xvar2' _ws_`var'
}
***********************************************************************
* Use the sub-command "polyn" to:
* - generate the arguments of the polynomial function
* - demean the arguments and generate the regressors "T*w"
* - put them into the local macro "treat" and run the basic regression
***********************************************************************
*****************************************************
* First: generate T_`j' as variables (j=1,...,m)
*****************************************************
forvalues j=0/`m'{
tempvar t_`j'
}
forvalues j=0/`m'{
gen `t_`j''=(`ct')^(`j') if `touse'  
}
forvalues j=1/`m'{
tempvar mean_t_`j'
}
forvalues j=1/`m'{
egen `mean_t_`j''=mean(`t_`j'') if `ct'!=. & `touse'
}
forvalues j=1/`m'{
cap drop T_`j'
}
forvalues j=1/`m'{
gen T_`j'=`t_`j''-`mean_t_`j'' if `touse' 
}
******************************************************
* Use the sub-command "polyn"
******************************************************
polyn `ct' `w' , m(`m') 
return list
local treat `r(output)'
*************************************************
* Estimate the regression model and calculate ATE
*************************************************
xtreg `y' `w' `xvars' `xvar2' `treat' if `touse' [`weight'`exp'] , fe vce(`vce') `const' `head' level(`conf') 
ereturn scalar ate = _b[`w']
capture drop ATE
gen ATE=_b[`w']
foreach var of local xvar2{
scalar d`var' = _b[`var']
}
tempvar k
generate `k' = 0 
foreach var of local hetero{
replace `k' = `k' + (`s_`var'' * d_ws_`var') 
}
*********************************************************
* PUT THE PARAMETERS OF Tw_1, Tw_2,..., Tw_m INTO SCALARS
*********************************************************
forvalues j=1/`m'{
scalar dTw_`j'=_b[Tw_`j']
}
****************************************************
* GENERATE THE POLYNOMIAL FUNCTION: h(t) 
****************************************************
tempvar h
gen `h' = 0
forvalues j=1/`m'{
replace `h'=`h'+ dTw_`j'*`ct'^`j' if `touse'
} 
qui sum `h' if `touse' 
tempvar mean_h
gen `mean_h'=r(mean)
*****************************************************
* DEMEAN h(t)
*****************************************************
tempvar h_t_h_mean
gen `h_t_h_mean' = `h' - `mean_h' if `touse'

*****************************************************
* CALCULATE: ATE(x;t), ATET(x;t) e ATENT(x;t) 
*****************************************************
* GENERATE "ATE_x_t"
capture drop ATE_x_t
gen ATE_x_t=ATE+`k'+`h_t_h_mean'
qui sum ATE_x_t
* GENERATE "ATET_x_t"
capture drop ATET_x_t 
gen ATET_x_t=ATE+`k'+`w'*`h_t_h_mean' if `touse' & `w'==1
qui sum ATET_x_t if `touse' & `w'==1
capture drop ATET
gen ATET=r(mean) if `touse' & `w'==1
* GENERATE "ATENT_x_t"
capture drop ATENT_x_t  
gen ATENT_x_t=ATE-`mean_h'+`k' if `touse' & `w'==0
qui sum ATENT_x_t
capture drop ATENT
gen ATENT=r(mean) if `touse' & `w'==0
* REPEAT GENERATE "ATET_x_t"
capture drop ATET_x_t 
gen ATET_x_t=ATE+`k'+`w'*`h_t_h_mean' if `touse' & `w'==1
qui sum ATET_x_t if `touse' & `w'==1
capture drop ATET
gen ATET=r(mean) if `touse' & `w'==1
* REPEAT GENERATE "ATENT_x_t"
capture drop ATENT_x_t  
gen ATENT_x_t=ATE-`mean_h'+`k' if `touse' & `w'==0
qui sum ATENT_x_t
capture drop ATENT
gen ATENT=r(mean) if `touse' & `w'==0
************************************************************************
* ereturn SAMPLE SIZES
************************************************************************
qui sum ATE_x_t
ereturn scalar N_tot=r(N)
qui sum ATET_x_t
ereturn scalar atet=r(mean)
ereturn scalar N_treat=r(N)
qui sum ATENT_x_t
ereturn scalar atent=r(mean)
ereturn scalar N_untreat=r(N)
*****************************************************
* CALCULATE: ATE(t), ATET(t) e ATENT(t) 
*****************************************************
* CALCULATE FIRST [h(t)-E(h(t)] FOR t>0: 
tempvar h2
tempvar h2
gen `h2' = 0
forvalues j=1/`m'{
replace `h2'=`h2'+ dTw_`j'*`ct'^`j' if `touse' & `w'==1
} 
qui sum `h2' if `touse' & `w'==1 
tempvar mean_h2
gen `mean_h2'=r(mean)
tempvar h_t_h_mean2
gen `h_t_h_mean2' = `h2'-`mean_h2' if `touse' & `w'==1
* GENERATE ATE(t)
capture drop ATE_t
gen ATE_t = ATET + `h_t_h_mean2' if `touse' & `w'==1 
replace ATE_t = ATENT if `touse' & `w'==0
qui sum ATE_t
* GENERATE ATET(t)
capture drop ATET_t
gen ATET_t = ATE_t if `ct'>0 & `touse'
qui sum ATET_t
* GENERATE ATENT(t)
capture drop ATENT_t
gen ATENT_t = ATE_t if `ct'==0 & `touse'
qui sum ATENT_t
*********************************************************************
* GENERATE THE "DOSE-RESPONSE FUNCTION" = ATE(t) 
* GENERATE "ATE(t;delta)" 
*********************************************************************
* WE DEFINE A NEW CAUSAL PARAMETER, ATE (t, delta), 
* DEFINED AS: ATE(t; delta)=E [y(t + delta)-y(t)]. 
* IT MEASURES THE DIFFERENCE IN AVERAGE OUTCOME 
* FOR TWO DIFFERENT SITUATIONS: THE ONE WHERE THE 
* UNIT IS TREATED WITH A DOSE EQUAL TO "t + delta" 
* AND THAT IN WHICH THE SAME UNIT IS TREATED 
* WITH A DOSE "t". ATE(t, delta) IS 'A FUNCTION OF "t" 
* GIVEN "delta". IN PARTICULAR, FOR VERY SMALL "delta" (delta -> 0), 
* THE "ATE(t, delta)" IS EQUAL TO THE DERIVATIVE IF THE 
* "DOSE-RESPONSE-FUNCTION ATE(t)" (DEFINED ON ALL THE SUPPORT OF "t"):
**********************************************************************
*****************************************************
* First: generate t_delta`j' as variables (j=1,...,m)
*****************************************************
if "`delta'"!=""{  // allows option for "delta"
local delta = `delta'
forvalues j=1/`m'{
cap drop t_delta`j'
}
forvalues j=1/`m'{
gen t_delta`j'=(`ct'+`delta')^(`j') if `touse'  
}
capture drop ATE_t_delta
gen ATE_t_delta = 0 if `touse'
forvalues j=1/`m'{
replace ATE_t_delta = ATE_t_delta + dTw_`j' * (`t_`j''-t_delta`j')  if `touse'
} 
qui sum ATE_t_delta if `touse'
ereturn scalar ate_t_delta=r(mean) 
} // close option for "delta"
***********************************************
* CALCULATE THE DERIVATIVE OF "ATE(t)" IN "t":
***********************************************
capture drop der_ATE_t
gen der_ATE_t = dTw_1 if `touse' & `w'==1
forvalues j=2/`m'{
local k =`j'-1
replace der_ATE_t = der_ATE_t +`j'*dTw_`j'*`t_`k'' if `touse' & `w'==1
} 
replace der_ATE_t = 0 if `touse' & `w'==0
*******************************************************************
* Calculate the scalar ATE(s) and define it as an ereturn element:
*******************************************************************
*****************************************************
* CALCULATE: ATE(s)
*****************************************************
* CALCULATE FIRST [h(s)-E(h(s)] FOR t>0: 
tempvar s2
tempvar tc
gen `s2' = 0
gen `tc'=`s'
forvalues j=1/`m'{
replace `s2'=`s2'+ dTw_`j'*`tc'^`j' if `touse' & `w'==1
} 
tempvar s_t_s_mean2
gen `s_t_s_mean2' = `s2'-`mean_h2' if `touse' & `w'==1
* GENERATE ATE(s)
cap drop ATE_s
gen ATE_s = ATET + `s_t_s_mean2' if `touse' & `w'==1 
replace ATE_s = ATENT if `touse' & `w'==0
sum ATE_s if `ct'>0
ereturn scalar ate_s=r(mean) 
*******************************************************************
* PLOTTING THE ATE(t) AND ITS DERIVATIVE FOR t>0 ON THE SAME GRAPH,
* NEEDS "STANDARDIZING" THEIR VALUES:
*******************************************************************
capture drop std_ATE_t
egen std_ATE_t=std(ATE_t)
capture drop std_der_ATE_t
egen std_der_ATE_t=std(der_ATE_t)
******************
* DRAW THE GRAPHS:
******************
if "`hetero'"!="" & "`graphate'"=="graphate"{
graph_ct `model' `y'
}     // CLOSE MODEL "ct-ols"
if "`graphdrf'"=="graphdrf"{
graph_ctic `ct' `model' `y' `delta' `ci' `m'
}
}
***********************************************************************
* -> MODEL: CT-IV
***********************************************************************
else if "`model'"=="ct-iv"{
marksample touse
markout `touse' `iv_t' `iv_w'
tokenize `varlist'
local y `1'
local w `2'
macro shift
macro shift
local xvars `*'
**************************************************************
* ESTIMATE THE "BIVARIATE SAMPLE SELECTION MODEL" BY "heckman"
**************************************************************
if "`estype'"=="twostep"{
heckman `ct' `xvars' `iv_t' if `touse' , select(`w' = `xvars' `iv_w') twostep vce(`heckvce')
}
else if "`estype'"=="ml"{
heckman `ct' `xvars' `iv_t' if `touse' , select(`w' = `xvars' `iv_w') vce(`heckvce')
}
capture drop mills
predict mills , mills
capture drop probw 
predict probw , psel
tempvar `ct'_hat
predict ``ct'_hat' , xb
capture drop t_hat
gen t_hat=``ct'_hat' if `touse' 
*******************************************************************
* BUILD MODEL'S VARIABLES. OBSERVE THAT NOW "probw" SUBSTITUTES "w"
*******************************************************************
foreach var of local hetero{
tempvar m_`var' 
tempvar s_`var' 
egen `m_`var'' = mean(`var')  if `touse'
gen `s_`var'' = (`var' - `m_`var'') if `touse'
gen _ps_`var'=probw*`s_`var'' if `touse'
gen _ws_`var'=`w'*`s_`var'' if `touse'
}
foreach var of local hetero{
local xvar3 `xvar3' _ps_`var'
}
foreach var of local hetero{
local xvar2 `xvar2' _ws_`var'
}
********************************************************************
* BUILD THE ARGUMENTS FOR THE FUNCTION h(t). OBSERVE THAT - 
* COMPARED WITH OLS - Tw, ... ARE SUBSTITUTED BY Tp, ...
* WARNING: IN THE MAIN REGRESSION WE SHOULD USE "t_hat" INSTEAD OF 
* "t". INDEED, "t_hat" IS THE EXOGENOUS PART OF "t" 
* (BEING "t" ENDOGENOUS). THE PROBLEM IS THAT T_HAT MAY ASSUME ALSO
* NEGATIVE VALUES. THIS ENGENDERS A PROBLEM. THUS, WE CONSIDER
* "t" (THE ACTUAL LEVEL) INSTEAD OF "t_hat" (THE PREDICTION FROM THE
* HECKMAN COMMAND)   
********************************************************************
* Use the sub-command "polynp" to create "Tp_1, T2p_2,...,Tp_m"
* to collect in a local macro "treatp"
********************************************************************
polynp `ct' probw , m(`m')
return list
local treatp `r(output_p)'
**********************************************
* GENERATE T_hat_1, T_hat_2,..., T_hat_m
**********************************************
forvalues j=1/`m'{
tempvar t_hat_`j'
}
forvalues j=1/`m'{
gen `t_hat_`j'' = t_hat^(`j') if `touse'
}
*************************************
* DEMEANING and create "T_hat_j"
*************************************
forvalues j=1/`m'{
tempvar mean_t_hat_`j'
}
forvalues j=1/`m'{
egen `mean_t_hat_`j'' = mean(`t_hat_`j'') if t_hat!=. & `touse'
}
forvalues j=1/`m'{
tempvar T_hat_`j'
}
forvalues j=1/`m'{
gen `T_hat_`j''=`t_hat_`j''-`mean_t_hat_`j'' if `touse'
}
****************************************************
* Generate T_hatp_1, T_hatp_2,..., T_hatp_m
* and collect them into the local macro "treat_hatp"
****************************************************
forvalues j=1/`m'{
cap drop T_hatp_`j'
}
forvalues j=1/`m'{
gen T_hatp_`j' = `T_hat_`j'' * probw  if `touse'
}
local treat_hatp
forvalues j=1/`m'{
local treat_hatp `treat_hatp' T_hatp_`j'
}  
*****************************************************
* First: generate T_`j' as variables (j=1,...,m)
*****************************************************
forvalues j=1/`m'{
tempvar t_`j'
}
forvalues j=1/`m'{
gen `t_`j''=(`ct')^(`j') if `touse'  
}
forvalues j=1/`m'{
tempvar mean_t_`j'
}
forvalues j=1/`m'{
egen `mean_t_`j''=mean(`t_`j'') if `ct'!=. & `touse'
}
forvalues j=1/`m'{
cap drop T_`j'
}
forvalues j=1/`m'{
gen T_`j'=`t_`j''-`mean_t_`j'' if `touse' 
}
************************************************
* Generate "Tw_1, Tw_2,...,T3w_m" using "polyn" 
* and collect them into the local "treatw"
************************************************
polyn `ct' `w' , m(`m') 
return list
local treatw `r(output)'
**********************************
*******************************************************************
* ESTIMATE THE IV REGRESSION USING AS INSTRUMENTS: 
*******************************************************************
ivreg `y'  (`w' `xvar2' `treatw'  =  probw  `xvar3' `treat_hatp') `xvars' if `touse' [`weight'`exp'] , `const' `head' 
ereturn scalar ate = _b[`w']
capture drop ATE
gen ATE=_b[`w']
foreach var of local xvar2{
scalar d`var' = _b[`var']
}
tempvar k
generate `k' = 0 
foreach var of local hetero{
replace `k' = `k' + (`s_`var'' * d_ws_`var') 
}
********************************************************
* PUT THE PARAMETERS OF Tw_1, Tw_2,...,Tw_m INTO SCALARS
********************************************************
forvalues j=1/`m'{
scalar dTw_`j'=_b[Tw_`j']
}
****************************************************
* GENERATE THE POLYNOMIAL FUNCTION: h(t) 
****************************************************
tempvar h
gen `h' = 0
forvalues j=1/`m'{
replace `h'=`h'+ dTw_`j'*`ct'^`j' if `touse'
} 
qui sum `h' if `touse' 
tempvar mean_h
gen `mean_h'=r(mean)
*****************************************************
* DEMEAN h(t)
*****************************************************
tempvar h_t_h_mean
gen `h_t_h_mean' = `h' - `mean_h' if `touse'
*****************************************************
* CALCULATE: ATE(x;t), ATET(x;t) e ATENT(x;t) 
*****************************************************
* GENERATE "ATE_x_t"
capture drop ATE_x_t
gen ATE_x_t=ATE+`k'+`h_t_h_mean'
qui sum ATE_x_t
* GENERATE "ATET_x_t"
capture drop ATET_x_t 
gen ATET_x_t=ATE+`k'+`w'*`h_t_h_mean' if `touse' & `w'==1
qui sum ATET_x_t if `touse' & `w'==1
capture drop ATET
gen ATET=r(mean) if `touse' & `w'==1
* GENERATE "ATENT_x_t"
capture drop ATENT_x_t  
gen ATENT_x_t=ATE-`mean_h'+`k' if `touse' & `w'==0
qui sum ATENT_x_t
capture drop ATENT
gen ATENT=r(mean) if `touse' & `w'==0
* REPEAT GENERATE "ATET_x_t" // Not clear why but it works !
capture drop ATET_x_t 
gen ATET_x_t=ATE+`k'+`w'*`h_t_h_mean' if `touse' & `w'==1
qui sum ATET_x_t if `touse' & `w'==1
capture drop ATET
gen ATET=r(mean) if `touse' & `w'==1
* REPEAT GENERATE "ATENT_x_t" // Not clear why but it works !
capture drop ATENT_x_t  
gen ATENT_x_t=ATE-`mean_h'+`k' if `touse' & `w'==0
qui sum ATENT_x_t
capture drop ATENT
gen ATENT=r(mean) if `touse' & `w'==0
************************************************************************
* ereturn SAMPLE SIZES
************************************************************************
qui sum ATE_x_t
ereturn scalar N_tot=r(N)
qui sum ATET_x_t
ereturn scalar atet=r(mean)
ereturn scalar N_treat=r(N)
scalar N_treat=r(N)
qui sum ATENT_x_t
ereturn scalar atent=r(mean)
ereturn scalar N_untreat=r(N)
*****************************************************
* CALCULATE: ATE(t), ATET(t) e ATENT(t) 
*****************************************************
* CALCULATE FIRST [h(t)-E(h(t)] FOR t>0: 
tempvar h2
tempvar h2
gen `h2' = 0
forvalues j=1/`m'{
replace `h2'=`h2'+ dTw_`j'*`ct'^`j' if `touse' & `w'==1
} 
qui sum `h2' if `touse' & `w'==1 
tempvar mean_h2
gen `mean_h2'=r(mean)
tempvar h_t_h_mean2
gen `h_t_h_mean2' = `h2'-`mean_h2' if `touse' & `w'==1
* GENERATE ATE(t)
capture drop ATE_t
gen ATE_t = ATET + `h_t_h_mean2' if `touse' & `w'==1 
replace ATE_t = ATENT if `touse' & `w'==0
qui sum ATE_t
* GENERATE ATET(t)
capture drop ATET_t
gen ATET_t = ATE_t if `ct'>0 & `touse'
qui sum ATET_t
* GENERATE ATENT(t)
capture drop ATENT_t
gen ATENT_t = ATE_t if `ct'==0 & `touse'
qui sum ATENT_t
*********************************************************************
* GENERATE THE "DOSE-RESPONSE FUNCTION" = ATE(t) 
* GENERATE "ATE(t;delta)" 
*********************************************************************
* WE DEFINE A NEW CAUSAL PARAMETER, ATE (t, delta), 
* DEFINED AS: ATE(t; delta)=E [y(t + delta)-y(t)]. 
* IT MEASURES THE DIFFERENCE IN AVERAGE OUTCOME 
* FOR TWO DIFFERENT SITUATIONS: THE ONE WHERE THE 
* UNIT IS TREATED WITH A DOSE EQUAL TO "t + delta" 
* AND THAT IN WHICH THE SAME UNIT IS TREATED 
* WITH A DOSE "t". ATE(t, delta) IS 'A FUNCTION OF "t" 
* GIVEN "delta". IN PARTICULAR, FOR VERY SMALL "delta" (delta -> 0), 
* THE "ATE(t, delta)" IS EQUAL TO THE DERIVATIVE IF THE 
* "DOSE-RESPONSE-FUNCTION ATE(t)" (DEFINED ON ALL THE SUPPORT OF "t"):
**********************************************************************
*****************************************************
* First: generate t_delta`j' as variables (j=1,...,m)
*****************************************************
if "`delta'"!=""{  // allows option for "delta"
local delta = `delta'
forvalues j=1/`m'{
cap drop t_delta`j'
}
forvalues j=1/`m'{
gen t_delta`j'=(`ct'+`delta')^(`j') if `touse'  
}
capture drop ATE_t_delta
gen ATE_t_delta = 0 if `touse'
forvalues j=1/`m'{
replace ATE_t_delta = ATE_t_delta + dTw_`j' * (`t_`j''-t_delta`j')  if `touse'
} 
qui sum ATE_t_delta if `touse'
ereturn scalar ate_t_delta=r(mean) 
} // close option for "delta"
***********************************************
* CALCULATE THE DERIVATIVE OF "ATE(t)" IN "t":
***********************************************
capture drop der_ATE_t
gen der_ATE_t = dTw_1 if `touse' & `w'==1
forvalues j=2/`m'{
local k =`j'-1
replace der_ATE_t = der_ATE_t +`j'*dTw_`j'*`t_`k'' if `touse' & `w'==1
} 
replace der_ATE_t = 0 if `touse' & `w'==0
*******************************************************************
* Calculate the scalar ATE(s) and define it as an ereturn element:
*******************************************************************
*****************************************************
* CALCULATE: ATE(s)
*****************************************************
* CALCULATE FIRST [h(s)-E(h(s)] FOR t>0: 
tempvar s2
tempvar tc
gen `s2' = 0
gen `tc'=`s'
forvalues j=1/`m'{
replace `s2'=`s2'+ dTw_`j'*`tc'^`j' if `touse' & `w'==1
} 
tempvar s_t_s_mean2
gen `s_t_s_mean2' = `s2'-`mean_h2' if `touse' & `w'==1
* GENERATE ATE(s)
cap drop ATE_s
gen ATE_s = ATET + `s_t_s_mean2' if `touse' & `w'==1 
replace ATE_s = ATENT if `touse' & `w'==0
sum ATE_s if `ct'>0
ereturn scalar ate_s=r(mean) 
*******************************************************************
* PLOTTING THE ATE(t) AND ITS DERIVATIVE FOR t>0 ON THE SAME GRAPH,
* NEEDS "STANDARDIZING" THEIR VALUES:
*******************************************************************
capture drop std_ATE_t
egen std_ATE_t=std(ATE_t)
capture drop std_der_ATE_t
egen std_der_ATE_t=std(der_ATE_t)
******************
* DRAW THE GRAPHS:
******************
if "`hetero'"!="" & "`graphate'"=="graphate"{
graph_ct `model' `y'
}     // CLOSE MODEL "ct-iv"
if "`graphdrf'"=="graphdrf"{
graph_ctic `ct' `model' `y' `delta' `ci' `m'
}
}
*************************************************
tokenize `varlist'
local depvar `1'
local treat `2'
macro shift
macro shift
local covs `*'
local mymodel ctreatreg `y' `w' `xvars' , ///
hetero(`hetero') model(`model') ct(`ct') ///
ci(`ci') m(`m') estype(`estype') vce(`vce') ///
`beta' const(`const') head(`head') ///
iv_t(`iv_t') iv_w(`iv_w') vce(`heckvce')
ereturn local cdmline `mymodel'
ereturn local depvar `y'
ereturn local treat `w'
ereturn local ci `ci'
ereturn local modtype `model'
ereturn local cdm2 ctreatreg
***************************************
end   // END OF THE PROGRAM "ctreatreg"

***********************************************************************
* PROGRAM "graph_ct" TO DRAW THE OVELAPPING DISTRIBUTIONS 
* OF ATE(x), ATET(x) and ATENT(x)
***********************************************************************
! graph_ct v1.0.0 GCerulli 31Jul2012
capture program drop graph_ct
program graph_ct
args model outcome
version 13
*
capture graph drop DRF0
twoway kdensity ATE_x_t , /// 
|| ///
kdensity ATET_x_t , lpattern(dash) ///
|| ///
kdensity ATENT_x_t , lpattern(longdash_dot) xtitle() ///
ytitle(Kernel density) legend(order(1 "ATE(x)" 2 "ATET(x)" 3 "ATENT(x)")) ///
scheme(s2mono) graphregion(fcolor(white)) ///
title("Model `model': Distribution of ATE(x) ATET(x) ATENT(x)", size(medlarge)) name(DRF0) ///
note("Outcome variable: `outcome'")
end  // END OF THE PROGRAM "graph_ct"

***********************************************************************
* PROGRAM "graph_ctic" TO DRAW THE DOSE RESPONSE FUNCTION
***********************************************************************
! graph_ctic v1.0.0 GCerulli 31Jul2012
capture program drop graph_ctic
program graph_ctic
args t model outcome delta ci m
version 13
marksample touse
capture graph drop DRFIC
tempname V 
tempvar lim upper lower lim2 upper2 lower2 lim3 upper3 lower3
forvalues j=1/`m'{
forvalues i=1/`m'{
tempname cov_a`i'_a`j'
}
}
* Calculate the variances and covariances
matrix `V'=e(V)
forvalues j=1/`m'{
forvalues i=1/`m'{
matrix `cov_a`i'_a`j''=`V'["Tw_`i'","Tw_`j'"]
scalar cov_a`i'_a`j'=`cov_a`i'_a`j''[1,1]
}
}
****************************************************************
** Generate the std. err. of ATE(t) using its variance's formula
****************************************************************
cap drop var_ate_t
gen var_ate_t = 0 if `touse' 
forvalues j=1/`m'{
forvalues i=1/`m'{
replace var_ate_t = var_ate_t + (T_`j'*T_`i')*cov_a`j'_a`i'  if `touse' 
}
}
replace var_ate_t=. if var_ate_t<=0  // eliminate negative or zer covariances.
capture drop se_ate_t
gen se_ate_t = sqrt(var_ate_t) if `touse' 
**************************************************************************
* Calculate the 99%, 95% and 90% confidence interval of ATET(t) for each t
**************************************************************************
if `ci'==1{
local cis=2.576
} 
if `ci'==5{
local cis=1.96
} 
if `ci'==10{
local cis=1.645
} 
gen `lim'=`cis'*se_ate_t  if `t'>0
gen `upper'=ATE_t+`lim'   if `t'>0
gen `lower'=ATE_t-`lim'   if `t'>0
* Graph the the DRF (i.e. ATE(t)) showing the the 95% confidence interval;
graph twoway mspline ATE_t   `t' if `t'>0, clwidth(medium) clcolor(blue) clcolor(black)   ///
        ||   mspline `upper' `t' if `t'>0, clpattern(dash) clwidth(thin) clcolor(black) ///
        ||   mspline `lower' `t' if `t'>0, clpattern(dash) clwidth(thin) clcolor(black) ///
        ||   ,   ///
		     name(DRFIC)    ///
             note("Model: `model'")   ///
			 xlabel(0 10 20 30 40 50 60 70 80 90 100, labsize(2.5)) ///
             ylabel(,   labsize(2.5)) ///
             yscale(noline) ///
             xscale(noline) ///
             legend(col(1) order(1 2) label(1 "ATE(t)") ///
                                      label(2 "`ci'% significance") ///
                                      label(3 " ")) ///
             title("Dose Response Function", size(4))  ///
             subtitle(" " "Outcome variable: `outcome' "" ", size(3)) ///
             xtitle(Dose (t), size(3)) ///
             xsca(titlegap(2)) ///
             ysca(titlegap(2)) ///
             ytitle("Response-function", size(3)) ///
             scheme(s2mono) graphregion(fcolor(white))

******************************************************************************
** Generate the std. err. of Derivative of ATE(t) using its variance's formula
******************************************************************************
cap drop var_der_ate_t
gen var_der_ate_t = 0 if `touse' 
forvalues j=0/`m'{
cap drop t_`j'
}
forvalues j=0/`m'{
gen t_`j'=(`t')^(`j') if `touse'  
}
forvalues j=1/`m'{
forvalues i=1/`m'{
local kj=`j'-1
local ki=`i'-1
replace var_der_ate_t = var_der_ate_t + (`j'*t_`kj')*(`i'*t_`ki')*cov_a`j'_a`i'  if `touse' 
}
}
replace var_der_ate_t=. if var_der_ate_t<=0  // eliminate negative or zero covariances.
capture drop se_der_ate_t
gen se_der_ate_t = sqrt(var_der_ate_t) if `touse' 

***************************************************************************************
* Calculate the 99%, 95% and 90% confidence interval of derivative of ATE(t) for each t
***************************************************************************************			 
gen `lim2'=`cis'*se_der_ate_t   if `t'>0
gen `upper2'=der_ATE_t+`lim2'   if `t'>0
gen `lower2'=der_ATE_t-`lim2'   if `t'>0
* Graph the the DRF (i.e. ATE(t)) showing the the 95% confidence interval;
capture graph drop DerDRFIC
graph twoway mspline der_ATE_t `t' if `t'>0, clwidth(medium) clcolor(blue) clcolor(black)   ///
        ||   mspline `upper2' `t' if `t'>0, clpattern(dash) clwidth(thin) clcolor(black) ///
        ||   mspline `lower2' `t' if `t'>0, clpattern(dash) clwidth(thin) clcolor(black) ///
        ||   ,   ///
		     name(DerDRFIC)    ///
             note("Model: `model'")   ///
			 xlabel(0 10 20 30 40 50 60 70 80 90 100, labsize(2.5)) ///
             ylabel(,   labsize(2.5)) ///
             yscale(noline) ///
             xscale(noline) ///
             legend(col(1) order(1 2) label(1 "Der_ATE(t)") ///
                                      label(2 "`ci'% significance") ///
                                      label(3 " ")) ///
             title("Derivative of the Dose Response Function", size(4))  ///
             subtitle(" " "Outcome variable: `outcome' "" ", size(3)) ///
             xtitle(Dose (t), size(3)) ///
             xsca(titlegap(2)) ///
             ysca(titlegap(2)) ///
             ytitle("Derivative of the Response-function", size(3)) ///
             scheme(s2mono) graphregion(fcolor(white))
			  
********************************************************************************
* Calculate the 99%, 95% and 90% confidence interval of ATE(t;delta) for each t
********************************************************************************	
if "`delta'"!=""{  // allows option for "delta"
cap drop var_ate_t_delta
gen var_ate_t_delta = 0 if `touse' 
forvalues j=1/`m'{
forvalues i=1/`m'{
replace var_ate_t_delta = var_ate_t_delta + (t_`j'-t_delta`j')*(t_`i'-t_delta`i')*cov_a`j'_a`i' if `touse' 
}
}
replace var_ate_t_delta=. if var_ate_t_delta<=0  // eliminate negative or zer0 covariances.
capture drop se_ate_t_delta
gen se_ate_t_delta = sqrt(var_ate_t_delta) if `touse' 
gen `lim3'=`cis'*se_ate_t_delta   if `t'>0
gen `upper3'=ATE_t_delta+`lim3'   if `t'>0
gen `lower3'=ATE_t_delta-`lim3'   if `t'>0
* Graph the the DRF (i.e. ATE(t)) showing the the 95% confidence interval;
capture graph drop DeltaDRFIC
graph twoway mspline ATE_t_delta `t' if `t'>0, clwidth(medium) clcolor(blue) clcolor(black) ///
        ||   mspline `upper3' `t' if `t'>0, clpattern(dash) clwidth(thin) clcolor(black) ///
        ||   mspline `lower3' `t' if `t'>0, clpattern(dash) clwidth(thin) clcolor(black) ///
        ||   ,   ///
		     name(DeltaDRFIC)    ///
             note("Model: `model' ; delta = `delta'")   ///
			 xlabel(0 10 20 30 40 50 60 70 80 90 100, labsize(2.5)) ///
             ylabel(,   labsize(2.5)) ///
             yscale(noline) ///
             xscale(noline) ///
             legend(col(1) order(1 2) label(1 "Der_ATE(t)") ///
                                      label(2 "`ci'% significance") ///
                                      label(3 " ")) ///
             title("Estimation of ATE(t;delta) = E[y(t+delta)-y(t)]", size(4))  ///
             subtitle(" " "Outcome variable: `outcome' "" ", size(3)) ///
             xtitle(Dose (t), size(3)) ///
             xsca(titlegap(2)) ///
             ysca(titlegap(2)) ///
             ytitle("ATE(t;delta)", size(3)) ///
             scheme(s2mono) graphregion(fcolor(white))
} // close option for "delta"		 
*
capture graph drop DRF1
graph twoway (mspline ATE_t `t'  if `t'>0, name(DRF1) ///
title("Model `model': Estimation of the Dose Response Function", size(medlarge)) ///
note(NOTE: y = `outcome') xtitle(Dose (t), size(3)) ytitle(ATE(t)) ///
scheme(s2mono) graphregion(fcolor(white)) ///
scale(1) lpattern(solid) lwidth(medthick) legend(off) legend(label(1 "Spline"))) ///

*
if "`delta'"!=""{  // allows option for "delta"
capture graph drop DRF2
graph twoway (mspline ATE_t_delta `t' if `t'>0, name(DRF2) ///
title("Model `model': Estimation of ATE(t;delta) = E[y(t+delta)-y(t)]", size(medlarge)) ///
note(NOTE: y = `outcome' ; delta = `delta') xtitle(Dose (t), size(3)) ytitle(ATE(t,delta)) ///
scheme(s2mono) graphregion(fcolor(white)) ///
scale(1) lpattern(solid) lwidth(medthick) legend(off) legend(label(1 "Spline"))) 
} // close option for "delta"
*
capture graph drop DRF3
graph twoway (mspline der_ATE_t `t' if `t'>0, name(DRF3) ///
title("Model `model': Derivative of the Dose Response Function", size(medlarge)) ///
note(NOTE: y = `outcome') ///
xtitle(Dose (t), size(3)) ytitle(ATE'(t)) ///
scheme(s2mono) graphregion(fcolor(white)) ///
scale(1) lpattern(solid) lwidth(medthick) legend(off) legend(label(1 "Spline"))) 
*
capture graph drop DRF4
graph twoway (mspline std_ATE_t `t' if `t'>0, name(DRF4)  ///
title("Model `model': Dose Response Function and its Derivative", ///
size(medlarge)) note(NOTE: y = `outcome' ; Standardized values.) ///
xtitle(Dose (t), size(3)) ytitle(ATE(t); ATE'(t)) ///
scheme(s2mono) graphregion(fcolor(white)) ///
scale(1) lpattern(solid) lwidth(medthick) legend(on) ///
legend(label(1 "DFR") label(2 "Derivative of the DRF"))) ///
(mspline std_der_ATE_t `t' if `t'>0)			 
end // End of the program "graph_ctic".

*****************************************************************
* This program (called "polyn") returns a local macro containing
* the regressors to estimate the dose-response-function through
* a polynomial of degree "m"
* These terms are: Tw_1, Tw_2, ... Tw_m.
*****************************************************************
*! polyn v1.0.0 GCerulli 02Aug2014
cap program drop polyn
program polyn, rclass
version 13
#delimit ;     
syntax varlist [if] [in] [fweight iweight pweight] ,
m(numlist max=1)
;
#delimit cr
*******************************************************
marksample touse
tokenize `varlist'
local ct `1'
local w `2'
forvalues j=1/`m'{
tempvar t_`j'
}
forvalues j=1/`m'{
gen `t_`j''=(`ct')^(`j') if `touse'  
}
forvalues j=1/`m'{
tempvar mean_t_`j'
}
forvalues j=1/`m'{
egen `mean_t_`j''=mean(`t_`j'') if `ct'!=. & `touse'
}
***********************************************************************
* DEMEAN THE ARGUMENTS AND GENERATE THE REGRESSORS "T*w"
***********************************************************************
forvalues j=1/`m'{
tempvar T_`j'
}
forvalues j=1/`m'{
gen `T_`j''=`t_`j''-`mean_t_`j'' if `touse' 
}
forvalues j=1/`m'{
cap drop Tw_`j'
}
forvalues j=1/`m'{
gen Tw_`j'=`T_`j''*`w' if `touse' 
}
***********************************************************************
* PUT THEM INTO THE LOCAL MACRO "treat" AND RUN THE BASIC REGRESSION
***********************************************************************
local treat
forvalues j=1/`m'{
local treat `treat' Tw_`j'
}                       
return local output "`treat'"						
end  // End of "polyn"

*****************************************************************
* This program (called "polynp") returns a local macro containing
* the regressors to estimate the dose-response-function 
* with IV through a polynomial of degree "m"
* These terms are: Tp_1, Tp_2, ... Tp_m.
*****************************************************************
*! polynp v1.0.0 GCerulli 02Aug2014
cap program drop polynp
program polynp, rclass
version 13
#delimit ;     
syntax varlist [if] [in] [fweight iweight pweight] ,
m(numlist max=1)
;
#delimit cr
*******************************************************
marksample touse
tokenize `varlist'
local ct `1'
local probw `2'
forvalues j=1/`m'{
tempvar t_`j'
}
forvalues j=1/`m'{
gen `t_`j''=(`ct')^(`j') if `touse'  
}
forvalues j=1/`m'{
tempvar mean_t_`j'
}
forvalues j=1/`m'{
egen `mean_t_`j''=mean(`t_`j'') if `ct'!=. & `touse'
}
***********************************************************************
* DEMEAN THE ARGUMENTS AND GENERATE THE REGRESSORS "T*w"
***********************************************************************
forvalues j=1/`m'{
tempvar T_`j'
}
forvalues j=1/`m'{
gen `T_`j''=`t_`j''-`mean_t_`j'' if `touse' 
}
forvalues j=1/`m'{
cap drop Tp_`j'
}
forvalues j=1/`m'{
gen Tp_`j'=`T_`j''*`probw' if `touse' 
}
***********************************************************************
* PUT THEM INTO THE LOCAL MACRO "treat" AND RUN THE BASIC REGRESSION
***********************************************************************
local treatp
forvalues j=1/`m'{
local treatp `treatp' Tp_`j'
}                       
return local output_p "`treatp'"
end // End of "polynp"
********************************************************************************
* END CTREATREG
********************************************************************************
