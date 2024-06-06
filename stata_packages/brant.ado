*! version 4.0.0 2017-08-23 | long freese | stata 15 parameter naming fix

//  brant test of parallel reg assumption

capture program drop brant
program define brant, rclass
    version 11
    syntax [, DETAILs]

    tempvar touse dummy
    tempname bout d pvals ivchi ivout step1 step2 ologit
    tempname XpWmmX iXpWmmX XpWmlX XpWllX iXpWllX DB DBp iDvBDp
    tempname varb bstar id negid zero feed DB DBp iDvBDp step1 step2
    tempname step1 wald waldout pout dfout dtemp vbtemp bstemp outmat outvec

    if "`e(cmd)'"!="ologit" {
        di as error "brant can only be used after ologit"
        exit 9991
    }
    if "`e(wtype)'"!="" {
        di as error "brant does not work with weights"
        exit 9992
    }
    local depvar "`e(depvar)'"
    gen `touse' = e(sample)
    
    * 4.0.0 2017-08-23 stata 15 parameter naming fix
    if (_caller()>=15) version 15: _rm_modelinfo2
    else _rm_modelinfo2
    
    local rhsnms   "`r(rhsnms)'"
    local rhsN     "`r(rhsn)'"
    local catsN `r(lhscatn)'
    local catsNm1 = `catsN' - 1
    local catsNm2 = `catsN' - 2
    local catvals "`r(lhscatvals)'"

    * re-parse ologit model to get syntax for binary logits
    _getologitIV // program at bottom of file
    local logitvarlist "`s(varlist)'"

    _estimates hold `ologit'

//  estimate series of binary logits

    local i = 1
    local estlist ""
    while `i' < `catsN' {
        local splitat : word `i' of `catvals'
        capture drop `dummy'
        qui gen `dummy' = 0 if `depvar' <= `splitat' & `touse'==1
        qui replace `dummy' = 1 if `depvar' > `splitat' & `touse'==1
        qui logit `dummy' `logitvarlist' if `touse' == 1
        _rm_modelinfo2
        local binrhsN = `r(rhsn)'
        if `rhsN' != `binrhsN' {
            di as error ///
            "not all independent variables can be retained in binary logits"
            di as error "brant test cannot be computed"
            exit 9993
        }
        tempvar prob`i'
        qui predict `prob`i''
        tempname b`i' V`i' bc`i'
        mat `b`i'' = e(b)
        _rm_matrix_noomitted `b`i'' row
        _rm_matrix_noomitted `b`i'' col
        mat `b`i'' = `b`i''[1, 1..`rhsN']
        mat `V`i'' = e(V)
        _rm_matrix_noomitted `V`i'' row
        _rm_matrix_noomitted `V`i'' col
        mat `V`i'' = `V`i''[1..`rhsN', 1..`rhsN']
        mat `bc`i'' = e(b) /* with constant--for detail output only */
        mat `bc`i'' = `bc`i'''
        _rm_matrix_noomitted `bc`i'' row
        _rm_matrix_noomitted `bc`i'' col
        local outname "y>`splitat'"
        local outname "y_gt_`splitat'"
        estimates store `outname'
        local estlist "`estlist'`outname' "
        mat `bout' = nullmat(`bout'), `bc`i''
        local ++i
    }
    mat rownames `bout' = :

//  make variables for W(ml) matrices

    local i = 1
    while `i' < `catsN' {
        local i2 = `i'
        while `i2' <= `catsNm1' {
            tempvar w`i'_`i2'
            qui gen double `w`i'_`i2'' = `prob`i2'' - (`prob`i''*`prob`i2'')
            local ++i2
        }
        local ++i
    }

//  calculate variance Bm, Bl

    local i = 1
    while `i' < `catsN' {
        local i2 = `i'
        while `i2' < `catsN' {
            qui {
                * inverse(X'W(mm)X)
                mat accum `XpWmmX' = `logitvarlist' [iw=`w`i'_`i''] if `touse'==1
                _rm_matrix_noomitted `XpWmmX' row
                _rm_matrix_noomitted `XpWmmX' col
                mat `iXpWmmX' = inv(`XpWmmX')
                * X'W(ml)X
                mat accum `XpWmlX' = `logitvarlist' [iw=`w`i'_`i2''] if `touse'==1
                _rm_matrix_noomitted `XpWmlX' row
                _rm_matrix_noomitted `XpWmlX' col
                * inverse(X'W(ll)X)
                mat accum `XpWllX' = `logitvarlist' [iw=`w`i2'_`i2''] if `touse'==1
                _rm_matrix_noomitted `XpWllX' row
                _rm_matrix_noomitted `XpWllX' col
                mat `iXpWllX' = inv(`XpWllX')
                * product of three matrices
                mat `step1' = `iXpWmmX'*`XpWmlX'
                tempname vb`i'_`i2'
                mat `vb`i'_`i2'' = `step1'*`iXpWllX'
            }
            mat `vb`i'_`i2''= `vb`i'_`i2''[1..`rhsN',1..`rhsN']
            local ++i2
        }
        local ++i
    }

//  define var(B) matrix

    local i = 1
    while `i' < `catsN' {
        tempname row`i'
        local i2 = 1
        while `i2' <= `catsNm1' {
            if (`i'==`i2') mat `row`i'' = nullmat(`row`i''), `V`i''
            if (`i'<`i2')  mat `row`i'' = nullmat(`row`i''), `vb`i'_`i2''
            if (`i'>`i2')  mat `row`i'' = nullmat(`row`i''), `vb`i2'_`i'''
            local ++i2
        }
        local ++i
    }

