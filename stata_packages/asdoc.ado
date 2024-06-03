*! Attaullah Shah; attaullah.shah@imsciences.edu.pk
*! Tenured Associate Professor at the Institute of Management Sciences, Peshawar, Pakistan.
*!-------------------------------------------------------------------------------
*! Version 2.3.9.5 : Changes made on April 10 , 2021   : Bug fixed in sum command when a variable had all empty values

*! Version 2.3.9.4 : Changes made on Jan 30, 2021      : Time series operatr now works with the variable names when exorting data with the list comand. eg asdoc list id year l.x D.x, replace
*  Version 2.3.9.3 : Changes made on Jan 1, 2021       : Bug fixed in the ttest with option unequal: Previously, it would report results for samples with equal variance.
*  Version 2.3.9.2 : Changes made on Dec 25, 2020      : Added Option cell to tabulate command to report cell percentages; (2) eform now works with the detailed regression
*  Version 2.3.9.1 : Changes made on Nov 3, 2020       : Added inspect command to asdoc
*  Version 2.3.9.1 : Changes made on October 30, 2020  : Added option chi2 to tabulate
*  Version 2.3.9.0 : Changes made on October 21, 2020  : Added opton row and col to the table command
*  Version 2.3.8.9 : Changes made on October 12, 2020  : Factor variable now appear with value lables in details regression. Also, the number of observations now do no not have decimal points
*  Version 2.3.8.8 : Changes made on October 5, 2020   : Bug fixed with bys tabstat
*  Version 2.3.8.7 : Changes made on Sep 9, 2020       : Option force added to newey regression
*  Version 2.3.8.6 : Changes made on Sep 4, 2020       : Option col fixed in tabulate
*  Version 2.3.8.5 : Changes made on August 27, 2020   : cnames() option added to two sample ttest. This option can be used to write custom column titles for the mean values of the two groups. Prevously only Mean1 and Mean2 were used as default names.
*  Version 2.3.8.4 : Changes made on August 27, 2020   : Bug fixed in pwcorr
*  Version 2.3.8.3 : Changes made on August 26, 2020   : More than 20 nested regressions are now supported
*  Version 2.3.8.2 : Changes made on August 19, 2020   : Fix to Option row in tabulate when used with nofreq option.
*  Version 2.3.8.1 : Changes made on August 19, 2020   : applies to sum command: bysort or by() now correctly follows the order if the byvariable is numeric.
*  Version 2.3.8.0 : Changes made on August 16, 2020   : Factor variables can now be included in summary statistics, though work on detailed summary is on the to-do list 
*  Version 2.3.7.9 : Changes made on August 16, 2020   : Support added for multiple equation regresions such sureg, sqreg in the nest option. 
*  Version 2.3.7.8 : Changes made on July 30, 2020     : Option row fix in table command. Previously, it was incorrectly reporting column totals 
*  Version 2.3.7.7 : Changes made on July 28, 2020     : Option row fix in tabulate 
*  Version 2.3.7.6 : Changes made on April 16, 2020    : Digit Rounding issue resolved in table command. 
*  Version 2.3.7.5 : Changes made on April 15, 2020    : Option nofvlabel can be used now to suppress the base category of factor variables in nested regressions
*  Version 2.3.7.4 : Changes made on April 9, 2020     : One sample ttest can now accept expression other than == 0
*  Version 2.3.7.3 : Changes made on April 1, 2020     : Fixed bug in ttest by(vars)
*  Version 2.3.7.2 : Changes made on March 19,2020     : Fixed bug in xtpoisson for irr option
*  Version 2.3.7.1 : Changes made on March 9, 2020     : Fixed bug in tabulate with column option
*  Version 2.3.7.0 : Changes made on March 7, 2020     : Added the bysort support for tab commands
*  Version 2.3.6.9 : Changes made on Jan  25, 2020     : Bug fixed in paired ttests 
*  Version 2.3.6.8 : Changes made on Jan  17, 2020     : p-values can now be reported in nested regression tables using option rep(p)
*  Version 2.3.6.7 : Changes made on Jan  1,  2020     : Three- way table : corrected the rowtotal calculations
*  Version 2.3.6.6 : Changes made on Nov 22,  2019     : Option row now works with nofreq option in the tabulate command
*  Version 2.3.6.5 : Changes made on October 12, 2019   : table command now works even with no space between command and option row
*  Version 2.3.6.4 : Changes made on October 11, 2019   : bug fixed in ttest by(varlist)
*  Version 2.3.6.3 : Changes made on October 8, 2019    : Decimal points can be controlld with t-statistics and ttest commands
*  Version 2.3.6.2 : Changes made on October 2, 2019    : IF and IN conditios now works with the table command
*  Version 2.3.6.1 : Changes made on Seperator 29, 2019 : Fixed bug in reset option of nested regression
*  Version 2.3.6.0 : Changes made on Seperator 21, 2019 : Fixed bug when option replace was used as ,replace
*  Version 2.3.5.9 : Changes made on Seperator 10, 2019 : Fixed row and column names issue with wmat
*  Version 2.3.5.8 : Changes made on Aug 18, 2019       : Added support for spearman command
*  Version 2.3.5.7: Changes made on Aug 15, 2019        : Custome title fixed in bys reg
*  Version 2.3.5.6: Changes made on Aug 14, 2019        : Bug fixed where if had both numeric and string-basde conditions
*  Version 2.3.5.5: Changes made on July 27 , 2019      : Bug fixing in the setstars option 
*  Version 2.3.5.4: Changes made on July 25 , 2019      : Adding dpcomma, sep000 for comma period swapping and digit seperators. 

* Version 2.3.5.2: Changes made July 16 , 2019: Adding column formating uisng globals c1_dec etc. 
* Version 2.3.5.1: Changes made July 18 , 2019: Added lastrow(mean) and lastrow(total) to tabstat with bys: 
* Version 2.3.5.0: Changes made July 13 , 2019: tab command with string variables
* Version 2.3.4.9: Changes made July 12 , 2019: Label now works with factor variables in regressions
* Version 2.3.4.8: Changes made July 03 , 2019: Significance stars customizable uisng setstar() option. 
* Version 2.3.4.8: Changes made June 29 , 2019: weights added to the table command
* Version 2.3.4.7: Changes made June 25 , 2019: aweights added
* Version 2.3.4.6: Changes made June 25 , 2019: stat() opton of nested reg improved
* Version 2.3.4.5: Changes made June 24 , 2019: Total row added to the tab command
* Version 2.3.4.4: Changes made June 24 , 2019: Table command now supports date/time variables
* Version 2.3.4.3: Changes made June 19, 2019: File saving made easy. Just use global save "Whatever file name" or use option save() first time with asdoc, then asdoc will remember the file name until Stata is closed or another name is written to the global save macro
* Version 2.3.4.2: Changes made June 19, 2019: Support for emtpy value in accum option, used with row option: 2. Integers do not have decimal points now in option row()
* Version 2.3.4.1: Changes made June 15, 2019: option label added to list command; Fixing bys sum in MacOS
* Version 2.3.4.0: Changes made June 6, 2019: eform() logistic pvalues correction in nested table
* Version 2.3.3.9: command replay added. This is used with bootstrap or other regressions that have complex syntax
* Version 2.3.3.8: Adding significance level for multi levels
* Version 2.3.3.7: Windows and MAC separate processing
/*
	   1. eform option added to nested tables for logistic family of regressions
	   2. Option font added to specify font face, for example, font(Garamond)
	   3. support for ivregress and 2sls added
	   4. Improving output of non-standard Stata output, i.e. multilevel models
	   5. Option fhr fhc for formating header-row and header-column e.g., fhr(\b) for making the title row bold
	   6. Support added for xtmelogit
	   7. Added header row to tab command
	   7. Added support for macOS for the following
	   7.1 wide regression table
	   7.2 option row()
	   7.3 table command revamped completely
	   7.4 proportions
	   8. setting stars level with option setstar e.g, setstars(***@.1, **@.04, *@.01)
	   9. Added confidence intervals to detailed regression
	   10. making stars and confidence intervals optional in detailed regression
	   11. tab command revamped completely
	   12. Table command revamped completely
*/

version 12

