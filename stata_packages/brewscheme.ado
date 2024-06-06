********************************************************************************
* Description of the Program -												   *
* This program is a tool to facilitate Stata users developing graph schemes    *
* using research-based color palettes.  Unlike other uses of the color 		   *
* palettes developed by Brewer (see References below), this program allows 	   *
* users to specify the number of colors from any of the 35 color palettes they *
* would like to use and allows users to mix/combine different palettes for the *
* various graph types.														   *
*                                                                              *
* Data Requirements -														   *
*     none                                                                     *
*																			   *
* System Requirements -														   *
*     none                                                                     *
*                                                                              *
* Program Output -                                                             *
*     scheme-`schemename'.scheme                                               *
*                                                                              *
* Lines -                                                                      *
*     1561                                                                     *
*                                                                              *
********************************************************************************
		
*! brewscheme
*! v 1.0.0
*! 21MAR2016

// Drop the program from memory if loaded
cap prog drop brewscheme

// Define the program as an rclass program
prog def brewscheme, rclass

	// Specify the version number
	version 13.1

	// Define the syntax structure of the program
	syntax , SCHEMEname(string asis)										 ///   
		[ ALLSTyle(string asis) ALLColors(real 3) ALLSATuration(real 100)	 ///    
		BARSTyle(string asis) BARColors(real 3) BARSATuration(real 100)		 ///   
		SCATSTyle(string asis) SCATColors(real 3) SCATSATuration(real 100)	 ///
		AREASTyle(string asis) AREAColors(real 3) AREASATuration(real 100)	 ///
		LINESTyle(string asis) LINEColors(real 3) LINESATuration(real 100)	 ///
		BOXSTyle(string asis) BOXColors(real 3) BOXSATuration(real 100)		 ///
		DOTSTyle(string asis) DOTColors(real 3) DOTSATuration(real 100)		 ///
		PIESTyle(string asis) PIEColors(real 3) PIESATuration(real 100)		 ///
		SUNSTyle(string asis) SUNColors(real 4) SUNSATuration(real 100)		 ///
		HISTSTyle(string asis) HISTColors(real 3) HISTSATuration(real 100)	 ///
		CISTyle(string asis) CIColors(real 3) CISATuration(real 100)		 ///
		MATSTyle(string asis) MATColors(real 3) MATSATuration(real 100)		 ///
		REFLSTyle(string asis) REFLColors(real 3) REFLSATuration(real 100)	 ///
		REFMSTyle(string asis) REFMColors(real 3) REFMSATuration(real 100) 	 ///   
		CONSTart(string asis) CONEnd(string asis) CONSATuration(real 100)	 ///   
		SOMESTyle(string asis) SOMEColors(real 3) SOMESATuration(real 100)	 ///   
		REPlace DBug THEMEFile(string asis) SYMBols(string asis) ]
		
		// Check for brewscheme Mata library
		qui: brewlibcheck
	
		// Define local with valid symbols arguments
		loc validsymbols circle diamond triangle square plus smcircle 		 ///   
		smdiamond smsquare smtriangle smplus smx circle_hollow				 ///   
		diamond_hollow triangle_hollow square_hollow smcircle_hollow 		 ///   
		smdiamond_hollow smtriangle_hollow smsquare_hollow point none
		
		// Check for symbols argument
		if `"`symbols'"' != "" {
		
			// Get the number of symbols passed
			loc numsymbols `: word count `symbols''
			
			// Loop over symbols
			forv i = 1/`numsymbols' {
			
				// Get the individual symbol argument
				loc thissymbol `: word `i' of `symbols''
				
				// Check if valid symbol
				if `: list thissymbol in validsymbols' == 0 {
				
					// Display error message in the console
					di as err `"The argument `thissymbol' passed to the "'   ///   
					"symbols parameter is invalid.  Must be one of "'		 ///   
					`"`: subinstr loc validsymbols `" "' `", "', all'."'	
					
					// Issue generic error code
					err 198
					
				} // End IF Block for argument validation
			
			} // End Loop over symbols arguments for validation
		
		} // End IF Block to validate symbol arugments
		
		// If no argument passed default to circle
		else {
		
			// Set number of symbols local
			loc numsymbols = 1
		
			// Set symbols to default to circle
			loc symbols circle
			
		} // End ELSE Block for null symbols parameter

		// Preserve data currently loaded in memory
		preserve
		
			// Check for directory and if not build it	
			dirfile, p(`"`c(sysdir_personal)'b"') 
			
			// Check for subdirectory used for storing scheme files
			dirfile, p(`"`c(sysdir_plus)'s"')

			// Check for the metadata dataset
			cap confirm new file `"`c(sysdir_personal)'b/brewmeta.dta"'

			// If file doesn't exist
			if inlist(_rc, 0, 603) {
			
				// Call brewmeta to build lookup data set
				qui: brewdb, `replace'
				
				// Load the lookup table
				qui: use `"`c(sysdir_personal)'b/brewmeta.dta"', clear			
				
			} // End IF Block to build look up data set
			
			// Check for file
			cap confirm new file `"`c(sysdir_personal)'b/brewmeta.dta"'
				
			// If file doesn't exist
			if inlist(_rc, 0, 603) | "`replace'" != "" {
			
				// Call brewmeta to build lookup data set
				qui: brewdb, `replace'
				
				// Load the lookup table
				qui: use `"`c(sysdir_personal)'b/brewmeta.dta"', clear			
				
			} // End IF Block to build look up data set
			
			// If the file exists load it
			else {
				
				// Load the lookup table
				qui: use `"`c(sysdir_personal)'b/brewmeta.dta"', clear

			} // End ELSE Block to load brewmeta file
			
			// Get acceptable palette names
			qui: levelsof palette, loc(palettes)
			
			// Initialize a new brewcolors class
			qui: mata: brewc = brewcolors()
			
			// Loop over the palette names
			foreach v of loc palettes {
			
				// Get the maximum number of colors available in the palette
				qui: su maxcolors if palette == `"`v'"', meanonly
				
				// Store in the macro with the name of the palette followed by c
				loc `v'c = `r(mean)'
				
			} // End Loop to get maximum number of colors per palette
			
			// Set local with the graph type stub names
			loc gr1 bar scat area line con box dot pie
			loc gr2 sun hist ci mat refl refm
			loc grstyles `gr1' `gr2'
			
			/* Validate arguments (if all graph types are null, an all parameter 
			must be specified */
			if mi("`barstyle'") & mi("`scatstyle'") & mi("`areastyle'") & 	 ///   
			mi("`linestyle'") & mi("`constart'") & mi("`boxstyle'") & 		 ///  
			mi("`dotstyle'") & mi("`piestyle'") & mi("`sunstyle'") & 		 ///   
			mi("`histstyle'") & mi("`cistyle'") & mi("`matstyle'") & 		 ///   
			mi("`reflstyle'") & mi("`refmstyle'") & mi("`allstyle'") & 		 ///   
			mi("`conend'") {
			
				// Print error message to the screen
				di as err "Must include either arguments for the all "		 ///   
				"parameters or use a combination of graph type arguments and "	 ///   
				"some arguments to provide default colors to the other graph types"
				
				// Kill the program
				exit	
				
			} // End IF Block for valid arguments
			
			// If all the graph styles are missing and an all style is specified
			else if mi("`barstyle'") & mi("`scatstyle'") & mi("`areastyle'") & 	 ///   
			mi("`linestyle'") & mi("`boxstyle'") & mi("`dotstyle'") & 		 ///   
			mi("`piestyle'") & mi("`sunstyle'") & mi("`histstyle'") & 		 ///   
			mi("`cistyle'") & mi("`matstyle'") & mi("`reflstyle'") & 		 ///   
			mi("`refmstyle'") & mi("`constart'") & mi("`conend'") & 		 ///   
			!mi("`allstyle'")  {

				// Checks the saturation values and returns valid value if 
				// invalid argument is passed
				checkSat, int(`allsaturation')
				
				// Resets the local to the corrected value
				loc allsaturation = `r(saturation)'

				// Set the style parameters for all graph types to the values in the 
				// all parameters
				if `allcolors' <= ``allstyle'c' {
				
					// Check to see if all style was an available palette
					if `: list allstyle in palettes' != 1 {
					
						// Let user know valid values
						di as err `"Styles arguments must be one of: `palettes'"'
						
						// Exit program
						exit
						
					} // End IF Block to check for valid color palette
					
					// Loop over graph types and assign the all styles to them
					foreach stile in "bar" "scat" "area" "line" "box" 		 ///   
						"dot" "pie" "sun" "hist" "ci" "mat" "refl" "refm" {
						
						/* Assign the all style, color, and saturation levels to the 
						individual graph types. */
						loc `stile'style `allstyle'
						loc `stile'colors  `allcolors'
						loc `stile'saturation  `allsaturation'

					} // End Loop over graph types
					
					// Sets the palette for the starting color for contourplots
					loc constart `allstyle'
					
					// Sets the palette for the ending color for contourplots
					loc conend `allstyle'
					
				} // End IF Block to check if the # of colors is valid for the style

				// If the user selected more colors than available in the palette
				else {
				
					// Print error message to the screen
					di as err `"More colors (`allcolors') than "'			 ///   
					`"available (``allstyle'c') in the palette `allstyle'"'
					
					// Kill the program
					exit
					
				} // End ELSE Block for # colors > available colors
				
			} // End ELSEIF Block for missing graph styles with nonmissing all style
			
			// If missing some arguments make sure some parameters have values
			else if ("`barstyle'" == "" |  "`scatstyle'" == "" |   		     ///   
				"`areastyle'" == "" |  "`linestyle'" == "" |  		    	 ///   
				"`boxstyle'" == "" |  "`dotstyle'" == "" |					 ///
				"`piestyle'" == "" |  "`sunstyle'" == "" |   		    	 ///   
				"`histstyle'" == "" |  "`cistyle'" == "" |  		    	 ///   
				"`matstyle'" == "" | "`reflstyle'" == "" |  		   		 ///   
				"`refmstyle'" == "" | "`constart'" == "" | "`conend'" == "") & 	 ///   
				"`somestyle'" == "" {
				
				// If missing some graph type styles must include defaults in some
				di as err "Must include arguments for somestyle if missing graph types"
				
				// Kill program
				exit	
				
			} // End ELSEIF Block for missing types w/o some argument
			
			// If missing some graph types and defaults provided
			else if ("`barstyle'" == "" |  "`scatstyle'" == "" |   		     ///   
				"`areastyle'" == "" |  "`linestyle'" == "" |  		    	 ///   
				"`boxstyle'" == "" |  "`dotstyle'" == "" |					 ///
				"`piestyle'" == "" |  "`sunstyle'" == "" |   		    	 ///   
				"`histstyle'" == "" |  "`cistyle'" == "" |  		    	 ///   
				"`matstyle'" == "" | "`reflstyle'" == "" |  		   		 ///   
				"`refmstyle'" == "" | "`constart'" == "" | "`conend'" == "") & 	 ///   
				"`somestyle'" != "" {
				
				// Check to see if some style was an available palette
				if `: list somestyle in palettes' != 1 {
												
					// Let user know valid values
					di as err "Styles arguments must be one of: " _n `"`palettes'"'
					
					// Exit program
					exit
					
				} // End IF Block to check for valid color palette
				
				// Tests the saturation value for the some option
				checkSat, int(`somesaturation')
				
				// Returns the corrected values to the same local
				loc somesaturation = `r(saturation)'
				
				// If more colors specified for default than available
				if `somecolors' > ``somestyle'c' & `somecolors' != . {
					
					// Print error message to screen
					di as err `"More colors (``stile'colors') than "'	 ///   
					`"available (``stile'style') in the palette "' 		 ///  
					`""`stile'style" = ``somestyle'c'"'
					
					// Kill the program
					err 198
					
				} // End ELSEIF Block for # colors > available for defaults
	
				// Loop over # available colors per graph
				foreach stile in `grstyles' {
					
					// Check contour plot scheme arguments
					if `"``stile'start'"' == "" loc constart "`somestyle'"
					if `"``stile'end'"' == "" loc conend "`somestyle'"
						
					// If the style is missing and valid # colors for default
					if "``stile'style'" == "" {
							
						// Assign the default styles to the graph type
						loc `stile'style "`somestyle'"
						loc `stile'colors `somecolors'
						loc `stile'saturation `somesaturation'
							
					} // End IF Block for unspecified graphs
							
					// If the graph type has a style specified
					else {
						
						// Check to see if there are the requested number of colors
						if ``stile'colors' > ```stile'style'c' {
						
							// If not print error to screen
							di as err `"Too many colors specified in "' 	 ///   
							`"`stile'colors(``stile'colors') for the "'		 ///   
							`"``stile'style' palette."' _n 					 ///   
							`"Maximum number of colors allowed is ```stile'style'c'"'
							
							// Issue error code and exit
							err 198
							
						} // End IF Block for more colors than available
						
						// If there are an appropriate number of colors requested
						else {
							
							// Check the saturation values
							checkSat, int(``stile'saturation')

							// And replace the passed argument with the validated value
							loc `stile'saturation = `r(saturation)'
							
						} // End ELSE Block for sufficient colors
						
					} // End ELSE Block for graphs with specified color palettes
					
				} // End Loop over graph types
						
			} // End ELSEIF Block for valid parameters
			
			// For cases where all styles are specified
			else {
			
				// Loop over # available colors per graph
				foreach stile in `grstyles' {
				
					// Skip over contour plot case
					if `"`stile'"' == "con" continue
					
					// Check to see if there are the requested number of colors
					else if ``stile'colors' > ```stile'style'c' {
					
						// If not print error to screen
						di as err `"Too many colors specified in "' 	 ///   
						`"`stile'colors(``stile'colors') for the "'		 ///   
						`"``stile'style' palette."' _n 					 ///   
						`"Maximum number of colors allowed is ```stile'style'c'"'
						
						// Issue error code and exit
						err 198
						
					} // End ELSEIF Block for more colors than available
					
					// If there are an appropriate number of colors requested
					else {
						
						// Check the saturation values
						checkSat, int(``stile'saturation')

						// And replace the passed argument with the validated value
						loc `stile'saturation = `r(saturation)'
						
					} // End ELSE Block for sufficient colors
					
				} // End Loop over graph types
				
			} // End ELSE Block for cases with all graph types specified	
			
			// Line saturation gets defined as a color multiplier
			// loc linesaturation = `linesaturation'/100
			
			// Dot plot saturation is defined as a color multiplier
			// loc dotsaturation = `dotsaturation'/100
								
			// Scatterplot saturation gets defined as a color multiplier
			// loc scatsaturation = `scatsaturation'/100
			
			// Use a tempname for the scheme file filehandle
			tempname scheme1 scheme2 scheme3 scheme4 scheme5 
			
			// Root file path to theme files
			loc themeroot `"`c(sysdir_personal)'b/theme/theme"'
					
			// Root file path for brewscheme created scheme files
			loc schemeroot `"`c(sysdir_plus)'/s/scheme"'
								
			// Write the scheme file to a location on the path
			qui: file open `scheme1' using `"`schemeroot'-`schemename'.scheme"', w replace
			qui: file open `scheme2' using 					 ///   
			`"`schemeroot'-`schemename'_achromatopsia.scheme"', w replace
			qui: file open `scheme3' using						 ///   
			`"`schemeroot'-`schemename'_protanopia.scheme"', w replace
			qui: file open `scheme4' using						 ///   
			`"`schemeroot'-`schemename'_deuteranopia.scheme"', w replace
			qui: file open `scheme5' using						 ///   
			`"`schemeroot'-`schemename'_tritanopia.scheme"', w replace

			// Find maximum number of colors to set the recycle parameter
			loc pcycles = max(	`barcolors', `scatcolors', `areacolors',	 ///   
								`linecolors', `boxcolors', `dotcolors', 	 ///   
								`piecolors', `suncolors', `histcolors', 	 ///   
								`cicolors', `matcolors', `reflcolors', 		 ///   
								`refmcolors')
								
			// Recycle the number of symbols
			qui: mata: recycle(`numsymbols', `pcycles')
			
			// Loop over the sequence of symbols
			foreach symb in `sequence' {
			
				// Build a string with each of the symbols corresponding to the 
				// appropriate cycle number
				loc symbolseq `"`symbolseq' "`: word `symb' of `symbols''""'
				
			} // End Loop over symbol sequence
			
			// Check to see if start and end contour color palettes are the same
			if `"`constart'"' == `"`conend'"' {
				
				// Get version of palette w/minimum number of colors
				qui: su pcolor if palette == `"`constart'"'
				
				// Get the first value from the palette as the start of the contour
				qui: levelsof rgb if palette == `"`constart'"' & 			 ///   
				pcolor == `r(min)', loc(cstart)
				
				// Overwrite the local macro with the RGB value
				loc constart `: word 1 of `cstart''

				// Overwrite the local macro with the RGB value
				loc conend `: word 2 of `cstart''
				
			} // End IF Block for case where contour start/end use same palette	

			// If they use different palettes 
			else {
			
				// Get version of palette with minimum number of colors for start
				qui: su pcolor if palette == `"`constart'"'
				
				// Get the first value from the palette as the start of the contour
				qui: levelsof rgb if palette == `"`constart'"' & 			 ///   
				pcolor == `r(min)', loc(cstart)
				
				// Overwrite the local macro with the RGB value
				loc constart `: word 1 of `cstart''

				// Get version of palette with minimum number of colors for start
				qui: su pcolor if palette == `"`conend'"'
				
				// Get the first value from the palette as the end of the contour
				qui: levelsof rgb if palette == `"`conend'"' & 				 ///   
				pcolor == `r(min)', loc(cend)
							
				// Overwrite the local macro with the RGB value second word used here 
				// to prevent same color issue if the allstyle option is used.
				loc conend `: word 2 of `cend''			

			} // End ELSE Block for separate start/end contour palettes
			
			// Recycle the number of symbols
			qui: mata: recycle(`numsymbols', `pcycles')
			
			// Loop over the sequence of symbols
			foreach symb in `sequence' {
			
				// Build a string with each of the symbols corresponding to the 
				// appropriate cycle number
				loc symbolseq `"`symbolseq' "`: word `symb' of `symbols''""'
				
			} // End Loop over symbol sequence
			
			// Loop over color macros
			foreach color in bar scat area line box dot pie hist ci mat		 ///   
			refl refm sun {
			
				/* Create the sequence of color ids for each graph type based on 
				the maximum number of colors in any listed color argument. */
				qui: mata: recycle(``color'colors', `pcycles')
				
				// Assign the id sequence to a local with seq as suffix
				loc `color'seq = `"`sequence'"'
				
				// Get RGB values for a given palette and max colors
				qui: levelsof rgb if palette == "``color'style'" & 			 ///   
				pcolor == ``color'colors', loc(rgbs)
				
				// If the RGB value macro is null get the values for the maxmimum
				// number of colors available for the palette
				if `"`rgbs'"' == "" {
				
					// Gets the same palette but with the maximum number of colors
					qui: levelsof rgb if palette == "``color'style'" &		 ///   
					pcolor == ```color'style'c', loc(rgbs)
					
				} // End IF Block for palettes that only have a single set of colors	

				// Developer option to print debug messages
				if "`dbug'" != "" {
					
					// Prints the graph type with data that follows
					di "Graph type = `color'"
					
					// Print debugging message
					di "Color: `color'" _n "Number of colors: ``color''" _n  ///   
					`"Color sequence: ``color'seq'"'
				
				} // End Debug messages
				
				// Loop over the rgb values to construct the graph specific  
				// rgb values
				foreach c of loc `color'seq {
				
					// Construct macro with RGB values for lookup
					loc `color'rgb `"``color'rgb' "`: word `c' of `rgbs''" "'
					
				} // End Loop
				
				// Create marker for graph type with maximum number of colors
				if ``color'colors' == `pcycles' {
				
					// Set the generic color macro to reference macro w/max colors
					loc gencolor `"``color'rgb'"'
					
				} // End of IF Block to define generic color macro	
			
				// Check for debug option
				if "`dbug'" != "" {
									
					// Print the RGB color string to screen
					di `"``color'rgb'"'
				
				} // End debug option
				
			} // End Loop over number of colors for graph types	
			
			// Stubs to use for line references to theme files
			loc linerefs theme1 theme2 theme3 theme4 theme5

			// Tempnames
			tempname theme1 theme2 theme3 theme4 theme5

			// Check for theme file
			if `"`themefile'"' != "" {

				// Themefile names
				loc themerefs `"`themeroot'-`themefile'.theme"'				 ///   
				`"`themeroot'-`themefile'_achromatopsia.theme"'				 ///   
				`"`themeroot'-`themefile'_protanopia.theme"'				 ///   
				`"`themeroot'-`themefile'_deuteranopia.theme"'				 ///   
				`"`themeroot'-`themefile'_tritanopia.theme"'

				// Loop over theme files
				forv thf = 1/5 {
				
					// Open the first file
					file open `theme`thf'' using `"`: word `thf' of `"`themerefs'"''"', r
						
					// zero value local macro
					loc x = 1
						
					// Read the first line of the file
					file read `theme`thf'' theme`thf'_`x'	

					// Loop until end of file
					while r(eof) == 0 {
					
						// Increment line counter
						loc x = `x' + 1
						
						// Read line into local macro
						file read `theme`thf'' theme`thf'_`x'
					
					} // End Loop over theme file
					
					// Close the file connection
					file close `theme`thf''
				
				} // End Loop over themefiles
			
			} // End IF Block for user specified theme file
			
			// If user does not specify a file
			else {
			
				// Check for default file
				cap confirm file `"`themeroot'-default.theme"'
			
				// If the default file exists
				if _rc != 0 {

					// Create the default brewtheme files
					qui: brewtheme
			
				} // End IF Block to open a connection to the default theme
				
				// Themefile names
				loc themerefs `"`themeroot'-default.theme"'					 ///   
				`"`themeroot'-default_achromatopsia.theme"'					 ///   
				`"`themeroot'-default_protanopia.theme"'					 ///   
				`"`themeroot'-default_deuteranopia.theme"'					 ///   
				`"`themeroot'-default_tritanopia.theme"'

				// Loop over theme files
				forv thf = 1/5 {
				
					// Open the first file
					file open `theme`thf'' using `"`: word `thf' of `"`themerefs'"''"', r
						
					// zero value local macro
					loc x = 1
					
					// Read the first line of the file
					file read `theme`thf'' theme`thf'_`x'	

					// Loop until end of file
					while r(eof) == 0 {
					
						// Increment line counter
						loc x = `x' + 1
						
						// Read line into local macro
						file read `theme`thf'' theme`thf'_`x'
						
					} // End Loop over theme file
					
					// Close the file connection
					file close `theme`thf''
				
				} // End Loop over themefiles
						
			} // End ELSE Block for null theme file
			
			// Name extension macros
			loc nameext "" "_achromatopsia" "_protanopia" "_deuteranopia" "_tritanopia"
			
			// Loop over the theme/scheme file pairs
			forv j = 1/5 {
			
				// Correction for schemenames
				if `j' == 1  loc schemelabel `"label "`schemename'""'

				// For all other cases
				else loc schemelabel `"label "`schemename'`: word `j' of `nameext''""'
				
				file write `scheme`j'' `"*                                    s2color.scheme"' _n
				file write `scheme`j'' `""' _n
				file write `scheme`j'' `"* s2 scheme family with a naturally white background (white plotregions and"' _n
				file write `scheme`j'' `"* lightly colored background) and color foreground (lines, symbols, text, etc)."' _n
				file write `scheme`j'' `""' _n
				file write `scheme`j'' `"*  For p[#][stub] scheme references the corresponding style is resolved by"' _n
				file write `scheme`j'' `"*  searching the scheme ids with the following preference ordering:"' _n
				file write `scheme`j'' `"*"' _n
				file write `scheme`j'' `"*                p#stub"' _n
				file write `scheme`j'' `"*                pstub"' _n
				file write `scheme`j'' `"*                p#"' _n
				file write `scheme`j'' `"*                p"' _n
				file write `scheme`j'' `"*"' _n
				file write `scheme`j'' `"*  Thus it is possible to control the selected style to great detail, or let it"' _n
				file write `scheme`j'' `"*  default to common defaults.  In particular -p- or -pstub- without"' _n
				file write `scheme`j'' `"*  # can be used to designate a common plotting symbol, or back plotting"' _n
				file write `scheme`j'' `"*  symbol, or for that matter common color or sizes."' _n
				file write `scheme`j'' `"*"' _n
				file write `scheme`j'' `"*  "style"s designated "special" are not styles at all, but direct signals to"' _n
				file write `scheme`j'' `"*  graphs, plots, or other classes and their parsers.  Their contents are"' _n
				file write `scheme`j'' `"*  specific to the use and may only be understood by the caller."' _n
				file write `scheme`j'' `""' _n
				file write `scheme`j'' `"*!  version 1.2.5   16jun2011"' _n(2)
				file write `scheme`j'' `"sequence 1299"' _n
				file write `scheme`j'' `"`schemelabel'"' _n(2)
				file write `scheme`j'' `"system   naturally_white  1"' _n(3)

				// Loop over first 10 lines of theme file
				forv i = 1/10 {
				
					// Write each line to the scheme file
					file write `scheme`j'' `theme`j'_`i''
				
				} // End Loop over lines 1-10 of theme file
						
				file write `scheme`j'' `"numstyle pcycle           `pcycles'"' _n(2)
				
				// Loop over lines 11-16 of the theme file
				forv i = 11/16 {
				
					// Write each line to the scheme file
					file write `scheme`j'' `theme`j'_`i''
					
				} // End loop over lines 11-16 of the theme file
				
				file write `scheme`j'' `"numstyle contours         `pcycles'"' _n(2)
						
				// Loop over lines 17-179 of the theme file
				forv i = 17/179 {
				
					// Write each line to the scheme file
					file write `scheme`j'' `theme`j'_`i''
					
				} // End loop over lines 17-179 of the theme file
			
			} // End Loop over scheme/theme file pairs
			
			// Local with color type refs
			loc ctyperefs rgb achromatopsia protanopia deuteranopia tritanopia
			
			// Get the area1 rgb values
			mata: brewc.brewColorSearch("`: word 1 of `areargb''")
			
			// Loop over macros
			forv rfs = 1/5 {
			
				// Store all the translated RGB values
				loc ci_area`rfs' ``: word `rfs' of `ctyperefs'''

			} // End Loop over macro reassignments
			
			// Get the cysymbol rgb values
			mata: brewc.brewColorSearch("`: word 1 of `cirgb''")
			
			// Loop over macros
			forv rfs = 1/5 {
			
				// Store all the translated RGB values
				loc ci_symbol`rfs' ``: word `rfs' of `ctyperefs'''

			} // End Loop over macro reassignments
			
			// Get the area1 rgb values
			mata: brewc.brewColorSearch("`: word 2 of `areargb''")
			
			// Loop over macros
			forv rfs = 1/5 {
			
				// Store all the translated RGB values
				loc ci2_area`rfs' ``: word `rfs' of `ctyperefs'''

			} // End Loop over macro reassignments
			
			// Get the cysymbol rgb values
			mata: brewc.brewColorSearch("`: word 2 of `cirgb''")
			
			// Loop over macros
			forv rfs = 1/5 {
			
				// Store all the translated RGB values
				loc ci2_symbol`rfs' ``: word `rfs' of `ctyperefs'''

			} // End Loop over macro reassignments		
			
			// Search for histogram color
			mata: brewc.brewColorSearch("`: word 1 of `histrgb''")
			
			// Loop over macros
			forv rfs = 1/5 {
			
				// Store all the translated RGB values
				loc histogram`rfs' ``: word `rfs' of `ctyperefs'''

			} // End Loop over macro reassignments		
			
			// Search for generic sunflower plot color
			mata: brewc.brewColorSearch("`: word 1 of `sunrgb''") 

			// Loop over macros
			forv rfs = 1/5 {
			
				// Store all the translated RGB values
				loc sunflower`rfs' ``: word `rfs' of `ctyperefs'''

			} // End Loop over macro reassignments		
			
			// Search for generic light flower
			mata: brewc.brewColorSearch("`: word 2 of `sunrgb''") 

			// Loop over macros
			forv rfs = 1/5 {
			
				// Store all the translated RGB values
				loc sunflowerlf`rfs' ``: word `rfs' of `ctyperefs'''

			} // End Loop over macro reassignments		

			// Search for generic dark flower
			mata: brewc.brewColorSearch("`: word 3 of `sunrgb''") 

			// Loop over macros
			forv rfs = 1/5 {
			
				// Store all the translated RGB values
				loc sunflowerdf`rfs' ``: word `rfs' of `ctyperefs'''

			} // End Loop over macro reassignments	
			
			// Search for contour start values
			mata: brewc.brewColorSearch("`constart'")
			
			// Store the contour start values
			forv rfs = 1/5 {
			
				// Index values like other graph types
				loc constart`rfs' ``: word `rfs' of `ctyperefs'''

			} // End Loop over contour plot starting values
			
			// Search for contour end values
			mata: brewc.brewColorSearch("`conend'")
			
			// Store the contour end values
			forv rfs = 1/5 {
			
				// Index values like other graph types
				loc conend`rfs' ``: word `rfs' of `ctyperefs'''

			} // End Loop over contour plot ending values
				
			// Loop over scheme/theme file pairs
			forv j = 1/5 {
			
				file write `scheme`j'' `"color ci_line        "0 0 0""' _n
				file write `scheme`j'' `"color ci_arealine    "0 0 0""' _n
				file write `scheme`j'' `"color ci_area        "`ci_area`j''" "' _n
				file write `scheme`j'' `"color ci_symbol      "`ci_symbol`j''" "' _n
				file write `scheme`j'' `"color ci2_line       "0 0 0""' _n
				file write `scheme`j'' `"color ci2_arealine   "0 0 0""' _n
				file write `scheme`j'' `"color ci2_area       "`ci2_area`j''" "' _n
				file write `scheme`j'' `"color ci2_symbol     "`ci2_symbol`j''" "' _n(2)
				
				file write `scheme`j'' `"color pieline        "0 0 0""' _n(2)
			
				// Writes line 180 from the theme file
				file write `scheme`j'' `theme`j'_180'
						
				// Writes line 181 from the theme file
				file write `scheme`j'' `theme`j'_181'
				
				file write `scheme`j'' `"color refmarker      "0 0 0""' _n
				file write `scheme`j'' `"color refmarkline    "0 0 0""' _n
				file write `scheme`j'' `"color histogram      "`histogram`j''" "' _n

				// Writes line 182 from the theme file
				file write `scheme`j'' `theme`j'_182'
				
				file write `scheme`j'' `"color histogram_line "0 0 0""' _n
				file write `scheme`j'' `"color dot_line       "0 0 0""' _n
				file write `scheme`j'' `"color dot_arealine   "0 0 0""' _n
				file write `scheme`j'' `"color dot_area       "`ci_area`j''" "' _n
				file write `scheme`j'' `"color dotmarkline    "0 0 0""' _n(2)
				
				file write `scheme`j'' `"color xyline         "0 0 0""' _n
				file write `scheme`j'' `"color refline        "0 0 0""' _n
				file write `scheme`j'' `"color dots           "0 0 0""' _n(2)
				
				// Loop over lines 183-192 of the theme file
				forv i = 183/192 {
				
					// Write each line to the scheme file
					file write `scheme`j'' `theme`j'_`i''
					
				} // End loop over lines 183-192 of the theme file
				
				// Check for values for starting/ending contour plots
				if "`constart`j''" == "" {
					loc constart purple
				} 
				if "`conend`j''" == "" {
					loc conend orange
				}
			
				file write `scheme`j'' `"color contour_begin "`constart`j''""' _n
				file write `scheme`j'' `"color contour_end "`conend`j''""' _n
				file write `scheme`j'' `"color zyx2 "0 0 0""' _n(2)
			
				file write `scheme`j'' `"color sunflower "`sunflower`j''""' _n
				file write `scheme`j'' `"color sunflowerlb "0 0 0""' _n
				file write `scheme`j'' `"color sunflowerlf "`sunflowerlf`j''""' _n
				file write `scheme`j'' `"color sunflowerdb "0 0 0""' _n
				file write `scheme`j'' `"color sunflowerdf "`sunflowerdf`j''""' _n(2)
				file write `scheme`j'' `"color p       gs6"' _n
				
			} // End Loop over theme/scheme pairs
			
			/* Add generic color loop here */
			forv i = 1/`: word count `gencolor'' {

				// Look up color value
				mata: brewc.brewColorSearch("`: word `i' of `gencolor''")
			
				// Loop over macros / theme/scheme file pairs
				forv rfs = 1/5 {
				
					// Add entry to scheme files
					file write `scheme`rfs'' `"color p`i' "``: word `rfs' of `ctyperefs'''""' _n

				} // End Loop over theme/scheme file pairs
				
			} // End Loop for generic colors
			
			// Loop over theme/scheme file pairs
			forv j = 1/5 {
			
				// Write blank line to scheme file
				file write `scheme`j'' `""' _n
				
				// Loop over lines 193-331 of the theme file
				forv i = 193/331 {
				
					// Write each line to the scheme file
					file write `scheme`j'' `theme`j'_`i''
					
				} // End loop over lines 193-331 of the theme file
				
				file write `scheme`j'' `"markerstyle p1"' _n
				file write `scheme`j'' `"markerstyle dots dots"' _n
				file write `scheme`j'' `"markerstyle star star"' _n
				file write `scheme`j'' `"markerstyle histogram histogram"' _n
				file write `scheme`j'' `"markerstyle ci ci"' _n
				file write `scheme`j'' `"markerstyle ci2 ci2"' _n
				file write `scheme`j'' `"markerstyle ilabel ilabel"' _n
				file write `scheme`j'' `"markerstyle matrix matrix"' _n
				file write `scheme`j'' `"markerstyle box_marker refmarker"' _n
				file write `scheme`j'' `"markerstyle editor editor"' _n
				file write `scheme`j'' `"markerstyle editor_arrow ed_arrow"' _n
				file write `scheme`j'' `"markerstyle sunflower sunflower"' _n(2)
				
				// Write generic marker styles
				foreach i in "" "box" "dot" "arrow" {
				
					// Loop over cycle numbers
					forv v = 1/`pcycles' {
					
						// Add entry to scheme file
						file write `scheme`j'' `"markerstyle p`v'`i'  p`v'`i'"' _n
					
					} // End Loop over cycle number
					
					// Write blank line between each of the types
					file write `scheme`j'' `""' _n
				
				} // End Loop over marker style generic types

				// Add extra space after p#arrow
				file write `scheme`j'' `""' _n
			
				// Loop over lines 332-382 of the theme file
				forv i = 332/382 {
				
					// Write each line to the scheme file
					file write `scheme`j'' `theme`j'_`i''

				} // End loop over lines 332-382 of the theme file
			
				// Shade/fill settings
				file write `scheme`j'' `"shadestyle foreground"' _n
				file write `scheme`j'' `"shadestyle background background"' _n
				file write `scheme`j'' `"shadestyle foreground foreground"' _n(2)
				file write `scheme`j'' `"shadestyle ci ci"' _n
				file write `scheme`j'' `"shadestyle ci2 ci2"' _n
				file write `scheme`j'' `"shadestyle histogram histogram"' _n
				file write `scheme`j'' `"shadestyle dendrogram dendrogram"' _n
				file write `scheme`j'' `"shadestyle dotchart dotchart"' _n
				file write `scheme`j'' `"shadestyle legend legend"' _n
				file write `scheme`j'' `"shadestyle clegend_outer clegend_outer"' _n
				file write `scheme`j'' `"shadestyle clegend_inner clegend_inner"' _n
				file write `scheme`j'' `"shadestyle clegend_preg none"' _n
				file write `scheme`j'' `"shadestyle plotregion plotregion"' _n
				file write `scheme`j'' `"shadestyle matrix_plotregion matrix_plotregion"' _n
				file write `scheme`j'' `"shadestyle sunflower sunflower"' _n
				file write `scheme`j'' `"shadestyle sunflowerlb sunflowerlb"' _n
				file write `scheme`j'' `"shadestyle sunflowerdb sunflowerdb"' _n
				file write `scheme`j'' `"shadestyle contour_begin contour_begin"' _n
				file write `scheme`j'' `"shadestyle contour_end contour_end"' _n(2)
				file write `scheme`j'' `"shadestyle p foreground"' _n(2)
				
				// Write generic marker styles
				foreach i in "" "bar" "box" "pie" "area" {
				
					// Loop over cycle numbers
					forv v = 1/`pcycles' {
					
						// Add entry to scheme file
						file write `scheme`j'' `"shadestyle p`v'`i'  p`v'`i'"' _n
					
					} // End Loop over cycle number
					
					// Spaces between graph types
					if "`i'" != "area" {
					
						// Write blank line between each of the types
						file write `scheme`j'' `""' _n

					} // End IF Block for other graphtypes
					
					// For area shade styles
					else {
					
						// This line files final area entry
						file write `scheme`j'' `"* shadestyle p#other  p1"' _n(3)
						
					} // End Else Block for area shade styles
						
				} // End Loop over marker style generic types

				// Loop over lines 383-434 of the theme file
				forv i = 383/434 {
				
					// Write each line to the scheme file
					file write `scheme`j'' `theme`j'_`i''
					
				} // End loop over lines 383-434 of the theme file
				
				// Write generic marker styles
				foreach i in "" "bar" "box" "area" "line" "other" "mark" 		 ///   
				"boxmark" "dotmark" "arrow" "arrowline" "sunflowerlight" 		 ///   
				"sunflowerdark" {
				
					// Loop over cycle numbers
					forv v = 1/`pcycles' {

						// Check for sunflower cases
						if !inlist(`"`i'"', "sunflowerlight", "sunflowerdark") {

							// Add entry to scheme file
							file write `scheme`j'' `"linestyle p`v'`i'  p`v'`i'"' _n
						
						} // End If Block for non sunflower plots
						
						// For the sunflower caes
						else {
						
							// Use the generic line style for the sunflower plots
							file write `scheme`j'' `"linestyle p`v'`i' p`v'"' _n
						
						} // End ELSE Block for sunflower plots
						
					} // End Loop over cycle number
					
					// Write blank line between each of the types
					file write `scheme`j'' `""' _n

				} // End Loop over marker style generic types
				
				// Loop over lines 435-494 of the theme file
				forv i = 435/494 {
				
					// Write each line to the scheme file
					file write `scheme`j'' `theme`j'_`i''
					
				} // End loop over lines 435-494 of the theme file
			
				// Settings for color saturation
				file write `scheme`j'' `"intensity            full"' _n
				file write `scheme`j'' `"intensity foreground inten100"' _n
				file write `scheme`j'' `"intensity background inten100"' _n(2)
				file write `scheme`j'' `"intensity symbol     inten`scatsaturation'"' _n
				file write `scheme`j'' `"intensity ci_area    inten`cisaturation'"' _n
				file write `scheme`j'' `"intensity histogram  inten`histsaturation'"' _n
				file write `scheme`j'' `"intensity dendrogram inten`linesaturation'"' _n
				file write `scheme`j'' `"intensity dot_area   inten`dotsaturation'"' _n
				file write `scheme`j'' `"intensity sunflower  inten`sunsaturation'"' _n(2)
				file write `scheme`j'' `"intensity bar        inten`barsaturation'"' _n
				file write `scheme`j'' `"intensity bar_line   inten`linesaturation'"' _n
				file write `scheme`j'' `"intensity box        inten`boxsaturation'"' _n
				file write `scheme`j'' `"intensity box_line   inten`linesaturation'"' _n
				file write `scheme`j'' `"intensity pie        inten`piesaturation'"' _n(2)
				file write `scheme`j'' `"intensity legend     inten100"' _n
				file write `scheme`j'' `"intensity plotregion inten100"' _n
				file write `scheme`j'' `"intensity matrix_plotregion inten`matsaturation'"' _n(2)
				file write `scheme`j'' `"intensity clegend       inten100"' _n
				file write `scheme`j'' `"intensity clegend_outer inten100"' _n
				file write `scheme`j'' `"intensity clegend_inner inten100"' _n(3)
				file write `scheme`j'' `"intensity p          inten`scatsaturation'"' _n

				file write `scheme`j'' `"* intensity p#        inten80"' _n
				file write `scheme`j'' `"* intensity p#shade   inten80"' _n
				file write `scheme`j'' `"* intensity p#bar     inten80	   // twoway bar only, graph bar overall"' _n
				file write `scheme`j'' `"* intensity p#box     inten80	   // unused, overall only, control w/ color"' _n
				file write `scheme`j'' `"* intensity p#pie     inten80	   // unused, overall only, control w/ color"' _n
				file write `scheme`j'' `"* intensity p#area    inten80"' _n(3)
				
				file write `scheme`j'' `"fillpattern pattern10"' _n
				file write `scheme`j'' `"fillpattern foreground pattern10"' _n
				file write `scheme`j'' `"fillpattern background pattern10"' _n(3)
				
				// Loop over lines 495-536 of the theme file
				forv i = 495/536 {
				
					// Write each line to the scheme file
					file write `scheme`j'' `theme`j'_`i''

				} // End loop over lines 495-536 of the theme file
				
				// Write generic marker styles
				foreach i in "" "boxlabel" {
				
					// Loop over cycle numbers
					forv v = 1/`pcycles' {

						// Add entry to scheme file
						file write `scheme`j'' `"textboxstyle p`v'`i'  p`v'`i'"' _n
						
					} // End Loop over cycle number
					
					// Write blank line between each of the types
					file write `scheme`j'' `""' _n

				} // End Loop over marker style generic types
				
				file write `scheme`j'' `"* textboxstyle p15label     xyz"' _n(3)

				// Loop over lines 537-590 of the theme file
				forv i = 537/590 {
				
					// Write each line to the scheme file
					file write `scheme`j'' `theme`j'_`i''
					
				} // End loop over lines 537-590 of the theme file
				
				// Write generic marker styles
				foreach i in "" "bar" "box" "pie" "area" "sunflowerlight" 		 ///   
				"sunflowerdark" {
				
					// Loop over cycle numbers
					forv v = 1/`pcycles' {

						// Check for sunflower cases
						if !inlist(`"`i'"', "sunflowerlight", "sunflowerdark") {

							// Add entry to scheme file
							file write `scheme`j'' `"areastyle p`v'`i'  p`v'`i'"' _n
						
						} // End If Block for non sunflower plots
						
						// For the sunflower caes
						else {
						
							// Use the generic line style for the sunflower plots
							file write `scheme`j'' `"areastyle p`v'`i' p`v'"' _n
						
						} // End ELSE Block for sunflower plots
						
					} // End Loop over cycle number
					
					// Write blank line between each of the types
					file write `scheme`j'' `""' _n

				} // End Loop over marker style generic types
				
				// Loop over lines 591-770 of the theme file
				forv i = 591/770 {
				
					// Write each line to the scheme file
					file write `scheme`j'' `theme`j'_`i''
					
				} // End loop over lines 591-770 of the theme file
				
				// Write generic marker styles
				foreach i in "" "box" {
				
					// Loop over cycle numbers
					forv v = 1/`pcycles' {

						// Add entry to scheme file
						file write `scheme`j'' `"labelstyle p`v'`i'  p`v'`i'"' _n
						
					} // End Loop over cycle number
					
					// Write blank line between each of the types
					file write `scheme`j'' `""' _n

				} // End Loop over marker style generic types
				
				file write `scheme`j'' `""' _n
				
				// Loop over lines 771-911 of the theme file
				forv i = 771/911 {
				
					// Write each line to the scheme file
					file write `scheme`j'' `theme`j'_`i''
					
				} // End loop over lines 771-911 of the theme file
				
				// Loop over color cycles
				forv i = 1/`pcycles' {

					// Add default entry for each color cycle
					file write `scheme`j'' `"zyx2style p`i' default"' _n
					
				} // End Loop over number of color cycles
				
				file write `scheme`j'' `"seriesstyle p1"' _n(2)
				
				file write `scheme`j'' `"seriesstyle dendrogram dendrogram"' _n(2)
				
				file write `scheme`j'' `"seriesstyle ilabel ilabel"' _n
				file write `scheme`j'' `"seriesstyle matrix matrix"' _n(2)
				
				// Write generic marker styles
				foreach i in "" "bar" "box" "pie" "area" "line" "dot" "arrow" {
				
					// Loop over cycle numbers
					forv v = 1/`pcycles' {

						// Add entry to scheme file
						file write `scheme`j'' `"seriesstyle p`v'`i'  p`v'`i'"' _n
											
					} // End Loop over cycle number
					
					// Write blank line between each of the types
					file write `scheme`j'' `""' _n

				} // End Loop over marker style generic types

				// Loop over lines 912-976 of the theme file
				forv i = 912/976 {
				
					// Write each line from the theme file to the scheme file
					file write `scheme`j'' `theme`j'_`i''
					
				} // End Loop over lines 912-976 of the theme file
				
				// Set generic parameters
				forv i = 1/`pcycles' {
											
					// Generic Sunflower plot styles
					if `i' == 1 {
						file write `scheme`j'' `"sunflowerstyle p1 sunflower"' _n
					}
					else {
						file write `scheme`j'' `"sunflowerstyle p`i' p`i'"' _n
					}
				
				} // End Generic parameters
			
			} // End Loop over theme/scheme file pairs
			
			// Write the Area Graph characteristics for the number of colors chosen
			forv i = 1/`pcycles' {
			
				// Get area color index value
				loc areaid `: word `i' of `areacolorsseq''
			
				// Get bar color index value
				loc barid `: word `i' of `barcolorsseq''
			
				// Get box plot color index value
				loc boxid `: word `i' of `boxcolorsseq''

				// Get dot plot color index value
				loc dotid `: word `i' of `dotcolorsseq''

				// Get line plot color index value
				loc lineid `: word `i' of `linecolorsseq''

				// Get pie color index value
				loc pieid `: word `i' of `piecolorsseq''

				// Get scatterplot color index value
				loc scatid `: word `i' of `scatcolorsseq''
				
				// Get current symbol
				loc thissymbol `: word `i' of `symbolseq''
				
				// Get the area colors
				mata: brewc.brewColorSearch("`: word `i' of `areargb''")
				
				// Store all the translated RGB values for area
				loc areacolor1 `rgb'
				loc areacolor2 `achromatopsia'
				loc areacolor3 `protanopia'
				loc areacolor4 `deuteranopia'
				loc areacolor5 `tritanopia'
				
				// Get the area colors
				mata: brewc.brewColorSearch("`: word `i' of `barrgb''")
				
				// Store all the translated RGB values for bar graphs
				loc barcolor1 `rgb'
				loc barcolor2 `achromatopsia'
				loc barcolor3 `protanopia'
				loc barcolor4 `deuteranopia'
				loc barcolor5 `tritanopia'
								
				// Get the area colors
				mata: brewc.brewColorSearch("`: word `i' of `boxrgb''")
				
				// Store all the translated RGB values for boxplots
				loc boxcolor1 `rgb'
				loc boxcolor2 `achromatopsia'
				loc boxcolor3 `protanopia'
				loc boxcolor4 `deuteranopia'
				loc boxcolor5 `tritanopia'
				
				// Get the area colors
				mata: brewc.brewColorSearch("`: word `i' of `dotrgb''")
				
				// Store all the translated RGB values for dot plots
				loc dotcolor1 `rgb'
				loc dotcolor2 `achromatopsia'
				loc dotcolor3 `protanopia'
				loc dotcolor4 `deuteranopia'
				loc dotcolor5 `tritanopia'
				
				// Get the area colors
				mata: brewc.brewColorSearch("`: word `i' of `linergb''")
				
				// Store all the translated RGB values for line graphs
				loc linecolor1 `rgb'
				loc linecolor2 `achromatopsia'
				loc linecolor3 `protanopia'
				loc linecolor4 `deuteranopia'
				loc linecolor5 `tritanopia'
				
				// Get the area colors
				mata: brewc.brewColorSearch("`: word `i' of `piergb''")
				
				// Store all the translated RGB values for pie graphs
				loc piecolor1 `rgb'
				loc piecolor2 `achromatopsia'
				loc piecolor3 `protanopia'
				loc piecolor4 `deuteranopia'
				loc piecolor5 `tritanopia'
				
				// Get the area colors
				mata: brewc.brewColorSearch("`: word `i' of `scatrgb''")
				
				// Store all the translated RGB values for scatterplots
				loc scatcolor1 `rgb'
				loc scatcolor2 `achromatopsia'
				loc scatcolor3 `protanopia'
				loc scatcolor4 `deuteranopia'
				loc scatcolor5 `tritanopia'
				
				// Check debug option
				if "`dbug'" != "" {
				
					di as res `"Color Sequence `i'"' _n						 ///   
					`"Area `i' RGB `areacolor'"' _n							 ///
					`"Bar `i' RGB `barcolor'"' _n							 ///   
					`"Box `i' RGB `boxcolor'"' _n							 ///
					`"Dot `i' RGB `dotcolor'"' _n							 ///   
					`"Line `i' RGB `linecolor'"' _n							 ///
					`"Pie Slice `i' RGB `piecolor'"' _n						 /// 
					`"Scatter `i' RGB `scatcolor'"'

				} // End IF Block for debugging option
				
				// Loop over theme/scheme file pairs
				forv j = 1/5 {
				
					/* Connected Plots */
					// Primary connected plot entries
					file write `scheme`j'' `"color p`i'area "`areacolor`j''""' _n
					file write `scheme`j'' `"linewidth p`i'area vvthin"' _n
					file write `scheme`j'' `"linepattern p`i'area solid"' _n
					file write `scheme`j'' `"color p`i'arealine "`linecolor`j''""' _n
					file write `scheme`j'' `"intensity p`i'area inten`areasaturation'"' _n

					// Define scheme colors for bar graphs
					file write `scheme`j'' `"color p`i' "`barcolor`j''""' _n
					file write `scheme`j'' `"color p`i'bar "`barcolor`j''""' _n
					file write `scheme`j'' `"intensity p`i'bar inten`barsaturation'"' _n
					// file write `scheme1' `"areastyle p`i'bar p`i'bar"' _n
					file write `scheme`j'' `"seriesstyle p`i'bar p`i'bar"' _n
					file write `scheme`j'' `"color p`i'barline "0 0 0""' _n

					/* Box Plot Styles */
					// Primary box plot entries
					file write `scheme`j'' `"color p`i'box "`boxcolor`j''""' _n
					file write `scheme`j'' `"intensity box inten`boxsaturation'"' _n
					file write `scheme`j'' `"linewidth p`i'box medthin"' _n
					file write `scheme`j'' `"linepattern p`i'box solid"' _n
					file write `scheme`j'' `"color p`i'boxline "0 0 0""' _n
					file write `scheme`j'' `"intensity box_line full"' _n
					file write `scheme`j'' `"symbol p`i'box `thissymbol'"' _n
					file write `scheme`j'' `"symbolsize p`i'box medium"' _n
					file write `scheme`j'' `"linewidth p`i'boxmark vthin"' _n
					file write `scheme`j'' `"color p`i'boxmarkfill "`scatcolor`j''""' _n
					file write `scheme`j'' `"color p`i'boxmarkline	"0 0 0""' _n
					file write `scheme`j'' `"gsize p`i'boxlabel vsmall"' _n
					file write `scheme`j'' `"color p`i'boxlabel "0 0 0""' _n
					file write `scheme`j'' `"clockdir p`i'box 0"' _n

					// Composite entries for box plots
					file write `scheme`j'' `"linestyle p`i'box p`i'box"' _n
					file write `scheme`j'' `"linestyle p`i'boxmark p`i'boxmark"' _n
					file write `scheme`j'' `"markerstyle p`i'box p`i'box"' _n
					file write `scheme`j'' `"seriesstyle p`i'box p`i'box"' _n

					// Custom median and whisker entries
					file write `scheme`j'' `"medtypestyle boxplot line"' _n
					file write `scheme`j'' `"yesno custom_whiskers yes"' _n
					file write `scheme`j'' `"linestyle box_whiskers ci"' _n
					file write `scheme`j'' `"linestyle box_median refline"' _n
					file write `scheme`j'' `"markerstyle box_marker p`i'box"' _n
					
					/* Connected Plots */
					// Primary connected plot entries
					file write `scheme`j'' `"color p`i'line "`linecolor`j''""' _n
					file write `scheme`j'' `"yesno p`i'cmissings no"' _n
					file write `scheme`j'' `"connectstyle p`i' direct"' _n

					// Composite entries for connected plots
					file write `scheme`j'' `"markerstyle p`i' p`i'"' _n
					file write `scheme`j'' `"seriesstyle p`i' p`i'"' _n
					file write `scheme`j'' `"linestyle p`i'connect p`i'"' _n
					file write `scheme`j'' `"linestyle p`i'mark p`i'line"' _n
					file write `scheme`j'' `"linewidth p`i' medium"' _n
					file write `scheme`j'' `"linepattern p`i'line solid"' _n

					/* Connected Plots */
					// Primary connected plot entries
					file write `scheme`j'' `"color p`i'dotmarkfill "`dotcolor`j''""' _n
					file write `scheme`j'' `"linewidth p`i'dotmark vthin"' _n
					file write `scheme`j'' `"symbol p`i'dot `thissymbol'"' _n
					file write `scheme`j'' `"symbolsize p`i'dot medium"' _n

					// Composite entries for connected plots
					file write `scheme`j'' `"linestyle p`i'dotmark p`i'dotmark"' _n
					file write `scheme`j'' `"markerstyle p`i'dot p`i'dot"' _n
					file write `scheme`j'' `"seriesstyle p`i'dot p`i'dot"' _n

					/* Connected Plots */
					// Primary connected plot entries
					file write `scheme`j'' `"color p`i'lineplot "`linecolor`j''""' _n
					file write `scheme`j'' `"linewidth p`i'lineplot medium"' _n
					file write `scheme`j'' `"linepattern p`i'lineplot solid"' _n
					file write `scheme`j'' `"connectstyle p`i' direct"' _n

					// Primary entries for scatter plots
					file write `scheme`j'' `"color p`i'pie "`piecolor`j''""' _n
					file write `scheme`j'' `"color p`i'pieline "0 0 0""' _n
					file write `scheme`j'' `"intensity pie inten`piesaturation'"' _n
					file write `scheme`j'' `"areastyle p`i'pie p`i'pie"' _n
					file write `scheme`j'' `"seriesstyle p`i'pie p`i'pie"' _n
						
					// Primary entries for scatter plots
					file write `scheme`j'' `"symbol p`i' `thissymbol'"' _n
					file write `scheme`j'' `"symbolsize p`i' medium"' _n
					file write `scheme`j'' `"color p`i'markline "0 0 0""' _n
					file write `scheme`j'' `"linewidth p`i'mark vthin"' _n
					file write `scheme`j'' `"color p`i'markfill "`scatcolor`j''""' _n
					file write `scheme`j'' `"color p`i'label "0 0 0""' _n
					file write `scheme`j'' `"clockdir p`i' 0"' _n
						
					// Secondary entries for scatter plots
					file write `scheme`j'' `"color p`i'shade "`scatcolor`j''""' _n
					file write `scheme`j'' `"intensity p`i'shade inten`scatsaturation'"' _n
					file write `scheme`j'' `"linewidth p`i'other vthin"' _n
					file write `scheme`j'' `"linepattern p`i'other solid"' _n
					file write `scheme`j'' `"color p`i'otherline "`linecolor`j''""' _n 

					// Composite entries for scatter plots
					file write `scheme`j'' `"linestyle p`i'mark p`i'mark"' _n
					file write `scheme`j'' `"markerstyle p`i' p`i'"' _n
					file write `scheme`j'' `"labelstyle p`i' p`i'"' _n
					file write `scheme`j'' `"seriesstyle p`i' p`i'"' _n
					
				} // End Loop over theme/scheme file pairs

			} // End Loop to create scatterplot scheme file entries

		// Close and save the graph scheme file
		file close `scheme1'
		file close `scheme2'
		file close `scheme3'
		file close `scheme4'
		file close `scheme5'

		// Create loop to generate all of the returned values
		foreach metachar in `: char _dta[]' {
		
			// Return the characteristics in self names locals
			ret loc `metachar' = `"`: char _dta[`metachar']'"'
			
		} // End Loop to build returned macros
		
	// Return data in memory to user
	restore
		
	// Print reference to console
	di in green _n(2) `"For bugs/issues, please submit issues to: "' _n		 ///       
	as res `"{browse "http://github.com/wbuchanan/brewscheme"}"' _n 		 ///   
	in green `"For additional information about the program visit: "' _n 	 ///   
	as res `"{browse "http://wbuchanan.github.io/brewscheme"}"' _n
	
