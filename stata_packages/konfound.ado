* updated Feb 2025
* Aligned konfound output with R
* Logistic model with dichotomous predictor support

capture program drop konfound
program define konfound, rclass
    version 13.1
    syntax varlist (min=1 max=10), [if] [in] [sig(real 0.05) onetail(real 0) uncond(real 0) non_li(real 0) n_treat(real 0) indx(str)]

	if "`indx'" == "" {
    local indx "RIR"
}
	
	if "`indx'" == "RIR" {
        di ""
        di "The default framework for the konfound command is now RIR (Robustness of"
        di "Inference to Replacement). To generate ITCV, enter: konfound ind_var, indx(IT)"
        di "where ind_var is the focal predictor."
    }
	
    if "`e(cmd)'" != "regress" & "`e(cmd)'" != "logit" {
    di as error "Error: konfound can only be used with linear regression (regress) or logistic regression (logit) models."
    exit
}

if "`e(cmd)'" == "logit" & "`n_treat'" == "0" {
        di as error "Warning: Please provide a value for n_treat to use this functionality with a dichotomous predictor. For example, konfound x1, n_treat(55), where n_treat=55 indicates 55 data points were assigned to the treatment."
        exit
		
    }

    ** Lock some features for updating
    local rep_0 = 0
    local nu = 0

    capture drop esti_ 
    capture drop thres_ 
    capture drop id_ 
    capture drop ttt_ 
    capture drop samused_
    capture drop _namelis 
    capture drop _count
    quietly gen esti_ = .
    quietly gen thres_ = .
    quietly gen id_ = ""

    local i = 0
    foreach x in `varlist' {
        local i = `i' + 1

        if `non_li' == 0 {
            local `x'coef = _b[`x']
            local `x'sd   = _se[`x']
        }

        if "`n_treat'" != "" {
            local sample_size = `n_treat'
            local n_treat = `n_treat'
        } 
		else {
            local sample_size = e(N)
        }
        
        if `non_li' == 1 {
            margins, dydx(`x')
            local `x'coef = el(r(b), 1, 1)
            local `x'sd = sqrt(el(r(V), 1, 1))
        }
    }

    if "`e(cmd)'" == "logit" & "`n_treat'" != "" {
        local var_count : word count `varlist'
        if `var_count' > 1 {
            di as error "Warning: Logistic regression detected. Please provide only one variable for konfound when using logistic regression."
            exit 1
        }

        local tested_var : word 1 of `varlist'
        local est_eff = string(_b[`tested_var'], "%9.3f")
        local std_err = _se[`tested_var']
        
        if "`n_treat'" != "0" {
            local sample_size = `n_treat'
        }

        local covariate_list : colnames e(b)
        local n_covariates = wordcount("`covariate_list'")

        if "`est_eff'" == "" | "`std_err'" == "" {
            di as error "Error: Unable to retrieve coefficient or standard error for the tested variable."
            exit
        }

        local n_covariates = e(df_m)
        
        if "`est_eff'" == "" | "`std_err'" == "" | "`e(N)'" == "" | "`n_covariates'" == "" | "`n_treat'" == "" {
            di as error "Warning: One or more parameters for pkonfound are missing. Please check est_eff, std_err, n_obs, n_covariates, and n_treat."
            exit
        }

        pkonfound `est_eff' `std_err' `e(N)' `n_covariates' `n_treat', model_type(1)
        exit
    }


		
local i=0
foreach x in `varlist' {
local i= `i'+1

if `non_li' == 0  {
  local `x'coef = _b[`x']
  local `x'sd   = _se[`x']
  }
