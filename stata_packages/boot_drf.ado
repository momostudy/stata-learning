*! boot_drf v1.0.0 GCerulli 23oct2014
capture program drop boot_drf
program boot_drf, eclass
version 13
syntax , rep(numlist max=1 integer) ///
[bca saving(string) size(numlist max=1 integer)]
if "`e(cdm2)'" != "ctreatreg"{
error 301
}
else{
local mod `e(cdmline)'
local dep `e(depvar)'
local ci `e(ci)'
local mtype `e(modtype)'
local lenght 100
tempname A B
mat _G=J((`lenght'/5)+1,4,0)
local j=0
foreach i of numlist 0(5)`lenght'{
bootstrap ate_s=e(ate_s) , rep(`rep') `bca' size(`size') : ///
`mod' s(`i')
mat `A' = e(ci_normal)
mat `B'=e(b)
local j=`j'+1
mat _G[`j',1]=`A'[1,1] 
mat _G[`j',2]=`A'[2,1]
mat _G[`j',3]=`B'[1,1]
mat _G[`j',4]=`i'
}
mat list _G
cap drop _G*
svmat _G
capture graph drop boot_drf
graph twoway rcap _G1 _G2 _G4, clwidth(medium) clcolor(blue) clcolor(black) ///
        ||   scatter _G3 _G4, clpattern(dash) clwidth(thin) clcolor(black) ///
        ||   ,   ///
		     name(boot_drf)    ///
             note("Model: `mtype'")   ///
			 xlabel(0 10 20 30 40 50 60 70 80 90 100, labsize(2.5)) ///
             ylabel(,   labsize(2.5)) ///
             yscale(noline) ///
             xscale(noline) ///
             legend(col(1) order(1 2) label(1 "`ci'% significance" ) ///
                                      label(2 "ATE(t)") ///
                                      label(3 " ")) ///
             title("Dose-response function with bootstrapped std. err.", size(4))  ///
             subtitle(" " "Outcome variable: `dep' "" ", size(3)) ///
             xtitle(Dose (t), size(3)) ///
             xsca(titlegap(2)) ///
             ysca(titlegap(2)) ///
             ytitle("ATE(t)", size(3)) ///
             scheme(s2mono) graphregion(fcolor(white))
}
end  // end of "boot_drf"
