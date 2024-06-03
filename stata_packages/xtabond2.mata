*! xtabond2 3.7.0 22 November 2020
// Copyright (C) 2005-20 David Roodman. May be distributed free.

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

mata
mata clear
mata drop *()
mata set matastrict on
mata set mataoptimize on
mata set matalnum off


struct IVinst {
	real scalar mz, passthru, equation
	string scalar ivstyle, BaseVarNames
	real matrix Base     // instrumenting variables
	pointer (struct IVinst scalar) scalar next
}

struct GMMinst {
	real scalar equation, passthru, FullInstSetEq, NumInsts, NumBaseVars, collapse, FullInstSetDiffed, MakeExtraInsts, InstOrthogonal
	string scalar gmmstyle, BaseVarNames
	real matrix Laglim, Base
	real colvector BaseNameTs // time index of each instrumen, before lagging
	pointer (real matrix) colvector BaseAll
	pointer (string colvector) colvector BaseNamesAll
	pointer (struct GMMinst scalar) scalar next
}

struct ClustInfo {
	real colvector ID
	real scalar N, sign, OneVar
	pointer (real matrix) colvector pZe1i
}



real scalar xtabond2_mata() {
	real scalar artests, arlevels, steps, h, consopt, r, r2, small, robust, onestepnonrobust,
		j, j0, k, NObs, NObsEff, NGroups, diffsargan, NOtherInsts,
		Nnottouse, NIVOptions, NGMMOptions, NDiffSargans, tmin, 
		N, T, NT, SystemGMM, RowsPerGroup, SystemHeight, j_GMM, j_IV, weights, wttot, rc, svmat, svvar, tdelta, pca, components, KMO, MinNClust
	real matrix tmp, Xi, X0, Y0, Subscripts, Z_IV, Z_GMM, SubscriptsStart, SubscriptsStep, eigenvectors
	string scalar idName, tName, LevelArg, optionsArg, touseName, bname, Vname, idSampleName, wtvarname, wtype, wexp, tsfmt
	string rowvector VarlistNames, Xnames, InstOptTxt, ClustVars
	string matrix Stripe, ZGMMnames, ZIVnames, eigenvectorBasisNames
	real colvector p, p_IV, p_GMM, p_AllIV, p_AllGMM, p_System, touseVar, idVar, tVar0, tVar, SortByIDEq, SortByEqID, ErrorEq, nottouse, Fill, touse, Complete,
		wt, wt0, _wt, wtvar, ideqt, Xiota
	struct ClustInfo colvector clusts
	pointer(real rowvector) matrix InstOptInd
	real rowvector TiMinMax, mz, passthru, equation, collapse, orthogonal, eigenvalues, keep
	pointer(struct GMMinst scalar) GMM, GMMinsts
	pointer (struct IVinst scalar) IV, IVinsts
	real colvector e1, e2, b1, b2, Ze, ZeDiffSargan, ARz, ARp, A1diag, Xcons, b
	real matrix S, D, ZXi, Z, Zi, A1Ze, A2Ze, H, V1, V2, _V, A1, A2, App, V1robust, V2robust, XZA, VXZA, m2VZXA,
		  diffsargans, X, Y, ZX, ZXp, ZY, laglimits, V
	real scalar c, i, sig2, g, sarganDF, sargan, sarganp, hansen, hansenp, DFm, DFr, F, Fp, chi2, chi2p
	pointer (real matrix) pA, pV, pVrobust
	pointer (real matrix) colvector pei, pZe1i, pX
	pointer (real colvector) pe, pwe, ptouse
	pointer (real matrix function) pfnXform

	pragma unset NIVOptions; pragma unset NGMMOptions; pragma unset j_GMM; pragma unset Z_IV; pragma unset InstOptTxt
	pragma unset p; pragma unset touseVar; pragma unset idVar; pragma unset tVar0; pragma unset wtvar; pragma unset InstOptInd
	pragma unset g; pragma unset eigenvalues; pragma unset eigenvectors; pragma unset ZGMMnames; pragma unset ZIVnames; pragma unset GMMinsts
	pragma unset ARz; pragma unset ARp

	if (favorspeed())
		printf(`"{txt}Favoring speed over space. To switch, type or click on {stata "mata: mata set matafavor space, perm"}.\n"')
	else
		printf(`"{txt}Favoring space over speed. To switch, type or click on {stata "mata: mata set matafavor speed, perm"}.\n"')
	
	if (st_nobs() <= 1) {
		printf("{err}No observations.\n")
		return(2000)
	}	

	LevelArg = st_local("level")

	stata("marksample touse")
	touseName = st_local("touse")
	stata("qui xtset") // prevents "not sorted" message
	if ((tName = st_global("_dta[tis]"))=="" | (idName = st_global("_dta[iis]"))=="") {
		printf("{err}You must {help xtset} the data to specify the panel and time variables.\n")
		return (459)
	}
	tdelta = st_numscalar("r(tdelta)")
	if ((tsfmt=st_global("r(tsfmt)")) == "%tc") tsfmt = "%9.0g"
	
	stata("markout "+ touseName + " " + idName)
	stata("bysort " + idName + ": egen " + (idSampleName=st_tempname()) + "=max(" + touseName + ")")

	st_view(touseVar, ., touseName, idSampleName)

	if (!any(touseVar)) {
		printf("{err}No observations.\n")
		return(2000)
	}

	st_view(tVar0, .,  tName, idSampleName)
	st_view(idVar, ., idName, idSampleName)
	if (missing(tVar0)) {
		printf("{err}Missing values in time variable (%s).\n", tName)
		return (459)
	}
	tVar = (tVar0 :- (tmin = min(tVar0))) / tdelta
	T = max(tVar) + 1

	VarlistNames = tokens(st_local("varlist"))

	if (weights = strlen(wtype = st_local("weight"))) {
		stata("quietly generate double " + (wtvarname = st_tempname()) + (wexp = st_local("exp")) + " if " + touseName)
		st_view(wtvar, ., wtvarname, idSampleName)
	}

	st_local("0", "," + st_local("options"))
	stata("syntax, [Robust Cluster(varlist) TWOstep noConstant noLeveleq ORthogonal ARtests(integer 2) SMall H(integer 3) DPDS2 Level(integer $S_level) ARLevels noDiffsargan SVMat SVVar pca COMPonents(integer 0) *]")

	arlevels = st_local("arlevels")!= ""
	small = st_local("small")!= ""
	steps = 1 + (st_local("twostep")=="twostep")
	if ((pca = st_local("pca")!= "") & favorspeed() == 0) {
		printf("{err}pca not available in space-favoring mode.\n")
		return(198)
	}
	if (pca)
		components = strtoreal(st_local("components"))
	if ((ClustVars = st_local("cluster")) != "" & favorspeed() == 0) {
		printf("{err}cluster() not available in space-favoring mode.\n")
		return(198)
	}
	if (((svmat = st_local("svmat") != "") | (svvar = st_local("svvar") != "")) & favorspeed() == 0)
		printf("{res}In space-favoring mode, svmat and svvar will not save Z matrix.\n")

	robust = ClustVars != "" | st_local("robust") != "" | (substr(wtype,1,1) == "p" & steps == 1)
	onestepnonrobust = steps == 1 & robust == 0
	diffsargan = st_local("diffsargan") == ""
	pfnXform = (orthogonal = st_local("orthogonal") != "") ? &_Orthog() : &_Difference()
	h = strtoreal(st_local("h"))
	artests = strtoreal(st_local("artests"))
	SystemGMM = st_local("leveleq") == ""

	if (SystemGMM == 0 & arlevels) {
		printf("{err}arlevels option invalid for difference GMM estimation.\n")
		return (198)
	}
	if (h != 1 & h != 2 & h != 3) {
		printf("{err}h(%f) invalid.\n", h)
		return (198)
	}

	// Compute row number for each observation once the data set is filled out to NT rows
	Fill = J(rows(tVar), 1, 1)
	for (r = 2; r <= rows(tVar); r++)
		Fill[r] = idVar[r]==idVar[r-1] ? Fill[r-1] : Fill[r-1] + T
	N = (NT = Fill[rows(Fill)] + T - 1) / T
	Fill = Fill + tVar
	SystemHeight = (SystemGMM + 1) * NT
	(Y0 = touse = J(NT, 1, .))[Fill] = st_data(., VarlistNames[1], idSampleName)
	touse[Fill] = touseVar
	if (weights) (wt0 = J(NT, 1, .))[Fill] = wtvar
	if (svmat) (ideqt = J(NT, 3, 0))[Fill,(1,3)] = idVar, tVar0

	if (cols(VarlistNames) > 1) {
		tmp = st_data(., Xnames = VarlistNames[|2 \ .|], idSampleName)
		(X0 = J(NT, cols(tmp), .))[Fill, .] = tmp
	} else {
		Xnames = J(1, 0, "")
		X0 = J(NT, 0, .)
	}

	if (consopt = (SystemGMM & st_local("constant") == "")) {
		Xnames = Xnames, "_cons"
		X0 = X0, (Xcons = J(NT, 1, 1))
	} else if (cols(Xnames) == 0) {
		printf("{err}No regressors.\n")
		return (481)
	}

	RowsPerGroup = (1 + SystemGMM) * T

	SubscriptsStart = SystemHeight-RowsPerGroup+1,. \ SystemHeight,.
	SubscriptsStep = J(2, 1, RowsPerGroup), J(2, 1, 0)

	if (SystemGMM) { // reorder rows by t, equation rather than equation, t
		SortByIDEq = 0 :: SystemHeight-1
		SortByIDEq = trunc(SortByIDEq :/ RowsPerGroup) :* T + (mod(SortByIDEq, RowsPerGroup) :>= T) :* NT + mod(SortByIDEq, T) :+ 1
		SortByEqID = invorder(SortByIDEq)
		ErrorEq = J(N,1,(h!=1\h==1)#J(T,1,1)) // dummy for equation whose errors to use for sig2 and serial correlation test--tranformed eq unless h=1
	}

	Complete = !(rowmissing(X0) :| rowmissing(Y0))

	if (j_IV = consopt) {
		IVinsts = &(IVinst())
		IVinsts->next = NULL  // add new IV inst group to linked list
		IVinsts->equation = IVinsts->mz = IVinsts->passthru = 0
		IVinsts->ivstyle = ""
		IVinsts->Base = Xcons
		IVinsts->BaseVarNames = "_cons"
	} else
		IVinsts = NULL

	rc = _ParseInsts(j_IV, j_GMM, NIVOptions, NGMMOptions, IVinsts, GMMinsts, SystemGMM, Complete, N, T, NT, idSampleName, Fill, orthogonal)
	if (rc) return (rc)

	pca = pca & j_GMM

	NDiffSargans = NIVOptions + NGMMOptions + SystemGMM

	_MakeIVinsts(InstOptInd, InstOptTxt, g, Z_IV, j_IV, SystemHeight, N, T, NT, NIVOptions, IVinsts, pfnXform, Complete, NDiffSargans, SystemGMM, ZIVnames)

	if (NGMMOptions & diffsargan) {
		p_System = J(1, 0, 0)
		i = 0; GMM = GMMinsts
		while (GMM != NULL) {
			p = 0..i , i+1+GMM->NumInsts..j_GMM+1
			InstOptInd[g, 2] = &(cols(p)>2 ? p[|2 \ cols(p) - 1|] : J(1, 0, .))
			InstOptTxt[g--] = GMM->gmmstyle

			if (SystemGMM & GMM->FullInstSetEq == 0) { // mark GMM instruments for difference equation, for inclusion in diff-Sargan test of levels instruments
				tmp = GMM->NumInsts - (GMM->MakeExtraInsts? (GMM->collapse? 1 : T - GMM->FullInstSetDiffed) * GMM->NumBaseVars : 0)
				if (tmp > 0) p_System = p_System , i+1 .. i+tmp
			}
				
			i = i + GMM->NumInsts
			GMM = GMM->next
		}
		if (SystemGMM) {
			InstOptInd[1, 2] = &p_System
			InstOptTxt[1] = "GMM instruments for levels"
		}
	}

	if (SystemGMM) {
		if (weights) wt = wt0 \ wt0
		touse = (orthogonal? _lag(touse, 1) : touse) \ touse
		X = (*pfnXform)(X0, N, T, NT, Complete, 1) \ X0
		Y = (*pfnXform)(Y0, N, T, NT, Complete, 1) \ Y0
		if (svmat) ideqt = ideqt \ (ideqt[|.,.\.,1|], J(NT, 1, 1), ideqt[|.,3\.,.|])
	} else {
		X = (*pfnXform)(X0, N, T, NT, Complete, 1)
		Y = (*pfnXform)(Y0, N, T, NT, Complete, 1)
		if (orthogonal) __lag(touse, 1)
		if (weights) wt = wt0
	}

	touse = touse :& !(rowmissing(Z_IV) :| rowmissing(X) :| rowmissing(Y))
	touseVar[,] = (SystemGMM? touse[|NT+1 \ .|] : touse)[Fill]

	if ((optionsArg=st_local("options")) != "") {
		printf("{err}%s invalid.", optionsArg)
		return (198)
	}

	if (ClustVars != "") {
		ClustVars = strCombs(tokens(ClustVars))[|2,.\.,.|]
		clusts = ClustInfo(rows(ClustVars), 1)
		MinNClust = .
		for (i=rows(ClustVars); i; i--) {
			stata("tempvar clust")
			stata("qui egen long " + st_local("clust") + " = group(" + invtokens(ClustVars[i,]) + ") if " + touseName + ", missing")
			st_view(p, ., st_local("clust"), idSampleName)
			(clusts[i].ID = J(NT, 1, .))[Fill] = p
			if (SystemGMM) clusts[i].ID = clusts[i].ID \ clusts[i].ID
			if ((clusts[i].N = colmax(p)) < MinNClust) MinNClust = clusts[i].N
			j = rowsum(ClustVars[i,]:!="")
			clusts[i].OneVar = j==1
			clusts[i].sign = 2*mod(j, 2) - 1
			clusts[i].pZe1i = J(clusts[i].N, 1, NULL)
		}
	}

	if (favorspeed())
		Z_GMM = _MakeGMMinsts(N, T, NT, SystemHeight, orthogonal, RowsPerGroup, j_GMM, touse, GMMinsts, ZGMMnames, tsfmt, tmin, tdelta)

	// Zero out excluded observations
	nottouse = J(Nnottouse = SystemHeight - sum(touse), 1, 0)
	r2 = Nnottouse
	for (r = SystemHeight; r; r--) if (touse[r] == 0) nottouse[r2--] = r
	Y = Y :* touse
	if (weights) wt = wt :/ touse
	if (svmat) ideqt = ideqt :/ touse
	for (i=rows(clusts); i; i--) clusts[i].ID = clusts[i].ID :* touse
	X[nottouse,] = J(Nnottouse, cols(X), 0)
	Z_IV[nottouse,] = J(Nnottouse, j_IV, 0)
	if (favorspeed())
		Z_GMM[nottouse,] = J(Nnottouse, j_GMM, 0)
	_editmissing(X, 0)
	_editmissing(Y, 0)
	_editmissing(Z_IV, 0)

	k = cols(keep = _rmcoll(X, consopt, 1, Xnames))
	if (k == 0) {
		printf("{err}No regressors.\n")
		return (481)
	}

  if (k < cols(X)) {
		Xnames = Xnames[keep]
		X = X[, keep]
	}
	
  NObsEff = NObs = sum(tmp = colshape(touse[|SystemHeight-NT+1 \ .|], T))
	NGroups = sum(rowmax(tmp))

	if (weights) {
		wttot = sum(_wt = wt[|SystemHeight-NT+1 \ .|]) // holds weight sum first for "main" eq, then for eq used to compute sig2
		printf("(sum of weights is %f)\n", wttot)
		if (substr(wtype,1,1) == "f") {
			if (sum(_Difference(_wt, N, T, NT, Complete, 0, 0))) {
				printf("{err}Frequency weights must be constant over time for {cmd:xtabond2}.\n")
				return (101)
			}
			NObs = wttot
			if (onestepnonrobust)
				NObsEff = wttot   // Effective sample size with fweights = sum of weights only if no clustering
			if (SystemGMM & h>1) wttot = sum(wt[|.\NT|])
			else {
				wt = wt * (NObsEff / wttot)
				wttot = SystemGMM & h>1? sum(touse[|.\NT|]) : NObsEff // sum of weights in Xformed eq
			}
		} else {
			wt = wt * (NObs / wttot)
			wttot = SystemGMM & h>1? sum(touse[|.\NT|]) : NObs // sum of weights in Xformed eq
		}
		X = X :* wt
		Y = Y :* wt
	} else
		wttot = SystemGMM & h>1? sum(touse[|.\NT|]) : NObs

	if (pca) {
		tmp = colsum(Z_GMM:!=0):!=0
		Z_GMM = select(Z_GMM, tmp)
		eigenvectorBasisNames = select(ZGMMnames, tmp')
		j_GMM = cols(Z_GMM)
		S = quadcorrelation(Z_GMM, weights? wt : touse)
		KMO = 1 /(1 + quadsum(lowertriangle(corr(invsym(S)),0):^2) / quadsum(lowertriangle(S,0):^2))

		_symeigensystem(S, eigenvectors, eigenvalues)
		_edittozerotol(eigenvalues, 1e-12)
		j_GMM = components? min((components, j_GMM)) : max((sum(eigenvalues:>.999999), k-j_IV))
		Z_GMM = Z_GMM * eigenvectors[|.,. \ ., j_GMM|]
		ZGMMnames = J(j_GMM, 1, ""), strofreal(eigenvalues'[|.\j_GMM|], "%32.12f")
	}
	
	if ((j = j_GMM + j_IV) < k) {
		printf("{err}Equation not identified. Regessors outnumber instruments.\n")
		return (481)
	}

	if (NObs == 0) {
		printf("{err}No observations.\n")
		return(2000)
	}
	TiMinMax = minmax(rowsum(tmp))

	if (SystemGMM) { // reorder rows by t, equation rather than equation, t
		X = X[SortByIDEq,]
		Y = Y[SortByIDEq]
		Z_IV = Z_IV[SortByIDEq,]
		touse = touse[SortByIDEq]
		if (weights) wt = wt[SortByIDEq]
		if (svmat) ideqt = ideqt[SortByIDEq,]
		for (i=rows(clusts); i; i--) clusts[i].ID = clusts[i].ID[SortByIDEq]
		if (favorspeed()) Z_GMM = Z_GMM[SortByIDEq,]
	}

	Zi = J(RowsPerGroup, j_GMM, 0)
	H = _H(h, orthogonal, orthogonal, SystemGMM, T)

	if (favorspeed()) {
		ZY = quadcross(Z_IV, Y) \ quadcross(Z_GMM, Y)
		ZX = quadcross(Z_IV, X) \ quadcross(Z_GMM, X)
  } else {
		ZX = J(j_GMM, cols(X), 0); ZY = J(j_GMM, 1, 0)
		if (j_GMM) {
			Subscripts = SubscriptsStart
			for (i = N; i; i--) {
				Zi[,] = _MakeGMMinsts(N, T, NT, SystemHeight, orthogonal, RowsPerGroup, j_GMM, touse, GMMinsts, ZGMMnames, tsfmt, tmin, tdelta, i)
				ZY = ZY + quadcross(Zi, Y[|Subscripts|])
				ZX = ZX + quadcross(Zi, X[|Subscripts|])
				Subscripts = Subscripts - SubscriptsStep
			}
		}
		ZY = quadcross(Z_IV, Y) \ ZY
		ZX = quadcross(Z_IV, X) \ ZX
	}

	S = J(j, j, 0); Zi = J(RowsPerGroup, j, 0); Subscripts = SubscriptsStart
	for (i = N; i; i--) {
		_wt = weights? sqrt(wt[|Subscripts|]) : 1
		if (j_IV) Zi[|.,. \ .,j_IV|] = Z_IV[|Subscripts|]
		if (j_GMM) Zi[|.,j_IV+1 \ .,.|] = favorspeed()? Z_GMM[|Subscripts|] :
		   _MakeGMMinsts(N, T, NT, SystemHeight, orthogonal, RowsPerGroup, j_GMM, touse, GMMinsts, ZGMMnames, tsfmt, tmin, tdelta, i) :* touse[|Subscripts|]
		S = S + quadcross(Zi, _wt, quadcross(H, _wt, Zi))
		Subscripts = Subscripts - SubscriptsStep
	}

	A1 = invsym(S)
	V1 = invsym((XZA=quadcross(ZX, A1)) * ZX)
	e1 = Y - X * (b1 = V1 * XZA * ZY)
	pwe = &(weights? e1:/sqrt(wt) : e1)
	if (SystemGMM) pwe = &(*pwe :* ErrorEq)
	sig2 = quadcross(*pwe,*pwe) / (2 - (orthogonal | h==1)) / wttot
	A1 = A1 / sig2
	V1 = V1 * sig2
	j0 = j - diag0cnt(A1) // Adjust roughly for collinear instruments, based on number of collinear moments
	if (j0 > NGroups)
		printf("{res}Warning: Number of instruments may be large relative to number of observations.\n")

	A1Ze = A1 * (Ze = _Ze(e1, ., ., N, T, NT, SystemHeight, orthogonal, RowsPerGroup, j_GMM, touse, GMMinsts, 
					SubscriptsStart, SubscriptsStep, Z_IV, Z_GMM, tsfmt, tmin, tdelta))
	sarganp = chi2tail(sarganDF = j0 - k, sargan = quadcross(Ze, A1Ze))

	if (onestepnonrobust) {
		// correct H by sig2 too and prepare to do Hansen as well as Sargan
		H = H * sig2
		S = S * sig2
	} else {	
		if (rows(clusts)) {
			if (SystemGMM | clusts[rows(clusts)].N!=NObs) S = J(j, j, 0)
			for (c=rows(clusts); c; c--) {
				if (clusts[c].N==NObs & !SystemGMM) { // efficient code for clustering by obs/het-robust case
					Z = Z_IV, Z_GMM
					S = (small? clusts[c].sign*clusts[c].N/(clusts[c].N-1) : clusts[c].sign) * quadcross(Z, e1:*e1, Z)
				} else {
					tmp = J(j, j, 0)
					for (i=clusts[c].N; i; i--) {
						p = clusts[c].ID:==i
						e2 = select(e1, p)
						clusts[c].pZe1i[i] = &( (j_IV? quadcross(e2, select(Z_IV, p)) : J(1, 0, 0)) , (j_GMM? quadcross(e2, select(Z_GMM, p)) : J(1, 0, 0)) )
						tmp = tmp + quadcross(*clusts[c].pZe1i[i], *clusts[c].pZe1i[i])
					}
					S = S + (small? clusts[c].sign*clusts[c].N/(clusts[c].N-1) : clusts[c].sign) * tmp
				}
			}
		} else {
			S = J(j, j, 0)
			pZe1i = J(N, 1, NULL); Subscripts = SubscriptsStart
			for (i = N; i; i--) {
				e2 = e1[|Subscripts|]
				pZe1i[i] = &( (j_IV? quadcross(e2, Z_IV[|Subscripts|]) : J(1, 0, 0)) , (j_GMM? quadcross(e2, 
							favorspeed()? Z_GMM[|Subscripts|] : _MakeGMMinsts(N, T, NT, SystemHeight, orthogonal, RowsPerGroup, j_GMM, touse, GMMinsts, ZGMMnames, tsfmt, tmin, tdelta, i)) : J(1, 0, 0)) )
				S = S + quadcross(*pZe1i[i], *pZe1i[i])
				Subscripts = Subscripts - SubscriptsStep
			}
		}		
		if (robust) { 
			VXZA = V1 * quadcross(ZX, A1)
			V1robust = VXZA * S * VXZA'
		}
 		A2 = invsym(S)

		if (diag0cnt(A2)) {
			printf("{res}Warning: Two-step estimated covariance matrix of moments is singular.\n")
			printf("{res}  Using a generalized inverse to calculate %s.\n", steps==2? "optimal weighting matrix for two-step estimation" : 
				"robust weighting matrix for Hansen test")
			if (diffsargan) printf("{res}  Difference-in-Sargan/Hansen statistics may be negative.\n")
		}

		// even in one-step robust, get Hansen
		V2 = invsym((XZA = quadcross(ZX, A2)) * ZX) 
		e2 = Y - X * (b2 = (VXZA = V2 * XZA) * ZY)
		if (steps == 2) {
			pwe = &(weights? e2:/sqrt(wt) : e2)
			if (SystemGMM) pwe = &(*pwe :* ErrorEq)
			sig2 = quadcross(*pwe,*pwe) / (2 - (orthogonal | h==1)) / wttot
		}
		A2Ze = A2 * (Ze = _Ze(e2, . , ., N, T, NT, SystemHeight, orthogonal, RowsPerGroup, j_GMM, touse, GMMinsts, 
						SubscriptsStart, SubscriptsStep, Z_IV, Z_GMM, tsfmt, tmin, tdelta))

		if (steps==2 & robust) {
		// Windmeijer-corrected variance matrix for two-step
		//   Need to compute matrix whose jth column is 
		//	[sum_i Z_i'(xj_i*e1_i'+e1_i*xj_i')Z_i]*A2*Z'e2 (where xj = jth col of X)
		//   = sum_i (Z_i'xj_i*e1_i'Z_i*A2*Z'e2 + Z_i'e1_i*xj_i'Z_i*A2*Z'e2).
		//   Since e1_i'Z_i*A2*Z'e2 and xj_i'Z_i*A2*Z'e2 are scalars, they can be transposed and swapped with 
		//   adjacent terms. So this is:
		//   matrix whose jth col is sum_i (e1_i'Z_i*A2*Z'e2 + Z_i'e1_i*e2'Z*A2)Z_i'xj_i
		//   = sum_i (e1_i'Z_i*A2*Z'e2 + Z_i'e1_i*e2'Z*A2)Z_i'X_i
		//   (transformation reverse engineered from DPD.)
			if (rows(clusts)) {
				if (SystemGMM | clusts[rows(clusts)].N!=NObs) D = J(j, cols(X), 0)
				for (c=rows(clusts); c; c--)
					if (clusts[c].N==NObs & !SystemGMM) // efficient code for clustering by obs/het-robust case
						D = (small? clusts[c].sign*clusts[c].N/(clusts[c].N-1) : clusts[c].sign) * 2*quadcross(Z, e1 :* Z*A2Ze, X)
					else {
						tmp = J(j, cols(X), 0)
						for (i=clusts[c].N; i; i--) {
							p = clusts[c].ID:==i
							Xi = select(X, p)
							ZXi = (j_IV? quadcross(select(Z_IV, p), Xi) : J(0, cols(X), 0)) \ (j_GMM? quadcross(select(Z_GMM, p), Xi) : J(0, cols(X), 0))
							tmp = tmp + (*clusts[c].pZe1i[i] * A2Ze) * ZXi + quadcross(A2Ze * *clusts[c].pZe1i[i], ZXi)
						}
						D = D + (small? clusts[c].sign*clusts[c].N/(clusts[c].N-1) : clusts[c].sign) * tmp
					}
			} else {
				D = J(j, cols(X), 0)
				Subscripts = SubscriptsStart
				for (i = N; i; i--) {
					Xi = X[|Subscripts|]
					ZXi = (j_IV? quadcross(Z_IV[|Subscripts|], Xi) : J(0, cols(X), 0)) \
					   (j_GMM? quadcross(favorspeed()? Z_GMM[|Subscripts|] :
								_MakeGMMinsts(N, T, NT, SystemHeight, orthogonal, RowsPerGroup, j_GMM, touse, GMMinsts, ZGMMnames, tsfmt, tmin, tdelta, i), Xi) : J(0, cols(X), 0))
					D = D + (*pZe1i[i] * A2Ze) * ZXi + quadcross(A2Ze * *pZe1i[i], ZXi)
					Subscripts = Subscripts - SubscriptsStep
				}
			}
			D = VXZA * D
			V2robust = V2 + D * V1robust * D' + (D + D) * V2
		}
		hansenp = chi2tail(sarganDF, hansen = quadcross(Ze, A2Ze))
	}

	if (steps == 1) {
		b = b1
		pV = robust? &V1robust : &V1
	} else {
		b = b2
		pV = robust? &V2robust : &V2
	}
	V = (*pV + *pV')/2

	if (steps == 1) {
		pV = &V1
		pVrobust = &V1robust
		pA = &A1
		pe = &e1
	} else {
		pV = &V2
		pVrobust = &V2robust
		pA = &A2
		pe = &e2
	}

	m2VZXA = (-2 * *pV) * quadcross(ZX, *pA)
	if (robust)
		pV = pVrobust

	if (onestepnonrobust == 0) { // preserve estimation residuals for AR tests
		pei = J(N, 1, NULL)
		Subscripts = SubscriptsStart
		for (i = N; i; i--) {
			pei[i] = &((*pe)[|Subscripts|])
			Subscripts = Subscripts - SubscriptsStep
		}
	}

	if (small) {
		tmp = wttot/(wttot - k)
		V = V * (onestepnonrobust? tmp : (rows(clusts)? (NObs-1)/(NObs-k) : (NObs-1)/(NObs-k)*NGroups/(NGroups-1)) )
		sig2 = sig2 * tmp
	}

	pX = SystemGMM? &(X[tmp = SortByEqID[|NT+1 \ .|], .]) : &X  // for system GMM, drop difference equation from model fit test
	DFm = rank(*pX) - consopt
	if (!consopt) {  // In case constant is in column space of X, even despite noconstant, bump it out for F/chi2 test
		ptouse = SystemGMM? &(touse[tmp]) : &touse
		Xiota = cross(*pX, *ptouse)
		DFm = DFm - mreldif(Xiota ' invsym(cross(X,X)) * Xiota, colsum(*ptouse)) < epsilon(1)*rows(*pX)
	}
	if (DFm)
		if (small)
			Fp = Ftail(DFm, DFr = (onestepnonrobust? NObsEff - DFm : (rows(clusts)? MinNClust : NGroups)) - consopt,
															 F = quadcross(b, invsym(V)) * b / DFm)
		else
			chi2p = chi2tail(DFm, chi2 = quadcross(b, invsym(V)) * b)
	else if (small) 
			DFr = (onestepnonrobust? NObsEff : (rows(clusts)? MinNClust : NGroups)) - consopt

	if (diffsargan & !pca) {
		diffsargans = J(5, NDiffSargans, .)
		A1diag = diagonal(A1)
		p_AllIV  = j_IV ? 1..j_IV  : J(1, 0, 0)
		p_AllGMM = j_GMM? 1..j_GMM : J(1, 0, 0)
		for (g = NDiffSargans; g; g--) {
			p_IV = *InstOptInd[g, 1]
			p_GMM = *InstOptInd[g, 2]
			p = (p_IV  == . ? p_AllIV  : p_IV ) , 
			    (p_GMM == . ? p_AllGMM : p_GMM) :+ j_IV
			NOtherInsts = sum(A1diag[p] :!= 0)
			if (NOtherInsts >= k & NOtherInsts < j0) { // invalid if # remaining insts < # of regressors
				XZA = quadcross(ZXp = ZX[p,], App = invsym(S[p,p]))
				_V = invsym(XZA * ZXp)
				if (diag0cnt(_V)==diag0cnt(*pV)) { // as long as the restriction doesn't render any parameters unidentified
					ZeDiffSargan = _Ze(Y - X * (_V * (XZA * ZY[p])), p_IV, p_GMM, N, T, NT, SystemHeight, orthogonal, RowsPerGroup, 
							j_GMM, touse, GMMinsts, SubscriptsStart, SubscriptsStep, Z_IV, Z_GMM, tsfmt, tmin, tdelta)
					diffsargans[2, g] = (hansen==.? sargan : hansen) - (diffsargans[1, g] = quadcross(ZeDiffSargan, App * ZeDiffSargan)) // unrestricted Sargan, and difference
					diffsargans[3, g] = j0 - NOtherInsts - diag0cnt(V2)                           // # insts in group
					diffsargans[4, g] = chi2tail(sarganDF - diffsargans[3, g], diffsargans[1, g]) // p value
					diffsargans[5, g] = chi2tail(diffsargans[3, g], diffsargans[2, g])            // p value
				}
			}
		}
		NDiffSargans = rows(InstOptTxt = select(InstOptTxt, diffsargans[1,]' :!= .))
		diffsargans = select(diffsargans, diffsargans[1,] :!= .)
	}

	_ARTests(arlevels, artests, onestepnonrobust, h, N, T, NT, SystemHeight, RowsPerGroup, sig2, orthogonal, SystemGMM, j, j_IV, j_GMM, touse, SortByEqID, Complete,
	           X, X0, Y0, Z_IV, Z_GMM, b, weights, wt, wt0, pe, pei, ARz, ARp, SubscriptsStep, SubscriptsStart, GMMinsts, ZGMMnames, tsfmt, tmin, tdelta, m2VZXA, keep, pV)

	st_local("b", bname=st_tempname())
	st_matrix(bname, b')
	Stripe = J(cols(Xnames), 1, ""), Xnames'
	st_matrixcolstripe(bname, Stripe)
	st_local("V", Vname=st_tempname())
	st_matrix(Vname, V)
	st_matrixcolstripe(Vname, Stripe)
	st_matrixrowstripe(Vname, Stripe)
	stata("est post " + bname + " " + (hasmissing(V)? "" : Vname) + "," + (small? "dof(" + strofreal(DFr)+")" : "") + " obs(" + strofreal(NObs) + 
				") esample(" + touseName +") depname(" + VarlistNames[1] + ")")

	st_numscalar("e(sargan)", sargan)
	st_numscalar("e(sar_df)", sarganDF)
	st_numscalar("e(sarganp)", sarganp)
	st_matrix("e(Ze)", Ze)
	if (hansen != .) {
		st_numscalar("e(hansen)", hansen)
		st_numscalar("e(hansen_df)", sarganDF)
		st_numscalar("e(hansenp)", hansenp)
	}

	if (cols(diffsargans)) {
		st_matrix("e(diffsargan)", diffsargans)
		st_matrixcolstripe("e(diffsargan)", (J(NDiffSargans, 1, ""), substr(subinstr(InstOptTxt, ".", ""), 1, 32)))
		st_matrixrowstripe("e(diffsargan)", (J(5, 1, ""), 
		  ("Unrestricted Sargan/Hansen"\"Difference in Sargan"\"Instruments generated"\"Unrestricted Sargan p"\"Difference in Sargan p")))
	}

	bname = ""
	for (i=1; i<=rows(InstOptTxt); i++) st_global("e(diffgroup"+strofreal(i)+")", InstOptTxt[i])

	st_matrix("e(A1)", A1)
	if (A2 != .) st_matrix("e(A2)", A2)
	if (pca) {
		st_global("e(pca)", "pca")
		st_numscalar("e(components)", j_GMM)
		st_matrix("e(eigenvalues)", eigenvalues)
		st_numscalar("e(pcaR2)", quadsum(eigenvalues[|.,.\.,j_GMM|])/cols(eigenvalues))
		st_numscalar("e(kmo)", KMO)
	}
	st_global("e(depvar)", VarlistNames[1])
	st_numscalar("e(N)", NObs)
	st_numscalar("e(sig2)", sig2)
	st_numscalar("e(sigma)", sqrt(sig2))
	st_numscalar("e(artests)", artests)
	st_global("e(transform)", orthogonal? "orthogonal deviations" : "first differences")
	st_numscalar("e(g_min)", TiMinMax[1])
	st_numscalar("e(g_max)", TiMinMax[2])
	st_numscalar("e(N_g)", NGroups)
	st_numscalar("e(df_m)", DFm)
	st_numscalar("e(h)", h)
	if (rows(clusts)) {
		st_global("e(clustvar)", st_local("cluster"))
		for (c=i=1; i<=rows(clusts); i++)
			if (clusts[i].OneVar)
				st_numscalar("e(Nclust"+strofreal(c++)+")", clusts[i].N)
	}
	if (strlen(wexp)) {
		st_global("e(wtype)", wtype)
		st_global("e(wexp)", wexp)
	}
	if (small) {
		st_numscalar("e(F)", F)
		st_numscalar("e(F_p)", Fp)
		st_numscalar("e(df_r)", DFr)
		st_global("e(small)", "small")
	} else {
		st_numscalar("e(chi2)", chi2)
		st_numscalar("e(chi2p)", chi2p)
	}

	st_numscalar("e(g_avg)", NObs / NGroups)

	for (i=1; i<=artests; i++) {
		st_numscalar("e(ar" + strofreal(i) + ")", ARz[i])
		st_numscalar("e(ar" + strofreal(i) + "p)", ARp[i])
	}

	if (steps==2)
		st_global("e(twostep)", "twostep")
	if (robust) {
		st_global("e(robust)", "robust")
		st_global("e(vcetype)", steps==1? "Robust" : "Corrected")
	}

	i = 1; IV = IVinsts; equation = passthru = mz = J(1, 0, 0)
	while (IV != NULL) {
		st_global( "e(ivinsts"+strofreal(i++)+")", IV->BaseVarNames)
		equation = equation, IV->equation
		passthru = passthru, IV->passthru
		mz       = mz      , IV->mz
		IV = IV->next
	}
	st_matrix("e(ivequation)", equation)
	st_matrix("e(ivpassthru)", passthru)
	st_matrix("e(ivmz)",       mz)

	if (favorspeed() & (svmat | svvar)) Z_GMM = Z_IV, Z_GMM

	if (svmat) {
		Stripe = substr(vec(strofreal(idVar[panelsetup(idVar,1)[,1]#J(SystemGMM+1,1,1)]') :+ J(1, SystemGMM+1, J(1, N, ", ":+strofreal((0::T-1)*tdelta:+tmin, tsfmt)))), 1, 32)
		Stripe = J(rows(Stripe), 1, ""), Stripe

		st_matrix("e(X)", X)
		st_matrixcolstripe("e(X)", substr((J(cols(X), 1, ""), Xnames'), 1, 32))
		st_matrixrowstripe("e(X)", Stripe)
		st_matrix("e(Y)", Y)
		st_matrixcolstripe("e(Y)", ("", substr(VarlistNames[1], 1, 32)))
		st_matrixrowstripe("e(Y)", Stripe)
		st_matrix("e(H)", H)
		st_matrix("e(ideqt)", ideqt)
		st_matrixcolstripe("e(ideqt)", ("","id"\"","eq"\"","t"))
		if (weights) {
			st_matrix("e(wt)", wt)
			st_matrixrowstripe("e(wt)", Stripe)
		}
		for (c=i=1; i<=rows(clusts); i++)
			if (clusts[i].OneVar) {
				st_matrix("e(clustid"+strofreal(c)+")", clusts[i].ID)
				st_matrixrowstripe("e(clustid"+strofreal(c)+")", Stripe)
				c++
			}
		if (favorspeed()) {
			st_matrix("e(Z)", Z_GMM)
			st_matrixcolstripe("e(Z)", substr((ZIVnames \ ZGMMnames), 1, 32))
			st_matrixrowstripe("e(Z)", Stripe)
			if (cols(eigenvectors)) {
				st_matrix("e(eigenvectors)", eigenvectors)
				st_matrixcolstripe("e(eigenvectors)", (J(cols(eigenvalues), 1, ""), strofreal(eigenvalues',"%32.12f")))
				st_matrixrowstripe("e(eigenvectors)", substr(eigenvectorBasisNames, 1, 32))
			}
		}
	}

	if (svvar) {
		stata("gsort -" + idSampleName + " +" + idName + " +" + tName)

		Vname = orthogonal? "orthog" : "diff"

		p = SystemGMM? (J(N,1,1::T) + 2*T*(0::N-1)#J(T,1,1))[Fill] : Fill

		stata("capture matrix rename sample" + Vname + " " + (bname=st_tempname()))
		st_matrix("sample"+Vname, touse[p])
		stata("capture noisily svmat double sample"+Vname)
		stata("capture matrix drop sample"+Vname)
		stata("capture matrix rename " + bname + " sample"+Vname)

		stata("capture matrix rename y" + Vname + " " + (bname=st_tempname()))
		st_matrix("y"+Vname, Y[p])
		stata("capture noisily svmat double y"+Vname)
		stata("capture matrix drop y"+Vname)
		stata("capture matrix rename " + bname + " y"+Vname)

		stata("capture matrix rename x" + Vname + " " + (bname=st_tempname()))
		st_matrix("x"+Vname, X[p,])
		stata("capture noisily svmat double x"+Vname)
		stata("capture matrix drop x"+Vname)
		stata("capture matrix rename " + bname + " x"+Vname)

		if (favorspeed()) {
			stata("capture matrix rename z" + Vname + " " + (bname=st_tempname()))
			Z_IV = Z_GMM[p,]
			Z_IV = select(Z_IV, colsum(Z_IV:!=0))
			if (cols(Z_IV)) {
				st_matrix("z"+Vname, select(Z_IV, colsum(Z_IV:!=0)))
				stata("capture noisily svmat double z"+Vname)
				stata("capture matrix drop z"+Vname)
				stata("capture matrix rename " + bname + " z"+Vname)
			}
		}

		if (SystemGMM) {
			p = p :+ T

			stata("capture matrix rename ylev " + (bname=st_tempname()))
			st_matrix("samplelev", touse[p])
			stata("capture noisily svmat double samplelev")
			stata("capture matrix drop samplelev")
			stata("capture matrix rename " + bname + " samplelev")

			stata("capture matrix rename ylev " + (bname=st_tempname()))
			st_matrix("ylev", Y[p])
			stata("capture noisily svmat double ylev")
			stata("capture matrix drop ylev")
			stata("capture matrix rename " + bname + " ylev")

			stata("capture matrix rename xlev " + (bname=st_tempname()))
			st_matrix("xlev", X[p,])
			stata("capture noisily svmat double xlev")
			stata("capture matrix drop xlev")
			stata("capture matrix rename " + bname + " xlev")

			if (favorspeed()) {
				stata("capture matrix rename zlev " + (bname=st_tempname()))
				Z_IV = Z_GMM[p,]
				Z_IV = select(Z_IV, colsum(Z_IV:!=0))
				if (cols(Z_IV)) {
					st_matrix("zlev", select(Z_IV, colsum(Z_IV:!=0)))
					stata("capture noisily svmat double zlev")
					stata("capture matrix drop zlev")
					stata("capture matrix rename " + bname + " zlev")
				}
			}
		}
	}

	i = 1; GMM = GMMinsts; equation = passthru = collapse = orthogonal = J(1, 0, 0); laglimits = J(2, 0, 0)
	while (GMM != NULL) {
		st_global("e(gmminsts"+strofreal(i++)+")", GMM->BaseVarNames)
		equation   = equation,   GMM->equation
		passthru   = passthru,   GMM->passthru
		collapse   = collapse,   GMM->collapse
		laglimits  = laglimits,  GMM->Laglim'
		orthogonal = orthogonal, GMM->InstOrthogonal
		GMM = GMM->next
	}
	st_matrix("e(gmmequation)",   equation)
	st_matrix("e(gmmpassthru)",   passthru)
	st_matrix("e(gmmcollapse)",   collapse)
	st_matrix("e(gmmlaglimits)",  laglimits)
	st_matrix("e(gmmorthogonal)", orthogonal)

	st_global("e(ivar)", idName)
	st_global("e(tvar)", tName)
	st_numscalar("e(j)", j0)
	st_numscalar("e(j0)", j)
	st_global("e(esttype)", SystemGMM? "system" : "difference")
	st_global("e(artype)", arlevels? "levels" : "first differences")
	st_local("level", LevelArg)
	st_global("e(marginsok)", "XB default")
	st_global("e(predict)", "xtab2_p")
	st_global("e(cmd)", "xtabond2")

	return(0) 
}

real scalar _ParseInsts(real scalar j_IV, real scalar j_GMM, real scalar NIVOptions, real scalar NGMMOptions, pointer(struct IVinst scalar) IV, 
	pointer(struct GMMinst scalar) GMM, real scalar SystemGMM, 
	real colvector Complete, real scalar N, real scalar T, real scalar NT, string scalar idSampleName, real colvector Fill, real scalar orthogonal) {

	string scalar ivstyle, gmmstyle, optionsArg, LaglimArg, EquationArg
	string rowvector LaglimStr
	string colvector BaseNames
	pointer (string colvector) pBaseNames
	real scalar split, steps, EquationTokenCount
	real matrix Base, tmp
	pointer(real matrix) scalar pBase
	pointer next
	struct GMMinst scalar sGMM
	
	st_local("0", "," + st_local("options"))
	stata("syntax [, IVstyle(string) *]")
	NIVOptions = j_IV
	while ((ivstyle = st_local("ivstyle")) != "") {
		NIVOptions++
		// Insert vector of paramaters and data describing IV inst set at head of linked list of such vectors
		next = IV; (*(IV = &(IVinst()))).next = next  // add new IVinst group to linked list
		optionsArg = st_local("options")
		st_local("0", ivstyle)
		stata("capture syntax varlist(numeric ts fv), [Equation(string) Passthru MZ]")
		stata("loc _rc = _rc")
		if (st_local("_rc") != "0") {
			printf("{err}ivstyle(%s) invalid.\n", ivstyle)
			return (198)
		}
    stata("fvexpand " + st_local("varlist"))
    IV->BaseVarNames = st_global("r(varlist)")

		st_local ("0", "," + (EquationArg = st_local("equation")))
		EquationTokenCount = cols(tokens(EquationArg))
		stata("capture syntax, [Diff Level Both]")
		stata("loc _rc = _rc")
		if (EquationTokenCount > 1 | st_local("_rc") != "0") {
			printf("{err}equation(%s) invalid.\n", EquationArg)
			return (198)
		}
		// 0=eq(level), 1=eq(diff), 2=eq(both) (default)
		IV->equation = !EquationTokenCount | st_local("both")!="" ? 2 : st_local("level")==""

		if (!(SystemGMM | IV->equation)) {
			printf ("{txt}Instruments for levels equations only ignored since noleveleq specified.\n")
			IV = next
		} else {
			IV->passthru = st_local("passthru") != ""
			IV->mz = st_local("mz") != ""
	
			if (IV->passthru & IV->equation==2 & SystemGMM) {
				printf ("{err}passthru not valid with equation(both) in system GMM.\n")
				return (198)
			}

			IV->ivstyle = "iv(" + IV->BaseVarNames
			if (IV->mz | IV->passthru | IV->equation != 2) {
				                      IV->ivstyle = IV->ivstyle + ","
				if (IV->passthru)     IV->ivstyle = IV->ivstyle + " passthru"
				if (IV->mz)           IV->ivstyle = IV->ivstyle + " mz"
				if (IV->equation !=2) IV->ivstyle = IV->ivstyle + " eq(" + (IV->equation? "diff" : "level") + ")"
			}
			                          IV->ivstyle = IV->ivstyle + ")"
			tmp = st_data(., tokens(IV->BaseVarNames), idSampleName)
			(IV->Base = J(NT, cols(tmp), .))[Fill, .] = tmp
			if (IV->mz == 0)
        Complete = Complete :& !rowmissing(IV->Base)
			j_IV = j_IV + cols(tmp)
		}
		st_local("0", "," + optionsArg)
		stata("syntax [, IVstyle(string) *]")
	}

	st_local("0", "," + st_local("options"))
	stata("syntax [, GMMstyle(string) *]")
	GMM = NULL; j_GMM = 0
	NGMMOptions = 0
	while ((gmmstyle = st_local("gmmstyle")) != "") {
		next = GMM; (*(GMM = &(GMMinst()))).next = next  // add new GMMinst group to linked list
		optionsArg = st_local("options")
		st_local ("0", gmmstyle)
		stata("capture syntax anything, [SPlit *]") // strip out this suboption first so it won't appear in diff-sargan reports
		stata("local _rc = _rc")
		if (st_local("_rc") != "0") {
			printf("{err}gmmstyle(%s) invalid.\n", gmmstyle)
			return (198)
		}
		split = strlen(st_local("split")) > 0

		if (strlen(gmmstyle = st_local("options")))
			gmmstyle = st_local("anything") + ", " + gmmstyle
		else
			gmmstyle = st_local("anything")

		st_local ("0", gmmstyle)
		stata("capture syntax varlist(numeric ts fv), [Equation(string) Laglimits(string) Collapse Passthru Orthogonal]")
		stata("loc _rc = _rc")
		if (st_local("_rc") != "0") {
			printf("{err}gmmstyle(%s) invalid.\n", gmmstyle)
			return (198)
		}
		GMM->passthru       = st_local("passthru") != ""
		GMM->collapse       = st_local("collapse") != ""
		GMM->InstOrthogonal = st_local("orthogonal") != ""

    stata("fvexpand " + st_local("varlist"))
    GMM->BaseVarNames = st_global("r(varlist)")

		st_local ("0", "," + (EquationArg = st_local("equation")))
		EquationTokenCount = cols(tokens(EquationArg))
		stata("capture syntax, [Diff Level Both]")
		stata("loc _rc = _rc")
		if (EquationTokenCount > 1 | st_local("_rc") != "0") {
			printf("{err}equation(%s) invalid.\n", EquationArg)
			return (198)
		}
		// 0=eq(level), 1=eq(diff), 2=eq(both) (default)
		GMM->equation = !EquationTokenCount | st_local("both")!="" ? 2 : st_local("level")==""
		if (GMM->InstOrthogonal & !orthogonal & GMM->equation) {
			printf("{res}Warning: backward-orthogonal-deviations are usually not valid unless forward-orthgonal-deviations regressors are specified.\n")
			printf("{res}         I.e., {inp}orthogonal{res} option should accompany the {inp}orthogonal{res} suboption of {inp}gmmstyle(){res} option.\n")
		}

		if (split & GMM->equation != 2) {
			printf("{res}Warning: split has no effect in combination with equation(%s).\n", EquationArg)
			split = 0
		}
		if (split & !SystemGMM) {
			printf("res}Warning: split has no effect in Difference GMM.\n")
			split = 0
		}

		if (!(SystemGMM | GMM->equation)) {
			printf ("{txt}Instruments for levels equations only ignored since noleveleq specified.\n")
			GMM = next
		} else {
			if (SystemGMM & GMM->passthru & GMM->equation==2) {
				printf("{err}passthru not valid with equation(both) in system GMM.\n")
				return (198)
			}

			if (cols(LaglimStr = tokens(LaglimArg = st_local("laglimits")))) {
				if (cols(LaglimStr) != 2) {
					printf("{err}Laglimits(%s) must have two arguments.\n", LaglimArg)
					return (198)
				}
				if (missing(GMM->Laglim = strtoreal(LaglimStr)) > sum(LaglimStr :== ".")) {
					printf("{err}Laglimits(%s) invalid.\n", LaglimArg)
					return (198)
				}
				if (GMM->Laglim[1] == .)
					GMM->Laglim[1] = 1
				if (GMM->Laglim[1] > GMM->Laglim[2])
					GMM->Laglim = GMM->Laglim[(2,1)]
			} else
				GMM->Laglim = 1, .

			GMM->gmmstyle = "gmm(" + GMM->BaseVarNames + ","

			if (GMM->collapse)       GMM->gmmstyle = GMM->gmmstyle + " collapse"
			if (GMM->passthru)       GMM->gmmstyle = GMM->gmmstyle + " passthru"
			if (GMM->InstOrthogonal) GMM->gmmstyle = GMM->gmmstyle + " orthogonal"
			if (split)
				GMM->equation = 1
			else {
				if (GMM->equation != 2) GMM->gmmstyle = GMM->gmmstyle + " eq(" + (GMM->equation? "diff" : "level") + ")"
				GMM->gmmstyle = GMM->gmmstyle + " lag(" + strofreal(GMM->Laglim[1]) + " " + strofreal(GMM->Laglim[2]) + ")" 
			}

			// Get base vars filled out to NT rows
			tmp = st_data(. , tokens(GMM->BaseVarNames), idSampleName)
			(Base = J(NT, cols(tmp), .))[Fill, .] = tmp
			pBase = &(GMM->InstOrthogonal? _Orthog(Base, N, T, NT, Complete, 0, 0) : Base)
			BaseNames = tokens(GMM->BaseVarNames)'
			if (!GMM->collapse) {
				pBase = &_Explode(*pBase, N, T, NT)
				GMM->BaseNameTs = (0::T-1) # J(rows(BaseNames), 1, 1)
				BaseNames = J(T, 1, BaseNames :+ (stataversion()< 1200? "_" : "/")) // "/" only allowed in matrix stripes starting in Stata 12
			}
			pBaseNames = GMM->InstOrthogonal? &("D.":+BaseNames) : xtabond2_clone(BaseNames)

			GMM->MakeExtraInsts = GMM->equation==2 & SystemGMM   // Need to make extra instruments, as in standard Blundell-Bond?
			GMM->BaseAll = SystemGMM | !(GMM->equation | GMM->passthru)? 
						&editmissing(*pBase, 0) \ (GMM->collapse? 
								&_Difference(Base, N, T, NT, Complete, 0, 0) :
								&_Explode(_Difference(Base, N, T, NT, Complete, 0, 0), N, T, NT)) :
						&editmissing(*pBase, 0)

			GMM->BaseNamesAll = SystemGMM | !(GMM->equation | GMM->passthru)? pBaseNames \ &("D.":+*pBaseNames) : pBaseNames

			for (steps=split; steps>=0; steps--) { // run twice for split groups
				NGMMOptions++
				GMM->FullInstSetEq = !GMM->equation  			 // Should the full instrument set apply to levels equation?
				GMM->FullInstSetDiffed = !(GMM->equation | GMM->passthru) // Exploded instrument based on differences?
				j_GMM = j_GMM + (GMM->NumInsts = cols(Base) * _GMMinstPerBaseVar(GMM, T))
				GMM->gmmstyle = GMM->gmmstyle + (split? (GMM->equation?" eq(diff)":" eq(level)")+" lag("+strofreal(GMM->Laglim[1])+" "+strofreal(GMM->Laglim[2])+")" : "") + ")"
				GMM->NumBaseVars = cols(Base)
				if (split & steps) { // run at end of 1st iteration of split group
					sGMM = *GMM
					sGMM.next = GMM
					GMM = &sGMM
					GMM->equation = 0
					GMM->Laglim = J(1, 2, GMM->Laglim[1] - 1)  // levels inst for gmm(X, lag(a b)) specified by gmm(X, lag(a-1 a-1) eq(lev))
				}
			}
		}
		st_local("0", "," + optionsArg)
		stata("syntax [, GMMstyle(string) *]")
	}
	return (0)
}

void _MakeIVinsts(pointer(real rowvector) matrix InstOptInd, string rowvector InstOptTxt, real scalar g, real matrix Z_IV, real scalar j_IV, 
		real scalar SystemHeight, real scalar N, real scalar T, real scalar NT, real scalar NIVOptions, pointer(struct IVinst scalar) scalar IVinsts, 
		pointer (real matrix function) pfnXform, real colvector Complete, real scalar NDiffSargans, real scalar SystemGMM, string matrix ZIVnames) {
	real scalar i; real colvector p; pointer(struct IVinst scalar) scalar IV
	InstOptInd = J(NDiffSargans, 2, &.) // holds col indices for complements of each instument group--IV and GMM separate
	InstOptTxt = J(NDiffSargans, 1, " ")
	g = NDiffSargans
	Z_IV = J(SystemHeight, j_IV, 0); ZIVnames = J(0, 1, "")
	if (NIVOptions) {
		i = 0; 	IV = IVinsts
		while (IV != NULL) {
			ZIVnames = ZIVnames \ tokens(IV->BaseVarNames)'
			if (IV->equation)
				Z_IV[|1,i+1 \ NT, i+cols(IV->Base)|] = IV->mz?
																editmissing((IV->passthru? IV->Base : 
																(*pfnXform)(IV->Base, N, T, NT, Complete, 1)),0) : 
												     (IV->passthru? IV->Base : (*pfnXform)(IV->Base, N, T, NT, Complete, 1))
			if (SystemGMM & IV->equation != 1)
				Z_IV[|NT+1,i+1 \ SystemHeight, i+cols(IV->Base)|] = IV->mz? editmissing(IV->Base,0) : IV->Base
	
			if (strlen(IV->ivstyle)) { // leave constant term out of diff-sargan testing
				p = 0..i , i+1+cols(IV->Base)..j_IV+1
				InstOptInd[g, 1] = &(cols(p)>2 ? p[|2 \ cols(p) - 1|] : J(1, 0, .))
				InstOptTxt[g--] = IV->ivstyle
			}
			i = i + cols(IV->Base)
			IV = IV->next
		}
	}
	ZIVnames = J(rows(ZIVnames), 1, ""), ZIVnames
}

// AR test. e=full residual vector. w = (weighted) diff or levels residuals tested for AR(). wl = unweighted lagged residuals
void _ARTests	(real scalar arlevels, real scalar artests, real scalar onestepnonrobust, real scalar h, real scalar N, real scalar T, real scalar NT, real scalar SystemHeight, real scalar RowsPerGroup, 
                 real scalar sig2, real scalar orthogonal, real scalar SystemGMM, real scalar j, real scalar j_IV, real scalar j_GMM, real colvector touse, real colvector SortByEqID, real colvector Complete, 
								 real matrix X, real matrix X0, real colvector Y0, real matrix Z_IV, real matrix Z_GMM, real colvector b, real scalar weights, real colvector wt, real colvector wt0, 
								 pointer (real colvector) pe, pointer (real matrix) colvector pei, real colvector ARz, real colvector ARp, real matrix SubscriptsStep, real matrix SubscriptsStart,
								 pointer(struct GMMinst scalar) GMMinsts, string matrix ZGMMnames, string scalar tsfmt, real scalar tmin, real scalar tdelta, real matrix m2VZXA,
								 real rowvector keep, pointer (real matrix) pV) {

	real colvector p, touse2, w, wl, ZHw, _wt, wli
	real matrix H, psit, psiw, sum_wwli, Subscripts, tmp
	pointer (real matrix) pX
	real scalar lag, wHw, i
	
	if (onestepnonrobust) {
		H = _H(arlevels? 1 : h, 0, 0, 0, T) * sig2
		psit = _H(h, 0, orthogonal, 0, T) * sig2 //psi'
		if (SystemGMM) psit = arlevels? J(T, T, 0), psit : psit, J(T, T, 0)
	}
	touse2 = colshape(SystemGMM? touse[p = SortByEqID[|arlevels? NT+1 \ SystemHeight : . \ NT|]] : touse, T)'
	if (orthogonal & arlevels == 0) { // Get residuals in first differences for AR() test
		wl = _Difference(Y0 - (X0 = X0[, keep]) * b, N, T, NT, Complete, 0)
		pX = &_Difference(X0, N, T, NT, Complete, 0)
		if (weights) {
			pX = &(*pX :* wt0)
			w = colshape(wl :* wt0, T)'
			wl = colshape(wl, T)'
		} else
			wl = w = colshape(wl, T)'
	} else {
		if (SystemGMM) {
			w = (*pe)[p] // get residuals subject to AR() test 
			pX = &X[p,]
		} else {
			w = *pe
			pX = &X
		}
		if (weights) {
			wl = colshape(w :/ wt0, T)'
			w = colshape(w, T)'
		} else
			wl = w = colshape(w, T)'
	}
	ARz = ARp = J(artests, 1, .)
	for (lag=1; lag<=artests; lag++) {
		__lag(wl)
		if (any(sum_wwli = colsum(w :* wl))) {
			ZHw = J(j, 1, 0); Subscripts = SubscriptsStart
			if (onestepnonrobust) {
				wHw = 0
				for (i = N; i; i--) {
					_wt = weights? wt[|Subscripts|][|1\T|] : 1
					wli = wl[,i] :* touse2[,i]
					wHw = wHw + quadcross(wli, quadcross(H, _wt, wli))
					psiw = quadcross(psit, _wt, wli) // DPD uses ortho dev residuals here
					ZHw = ZHw + ((j_IV? quadcross(Z_IV[|Subscripts|], psiw) : J(0, 1, 0)) \ (j_GMM? quadcross(favorspeed()? Z_GMM[|Subscripts|] :
							_MakeGMMinsts(N, T, NT, SystemHeight, orthogonal, RowsPerGroup, j_GMM, touse, GMMinsts, ZGMMnames, tsfmt, tmin, tdelta, i) :* touse[|Subscripts|], psiw) : J(0, 1, 0)))
					Subscripts = Subscripts - SubscriptsStep
				}
			} else {
				wHw = sum(sum_wwli :* sum_wwli)
				for (i = N; i; i--) {
					ZHw = ZHw + ((j_IV? quadcross(Z_IV[|Subscripts|], *pei[i]) : J(0, 1, 0)) \ (j_GMM? quadcross(favorspeed()? Z_GMM[|Subscripts|] :
							_MakeGMMinsts(N, T, NT, SystemHeight, orthogonal, RowsPerGroup, j_GMM, touse, GMMinsts, ZGMMnames, tsfmt, tmin, tdelta, i), *pei[i]) : J(0, 1, 0))) * sum_wwli[i]
					Subscripts = Subscripts - SubscriptsStep
				}

				}
			tmp = quadcross(*pX, vec(wl))
			ARp[lag] = 2 * normal(-abs(ARz[lag] = sum(sum_wwli) / sqrt(wHw + quadcross(tmp, (m2VZXA * ZHw + *pV * tmp)))))
		}
	}
}

// Compute Z'e given e
real colvector _Ze(real colvector e, real rowvector p_IV, real rowvector p_GMM, real scalar N, real scalar T, real scalar NT, 
				real scalar SystemHeight, real scalar orthogonal, real scalar RowsPerGroup, real scalar j_GMM, real colvector touse, 
				pointer(pointer rowvector) GMM, real matrix SubscriptsStart, real matrix SubscriptsStep, real matrix Z_IV, real matrix Z_GMM,
				string scalar tsfmt, real scalar tmin, real scalar tdelta) {
	real matrix ZGMMe, Subscripts; real scalar id, j; string matrix ZGMMnames
	pragma unset ZGMMnames
	if (favorspeed())
		ZGMMe = quadcross(Z_GMM[, p_GMM], e)
	else if (cols(p_GMM) == 0)
		ZGMMe = J(0, 1, 0)
	else {
		j = p_GMM == . ? j_GMM : cols(p_GMM)
		ZGMMe = J(j, 1, 0)
		Subscripts = SubscriptsStart
		for (id = N; id; id--) {
			ZGMMe = ZGMMe + quadcross(_MakeGMMinsts(N, T, NT, SystemHeight, orthogonal, RowsPerGroup, j_GMM, touse, GMM, ZGMMnames, tsfmt, tmin, tdelta, id)[, p_GMM], e[|Subscripts|])
			Subscripts = Subscripts - SubscriptsStep
		}
	}
	return (quadcross(Z_IV[, p_IV], e) \ ZGMMe)
}

// Return matrix that effects transformation, transposed
real matrix _xform(real scalar xform, real scalar T) { //xform = 0 is diff, 1 is orthog dev
	real matrix M
	real scalar r
	M = I(T)
	if (xform) {
		__lag(M, -1)  // lag it to parallel first difference transform
		for (r=T-1; r; r--) M[|r+1, r+1 \ ., r+1|] = J(T-r, 1, -1/(T-r))
		return (M :/ editvalue(sqrt(colsum(M :^ 2)), 0, 1))
	}
	(M = M - _lag(M, -1))[1,1] = 0
	return (M)
}

// h is value of h() option; LeftXform and Rightxform=0 for diff, 1 for orthog
real matrix _H(real scalar h, real scalar LeftXform, real scalar RightXform, real scalar SystemGMM, real scalar T) {
	real matrix Ml, Mr, H
	Ml = h==1? I(T) : _xform(LeftXform, T)
	Mr = h==1? I(T) : _xform(RightXform, T)
	if (h == 3 | !SystemGMM) {
		if (SystemGMM) {
			Ml = Ml , I(T)
			Mr = Mr , I(T)
		}
		H = quadcross(Ml, Mr)
	} else
		H = blockdiag(quadcross(Ml,Mr), I(T))
	_edittozero(H, 100)
	return (H)
}

real scalar _GMMinstPerBaseVar(pointer(struct GMMinst) GMM, real scalar T)
{
	real scalar InstsPerBaseVar, LagMax, ForwardMax, N1, N2

	LagMax = T - 1 - (GMM->FullInstSetEq & GMM->FullInstSetDiffed)  // the most one could lag in the "full" instrument set
	ForwardMax = T - 2 + GMM->FullInstSetEq 		            // the most one could "forward" therein
	GMM->Laglim = max((-ForwardMax, GMM->Laglim[1])) , min((LagMax, GMM->Laglim[2]))

	if (GMM->collapse)
		return (GMM->Laglim[2] - GMM->Laglim[1] + 1 + GMM->MakeExtraInsts)
	else {
		if (GMM->Laglim[1] > 0 | GMM->Laglim[2] <= 0) {
			if (GMM->Laglim[1] >= 0) {
				N1 = LagMax - GMM->Laglim[1] + 1
				N2 = LagMax - GMM->Laglim[2]
			} else {
				N1 = ForwardMax + GMM->Laglim[2] + 1
				N2 = ForwardMax + GMM->Laglim[1]
			}
			InstsPerBaseVar = (N1*(N1+1) - N2*(N2+1))/2
		} else {
			N1 = ForwardMax + GMM->Laglim[1]
			N2 = LagMax - GMM->Laglim[2]
			InstsPerBaseVar = (LagMax+1)*(ForwardMax+1) - (N1*(N1+1) + N2*(N2+1))/2
		}
		return (GMM->MakeExtraInsts? InstsPerBaseVar + T - GMM->FullInstSetDiffed : InstsPerBaseVar)
	}
}

real matrix _MakeGMMinsts(real scalar N, real scalar T, real scalar NT, real scalar SystemHeight, real scalar orthogonal, real scalar RowsPerGroup, 
					real scalar j_GMM, real colvector touse, pointer(struct GMMinst scalar) scalar GMMinsts, string matrix ZGMMnames, string scalar tsfmt,
					real scalar tmin, real scalar tdelta,
					| real scalar id) // If id!=., restricts Z to just individual id
{
	real scalar c, Lag, LagStop, SearchDir, InstOffset, Zeros, _N, _NT, _SystemHeight
	real matrix Z, SubscriptsBase, SubscriptsInst, SubscriptsStep, NewInsts
	real colvector p
	pointer(real matrix) colvector BaseAll
	pointer(struct GMMinst scalar) scalar GMM
	
	if (id != .) {
		_N = 1
		_NT = T
		_SystemHeight = RowsPerGroup
	} else {
		_N = N
		_NT = NT
		_SystemHeight = SystemHeight
	}
	Z = J(_SystemHeight, j_GMM, 0)
	ZGMMnames = J(j_GMM, 2, " ")
	SubscriptsInst = J(2, 2, 1)
	GMM = GMMinsts
	while (GMM != NULL) {
		BaseAll = GMM->BaseAll

		if (id != .)
			for (c=1; c<=rows(BaseAll); c++) // Restrict to this id
				BaseAll[c] = &((*BaseAll[c])[|(id - 1) * T + 1, . \ id * T, .|])
		
		// Make instruments by copying columns sets from the "Wide" or (if collapse) original matrices.
		SubscriptsStep = 1, (GMM->collapse? 0 : GMM->NumBaseVars)
		SubscriptsBase = GMM->Laglim[1]+GMM->FullInstSetEq > 0? 1+GMM->FullInstSetDiffed \ _NT-GMM->Laglim[1] : 2-GMM->FullInstSetEq-GMM->Laglim[1] \ _NT
		SubscriptsBase = SubscriptsBase, (GMM->collapse? 1 \ GMM->NumBaseVars : (SubscriptsBase[1]-1) * GMM->NumBaseVars + 1 \ (SubscriptsBase[2] + T - _NT) * GMM->NumBaseVars)
		InstOffset = GMM->FullInstSetEq * _NT + GMM->Laglim[1]
		for (Lag = GMM->Laglim[1]; Lag <= GMM->Laglim[2]; Lag++) {
			SubscriptsInst = SubscriptsBase[,1] :+ InstOffset++ , SubscriptsBase[,2] :+ SubscriptsInst[1,2]-SubscriptsBase[1,2]
			NewInsts = (*BaseAll[GMM->FullInstSetDiffed+1])[|SubscriptsBase|]
			if (Lag & _N > 1) {  // 0 out rows that shifted into adjacent group
				Zeros = abs(Lag) + (!GMM->FullInstSetEq & Lag<0)
				p = 0 :: Zeros * (_N - 1) - 1
				p = trunc(p :/ Zeros) :* T + mod(p, Zeros) :+ T - Zeros + 1
				NewInsts[p,] = J(rows(p), cols(NewInsts), 0)
			}

			Z[|SubscriptsInst|] = NewInsts
			ZGMMnames[|SubscriptsInst[,2],(.\.)|] = J(cols(NewInsts), 1, GMM->FullInstSetEq? "Levels" : (orthogonal? "Orthog eq" : "Diff eq")) , 
			                                          _LF(Lag) :+ (*GMM->BaseNamesAll[GMM->FullInstSetDiffed+1]:+(GMM->collapse? "" : strofreal((GMM->BaseNameTs:+Lag)*tdelta:+tmin,tsfmt)))[|SubscriptsBase[,2]|]
			SubscriptsInst[1,2] = SubscriptsInst[2,2] + 1
			// To move base frame, raise the top end toward t=1, or, if it's flush against t=1, raise its bottom end
			if (Lag>=0) SubscriptsBase[2,] = SubscriptsBase[2,] - SubscriptsStep
			if (Lag<0 | !Lag & !GMM->FullInstSetDiffed) SubscriptsBase[1,] = SubscriptsBase[1,] - SubscriptsStep
		}
	
		if (GMM->MakeExtraInsts) {		
			if (GMM->Laglim[1] > 0) { // if both lags positive, start at lag Laglim[1]-1 (as is standard) and search to deeper lags if neceesary
				Lag = GMM->Laglim[1] - 1
				LagStop = GMM->Laglim[2] - 1
				SearchDir = 1
			} else {
				if (GMM->Laglim[2] > 0) { // if lags straddle 0, start at lag 0 and search to deeper lags (which could miss workable negative lags, but we only need one)
					Lag = 0
					LagStop = GMM->Laglim[2] - 1
					SearchDir = 1
				} else { // if both lags non-positive, start at lag Laglim[2]-1 and search to deeper forwards if neceesary
					Lag = GMM->Laglim[2] - 1
					SearchDir = -1
					LagStop = GMM->Laglim[1] - 1
				}
			}

			SubscriptsBase[,1] = Lag >= 0? 1 \ _NT-Lag : 1-Lag \ _NT
			SubscriptsBase[,2] = GMM->collapse? 1 \ GMM->NumBaseVars : (SubscriptsBase[1,1]-1) * GMM->NumBaseVars + 1 \ (SubscriptsBase[2,1] + T - _NT) * GMM->NumBaseVars
			SubscriptsInst = SubscriptsBase[,1] :+ Lag+_NT , SubscriptsBase[,2] :+ SubscriptsInst[1,2]-SubscriptsBase[1,2]
			NewInsts = (*BaseAll[2])[|SubscriptsBase|]
			if (Lag & _N > 1) {  // 0 out rows that shifted into adjacent group
				Zeros = abs(Lag)
				p = 0 :: Zeros * (_N - 1) - 1
				p = trunc(p :/ Zeros) :* T + mod(p, Zeros) :+ T - Zeros + 1
				NewInsts[p, .] = J(rows(p), cols(NewInsts), 0)
			}
			Z[|SubscriptsInst|] = NewInsts
			ZGMMnames[|SubscriptsInst[,2],(.\.)|] = J(cols(NewInsts), 1, "Levels eq"), _LF(Lag):+((*GMM->BaseNamesAll[2]):+(GMM->collapse? "" : (GMM->collapse? "" : strofreal((GMM->BaseNameTs:+Lag)*tdelta:+tmin, tsfmt))))[|SubscriptsBase[,2]|]
			SubscriptsInst[1,2] = SubscriptsInst[2,2] + 1

			// If any of these instruments happens to be 0 for all included observations, try shifting it to other t's in the instrument matrix
			if (SearchDir == 1) 
				for (c=SubscriptsInst[1,2]; c<=SubscriptsInst[2,2]; c++)
					for (; Lag<LagStop & !any(Z[,c] :& touse); Lag++) {
						Z[|2,c \ .,c|] = Z[|1,c \ _SystemHeight-1, c|]
						Z[_NT+1, c] = 0
					}
			else
				for (c=SubscriptsInst[1,2]; c<=SubscriptsInst[2,2]; c++)
					for (; Lag>LagStop & !any(Z[,c] :& touse); Lag--) {
						Z[|1,c \ _SystemHeight-1, c|] = Z[|2,c \ .,c|]
						Z[_SystemHeight, c] = 0
					}
		}
		GMM = GMM->next
	}
	return (Z)
}

real rowvector _rmcoll(real matrix X, real scalar hascons, real scalar nocons, | string rowvector varnames) {	
	real rowvector keep; real matrix U, t; real rowvector means; real colvector diag; real scalar i, jkeep; pointer(real matrix) scalar pX	
	if (cols(X)<=1)	
		return (cols(X))	
	if (rows(X)) {	
		if (nocons) {	
			if (hascons) {	
				t = X[,cols(X)]	
				pX = &(X - quadcross(X, t)'/sum(t) # t) // partial out constant term, which in Sys GMM has both 0's and 1's, to prevent it being picked for dropping 	
			} else
				pX = &X	
			U = quadcross(*pX, *pX)	
		} else {	
			means = mean(X)	
			U = quadcrossdev(X, means, X, means)	
		}	
		if (hascons) U = U[|.,. \ cols(U)-1,cols(U)-1|]	
		diag = editmissing(1 :/ sqrt(diagonal(U)), 0)
		U = (U :* diag) :* diag' // normalize	
		_edittozero(U = diagonal(invsym(U)), 10000)	
		keep = J(1, cols(X) - sum(!U), cols(X)) // if hascons=1 then last entry will default to cols(X), meaning keep constant, the last term	
		jkeep = 1	
		for (i = 1; i <= rows(U); i++)	
			if (U[i])	
				keep[jkeep++] = i	
			else if (cols(varnames))	
				printf("{txt}%s dropped due to collinearity\n", varnames[i])	
		return (keep)	
	}	
	return (.)	
}

real matrix _Difference(real matrix X, real scalar N, real scalar T, real scalar NT, real colvector Complete, real scalar forward, | real scalar MissingFillValue) {
	pragma unused Complete; pragma unused forward
	real matrix X2
	X2 = J(NT, cols(X), MissingFillValue)
	X2[|2,. \ .,.|] = X[|2,. \ .,.|] - X[|1,. \ NT-1,.|]
	if (N > 1) X2[(1::N-1) :* T :+ 1, .] = J(N-1, cols(X), MissingFillValue)
	if (MissingFillValue != .) _editmissing(X2, MissingFillValue)
	return (X2)
}

real matrix _Orthog(real matrix X, real scalar N, real scalar T, real scalar NT, real colvector Complete, real scalar forward, | real scalar MissingFillValue) {
	pragma unused N
	real matrix X2; real scalar i, j, it, _it, NLeadingVals; real rowvector SumLeadingVals
	X2 = J(NT, j=cols(X), MissingFillValue)
	for (i = it = NT; i; i = i - T) {
		NLeadingVals = 0; SumLeadingVals = J(1, j, 0)
		for (; it > i - T; it--) {
			_it = forward? it : NT + 1 - it
			if (NLeadingVals)
				X2[_it + forward,] = sqrt(1-1/(NLeadingVals+1)) * (X[_it, .] - SumLeadingVals / NLeadingVals)
			if (Complete[_it]) {
				NLeadingVals++
				SumLeadingVals = SumLeadingVals + X[_it,]
			}
		}
	}
	return (X2)
}

real matrix _Explode(real matrix Base, real scalar N, real scalar T, real scalar NT) {
	real matrix BaseWide, pr, pc, prStep, pcStep; real scalar NumBaseVars, TNumBaseVars
	BaseWide = J(NT, TNumBaseVars = T * (NumBaseVars=cols(Base)), 0)
	pc = TNumBaseVars-NumBaseVars+1 .. TNumBaseVars
	pcStep = J(1, NumBaseVars, NumBaseVars)
	prStep = J(N, 1, 1)
	for (pr = (1::N) :* T; pr[1,1]; pr = pr - prStep) {
		BaseWide[pr, pc] = Base[pr, .]
		pc = pc - pcStep
	}
	return(BaseWide)
}

void __lag(real matrix X, | real scalar lag) {
	if (lag > 0) {
		if (lag == .) lag = 1
		X[|1+lag,. \ .,.|] = X[|.,. \ rows(X)-lag,.|]
		X[|.,. \ lag,.|] = J(lag, cols(X), 0)
	} else if (lag < 0) {
		X[|.,. \ rows(X)+lag,.|] = X[|1-lag,. \ .,.|]
		X[|rows(X)+lag+1,. \ .,.|] = J(-lag, cols(X), 0)
	}
}

real matrix _lag(real matrix X, | real scalar lag) {
	real matrix X2
	__lag(X2 = X, lag)
	return (X2)
}

string scalar _LF(real scalar lag)
	return (lag!=0? (lag>0? "L" : "F") + strofreal(abs(lag)) + ".": "")

pointer (transmorphic matrix) scalar xtabond2_clone(transmorphic matrix X) {
	transmorphic matrix Y
	return(&(Y = X))
}

// return matrix whose rows are all the subsets of a row of strings. Null is at top.
string matrix strCombs(string rowvector symbols) {
	string matrix t
	if (cols(symbols)==1)
		return ("" \ symbols)
	t = strCombs(symbols[|2\.|])
	return ((J(rows(t),1,""), t) \ (J(rows(t),1,symbols[1]), t))
}

mata mlib create lxtabond2, dir("`c(sysdir_plus)'l") replace
mata mlib add lxtabond2 *(), dir("`c(sysdir_plus)'l")
mata mlib index
end
