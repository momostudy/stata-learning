********************************************************************************
* Description of the Program -												   *
* Program used to check the status of the brewscheme library.  If the version  *
* of the file is older than the distribution date defined below, recompile it  *
* to get all of the changes.  Otherwise, do nothing.                           *
*                                                                              *
* System Requirements -														   *
*     Java 8 or later                                                          *
*                                                                              *
* Program Output -                                                             *
*                                                                              *
* Lines -                                                                      *
*     62                                                                       *
*                                                                              *
********************************************************************************
		
*! brewlibcheck
*! v 1.0.0
*! 21MAR2016

// Drop the program if already loaded in memory
cap prog drop brewlibcheck

// Define the program
prog def brewlibcheck

	// Set the version for Stata to use to interpret the code
	version 13.1
	
	// Check to see if Mata library file exists
	cap confirm new file `"`c(sysdir_plus)'l/libbrewscheme.mlib"'
	
	// If the file does not currently exist
	if _rc == 0 {
	
		// Compile the file for the first time
		qui: libbrewscheme, replace size(2048)
		
	} // End IF Block for non-existent Mata library	
	
	// If the file already exists
	else {
	
		// Get the file system properties related to the Mata library
		filesys `c(sysdir_plus)'l/libbrewscheme.mlib, attr
		
		// If the existing version of the library is lower than the distro date
		// recompile the library
		if `r(creatednum)' < clock("21mar2016 00:00:00", "YMDhms") {
			
			// Recompile the library
			qui: libbrewscheme, replace size(2048)
			
		} // End IF Block for fresh recompile
	
	} // End ELSE Block for existing brewscheme Mata library
	
// End of Program definition	
end
	
