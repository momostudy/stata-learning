*! version 2.1.6  12aug2013

program define kountry, sortpreserve
	version 8.2
	syntax varname(max=1), from(passthru) [Marker geo(passthru) to(passthru) STuck]
	
	set more off
	
	// from() options: 
     // if to()  specified: capc, cowc, cown, iso2c, iso3c, iso3n, imfn, mcc, marc, penn, unc
	   // if to() ~specified: other
   
   // geo() options: cow, marc, men, menb, sov, un, undet
   
   // `from'         =     "from(xxx)"
   // `to'           =     "to(yyy)"
   // `fromdata'     =     "xxx"
   // `todata'       =     "yyy"
   // `FROM'         =     "_XXX_"
   // `TO'           =     "_YYY_"
   // `geo'          =     "geo(zzz)"
   // `GEO'          =     "zzz"

	// save what was typed inside from()
	tokenize `from', parse("()")
	macro shift
	macro shift
	local fromdata `1'
	
	// save what was typed inside to()
	if "`to'" != "" {
	   tokenize `to', parse("()")
	   macro shift
	   macro shift
   	 local todata `1'
   }
   
   // save what was typed inside geo()
	if "`geo'" != "" {
		tokenize `geo', parse("()")
   	macro shift
   	macro shift
   	local GEO `1'
   }
   
   // user enters "from(xxx)" but in kountry.dta data xxx is named _XXX_
   local FROM2 `fromdata'
   local FROM1 = upper("`FROM2'")
   local FROM = "_`FROM1'_"
   
   // user enters "to(yyy)" but in kountry.dta data yyy is named _YYY_
   local TO2 `todata'
   local TO1 = upper("`TO2'")
   local TO = "_`TO1'_"

// make sure NAMES_STD is not already defined
capture confirm variable NAMES_STD
if !_rc {
   if "`to'" != "" {
      di
      di in red "{hline 66}"
      di in white "kountry" in red " uses " in white "NAMES_STD " in red "internally. You must rename or drop" 
      di in red "the current " in white "NAMES_STD " in red "variable in order to run this command."
	   di in red "{hline 66}"
	   exit 110
   }
   else {
	   di 
	   di in red "{hline 64}"
	   di in white "NAMES_STD " in red "already exists."
	   di in red "Rename or drop the current " in white "NAMES_STD " in red "and re-run the command."
	   di in red "{hline 64}"
	   exit 110
   }
}

// make sure "MARKER" is not defined if option marker is specified
if "`marker'"=="marker" {
	capture confirm variable MARKER
	if !_rc {
		di 
		di in red "{hline 62}"
		di in white "MARKER " in red "already exists."
		di in red "Rename or drop the current " in white "MARKER " in red "and re-run the command."
		di in red "{hline 62}"
		exit 110
	}
}

// make sure only the following from options are allowed
if  "`fromdata'" != "cowc" & "`fromdata'" != "cown" & "`fromdata'" != "imfn" & "`fromdata'" != "mcc" ///
  & "`fromdata'" != "capc" & "`fromdata'" != "unc" & "`fromdata'" != "iso3n"  & "`fromdata'" != "iso2c" ///
  & "`fromdata'" != "iso3c" & "`fromdata'" != "marc" & "`fromdata'" != "penn" & "`fromdata'" != "other" {
	 	di 
	 	di in red "{hline 58}"
	 	di in red "Incorrect from() option."
	 	di in red "Click {help kountry##table1:here} to see a list of acceptable database_names."
	 	di in red "{hline 58}"
	 	exit 198
}

