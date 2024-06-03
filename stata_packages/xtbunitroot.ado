*! xtbunitroot version 1.1 - 29.04.2022
/*
Changelog
- 29.04.2022 - xtbunitroot now supports unbalanced panels. The new options include seed, showindex and level.
*/

program xtbunitroot,rclass

version 12

syntax varname(ts) [if] [in] [, TRend KNown(numlist integer) UNKnown(numlist integer) NORmal csd het NObootstrap Level(integer 5) seed(integer 123) SHOwindex]
tsunab devar:`varlist'
marksample touse

quietly{

preserve

xtset
tempname usrdelta
local panelvar `r(panelvar)'
local timevar `r(timevar)'
local fmt : format `timevar'
sca `usrdelta' =  `r(tdelta)'



//extend unbalanced to balanced panel
tsfill,full
xtset
local panelvar `r(panelvar)'
local timevar `r(timevar)'
local tmax `r(tmax)'

//check for strongly balanced panel
tempvar misstest misstotal bymiss
gen `misstest'=missing(`devar') `if' 
egen `misstotal'=total(`misstest')
local miss=`misstotal'[1]
if `miss' >0 {
	local nomiss "0"

	}
	else{
	local nomiss "1"

	}

egen `bymiss'=total(`misstest'),by(`panelvar')	
sum `bymiss'
if `r(max)'==`tmax'{
		di as error				///
		 "There are cross section units with no values"
		 exit 98
}	

//generate dependent variables
	
tempvar depvar lagdepvar mi tsum differy
gen `depvar'=`devar' if `touse'
gen `lagdepvar'=l.`depvar' if `touse'
gen `differy'=d.`depvar' 


qui tab `panelvar' `if'
local rnum=r(r)



//deal with missing values
gen `mi'=(`depvar'>=.) `if'
by `panelvar':replace `mi'=2 if _n==1 & `mi'==1
replace `mi'=2 if `mi'==1 & `mi'[_n-1]==2 & `panelvar'[_n]==`panelvar'[_n-1]
bysort `timevar':egen `tsum'=total(`mi') 
sort `panelvar' `timevar'
replace `tsum'=`tsum'/`rnum'
replace `mi'=0 if `tsum'==2



tempname di
gen `di'=`mi' 
replace `di'=1 if `mi'[_n-1]==1 & `panelvar'[_n]==`panelvar'[_n-1] & `di'[_n-1] !=.


replace `depvar'=0 if `mi' !=0 & `mi' !=.
replace `depvar'=0 if `mi'[_n-1]!=0 & `panelvar'[_n]==`panelvar'[_n-1] & `mi'[_n-1] !=.
replace `lagdepvar'=0 if `mi'==1
replace `lagdepvar'=0 if `mi'[_n-1]!=0 & `panelvar'[_n]==`panelvar'[_n-1] & `mi'[_n-1] !=.
replace `differy'=0 if `mi'==1
replace `differy'=0 if `mi'[_n-1]!=0 & `panelvar'[_n]==`panelvar'[_n-1] & `mi'[_n-1] !=.


replace `touse' =1 if `mi' !=0 & `mi' !=.





//decide M1 or M2 model
if "`trend'" != "" {
local model=2    //M2 model
local mod trend
}

else{
local model=1	 //default
local mod constant
}



//decide number of breaks
if "`known'" != ""{
tokenize `known'
local firknown="`1'"
local secknown="`2'"
local thirknown="`3'"
if "`thirknown'" != ""{
		di as error				///
		 "Up to two breaks are allowed"
		 exit 98
}
if "`secknown'" != ""{
if `secknown'<`firknown' | `secknown'==`firknown'{
di as error				///
		 "The second break date should be later than the first break date"
		 exit 98
}
}
if "`unknown'" !=""{
		di as error				///
		 "The 'known' and 'unknown' options can not be used at the same time"
		 exit 98
}
}
else if "`unknown'" !=""{
tokenize `unknown'
local unknowndate=`1'
if "`2'"!=""{
if `2' > 0{
local bootstrap=`2'
}
else{
		di as error				///
		 "The number of bootstrap replications should be a positive integer"
		 exit 98
}
}
else if "`2'" ==""{
local bootstrap=100
}
if "`unknowndate'"=="1"{
local firknown="1"
local secknown=""
}
else if "`unknowndate'"=="2"{
local firknown="1"
local secknown="2"
}
else{
		di as error				///
		 "The number of unknown breaks should be either 1 or 2"
		 exit 98
}
}
else{
local firknown=""
local secknown=""
}
if "`firknown'"!="" & "`secknown'"==""{
local numofbreak=1
}
else if "`secknown'"!=""{
local numofbreak=2
}
else if "`firknown'"=="" & "`secknown'"==""{
local numofbreak=1		//default 1 break
}
else{
		di as error				///
		 "The number of known breaks should be either 1 or 2"
		 exit 30
}

if "`nobootstrap'" != ""{
if "`normal'" == "" | "`unknown'" ==""{
		di as error				///
		 "The nobootstrap option should be used with options 'normal' and 'unknown'"
		 exit 30
}
else{
local bootstrap=0
}
}



//decide default unknown 
if "`known'"=="" & "`unknown'"=="" & "`bootstrap'"==""{
local bootstrap=100
}


if "`known'"=="" {
	if `bootstrap'>_N{
		di as error				///
		 "The number of bootstrap should be less than number of total observations"
		 exit 198
		 }
}



//determine level of the test
if "`level'"!= ""{
    local size=`level'*0.01
	
}
else{
    local size=0.05
}
local critival=invnormal(`size')




//get capN and capT
tempvar countme
qui by `panelvar':egen `countme'=total(`touse') `if'
summ `countme' if `touse',mean
local capT=r(min)
qui count if `touse'
local capN=r(N)/`capT'



tempvar obs obsid
egen `obsid'=seq() if `touse',from(1)to(`rnum')block(`capT')
gen `obs'=_n

//time-invariant test
tempvar timeinvar sumtvar
gen `timeinvar'=`depvar'-l.`depvar'
egen `sumtvar'=total(`timeinvar')
if `sumtvar'[1]==0 {
		di as error				///
		 "Variable is time-invariant "
		 exit 2200
}


//cross-section dependence
if "`csd'" != ""{
tempvar crossvar ydepen 
gen `crossvar'=`depvar'

bysort `timevar': egen `ydepen'=mean(`depvar') if `touse'
sort `panelvar' `timevar'
replace `depvar'=`crossvar'-`ydepen'

}



tempvar realdepvar idd mii
gen `realdepvar'=`depvar' if !missing(`lagdepvar')
gen `idd'=`panelvar' if !missing(`lagdepvar')
gen `mii'=(`di'==0) if !missing(`lagdepvar') & `touse'
local realt=`capT'-1

local minrealt=`realt'-1
local minirealt=`minrealt'-1

count if `mii'==1
local countmi=r(N)



//calculate

creturn list
local IC=c(flavor)
local SE=c(SE)
local MP=c(MP)



tempname rho p fihat
if `SE'==1 | `MP'==1{
set matsize 11000
}
else{
set matsize 800
}


if "`het'" == ""{

						// calculate k sigma
tempvar dy dydot dymean sumdy sumdy2 count1 count2 count3 mimean1 mimean2 tdummy
gen `dy'=`differy'
egen `dymean'=mean(`mii'*`dy'),by(`idd')
egen `count1'=total(`mii') ,by(`panelvar')
replace `dymean'=`dymean'*`realt'/`count1'
gen `dydot'=`dy'-`dymean'
egen `sumdy'=total(`mii'*`dydot'*`dydot') 
local sigma=`sumdy'[1]/(`countmi'-`rnum')
egen `sumdy2'=total(`mii'*(`dydot'^4))

bysort `panelvar': gen `count2'=3*(`count1'-1)*(2*`count1'-3)/(`count1'^2)
bysort `panelvar': gen `tdummy'=_n
egen `mimean1'=mean(`count2') if `tdummy'==1

bysort `panelvar': gen `count3'=(`count1'-1)*(`count1'^2-3*(`count1')+3)/(`count1'^2)
egen `mimean2'=mean(`count3') if `tdummy'==1
sort `panelvar' `timevar'


local ku=(((`sumdy2'[1])/`capN')-((`mimean1'[1])*(`sigma'^2)))/((`mimean2'[1])*(`sigma'^2))

if "`normal'" !=""{
local ku=0
}


}

else{



tempvar dy dydot dymean sumdy sumdy2 count1 count2 count3 
gen `dy'=`differy'
egen `dymean'=mean(`mii'*`dy'),by(`idd')
egen `count1'=total(`mii') `if',by(`panelvar')
replace `dymean'=`dymean'*`realt'/`count1'
gen `dydot'=`dy'-`dymean'
egen `sumdy'=total(`mii'*`dydot'*`dydot') `if',by(`panelvar')
egen `sumdy2'=total(`mii'*(`dydot'^4)) `if',by(`panelvar')
bysort `panelvar': gen `count2'=3*(`count1'-1)*(2*`count1'-3)/(`count1'^2)
bysort `panelvar': gen `count3'=(`count1'-1)*(`count1'^2-3*(`count1')+3)/(`count1'^2)
sort `panelvar' `timevar'

local sigma=0
local ku=0

tempname vecsigma vecku
matrix `vecsigma'=1
matrix `vecku'=1
forvalues he=1/`capN'{
sum `obs' if `obsid'==`he'
local indica=r(min)
local sigmai=`sumdy'[`indica']/(`count1'[`indica']-1)
local sigma=`sigma'+`sigmai'
local kui=((`sumdy2'[`indica'])-((`count2'[`indica'])*(`sigmai'^2)))/((`count3'[`indica'])*(`sigmai'^2))
local ku=`ku'+`kui'
matrix `vecsigma'=`vecsigma'\(`sigmai')
matrix `vecku'=`vecku'\(`kui')
}
local sigma=`sigma'/`capN'
local ku=`ku'/`capN'


matrix `vecsigma'=`vecsigma'[2...,1]
matrix `vecku'=`vecku'[2...,1]
if "`normal'" !=""{
matrix `vecku'=J(`capN',1,0)
}
numlist "1/`capN'"
mat rownames `vecsigma'=`r(numlist)'
mat rownames `vecku'=`r(numlist)'




tempvar vsigma vku 
svmat `vecsigma', names(`vsigma')
svmat `vecku', names(`vku')



}



	//1 break
if `numofbreak'==1{


		//known breaks

if "`known'" != ""{
local brokentt=`known'-1
tempname brokent
scalar `brokent'=`known'-1




			//M1 model
if "`model'" == "1"{

if `brokent'>=`realt' | `brokent'<1{
		di as error				///
		 "This date is not allowed to be the break date"
		 exit 498
}

									
mata:taskp(`realt',`brokentt',`capN',`sigma',`ku',"`lagdepvar'","`realdepvar'","`idd'","`mii'")



scalar `rho'=r(sta)
scalar `fihat'=r(fihat)
scalar  `p'=normal(`rho')
			//M1 model
}

			//M2 model
if "`model'" == "2"{

if `brokent'>=`minrealt' | `brokent'<2{
		di as error				///
		 "This date is not allowed to be the break date"
		 exit 498
}




tempvar ti
by `panelvar':gen `ti'=_n-1
tempvar tt1 tt2
gen `tt1'=`ti'
forvalues t1=1/`capN'{
replace `tt1'=0 if `idd'==`t1' & `ti'>`brokent'
}
gen `tt2'=`ti'
forvalues t2=1/`capN'{
replace `tt2'=0 if `idd'==`t2' & `ti'<=`brokent'
}


mata:taskp2(`realt',`brokentt',`capN',`sigma',`ku',"`lagdepvar'","`realdepvar'","`idd'","`tt1'","`tt2'","`mii'")
scalar `rho'=r(sta)
scalar `fihat'=r(fihat)
scalar  `p'=normal(`rho')


			//M2 model
}


		//known breaks
}




		//unknown breaks
