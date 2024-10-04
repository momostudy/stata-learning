*! version 2.0  28Apr2010 B. Sianesi
// density2 score [if], Group(treated) Matched(_weight) twoway_line_options

program define density2

version 10.0

syntax varname [if] [in], Group(varname) [Matched(varname) *]

	marksample touse
	
	tempvar w fw fw0 fw1
	
	kdensity `varlist' if `touse', nograph gen(`w' `fw')
	
	if `"`matched'"' != `""'  {
		kdensity `varlist' if `touse' & `group'==0 [fw=`matched'], nograph gen(`fw0') at(`w')
		label var `fw0' "Matched `group'=0"
		kdensity `varlist' if `touse' & `group'==1 [fw=`matched'], nograph gen(`fw1') at(`w')
		label var `fw1' "Matched `group'=1"
	}
	if `"`matched'"' == `""'  {
		kdensity `varlist' if `touse' & `group'==0, nograph gen(`fw0') at(`w')
		label var `fw0' "`group'=0"
		kdensity `varlist' if `touse' & `group'==1, nograph gen(`fw1') at(`w')
		label var `fw1' "`group'=1"
	}
	
	twoway line `fw1' `fw0' `w',  lw(thick medium) `options' 

end

// twoway (kdensity `varlist' if `group'==1, clwid(thick)) (kdensity `varlist' if `group'==0, clwid(thin) clcolor(black)), xti("") yti("") title(`title') saving(`label', replace)  legend(order(1 "treated" 2 "non-treated")) xlabel(0(.2)1) graphregion(color(gs16)) 
