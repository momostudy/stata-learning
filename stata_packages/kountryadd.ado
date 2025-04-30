// adds user-specified country name spelling to k_other_extras.txt
// and translates k_other_extras.txt into k_other_extras.ado

program define kountryadd
	version 8.2
   args name1 to name2 add
   // name1	is the user-added spelling
   // name2 is the standardized country name as defined in kountrynames.hlp
   
   if "`to'" != "to" | "`add'" != "add" {
      di
      di in red "Incorrect syntax, see {help kountryadd:kountryadd} for help."
      exit
   }
   
   local x1 = `"`name1'"'
   local x1 = lower(`"`x1'"') // convert to lower case
   local x1 = subinstr(`"`x1'"', "(", "", .) // strip all (
	local x1 = subinstr(`"`x1'"', ")", "", .) // strip all )
	local x1 = subinstr(`"`x1'"', "]", "", .) // strip all ]
	local x1 = subinstr(`"`x1'"', "[", "", .) // strip all [
	local x1 = subinstr(`"`x1'"', "-", "", .) // strip all dashes
	local x1 = subinstr(`"`x1'"', "&", "", .) // strip all ampersands 
	local x1 = subinstr(`"`x1'"', ".", "", .)  // strip all periods
	local x1 = subinstr(`"`x1'"', "the", "", .)  // strip all "the"
	local x1 = subinstr(`"`x1'"', ",", "", .)  // strip all commas
	local x1 = subinstr(`"`x1'"', "  ", " ", .) // strip all double blanks
	local x1 = trim(`"`x1'"') // strip blanks on both sides
	
   local addline replace NAMES_STD = `"`name2'"' if NAMES_STD == `"`x1'"'
   //di "`addline'"
   
   capture file close extras
   capture file close extrasado
   
   file open extras using `"`c(sysdir_plus)'k/k_other_extras.txt"', write text append
   file write extras `"`addline'"' _n
   file close extras
   
   quietly copy `"`c(sysdir_plus)'k/k_other_extras.txt"' `"`c(sysdir_plus)'k/k_other_extras.ado"', replace
   
   file open extrasado using `"`c(sysdir_plus)'k/k_other_extras.ado"', write text append
   file write extrasado _n
   file write extrasado "end" _n
   file write extrasado "exit" _n
   file close extrasado
   
   di 
   di in green `"The following line has been added to `c(sysdir_plus)'k/k_other_extras.txt:"'
   di in yellow `"`addline'"'
   
   discard
   
end
exit
