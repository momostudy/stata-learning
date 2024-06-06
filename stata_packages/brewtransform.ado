********************************************************************************
* Description of the Program -												   *
* This program takes an RGB variable and creates/returns transforms of the RGB *
* value for each of the types of color sightedness impairment.				   *
*                                                                              *
* Data Requirements -														   *
*     none                                                                     *
*																			   *
* Dependencies -															   *
*     libbrewscheme.mlib													   *
*                                                                              *
* Program Output -                                                             *
*     achronopsia - Complete color blindness RGB transform/translate		   *
*	  protanopia - Red color blindness RGB transform/translate				   *
*	  deuteranopia - Green color blindness RGB transform/translate			   *
*	  tritanopia - Blue color blindness RGB transform/translate				   *
*                                                                              *
* Lines -                                                                      *
*     94                                                                       *
*                                                                              *
********************************************************************************
		
*! brewtransform
*! v 1.0.0
*! 21MAR2016

// Drop the program if already loaded in memory
cap prog drop brewtransform

// Define the program brewtransform
prog def brewtransform

	// Version to use for interpretation of code
	version 13.1
	
	// Syntax structure for program
	syntax varlist(max=1 string)
	
	// Check for brewscheme Mata library
	qui: brewlibcheck
	
	// Get all unique rgb values
	qui: levelsof `varlist', loc(colors)
	
	// New variable creation/checks
	foreach v in achromatopsia protanopia deuteranopia tritanopia {
	
		// Check to see if variable exists
		cap confirm new v `v'
		
		// If variable does not exist
		if _rc == 0 {
		
			// Create the variable
			qui: g `v' = ""
			
		} // End IF Block for new variable
		
	} // End Loop for color transformation variable creation
	
	// Loop over the rgb values
	foreach rgbval of loc colors {
	
		// Get the transformed rgb
		mata translateColor(`: subinstr loc rgbval `" "' `", "', all')
		
		// Set achomatopsia value
		qui: replace achromatopsia = "`achromatopsia'" if `varlist' == "`rgbval'"
		
		// Set protanopia value
		qui: replace protanopia = "`protanopia'" if `varlist' == "`rgbval'"
		
		// Set deuteranopia value
		qui: replace deuteranopia = "`deuteranopia'" if `varlist' == "`rgbval'"
		
		// Set tritanopia value
		qui: replace tritanopia = "`tritanopia'" if `varlist' == "`rgbval'"
		
	} // End loop over colors
	
	// Label the color sightedness impairment variables
	la var achromatopsia `"`achromatopsialab' RGB Transformed Equivalent"'
	
	// Label the color sightedness impairment variables
	la var protanopia `"`protanopialab' RGB Transformed Equivalent"'
	
	// Label the color sightedness impairment variables
	la var deuteranopia `"`deuteranopialab' RGB Transformed Equivalent"'
	
	// Label the color sightedness impairment variables
	la var tritanopia `"`tritanopialab' RGB Transformed Equivalent"'
	
// End of program
end

