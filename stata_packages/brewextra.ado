********************************************************************************
* Description of the Program -												   *
* This program is used to install additional palettes into the brewmeta  	   *
* database locally.  It is called initially when brewmeta is called, but sub-  *
* sequently would be used with a future program brewpalettes to construct and  *
* persist data files with palettes over time (so a user could rebuild the 	   *
* entire database in a single step.											   *
*                                                                              *
* Data Requirements -														   *
*     none                                                                     *
*																			   *
* System Requirements -														   *
*     none                                                                     *
*                                                                              *
* Program Output -                                                             *
*     r(brewextrapalettes) - List of the names of the additional palettes      *
*     r(brewextras) - File path/name where extras dataset is located		   *
*                                                                              *
* Lines -                                                                      *
*     1408                                                                     *
*                                                                              *
********************************************************************************
		
*! brewextra
*! v 1.0.0
*! 21MAR2016

// Drop the program from memory if loaded
cap prog drop brewextra

// Define the program as an rclass program
prog def brewextra, rclass

	// Version of Stata underwhich program is assumed to run
	version 13.1
	
	// Define syntax structure for program
	syntax [, files(string asis) REPlace]
	
	// Preserve pre-existing state of the data
	preserve
	
		// Check for/build directory
		dirfile, p(`"`c(sysdir_personal)'brewuser"')
		
		// Check for replace option
		cap confirm new file `"`c(sysdir_personal)'brewuser/extras.dta"'
		
		// Check for existing extras file or replace option
		if _rc == 0 | "`replace'" != "" {
		
			// Clear existing data from memory
			clear

			// Reserve memory for 130 observations
			set obs 200

			// Create palette, RGB, and meta variables 
			// Meta variable contains additional info related to the research/experiments
			// and could include labels with which people associated a particular color
			qui: g palette = "" 
			qui: g rgb = ""
			qui: g meta = ""

			// Populate the palette variable(s) with data from brewscheme project
			qui: replace palette = "mdebar" in 1/5
			qui: replace palette = "mdepoint" in 6/8
			qui: replace palette = "tableau" in 9/28
			qui: replace palette = "fruite" in 29/35
			qui: replace palette = "fruita" in 36/42
			qui: replace palette = "veggiesa" in 43/49
			qui: replace palette = "veggiese" in 50/56
			qui: replace palette = "brandsa" in 57/63
			qui: replace palette = "brandse" in 64/70
			qui: replace palette = "drinksa" in 71/77
			qui: replace palette = "drinkse" in 78/84
			qui: replace palette = "fooda" in 85/91
			qui: replace palette = "foode" in 92/98
			qui: replace palette = "carsa" in 99/104
			qui: replace palette = "carse" in 105/110
			qui: replace palette = "featuresa" in 111/115
			qui: replace palette = "featurest" in 116/120
			qui: replace palette = "activitiesa" in 121/125
			qui: replace palette = "activitiest" in 126/130
			qui: replace palette = "category10" in 131/140
			qui: replace palette = "category20" in 141/160
			qui: replace palette = "category20b" in 161/180
			qui: replace palette = "category20c" in 181/200
			qui: replace meta = "Mississippi Department of Education" in 1/8
			qui: replace meta = "D3js" in 131/200
			qui: replace meta = "Tableau" in 9/28
			bys palette: g colorid = _n
			bys palette: g pcolor = _N
			qui: g maxcolors = pcolor
			
			// Mississippi Department of Education specific colors for bar graphs
			qui: replace rgb = "255 0 0" if palette == "mdebar" & colorid == 1
			qui: replace rgb = "255 127 0" if palette == "mdebar" & colorid == 2
			qui: replace rgb = "255 255 0" if palette == "mdebar" & colorid == 3
			qui: replace rgb = "0 128 0" if palette == "mdebar" & colorid == 4
			qui: replace rgb = "0 0 255" if palette == "mdebar" & colorid == 5
				
			// Mississippi Department of Education specific colors for scatter plots
			qui: replace rgb = "0 0 255" if palette == "mdepoint" & colorid == 1
			qui: replace rgb = "255 127 0" if palette == "mdepoint" & colorid == 2
			qui: replace rgb = "0 128 0" if palette == "mdepoint" & colorid == 3
			
			// Define colors used in Tableau's color scheme
			qui: replace rgb = "31 119 180" if palette == "tableau" & colorid == 1
			qui: replace rgb = "255 127 14" if palette == "tableau" & colorid == 2
			qui: replace rgb = "44 160 44" if palette == "tableau" & colorid == 3
			qui: replace rgb = "214 39 40" if palette == "tableau" & colorid == 4
			qui: replace rgb = "148 103 189" if palette == "tableau" & colorid == 5 
			qui: replace rgb = "140 86 75" if palette == "tableau" & colorid == 6
			qui: replace rgb = "227 119 194" if palette == "tableau" & colorid == 7
			qui: replace rgb = "127 127 127" if palette == "tableau" & colorid == 8
			qui: replace rgb = "188 189 34" if palette == "tableau" & colorid == 9
			qui: replace rgb = "23 190 207" if palette == "tableau" & colorid == 10
			qui: replace rgb = "174 119 232" if palette == "tableau" & colorid == 11
			qui: replace rgb = "255 187 120" if palette == "tableau" & colorid == 12
			qui: replace rgb = "152 223 138" if palette == "tableau" & colorid == 13
			qui: replace rgb = "255 152 150" if palette == "tableau" & colorid == 14
			qui: replace rgb = "197 176 213" if palette == "tableau" & colorid == 15
			qui: replace rgb = "196 156 148" if palette == "tableau" & colorid == 16
			qui: replace rgb = "247 182 210" if palette == "tableau" & colorid == 17
			qui: replace rgb = "199 199 199" if palette == "tableau" & colorid == 18
			qui: replace rgb = "219 219 141" if palette == "tableau" & colorid == 19
			qui: replace rgb = "158 218 229" if palette == "tableau" & colorid == 20

			// Fruits corresponding to fruit palettes
			qui: replace meta = "Apple" if inlist(palette, "fruite",		 ///   
											"fruita") & colorid == 1
			qui: replace meta = "Banana" if inlist(palette, "fruite",		 ///   
											"fruita") & colorid == 2 
			qui: replace meta = "Blueberry" if inlist(palette, "fruite",	 ///   
											"fruita") & colorid == 3
			qui: replace meta = "Cherry" if inlist(palette, "fruite",		 ///   
											"fruita") & colorid == 4
			qui: replace meta = "Grape" if inlist(palette, "fruite",		 ///   
											"fruita") & colorid == 5
			qui: replace meta = "Peach" if inlist(palette, "fruite",		 ///   
											"fruita") & colorid == 6
			qui: replace meta = "Tangerine" if inlist(palette, "fruite",	 ///   
											"fruita") & colorid == 7

			// Fruit expert selected palette
			qui: replace rgb = "146 195 51" if palette == "fruite" & colorid == 1
			qui: replace rgb = "251 222 6" if palette == "fruite" & colorid == 2
			qui: replace rgb = "64 105 166" if palette == "fruite" & colorid == 3
			qui: replace rgb = "200 0 0" if palette == "fruite" & colorid == 4
			qui: replace rgb = "127 34 147" if palette == "fruite" & colorid == 5
			qui: replace rgb = "251 162 127" if palette == "fruite" & colorid == 6
			qui: replace rgb = "255 86 29" if palette == "fruite" & colorid == 7

			// Fruit algorithm selected palette
			qui: replace rgb = "44 160 44" if palette == "fruita" & colorid == 1
			qui: replace rgb = "188 189 34" if palette == "fruita" & colorid == 2
			qui: replace rgb = "31 119 180" if palette == "fruita" & colorid == 3
			qui: replace rgb = "214 39 40" if palette == "fruita" & colorid == 4
			qui: replace rgb = "148 103 189" if palette == "fruita" & colorid == 5
			qui: replace rgb = "255 187 120" if palette == "fruita" & colorid == 6
			qui: replace rgb = "255 127 14" if palette == "fruita" & colorid == 7

			// Vegetables corresponding to veggies palettes		
			qui: replace meta = "Carrot" if inlist(palette, "veggiese",		 ///   
											"veggiesa") & colorid == 1
			qui: replace meta = "Celery" if inlist(palette, "veggiese",		 ///   
											"veggiesa") & colorid == 2
			qui: replace meta = "Corn" if inlist(palette, "veggiese",		 ///   
											"veggiesa") & colorid == 3
			qui: replace meta = "Eggplant" if inlist(palette, "veggiese",	 ///   
											"veggiesa") & colorid == 4
			qui: replace meta = "Mushroom" if inlist(palette, "veggiese",	 ///   
											"veggiesa") & colorid == 5
			qui: replace meta = "Olive" if inlist(palette, "veggiese",		 ///   
											"veggiesa") & colorid == 6
			qui: replace meta = "Tomato" if inlist(palette, "veggiese",		 ///   
											"veggiesa") & colorid == 7

			// Vegetable algorithm selected
			qui: replace rgb = "255 127 14" if palette == "veggiesa" & colorid == 1
			qui: replace rgb = "44 160 44" if palette == "veggiesa" & colorid == 2
			qui: replace rgb = "188 189 34" if palette == "veggiesa" & colorid == 3
			qui: replace rgb = "148 103 189" if palette == "veggiesa" & colorid == 4
			qui: replace rgb = "140 86 75" if palette == "veggiesa" & colorid == 5
			qui: replace rgb = "152 223 138" if palette == "veggiesa" & colorid == 6
			qui: replace rgb = "214 39 40" if palette == "veggiesa" & colorid == 7

			// Vegetable export selected
			qui: replace rgb = "255 141 61" if palette == "veggiese" & colorid == 1
			qui: replace rgb = "157 212 105" if palette == "veggiese" & colorid == 2
			qui: replace rgb = "245 208 64" if palette == "veggiese" & colorid == 3
			qui: replace rgb = "104 59 101" if palette == "veggiese" & colorid == 4
			qui: replace rgb = "239 197 143" if palette == "veggiese" & colorid == 5
			qui: replace rgb = "139 129 57" if palette == "veggiese" & colorid == 6
			qui: replace rgb = "255 26 34" if palette == "veggiese" & colorid == 7

			// Brands corresponding to brand palettes
			qui: replace meta = "Apple" if inlist(palette, "brandse",		 ///   
											"brandsa") & colorid == 1
			qui: replace meta = "AT&T" if inlist(palette, "brandse",		 ///   
											"brandsa") & colorid == 2
			qui: replace meta = "Home Depot" if inlist(palette, "brandse",	 ///   
											"brandsa") & colorid == 3
			qui: replace meta = "Kodak" if inlist(palette, "brandse",		 ///   
											"brandsa") & colorid == 4
			qui: replace meta = "Starbucks" if inlist(palette, "brandse",	 ///   
											"brandsa") & colorid == 5
			qui: replace meta = "Target" if inlist(palette, "brandse",		 ///   
											"brandsa") & colorid == 6
			qui: replace meta = "Yahoo!" if inlist(palette, "brandse",		 ///   
											"brandsa") & colorid == 7

			// Brands algorithm selected
			qui: replace rgb = "152 223 138" if palette == "brandsa" & colorid == 1
			qui: replace rgb = "31 119 180" if palette == "brandsa" & colorid == 2
			qui: replace rgb = "255 127 14" if palette == "brandsa" & colorid == 3
			qui: replace rgb = "140 86 75" if palette == "brandsa" & colorid == 4
			qui: replace rgb = "44 160 44" if palette == "brandsa" & colorid == 5
			qui: replace rgb = "214 39 40" if palette == "brandsa" & colorid == 6
			qui: replace rgb = "148 103 189" if palette == "brandsa" & colorid == 7

			// Brands export selected
			qui: replace rgb = "161 165 169" if palette == "brandse" & colorid == 1
			qui: replace rgb = "44 163 218" if palette == "brandse" & colorid == 2
			qui: replace rgb = "242 99 33" if palette == "brandse" & colorid == 3
			qui: replace rgb = "255 183 0" if palette == "brandse" & colorid == 4
			qui: replace rgb = "0 112 66" if palette == "brandse" & colorid == 5
			qui: replace rgb = "204 0 0" if palette == "brandse" & colorid == 6
			qui: replace rgb = "123 0 153" if palette == "brandse" & colorid == 7

			// Drinks corresponding to brand palettes
			qui: replace meta = "A&W Root Beer" if inlist(palette, 			 ///   
											 "drinkse", "drinksa") & colorid == 1
			qui: replace meta = "Coca-Cola" if inlist(palette, "drinkse",	 ///   
											"drinksa") & colorid == 2
			qui: replace meta = "Dr. Pepper" if inlist(palette, "drinkse",	 ///   
											"drinksa") & colorid == 3
			qui: replace meta = "Pepsi" if inlist(palette, "drinkse",		 ///   
											"drinksa") & colorid == 4
			qui: replace meta = "Sprite" if inlist(palette, "drinkse",		 ///   
											"drinksa") & colorid == 5
			qui: replace meta = "Sunkist" if inlist(palette, "drinkse",		 ///   
											"drinksa") & colorid == 6
			qui: replace meta = "Welch's Grape" if inlist(palette, 			 ///   
											"drinkse", "drinksa") & colorid == 7

			// Drinks algorithm selected
			qui: replace rgb = "140 86 75" if palette == "drinksa" & colorid == 1
			qui: replace rgb = "214 39 40" if palette == "drinksa" & colorid == 2
			qui: replace rgb = "227 119 194" if palette == "drinksa" & colorid == 3
			qui: replace rgb = "31 119 180" if palette == "drinksa" & colorid == 4
			qui: replace rgb = "44 160 44" if palette == "drinksa" & colorid == 5
			qui: replace rgb = "255 127 14" if palette == "drinksa" & colorid == 6
			qui: replace rgb = "148 103 189" if palette == "drinksa" & colorid == 7

			// Drinks export selected
			qui: replace rgb = "119 67 6" if palette == "drinkse" & colorid == 1
			qui: replace rgb = "254 0 0" if palette == "drinkse" & colorid == 2
			qui: replace rgb = "151 37 63" if palette == "drinkse" & colorid == 3
			qui: replace rgb = "1 106 171" if palette == "drinkse" & colorid == 4
			qui: replace rgb = "1 159 76" if palette == "drinkse" & colorid == 5
			qui: replace rgb = "254 115 20" if palette == "drinkse" & colorid == 6
			qui: replace rgb = "104 105 169" if palette == "drinkse" & colorid == 7

			// Foods corresponding to brand palettes
			qui: replace meta = "Sour Cream" if inlist(palette, "foodse", 	 ///   
											"foodsa") & colorid == 1
			qui: replace meta = "Blue Cheese Dressing" if inlist(palette, 	 ///   
											"foodse", "foodsa") & colorid == 2
			qui: replace meta = "Porterhouse Steak" if inlist(palette, 		 ///   
											"foodse", "foodsa") & colorid == 3
			qui: replace meta = "Iceburg Lettuce" if inlist(palette, 		 ///   
											"foodse", "foodsa") & colorid == 4
			qui: replace meta = "Onions (Raw)" if inlist(palette, "foodse",	 ///   
											"foodsa") & colorid == 5
			qui: replace meta = "Potato (Baked)" if inlist(palette,			 ///   
											"foodse", "foodsa") & colorid == 6
			qui: replace meta = "Tomato" if inlist(palette, "foodse",		 ///   
											"foodsa") & colorid == 7

			// Foods algorithm selected
			qui: replace rgb = "31 119 180" if palette == "fooda" & colorid == 1
			qui: replace rgb = "255 127 14" if palette == "fooda" & colorid == 2
			qui: replace rgb = "140 86 75" if palette == "fooda" & colorid == 3
			qui: replace rgb = "44 160 44" if palette == "fooda" & colorid == 4
			qui: replace rgb = "255 187 120" if palette == "fooda" & colorid == 5
			qui: replace rgb = "219 219 141" if palette == "fooda" & colorid == 6
			qui: replace rgb = "214 39 40" if palette == "fooda" & colorid == 7

			// Foods export selected
			qui: replace rgb = "199 199 199" if palette == "foode" & colorid == 1
			qui: replace rgb = "31 119 180" if palette == "foode" & colorid == 2
			qui: replace rgb = "140 86 75" if palette == "foode" & colorid == 3
			qui: replace rgb = "152 223 138" if palette == "foode" & colorid == 4
			qui: replace rgb = "219 219 141" if palette == "foode" & colorid == 5
			qui: replace rgb = "196 156 148" if palette == "foode" & colorid == 6
			qui: replace rgb = "214 39 40" if palette == "foode" & colorid == 7

			// Car Colors corresponding to brand palettes
			qui: replace meta = "Red" if inlist(palette, "carse",			 ///   
												"carsa") & colorid == 1
			qui: replace meta = "Silver" if inlist(palette, "carse",		 ///   
												"carsa") & colorid == 2
			qui: replace meta = "Black" if inlist(palette, "carse",			 ///   
												"carsa") & colorid == 3
			qui: replace meta = "Green" if inlist(palette, "carse",			 ///   
												"carsa") & colorid == 4
			qui: replace meta = "Brown" if inlist(palette, "carse",			 ///   
												"carsa") & colorid == 5
			qui: replace meta = "Blue" if inlist(palette, "carse",			 ///   
												"carsa") & colorid == 6

			// Car Colors algorithm selected
			qui: replace rgb = "214 39 40" if palette == "carsa" & colorid == 1
			qui: replace rgb = "199 199 199" if palette == "carsa" & colorid == 2
			qui: replace rgb = "127 127 127" if palette == "carsa" & colorid == 3
			qui: replace rgb = "44 160 44" if palette == "carsa" & colorid == 4
			qui: replace rgb = "140 86 75" if palette == "carsa" & colorid == 5
			qui: replace rgb = "31 119 180" if palette == "carsa" & colorid == 6

			// Car Colors export selected
			qui: replace rgb = "214 39 40" if palette == "carse" & colorid == 1
			qui: replace rgb = "199 199 199" if palette == "carse" & colorid == 2
			qui: replace rgb = "127 127 127" if palette == "carse" & colorid == 3 
			qui: replace rgb = "44 160 44" if palette == "carse" & colorid == 4
			qui: replace rgb = "140 86 75" if palette == "carse" & colorid == 5
			qui: replace rgb = "31 119 180" if palette == "carse" & colorid == 6

			// Features corresponding to brand palettes
			qui: replace meta = "Speed" if inlist(palette, "featurest",		 ///   
											"featuresa") & colorid == 1
			qui: replace meta = "Reliability" if inlist(palette, "featurest", ///   
											"featuresa") & colorid == 2
			qui: replace meta = "Comfort" if inlist(palette, "featurest",	 ///   
											"featuresa") & colorid == 3
			qui: replace meta = "Safety" if inlist(palette, "featurest",	 ///   
											"featuresa") & colorid == 4
			qui: replace meta = "Efficiency" if inlist(palette, "featurest", ///   
											"featuresa") & colorid == 5

			// Features algorithm selected
			qui: replace rgb = "214 39 40" if palette == "featuresa" & colorid == 1
			qui: replace rgb = "31 119 180" if palette == "featuresa" & colorid == 2
			qui: replace rgb = "140 86 75" if palette == "featuresa" & colorid == 3
			qui: replace rgb = "255 127 14" if palette == "featuresa" & colorid == 4
			qui: replace rgb = "44 160 44" if palette == "featuresa" & colorid == 5

			// Features export selected
			qui: replace rgb = "214 39 40" if palette == "featurest" & colorid == 1
			qui: replace rgb = "31 119 180" if palette == "featurest" & colorid == 2
			qui: replace rgb = "174 119 232" if palette == "featurest" & colorid == 3 
			qui: replace rgb = "44 160 44" if palette == "featurest" & colorid == 4
			qui: replace rgb = "152 223 138" if palette == "featurest" & colorid == 5

			// Activities corresponding to brand palettes
			qui: replace meta = "Sleeping" if inlist(palette, "activitiest", ///   
											"activitiesa") & colorid == 1
			qui: replace meta = "Working" if inlist(palette, "activitiest",	 ///   
											"activitiesa") & colorid == 2
			qui: replace meta = "Leisure" if inlist(palette, "activitiest",	 ///   
											"activitiesa") & colorid == 3
			qui: replace meta = "Eating" if inlist(palette, "activitiest",	 ///   
											"activitiesa") & colorid == 4
			qui: replace meta = "Driving" if inlist(palette, "activitiest",	 ///   
											"activitiesa") & colorid == 5

			// Activities algorithm selected
			qui: replace rgb = "140 86 75" if palette == "activitiesa"		 ///   
														& colorid == 1
			qui: replace rgb = "255 127 14" if palette == "activitiesa"		 ///   
														& colorid == 2
			qui: replace rgb = "31 119 180" if palette == "activitiesa"		 ///   
														& colorid == 3
			qui: replace rgb = "227 119 194" if palette == "activitiesa"	 ///   
														& colorid == 4 
			qui: replace rgb = "214 39 40" if palette == "activitiesa"		 ///   
														& colorid == 5

			// Activities export selected
			qui: replace rgb = "31 119 180" if palette == "activitiest"		 ///   
														& colorid == 1
			qui: replace rgb = "214 39 40" if palette == "activitiest"		 ///   
														& colorid == 2
			qui: replace rgb = "152 223 138" if palette == "activitiest"	 ///   
														& colorid == 3 
			qui: replace rgb = "44 160 44" if palette == "activitiest"		 ///   
														& colorid == 4
			qui: replace rgb = "127 127 127" if palette == "activitiest"	 ///   
														& colorid == 5

			/* This section adds the D3js palettes from:
			https://github.com/mbostock/d3/wiki/Ordinal-Scales#ordinal */
			
			// D3js 10 Category Ordinal Scale
			qui: replace rgb = "31 119 180" if palette == "category10" & colorid == 1
			qui: replace rgb = "255 127 14" if palette == "category10" & colorid == 2
			qui: replace rgb = "44 160 44" if palette == "category10" & colorid == 3
			qui: replace rgb = "214 39 40" if palette == "category10" & colorid == 4
			qui: replace rgb = "148 103 189" if palette == "category10" & colorid == 5
			qui: replace rgb = "140 86 75" if palette == "category10" & colorid == 6
			qui: replace rgb = "227 119 194" if palette == "category10" & colorid == 7
			qui: replace rgb = "127 127 127" if palette == "category10" & colorid == 8
			qui: replace rgb = "188 189 34" if palette == "category10" & colorid == 9
			qui: replace rgb = "23 190 207" if palette == "category10" & colorid == 10

			// D3js 20 Category Ordinal Scale
			qui: replace rgb = "31 119 180" if palette == "category20" & colorid == 1
			qui: replace rgb = "174 199 232" if palette == "category20" & colorid == 2
			qui: replace rgb = "255 127 14" if palette == "category20" & colorid == 3
			qui: replace rgb = "255 187 120" if palette == "category20" & colorid == 4
			qui: replace rgb = "44 160 44" if palette == "category20" & colorid == 5
			qui: replace rgb = "152 223 138" if palette == "category20" & colorid == 6
			qui: replace rgb = "214 39 40" if palette == "category20" & colorid == 7
			qui: replace rgb = "255 152 150" if palette == "category20" & colorid == 8
			qui: replace rgb = "148 103 189" if palette == "category20" & colorid == 9
			qui: replace rgb = "197 176 213" if palette == "category20" & colorid == 10
			qui: replace rgb = "140 86 75" if palette == "category20" & colorid == 11
			qui: replace rgb = "196 156 148" if palette == "category20" & colorid == 12
			qui: replace rgb = "227 119 194" if palette == "category20" & colorid == 13
			qui: replace rgb = "247 182 210" if palette == "category20" & colorid == 14
			qui: replace rgb = "127 127 127" if palette == "category20" & colorid == 15
			qui: replace rgb = "199 199 199" if palette == "category20" & colorid == 16
			qui: replace rgb = "188 189 34" if palette == "category20" & colorid == 17
			qui: replace rgb = "219 219 141" if palette == "category20" & colorid == 18
			qui: replace rgb = "23 190 207" if palette == "category20" & colorid == 19
			qui: replace rgb = "158 218 229" if palette == "category20" & colorid == 20
			
			// D3js 20 Category Ordinal Scale b
			qui: replace rgb = "57 59 121" if palette == "category20b" & colorid == 1
			qui: replace rgb = "82 84 163" if palette == "category20b" & colorid == 2
			qui: replace rgb = "107 110 207" if palette == "category20b" & colorid == 3
			qui: replace rgb = "156 158 222" if palette == "category20b" & colorid == 4
			qui: replace rgb = "99 121 57" if palette == "category20b" & colorid == 5
			qui: replace rgb = "140 162 82" if palette == "category20b" & colorid == 6
			qui: replace rgb = "181 207 107" if palette == "category20b" & colorid == 7
			qui: replace rgb = "206 219 156" if palette == "category20b" & colorid == 8
			qui: replace rgb = "140 109 49" if palette == "category20b" & colorid == 9
			qui: replace rgb = "189 158 57" if palette == "category20b" & colorid == 10
			qui: replace rgb = "231 186 82" if palette == "category20b" & colorid == 11
			qui: replace rgb = "231 203 148" if palette == "category20b" & colorid == 12
			qui: replace rgb = "132 60 57" if palette == "category20b" & colorid == 13
			qui: replace rgb = "173 73 74" if palette == "category20b" & colorid == 14
			qui: replace rgb = "214 97 107" if palette == "category20b" & colorid == 15
			qui: replace rgb = "231 150 156" if palette == "category20b" & colorid == 16
			qui: replace rgb = "123 65 115" if palette == "category20b" & colorid == 17
			qui: replace rgb = "165 81 148" if palette == "category20b" & colorid == 18
			qui: replace rgb = "206 109 189" if palette == "category20b" & colorid == 19
			qui: replace rgb = "222 158 214" if palette == "category20b" & colorid == 20

			// D3js 20 Category Ordinal Scale c
			qui: replace rgb = "49 130 189" if palette == "category20c" & colorid == 1
			qui: replace rgb = "107 174 214" if palette == "category20c" & colorid == 2
			qui: replace rgb = "158 202 225" if palette == "category20c" & colorid == 3
			qui: replace rgb = "198 219 239" if palette == "category20c" & colorid == 4
			qui: replace rgb = "230 85 13" if palette == "category20c" & colorid == 5
			qui: replace rgb = "253 141 60" if palette == "category20c" & colorid == 6
			qui: replace rgb = "253 174 107" if palette == "category20c" & colorid == 7
			qui: replace rgb = "253 208 162" if palette == "category20c" & colorid == 8
			qui: replace rgb = "49 163 84" if palette == "category20c" & colorid == 9
			qui: replace rgb = "116 196 118" if palette == "category20c" & colorid == 10
			qui: replace rgb = "161 217 155" if palette == "category20c" & colorid == 11
			qui: replace rgb = "199 233 192" if palette == "category20c" & colorid == 12
			qui: replace rgb = "117 107 177" if palette == "category20c" & colorid == 13
			qui: replace rgb = "158 154 200" if palette == "category20c" & colorid == 14
			qui: replace rgb = "188 189 220" if palette == "category20c" & colorid == 15
			qui: replace rgb = "218 218 235" if palette == "category20c" & colorid == 16
			qui: replace rgb = "99 99 99" if palette == "category20c" & colorid == 17
			qui: replace rgb = "150 150 150" if palette == "category20c" & colorid == 18
			qui: replace rgb = "189 189 189" if palette == "category20c" & colorid == 19
			qui: replace rgb = "217 217 217" if palette == "category20c" & colorid == 20

			// Add observations to the data set
			qui: set obs 499
			
			// Add the ggplot2 default colors for 2-24 colors in the scale
			qui: replace palette = "ggplot2" in 201/499
			qui: replace meta = "ggplot2" in 201/499
			qui: replace maxcolors = 24 in 201/499
			qui: replace pcolor = 2 in 201/202
			qui: replace pcolor = 3 in 203/205
			qui: replace pcolor = 4 in 206/209
			qui: replace pcolor = 5 in 210/214
			qui: replace pcolor = 6 in 215/220
			qui: replace pcolor = 7 in 221/227
			qui: replace pcolor = 8 in 228/235
			qui: replace pcolor = 9 in 236/244
			qui: replace pcolor = 10 in 245/254
			qui: replace pcolor = 11 in 255/265
			qui: replace pcolor = 12 in 266/277
			qui: replace pcolor = 13 in 278/290
			qui: replace pcolor = 14 in 291/304
			qui: replace pcolor = 15 in 305/319
			qui: replace pcolor = 16 in 320/335
			qui: replace pcolor = 17 in 336/352
			qui: replace pcolor = 18 in 353/370
			qui: replace pcolor = 19 in 371/389
			qui: replace pcolor = 20 in 390/409
			qui: replace pcolor = 21 in 410/430
			qui: replace pcolor = 22 in 431/452
			qui: replace pcolor = 23 in 453/475
			qui: replace pcolor = 24 in 476/499
			qui: replace rgb = "248 118 109" in 201
			qui: replace colorid = 1 in 201
			qui: replace rgb = "0 191 196" in 202
			qui: replace colorid = 2 in 202
			qui: replace rgb = "248 118 109" in 203
			qui: replace colorid = 1 in 203
			qui: replace rgb = "0 186 56" in 204
			qui: replace colorid = 2 in 204
			qui: replace rgb = "97 156 255" in 205
			qui: replace colorid = 3 in 205
			qui: replace rgb = "248 118 109" in 206
			qui: replace colorid = 1 in 206
			qui: replace rgb = "124 174 0" in 207
			qui: replace colorid = 2 in 207
			qui: replace rgb = "0 191 196" in 208
			qui: replace colorid = 3 in 208
			qui: replace rgb = "199 124 255" in 209
			qui: replace colorid = 4 in 209
			qui: replace rgb = "248 118 109" in 210
			qui: replace colorid = 1 in 210
			qui: replace rgb = "163 165 0" in 211
			qui: replace colorid = 2 in 211
			qui: replace rgb = "0 191 125" in 212
			qui: replace colorid = 3 in 212
			qui: replace rgb = "0 176 246" in 213
			qui: replace colorid = 4 in 213
			qui: replace rgb = "231 107 243" in 214
			qui: replace colorid = 5 in 214
			qui: replace rgb = "248 118 109" in 215
			qui: replace colorid = 1 in 215
			qui: replace rgb = "183 159 0" in 216
			qui: replace colorid = 2 in 216
			qui: replace rgb = "0 186 56" in 217
			qui: replace colorid = 3 in 217
			qui: replace rgb = "0 191 196" in 218
			qui: replace colorid = 4 in 218
			qui: replace rgb = "97 156 255" in 219
			qui: replace colorid = 5 in 219
			qui: replace rgb = "245 100 227" in 220
			qui: replace colorid = 6 in 220
			qui: replace rgb = "248 118 109" in 221
			qui: replace colorid = 1 in 221
			qui: replace rgb = "196 154 0" in 222
			qui: replace colorid = 2 in 222
			qui: replace rgb = "83 180 0" in 223
			qui: replace colorid = 3 in 223
			qui: replace rgb = "0 192 148" in 224
			qui: replace colorid = 4 in 224
			qui: replace rgb = "0 182 235" in 225
			qui: replace colorid = 5 in 225
			qui: replace rgb = "165 138 255" in 226
			qui: replace colorid = 6 in 226
			qui: replace rgb = "251 97 215" in 227
			qui: replace colorid = 7 in 227
			qui: replace rgb = "248 118 109" in 228
			qui: replace colorid = 1 in 228
			qui: replace rgb = "205 150 0" in 229
			qui: replace colorid = 2 in 229
			qui: replace rgb = "124 174 0" in 230
			qui: replace colorid = 3 in 230
			qui: replace rgb = "0 190 103" in 231
			qui: replace colorid = 4 in 231
			qui: replace rgb = "0 191 196" in 232
			qui: replace colorid = 5 in 232
			qui: replace rgb = "0 169 255" in 233
			qui: replace colorid = 6 in 233
			qui: replace rgb = "199 124 255" in 234
			qui: replace colorid = 7 in 234
			qui: replace rgb = "255 97 204" in 235
			qui: replace colorid = 8 in 235
			qui: replace rgb = "248 118 109" in 236
			qui: replace colorid = 1 in 236
			qui: replace rgb = "211 146 0" in 237
			qui: replace colorid = 2 in 237
			qui: replace rgb = "147 170 0" in 238
			qui: replace colorid = 3 in 238
			qui: replace rgb = "0 186 56" in 239
			qui: replace colorid = 4 in 239
			qui: replace rgb = "0 193 159" in 240
			qui: replace colorid = 5 in 240
			qui: replace rgb = "0 185 227" in 241
			qui: replace colorid = 6 in 241
			qui: replace rgb = "97 156 255" in 242
			qui: replace colorid = 7 in 242
			qui: replace rgb = "219 114 251" in 243
			qui: replace colorid = 8 in 243
			qui: replace rgb = "255 97 195" in 244
			qui: replace colorid = 9 in 244
			qui: replace rgb = "248 118 109" in 245
			qui: replace colorid = 1 in 245
			qui: replace rgb = "216 144 0" in 246
			qui: replace colorid = 2 in 246
			qui: replace rgb = "163 165 0" in 247
			qui: replace colorid = 3 in 247
			qui: replace rgb = "57 182 0" in 248
			qui: replace colorid = 4 in 248
			qui: replace rgb = "0 191 125" in 249
			qui: replace colorid = 5 in 249
			qui: replace rgb = "0 191 196" in 250
			qui: replace colorid = 6 in 250
			qui: replace rgb = "0 176 246" in 251
			qui: replace colorid = 7 in 251
			qui: replace rgb = "149 144 255" in 252
			qui: replace colorid = 8 in 252
			qui: replace rgb = "231 107 243" in 253
			qui: replace colorid = 9 in 253
			qui: replace rgb = "255 98 188" in 254
			qui: replace colorid = 10 in 254
			qui: replace rgb = "248 118 109" in 255
			qui: replace colorid = 1 in 255
			qui: replace rgb = "219 142 0" in 256
			qui: replace colorid = 2 in 256
			qui: replace rgb = "174 162 0" in 257
			qui: replace colorid = 3 in 257
			qui: replace rgb = "100 178 0" in 258
			qui: replace colorid = 4 in 258
			qui: replace rgb = "0 189 92" in 259
			qui: replace colorid = 5 in 259
			qui: replace rgb = "0 193 167" in 260
			qui: replace colorid = 6 in 260
			qui: replace rgb = "0 186 222" in 261
			qui: replace colorid = 7 in 261
			qui: replace rgb = "0 166 255" in 262
			qui: replace colorid = 8 in 262
			qui: replace rgb = "179 133 255" in 263
			qui: replace colorid = 9 in 263
			qui: replace rgb = "239 103 235" in 264
			qui: replace colorid = 10 in 264
			qui: replace rgb = "255 99 182" in 265
			qui: replace colorid = 11 in 265
			qui: replace rgb = "248 118 109" in 266
			qui: replace colorid = 1 in 266
			qui: replace rgb = "222 140 0" in 267
			qui: replace colorid = 2 in 267
			qui: replace rgb = "183 159 0" in 268
			qui: replace colorid = 3 in 268
			qui: replace rgb = "124 174 0" in 269
			qui: replace colorid = 4 in 269
			qui: replace rgb = "0 186 56" in 270
			qui: replace colorid = 5 in 270
			qui: replace rgb = "0 192 139" in 271
			qui: replace colorid = 6 in 271
			qui: replace rgb = "0 191 196" in 272
			qui: replace colorid = 7 in 272
			qui: replace rgb = "0 180 240" in 273
			qui: replace colorid = 8 in 273
			qui: replace rgb = "97 156 255" in 274
			qui: replace colorid = 9 in 274
			qui: replace rgb = "199 124 255" in 275
			qui: replace colorid = 10 in 275
			qui: replace rgb = "245 100 227" in 276
			qui: replace colorid = 11 in 276
			qui: replace rgb = "255 100 176" in 277
			qui: replace colorid = 12 in 277
			qui: replace rgb = "248 118 109" in 278
			qui: replace colorid = 1 in 278
			qui: replace rgb = "225 138 0" in 279
			qui: replace colorid = 2 in 279
			qui: replace rgb = "190 156 0" in 280
			qui: replace colorid = 3 in 280
			qui: replace rgb = "140 171 0" in 281
			qui: replace colorid = 4 in 281
			qui: replace rgb = "36 183 0" in 282
			qui: replace colorid = 5 in 282
			qui: replace rgb = "0 190 112" in 283
			qui: replace colorid = 6 in 283
			qui: replace rgb = "0 193 171" in 284
			qui: replace colorid = 7 in 284
			qui: replace rgb = "0 187 218" in 285
			qui: replace colorid = 8 in 285
			qui: replace rgb = "0 172 252" in 286
			qui: replace colorid = 9 in 286
			qui: replace rgb = "139 147 255" in 287
			qui: replace colorid = 10 in 287
			qui: replace rgb = "213 117 254" in 288
			qui: replace colorid = 11 in 288
			qui: replace rgb = "249 98 221" in 289
			qui: replace colorid = 12 in 289
			qui: replace rgb = "255 101 172" in 290
			qui: replace colorid = 13 in 290
			qui: replace rgb = "248 118 109" in 291
			qui: replace colorid = 1 in 291
			qui: replace rgb = "227 137 0" in 292
			qui: replace colorid = 2 in 292
			qui: replace rgb = "196 154 0" in 293
			qui: replace colorid = 3 in 293
			qui: replace rgb = "153 168 0" in 294
			qui: replace colorid = 4 in 294
			qui: replace rgb = "83 180 0" in 295
			qui: replace colorid = 5 in 295
			qui: replace rgb = "0 188 86" in 296
			qui: replace colorid = 6 in 296
			qui: replace rgb = "0 192 148" in 297
			qui: replace colorid = 7 in 297
			qui: replace rgb = "0 191 196" in 298
			qui: replace colorid = 8 in 298
			qui: replace rgb = "0 182 235" in 299
			qui: replace colorid = 9 in 299
			qui: replace rgb = "6 164 255" in 300
			qui: replace colorid = 10 in 300
			qui: replace rgb = "165 138 255" in 301
			qui: replace colorid = 11 in 301
			qui: replace rgb = "223 112 248" in 302
			qui: replace colorid = 12 in 302
			qui: replace rgb = "251 97 215" in 303
			qui: replace colorid = 13 in 303
			qui: replace rgb = "255 102 168" in 304
			qui: replace colorid = 14 in 304
			qui: replace rgb = "248 118 109" in 305
			qui: replace colorid = 1 in 305
			qui: replace rgb = "229 135 0" in 306
			qui: replace colorid = 2 in 306
			qui: replace rgb = "201 152 0" in 307
			qui: replace colorid = 3 in 307
			qui: replace rgb = "163 165 0" in 308
			qui: replace colorid = 4 in 308
			qui: replace rgb = "107 177 0" in 309
			qui: replace colorid = 5 in 309
			qui: replace rgb = "0 186 56" in 310
			qui: replace colorid = 6 in 310
			qui: replace rgb = "0 191 125" in 311
			qui: replace colorid = 7 in 311
			qui: replace rgb = "0 192 175" in 312
			qui: replace colorid = 8 in 312
			qui: replace rgb = "0 188 216" in 313
			qui: replace colorid = 9 in 313
			qui: replace rgb = "0 176 246" in 314
			qui: replace colorid = 10 in 314
			qui: replace rgb = "97 156 255" in 315
			qui: replace colorid = 11 in 315
			qui: replace rgb = "185 131 255" in 316
			qui: replace colorid = 12 in 316
			qui: replace rgb = "231 107 243" in 317
			qui: replace colorid = 13 in 317
			qui: replace rgb = "253 97 209" in 318
			qui: replace colorid = 14 in 318
			qui: replace rgb = "255 103 164" in 319
			qui: replace colorid = 15 in 319
			qui: replace rgb = "248 118 109" in 320
			qui: replace colorid = 1 in 320
			qui: replace rgb = "230 134 19" in 321
			qui: replace colorid = 2 in 321
			qui: replace rgb = "205 150 0" in 322
			qui: replace colorid = 3 in 322
			qui: replace rgb = "171 163 0" in 323
			qui: replace colorid = 4 in 323
			qui: replace rgb = "124 174 0" in 324
			qui: replace colorid = 5 in 324
			qui: replace rgb = "12 183 2" in 325
			qui: replace colorid = 6 in 325
			qui: replace rgb = "0 190 103" in 326
			qui: replace colorid = 7 in 326
			qui: replace rgb = "0 193 154" in 327
			qui: replace colorid = 8 in 327
			qui: replace rgb = "0 191 196" in 328
			qui: replace colorid = 9 in 328
			qui: replace rgb = "0 184 231" in 329
			qui: replace colorid = 10 in 329
			qui: replace rgb = "0 169 255" in 330
			qui: replace colorid = 11 in 330
			qui: replace rgb = "132 148 255" in 331
			qui: replace colorid = 12 in 331
			qui: replace rgb = "199 124 255" in 332
			qui: replace colorid = 13 in 332
			qui: replace rgb = "237 104 237" in 333
			qui: replace colorid = 14 in 333
			qui: replace rgb = "255 97 204" in 334
			qui: replace colorid = 15 in 334
			qui: replace rgb = "255 104 161" in 335
			qui: replace colorid = 16 in 335
			qui: replace rgb = "248 118 109" in 336
			qui: replace colorid = 1 in 336
			qui: replace rgb = "231 133 30" in 337
			qui: replace colorid = 2 in 337
			qui: replace rgb = "208 148 0" in 338
			qui: replace colorid = 3 in 338
			qui: replace rgb = "178 161 0" in 339
			qui: replace colorid = 4 in 339
			qui: replace rgb = "137 172 0" in 340
			qui: replace colorid = 5 in 340
			qui: replace rgb = "69 181 0" in 341
			qui: replace colorid = 6 in 341
			qui: replace rgb = "0 188 81" in 342
			qui: replace colorid = 7 in 342
			qui: replace rgb = "0 192 135" in 343
			qui: replace colorid = 8 in 343
			qui: replace rgb = "0 192 178" in 344
			qui: replace colorid = 9 in 344
			qui: replace rgb = "0 188 214" in 345
			qui: replace colorid = 10 in 345
			qui: replace rgb = "0 179 242" in 346
			qui: replace colorid = 11 in 346
			qui: replace rgb = "41 163 255" in 347
			qui: replace colorid = 12 in 347
			qui: replace rgb = "156 141 255" in 348
			qui: replace colorid = 13 in 348
			qui: replace rgb = "210 119 255" in 349
			qui: replace colorid = 14 in 349
			qui: replace rgb = "241 102 232" in 350
			qui: replace colorid = 15 in 350
			qui: replace rgb = "255 97 199" in 351
			qui: replace colorid = 16 in 351
			qui: replace rgb = "255 104 158" in 352
			qui: replace colorid = 17 in 352
			qui: replace rgb = "248 118 109" in 353
			qui: replace colorid = 1 in 353
			qui: replace rgb = "232 133 38" in 354
			qui: replace colorid = 2 in 354
			qui: replace rgb = "211 146 0" in 355
			qui: replace colorid = 3 in 355
			qui: replace rgb = "183 159 0" in 356
			qui: replace colorid = 4 in 356
			qui: replace rgb = "147 170 0" in 357
			qui: replace colorid = 5 in 357
			qui: replace rgb = "94 179 0" in 358
			qui: replace colorid = 6 in 358
			qui: replace rgb = "0 186 56" in 359
			qui: replace colorid = 7 in 359
			qui: replace rgb = "0 191 116" in 360
			qui: replace colorid = 8 in 360
			qui: replace rgb = "0 193 159" in 361
			qui: replace colorid = 9 in 361
			qui: replace rgb = "0 191 196" in 362
			qui: replace colorid = 10 in 362
			qui: replace rgb = "0 185 227" in 363
			qui: replace colorid = 11 in 363
			qui: replace rgb = "0 173 250" in 364
			qui: replace colorid = 12 in 364
			qui: replace rgb = "97 156 255" in 365
			qui: replace colorid = 13 in 365
			qui: replace rgb = "174 135 255" in 366
			qui: replace colorid = 14 in 366
			qui: replace rgb = "219 114 251" in 367
			qui: replace colorid = 15 in 367
			qui: replace rgb = "245 100 227" in 368
			qui: replace colorid = 16 in 368
			qui: replace rgb = "255 97 195" in 369
			qui: replace colorid = 17 in 369
			qui: replace rgb = "255 105 156" in 370
			qui: replace colorid = 18 in 370
			qui: replace rgb = "248 118 109" in 371
			qui: replace colorid = 1 in 371
			qui: replace rgb = "233 132 44" in 372
			qui: replace colorid = 2 in 372
			qui: replace rgb = "214 145 0" in 373
			qui: replace colorid = 3 in 373
			qui: replace rgb = "188 157 0" in 374
			qui: replace colorid = 4 in 374
			qui: replace rgb = "156 167 0" in 375
			qui: replace colorid = 5 in 375
			qui: replace rgb = "111 176 0" in 376
			qui: replace colorid = 6 in 376
			qui: replace rgb = "0 184 19" in 377
			qui: replace colorid = 7 in 377
			qui: replace rgb = "0 189 97" in 378
			qui: replace colorid = 8 in 378
			qui: replace rgb = "0 192 142" in 379
			qui: replace colorid = 9 in 379
			qui: replace rgb = "0 192 180" in 380
			qui: replace colorid = 10 in 380
			qui: replace rgb = "0 189 212" in 381
			qui: replace colorid = 11 in 381
			qui: replace rgb = "0 181 238" in 382
			qui: replace colorid = 12 in 382
			qui: replace rgb = "0 167 255" in 383
			qui: replace colorid = 13 in 383
			qui: replace rgb = "127 150 255" in 384
			qui: replace colorid = 14 in 384
			qui: replace rgb = "188 129 255" in 385
			qui: replace colorid = 15 in 385
			qui: replace rgb = "226 110 247" in 386
			qui: replace colorid = 16 in 386
			qui: replace rgb = "248 99 223" in 387
			qui: replace colorid = 17 in 387
			qui: replace rgb = "255 98 191" in 388
			qui: replace colorid = 18 in 388
			qui: replace rgb = "255 106 154" in 389
			qui: replace colorid = 19 in 389
			qui: replace rgb = "248 118 109" in 390
			qui: replace colorid = 1 in 390
			qui: replace rgb = "234 131 49" in 391
			qui: replace colorid = 2 in 391
			qui: replace rgb = "216 144 0" in 392
			qui: replace colorid = 3 in 392
			qui: replace rgb = "192 155 0" in 393
			qui: replace colorid = 4 in 393
			qui: replace rgb = "163 165 0" in 394
			qui: replace colorid = 5 in 394
			qui: replace rgb = "124 174 0" in 395
			qui: replace colorid = 6 in 395
			qui: replace rgb = "57 182 0" in 396
			qui: replace colorid = 7 in 396
			qui: replace rgb = "0 187 78" in 397
			qui: replace colorid = 8 in 397
			qui: replace rgb = "0 191 125" in 398
			qui: replace colorid = 9 in 398
			qui: replace rgb = "0 193 163" in 399
			qui: replace colorid = 10 in 399
			qui: replace rgb = "0 191 196" in 400
			qui: replace colorid = 11 in 400
			qui: replace rgb = "0 186 224" in 401
			qui: replace colorid = 12 in 401
			qui: replace rgb = "0 176 246" in 402
			qui: replace colorid = 13 in 402
			qui: replace rgb = "53 162 255" in 403
			qui: replace colorid = 14 in 403
			qui: replace rgb = "149 144 255" in 404
			qui: replace colorid = 15 in 404
			qui: replace rgb = "199 124 255" in 405
			qui: replace colorid = 16 in 405
			qui: replace rgb = "231 107 243" in 406
			qui: replace colorid = 17 in 406
			qui: replace rgb = "250 98 219" in 407
			qui: replace colorid = 18 in 407
			qui: replace rgb = "255 98 188" in 408
			qui: replace colorid = 19 in 408
			qui: replace rgb = "255 106 152" in 409
			qui: replace colorid = 20 in 409
			qui: replace rgb = "248 118 109" in 410
			qui: replace colorid = 1 in 410
			qui: replace rgb = "235 131 53" in 411
			qui: replace colorid = 2 in 411
			qui: replace rgb = "218 143 0" in 412
			qui: replace colorid = 3 in 412
			qui: replace rgb = "196 154 0" in 413
			qui: replace colorid = 4 in 413
			qui: replace rgb = "169 164 0" in 414
			qui: replace colorid = 5 in 414
			qui: replace rgb = "134 172 0" in 415
			qui: replace colorid = 6 in 415
			qui: replace rgb = "83 180 0" in 416
			qui: replace colorid = 7 in 416
			qui: replace rgb = "0 186 56" in 417
			qui: replace colorid = 8 in 417
			qui: replace rgb = "0 190 109" in 418
			qui: replace colorid = 9 in 418
			qui: replace rgb = "0 192 148" in 419
			qui: replace colorid = 10 in 419
			qui: replace rgb = "0 192 181" in 420
			qui: replace colorid = 11 in 420
			qui: replace rgb = "0 189 210" in 421
			qui: replace colorid = 12 in 421
			qui: replace rgb = "0 182 235" in 422
			qui: replace colorid = 13 in 422
			qui: replace rgb = "0 171 253" in 423
			qui: replace colorid = 14 in 423
			qui: replace rgb = "97 156 255" in 424
			qui: replace colorid = 15 in 424
			qui: replace rgb = "165 138 255" in 425
			qui: replace colorid = 16 in 425
			qui: replace rgb = "208 120 255" in 426
			qui: replace colorid = 17 in 426
			qui: replace rgb = "236 105 239" in 427
			qui: replace colorid = 18 in 427
			qui: replace rgb = "251 97 215" in 428
			qui: replace colorid = 19 in 428
			qui: replace rgb = "255 99 185" in 429
			qui: replace colorid = 20 in 429
			qui: replace rgb = "255 107 150" in 430
			qui: replace colorid = 21 in 430
			qui: replace rgb = "248 118 109" in 431
			qui: replace colorid = 1 in 431
			qui: replace rgb = "236 130 57" in 432
			qui: replace colorid = 2 in 432
			qui: replace rgb = "219 142 0" in 433
			qui: replace colorid = 3 in 433
			qui: replace rgb = "199 152 0" in 434
			qui: replace colorid = 4 in 434
			qui: replace rgb = "174 162 0" in 435
			qui: replace colorid = 5 in 435
			qui: replace rgb = "143 170 0" in 436
			qui: replace colorid = 6 in 436
			qui: replace rgb = "100 178 0" in 437
			qui: replace colorid = 7 in 437
			qui: replace rgb = "0 184 27" in 438
			qui: replace colorid = 8 in 438
			qui: replace rgb = "0 189 92" in 439
			qui: replace colorid = 9 in 439
			qui: replace rgb = "0 192 133" in 440
			qui: replace colorid = 10 in 440
			qui: replace rgb = "0 193 167" in 441
			qui: replace colorid = 11 in 441
			qui: replace rgb = "0 191 196" in 442
			qui: replace colorid = 12 in 442
			qui: replace rgb = "0 186 222" in 443
			qui: replace colorid = 13 in 443
			qui: replace rgb = "0 178 243" in 444
			qui: replace colorid = 14 in 444
			qui: replace rgb = "0 166 255" in 445
			qui: replace colorid = 15 in 445
			qui: replace rgb = "124 150 255" in 446
			qui: replace colorid = 16 in 446
			qui: replace rgb = "179 133 255" in 447
			qui: replace colorid = 17 in 447
			qui: replace rgb = "216 116 253" in 448
			qui: replace colorid = 18 in 448
			qui: replace rgb = "239 103 235" in 449
			qui: replace colorid = 19 in 449
			qui: replace rgb = "253 97 211" in 450
			qui: replace colorid = 20 in 450
			qui: replace rgb = "255 99 182" in 451
			qui: replace colorid = 21 in 451
			qui: replace rgb = "255 107 148" in 452
			qui: replace colorid = 22 in 452
			qui: replace rgb = "248 118 109" in 453
			qui: replace colorid = 1 in 453
			qui: replace rgb = "236 130 60" in 454
			qui: replace colorid = 2 in 454
			qui: replace rgb = "221 141 0" in 455
			qui: replace colorid = 3 in 455
			qui: replace rgb = "202 151 0" in 456
			qui: replace colorid = 4 in 456
			qui: replace rgb = "179 160 0" in 457
			qui: replace colorid = 5 in 457
			qui: replace rgb = "151 169 0" in 458
			qui: replace colorid = 6 in 458
			qui: replace rgb = "113 176 0" in 459
			qui: replace colorid = 7 in 459
			qui: replace rgb = "47 182 0" in 460
			qui: replace colorid = 8 in 460
			qui: replace rgb = "0 187 75" in 461
			qui: replace colorid = 9 in 461
			qui: replace rgb = "0 191 118" in 462
			qui: replace colorid = 10 in 462
			qui: replace rgb = "0 192 152" in 463
			qui: replace colorid = 11 in 463
			qui: replace rgb = "0 192 183" in 464
			qui: replace colorid = 12 in 464
			qui: replace rgb = "0 189 209" in 465
			qui: replace colorid = 13 in 465
			qui: replace rgb = "0 183 232" in 466
			qui: replace colorid = 14 in 466
			qui: replace rgb = "0 174 250" in 467
			qui: replace colorid = 15 in 467
			qui: replace rgb = "61 161 255" in 468
			qui: replace colorid = 16 in 468
			qui: replace rgb = "143 145 255" in 469
			qui: replace colorid = 17 in 469
			qui: replace rgb = "190 128 255" in 470
			qui: replace colorid = 18 in 470
			qui: replace rgb = "222 113 249" in 471
			qui: replace colorid = 19 in 471
			qui: replace rgb = "242 101 231" in 472
			qui: replace colorid = 20 in 472
			qui: replace rgb = "254 97 207" in 473
			qui: replace colorid = 21 in 473
			qui: replace rgb = "255 100 179" in 474
			qui: replace colorid = 22 in 474
			qui: replace rgb = "255 108 146" in 475
			qui: replace colorid = 23 in 475
			qui: replace rgb = "248 118 109" in 476
			qui: replace colorid = 1 in 476
			qui: replace rgb = "237 129 62" in 477
			qui: replace colorid = 2 in 477
			qui: replace rgb = "222 140 0" in 478
			qui: replace colorid = 3 in 478
			qui: replace rgb = "205 150 0" in 479
			qui: replace colorid = 4 in 479
			qui: replace rgb = "183 159 0" in 480
			qui: replace colorid = 5 in 480
			qui: replace rgb = "157 167 0" in 481
			qui: replace colorid = 6 in 481
			qui: replace rgb = "124 174 0" in 482
			qui: replace colorid = 7 in 482
			qui: replace rgb = "73 181 0" in 483
			qui: replace colorid = 8 in 483
			qui: replace rgb = "0 186 56" in 484
			qui: replace colorid = 9 in 484
			qui: replace rgb = "0 190 103" in 485
			qui: replace colorid = 10 in 485
			qui: replace rgb = "0 192 139" in 486
			qui: replace colorid = 11 in 486
			qui: replace rgb = "0 193 169" in 487
			qui: replace colorid = 12 in 487
			qui: replace rgb = "0 191 196" in 488
			qui: replace colorid = 13 in 488
			qui: replace rgb = "0 187 220" in 489
			qui: replace colorid = 14 in 489
			qui: replace rgb = "0 180 240" in 490
			qui: replace colorid = 15 in 490
			qui: replace rgb = "0 169 255" in 491
			qui: replace colorid = 16 in 491
			qui: replace rgb = "97 156 255" in 492
			qui: replace colorid = 17 in 492
			qui: replace rgb = "159 140 255" in 493
			qui: replace colorid = 18 in 493
			qui: replace rgb = "199 124 255" in 494
			qui: replace colorid = 19 in 494
			qui: replace rgb = "227 110 246" in 495
			qui: replace colorid = 20 in 495
			qui: replace rgb = "245 100 227" in 496
			qui: replace colorid = 21 in 496
			qui: replace rgb = "255 97 204" in 497
			qui: replace colorid = 22 in 497
			qui: replace rgb = "255 100 176" in 498
			qui: replace colorid = 23 in 498
			qui: replace rgb = "255 108 145" in 499
			qui: replace colorid = 24 in 499
			
			// Add an additional 15 observations for the s2color defaults
			qui: set obs 514
			qui: replace palette = "s2color" in 500/514
			qui: replace pcolor = 15 in 500/514
			qui: replace maxcolors = 15 in 500/514
			
			// navy
			qui: replace rgb = "26 71 111" in 500
			qui: replace colorid = 1 in 500
			
			// maroon
			qui: replace rgb = "144 53 59" in 501
			qui: replace colorid = 2 in 501
			
			// forest_green
			qui: replace rgb = "85 117 47" in 502
			qui: replace colorid = 3 in 502
			
			// dkorange
			qui: replace rgb = "227 126 0" in 503
			qui: replace colorid = 4 in 503
			
			// teal
			qui: replace rgb = "110 142 132" in 504
			qui: replace colorid = 5 in 504
			
			// cranberry
			qui: replace rgb = "193 5 52" in 505
			qui: replace colorid = 6 in 505
			
			// lavender
			qui: replace rgb = "147 141 210" in 506
			qui: replace colorid = 7 in 506
			
			// khaki
			qui: replace rgb = "202 194 126" in 507
			qui: replace colorid = 8 in 507
			
			// sienna
			qui: replace rgb = "160 82 45" in 508
			qui: replace colorid = 9 in 508
			
			// emidblue
			qui: replace rgb = "123 146 168" in 509
			qui: replace colorid = 10 in 509
			
			// emerald
			qui: replace rgb = "45 109 102" in 510
			qui: replace colorid = 11 in 510
			
			// brown
			qui: replace rgb = "156 136 71" in 511
			qui: replace colorid = 12 in 511
			
			// erose
			qui: replace rgb = "191 161 156" in 512
			qui: replace colorid = 13 in 512
			
			// gold
			qui: replace rgb = "255 210 0" in 513
			qui: replace colorid = 14 in 513
			
			// bluishgray
			qui: replace rgb = "217 230 235" in 514
			qui: replace colorid = 15 in 514
			
			// Create a sequence ID for the Data set 
			qui: egen seqid = concat(palette pcolor colorid)
			
			// Local macros w/palette names
			loc sem1 "carsa, carse, foodsa, foodse, featuresa, featurese"
			loc sem2 "activitiesa, activitiese, fruita, fruite, veggiesa"
			loc sem3 "veggiese, brandsa, brandse, drinksa, drinkse"
			loc sem4 "mdebar, mdepoint, tableau, category10, category20"
			loc others "category20b, category20c, ggplot2, s2color"
			loc extrapalettes `"`sem1', `sem2', `sem3', `sem4', `others'"'
			
			// Return all added palette names in single local
			ret loc brewextrapalettes = `"`extrapalettes'"'
			
			// Return file path/name for file created
			ret loc brewextras = `"`c(sysdir_personal)'brewuser/extras.dta"'
							
			// Save the brew extras data set
			qui: save `"`c(sysdir_personal)'brewuser/extras.dta"', replace
			
			// Push the extras file through check file spec sub routine
			checkfilespec 
			
		} // End IF Block for replace/no extras file
									
		// If the files parameter contains an argument 								
		if `"`files'"' != "" {
		
			// Loop over the individual files listed in the argument
			forv i = 1/`: word count `files'' {
			
				// Check the individual files
				checkfilespec `"`: word `i' of `files''"'
			
				// Return name of file with palettes added
				ret loc brewextrafile`i' = `"`r(filenm)'"'
			
			} // End Loop over files
			
		} // End IF Block for files argument being non-null
		
	// Restore data to original state
	restore
		
// End of Subroutine definition
end


// Define subroutine to check the additional incoming files
prog def checkfilespec, rclass

	// Syntax structure for subroutine
	syntax [anything(name = infiles id = "Palette file")]
	
	// Preserve state of data currently in memory
	preserve
	
		// Onload load file if not null
		if `"`infiles'"' != "" {
		
			// Load the data file into memory
			qui: use `infiles', clear

		} // End IF Block for checking of file specifications
		
		// Strip any unnecessary compound/single quotes
		loc infiles `: list clean infiles'
		
		// Loop over required variables to make sure all necessary data is 
		// available
		foreach v in palette rgb seqid meta {
		
			// Confirm variable exists
			cap confirm variable `v'
			
			// If variable doesn't exist
			if _rc != 0 {
			
				// Display error message
				di as err "Variable `v' does not exist in the file."
				
				// Return code of 1
				ret sca code = 1

			} // End IF Block for variable existence
			
			// If variable exists check type
			else {
			
				// Check to make sure the variable is a string
				if regexm("`: type `v''", "str*") != 1 {
				
					// Print error message to console
					di as err "Variable `v' must be a string variable."
					
					// Return code of 1
					ret sca code = 1
					
				} // End IF Block for type cast checking
			
			} // End ELSE Block for type checking
			
		} // End Loop over string variables
		
		// Loop over numeric variables
		foreach v in colorblind print photocopy lcd colorid pcolor {
		
			// Confirm variable exists
			cap confirm variable `v'
			
			// If variable doesn't exist
			if _rc != 0 & inlist("`v'", "colorid", "pcolor") == 1 {
			
				// Display error message
				di as err "Variable `v' does not exist in the file."
				
				// Return code of 1
				ret sca code = 1

			} // End IF Block for variable existence
			
			// For the meta data variables create them if they don't exist
			else if _rc != 0 & !inlist("`v'", "colorid", "pcolor") == 1 {
			
				// Populate the meta data variables with missing codes for 
				// information not available
				qui: g `v' = .n
				
			} // End ELSEIF Block 
			
			// Otherwise secondary checks
			else {
			
				// For id variables they must be non-null
				if inlist("`v'", "colorid", "pcolor") == 1  {
				
					// See if any values are missing 
					qui: count if mi(`v')
					
					// Exit if missing values
					if `= r(N)' != 0 {
					
						// Print error message
						di as err `"Missing values encountered in `v'"'
						
						// Exit program
						exit
						
					} // End IF Block for no null value ids
					
				} // End IF Block for ID Variable additional validation
				
				// Otherwise
				else {
				
					// Replace missing values with coded missing values
					qui: replace `v' = .n if mi(`v')
					
				} // End ELSE Block for metadata variables
				
			} // End ELSE Block
			
		} // End Loop over numeric variables
		
		// Get the names of the palettes to add to the brewmeta data file
		qui: levelsof palette, loc(newpalettes)

		// Set the display order of the variables to match brewmeta.dta
		order palette colorblind print photocopy lcd colorid pcolor rgb 	 ///   
		maxcolors seqid meta

		// Compress dataset before saving
		qui: compress
		
		// Add colorblind transformed values to the file
		qui: brewtransform rgb
		
		// Check for path delimiters in the file name
		loc fnm = regexm(`"`infiles'"', "(\/)")
		
		// If filename includes path delimiters
		if `fnm' == 1 & `"`infiles'"' != "" {
		
			// Get new file name from user
			di as res "Enter a short file name for this palette" _request(_nfnm)

			// Save file to user directory
			qui: save `"`c(sysdir_personal)'brewuser/`nfnm'.dta"'
			
		} // End IF Block for filename with file path
		
		// If no path delimiters in name
		else if `fnm' == 0 & `"`infiles'"' != "" {
		
			// Set local macro for later reference
			loc nfnm `"`infiles'"'
		
			// If the file checks out thus far save it to the extras directory
			qui: save `"`c(sysdir_personal)'brewuser/`infiles'"', replace
					
		} // End ELSEIF Block for fileonly file name
		
		// For all other cases (e.g., null) save default file name
		else {
		
			// Default file built with program
			loc nfnm "extras.dta"
		
			// If the file checks out thus far save it to the extras directory
			qui: save `"`c(sysdir_personal)'brewuser/extras.dta"', replace
		
		} // End ELSE Block for default file name
		
		// Load brewmeta file
		qui: use `"`c(sysdir_personal)'b/brewmeta.dta"', clear
		
		// Get existing palettes characteristics
		loc existpalettes : char _dta[palettes]
	
		// Append new colors
		qui: append using `"`c(sysdir_personal)'brewuser/`nfnm'"'
		
		// Drop any duplicates
		qui: duplicates drop
		
		// Define meta data characteristics with available palettes
		char _dta[palettes] `"`existpalettes', `newpalettes'"'	
		
		// Save over old file
		qui: save, replace
	
	// Restore to original state of data in memory
	restore
	
	// Return a code of 0
	ret sca code = 0
	
	// Return file name
	ret loc filenm = `"`c(sysdir_personal)'brewuser/`infiles'"'
		
// End Subroutine
end		

