capture program drop selmlog
program define selmlog

*version 13 of selmlog
*authors: Martin Fournier & Marc Gurgand - nov 2005 - corrected august 2006;

version 6.0

syntax varlist [if] [in], SELect(string) [LEE DMF(string) DHL(string) SHOWmlogit WLS BOOTstrap(string) MLOPtions(string) GEN(string)]

tokenize `varlist'
local y `1'

tokenize `bootstrap', parse(" ")
local K `1'
macro shift
local ssample `2'

tempname a 

if "`bootstrap'"=="" {
base `varlist' `if' `in', select(`select') `lee' dmf(`dmf') dhl(`dhl') `showmlogit' `wls' mloptions(`mloptions') gen(`gen')
}
else {
tempname b bstrv

local k=1
while `k'<=`K' {
preserve
bsample `ssample'
base `varlist' `if' `in', select(`select') `lee' dmf(`dmf') dhl(`dhl') `wls' bootstrap mloptions(`mloptions')
tempname b`k'
mat `b`k''=e(b)
mat coleq `b`k''="`y'"

if "`dhl'"=="" {
mat `b`k''=`b`k'',e(a)
}

if `k'==1 {
matrix `b'=`b`k''
}
if `k'>1 {
matrix `b'=`b'+`b`k''
}	
restore
local k=`k'+1
}

local k=1
while `k'<=`K' {
if `k'==1 {
matrix `bstrv'=(`b`k'' - (`b'/`K'))'*(`b`k'' - (`b'/`K'))
}
if `k'>1 {
matrix `bstrv'=`bstrv'+(`b`k'' - (`b'/`K'))'*(`b`k'' - (`b'/`K'))
}
local k=`k'+1
}
matrix `bstrv'=`bstrv'/(`K'-1)

base `varlist' `if' `in', select(`select') `lee' dmf(`dmf') dhl(`dhl') `showmlogit' `wls' bootstrap mloptions(`mloptions') gen(`gen')
matrix `b'=e(b)
mat coleq `b'="`y'"
if "`dhl'"=="" {
mat `b'=`b',e(a)
}

estimates post `b' `bstrv', depname("`y'") 
di _newline
di _newline
di in green "Selectivity correction based on multinomial logit"
di in green "Second step regression"
di in green "Bootstrapped standard errors (`K' replications)"
estimates display

if "`dhl'"~="" & "`wls'"=="wls" {
di in red "wls not implemented for dhl method"
}
} 
*(else)

drop _m*
end
*(selmlog)

capture program drop glquad
program define glquad
version 6.0

local mp="`1'"
local vp="`2'"
local p="`3'"

local x1=.093307812017
local x2=.492691740302
local x3=.1215595412071*10
local x4=.2269949526204*10
local x5=.3667622721751*10
local x6=.5425336627414*10
local x7=.7565916226613*10
local x8=.101220228568019*100
local x9=.13130282482176*100
local x10=.16654407708330*100
local x11=.20776478899449*100
local x12=.25623894226729*100
local x13=.31407519169754*100
local x14=.38530683306486*100
local x15=.48026085572686*100

local w1=.218234885940
local w2=.342210177923
local w3=.263027577942
local w4=.126425818106
local w5=.402068649210*1e-1
local w6=.856387780361*1e-2
local w7=.121243614721*1e-2
local w8=.111674392344*1e-3
local w9=.645992676202*1e-5
local w10=.222631690710*1e-6
local w11=.422743038498*1e-8
local w12=.392189726704*1e-10
local w13=.145651526407*1e-12
local w14=.148302705111*1e-15
local w15=.160059490621*1e-19

qui gen `mp'=0
qui gen `vp'=0
local i=1
while `i'<=15 {		
qui replace `mp'=`mp'+`w`i''*invnorm(exp(-`p'*`x`i''))
qui replace `vp'=`vp'+`w`i''*(invnorm(exp(-`p'*`x`i'')))^2
local i=`i'+1
}

end
*(glquad)

capture program drop base
program define base, eclass
version 6.0

syntax varlist [if] [in], SELect(string) [LEE DMF(string) DHL(string) SHOWmlogit WLS BOOTstrap MLOPtions(string) GEN(string)]

tempvar smpl
gen `smpl'=1

tokenize `dhl', parse(" ")
local order `1'
local prnb `2'
	
tokenize `dmf', parse(" ")
local variant `1'
if "`dmf'"=="" {
local variant=.
}

tokenize `select', parse("=")
local m `1'
macro shift
local z `2'

tokenize `varlist'
local y `1'
macro shift
while "`1'"~="" {
qui replace `smpl'=0 if `1'==. & `y'~=.
macro shift
}

if "`lee'"=="" & "`dmf'"=="" & "`dhl'"==""  {
di in red "Method option not specified"
exit
}
if ("`lee'"~="" & ("`dmf'"~="" | "`dhl'"~="")) | ("`dmf'"~="" & "`dhl'"~="")  {
di in red "Too many method options specified"
exit
}

qui sum `smpl'
if r(mean)~=1 {
di in red "Beware: the mlogit step uses observations that have missing values in the main equation"
}

if "`showmlogit'"=="showmlogit" {
mlogit `m' `z' `if' `in', `mloptions'
}
else {
qui mlogit `m' `z' `if' `in', `mloptions'
}		 
local nselcat=0
global m
local n=colsof(e(cat))

local i=1
while `i'<=`n' {
local cat`i'=el(e(cat),1,`i')
tempname P`i'
qui predict `P`i'' if e(sample), outcome(`cat`i'')
qui sum `y' if `m'==`cat`i''
if r(mean)~=. {
local selcat=`cat`i''
local nselcat=`nselcat'+1
}
if `nselcat'>1 {
di in red "Non-missing values of dependent variable for more than one outcome" 
exit
}
local i=`i'+1
}

local i=1
while `i'<=`n' {
if `cat`i''==`selcat' {
tempname Pselcat
qui gen `Pselcat'=`P`i''
}
local i=`i'+1
}

local i=1
while `i'<=`n' {

if "`dhl'"=="" {
capture drop _m`cat`i''
}

if "`lee'"=="lee" {
if `cat`i''==`selcat' {
qui gen _m`cat`i''=-normd(invnorm(`Pselcat'))/(`Pselcat')
global m "$m _m`cat`i''"

tempvar v`i'
qui gen `v`i''=_m`cat`i''*(invnorm(`Pselcat')+_m`cat`i'')

if "`gen'"~="" {
qui gen `gen'`cat`i''= _m`cat`i''
}
}
}
*(lee)

if "`dmf'"~="" & `variant'==0 {
if `cat`i''~=`selcat' {
qui gen _m`cat`i''=`P`i''*ln(`P`i'')/(1-`P`i'')+ln(`Pselcat')
global m "$m _m`cat`i''"

local euler=.577215664901
tempvar v`i'
qui gen `v`i''=`P`i''*(ln(`P`i'')/(1-`P`i''))^2

if "`gen'"~="" {
qui gen `gen'`cat`i''= _m`cat`i''
}
}
}
*(dmf0)

if "`dmf'"~="" & `variant'==1 {
if `cat`i''~=`selcat' {
qui gen _m`cat`i''=`P`i''*ln(`P`i'')/(1-`P`i'')

local euler=.577215664901
tempvar v`i'
qui gen `v`i''=`P`i''*(ln(`P`i'')/(1-`P`i''))^2
}
if `cat`i''==`selcat' {
qui gen _m`cat`i''=-ln(`Pselcat')
}
global m "$m _m`cat`i''"
if "`gen'"~="" {
qui gen `gen'`cat`i''= _m`cat`i''
}
}
*(dmf1)

if "`dmf'"~="" & `variant'==2 {
tempvar v`i'
qui glquad _m`cat`i'' `v`i'' `P`i''

if `cat`i''~=`selcat' {
qui replace _m`cat`i''=_m`cat`i''*`P`i''/(`P`i''-1)
qui replace `v`i''=(1-`P`i''*`v`i'')/(1-`P`i'')-(_m`cat`i'')^2
}
if `cat`i''==`selcat' {
qui replace `v`i''=`v`i''-(_m`cat`i'')^2
}
global m "$m _m`cat`i''"
if "`gen'"~="" {
qui gen `gen'`cat`i''= _m`cat`i''
}
} 
*(dmf2)

if "`dhl'"~="" {	

if `order'==. {
local order=1
}
if "`prnb'"=="one" | "`prnb'"=="" { 
if `cat`i''==`selcat' {	
local o=1
while `o'<=`order' {
capture drop _m`i'`o'
qui gen _m`i'`o'=(`Pselcat')^`o'
global m "$m _m`i'`o'"

if "`gen'"~="" & `o'==1 {
qui gen `gen'`cat`i''= _m`i'`o'
}

local o=`o'+1
}
}
}
*(prnb=all)

if "`prnb'"=="all" { 
local o=1
while `o'<=`order' {

if `i'>1 | `o'>1 {
capture drop _m`i'`o'
qui gen _m`i'`o'=((`P`i'')^`o')
global m "$m _m`i'`o'"
}

local r=1
while `r'<`o' {
local j=1
while `j'<`i' {
capture drop _m`i'`o'`j'`r'
qui gen _m`i'`o'`j'`r'=((`P`i'')^`o')*(`P`j'')^`r'
global m "$m _m`i'`o'`j'`r'"
local j=`j'+1
}
local r=`r'+1
}
local o=`o'+1
}
}
*(prnb=all)
}
*(dhl)

local i=`i'+1
}

qui regress `varlist' $m `if' `in'
local rss=e(rss)/e(N)

tempvar deltai
qui gen `deltai'=0 if e(sample)

if "`lee'"=="lee" {
local i=1
while `i'<=`n' {
if `cat`i''==`selcat' {
qui replace `deltai'=-(_b[_m`cat`i'']^2)*`v`i'' if e(sample)
}
local i=`i'+1
}
}
*(lee)

if "`dmf'"~="" & (`variant'==0 | `variant'==1) {
local i=1
while `i'<=`n' {
if `cat`i''~=`selcat' {
qui replace `deltai'=`deltai'-(_b[_m`cat`i'']^2)*`v`i'' if e(sample)
}
local i=`i'+1
}
}
*(dmf0/1)

if "`dmf'"~="" & `variant'==2 {
local i=1
while `i'<=`n' {
qui replace `deltai'=`deltai'+(_b[_m`cat`i'']^2)*(`v`i''-1) if e(sample)
local i=`i'+1
}
}
*(dmf2)

qui sum `deltai' if e(sample)
local sigma2=`rss'-r(mean)

if "`bootstrap'"=="" {
di _newline
di in green "Selectivity correction based on multinomial logit"
di in green "Second step regression"
di in green "(Beware: standard errors below do not take account of the two-step procedure)"
di _newline
}