// if VARNAME is a string, convert to lower case
// if VARNAME is numeric, convert to string 
tempvar x1 markvar
qui {
  capture confirm string variable `varlist'
	if !_rc {
	    gen `x1' = lower(`varlist') // convert to lower case
	    replace `x1' = subinstr(`x1', "(", "", .) // strip all (
	    replace `x1' = subinstr(`x1', ")", "", .) // strip all )
	    replace `x1' = subinstr(`x1', "]", "", .) // strip all ]
	    replace `x1' = subinstr(`x1', "[", "", .) // strip all [
			replace `x1' = subinstr(`x1', "-", "", .) // strip all dashes
			replace `x1' = subinstr(`x1', "&", "", .) // strip all ampersands 
			replace `x1' = subinstr(`x1', ".", "", .)  // strip all periods
			replace `x1' = subinstr(`x1', "the", "", .)  // strip all "the"
			replace `x1' = subinstr(`x1', ",", "", .)  // strip all commas
			replace `x1' = subinstr(`x1', "  ", " ", .) // strip all double blanks
			gen NAMES_STD = trim(itrim(`x1')) // strip blanks
			drop `x1'
			gen `markvar' = NAMES_STD
	}
	else {
		capture tostring `varlist', generate(NAMES_STD)
		capture replace NAMES_STD = "" if NAMES_STD == "."
		capture replace NAMES_STD = trim(NAMES_STD)
		gen `markvar' = NAMES_STD
	}
	
	// process the stuck option
   if "`stuck'" != "" {
      if "`fromdata'" != "other" | "`to'" != "" | "`geo'" != "" {
         noi di
         noi di in red "{hline 59}"
         noi di in red "If you specify the stuck option,"
         noi di in red "you must type {c 34}" in white "kountry country_var, from(other) stuck [marker]" in red "{c 34}."
         noi di in red "{hline 59}"
         capture drop NAMES_STD
         capture drop MARKER
         exit 198
      }
      k_other
      capture k_other_extras
      k_stuck
	  	label var _ISO3N_ "ISO 3166 numeric code"
	  
	  	if "`marker'" == "" {
				capture drop NAMES_STD
				noi di
    		noi di in green "{hline 38}"
				noi di in green "The command has finished."
				noi di in green "The new variable is called " in white "_ISO3N_" in green "."
				noi di in green "{hline 38}"
				exit 0
	  	}
	  	else {
				qui marker_ `markvar'
				capture replace MARKER = 0 if _ISO3N_ == .
				capture drop NAMES_STD
				noi di
				noi di in green "{hline 50}"
				noi di in green "The command has finished."
				noi di in green "The new variables are named " in white "_ISO3N_" in green " and " in white "MARKER" in green "."
				noi di in green "{hline 50}"
				exit 0
	  	}
   }
   
   // process the from option
   if "`fromdata'" == "cown" {
   	qui k_cown
   }
   else if "`fromdata'" == "cowc" {
   	qui k_cowc
   }
   else if "`fromdata'" == "iso3n" {
   	qui k_iso3n
   }
   else if "`fromdata'" == "iso2c" {
   	qui k_iso2c
   }
   else if "`fromdata'" == "iso3c" {
   	qui k_iso3c
   }
   else if "`fromdata'" == "imfn" {
   	qui k_imfn
   }
   else if "`fromdata'" == "capc" {
   	qui k_capc
   }
   else if "`fromdata'" == "mcc" {
   	qui k_mcc
   }
   else if "`fromdata'" == "marc" {
   	qui k_marc
   }
   else if "`fromdata'" == "penn" {
   	qui k_penn
   }
   else if "`fromdata'" == "unc" {
   	qui k_unc
   }
   else {
      qui k_other
      qui capture k_other_extras
   }
}

// process the marker option
if "`marker'" != "" {
	qui marker_ `markvar'
}

// make sure variable GEO is not already defined if option geo is specified
if "`geo'"!="" {
	capture confirm variable GEO
	if !_rc {
		di
		di in red "{hline 59}"
		di in white "GEO " in red "already exists."
		di in red "Rename or drop the current " in white "GEO " in red "and re-run the command."
		di in red "{hline 59}"
		capture drop NAMES_STD
	   capture drop MARKER
		exit 110
	}
	
	// make sure only the following geo options are allowed
	if "`GEO'" != "cow" & "`GEO'" != "marc" & "`GEO'" != "men" & "`GEO'" != "meb" ///
    & "`GEO'" != "sov" & "`GEO'" != "un" &"`GEO'" != "undet" {
      di 
      di in red "{hline 72}"
      di in red "Incorrect geo() option."
      di in red "Click {help kountry##table2:here} to see a list of acceptable geo_options."
      di in red "{hline 72}"
      capture drop NAMES_STD
		  capture drop MARKER
      exit 198
  }
   
   if "`GEO'" == "cow" {
      qui k_geo_cow
   }
   else if "`GEO'" == "marc" {
   	qui k_geo_marc
   }
   else if "`GEO'" == "men" {
   	qui k_geo_men
   }
   else if "`GEO'" == "meb" {
   	qui k_geo_meb
   }
   else if "`GEO'" == "sov" {
   	qui k_geo_sov
   }
   else if "`GEO'" == "un" {
   	qui k_geo_un
   }
   else {
   	qui k_geo_undet 
   }
}

// process the to() option
if "`todata'" != "" {
   if "`todata'" != "capc" & "`todata'" != "iso2c" & "`todata'" != "iso3c" & "`todata'" != "imfn" ///
    & "`todata'" != "mcc" & "`todata'" != "cowc" & "`todata'" != "unc" & "`todata'" != "iso3n" ///
    & "`todata'" != "cown" & "`todata'" != "marc" & "`todata'" != "penn" {
	 	di
	 	di in red "{hline 56}"
	 	di in red "Incorrect to() option."
	 	di in red "Click {help kountry##fromto:here} to see a list of acceptable to() options."
	 	di in red "{hline 56}"
	 	
	 	capture drop NAMES_STD
	 	capture drop GEO
	 	capture drop MARKER
	 	exit 198
   }
   if "`fromdata'" == "other" { 
      di
      di in red "{hline 67}"
      di in red "When " in white "from()" in red " is used with " in white "to()"  ///
      in red ", you cannot use the keyword " in white "other" in red "."
      di in red "{hline 67}"
	 	
	 		capture drop NAMES_STD
	 		capture drop GEO
	 		capture drop MARKER
	 		exit 198
   }
   
   capture confirm variable `TO'
	 if !_rc {
			di 
			di in red "{hline 62}"
			di in white "`TO' " in red "already exists." 
			di in red "Rename or drop the current " in white "`TO' " in red "and re-run the command."
			di in red "{hline 62}"
			capture drop NAMES_STD
			capture drop MARKER
			capture drop GEO
			exit 110
	 }
	 
	 preserve
   qui use `"`c(sysdir_plus)'k/kountry.dta"', clear
   tempfile tokountry
      
   keep `FROM' `TO'
   capture drop if `FROM' == .
   capture drop if `FROM' == ""

   local quit = 0
   capture rename `FROM' `varlist'
	 if _rc {
			di 
     	di in red "{hline 58}"
     	di in white "kountry" in red " uses " in white "`FROM'" in red " internally."  
     	di in red "Rename the current " in white "`FROM' " in red "and re-run the command."
     	di in red "{hline 58}"
			local quit = 1
   }
   sort `varlist'
   label data ""
   qui save `tokountry', replace
   restore
	
   if `quit'==1 {
	capture drop NAMES_STD
     	capture drop MARKER
     	capture drop GEO
     	exit 110
   }

   sort `varlist'
   capture confirm variable _merge, exact
   if !_rc {
	di 
     	di in red "{hline 58}"
     	di in white "kountry" in red " uses " in white "_merge" in red " internally."  
     	di in red "Rename the current " in white "_merge " in red "and re-run the command."
     	di in red "{hline 58}"
     	capture drop NAMES_STD
     	capture drop MARKER
     	capture drop GEO
     	exit 198
   }
   capture merge `varlist' using `tokountry', uniqusing
	 if _rc {
			capture drop NAMES_STD
			capture confirm string variable `varlist'
	 		if _rc {
				di 
				di in red "{hline 72}"
				di in red "from(" in white "`fromdata'" in red ") indicates that you are converting from a string variable "
					di in red "but variable " in white "`varlist'" in red " is numeric."
				di in red "{hline 72}"
			}
			else {
				di
				di in red "{hline 72}"
				di in red "from(" in white "`fromdata'" in red ") indicates that you are converting from a numeric variable " 
					di in red "but variable " in white "`varlist'" in red " is a string."
				di in red "{hline 72}"
			}
			exit 106
	 }
   qui drop if _merge==2
   qui drop _merge
   
   di
   di in green "{hline 44}"
   di in green "You are converting from " in white "`fromdata'" in green " to " in white "`todata'" in green "...."
   di in green "{hline 44}"
   
   if "`marker'" == "" {
     capture drop NAMES_STD
     if "`geo'" != "" {
        di
	     di in green "{hline 47}"
	     di in green "The command has finished."
	     di in green "The new variables are named " in white "`TO'" in green " and " in white "GEO" in green "."
	     di in green "{hline 47}"
     }
     else {
        di
        di in green "{hline 38}"
        di in green "The command has finished."
        di in green "The new variable is named " in white "`TO'" in green "."
        di in green "{hline 38}"
     }
     exit 0
  }
}

