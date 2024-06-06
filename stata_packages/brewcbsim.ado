********************************************************************************
* Description of the Program -												   *
* This program is used to preview how a color may be perceived by individuals  * 
* with varying forms of colorblindness.  									   *
*                                                                              *
* Dependencies -															   *
*     libbrewscheme - colorblind, cbtype, Protanopia, Deuteranopia, and 	   *
*					  Tritanopia classes and associated methods.			   *
*																			   *
* Program Output -                                                             *
*                                                                              *
* Lines -                                                                      *
*     176                                                                      *
*                                                                              *
********************************************************************************
		
*! brewcbsim
*! v 1.0.0
*! 21MAR2016

// Drops program if loaded in memory
cap prog drop brewcbsim

// Defines program with R-class property
prog def brewcbsim, rclass

	// Version of Stata to use for interpretation of code
	version 13.1
	
	// Syntax structure of program
	syntax anything(name = colors id = "Red, Green, Blue Color or named color styles")
	
	// Check for brewscheme Mata library
	qui: brewlibcheck

	// Clear existing returned value
	return clear
	
	// Create a new brewcolors object
	mata: x = brewcolors()
	
	// Get a list of all named color styles currently installed
	mata: x.getNames(1)
	
	// Macro to store constructor for the graph
	loc cbsim 
	
	// Macro to store the x-labels
	loc xlabels 
	
	// Macro to define y-axis labels
	loc ylabs 10 "Specified" 8 "Achromatopsia" 6 "Protanopia" 4 "Deuteranopia" 2 "Tritanopia"
	
	// Loop over colors passed to program
	forv i = 1/`: word count `colors'' {
	
		// Get the token for this iteration
		loc color "`: word `i' of `colors''"
	
		// If the argument is only a single word and is a named color style
		if `: word count `color'' == 1 & `: list color in colornames' == 1 {
		
			// Get the named color style
			mata: x.brewNameSearch("`color'")
			
			// Define baseline points
			loc cbbase (scatteri 10 `i' (12) "`rgb'", mlc(black) ms(S)		 ///   
			mc("`rgb'") mlabc(black) msize(5) mlabgap(3) mlabs(small))

			// Define point for Achromatopsia
			loc achrom (scatteri 8 `i' (12) "`achromatopsia'", mlc(black) 	 ///   
			ms(S) mc("`achromatopsia'") mlabc(black) msize(5) mlabgap(3) mlabs(small))
						
			// Define point for protanopia			
			loc protan (scatteri 6 `i' (12) "`protanopia'", mlc(black) ms(S) ///   
			mc("`protanopia'") mlabc(black) msize(5) mlabgap(3) mlabs(small))
						
			// Define point for deuteranopia			
			loc deuteran (scatteri 4 `i' (12) "`deuteranopia'", mlc(black) 	 ///   
			ms(S) mc("`deuteranopia'") mlabc(black) msize(5) mlabgap(3) mlabs(small))
						  
			// Define point for tritanopia			  
			loc tritan (scatteri 2 `i' (12) "`tritanopia'", mlc(black) ms(S) ///    
			mc("`tritanopia'") mlabc(black) msize(5) mlabgap(3) mlabs(small))
			
			// Add the RGB value to a macro to store all the RGB values
			loc thebaseline "`rgb'"
			
			// Add the entry to the macro to build the graph command
			loc cbsim `cbsim' `cbbase' `achrom' `protan' `deuteran' `tritan'
			
			// The current xaxis label
			loc thisxlab `i' "`color'"
			
			// Add xlabel entry
			loc xlabels `xlabels' `thisxlab'
		
		} // End IF Block for named color styles

		// If the argument is an RGB color string
		else if `: word count `color'' == 3 {
		
			// Used to parse/clean/format the string to be passed to the mata 
			// function on the next line
			loc transcolors `: word 1 of `color'' `: word 2 of `color'' `: word 3 of `color''
		
			// Get the translated colors
			mata: translateColor(`: subinstr loc transcolors `" "' `", "', all')
		
			// Define baseline points
			loc cbbase (scatteri 10 `i' (12) "`baseline'", mlc(black) ms(S)	 ///   
			mc("`baseline'") mlabc(black) msize(5) mlabgap(3) mlabs(small))

			// Define point for Achromatopsia
			loc achrom (scatteri 8 `i' (12) "`achromatopsia'", mlc(black) 	 ///   
			ms(S) mc("`achromatopsia'") mlabc(black) msize(5) mlabgap(3) mlabs(small))
						
			// Define point for protanopia			
			loc protan (scatteri 6 `i' (12) "`protanopia'", mlc(black) ms(S) ///   
			mc("`protanopia'") mlabc(black) msize(5) mlabgap(3) mlabs(small))
						
			// Define point for deuteranopia			
			loc deuteran (scatteri 4 `i' (12) "`deuteranopia'", mlc(black) 	 ///   
			ms(S) mc("`deuteranopia'") mlabc(black) msize(5) mlabgap(3) mlabs(small))
						  
			// Define point for tritanopia			  
			loc tritan (scatteri 2 `i' (12) "`tritanopia'", mlc(black) ms(S) ///    
			mc("`tritanopia'") mlabc(black) msize(5) mlabgap(3) mlabs(small))
			
			// Gets the baseline color passed to the program
			loc thebaseline "`baseline'"

			// Add the entry to the macro to build the graph command
			loc cbsim `cbsim' `cbbase' `achrom' `protan' `deuteran' `tritan'
		
			// The current xaxis label
			loc thisxlab `i' "`baseline'"
			
			// Add xlabel entry
			loc xlabels `xlabels' `thisxlab'
		
		} // End ELSEIF Block for RGB color strings
		
		// For any other values
		else {
		
			// Print error message to the Stata console
			di as err "IGNORED: `color' is not a valid named color style or RGB color string."

		} // End ELSE Block for invalid arguments	
		
		// Add the RGB value to a macro to store all the RGB values
		ret loc original`i' `"`thebaseline'"'
			
		// Add the achromatopsia value to a macro for achromatopsia values
		ret loc achromatopsic`i' `"`achromatopsia'"'
		
		// Add the protanopia value to a macro for protanopia values
		ret loc protanopic`i' `"`protanopia'"'
		
		// Add the deuteranopia value to a macro for deuteranopia values
		ret loc deuteranopic`i' `"`deuteranopia'"'
		
		// Add the tritanopia value to a macro for tritanopia values
		ret loc tritanopic`i' `"`tritanopia'"'

	} // End Loop over the arguments
			
	// Create the graph to show the colors
	tw `cbsim', ti("brewscheme - Color Sight Simulator", 					 ///   
	size(large) c(black) margin(l = 10 r = 10 b = 10 t = 5) span)			 ///   
	graphr(ic(white) fc(white) lc(white)) yti("Vision Type") 				 ///   
	plotr(ic(white) fc(white) lc(white)) legend(off)						 ///   
	xlab(`xlabels', labs(small)) ylab(`ylabs', angle(0) labs(small) nogrid)  ///    
	xsca(range(0.5(0.1)`= 0.5 + `: word count `colors''')) 					 ///   
	ysca(range(1.5(1)10.5))	xti("User Specified Colors", margin(t=2))

// End of program definition
end

