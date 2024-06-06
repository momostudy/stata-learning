********************************************************************************
* Description of the Program -												   *
* This program is used to generate a proof of a user specified graph to view   *
* a simulation of how the graph might appear to individuals with varying forms *
* of color sight impairments. 												   *
*                                                                              *
* Program Output -                                                             *
* Creates 5 named graphs based on the user specified graph command.  The 	   *
* graphs are named based on the form of colorblindness with the exception of   *
* the proof copy which is a combined graph showing all forms of colorblindness.*
*                                                                              *
* Lines -                                                                      *
*     178                                                                      *
*                                                                              *
********************************************************************************
		
*! brewproof
*! v 1.0.0
*! 21MAR2016

// Drop program from memory if already loaded
cap prog drop brewproof

// Define program
prog def brewproof

	// version of Stata to use for interpretation
	version 13.1
	
	// Get the scheme name and any possible title names
	mata: brewproofParser(`"`0'"')
	
	// Check for scheme file and associated colorblind files
	foreach v in `schemename' `schemename'_achromatopsia `schemename'_protanopia ///   
	`schemename'_deuteranopia `schemename'_tritanopia {
	
		// Check for the files
		cap confirm file `"`c(sysdir_plus)'s/scheme-`v'.scheme"'
		
		// If file does not exist issue error to user
		if _rc != 0 {
		
			// Print error message
			di as err `"{help brewproof} could not find the file "'			 ///   
			`"`c(sysdir_plus)'s/scheme-`v'.scheme.  You may need to "'		 ///   
			`"rebuild it with {help brewtheme} and {help brewscheme} "'		 ///  
			`"if you used {help brewscheme} v < 1.0.0 to create the scheme file"'
			
			// Error code
			err 198
			
		} // End IF Block for non-existent scheme files
		
	} // End Loop to verify scheme files
	
	// Tokenize the input string
	gettoken name graph : 0, parse(":") bind 
	
	// Remove leading colon from the graph command
	loc graph `: subinstr loc graph `":"' ""'
	
	// Remove the colon from the graph command
	mata: brewproofCleaner(`"`graph'"')
	
	// Generate baseline graph
	cap `graph', scheme(`schemename') `titlestring' name(original, replace)
	
	// If return code issues
	if _rc != 0 {
	
		// Run command again w/o the comma before the scheme option
		`graph' scheme(`schemename') `titlestring' name(original, replace)
	
		// Repeat with the other versions of the scheme
		foreach v in achromatopsia protanopia deuteranopia tritanopia {
		
			// Create a proper cased version of the string
			loc fortitle `: di proper("`v'")'
		
			// Generate graph with simulated color values
			`graph' scheme(`schemename'_`v') name(`v', replace)				 ///   
			title(`"`fortitle' Simulation of Original Graph"')
			
		} // End of Loop over color blindness types
	
		// Generate proof graph
		gr combine achromatopsia protanopia deuteranopia tritanopia, 		 ///   
		scheme(`schemename') ti("brewproof colorblindness proofing", span 	 ///   
		c(black) size(medlarge)) name(brewproof, replace)
		
	} // End of IF Block for cases where the comma needed to be removed
	
	// If the comma did not need to be removed
	else {
	
		// Repeat with the other versions of the scheme
		foreach v in achromatopsia protanopia deuteranopia tritanopia {
		
			// Create a proper cased version of the string
			loc fortitle `: di proper("`v'")'
		
			// Generate graph with simulated color values
			`graph', scheme(`schemename'_`v') name(`v', replace)			 ///   
			title(`"`fortitle' Simulation of Original Graph"')
			
		} // End of Loop over color blindness types
	
		// Generate proof graph
		gr combine achromatopsia protanopia deuteranopia tritanopia, 		 ///   
		scheme(`schemename') ti("brewproof colorblindness proofing", span 	 ///   
		c(black) size(medlarge)) name(brewproof, replace)
			
	} // End of ELSE Block for cases w/o graph options
	
// End of Program
end	
	
// Start mata session	
mata:

// Regular expression based function to parse brewproof command
void brewproofParser(string scalar source) {
	
	// Initialize string scalars to store the scheme name and title string
	string scalar scheme, title

	// Scheme name
	regexm(source, `"( scheme\(?[a-zA-Z0-9]+\)?)"')

	// Get the chunk matching the regex
	scheme = regexs(1)
	
	// Remove the option name around things
	scheme = subinstr(scheme, "scheme(", "")
	
	// Remove the closing parenthesis
	scheme = subinstr(scheme, ")", "")
	
	// Check for title string
	if (regexm(source, `"( ti.*\(?[a-zA-Z0-9]+\)?)"') == 1) { 

		// If matched get the matching portion of the string
		title = regexs(1)
		
		// Return the title in the local macro titlestring
		st_local("titlestring", title)
	
	} // End IF Block for title string(s)
	
	else st_local("titlestring", "")
	
	// Return the scheme file name in the local macro schemename
	st_local("schemename", scheme)
	
} // End Function definition

// Function to remove any options that cannot be present in the graph command
void brewproofCleaner(string scalar graphcmd) {

	// String to hold result after cleaning
	string scalar graphstr

	// Get rid of name option if included
	graphstr = regexr(graphcmd, `" name\(?[a-zA-Z0-9].*\)?"', "")

	// Get rid of additional scheme option if included
	graphstr = regexr(graphstr, `"( scheme\(?[a-zA-Z0-9]+\)?)"', "")

	// Get rid of title option if included
	graphstr = regexr(graphstr, `"( ti.*\(?[a-zA-Z0-9]+\)?)"', "")
	
	// Return the cleaned string
	st_local("graph", graphstr)
	
} // End Function definition
	
// End Mata session
end

/*
Example:

brewproof, scheme(ggtest2) : tw lowess mpg weight, || scatter mpg weight if rep78 == 1 || scatter mpg weight if rep78 == 2 || scatter mpg weight if rep78 == 3 || scatter mpg weight if rep78 == 4 || scatter mpg weight if rep78 == 5, scheme(ggtest2) legend(order(2 "1978 Repair Record = 1" 3 "1978 Repair Record = 2" 4 "1978 Repair Record = 3" 5 "1978 Repair Record = 4" 6 "1978 Repair Record = 5")) name(baseline, replace)

*/
