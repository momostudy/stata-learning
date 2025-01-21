*! version 2.0  Jun 2023

program quaidsce, eclass

	version 12

	syntax varlist [if] [in] ,					///
		  ANOT(real)						///
		  REPS(real)						///
		[ LNEXPenditure(varlist min=1 max=1 numeric) 		///
		  EXPenditure(varlist min=1 max=1 numeric) 		///
		  PRices(varlist numeric)				///
		  LNPRices(varlist numeric) 				///
		  DEMOgraphics(varlist numeric)				///
		  noQUadratic 						///
		  noCEnsor   ///
		  INITial(name) noLOg Level(cilevel) Method(name) * ] 	
	
	if replay() {
		if "`e(cmd)'" != "quaidsce" {
			error 301 
		}
		Display `0'
		exit
	}
	
	parallel bs, reps(`reps'): quaidsce_c `0'

end

exit