if "`known'" == ""{

local rep=`bootstrap'
local plusn=`capN'+1
set seed `seed'

			//M1 model
if `model' == 1{

tempvar tempresult tempt tempfihat
gen `tempresult'=.
gen `tempt'=.
gen `tempfihat'=.
tempname v sta fi
forvalues mf=1/`minrealt'{
local tempbrokentt=`mf'


mata:taskp(`realt',`tempbrokentt',`capN',`sigma',`ku',"`lagdepvar'","`realdepvar'","`idd'","`mii'")


scalar `sta'=r(sta)
scalar `fi'=r(fihat)
replace `tempresult'=`sta' in `mf'
replace `tempt'=`mf' in `mf'
replace `tempfihat'=`fi' in `mf'
}

tempvar ymin storedt storedt2 fistoredt fistoredt2
egen `ymin'=min(`tempresult')
gen `storedt'=`tempt' if `ymin'==`tempresult'
egen `storedt2'=min(`storedt')
gen `fistoredt'=`tempfihat' if `ymin'==`tempresult'
egen `fistoredt2'=min(`fistoredt')
tempname zd fint
scalar `zd'=`ymin'[1]
scalar `fint'=`storedt2'[1]
scalar `fihat'=`fistoredt2'[1]

if `SE'==1 | `MP'==1{
set matsize 11000
}
else{
set matsize 800
}

tempvar diffyx diffmi dmi
gen `diffyx'=`differy' if !missing(`lagdepvar')
gen `dmi'=(`di'==0)	if `touse'
gen `diffmi'=d.`dmi' if !missing(`lagdepvar') & `touse'


tempvar xtid
gen `xtid'=`panelvar' if `touse'

tempname ori omi

capture drop `cv'
tempvar cv
gen `cv'=.
replace `cv'=`zd' in 1

tempvar yirvar ymi
gen `yirvar'=.
gen `ymi'=.

tempvar lagyirvar yirvart
gen `lagyirvar'=.
gen `yirvart'=.

tempname dyr dyrdot
gen `dyr'=.
gen `dyrdot'=.

tempvar storedresult
gen `storedresult'=.

tempname sta sta2 deltz zr


local nt=`capN'*`capT'
local ntp=`capN'*`capT'+1

forvalues mc=1/`rep'{



mata:ori(`realt',`capN',"`differy'","`idd'","`depvar'","`xtid'","`dmi'","`diffmi'")
matrix `ori'=r(ori)
matrix `omi'=r(omi)

forvalues os1=1/`capN'{
	forvalues os2=1/`capT'{
sum `obs' if `obsid'==`os1'
local indica=r(min)
local ord=`os2'-1+`indica'
replace `yirvar'=`ori'[`os2',`os1'] in `ord'
replace `ymi'=`omi'[`os2',`os1'] in `ord'
	}
}

tempvar ytsum
bysort `panelvar':egen `ytsum'=total(`ymi')
replace `ymi'=`ymi'+1 if `ytsum'<0


replace `lagyirvar'=l.`yirvar'

replace `yirvar'=0 if `ymi'==0
replace `yirvar'=0 if `ymi'[_n-1]==0 & `panelvar'[_n]==`panelvar'[_n-1]
replace `lagyirvar'=0 if `ymi'==0
replace `lagyirvar'=0 if `ymi'[_n-1]==0 & `panelvar'[_n]==`panelvar'[_n-1]

replace `yirvart'=`yirvar' if !missing(`lagyirvar')
tempname ymii
gen `ymii'=`ymi' if !missing(`lagyirvar')
replace `ymii'=0 if `ymi'[_n-1]==0 & `panelvar'[_n]==`panelvar'[_n-1]




tempname dyrmean sumdyr sumdyr2
replace `dyr'=d.`yirvar'
egen `dyrmean'=mean(`dyr'),by(`idd')
replace `dyrdot'=`dyr'-`dyrmean' if !missing(`dyr')
egen `sumdyr'=total(`dyrdot'*`dyrdot')
local sigmar=`sumdyr'[1]/(`capN'*(`capT'-1))
egen `sumdyr2'=total(`dyrdot'^4)
local kur=(((`capT'^2*`sumdyr2'[1])/`capN')-(3*(`capT'-1)*(2*`capT'-3)*(`sigmar'^2)))/((`capT'-1)*(`capT'^2-3*`capT'+3)*(`sigmar'^2))






replace `storedresult'=.

forvalues mfc=1/`minrealt'{
local brokentt2=`mfc'
mata:taskp(`realt',`brokentt2',`capN',`sigma',`ku',"`lagdepvar'","`realdepvar'","`idd'","`mii'")
scalar `sta'=r(sta)
mata:boot1p1b(`realt',`brokentt2',`capN',`sigmar',`kur',"`lagyirvar'","`yirvart'","`idd'","`ymii'")
scalar `sta2'=r(sta2)
scalar `deltz'=`sta2'-`sta'
replace `storedresult'=`deltz' in `mfc'
}
capture drop `zmin'
tempvar zmin
egen `zmin'=min(`storedresult')

scalar `zr'=`zmin'[1]

local hplus=`mc'+1
replace `cv'=`zr' in `hplus'

}
centile `cv',centile(`level')
scalar `rho'=`zd'
scalar  `p'=r(c_1)
tempname pv
count if `cv'<`rho' & !missing(`cv')
scalar `pv'=r(N)/`rep'
			//M1 model
}

			//M2 model
if `model' == 2{

tempvar tempresult tempt tempfihat
gen `tempresult'=.
gen `tempt'=.
gen `tempfihat'=.

tempname tempbrokent v sta fi

local lowt=`realt'-1
forvalues mf=2/`minirealt'{
local tempbrokentt=`mf'

scalar `tempbrokent'=`mf'


mata:boot1p2a(`realt',`tempbrokentt',`capN',`sigma',`ku',"`lagdepvar'","`realdepvar'","`idd'","`mii'")


scalar `sta'=r(sta)
scalar `fi'=r(fihat)
replace `tempresult'=`sta' in `mf'
replace `tempt'=`mf' in `mf'
replace `tempfihat'=`fi' in `mf'
}

tempvar ymin storedt storedt2 fistoredt fistoredt2
egen `ymin'=min(`tempresult')
gen `storedt'=`tempt' if `ymin'==`tempresult'
egen `storedt2'=min(`storedt')
gen `fistoredt'=`tempfihat' if `ymin'==`tempresult'
egen `fistoredt2'=min(`fistoredt')
tempname zd fint
scalar `zd'=`ymin'[1]
scalar `fint'=`storedt2'[1]
scalar `fihat'=`fistoredt2'[1]

if `SE'==1 | `MP'==1{
set matsize 11000
}
else{
set matsize 800
}

tempvar diffyx diffmi dmi
gen `diffyx'=`differy' if !missing(`lagdepvar')
gen `dmi'=(`di'==0)
gen `diffmi'=d.`dmi' if !missing(`lagdepvar')

tempvar xtid
gen `xtid'=`panelvar' if `touse'

tempname ori omi


tempvar cv
gen `cv'=.
replace `cv'=`zd' in 1


tempvar yirvar ymi
gen `yirvar'=.
gen `ymi'=.

tempvar lagyirvar yirvart
gen `lagyirvar'=.
gen `yirvart'=.
tempname dyr dyrdot
gen `dyr'=.
gen `dyrdot'=.
tempvar storedresult
gen `storedresult'=.
tempname brokent2
tempname sta sta2 deltz
tempname zr

local nt=`capN'*`capT'
local ntp=`capN'*`capT'+1

forvalues mc=1/`rep'{


mata:ori(`realt',`capN',"`differy'","`idd'","`depvar'","`xtid'","`dmi'","`diffmi'")
matrix `ori'=r(ori)
matrix `omi'=r(omi)
forvalues os1=1/`capN'{
	forvalues os2=1/`capT'{
sum `obs' if `obsid'==`os1'
local indica=r(min)
local ord=`os2'-1+`indica'
replace `yirvar'=`ori'[`os2',`os1'] in `ord'
replace `ymi'=`omi'[`os2',`os1'] in `ord'
	}
}


tempvar ytsum
bysort `panelvar':egen `ytsum'=total(`ymi')
replace `ymi'=`ymi'+1 if `ytsum'<0


replace `lagyirvar'=l.`yirvar'

replace `yirvar'=0 if `ymi'==0
replace `yirvar'=0 if `ymi'[_n-1]==0 & `panelvar'[_n]==`panelvar'[_n-1]
replace `lagyirvar'=0 if `ymi'==0
replace `lagyirvar'=0 if `ymi'[_n-1]==0 & `panelvar'[_n]==`panelvar'[_n-1]

replace `yirvart'=`yirvar' if !missing(`lagyirvar')
tempname ymii
gen `ymii'=`ymi' if !missing(`lagyirvar')
replace `ymii'=0 if `ymi'[_n-1]==0 & `panelvar'[_n]==`panelvar'[_n-1]



tempname dyrmean sumdyr sumdyr2
replace `dyr'=d.`yirvar'
egen `dyrmean'=mean(`dyr'),by(`idd')
replace `dyrdot'=`dyr'-`dyrmean' if !missing(`dyr')
egen `sumdyr'=total(`dyrdot'*`dyrdot')
local sigmar=`sumdyr'[1]/(`capN'*(`capT'-1))
egen `sumdyr2'=total(`dyrdot'^4)
local kur=(((`capT'^2*`sumdyr2'[1])/`capN')-(3*(`capT'-1)*(2*`capT'-3)*(`sigmar'^2)))/((`capT'-1)*(`capT'^2-3*`capT'+3)*(`sigmar'^2))



replace `storedresult'=.

forvalues mfc=2/`minirealt'{
local brokentt2=`mfc'

scalar `brokent2'=`mfc'

mata:boot1p2a(`realt',`brokentt2',`capN',`sigma',`ku',"`lagdepvar'","`realdepvar'","`idd'","`mii'")

scalar `sta'=r(sta)
mata:boot1p2b(`realt',`brokentt2',`capN',`sigmar',`kur',"`lagyirvar'","`yirvart'","`idd'","`ymii'")
scalar `sta2'=r(sta2)
scalar `deltz'=`sta2'-`sta'
replace `storedresult'=`deltz' in `mfc'
}

tempvar zmin
egen `zmin'=min(`storedresult')

scalar `zr'=`zmin'[1]

local hplus=`mc'+1
replace `cv'=`zr' in `hplus'

}
centile `cv',centile(`level')
scalar `rho'=`zd'
scalar  `p'=r(c_1)
tempname pv
count if `cv'<`rho' & !missing(`cv')
scalar `pv'=r(N)/`rep'




			//M2 model
}



		//unknown breaks
}


	//1 break
}



	//2 break
if `numofbreak'==2{

		//known breaks

if "`known'" != ""{
tokenize `known'
local brokentt=`1'-1
local brokentt2=`2'-1
tempname brokent brokent2
scalar `brokent'=`1'-1
scalar `brokent2'=`2'-1





			//M1 model
if "`model'" == "1"{

if `brokent'>=`realt' | `brokent'<1 | `brokent2'>=`realt' | `brokent2'<2{
		di as error				///
		 "This date is not allowed to be the break date"
		 exit 498
}
									
mata:task2p(`realt',`brokentt',`capN',`brokentt2',`sigma',`ku',"`lagdepvar'","`realdepvar'","`idd'","`mii'")

scalar `rho'=r(sta)
scalar `fihat'=r(fihat)
scalar  `p'=normal(`rho')
			//M1 model
}

			//M2 model
if "`model'" == "2"{

if `brokent'>=`minrealt' | `brokent'<2 | `brokent2'>=`minrealt' | `brokent2'<2{
		di as error				///
		 "This date is not allowed to be the break date"
		 exit 498
}


if `brokent'==`brokent2'-1 | `brokent'==`brokent2'+1{
		di as error				///
		"Two consecutive break dates are not allowed in the model with trend"
		exit 498
}




tempvar ti
by `panelvar':gen `ti'=_n-1
tempvar tt1 tt2 tt3
gen `tt1'=`ti'
forvalues t1=1/`capN'{
replace `tt1'=0 if `idd'==`t1' & `ti'>`brokent'
}
gen `tt2'=`ti'
forvalues t2=1/`capN'{
replace `tt2'=0 if `idd'==`t2' & `ti'<=`brokent'
replace `tt2'=0 if `idd'==`t2' & `ti'>`brokent2'
}
gen `tt3'=`ti'
forvalues t3=1/`capN'{
replace `tt3'=0 if `idd'==`t3' & `ti'<=`brokent2'
}

