********************************************************************************
* Description of the Program -												   *
* This program is used to check the meta data available on different visual    *
* properties of a given color palette for a specified number of colors.		   *
*                                                                              *
* Data Requirements -														   *
*     none                                                                     *
*																			   *
* System Requirements -														   *
*     Active Internet Connection											   *
*                                                                              *
* Program Output -                                                             *
*     r(paletteName[#Max][#C]_print) - Print friendliness indicator     	   *
*     r(paletteName[#Max][#C]_photocopy) - Photocopier friendliness indicator  *
*     r(paletteName[#Max][#C]_lcd) - LCD Viewing friendliness indicator        *
*     r(paletteName[#Max][#C]_colorblind) - Colorblindness friendliness		   *
*                                                                              *
* Lines -                                                                      *
*     160                                                                      *
*                                                                              *
********************************************************************************
		
*! brewmeta
*! v 1.0.0
*! 21MAR2016

// Drop the program from memory if loaded
cap prog drop brewmeta

// Define the program as an rclass program
prog def brewmeta, rclass

	// Specify the version number
	version 13.1

	// Define the syntax structure of the program
	syntax anything(name = palette id = "palette name"), colorid(integer) ///   
		[colors(integer -12) PROPerties PROPerties2(string asis) ]
		
	// Strip any quation marks from the palette name
	loc palette : subinstr loc palette `"""' "", all
	
	// Preserve the data in memory
	preserve
	
		// Check for the metadata dataset
		cap confirm file `"`c(sysdir_personal)'b/brewmeta.dta"'

		// If the file does not exist 
		if _rc != 0 | _rc == 603 {
		
			// Print error message
			di as err "Must first build the brewscheme database." _n		 ///   
			"Use the following command to do that: " as smcl {stata brewdb}
			
			// Error out of the program
			err 601
			
		} // End IF Block for non-existent brewscheme DB
		
		// If the file does exist
		else {
		
			// Load the dataset 
			qui: use `"`c(sysdir_personal)'b/brewmeta.dta"', clear
			
			// Check the colors option
			if `colors' < 2 {
			
				// Get the maximum value of colors for the given palette
				qui: su maxcolors if palette == "`palette'", meanonly
				
				// Get maximum value for the palette
				loc colors = `r(mean)'
				
			} // End IF Block if max colors parameter is missing or invalid
			
			// Validate the color ID parameter
			if `colorid' > `colors' {
			
				// Error out
				di as err "Color ID > # of colors in the palette"
				
				// Return error code
				err 198
				
			} // End IF Block for color ID validation check
			
			// Check to make sure colors value is <= max colors for the palette
			else {
				
				// Get the maximum colors value for the palette
				qui: su maxcolors if palette == "`palette'", meanonly
				
				// Check the values
				if `colors' > `r(mean)' {
				
					// Error out of the program
					di as err "Colors argument cannot exceed the max # of colors for the palette"
					
					// Exit program
					exit
					
				} // End IF Block for validation check
			
			} // End ELSE Block for the colors -> max colors validation
						
			// If all/no option specified	
			if inlist("`properties2'", "all", "") {
			
				// Loop over the property types
				foreach x in colorblind lcd photocopy print meta {
				
					// Get the characteristics
					loc prop `: char _dta[`palette'`colors'`colorid'_`x']'
					
					// Print to the screen
					di as res `"The color `colorid' of palette `palette' with `colors' colors is `prop'"'
					
					// Return the value
					ret local `palette'`colors'`colorid'_`x' `"`prop'"'
					
				} // End Loop over variables for characteristics
				
			} // End IF Block over all properties
				
			// other wise
			else {
			
				// Count the number of words in the string
				loc prps `: word count `properties2''
				
				// Set up loop to allow the command to generalize to multiple properties
				forv i = 1/`prps' {
				
					// Get the specific property value
					loc pr`i' `: word `i' of `properties2''
					
					// Get the characteristics
					loc prop `: char _dta[`palette'`colors'`colorid'_`pr`i'']'
					
					// Print to the screen
					di as res `"The color `colorid' of palette `palette' with `colors' colors is `prop'"'
					
					// Return the value
					ret local `palette'`colors'`colorid'_`pr`i'' `"`prop'"'
					
				} // End Loop to get properties
				
			} // End ELSE Block for specified properties
			
		} // End ELSE Block for existing brewscheme DB
				
	// Return data to original state
	restore
		
// End of Program
end 