if "`wls'"=="wls" {

tempvar weight
qui sum `deltai' if e(sample)
qui gen `weight'=`rss' + (`deltai'-r(mean))

qui replace `weight'=1/sqrt(`weight')
qui count if `weight'==. & e(sample)
if r(N)>=1 {
di in red "Beware: for " r(N) " observations, the computed heteroskedastic residual variance is negative."
}

if "`bootstrap'"~="" {
qui regress `varlist' $m [aweight=`weight'] `if' `in'
}
if "`bootstrap'"=="" {
regress `varlist' $m [aweight=`weight'] `if' `in'
if "`dhl'"~="" {
di in red "wls not implemented for dhl method"
}
}
}
*(wls)

else {
if "`bootstrap'"~="" {
qui regress `varlist' $m `if' `in'
}

if "`bootstrap'"=="" {
regress `varlist' $m `if' `in'
}
}

if "`dhl'"=="" {

tempname a aprov 
mat `a'=(`sigma2')
mat coleq `a'=Anciliary
mat coln `a'=Sigma2

local i=1
while `i'<=`n' {

if "`lee'"=="lee" {
if `cat`i''==`selcat' {
local rho`cat`i''=_b[_m`cat`i'']/(sqrt(`sigma2'))
if `sigma2'<=0 {
local rho`cat`i''=0
}
mat `aprov'=`rho`cat`i'''
mat coleq `aprov'=Anciliary
mat coln `aprov'=rho`cat`i''
mat `a'=`a',`aprov'
}
}
*(lee)
if "`dmf'"~="" & `variant'==0 {
if `cat`i''~=`selcat' {
local rho`cat`i''=_b[_m`cat`i'']*_pi/(sqrt(`sigma2'*6))
if `sigma2'<=0 {
local rho`cat`i''=0
}
mat `aprov'=`rho`cat`i'''
mat coleq `aprov'=Anciliary
mat coln `aprov'=rho`cat`i''
mat `a'=`a',`aprov'
}
}
*(dmf0)
if "`dmf'"~="" & `variant'==1 {
local rho`cat`i''=_b[_m`cat`i'']*_pi/(sqrt(`sigma2'*6))
if `sigma2'<=0 {
local rho`cat`i''=0
}
mat `aprov'=`rho`cat`i'''
mat coleq `aprov'=Anciliary
mat coln `aprov'=rho`cat`i''
mat `a'=`a',`aprov'
}
*(dmf1)
if "`dmf'"~="" & `variant'==2 {
local rho`cat`i''=_b[_m`cat`i'']/(sqrt(`sigma2'))
if `sigma2'<=0 {
local rho`cat`i''=0
}
mat `aprov'=`rho`cat`i'''
mat coleq `aprov'=Anciliary
mat coln `aprov'=rho`cat`i''
mat `a'=`a',`aprov'
}
*(dmf2)

local i=`i'+1
}

estimates matrix a `a'

if "`bootstrap'"=="" {
tempname a aV b bV c cV
mat `b'=e(b) 
mat coleq `b'="`y'"
mat `bV'=e(V)
mat coleq `bV'="`y'"
mat `a'=e(a)

mat `c'=`b',`a'
mat `cV'=0*((`c')'*`c')
mat `cV'[1,1]=`bV'

mat `aV'=0*((`a')'*`a')
estimates post `a' `aV'
estimates display

estimates post `c' `cV'
*(so as to have the correct matrices in memory)
}
}
*(not dhl)

end
*(base)