else  {
  margins, dydx(`x')
  local `x'coef=el(r(b),1,1)
  local `x'sd=sqrt(el(r(V),1,1))
  }	
//for RIR
    if e(N_g) == . {
        local `x'criticalt = sign(``x'coef' - `nu') * invttail(e(N) - e(df_m) - 1, `sig' / (2 - `onetail'))
        
        ** 调试信息：输出计算的关键t值
        //di as text "Debug: Critical t-value for `x' = ``x'criticalt'"
    } 
	else {
        local `x'criticalt = sign(``x'coef' - `nu') * invttail(e(N) - e(df_m) - e(N_g), `sig' / (2 - `onetail'))
        
        ** 调试信息：输出计算的关键t值
        //di as text "Debug: Critical t-value for `x' = ``x'criticalt'"
    }

    ** 检查 criticalt 和 sd 是否有有效值
    if "`x'criticalt'" == "" | "`x'sd'" == "" {
        di as error "Error: Unable to calculate critical value or standard deviation is missing."
        exit
    }

    local `x'threshold = ``x'criticalt' * ``x'sd'

    ** 调试信息：输出计算的 threshold
    //di as text "Debug: Threshold for `x' = ``x'threshold'"
  if `rep_0'==1 {
  local `x'bias = string(100*(1- ((``x'threshold'+`nu')/``x'coef')),"%6.2f")
  }
  else {
  local `x'bias = string(100*(1- (``x'threshold'/(``x'coef'-`nu'))),"%6.2f")
  }
    if abs(``x'coef')> abs(``x'threshold'+`nu') {
    local `x'sustain = string(100*(1- ((``x'threshold'+`nu')/(``x'coef'))),"%6.2f")
	}
	else {
    local `x'sustain = string(100*(1- ((``x'coef')/((``x'threshold'+`nu')))),"%6.2f")
	}
 
 
  if `non_li' == 1  {
  dis "Note that if your model is a logistic regression we recommend using the pkonfound command for logistic regression with manually entered parameter estimates and other quantities."
  dis "Following calculation is based on Average Partial Effect:"
  }
  
 if ("`indx'" == "RIR"){ 
  dis ""
  dis "For variable `x'"
  dis ""
  dis "Robustness of Inference to Replacement (RIR)" 
  dis ""
  
  if (abs(``x'coef' - `nu')- abs(``x'threshold')) >=0  {
  	
  local `x'recase = round(e(N) * ``x'bias'/100,1)
  local `x'threshold = round(``x'threshold', 0.001)
  local `x'coef = round(``x'coef', 0.001)
  
  if `rep_0'==0 {
  
	dis "RIR = ``x'recase'" _newline ///

	dis "To nullify the inference of an effect using the threshold of ``x'threshold' for" _newline ///
	"statistical significance (with null hypothesis = `nu' and alpha = `sig'), ``x'bias'% " _newline ///
	"of the (``x'coef') estimate would have to be due to bias. This implies that to" _newline ///
	"nullify the inference one would expect to have to replace ``x'recase' (``x'bias'%) " _newline ///
	"observations with data points for which the effect is `nu' (RIR = ``x'recase')."
  
}
else {
  
	dis "RIR = ``x'recase'" _newline ///

	dis "To nullify the inference of an effect using the threshold of ``x'threshold' for" _newline ///
	"statistical significance (with null hypothesis = `nu' and alpha = `sig'), ``x'bias'% " _newline ///
	"of the (``x'coef') estimate would have to be due to bias. This implies that to" _newline ///
	"nullify the inference one would expect to have to replace ``x'recase' (``x'bias'%) " _newline ///
	"observations with data points for which the effect is zero (RIR = ``x'recase')."

}
  }
  else {
  	
  local `x'recase = round(e(N) * ``x'sustain'/100,1)
  local `x'threshold = round(``x'threshold', 0.001)
  local `x'coef = round(``x'coef', 0.001)
  
  dis "RIR = ``x'recase'" _newline ///
  
  dis "To sustain the inference of an effect using the threshold of ``x'threshold' for" _newline ///
  "statistical significance (with null hypothesis = `nu' and alpha = `sig'), ``x'sustain'% " _newline ///
  "of the (``x'coef') estimate would have to be due to bias. This implies that to" _newline ///
  "sustain the inference one would expect to have to replace ``x'recase' (``x'sustain'%) " _newline ///
  "observations with data points for which the effect is ``x'threshold' (RIR = ``x'recase')."
  
  }
 }
  
