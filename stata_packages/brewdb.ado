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
*     432                                                                      *
*                                                                              *
********************************************************************************
		
*! brewdb
*! v 1.0.0
*! 21MAR2016

// Drop the program from memory if loaded
cap prog drop brewdb

// Define the program as an rclass program
prog def brewdb

	// Specify the version number
	version 13.1

	// Define the syntax structure of the program
	syntax, [REPlace]
		
	// Preserve the data in memory
	preserve
			
		// Check for directory and if not build it	
		dirfile, p(`"`c(sysdir_personal)'b"') rebuild

		// Check for the metadata dataset
		cap confirm new file `"`c(sysdir_personal)'b/brewmeta.dta"'

		// If the file doesn't exist
		if _rc == 0 | `"`replace'"' != "" {
			
			// Create a tempfile to read the JS into
			tempfile brewjs
			
			// Get the current date/time
			loc date `"`c(current_date)'"'
			loc time `"`c(current_time)'"'
						
			// Read the javascript into memory
			qui: copy "http://colorbrewer2.org/colorbrewer_schemes.js" 	 ///   
			`brewjs'.js
			
			// Read the data into memory
			qui: insheet using `brewjs'.js, clear
			
			// Force the erasing of the temp file
			qui: erase `brewjs'.js
						
			// Remove extraneous metadata from the javascript file
			qui: drop in 1/7
			
			// Parse the string into colors and meta-data properties
			qui: split v1, g(z) p(`"'], 'properties'"')
			
			// This parses the data into the individual sets of colors
			qui: split z1, g(w) parse(`":  {"')
			
			// Loop over the maximum colors for each subpalette
			forv i = 3/12 {
				
				// Value of 9 requires special handling
				if !inlist(`i', 9, 12) {
				
					// Return only the rgb values for the # of colors
					qui: g v`i' = regexs(1) if regexm(w2,					 ///   
											 `"(`i': \[.*\], `= `i' + 1')"')
					
				} // End IF Block for # of colors within subpalette
				
				// For the case of the value of 9
				else if `i' == 9 {
				
					// Parse the string, hardcoding the next value
					qui: g v9 = regexs(1) if regexm(w2, `"(9: \[.*\'], 10:)"')
					
					// Get rid of left overs from regex
					qui: replace v9 = subinstr(v9, "9:", "", .)
					
					// Get rid of left overs from regex
					qui: replace v9 = subinstr(v9, "10:", "", .)
					
				} // End ELSE Block for the special case for value 9
				
				// For the case of the value of 10
				else if `i' == 10 {
				
					// Parse the string, hardcoding the next value
					qui: g v10 = regexs(1) if regexm(w2, `"(10: \[.*\'], 11:)"')
					
					// Get rid of left overs from regex
					qui: replace v10 = subinstr(v10, "10:", "", .)
					
					// Get rid of left overs from regex
					qui: replace v10 = subinstr(v10, "11:", "", .)
					
				} // End ELSE Block for the special case for value 9
				
				// For the case of the value of 11
				else if `i' == 11 {
				
					// Parse the string, hardcoding the next value
					qui: g v11 = regexs(1) if regexm(w2, `"(11: \[.*\'], 12:)"')
					
					// Get rid of left overs from regex
					qui: replace v11 = subinstr(v11, "11:", "", .)
					
					// Get rid of left overs from regex
					qui: replace v11 = subinstr(v11, "12:", "", .)
					
				} // End ELSE Block for the special case for value 9
				
				// Need to handle case of 12 color palettes since the end differs
				else {
				
					// This regex makes sure the 12th color element isn't dropped
					qui: g v12 = regexs(1) if regexm(w2, `"(12: \[.*)"')

				} // End ELSE Block for parsing the RGB strings by # colors 
				
				// Parse out only the rgb parts of the strings
				qui: replace v`i' = regexr(v`i', "(`i': \[')|(, [0-9])|(  [0-9])", "")

				// Split the string to create a single variable for each color
				qui: split v`i', g(v`i'color) parse(`"', '"')
				
				// Get the variable by color combinations for each value 3-12
				qui: ds v`i'color*
				
				// Loop over the returned list of variables
				foreach x in `r(varlist)' {
				
					// Remove any extra space in the variables
					qui: replace `x' = trim(itrim(`x'))
					
					// Remove punctuation and 'rgb(' from the start of the value string
					qui: replace `x' = regexr(`x', "(rgb\()|(\))", "")
					
					// Remove the commas between the values
					qui: replace `x' = subinstr(`x', ",", " ", .)

					// Remove any trailing/closing parenthesis
					qui: replace `x' = subinstr(`x', `")"', "", .)

					// Remove any trailing/closing square brackets
					qui: replace `x' = subinstr(`x', `"]"', "", .)

					// Remove any leading/opening square brackets
					qui: replace `x' = subinstr(`x', `"["', "", .)

					// Remove any remaining apostrophes 
					qui: replace `x' = subinstr(`x', `"'"', "", .)

					// Remove IDs for next color/palette combination
					qui: replace `x' = regexr(`x', "(  [0-9])", "")
					
					// Remove erroneous spaces
					qui: replace `x' = trim(itrim(`x'))

				} // End Loop over individual color variables
				
				// Drop the variable with the full set of color values for that sub palette
				qui: drop v`i'
				
			} // End Loop over possible number of colors within palettes

			// Parse the string to get the palette names
			qui: split v1, gen(palette) parse(":  {")

			// Clean up the string 
			qui: g palette = regexr(palette1, ".* [DQS][a-z].* */", "")

			// Drop records if missing a value for palette
			qui: drop if mi(palette)

			// Keep only the variables needed to build out the RGB values or properties
			qui: keep palette v*color* v1

			// Parse the JS
			qui: g x = regexs(0) if regexm(v1, 								 ///   
			`"'blind':\[[0-2].*\],'print':\[[0-2].*\],'copy':\[[0-2].*\],'screen':\[[0-2].*\]"')

			// Drop observations without data
			qui: drop if mi(x)

			// Parse the returned substring from the regular expression
			qui: split x, gen(y) parse("],")

			// Parse the colorblind friendliness indicator from the JS
			qui: replace y1 = regexr(y1, "('blind':\[)", "")
			
			// Parse the print friendliness indicator from the JS
			qui: replace y2 = regexr(y2, "('print':\[)", "")
			
			// Parse the copy friendliness indicator from the JS
			qui: replace y3 = regexr(y3, "('copy':\[)", "")
			
			// Parse the LCD view friendliness indicator from the JS
			qui: replace y4 = regexr(y4, "('screen':\[)", "")
			
			// Clean up how the LCD property is parsed
			qui: replace y4 = regexr(y4, "(\])", "")

			// Split colorblind indicator string into element/color wise indicators
			qui: split y1, gen(colorblind) parse(",")

			// Split print indicator string into element/color wise indicators
			qui: split y2, gen(print) parse(",")

			// Split photocopy indicator string into element/color wise indicators
			qui: split y3, gen(photocopy) parse(",")

			// Split lcd indicator string into element/color wise indicators
			qui: split y4, gen(lcd) parse(",")

			// Drop some unnecessary junk to reduce memory usage
			qui: drop x y1 y2 y3 y4 
			
			/* Brewer only created palettes with 3 - 12 colors, but the JS is 
			stored in such a way as to only include a maximum of 10 elements.  
			In order to align the indicators with the colors, we need to make 
			sure that the highest value indicator is numbered the same as the 
			corresponding color to which it references.  This takes the variables
			for each of the indicators and alters the number that appears as a 
			suffix from the split command and adds the appropriate number to it 
			to align the characteristics with the colors. */
			forv i = 10(-1)1 {
				
				// Use the group rename command to batch rename the indicators
				rename (colorblind`i' print`i' photocopy`i' lcd`i')			 ///   
				(colorblind`= `i' + 2' print`= `i' + 2' photocopy`= `i' + 2' ///   
				lcd`= `i' + 2')
				
			} // End Loop over the color metadata properties
			
			// Additional garbage collection to reduce memory usage
			qui: keep palette v*color* colorblind* print* photocopy* lcd*
			
			// Start imposing a higher order normalized form on the data structure
			qui: reshape long v3color v4color v5color v6color v7color v8color ///   
			v9color v10color v11color v12color colorblind print photocopy 	 ///   
			lcd, i(palette) j(colorid)
			
			// Rename the remaining variables to normalize the data again
			qui: rename v#color v#
			
			// Structure data in first normalized form:
			// Primary key = palette, pcolor, colorid
			qui: reshape long v, i(palette colorblind print photocopy lcd 	 ///   
			colorid) j(pcolor)

			// Drop the record if no RGB value exists for it to save memory
			qui: drop if mi(v)
			
			// Rename the generic variable 
			qui: rename v rgb
			
			/* This patches a bug with parsing the JavaScript when the array 
			contains > 10 elements.  This only affected the paired and set3 
			colorbrewer palettesand trims the extra character added to the 
			start and/or end of the string. */
			qui: replace rgb = cond(regexm(rgb, "([0-9][0-9][0-9][0-9]$)"),  ///   
								substr(rgb, 1, 11), 						 ///   
						  cond(regexm(rgb, "(^[0-9][0-9][0-9][0-9])"), 		 ///   
						  substr(rgb, 2, 12), rgb))
			
			// Make all palette names lower cased
			qui: replace palette = lower(palette)

			// Recast the numeric indicators into true numeric values
			qui: destring colorblind print photocopy lcd, replace

			// Get maximum number of values allowable
			qui: bys palette (pcolor colorid): egen maxcolors = max(pcolor)

			// Loop over the properties
			foreach v of var colorblind print photocopy lcd {

				// Replace with extended missing
				qui: replace `v' = .n if mi(`v')
				
			} // End Loop over properties

			// Define value labels for the meta variables
			la def colorblind 	0 "Not color blind friendly" 				 ///
								1 "Color blind friendly"  					 ///
								2 "Possibly color blind friendly"			 ///   
								.n "Missing Data on Colorblind Friendliness", ///   
								modify

			la def print	 	0 "Not print friendly" 						 ///
								1 "Print friendly"  						 ///
								2 "Possibly print friendly"					 ///   
								.n "Missing Data on Print Friendliness", modify

			la def photocopy 	0 "Not photocopy friendly" 					 ///
								1 "Photocopy friendly" 						 ///   
								2 "Possibly photocopy friendly"				 ///   
								.n "Missing Data on Photocopier Friendliness", ///   
								modify

			la def lcd			0 "Not LCD friendly" 						 ///   
								1 "LCD friendly" 							 ///   
								2 "Possibly LCD friendly"					 ///   
								.n "Missing Data on LCD Friendliness", modify
								
			// Apply the value labels to the metadata properties
			la val colorblind colorblind
			la val print print
			la val photocopy photocopy
			la val lcd lcd
	
			// Create a sequence ID for the Data set 
			qui: egen seqid = concat(palette pcolor colorid)
			
			// Create local macros to store palettes based on scale types
			loc qual1 `""accent", "dark2", "paired", "pastel1", "pastel2""'
			loc qual2 `""set1", "set2", "set3""'
			loc seq1 `""blues", "bugn", "bupu", "gnbu", "greens", "greys""'
			loc seq2 `""oranges", "orrd", "pubu", "pubugn", "purd", "purples""' 
			loc seq3 `""rdpu", "reds", "ylgn", "ylgnbu", "ylorbr", "ylorrd""'
			loc div1 `""brbg", "piyg", "prgn", "puor", "rdbu", "rdgy""' 
			loc div2 `""rdylbu", "rdylgn", "spectral""'
			loc qual `"`qual1', `qual2'"'
			loc seq `"`seq1', `seq2', `seq3'"'
			loc div `"`div1', `div2'"'
			
			// Create a meta variable for use with the extra color palettes
			qui: g meta = cond(inlist(palette, `qual1'), "Qualitative", 	 ///
						  cond(inlist(palette, `qual2'), "Qualitative",		 ///   
						  cond(inlist(palette, `seq1'), "Sequential",		 ///   
						  cond(inlist(palette, `seq2'), "Sequential",		 ///   
						  cond(inlist(palette, `seq3'), "Sequential",		 ///   
						  cond(inlist(palette, `div1'), "Divergent", 		 ///   
						  cond(inlist(palette, `div2'), "Divergent",   "")))))))
			
			// Define Qualitative Palettes
			char _dta[qualitative] `"`qual'"'

			// Define Divergent Palettes
			char _dta[divergent] `"`div'"'

			// Define Sequential/Continuous Palettes
			char _dta[sequential] `"`seq'"'
			
			// Add characteristic to the dataset for the palettes available
			char _dta[palettes] `"`qual', `seq', `div'"'

			// Get number of records
			qui: count
			
			// Store in local macro
			loc N = r(N)
			
			// Loop across observations
			forv i = 1/`N' {
			
				// Create stem for characteristics
				loc stem "`: di seqid[`i']'"
			
				// Loop over the property variables
				foreach v of var colorblind lcd photocopy print meta {
				
					// Check type casting of variable
					if substr(`"`: type `v''"', 1, 3) != "str" {
				
						// Get the characteristic for the observation
						loc theproperty : label(`v') `: di `v'[`i']'
						
					} // End IF Block for numeric variables
					
					// For string/character variables
					else {
					
						// Store the string value of the data instead
						loc theproperty : di `v'[`i']

					} // End ELSE Block for string variables
					
					// Set the characteristic for the variable/value
					qui: char def _dta[`stem'_`v'] `"`theproperty'"'
					
				} // End Loop over variables for characteristics
				
			} // End Loop over observations
			
			// Create variable labels
			la var palette "Name of Color Palette"
			la var pcolor "Palette by Colors Selected ID"
			la var colorblind "Colorblind Indicator"
			la var photocopy "Photocopy Indicator"
			la var print "Print Indicator"
			la var lcd "LCD/Laptop Indicator"
			la var seqid "Sequential ID for property lookups"
			la var colorid "Within pcolor ID for individual color look ups"
			la var rgb "Red-Green-Blue Values to Build Scheme Files"
			la var maxcolors "Maximum number of colors allowed for the palette"
			la var meta "Meta-Data Palette Characteristics (see char _meta[*] for more info)"
			
			// Add additional meta data characteristics to explain meta properties
			qui: char meta[Qualitative] "ColorBrewer Palettes Designed for Nominal/Ordinal Scale Variables"
			qui: char meta[Sequential] "ColorBrewer Palettes Designed for Intervallic/Ratio Scale Variables"
			qui: char meta[Divergent] "ColorBrewer Palettes Designed for Variables Encoding Deviances"
			
			// Optimize the data set storage
			qui: compress
			
			// Define locals to store end of processing time data
			loc pdate `"`c(current_date)'"'
			loc ptime `"`c(current_time)'"'
			
			/* Add characteristics to the dataset detailing the retrieval and 
			clean up process. */
			qui: char def _dta[timestamp] `"Data Retrieved on `date' at `time'"'
			qui: char def _dta[rooturl] "http://www.colorbrewer2.org/"
			qui: char def _dta[filename] "colorbrewer_schemes.js"
			qui: char def _dta[citation] `"Brewer, C. A. (200x). http://www.ColorBrewer.org. Retrieved on `date'"'
			qui: char def _dta[processtime] `"Finished processing at `ptime' on `pdate'"'		
			qui: char def _dta[munged] "JavaScript Munged by brewdb"
			qui: char def _dta[brew] "brewmeta is available from the SSC Archives."
			qui: char def _dta[brew2] `"Use: "ssc inst brewscheme" to install"'
			qui: char def _dta[brew3] "Development branch available at: "
			qui: char def _dta[brew4] "https://github.com/wbuchanan/brewscheme"
			
			// Apply parser corrections
			qui: replace rgb = "0 60 48" if palette == "brbg" & pcolor == 10 & colorid == 10 
			qui: replace rgb = "106 61 154" if palette == "paired" & pcolor == 10 & colorid == 10 
			qui: replace rgb = "0 68 27" if palette == "prgn" & pcolor == 10 & colorid == 10 
			qui: replace rgb = "45 0 75" if palette == "puor" & pcolor == 10 & colorid == 10 
			qui: replace rgb = "5 48 97" if palette == "rdbu" & pcolor == 10 & colorid == 10 
			qui: replace rgb = "26 26 26" if palette == "rdgy" & pcolor == 10 & colorid == 10 
			qui: replace rgb = "49 54 149" if palette == "rdylbu" & pcolor == 10 & colorid == 10 
			qui: replace rgb = "0 104 55" if palette == "rdylgn" & pcolor == 10 & colorid == 10 
			qui: replace rgb = "94 79 162" if palette == "spectral" & pcolor == 10 & colorid == 10 
			
			// Add transformed values to the data set
			qui: brewtransform rgb
			
			// Attach a checksum to the file
			qui: datasignature set 
			
			// Save the dataset
			qui: save `"`c(sysdir_personal)'b/brewmeta.dta"', replace
			
			// Call brewextras to add additional color palettes to the data set
			qui: brewextra, replace
			
		} // End IF Block to build new look up database
		
		// If the file exists and replace was not called
		else {
		
			// Print status message to screen
			di as res `"The file : "' _n									 ///   
			`"`c(sysdir_personal)'b/brewmeta.dta"' _n						 ///   
			`"already exists and will not be rebuilt."'
			
			// Print help message to screen
			di `"To rebuild the database pass the replace option to brewscheme."'
			
		} // End ELSE Block for non over write
		
	// Bring data back into active memory
	restore
	
// End of function definition
end
