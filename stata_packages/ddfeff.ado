
*! version 1.0
* By Kerry Du, 29 Oct 2019 
**
* 
capture program drop ddfeff
program define ddfeff, rclass
    version 16

    gettoken word 0 : 0, parse(" =:,")
    while `"`word'"' != ":" & `"`word'"' != "=" {
        if `"`word'"' == "," | `"`word'"'=="" {
                error 198
        }
		local invars `invars' `word'
		gettoken word 0 : 0, parse("=:,")
    }
    unab invars : `invars'

	gettoken word 0 : 0, parse(" =:,")
    while `"`word'"' != ":" & `"`word'"' != "=" {
        if `"`word'"' == "," | `"`word'"'=="" {
                error 198
        }
		local gopvars `gopvars' `word'
		gettoken word 0 : 0, parse(" =:,")
    }
    unab gopvars : `gopvars'
	
	
    syntax varlist [if] [in], dmu(varname) [gx(varlist) gy(varlist) gb(varlist)  ///
	                                       Time(varname) SEQuential GLOB VRS     ///
										   PRODuctivity SAVing(string)           ///
										   maxiter(numlist integer >0 max=1) tol(numlist max=1)]
	
	
	local techtype "contemporaneous production technology"
	local gpt=0
   
   if `"`time'"'==""{
   		local gpt=1
   		local techtype "global production technology"

   }

   if "`glob'"!=""{
	   if "`sequential'"!=""{
	   
		   disp as error "glob and sequential cannot be specified together."
		   error 498	   
	   
	   }
	   
	   local gpt=1
	   local techtype "global production technology"
	
	}
	
	
	
	if "`maxiter'"==""{
		local maxiter=-1
	}
	if "`tol'"==""{
		local tol=-1
	}	
	
	if "`sequential'"!=""{
		if "`time'"==""{
		   disp as error "For sequential model, time() should be specified."
		   error 498
		}
		else{
		   local techflag "<="
		   local techtype "sequential production technology"
		}
	
	}
	
	if "`productivity'"!=""{
		if "`time'"==""{
		   disp as error "For estimating Malmquist–Luenberger productivity index, time() should be specified."
		   error 498
		}
	
	}

	
	preserve
	marksample touse 
	markout `touse' `invars' `gopvars' `gx' `gy' `gb'

	local bopvars `varlist'
	
	local invars: list uniq invars
	local gopvars: list uniq gopvars
	local bopvars: list uniq bopvars
	
	local ninp: word count `invars'
    local ngo: word count `gopvars'
    local nbo: word count `bopvars'
	
	
	confirm numeric var `invars' `gopvars' `bopvars'
	
	
	if "`gx'"!=""{
		local ngx: word count `gx'
		if `ngx'!=`ninp'{
		    disp as error "# of input variables != # of variables specified in gx()."
		    error 498
		}
		local gmat `gmat' `gx'
	
	}
	else{
		forv k=1/`ninp'{
		    tempvar gx_`k'
			qui gen `gx_`k''=0
			local gmat `gmat' `gx_`k''
		}
	
	}
	
	if "`gy'"!=""{
		local ngy: word count `gy'
		if `ngy'!=`ngo'{
		    disp as error "# of desriable output variables != # of variables specified in gy()."
		    error 498
		}
		local gmat `gmat' `gy'
	
	}
	else{
	    local gopvarscopy `gopvars'
		forv k=1/`ngo'{
		    gettoken word gopvarscopy:gopvarscopy
		    tempvar gy_`k'
			qui gen `gy_`k''=`word'
			local gmat `gmat' `gy_`k''
		}
	
	}
		
	if "`gb'"!=""{
		local ngb: word count `gb'
		if `ngb'!=`nbo'{
		    disp as error "# of undesriable output variables != # of variables specified in gb()."
		    error 498
		}
		local gmat `gmat' `gb'
	
	}
	else{
	    local bopvarscopy `bopvars'
		forv k=1/`nbo'{
		    gettoken word bopvarscopy:bopvarscopy
		    tempvar gb_`k'
			qui gen `gb_`k''=-`word'
			local gmat `gmat' `gb_`k''
		}
	
	}	
	
	
	local comvars: list invars & gopvars 
	if !(`"`comvars'"'==""){
		disp as error "`comvars' should not be specified as input and desriable output simultaneously."
		error 498
	}
	
	local comvars: list invars & bopvars
	if !(`"`comvars'"'==""){
		disp as error "`comvars' should not be specified as input and undesriable output simultaneously."
		error 498
	}	
	
	local comvars: list gopvars & bopvars
	if !(`"`comvars'"'==""){
		disp as error "`comvars' should not be specified as desriable and undesriable outputs simultaneously."
		error 498
	}	
		
	

	
	local rstype=1
	if "`vrs'"!=""{
	   local rstype=0
	}
	

	

	qui keep   `invars' `gopvars' `bopvars' `dmu' `time' `gmat' `touse'
	qui gen _Row=_n
	qui keep if `touse'
	label var _Row "Row #"
	qui gen double Dval=.
	label var Dval "Value of DDFs: `techtype'"
	
	if "`productivity'"!=""{
		qui gen double MLPI=.
		label var MLPI "Malmquist–Luenberger productivity index"
		local mql MLPI
	    if "`glob'"==""{
			qui gen double MLEFFCH=.
			local tech MLEFFCH
			label var MLEFFCH "Efficiency Change"
			qui gen double MLTECH=.
			local tecch MLTECH
			label var MLTECH "Technological Change"
		
		}
	
	}
	
	
    tempvar tvar dmu2
	
	qui egen `dmu2'=group(`dmu')
	
	if  `"`time'"'!="" {
	    qui egen `tvar'=group(`time')

	}
	else{
	    qui gen `tvar'=1
		//qui gen `dmu2'=_n
	}
	
	sort `dmu2' `tvar' _Row
	/*
    if "`super'"!=""{
	  local sup "sup"
	}
	*/
	qui mata mata mlib index
	mata: _DDFmain(`"`invars'"',`"`gopvars'"',`"`bopvars'"',"`dmu2'","`tvar'", ///
	               "`gmat'",`gpt',`rstype',"`techflag'","Dval",`"`mql'"',"`tech'", ///
				   "`tecch'",`maxiter',`tol')
	
	if "`productivity'"!=""{
		tempvar t1
		qui bys `dmu2' (`tvar'): gen `t1'=`time'[_n-1]	
		cap qui bys `dmu2' (`tvar'): gen Pdwise=string(`t1')+ "-"+ string(`time')
		cap qui bys `dmu2' (`tvar'): gen Pdwise=`t1'+ "-"+ `time'
		qui bys `dmu2' (`tvar'): replace Pdwise="" if _n==1
		local Periodwise Pdwise
		label var Pdwise "Periodwise"
	}

	
	order _Row `dmu' `time' Dval `Periodwise' `mql' `tech' `tecch'
	keep  _Row `dmu' `time' Dval `Periodwise' `mql' `tech' `tecch'
	
	disp _n(2) " Directional Distance Function Results:"
	disp "    (_Row: Row # in the original data; Dval: Estimated value of DDF)"
	//disp "      S_X : Slack of X"
	list _Row `dmu' `time' Dval if !missing(`Periodwise'), sep(0) 
	di "Note: missing value indicates infeasible problem."
	if "`productivity'"!=""{
		disp _n(2) " Malmquist–Luenberger Productivity Index Results:"
		disp "    (_Row: Row # in the original data; `Periodwise': periodwise)"
		//disp "      S_X : Slack of X"
		list _Row `dmu' `Periodwise' `mql' `tech' `tecch' if !missing(`Periodwise'), sep(0) 
		di "Note: missing value indicates infeasible problem."
	}
	//disp _n
	if `"`saving'"'!=""{
	  save `saving'
	  gettoken filenames saving:saving, parse(",")
	  local filenames `filenames'.dta
	  disp _n `"Estimated Results are saved in `filenames'."'
	}

	return local file `filenames'

	
	restore 
	
	end
	


/*	
make ddfeff, replace toc pkg title(Directional Distance Function for Efficiency/Productivity Analysis) ///
             version(1.0) author(Kerry Du) affiliation(Xiamen University) ///
			 email(kerrydu@xmu.edu.cn) install("ddfeff.ado;ddfeff.sthlp;lddfeff.mlib")
*/