mata:task2p2(`realt',`brokentt',`capN',`brokentt2',`sigma',`ku',"`lagdepvar'","`realdepvar'","`idd'","`tt1'","`tt2'","`tt3'","`mii'")
scalar `rho'=r(sta)
scalar `fihat'=r(fihat)
scalar  `p'=normal(`rho')


			//M2 model
}


		//known breaks
}



		//unknown breaks
if "`known'" == ""{

local rep=`bootstrap'
local plusn=`capN'+1
set seed `seed'

			//M1 model
if `model' == 1{


tempvar tempresult2 tempt sectempt fisectempt

gen `tempresult2'=.
gen `tempt'=.
gen `sectempt'=.
gen `fisectempt'=.

tempvar tempt2 tempresult fitemp
gen `tempt2'=.
gen `tempresult'=.
gen `fitemp'=.
tempname v sta fi
tempvar firstoredt fifirstoredt
gen `firstoredt'=.
gen `fifirstoredt'=.

forvalues mf=1/`minrealt'{
local tempbrokentt=`mf'


replace `tempt2'=.
replace `tempresult'=.
replace `firstoredt'=.
replace `fitemp'=.
replace `fifirstoredt'=.
forvalues mf2=`mf'/`minrealt'{

if `mf2' != `mf'{
local tempbrokentt2=`mf2'

mata:boot2p1a(`realt',`tempbrokentt',`capN',`tempbrokentt2',`sigma',`ku',"`lagdepvar'","`realdepvar'","`idd'","`mii'")


scalar `sta'=r(sta)
scalar `fi'=r(fihat)
replace `tempresult'=`sta' in `mf2'
replace `tempt2'=`mf2' in `mf2'
replace `fitemp'=`fi' in `mf2'
}


}

tempvar ymin firstoredt2 fifirstoredt2
egen `ymin'=min(`tempresult')
local finz=`ymin'[1]
replace `tempresult2'=`finz' in `mf'
replace `firstoredt'=`tempt2' if `ymin'==`tempresult'
egen `firstoredt2'=min(`firstoredt')
local storedz=`firstoredt2'[1]
replace `fifirstoredt'=`fitemp' if `ymin'==`tempresult'
egen `fifirstoredt2'=min(`fifirstoredt')
local storedfi=`fifirstoredt2'[1]
replace `fisectempt'=`storedfi' in `mf'
replace `sectempt'=`storedz' in `mf'
replace `tempt'=`mf' in `mf'
}


tempvar ymin2 finfirst1 finfirst2 finsec1 finsec2 finfihat finfihat2
egen `ymin2'=min(`tempresult2')
gen `finfirst1'=`tempt' if `ymin2'==`tempresult2'
egen `finfirst2'=min(`finfirst1')
gen `finsec1'=`sectempt' if `ymin2'==`tempresult2'
egen `finsec2'=min(`finsec1')
gen `finfihat'=`fisectempt' if `ymin2'==`tempresult2'
egen `finfihat2'=min(`finfihat')
tempname zd fint fint2
scalar `zd'=`ymin2'[1]
scalar `fint'=`finfirst2'[1]
scalar `fint2'=`finsec2'[1]
scalar `fihat'=`finfihat2'[1]

if `SE'==1 | `MP'==1{
set matsize 11000
}
else{
set matsize 800
}

tempvar diffyx diffmi dmi
gen `diffyx'=`differy' if !missing(`lagdepvar')
gen `dmi'=(`di'==0)
gen `diffmi'=d.`dmi' if !missing(`lagdepvar')

tempvar xtid
gen `xtid'=`panelvar' if `touse'


tempname ori omi


tempvar cv
gen `cv'=.
replace `cv'=`zd' in 1




tempvar yirvar ymi
gen `yirvar'=.
gen `ymi'=.

tempvar lagyirvar yirvart
gen `lagyirvar'=.
gen `yirvart'=.
tempname dyr dyrdot
gen `dyr'=.
gen `dyrdot'=.

tempvar storedresult2
gen `storedresult2'=.
tempvar storedresult
gen `storedresult'=.
tempname sta sta2 deltz zr

local nt=`capN'*`capT'
local ntp=`capN'*`capT'+1

forvalues mc=1/`rep'{



mata:ori(`realt',`capN',"`differy'","`idd'","`depvar'","`xtid'","`dmi'","`diffmi'")
matrix `ori'=r(ori)
matrix `omi'=r(omi)

forvalues os1=1/`capN'{
	forvalues os2=1/`capT'{
sum `obs' if `obsid'==`os1'
local indica=r(min)
local ord=`os2'-1+`indica'
replace `yirvar'=`ori'[`os2',`os1'] in `ord'
replace `ymi'=`omi'[`os2',`os1'] in `ord'
	}
}



tempvar ytsum
bysort `panelvar':egen `ytsum'=total(`ymi')
replace `ymi'=`ymi'+1 if `ytsum'<0


replace `lagyirvar'=l.`yirvar'

replace `yirvar'=0 if `ymi'==0
replace `yirvar'=0 if `ymi'[_n-1]==0 & `panelvar'[_n]==`panelvar'[_n-1]
replace `lagyirvar'=0 if `ymi'==0
replace `lagyirvar'=0 if `ymi'[_n-1]==0 & `panelvar'[_n]==`panelvar'[_n-1]

replace `yirvart'=`yirvar' if !missing(`lagyirvar')
tempname ymii
gen `ymii'=`ymi' if !missing(`lagyirvar')
replace `ymii'=0 if `ymi'[_n-1]==0 & `panelvar'[_n]==`panelvar'[_n-1]




tempname dyrmean sumdyr sumdyr2
replace `dyr'=d.`yirvar'
egen `dyrmean'=mean(`dyr'),by(`idd')
replace `dyrdot'=`dyr'-`dyrmean' if !missing(`dyr')
egen `sumdyr'=total(`dyrdot'*`dyrdot')
local sigmar=`sumdyr'[1]/(`capN'*(`capT'-1))
egen `sumdyr2'=total(`dyrdot'^4)
local kur=(((`capT'^2*`sumdyr2'[1])/`capN')-(3*(`capT'-1)*(2*`capT'-3)*(`sigmar'^2)))/((`capT'-1)*(`capT'^2-3*`capT'+3)*(`sigmar'^2))



replace `storedresult2'=.

forvalues mfc=1/`minrealt'{
local brokentt2=`mfc'

replace `storedresult'=.
forvalues mfc2=`mfc'/`minrealt'{

if `mfc2' != `mfc'{
local brokentt3=`mfc2'
mata:boot2p1a(`realt',`brokentt2',`capN',`brokentt3',`sigma',`ku',"`lagdepvar'","`realdepvar'","`idd'","`mii'")

scalar `sta'=r(sta)
mata:boot2p1b(`realt',`brokentt2',`capN',`brokentt3',`sigmar',`kur',"`lagyirvar'","`yirvart'","`idd'","`ymii'")
scalar `sta2'=r(sta2)
scalar `deltz'=`sta2'-`sta'
replace `storedresult'=`deltz' in `mfc2'
}

}
tempvar finymin
egen `finymin'=min(`storedresult')
local finzz=`finymin'[1]

replace `storedresult2'=`finzz' in `mfc'
}

tempvar zmin
egen `zmin'=min(`storedresult2')

scalar `zr'=`zmin'[1]

local hplus=`mc'+1
replace `cv'=`zr' in `hplus'

}
centile `cv',centile(`level')
scalar `rho'=`zd'
scalar  `p'=r(c_1)
tempname pv
count if `cv'<`rho' & !missing(`cv')
scalar `pv'=r(N)/`rep'
			//M1 model
}

			//M2 model
if `model' == 2{

tempvar tempresult2 tempt sectempt fisectempt

gen `tempresult2'=.
gen `tempt'=.
gen `sectempt'=.
gen `fisectempt'=.

tempvar tempt2 tempresult fitemp
gen `tempt2'=.
gen `tempresult'=.
gen `fitemp'=.

tempname tempbrokent tempbrokent2

tempname v sta fi
tempvar firstoredt fifirstoredt
gen `firstoredt'=.
gen `fifirstoredt'=.


forvalues mf=2/`minirealt'{
local tempbrokentt=`mf'

replace `tempt2'=.
replace `tempresult'=.
scalar `tempbrokent'=`mf'
replace `firstoredt'=.
replace `fitemp'=.
replace `fifirstoredt'=.

forvalues mf2=`mf'/`minirealt'{
local des=`mf'+1
if `mf2' != `mf' & `mf2' != `des'{
local tempbrokentt2=`mf2'
scalar `tempbrokent2'=`mf2'



mata:boot2p2a(`realt',`tempbrokentt',`capN',`tempbrokentt2',`sigma',`ku',"`lagdepvar'","`realdepvar'","`idd'","`mii'")


scalar `sta'=r(sta)
scalar `fi'=r(fihat)
replace `tempresult'=`sta' in `mf2'
replace `fitemp'=`fi' in `mf2'
replace `tempt2'=`mf2' in `mf2'
}



}

tempvar ymin firstoredt2 fifirstoredt2
egen `ymin'=min(`tempresult')
local finz=`ymin'[1]
replace `tempresult2'=`finz' in `mf'
replace `firstoredt'=`tempt2' if `ymin'==`tempresult'
egen `firstoredt2'=min(`firstoredt')
local storedz=`firstoredt2'[1]
replace `fifirstoredt'=`fitemp' if `ymin'==`tempresult'
egen `fifirstoredt2'=min(`fifirstoredt')
local storedfi=`fifirstoredt2'[1]
replace `fisectempt'=`storedfi' in `mf'
replace `sectempt'=`storedz' in `mf'
replace `tempt'=`mf' in `mf'
}

tempvar ymin2 finfirst1 finfirst2 finsec1 finsec2 finfihat finfihat2
egen `ymin2'=min(`tempresult2')
gen `finfirst1'=`tempt' if `ymin2'==`tempresult2'
egen `finfirst2'=min(`finfirst1')
gen `finsec1'=`sectempt' if `ymin2'==`tempresult2'
egen `finsec2'=min(`finsec1')
gen `finfihat'=`fisectempt' if `ymin2'==`tempresult2'
egen `finfihat2'=min(`finfihat')
tempname zd fint fint2
scalar `zd'=`ymin2'[1]
scalar `fint'=`finfirst2'[1]
scalar `fint2'=`finsec2'[1]
scalar `fihat'=`finfihat2'[1]

