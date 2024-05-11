*! version 1.0  27may2014  Joseph Canner
/*
renvarlab: Renames variables, with option of using variable labels to create new variable names
Usage: renvars varlist [, transformation options]
Author: 
    Joseph Canner
    Johns Hopkins University School of Medicine
    Department of Surgery
    Center for Surgical Trials and Outcomes Research
	jcanner1@jhmi.edu
Acknoweldgements: Adapted from -renvars- (SSC) by Nicholas J. Cox and Jeroen Weesie
Version 1.0 May 27, 2014
*/

program renvarlab
 	version 8 

	// "/" is allowed, but not documented
 	gettoken oldvars 0 : 0 , parse("\/,")
 	if `"`oldvars'"' == "\" | `"`oldvars'"' == "/" | `"`oldvars'"' == "," {
 		local 0 `"`oldvars' `0'"'
 		local oldvars "_all"
 	}
 	unab oldvars : `oldvars'
 	local nold : word count `oldvars'
 	tokenize `oldvars'

 	gettoken punct 0 : 0, parse("\/,")

 	if `"`punct'"' != "\" & `"`punct'"' != "/" & `"`punct'"' != "," {
 		di as err "illegal syntax: "  ///
			`""\ varlist" or transformation option expected"'
 		exit 198
 	}

 	if `"`punct'"' == "\" | `"`punct'"' == "/" {  /* one-to-one mapping */

 		syntax newvarlist [, Display TEST ]
 		local nnew : word count `varlist'
 		if `nold' != `nnew' {
 			di as err ///
				"lists of old and new varnames unequal in length"
 			exit 198
 		}
 		local newvars `varlist'
 	}

 	else if `"`punct'"' == "," {                  /* transformation */

 		local 0 ", `0'"
 		syntax , [ Upper Lower PREFix(str) POSTFix(str)      ///
 		SUFFix(str) PRESub(str) POSTSub(str) SUBst(str)      /// 
 		PREDrop(str) POSTDrop(str) Trim(str) TRIMEnd(str)    ///
 		Map(str asis) SYmbol(str) Display TEST LABel ]

		if `"`symbol'"' == "" local symbol "@"
		
		if `"`map'"' != "" & !index(`"`map'"',`"`symbol'"') {
			di as err `"map() does not contain `symbol'"'
			exit 198
		}

		// suffix is a synonym for postfix; issuing both
		// is not an error, so long as they agree
		if `"`suffix'"' != "" {
			if `"`postfix'"' != "" & `"`postfix'"' != `"`suffix'"' {
				di as err "postfix() and suffix() differ"
				exit 198
			}
			local postfix `"`suffix'"'
			local suffix
		}

 		local nopt : word count `upper' `lower' `prefix' `postfix' `suffix' `predrop' `postdrop' `trim' `trimend'
		local nopt = `nopt' + (`"`map'"' != "") + (`"`presub'"' != "") 	+ (`"`postsub'"' != "") + (`"`subst'"' != "")
 		if (`nopt' != 1) & !(`nopt'==0 & "`label'"!="") {
 			di as err "exactly one transformation option should be specified"
 			exit 198
 		}

 		if `"`subst'"' != "" {
 			local srch : word 1 of `subst'
 			local repl : word 2 of `subst'
 		}
 		if `"`presub'"' != "" {
 			local srch : word 1 of `presub'
 			local repl : word 2 of `presub'
 			local nsrch = length(`"`srch'"')
 		}
 		if `"`postsub'"' != "" {
 			local srch : word 1 of `postsub'
 			local repl : word 2 of `postsub'
 			local nsrch = length(`"`srch'"')
 		}

 		// varlist is already tokenized
		local i 1
		local oldvars
		local newvars
 		while "``i''" != "" {
		    local oldname="``i''"
		    if "`label'" != "" {
			   local source : var label ``i''
			   // If there are no other transformation options, make the variable out of the label
			   if `nopt'==0 {
				 local newname = strtoname("`source'")
			   }
			}
			else {
			   local source = "``i''"
			}
 			if "`upper'" != "" {
				local newname = upper("`source'")
			}	
 			else if "`lower'" != "" {
				local newname = lower("`source'")
			}	
 			else if `"`prefix'"' != "" {
				local newname `"`prefix'`source'"'
			}	
 			else if `"`postfix'"'  != "" {
				local newname `"`source'`postfix'"'
			}	
 			else if `"`subst'"' != "" {
 				local newname : ///
 					subinstr local source `"`srch'"' `"`repl'"', all
 			}
 			else if `"`presub'"' != "" {
 				if "`srch'" == substr("`source'",1,`nsrch') {
					local newname = /// 
 						`"`repl'"' + substr("`source'", `nsrch' + 1, .)
 				}
 				else local newname `source'
 			}
 			else if `"`postsub'"' != "" {
 				if `"`srch'"' == substr("`source'",-`nsrch',.) {
 					local newname = ///
						substr("`source'",1,length("`source'")-`nsrch') + `"`repl'"'
				}
 				else local newname `source'
 			}
 			else if `"`predrop'"' != "" {
 				confirm integer number `predrop'
 				local newname = substr("`source'", 1 + `predrop', .)
 			}
 			else if `"`postdrop'"' != "" {
 				confirm integer number `postdrop'
 				local newname = /// 
					substr("`source'", 1, length("`source'") - `postdrop')
 			}
 			else if `"`trim'"' != "" {
 				confirm integer number `trim'
 				local newname = substr("`source'", 1, `trim')
 			}
 			else if `"`trimend'"' != "" {
 				confirm integer number `trimend'
				if `trimend' <= length("`source'") { 
	 				local newname = substr("`source'", -`trimend', .)
				}
				else local newname "`source'" 
 			}
 			else if `"`map'"' != "" {
			    // Build map expression
				local mapexp : ///
					subinstr local map "`symbol'" "`source'", all
				// Evaluate expression and test validity
				capture local newname = `mapexp'
				if _rc {
					di as err "Error in map"
					exit _rc
				}
			}
			// Check to make sure the result is a valid variable name
			capture confirm name `newname'
			if _rc {
				di as err "Resulting variable name (`newname') is invalid"
				exit _rc
			}
			// Check to make sure the new name is either the same as the old name or represents a new unique name
			capture confirm new var `newname'
			if _rc & "`newname'"!="`oldname'" {
				di as err "Variable name (`newname') already exists."
				exit _rc
			}
			
			if "``i''" != "`newname'" {
				local oldvars `oldvars' ``i''
				local newvars `newvars' `newname'
			}
 			local ++i 
 		}

		// One last check to make sure new list consists of all new names
		if `"`newvars'"' != "" {
			confirm new var `newvars'
			tokenize `oldvars'
		}
		else {
			di as txt "No renames necessary: all new names match old names"
			exit 0
		}
 	} /* end of syntax processing for transformation */

	if "`test'" == "" {
		nobreak {
			local nold : word count `oldvars'
	 		forv i = 1 / `nold' {
 				local newname : word `i' of `newvars'
 				if "`display'" != "" {
 					di as txt "  {ralign 32:``i''} -> `newname'"
	 			}
	 			rename ``i'' `newname'
			}
		}
	}
	else {
		di as txt ///
			"specification would result in the following renames:"
		local nold : word count `oldvars'
		forv i = 1 / `nold' {
 			local newname : word `i' of `newvars'
 			di as txt "  {ralign 32:``i''} -> `newname'"
		}
	}
end
exit