prog asdoc, byable(onecall) 
	if `"`0'"' == "" {
		di "No command found"
		help asdoc
		exit
	}

	cap file close temphandle
	cap file open temphandle using "temp.tmp", write replace
	if _rc {
		display as error "The current directory is not writable!
		display as res "The current working directory is " c(pwd) 
		dis as text "{help asdoc} cannot write to this directory. As a solution, {break}you can change to another directory with command {bf: cd}"
		dis as text "For example, try creating a folder {bf:results} in drive {bf:C:},{break}change to that directory, and retry your asdoc command."
		di
		dis as smcl `"{stata "cap mkdir c:/results":  mkdir c:/results}"' 
		di
		dis as smcl `"{stata "cd c:/results":  cd c:/results}"' 
		di
		dis as smcl `"{stata "asdoc `0'":  asdoc `0'}"' 
		exit

	}
	else cap file close temphandle
	cap rm "temp.tmp"

	gettoken anything options : 0, parse(",") bind
	loc svyexists = strmatch("`anything'", "*svy:*")

	if `svyexists' {
		gettoken svy remaining : anything, parse(":")
		gettoken throw anything : remaining, parse(":")
	}

	getoptions `options'
	if strmatch("`poptions'", "*,replace*") loc replace replace
	if "`isreg'" 	!= "" loc command detailedReg
	if "`poptions'" == "" loc poptions ,
	if "`fs'" 		== "" loc fs = 20
	else loc fs 	= `fs'*2
	if "`frs'" 		== "" loc frs = 1300
	if "`abb'" 		== "" loc abb = 20
	if "`stats'" 	!= "" | "`stat'"!="" | "`statistics'" != "" loc stats "`stats' `stat' `statistics'"
	if "`mat'" 		!= "" loc matrix `mat'
	if "`align'" 	== "" loc align r
	if "`font'"		== "" loc font Garamond
	if "`cellwidth'" =="" loc cellwidth 6
	if "`setstars'" != "" global setstars `setstars'
	else if "$setstars" == "" global setstars "***@.01, **@.05, *@.1"
	if "`dec'" 		== "" loc dec 3
	loc opsys `c(os)'
	global system = cond("`opsys'" == "Windows", 4, 1)

	if "`sep000'" != "" & "`sepspace'" != "" {
		dis as error "sepspace and sep000 cannot be used together"
		dis as text "Option sep000 is retained"
		loc sepspace
		global sepspace
	}
	if "`dpcomma'" != "" global dpcomma ","

	if "`sep000'" != "" {

		global sep000 sep000

		global sepspace

	}
	if "`sepspace'" != "" {

		global sep000 

		global sepspace sepspace

	}



	if "`cs'" 		!= "" {
		confirm number `cs'
		loc cs 		= `cs' * 100

	}
	// header row and column formating
	if "`fhr'" != "" loc fhr = subinstr("`fhr'", "/", "\", .)
	if "`fhc'" != "" loc fhc = subinstr("`fhc'", "/", "\", .)


	if "`accum'" != "" {
		if "`replace'" ~= "" {
			dis as error "Option replace cannot be combined with option accum"
			exit
		}
		if "${accum}" != "" global accum ${accum} ,
		gettoken myvalue accum : accum, parse(",")

		while "`myvalue'" != "" {
			cap confirm number `myvalue'
			if _rc loc plucked `myvalue'
			else {
				capture confirm integer number `myvalue'
				if _rc loc plucked : di %9.`dec'f = `myvalue'
				else loc plucked `myvalue'
			}
			global accum ${accum} `plucked'
			gettoken myvalue accum : accum, parse(",")

		}
		global accum = subinstr("${accum}", ")", "\i", .)

		if "`show'" != "" di "${accum}"
		exit
	}
	if "`nest'"=="" & "`nested'" == "" & "$nest" == "" {
		global reset reset
		global nest
	}
	if "`wide'" != "" &  "`nest'" != "" {
		dis as error " wide and nest cannot be used together"
		exit
	}

	else if "`wide'" != "" loc command wideReg
	else if "`accum'" != "" loc command accum
	else if "`nest'" != "" | "`nested'"!="" {
		loc command "nestedReg"
		if "`anything'" == "replay" loc replay replay
		if "`add'" != "" {
			ctq `add'
			loc ntext : word count `ctext'
			if mod(`ntext',2) {
				dis as error "Error in option {bf:add()}"
				dis as text "   You have entered `ntext' word(s) in the option add()" 
				dis as smcl "   add() requires even number of words, each one seperated by a comma" 
				dis as text "   For example,{bf: add}{it:(Industry dummies, YES, Year dummies, YES)}" 
				dis as smcl "   See {help asdoc##37add:this entry} in the help file for more details." 
				exit
			}
		}
		if "`replace'" != "" {
			global modelrun = 1
			loc POS 0
			global AlldepVars ""
			if "`rep'" == "" global REP se
			else global REP `rep'
			global attach1
			global attach2
			global attach3
			global  textrun = 1
			loc header yes
		}
		global  nest = 1

	}

	else {
		if `"`anything'"' != "," {
			loc byexists = strmatch("`anything'", "*:*")
			if inlist("`: word 1 of `0''", "mixed", "xtmelogit", "mi", "xtmixed") {
				loc byexists 0 

			}

			if `byexists' {
				gettoken BY remaining : anything, parse(":")
				gettoken throw _byvars : BY
				gettoken throw anything : remaining, parse(":")
			}

			loc something "is here"
			gettoken what varlistifin : anything
			getcmd `what'

			*----------------------------------fmt blck---------------------------------------------


			*---------------end----------------------------------------------------------------

			if "`command'" == "replay" loc replay replay
			if  "`dec'" == "" loc dec 3
			cap confirm integer number `dec' 
			if _rc {
				dis as error "Error in the option dec()"
				dis as text "you have entered dec(`dec') where dec() expects integers"
				exit 
			}
			if inlist("`command'", "tab", "tab1", "tab2", "table") {
				if strmatch("`options'", "*row*") loc row row
			}

			if inlist("`command'", "sum", "tabstat", "list", "cor", "ttest", ///
				"pwcorr", "aslist", "tab", "tab1") | inlist("`command'", "tab2", "table"){
				cap getifin `varlistifin'
				if _rc getifin2 `varlistifin'
			}


			if "`command'" == "sum" & "`by'" != "" {
				loc command tabstat
				if "`stats'" == "" loc stats "N mean sd min max"
				loc myfirst: word 1 of `anything'
				loc anything = subinstr("`anything'", "`myfirst'", "tabstat", .)
			}


			if "`command'" == "sum" & "`_byvars'" != "" {
				loc command tabstat
				if "`stats'" == "" loc stats "N mean sd min max"

				loc myfirst: word 1 of `anything'
				loc anything = subinstr("`anything'", "`myfirst'", "tabstat", .)
			}

			if "`command'" == "sum" & "`stats'" != "" loc command tabstat

			if inlist("`command'", "sum","cor", "tabstat", "pwcorr", "ameans")  {

				if "`varlist'" == "" {
					qui ds, has(type numeric)
					local varlist "`r(varlist)'"
				}
			}

			if "`command'" != "ttest" {
				cap tsunab varlist : `varlist'
				cap unab varlist : `varlist'
			}
		}

		else {
			if "`text'" == "" & "`matrix'" == "" & "`rowappend'" == "" & "`row'" == ""{
				display as error "No command found"
				display as text "The program requires a valid Stata command or option {opt text(string)}"
				di as text "e.g, {opt asdoc sum, replace} for summary statistics} OR"
				di as text "{cmd: asdoc, text(I want to add this line) append} for adding text to your file"
				exit
			}
			else if "`row'" != "" loc command row

		}
	}
	*---------------------------fmt block-------------------------------------------
	if "`command'" != "setfmt" & "`command'" != "resetfmt" {


		if "`align'" != "" {
			if "`align'" == "r" loc align
			else loc align align(`align')
		}

		//if "`fontformat'" != "" loc fontformat fontformat(`fontformat')

		set_default_format, dec(`dec') format(`format') `dpcomma' `sep000' ///
			`sepspace' `tzok' `align'  fontformat(`fontformat')


	}
	if "`command'" == "setfmt" | "`command'" == "resetfmt" {

		//if "`format'" != "" loc format format(`format')
		//else loc format format("%14.`dec'f")

		if "`align'" != "" {
			if "`align'" == "r" loc align
			else loc align align(`align')
		}
		//if "`fontformat'" != "" loc fontformat fontformat(`fontformat')

	}
	if "`command'" == "setfmt" {


		if "$dpcomma" != "" loc dpcomma $dpcomma

		if "$sep000" != "" loc sep000 $sep000

		if "$sepspace" != "" loc sepspace $sepspace

		dis "All formating options are successfully saved"
		dis "asdoc will remember these until over-written or Stata is closed"

		set_default_format, dec(`dec') format(`format') `dpcomma' `sep000' ///
			`sepspace' `tzok' `align'  fontformat(`fontformat')


		if "`currency'" != "" global currency "`currency'"

		if "`bracket'" != "" global bracket_type "`bracket'"



		exit
	}

	else if "`command'" == "resetfmt" {

		if "`dpcomma'" == "" global dpcomma

		if "`sep000'" == "" global sep000

		if "`sepspace'" == "" global sepspace
		forv i = 1 / 50 {
			cap mac drop c`i'_tzok
			cap mac drop c`i'_disfmt
			cap mac drop c`i'_dec
			cap mac drop c`i'_fmt
			cap mac drop c`i'_align

		}

		set_default_format, dec(`dec') `format' `dpcomma' `sep000' ///
			`sepspace' `tzok' `align'  fontformat(`fontformat')

		dis "All formating options have been reset to default"
		exit
	}
	*-------------------------------------------------------------------------------


	if "`hideresults'" != "" local qui 

	if "`save'" != "" global save "`save'"

	if "${save}" != "" loc save "${save}"

	if "`save'" == "" local save "Myfile.doc"
	else {
		if !strmatch("`save'", "*.*") loc save "`save'.doc"
	}
	loc regtableanything `anything'

	if "`svy'" != "" loc anything svy: `anything' 
	closemall

	*-----------------------------------------------------------------------
	*             REPLACE APPEND ROWAPPEND
	*-----------------------------------------------------------------------
	if "`append'" != "" & "`replace'" != "" {
		di as error "Option append and replace cannot be used together"
		exit
	}
	else if "`rowappend'" != "" & "`replace'" != "" {
		di as error "Option rowappend and replace cannot be used together"
		exit
	}
	cap qui confirm file "`save'" 
	if _rc{
		if  "`append'" != ""  loc append ""
		loc POS 0
		loc replace replace
		if "`header'" == "" loc header yes
		loc rowappend
	}
	else {

		if "`append'" == "" & "`replace'"=="" {
			dis as txt "(File `save' already exists, option {bf:append} was assumed)"
			loc append append

		}
		else if  "`replace'" != "" {
			qui cap rm "`save'"
			if "`header'" == "" loc header yes

		}

	}

	if "`command'" != "wideReg" global wideReg
	if "`command'" != "row" global row


	if "`text'"   != "" mata : rtftext("`save'",`fs',"`append'", "`text'", "`something'", "`font'")


	*-----------------------------------------------------------------------
	* 							wideReg
	*---------------------------------------------------------------------------
	else if "`command'" == "wideReg" {
		if "`by'" == "" & "`_byvars'" == "" {


			`qui' `anything'  `poptions' 
			loc regcommand : word 1 of `anything'

			if inlist("`regcommand'" , "ivreg", "ivregr", "ivregre", "ivregres", "ivregress") {
				loc depvar : word 3 of `anything'
			}

			else loc depvar : word 2 of `anything'
			if "`add'" != "" loc depvar "`add'"

			cap confirm matrix r(table)
			if _rc {
				dis as error "Your Stata command does not have a regression output"
				exit
			}
			mat t = r(table)
			loc varnames : colnames  t

			if "`cnames'" != "" {
				loc Ncnames : word count `cnames'
				loc Nvarnames : word count `varnames'

				loc n = 1
				while `n' <= `Nvarnames' {

					if "`: word `n' of `cnames''" != ""  loc coltitles `coltitles' `: word `n' of `cnames''
					else loc coltitles `coltitles' `: word `n' of `varnames''
					loc `++n'
				}
				loc varnames `coltitles' 
			}


			if "`bracket'" == "" {
				loc btp btp
				loc bName parenthesis
			}
			else loc bName square brackets

			*---------------------------------------
			*            E(STATS)
			*---------------------------------------
			if "`stats'" != "" {
				loc stats= subinstr("`stats'", ",", "", .)
				local AllowedStats "N df_m df_r F rmse mss rss r2_a ll ll_0 rank chi2 p sigma_u sigma_e sigma rho Tbar Tcon N_g g_min r2_o r2_b r2_w"
				if !`: list stats in local(AllowedStats)'{
					display as error "Error in the stats(`stats') option!"
					display as text "only the following statistics are allowed with option flat"
					display as result "`AllowedStats'"
				}
			}
			loc i = 1
			foreach s of local stats {
				if `i' == 1{
					loc estat_text ",`s'"
					if "`s'" != "N" loc a : di %9.`dec'f = e(`s')
					else loc a : di %9.0f = e(`s')
					loc estat ",`a'"
					loc `++i'
				}
				else {
					loc estat_text "`estat_text', `s'"
					loc a : di %9.`dec'f = e(`s')
					loc estat "`estat', `a'"
					loc `++i'

				}
			}
			loc estat_text = subinstr("`estat_text'", "r2_a", "Adj.R2", .)
			loc estat_text = subinstr("`estat_text'", "rmse", "RMSE", .)
			loc estat_text = subinstr("`estat_text'", "chi2", "Chi2", .)




			// Stats ends


			if "`t'" != "" & "`se'" != "" {
				dis as error "Option t cannot be combined with option se"
				exit
			}
			if "`se'" != "" {
				loc STAT_VAL SE
				loc STATS_TEXT se
				loc se `se'
			}
			else if "`t'"  != "" {
				loc STAT_VAL T
				loc STATS_TEXT t
				loc t `t'
			}

			if "`end'" != "" {
				if "`t'" 	    != "" 	loc ReportText t-statistics are in `bName' 
				else if "`se'"  != "" 	loc ReportText Standard errors are in `bName'
				if "`stars'"    != ""	{
					if "`ReportText'" == "" loc ReportText *** p<0.01, ** p<0.05, * p<0.1
					else loc ReportText `ReportText'; *** p<0.01, ** p<0.05, * p<0.1

				}
			}
			if "`STATS_TEXT'" != "" {
				if !inlist("``STATS_TEXT''", "below" , "side") {
					di as error "Error in option `STATS_TEXT'(). Only `STATS_TEXT'(below) or `STATS_TEXT'(side) or allowed"
					exit

				}
				else {
					loc i = 1
					foreach v of local varnames {
						if `i' == 1 loc SE_text ",`STATS_TEXT'[`v']"	
						else loc SE_text "`SE_text', `STATS_TEXT'[`v']"
						loc `++i'
					}
				}
			}
			if "`title'" == "" loc title "Table: Regression results"
			if "`save'" == "" loc save "Myfile.doc"

			if "`stars'" == "" {

				* accumulate coefficients
				loc i = 2
				loc cof : di %9.`dec'f = t[1,1]
				loc SE  : di %9.`dec'f = t[2,1]
				loc T   : di %9.`dec'f = t[3,1]

				loc SE  ",`SE'"
				loc T   ",`T'"

				loc count : word count `varnames'
				forv  v = 2 / `count' {
					loc a : di %9.`dec'f = t[1,`i']
					loc cof `cof', `a'
					loc a : di %9.`dec'f = t[2,`i']
					loc SE `SE', `a'
					loc a : di %9.`dec'f = t[3,`i']
					loc T `T', `a'
					loc `++i'
				}
			}

			else { // Reporting Stars
				loc asterisk = cond(t[4,1] <= .01, "***", cond(t[4,1] <= .05, "***", cond(t[4,1]<=.1, "*", "")))		
				loc i = 2
				loc cof : di %9.`dec'f = t[1,1]
				loc SE  : di %9.`dec'f = t[2,1]
				loc T   : di %9.`dec'f = t[3,1]

				loc cof `cof'`asterisk'
				loc SE  ",`SE'"
				loc T   ",`T'"

				loc count : word count `varnames'
				forv  v = 2 / `count' {
					loc a : di %9.`dec'f = t[1,`i']
					loc asterisk = cond(t[4,`i'] <= .01, "***", cond(t[4,`i'] <= .05, "***", cond(t[4,`i']<=.1, "*", "")))		
					loc cof `cof', `a'`asterisk'
					loc a : di %9.`dec'f = t[2,`i']
					loc SE `SE', `a'
					loc a : di %9.`dec'f = t[3,`i']
					loc T `T', `a'
					loc `++i'
				}
			}	

			ltc `varnames'


			*----------------------
			* R2 handle
			*----------------------
			if "`nor2'" == "" {
				loc rsquare_value = cond("`e(r2_p)'"!="", 	"`e(r2_p)',", 		///
					cond("`e(r2)'"!="", 	"`e(r2)',", 							///
					cond("`e(r2_o)'"!="", 	"`e(r2_o)',","")))

				loc r2text ",R\super\ 2"

				cap loc r2 : di %9.`dec'f = `rsquare_value'
				loc r2 ",`r2'"
			}
			if "`FirsCellTitle'" == "" 	loc FirsCellTitle "Vars"


			*--------------------
			* Handle new reg
			*--------------------


			if "`append'" == "" & "`newtable'" == "" {
				loc AppendType 1
				loc line2 3
			}

			else if "`newtable'" != "" {
				loc AppendType 2
				loc line2 3
			}
			else if  "$wideReg" != "" & "`append'" != ""  {
				loc AppendType 3
				loc line2 3
			}
			else if  "$wideReg" == "" & "`append'" != ""  {
				loc AppendType 4
				loc line2 4
			}


			loc statval ``STAT_VAL''
			gettoken myvalue statval : statval, parse(",")
			while "`myvalue'" != "" {
				if "`myvalue'" == "," loc plucked `myvalue'
				else loc plucked [`myvalue']
				loc STAT_VALUES `STAT_VALUES' `plucked'
				gettoken myvalue statval : statval, parse(",")

			}
			if "`notse'" == "" {
				if "``STATS_TEXT''" == "below" {
					if "`t'" 	    != "" loc TSEReport \i\ t-value
					if "`se'"		!= "" loc TSEReport \i\ se
				}
			}
			else loc TSEReport \i

			if "`AppendType'"!= "3" mata : CustomCellSize("`depvar', `cof' `STAT_VALUES' `r2' `estat'")

			cap mata : CustomCellSize
			if "`t'" != "below" & "`se'" != "below" {
				if "`AppendType'" == "1" | "`AppendType'" == "2" {
					mata : sparse_table("`save'",`fs', "`FirsCellTitle', `ctext' `SE_text' `r2text'`estat_text'" ///
						, "`title'", "`AppendType'" , "`cs'", "`align'", "`btp'", "" , ///
						"`font'", "`fhr'", "`fhc'")
				}
				mata : sparse_table("`save'",`fs', "`depvar', `cof' `STAT_VALUES' `r2' `estat'", ///
					"`title'",  "`line2'", "`cs'", "`align'","`btp'", "`ReportText'" , ///
					"`font'", "`fhr'", "`fhc'")

			}

			else {
				if "`AppendType'" == "1" | "`AppendType'" == "2"  mata : sparse_table("`save'",`fs', "`FirsCellTitle', `ctext' `r2text' `estat_text'", "`title'", "`AppendType'",  "`cs'","`align'","`btp'","" , "`font'", "`fhr'", "`fhc'")

				mata : sparse_table("`save'",`fs', "`depvar', `cof' `r2' `estat'", "`title'", "`line2'", "`cs'","`align'","`btp'", "" , "`font'", "`fhr'", "`fhc'")

				mata : sparse_table("`save'",`fs',"`TSEReport' `STAT_VALUES',\i", "`title'",  "`line2'", "`cs'","`align'","`btp'", "`ReportText'" , "`font'", "`fhr'", "`fhc'")
			}

			if "`end'" == "" global wideReg wideReg
			else global wideReg

		}

		// end of one call wideReg


		*--------------------------------------------------------------------------
		* 						wideReg : bys regressions
		*--------------------------------------------------------------------------

		else {



			tempvar Groups
			qui ds `by' `_byvars' , has(type string)
			if "`r(varlist)'" == "" {
				tempvar strby 
				ds `by' `_byvars' , has(vallabel)
				if "`r(varlist)'" != "" {
				    decode `by' `_byvars', gen(`strby')
					qui encode `strby' `if' `in', gen(`Groups')
				}

				else { // Pure numeric without labels 
					qui asencode `by' `_byvars' , gen(`Groups')
				}
			}
			else qui encode `by' `_byvars' `if' `in', gen(`Groups')


			qui sum `Groups' `if' `in'
			if "`r(max)'" == "" loc maxGroups 0 
			else loc maxGroups = `r(max)'

			cap getifin `varlistifin'
			if "`if'" != "" loc byGroup &  `Groups'
			else loc byGroup if `Groups'



			forv g = 1 / `maxGroups' {
				if `g'>1 {
					loc append append
					global wideReg wideReg
				}

				cap noi `qui' `anything' `byGroup' == `g'  `poptions' 
				if _rc continue
				loc depvar : label `Groups' `g'
				loc regcommand : word 1 of `anything'
				if "`add'" != "" loc depvar "`add'"

				cap confirm matrix r(table)
				if _rc {
					dis as error "Your Stata command does not have a regression output"
					exit
				}
				mat t = r(table)
				loc varnames : colnames  t

				if "`bracket'" == "" {
					loc btp btp
					loc bName parenthesis
				}
				else loc bName square brackets

				*---------------------------------------
				*            E(STATS)
				*---------------------------------------
				if "`stats'" != "" {
					loc stats= subinstr("`stats'", ",", "", .)
					local AllowedStats "N df_m df_r F rmse mss rss r2_a ll ll_0 rank chi2 p sigma_u sigma_e sigma rho Tbar Tcon N_g g_min r2_o r2_b r2_w"
					if !`: list stats in local(AllowedStats)'{
						display as error "Error in the stats(`stats') option!"
						display as text "only the following statistics are allowed with option flat"
						display as result "`AllowedStats'"
					}
				}
				loc i = 1
				foreach s of local stats {
					if `i' == 1{
						loc estat_text ",`s'"
						if "`s'" != "N" loc a : di %9.`dec'f = e(`s')
						else loc a : di %9.0f = e(`s')
						loc estat ",`a'"
						loc `++i'
					}
					else {
						loc estat_text "`estat_text', `s'"
						loc a : di %9.`dec'f = e(`s')
						loc estat "`estat', `a'"
						loc `++i'

					}
				}
				loc estat_text = subinstr("`estat_text'", "r2_a", "Adj.R2", .)
				loc estat_text = subinstr("`estat_text'", "rmse", "RMSE", .)
				loc estat_text = subinstr("`estat_text'", "chi2", "Chi2", .)




				// Stats ends


				if "`t'" != "" & "`se'" != "" {
					dis as error "Option t cannot be combined with option se"
					exit
				}
				if "`se'" != "" {
					loc STAT_VAL SE
					loc STATS_TEXT se
					loc se `se'
				}
				else if "`t'"  != "" {
					loc STAT_VAL T
					loc STATS_TEXT t
					loc t `t'
				}

				if "`end'" != "" {
					if "`t'" 	    != "" 	loc ReportText t-statistics are in `bName' 
					else if "`se'"  != "" 	loc ReportText Standard errors are in `bName'
					if "`stars'"    != ""	{
						if "`ReportText'" == "" loc ReportText *** p<0.01, ** p<0.05, * p<0.1
						else loc ReportText `ReportText'; *** p<0.01, ** p<0.05, * p<0.1

					}
				}
				if "`STATS_TEXT'" != "" {
					if !inlist("``STATS_TEXT''", "below" , "side") {
						di as error "Error in option `STATS_TEXT'(). Only `STATS_TEXT'(below) or `STATS_TEXT'(side) or allowed"
						exit

					}
					else {
						loc i = 1
						foreach v of local varnames {
							if `i' == 1 loc SE_text ",`STATS_TEXT'[`v']"	
							else loc SE_text "`SE_text', `STATS_TEXT'[`v']"
							loc `++i'
						}
					}
				}
				if "`title'" == "" loc title "Table: Regression results"
				if "`save'" == "" loc save "Myfile.doc"

				if "`stars'" == "" {

					* accumulate coefficients
					loc i = 2
					loc cof : di %9.`dec'f = t[1,1]
					loc SE  : di %9.`dec'f = t[2,1]
					loc T   : di %9.`dec'f = t[3,1]

					loc SE  ",`SE'"
					loc T   ",`T'"

					loc count : word count `varnames'
					forv  v = 2 / `count' {
						loc a : di %9.`dec'f = t[1,`i']
						loc cof `cof', `a'
						loc a : di %9.`dec'f = t[2,`i']
						loc SE `SE', `a'
						loc a : di %9.`dec'f = t[3,`i']
						loc T `T', `a'
						loc `++i'
					}
				}

				else { // Reporting Stars
					loc asterisk = cond(t[4,1] <= .01, "***", cond(t[4,1] <= .05, "***", cond(t[4,1]<=.1, "*", "")))		
					loc i = 2
					loc cof : di %9.`dec'f = t[1,1]
					loc SE  : di %9.`dec'f = t[2,1]
					loc T   : di %9.`dec'f = t[3,1]

					loc cof `cof'`asterisk'
					loc SE  ",`SE'"
					loc T   ",`T'"

					loc count : word count `varnames'
					forv  v = 2 / `count' {
						loc a : di %9.`dec'f = t[1,`i']
						loc asterisk = cond(t[4,`i'] <= .01, "***", cond(t[4,`i'] <= .05, "***", cond(t[4,`i']<=.1, "*", "")))		
						loc cof `cof', `a'`asterisk'
						loc a : di %9.`dec'f = t[2,`i']
						loc SE `SE', `a'
						loc a : di %9.`dec'f = t[3,`i']
						loc T `T', `a'
						loc `++i'
					}
				}	

				ltc `varnames'


				*----------------------
				* R2 handle
				*----------------------
				if "`nor2'" == "" {
					loc rsquare_value = cond("`e(r2_p)'"!="", 	"`e(r2_p)',", 		///
						cond("`e(r2)'"!="", 	"`e(r2)',", 							///
						cond("`e(r2_o)'"!="", 	"`e(r2_o)',","")))

					loc r2text ",R\super\ 2"

					cap loc r2 : di %9.`dec'f = `rsquare_value'
					loc r2 ",`r2'"
				}
				if "`FirsCellTitle'" == "" 	loc FirsCellTitle "`by'`_byvars'"


				*--------------------
				* Handle new reg
				*--------------------


				if "`append'" == "" & "`newtable'" == "" {
					loc AppendType 1
					loc line2 3
				}

				else if "`newtable'" != "" {
					loc AppendType 2
					loc line2 3
				}

				else if  "$wideReg" != "" & "`append'" != ""  {
					loc AppendType 3
					loc line2 3
				}
				else if  "$wideReg" == "" & "`append'" != ""  {
					loc AppendType 4
					loc line2 4
				}


				loc statval ``STAT_VAL''
				gettoken myvalue statval : statval, parse(",")
				while "`myvalue'" != "" {
					if "`myvalue'" == "," loc plucked `myvalue'
					else loc plucked [`myvalue']
					loc STAT_VALUES `STAT_VALUES' `plucked'
					gettoken myvalue statval : statval, parse(",")

				}

				if "`notse'" == "" {
					if "``STATS_TEXT''" == "below" {
						if "`t'" 	    != "" loc TSEReport \i\ t-value
						if "`se'"		!= "" loc TSEReport \i\ se
					}
				}
				else loc TSEReport \i


				if "`AppendType'"!= "3" mata : CustomCellSize("`depvar', `cof' `STAT_VALUES' `r2' `estat'")

				if "`t'" != "below" & "`se'" != "below" {

					if "`AppendType'" == "1" | "`AppendType'" == "2"  	mata : sparse_table("`save'",`fs', "`FirsCellTitle', `ctext' `SE_text' `r2text'`estat_text'" , "`title'", "`AppendType'" , "`cs'", "`align'", "`btp'", "" , "`font'", "`fhr'", "`fhc'")

					mata : sparse_table("`save'",`fs', "`depvar', `cof' `STAT_VALUES' `r2' `estat'", "`title'",  "`line2'", "`cs'", "`align'","`btp'", "`ReportText'" , "`font'", "`fhr'", "`fhc'")
				}


				else {

					if "`AppendType'" == "1" | "`AppendType'" == "2"  mata : sparse_table("`save'",`fs', "`FirsCellTitle', `ctext' `r2text' `estat_text'", "`title'", "`AppendType'",  "`cs'","`align'","`btp'","" , "`font'", "`fhr'", "`fhc'")

					mata : sparse_table("`save'",`fs', "`depvar', `cof' `r2' `estat'", "`title'", "`line2'", "`cs'","`align'","`btp'", "" , "`font'", "`fhr'", "`fhc'")

					mata : sparse_table("`save'",`fs',"`TSEReport' `STAT_VALUES',\i", "`title'",  "`line2'", "`cs'","`align'","`btp'", "`ReportText'" , "`font'", "`fhr'", "`fhc'")

				}
				loc SE_text
				loc STAT_VALUES
				loc cof
				loc estat
				loc r2text
				loc estat
				loc r2
				loc title
				loc ReportText
				loc loc T
				loc SE

			}
		}
		if "`end'" == "" global wideReg wideReg
		else global wideReg


	} // end of bys-wideReg regressions

	else if "`command'"== "row"  {
		if "`noheader'" != "" global row row

		if "`bracket'" == "" loc btp btp


		if "`title'" == "" loc title "Table 1"

		if "`append'" == "" {
			loc AppendType 1 // replace
			loc newCellSize = 1
		}
		else {
			if "$row" == "" loc AppendType 2 // add title row
			else loc AppendType 3 // add row
			loc newCellSize = 0
		}
		if "`dec'"!= "" {

			gettoken myvalue row : row, parse(",")

			while "`myvalue'" != "" {
				cap confirm number `myvalue'
				if _rc loc plucked `myvalue'
				else {
					capture confirm integer number `myvalue'
					if _rc loc plucked : di %9.`dec'f = `myvalue'
					else loc plucked `myvalue'
				}
				loc CELLS `CELLS' `plucked'
				gettoken myvalue row : row, parse(",")

			}


		}
		if `newCellSize' == 1 mata : CustomCellSize("`CELLS'")
		cap confirm matrix cs
		if _rc mata : CustomCellSize("`CELLS'")
		mata : sparse_table("`save'",`fs', "`CELLS'" , "`title'", "`AppendType'", ///
			"`cs'", "`align'", "`btp'", "" , "`font'", "`fhr'", "`fhc'")
		global row row
		global accum
	}
	//--------------------------------------------------------------------------
	*								TABULATION
	*===========================================================================

	if inlist("`command'" , "tab1", "tab2", "tab") {
	    if strmatch("`poptions'", "*chi2*") loc chi2 chi2

		if "`_byvars'" != "" {
			loc byexists = 1
			tempvar Groups
			qui ds `_byvars' , has(type string)

			if "`r(varlist)'" == "" {
				tempvar strby 
				qui ds `_byvars'  , has(vallabel)
				if "`r(varlist)'" != "" {
				    decode `by' `_byvars', gen(`strby')
					qui encode `strby' `if' `in', gen(`Groups')
				}

				else { // Pure numeric without labels 
					qui asencode `by' `_byvars' , gen(`Groups')
				}
			}
			else qui encode `_byvars'  `if' `in', gen(`Groups')
			qui sum `Groups' `if' `in'
			if "`r(max)'" == "" loc maxGroups 0 
			else loc maxGroups = `r(max)'

			qui aslev `_byvars', vl
			loc allLabels "`r(vLabel)'"



			//loc groupName : label `Groups' `j'
			//di "`: word `j' of `allLabels''"
			//}
		}
		else {
			loc maxGroups = 1
			loc byexists = 0


		}
		loc orignal_if `if'
		loc orignal_title `title'

		forv j = 1 / `maxGroups' {




			if `byexists' {
				loc label : word `j' of `allLabels'

				loc theByTitle when `_byvars' is `label'
				if `j' > 1 loc append append
				if "`orignal_if'" ~= "" loc if `if' & `j' == `Groups'
				else loc if if `Groups' ==  `j' 
			}
			if "`command'" == "tab1" {

				foreach r of varlist `varlist' {
					qui ds `r' , has(type string)
					if "`r(varlist)'" != "" {
						tempvar  `r'_
						qui encode `r' , gen(``r'_')
						loc accum_vars `accum_vars' ``r'_'
					}
					else loc accum_vars `accum_vars' `r'
				}
				loc original_vars `varlist'
				loc varlist `accum_vars'


				loc run = 1
				foreach var of varlist `varlist' {
					asdoc_tabulate `var' `if' `poptions' `row' ///
						matcell(frequencies) matrow(header_row) 

					loc original_name : word `run' of `original_vars'
					if "`title'" == "" loc temptitle "Tabulation of `original_name' `theByTitle'"
					else temptitle `title'



					if `run' == 1 loc append `append'
					else loc append append
					mata: asdoc_tab_onevar("`var'", "`save'", "`temptitle'", ///
						"`append'", `fs', "`dec'", "`cmd'",`abb', "`nofreq'", ///
						"`nolabel'", "`font'", "`fhc'", "`fhr'", "`nocf'") 
					loc `++run'
				}

			}
			* Tabulate2
			if "`command'" == "tab2" {

				if strmatch("`poptions'", "*first*") loc firstonly firstonly
				if strmatch("`poptions'", "*col*") loc subopt col
				if strmatch("`poptions'", "*nof*") loc nofreq nofreq
				if strmatch("`poptions'", "*nok*") loc nokey nokey

				foreach r of varlist `varlist' {
					qui ds `r' , has(type string)
					if "`r(varlist)'" != "" {
						qui encode `r' , gen(`r'_)
						loc tempvars_string `tempvars_string' `r'_
						loc accum_vars `accum_vars' `r'_

					}
					else loc accum_vars `accum_vars' `r'
				}
				loc original_vars `varlist'
				loc varlist `accum_vars'

				if "`row'" != "" loc subopt `subopt' row

				loc run = 1

				tokenize `varlist'
				local stop : word count `varlist'
				local i 1
				while `i' <= `stop' {
					local L "``i''"
					mac shift
					local varlist "`*'"
					local stop : word count `varlist'
					local j 1
					while `j' <= `stop' {		

						noisily di `"-> tabulation of `L' by ``j'' `if' `in'"'
						asdoc_tabulate `L' ``j''  `if' `poptions' `row' ///
							matcell(frequencies) matrow(header_row) 

						if "`title'" == "" loc titlej "Tabulation of `L' by ``j''"

						if "`col'"!="" | "`column'"!="" loc subopt column
						if `run' == 1 loc append `append'
						else loc append append

						if "`chi2'" != "" {
							loc chi2 : dis %9.2f = `r(chi2)'
							loc chip2 : dis %9.4f = `r(p)'
							loc chistr "`chi2' | `chip2'"
						}

						mata: asdoc_tab_twovars("`L' ``j''", "`save'", "`titlej'", ///
							"`append'", `fs', "`dec'", "`cmd'",`abb', "`nofreq'", ///
							"`subopt'", "`nolabel'", "`nokey'", "`font'", "`fhr'", ///
							"`fhc'", "`notes'", "`chistr'" ) 

						loc `++run'
						local j = `j' + 1
						if _rc!=0 & _rc!=1001 { exit _rc }

					}
					if "`firstonly'" ~= "" loc i 1000
					//loc i = `i' + 1
					tokenize `varlist'
				}
				qui cap drop `tempvars_string'
			}



			else if "`command'" == "tab" {
				if strmatch("`poptions'", "*col*") loc subopt col
				if strmatch("`poptions'", "*cell*") loc subopt `subopt' cell
				if strmatch("`poptions'", "*nof*") loc nofreq nofreq
				if strmatch("`poptions'", "*nolab*") loc nolabel nolabel

				foreach r of varlist `varlist' {
					qui ds `r' , has(type string)
					if "`r(varlist)'" != "" {
						tempvar  `r'_
						qui encode `r', gen(``r'_')
						loc accum_vars `accum_vars' ``r'_'
					}
					else loc accum_vars `accum_vars' `r'
				}
				loc original_vars `varlist'
				loc varlist `accum_vars'


				if "`row'" != "" loc subopt `subopt' row

				asdoc_tabulate `varlist' `weights' `if' `poptions'  ///
					matcell(frequencies) matrow(header_row) `matcol'  `subopt'
				if "`chi2'" != "" {
					loc chi2 : dis %9.2f = `r(chi2)'
					loc chip2 : dis %9.4f = `r(p)'
					loc chistr "`chi2' | `chip2'"
				}


				if "`abb'" == "" loc abb = 150

				if "`orignal_title'" == "" loc title `"Tabulation of `original_vars' `theByTitle'"'
				else loc title `orignal_title'
				loc title : dis "`title'

				* Tabulation of one variable
				if `number_of_variables' == 1 {

					if "`nofreq'" == "" mata: asdoc_tab_onevar("`varlist'", "`save'", "`title'", ///
						"`append'", `fs', "`dec'", "`cmd'",`abb', "`nofreq'", "`nolabel'", ///
						"`font'", "`fhc'", "`fhr'", "`nocf'") 

				}

				* Tabulation of two variables
				else {
					if "`col'"!="" | "`column'"!="" loc subopt column
					mata: asdoc_tab_twovars("`varlist'", "`save'", "`title'", ///
						"`append'", `fs', "`dec'", "`cmd'",`abb',"`nofreq'", ///
						"`subopt'", "`nolabel'","`nokey'", "`font'", "`fhr'", ///
						"`fhc'", "`notes'", "`chistr'") 

				}
			}
			loc accum_vars
			loc if `orignal_if'
			loc title `orignal_title'
		}
	}
	// End of Tabulation






	else if "`command'" == "list" {
		if "`cmd'" != "" loc cmd `anything' `poptions'
		loc list list
		loc flesh : list anything - list
		asdoclist `flesh' , `append' dec(`dec') fs(`fs') save("`save'") ///
			title("`title'") align(default) font(`font') fhc(`fhc') ///
			fhr(`fhr') `label'

		`qui' `anything' `poptions'
	}
	else if "`command'" == "aslist" {
		qui aslist `varlist' `if' `in' , `append' dec(`dec') fs(`fs') ///
			save("`save'") title("`title'") font(`font')
	}
	else if "`command'" == "des" {
		if "`title'" == "" loc title Description of variables
		loc poptions = subinstr("`poptions'", ",","", .)
		qui asdocdes `varlist', `append' dec(`dec') fs(`fs') save("`save'") ///
			title("`title'") `poptions' font(`font')
	}
	if "`command'" == "mean" { 
		if "`cmd'" != "" loc cmd `anything' `poptions'
		mata: ghkstart()
		`qui' `anything'  `poptions' 
		mata: ghkend()
		if "`title'" == "" loc title "`what' of `varlist'"
		if 	strmatch("`poptions'", "*over(*") loc over over
		if "`over'" == "over" loc space " "
		else loc space ""
		mata: asdocmean("`save'", "`title'","`over'", "`space'", "`append'", ///
			`fs', "`cmd'" , "`font'", "`fhr'", "`fhc'")

	}

	else if "`command'" == "cor" {
		if strmatch("`anything'", "*spearman*") {
			loc cor  spearman
			if "`title'" == "" loc title "Spearman's rank correlation coefficients "
		}
		else {
			loc cor cor
			if "`title'" == "" loc title "Matrix of correlations"
		}


		if `abb'==10 loc abb 22
		if "`cmd'" != "" loc cmd `anything' `poptions'


		`qui' `cor' `varlist' `if' `in'

		if "`cor'" == "cor" mat C = r(C)
		else {
			mat C = r(Rho)
			loc roh : dis %9.`dec'f = `r(rho)'
			loc roh "Spearman rho =`roh'"
			if "`notes'" == "" loc notes `roh'
			else loc notes `roh' \par `notes'
		}

		mata: asdoccor("`save'", "`varlist'", "`title'", `fs', `abb', "`append'", ///
			"`dec'", "`cmd'","`nonum'", "`label'" , "`font'", "`fhc'", /// 
			"`fhr'", "`notes'", "`store'")
	}

	if "`command'" == "pwcorr" {
		if "`cmd'" != "" loc cmd `anything' `poptions'
		if "`title'" == "" loc title "Pairwise correlations"
		`qui' asdocor `varlist' `if' `in' `poptions' save(`save') title(`title') ///
			fs(`fs') `append' `replace' `label' dec(`dec') `nonumber' `non' `nonum' ///
			`cmd' font(`font') fhr(`fhr') fhc(`fhc') `store' `tzok' notes(`notes') abb(`abb')

	}

	if "`command'" == "tetrachoric" {
		if "`cmd'" != "" loc cmd `anything' `poptions'
		mat C = r(rho)
		`qui' `anything'  `poptions' matrix		
		if "`title'" == "" loc title "Matrix with tetrachoric correlations"

		loc rownames : rowfullnames  r(Rho)
		mata: asdoccor("`save'", "`rownames'", "`title'", `fs', `abb', ///
			"`append'", "`dec'", "`cmd'", "`nonumber'", "`label'", ///
			"`font'", "`fhr'", "`fhc'", "`notes'", "`store'")
	}
	if "`command'" == "proportion" {
		if "`cmd'" != "" loc cmd `anything' `poptions'

		if "`what'" == "ameans" {
			local noh "" 
			loc InterSectSpace no
			loc space "yes"
			if "`title'" == "" loc title " Arithmetic, geometric, and harmonic means"

		} 
		else local noh noh
		mata: ghkstart()
		`qui' `anything' `poptions' `noh'
		if "`title'" == "" loc title "`what' estimation"

		if 	strmatch("`poptions'", "*over(*") {
			loc space yes
			loc InterSectSpace yes
		}
		else  if "`what'" != "ameans" {
			loc  InterSectSpace yes
			loc space no
		}
		mata: asproportion("`save'", "`title'","`InterSectSpace'", "`space'", ///
			"`append'", `fs', "`cmd'",`dec' , "`font'", "`fhr'", "`fhc'")

	}

	else if "`command'" == "pcorr" {
		if "`cmd'" != "" loc cmd `anything' `poptions'
		mata: ghkstart()
		`qui' `anything' 
		mata: ghkend()
		mata: asdocpcorr("`save'", "`title'", "`append'", `fs', "`cmd'", ///
			"`dec'", "`font'", "`fhr'", "`fhc'")
	}


	else if "`command'" == "icc" {
		if "`cmd'" != "" loc cmd `anything' `poptions'

		mata: ghkstart()

		`qui' `anything'  `poptions'
		loc F = `r(icc_avg_F)'
		loc P = `r(icc_i_p)'
		mata: ghkend()

		mata: asdocicc("`save'", `F', `P', "`title'", "`append'",`fs', "`cmd'", "`dec'", "`font'")
	}






	*------------------------------------------------------------------------------
	* 									TABLE
	*------------------------------------------------------------------------------

	else if "`command'" == "table" {
		if "`cmd'" != "" loc cmd `anything' `poptions'

		* Handle BY
		if "`by'" != "" | "`_byvars'" != "" {
			loc by `by' `_byvars'
			loc byexists 1

			tempvar Groups
			qui ds `by' , has(type string)
			if "`r(varlist)'" == "" {
				tempvar strby 
				ds `by'  , has(vallabel)
				if "`r(varlist)'" != "" decode `by' , gen(`strby')
				else qui tostring `by' , gen(`strby')
				qui encode `strby' `if' `in', gen(`Groups')
			}
			else qui encode `by'  `if' `in', gen(`Groups')
			qui sum `Groups' `if' `in'
			if "`r(max)'" == "" loc maxGroups 0 
			else loc maxGroups = `r(max)'


			//cap getifin `varlistifin'
			if "`if'" != "" loc byGroup &  `Groups'
			else loc byGroup if `Groups'


		}
		else loc byexists 0


		if strmatch("`poptions'", "*sc*") loc super_colum  super_colum
		if strmatch("`poptions'", "*col*") loc col  col


		if "`title'" == "" loc title Tabulation of `varlist'

		if "`dec'" != "" loc dec dec(`dec')


		foreach v of varlist `varlist' {
			cap confirm string variable `v'
			if _rc {
				local varformat : format `v'
				loc i = 1
				if regexm(`"`varformat'"', "^%-?(t|d)") {
					loc `++i'
					gen temp_`v' = string(`v', "`varformat'")
					encode temp_`v', gen(VARsForTableCommand_`i')
					qui getlable `v'
					label var VARsForTableCommand_`i' "`varLabel'"
					qui drop temp_`v'
					loc allvars `allvars' VARsForTableCommand_`i'
				}
				else loc allvars `allvars' `v'
			}

			else {
				qui encode `v', gen(VARsForTableCommand_`i')
				loc allvars `allvars' VARsForTableCommand_`i'

			}

			loc varlist `allvars'
		}

		if !`byexists' {
			`qui' tablex `varlist' `if' `in' `weights' `poptions' `row' `dec'
			mata: astable("`save'", "`title'", "`append'","`varlist'", "`row'", ///
				"`col'", "`super_colum'", `fs', "`cmd'", "`font'", "`fhr'", "`fhc'", ///
				"`if'", "`in'")
		}
		else {
			loc run = 1
			loc labi : var label `by'
			if "`labi'" == "" loc labi `by'
			local lbe : value label `Groups'

			forv g = 1 / `maxGroups' {
				preserve
				keep `if' `in' `byGroup' == `g'

				if `run' == 1 loc append `append'

				else loc append append

				cap local vlabel : label `lbe' `g'
				`qui' tablex `varlist'  `poptions' `row' `dec' 

				mata: astable("`save'", "`by'  =  `vlabel'", "`append'", "`varlist'", "`row'", ///
					"`col'", "`super_colum'", `fs', "`cmd'", "`font'", "`fhr'", "`fhc'", ///
					"`if'", "`in'")
				set trace off

				loc `++run'
				restore
			}


		}
		cap drop VARsForTableCommand_*
	}

	else if "`command'" == "hausman" {
		if "`cmd'" != "" loc cmd `anything' `poptions'

		`qui' `anything' `poptions'
		mat C = J(2,1,.)
		qui asdocdec `r(chi2)', dec(`dec')

		mat C[1,1] = `value'
		qui asdocdec `r(p)', dec(`dec')

		mat C[2,1] = `value'
		if "`title'" == "" loc title "Hausman (1978) specification test"	
		if "`tzok'" == "" qui asdocmatdec C, dec(`dec')

		mata: asdoctable("`save'", "Coef.", "Chi-square test value, P-value",  "C", ///
			"`title'", `fs', 30, "`append'", "`noheader'", "`rowappend'", "," ,2000, "", ///
			"`dec'", "`cmd'", "`label'", "`tzok'", "`font'", "`fhc'", "`fhr'", "`notes'", "`store'")
	}
	else if "`command'" == "vif" {
		if "`cmd'" != "" loc cmd `anything' `poptions'

		`qui' vif
		loc name `r(name_1)'
		mat a = J(1,2,.)
		local i = 1
		while "`name'" != ""{
			if `i' == 1{
				mat a[1,1] = `r(vif_1)'
				mat a[1,2] = 1/`r(vif_1)'
				mat C = a
				loc `++i'
				loc rownames `rownames' `name' 
				loc name `r(name_`i')'
			}
			else {
				mat a[1,1] = `r(vif_`i')'
				mat a[1,2] = 1/`r(vif_`i')'
				mat C = C \ a

				loc rownames `rownames' `name' 
				loc `++i'
				loc name `r(name_`i')'
			}
			if "`title'" == "" loc title "Variance inflation factor"	
		}
		mat a = C[1..., 1]
		mata: meanvif("a")
		mat a = J(1,2,.)
		mat a[1,1] = `meanvif'
		mat C = C \ a
		loc rownames "`rownames'  Mean_VIF"
		if "`tzok'" == "" qui asdocmatdec C, dec(`dec')

		mata: asdoctable("`save'", "VIF 1/VIF", "`rownames'", "C", ///
			"`title'", `fs', `abb', "`append'", "`noheader'", "`rowappend'", ///
			" " ,`frs',"", "`dec'", "`cmd'", "`label'", "`tzok'", "`font'", "`fhc'", "`fhr'", "`notes'", "`store'")
	}





	*-----------------------------------------------------------------------------
	*  										nestedReg
	*=============================================================================

	else if "`command'"=="nestedReg" {
	    loc multireg 0
		if "`eform'" != "" & "`or'" != "" dis as error "Please note that option eform and or do the same thing, i.e report odd ratios"
		if "`notse'" != "" & "`rep'" == "t" dis as error "Option notse ignored as you have used option rep(t)"
		if "`by'" == "" & "`_byvars'" == "" {

			if "`replay'" != "replay" {
				gettoken cmd varlist : regtableanything

				//loc abb = max(18,.)

				if inlist("`cmd'", "sqreg", "sureg", "reg3", "mvreg") loc multireg 1

				gettoken depvar indepvars : varlist
				if inlist("`cmd'" , "ivreg", "ivregr", "ivregre", "ivregres", "ivregress", "mi") {
					gettoken depvar indepvars : indepvars
				}
				if !`multireg' qui _fv_check_depvar `depvar'
			}
			else {
				estimates replay
				loc depvar `e(depvar)'
				loc indepvars : colnames  r(table)
				loc conS _cons
				local indepvars : list indepvars - conS
			}

			if "`cnames'"=="" loc coltitle `depvar'
			else {
				loc cnames = subinstr("`cnames'", " ", "_", .)
				loc coltitle `cnames'
			}


			if "`reset'" != "" {
				global UseVarnames "`ExpIndepVars'"
				global AlldepVars ""
				if "`rep'" == "" global REP se
				else global REP `rep'
				global attach1
				global attach2
				global attach3
				global textrun = 1
				global modelrun = 1
			}
			if "$modelrun" == "" global modelrun = 1
			if "$modelrun" == "1" {
				mata: delete_closing_lines("`save'")
				mata :  st_global("Startpos", strofreal(rtfposition("`save'"))) 
			}
			if "`append'" != "" {
				local 	PreviousVars "$UseVarnames"
				global UseVarnames : list PreviousVars | ExpIndepVars
				if "`reset'"	== "" 	loc POS $Startpos
				if "`POS'" 		== "" loc POS 0
				if "`rep'"		!= "" display as text "option `rep' ignored, it can be used only with option replace or reset"

			}
			global AlldepVars $AlldepVars `coltitle'
			if "`drop'"!="" {
				loc drop "drop(`drop')"
			}
			if "`keep'"!="" {
				loc keep "keep(`keep')"
			}

			if strmatch("`poptions'", "*robust*") loc info "Robust standard"

			if "`eform'" == "eform" loc or or
			if "`or'" == "or" loc eform eform
			if "`cmd'" == "xtpoisson" {
				if strmatch("`poptions'", "* irr*") {
					loc eform eform
				}
			}

			if "`replay'" != "replay" `qui' `anything' `poptions' `or' `force'
			mat A = r(table)
			loc neq `e(n_q)'
			loc eq_names `e(eqnames)'
			if "`e(r2)'" != "" loc r2 r2
			else loc r2 r2_p

			if !`multireg' qui estimates store M$modelrun 

			if "$textrun" =="" global textrun = 1

			if "`add'"!="" {
				global  textrun = $textrun + 1
				loc ntext : word count `add'
				if `ntext' > 3 {
					loc nt = 0
					while "`add'"!="" {
						gettoken base rest : add, parse(",")
						gettoken throw rest : rest, parse(",")
						gettoken hand add : rest, parse(",")
						gettoken throw add : add, parse(",")
						loc `++nt'
						if "$attach1"=="" global attach1 "`base'"
						mata: asdocaddtext2("`base'", "`hand'", $modelrun)
					}
				}	
				else {
					gettoken base rest : add, parse(",")
					gettoken throw rest : rest, parse(",")
					gettoken hand add : rest, parse(",")
					if "$attach1"=="" global attach1 "`base'"
					if "$attach1"=="" global attach1 "`base'"
					mata: asdocaddtext("`base'", "`hand'", $modelrun)


				}
			}
			else {
				if "$attach1" != "" global attach1 "$attach1,_ "
				if "$attach2" != "" global attach2 "$attach2,_ "
				if "$attach3" != "" global attach3 "$attach3,_ "
			}

			if !`multireg' {
				forv i = 1 / $modelrun {
					loc AllModels "`AllModels' M`i'"
				}

				cap drop _est_M$modelrun
				global  modelrun = $modelrun + 1
			}
			if "`stat'" != "" loc stat = subinstr("`stat'", ",", " ", .)
			if strmatch("`poptions'", "* nofvlabel*") global nofvlabel nofvlabel
			loc removeN N
			loc removeDFR df_r

			if `: list removeDFR in local(stat)' global dfr dfr
			if "`e(r2)'" != "" global r2 `r2'

			local  stat : list stat - removeN
			local  stat : list stat - removeDFR

			loc statlable "N `r2' `stat'"

			loc nstlab : word count `statlable'	


			if !`multireg' {
				qui estimates table `AllModels', stats(df_r N `r2' `stat') `drop' `keep'  equations(1) `eform' 

				loc rownames : rowfullnames  r(coef)
				if strmatch("`rownames'", "*#*") loc frs = 2000

				mat coefmat = r(coef)
				if "`cmd'" == "iqreg" {
				    if "`title'" == "" loc title "Table : Interquantile regression"
					loc info "Boostrap standard"
				}
				if "`cmd'" == "qreg" & "`title'" == "" loc title "Table : Quantile regression"
				if "`title" == "" loc title  "Table : Regression results"
				mata: func_nested_reg("`save'", "$AlldepVars", "`rownames'", "coefmat", ///
					"r(stats)", "`title'", `fs', `abb', "`append'", "`noheader'", ///
					" " ,`frs', `POS',"$REP", "`dec'", "`statlable'", ///
					`nstlab', $modelrun, "`header'", "`label'" , "`eform'","`notse'", "`font'", ///
					"`fhr'", "`fhc'", "`tzok'", "`notes'", "`force'", "`transpose'", "`info'")
			}

			else {

				loc Eqvars: colfullnames A
				mata: ParseEqVars("`Eqvars'")

			    if "`neq'" != "" loc N `neq'
				qui estimate store m1

				qui estimate table m1, stats(df_r N `r2' `stat') `drop' `keep'  equations(1) `eform' 
				mat A = r(coef)

				loc allvarnames : rowvarlist  r(coef)

				if "`eq_names'" == "" {
					loc eq_names "`eq1' `eq2' `eq3' `eq4' `eq5' `eq6' `eq7' `eq8' `eq9' `eq10'"
				}


				if "$modelrun" == "" global modelrun = 1

				forv e = 1 / `N' {
					if `e' > 1 loc append append
					if "$modelrun" == "1" {
						mata: delete_closing_lines("`save'")
						mata :  st_global("Startpos", strofreal(rtfposition("`save'"))) 
					}
				    global  modelrun = $modelrun + 1
					loc jump : word count `eq`e'vars'
					loc f = `e' - 1
					loc from_row = (`f' * `jump') + 1
					loc to_row   = `e' * `jump'
					mat ThisMat = A[`from_row' .. `to_row' , 1..2]
					matrix coleq ThisMat = :
					matrix roweq ThisMat = :

					mat tempstats = r(stats)
					if inlist("`cmd'", "sqreg" ) {
					    mat tempstats[3,1] = `e(r2_p_q`e')'
						if `title'"=="" loc title  "Table : Simultaneous Quantile Regression"
						loc info "Boostrap standard"


					}
					else if inlist("`cmd'", "sureg") {
					    if "`title'"=="" loc title  "Table : Seemingly Unrelated Regression"
						mat tempstats[3,1] = `e(r2_`e')'
					}  

					else if inlist("`cmd'", "reg3") {
					    if "`title'"=="" loc title  "Table : Three-Stage Least-Squares Regression"
						mat tempstats[3,1] = `e(r2_`e')'
					}  



					if `e' == 1 {
					    mat coefmat = ThisMat
						mat rstats = tempstats
					}
					else {

						matrix coljoin coefmat = coefmat ThisMat 
						mat rstats = rstats , tempstats
					}
				}
				loc rownames: rowfullnames coefmat


				loc title  "Table : Regression results"

				mata: func_nested_reg("`save'", "`eq_names'", "`rownames'", "coefmat", ///
					"rstats", "`title'", `fs', `abb', "`append'", "`noheader'", ///
					" " ,`frs', `POS',"$REP", "`dec'", "`statlable'", ///
					`nstlab', $modelrun, "`header'", "`label'" , "`eform'","`notse'", "`font'", ///
					"`fhr'", "`fhc'", "`tzok'", "`notes'", "`force'", "`transpose'", "`info'")



			}
			global reset
			global nest
		} // end of one call nested




		**************************************************************************
		*						bysort nested reg
		**************************************************************************
		else{


			tempvar Groups
			qui ds `by' `_byvars' , has(type string)
			if "`r(varlist)'" == "" {
				tempvar strby 
				ds `by' `_byvars' , has(vallabel)
				if "`r(varlist)'" != "" {
				    decode `by' `_byvars', gen(`strby')
					qui encode `strby' `if' `in', gen(`Groups')
				}

				else { // Pure numeric without labels 
					qui asencode `by' `_byvars' , gen(`Groups')
				}
			}
			else qui encode `by' `_byvars' `if' `in', gen(`Groups')


			qui sum `Groups' `if' `in'
			if "`r(max)'" == "" loc maxGroups 0 
			else loc maxGroups = `r(max)'



			cap getifin `varlistifin'
			if "`if'" != "" loc byGroup &  `Groups'
			else loc byGroup if `Groups'

			forv j = 1 / `maxGroups' {

				qui cap noi `anything' `byGroup' == `j'  `poptions' `force'
				if _rc continue
				if `j' > 1 loc append append
				gettoken cmd varlist : regtableanything
				gettoken depvar indepvars : varlist
				qui _fv_check_depvar `depvar'

				loc cnames : label `Groups' `j'
				loc coltitle = subinstr("`cnames'", " ", "_", .)


				if "$reset" != "" {
					global UseVarnames "`ExpIndepVars'"
					global AlldepVars ""
					if "`rep'" == "" global REP se
					else global REP `rep'
					global attach1
					global attach2
					global attach3
					global  textrun = 1
					global modelrun = 1
				}

				if "$modelrun" == "" global modelrun = 1

				if "$modelrun" == "1" {
					mata: delete_closing_lines("`save'")
					mata :  st_global("Startpos", strofreal(rtfposition("`save'"))) 
				}


				if "`append'" != "" {
					local 	PreviousVars "$UseVarnames"	
					global UseVarnames : list PreviousVars | ExpIndepVars
					if "$reset" == "" loc POS $Startpos
					if   "`POS'" == "" loc POS 0

				}
				global AlldepVars $AlldepVars `coltitle'
				if "`drop'" != "" {
					loc drop "drop(`drop')"
				}
				if "`keep'" != "" {
					loc keep "keep(`keep')"
				}
				if "`eform'" == "eform" loc or or
				if "`or'" == "or" loc eform eform


				cap noi `qui' `anything' `byGroup' == `j'  `poptions' `or'

				qui estimates store M$modelrun

				if "`title'" == "" loc title  "Table : Regression results"
				if "$textrun" == "" global textrun = 1

				if "`add'" != "" {
					global  textrun = $textrun + 1
					loc ntext : word count `add'
					if `ntext' > 3 {
						loc nt = 0
						while "`add'" != "" {
							gettoken base rest : add, parse(",")
							gettoken throw rest : rest, parse(",")
							gettoken hand add : rest, parse(",")
							gettoken throw add : add, parse(",")
							loc `++nt'
							if "$attach1" == "" global attach1 "`base'"
							mata: asdocaddtext2("`base'", "`hand'", $modelrun)
						}
					}	
					else {
						gettoken base rest : add, parse(",")
						gettoken throw rest : rest, parse(",")
						gettoken hand add : rest, parse(",")
						if "$attach1" == "" global attach1 "`base'"
						if "$attach1" == "" global attach1 "`base'"
						mata: asdocaddtext("`base'", "`hand'", $modelrun)
					}
				}
				else {
					if "$attach1" != "" global attach1 "$attach1,_ "
					if "$attach2" != "" global attach2 "$attach2,_ "
					if "$attach3" != "" global attach3 "$attach3,_ "
				}
				forv i = 1/$modelrun {
					loc AllModels "`AllModels' M`i'"
				}
				cap drop _est_M$modelrun

				global  modelrun = $modelrun + 1

				if "`stat'" != "" loc statb = subinstr("`stat'", ",", " ", .)
				qui estimates table `AllModels', stats(df_r N r2 `statb') `drop' `keep'  equations(1) 
				loc rownames : rowfullnames  r(coef)
				if strmatch("`rownames'", "*#*") loc frs = 2000

				if "`stat'" != "" loc stat ",`stat'"
				loc statlable "Obs., R-squared `stat'"
				ctq `statlable'
				loc nstlab : word count `ctext'	
				mat coefmat = r(coef)
				global reset
				global nest
			}
			mata: func_nested_reg("`save'", "$AlldepVars", "`rownames'", "coefmat", 		///
				"r(stats)", "`title'", `fs', `abb', "`append'", "`noheader'", 			///
				" " ,`frs', `POS',"$REP", "`dec'", "`statlable'", 						///
				`nstlab', $modelrun, "`header'", "`label'", "`eform'","`notse'", "`font'", ///
				"`fhr'", "`fhc'", "`tzok'", "`notes'", "`force'", "`transpose'", "`info'")

		}

	} // end of nested



	else if "`command'" == "ttest" {
		if "`cmd'" != "" loc cmd `anything' `poptions'

		if "`cnames'" != "" loc cnames cnames(`cnames')

		if "`stats'" != "" {
			local AllowedStats "mean se df obs t p sd dif"
			if !`: list stats in local(AllowedStats)'{
				display as error "Error in the stats(`stats') option!"
				display as text "only the following statistics are allowed with t-tests"
				display as result "`AllowedStats'"
			}
			loc statsOptions "stat(`stats')"
		}
		else loc statsOptions ""
		//if "`by'" != "" loc by "by(`by')"
		if "`exp'" != "" loc varlist `varlist'=`exp'
		loc frs = 1400
		if "`title'" != "" loc title "title(`title')"
		if "`rowappend'" != "" {
			loc noheader "header not needed"
			local TableTitle ""
		}
		if "`_byvars'" == "" & "`by'" == "" {


			asttom `varlist' `if' `in' `poptions' sep(,) `title' `statsOptions' `cnames'

			mat T = r(T)
			//if "`tzok'" == "" qui asdocmatdec T, dec(`dec')
			mata: asdoctable("`save'", "`r(colnames)'", "`r(rownames)'", 	///
				"T", "`r(ttitle)'", `fs', `abb', "`append'", "`noheader'", 		///
				"`rowappend'", "," ,`frs',"", "`dec'", "`cmd'", "`label'", ///
				"`tzok'", "`font'", "`fhc'", "`fhr'", "`notes'", "`store'")
		}
		else {

			// First handle by(groups) and then _bysort
			if ("`by'" != "") {
				loc by by(`by')
				asttom `varlist' `if' `in' `poptions' sep(,) `by' `title' `statsOptions' `cnames'

				mat T = r(T)
				matlist T
				set trace on

				mata: asdoctable("`save'", "`r(colnames)'", "`r(rownames)'", 	///
					"T", "`r(ttitle)'", `fs', `abb', "`append'", "`noheader'", 		///
					"`rowappend'", "," ,`frs',"", "`dec'", "`cmd'", "`label'", ///
					"`tzok'", "`font'", "`fhc'", "`fhr'", "`notes'", "`store'")
				set trace off
			}
			else { // _bysort
				tempvar Groups
				qui ds `by' `_byvars' , has(type string)

				if "`r(varlist)'" == "" {
					tempvar strby 
					ds `by' `_byvars' , has(vallabel)
					if "`r(varlist)'" != "" decode `by' `_byvars', gen(`strby')
					else qui tostring `by' `_byvars', gen(`strby')
					qui encode `strby' `if' `in', gen(`Groups')
				}
				else qui encode `by' `_byvars' `if' `in', gen(`Groups')


				qui sum `Groups' `if' `in'
				if "`r(max)'" == "" loc maxGroups 0 
				else loc maxGroups = `r(max)'


				bys `Groups' : asttomby `varlist' `poptions' sep(,) `title' `statsOptions'


				mat T = r(T)
				local colnames : colfullnames  T
				local rownames : rowfullnames  T

				//if "`tzok'" == "" qui asdocmatdec T, dec(`dec')
				mata: asdoctable("`save'", "`colnames'", "`rownames'", 				///
					"T", "`r(ttitle)'", `fs', `abb', "`append'", "`noheader'", 		///
					"`rowappend'", "" ,`frs',"", "`dec'", "`cmd'", "`label'", 		///
					"`tzok'", "`font'", "`fhc'", "`fhr'", "`notes'", "`store'")
				set trace off

			}
		}

	}
	else if "`command'"=="tabstat" {
		if "`cmd'"!="" loc cmd `anything' `poptions'

		if "`stats'"!="" | "`stat'"!=""| "`statistics'"!="" {
			local AllowedStats "N sd mean semean median count sum range min max var cv skewness kurtosis iqr p1 p5 p10 p25 p50 p75 p90 p95 p99 tstat"
			if !`: list stats in local(AllowedStats)'{

				display as error "Error in the stat(`stats') option!"
				display as text "only the following statistics are allowed"
				display as result "`AllowedStats'"
				exit
			}
			local tstat "tstat"
			if `: list tstat in local(stats)'{
				local stats: list stats - tstat
				loc tstat "yes"

			}
			if "`tstat'"=="yes" & "`by'" == ""{

				qui tabstat `varlist' `if' `in', save stat(mean semean)

				mat ts = r(StatTotal)
				loc tsCols = colsof(ts)
				mat tstat = J(1, `tsCols', .)
				forv c = 1 / `tsCols' {
					mat tstat[1,`c'] = ts[1,`c'] / ts[2,`c']
					mat rowname tstat = "t-value"
				}
			}
		}


		if "`by'" != "" | "`_byvars'"!= "" {
			if "`by'"!="" & "`_byvars'"! = "" {
				dis as error "bysort: and by() cannot be combined!"
				exit
			}

			// New by coding----------------------------
			tempvar Groups
			qui ds `by' `_byvars' , has(type string)

			// numeric
			if "`r(varlist)'" == "" {
				tempvar strby 
				ds `by' `_byvars' , has(vallabel)

				if "`r(varlist)'" != "" {
				    decode `by' `_byvars', gen(`strby')
					qui encode `strby' `if' `in', gen(`Groups')
				}

				else { // Pure numeric without labels 
					qui asencode `by' `_byvars' , gen(`Groups')
				}	
			}

			else qui encode `by' `_byvars' `if' `in', gen(`Groups')
			qui sum `Groups' `if' `in'
			if "`r(max)'" == "" loc maxGroups 0 
			else loc maxGroups = `r(max)'


			* One Statistics
			//--------------------------------------
			local nstats : word count `stats'
			if `nstats' <2 {
				loc statlable = 											///
					cond("`stats'" == "mean", "Mean", 							///
					cond("`stats'" == "sd", "Standard deviation", 				///
					cond("`stats'" == "min", "Minimum", 						///
					cond("`stats'" == "max", "Maximum", 							///
					cond("`stats'" == "tstat", "t-statistic", 					///
					cond("`stats'" == "median", "Median", 						///
					cond("`stats'" == "cv", "Coefficient of variation", 			///
					cond("`stats'" == "var", "Variance", 						///
					cond("`stats'" == "iqr", "Inter-quartile range", "`stats'")))))))))


				loca nvars : word count `varlist'
				loc byName `by'  `_byvars'
				local NameLabel : variable label `by' `_byvars'
				if "`NameLabel'" == "" local NameLabel `by' `_byvars'

				if "`title'"=="" loc title "Descriptive statistics - `statlable' by(`by' `_byvars')"
				qui `anything', by(`by' `_byvars') stat(`stats') save

				local i = 1
				forv v = 1 / `maxGroups'  {
					if `i' == 1 {
						mat C = r(Stat1)
						local f1 : label `Groups' 1

						qui space_remover, text(`f1')
						loc accum `xspace'
						loc name = abbrev("`xspace'", 30)
						loc name = subinstr("`name'", ".","_",.)
						mat rownames C = `name'
						local `++i'

					}
					else {
						mat B = r(Stat`i')
						local f1 : label `Groups' `i'
						qui space_remover, text(`f1')
						loc accum `accum' `xspace'
						loc name = abbrev("`xspace'", 30)
						loc name = subinstr("`name'", ".","_",.)
						mat rownames B = `name'				
						mat C = C \ B
						local `++i'
					}

				}
				if "`tstat'" == "yes" {
					qui tstatby `varlist', by(`by' `_byvars')
					mat C = C,TSTAT
				}
				local NaturalCname : colfullnames  C
				local TableTitle `r(name`i')'

				//if "`tzok'" == "" qui asdocmatdec C, dec(`dec')
				if "`lastrow'" != "" {
					if "`lastrow'" == "mean" {
						mata: C = st_matrix("C")
						mata: Mean = mean(C)
						mata: st_matrix("Mean", Mean)
						mat rownames Mean = Average
						if "`tzok'" == "" qui asdocmatdec Mean, dec(`dec')
						mat C = C \ Mean
						loc accum `accum' Average

					}

					else if "`lastrow'" == "total" {
						mata: C = st_matrix("C")
						mata: Mean = sum(C)
						mata: st_matrix("Mean", Mean)
						mat rownames Mean = Total
						//if "`tzok'" == "" qui asdocmatdec Mean, dec(`dec')
						mat C = C \ Mean
						loc accum `accum' Total


					}


				}
				matlist C
				mata: asdoctable("`save'", "`NaturalCname'", "`accum'", ///
					"C", "`title'", `fs', 30, "`append'", "", "`rowappend'", " ", ///
					`frs',"", "`dec'", "`cmd'", "`label'", "`tzok'", "`font'", "`fhc'",  "`fhr'", "`notes'", "`store'")
			}
			else {
				loc byName `by' `_byvars'
				local NameLabel : variable label `by' `_byvars'
				if "`NameLabel'" == "" local NameLabel `by' `_byvars'

				qui aslev `by' `_byvars', vlab
				loc Ngroups "`r(groups)'"
				loc Vlables `r(vLabel)'

				if "`title'"=="" loc title "Summary statistics: `stats' by(`by' `_byvars')"

				local nvars : word count `varlist'
				loc i = 1
				if `nvars' == 1 {
					// problem

					if "`tstat'" == "yes" {
						qui tstatby `varlist', by(`by' `_byvars')
						`qui' tabstat `varlist' `if' `in', by(`by' `_byvars') stat(`stats') save

						local NaturalCname : rowfullnames  r(Stat1)
						local NaturalCname `NaturalCname' t-value

						local TableTitle "`NameLabel' : `r(name`i')'"


						foreach v of local Ngroups {
							local NaturalRname "`v'"

							mat C = r(Stat`i')' , TSTAT[`i',1]
							if `i' == 1 {
								loc rowappend "`i'"
								loc append `append'
								//if "`tzok'" == "" qui asdocmatdec C, dec(`dec')


								if "`lastrow'" != "" {
									if "`lastrow'" == "mean" {
										mata: C = st_matrix("C")
										mata: Mean = mean(C)
										mata: st_matrix("Mean", Mean)
										mat rownames Mean = Average
										if "`tzok'" == "" qui asdocmatdec Mean, dec(`dec')
										mat C = C \ Mean
										loc NaturalRname `NaturalRname' Average

									}

									else if "`lastrow'" == "total" {
										mata: C = st_matrix("C")
										mata: Mean = sum(C)
										mata: st_matrix("Mean", Mean)
										mat rownames Mean = Total
										if "`tzok'" == "" qui asdocmatdec Mean, dec(`dec')
										mat C = C \ Mean
										loc NaturalRname `NaturalRname' Total

									}
								}

								mata: asdoctable("`save'", "`NaturalCname'", 		///
									"`NaturalRname'", "C", "`title'", `fs', `abb', 		///
									"`append'", "", "`rowappend'", " ", `frs', 			///
									"`by'`_byvars'", "`dec'", "`cmd'", "`label'", ///
									"`tzok'", "`font'", "`fhc'",  "`fhr'", "`notes'", "`store'")
								loc `++i'
							}
							else {
								loc append
								loc rowappend "`i'"
								mat C = r(Stat`i')' , TSTAT[`i',1]
								//loc rowappend "yes"
								//mata : append("`save'", "`rowappend'")
								//if "`tzok'" == "" qui asdocmatdec C, dec(`dec')

								mata: asdoctable("`save'", "`NaturalCname'", 	///
									"`NaturalRname'", "C", "`'", `fs', `abb', 		///
									"append", "noheader","`rowappend'"," ", `frs',	///
									"", "`dec'", "`cmd'", "`label'", "`tzok'", ///
									"`font'", "`fhc'",  "`fhr'", "`notes'", "`store'")
								loc `++i'
							}
						}
					}
					// end problem

					else {


						`qui' `anything', by(`Groups') stat(`stats') save

						local NaturalCname : rowfullnames  r(Stat1)
						local TableTitle "`NameLabel' : `r(name`i')'"
						global Ngroups `maxGroups'
						forv i = 1 / `maxGroups'  {
							loc rowappend "`i'"

							local f1 : label `Groups' `i'
							qui space_remover, text(`f1')
							loc accum `xspace'
							loc accum = abbrev("`xspace'", 30)


							mat C = r(Stat`i')'
							if `i' == 1 {
								loc rowappend "`i'"
								loc append `append'
								//if "`tzok'" == "" qui asdocmatdec C, dec(`dec')
								mata: asdoctable("`save'", "`NaturalCname'",		///
									"`accum'", "C", "`title'", `fs', `abb', 		///								
									"`append'", "", "`rowappend'", " ", `frs',		///
									"`by'`_byvars'", "`dec'", "`cmd'", "`label'",	///
									"`tzok'", "`font'", "`fhc'",  "`fhr'", "`notes'", "`store'")
							}
							else {

								loc append
								mat C = r(Stat`i')'
								loc rowappend "`i'"
								//mata : append("`save'", "`rowappend'")
								//if "`tzok'" == "" qui asdocmatdec C, dec(`dec')

								mata: asdoctable("`save'", "`NaturalCname'", 	///
									"`accum'", "C", "`'", `fs', `abb', "append",	///
									"noheader","`rowappend'"," ", `frs',"", 	///
									"`dec'", "`cmd'", "`label'", "`tzok'", ///
									"`font'", "`fhc'",  "`fhr'", "`notes'", "`store'")

							}
						}

					}
				}
				else{
					// problem
					if "`tstat'" == "yes" {
						qui tstatby `varlist', by(`by' `_byvars')
						`qui' tabstat `varlist' `if' `in', by(`by' `_byvars') stat(`stats') save

						loc i = 1
						foreach v of local Ngroups {
							local NaturalRname : rowfullnames  r(Stat`i')
							local NaturalRname `NaturalRname' t-value
							local NaturalCname : colfullnames  r(Stat`i')
							local TableTitle`i' "`NameLabel' : `r(name`i')'"
							if `i' == 1 {


								mat C = r(Stat`i') \ TSTAT[1, 1...]
								mat C = C'

								//if "`tzok'" == "" qui asdocmatdec C, dec(`dec')
								mata: asdoctable("`save'", "`NaturalRname'", 		///
									"`NaturalCname'", "C", "`title' \line `TableTitle`i''", `fs', `abb', 	///
									"`append'", "", "`rowappend'", " ", `frs', 		///
									"", "`dec'", "`cmd'", "`label'", "`tzok'", ///
									"`font'", "`fhc'",  "`fhr'", "`notes'", "`store'")
								loc `++i'

							}
							else {
								local TableTitle "`NameLabel' : `r(name`i')'"
								mat C = r(Stat`i') \ TSTAT[2, 1...]
								mat C = C'

								mata : appendtoExistingFile("`save'", "`rowappend'", $system)
								//if "`tzok'" == "" qui asdocmatdec C, dec(`dec')
								mata: asdoctable("`save'", "`NaturalRname'", 		///
									"`NaturalCname'", "C", "`TableTitle`i''", `fs', 	///
									`abb', "append", "noheader","`rowappend'"," ", 	///
									`frs',"", "`dec'", "`cmd'", "`label'", "`tzok'", ///
									"`font'", "`fhc'",  "`fhr'"	, "`store'")
								loc `++i'
							}
						}
					} // end problem

					else { //by - 2 variables or more - no tstat
						`qui' tabstat `varlist' `if' `in', by(`Groups') stat(`stats') save
						local TableTitle`i' "`NameLabel': `r(name`i')'"

						forv i = 1 / `maxGroups' {

							local NaturalCname : rowfullnames  r(Stat`i')
							local NaturalRname : colfullnames  r(Stat`i')
							local TableTitle `r(name`i')'


							if `i' == 1 {
								mat C = r(Stat1)'
								//if "`tzok'" == "" qui asdocmatdec C, dec(`dec')

								mata: asdoctable("`save'", "`NaturalCname'", "`NaturalRname'", 		///
									"C", "`title' \line `TableTitle`i''", `fs', `abb', 				///
									"`append'", "", "`rowappend'", 								///
									" ", `frs',"", "`dec'", "`cmd'", "`label'", "`tzok'", ///
									"`font'", "`fhc'",  "`fhr'", "`notes'", "`store'")
							}
							else {

								local TableTitle : label `Groups' `i'
								mata : appendtoExistingFile("`save'", "`rowappend'", $system)
								mat C = r(Stat`i')'
								//if "`tzok'" == "" qui asdocmatdec C, dec(`dec')

								mata: asdoctable("`save'", "`NaturalCname'", "`NaturalRname'", 			///
									"C", "`TableTitle'", `fs', `abb', "append", "noheader", 			///
									"`rowappend'"," ", `frs',"", "`dec'", "`cmd'", "`label'", ///
									"`tzok'", "`font'", "`fhc'",  "`fhr'", "`notes'", "`store'")

							}
						}
					}
				}
			}
		}
		else {
			if "`title'"=="" loc title "Summary statistics"
			qui tabstat `varlist' `if' `in', stat(`stats') save
			if "`tstat'"=="yes" mat StatTotal = r(StatTotal) \ tstat
			else mat StatTotal = r(StatTotal)
			loc ActualCols = colsof(StatTotal)
			loc ActualRows = rowsof(StatTotal)

			mat StatTotal = StatTotal'
			local NaturalRname : rowfullnames   StatTotal
			local NaturalCname : colfullnames   StatTotal
			loc NaturalCname = subinstr("`NaturalCname'", "sd", "St.Dev", .)
			loc NaturalCname = subinstr("`NaturalCname'", "p50", "Median", .)
			loc NaturalCname = subinstr("`NaturalCname'", "mean", "Mean", .)
			if "`rowappend'" != "" {
				loc noheader "header not needed"
				local title 
			}

			matlist StatTotal

			if "`lastrow'" != "" {
				if "`lastrow'" == "total" {

				}
				else if "`lastrow'" == "mean" {

				}

			}

			//if "`tzok'" == "" qui asdocmatdec StatTotal, dec(`dec')
			mata: asdoctable("`save'", "`NaturalCname'", "`NaturalRname'", ///
				"StatTotal", "`title'", `fs', `abb', "`append'", "`noheader'",   ///
				"`rowappend'", " ", `frs',"", "`dec'", "`cmd'", "`label'", ///
				"`tzok'", "`font'", "`fhc'", "`fhr'", "`notes'", "`store'")
		}
	}


	else if "`command'"=="wmat" {
		if "`cmd'"!="" loc cmd `anything' `poptions'

		if "`title'"=="" loc title "Results Table"
		if "`matrix'" != "mata" {

			cap confirm matrix `matrix'
			if _rc {
				dis as error "Matrix `matrix' not found"
				dis as text "If you are trying to get a matrix from results stored"
				dis as text " in r or e, those are cleared before this program gets control."
				dis as text " Therefore, first shift results stored in r() to a matrix. "
				dis as text " For example {opt mat C = r(table)}"
				exit
			}
			local NaturalRname : rowfullnames `matrix'
			local NaturalCname : colfullnames `matrix'
			loc ActualCols = colsof(`matrix')
			loc ActualRows = rowsof(`matrix')


			if "`rnames'"!="" | "`cnames'"!=""{
				loc NaturalRname `rnames'
				loc NaturalCname `cnames'


				loc SuppliedRows : word count `rnames'
				loc SuppliedCols : word count `cnames'

				if `SuppliedRows' < `ActualRows' {
					loc dif = `ActualRows'-`SuppliedRows'
					forv i = 1 / `dif' {
						loc NaturalRname  `rnames' Row
					}
				}
				if `SuppliedCols' < `ActualCols' {
					loc dif = `ActualCols'-`SuppliedCols'
					forv i = 1/`dif'{
						loc NaturalCname  `cnames' Col
					}
				}
			}
			else {
				mata: colnames = st_matrixcolstripe("`matrix'")
				mata: rownames = st_matrixrowstripe("`matrix'")


				mata: st_local("NaturalRname", rownames[1,2])
				local NaturalRname "`NaturalRname'"
				mata: st_local("NaturalCname", colnames[1,2])
				local NaturalCname "`NaturalCname'"

				forv r = 2 / `ActualRows' {
					mata: st_local("new", rownames[`r',2])
					if `r' == `ActualRows' local NaturalRname "`NaturalRname', `new'"
					else local NaturalRname "`NaturalRname', `new'"
				}

				forv c = 2 / `ActualCols' {
					mata: st_local("new", colnames[`c',2])
					if `c' == `ActualCols' local NaturalCname "`NaturalCname', `new'"
					else local NaturalCname "`NaturalCname', `new'"
				}
				loc parse ","
			}

			`qui' matlist `matrix', border(top bottom) format(%9.`dec'f)  title("`title'") 
			//if "`tzok'" == "" qui asdocmatdec `matrix', dec(`dec')
			mata: asdoctable("`save'", "`NaturalCname'", "`NaturalRname'", "`matrix'", ///
				"`title'", `fs', `abb', "`append'", "`noheader'","`rowappend'", "`parse'", `frs', ///
				"", "`dec'", "`cmd'", "`label'", "`tzok'", "`font'", "`fhc'",  "`fhr'", "`notes'", "`store'")

		}

		else if "`cnames'" != "" | "`rnames'" != "" {

			mata: 	asdoc_mata_matrix("`save'", "`cnames'", "`rnames'", "`matrix'", ///
				"`title'", `fs', 12, "`append'", "`noheader'","`rowappend'", " ", `frs', ///
				"", "`dec'", "`cmd'", "`label'", "`tzok'" , "`font'", "`fhr'", "`fhc'")
		}
		else mata: 	asdoc_mata_matrix_noheaders("`save'", "_00.asdoc", ///
			"`title'", `fs', 12, "`append'", "`rowappend'", " ", `frs', ///
			"", "`dec'", "`cmd'", "`label'", "`tzok'" , "`font'", "`fhr'", "`fhc'")
	}


	if "`command'" == "sum" {
		if 	strmatch("`poptions'", "*d*") loc details details

		if "`details'"==""{

			// Basic summary statistics

			if "`cmd'"!="" loc cmd `anything' `poptions'
			if "`title'"=="" loc title "Descriptive Statistics"
			loc nVars : word count `varlist'

			if "`qui'"=="" sum `varlist' `if' `in'
			loc i = 1
			loc nz = 1
			foreach z of local varlist {
				loc factor_var_exists 0

				if strmatch("`z'", "*.*") {
					if regexm("`z'", "^ibn.") {
						loc z = regexr("`z'","^ibn.","")
						loc factor_var_exists 1
					} 
					else if regexm("`z'", "^ib.")  {
						loc z = regexr("`z'","^ib.","")
						loc factor_var_exists 1
					}
					else if regexm("`z'", "^i.") {
						loc z = regexr("`z'","^i.","")
						loc factor_var_exists 1				
					}
				}
				if `factor_var_exists' {
					loc i = `i' + 1
					qui aslev `z',  nl  vl  sep(,)
					loc groups  `r(groups)'
					cap qui space_remover, text(`r(vLabel)')
					local rowtitles `rowtitles' \b_`z' `xspace'

					loc nVars = `r(ng)' + 1

					if `nz' == 1 mat SUM = J(`nVars', 5, .)
					else mat SUM =   SUM \ J(`nVars', 5, .)

					foreach v of local groups {

						qui	sum `v'.`z' `if' `in'

						mat SUM[`i',1] = `r(N)'

						mat SUM[`i',2] = `r(mean)'

						mat SUM[`i',3] = `r(sd)'

						mat SUM[`i',4] = `r(min)'

						mat SUM[`i',5] = `r(max)'

						loc `i++'	

					}
				}
				else {
					qui sum `z' `if' `in'
					if `nz' == 1 mat SUM = J(1, 5, .)
					else         mat SUM = SUM \ J(1, 5, .)
					loc rowtitles `rowtitles' `z'

					confirm numeric var `z'

					qui	sum `z' `if' `in'

					if `r(N)' != 0 {

						mat SUM[`i',1] = `r(N)'

						mat SUM[`i',2] = `r(mean)'

						mat SUM[`i',3] = `r(sd)'

						mat SUM[`i',4] = `r(min)'

						mat SUM[`i',5] = `r(max)'

						loc `i++'	
					}

					else {
						mat SUM[`i',1] = 0
						loc `i++'

					}
				}
				loc `++nz'
			}
			//if "`tzok'" == "" asdocmatdectzok SUM, dec(`dec') `tzok'

			loc ctitle "Variable Obs Mean Std.Dev. Min Max"
			mata: asdocsum("`save'", "`ctitle'", "`rowtitles'", "`title'", `fs', `abb', ///
				"`append'", "`dec'","`details'", "`cmd'", "`label'", "`tzok'" , "`font'", ///
				"`fhc'", "`fhr'", "`force'", "`notes'", "`store'")
		}
		else  {
			if "`title'"=="" loc title "Descriptive Statistics"
			if "`cmd'"!="" loc cmd `anything' `poptions'

			loc nVars : word count `varlist'
			mat SUM = J(`nVars', 9, .)
			loc i = 1
			foreach v of varlist `varlist' {
				qui	sum `v' `if' `in', d
				mat SUM[`i',1] = `r(N)'

				qui asdocdec `r(mean)', dec(`dec')
				mat SUM[`i',2] = `value'

				qui asdocdec `r(sd)', dec(`dec')
				mat SUM[`i',3] = `value'

				qui asdocdec `r(min)', dec(`dec')
				mat SUM[`i',4] = `value'

				qui asdocdec `r(max)', dec(`dec')
				mat SUM[`i',5] = `value'

				qui asdocdec `r(p1)', dec(`dec')
				mat SUM[`i',6] = `value'

				qui asdocdec `r(p99)', dec(`dec')
				mat SUM[`i',7] = `value'

				qui asdocdec `r(skewness)', dec(`dec')
				mat SUM[`i',8] = `value'

				qui asdocdec `r(kurtosis)', dec(`dec')
				mat SUM[`i',9] = `value'
				loc `i++'	
			}
			loc ctitle "Obs Mean Std_Dev Min Max p1 p99 Skew Kurt"

			if "`qui'"=="" {
				mat colnames SUM  = `ctitle'
				mat rownames SUM  = `varlist'
				if "`tzok'" != "" matlist SUM,  border(top bottom) format(%9.`dec'f)  title("`title'") 

				else matlist SUM,  border(top bottom) title("`title'")

			}
			loc ctitle "Variables Obs Mean Std.Dev. Min Max p1 p99 Skew. Kurt."
			mata: asdocsum("`save'", "`ctitle'", "`varlist'", "`title'", `fs', `abb', ///
				"`append'", "`dec'", "`details'", "`cmd'", "`label'", "`tzok'", "`font'", ///
				"`fhc'", "`fhr'", "`force'", "`notes'", "`store'")
		}
	}


	*----------------------------------------------------------------------
	*				Multi variate regressions
	*======================================================================
	else if "`command'"=="multireg"{
		`qui' `anything' `poptions'

		* number of equations
		loc nEquations =  e(k_eq)
		loc indepvarsNames : colname(e(b))





	}



	************************* END multi variate regressions ****************




	*---------------
	* reg one call
	*--------------

	else if "`command'"=="detailedReg"{


		if "`by'" == "" & "`_byvars'" == "" {


			`qui' `anything' `poptions' `force' `eform' `or'
			if "`e(cmd)'" == "mi estimate" loc indepvarsNames : colname(e(b_mi))
			else loc indepvarsNames : colname(e(b))
			loc depvar  `e(depvar)'

			cap loc ftp = fprob(`e(df_m)',`e(df_r)',`e(F)')
			if "`e(chi2)'"!="" {
				if "`e(df_m)'"== "" loc dfm = `e(N)' - `e(df)'
				else loc  dfm = `e(df_m)'
				if "`e(p)'" == "" loc chipvalue = chi2tail(`dfm', `e(chi2)')
				else loc chipvalue = `e(p)'

			}

			loc f_testP_value 		= 	chi2tail(e(df_m), e(chi2))

			loc rsquare_value = cond("`e(r2_p)'"!="", 	"`e(r2_p)',", 		 ///
				cond("`e(r2)'"!="", 	"`e(r2)',", 						 ///
				cond("`e(r2_o)'"!="", 	"`e(r2_o)',","")))

			loc rsquare_text =  cond("`e(r2_p)'"!="", 	",Pseudo r-squared", ///
				cond("`e(r2)'"!="", 	",R-squared", 						 ///
				cond("`e(r2_o)'"!="", 	",Overall r-squared","" )))

			loc f_test_value = 	cond("`e(chi2)'"!="", 	"`e(chi2)',", 		 ///
				cond("`e(F)'"!="", 		"`e(F)',", 	".,"))


			loc f_test_text = 	cond("`e(chi2)'"!="", 	",Chi-square", 		 ///
				cond("`e(F)'"!="", 		",F-test", 	""))

			loc f_testP_value = cond("`e(chi2)'"!="", 	"`chipvalue',", 	 ///
				cond("`e(F)'"!="", 		"`ftp',", ".,"))

			loc f_testP_text = 	cond("`e(chi2)'"!="", 	 ",Prob > chi2", 	 ///
				cond("`e(F)'"!="", 		",Prob > F", ""))

			loc model_name 		`e(title)'					
			loc depvar 			`e(depvar)'

			loc nobs			",Number of obs"
			loc nobs_value 	= 	"`e(N)',"
			loc model_name		`e(title)'
			if "`cmd'"!="" loc cmd	`e(cmdline)'

			mat C = r(table)
			//qui asdocmatdec C, dec(`dec')
			qui cap estat ic
			mat S = r(S)

			if S[1,1]!= . {
				loc aictext ",Akaike crit. (AIC), Bayesian crit. (BIC)"
				loc AIC_value 	= S[1,5]
				loc BIC_value 	= S[1,6]
				loc aicvalue = "`AIC_value', `BIC_value'"
				loc fp = "`f_testP_value'"

			}
			else {
				if "`e(r2_o)'"!=""{
					loc aictext ",R-squared within, R-squared between"
					loc AIC_value 	= `e(r2_w)'
					loc BIC_value 	= `e(r2_b)'
					loc aicvalue 	= "`AIC_value', `BIC_value'"
					loc fp 			= "`f_testP_value'"

				}
				else {
					loc fp 			= "`f_testP_value' ."

				}
			}

			qui sum `depvar' if e(sample)
			loc Mean 	= "`r(mean)'"
			loc SD 		= "`r(sd)'"
			if "`Mean'" == "" loc Mean ".,"
			else loc Mean "`Mean',"
			if "`SD'" == "" loc SD ".,"
			else loc SD "`SD',"
			if "`title'"=="" loc title "`model_name'"
			if "`title'"=="" loc title "Regression results"
			if `abb' == 10 loc abb 20

			loc model_info "`title', `depvar'"
			loc topline "`depvar' Coef. St.Err t-value p-value Sig."
			loc reg_text "Mean dependent var, SD dependent var `rsquare_text' `nobs'  `f_test_text'  `f_testP_text' `aictext'"
			mat reg_value_vector =`Mean'  `SD' `rsquare_value'  `nobs_value'  `f_test_value' `fp' `aicvalue'

			mata: func_detailed_reg("`reg_text'",	"`model_info'",	"`topline'", "`save'", 	///
				"`indepvarsNames'","`depvar'", `fs', `abb', "`append'", "SE_option", "`title'",	///
				"`cmd'", "`dec'", "`label'",1 , "`font'", "`fhr'", "`fhc'", ///
				"`nostars'", "`noci'", "`tzok'", "`notes'", "`force'")

			//makertf, notes(`notes') title(`title') save(`save') append(`append') ///
				//  fs(`fs') font(`font') abb(`abb') `tzok' cs(`cs') notes(`notes')
		}
		else {

			**************************************************************************
			*						bysort detailedReg
			**************************************************************************
			tempvar Groups
			qui ds `by' `_byvars' , has(type string)
			if "`r(varlist)'" == "" {
				tempvar strby 
				ds `by' `_byvars' , has(vallabel)
				if "`r(varlist)'" != "" {
				    decode `by' `_byvars', gen(`strby')
					qui encode `strby' `if' `in', gen(`Groups')
				}

				else { // Pure numeric without labels 
					qui asencode `by' `_byvars' , gen(`Groups')
				}
			}
			else qui encode `by' `_byvars' `if' `in', gen(`Groups')


			qui sum `Groups' `if' `in'
			if "`r(max)'" == "" loc maxGroups 0 
			else loc maxGroups = `r(max)'


			cap getifin `varlistifin'

			if "`if'" != "" loc byGroup &  `Groups'
			else loc byGroup if `Groups'


			forv j = 1 / `maxGroups' {
				qui cap noi `anything' `byGroup' == `j'  `poptions' `eform' `or'
				if _rc continue
				if `j' == `maxGroups' loc bylast = 1  
				else loc bylast = 0 
				if `j' > 1 loc append append
				loc groupName : label `Groups' `j'

				loc coltitle = subinstr("`cnames'", " ", "_", .)


				loc indepvarsNames : colname(e(b))
				loc depvar  `e(depvar)'
				cap loc ftp = fprob(`e(df_m)',`e(df_r)',`e(F)')
				if "`e(chi2)'"!="" {
					if "`e(df_m)'"== "" loc dfm = `e(N)' - `e(df)'
					else loc  dfm = `e(df_m)'
					if "`e(p)'" == "" loc chipvalue = chi2tail(`dfm', `e(chi2)')
					else loc chipvalue = `e(p)'

				}

				loc f_testP_value 		= 	chi2tail(e(df_m), e(chi2))

				loc rsquare_value = cond("`e(r2_p)'"!="", 	"`e(r2_p)',", 		///
					cond("`e(r2)'"!="", 	"`e(r2)',", 							///
					cond("`e(r2_o)'"!="", 	"`e(r2_o)',","")))

				loc rsquare_text =  cond("`e(r2_p)'"!="", 	",Pseudo r-squared", ///
					cond("`e(r2)'"!="", 	",R-squared", 							///
					cond("`e(r2_o)'"!="", 	",Overall r-squared","" )))

				loc f_test_value = 	cond("`e(chi2)'"!="", 	"`e(chi2)',", 		///
					cond("`e(F)'"!="", 		"`e(F)',", 	".,"))

				loc f_test_text = 	cond("`e(chi2)'"!="", 	",Chi-square", 		///
					cond("`e(F)'"!="", 		",F-test", 	""))

				loc f_testP_value = cond("`e(chi2)'"!="", 	"`chipvalue',", 	///
					cond("`e(F)'"!="", 		"`ftp',", ".,"))

				loc f_testP_text = 	cond("`e(chi2)'"!="", 	 ",Prob > chi2", 	///
					cond("`e(F)'"!="", 		",Prob > F", ""))

				loc model_name 		`e(title)'					
				loc depvar 			`e(depvar)'
				loc nobs			",Number of obs"
				loc nobs_value 	= 	"`e(N)',"
				loc model_name		`e(title)'
				if "`cmd'"!="" loc cmd	`e(cmdline)'

				mat C = r(table)
				qui asdocmatdec C, dec(`dec')
				qui cap estat ic
				mat S = r(S)

				if S[1,1]!= . {
					loc aictext ",Akaike crit. (AIC), Bayesian crit. (BIC)"
					loc AIC_value 	= S[1,5]
					loc BIC_value 	= S[1,6]
					loc aicvalue = "`AIC_value', `BIC_value'"
					loc fp = "`f_testP_value'"

				}
				else {
					if "`e(r2_o)'"!=""{
						loc aictext ",R-squared within, R-squared between"
						loc AIC_value 	= `e(r2_w)'
						loc BIC_value 	= `e(r2_b)'
						loc aicvalue 	= "`AIC_value', `BIC_value'"
						loc fp 			= "`f_testP_value'"

					}
					else {
						loc fp 			= "`f_testP_value' "

					}
				}

				qui sum `depvar' if e(sample)
				loc Mean 	= "`r(mean)'"
				loc SD 		= "`r(sd)'"
				if "`Mean'" == "" loc Mean ".,"
				else loc Mean "`Mean',"
				if "`SD'" == "" loc SD ".,"
				else loc SD "`SD',"

				if "`title'"=="" loc titletouse "`model_name': `by' `_byvars' = `groupName'"
				else loc titletouse  "`title'"
				if `abb' == 10 loc abb 20

				loc model_info "`title', `depvar'"
				loc topline "`depvar' Coef. St.Err t-value p-value Sig."
				loc reg_text "Mean dependent var, SD dependent var `rsquare_text' `nobs'  `f_test_text'  `f_testP_text' `aictext'"

				mat reg_value_vector =`Mean'  `SD' `rsquare_value'  `nobs_value'  `f_test_value' `fp' `aicvalue'
				mata: func_detailed_reg("`reg_text'",	"`model_info'",	"`topline'", "`save'", 	///
					"`indepvarsNames'", "`depvar'",`fs', `abb', "`append'", "SE_option", "`titletouse'",	///
					"`cmd'", "`dec'", "`label'", `bylast', "`font'", "`fhr'", ///
					"`fhc'", "`nostars'", "`noci'", "`tzok'", "`notes'", "`force'")

			}
		}
	}

	else if "`command'" == "inspect" {

		if "`varlistifin'" == "" | "`varlistifin'" == " " {
			qui ds, has(type numeric) 
			loc varlistifin "`r(varlist)'"
		}

		loc nvars : word count `varlistifin'
		if `nvars' > 1 {
			loc index = 1

			foreach v of varlist `varlistifin' {
				capture confirm numeric variable `v' 

				if !_rc {
					loc label : variable label `v'
					if `index' == 1 {

						asdoc_inspect `v', notes(`notes') title(`v' : `label') save(`save') append(`append') ///
							fs(`fs') font(`font') abb(`abb') `tzok' 
						loc ++index
					}
					else {
						asdoc_inspect `v', notes(`notes') title(`v' : `label') save(`save') append(append) ///
							fs(`fs') font(`font') abb(`abb') `tzok' 
						loc ++index
					}
				}
			}
		}

		else {
			capture confirm numeric variable `varlistifin'
			if !_rc {
				loc label : variable label `varlistifin'
				asdoc_inspect `varlistifin', notes(`notes') title(`v' : `label') save(`save') append(`append') ///
					fs(`fs') font(`font') abb(`abb') `tzok' 
			}
			else {
				dis as error "Variable '`varlistifin'' is not numeric, no table generated."
				exit
			}
		}

	}


	else if "`command'"=="other" {
		if "`by'" != "" loc by by(`by')
		mata: ghkstart()
		`anything'  `poptions' `by'
		mata: ghkend()
		mata:asdocfsize()
		if `nlines'>1 mata: asdocrest("`save'","`title'", "`append'", `fs', ///
			"`cmd'", "`font'", `dec', "`fhr'", "`fhc'")

	}
	else if "`command'"=="other_custom" {
		if "`by'" != "" loc by by(`by')
		mata: ghkstart()
		`anything'  `poptions' `by'
		mata: ghkend()
		mata:asdocfsize()
		if `nlines'>1 mata: asdocrest_custom("`save'","`title'", "`append'", `fs', ///
			"`cmd'", "`font'", `dec', "`fhr'", "`fhc'")

	}



	closemall
	if "`command'" !="accu," {
		if "`output'" != "no" di as smcl `"Click to Open File:  {browse "`save'"}"'
	}
	cap rm a2.log
	if "`cite'" != "" {


	}
	if "`transpose'" != ""  makertf, transpose 

end

program define set_default_format


	syntax, [format(str) dec(str) dpcomma sep000 fontformat(str) tzok sepspace align(str) *]

	if ("`format'" != "" & "`sep000'" != "") dis "Please note that the option sep000 uses the %14,#fc format and overrides any custom format"

	if ("`format'" != "" & "`sepspace'" != "") dis "Please note that the option sepspace uses the %14,#fc format and overrides any custom format"

	if ("`sep000'"  != "") loc format  "%14,`dec'fc"

    if ("`sepspace'" != "") loc format  "%14.`dec'fc"

	if ("`dpcomma'" != "") loc format  "%14.`dec'fc"

	if "`sep000'" == "" {

		if "`format'" != "" {

			mata: st_local("is_correct_format", strofreal(st_isfmt("`format'")))

			if !`is_correct_format' {

				dis as error "Invalide format specified in the the fmt() option, hence ignored"

				loc format
			}
		}

		else loc format %14.`dec'f
	}

	if "`dpcomma'" != "" loc format = subinstr("`format'", ".", "," , .)

	else loc format = subinstr("`format'", ",", "." , .)
	forv i = 1 / 50 {
		if ("${c`i'_dec}" == "")  global c`i'_dec = `dec'
		else global c`i'_dec ${c`i'_dec}

		global c`i'_disfmt  "`format'"

		if ("${c`i'_tzok}" != "" ) global c`i'_tzok "${c`i'_tzok} "

		if ("${c`i'_fmt}" != "" ) global c`i'_fmt  ${c`i'_fmt}
		//global c`i'_align `align'

	}
end


program define reset_colfmt
	syntax, [dpcomma]
	forv i = 1 / 50 {
		global c`i'_dec = 3
		global c`i'_disfmt "%20.3f"
		global c`i'_tzok 
		global c`i'_fmt 
		global c`i'_align
	}

end

*! Attaullah Shah : Formatted macro: flocal creates a local that is formated for decimal points
prog flocal
	syntax anything, [dec(int 3)]

	local nwindow : word count `anything'
	if `nwindow'>2 {
		dis ""
		display as error "Only two arguments allowed! name of the macro and a number"
		exit
	}
	tokenize `anything'
	gettoken  MacroName anything : anything
	gettoken  Number anything : anything


	cap confirm number `Number'
	if _rc c_local `MacroName' `Number'
	else c_local `MacroName' : di %9.`dec'f = `Number'
end






*! ltc 1 : List to comma, by Attaullah Shah, May 5, 2018
prog ltc

	loc count : word count `0'
	loc accum : word 1 of `0'
	loc accum "`accum'"
	loc nt = 1
	forv i = 2 / `count' {
		loc alone : word `i' of `0'
		loc accum "`accum', `alone'"
	}
	c_local ctext `accum'
end


*! tstatby : ttests over a grouping variable: Attaullah Shah July 2007
prog tstatby
	syntax varlist [in][if], [by(varlist)]
	marksample touse

	if "`by'" != ""{

		qui aslev `by', noq
		loc groups `r(groups)'
		loc ng = `r(ng)'
		loc nvar : word count `varlist'
		qui tabstat `varlist' if `touse', stat(mean semean) save by(`by') 
		if `nvar' == 1{
			mat TSTAT = J(`ng',1,.)
			loc i = 1
			foreach v of local  groups{
				mat ts = r(Stat`i')
				mat TSTAT[`i',1] = ts[1,1] / ts[2,1]
				loc `++i'
			}
			mat rowname TSTAT = `groups'
			mat colname TSTAT = "t-value"
		}
		else {
			loc i = 1

			foreach v of local  groups{
				mata:  C = st_matrix("r(Stat`i')")
				mata: T = C[|1,1 \ 1,.|]:/ C[|2,1 \ 2,.|]
				mata: st_matrix("T", T)
				if `i' == 1 mat TSTAT = T
				else mat TSTAT = TSTAT \ T
				loc `++i'
			}
			loc i = 1
			foreach v of varlist `varlist' {
				if `i' == 1 {
					loc cnames "t(`v')"
					loc `++i'
				}
				else {
					loc cnames "`cnames' t(`v')"
					loc `++i'
				}
			} 
			mat rowname TSTAT = `groups'
			mat colname TSTAT = `cnames'
		}

	}
	else {
		qui ttest `varlist' == 0 if `touse'
		mat TSTAT = J(1,1,.)
		mat TSTAT[1,1] =   `r(t)'
	}
	matlist TSTAT

end



*! closemall : Close all open file handles: Attaullah Shah, July 2017
program closemall
	forvalues i=0/10 {
		cap mata: fclose(`i')
	}
end


prog no_output
	dis as res "No output found"
	c_local output no
end


*! asttom 1.0: ttests to matrix by Attaullah Shah 08Jan2018
prog asttom, byable(onecall) rclass
	gettoken vn rest : 0, parse(" =")
	gettoken eq rest : rest, parse(" =")
	if "`eq'" == "==" {
		local 0 `vn' = `rest'
	}
	syntax varname 		///
		[=/exp]	 			///
		[if] [in] [,		///
		Title(string) 		///
		save(string)		///
		ABBreviate(int 8)   ///
		DECimal(int 3)		///
		FSize (int 8)		///
		Robust        		///
		Newey(int 0)		///
		ROWNames(string)	///
		COLNames(string)	///
		TABLEname(string)	///
		BY(varlist)			///
		UNPaired 			///
		UNEqual 			///
		Welch 				///
		Level(int 95) 		///
		ONEsample 			///
		TWOsample 			///
		STatistics(string)		///
		SEPerator(string)		///
		CNames(str) 			///
		]

	cap confirm variable `exp'
	if `"`exp'"'!="" {
		if "`by'"!="" {
			di in red "may not combine = and option by()"
			di as txt "You can use the bysort prefix for repeating t-test over groups"
			di as txt " e.g, {cmd: bysort `by': asdoc ttest `varlist' == `exp', replace}"
			exit 198
		}
		cap confirm variable `exp'
		if _rc local test "OneSample"
		else   local test "TwoSampleVar"
	}
	else if "`by'"=="" {
		loc exp = "=0"
		local test "OneSample"
	}
	else local test "TwoSampleBy"

	marksample touse
	if "`robust'"!="" & "`unpaired'"!="" & "`unequal'"!="" & "`welch'"!=""{
		dis as error "Option robust and `unpaired' `unequal' `welch' cannot be used together"
		exit
	}
	loc options ", `robust' `unpaired' `unequal' `welch'"
	local AllowedStats "mean se df obs t p sd dif"
	if !`: list statistics in local(AllowedStats)'{
		display as error "Error in the statistics(`statistics') option!"
		display as text "only the following statistics are allowed"
		display as result "`AllowedStats'"
	}

	if "`_byvars'"!="" {
		qui aslev `_byvars', nl
		local groups "`r(groups)'"
		loc NameLabel  `r(nLabel)'
		loc ng `r(ng)'
		if "`NameLabel'" == "" local NameLabel `by'
	}


	if "`cnames'" != "" {
		gettoken a cnames : cnames, p(",")
		gettoken b cnames : cnames, p(",")
		gettoken c cnames : cnames, p(",")
	}
	else {
		loc a Mean1
		loc c Mean2
	}
	if "`a'" == "" loc a Mean1
	if "`c'" == "" loc c Mean2
	qui space_remover, text(`a')
	loc a "`xspace'"

	qui space_remover, text(`c')
	loc c "`xspace'"



	if "`robust'"!="" loc optRobust_text "(with robust standard errors)"
	if "`test'" == "OneSample" {	

		if "`title'"=="" local title "One-sample t test for `varlist' `optRobust_text'"

		if "`statistics'"=="" local statistics "obs mean se t p"
		loc nstats : word count `statistics'




		qui reg `varlist' if `touse' , `robust'

		mat C = J(1,`nstats',.)
		loc se = _se[_cons]
		loc mean = _b[_cons]

		loc t = `mean' / `se'
		loc df =  e(df_r)
		loc p =  2*ttail(`df', abs(`t'))
		loc obs = e(N)
		loc sd = sqrt(`obs') * `se'


		if "`exp'" != "0" {
			tempvar expvar
			qui gen `expvar' = `varlist' - `exp'
			qui reg `expvar' if `touse' , `robust'
			loc se = _se[_cons]
			loc t = _b[_cons] / `se'
			loc sd = sqrt(`obs') * `se'
			loc p =  2*ttail(`df', abs(`t'))

		}





		local i = 1
		foreach v of local statistics{
			if "`v'" == "obs" {
				mat C[1 , `i'] = round(`obs' , .5)
				loc accum "`accum' obs"
				loc `++i'
			}
			else if "`v'" == "mean" {
				mat C[1 , `i'] = round(`mean' , .0005)
				loc accum "`accum' Mean"

				loc `++i'
			}
			else if "`v'" == "se" {
				mat C[1 , `i'] = round(`se' , .0005)
				loc accum "`accum' St_Err"

				loc `++i'
			}
			else if "`v'" == "t" {
				mat C[1 , `i'] = round(`t', .0005)
				loc accum "`accum' t_value"

				loc `++i'
			}
			else if "`v'" == "p" {
				mat C[1 , `i'] = round(`p' , .0005)
				loc `++i'
				loc accum "`accum' p_value"

			}
			else if "`v'" == "df" {
				mat C[1 , `i'] = round(`df' , .5)
				loc `++i'
				loc accum "`accum' df"

			}	
			else if "`v'" == "sd" {
				mat C[1 , `i'] = round(`sd' , .0005)
				loc accum "`accum' St_Dev"

				loc `++i'

			}	

		}
		local rownames "`varlist'"
		loc twidth = 16


	}
	if "`test'"=="TwoSampleBy" {
		if "`title'" == "" {
			if "`unequal'"!= "" loc pair unequal
			else loc pair equal
			local title "Two-sample t test with `pair' variances"
		}
		if "`statistics'"=="" local statistics "obs mean dif se t p"
		loc nstats : word count `statistics'

		loc mean "mean"
		if `: list mean in local(statistics)'{
			loc nstats = `nstats' + 1
		}

		loc mean "obs"
		if `: list obs in local(statistics)'{
			loc nstats = `nstats' + 1
		}

		ttest `varlist' if `touse', by(`by') `welch' `unequal' level(`level')
		mat C = J(1,`nstats',.)
		loc mean1  = r(mu_1)
		loc mean2  = r(mu_2)
		loc obs1 =  r(N_1)
		loc obs2 =  r(N_2)
		loc se = r(se)
		loc dif = `mean1' - `mean2'
		loc t = r(t)
		loc p = r(p)
		loc df = r(df_t)
		qui aslev `by', nl
		loc ByCategories `r(groups)'


		local i = 1
		foreach v of local statistics{
			if "`v'" == "obs" {
				mat C[1 , `i'] = round(`obs1' , .5)
				loc accum "`accum' obs1"
				loc `++i'

				mat C[1 , `i'] = round(`obs2' , .5)

				loc accum "`accum' obs2"
				loc `++i'
			}
			else if "`v'" == "mean" {
				mat C[1 , `i'] = round(`mean1' , .0005)
				loc accum "`accum' `a'"
				loc `++i'

				mat C[1 , `i'] = round(`mean2' , .0005)

				loc accum "`accum' `c'"

				loc `++i'
			}
			else if "`v'" == "se" {
				mat C[1 , `i'] = round(`se' , .0005)
				loc accum "`accum' St_Err"

				loc `++i'
			}
			else if "`v'" == "t" {
				mat C[1 , `i'] = round(`t', .05)
				loc accum "`accum' t_value"

				loc `++i'
			}
			else if "`v'" == "p" {
				mat C[1 , `i'] = round(`p' , .0005)
				loc `++i'
				loc accum "`accum' p_value"

			}
			else if "`v'" == "df" {
				mat C[1 , `i'] = round(`df' , .5)
				loc `++i'
				loc accum "`accum' df"

			}	
			else if "`v'" == "dif" {
				mat C[1 , `i'] = round(`dif', .0005)
				loc accum "`accum' dif"

				loc `++i'

			}
			loc ByCategories "`ByCategories'"
			mata: stloc = st_local("ByCategories")
			mata: st = subinstr(stloc, char(34), "")
			mata: st_local("ByCategories", st)


			local rownames "`varlist' by `by': `ByCategories'"

			loc twidth = 22
		}

	}
	if "`test'" == "TwoSampleVar" {
		if "`statistics'"=="" local statistics "obs mean dif se t p"
		loc nstats : word count `statistics'
		if "`unpaired'"!= "" loc pair Unpaired
		else loc pair Paired
		if "`title'" == "" local title "`pair' t test : `varlist' `exp'"
		* IF mean
		loc mean "mean"
		if `: list mean in local(statistics)'{
			loc nstats = `nstats' + 1
		}


		`qui' ttest `varlist' = `exp' if `touse', `welch' `unequal' level(`level')
		mat C = J(1,`nstats',.)
		loc mean1  = r(mu_1)
		loc mean2  = r(mu_2)
		loc obs =  r(N_1)
		loc se = r(se)
		loc dif = `mean1' - `mean2'
		loc t = r(t)
		loc p = r(p)
		loc df = r(df_t)
		local i = 1
		foreach v of local statistics{
			if "`v'" == "obs" {
				mat C[1 , `i'] = round(`obs' , .5)
				loc accum "`accum' obs"
				loc `++i'

			}
			else if "`v'" == "mean" {
				mat C[1 , `i'] = round(`mean1' , .0005)
				loc accum "`accum' `a'"
				loc `++i'

				mat C[1 , `i'] = round(`mean2' , .0005)

				loc accum "`accum' `c'"

				loc `++i'
			}
			else if "`v'" == "se" {
				mat C[1 , `i'] = round(`se' , .0005)
				loc accum "`accum' St_Err"

				loc `++i'
			}
			else if "`v'" == "t" {
				mat C[1 , `i'] = round(`t', .05)
				loc accum "`accum' t_value"

				loc `++i'
			}
			else if "`v'" == "p" {
				mat C[1 , `i'] = round(`p' , .0005)
				loc `++i'
				loc accum "`accum' p_value"

			}
			else if "`v'" == "df" {
				mat C[1 , `i'] = round(`df' , .5)
				loc `++i'
				loc accum "`accum' df"

			}	
			else if "`v'" == "dif" {
				mat C[1 , `i'] = `dif'
				loc accum "`accum' dif"

				loc `++i'
			}	
		}
		local rownames "`varlist' - `exp'"
		loc twidth = 22

	}
	if "`seperator'"!="" {
		aseploc  `accum', seperator(`seperator')
		loc colnames `r(sep)'
	}
	else loc colnames "`accum'"

	mat colnames C = `accum'

	mat rownames C = "`rownames'"
	matlist C, title("`title'") tindent(20) line(eq) border(top bottom) twidth(`twidth')  

	return matrix T = C
	return local colnames "`colnames'"
	return local rownames "`rownames'`seperator'"
	return local ttitle "`title'"
	return hidden local sep "`seperator'"

end



*! ctq: comma to quotes: Version 1.0 Attaullah Shah 05Feb2018

prog ctq
	loc nt = 1
	while "`0'"!="" {
		gettoken base rest : 0, parse(",")
		gettoken throw 0 : rest, parse(",")
		loc `++nt'
		if `nt' == 1 loc accum "`base'"
		else loc accum "`accum'" "`base'"
	}
	c_local ctext `accum'""
end



*! asttomby: ttests over a grouping variable: Version 1.0 Attaullah Shah 09Jan2018
prog asttomby, byable(onecall) rclass
	//syntax varlist [if] [in], [by(str)]
	if  strmatch("`0'", "*if*") loc andif "&"
	else loc andif "if"

	gettoken p1 options : 0, parse(",")
	qui sum `_byvars'
	if "`r(max)'" == "" loc maxGroups 0 
	else loc maxGroups = `r(max)'



	forv g = 1 / `maxGroups' {
		if `g' == 1 {
			cap qui asttom `p1' `andif' `_byvars' == `g' `options' 
			if !_rc mat accum = r(T)

			local f1 : label `_byvars' 1
			qui space_remover, text(`f1')
			loc name = abbrev("`xspace'", 50)
			mat rownames accum = `name'

		}
		else {
			cap qui asttom `p1' `andif' `_byvars' == `g' `options' 
			if !_rc {
				mat B = r(T)
				loc title "`r(ttitle)'"	
				local f1 : label `_byvars' `g'
				qui space_remover, text(`f1')
				loc name = abbrev("`xspace'", 50)
				mat rownames B = `name'

				mat accum = accum \ B

			}
		}
	}
	/*
		   Work on combined and difference is remaining
		   if `maxGroups' == 2 {
		   qui ttest `p1'  , by(`_byvars')
		   loc cols = colsof(accum)
		   loc rows = rowsof(accum)
		   mat accum = accum \ J(`rows', `cols', .)
		   mat accum[`rows'+1, 1] = `r(N_1)' + `r(N_2)'
		   mat accum[`rows'+1, 2] = `r(mu_1)' - `r(mu_2)'

		   }
	*/
	matlist accum,      	///
		title(`title') 		///
		tindent(20) 			///
		line(eq)           	///
		border(top bottom) 	///
		twidth(22)        		///

	return matrix T = accum
	return local ttitle "`title'"

end


*! Added global Jan4, 2018
*! Added [if] [in] support: Aug 28, 2018
*! Version 2.1.0 , Attaullah Shah, attaullah.shah@imsciences.edu.pk,Aug1, 2018
*! Version 1.0 , Attaullah Shah, attaullah.shah@imsciences.edu.pk,7Jan2018
prog aslev, sortpreserve rclass

	syntax varname [if] [in],  [VLabel NLabel NOQuotes SEP(str) global NOSpace]
	preserve
	marksample touse, nov


	qui keep if `touse'
	capture confirm numeric variable `varlist'
	if _rc loc varnum = 0
	else loc varnum = 1

	tempname id first 
	bys `varlist' `touse' : gen `first' = _n==1
	gen `id' = sum(`first')

	qui replace `id' = . if `first'==0
	qui sum `id'
	sort `id'
	loc i = 1

	if `varnum'==1 | "`noquotes'"~="" {
		if "`varnum'" == "0" local p = `""""'
		else local p = .
		while `id'[`i']!=. &  `varlist'[`i']!=`p' {
			loc level = `varlist'[`i']  
			loc accum `accum' `level'
			loc i = `i'+1
		}
	}
	else {
		tempvar dummy
		qui gen `dummy' =`"""'+`varlist'+`"""' if `first'==1

		while `id'[`i']!=. {
			if `i'!= 1 {
				loc level = `dummy'[`i']
				loc accum `accum' `level'
				loc i = `i'+1
			}
			else{
				loc level = `dummy'[`i']
				loc accum `level'"
				loc i = `i'+1
			}
		}
	}

	if "`vlabel'" ~= ""{
		qui ds `varlist', has(vallabel)
		if "`r(varlist)'" != "" {
			local lbe : value label `varlist'
			loc n = 1
			foreach i of local accum {
				cap local f`i' : label `lbe' `i'
				if _rc {


					if `n'!=1 loc vLabel "`vLabel'`sep' `i'"
					else loc vLabel "`vLabel'`i'"
					if "`nospace'" != "" qui space_remover, text(`vLabel')

				}
				else if `n'!=1 loc vLabel "`vLabel'`sep' `f`i''"
				else loc vLabel "`vLabel'`f`i''"

				loc `++n'
			}
			return local vLabel "`vLabel'"
			if "`global'" != "" global vLabel "`vLabel'"

		}


		// numeric variables
		else{
			loc n = 1
			foreach i of local accum {
				if `n'!=1 loc vLabel "`vLabel'`sep' `i'"
				else loc vLabel "`i'"

				loc `++n'
			}
			return local vLabel "`vLabel'"
			if "`global'" != "" global vLabel "`vLabel'"
		}
	}
	if "`nlabel'"~=""{
		local nLabel : variable label `varlist'
		return local nLabel "`nLabel'"
		if "`global'" != "" global nLabel "`nLabel'"

	}

	*-----------------------------
	if `varnum' | "`noquotes'"~="" {
		di "`accum'"
		return local groups `accum'
		local ng : word count `accum'
		return local ng `ng'
		if "`global'" != "" global ng `ng'

	}

	*-----------------------------

	else {
		di `""`accum'"'
		loc g = `""`accum'"'
		return local groups ""`accum'"
		local ng : word count `g'
		return local ng `ng'
		if "`global'" != "" global ng `ng'

	}
	if `varnum' == 1 return local vartype numeric
	else return local vartype string

end


*! getlable: get variable lable
prog def getlable

	local NameLabel : variable label `0'
	if "`NameLabel'" == "" local NameLabel `0'
	c_local varLabel "`NameLabel'"
end



*! asdocby : Handle byvars
prog asdocby
	syntax varlist [if] [in]
	qui ds `varlist' , has(type string)
	if "`r(varlist)'" != "" {
		c_local str = 1
		loca str = 1
	}
	else {
		c_local str = 0
		local str = 0
	}

	qui aslev `varlist' `if' `in', vlabel
	if `str' == 1 c_local Ngroups  `"`r(groups)'"'
	else c_local Ngroups  `r(groups)'

	cap qui space_remover, text(`r(vLabel)')
	c_local vgroups  `xspace'

end





*! getoptions: seperate asdoc and Stata options: version 1.0 15Jan2018 Attaullah Shah
prog getoptions, rclass
	loc col_tzok_list c1_tzok c2_tzok c3_tzok c4_tzok c5_tzok c6_tzok c7_tzok ///
		c8_tzok c9_tzok c10_tzok c11_tzok c12_tzok c13_tzok c14_tzok c15_tzok ///
		c16_tzok c17_tzok c18_tzok c19_tzok c20_tzok

	loc col_align_list c1_align c2_align c3_align c4_align c5_align c6_align ///
		c7_align c8_align c9_align c10_align c11_align c12_align c13_align  /// 
		c14_align c15_align c16_align c17_align c18_align c19_align c20_align

	loc col_fmt_list c1_fmt c2_fmt c3_fmt c4_fmt c5_fmt c6_fmt c7_fmt c8_fmt ///
		c9_fmt c10_fmt c11_fmt c12_fmt c13_fmt c14_fmt c15_fmt c16_fmt c17_fmt ///
		c18_fmt c19_fmt  c20_fmt 

	loc col_disfmt_list c1_disfmt c2_disfmt c3_disfmt c4_disfmt c5_disfmt c6_disfmt c7_disfmt c8_disfmt ///
		c9_disfmt c10_disfmt c11_disfmt c12_disfmt c13_disfmt c14_disfmt c15_disfmt c16_disfmt c17_disfmt ///
		c18_disfmt c19_disfmt c20_disfmt 

	loc col_dec_list c1_dec c2_dec c3_dec c4_dec c5_dec c6_dec c7_dec c8_dec ///
		c9_dec c10_dec c11_dec c12_dec c13_dec c14_dec c15_dec c16_dec c17_dec ///
		c18_dec c19_dec c20_dec

	loc singleOption nest nested append replace hid cmd  noheader pbreak reset end ///
		nonum non label isreg tzok newtable stars nor2 rowappend wide bracket /// 
		notse btp show eform nostars noci or force  dpcomma sep000 ///
		sepspace store nocf transpose

	loc alist frs keep drop title save abb dec text add rnames cnames mat matrix ///
		fcolor stats stat statistics fs by rep row  t se align addend cs accum ///
		fhr fhc cellwidth subopt setstars font cite notes lastrow format currency ///
		bracket fontformat 

	while "`0'" != ""{
		gettoken a 0 : 0, bind
		gettoken c p2: a, parse("(") bind

		if `: list c in local(alist)'{
			loc compopt `compopt' `c'`p2'
			loc sepCompact "`sepCompact' "`c'`p2'""

		}
		else if `: list c in local(singleOption)'{
			loc signleopt `signleopt' `c'
		}
		else if `: list c in local(col_tzok_list)' {
			loc tzok_option `tzok_option' `c'
		}
		else if `: list c in local(col_align_list)'{
			loc align_opton "`align_opton' "`c'`p2'""
		}
		else if `: list c in local(col_fmt_list)'{
			loc fmt_opton "`fmt_opton' "`c'`p2'""
		}
		else if `: list c in local(col_disfmt_list)'{
			loc disfmt_opton "`disfmt_opton' "`c'`p2'""
		}
		else if `: list c in local(col_dec_list)'{
			loc dec_opton "`dec_opton' "`c'`p2'""
		}
		else {
			loc pOptions `pOptions' `c'`p2'
		}
	}
	c_local aoption "`asdocOptions'"

	foreach i of local signleopt {

		c_local `i' `i'
	}

	foreach i of local tzok_option {
		global `i' `i'
	}
	foreach i of local align_opton {
		gettoken name content : i, parse("(")
		gettoken par content : content, parse("(")
		gettoken content par : content, parse(")")
		global `name' `content'
	}

	foreach i of local fmt_opton {
		gettoken name content : i, parse("(")
		gettoken par content : content, parse("(")
		gettoken content par : content, parse(")")
		global `name' `content'
	}
	foreach i of local disfmt_opton {
		gettoken name content : i, parse("(")
		gettoken par content : content, parse("(")
		gettoken content par : content, parse(")")
		global `name' `content'
	}
	foreach i of local dec_opton {
		gettoken name content : i, parse("(")
		gettoken par content : content, parse("(")
		gettoken content par : content, parse(")")
		global `name' `content'
	}


	foreach i of local sepCompact {
		gettoken name content : i, parse("(")
		gettoken par content : content, parse("(")
		gettoken content par : content, parse(")")
		c_local `name' `content'
	}

	c_local poptions "`pOptions'"
	return local aoption "`signleopt' `compopt'"
	return local poptions "`pOptions'"
end




*! asdocdec: Handle decimal points: Attaullah Shah : Feb20, 2018
prog asdocdec
	syntax anything, dec(str)

	cap confirm number `anything'
	if _rc c_local value `anything'
	else {

		if strmatch("`anything'", "*.*") {
			if length("`anything'") > `dec' {
				c_local value : di %9.`dec'f =  `anything'
			}
			else c_local value = `anything'

		}
		else c_local value = `anything'
	}

end



*! asdocmatdec: Handle matrix decimal points: Attaullah Shah : Feb20, 2018
prog asdocmatdec
	syntax anything, dec(str) 
	loc c = colsof(`anything')
	loc r = rowsof(`anything')

	forv C = 1 / `c' {
		forv R = 1 / `r' {
			loc v = `anything'[`R', `C']
			if strmatch("`v'", "*.*") {
				if length("`v'") > `dec' 	loc value : di %19.`dec'f =  `v'
				else loc value = `v'

			}
			else loc value `v'
			mat `anything'[`R', `C'] = `value'
		}
	}
end

*! asdocmatdectzok: matrix equal decimal points: Attaullah Shah
prog asdocmatdectzok


	syntax anything, dec(str) [tzok]


	mata: set_column_formats("`tzok'")
	loc c = colsof(`anything')
	loc r = rowsof(`anything')
	forv C = 1 / `c' {
		if (`C' > 1) mata: st_local("dec", matrixfmt[1,`=`C'+1'])
		forv R = 1 / `r' {
			loc v = `anything'[`R', `C']
			loc value : di %9.`dec'f =  `v'
			mat `anything'[`R', `C'] = `value'
		}
	}

end


*! asdoclist: Write values from list command: Attaullah Shah, 2017
cap prog drop asdoclist
prog asdoclist
	syntax [varlist(ts)] [if] [in], [append  dec(int 3) fs(int 20) save(str) ///
		title(str) align(str) font(str) fhc(str) fhr(str) label ]
	* If time series variables
	fvexpand `varlist'
	loc varlist `r(varlist)'
	loc varnames `varlist'
	if "`r(tsops)'" == "true" {
		loc tsops 1
		tsrevar `varlist'
		loc varlist `r(varlist)'
	}
	if "`align'" == "left" loc justify  \ql
	else loc justify  \qr
	preserve
	if "`if'" != "" | "`in'" != "" qui keep `if' `in'
	loc FS "\fs`fs'"
	loc save "`save'"
	cap	file close fh_out 
	if "`title'"=="" loc title "Table: List of Variables"
	file open fh_out using "`save'" , write `append'
	if "`append'"=="" {
		file write fh_out "{\rtf1\ansi\deff0 {\fonttbl{\f0\fnil `font';}}" _n
		file write fh_out "{\info {\author .}{\company .}{\title .}}" _n
		file write fh_out "\deflang1033\plain`FS'" _n
		file write fh_out "{\footer\pard\qc\plain\f0`FS'\chpgn\par}" _n
		file write fh_out "{" _n
	}
	else mata: delete_closing_lines("`save'") 
	file write fh_out "{\b\qc\line `title' }{\par}" _n

	if "`varlist'" == "" loc varlist *

	loc nvars : word count `varlist'


	loc MaxNumLength = 	cond(`nvars'<4, 1300, ///
		cond(`nvars'<6, 1200, ///
		cond(`nvars'<8, 1100, ///
		cond(`nvars'<10, 1000, 900))))

	loc MaxStrLength = 	cond(`nvars'<4, 4000, ///
		cond(`nvars'<6, 3000, ///
		cond(`nvars'<8, 2500, ///
		cond(`nvars'<10, 2000, 1500))))
	loc i = 1	
	foreach v of varlist `varlist' {
		local varformat : format `v'
		if regexm(`"`varformat'"', "^%-?(t|d)") {
			gen temp_`v' = string(`v', "`varformat'")
			drop `v'
			ren temp_`v' `v'
		}

		local whichformat : type `v'
		if strmatch("`whichformat'", "*str*") {
			qui gen temp_`v' = length(`v')
			qui sum temp_`v'
			loc max =  `r(max)'
			loc f`i' = min(max(`max'*120, 850),`MaxStrLength')
			loc strvars `strvars' `v'
		}
		else  {
			if strmatch("`f'", "*.*") loc f = 555555
			loc f`i' = min(max(length("`f'") * 190, `MaxNumLength'),1800)
		}
		loc `++i'
	}

	file write fh_out "{\trowd\trgaph108\trleft-108" _n 
	loc i = 1
	loc cw = `f`i''
	foreach v of varlist `varlist' {
		loc vari : word `i' of `varnames'
		if "`tsops'" !="" {
		    fvexpand `vari'
		}
		if "`r(tsops)'" == "true" loc variable `r(varlist)'

		else {

			if "`label'" == "" loc variable `v'
			else loc variable  : variable label `v'
			if "`variable'" == "" loc variable `v'
		}
		file write fh_out "\clbrdrt\brdrw10\brdrs \clbrdrb\brdrw25\brdrs \cellx`cw'" _n

		file write fh_out "`FS' \pard\intbl `justify' {`fhc' `variable'}\cell" _n


		//mata: output

		loc `++i'
		cap loc cw = `cw'+`f`i''
		loc lastsize = `cw'
	}
	file write fh_out "\row}" _n
	qui des
	loc N = r(N)
	forv n = 1 / `N' {
		file write fh_out "{\trowd\trgaph108\trleft-108" _n 
		loc i = 1
		loc cw = `f`i''
		foreach v of varlist `varlist' {
			file write fh_out "\cellx`cw'" _n
			loc value =  `v'[`n']
			if !`: list v in local(strvars)' {
				loc justify \qr
				if strmatch("`value'", "*.*") {

					if length("`value'") > `dec' loc value : di %9.`dec'f =  `value'
				}
			}
			else loc justify \ql
			if `i' == 1 file write fh_out "`FS' \pard\intbl `justify' {`fhr' `value'}\cell" _n

			else file write fh_out "`FS' \pard\intbl `justify' {`value'}\cell" _n

			loc `++i'
			cap loc cw = `cw'+`f`i''
			loc lastsize = `cw'
		}
		file write fh_out "\row}" _n
	}

	file write fh_out "" _n 
	file write fh_out "" _n 
	file write fh_out "\writepositionforappend" _n 


	file write fh_out "{\trowd\trgaph108\trleft-108"_n 
	file write fh_out "\clbrdrt\brdrw15\brdrs\cellx`lastsize' \cell" _n
	file write fh_out "\row}}}" _n
	cap	file close fh_out 
end

prog makertf
	syntax, [save(str) title(str) append(str) fs(int 20) font(str) ///
		abb(int 30) dec(int 3) tzok matname(str) cs(int 200) vlines(str) ///
		notes(str) transpose(str) *]

	if "`save'" == "" loc save "Myfile_`transpose'.doc"
	if "`title'" == "" loc title Table : Results
	//cap rm "`save'"
	if "`matname'" == "" loc matname "_stored_results.asd"
	if "`cs'" == "" loc cs 300
	if "`font'" == "" loc font Garamond





	mata: rtf_maker("`save'", "`title'", "`append'", 20, "`font'", ///
		30, "`dec'", "tzok", "`matname'", `cs', "`vlines'", "`notes'")


end
*! asdocor: Write values from correlation command: Version 1: Attaullah Shah : March 3, 2018
program define asdocor, byable(recall)
	version 11
	syntax [varlist(min=2 ts)] [if] [in] [aw fw] ///
		[, Bonferroni Obs Print(real -1) SIDak SIG  ///
		STar(str) LISTwise CASEwise dec(int 3) ///
		save(str) fs(int 20) title(str) REPLACE   ///
		APPEND LABel NONumber cmd(str) font(str) ///
		fhr(str) fhc(str) notes(str) store `tzok' abb(str) * ]
	tempvar touse
	if "`star'" == "" loc star = -1

	loc nvars : word count `varlist'

	if "`sig'" == "" mata: output = J(`nvars' +1  , `nvars' +1 , "")
	else mata: output = J(`nvars' *2 +1  , `nvars' +1 , "")

	mata: set_column_formats("`tzok'")

	mark `touse' `if' `in' 		
	if "`font'" == "" loc font Garamond

	if "`listwise'" != "" | "`casewise'" != "" {
		markout `touse' `varlist'
	} 
	loc FS "\fs`fs'"
	if "`title'"=="" loc title "Matrix of correlations"

	if "`label'" != "" loc frw = 2200
	else loc frw = 1700
	loc cw = `frw'	
	if `dec'== 3 loc CellSize = 740
	else if `dec' == 2 loc CellSize = 640
	else if `dec' == 4 loc CellSize = 840

	if "`star'" != "" {
		if "`star'" == "all" loc CellSize = `CellSize' + 200
		else loc CellSize = `CellSize' + 100
	}
	if `abb' == 22 	loc CellSize = `CellSize' + 80
	loc k = 1
	cap loc cw = `cw' + `CellSize'

	mata{
		k = strtoreal(st_local("k"))
		if (matrixfmt[4,k] == "") 	align = "\ql " 
		else align = matrixfmt[4,k] 

		st_local("align", align)
		font_formating = "{"+ matrixfmt[3,k] 
		st_local("font_formating", font_formating)

	}

	mata: output[1,1] = "Variables"

	foreach b of varlist `varlist' {
		cap confirm numeric variable `b'
		if _rc == 0 {

			if "`nonumber'" == "" {
				mata: output[1, `=1+`k''] = "(`k')"

			}
			else {
				mata: output[1, `=1+`k''] = "(`b')"

			}
		}
		loc `++k'

	}
	tokenize `varlist'
	local i 1
	while "``i''" != "" { 
		capture confirm str var ``i''
		if _rc==0 { 
			di in gr "(``i'' ignored because string variable)"
			local `i' " "
		}
		local i = `i' + 1
	}
	local varlist `*'
	tokenize `varlist'
	local nvar : word count `varlist'
	if `nvar' < 2  error 102 

	local weight "[`weight'`exp']"
	local adj 1
	if "`bonferr'" != "" | "`sidak'" != "" {
		if "`bonferr'" != "" & "`sidak'" != ""  error 198 
		local nrho=(`nvar'*(`nvar'-1))/2
		if "`bonferr'" != ""  local adj `nrho' 
	}
	if "`star'" != "all" {

		if (`star' >= 1) {
			local star = `star'/100
			if `star' >= 1 {
				di in red "star() out of range"
				exit 198
			}
		}
	}
	if (`print'>=1) {
		local print = `print'/100
		if `print'>=1 {
			di in red "print() out of range"
			exit 198
		}
	}
	local j0 1
	while (`j0'<=`nvar') {
		di
		local j1=min(`j0'+100,`nvar')
		local j `j0'
		di in smcl in gr _skip(13) "{c |}" _c
		while (`j'<=`j1') {
			di in gr %9s abbrev("``j''",8) _c
			local j=`j'+1
		}
		local l=9*(`j1'-`j0'+1)
		di in smcl in gr _n "{hline 13}{c +}{hline `l'}"

		local i `j0'
		while `i'<=`nvar' {

			if ("`label'" != "") {
				loc v : variable label ``i''

				if "`v'" == "" loc v ``i''
			}
			else loc v ``i''

			if "`nonumber'" == "" loc vname = abbrev("(`i') `v'", `abb')
			else loc vname = abbrev("`v'", `abb')

			if "`sig'" == ""  mata: output[`=1+`i'', 1] = "`vname'"
			else {
				if `i' == 1 loc row = 2
				else loc row = `row' + 2
				mata: output[`row', 1] = "`vname'"
			}

			di in smcl in gr %12s abbrev("``i''",12) " {c |} " _c

			local j `j0'
			while (`j'<=min(`j1',`i')) {

				cap corr ``i'' ``j'' if `touse' `weight'
				if _rc == 2000 {
					local c`j' = .
				}
				else {
					local c`j' = r(rho)
				}
				local n`j'=r(N)
				if (r(rho) != . & r(rho) < 1) {

					local p`j'= min(2*`adj'*ttail(r(N)-2, abs(r(rho))*sqrt(r(N)-2)/ sqrt(1-r(rho)^2)),1)
				}
				else if (r(rho)>=1 & r(rho) != .) {
					local p`j'=0
				}
				else if r(rho) == . {
					local p`j'= .
				}
				if "`sidak'"!="" {
					local p`j'=min(1,1-(1-`p`j'')^`nrho')
				}
				local j=`j'+1
			}
			local j `j0'

			while (`j'<=min(`j1',`i')) {
				if "`star'" == "all" {

					if  `i'!=`j' { 
						mata: sigstars(`p`j'')

					}
					else local ast " "

				}
				else {

					if `p`j''<=`star' & `i'!=`j' { 
						local ast "*" 
					}
					else local ast " "
				}
				if `p`j''<=`print' | `print'==-1 |`i'==`j' {
					loc value : di %7.`dec'f =`c`j''
					loc value = trim("`value'`ast'")


					if "`sig'" == "" mata: output[`=1+`i'', `=1+`j''] = "`value'"
					else mata: output[`row', `=1+`j''] = "`value'"



					di " " %7.4f `c`j'' "`ast'"  _c
				}
				else 	di _skip(9) _c
				local j=`j'+1
			}
			di

			if "`sig'"!="" {

				di in smcl in gr _skip(13) "{c |}" _c
				local j `j0'
				while (`j'<=min(`j1',`i'-1)) {
					loc value2 : di %7.`dec'f =`p`j''
					loc value2 = trim("`value2'")

					mata: output[`=`row'+1', `=1+`j''] = "(`value2')"


					if `p`j''<=`print' | `print'==-1 {
						di "  " %7.4f `p`j'' _c
					}
					else	di _skip(9) _c
					local j=`j'+1
				}
				di
			}
			if "`obs'"!="" {
				di in smcl in gr _skip(13) "{c |}" _c

				local j `j0'
				while (`j'<=min(`j1',`i')) {
					if `p`j''<=`print' | `print'==-1 |`i'==`j' {
						di "  " %7.0g `n`j'' _c
					}
					else	di _skip(9) _c
					local j=`j'+1
				}
				di
			}
			if "`obs'"!="" | "`sig'"!="" {
				di in smcl in gr _skip(13) "{c |}" 
			}
			local i=`i'+1
		}
		local j0=`j0'+100
	}

	if "`star'" != "-1" {

		if "`star'" != "-1" {
			if "`star'" !="all" {
			}
		}
	}

	if "`star'" != "-1" {
		loc siginfo "\i *** p<0.01, ** p<0.05, * p<0.1"
		if "`notes'" == "" loc notes `siginfo'
		else loc notes `siginfo' \par `notes'
	}
	makertf, notes(`notes') title(`title') save(`save') append(`append') ///
		fs(`fs') font(`font') abb(`abb') `tzok' cs(`cs') notes(`notes')

	//}



end


*! getcmd: Get stata commands: Attaullah Shah
prog getcmd

	loc SUM sum summarize summ summar summari su
	loc REG reg regre regres regress  logit tobit ivreg ivregress ivreg2 gmm  			///
		reg3 ivprobit ivtobit ivpoisson xtivreg xthtaylor 							///
		xtabond2 asreg asregc xtfmb gls xtgls logistic arch arima exlogistic nl cnsreg 	///
		intreg truncreg boxcox fp mfp qreg iqreg sqreg bsqreg eivreg frontier 		///
		xtreg xtregar xtrc xtabond xtdpdsys xtdpd xtintreg xttobit xtgls xtpcse 	///
		xtfrontier mixed  reg3 nlsur vwls rreg areg areg2gen xtlogit melogit 	    ///
		probit ivprobit heckprob heckprobit biprobit xtprobit meprobit cloglog 		///
		xtcloglog mecloglog binreg hetprob hetprobit scobit blogit bprobit glogit 	///
		gprobit ologit oprob opr oprobi oprobit rologit asroprobit xtologit 		///
		xtoprobit mlogit mprobit clogit asclogit asmprobit cloglog slogit 			///
		nlogit poisson expoisson zip tpoisson xtpoisson mepoisson nbreg gnbreg 		///
		zinb tnbreg xtnbreg menbreg glm xtgee meglm teffects etreg etregress 		///
		mecloglog anova heckman heckprob heckprobit arima arch arfima ucm prais 	///
		newey sspace svar vec dfactor mgarch  meologit meqrlogit 			        ///
		meqrpoisson mi mixed stcox stcrreg stcrr streg rocreg rocfit roctab manova  ///
		xtmelogit xtmixed xtqreg ppmlhdfe

	*loc MREG mvreg var	


	loc TTEST ttest
	loc VIF vif
	loc TABSTAT tabstat
	loc COR cor corr corre correl correla correlat correlate spearman
	loc TAB tab tabulate tabu tabul tabula tabulat  
	loc TAB1 tab1 tabulate1
	loc TAB2 tab2 tabulate2 

	loc SUM sum summarize summ summar summari su 
	loc GEN mean total pwmean ci 
	loc PROP proportion ratio ameans
	loc PCORR pcorr
	loc DES des desc descr descri describ describe
	loc OTHER_CUSTOM irf estat
	if `: list 0 in local(REG)' 	c_local command detailedReg
	else if `: list 0 in local(MREG)' 	c_local command multireg
	else if `: list 0 in local(SUM)' 	c_local command sum
	else if `: list 0 in local(COR)' 	c_local command cor
	else if `: list 0 in local(TAB)' 	c_local command tab
	else if `: list 0 in local(TAB1)' 	c_local command tab1
	else if `: list 0 in local(TAB2)' 	c_local command tab2

	else if `: list 0 in local(GEN)' 	c_local command mean
	else if `: list 0 in local(PROP)' 	c_local command proportion
	else if `: list 0 in local(PCORR)' 	c_local command pcorr
	else if `: list 0 in local(DES)' 	c_local command des
	else if `: list 0 in local(OTHER_CUSTOM)' 	c_local command other_custom

	else if "`0'" == "vif" c_local 		command vif
	else if "`0'" == "ttest" c_local 	command ttest
	else if "`0'" == "tabstat" c_local 	command tabstat
	else if "`0'" == "hausman" c_local 	command hausman
	else if "`0'" == "table" c_local 	command table
	else if "`0'" == "pwcorr" c_local 	command pwcorr
	else if "`0'" == "icc" c_local 		command icc
	else if "`0'" == "tetrachoric" 		c_local command tetrachoric 
	else if "`0'" == "list" c_local 	command list 
	else if "`0'" == "wmat" c_local 	command wmat 
	else if "`0'" == "aslist" c_local 	command aslist 
	else if "`0'" == "replay" c_local 	command replay 
	else if "`0'" == "resetfmt" c_local command resetfmt
	else if "`0'" == "setfmt" c_local   command setfmt
	else if "`0'" == "inspect" c_local  command inspect




	else c_local command other

end

prog define asdoc_inspect 
	syntax varlist, [save(str) append(str) notes(str) title(str)  ///
		fs(str) font(str) abb(str) tzok * ]



	qui count if `varlist' != .
	loc nonmissing = `r(N)'

	qui count if `varlist' == .
	loc missing = `r(N)'

	loc all = `nonmissing' + `missing'

	inspect `varlist'

	mata{
		output = J(7, 4, "")

		output[1,2] = "Total"
		output[1,3] = "Integers"
		output[1,4] = "Non-integers"

		row = 1
		col = 1
		negative_nonintegers = strofreal(`r(N_neg)' - `r(N_negint)')
		positive_nonintegers = strofreal(`r(N_pos)' - `r(N_posint)')
		all_integers = strofreal(`r(N_0)' + `r(N_posint)' + `r(N_negint)')
		all_nonintegers = strofreal(`r(N_neg)' - `r(N_negint)' + `r(N_pos)' - `r(N_posint)')

		// Row Negative
		output[row+1,col] = "Negative"
		output[row+2,col] = "Zero"
		output[row+3,col] = "\line Positive"
		output[row+4,col] = " Total"
		output[row+5,col] = "Missing"
		output[row+6,col] = "All"


		col = 2
		output[row+1,col] = "`r(N_neg)'"
		output[row+2,col] = "`r(N_0)'"
		output[row+3,col] = "`r(N_pos)'"
		output[row+4,col] = "`r(N)'"
		output[row+5,col] = "`missing'"
		output[row+6,col] = "`all'"

		col = 3
		output[row+1,col] = "`r(N_negint)'"
		output[row+2,col] = "`r(N_0)'"
		output[row+3,col] = "`r(N_posint)'"
		output[row+4,col] = all_integers

		col = 4
		output[row+1,col] = negative_nonintegers
		output[row+2,col] = "-"
		output[row+3,col] = positive_nonintegers
		output[row+4,col] = all_nonintegers
		//mata: output
	}
	if "`title'" == "" loc title Number of Observations
	makertf, notes(`notes') title(`title') save(`save') append(`append') ///
		fs(`fs') font(`font') abb(`abb') `tzok' cs(`cs') dec(0)




end


*! getifin: Parse if in command : Attaullah Shah - 2017
cap prog drop getifin
prog getifin
	syntax [anything] [=/exp] [if] [in]
	c_local if `if'
	c_local in `in'
	c_local exp `exp'
	c_local varlist `anything'
end

prog get_label_tab
	loc rows  = rowsof(header_row)
	local lbe : value label `1'
	mata: A = J(strtoreal(st_local("rows")),3,"")

	forv i = 1 / `rows' {
		loc v = header_row[`i',1]
		local value_label : label `lbe' `v'
		mata: A[strtoreal(st_local("i")),1]=st_local("value_label")

	}

end

*! getifin2: Parse if in command : Attaullah Shah - 2017
cap prog drop getifin2
prog getifin2
	syntax [anything] [aweight fweight pweight iweight/] [if] [in]



	c_local weights "[`weight'=`exp']"


	c_local if `if'
	c_local in `in'
	c_local exp `exp'
	c_local varlist `anything'
end



*! aseploc: Change words seperator type: Version 1.0 Attaullah Shah 10Jan2018
prog aseploc, rclass
	syntax anything [, Seperator(string)]
	if "`seperator'"=="" loc seperator ","
	loc i = 1
	loc last : word count `anything' 
	foreach m of local anything {
		if `i' == 1 {
			loc accum "`m' `seperator'"
			loc `++i'
		}
		else if `i'~=`last' {
			loc accum "`accum' `m' `seperator'"
			loc `++i'
		}
		else {
			loc accum "`accum' `m'"
			loc `++i'
		}
	}
	return local sep "`accum'"
end

program asdoc_tabulate

	syntax  varlist [if] [in] [fweight aweight iweight] ///
		[, chi2 Exact(str) gamma LRchi2 Taub V cchi2 COlumn ///
		Row CLRchi2 CEll EXPected NOFreq rowsort colsort Missing ///
		Wrap NOkey NOLabel nolog FIRSTonly All matcell(str) matrow(str) matcol(str) * ]

	if "`weight'" != "" loc weights [`weight' `exp']
	local varRow `1' /* points to the variable to be displayed in the row */
	local varCol `2' /* points to the variable to be dipslayed in the column */
	loc number_of_variables : word count `varlist'
	c_local number_of_variables `number_of_variables'

	if `number_of_variables' == 2 loc matcol matcol(header_col)

	tabulate `varlist' `if' `in' `weights', ///
		matcell(`matcell') matrow(`matrow') `matcol'  ///
		`chi2' `exact' `gamma' `lrchi2' `taub' `v' `cchi2' `column' ///
		`clrchi2' `cell' `expected' `nofreq' `rowsort' `colsort' `missing' ///
		`wrap' `nokey' `nolabel' `nolog'  `all' `row'

	c_local Nobs = r(N) 




end



*! aslist: Create unique list of groups: Version 1.0 , Attaullah Shah, attaullah.shah@imsciences.edu.pk, 20Oct2017
prog aslist
	syntax [varlist] [if] [in], [append  dec(int 3) fs(int 20) save(str) title(str) font(str) ]
	if "`font'" == "" loc font Garamond

	preserve
	marksample touse, nov

	bys `varlist' : keep if _n ==_N 
	list `varlist' if `touse'

	asdoclist `varlist' `if' `in' , `append' dec(`dec') fs(`fs') save("`save'") ///
		title("`title'") align(default) font(`font')

	restore
end




*! asdocdes: Write variables and thier lables to files: Version 1.0 , Attaullah Shah, attaullah.shah@imsciences.edu.pk, Feb25, 2018
prog asdocdes

	syntax [varlist], [append  dec(int 3) fs(int 20) save(str) title(str)  Fullnames Numbers ///
		position type isnumeric format vallab font(str)  ]
	if "`font'" == "" loc font Garamond
	preserve

	qui des `varlist', replace `fullnames' `numbers' clear

	list `position' name `type' `isnumeric' `format' `vallab' varlab 
	asdoclist `position' name `type' `isnumeric' `format' `vallab' varlab , ///
		`append' dec(`dec') fs(`fs') save("`save'") title("`title'") align(left) font(`font')
	restore
end



*! Space_remover: replaces spaces with underscore, Aug 1, 2018; Attaullah Shah
prog space_remover
	syntax, text(str)
	gettoken myvalue text : text, parse(",")
	while "`myvalue'" != "" {
		if "`myvalue'" == "," gettoken myvalue text : text, parse(",")
		loc plucked = subinstr("`myvalue'", " ", "_", .)
		loc CELLS `CELLS' `plucked'
		gettoken myvalue text : text, parse(",")
	}
	c_local xspace "`CELLS'"
end

cap prog drop makemat
prog makemat, by(onecall) rclass
	syntax varlist, [ROWsum COLumn SColumn dec(str)]
	preserve
	qui {
		loc nvars : word count `varlist'

		loc var1 : word 1 of `varlist'
		//qui {

		qui use orig2, clear
		save OG, replace
		loc check = 1
		while `check' != 0 {
			cap confirm var __000002
			if _rc {

				ds __000*
				loc tempvars `r(varlist)'

				forv i = 3 / 8 {
					cap confirm var __00000`i'
					if _rc == 0 qui ren __00000`i' __00000`=-1+`i''
				}
			}
			else loc check = 0
		}
		if "`rowsum'`column'`scsum'" != "" {
			qui save sumdata, replace
			DropMis `varlist'

		}
		qui ds __*
		loc stats `r(varlist)'
		loc nstats :  word count `stats'

		global nstats `nstats'

		if `nstats' > 1 {
			loc i = 1
			foreach v of varlist `stats' {
				local w : var label  `v'
				loc w = subinstr("`w'", "(","",.)
				loc w = subinstr("`w'", ")","_",.)
				loc w = subinstr("`w'", " ","",.)
				loc w = subinstr("`w'", "count__000000","Freq.",.)
				loc w = subinstr("`w'", "*p50*","med",.)
				loc accum   `accum' `w'
				loc `++i'
			}

		}

		qui aslev `var1', vl nl sep(,)
		loc v1 "`r(groups)'"
		loc ng1 `r(ng)'
		loc vLabel `r(vLabel)'
		loc var1type `r(vartype)'
		qui des

		loc N = `r(N)'

		if `nvars' == 1 {
			qui ds
			loc all `r(varlist)'
			loc first: word 1 of `all'
			loc other : list all - first
			mkmat `other', mat(st_mat_main)
		}

		else if `nvars' == 2 {

			loc var2 : word 2 of `varlist'

			qui aslev `var2', vl nl sep(,)
			loc v2 "`r(groups)'"
			loc ng2 `r(ng)'
			loc var2type `r(vartype)'
			loc rows = `ng1' * `nstats'
			mat st_mat_main = J(`rows', `ng2', .)


			forv o = 1 / `N' {
				loc r = 0

				foreach  vr of local v1 {
					loc r = `r' + `nstats'
					loc c = 0
					foreach vc of local v2 {
						loc `++c'
						if "`var2type'" == "string" loc vc ""`vc'""
						if "`var1type'" == "string" loc vr ""`vr'""
						if `nstats' == 1 {
							if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' mat st_mat_main[`r',`c']       = __000002[`o']
						}
						else if `nstats' == 2 {
							if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' mat st_mat_main[`=-1+`r'',`c'] = __000002[`o']

							if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' mat st_mat_main[`r',`c']       = __000003[`o']
						}
						else if `nstats' == 3 {
							if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' mat st_mat_main[`=-2+`r'',`c'] = __000002[`o']

							if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' mat st_mat_main[`=-1+`r'',`c'] = __000003[`o']

							if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' mat st_mat_main[`r',`c']       = __000004[`o']

						}

						else if `nstats' == 4 {
							if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' mat st_mat_main[`=-3+`r'',`c'] = __000002[`o']

							if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' mat st_mat_main[`=-2+`r'',`c'] = __000003[`o']

							if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' mat st_mat_main[`=-1+`r'',`c'] = __000004[`o']

							if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' mat st_mat_main[`r',`c']       = __000005[`o']

						}

						else if `nstats' == 5 {
							if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' mat st_mat_main[`=-4+`r'',`c'] = __000002[`o']

							if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' mat st_mat_main[`=-3+`r'',`c'] = __000003[`o']

							if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' mat st_mat_main[`=-2+`r'',`c'] = __000004[`o']

							if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' mat st_mat_main[`=-1+`r'',`c'] = __000005[`o']

							if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' mat st_mat_main[`r',`c']       = __000006[`o']
						}
					}
				}
			}
		}
		else if `nvars' == 3 {
			if "`column'" == "" loc mfactor = 0
			else loc mfactor= 1

			loc var2 : word 2 of `varlist'
			loc var3 : word 3 of `varlist'

			qui aslev `var2', vl nl sep(,)
			loc var3type `r(vartype)'

			loc v2 `r(groups)'
			loc ng2 `r(ng)'

			qui aslev `var3', vl nl sep(,)
			loc v3 `r(groups)'
			loc ng3 `r(ng)'
			loc matcols = (`mfactor'+`ng2') * `ng3'
			loc rows = `ng1' * `nstats'
			mat st_mat_main = J(`rows', `matcols', .)

			forv o = 1 / `N' {
				loc r = 0	
				foreach  vr of local v1 {
					loc r = `r' + `nstats'
					loc col = 0
					foreach vs of local v3 {

						foreach vc of local v2 {				
							loc `++col'
							if `nstats' == 1 {
								if "`var3type'" == "string" loc vs ""`vs'""
								if "`var2type'" == "string" loc vc ""`vc'""
								if "`var1type'" == "string" loc vr ""`vr'""
								if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' & `var3'[`o'] == `vs'  mat st_mat_main[`r',`col']       = __000002[`o']	
							}
							else if `nstats' == 2 {
								if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' & `var3'[`o'] == `vs'  mat st_mat_main[`=-1+`r'',`col'] = __000002[`o']	
								if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' & `var3'[`o'] == `vs'  mat st_mat_main[`r',`col']       = __000003[`o']	
							}

							else if `nstats' == 3 {
								if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' & `var3'[`o'] == `vs'  mat st_mat_main[`=-2+`r'',`col'] = __000002[`o']	
								if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' & `var3'[`o'] == `vs'  mat st_mat_main[`=-1+`r'',`col'] = __000003[`o']	
								if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' & `var3'[`o'] == `vs'  mat st_mat_main[`r',`col']       = __000004[`o']	
							}

							else if `nstats' == 4 {
								if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' & `var3'[`o'] == `vs'  mat st_mat_main[`=-3+`r'',`col'] = __000002[`o']	
								if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' & `var3'[`o'] == `vs'  mat st_mat_main[`=-2+`r'',`col'] = __000003[`o']	
								if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' & `var3'[`o'] == `vs'  mat st_mat_main[`=-1+`r'',`col'] = __000004[`o']	
								if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' & `var3'[`o'] == `vs'  mat st_mat_main[`r',`col']       = __000005[`o']	
							}
							else if `nstats' == 5 {
								if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' & `var3'[`o'] == `vs'  mat st_mat_main[`=-4+`r'',`col'] = __000002[`o']	
								if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' & `var3'[`o'] == `vs'  mat st_mat_main[`=-3+`r'',`col'] = __000003[`o']	
								if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' & `var3'[`o'] == `vs'  mat st_mat_main[`=-2+`r'',`col'] = __000004[`o']	
								if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' & `var3'[`o'] == `vs'  mat st_mat_main[`=-1+`r'',`col'] = __000005[`o']	
								if `var1'[`o'] == `vr' & `var2'[`o'] == `vc' & `var3'[`o'] == `vs'  mat st_mat_main[`r',`col']       = __000006[`o']	
							}
						}

						if "`column'"!= "" loc col = `col' + 1
					}
				}
			}
		}

		if "`column'" != "" {
			if `nvars' == 3 {
				qui	use sumdata, clear

				if "`rowsum'" != "" qui drop if `var2' == . & `var1' == .
				qui keep if `var2' == .
				qui sum __000002
				loc N = `r(N)'

				forv o = 1 / `N' {
					loc r = 0

					foreach  vr of local v1 { // row variable
						loc r = `r' + `nstats'
						loc col = `ng2'+1

						foreach vs of local v3 { // super col variable
							if "`var3type'" == "string" loc vs ""`vs'""
							if "`var1type'" == "string" loc vr ""`vr'""

							if `nstats' == 1 & `var1'[`o'] == `vr' & `var3'[`o'] == `vs'  mat st_mat_main[`r',`col']       = __000002[`o']	

							else if `nstats' == 2{
								if `var1'[`o'] == `vr' & `var3'[`o'] == `vs'  mat st_mat_main[`=-1+`r'',`col'] = __000002[`o']	
								if `var1'[`o'] == `vr' & `var3'[`o'] == `vs'  mat st_mat_main[`r',`col']       = __000003[`o']	

							}
							else if `nstats' == 3{
								if `var1'[`o'] == `vr' & `var3'[`o'] == `vs'  mat st_mat_main[`=-2+`r'',`col'] = __000002[`o']	
								if `var1'[`o'] == `vr' & `var3'[`o'] == `vs'  mat st_mat_main[`=-1+`r'',`col'] = __000003[`o']	
								if `var1'[`o'] == `vr' & `var3'[`o'] == `vs'  mat st_mat_main[`r',`col']       = __000004[`o']	

							}


							else if `nstats' == 4{
								if `var1'[`o'] == `vr' & `var3'[`o'] == `vs'  mat st_mat_main[`=-3+`r'',`col'] = __000002[`o']	
								if `var1'[`o'] == `vr' & `var3'[`o'] == `vs'  mat st_mat_main[`=-2+`r'',`col'] = __000003[`o']	
								if `var1'[`o'] == `vr' & `var3'[`o'] == `vs'  mat st_mat_main[`=-1+`r'',`col'] = __000004[`o']	
								if `var1'[`o'] == `vr' & `var3'[`o'] == `vs'  mat st_mat_main[`r',`col']       = __000005[`o']	

							}

							else if `nstats' == 5{
								if `var1'[`o'] == `vr' & `var3'[`o'] == `vs'  mat st_mat_main[`=-4+`r'',`col'] = __000002[`o']	
								if `var1'[`o'] == `vr' & `var3'[`o'] == `vs'  mat st_mat_main[`=-3+`r'',`col'] = __000003[`o']	
								if `var1'[`o'] == `vr' & `var3'[`o'] == `vs'  mat st_mat_main[`=-2+`r'',`col'] = __000004[`o']	
								if `var1'[`o'] == `vr' & `var3'[`o'] == `vs'  mat st_mat_main[`=-1+`r'',`col'] = __000005[`o']	
								if `var1'[`o'] == `vr' & `var3'[`o'] == `vs'  mat st_mat_main[`r',`col']       = __000006[`o']	
							}
							loc col = `col'+`ng2'+1
						}
					}
				}
			}
			else {
				qui	use sumdata, clear
				if "`column'" != ""  {
					qui drop if `var2' == . & `var1' == .
					AddOnlyColumn `var1' `var2' `var3',  nstats(`nstats')
				}
			}
		}
		if "`column'" == "" & "`rowsum'" != "" {
			qui	use sumdata, clear
			AddOnlyRow `var1' `var2' `var3',  nstats(`nstats')

		}
		if "`column'" != "" & "`rowsum'" != "" {
			qui	use sumdata, clear
			save sum3, replace
			AddBothColRow  `var1' `var2' `var3', nstats(`nstats')

		}

	}

	//qui cap rm  sumdata.dta
	qui cap rm  orig2.dta
	if "`dec'" != "" qui asdocmatdec st_mat_main, dec(`dec')

	if `nstats' > 1 & `nvars' == 1 mat colnames st_mat_main = `accum'
end

progr AddBothColRow
	syntax varlist, nstats(str)
	loc nvars : word count `varlist'
	if `nvars' == 1 loc var1 : word 1 of `varlist'
	else if `nvars' == 2{

		loc var1 : word 1 of `varlist'
		loc var2 : word 2 of `varlist'
	}
	else if `nvars' == 3{

		loc var1 : word 1 of `varlist'
		loc var2 : word 2 of `varlist'
		loc var3 : word 3 of `varlist'
	}
	if `nstats' == 1 {

		drop if `var1' !=. & `var2' == .
		keep if `var1' ==.
		sort `var3' `var2'
		mkmat __000002, mat(rowmat)
		mat st_mat_main = st_mat_main \ rowmat'
	}

	if `nstats' == 2 {

		drop if `var1' !=. & `var2' == .
		keep if `var1' ==.
		sort `var3' `var2'
		mkmat __000002, mat(rowmat1)
		mkmat __000003, mat(rowmat2)
		mat st_mat_main = st_mat_main \ rowmat1'
		mat st_mat_main = st_mat_main \ rowmat2'
	}

	else if `nstats' == 3 {
		drop if `var1' !=. & `var2' == .
		keep if `var1' ==.
		sort `var3' `var2'
		mkmat __000002, mat(rowmat1)
		mkmat __000003, mat(rowmat2)
		mkmat __000004, mat(rowmat3)
		mat st_mat_main = st_mat_main \ rowmat1'
		mat st_mat_main = st_mat_main \ rowmat2'
		mat st_mat_main = st_mat_main \ rowmat3'
	}

	else if `nstats' == 4 {
		drop if `var1' !=. & `var2' == .
		keep if `var1' ==.
		sort `var3' `var2'
		mkmat __000002, mat(rowmat1)
		mkmat __000003, mat(rowmat2)
		mkmat __000004, mat(rowmat3)
		mkmat __000005, mat(rowmat4)
		mat st_mat_main = st_mat_main \ rowmat1'
		mat st_mat_main = st_mat_main \ rowmat2'
		mat st_mat_main = st_mat_main \ rowmat3'
		mat st_mat_main = st_mat_main \ rowmat4'
	}

	else if `nstats' == 5 {
		drop if `var1' !=. & `var2' == .
		keep if `var1' ==.
		sort `var3' `var2'
		mkmat __000002, mat(rowmat1)
		mkmat __000003, mat(rowmat2)
		mkmat __000004, mat(rowmat3)
		mkmat __000005, mat(rowmat4)
		mkmat __000006, mat(rowmat5)
		mat st_mat_main = st_mat_main \ rowmat1'
		mat st_mat_main = st_mat_main \ rowmat2'
		mat st_mat_main = st_mat_main \ rowmat3'
		mat st_mat_main = st_mat_main \ rowmat4'
		mat st_mat_main = st_mat_main \ rowmat5'
	}






end

progr AddOnlyRow
	syntax varlist, nstats(str)
	loc nvars : word count `varlist'
	if `nvars' == 1 loc var1 : word 1 of `varlist'

	else if `nvars' == 2{
		loc var1 : word 1 of `varlist'
		loc var2 : word 2 of `varlist'
	}

	else if `nvars' == 3{
		loc var1 : word 1 of `varlist'
		loc var2 : word 2 of `varlist'
		loc var3 : word 3 of `varlist'
	}

	if `nstats' == 1 {
		keep if `var1' == .
		drop if `var2' == .
		mkmat __000002, mat(rowmat)
		mat st_mat_main = st_mat_main \ rowmat'
	}

	else if `nstats' == 2 {
		keep if `var1' == .
		drop if `var2' == .
		mkmat __000002, mat(rowmat1)
		mkmat __000003, mat(rowmat2)
		mat st_mat_main = st_mat_main \ rowmat1'
		mat st_mat_main = st_mat_main \ rowmat2'
	}

	else if `nstats' == 3 {
		keep if `var1' == .
		drop if `var2' == .
		mkmat __000002, mat(rowmat1)
		mkmat __000003, mat(rowmat2)
		mkmat __000004, mat(rowmat3)
		mat st_mat_main = st_mat_main \ rowmat1'
		mat st_mat_main = st_mat_main \ rowmat2'
		mat st_mat_main = st_mat_main \ rowmat3'
	}

	else if `nstats' == 4 {
		keep if `var1' == .
		drop if `var2' == .
		mkmat __000002, mat(rowmat1)
		mkmat __000003, mat(rowmat2)
		mkmat __000004, mat(rowmat3)
		mkmat __000005, mat(rowmat4)
		mat st_mat_main = st_mat_main \ rowmat1'
		mat st_mat_main = st_mat_main \ rowmat2'
		mat st_mat_main = st_mat_main \ rowmat3'
		mat st_mat_main = st_mat_main \ rowmat4'
	}

	else if `nstats' == 5 {
		keep if `var1' == .
		drop if `var2' == .
		mkmat __000002, mat(rowmat1)
		mkmat __000003, mat(rowmat2)
		mkmat __000004, mat(rowmat3)
		mkmat __000005, mat(rowmat4)
		mkmat __000006, mat(rowmat5)
		mat st_mat_main = st_mat_main \ rowmat1'
		mat st_mat_main = st_mat_main \ rowmat2'
		mat st_mat_main = st_mat_main \ rowmat3'
		mat st_mat_main = st_mat_main \ rowmat4'
		mat st_mat_main = st_mat_main \ rowmat5'
	}

end

progr AddOnlyColumn

	syntax varlist, nstats(str)
	loc nvars : word count `varlist'
	if `nvars' == 1 loc var1 : word 1 of `varlist'

	else if `nvars' == 2{
		loc var1 : word 1 of `varlist'
		loc var2 : word 2 of `varlist'
	}

	else if `nvars' == 3{
		loc var1 : word 1 of `varlist'
		loc var2 : word 2 of `varlist'
		loc var3 : word 3 of `varlist'
	}


	qui keep if `var2' == .
	if `nstats' == 1 {
		qui keep __000002
		mkmat __000002 , mat(sc)
	}

	else if `nstats' == 2 {
		qui sum `var1'
		loc N = `r(N)'

		forv o = 1/ `N'{
			if `o' == 1 mat sc = __000002[`o'] \ __000003[`o']
			else mat sc =   sc \ __000002[`o'] \ __000003[`o']
		}
	}
	else if `nstats'==3 {
		qui sum `var1'
		loc N = `r(N)'
		forv o = 1/ `N'{
			if `o' == 1 mat sc = __000002[`o'] \ __000003[`o']\ __000004[`o']
			else mat sc =   sc \ __000002[`o'] \ __000003[`o']\ __000004[`o']
		}
	}
	else if `nstats'==4 {
		qui keep if `var2' == .
		qui sum `var1'
		loc N = `r(N)'

		forv o = 1/ `N'{
			if `o' == 1 mat sc = __000002[`o'] \ __000003[`o']\ __000004[`o']\ __000005[`o']
			else mat sc =   sc \ __000002[`o'] \ __000003[`o']\ __000004[`o']\ __000005[`o']
		}
	}
	else if `nstats'==5 {
		qui keep if `var2' == .
		qui sum `var1'
		loc N = `r(N)'

		forv o = 1/ `N'{
			if `o' == 1 mat sc = __000002[`o'] \ __000003[`o']\ __000004[`o']\ __000005[`o']\ __000006[`o']
			else mat sc =   sc \ __000002[`o'] \ __000003[`o']\ __000004[`o']\ __000005[`o']\ __000006[`o']
		}
	}
	mat st_mat_main = st_mat_main , sc
end


* Adopted from table
program define tablex, byable(recall)
	syntax varlist(max=3) [if] [in] [fw aw pw iw] [, /* 
		*/ BY(varlist) COLumn CW Format(string) Name(string) REPLACE /*
	*/ ROW SColumn markdown Contents(string) CELLwidth(string) dec(str) *]

	// Removing option Scolumn for now, shall work on it if someone is interested enough
	loc scolumn

	local sctotal "`scolumn'"
	local coltota "`column'"
	local rowtota "`row'"

	if "`replace'"!="" & _by()==1 { 
		di in red "option replace may not be combined with by"
		exit 190
	}

	local stats "`contents'"
	local contents
	if "`by'" != "" {
		local byopt "by(`by')"
	}

	if "`cellwidth'" =="" {
		/* set cellw to width implied by format() option if it is
		   greater than 9.  Set cellw to 0 otherwise. */
		GetFormatWidth "`format'"
		if `s(formatwidth)' > 9 {
			local cellw `s(formatwidth)'
			local cellwidth `cellw'
		}
		else {
			local cellw 0
		}
	}
	else local cellw  `cellwidth' 
	local msg  1 

	tokenize `varlist'
	local row "`1'"
	local col "`2'"
	local sc  "`3'"

	if "`coltota'"!="" & "`col'"=="" { 
		local coltota 
	}
	if "`sctotal'"!="" & "`sc'"=="" {
		local sctotal 
	}

	tempname one touse

	if "`stats'"=="" {
		local stats "freq"
	}


	if "`replace'"!="" & "`name'"=="" {
		local name "table"
	}
	local i 0
	get_stats_in_order  `stats'
	tokenize `"`stats'"'
	while "`1'" != "" { 
		local i = `i' + 1
		if "`replace'"!="" {
			tempname `name'`i'	
			local res `"``name'`i''"'
		}
		else	tempvar res
		Parse "`weight'" `"`format'"' `res' `one' `*'
		if "`replace'"!="" {
			local s3`i' = $S_3
		}

		local clist "`clist' $S_1"
		local cell  "`cell' `res'"
		local vlist "`vlist' $S_2"
		local flist "`flist' $S_4"
		mac shift $S_3
	}








	if `i'>5 /* limit from tabdisp */ {
		di in red "too many stats()"
		exit 103
	}
	/* take care of cell length */
	if `i' <= 4 {
		local flag 1
	}
	else local flag 0 

	confirm new var `res'			/* in case replace	*/

	quietly { 
		if "`weight'" != "" {
			tempvar wvar
			gen double `wvar' `exp'
			local wgt "[`weight'=`wvar']"
		}
		mark `touse' `wgt' `if' `in'
		count if `touse'
		if r(N)==0 { 
			noisily error 2000
		}
		preserve
		keep if `touse'
		drop `touse'
		DropMis `varlist' `by'
		if _N==0 { 
			noisily error 2000
		}
		gen byte `one' = 1 

		keep `varlist' `by' `vlist' `wvar'
		if "`rowtota'"=="" & "`coltota'"=="" & "`sctotal'"=="" {


			capture collapse `clist' `wgt', ///
				by(`varlist' `by') fast `cw'
			qui save orig2, replace

			if (_rc == 111) {
				di as err ///
					"rowvar variable(s) may not be used in contents()"
				exit _rc 
			}
			if (_rc == 135) {
				local sd_in = cond(strpos("`clist'","sd")==0,"0","sd")
				local se_in = cond(strpos("`clist'","sem")==0,"0","semean")
				local seb_in = cond(strpos("`clist'","seb")==0 /*
				*/,"0","sebinomial")
				local sep_in = cond(strpos("`clist'","sep")==0 /*
				*/,"0","sepoisson")

				GetError `weight' `sd_in' `se_in' `seb_in' `sep_in'
				di as err "`s(error)'"
				exit _rc
			}  	
		}
		else {
			tempfile res orig
			save "`orig'"
			capture collapse `clist' `wgt', ///
				by(`varlist' `by') fast `cw'

			qui save orig2, replace

			if (_rc == 111) {
				di as err ///
					"rowvar variable(s) may not be used in contents()"
				exit _rc 
			}
			if (_rc == 135) {
				local sd_in = cond(strpos("`clist'","sd")==0,"0","sd")
				local se_in = cond(strpos("`clist'","sem")==0,"0","semean")
				local seb_in = cond(strpos("`clist'","seb")==0 /*
				*/,"0","sebinomial")
				local sep_in = cond(strpos("`clist'","sep")==0 /*
				*/,"0","sepoisson")

				GetError `weight' `sd_in' `se_in' `seb_in' `sep_in'
				di as err "`s(error)'"
				exit _rc
			}
			save "`res'"
			if "`rowtota'" != "" {
				AddRes "`res'" "`orig'" "`clist'" /*
				*/ "`col' `sc' `by'" "`cw'" "`wgt'"
			}
			if "`coltota'"!= "" {
				AddRes "`res'" "`orig'" "`clist'" /*
				*/ "`row' `sc' `by'" "`cw'" "`wgt'"


				if "`rowtota'" != "" {
					AddRes "`res'" "`orig'" "`clist'" /*
					*/ "`sc' `by'" "`cw'" "`wgt'"
				}
			}
			if "`sctotal'"!="" {
				AddRes "`res'" "`orig'" "`clist'" /*
				*/ "`row' `col' `by'" "`cw'" "`wgt'"
				if "`rowtota'" != "" {
					AddRes "`res'" "`orig'" "`clist'" /*
					*/ "`col' `by'" "`cw'" "`wgt'"
				}
				if "`coltota'" != "" {
					AddRes "`res'" "`orig'" "`clist'" /*
					*/ "`row' `by'" "`cw'" "`wgt'"
				}
				if "`rowtota'" != "" & "`coltota'"!="" {
					AddRes "`res'" "`orig'" "`clist'" /*
					*/ "`by'" "`cw'" "`wgt'"
				}
			}
		}
	}

	qui save orig2, replace

	tokenize `"`flist'"'
	while "`1'" != "" { 
		capture format `1' `2'
		if _rc {
			di as err "invalid format `2'"
			exit 198
		}
		mac shift 2
	}

	if "`c'"=="" | "`replace'"!="" {
		FixLabs "(count) `one'" `cellw' `flag' `msg' `cell'
	}
	if "`replace'"!="" {
		mac drop S_FN S_FNDATE
		restore, not
	}
	loc options = subinstr("`options'", "row", "", .)

	if "`cellwidth'" == "" {
		tabdisp `varlist', cell(`cell') `byopt' totals `options' `markdown' missing
	}
	else {
		local options "cellwidth(`cellwidth') `options'"
		tabdisp `varlist', cell(`cell') `byopt' totals `options' `markdown' missing
	}
	if "`replace'" != "" {
		tokenize `"`stats'"'
		local i = 0
		while "`1'" != "" {

			local i = `i' + 1

			mac shift `s3`i''
		}
	}
	if "`dec'" != "" loc dec dec(`dec')
	makemat `varlist', `rowtota' `coltota' `sctotal'  `dec'


end

program get_stats_in_order

	while `"`0'"' != "" {
		gettoken stat 0 : 0
		loc TBL_STATS `TBL_STATS' `stat' 
		gettoken variable 0 : 0

	}
	global TBL_STATS `TBL_STATS'



end

program define AddRes /* resfn origfn clist by cw wgt */
	args res orig clist by cw wgt 

	use "`orig'", clear
	local n : word count `by'
	if `n' {
		collapse `clist' `wgt', by(`by') fast `cw'
	}
	else	collapse `clist' `wgt', fast `cw'

	append using "`res'"
	save "`res'", replace

end

program define Parse /* "weighttype" fmt newvar onevar stuff */
	args weight fmt res one 
	mac shift 4
	if "`1'"=="freq" {
		global S_1 "(count) `res'=`one'"
		global S_2 "`one'"
		global S_3 1
		if ("`weight'"=="aweight" | "`weight'"=="iweight" /*
		*/ | "`weight'"=="pweight" | "`weight'"=="fweight") /*
		*/ & `"`fmt'"'!=""  {
			global S_4 "`res' `fmt'"
		}
		else if `"`fmt'"' != "" {

			global S_4 "`res' `fmt'"
		}
		else	global S_4 "`res' %9.0gc"
		exit
	}

	if "`2'"=="" { 
		di in red "`1' invalid or requires argument"
		exit 198 
	}

	/* synonyms	*/
	if lower("`1'")=="n" {
		local 1 "count"
	}
	else if substr("median",1,max(3,length("`1'")))=="`1'" {
		local 1 "median"
	}
	else if substr("mean",1,length("`1'"))=="`1'" {
		local 1 "mean"
	}


	unabbrev `2', max(1)
	local vn "`s(varlist)'"

	confirm numeric variable `vn'

	Valid `1' `vn' `"`fmt'"' `weight'
	global S_4 "`res' $S_1"
	global S_1 "(`1') `res'=`vn'"
	global S_2 "`vn'"
	global S_3 2
end

program define Valid /* word fromvar dfltfmt weighttype */
	args w v f weight

	local len : length local w
	if substr("semean", 1, max(3,`len')) == "`w'" {
		local w "sem"
	}
	if substr("sebinomial", 1, max(3,`len')) == "`w'" {
		local w "seb"
	}
	if substr("sepoisson", 1, max(3,`len')) == "`w'" {
		local w "sep"
	}

	if "`w'"=="sd" | "`w'"=="sem" | "`w'"=="sep" | /*
	*/ "`w'"=="seb" | "`w'"=="iqr" | "`w'"=="sum" | "`w'"=="rawsum" {
		/* meaning default format */
		global S_1 = cond(`"`f'"'=="", "%9.0g", `"`f'"')
		exit 
	}

	if "`w'"=="count" {
		if ("`weight'"=="aweight" | "`weight'"=="iweight" /*
		*/ | "`weight'"=="pweight") & `"`f'"'!=""  {
			global S_1 `"`f'"'
		}
		else 	global S_1 "%9.0gc"	/* meaning as-is format */
		exit
	}

	/*
		   remaining have default format or 
		   variable's date format
	*/
	local fmt : format `v'
	if substr("`fmt'",2,1)=="-" { 
		local fmt = "%" + substr("`fmt'",3,.)
	}

	if substr("`fmt'",1,2)=="%d" | substr("`fmt'",1,2)=="%t" {
		global S_1 "`fmt'"
	}
	else	global S_1 = cond("`f'"=="", "`fmt'", "`f'")


	if "`w'"=="mean" | "`w'"=="median" { 
		exit 
	}
	if "`1'"=="max" | "`1'"=="min" {
		exit 
	}

	if substr("`1'",1,1)=="p" {
		local n = substr("`1'",2,.)
		capture confirm integer number `n'
		if _rc==0 { 
			if `n'>0 & `n'<100 { 
				exit
			}
		}
	}
	di in red "`1' invalid"
	exit 198
end

program define DropMis /* varnames */
	while "`1'" != "" {
		local t : type `1'
		if substr("`t'",1,3)=="str" { 
			drop if `1'=="" 
		}
		else	drop if `1'==.
		mac shift 
	}
end

program define FixLabs /* lab varnames */
	args true cellw flag msg
	mac shift 4
	while "`1'" != "" {
		local lab : variable label `1'
		if "`lab'"=="`true'" {
			label var `1' "Freq."
		}
		else {
			FixLab2 `cellw' `flag' `msg' `1' `lab'
			local msg `s(tmp)'
		}
		mac shift
	}
end

program define FixLab2, sclass /* label */
	args cellw flag msg var wrd
	mac shift 5 
	sreturn clear
	if "`wrd'"=="(count)" {
		if `cellw' == 0 {
			local len = cond(`flag'==1, 8, 9)
		}
		else	local len = `cellw'-3
		FixLab3 `var' N "`*'" `len' `msg'
		/* sreturn local tmp = `s(tmp)' */
		exit
	}
	if "`wrd'" == "(p" {
		local wrd "`1'"
		mac shift 
		if "`wrd'"=="50)" {
			local wrd "med"
			if `cellw' == 0 {
				local len = cond(`flag'==0, 7, 8)
			}
			else	local len = `cellw' - 5
		}
		else {
			local wrd = substr("`wrd'",1,length("`wrd'")-1)
			if `cellw' == 0 {
				local len = cond(`flag'==0,9-length("`wrd'"),8)
			}
			else 	local len = `cellw' - length("`wrd'") - 3
			local wrd p`wrd'
		}
		FixLab3 `var' `wrd' "`*'" `len' `msg'
		/* sreturn local tmp = `s(tmp)' */
		exit
	}
	if "`wrd'"=="(sepoisson)" | "`wrd'"=="(sebinomial)" | "`wrd'"=="(semean)" {
		local wrd = substr("`wrd'",2,3)
		if `cellw' == 0 {
			local len = cond(`flag'==0, 7, 8)
		}
		else    local len = `cellw' - 5
		FixLab3 `var' `wrd' "`*'" `len' `msg'
		/* sreturn local tmp = `s(tmp)' */
		exit
	}

	if substr("`wrd'",1,1)=="(" & substr("`wrd'",-1,1)==")" {
		local wrd = substr("`wrd'",2,length("`wrd'")-2)
		if `cellw' == 0 {
			local len=cond(`flag'==0,10-length("`wrd'"),8)
		}
		else 	local len = `cellw'-length("`wrd'")-2
		FixLab3 `var' `wrd' "`*'" `len' `msg'
		/* sreturn local tmp=`s(tmp)' */
		exit
	}
end

program define FixLab3, sclass
	args vn fcn name len msg
	local len = `len'
	if `len' < 0 {
		local nam = ""
		local fcn = ""
		di _n in gr /* 
		*/ "note: cellwidth too small, cannot display column heading;"
		di in gr /*
		*/ "to increase cellwidth, specify cellwidth(#)"
		local msg 0
		label var `vn' " "
	}
	else if `len' == 0 {
		di _n in gr /* 
		*/ "note: cellwidth too small, cannot display variable name;"
		di in gr /*
		*/ "to increase cellwidth, specify cellwidth(#)"
		local msg 0
		label var `vn' "`fcn'()"
	}
	else if `len' < 5 {
		local nam = udsubstr("`name'", 1, `len')
		if `msg' & "`nam'"!="" & "`nam'"!="`name'" {
			di _n in gr /* 
			*/ "note: cellwidth too small, variable name truncated;"
			di in gr /*
			*/ "      to increase cellwidth, specify cellwidth(#)"
			local msg 0
		}
		label var `vn' "`fcn'(`nam')"	
	}
	else {
		local nam = abbrev("`name'", `len')
		label var `vn' "`fcn'(`nam')"
	}
	sret local tmp `msg'
end

program define GetFormatWidth, sclass
	args fmt

	if "`fmt'" == "" | substr("`fmt'",1,1)!="%" {

		sret local formatwidth 0
	}
	else {
		local fmt = substr("`fmt'",2,.)  /* remove the % */
		if substr("`fmt'",1,1)=="-" {
			local fmt = substr("`fmt'",2,.)  /* remove the - */
		}
		if substr("`fmt'",1,1)=="d" | substr("`fmt'",1,1)=="t" {
			sret local formatwidth 0
		}
		else if index("`fmt'","s") { /* string format */
			sret local formatwidth = /*
			*/ substr("`fmt'",1,length("`fmt'")-1)
		}
		else if index("`fmt'",".") { /* numeric format */
			sret local formatwidth = /*
			*/ substr("`fmt'",1,index("`fmt'",".")-1)
		}
		else if index("`fmt'",",") { /* european numeric format */
			sret local formatwidth = /*
			*/ substr("`fmt'",1,index("`fmt'",",")-1)
		}
		else { /* bad format -- default to 0 (unknown) */
			sret local formatwidth 0
		}
	}
end

// Encode numeric variables without following alphabatical order
prog asencode
	syntax varlist [if] [in], GEN(str)
	marksample touse
	qui aslev `varlist' if `touse'
	loc ng = `r(ng)'
	loc levels `r(groups)'
	cap qui label drop `gen'

	forv i = 1 / `ng' {

		loc itemi : word `i' of `levels'

		label define `gen' `i' "`itemi'", modify 
	}
	tempvar strby
	qui tostring `varlist', gen(`strby')
	replace `strby' = "" if `touse' == 0
	qui encode `strby', gen(`gen') label(`gen') noextend
end

program define GetError, sclass
	args wgt sd_in se_in seb_in sep_in
	local s_list "`sd_in' `se_in' `seb_in' `sep_in'"

	if "`wgt'"=="iweight" {
		local s_list = subinstr("`s_list'","sd","",1)
	}
	if "`wgt'"=="aweight" {
		local s_list = subinstr("`s_list'","sd","",1)
		local s_list = subinstr("`s_list'","semean","",1)
	}

	local s_list = subinstr("`s_list'","0","",.)
	local count: word count `s_list'
	local error ""
	local i=0

	foreach opt of local s_list {
		local ++i
		if `i' < `count'-1{
			local error "`error'`opt', "
		}
		else if `i'==`count'-1 {
			local error "`error'`opt' and "
		}
		else if `i'==`count' {
			local error "`error'`opt' not allowed with `wgt's"
		}
	}
	sret local error "`error'"
end