if `SE'==1 | `MP'==1{
set matsize 11000
}
else{
set matsize 800
}

tempname ori omi


tempvar diffyx diffmi dmi
gen `diffyx'=`differy' if !missing(`lagdepvar')
gen `dmi'=(`di'==0)
gen `diffmi'=d.`dmi' if !missing(`lagdepvar')

tempvar xtid
gen `xtid'=`panelvar' if `touse'

capture drop `cv'
tempvar cv
gen `cv'=.
replace `cv'=`zd' in 1


tempvar yirvar ymi
gen `yirvar'=.
gen `ymi'=.
tempvar lagyirvar yirvart
gen `lagyirvar'=.
gen `yirvart'=.
tempvar dyr dyrdot 
gen `dyr'=.
gen `dyrdot'=.
tempvar storedresult2
gen `storedresult2'=.
tempname brokent2 brokent3
tempvar storedresult
gen `storedresult'=.
tempname sta sta2 deltz zr
local nt=`capN'*`capT'
local ntp=`capN'*`capT'+1

forvalues mc=1/`rep'{


mata:ori(`realt',`capN',"`differy'","`idd'","`depvar'","`xtid'","`dmi'","`diffmi'")
matrix `ori'=r(ori)
matrix `omi'=r(omi)
forvalues os1=1/`capN'{
	forvalues os2=1/`capT'{
sum `obs' if `obsid'==`os1'
local indica=r(min)
local ord=`os2'-1+`indica'
replace `yirvar'=`ori'[`os2',`os1'] in `ord'
replace `ymi'=`omi'[`os2',`os1'] in `ord'
	}
}


tempvar ytsum
bysort `panelvar':egen `ytsum'=total(`ymi')
replace `ymi'=`ymi'+1 if `ytsum'<0


replace `lagyirvar'=l.`yirvar'

replace `yirvar'=0 if `ymi'==0
replace `yirvar'=0 if `ymi'[_n-1]==0 & `panelvar'[_n]==`panelvar'[_n-1]
replace `lagyirvar'=0 if `ymi'==0
replace `lagyirvar'=0 if `ymi'[_n-1]==0 & `panelvar'[_n]==`panelvar'[_n-1]

replace `yirvart'=`yirvar' if !missing(`lagyirvar')
tempname ymii
gen `ymii'=`ymi' if !missing(`lagyirvar')
replace `ymii'=0 if `ymi'[_n-1]==0 & `panelvar'[_n]==`panelvar'[_n-1]



tempname dyrmean sumdyr sumdyr2
replace `dyr'=d.`yirvar'
egen `dyrmean'=mean(`dyr'),by(`idd')
replace `dyrdot'=`dyr'-`dyrmean' if !missing(`dyr')
egen `sumdyr'=total(`dyrdot'*`dyrdot')
local sigmar=`sumdyr'[1]/(`capN'*(`capT'-1))
egen `sumdyr2'=total(`dyrdot'^4)
local kur=(((`capT'^2*`sumdyr2'[1])/`capN')-(3*(`capT'-1)*(2*`capT'-3)*(`sigmar'^2)))/((`capT'-1)*(`capT'^2-3*`capT'+3)*(`sigmar'^2))


replace `storedresult2'=.

forvalues mfc=2/`minirealt'{
local brokentt2=`mfc'

scalar `brokent2'=`mfc'


replace `storedresult'=.
forvalues mfc2=`mfc'/`minirealt'{
local des2=`mfc'+1
if `mfc2' != `mfc' & `mfc2' != `des2'{
local brokentt3=`mfc2'

scalar `brokent3'=`mfc2'



mata:boot2p2a(`realt',`brokentt2',`capN',`brokentt3',`sigma',`ku',"`lagdepvar'","`realdepvar'","`idd'","`mii'")

scalar `sta'=r(sta)
mata:boot2p2b(`realt',`brokentt2',`capN',`brokentt3',`sigmar',`kur',"`lagyirvar'","`yirvart'","`idd'","`ymii'")
scalar `sta2'=r(sta2)
scalar `deltz'=`sta2'-`sta'
replace `storedresult'=`deltz' in `mfc2'


}

}
capture drop `finymin'
tempvar finymin
egen `finymin'=min(`storedresult')
local finzz=`finymin'[1]

replace `storedresult2'=`finzz' in `mfc'
}
capture drop `zmin'
tempvar zmin
egen `zmin'=min(`storedresult2')
scalar `zr'=`zmin'[1]

local hplus=`mc'+1
replace `cv'=`zr' in `hplus'

}
centile `cv',centile(`level')
scalar `rho'=`zd'
scalar  `p'=r(c_1)
tempname pv
count if `cv'<`rho' & !missing(`cv')
scalar `pv'=r(N)/`rep'

			//M2 model
}



		//unknown breaks
}






	//2 break
}











//quietly
}




if "`known'" ==""{
ret clear
ret scalar N=`capN'*`capT'
ret scalar N_g=`capN'
ret scalar T=`capT'
ret scalar Z=`rho'
ret scalar cv=`p'
ret scalar lev=`size'
ret scalar breaks=`numofbreak'
ret scalar pvalue=`pv'
ret scalar Rep=`rep'
ret scalar boot=`rep'
ret scalar khat=`ku'
ret scalar shat=`sigma'
ret scalar fihat=`fihat'
ret scalar seed=`seed'
ret local model "`mod'"
ret local varname "`devar'"
ret local tvar "`timevar'"
ret local idvar "`panelvar'"
ret local avert=`countmi'/`capN'+1


if `numofbreak'==1{
ret scalar break1=`fint'+1
ret local date1: di `fmt' `timevar'[return(break1)]

}
else{
ret scalar break1=`fint'+1
ret scalar break2=`fint2'+1
ret local date1: di `fmt' `timevar'[return(break1)]
ret local date2: di `fmt' `timevar'[return(break2)]

}

if "`nobootstrap'" != ""{
ret scalar cv=.
}

if "`het'" != ""{
ret matrix sigmai=`vecsigma'
ret matrix kui=`vecku'

}

di as text "Karavias and Tzavalis (2014) panel unit root test for " as res "`varlist'"
di in smcl as text "{hline 78}"
di as text "H0: All panel time series are unit root processes"			
di as text "H1: Some or all of the panel time series are stationary processes"				
di in smcl as text "{hline 78}"

di as text "Number of panels"  ///
	_col(12) ":"  ///
	_col(35) as res return(N_g)  ///
	_col(45) as text "Avrge number of periods"				///
	_col(61) ":"						///
	_col(70) %5.2f as res `return(avert)'
	
di as text  "Number of breaks"            ///
			_col(12) ":" 						///
			_col(35) as res return(breaks) ///
				_col(45) as text "Bootstrap replications"		///		///
	_col(61) ":"						///
	_col(70) as res return(boot)

di as text "Cross-section dependence: " _c
	if "`csd'" == ""{
		di as res _col(35) "No" _c
	}
	else {
		di as res _col(35) "Yes" _c
	}
di as text _col(45) "Linear time trend:" _c
		if `model' == 1{
		di as res _col(70)"No"
	}
	else {
		di as res _col(70) "Yes" 
	}
di as text "Cross-section heteroskedasticity: " _c
	if "`het'" == ""{
		di as res _col(35) "No" _c
	}
	else {
		di as res _col(35) "Yes" _c
	}
di as text _col(45) "Normal errors:" _c
		if "`normal'" == ""{
		di as res _col(70) "No" 
	}
	else {
		di as res _col(70) "Yes" 
	}


di in smcl as text "{hline 78}"
	di as text _col(21) "Statistic" _col(33) "Bootstrap critical-value" _col(65) "p-value"
	di in smcl as text "{hline 78}"
	di as text _col(2) "minZ-statistic"			///
		as res _col(21) %8.4f return(Z)	///
		as res _col(42) %6.4f return(cv)	///
		as res _col(65) %6.4f return(pvalue)
	di in smcl as text "{hline 78}"
	

	
if `rho' < `p'{
di as result "Result: the null is rejected" 
di as text "Estimated break date(s):" _c
if "`showindex'"==""{
if `numofbreak'==1{
	di as text _col(23) return(date1) 
}
else{
	di as text _col(23) return(date1)			///
	_col(33) return(date2)
}	
}		
else{
if `numofbreak'==1{
	di as text _col(23) return(break1) 
}
else{
	di as text _col(23) return(break1)			///
	_col(33) return(break2)
}		
}

}

else{
di as result "Result: the null is not rejected"
}	
	
di as text "Significance level of test"	///
	_col(14) ":"  ///
	_col(30) as text return(lev)	
	
	
	
if "`nobootstrap'" != ""{
di as text ""

di as text "Approximate asymptotic critical values can be found in Table 1 of Karavias and"
di as text "Tzavalis (2014), for one break:"
di in smcl as text "{hline 78}"
di as text _col(3) "sig(%)" _col(13) "T"
di in smcl as text _col(10) "{hline 69}"
di as text  _col(13) "Panel A(for model M1)"  _col(48) "panel B(for model M2)"
di in smcl as text _col(10) "{hline 32}" _col(47) "{hline 32}"
di as text _col(13) "10" _col(21) "15" _col(29) "25" _col(37) "50" ///
_col(48) "10" _col(56) "15" _col(64) "25" _col(72) "50"
di in smcl as text "{hline 78}"
di as text _col(3) "1" _col(13) "-2.91" _col(21) "-2.95" _col(29) "-2.98" _col(37) "-3.05" ///
_col(48) "-2.92" _col(56) "-2.97" _col(64) "-3.04" _col(72) "-3.10"
di as text _col(3) "5" _col(13) "-2.15" _col(21) "-2.33" _col(29) "-2.37" _col(37) "-2.43" ///
_col(48) "-2.31" _col(56) "-2.38" _col(64) "-2.43" _col(72) "-2.49"
di as text _col(3) "10" _col(13) "-1.83" _col(21) "-2.00" _col(29) "-2.04" _col(37) "-2.10" ///
_col(48) "-1.99" _col(56) "-2.07" _col(64) "-2.11" _col(72) "-2.16"
di in smcl as text "{hline 78}"
}
	

	
	
	
	
}

if "`known'" !=""{
ret clear

ret scalar N=`capN'*`capT'
ret scalar N_g=`capN'
ret scalar T=`capT'
ret scalar Z=`rho'
ret scalar pvalue=`p'
ret scalar breaks=`numofbreak'
ret scalar cv=`critival'
ret scalar lev=`size'
ret scalar khat=`ku'
ret scalar shat=`sigma'
ret scalar fihat=`fihat'
ret local model "`mod'"
ret local varname "`devar'"
ret local tvar "`timevar'"
ret local idvar "`panelvar'"
ret local avert=(`countmi'/`capN'+1)

if "`het'" != ""{
ret matrix sigmai=`vecsigma'
ret matrix kui=`vecku'

}


if `numofbreak'==1{
ret scalar break1=`brokentt'+1
ret local date1: di `fmt' `timevar'[return(break1)]

}
else{
ret scalar break1=`brokentt'+1
ret scalar break2=`brokentt2'+1
ret local date1: di `fmt' `timevar'[return(break1)]
ret local date2: di `fmt' `timevar'[return(break2)]

}

di as text "Karavias and Tzavalis (2014) panel unit root test for " as res "`varlist'"
di in smcl as text "{hline 78}"
di as text "H0: All panel time series are unit root processes"			
di as text "H1: Some or all of the panel time series are stationary processes"				
di in smcl as text "{hline 78}"

di as text "Number of panels"  ///
	_col(12) ":"  ///
	_col(35) as res return(N_g)  ///
	_col(45) as text "Avrge number of periods"				///
	_col(61) ":"						///
	_col(70) %5.2f as res `return(avert)'

di as text  "Number of breaks"            ///
			_col(12) ":" 						///
			_col(35) as res return(breaks)	

di as text "Cross-section dependence: " _c
	if "`csd'" == ""{
		di as res _col(35) "No" _c
	}
	else {
		di as res _col(35) "Yes" _c
	}