//  combine matrices

    local i = 1
    while `i' < `catsN' {
        mat `varb' = nullmat(`varb') \ `row`i''
        local ++i
    }

//  make beta vector

    local i = 1
    while `i' < `catsN' {
        mat `bstar' = nullmat(`bstar'), `b`i''
        local ++i
    }
    mat `bstar' = `bstar''

//  create design matrix for wald test; make I, -I, and 0 matrices

    local dim = `rhsN'
    mat `id' = I(`dim')
    mat rownames `id' = `rhsnms'
    mat colnames `id' = `rhsnms'
    mat `negid' = -1*`id'
    mat rownames `negid' = `rhsnms'
    mat colnames `negid' = `rhsnms'
    mat `zero' = J(`dim', `dim', 0)
    mat rownames `zero' = `rhsnms'
    mat colnames `zero' = `rhsnms'
    * dummy mat
    local i = 1
    while `i' <= `catsNm2' {
        tempname drow`i'
        local i2 = 1
        while `i2' <= `catsNm1' {
            if (`i2'==1)  mat `feed' = `id'
            else if (`i2'-`i'==1) mat `feed' = `negid'
            else mat `feed' = `zero'
            mat `drow`i'' = nullmat(`drow`i'') , `feed'
            local ++i2
        }
        local ++i
    }
    local i = 1
    while `i' <= `catsNm2' {
        mat `d' = nullmat(`d') \ `drow`i''
        local ++i
    }

//  terms of wald test

    mat `DB' = `d'*`bstar'
    mat `DBp' = `DB''
    mat `step1' = `d'*`varb'
    mat `step2' = `step1'*`d''
    mat `iDvBDp' = inv(`step2')

//  calculate wald stat

    mat `step1' = `DBp'*`iDvBDp'
    mat `wald' = `step1'*`DB'
    sca `waldout' = `wald'[1,1]
    sca `dfout' = `rhsN'*`catsNm2'
    sca `pout' = chiprob(`dfout', `waldout')
    local i = 1
    while `i' <= `rhsN' {
        tempname d`i' vb`i' bstar`i'
        local i2 = 1
        while `i2' < `catsN' { // -1
            local row = (`rhsN'*(`i2'-1)) + `i'
            tempname drow vbrow
            local i3 = 1
            while `i3' <= `catsNm1' {
                local column = (`rhsN'*(`i3'-1)) + `i'
                if `i2' < `catsNm1' {
                    mat `dtemp' = `d'[`row',`column']
                    mat `drow' = nullmat(`drow') , `dtemp'
                }
                mat `vbtemp' = `varb'[`row',`column']
                mat `vbrow' = nullmat(`vbrow') , `vbtemp'
                local ++i3
            }
            if (`i2'<`catsNm1') mat `d`i'' = nullmat(`d`i'') \ `drow'
            mat `vb`i'' = nullmat(`vb`i'') \ `vbrow'
            mat `bstemp' = `bstar'[`row', 1]
            mat `bstar`i'' = nullmat(`bstar`i'') \ `bstemp'
            local i2 = `i2' + 1
        }
        local ++i
    }

//  wald test for each independent variable

    tempname waldiv
    local i = 1
    while `i' <= `rhsN' {
        mat `DB' = `d`i'' * `bstar`i''
        mat `DBp' = `DB''
        mat `step1' = `d`i''*`vb`i''
        mat `step2' = `step1' * `d`i'''
        mat `iDvBDp' = inv(`step2')
        mat `step1' = `DBp' * `iDvBDp'
        mat `waldiv' = nullmat(`waldiv') \ (`step1' * `DB')
        local ++i
    }
    if "`details'"=="details" {
        estimates table `estlist', b(%8.3f) t(%8.2f) ///
            title(Estimated coefficients from binary logits)
    }
    estimates drop `estlist'
    local rspec "&--"
    mat `outmat' = (`waldout', `pout', `dfout')
    mat rowna `outmat' = All
    mat colna `outmat' = chi2 "p>chi2" df
    local twid = 12
    * p for individual wald tests
    mat `pvals' = J(`rhsN', 1, 0)
    local i = 1
    local df = `catsNm2'
    while `i' <= `rhsN' {
        sca `ivchi' = `waldiv'[`i',1]
        if (`ivchi'>=0) mat `pvals'[`i',1] = chiprob(`df',`ivchi')
        if (`ivchi'<0) mat `pvals'[`i',1] = -999
        local vnm : word `i' of `rhsnms'
        local vlen = strlen("`vnm'") + 1
        if (`vlen'>`twid') local twid = `vlen'
        local rspec "`rspec'&"
        mat `outvec' = `ivchi', `pvals'[`i',1], `df'
        mat rowna `outvec' = `vnm'
        mat `outmat' = nullmat(`outmat') \ `outvec'
        local ++i
    }
    local cspec "o1& %`twid's | %10.2f & %9.3f & %6.0f &"
    matlist `outmat', title(Brant test of parallel regression assumption) ///
        cspec(`cspec') rspec(`rspec')
    di _new ///
        "A significant test statistic provides evidence that the parallel"
    di "regression assumption has been violated."
    mat `ivout' = `waldiv', `pvals'
    mat rownames `ivout' = `rhsnms'
    mat colnames `ivout' = chi2 p>chi2
    return scalar chi2 = `waldout'
    return scalar p = `pout'
    return scalar df = `dfout'
    return matrix ivtests `ivout'
    _estimates unhold `ologit'

end

program define _getologitIV, sclass

    local 0 "`e(cmdline)'"
    local 0 : subinstr local 0 "ologit" ""

        version 11

        syntax varlist(ts fv) [if] [in]        ///
            [fw pw iw aw] [, ///
            FROM(string) noLOg ///
            OFFset(varname numeric) /// -ml model- options
            TECHnique(passthru) VCE(passthru) LTOLerance(passthru) ///
            TOLerance(passthru) noWARNing ///
            Robust CLuster(passthru) /// old options
            CRITtype(passthru) SCORE(passthru) ///
            DOOPT /// NOT DOCUMENTED
            notable /// -Replay- options
            noHeader NOCOEF OR ///
            * /// -mlopts- options
        ]

    local dv : word 1 of `varlist'
    local varlist: subinstr local varlist "`dv'" ""
    sreturn local varlist "`varlist'"

end
exit
* version 3.3.1 2017-08-02 | long freese | stata 15 renaming fix
* version 3.3.0 2014-02-14 | long freese | spost13 release