// display final message
if "`marker'" == "marker" & "`geo'" != "" & "`to'" != "" {
   di
   di in green "{hline 66}"
	di in green "The command has finished."
	di in green "The new variables are named " in white "NAMES_STD" in green ", " in white "MARKER" ///
	   in green ", " in white "GEO" in green ", and " in white "`TO'" in green "."
	di in green "{hline 66}"
}
else if "`marker'" == "marker" & "`stuck'" != "" {
   di
   di in green "{hline 36}"
	di in green "The command has finished."
	di in green "The new variable is named " in white "MARKER" in green "."
	di in green "{hline 36}"
}
else if "`marker'" == "" & "`geo'" == "" {
	di
	di in green "{hline 40}"
	di in green "The command has finished."
	di in green "The new variable is named " in white "NAMES_STD" in green "."
	di in green "{hline 40}"
}
else if "`marker'" == "marker" & "`geo'" == "" & "`to'" != "" {
	di
	di in green "{hline 62}"
	di in green "The command has finished."
	di in green "The new variables are named " in white "NAMES_STD" ///
	in green ", " in white "MARKER" in green ", and " in white "`TO'" in green "."
	di in green "{hline 62}"
}
else if "`marker'" == "marker" & "`geo'" == "" {
	di
	di in green "{hline 54}"
	di in green "The command has finished."
	di in green "The new variables are named " in white "NAMES_STD " ///
	in green "and " in white "MARKER" in green "."
	di in green "{hline 54}"
}
else if "`marker'" == "" & "`geo'" != "" {
	di
	di in green "{hline 51}"
	di in green "The command has finished."
	di in green "The new variables are named " in white "NAMES_STD " ///
	in green "and " in white "GEO" in green "."
	di in green "{hline 51}"
}
else {
   if "`marker'" == "marker" & "`geo'" != "" {
	   di
	   di in green "{hline 60}"
	   di in green "The command has finished."
	   di in green "The new variables are named " in white "NAMES_STD" ///
	   in green ", " in white "MARKER" in green ", and " in white "GEO" in green "."
	   di in green "{hline 60}"
	}
}