di as text _col(45) "Linear time trend:" _c
		if `model' == 1{
		di as res _col(70)"No"
	}
	else {
		di as res _col(70) "Yes" 
	}
di as text "Cross-section heteroskedasticity: " _c
	if "`het'" == ""{
		di as res _col(35) "No" _c
	}
	else {
		di as res _col(35) "Yes" _c
	}
di as text _col(45) "Normal errors:" _c
		if "`normal'" == ""{
		di as res _col(70) "No" 
	}
	else {
		di as res _col(70) "Yes" 
	}

			
di in smcl as text "{hline 78}"
	di as text _col(21) "Statistic" _col(33) "Asymtotic critical-value" _col(65) "p-value"
	di in smcl as text "{hline 78}"
	di as text _col(2) "Z-statistic"			///
		as res _col(21) %8.4f return(Z)	///
		as res _col(42) %6.4f return(cv)	///
		as res _col(65) %6.4f return(pvalue)
	di in smcl as text "{hline 78}"


if `rho' < `critival'{
di as result "Result: the null is rejected" 

di as text "Known break date(s):" _c
if "`showindex'"==""{
if `numofbreak'==1{
	di as text _col(23) return(date1) 
}
else{
	di as text _col(23) return(date1)			///
	_col(32) return(date2)
}	
}		
else{
if `numofbreak'==1{
	di as text _col(23) return(break1) 
}
else{
	di as text _col(23) return(break1)			///
	_col(33) return(break2)
}		
}
}
else{
di as result "Result: the null is not rejected"
}


di as text "Significance level of test"	///
	_col(14) ":"  ///
	_col(30) as text return(lev)
}




end




capture mata mata drop ori()
version 12
mata:
void ori(real scalar realt,real scalar n,string rowvector differy,string rowvector idd,string rowvector depvar,string rowvector xtid,string rowvector dmi,string rowvector diffmi)
{
real matrix D,Vid,g,go,b3,Yt
real scalar plusn,plust
D=Vid=Yt=Vix=G=GD=.
st_view(D,.,differy,0)
st_view(Vid,.,idd,0)
st_view(Yt,.,depvar,0)
st_view(Vix,.,xtid,0)
st_view(G,.,dmi,0)
st_view(GD,.,diffmi,0)

plust=realt+1
b1=J(realt,1,0)
md1=J(realt,1,0)
info=panelsetup(Vid,1)
for (i=1;i<=rows(info);i++){
Di=panelsubmatrix(D,i,info)
GDi=panelsubmatrix(GD,i,info)
b1=b1,Di
md1=md1,GDi
}
plusn=n+1
b2=b1[.,(2..plusn)]
md2=md1[.,(2..plusn)]


bx1=J(plust,1,0)
mi1=J(plust,1,0)
info2=panelsetup(Vix,1)
for (i=1;i<=rows(info2);i++){
Yi=panelsubmatrix(Yt,i,info2)
Gi=panelsubmatrix(G,i,info2)
bx1=bx1,Yi
mi1=mi1,Gi
}
bx2=bx1[.,(2..plusn)]
mi2=mi1[.,(2..plusn)]

g=runiform(n,1)'
go=floor(n*g)+J(n,1,1)'
b3=b2[.,go]
md3=md2[.,go]

tri=J(realt,realt,1)
v=tri-uppertriangle(tri,.)

bxx1=J(plust,1,0)
mxx1=J(plust,1,0)
info3=panelsetup(Vid,1)
for (i=1;i<=rows(info3);i++){
Yzi=bx2[1,i]
Ysi=(bx2[1,i]*J(1,realt,1))'+v*b3[.,i]+b3[.,i]
Yfi=Yzi\Ysi
bxx1=bxx1,Yfi

Mzi=mi2[1,i]
Msi=(mi2[1,i]*J(1,realt,1))'+v*md3[.,i]+md3[.,i]
Mfi=Mzi\Msi
mxx1=mxx1,Mfi

}
b4=bxx1[.,(2..plusn)]
m4=mxx1[.,(2..plusn)]
st_eclear()
st_matrix("r(ori)",b4)
st_matrix("r(omi)",m4)
}
end




capture mata mata drop orit()
version 12
mata:
void orit(real scalar realt,real scalar n,string rowvector differy,string rowvector idd,string rowvector depvar,string rowvector xtid)
{
real matrix D,Vid,g,go,b3,Yt
real scalar plusn,plust
D=Vid=Yt=Vix=.
st_view(D,.,differy,0)
st_view(Vid,.,idd,0)
st_view(Yt,.,depvar,0)
st_view(Vix,.,xtid,0)

plust=realt+1
b1=J(realt,1,0)

info=panelsetup(Vid,1)
for (i=1;i<=rows(info);i++){
Di=panelsubmatrix(D,i,info)
b1=b1,Di
}
plusn=n+1
b2=b1[.,(2..plusn)]


bx1=J(plust,1,0)
info2=panelsetup(Vix,1)
for (i=1;i<=rows(info2);i++){
Yi=panelsubmatrix(Yt,i,info2)
bx1=bx1,Yi
}
bx2=bx1[.,(2..plusn)]

g=runiform(n,1)'
go=floor(n*g)+J(n,1,1)'
b3=b2[.,go]

tri=J(realt,realt,1)
v=tri-uppertriangle(tri,.)

bxx1=J(plust,1,0)
info3=panelsetup(Vid,1)
for (i=1;i<=rows(info3);i++){
Yzi=bx2[1,i]
Ysi=(bx2[1,i]*J(1,realt,1))'+v*b3[.,i]+b3[.,i]
Yfi=Yzi\Ysi
bxx1=bxx1,Yfi
}
b4=bxx1[.,(2..plusn)]

st_eclear()
st_matrix("r(ori)",b4)
}
end





