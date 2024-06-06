********************************************************************************
* Description of the Program -												   *
* This program is used to generate a series of colors interpolated between two *
* known colors.  There are also options available to return an arbitrarily 	   *
* brighter and/or darker color (for RGB), the inverse of the color, and 	   *
* provides options to return color strings in several color spaces.			   *
*                                                                              *
* Data Requirements -														   *
*     none                                                                     *
*																			   *
* System Requirements -														   *
*     JRE >= 1.8 															   *
*                                                                              *
* Program Output -                                                             *
*     r(start) - The value of the color used as the starting point	     	   *
*     r(end) - The value of the color used as the end point					   *
*     r(colorstring) - A string of colors from start to end in a single macro  *
*     r(terpcolor#) - The ith interpolated color between start and end		   *
*                                                                              *
* Lines -                                                                      *
*     205                                                                      *
*                                                                              *
********************************************************************************
		
*! brewterpolate
*! v 1.0.0
*! 21MAR2016

// Drop the program from memory if loaded
cap prog drop brewterpolate

// Define the program with rclass property
prog def brewterpolate, rclass

	// Set the version to interpret the code under
	version 13.1

	// Set the syntax for the program
	syntax, SColor(string) EColor(string) Colors(integer) 					 ///   
			[ CMod(string) ICSpace(string) RCSpace(string) INVerse Grayscale ]

		// If user specified grayscale set the boolean for that macro
		if `"`grayscale'"' != "" loc grayscale "true"
		
		// If not set to false to prevent the returned colors coming back in 
		// grayscale
		else loc grayscale "false"
			
		// Check arguments passed to color modification parameter
		if !inlist(`"`cmod'"', "brighter", "darker", "saturated", 		 ///   
		"desaturated", "") {

			// Print error message to screen
			di as err `"Argument `cmod' not allowed for the color "' 		 ///   
			"modification parameter.  Ignoring this argument." 
			
			// Reset color modification to a nullstring
			loc cmod ""

		} // End IF Block for color modification parameter
		
		if mi("`cmod'") loc cmod `""'

		// Check input color space
		if !inlist(`"`icspace'"', "rgb", "rgba", "srgb", "srgba", "hsb") & 	 ///   
		!inlist(`"`icspace'"', "hsba", "web", "weba", "hex", "hexa", "") {

			// Print error message to screen
			di as err `"Illegal input color space `icspace'."' _n			 ///   
			"The only allowable values are: rgb, srgb, hsb, hsba, and "		 ///   
			"web." _n  "Program defaults to RGB if no value passed."

			// Return error code
			err 198

		} // End IF Block for invalid input color space

		// Check for web-based color values
		else if inlist(`"`icspace'"', "weba", "hexa") {

			// Check for a sufficient number of characters in the string
			if (length(`"`scolor'"') < 8) {
			
				// Print error message
				di as err "Hexademical values with alpha transparency must have be >= 8 characters in length"

				// Set error message
				err 119
				
			} // End IF Block for too few characters
			
			// Check for valid specification using a decimal valued alpha parameter 
			// requires a space delimiter between the hexstring and decimal values
			// which may or may not include a leading zero/one
			else if !regexm(`"`scolor'"', "^([a-zA-Z0-9].*) ([0-1]\.[0-9.*])|(\.[0-9])$") {
			
				// Print error message
				di as err "Must use a single space between the hex string and decimal valued alpha parameter"

				// Set error message
				err 119
				
			} // End ELSE Block for malformed alpha param
						
		} // End ELSEIF Block for web-based colors

		// Check for web-based color values
		else if `"`icspace'"' == "" loc icspace "rgb"

		// Check returned color space
		if !inlist(`"`rcspace'"', "rgb", "rgba", "srgb", "srgba", "hsb") &   ///   
		!inlist(`"`rcspace'"', "hsba", "hex", "hexa", "web", "weba", "") {

			// Print error message to screen
			di as err `"Illegal input color space `icspace'."' _n			 ///   
			"The only allowable values are: rgb(a), srgb(a), and hsb(a)."    ///   
			_n "Program defaults to RGB if no value passed."

			// Return error code
			err 198

		} // End IF Block for invalid input color space

		// Check for null return spaces
		else if `"`rcspace'"' == "" loc rcspace "rgb"
		
		// Remove ',' characters and replace with spaces
		loc ecolor : subinstr loc ecolor "," " ", all

		// Remove double spaces and replace with single space
		loc ecolor : subinstr loc ecolor "  " " ", all

		// Remove ',' characters and replace with spaces
		loc scolor : subinstr loc scolor "," " ", all

		// Remove double spaces and replace with single space
		loc scolor : subinstr loc scolor "  " " ", all

		// Set boolean value for no inverted colors
		if "`inverse'" == "" loc inverse "false"

		// If user wants inverted colors
		else loc inverse "true"
 
		// Incremented by 1 in the Java plugin
		loc icolors = `colors'

		// Call the java program to interpolate the colors
		javacall org.paces.stata.ColorTerp interpcolors, 					 ///   
		args(`icspace' `rcspace' "`scolor'" "`ecolor'" `colors' "`cmod'" 	 ///   
		`inverse' `grayscale')

		// Clear existing return valies
		return clear
		
		// Return colors
		loc retcolors `= `colors' + 2'
		
		// Loop over the returned results
		forv i = 1/`retcolors' {

			// Set the return macros
			ret loc terpcolor`i' "`color`i''"

			// On first iteration
			if `i' == 1 {
			
				// Add each of the colors to the same macro
				loc scolorstring `""`color`i''""'
				
				// Store the starting color
				loc startingcolor "`color`i''"
			
			} // End IF Block for first iteration
			
			// ELSE Block for cases after the first iteration
			else {

				// Add each of the colors to the same macro
				loc scolorstring `"`scolorstring' "`color`i''""'
				
				// Check for last iteration and store ending color
				if `i' == `retcolors' loc endingcolor "`color`i''"
			
			} // End ELSE Block for iterations after the first
			
		} // End Loop
		
		// Return starting color
		ret loc start "`startingcolor'"
		
		// Return ending color
		ret loc end "`endingcolor'"
		
		// Return the total number of colors
		ret loc totalcolors `retcolors'
		
		// Return range for interpolated colors
		ret loc interpstart 2
		ret loc interpend `= `retcolors' - 1'
		
		// Return all the colors in a single macro
		ret loc colorstring `scolorstring'
		ret loc colorsdelim `: subinstr loc scolorstring `"" ""' `"", ""', all'

// End Program definition
end