// End of Program		
end


// Defines a subroutine used to check saturation parameter values
prog def checkSat, rclass

	// Defines the syntax the program uses
	syntax, [ INTensity(integer 100) ] 
	
	return clear

	// If color intensity is not a valid value
	if !inlist(`intensity', 0, 10, 20, 30, 40, 50, 60, 70, 80,  ///   
		90, 100, 200) {
		
		// If if invalid value is <= 104
		if `intensity' <= 104 {
		
			// Set the value to the nearest decile in [0, 100]
			loc saturation = round(`intensity', 10)
			
		} // End IF Block testing for saturation <= 104
		
		// If saturation is > 104 
		else if `intensity' > 104 {
		
			// Set to max valid saturation value
			loc saturation = 200
			
		} // End of ELSEIF Block for saturation > 104
		
		// For some other cases 
		else {
		
			// Print message to the results screen
			di "Setting saturation to 100"
			
			// Set value to full saturation
			loc saturation = 100
			
		} // End ELSE Block for some other values of saturation
		
	} // End IF Block for somesaturation value validation
	
	// IF the value is one of the integers defined in the IF Block set the return
	// macro to the value
	else loc saturation = `intensity'

	// Return the corrected value
	ret loc saturation = `saturation'

// End of subroutine to check intensity values	
end

	
