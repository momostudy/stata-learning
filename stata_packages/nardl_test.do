version 12
clear*
cd $dropbox/adodev/nardl
set more off
 
use okun_usa 

// partial sums
foreach v in un ip {
	generate `v'_pos  = 0
	generate `v'_neg  = 0
	generate d`v'_pos = max(0,D.`v')
	generate d`v'_neg = min(0,D.`v')
	replace  `v'_pos  = L.`v'_pos + d`v'_pos if _n>1
	replace  `v'_neg  = L.`v'_neg + d`v'_neg if _n>1
	}

// Static symmetric, Table 3a	
generate trend = _n
regress un ip trend	

// Static asymmetric, Table 3b	
regress un ip_pos ip_neg 
test ip_pos = ip_neg

// Dynamic linear, Table 4
regress D.un L.un L.ip L(1 11).D.un L(0 2 4).D.ip if tin(1983m3,2003m11)
// long run coefficient:
scalar  Ly = - _b[L.ip] / _b[L.un]
display Ly
testnl  (-1) * _b[L.ip] / _b[L.un] = 0

// Dynamic asymmetric, Table 5
regress D.un L.un L.ip_pos L.ip_neg ///
	L(1 11).D.un L(0 2).D.ip_pos L(0 4).D.ip_neg if tin(1983m3,2003m11)
// long run effects:
scalar  Ly_pos = - _b[L.ip_pos] / _b[L.un]
display Ly_pos  
scalar  Ly_neg =   _b[L.ip_neg] / _b[L.un]
display Ly_neg	// note: Long-run effect refers to a permanent change in IP by -1


 
/* 
Let's try to replicate this with the NARDL command.
You have to specify lag lengths p (dep. var.) and q (for all regressors). 
Notice that p and q refer to levels, so we need to specify p(12) to get up to
the 11th lag in differences. 
*/

nardl un ip if tin(1983m3,2003m11), p(12) q(5)  

// Restricting some coefficients to zero (for re-named variables): 
constraint 1 L2._dy L3._dy L4._dy L5._dy L6._dy L7._dy L8._dy L9._dy L10._dy 
constraint 2 L1._dx1p L3._dx1p L4._dx1p 
constraint 3 L1._dx1n L2._dx1n L3._dx1n 
nardl un ip if tin(1983m3,2003m11), p(12) q(5) horizon(80) constraints(1/3) plot

// as above, with bootstrap CI for asymmetry to get close to Figure 1a
nardl un ip if tin(1983m3,2003m11), p(12) q(5) h(80) constraints(1/3) plot bootstrap(100) level(90)
// Caution: you need to set the number of replications much higher in the "bootstrap" option
graph export nardlplot.png, replace width(1200)


