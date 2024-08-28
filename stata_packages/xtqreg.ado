* Version 1.5 - 30 Sep 2021
* By J.A.F. Machado and J.M.C. Santos Silva
* Please email jmcss@surrey.ac.uk for help and support


* The software is provided as is, without warranty of any kind, express or implied, including 
* but not limited to the warranties of merchantability, fitness for a particular purpose and 
* noninfringement. In no event shall the author be liable for any claim, damages or other 
* liability, whether in an action of contract, tort or otherwise, arising from, out of or in 
* connection with the software or the use or other dealings in the software.

prog define xtqreg, eclass
version 14.0
 if replay() {
                _prefix_display
                exit
        }
syntax varlist(numeric min=2 fv) [if] [in] ,  [ Id(string) Quantile(numlist) SAVEfe(string) ls Predict(string)]  
marksample touse 
markout `touse' 
tempname _obsr _ones alpha alphat gammat gamma b be V Ve u up au auhat deltas g xm inprod si k O auhat2 aauhat Qxx Pxx Px XI us s_hat ///
us2 bpost Vpost vp uv av v2 si2 w uw avw w2 Q V_location V_scale  Vmss 
gettoken _y _rhs: varlist

fvexpand `_rhs',
local _rhs `r(varlist)'
capture xtset
if ("`id'"=="")&("`r(panelvar)'"!="") local id "`r(panelvar)'"
if ("`id'"=="")&("`r(panelvar)'"=="") {
 di
 di as error "Must specify panelvar; use xtset or the id option"
 exit          
 }
if ("`quantile'"=="") {
local quantile .5        
 }
foreach x in `quantile'{
if (`x'>=1)|(`x'<=0) {
di as error "quantiles must be between 0 and 1"
exit 
}
}
di
di
di
di as txt "                              MM-QR regression results"
qui xtreg `_y' `_rhs' if `touse', fe i(`id') robust
if  e(g_max) < 3 {
 di
 di as error "It is not possible to identify the conditional quantiles with T<3; the estimator is valid only for large T"
 exit 
}
qui g `_obsr'=_n
local enne=e(N)
di as txt "Number of obs = "  _continue
di as result   `enne'
if ("`savefe'" != "")|("`predict'" != "") {
qui predict `alpha' , u
qui bysort `id': egen `alphat'=min(`alpha')
qui replace `alpha'=`alphat'+_b[_cons] 
}
if ("`ls'" != "") {
di
di as input "                                                           Location parameters"
ereturn display
} 
matrix `be'=e(b)
matrix `Ve'=e(V)
matrix `V_location'=e(V)
qui predict double `u' if `touse', e
qui g double `up'=(`u')>=0 if `touse'
su `up' if `touse', meanonly
qui replace `up'=(`up')-r(mean) if `touse'
qui g double `au'=(`u')*(`up')*2  if `touse'
qui xtreg `au' `_rhs' if `touse', fe i(`id') robust
if ("`savefe'" != "")|("`predict'" != "") {
qui predict `gamma' , u
qui bysort `id': egen `gammat'=min(`gamma')
qui replace `gamma'=`gammat'+_b[_cons]
}
if ("`ls'" != "") {
ereturn local depvar = "  "
di as input "                                                              Scale parameters"
ereturn display 
di
ereturn local depvar = "`au'"
}
matrix `g'=e(b)
matrix `V_scale'=e(V)
qui predict double `deltas'  , u
qui predict double `auhat' , xbu
qui g `s_hat' = (`auhat')<=0 if `touse'
su `s_hat' if `touse', meanonly 
if r(max)==1 di as error "WARNING: " 100*r(mean) "% of the fitted values of the scale function are not positive"
qui g double `us'=(`u')/(`auhat') if `touse'

qui g  byte  `_ones'=1 if `touse'
su `_ones' if `touse', meanonly
qui replace `_ones'=`_ones'/r(sum) if `touse'
mat veca `xm' = `_ones' `_rhs' if `touse'

mat `inprod' = (`xm')*(`g')'
qui g double `si'=(`deltas')+`inprod'[1,1] if `touse'

mat `k' = colsof(`g')
local k=`k'[1,1]-1
mat `be'=`be'[1..1,1..`k']
mat `g'=`g'[1..1,1..`k']
matrix `V_location'=`V_location'[1..`k',1..`k']
matrix `V_scale'=`V_scale'[1..`k',1..`k']

qui g double `auhat2'=(`auhat')^2 if `touse'
qui g double `aauhat'=abs(`auhat') if `touse'


local _regsm " "
foreach x in `_rhs' {
local cnt=`cnt'+1
tempvar nv`cnt'
qui bysort `id': egen `nv`cnt''=mean(`x') if `touse'
qui replace `nv`cnt''=`x'-`nv`cnt'' if `touse'
local _regsm "`_regsm' `nv`cnt''"
}
sort `_obsr'   

qui matrix accum `Qxx' = `_regsm' if `touse', noconst
qui matrix opaccum `Pxx' = `_regsm' if `touse', opvar(`aauhat') group(`_obsr') noconst
qui matrix vecaccum `Px' = `auhat2' `_regsm' if `touse', noconst
drop `_regsm'

