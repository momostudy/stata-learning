*! version 1.2.0 20 Apr 1997
*  acplot -- display and print correlogram
*  based on Sean Becketti's ac:
*  August 1989, updated April 1991.
*  lags synonym for nlags added 6/16/92 by SRB.
*  output options added or modified by NJC
program define acplot
    version 3.0
    local varlist "req ex max(1)"
    #delimit ;
    local options "Lags(int 0) Nlags(int 20) SE PRint SPike
    Symbol(str) TItle(str) Connect(str) Gap(int 6) XLAbel(str)
    YLAbel(str) RLAbel(str) YLIne(str) SOrt Pen(str) noBorder *" ;
    #delimit cr
    parse "`*'"
    local lags = cond(`lags',`lags',`nlags')        /* SRB, 6/16/92 */
    if `lags' <= 0 {
        di in r "lags must be positive"
        exit 198
    }
    local lags = min(`lags',_N-5)
    tempvar lag ac acse macse xlag zero
    local x "`varlist'"

    quietly {
        gen long `lag' = _n
        lab var `lag' "Lag"
        gen float `ac' = .
        lab var `ac' "Autocorrelations"
        gen float `acse' = .
        lab var `acse' "SE band"
        gen float `xlag' = .
        corr `x', cova
        local C0 = (_result(1) - 1) * _result(3)
        count if `x' != .
        local NN = _result(1)
        local l = 0
        while (`l' < `lags') {
            local l = `l' + 1
            replace `xlag' = `x'[_n - `l']
            corr `x' `xlag', cova
            replace `ac' = (_result(1) - 1) * _result(4)/`C0' in `l'
            replace `xlag' = sum(`ac'^2) in f/`l'
            replace `acse' = cond(`l' > 1, /*
                */ sqrt((1 + 2 * `xlag'[_n - 1])/`NN'), /*
                */ sqrt(1/`NN')) in `l'
        }
        gen float `macse' = -`acse'
        lab var `macse' " "
        local xlab : variable label `x'
        if "`xlab'" == "" { local xlab "`x'" }
    }

    if "`print'" == "print" {
        local l 1
        if "`se'" == "se" { di _n in g "    Lag    Autoc'n      SE" }
        else { di _n in g "    Lag    Autoc'n" }
        while `l' <= `lags' {
            if "`se'" == "se" { local pse = `acse'[`l'] }
            di in y %7.0f `l' %10.3f `ac'[`l'] %10.3f `pse'
            local l = `l' + 1
        }
    }

    if ("`title'" != "") {
        if ("`title'" == ".") { local title }
        else local title "title(`title')"
    }
    else local title "title(Autocorrelations of `xlab')"
    if "`spike'" == "spike" {
        local connect "||ll"
        local symbol "iiii"
    }
    if "`connect'" == "" { local connect "l.ll" }
    if "`symbol'" == "" { local symbol "oiii" }
    if "`yline'" == "" { local yline "0" }
    if "`se'" == "se" {
        local gse "`acse' `macse'"
        if "`pen'" == "" { local pen "2377" }
    }
    else if "`pen'" == "" { local pen "23" }
    if "`xlabel'" == "" { local xla "xla" }
    else local xla "xla(`xlabel')"
    if "`ylabel'" == "" { local yla "yla" }
    else local yla "yla(`ylabel')"
    if "`rlabel'" == "" { local rla "rla" }
    else local rla "rla(`rlabel')"
    if "`sort'" == "" { local sort "sort" }
    if "`border'" == "" { local border "border" }

    qui replace `ac' = 1 in l
    qui replace `lag' = 0 in l
    qui gen `zero' = 0 if `ac' != .

    gr `ac' `zero' `gse' `lag', yline(`yline') `border' c(`connect') /*
        */ s(`symbol') pen(`pen') gap(`gap') `sort' /*
        */ `xla' `yla' `rla' `title' `options'
end