if e(r2_p)!=. & `non_li' == 0 {
dis ""
dis "Warnings:"
dis "For a non-linear model calculation based on average partial effect is recommended, in the options use non_li(1)."
dis ""
dis "For a non-linear model users might also want to consider alternative standard error estimation methods,"_newline "such as the bootstrapping method."
dis "To use the bootstrapping method type [bootstrap, reps(#):] before your original command."
}  
  
if  ``x'bias' > 0 & `nu' == 0 & ``x'sd' != 0{

quietly replace esti_= abs(``x'coef') - abs(``x'threshold') in `i'
quietly replace thres_= abs(``x'threshold') in `i'
quietly replace id_ = "`x'" in `i'

 }

  }
  quietly egen ttt_= max(esti_)
if ttt_[1]!=. {
   graph bar thres_ esti_, over(id_) stack  legend( label(1 "threshold") label(2 "estimate") )
 }
  
drop thres_ esti_ id_ ttt_ 

local NN = e(N)
local dfm = e(df_m)
local Ng = e(N_g)
local prsq= e(r2_p)
local Dep= e(depvar)
gen samused_=e(sample)
local Rsq = e(r2)
quietly sum `Dep' if samused_==1
local VarY= r(Var)

quietly indeplist
local Ncov= wordcount(r(X))
quietly gen _namelis=r(X) in 1
quietly moss _namelis, match("([c0-9]+[\.].[^ ]*)") regex
local abc =_count[1]

forvalues xyz = 1/`abc'  {

quietly replace _namelis = subinword(_namelis,_match`xyz'[1],"",.) in 1
drop _pos`xyz' _match`xyz'
}

local namelist  = _namelis[1] 

local Nz= `Ncov' - _count[1] - 1
 
foreach x in `varlist' {

if `non_li' == 0  {
  local `x'coef = _b[`x']
  local `x'sd   = _se[`x']
  }