set more on
end

capture program drop marker_
program define marker_
version 8.2

	args markvar
	
	gen byte MARKER = 1
	capture replace MARKER = 0 if NAMES_STD == `markvar'
	
end 

exit

---------------------------------------------------
The kountry command consists of the following files
---------------------------------------------------

kountry.ado
kountryadd.ado
kountrybackup.ado
kountryrestore.ado

k_capc.ado
k_cowc.ado
k_cown.ado
k_imfn.ado
k_iso2c.ado
k_iso3c.ado
k_iso3n.ado
k_marc.ado
k_mcc.ado
k_penn.ado
k_unc.ado

k_geo_cow.ado
k_geo_marc.ado
k_geo_meb.ado
k_geo_men.ado
k_geo_sov.ado
k_geo_un.ado
k_geo_undet.ado

k_stuck.ado

k_other.ado
k_other_extras.txt
k_other_extras.ado // only if kountryadd has been previously called

kountry.dta

kountry.hlp
kountryadd.hlp
kountrynames.hlp
kountryregions.hlp
kountrybackup.hlp

---------------
version history
---------------

changes in version 2.0
----------------------

- database() renamed to from()
- consolidated from() keywords
- new from() options:
      - ISO codes alpha-2 (iso2c) and alpha-3 (iso3c)
      - MARC (Library of Congress) codes (marcc)
- new option to() that allows converting from one coding scheme to another
- new option geo() that creates geographical regions
- new option "stuck" that converts long country names to ISO alpha-3
- more spellings added to k_other.ado
- new helper "kountryadd" command that allows the user to add new
   country spellings from within Stata
- cleaned up code
- some minor bugs fixed in country names 

changes in version 2.1.0
------------------------

- added compound double quotes to paths in kountryadd.ado
- fixed a couple of error messages
- minor code cleanup in kountry.ado
- added code 499 to _ISO3N_ for Montenegro in kountry.dta, k_iso3n.ado, and k_stuck.ado
  added code 341 to _COWN_ for Montenegro in kountry.dta
  added code MNG to _COWC_ for Montenegro in kountry.dta
- updated contact info and references in kountry.hlp

changes in version 2.1.1
------------------------

- added South Sudan
- separated Penn World Table from ISO3C due to different coding for Germany, Romania,
   and Democratic Republic of Congo

changes in version 2.1.2
------------------------

- added iso3n code for Taiwan

changes in version 2.1.3
------------------------

- _COWN_ for Ethiopia fixed from 529 to 530
- _MARC_ for South Sudan fixed from SO to SD

changes in version 2.1.4
------------------------

- _ISO3N_ for Tanzania fixed from 835 to 834
- added a check for the existence of _merge variable

changes in version 2.1.5
------------------------

- _ISO3N_ for Tanzania fixed from 835 to 834 in k_stuck.ado

If an _ISO3N_ code changes, make sure to change it in k_stuck.ado as well!

changes in version 2.1.6
------------------------

- Slovenia was incorrectly coded "sl" in k_iso2c.ado.
  Changed the coding to "si".

