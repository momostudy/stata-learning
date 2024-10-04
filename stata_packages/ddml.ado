*! ddml v1.2
*! last edited: 21 jan 2023
*! authors: aa/ms

* notes:
* e.command		= tokens(estcmd)[1,1] fails if command string starts with a prefix e.g. capture
* check for incompatible y variables disabled - can't accommodate prefixes e.g. capture
* spin off init code into a subroutine?
* init code current calls _ddml_sample to set fold var, kfolds, etc. Allow options with init?

// (no)prefix option not implemented; prefixes not added (where prefix = `model'_)

program ddml	// no class - some subcommands are eclass, some are rclass

	version 14
	local lversion 0.5
	
	if replay() {
		syntax [, VERsion * ]
		 if "`version'"~="" & "`options'"=="" {
		 	// report version and exit
		 	_ddml_version, version(`lversion')
		 }
		 else {
			// recursive
			ddml estimate `e(mname)', rep(`e(rep)') spec(`e(spec)') notable replay
		}
	}
	else {
	
		local allargs `0'
		
		// split into before/after :
		tokenize "`allargs'", parse(":")
		local maincmd `1'
		macro shift 2
		local eqn `*'
		
		// parse first part using syntax
		local 0 "`maincmd'"
		// options used here already parsed out
		syntax [anything(name=mainargs)]		///
				[using/]						/// 
				[if] [in]						/// if/in sent to _ddml_sample
					 , [						///
						mname(name)				///
						newmname(name)			///
						fcluster(varname)		/// cluster by fold (ddml define)
						cluster(varname)		/// cluster-robust VCV (ddml estimate)
						Learner(name)			///
						predopt(string asis)	///
						vname(name)				///
						vtype(string)			///  "double", "float" etc
						REPlace					///
						cmdname(name)			///
						/* NOPrefix */ 			/// don't add model name as prefix (disabled - interferes with save/use option)
						*						///
						]
		// now parse main args; first element is subcmd
		tokenize "`mainargs'"
		local subcmd `1'
		macro shift
		// restmainargs is main args minus the subcommand
		local restmainargs `*'
		
		// should perhaps make subcmd list all lower case (more forgiving) and replace `subcmd' with strlower("`subcmd'").
		local alleqntypes E[Y|X] E[Y|X,D] E[Y|D,X] E[Y|X,Z] E[Y|Z,X] E[D|X] E[D|Z,X] E[D|X,Z] E[Z|X] yeq deq zeq dheq
		local allsubcmds  update describe export drop copy sample init reinit yeq deq dheq zeq crossfit estimate extract overlap which
		local allsubcmds `allsubcmds' `alleqntypes'
		if strpos("`allsubcmds'","`subcmd'")==0 {
			di as err "error - unknown subcommand `subcmd'"
			exit 198
		}
		
		// assign and check model name
		if "`mname'"=="" {
			local mname m0 // sets the default name
		}
		if ("`subcmd'"~="init" & "`subcmd'"~="extract" & "`subcmd'"~="update") {
			// exits with error if mname is not an mStruct
			check_mname "`mname'"
		}
		else if "`subcmd'"=="init"  {
			// we are initializing mname; warn if this overwrites an existing mStruct
			cap check_mname "`mname'"
			if _rc==0 {
				// did not exit with error, so it's an existing mStruct
				di as res "warning - model `mname' already exists"
				di as res "all existing model results and variables will"
				di as res "be dropped and model `mname' will be re-initialized"
				_ddml_drop, mname(`mname')
			}
		}
		else {
			// ddml extract or update; do nothing
		}
	
		*** get latest version
		if "`subcmd'"=="update" {
			net install ddml, from(https://raw.githubusercontent.com/aahrens1/ddml/master/) replace
		} 
		
		*** describe model
		if substr("`subcmd'",1,4)=="desc" {
			_ddml_describe `mname', `options'
		}
	
		*** export model
		if "`subcmd'"=="export" {
			if "`using'"=="" {
				di as err "error - syntax is 'using <destination filename>'"
				exit 198
			}
			_ddml_export, mname(`mname') fname(`using') `replace' `options'
		}
		
		*** drop model
		if "`subcmd'"=="drop" {
			_ddml_drop, mname(`mname')
		}
	
		*** copy model
		if "`subcmd'"=="copy" {
			if "`newmname'"=="" {
				di as err "error - newmname(.) option required"
				exit 198
			}
			_ddml_copy, mname(`mname') newmname(`newmname')
		}
		
		*** extract from model
		if "`subcmd'"=="extract" {
			local objname: word 2 of `mainargs'
			_ddml_extract `objname', mname(`mname') vname(`vname') `options'		
		}
	
		*** initialize new estimation
		if "`subcmd'"=="init" {
			local model: word 1 of `restmainargs'
			local allmodels		partial iv interactive late fiv interactiveiv
			if strpos("`allmodels'","`model'")==0 {
				di as err "no or wrong model specified." 
				exit 198
			}
			// interactiveiv is synonym of late; internally we use "late"
			if "`model'"=="interactiveiv" local model late
				
			mata: `mname'=init_mStruct()
			cap drop `mname'_id
			qui gen double `mname'_id	= _n
			mata: `mname'.id			= st_data(., "`mname'_id")
			// create and store sample indicator; initialized so all obs are used
			cap drop `mname'_sample
			// in case total sample limited by if or in:
			marksample touse
			qui gen byte `mname'_sample = `touse'
			if "`fcluster'"~="" {
				// fold cluster variable; can be real (missing=.) or string (missing="")
				cap replace `mname'_sample = 0 if `fcluster'==.			// real
				cap replace `mname'_sample = 0 if `fcluster'==""		// string
			}
			// fill by hand
			mata: `mname'.model			= "`model'"
			mata: `mname'.fclustvar		= "`fcluster'"
			// initialize with default fold var, kfolds, number of resamplings
			_ddml_sample `if' `in' , mname(`mname') `options'
		}
		
		*** reinitialize = drop crossfit and estimation results
		if "`subcmd'"=="reinit" {
			mata: clear_model_results(`mname')
			// update fold vars, kfolds, number of resamplings
			_ddml_sample `if' `in' , mname(`mname') `options'
		}
				
		*** set sample, foldvar, etc.
		if "`subcmd'"=="sample" {
			_ddml_sample `if' `in' , mname(`mname') `options'
		}
		
		*** add equation
		// condition will be nonzero (true) if subcmd (2nd arg) appears anywhere in the list (first arg).
		if strpos("`alleqntypes'","`subcmd'") {
	
			** check that ddml has been initialized
			// to add

			** variable type
			if "`vtype'"=="" local vtype double
			if "`vtype'"=="none" local vtype
	
			** check that equation is consistent with model
			mata: st_local("model",`mname'.model)
			if ("`model'"=="late"&strpos("E[D|Z,X] E[D|X,Z] E[Z|X] E[Y|X,Z] E[Y|Z,X] yeq deq zeq","`subcmd'")==0) {
				di as err "not allowed; `subcmd' not allowed with `model'"
				exit 198
			}
			if ("`model'"=="iv"&strpos("E[Y|X] E[D|X] E[Z|X] yeq deq zeq","`subcmd'")==0) {
				di as err "not allowed; `subcmd' not allowed with `model'"
				exit 198
			}
			if ("`model'"=="partial"&strpos("E[Y|X] E[D|X] yeq deq","`subcmd'")==0) {
				di as err "not allowed; `subcmd' not allowed with `model'"
				exit 198
			}
			if ("`model'"=="interactive"&strpos("E[D|X] E[Y|X,D] E[Y|D,X] yeq deq","`subcmd'")==0) {
				di as err "not allowed; `subcmd' not allowed with `model'"
				exit 198
			}
			if ("`model'"=="fiv"&strpos("E[D|Z,X] E[D|X,Z] E[Y|X] E[D|X] yeq deq dheq","`subcmd'")==0) {
				di as err "not allowed; `subcmd' not allowed with `model'"
				exit 198
			}
	
			** convert to internal equation names
			if "`subcmd'"=="E[Y|X]" local subcmd yeq
			if "`subcmd'"=="E[Y|X,D]"|"`subcmd'"=="E[Y|D,X]" local subcmd yeq
			if "`subcmd'"=="E[Y|X,Z]"|"`subcmd'"=="E[Y|Z,X]" local subcmd yeq
			if "`subcmd'"=="E[D|X]"&"`model'"!="fiv" local subcmd deq
			if "`subcmd'"=="E[D|X]"&"`model'"=="fiv" local subcmd dheq
			if "`subcmd'"=="E[Z|X]" local subcmd zeq
			if "`subcmd'"=="E[D|X,Z]"|"`subcmd'"=="E[D|Z,X]" local subcmd deq

			** vtilde: use 2nd and 1st words of eq (estimator) as the default
			if "`learner'"=="" {
				if "`subcmd'"=="yeq" {
					mata: st_local("counter",strofreal(`mname'.ycounter))
					mata: `mname'.ycounter = `counter'+1
					local prefix Y`counter'
				}
				else if "`subcmd'"=="deq" {
					mata: st_local("counter",strofreal(`mname'.dcounter))
					mata: `mname'.dcounter = `counter'+1
					local prefix D`counter'
				}
				else if "`subcmd'"=="zeq" {
					mata: st_local("counter",strofreal(`mname'.zcounter))
					mata: `mname'.zcounter = `counter'+1
					local prefix Z`counter'
				}
				else if "`subcmd'"=="dheq" {
					di as err "learner() required with 'ddml E[D|X]'"
					exit 198
				}
				else {
					di as err "ddml equation error - subcmd `subcmd'"
					exit 198
				}
				tokenize `"`eqn'"'
				local learner `prefix'_`1'
			}
	
			** vname: use 2nd word of eq (dep var) as the default 
			if "`vname'"=="" & "`subcmd'"=="dheq" {
				di as err "vname() required with 'ddml E[D|X]'"
			}
			else if "`vname'"=="" & "`subcmd'"!="dheq" {
				// tokenize `"`eqn'"'
				// local vname `2'
				// below deals with commas e.g. stacking y, ...
				local 0 `"`eqn'"'
				syntax [anything] [if] [in] [ , * ]
				local vname : word 2 of `anything'
			}
			** check that dep var in eqn isn't already used for some other eqn
			** also set flag for whether dep var is new
			mata: st_local("yvar",`mname'.nameY)
			mata: st_local("dvlist",invtokens(`mname'.nameD))
			mata: st_local("zvlist",invtokens(`mname'.nameZ))
			local posof_y : list posof "`vname'" in yvar
			local posof_d : list posof "`vname'" in dvlist
			local posof_z : list posof "`vname'" in zvlist
			if ("`subcmd'"=="yeq" | "`subcmd'"=="deq") & `posof_z' {
				di as err "not allowed - `vname' already in use in Z eqn"
				exit 198
			}
			if ("`subcmd'"=="deq" | "`subcmd'"=="zeq") & `posof_y' {
				di as err "not allowed - `vname' already in use in Y eqn"
				exit 198
			}
			if ("`subcmd'"=="yeq" | "`subcmd'"=="zeq") & `posof_d' {
				di as err "not allowed - `vname' already in use in D eqn"
				exit 198
			}
			// parsimonious way of getting posof that doesn't require checking eqn type
			local posof = `posof_y' + `posof_d' + `posof_z'
			
			// check syntax of D-eq with LIE
			if "`subcmd'"=="dheq" {
				if regexm(`"`eqn'"',"{D}")==0 {
					di as err "placeholder {D} for E[D^|X] is missing"
					exit 198				
				}
			}
					
			add_eqn_to_model,						///
								mname(`mname')		///
								vname(`vname')		///
								vtilde(`learner')	///
								vtype(`vtype')		///
								predopt(`predopt') 	///
								subcmd(`subcmd')	///
								posof(`posof')		///
								estring(`eqn')		///
								cmdname(`cmdname')
			
		}
	
		*** cross-fitting
		if "`subcmd'" =="crossfit" {
	
			// crossfit
			_ddml_crossfit, `options' mname(`mname') 
			
		}
	
		*** estimate
		if "`subcmd'" =="estimate" {
			
			mata: st_global("r(model)",`mname'.model)
			// cluster(varname) syntax is for ddml estimate; fcluster(varname) is for ddml define
			if ("`r(model)'"=="partial") {
				_ddml_estimate_linear `mname' `if' `in', `options' cluster(`cluster')
			}
			if ("`r(model)'"=="iv") {
				_ddml_estimate_linear `mname' `if' `in', `options' cluster(`cluster')
			}
			if ("`r(model)'"=="interactive") {
				_ddml_estimate_ate_late `mname' `if' `in', `options' cluster(`cluster')
			}
			if ("`r(model)'"=="late") {
				_ddml_estimate_ate_late `mname' `if' `in', `options' cluster(`cluster')
			}
			if ("`r(model)'"=="fiv") {
				_ddml_estimate_linear `mname' `if' `in', `options' cluster(`cluster')
			}
			
		}
		
		*** overlap (treatment effects only)
		if "`subcmd'" == "overlap" {
		
			_ddml_overlap, mname(`mname') `options'
		
		}
		
		if "`subcmd'" == "which" {
		
			foreach ado in 						///
				ddml.ado						///
				qddml.ado						///
				crossfit.ado					///
				_ddml_allcombos.ado				///
				_ddml_copy.ado					///
				_ddml_crossfit.ado				///
				_ddml_describe.ado				///
				_ddml_drop.ado					///
				_ddml_estimate_ate_late.ado		///
				_ddml_estimate_linear.ado		///
				_ddml_export.ado				///
				_ddml_extract.ado				///
				_ddml_nnls.ado					///
				_ddml_nnls_p.ado				///
				_ddml_overlap.ado				///
				_ddml_sample.ado				///
				_ddml_save.ado					///
				_ddml_use.ado					{
				
				which `ado', all
			}
			di
			di as text "mata: whichddmml()" _c
			mata: whichddml()
		
		}
		
	}

end

prog define check_mname

	args mname

	mata: st_local("isnull",strofreal(findexternal("`mname'")==NULL))
	if `isnull' {
		di as err "model `mname' not found"
		exit 3259
	}
	
	mata: st_local("eltype",eltype(`mname'))
	if "`eltype'"~="struct" {
		di as err "model `mname' is not a struct"
		exit 3259
	}

	mata: st_local("structname",structname(`mname'))
	if "`structname'"~="mStruct" {
		di as err "model `mname' is not an mStruct"
		exit 3000
	}

end

program define add_eqn_to_model, rclass

	syntax [anything],								/// 
							[						///
							mname(name)				/// name of mata struct with model
							vname(varname)			/// name of dep var in equation (to be orthogonalized)
							vtilde(name)			/// names of tilde variable
							vtype(string)			///
							predopt(string asis)	///
							subcmd(string)			/// yeq, deq, dheq or zeq
							estring(string asis)	/// names of estimation strings
													/// need asis option in case it includes strings
							posof(integer 0)		/// position of vname in name list; =0 if a new vname (new eqn)
							NOIsily					///
							cmdname(name)			///
							]

	// syntax checks
	mata: st_local("model",`mname'.model)
	// ATE or LIE with multiple D variables not supported
	if "`subcmd'"=="deq" & ("`model'"=="interactive" | "`model'"=="fiv") {
		mata: st_local("nameD",invtokens(`mname'.nameD))
		local nlist `nameD' `vname'
		local nlist : list uniq nlist
		local nlist : list sizeof nlist
		if `nlist' > 1 {
			di as err "error - multiple D variables not supported with `model' (`nameD' `vname')"
			exit 198
		}
	}
	// LATE with multiple Z variables not supported
	if "`subcmd'"=="zeq" & "`model'"=="late" {
		mata: st_local("nameZ",invtokens(`mname'.nameZ))
		local nlist `nameZ' `vname'
		local nlist : list uniq nlist
		local nlist : list sizeof nlist
		if `nlist' > 1 {
			di as err "error - multiple Z variables not supported with LATE (`nameZ' `vname')"
			exit 198
		}
	}
	
	// used for temporary Mata object
	tempname t
	
	// blank eqn - declare this way so that it's a struct and not transmorphic
	tempname eqn
	mata: `eqn' = init_eStruct()
	
	if `posof'==0 {
		// vname new to model so need a new eqn struct for it
		mata: `eqn'.vname = "`vname'"
	}
	else {
		// fetch existing eqn struct from model
		mata: `eqn' = (`mname'.eqnAA).get("`vname'")
	}
	
	// add vtilde to vtlist if not already there
	mata: st_local("vtlist",invtokens(`eqn'.vtlist))
	local posof_vt : list posof "`vtilde'" in vtlist
	if `posof_vt'!=0 & "`subcmd'"!="dheq" {
		di as text "Replacing existing learner `vtilde'..."
	}
	else if `posof_vt'==0 & "`subcmd'"!="dheq" {
		local vtlist `vtlist' `vtilde'
		local vtlist : list uniq vtlist		// should be unnecessary
		// in two steps, to accommodate singleton lists (which are otherwise string scalars and not matrices)
		mata: `t' = tokens("`vtlist'")
		mata: `eqn'.vtlist	= `t'
	}
	else if `posof_vt'==0 & "`subcmd'"=="dheq" {
		di as text "Learner `vtilde' not found. You first need to add learner for E[D|X,Z]."
		exit 198
	}
	
	// used below with syntax command
	local 0 `"`estring'"'
	// parse estimation string into main command and options; if and in will be stripped out
	syntax [anything] [if] [in] , [*]
	local est_main `anything'
	local est_options `options'
	if "`cmdname'"=="" local cmdname: word 1 of `est_main'
	if "`subcmd'"=="dheq" {
		mata: st_local("lieflag",strofreal(`eqn'.lieflag))
		if ("`lieflag'"=="1") di as text "Replacing existing learner `vtilde'_h..."
		mata: add_learner_item(`eqn',"`vtilde'","cmd_h","`cmdname'")
		mata: add_learner_item(`eqn',"`vtilde'","estring_h","`0'")
		mata: add_learner_item(`eqn',"`vtilde'","est_main_h","`est_main'")
		mata: add_learner_item(`eqn',"`vtilde'","est_options_h","`est_options'")
		mata: add_learner_item(`eqn',"`vtilde'","predopt_h","`predopt'")
		mata: add_learner_item(`eqn',"`vtilde'","vtype_h","`vtype'")
		mata: `eqn'.lieflag = 1
	}
	else {
		mata: add_learner_item(`eqn',"`vtilde'","cmd","`cmdname'")
		mata: add_learner_item(`eqn',"`vtilde'","estring","`0'")
		mata: add_learner_item(`eqn',"`vtilde'","est_main","`est_main'")
		mata: add_learner_item(`eqn',"`vtilde'","est_options","`est_options'")
		mata: add_learner_item(`eqn',"`vtilde'","predopt","`predopt'")
		mata: add_learner_item(`eqn',"`vtilde'","vtype","`vtype'")
		// update nlearners - counts deq and dheq as a single learner
		mata: `eqn'.nlearners = cols(`eqn'.vtlist)
		mata: `eqn'.lieflag = 0
		if "`model'"=="interactive" & "`subcmd'"=="yeq" {
			mata: `eqn'.ateflag = 1
		}
		else if "`model'"=="late" & ("`subcmd'"=="yeq" | "`subcmd'"=="deq") {
			mata: `eqn'.ateflag = 1
		}
	}

	// insert eqn struct into model struct
	mata: (`mname'.eqnAA).put("`vname'",`eqn')
	
	// update rest of model struct
	if `posof'==0 {
		mata: `t' = tokens("`vname'")
		if "`subcmd'"=="yeq" {
			// only ever 1 y eqn
			mata: `mname'.nameY = "`vname'"
			}
		else if "`subcmd'"=="deq" | "`subcmd'"=="dheq" {
			mata: `mname'.nameD = (`mname'.nameD, `t')			
		}
		else if "`subcmd'"=="zeq" {
			mata: `mname'.nameZ = (`mname'.nameZ, `t')			
		}
	}
	
	if "`subcmd'"=="dheq" {
		di as text "Learner `vtilde'_h added successfully."
	}
	else {
		di as text "Learner `vtilde' added successfully."
	}
	
	// no longer needed so clear from Mata
	cap mata: mata drop `t'
	cap mata: mata drop `eqn'

end

program define _ddml_version, eclass
	syntax , version(string)
	
	di as text "`version'"
	ereturn clear
	ereturn local version `version'
	
end
	
