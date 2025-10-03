*! Title:       ctabxl.ado   
*! Version:     1.1 published on GitHub July 17, 2023
*! Author:      Zachary King 
*! Email:       zacharyjking90@gmail.com
*! Description: Tabulate Pearson and Spearman correlations in Excel

program def ctabxl

	* Ensure Stata runs ctabxl using version 17 syntax
	
	version 17
	
	* Define syntax

	syntax varlist(min=3 numeric) [if] [in] using/ [, ///
	tablename(string) sheetname(string)              ///
	sig(numlist max=1 >0 <1)                        ///
	roundto(numlist integer max=1 >0 <27)            ///
	extrarows(numlist integer max=1 >0 <11)         ///
	extracols(numlist integer max=1 >0 <11)        ///
	3stars(numlist sort min=3 max=3 >0 <1)           ///
	NOZEROS NOPW NOSTARS NOONES BOLD ITALIC         ///
	PEARSONONLY SPEARMANONLY PEARSONUPPER          ///
	BONFERRONI SIDAK REPLACE]
	
	* Preserve so current dataset is restored after program is finished running

	preserve
	
	* Ensure pearsononly, spearmanonly, pearsonupper not used in combination
	
	tempname option_check
	
	local `option_check' = 0
	
	if "`pearsononly'" != "" local `option_check' = ``option_check'' + 1
	if "`spearmanonly'" != "" local `option_check' = ``option_check'' + 1
	if "`pearsonupper'" != "" local `option_check' = ``option_check'' + 1
	
	if ``option_check'' > 1 {
		di as error "only one of {bf:pearsononly}, {bf:spearmanonly}, and {bf:pearsonupper} options is allowed"
		exit 198
	}
	
	* Turn spearmanonly on if pearsonupper specified
	
	if "`pearsonupper'" != "" local spearmanonly "spearmanonly"
	
	* Set default table name if not specified
	
	if "`tablename'" == "" local tablename = "Correlations"
	
	* Set default sheet name if not specified
	
	if "`sheetname'" == "" local sheetname = "Correlations"
	
	* Ensure bonferroni and sidak not used in combination
	
	if "`bonferroni'" != "" & "`sidak'" != "" {
		di as error "only one of {bf:bonferroni} and {bf:sidak} options is allowed"
		exit 198
	}
	
	* Validate length of sheet name not too long
	
	if length("`sheetname'") >= 32 {
		di as error "sheet name too long; must be less than 32 characters"
		exit 198
	}
	
	* Set default significance level if not specified
	
	if "`sig'" == "" local sig = 0.05
	
	* Set default rounding if not specified
	
	if "`roundto'" == "" local roundto = 2
	
	tempname digits 
	local `digits' = `roundto' + 2
	
	* Set default extra rows if not specified
	
	if "`extrarows'" == "" local extrarows = 0
	
	* Set default extra columns if not specified
	
	if "`extracols'" == "" local extracols = 0
	
	* If replace option not specified, verify current sheet does not exist
	
	if "`replace'" == "" {
		cap: import excel "`using'", sheet("`sheetname'") clear
		if _rc {
			restore
			preserve
		}
		else {
			restore
			di as error "worksheet {bf:`sheetname'} already exists, specify {bf:replace} option to overwrite it"
			exit 601
		}
	}
	
	* Set zeros to missing if nozeros is specified
	
	if "`nozeros'" != "" {
		foreach v of varlist `varlist' {
			qui: replace `v' = . if `v' == 0
		}
	}
	
	* Drop observations with missing values if nopw is specified
	
	if "`nopw'" != "" {
		foreach v of varlist `varlist' {
			qui: drop if `v' == .
		}
	}
	
	* Check standard deviations and display warning if no variation
	
	foreach v of varlist `varlist' {
		qui: summarize `v'
		if r(sd) == 0 di as error "Warning: `v' has no variation in it"
	}
	
	* Ensure bold, italic, and nostars options not used with 3stars option
	
	if "`3stars'" != "" & ("`bold'" != "" | "`italic'" != "" | "`nostars'" != "") {
		di as error "{bf:bold}, {bf:italic}, and {bf:nostars} options not allowed with {bf:3stars} option"
		exit 198
	}
	
	* Save significance levels if 3stars specified
	
	if "`3stars'" != "" {
		tempname snum s1 s2 s3
		local `snum' = 3
		foreach level of numlist `3stars' {
			local `s``snum''' = `level'
			local `snum' = ``snum'' - 1
		}
	}
	
	* Run correlations and save results
	
	if "`spearmanonly'" == "" | "`pearsonupper'" != "" {
		qui: pwcorr `varlist' `if' `in', sig `bonferroni' `sidak'
		tempname pcoef psig pobs
		matrix `pcoef' = r(C)
		matrix `psig' = r(sig)
		matrix `pobs' = r(Nobs)
	}
	
	if "`pearsononly'" == "" {
		qui: spearman `varlist' `if' `in', stats(rho p) pw `bonferroni' `sidak'
		tempname scoef ssig sobs
		matrix `scoef' = r(Rho)
		matrix `ssig' = r(P)
		matrix `sobs' = r(Nobs)
	}
	
	* Check if observations are same across every correlation
	
	tempname sameobs nvars pfirstob sfirstob
	local `sameobs' = 1
	local `nvars': list sizeof local(varlist)
	if "`spearmanonly'" == "" local `pfirstob' = `pobs'[1,1]
	if "`pearsononly'" == "" local `sfirstob' = `sobs'[1,1]
	
	forvalues i = 1/``nvars'' {
		forvalues j = 1/``nvars'' {
			if "`spearmanonly'" == "" {
				if ``pfirstob'' != `pobs'[`i',`j'] local `sameobs' = 0
			}
			if "`pearsononly'" == "" {
				if ``sfirstob'' != `sobs'[`i',`j'] local `sameobs' = 0
			}
			if "`pearsononly'" == "" & "`spearmanonly'" == "" {
				if `pobs'[`i',`j'] != `sobs'[`i',`j'] local `sameobs' = 0
			}
		}
	}
	
	* Open Excel
	
	qui: putexcel set "`using'", open modify sh("`sheetname'", replace)
	
	* Write table name to cell A1
	
	qui: putexcel A1 = "`tablename'"
	
	* Tokenize A, B, C, ... , AA, AB, AC, ... , ZZ to loop over Excel columns
	
	tempname cell_letters
	
	forvalues i = 0/26 {
		if `i' == 0 {
			forvalues j = 1/26 {
				local `cell_letters' = "``cell_letters'' " + char(`j' + 64)
			}
		}
		else {
			forvalues j = 1/26 {
				local `cell_letters' = "``cell_letters'' " + char(`i' + 64) + char(`j' + 64)
			}
		}
	}
	
	tokenize "``cell_letters''"
	
	* Write variable names to Excel
	
	tempname c
	local `c' = 2

	foreach v of varlist `varlist' {
		qui: putexcel ```c'''2 = "`v'"
		local `c' = ``c'' + 1 + `extracols'
	}
	
	tempname r
	local `r' = 3

	foreach v of varlist `varlist' {
		qui: putexcel A``r'' = "`v'"
		local `r' = ``r'' + 1 + `extrarows'
	}
	
	* Write correlation table note to Excel
	
	tempname signote
	
	if "`nostars'" != "" {
		if "`bold'" == "" & "`italic'" == "" local `signote' = ""
		else if "`bold'" != "" & "`italic'" != "" local `signote' = ", bold italics indicate significant at p-value < 0`sig' level (two-tailed)"
		else if "`bold'" != "" local `signote' = ", bold indicates significant at p-value < 0`sig' level (two-tailed)"
		else local `signote' = ", italics indicate significant at p-value < 0`sig' level (two-tailed)"
	}
	else {
		if "`bold'" == "" & "`italic'" == "" local `signote' = ", * indicates significant at p-value < 0`sig' level (two-tailed)"
		else if "`bold'" != "" & "`italic'" != "" local `signote' = ", bold italics with * indicates significant at p-value < 0`sig' level (two-tailed)"
		else if "`bold'" != "" local `signote' = ", bold with * indicates significant at p-value < 0`sig' level (two-tailed)"
		else local `signote' = ", italics with * indicates significant at p-value < 0`sig' level (two-tailed)"
	}
	
	if "`3stars'" != "" local `signote' = ", *** (**, *) indicates significant at p-value < 0``s3'' (0``s2'', 0``s1'') level (two-tailed)"   
	
	if "`bonferroni'" != "" local `signote' = "``signote'', Bonferroni adjustment used to calculate p-values"
	else if "`sidak'" != "" local `signote' = "``signote'', Sidak adjustment used to calculate p-values"
	
	if "`pearsononly'" != "" qui: putexcel A``r'' = "Pearson correlations``signote''"
	else if "`pearsonupper'" != "" qui: putexcel A``r'' = "Spearman correlations in bottom triangle, Pearson correlations in top triangle``signote''"
	else if "`spearmanonly'" != "" qui: putexcel A``r'' = "Spearman correlations``signote''"
	else qui: putexcel A``r'' = "Pearson correlations in bottom triangle, Spearman correlations in top triangle``signote''"
	
	* Write number of observations to Excel if same for every correlation, or 
	* variable names to observation matrix if different across correlations
	
	local `r' = ``r'' + 1
	
	if ``sameobs'' == 1 & "`spearmanonly'" != "" qui: putexcel A``r'' = "Number of observations: ``sfirstob'' (same for every correlation coefficient)"
	else if ``sameobs'' == 1 qui: putexcel A``r'' = "Number of observations: ``pfirstob'' (same for every correlation coefficient)"
	
	else{
		
		local `r' = ``r'' + 1
		qui: putexcel A``r'' = "Number of observations for each correlation coefficient:"
		
		local `r' = ``r'' + 1
		local `c' = 2

		foreach v of varlist `varlist' {
			qui: putexcel ```c'''``r'' = "`v'"
			local `c' = ``c'' + 1 + `extracols'
		}
		
		local `r' = ``r'' + 1

		foreach v of varlist `varlist' {
			qui: putexcel A``r'' = "`v'"
			local `r' = ``r'' + 1 + `extrarows'
		}
	}
	
	* Write correlations to lower triangle
	
	tempname corrval nr
	
	local `c' = 2
	
	forvalues i = 1/``nvars'' {
		local `r' = 3
		local `nr' = 7 + ``nvars'' + ``nvars''*`extrarows'
		forvalues j = 1/``nvars'' {
			if `i' == `j' {
				if "`noones'" == "" qui: putexcel ```c'''``r'' = "1"
				if ``sameobs'' != 1 & "`spearmanonly'" != "" qui: putexcel ```c'''``nr'' = `sobs'[`j',`i']
				else if ``sameobs'' != 1 qui: putexcel ```c'''``nr'' = `pobs'[`j',`i']
			}
			else if `j' > `i' {
				if "`spearmanonly'" != "" {
					local `corrval' : di %-``digits''.`roundto'fc `scoef'[`j',`i']
					if `ssig'[`j',`i'] < `sig' & "`nostars'" == "" & "`3stars'" == "" qui: putexcel ```c'''``r'' = "``corrval''*"
					else if "`3stars'" != "" {
						if `ssig'[`j',`i'] < ``s3'' qui: putexcel ```c'''``r'' = "``corrval''***"
						else if `ssig'[`j',`i'] < ``s2'' qui: putexcel ```c'''``r'' = "``corrval''**"
						else if `ssig'[`j',`i'] < ``s1'' qui: putexcel ```c'''``r'' = "``corrval''*"
						else qui: putexcel ```c'''``r'' = "``corrval''"
					}
					else qui: putexcel ```c'''``r'' = "``corrval''"
					if `ssig'[`j',`i'] < `sig' & ("`bold'" != "" | "`italic'" != "") qui: putexcel ```c'''``r'', overwritefmt `bold' `italic'
				}
				else {
					local `corrval' : di %-``digits''.`roundto'fc `pcoef'[`j',`i']
					if `psig'[`j',`i'] < `sig' & "`nostars'" == "" & "`3stars'" == "" qui: putexcel ```c'''``r'' = "``corrval''*"
					else if "`3stars'" != "" {
						if `psig'[`j',`i'] < ``s3'' qui: putexcel ```c'''``r'' = "``corrval''***"
						else if `psig'[`j',`i'] < ``s2'' qui: putexcel ```c'''``r'' = "``corrval''**"
						else if `psig'[`j',`i'] < ``s1'' qui: putexcel ```c'''``r'' = "``corrval''*"
						else qui: putexcel ```c'''``r'' = "``corrval''"
					}
					else qui: putexcel ```c'''``r'' = "``corrval''"
					if `psig'[`j',`i'] < `sig' & ("`bold'" != "" | "`italic'" != "") qui: putexcel ```c'''``r'', overwritefmt `bold' `italic'
				}
				if ``sameobs'' != 1 & "`spearmanonly'" != "" qui: putexcel ```c'''``nr'' = `sobs'[`j',`i']
				else if ``sameobs'' != 1 qui: putexcel ```c'''``nr'' = `pobs'[`j',`i']
			}
			local `r' = ``r'' + 1 + `extrarows'
			local `nr' = ``nr'' + 1 + `extrarows'
		}
		local `c' = ``c'' + 1 + `extracols'
	}
	
	* Write correlations to upper triangle
	
	local `r' = 3
	local `nr' = 7 + ``nvars'' + ``nvars''*`extrarows'
	
	forvalues i = 1/``nvars'' {
		if "`pearsononly'" != "" continue, break 
		if "`spearmanonly'" != "" & "`pearsonupper'" == "" continue, break 
		local `c' = 2
		forvalues j = 1/``nvars'' {
			if `j' > `i' {
				if "`pearsonupper'" == "" {
					local `corrval' : di %-``digits''.`roundto'fc `scoef'[`i',`j']
					if `ssig'[`i',`j'] < `sig' & "`nostars'" == "" & "`3stars'" == "" qui: putexcel ```c'''``r'' = "``corrval''*"
					else if "`3stars'" != "" {
						if `ssig'[`i',`j'] < ``s3'' qui: putexcel ```c'''``r'' = "``corrval''***"
						else if `ssig'[`i',`j'] < ``s2'' qui: putexcel ```c'''``r'' = "``corrval''**"
						else if `ssig'[`i',`j'] < ``s1'' qui: putexcel ```c'''``r'' = "``corrval''*"
						else qui: putexcel ```c'''``r'' = "``corrval''"
					}
					else qui: putexcel ```c'''``r'' = "``corrval''"
					if `ssig'[`i',`j'] < `sig' & ("`bold'" != "" | "`italic'" != "") qui: putexcel ```c'''``r'', overwritefmt `bold' `italic'
					if ``sameobs'' != 1 qui: putexcel ```c'''``nr'' = `sobs'[`i',`j']
				}
				else {
					local `corrval' : di %-``digits''.`roundto'fc `pcoef'[`i',`j']
					if `psig'[`i',`j'] < `sig' & "`nostars'" == "" & "`3stars'" == "" qui: putexcel ```c'''``r'' = "``corrval''*"
					else if "`3stars'" != "" {
						if `psig'[`i',`j'] < ``s3'' & "`3stars'" != "" qui: putexcel ```c'''``r'' = "``corrval''***"
						else if `psig'[`i',`j'] < ``s2'' & "`3stars'" != "" qui: putexcel ```c'''``r'' = "``corrval''**"
						else if `psig'[`i',`j'] < ``s1'' & "`3stars'" != "" qui: putexcel ```c'''``r'' = "``corrval''*"
						else qui: putexcel ```c'''``r'' = "``corrval''"
					}
					else qui: putexcel ```c'''``r'' = "``corrval''"
					if `psig'[`i',`j'] < `sig' & ("`bold'" != "" | "`italic'" != "") qui: putexcel ```c'''``r'', overwritefmt `bold' `italic'
					if ``sameobs'' != 1 qui: putexcel ```c'''``nr'' = `pobs'[`i',`j']
				}
			}
			local `c' = ``c'' + 1 + `extracols'
		}
		local `r' = ``r'' + 1 + `extrarows'
		local `nr' = ``nr'' + 1 + `extrarows'
	}
	
	* Close Excel
	
	qui: putexcel close
	
end