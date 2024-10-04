*! version 1.0.1  12DEC2009
capture program drop dea
program define dea, rclass
    version 10.0

// syntax checking and validation-----------------------------------------------
// rts - return to scale, ort - orientation
// -----------------------------------------------------------------------------
    // returns 1 if the first nonblank character of local macro `0' is a comma,
    // or if `0' is empty.
		if replay() {
    		dis as err "ivars and ovars must be inputed."
        exit 198
		}

		// get and check invarnames
    gettoken word 0 : 0, parse(" =:,")
    while `"`word'"' != ":" & `"`word'"' != "=" {
        if `"`word'"' == "," | `"`word'"'=="" {
                error 198
        }
        local invarnames `invarnames' `word'
        gettoken word 0 : 0, parse(" :,")
    }
    unab invarnames : `invarnames'

    #del ;
    syntax varlist(min=1) [if] [in] [using/]
    [,
        RTS(string)
        ORT(string)
        STAGE(integer 2)
        TRACE
        SAVing(string)
        REPLACE
    ];
    #del cr

    local num_invar : word count `invarnames'
    local i 1
    while (`i'<=`num_invar') {
        local invarn : word `i' of `invarnames'
        local junk : subinstr local invarnames "`invarn'" "", ///
            word all count(local j)
        if `j' > 1 {
            di as error ///
                "cannot specify the same input variable more than once"
            error 498
        }
        local i = `i' + 1
    }

    // default model - CRS(Constant Return to Scale)
    if ("`rts'" == "") local rts = "CRS"
    else {
        local rts = upper("`rts'")
        if ("`rts'" == "CCR") local rts = "CRS"
        else if ("`rts'" == "BCC") local rts = "VRS"
        else if (~("`rts'" == "CRS" | "`rts'" == "VRS" | "`rts'" == "DRS")) {
            di as err "option rts allow for case-insensitive " _c
            di as err "CRS (eq CCR) or VRS (eq BCC) or DRS or nothing."
            exit 198
        }
    }

    // default orientation - Input Oriented
    if ("`ort'" == "") local ort = "IN"
    else {
        local ort = upper("`ort'")
        if ("`ort'" == "I" | "`ort'" == "IN" | "`ort'" == "INPUT") {
            local ort = "IN"
        }
        else if ("`ort'" == "O" | "`ort'" == "OUT" | "`ort'" == "OUTPUT") {
            local ort = "OUT"
        }
        else {
            di as err "option ort allow for case-insensitive " _c
            di as err "(i|in|input|o|out|output) or nothing."
            exit 198
        }
    }

    // default stage - 1
    if (~("`stage'" == "1" | "`stage'" == "2")) {
        dis as err "option stage is a 1 or 2 or nothing."
        exit 198
    }

    if ("`using'" != "") use "`using'", clear
    if (~(`c(N)' > 0 & `c(k)' > 0)) {
        dis as err "dataset is not ready!"
        exit 198
    }

// end of syntax checking and validation ---------------------------------------

    set more off
    capture log close dealog
    log using "dea.log", replace text name(dealog)
    preserve

    if ("`if'" != "" | "`in'" != "") {
        qui keep `in' `if'  // filtering : keep in range [if exp]
    }

    deanormal, ivars(`invarnames') ovars(`varlist') ///
        rts(`rts') ort(`ort') stage(`stage') `trace' saving(`saving') `replace'
    return add

    restore, preserve
    log close dealog
end

********************************************************************************
* DEA Normal - Data Envelopment Analysis Normal
********************************************************************************
program define deanormal, rclass
		#del ;
    syntax , IVARS(string) OVARS(string) RTS(string) ORT(string)
        [ STAGE(integer 2) TRACE SAVing(string) REPLACE ];
    #del cr

    preserve
    // di _n as input ///
    //     "options: RTS(`rts') ORT(`ort') STAGE(`stage') SAVing(`saving')"
    // di as input "Input Data:"
    // list

    // -------------------------------------------------------------------------

    tempname dmuIn dmuOut frameMat deamainrslt dearslt vrsfrontier crslambda
    mkDmuMat `ivars', dmumat(`dmuIn') sprefix("i")
    mkDmuMat `ovars', dmumat(`dmuOut') sprefix("o")
    local dmuCount = colsof(`dmuIn')

    mata: mkframemat("`frameMat'", "`dmuIn'", "`dmuOut'", "`rts'", "`ort'")
    deamain `dmuIn' `dmuOut' `frameMat' `rts' `ort' `stage' `trace'
    matrix `deamainrslt' = r(deamainrslt)
    mata: rankdea("`deamainrslt'", `=rowsof(`dmuIn')', `=rowsof(`dmuOut')')
    matrix `dearslt' = r(rank), `deamainrslt'

    // use mata function 'setup_dearslt_names' because the maximum string
    // variable length needs to be kept under the 244 for all the time
    mata: setup_dearslt_names("`dearslt'", "`dmuIn'", "`dmuOut'")

    if ("`rts'" == "VRS") {
        // caution : join order! (CRS -> VRS -> NIRS) // DRS-NIRS
        // 1. VRS TE(VRS Technical Efficiency)
        matrix `deamainrslt' = r(deamainrslt)
        matrix `vrsfrontier' = `deamainrslt'[1...,1]

        // 2. CRS TE(CRS Technical Efficiency)
        mata: mkframemat("`frameMat'", "`dmuIn'", "`dmuOut'", "CRS", "`ort'")
        deamain `dmuIn' `dmuOut' `frameMat' "CRS" `ort' 2 `trace'
        matrix `deamainrslt' = r(deamainrslt)
        matrix `vrsfrontier' = `deamainrslt'[1...,1], `vrsfrontier' // CRS VRS
        matrix `crslambda' = `deamainrslt'[1...,2..(`dmuCount' + 1)]

        // 3. NIRS TE(NIRS Technical Efficiency)
        mata: mkframemat("`frameMat'", "`dmuIn'", "`dmuOut'", "DRS", "`ort'")
        deamain `dmuIn' `dmuOut' `frameMat' "DRS" `ort' 1 `trace'
        matrix `deamainrslt' = r(deamainrslt)
        matrix `vrsfrontier' = `vrsfrontier', `deamainrslt'[1...,1] // VRS NIRS

        //
        matrix `vrsfrontier' = `vrsfrontier', J(rowsof(`vrsfrontier'), 2, 0)
        matrix rownames `vrsfrontier' = `: colfullnames `dmuIn''
        matrix colnames `vrsfrontier' = CRS_TE VRS_TE NIRS_TE SCALE RTS

        if("`trace'" == "trace") matrix list `crslambda'
        forvalues i = 1/`=rowsof(`vrsfrontier')' {
            matrix `vrsfrontier'[`i',4] = /*
                */ float(`vrsfrontier'[`i',1]/`vrsfrontier'[`i',2])

            /*******************************************************************
             * if CRS(CCR) == VRS(BCC) then CRS
             * else
             *     if sum of ル which DMUi reference equals to 1 then CRS mark
             *     if sum of ル which DMUi reference greater than 1 then DRS mark
             *     if sum of ル which DMUi reference less than 1 then IRS mark
             ******************************************************************/
            // (-1:drs, 0:crs, 1:irs)
            if (`vrsfrontier'[`i',1] == `vrsfrontier'[`i',2]) {
                matrix `vrsfrontier'[`i',5] = 0
            }
            else {
                local sumlambda = 0
                forvalues j = 1/`dmuCount' {
                    if (`crslambda'[`i', `j'] < .) {
                        local sumlambda = `sumlambda' + `crslambda'[`i', `j']
                    }
                }
                if (`sumlambda' < 1) {
                    matrix `vrsfrontier'[`i',5] = 1 // irs mark
                }
                else { // if (`sumlambda' >= 1) {
                    matrix `vrsfrontier'[`i',5] = -1 // drs mark
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // REPORT
    // -------------------------------------------------------------------------
    di as result ""
    di as input "options: RTS(`rts') ORT(`ort') STAGE(`stage')"
    di as result "`rts'-`ort'PUT Oriented DEA Efficiency Results:"
    matrix list `dearslt', noblank nohalf noheader f(%9.6g)

    if ("`saving'" != "") {
        // if save file exist and don't replace, make the backup file.
        if ("`replace'" == "") {
            local dotpos = strpos("`saving'",".")
            if (`dotpos' > 0) {
                mata: file_exists("`saving'")
            }
            else {
                mata: file_exists("`saving'.dta")
            }
            if r(fileexists) {
                local curdt = subinstr("`c(current_date)'", " ", "", .) + /*
                    */ subinstr("`c(current_time)'", ":", "", .)
                if (`dotpos' > 0) {
                    #del ;
                    local savefn = substr("`saving'", 1, `dotpos' - 1) +
                                   "_bak_`curdt'" +
                                   substr("`saving'",`dotpos', .);
                    #del cr
                    qui copy "`saving'" "`savefn'", replace
                }
                else {
                    local savefn = "`saving'_bak_`curdt'" + ".dta"
                    qui copy "`saving'.dta" "`savefn'", replace
                }
            }
        }

        if ("`rts'" != "VRS") {
            restore, preserve
            svmat `dearslt', names(eqcol)
            capture {
                renpfix _
                renpfix ref ref_
                renpfix islack is_
                renpfix oslack os_
            }
            capture save `saving', replace

            // di as result ""
            // di as result "DEA Result file:"
            // list
        }
    }
    return matrix dearslt = `dearslt'

    if ("`rts'" == "VRS") {
        if("`trace'" == "trace") {
            di _n(2) as result "CRS lambda(ル)"
            matrix list `crslambda' , noblank nohalf noheader f(%9.6f)
        }

        // to verify, if you don't have to verify you can comment this sentence.
        di _n(2) as result "VRS Frontier(-1:drs, 0:crs, 1:irs)"
        matrix list `vrsfrontier', noblank nohalf noheader f(%9.6f)

        di _n(2) as result "VRS Frontier:"
        restore, preserve
        svmat `vrsfrontier', names(col)
        rename RTS RTSNUM
        qui generate RTS = "drs" if RTSNUM == -1
        qui replace RTS = "-" if RTSNUM == 0
        qui replace RTS = "irs" if RTSNUM == 1
        drop NIRS_TE RTSNUM
        format CRS_TE VRS_TE SCALE %9.6f
        list
        if ("`saving'"!="") {
            capture save `saving', replace
        }
    }
    restore, preserve
end

********************************************************************************
* DEA Main - Data Envelopment Analysis Main
********************************************************************************
program define deamain, rclass
    args dmuIn dmuOut frameMat rts ort stage trace

    tempname efficientVec deamainrslt

    // stage step 1.
    if("`trace'" == "trace") {
        di _n(2) as txt "RTS(`rts') ORT(`ort') 1st stage."
    }
    dealp `dmuIn' `dmuOut' `frameMat' `rts' `ort' 1 `efficientVec' `trace'
    matrix `deamainrslt' = r(dealprslt)

    // stage step 2.
    if ("`stage'" == "2") {
        if("`trace'" == "trace") {
            di _n(2) as txt "RTS(`rts') ORT(`ort') 2nd stage."
        }
        matrix `efficientVec' = `deamainrslt'[1...,1]
        dealp `dmuIn' `dmuOut' `frameMat' `rts' `ort' 2 `efficientVec' `trace'
        matrix `deamainrslt' = r(dealprslt)
    }

    // if output oriented, get theta from eta
    if ("`ort'" == "OUT") {
        tempname eta
        forvalues i = 1/`=rowsof(`deamainrslt')' {
            scalar `eta' = el(`deamainrslt', `i', 1)
            matrix `deamainrslt'[`i',1] = 1/`eta'
            matrix `deamainrslt'[`i',2] = `deamainrslt'[`i',2...]/`eta'
        }
    }

    // adjust negative value
    forvalues i = 1/`=rowsof(`deamainrslt')' {
        forvalues j = 1/`=colsof(`deamainrslt')' {
            if (`deamainrslt'[`i',`j'] < 0) {
                matrix `deamainrslt'[`i',`j'] = 0
            }
        }
    }

    return matrix deamainrslt = `deamainrslt'
end

********************************************************************************
* DEA Loop - Data Envelopment Analysis Loop for DMUs
********************************************************************************
program define dealp, rclass
    args dmuIn dmuOut frameMat rts ort stagestep efficientVec trace

    tempname smMat dealprslt
    local dmuCount = colsof(`dmuIn')
    local dmuInRows = rowsof(`dmuIn')
    local dmuOutRows = rowsof(`dmuOut')
    local frameMatRows = rowsof(`frameMat')
    local frameMatCols = colsof(`frameMat')
    local lprsltCols = 1 + `dmuCount' + `dmuInRows' + `dmuOutRows'

    if (`stagestep' == 2) {
        matrix `frameMat'[1,2] = 0
        matrix `frameMat'[1,3+`dmuCount'] = J(1, `dmuInRows'+`dmuOutRows', 1)
        if ("`ort'" == "IN") {
            matrix `frameMat'[2,3] = ///
                -`frameMat'[2..(1+`dmuInRows'),3..(2+`dmuCount'+`dmuInRows')]
        }
    }

    if ("`ort'" == "IN") {
        forvalues j = 1/`dmuCount' {
            matrix `smMat' = `frameMat'

            if (`stagestep' == 1) {
                matrix `smMat'[2,2] = `dmuIn'[1...,`j']
            }
            else {
                matrix `smMat'[2,`frameMatCols'] = ///
                    `dmuIn'[1...,`j'] * `efficientVec'[`j',1]
            }
            matrix `smMat'[2 + `dmuInRows', `frameMatCols'] = `dmuOut'[1...,`j']

            lp `smMat' `j' `lprsltCols' `trace'
            matrix `dealprslt' = nullmat(`dealprslt') \ r(lprslt)
        }
    }
    else {
        forvalues j = 1/`dmuCount' {
            matrix `smMat' = `frameMat'

            matrix `smMat'[2, `frameMatCols'] = `dmuIn'[1...,`j']
            if (`stagestep' == 1) {
                matrix `smMat'[2 + `dmuInRows',2] = `dmuOut'[1...,`j']
            }
            else {
                matrix `smMat'[2 + `dmuInRows',`frameMatCols'] = ///
                    -`dmuOut'[1...,`j'] * `efficientVec'[`j',1]
            }

            lp `smMat' `j' `lprsltCols' `trace'
            matrix `dealprslt' = nullmat(`dealprslt') \ r(lprslt)
        }
    }

    // adjust efficiency
    if (`stagestep' == 2) {
        matrix `dealprslt'[1,1] = `efficientVec'
    }

    return matrix dealprslt = `dealprslt'
end

********************************************************************************
* LP - Linear Programming Using Simplex Method
********************************************************************************
program define lp, rclass
    args smMat dmui lprsltCols trace

    if("`trace'" == "trace") {
        di _n "[DMUi=`dmui']STEP 1: initialize matrix."
        matrix list `smMat', noblank nohalf noheader f(%9.6g)
    }

    tempname smequ elval // simplex method equation matrix(vector)
    local smMatRows = rowsof(`smMat')
    local smMatCols = colsof(`smMat')
    local artificialVal = `smMat'[1,`smMatCols' - 1] // constraint - 1

    // step 2. artificial variables elimination.
    matrix `smequ' = `smMat'[1,1...]
    forvalues i = 2/`smMatRows' {
      matrix `smequ' = `smequ' + (-`artificialVal')*`smMat'[`i',1...]
    }
    matrix `smMat'[1,1] = `smequ'

    if("`trace'" == "trace") {
        di _n "[DMUi=`dmui']STEP 2: artificial variables elimination."
        matrix list `smMat', noblank nohalf noheader f(%9.6g)
    }

    // temp matrix(vector) - dq(displacement quotient)
    tempname subsmequVec pivotRowVec pivotc constc dq
    local step = 3 // continue flag
    while `step' < c(maxiter) { // prevent infinite loop
        // make sub simplex method equation.
        // just, except C column and the constant column.
        matrix `subsmequVec' = `smMat'[1,2..(`smMatCols' - 1)]
        mata: maxvecindex("`subsmequVec'")
        if (r(maxval) <= 1.0e-12) continue, break

        local pivotCol = r(maxindex) + 1 // pick pivot column
        matrix `pivotc' = `smMat'[2...,`pivotCol']
        matrix `constc' = `smMat'[2...,`smMatCols']
        matrix `dq' = J(`smMatRows' - 1, 1, .)

        // beacause equal to `=`smMatRows' - 1' and
        // rowsof('pivotc') or rowsof(`constc')
        forvalues i = 1/`=`smMatRows' - 1' {
            // if pivotc's value less than 0, setting the (.)(missing value)
            if ( el(`pivotc', `i', 1) > 0) {
                matrix `dq'[`i',1] = el(`constc', `i', 1)/el(`pivotc', `i', 1)
            }
        }

        // pick pivot row
        mata: minvecindex("`dq'")
        if (r(minindex) == 0) { // if overall missing value
            if("`trace'" == "trace") di "pivotCol[`pivotCol']'s value check"
            matrix `smMat'[1,`pivotCol'] = 0
            continue, break
        }
        local pivotRow = r(minindex) + 1

        // By transforming the pivot column into unit vector.
        tempname pivotr smr derivedPivotr
        local pivotVal = `smMat'[`pivotRow',`pivotCol']
        matrix `pivotr' = `smMat'[`pivotRow',1...] / `pivotVal'
        matrix `smMat'[`pivotRow',1] = `pivotr'
        forvalues i = 1/`smMatRows' {
            if (`i' == `pivotRow') continue // except pivot row
            matrix `smr' = `smMat'[`i',1...]
            matrix `derivedPivotr' = `pivotr' * (`smr'[1,`pivotCol'])
            matrix `smMat'[`i',1] = `smr' - `derivedPivotr'
        }

        // adjustment
        forvalues iii = 1/`smMatRows' {
            forvalues jjj = 1/`smMatCols'{
                scalar `elval' = el(`smMat', `iii', `jjj')
                if(`elval'!=0 & abs(`elval')<=1.0e-12) {
                    matrix `smMat'[`iii',`jjj'] = 0
                }
            }
        }
        if("`trace'" == "trace") {
            di _n "[DMUi=`dmui']STEP `step': " _continue
            di "pivot[`pivotRow',`pivotCol'] = `pivotVal'"
            matrix list `smMat', noblank nohalf noheader f(%9.6g)
        }

        local ++step // next step.
    } // end of while loop

    // -------------------------------------------------------------------------
    // make result matrix
    // -------------------------------------------------------------------------
    tempname lprslt chkmat
    matrix `lprslt' = J(1, `lprsltCols', .)
    forvalues iii = 2/`smMatRows' {
        forvalues jjj = 2/`=`lprsltCols' + 1' { // except zvalue
            if(float(el(`smMat', `iii', `jjj')) == 1) {
                matrix `chkmat' = `smMat'[1...,`jjj']
                matrix `chkmat' = `chkmat'' * `chkmat'
                if (float(`chkmat'[1,1]) == 1) {
                    matrix `lprslt'[1,`jjj' - 1] = ///
                        float(`smMat'[`iii', `smMatCols'])
                }
            }
        }
    }

    return scalar zvalue = el(`smMat', 1, `smMatCols')
    return matrix lprslt = `lprslt'
end


********************************************************************************
* Data Import and Conversion
********************************************************************************

// Make DMU Matrix -------------------------------------------------------------
program define mkDmuMat
    #del ;
    syntax varlist(default=none numeric) [if] [in], DMUmat(name)
    [
        SPREfix(string)
    ];
    #del cr

    qui ds
    // variable not found error
    if ("`varlist'" == "") {
        di as err "variable not found"
        exit 111
    }

    // make matrix
    mkmat `varlist' `if' `in', matrix(`dmumat') rownames(dmu)
    matrix roweq `dmumat' = "dmu"
    matrix coleq `dmumat' = `=lower("`sprefix'") + "slack"'
    matrix `dmumat' = `dmumat''
end

// Start of the MATA Definition Area -------------------------------------------

version 10
mata:
mata set matastrict on

/**
 * make frame matrix and set matrix value at the param frameMat
 * rts - return to scale, ort - orientation
 */
function mkframemat( string scalar frameMat,
                     string scalar dmuIn,
                     string scalar dmuOut,
                     string scalar rts,
                     string scalar ort )
{
    real matrix F, X, Y
    real scalar row, col, sig, artificialval
    real scalar xrows, xcols, yrows, ycols, slacks, dmuCount

    X = st_matrix(dmuIn)
    Y = st_matrix(dmuOut)

    // basic value setting for artificial variabels
    sig = (ort == "IN" ? -1 : 1)
    artificialval = 1*(ort == "IN" ? max(X) : 1)
    xrows = rows(X); xcols = cols(X)
    yrows = rows(Y); ycols = cols(Y)
    if (rts == "VRS" | rts == "DRS") {
        slacks = xrows + yrows + 1
    }
    else {
        slacks = xrows + yrows
    }

    if (xcols != ycols) _error(3200, "in and out count of dmu is not match!")
    dmuCount = xcols // or ycols, because xcols == ycols

    // make frame matrix for CRS(CCR)
    F = J(1 + slacks, 3 + dmuCount + (2 * slacks), 0)
    replacesubmat(F, 1, 1, (1, sig))
    replacesubmat(F, 2, 3, sig * X)
    replacesubmat(F, 2 + xrows, 3, -sig * Y)
    replacesubmat(F, 2, 3 + dmuCount, sig * I(slacks))
    replacesubmat(F, 1, 3 + dmuCount + slacks, J(1, slacks, -artificialval))
    replacesubmat(F, 2, 3 + dmuCount + slacks, I(slacks))

    // adjustment for VRS(BCC) or DRS
    if (rts == "VRS") {
        replacesubmat(F, rows(F), 3, J(1, dmuCount, 1))
        F[rows(F),2 + dmuCount + slacks] = 0
        F[rows(F),cols(F)] = 1
    }
    else if (rts == "DRS") {
        replacesubmat(F, rows(F), 3, J(1, dmuCount + slacks, 1))
        F[rows(F),cols(F)] = 1
    }

    // return result
    st_matrix(frameMat, F)
}

function replacesubmat ( transmorphic matrix M,
                         real scalar row,
                         real scalar col,
                         transmorphic matrix T )
{
    M[|row,col\row + rows(T) - 1, col + cols(T) - 1|] = T
}

function setup_dearslt_names(string scalar dearsltmat,
                             string scalar dmuinmat,
                             string scalar dmuoutmat )
{
    string matrix DMU_CS // dmu in matrix column stripes
    string matrix DEARSLT_CS // dea result matrix column stripes
    string matrix DEARSLT_RS // dea result matrix row stripes
    scalar i

    DMU_CS = st_matrixcolstripe(dmuinmat)
    for(i = 1; i <= rows(DMU_CS); i++) {
        DMU_CS[i, 1] = "ref"
    }

    DEARSLT_CS = ("","rank"\"","theta")\DMU_CS\ // column join
        st_matrixrowstripe(dmuinmat)\st_matrixrowstripe(dmuoutmat)

    DEARSLT_RS = st_matrixcolstripe(dmuinmat)

    // setup dea result matrix row and column names
    st_matrixrowstripe(dearsltmat, DEARSLT_RS)
    st_matrixcolstripe(dearsltmat, DEARSLT_CS)
}

/**
 * deamat - dmucount x ( 1(theta) + dmu count + slcak(in, out) count)
 */
function rankdea( string scalar deamat,
                  real scalar dmuincount,
                  real scalar dmuoutcount )
{
    real matrix M
    real rowvector v, vv, retvec, slcaksum
    real scalar m, mm, row

    M = st_matrix(deamat)
    v = M[,1]
    retvec = J(rows(v), 1, .)
    maxindex(v, rows(v), i, w) //desc

    if (allof(w[,2], 1)) {
        retvec[i[1::rows(v)]] = (1::rows(v))
    }
    else {
        // rank correction for ties
        slcaksum = rowsum(M[|1,cols(M) - (dmuincount + dmuoutcount - 1)\.,.|])
        for (m = 1; m <= rows(w); m++) {
            if (w[m,2] >= 2) {
                vv = i[w[m,1]::(w[m,1] + w[m,2] - 1)]

                minindex(slcaksum[vv], w[m,2], ii, ww)
                for (mm = 1; mm <= rows(ww); mm++) {
                    for (row = ww[mm,1]; row < ww[mm,1] + ww[mm,2]; row++) {
                        retvec[vv[ii[row]]] = w[m,1] + ww[mm,1] - 1
                    }
                }
            }
            else {
                retvec[i[w[m,1]]] = w[m,1] // row = w[m,1]
            }
        }
    }

    st_matrix("r(rank)", retvec)
}

function maxvecindex( string scalar vecname )
{
    real matrix A

    A = st_matrix(vecname)
    maxindex(A, 1, i, w)

    st_numscalar("r(maxval)", A[i[1]])
    st_numscalar("r(maxindex)", i[1])
    st_matrix("r(maxindexes)", i)
}

function minvecindex( string scalar vecname )
{
    real matrix A

    A = st_matrix(vecname)
    if (sum(A :< .) > 0) {
        minindex(A, 1, i, w)
        st_numscalar("r(minval)", A[i[1]])
        st_numscalar("r(minindex)", i[1])
        st_matrix("r(minindexes)", i)
    }
    // if overall missing value.
    else {
        st_numscalar("r(minval)", .)
        st_numscalar("r(minindex)", 0)
        st_matrix("r(minindexes)", 0)
    }
}

function file_exists( string scalar fn )
{
    st_numscalar("r(fileexists)", fileexists(fn))
}
end

// End of the MATA Definition Area ---------------------------------------------
