********************************************************************************
* Description of the Program -												   *
* This program is used to build a dataset with the names and RGB values of all * 
* color styles defined by Stata that are part of the base installation of the  *
* program.  It will be used when proofing graphs from the perspective of 	   *
* different forms of color blindness.										   *
*                                                                              *
* Program Output -                                                             *
*                                                                              *
* Lines -                                                                      *
*     314                                                                      *
*                                                                              *
********************************************************************************
		
*! brewcolordb
*! v 1.0.0
*! 21MAR2016

// Drop the program from memory if loaded
cap prog drop brewcolordb

// Define a program
prog def brewcolordb, rclass

	// Version of Stata that should be used to interpret the code
	version 13.1

	// Defines syntax structure of program
	syntax [, DISplay REPlace OVERride]
	
	if `"`override'"' == "" {

		// Print warning message
		di as res "This program needs to clear all data currently in memory. "	 ///   
		"If this is ok hit enter, otherwise enter the letter 'n' and hit enter " ///  
		"to exit the program without clearing data from memory." _request(_perm)
	
		// Check response
		if lower(`"`perm'"') == "n" exit 
		
	}
		
	// Clear data from memory
	clear
	
	// Store personal directory
	loc personal `"`c(sysdir_personal)'"'
	
	// Remove tilde and replace with HOME environmental variable for color db subdirectory
	qui: dirfile, p(`"`: subinstr loc personal `"~"' `"`:environment HOME'"', all'brewcolors"')
	
	// Remove tilde and replace with HOME environmental variable for color db subdirectory
	qui: dirfile, p(`"`: subinstr loc personal `"~"' `"`:environment HOME'"', all'style"')

	// Check for file
	cap confirm new file `"`c(sysdir_personal)'brewcolors/colordb.dta"'
	
	// If file does not exist or replace option passed
	if _rc == 0 | `"`replace'"' != "" {

		// Get list of color style file names
		loc colors `: dir `"`c(sysdir_base)'/style/"' files "color*.style", respect'

		// Clean up the file names
		loc colors : list clean colors
		
		// Remove quotation marks from color file names
		loc colors `: subinstr loc colors `"""' "", all'
		
		// Set observations
		qui: set obs 2

		// Create entry for color black
		qui: g id = "black"
		
		// Create RGB balues for color black
		qui: g v1 = cond(_n == 1, "sequence 1", "0 0 0")

		// Loop over the list of files
		forv i = 1/`: word count `colors'' {
			
			// Keep the current data preserved in memory
			preserve
				
				// Get the color style file name
				loc name `: word `i' of `colors''
				
				// Load the color style file into memory
				qui: insheet using `"`c(sysdir_base)'style/`name'"', clear
				
				// Get the color name
				getColorName `name'
				
				// Use the color name for the ID field
				qui: g id = "`r(colorname)'"
				
				// Reserve space for a temp file in memory
				tempfile `i'
				
				// Save the current data set in the tempfile reserved above
				qui: save ``i''.dta, replace

			// Restore memory to previous state (e.g., first color style file)
			restore

			// Append this color style to the existing data set
			qui: append using ``i''.dta

		} // End Loop over the color style files
		
		// Generate a file id (row number)
		qui: g fileid = _n

		// Count the number of lines per file
		qui: bys id (fileid): g lines = _N

		// Create a row id for the lines from each color style file
		qui: bys id (fileid): g linenum = _n

		// Get the sequence number
		qui: g seqid = v1 if regexm(v1, "^sequence") == 1

		// Remove the word sequence
		qui: replace seqid = trim(itrim(subinstr(seqid, "sequence ", "", .)))

		// Make the sequence ID variable numeric
		qui: destring seqid, replace
		
		// Carry the value for the rest of the color
		bys id (fileid): replace seqid = seqid[_n -1] if mi(seqid)
		
		// Keep only the records that contain the RGB values
		qui: keep if lines == linenum

		// Replace the value for the color style none
		qui: replace v1 = "" if id == "none"

		// Rename v1 to something more informative
		rename v1 rgb

		// Check display option
		if `"`display'"' != "" {

			// Write the table header
			di as text _dup(80) `"_"' _n _skip(10) "Color Name" _skip(10) 	 ///   
			"RGB" _n _dup(80) "_" _n 

		} // End If Block for Display Header
		
		// Loop over the observations
		forv v = 1/`: word count `colors'' {
		
			// Check display option
			if `"`display'"' != "" {

				// Print the data to the screen
				di as res _skip(10) id[`v'] _col(30) rgb[`v']

			} // End IF Block for display option
			
			// Return the color value in the name of the color
			ret loc `: di id[`v']' `"`: di rgb[`v']'"'
				
		} // End Loop
			
		// Check display option
		if `"`display'"' != "" {

			// Add footer
			di as text _dup(80) "_"
			
		} // End IF Block for display option
		
		// Set the display order of the variables
		order id rgb
		
		// Keep only the needed variables
		qui: keep id rgb seqid
		
		// Clean up rgb values
		qui: replace rgb = trim(itrim(rgb))
		
		// Rename variable 
		qui: rename id palette
		
		// Make sequence ID string
		qui: tostring seqid, replace
		
		// Make sequence ID follow logic used for rest of suite
		qui: replace seqid = palette + seqid
		
		// Generate meta data fields
		foreach v in colorblind print lcd photocopy {
		
			// Generate variables with null values
			qui: g `v' = .n
			
		} // End Loop over meta properties
		
		// Generate a meta data field
		qui: g meta = "Stata"
		
		// Create a max colors value
		qui: g maxcolors = 1
		
		// Create colorid 
		qui: g colorid = 1
		
		// Create palette ID
		qui: g pcolor = 1
		
		// Add metadata 
		la var palette "Name of Stata Colorstyle"
		la var rgb "RGB Value of Stata Colorstyle"
		
		// Optimize data storage
		qui: compress
		
		// Drop any duplicate values
		qui: duplicates drop
		
		// Translate colorblind equivalent RGB values
		qui: brewtransform rgb
		
		// Loop over value variables
		foreach v of var rgb achromatopsia protanopia deuteranopia		 ///   
		tritanopia {

			// Replace the value for the color style none
			qui: replace `v' = "none" if palette == "none"
			
			// Make sure black and white are constant
			qui: replace `v' = "0 0 0" if palette == "black"
			qui: replace `v' = "255 255 255" if palette == "white"

		} // End of loop over value columns
		
		// Save to the brewscheme created directories
		qui: save `"`c(sysdir_personal)'brewcolors/colordb.dta"', replace
		
		// Loop over records
		forv i = 1/`c(N)' {
	
			// open new files for named colors
			loc rootnm `: di palette[`i']'
	
			// Store filename in local macro
			loc styleroot `"`c(sysdir_personal)'style/color-"'
		
			// Create new file wit the color definition
			qui: file open achrom using `"`styleroot'`rootnm'_achromatopsia.style"', w replace
			
			// Create new file wit the color definition
			qui: file open protan using `"`styleroot'`rootnm'_protanopia.style"', w replace

			// Create new file wit the color definition
			qui: file open deuter using `"`styleroot'`rootnm'_deuteranopia.style"', w replace
			
			// Create new file wit the color definition
			qui: file open tritan using `"`styleroot'`rootnm'_tritanopia.style"', w replace
			
			// Loop over the file connections
			foreach fnm in achrom protan deuter tritan {
			
				// Write a version number
				qui: file write `fnm' `"*! v 0.0.0 `c(current_date)' `c(current_time)'"' _n
				
				// Write color attribution
				qui: file write `fnm' `"*! Color defined by the user: `c(username)'"' _n
				
				// Add a sequence ID to the file
				qui: file write `fnm' `"sequence `: di seqid[`i']'"' _n
			
			} // End Loop over Stata defined colors
			
			// Write the color name
			qui: file write achrom `"label "`rootnm'_achromatopsia""' _n(2)
			qui: file write protan `"label "`rootnm'_protanopia""' _n(2)
			qui: file write deuter `"label "`rootnm'_deuteranopia""' _n(2)
			qui: file write tritan `"label "`rootnm'_tritanopia""' _n(2)
			
			// Write the color definition to the file
			qui: file write achrom `"set rgb "`: di achromatopsia[`i']'""' _n(2)
			qui: file write protan `"set rgb "`: di protanopia[`i']'""' _n(2)
			qui: file write deuter `"set rgb "`: di deuteranopia[`i']'""' _n(2)
			qui: file write tritan `"set rgb "`: di tritanopia[`i']'""' _n(2)
			
			// Close the file
			qui: file close achrom
			qui: file close protan
			qui: file close deuter
			qui: file close tritan
						
		} // End Loop over records

	} // End IF Block for case where replace option is passed or file does not exist
	
	// Otherwise
	else {
	
		// Print message to console
		di as res `"The file "'											 ///   
		`"`c(sysdir_personal)'brewcolors/colordb.dta already exists "'	 ///   
		`"and will not be overwritten"' 
		
	} // End ELSE Block for existing file without overwrite
		
// end of program
end

// Utility subroutine to parse the color name from a color style file name
prog def getColorName, rclass

	// Accepts only single mandatory argument of the color style file name
	syntax anything(name = cfname id = "Color style file name")
	
	// Remove the opening of the color style file name
	loc cname `: subinstr loc cfname `"color-"' "", all'
	
	// Remove the file extension
	loc cname `: subinstr loc cname `".style"' "", all'

	// Return the value
	ret loc colorname `cname'
	
// End of subroutine
end