mat `O'=J(`k'*2+1,`k'*2+1,0)
mat `XI'=J(`k',`k'*2+1,0)
mat `Ve'=`Ve'[1..`k',1..`k']
su `si' if `touse', meanonly
matrix `XI'[1,`k'*2+1]=(`g')'*(1/r(sum))
matrix `XI'[1,1]=invsym(`Qxx')

qui g double `us2'=(`us')^2 if `touse' 
su `us2' if `touse', meanonly
matrix `O'[1,1]=r(mean)*`Pxx'

qui g double `vp'=(`us')>=0 if `touse'
su `vp' if `touse', meanonly
qui replace `vp'=(`vp')-r(mean) if `touse'
qui g double `av'=(`us')*(`vp')*2 if `touse'

qui g double `uv'=(`us')*(`av') if `touse'
su `uv' if `touse', meanonly
matrix `O'[1,`k'+1]=r(mean)*`Pxx'
matrix `O'[`k'+1,1]=r(mean)*`Pxx'

qui g double `v2'=(`av')^2 if `touse'
su `v2' if `touse', meanonly
matrix `O'[`k'+1,`k'+1]==r(mean)*`Pxx'

qui g `si2'=(`si')^2 if `touse'
su `si2' if `touse', meanonly
local msi2=r(mean)

qui g double `w'=.
qui g double `uw'=.
qui g double `avw'=.
qui g double `w2'=.

foreach qu in `quantile' {

qui qreg `us' if `touse', q(`qu') vce(iid) nolog 
matrix `Q'=e(b)
local fuq=sqrt(`qu'*(1-`qu'))/(_se[_cons]*sqrt(e(N)))
qui replace `w'=(`qu'-((`us')<=`Q'[1,1]))/(`fuq') - (`us') - `Q'[1,1]*(`av') if `touse'
matrix `b'=`be'+(`g')*`Q'[1,1]
if ("`savefe'" != "") {
local __fe_q=ustrtoname("`savefe'_`qu'")
qui g `__fe_q' = `alpha'+`Q'[1,1]*`gamma'
}
if ("`predict'" != "") {
local __p_q=ustrtoname("`predict'_`qu'")
qui mat score `__p_q'=`b'
qui replace `__p_q'=`__p_q'+`alpha'+`Q'[1,1]*`gamma'
}

qui replace `uw'=(`us')*(`w') if `touse'
su `uw' if `touse', meanonly
mat `O'[`k'*2+1,1]=r(mean)*`Px'
mat `O'[1,`k'*2+1]=r(mean)*(`Px')'

qui replace `avw'=(`av')*(`w') if `touse'
su `avw' if `touse', meanonly
mat  `O'[`k'*2+1,`k'+1]=r(mean)*`Px'
mat  `O'[`k'+1,`k'*2+1]=r(mean)*(`Px')'

qui replace `w2'=(`w')^2 if `touse'
su `w2' if `touse', meanonly
mat `O'[`k'*2+1,`k'*2+1] = r(sum)*(`msi2')

matrix `XI'[1,`k'+1]=invsym(`Qxx')*`Q'[1,1]
matrix `Vmss'=`XI'*`O'*(`XI')'

mat `Ve'[1,1]=`Vmss'
mat `Vpost'=`Ve'
mat `bpost'=`b'

local __b_q=ustrtoname("__b`qu'")
matrix `__b_q' = `b'
local __V_q=ustrtoname("__V`qu'")
matrix `__V_q' = `Ve'
local __Q_q=ustrtoname("__Q`qu'")
matrix `__Q_q' = `Q'

di as txt `qu' " Quantile regression" 
ereturn post `bpost' `Vpost'
ereturn display
di
}
mat `Vpost'=`Ve'
mat `bpost'=`b'
ereturn post `bpost' `Vpost', obs(`enne') e(`touse') 
ereturn local cmd = "xtqreg"
ereturn local depvar = "`_y'"
ereturn matrix b_location = `be'
ereturn matrix b_scale = `g'
ereturn matrix V_location = `V_location'
ereturn matrix V_scale = `V_scale'
ereturn matrix q = `Q'
local wq : word count `quantile' 
if `wq' > 1 foreach qu in `quantile' {
local __b_q=ustrtoname("__b`qu'")
local _b_q=ustrtoname("b`qu'")
ereturn matrix `_b_q' = `__b_q'
local __V_q=ustrtoname("__V`qu'")
local _V_q=ustrtoname("V`qu'")
ereturn matrix `_V_q' = `__V_q'
local __Q_q=ustrtoname("__Q`qu'")
local _Q_q=ustrtoname("q`qu'")
ereturn matrix `_Q_q' = `__Q_q'
}
qui ereturn display
ereturn local cmd xtqreg
ereturn local cmdline xtqreg `0'
end