else  {
  quietly margins,dydx(`x')
  local `x'coef=el(r(b),1,1)
  local `x'sd=sqrt(el(r(V),1,1))
  }

}

//for ITCV
foreach x in `varlist'{ 
  
if `Ng'==. {
local `x'criticalt =sign(``x'coef' - `nu') *  invttail(`NN'-`dfm'-1,`sig'/(2 - `onetail'))
local `x'be_th = ``x'criticalt' * ``x'sd' +`nu'
local `x't_critr = ``x'be_th'/``x'sd'
local `x'r_crit = ``x't_critr'/sqrt((``x't_critr')^2 + (`NN'-`dfm'-1))
local `x'r_obs = (``x'coef'/``x'sd')/sqrt((``x'coef'/``x'sd')^2 +(`NN'-`dfm'-1))
}
else {
//degrees of freedom calculated as in Xtreg including use of one degree of freedom to estimate a parameter for each group
local `x'criticalt =sign(``x'coef' - `nu') *  invttail(`NN'-`dfm'-`Ng',`sig'/(2 - `onetail'))
local `x'be_th = ``x'criticalt' * ``x'sd' +`nu'
local `x't_critr = ``x'be_th'/``x'sd'
local `x'r_crit = ``x't_critr'/sqrt((``x't_critr')^2 + `NN'-`dfm'-`Ng')
local `x'r_obs = (``x'coef'/``x'sd')/sqrt((``x'coef'/``x'sd')^2 +`NN'-`dfm'-`Ng')
}

if (`dfm' > 1) {
	local `x'RsqYZ = ((``x'r_obs')^2 - `Rsq')/((``x'r_obs')^2 - 1)
}
else{
    local `x'RsqYZ = .
}

quietly sum `x' if samused_==1
local `x'VarX= r(Var)

if (`dfm' > 1) {
    local `x'RsqXZ = 1 - ((`VarY'*(1-`Rsq'))/(``x'VarX'*(`NN'-`dfm'-1)*((``x'sd')^2)))
}
else{
	local `x'RsqXZ = .
}
//what is for nested data?
if (``x'coef' < ``x'be_th') {
		local `x'signITCV = -1
		}
else if (``x'coef' > ``x'be_th') {
	  	local `x'signITCV = 1
		}
else if (``x'coef' == ``x'be_th') {
		local `x'signITCV = 0
		} 	

if (``x'r_obs' - ``x'r_crit') >= 0 {
  local `x'itcv = (``x'r_obs' - ``x'r_crit')/(1 -``x'r_crit')
  }
else {
  local `x'itcv = (``x'r_obs' - ``x'r_crit')/(1 +``x'r_crit')
  }
  
//"%9.3f"
local `x'impact = string(``x'itcv',"%9.3f")
local `x'r_con = string(sqrt(abs(``x'itcv')),"%9.3f")
local `x'rr_con = sqrt(abs(``x'itcv'))
local `x'nr_con = string(-1 * ``x'r_con',"%9.3f")
 
if (`dfm' > 1) {
 local `x'r_xcv = string(``x'rr_con' * sqrt(1-(``x'RsqXZ')),"%9.3f")
    if (``x'itcv') <0{
	    local `x'rr_ycv = -1 * ``x'rr_con' * sqrt(1-(``x'RsqYZ'))
		local `x'r_ycv = string(-1 * ``x'rr_con' * sqrt(1-(``x'RsqYZ')),"%9.3f")
	}
	else{
	    local `x'rr_ycv = ``x'rr_con' * sqrt(1-(``x'RsqYZ'))
		local `x'r_ycv = string(``x'rr_con' * sqrt(1-(``x'RsqYZ')),"%9.3f")
	}
 local `x'rr_xcv = ``x'rr_con' * sqrt(1-(``x'RsqXZ'))
 local `x'nr_xcv = -1 * ``x'r_xcv'
 local `x'un_itcv = ``x'itcv'*sqrt(1-(``x'RsqYZ'))*sqrt(1-(``x'RsqXZ'))
 local `x'un_impact = string(``x'un_itcv',"%9.3f")
}
else{
   if (``x'itcv') <0{
       local `x'rr_ycv = -1* ``x'rr_con'
	   local `x'r_ycv = string(``x'nr_con',"%9.3f")
     }
   else{
       local `x'rr_ycv = ``x'rr_con'
	   local `x'r_ycv = string(``x'r_con',"%9.3f")
 }
 local `x'r_xcv = string(``x'r_con',"%9.3f")
 local `x'rr_xcv = ``x'rr_con'
 local `x'un_itcv = ``x'itcv'
 local `x'un_impact = string(``x'itcv',"%9.3f")
}

local `x'uncond_rycv = round(``x'rr_con' * sqrt(1-(``x'RsqYZ')) * ``x'signITCV', 0.001)
local `x'uncond_rxcv = round(``x'rr_con' * sqrt(1-(``x'RsqXZ')) * ``x'signITCV', 0.001)

local `x'rycvGz = round(``x'rr_con' * ``x'signITCV', 0.001)
local `x'rxcvGz = round(``x'rr_con', 0.001)

local uncond_impact = round(``x'r_ycv' * ``x'r_xcv', 0.001)
local impact = round(``x'rycvGz' * ``x'rxcvGz', 0.001)



if ("`indx'" == "IT"){ 
	dis ""
	dis "For variable `x'"
	dis ""
    dis "Impact Threshold for a Confounding Variable (ITCV)"
	dis ""
 if abs(``x'r_obs') > abs(``x'r_crit') & ``x'r_obs' > 0 {

 	local `x'r_crit = round(``x'r_crit', 0.001)

    // Unconditional ITCV
    dis "Unconditional ITCV:"
    dis "The minimum impact of an omitted variable to nullify an inference for"
    dis "a null hypothesis of an effect of `nu' is based on a correlation of ``x'r_ycv'"
	dis "with the outcome and ``x'r_xcv' with the predictor of interest (BEFORE conditioning" 
	dis "on observed covariates; signs are interchangeable if they are different)."
    dis "This is based on a threshold effect of ``x'r_crit' for statistical significance (alpha = `sig')."
    dis ""
    dis "Correspondingly, the UNCONDITIONAL impact of an omitted variable (as defined in Frank 2000) must be"
    dis "``x'r_ycv' × ``x'r_xcv' = `uncond_impact' to nullify an inference for a null hypothesis of an effect of nu (`nu')."
	dis ""
	
	// Conditional ITCV
    dis "Conditional ITCV:"
    dis "The minimum impact of an omitted variable to nullify an inference for"
    dis "a null hypothesis of an effect of `nu' is based on a correlation of ``x'rycvGz'"
	dis "with the outcome and ``x'rxcvGz' with the predictor of interest (conditioning on all"
	dis "observed covariates in the model; signs are interchangeable if they are different)."
    dis "This is based on a threshold effect of ``x'r_crit' for statistical significance (alpha = `sig')."
    dis ""
    dis "Correspondingly, the impact of an omitted variable (as defined in Frank 2000) must be"
    dis "``x'rycvGz' × ``x'rxcvGz' = `impact' to nullify an inference for a null hypothesis of an effect of nu (`nu')."
	
}
else if abs(``x'r_obs') > abs(``x'r_crit') & ``x'r_obs' < 0 {

	local `x'r_crit = round(``x'r_crit', 0.001)

    // Unconditional ITCV
    dis "Unconditional ITCV:"
    dis "The minimum (in absolute value) impact of an omitted variable to nullify an inference"
    dis "for a null hypothesis of an effect of `nu' is based on a correlation of ``x'r_ycv' with the"
	dis "outcome and ``x'r_xcv' with the predictor of interest (BEFORE conditioning on observed covariates;" 
	dis "signs are interchangeable if they are different). This is based on a threshold effect of ``x'r_crit'"
    dis "for statistical significance (alpha = `sig')."
    dis ""
    dis "Correspondingly, the UNCONDITIONAL impact of an omitted variable (as defined in Frank 2000) must be"
    dis "``x'r_ycv' × ``x'r_xcv' = `uncond_impact' to nullify an inference for a null hypothesis of an effect of nu (`nu')."
	dis ""
	
	// Conditional ITCV
    dis "Conditional ITCV:"
    dis "The minimum (in absolute value) impact of an omitted variable to nullify an inference"
    dis "for a null hypothesis of an effect of `nu' is based on a correlation of ``x'rycvGz' with the"
	dis "outcome and ``x'rxcvGz' with the predictor of interest (conditioning on all observed covariates"
	dis "in the model; signs are interchangeable if they are different). This is based on a threshold"
    dis "effect of ``x'r_crit' for statistical significance (alpha = `sig')."
    dis ""
    dis "Correspondingly, the impact of an omitted variable (as defined in Frank 2000) must be"
    dis "``x'rycvGz' × ``x'rxcvGz' = `impact' to nullify an inference for a null hypothesis of an effect of nu (`nu')."

}
else if abs(``x'r_obs') < abs(``x'r_crit') & ``x'r_obs' >= 0 {

	local `x'be_th = round(``x'be_th', 0.001)

    // Unconditional ITCV
    dis "Unconditional ITCV:"
    dis "The maximum (in absolute value) impact of an omitted variable to sustain an inference"
    dis "for a null hypothesis of an effect of `nu' is based on a correlation of ``x'r_ycv' with"
	dis "the outcome and ``x'r_xcv' with the predictor of interest (BEFORE conditioning on observed" 
	dis "covariates; signs are interchangeable if they are different). This is based on a threshold"
    dis "effect of ``x'be_th' for statistical significance (alpha = `sig')."
    dis ""
    dis "Correspondingly, the UNCONDITIONAL impact of an omitted variable (as defined in Frank 2000) must be"
    dis "``x'r_ycv' × ``x'r_xcv' = `uncond_impact' to sustain an inference for a null hypothesis of an effect of nu (`nu')."
	dis ""
	
	// Conditional ITCV
    dis "Conditional ITCV:"
    dis "The maximum (in absolute value) impact of an omitted variable to sustain an inference"
    dis "for a null hypothesis of an effect of `nu' is based on a correlation of ``x'rycvGz' with"
	dis "the outcome and ``x'rxcvGz' with the predictor of interest (conditioning on all observed"
	dis "covariates in the model; signs are interchangeable if they are different). This is"
    dis "based on a threshold effect of ``x'be_th' for statistical significance (alpha = `sig')."
    dis ""
    dis "Correspondingly, the impact of an omitted variable (as defined in Frank 2000) must be"
    dis "``x'rycvGz' × ``x'rxcvGz' = `impact' to sustain an inference for a null hypothesis of an effect of nu (`nu')."

}
else if abs(``x'r_obs') < abs(``x'r_crit') & ``x'r_obs' < 0 {

	local `x'be_th = round(``x'be_th', 0.001)

    // Unconditional ITCV
    dis "Unconditional ITCV:"
    dis "The maximum impact of an omitted variable to sustain an inference for a null hypothesis"
    dis "of an effect of `nu' is based on a correlation of ``x'r_ycv' with the outcome and ``x'r_xcv'"
	dis "with the predictor of interest (BEFORE conditioning on observed covariates; signs are" 
	dis "interchangeable if they are different). This is based on a threshold effect of ``x'be_th'"
    dis "for statistical significance (alpha = `sig')."
    dis ""
    dis "Correspondingly, the UNCONDITIONAL impact of an omitted variable (as defined in Frank 2000) must be"
    dis "``x'r_ycv' × ``x'r_xcv'= `uncond_impact' to sustain an inference for a null hypothesis of an effect of nu (`nu')."
	dis ""
	
	// Conditional ITCV
    dis "Conditional ITCV:"
    dis "The maximum impact of an omitted variable to sustain an inference for a null hypothesis"
    dis "of an effect of `nu' is based on a correlation of ``x'rycvGz' with the outcome and ``x'rxcvGz'"
	dis "with the predictor of interest (conditioning on all observed covariates in the model;"
	dis "signs are interchangeable if they are different). This is based on a threshold effect of"
    dis "``x'be_th' for statistical significance (alpha = `sig')."
    dis ""
    dis "Correspondingly, the impact of an omitted variable (as defined in Frank 2000) must be"
    dis "``x'rycvGz' × ``x'rxcvGz' = `impact' to sustain an inference for a null hypothesis of an effect of nu (`nu')."

}
}

*dis ""
*dis "konfound command should only be run immediately after a model is estimated." 
*dis "No other commands should be entered between estimating the model and running konfound."

if ("`indx'" == "IT"){ 
dis ""
dis "For exact values calculated by ITCV, include 'return list' following the konfound command."

if `Nz'>0 {
dis ""
dis "These thresholds can be compared with the impacts of observed covariates below."
}

}


//return the core statistics
return scalar itcv = ``x'itcv'
return scalar unconitcv = ``x'un_itcv'

if ("`indx'" == "RIR"){ 
return scalar rir = ``x'recase'
}

return scalar thr = ``x'threshold'
return scalar RsqYZ = ``x'RsqYZ'
return scalar RsqXZ = ``x'RsqXZ'
return scalar Rsq = `Rsq'
return scalar r_ycv = ``x'rr_ycv'
return scalar r_xcv = ``x'rr_xcv'

if ("`indx'" == "IT"){ 

if `Nz'>0 {

	local `x'namelist1=trim(subinword("`namelist'","`x'","",.))

	quietly corr `x' ``x'namelist1' if samused_ ==1
	matrix rvx1 = r(C)
	mat rvx = rvx1[2..`Nz'+1, 1]

	quietly corr `Dep' ``x'namelist1' if samused_ ==1
	matrix rvy1 = r(C)
	mat rvy = rvy1[2..`Nz'+1, 1]

	matrix imp_raw = J(`Nz',1,0)
	forvalues i = 1/`Nz' {
			 matrix imp_raw[`i',1]= rvx[`i',1] * rvy[`i',1]	
			 }
			 }
if `Nz'>1 {
	quietly pcorr `x' ``x'namelist1' if samused_ ==1
	matrix prvx1 = r(p_corr) 
	mat prvx = prvx1[1..`Nz', 1]

	quietly pcorr `Dep' ``x'namelist1' if samused_ ==1
	matrix prvy1 = r(p_corr) 
	mat prvy = prvy1[1..`Nz', 1]

	matrix imp_par = J(`Nz',1,0)
	forvalues i = 1/`Nz' {
			 matrix imp_par[`i',1]= prvx[`i',1] * prvy[`i',1]	
			 }
			 }

if `Nz'>0 {

	mat Impact_Table=J(`Nz',3,0)
	mat Impact_Table2=J(`Nz',3,0)
	forvalues i = 1/`Nz' {
			 matrix Impact_Table[`i',1]= round(rvx[`i',1],.0001)
			 matrix Impact_Table[`i',2]= round(rvy[`i',1],.0001)
			 matrix Impact_Table[`i',3]= round(imp_raw[`i',1],.0001)
			 if `Nz'>1 {
			 matrix Impact_Table2[`i',1]= round(prvx[`i',1],.0001)
			 matrix Impact_Table2[`i',2]= round(prvy[`i',1],.0001)
			 matrix Impact_Table2[`i',3]= round(imp_par[`i',1],.0001)
			 }
			 
			 }


matrix rownames Impact_Table = ``x'namelist1'
matrix colnames Impact_Table = "Cor(vX)" "Cor(vY)" "Impact" 
matrix rownames Impact_Table2 = ``x'namelist1'
matrix colnames Impact_Table2 = "Cor(vX)" "Cor(vY)" "Impact"

matsort Impact_Table 3 down
matsort Impact_Table2 3 down

matlist Impact_Table, title("Observed Impact Table for `x'") border(all) rowtitle("Raw") lines(co) format(%15.6f)

if `Nz'>1 {
	matlist Impact_Table2, border(all)  rowtitle("Partial") lines(co) format(%15.6f)

}

if `Nz'>1 {
	dis ""
	dis "X represents `x', Y represents `Dep', v represents each covariate." _newline "First table is based on raw (unconditional) correlations, second table" _newline "is based on partial (conditional) correlations."
}

if `Nz'==1 {
	dis ""
	dis "X represents `x', Y represents `Dep', v represents each covariate." _newline "Table is based on raw (unconditional  correlations."
}

matrix drop Impact_Table Impact_Table2  imp_raw  rvy1 rvy  rvx rvx1

if `Nz'>1 {
 matrix drop imp_par prvy1 prvy prvx1 prvx
 }
 }
 
*drop samused_ _namelis _count

  if `prsq'!=. {
dis ""
 dis "Warnings:"
 dis "For a non-linear model impact threshold should not be used."
 dis ""
 }
}
}
 dis ""
 dis "konfound command should only be run immediately after a model is estimated." 
 dis "No other commands should be entered between estimating the model and running konfound."
 dis ""
 dis "See Frank et al. (2013) for a description of the method."
 dis ""
 dis "Citation: Frank, K.A., Maroulis, S., Duong, M., and Kelcey, B. (2013)."
 dis "What would it take to change an inference?"
 dis "Using Rubin's causal model to interpret the robustness of causal inferences."
 dis "Education, Evaluation and Policy Analysis, 35, 437-460."	
 
end