capture mata mata drop taskp()
version 12
mata:
void taskp(real scalar realt,real scalar brokentt,real scalar n,real scalar sigma,real scalar ku,string rowvector lagdepvar,string rowvector realdepvar,string rowvector idd,string rowvector mii)
{
real matrix X,Y,Vid,el1,el2,ell1,ell2,Xm,Im,Qm,b1,b2,b,tri,v,A,A2
real scalar leftt,B,C,z


X=Y=Vid=G=.

st_view(X,.,lagdepvar,0)
st_view(Y,.,realdepvar,0)
st_view(Vid,.,idd,0)
st_view(G,.,mii,0)



leftt=realt-brokentt
el1=J(brokentt,1,1)
el2=J(leftt,1,0)
ell1=J(brokentt,1,0)
ell2=J(leftt,1,1)
Xm=(el1,ell1\el2,ell2)
Im=I(realt)
Qm=Im-Xm*invsym(Xm'*Xm)*Xm'



tri=J(realt,realt,1)
v=tri-uppertriangle(tri,.)

if(st_local("nomiss")=="0"){

info=panelsetup(Vid,1)
b1=0
b2=0

bm1=0
bm2=0


for (i=1;i<=rows(info);i++){

Xi=panelsubmatrix(X,i,info)
Yi=panelsubmatrix(Y,i,info)
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)


Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

b1=b1+Xi'*Qmi*Xi
b2=b2+Xi'*Qmi*Yi

bm1=bm1+trace(v'*Di'*Qmi*Di)
bm2=bm2+trace(v'*Di'*Qmi*Di*v)

}
b=invsym(b1)*b2

B=bm1/bm2


vnum1=0
vnum2=0
for (i=1;i<=rows(info);i++){
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)
Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

Ai=0.5*(v'*Di'*Qmi*Di+Di'*Qmi*Di*v)-B*(v'*Di'*Qmi*Di*v)
Ai2=Ai*Ai
Aj2=Ai:*Ai
vnum1=vnum1+2*trace(Ai2)/n
vnum2=vnum2+trace(Aj2)/n
}
vnum=ku*vnum2+sigma^2*vnum1
vdenom=(sigma*bm2/n)^2



if(st_local("het")==""){
C=(vnum)/(vdenom)
}
else{
M=N=.
st_view(M,.,st_local("vsigma"),0)
st_view(N,.,st_local("vku"),0)
C=0
for (i=1;i<=rows(M);i++){
C=C+(N[i,1]*vnum2+(M[i,1]^2)*vnum1)/((M[i,1]*bm2/n)^2)
}
C=C/(n)
}

}
else{
	
	info=panelsetup(Vid,1)
b1=0
b2=0
for (i=1;i<=rows(info);i++){

Xi=panelsubmatrix(X,i,info)
Yi=panelsubmatrix(Y,i,info)
b1=b1+Xi'*Qm*Xi
b2=b2+Xi'*Qm*Yi
}
b=invsym(b1)*b2


B=trace(v'*Qm)/trace(v'*Qm*v)
A=0.5*(v'*Qm+Qm*v)-B*(v'*Qm*v)
A2=A:*A
if(st_local("het")==""){
C=(ku*trace(A2)+2*(sigma^2)*trace(A*A))/((sigma*trace(v'*Qm*v))^2)
}
else{
M=N=.
st_view(M,.,st_local("vsigma"),0)
st_view(N,.,st_local("vku"),0)
C=0
for (i=1;i<=rows(M);i++){
C=C+(N[i,1]*trace(A2)+2*(M[i,1]^2)*trace(A*A))/((M[i,1]*trace(v'*Qm*v))^2)
}
C=C/(n)
}
	
}



z=sqrt(n)*(b-1-B)/sqrt(C)
st_eclear()



st_numscalar("r(sta)",z)
st_numscalar("r(fihat)",b)
}
end




capture mata mata drop taskp2()
version 12
mata:
void taskp2(real scalar realt,real scalar brokentt,real scalar n,real scalar sigma,real scalar ku,string rowvector lagdepvar,string rowvector realdepvar,string rowvector idd,string rowvector tt1,string rowvector tt2,string rowvector mii)
{
real matrix X,Y,Vid,el1,el2,ell1,ell2,Xm,Im,Qm,b1,b2,b,tri,v,A,pi1,pi2,M,Xmm,A2
real scalar leftt,B,C,z,sett

X=Y=Vid=pi1=pi2=M=G=.
st_view(X,.,lagdepvar,0)
st_view(Y,.,realdepvar,0)
st_view(Vid,.,idd,0)
st_view(M,.,(tt1,tt2),0)
st_view(G,.,mii,0)
sett=realt+1
st_subview(pi1,M,(2,sett),1)
st_subview(pi2,M,(2,sett),2)

leftt=realt-brokentt
el1=J(brokentt,1,1)
el2=J(leftt,1,0)
ell1=J(brokentt,1,0)
ell2=J(leftt,1,1)
Xmm=(el1,ell1\el2,ell2)
Xm=(Xmm,pi1,pi2)
Im=I(realt)
Qm=Im-Xm*invsym(Xm'*Xm)*Xm'


tri=J(realt,realt,1)
v=tri-uppertriangle(tri,.)

info=panelsetup(Vid,1)
b1=0
b2=0

bm1=0
bm2=0


for (i=1;i<=rows(info);i++){

Xi=panelsubmatrix(X,i,info)
Yi=panelsubmatrix(Y,i,info)
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)


Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

b1=b1+Xi'*Qmi*Xi
b2=b2+Xi'*Qmi*Yi

bm1=bm1+trace(v'*Di'*Qmi*Di)
bm2=bm2+trace(v'*Di'*Qmi*Di*v)

}
b=invsym(b1)*b2

B=bm1/bm2

vnum1=0
vnum2=0
for (i=1;i<=rows(info);i++){
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)
Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

Ai=0.5*(v'*Di'*Qmi*Di+Di'*Qmi*Di*v)-B*(v'*Di'*Qmi*Di*v)
Ai2=Ai*Ai
Aj2=Ai:*Ai
vnum1=vnum1+2*trace(Ai2)/n
vnum2=vnum2+trace(Aj2)/n
}
vnum=ku*vnum2+sigma^2*vnum1
vdenom=(sigma*bm2/n)^2


if(st_local("het")==""){
C=(vnum)/(vdenom)
}
else{
M=N=.
st_view(M,.,st_local("vsigma"),0)
st_view(N,.,st_local("vku"),0)
C=0
for (i=1;i<=rows(M);i++){
C=C+(N[i,1]*vnum2+(M[i,1]^2)*vnum1)/((M[i,1]*bm2/n)^2)
}
C=C/(n)
}
z=sqrt(n)*(b-1-B)/sqrt(C)
st_eclear()

st_numscalar("r(sta)",z)
st_numscalar("r(fihat)",b)
}
end




capture mata mata drop task2p()
version 12
mata:
void task2p(real scalar realt,real scalar brokentt,real scalar n,real scalar brokentt2,real scalar sigma,real scalar ku,string rowvector lagdepvar,string rowvector realdepvar,string rowvector idd,string rowvector mii)
{
real matrix X,Y,Vid,el1,el2,ell1,ell2,Xm,Im,Qm,b1,b2,b,tri,v,A,A2,el3,ell3,elll1,elll2,elll3
real scalar leftt,B,C,z,leftt2


X=Y=Vid=G=.

st_view(X,.,lagdepvar,0)
st_view(Y,.,realdepvar,0)
st_view(Vid,.,idd,0)
st_view(G,.,mii,0)



leftt1=brokentt2-brokentt
leftt2=realt-brokentt2
el1=J(brokentt,1,1)
el2=J(leftt1,1,0)
el3=J(leftt2,1,0)
ell1=J(brokentt,1,0)
ell2=J(leftt1,1,1)
ell3=J(leftt2,1,0)
elll1=J(brokentt,1,0)
elll2=J(leftt1,1,0)
elll3=J(leftt2,1,1)
Xm=(el1,ell1,elll1\el2,ell2,elll2\el3,ell3,elll3)
Im=I(realt)
Qm=Im-Xm*invsym(Xm'*Xm)*Xm'


tri=J(realt,realt,1)
v=tri-uppertriangle(tri,.)

info=panelsetup(Vid,1)
b1=0
b2=0

bm1=0
bm2=0


for (i=1;i<=rows(info);i++){

Xi=panelsubmatrix(X,i,info)
Yi=panelsubmatrix(Y,i,info)
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)


Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

b1=b1+Xi'*Qmi*Xi
b2=b2+Xi'*Qmi*Yi

bm1=bm1+trace(v'*Di'*Qmi*Di)
bm2=bm2+trace(v'*Di'*Qmi*Di*v)

}
b=invsym(b1)*b2

B=bm1/bm2


vnum1=0
vnum2=0
for (i=1;i<=rows(info);i++){
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)
Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

Ai=0.5*(v'*Di'*Qmi*Di+Di'*Qmi*Di*v)-B*(v'*Di'*Qmi*Di*v)
Ai2=Ai*Ai
Aj2=Ai:*Ai
vnum1=vnum1+2*trace(Ai2)/n
vnum2=vnum2+trace(Aj2)/n
}
vnum=ku*vnum2+sigma^2*vnum1
vdenom=(sigma*bm2/n)^2



if(st_local("het")==""){
C=(vnum)/(vdenom)
}
else{
M=N=.
st_view(M,.,st_local("vsigma"),0)
st_view(N,.,st_local("vku"),0)
C=0
for (i=1;i<=rows(M);i++){
C=C+(N[i,1]*vnum2+(M[i,1]^2)*vnum1)/((M[i,1]*bm2/n)^2)
}
C=C/(n)
}
z=sqrt(n)*(b-1-B)/sqrt(C)
st_eclear()

st_numscalar("r(sta)",z)
st_numscalar("r(fihat)",b)
}
end



capture mata mata drop task2p2()
version 12
mata:
void task2p2(real scalar realt,real scalar brokentt,real scalar n,real scalar brokentt2,real scalar sigma,real scalar ku,string rowvector lagdepvar,string rowvector realdepvar,string rowvector idd,string rowvector tt1,string rowvector tt2,string rowvector tt3,string rowvector mii)
{
real matrix X,Y,Vid,el1,el2,ell1,ell2,Xm,Im,Qm,b1,b2,b,tri,v,A,pi1,pi2,M,Xmm,A2,pi3,el3,ell3,elll1,elll2,elll3
real scalar leftt,B,C,z,sett,leftt2

X=Y=Vid=pi1=pi2=M=G=.
st_view(X,.,lagdepvar,0)
st_view(Y,.,realdepvar,0)
st_view(Vid,.,idd,0)
st_view(M,.,(tt1,tt2,tt3),0)
st_view(G,.,mii,0)
sett=realt+1
st_subview(pi1,M,(2,sett),1)
st_subview(pi2,M,(2,sett),2)
st_subview(pi3,M,(2,sett),3)


leftt1=brokentt2-brokentt
leftt2=realt-brokentt2
el1=J(brokentt,1,1)
el2=J(leftt1,1,0)
el3=J(leftt2,1,0)
ell1=J(brokentt,1,0)
ell2=J(leftt1,1,1)
ell3=J(leftt2,1,0)
elll1=J(brokentt,1,0)
elll2=J(leftt1,1,0)
elll3=J(leftt2,1,1)
Xmm=(el1,ell1,elll1\el2,ell2,elll2\el3,ell3,elll3)
Xm=(Xmm,pi1,pi2,pi3)
Im=I(realt)
Qm=Im-Xm*invsym(Xm'*Xm)*Xm'


tri=J(realt,realt,1)
v=tri-uppertriangle(tri,.)

info=panelsetup(Vid,1)
b1=0
b2=0

bm1=0
bm2=0


for (i=1;i<=rows(info);i++){

Xi=panelsubmatrix(X,i,info)
Yi=panelsubmatrix(Y,i,info)
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)


Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

b1=b1+Xi'*Qmi*Xi
b2=b2+Xi'*Qmi*Yi

bm1=bm1+trace(v'*Di'*Qmi*Di)
bm2=bm2+trace(v'*Di'*Qmi*Di*v)

}
b=invsym(b1)*b2

B=bm1/bm2


vnum1=0
vnum2=0
for (i=1;i<=rows(info);i++){
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)
Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

Ai=0.5*(v'*Di'*Qmi*Di+Di'*Qmi*Di*v)-B*(v'*Di'*Qmi*Di*v)
Ai2=Ai*Ai
Aj2=Ai:*Ai
vnum1=vnum1+2*trace(Ai2)/n
vnum2=vnum2+trace(Aj2)/n
}
vnum=ku*vnum2+sigma^2*vnum1
vdenom=(sigma*bm2/n)^2



if(st_local("het")==""){
C=(vnum)/(vdenom)
}
else{
M=N=.
st_view(M,.,st_local("vsigma"),0)
st_view(N,.,st_local("vku"),0)
C=0
for (i=1;i<=rows(M);i++){
C=C+(N[i,1]*vnum2+(M[i,1]^2)*vnum1)/((M[i,1]*bm2/n)^2)
}
C=C/(n)
}
z=sqrt(n)*(b-1-B)/sqrt(C)
st_eclear()

st_numscalar("r(sta)",z)
st_numscalar("r(fihat)",b)
}
end







capture mata mata drop boot1p1b()
version 12
mata:
void boot1p1b(real scalar realt,real scalar brokenttt,real scalar n,real scalar sigmar,real scalar kur,string rowvector lagyirvar,string rowvector yirvart,string rowvector idd,string rowvector mii)
{
real matrix X,Y,Vid,el1,el2,ell1,ell2,Xm,Im,Qm,b1,b2,b,tri,v,A,A2
real scalar leftt,B,C,z

X=Y=Vid=G=.
st_view(X,.,lagyirvar,0)
st_view(Y,.,yirvart,0)
st_view(Vid,.,idd,0)
st_view(G,.,mii,0)

leftt=realt-brokenttt
el1=J(brokenttt,1,1)
el2=J(leftt,1,0)
ell1=J(brokenttt,1,0)
ell2=J(leftt,1,1)
Xm=(el1,ell1\el2,ell2)
Im=I(realt)
Qm=Im-Xm*invsym(Xm'*Xm)*Xm'



tri=J(realt,realt,1)
v=tri-uppertriangle(tri,.)

if(st_local("nomiss")=="0"){

info=panelsetup(Vid,1)
b1=0
b2=0

bm1=0
bm2=0


for (i=1;i<=rows(info);i++){

Xi=panelsubmatrix(X,i,info)
Yi=panelsubmatrix(Y,i,info)
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)


Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

b1=b1+Xi'*Qmi*Xi
b2=b2+Xi'*Qmi*Yi

bm1=bm1+trace(v'*Di'*Qmi*Di)
bm2=bm2+trace(v'*Di'*Qmi*Di*v)

}
b=invsym(b1)*b2

B=bm1/bm2


vnum1=0
vnum2=0
for (i=1;i<=rows(info);i++){
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)
Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

Ai=0.5*(v'*Di'*Qmi*Di+Di'*Qmi*Di*v)-B*(v'*Di'*Qmi*Di*v)
Ai2=Ai*Ai
Aj2=Ai:*Ai
vnum1=vnum1+2*trace(Ai2)/n
vnum2=vnum2+trace(Aj2)/n
}
vnum=kur*vnum2+sigmar^2*vnum1
vdenom=(sigmar*bm2/n)^2


C=(vnum)/(vdenom)

}

else{
	
info=panelsetup(Vid,1)
b1=0
b2=0
for (i=1;i<=rows(info);i++){

Xi=panelsubmatrix(X,i,info)
Yi=panelsubmatrix(Y,i,info)
b1=b1+Xi'*Qm*Xi
b2=b2+Xi'*Qm*Yi
}
b=invsym(b1)*b2


tri=J(realt,realt,1)
v=tri-uppertriangle(tri,.)
B=trace(v'*Qm)/trace(v'*Qm*v)
A=0.5*(v'*Qm+Qm*v)-B*(v'*Qm*v)
A2=A:*A
C=(kur*trace(A2)+2*(sigmar^2)*trace(A*A))/((sigmar*trace(v'*Qm*v))^2)
	
}




z=sqrt(n)*(b-1-B)/sqrt(C)
st_eclear()

st_numscalar("r(sta2)",z)
st_numscalar("r(fihat)",b)
}
end


capture mata mata drop boot1p2a()
version 12
mata:
void boot1p2a(real scalar realt,real scalar brokenttt,real scalar n,real scalar sigma,real scalar ku,string rowvector lagdepvar,string rowvector realdepvar,string rowvector idd,string rowvector mii)
{
real matrix X,Y,Vid,el1,el2,ell1,ell2,Xm,Im,Qm,b1,b2,b,tri,v,A,A2,pi1,pi2,M,Xmm
real scalar leftt,B,C,z,sett

X=Y=Vid=pi1=pi2=G=.
st_view(X,.,lagdepvar,0)
st_view(Y,.,realdepvar,0)
st_view(Vid,.,idd,0)
sett=realt+1
st_view(G,.,mii,0)

leftt=realt-brokenttt
el1=J(brokenttt,1,1)
el2=J(leftt,1,0)
ell1=J(brokenttt,1,0)
ell2=J(leftt,1,1)
Xmm=(el1,ell1\el2,ell2)

pi11=(1::brokenttt)
pi12=J(leftt,1,0)
pi21=J(brokenttt,1,0)
pi22=(brokenttt+1::realt)
pi1=pi11\pi12
pi2=pi21\pi22



Xm=(Xmm,pi1,pi2)
Im=I(realt)
Qm=Im-Xm*invsym(Xm'*Xm)*Xm'


tri=J(realt,realt,1)
v=tri-uppertriangle(tri,.)

if(st_local("nomiss")=="0"){


info=panelsetup(Vid,1)
b1=0
b2=0

bm1=0
bm2=0


for (i=1;i<=rows(info);i++){

Xi=panelsubmatrix(X,i,info)
Yi=panelsubmatrix(Y,i,info)
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)


Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

b1=b1+Xi'*Qmi*Xi
b2=b2+Xi'*Qmi*Yi

bm1=bm1+trace(v'*Di'*Qmi*Di)
bm2=bm2+trace(v'*Di'*Qmi*Di*v)

}
b=invsym(b1)*b2

B=bm1/bm2

vnum1=0
vnum2=0
for (i=1;i<=rows(info);i++){
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)
Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

Ai=0.5*(v'*Di'*Qmi*Di+Di'*Qmi*Di*v)-B*(v'*Di'*Qmi*Di*v)
Ai2=Ai*Ai
Aj2=Ai:*Ai
vnum1=vnum1+2*trace(Ai2)/n
vnum2=vnum2+trace(Aj2)/n
}
vnum=ku*vnum2+sigma^2*vnum1
vdenom=(sigma*bm2/n)^2


if(st_local("het")==""){
C=(vnum)/(vdenom)
}
else{
M=N=.
st_view(M,.,st_local("vsigma"),0)
st_view(N,.,st_local("vku"),0)
C=0
for (i=1;i<=rows(M);i++){
C=C+(N[i,1]*vnum2+(M[i,1]^2)*vnum1)/((M[i,1]*bm2/n)^2)
}
C=C/(n)
}

}
else{
	
	
info=panelsetup(Vid,1)
b1=0
b2=0

for (i=1;i<=rows(info);i++){

Xi=panelsubmatrix(X,i,info)
Yi=panelsubmatrix(Y,i,info)
b1=b1+Xi'*Qm*Xi
b2=b2+Xi'*Qm*Yi
}
b=invsym(b1)*b2


B=trace(v'*Qm)/trace(v'*Qm*v)
A=0.5*(v'*Qm+Qm*v)-B*(v'*Qm*v)
A2=A:*A
if(st_local("het")==""){
C=(ku*trace(A2)+2*(sigma^2)*trace(A*A))/((sigma*trace(v'*Qm*v))^2)
}
else{
M=N=.
st_view(M,.,st_local("vsigma"),0)
st_view(N,.,st_local("vku"),0)
C=0
for (i=1;i<=rows(M);i++){
C=C+(N[i,1]*trace(A2)+2*(M[i,1]^2)*trace(A*A))/((M[i,1]*trace(v'*Qm*v))^2)
}
C=C/n
}
}


z=sqrt(n)*(b-1-B)/sqrt(C)
st_eclear()


st_numscalar("r(sta)",z)
st_numscalar("r(fihat)",b)
}
end


capture mata mata drop boot1p2b()
version 12
mata:
void boot1p2b(real scalar realt,real scalar brokenttt,real scalar n,real scalar sigmar,real scalar kur,string rowvector lagyirvar,string rowvector yirvart,string rowvector idd,string rowvector mii)
{
real matrix X,Y,Vid,el1,el2,ell1,ell2,Xm,Im,Qm,b1,b2,b,tri,v,A,A2,pi1,pi2,M,Xmm
real scalar leftt,B,C,z,sett

X=Y=Vid=G=.
st_view(X,.,lagyirvar,0)
st_view(Y,.,yirvart,0)
st_view(Vid,.,idd,0)
sett=realt+1
st_view(G,.,mii,0)

leftt=realt-brokenttt
el1=J(brokenttt,1,1)
el2=J(leftt,1,0)
ell1=J(brokenttt,1,0)
ell2=J(leftt,1,1)
Xmm=(el1,ell1\el2,ell2)

pi11=(1::brokenttt)
pi12=J(leftt,1,0)
pi21=J(brokenttt,1,0)
pi22=(brokenttt+1::realt)
pi1=pi11\pi12
pi2=pi21\pi22

Xm=(Xmm,pi1,pi2)
Im=I(realt)
Qm=Im-Xm*invsym(Xm'*Xm)*Xm'


tri=J(realt,realt,1)
v=tri-uppertriangle(tri,.)

if(st_local("nomiss")=="0"){
	
info=panelsetup(Vid,1)
b1=0
b2=0

bm1=0
bm2=0


for (i=1;i<=rows(info);i++){

Xi=panelsubmatrix(X,i,info)
Yi=panelsubmatrix(Y,i,info)
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)


Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

b1=b1+Xi'*Qmi*Xi
b2=b2+Xi'*Qmi*Yi

bm1=bm1+trace(v'*Di'*Qmi*Di)
bm2=bm2+trace(v'*Di'*Qmi*Di*v)

}
b=invsym(b1)*b2

B=bm1/bm2

vnum1=0
vnum2=0
for (i=1;i<=rows(info);i++){
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)
Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

Ai=0.5*(v'*Di'*Qmi*Di+Di'*Qmi*Di*v)-B*(v'*Di'*Qmi*Di*v)
Ai2=Ai*Ai
Aj2=Ai:*Ai
vnum1=vnum1+2*trace(Ai2)/n
vnum2=vnum2+trace(Aj2)/n
}
vnum=kur*vnum2+sigmar^2*vnum1
vdenom=(sigmar*bm2/n)^2


C=(vnum)/(vdenom)
}

else{
	
	
info=panelsetup(Vid,1)
b1=0
b2=0

for (i=1;i<=rows(info);i++){

Xi=panelsubmatrix(X,i,info)
Yi=panelsubmatrix(Y,i,info)
b1=b1+Xi'*Qm*Xi
b2=b2+Xi'*Qm*Yi
}
b=invsym(b1)*b2



B=trace(v'*Qm)/trace(v'*Qm*v)
A=0.5*(v'*Qm+Qm*v)-B*(v'*Qm*v)
A2=A:*A
C=(kur*trace(A2)+2*(sigmar^2)*trace(A*A))/((sigmar*trace(v'*Qm*v))^2)
	
}
z=sqrt(n)*(b-1-B)/sqrt(C)
st_eclear()

st_numscalar("r(sta2)",z)
st_numscalar("r(fihat)",b)
}
end






capture mata mata drop boot2p1a()
version 12
mata:
void boot2p1a(real scalar realt,real scalar brokentt,real scalar n,real scalar brokentt2,real scalar sigma,real scalar ku,string rowvector lagdepvar,string rowvector realdepvar,string rowvector idd,string rowvector mii)
{

real matrix X,Y,Vid,el1,el2,ell1,ell2,Xm,Im,Qm,b1,b2,b,tri,v,A,el3,ell3,elll1,elll2,elll3,A2
real scalar leftt1,B,C,z,leftt2

X=Y=Vid=G=.
st_view(X,.,lagdepvar,0)
st_view(Y,.,realdepvar,0)
st_view(Vid,.,idd,0)
st_view(G,.,mii,0)

leftt1=brokentt2-brokentt
leftt2=realt-brokentt2
el1=J(brokentt,1,1)
el2=J(leftt1,1,0)
el3=J(leftt2,1,0)
ell1=J(brokentt,1,0)
ell2=J(leftt1,1,1)
ell3=J(leftt2,1,0)
elll1=J(brokentt,1,0)
elll2=J(leftt1,1,0)
elll3=J(leftt2,1,1)
Xm=(el1,ell1,elll1\el2,ell2,elll2\el3,ell3,elll3)
Im=I(realt)
Qm=Im-Xm*invsym(Xm'*Xm)*Xm'


tri=J(realt,realt,1)
v=tri-uppertriangle(tri,.)
if(st_local("nomiss")=="0"){
	
info=panelsetup(Vid,1)
b1=0
b2=0

bm1=0
bm2=0


for (i=1;i<=rows(info);i++){

Xi=panelsubmatrix(X,i,info)
Yi=panelsubmatrix(Y,i,info)
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)


Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

b1=b1+Xi'*Qmi*Xi
b2=b2+Xi'*Qmi*Yi

bm1=bm1+trace(v'*Di'*Qmi*Di)
bm2=bm2+trace(v'*Di'*Qmi*Di*v)

}
b=invsym(b1)*b2

B=bm1/bm2


vnum1=0
vnum2=0
for (i=1;i<=rows(info);i++){
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)
Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

Ai=0.5*(v'*Di'*Qmi*Di+Di'*Qmi*Di*v)-B*(v'*Di'*Qmi*Di*v)
Ai2=Ai*Ai
Aj2=Ai:*Ai
vnum1=vnum1+2*trace(Ai2)/n
vnum2=vnum2+trace(Aj2)/n
}
vnum=ku*vnum2+sigma^2*vnum1
vdenom=(sigma*bm2/n)^2



if(st_local("het")==""){
C=(vnum)/(vdenom)
}
else{
M=N=.
st_view(M,.,st_local("vsigma"),0)
st_view(N,.,st_local("vku"),0)
C=0
for (i=1;i<=rows(M);i++){
C=C+(N[i,1]*vnum2+(M[i,1]^2)*vnum1)/((M[i,1]*bm2/n)^2)
}
C=C/(n)
}
}
else{
	
info=panelsetup(Vid,1)
b1=0
b2=0
for (i=1;i<=rows(info);i++){

Xi=panelsubmatrix(X,i,info)
Yi=panelsubmatrix(Y,i,info)
b1=b1+Xi'*Qm*Xi
b2=b2+Xi'*Qm*Yi
}
b=invsym(b1)*b2


B=trace(v'*Qm)/trace(v'*Qm*v)
A=0.5*(v'*Qm+Qm*v)-B*(v'*Qm*v)
A2=A:*A
if(st_local("het")==""){
C=(ku*trace(A2)+2*(sigma^2)*trace(A*A))/((sigma*trace(v'*Qm*v))^2)
}
else{
M=N=.
st_view(M,.,st_local("vsigma"),0)
st_view(N,.,st_local("vku"),0)
C=0
for (i=1;i<=rows(M);i++){
C=C+(N[i,1]*trace(A2)+2*(M[i,1]^2)*trace(A*A))/((M[i,1]*trace(v'*Qm*v))^2)
}
C=C/n
}
}
z=sqrt(n)*(b-1-B)/sqrt(C)
st_eclear()


st_numscalar("r(sta)",z)
st_numscalar("r(fihat)",b)
}
end



capture mata mata drop boot2p1b()
version 12
mata:
void boot2p1b(real scalar realt,real scalar brokentt,real scalar n,real scalar brokentt2,real scalar sigmar,real scalar kur,string rowvector lagyirvar,string rowvector yirvart,string rowvector idd,string rowvector mii)
{

real matrix X,Y,Vid,el1,el2,ell1,ell2,Xm,Im,Qm,b1,b2,b,tri,v,A,el3,ell3,elll1,elll2,elll3,A2
real scalar leftt1,B,C,z,leftt2

X=Y=Vid=G=.
st_view(X,.,lagyirvar,0)
st_view(Y,.,yirvart,0)
st_view(Vid,.,idd,0)
st_view(G,.,mii,0)

leftt1=brokentt2-brokentt
leftt2=realt-brokentt2
el1=J(brokentt,1,1)
el2=J(leftt1,1,0)
el3=J(leftt2,1,0)
ell1=J(brokentt,1,0)
ell2=J(leftt1,1,1)
ell3=J(leftt2,1,0)
elll1=J(brokentt,1,0)
elll2=J(leftt1,1,0)
elll3=J(leftt2,1,1)
Xm=(el1,ell1,elll1\el2,ell2,elll2\el3,ell3,elll3)
Im=I(realt)
Qm=Im-Xm*invsym(Xm'*Xm)*Xm'


tri=J(realt,realt,1)
v=tri-uppertriangle(tri,.)
if(st_local("nomiss")=="0"){
info=panelsetup(Vid,1)
b1=0
b2=0

bm1=0
bm2=0


for (i=1;i<=rows(info);i++){

Xi=panelsubmatrix(X,i,info)
Yi=panelsubmatrix(Y,i,info)
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)


Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

b1=b1+Xi'*Qmi*Xi
b2=b2+Xi'*Qmi*Yi

bm1=bm1+trace(v'*Di'*Qmi*Di)
bm2=bm2+trace(v'*Di'*Qmi*Di*v)

}
b=invsym(b1)*b2

B=bm1/bm2


vnum1=0
vnum2=0
for (i=1;i<=rows(info);i++){
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)
Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

Ai=0.5*(v'*Di'*Qmi*Di+Di'*Qmi*Di*v)-B*(v'*Di'*Qmi*Di*v)
Ai2=Ai*Ai
Aj2=Ai:*Ai
vnum1=vnum1+2*trace(Ai2)/n
vnum2=vnum2+trace(Aj2)/n
}
vnum=kur*vnum2+sigmar^2*vnum1
vdenom=(sigmar*bm2/n)^2



C=(vnum)/(vdenom)
}
else{
	
info=panelsetup(Vid,1)
b1=0
b2=0
for (i=1;i<=rows(info);i++){

Xi=panelsubmatrix(X,i,info)
Yi=panelsubmatrix(Y,i,info)
b1=b1+Xi'*Qm*Xi
b2=b2+Xi'*Qm*Yi
}
b=invsym(b1)*b2


B=trace(v'*Qm)/trace(v'*Qm*v)
A=0.5*(v'*Qm+Qm*v)-B*(v'*Qm*v)
A2=A:*A
C=(kur*trace(A2)+2*(sigmar^2)*trace(A*A))/((sigmar*trace(v'*Qm*v))^2)

}


z=sqrt(n)*(b-1-B)/sqrt(C)
st_eclear()

st_numscalar("r(sta2)",z)
st_numscalar("r(fihat)",b)
}
end



capture mata mata drop boot2p2a()
version 12
mata:
void boot2p2a(real scalar realt,real scalar brokentt,real scalar n,real scalar brokentt2,real scalar sigma,real scalar ku,string rowvector lagdepvar,string rowvector realdepvar,string rowvector idd,string rowvector mii)
{
real matrix X,Y,Vid,el1,el2,ell1,ell2,Xm,Im,Qm,b1,b2,b,tri,v,A,pi1,pi2,M,Xmm,pi3,el3,ell3,elll1,elll2,elll3,A2
real scalar leftt1,B,C,z,sett,leftt2

X=Y=Vid=pi1=pi2=pi3=M=G=.
st_view(X,.,lagdepvar,0)
st_view(Y,.,realdepvar,0)
st_view(Vid,.,idd,0)
sett=realt+1
st_view(G,.,mii,0)

leftt1=brokentt2-brokentt
leftt2=realt-brokentt2
el1=J(brokentt,1,1)
el2=J(leftt1,1,0)
el3=J(leftt2,1,0)
ell1=J(brokentt,1,0)
ell2=J(leftt1,1,1)
ell3=J(leftt2,1,0)
elll1=J(brokentt,1,0)
elll2=J(leftt1,1,0)
elll3=J(leftt2,1,1)
Xmm=(el1,ell1,elll1\el2,ell2,elll2\el3,ell3,elll3)

pi11=(1::brokentt)
pi12=J(leftt1,1,0)
pi13=J(leftt2,1,0)
pi21=J(brokentt,1,0)
pi22=(brokentt+1::brokentt2)
pi23=J(leftt2,1,0)
pi31=J(brokentt,1,0)
pi32=J(leftt1,1,0)
pi33=(brokentt2+1::realt)
pi1=pi11\pi12\pi13
pi2=pi21\pi22\pi23
pi3=pi31\pi32\pi33


Xm=(Xmm,pi1,pi2,pi3)
Im=I(realt)
Qm=Im-Xm*invsym(Xm'*Xm)*Xm'

tri=J(realt,realt,1)
v=tri-uppertriangle(tri,.)

if(st_local("nomiss")=="0"){
info=panelsetup(Vid,1)
b1=0
b2=0

bm1=0
bm2=0


for (i=1;i<=rows(info);i++){

Xi=panelsubmatrix(X,i,info)
Yi=panelsubmatrix(Y,i,info)
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)


Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

b1=b1+Xi'*Qmi*Xi
b2=b2+Xi'*Qmi*Yi

bm1=bm1+trace(v'*Di'*Qmi*Di)
bm2=bm2+trace(v'*Di'*Qmi*Di*v)

}
b=invsym(b1)*b2

B=bm1/bm2


vnum1=0
vnum2=0
for (i=1;i<=rows(info);i++){
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)
Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

Ai=0.5*(v'*Di'*Qmi*Di+Di'*Qmi*Di*v)-B*(v'*Di'*Qmi*Di*v)
Ai2=Ai*Ai
Aj2=Ai:*Ai
vnum1=vnum1+2*trace(Ai2)/n
vnum2=vnum2+trace(Aj2)/n
}
vnum=ku*vnum2+sigma^2*vnum1
vdenom=(sigma*bm2/n)^2



if(st_local("het")==""){
C=(vnum)/(vdenom)
}
else{
M=N=.
st_view(M,.,st_local("vsigma"),0)
st_view(N,.,st_local("vku"),0)
C=0
for (i=1;i<=rows(M);i++){
C=C+(N[i,1]*vnum2+(M[i,1]^2)*vnum1)/((M[i,1]*bm2/n)^2)
}
C=C/(n)
}

}

else{
	
info=panelsetup(Vid,1)
b1=0
b2=0
for (i=1;i<=rows(info);i++){

Xi=panelsubmatrix(X,i,info)
Yi=panelsubmatrix(Y,i,info)
b1=b1+Xi'*Qm*Xi
b2=b2+Xi'*Qm*Yi
}
b=invsym(b1)*b2


B=trace(v'*Qm)/trace(v'*Qm*v)
A=0.5*(v'*Qm+Qm*v)-B*(v'*Qm*v)
A2=A:*A
if(st_local("het")==""){
C=(ku*trace(A2)+2*(sigma^2)*trace(A*A))/((sigma*trace(v'*Qm*v))^2)
}
else{
M=N=.
st_view(M,.,st_local("vsigma"),0)
st_view(N,.,st_local("vku"),0)
C=0
for (i=1;i<=rows(M);i++){
C=C+(N[i,1]*trace(A2)+2*(M[i,1]^2)*trace(A*A))/((M[i,1]*trace(v'*Qm*v))^2)
}
C=C/n
}
	
	
}
z=sqrt(n)*(b-1-B)/sqrt(C)
st_eclear()


st_numscalar("r(sta)",z)
st_numscalar("r(fihat)",b)
}
end




capture mata mata drop boot2p2b()
version 12
mata:
void boot2p2b(real scalar realt,real scalar brokentt,real scalar n,real scalar brokentt2,real scalar sigmar,real scalar kur,string rowvector lagyirvar,string rowvector yirvart,string rowvector idd,string rowvector mii)
{
real matrix X,Y,Vid,el1,el2,ell1,ell2,Xm,Im,Qm,b1,b2,b,tri,v,A,pi1,pi2,M,Xmm,pi3,el3,ell3,elll1,elll2,elll3,A2
real scalar leftt1,B,C,z,sett,leftt2

X=Y=Vid=pi1=pi2=pi3=M=G=.
st_view(X,.,lagyirvar,0)
st_view(Y,.,yirvart,0)
st_view(Vid,.,idd,0)
sett=realt+1
st_view(G,.,mii,0)

leftt1=brokentt2-brokentt
leftt2=realt-brokentt2
el1=J(brokentt,1,1)
el2=J(leftt1,1,0)
el3=J(leftt2,1,0)
ell1=J(brokentt,1,0)
ell2=J(leftt1,1,1)
ell3=J(leftt2,1,0)
elll1=J(brokentt,1,0)
elll2=J(leftt1,1,0)
elll3=J(leftt2,1,1)
Xmm=(el1,ell1,elll1\el2,ell2,elll2\el3,ell3,elll3)

pi11=(1::brokentt)
pi12=J(leftt1,1,0)
pi13=J(leftt2,1,0)
pi21=J(brokentt,1,0)
pi22=(brokentt+1::brokentt2)
pi23=J(leftt2,1,0)
pi31=J(brokentt,1,0)
pi32=J(leftt1,1,0)
pi33=(brokentt2+1::realt)
pi1=pi11\pi12\pi13
pi2=pi21\pi22\pi23
pi3=pi31\pi32\pi33



Xm=(Xmm,pi1,pi2,pi3)
Im=I(realt)
Qm=Im-Xm*invsym(Xm'*Xm)*Xm'


tri=J(realt,realt,1)
v=tri-uppertriangle(tri,.)
if(st_local("nomiss")=="0"){
info=panelsetup(Vid,1)
b1=0
b2=0

bm1=0
bm2=0


for (i=1;i<=rows(info);i++){

Xi=panelsubmatrix(X,i,info)
Yi=panelsubmatrix(Y,i,info)
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)


Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

b1=b1+Xi'*Qmi*Xi
b2=b2+Xi'*Qmi*Yi

bm1=bm1+trace(v'*Di'*Qmi*Di)
bm2=bm2+trace(v'*Di'*Qmi*Di*v)

}
b=invsym(b1)*b2

B=bm1/bm2


vnum1=0
vnum2=0
for (i=1;i<=rows(info);i++){
Gi=panelsubmatrix(G,i,info)
Di=diag(Gi)
Qmi=Im-Di*Xm*invsym(Xm'*Di'*Di*Xm)*Xm'*Di

Ai=0.5*(v'*Di'*Qmi*Di+Di'*Qmi*Di*v)-B*(v'*Di'*Qmi*Di*v)
Ai2=Ai*Ai
Aj2=Ai:*Ai
vnum1=vnum1+2*trace(Ai2)/n
vnum2=vnum2+trace(Aj2)/n
}
vnum=kur*vnum2+sigmar^2*vnum1
vdenom=(sigmar*bm2/n)^2


C=(vnum)/(vdenom)

}
else{
	
	
info=panelsetup(Vid,1)
b1=0
b2=0
for (i=1;i<=rows(info);i++){

Xi=panelsubmatrix(X,i,info)
Yi=panelsubmatrix(Y,i,info)
b1=b1+Xi'*Qm*Xi
b2=b2+Xi'*Qm*Yi
}
b=invsym(b1)*b2


B=trace(v'*Qm)/trace(v'*Qm*v)
A=0.5*(v'*Qm+Qm*v)-B*(v'*Qm*v)
A2=A:*A
C=(kur*trace(A2)+2*(sigmar^2)*trace(A*A))/((sigmar*trace(v'*Qm*v))^2)
}

z=sqrt(n)*(b-1-B)/sqrt(C)
st_eclear()


st_numscalar("r(sta2)",z)
st_numscalar("r(fihat)",b)
}
end

