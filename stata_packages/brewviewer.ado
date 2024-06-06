********************************************************************************
* Description of the Program -												   *
* This program is used to preview combinations of color palettes along with    *
* combinations created by different numbers of colors.						   *
*                                                                              *
* Lines -                                                                      *
*     461                                                                      *
*                                                                              *
********************************************************************************
		
*! brewviewer
*! v 1.0.0
*! 21MAR2016

// Drop program if already loaded in memory
cap prog drop brewviewer

// Define new program brewviewer
prog def brewviewer

	// Interpret syntax under Version 13.1
	version 13.1
	
	// Syntax structure for the program
	syntax anything(name=pal id="BrewScheme Color Palette") 				 ///   
	[, Colors(numlist min = 1 max = 24 integer) COMBine Seq IMpaired ]
	
	// Check colors argument
	if "`colors'" == "" {
	
		// Print error message to the console
		di as err "Must supply at least a single value for the colors parameter."
		
		// Error out
		err 198
		
	} // End IF Block for invalid number of color arguments
	
	// Check impairment option to add subtitle to graph
	if `"`impaired'"' != "" loc xtralab `""with simulated total, red, green, and blue colorblindness""'
	
	// Preserve the current state of the data
	preserve
	
		// Load the brewscheme dataset
		qui: use `"`c(sysdir_personal)'b/brewmeta.dta"', clear
		
		// For single color listed
		if `: word count `colors'' == 1 {
		
			// Get maximum number of colors 
			loc maxcol `= `colors''
						
			// If sequence switch is enabled
			if "`seq'" != "" {
			
				// Set color loop syntax
				loc colloop forv i = 3/`colors' 
				
				// Get minimum number of colors 
				loc mincol 3
				
				// sets of xaxis values
				loc simvals `= ((`colors' - 3) + 1)'

			} // End IF Block for sequence loop
			
			// If sequence switch is not enabled
			else {
			
				// Set color loop syntax
				loc colloop foreach i in `colors'
				
				// Get minimum number of colors 
				loc mincol `colors'
				
				// Sets of xaxis values
				loc simvals = 1
							
			} // End ELSE Block for color loop syntax
			
		} // End ELSEIF Block for single color value
		
		// For fewer colors than palettes
		else if `: word count `colors'' < `: word count `pal'' {
		
			// Get maximum number of colors 
			loc maxcol `= `: di max(`: subinstr loc colors `" "' `", "', all')''
						
			// If sequence switch is enabled
			if "`seq'" != "" {
			
				// Set color loop syntax
				loc colloop forv i = 3/`maxcol'
				
				// Get minimum number of colors 
				loc mincol 3

				// sets of xaxis values
				loc simvals `= ((`maxcol' - 3) + 1)'

			} // End IF Block for sequence loop
			
			// If sequence switch is not enabled
			else {
			
				// Set color loop syntax
				loc colloop foreach i in `colors'
				
				// Get minimum number of colors 
				loc mincol `: di min(`: subinstr loc colors `" "' `", "', all')'
				
				// Sets of xaxis values
				loc simvals = 1
													
			} // End ELSE Block for color loop syntax
									
		} // End ELSEIF Block for fewer colors than palettes
		
		// If there are more colors than palettes {
		else if `: word count `colors'' == `: word count `pal'' {

			// If sequence switch is enabled
			if "`seq'" != "" {
			
				// Set color loop syntax
				loc colloop forv i = 3/\`: word \`w' of `colors''
				
				// Get minimum number of colors 
				loc mincol 3

			} // End IF Block for sequence loop
			
			// If sequence switch is not enabled
			else {
			
				// Set color loop syntax
				loc colloop foreach i in \`: word \`w' of \`colors''
				
				// Get minimum number of colors 
				loc mincol `: di min(`: subinstr loc colors `" "' `", "', all')'

			} // End ELSE Block for color loop syntax
									
			// Get maximum number of colors 
			loc maxcol `= `: di max(`: subinstr loc colors `" "' `", "', all')''
						
			// sets of xaxis values
			loc simvals `= ((`maxcol' - 3) + 1)'

		} // End ELSEIF Block for more colors than palettes
		
		// If there are more colors than palettes
		else {
		
			// Set color loop syntax
			loc colloop foreach i in `colors'
			
			// Get maximum number of colors 
			loc maxcol `= `: di max(`: subinstr loc colors `" "' `", "', all')''
						
			// Get minimum number of colors 
			loc mincol `: di min(`: subinstr loc colors `" "' `", "', all')'
						
			// sets of xaxis values
			loc simvals `= ((`maxcol' - 3) + 1)'

		} // End ELSE Block for more colors than palettes
		
		// Create counter for simulated values
		loc simcount = 1
		
		// Loop over the number of palettes passed to the main argument
		forv w = 1/`: word count `pal'' {
		
			// Get the palette name
			loc palnm : word `w' of `pal'
			
			// Get the mean from the maxcolors variable (constant by palette)
			qui: su maxcolors if palette == `"`palnm'"'
			
			// Set a local for maximum number of colors
			loc bkupmax `r(max)'
			
			// Check for colorblindness simulation option
			if `"`simcb'"' != "" loc sze `= 1.5 + `= 1/(`maxcol' * 5)''
			
			// Set the size of the boxes based on the log of 3 times n colors
			else loc sze `= 2 + `= 1/`maxcol'''
			
			// Local to build xaxis labeling rules
			loc xax 
			
			// Initialize scatteri local macro
			loc cmd 
			
			// Loop over the smallest number of colors available in any palettes
			`colloop' {
			
				// Find max colors
				qui: su maxcolors if palette == `"`palnm'"', meanonly
			
				// Create graph if acceptable value
				if `r(mean)' >= `i' {
					
					// Initialize a null macro to use like a StringBuilder class in Java
					loc scat`i' 
					
					// Loop over the number of unique colors based on the palette color id
					forv j = 1/`i' {
					
						// Get the number of palette color ids
						qui: levelsof pcolor if palette == `"`palnm'"', loc(pcid)
						
						// Test if the value exists in the pcolor ids
						loc gmax : list i in pcid
						
						// If not in pcid list
						if `gmax' == 0 {
						
							// Get maximum number of colors
							loc pcid `bkupmax'
							
						} // End IF Block to get maximum color ID
						
						// Else {
						else {
						
							// Set the pcid macro
							loc pcid `i'
						
						} // End ELSE Block for cases where the value is in the pcid list
					
						// Get the RGB values for the palette with the palette color id i
						qui: levelsof rgb if pcolor == `pcid' & colorid == `j'  ///   
						& palette == `"`palnm'"', loc(xrgb)
						
						// Get the individual RGB value for this iteration
						loc col "`: word 1 of `xrgb''"
						
						// If color blind impairment simulation get the RGB values
						if `"`impaired'"' != "" {
						
							// Get simulated colors
							mata: translateColor(`: subinstr loc col `" "' `", "', all')
						
							// Sets the xaxis position for the baseline palette
							loc basex `= (`simcount' * 5) - 4'
							
							// Sets xaxis label for the baseline palette
							loc baselab `basex' "`i' "
						
							// Sets the xaxis position for the achromatopsia transformed palette
							loc achromx `= (`simcount' * 5) - 3'
						
							// Sets the xaxis label for the achromatopsia transformed palette
							loc achromlab `achromx' " a "
						
							// Sets the xaxis position for the protanopia transformed palette
							loc protanx `= (`simcount' * 5) - 2'
						
							// Sets the xaxis label for the protanopia transformed palette
							loc protanlab `protanx' " p "
						
							// Sets the xaxis position for the deuteranopia transformed palette
							loc deuterx `= (`simcount' * 5) - 1'
						
							// Sets the xaxis label for the deuteranopia transformed palette
							loc deuteranlab `deuterx' " d "
						
							// Sets the xaxis position for the tritanopia transformed palette
							loc tritanx `= (`simcount' * 5) - 0'
						
							// Sets the xaxis label for the tritanopia transformed palette
							loc tritanlab `tritanx' " t "
							
							// Build the command for graphing this individual color/label
							loc scat`i' `scat`i''							 ///   
							(scatteri `j' `basex', mc("`col'") mlabc(black) ///   
									/*msize(`sze' `sze')*/ mlc(black) ms(S))	 ///   
							(scatteri `j' `achromx', mlc(black) ms(S)		 ///   
								mc("`achromatopsia'") /*msize(`sze' `sze')*/)	 ///   
							(scatteri `j' `protanx', ms(S) mlc(black)		 ///   
								mc("`protanopia'") /*msize(`sze' `sze')*/)		 ///   
							(scatteri `j' `deuterx', ms(S) mlc(black)		 ///   
								mc("`deuteranopia'") /*msize(`sze' `sze')*/)	 ///    
							(scatteri `j' `tritanx', ms(S) mlc(black) 		 ///   
								mc("`tritanopia'") /*msize(`sze' `sze')*/)
							
							// Add to existing x-axis label macros
							loc xax `xax' `baselab' `achromlab' `protanlab' `deuteranlab' `tritanlab'
							
						} // End IF Block for impairment simulation
						
						// If not
						else { 
						
							// Build the command for graphing this individual color/label
							loc scat`i' `scat`i'' (scatteri `j' `i', mc("`col'") ///   
							mlabc(black) msize(`sze' `sze') mlc(black) ms(S))

						} // End ELSE Block for no color impairment simulation
						
					} // End Loop over colors within a given palette color id
					
					// Add these to a container macro used to build the full graph syntax
					loc cmd `cmd' `scat`i'' 
					
				} // End IF Block for acceptable max value

				// If it is outside the maximum number of colors
				else {
				
					// Don't alter command macro
					loc scat`i' `scat`i'' 
									
				} // For cases when the colors value is > max colors
				
				// Increment simvalue counter
				loc simcount = `simcount' + 1
				
			} // End Loop over the number of palette color ids to use
			
			// Check for simulation option
			if `"`impaired'"' != "" {
			
				// Adjust label angle and size 
				loc xax `xax', angle(0)
				
				// Remove x-axis title to make room for the additional labeling
				loc xaxti ""
				
			} // End IF Block for impairment option

			// If option not selected
			else {
			
				// Sort the x axis values
				loc xax : list sort xax
				
				// Remove any duplicate values
				loc xax : list uniq xax
			
				loc xax `xax', angle(0)
			
				// Set the x-axis title
				loc xaxti "# Colors"

			} // End ELSE Block for graph w/o simulated colorblindness option
			
			// Get minimum value
			loc scales r(`= `mincol' - 0.25'(0.5)`= `maxcol' + 0.25')
			
			if `"`impaired'"' != "" {
				loc note1 "a = Achromatopsia    p = Protanopia" 
				loc note2 "    d = Deuteranopia     t = Tritanopia" 
				loc note note(`note1' `note2', size(medsmall) c(black) pos(7))
			}
			
			// Graph the color palette
			tw `cmd', ysca(r(1 `maxcol') off) xsca(`scales') xlab(`xax') 	 ///   
			yti("") ylab(none, nogrid) legend(nodraw) `note'				 ///   
			xti(`"`xaxti'"') graphr(margin(medlarge) fc(white) lc(white) 	 ///   
			ic(white)) plotr(lc(white) fc(white) ic(white)) 				 ///   
			name(`palnm'`color', replace) xsize(17) ysize(11) 				 ///   
			ti("BrewScheme palette: `palnm' colors" `xtralab', 				 ///   
			size(medsmall) span)
			
			// Store the name of the graph
			loc grnames `grnames' `palnm'`color'
			
		} // End Loop over palettes
		
		// Check combine option and make sure there are multiple palettes
		if "`combine'" != "" & `: word count `pal'' >= 2 {
		
			// If divisible by 5 and not 5
			if mod(`: word count `pal'', 5) == 0 & `: word count `pal'' / 5 != 1 {
				
				// Set rows as number of palettes divided by 5
				loc r rows(`: word count `pal''/5)
				
				// Use 5 columns for the images
				loc c cols(5)
				
			} // End IF Block for row/col options
			
			// Else if 4 palettes
			else if `: word count `pal'' / 4 == 1 {
			
				// Two rows
				loc r rows(2)
				
				// Two columns
				loc c cols(2)
				
			} // End ELSEIF Block for row/col options
			
			// Else if 6 palettes
			else if `: word count `pal''/6 == 1 {
			
				// Two rows of
				loc r rows(2)
				
				// Three columns
				loc c cols(3)
			
			} // End ELSEIF Block for row/col options
			
			// Else if # of palettes is divisible by 4
			else if mod(`: word count `pal'', 4) == 0 {
				
				// Number of rows = palettes / 4
				loc r rows(`: word count `pal''/4)
				
				// Use 4 columns
				loc c cols(4)
				
			} // End ELSEIF Block for row/col options
			
			// Else if number of palettes is divisible by 3
			else if mod(`: word count `pal'', 3) == 0 {
				
				// Number of Rows = palettes / 3
				loc r rows(`: word count `pal''/3)
				
				// Use three columns for the display
				loc c cols(3)
				
			} // End ELSEIF Block for row/col options
			
			// All other cases
			else {
			
				// Stata default number of rows
				loc r 
				
				// Stata default number of columns
				loc c
				
			} // End ELSE Block for other cases
		
			// Combine graphs in a single graph image
			gr combine `grnames', altshrink graphr(ic(white) fc(white) 		 ///   
			lc(white)) plotr(ic(white) fc(white) lc(white)) `r' `c' 		 ///   
			ysize(8.5) xsize(11) 
		
		} // End IF Block to combine the graphs
		
	// Return original state of the data to the user
	restore
	
// End the program
end
