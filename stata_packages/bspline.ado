#delimit ;
capture program drop bspline;
program define bspline, rclass;
version 16.0;
/*
 Create a set of B-splines of specified power
 corresponding to a specified X-variable and a specified set of knots.
 Take, as input, X-variable name in xvar, power in power,
 and an ascending sequence of knots in knots,
 to be extended on left and right if exknot specified.
 Generate, as output, a set of B-splines in varlist,
 (or a set of B-splines prefixed by generatee,
 if varlist is absent),
 with type as specified in type,
 and variable labels generateed using format labfmt if present,
 or format of X-variable otherwise.
*! Author: Roger Newson
*! Date: 03 April 2020
*/

syntax [ newvarlist ] [if] [in] ,
  Xvar(varname numeric)
  [Knots(numlist min=2) noEXKnot
  Power(integer 0)
  Generate(string) Type(string)
  LABfmt(string) LABPrefix(string)
  ];
/*
 xvar() is the input X-variable.
 knots() specifies the knots.
 noexknot specifies that the knots will not be extended.
 power() specifies the power of the spline.
 generate() specifies the prefix of the names of the generated splines.
 type() specifies the storage type of the generated splines.
 labfmt() specifies the format to be used in the spline variable labels.
 labprefix() specifies the prefix to be used in the spline variable labels.
*/

*
 Set default label prefix
*;
if `"`labprefix'"'=="" {;
  local labprefix "B-spline on ";
};

* Rename varlist to splist *;
local splist "`varlist'";macro drop varlist;

* Check that power is non-negative *;
if(`power'<0){;
  display in red "Negative power not allowed";
  error 498;
};

* Set type to default if necessary *;
local deftype "float";
if("`type'"==""){;local type "`deftype'";};
else if(("`type'"!="float")&("`type'"!="double")){;
  disp in green "Note: invalid type for splines - `deftype' assumed";
  local type "`deftype'";
};

* Create to-use variable *;
tempvar touse;
mark `touse' `if' `in';markout `touse' `xvar';

*
 Check that there are observations
 and initialize knots if necessary
 and sort knots, discarding duplicates
*;
quietly summarize `xvar' if(`touse');
if((r(N)<=0)|(r(N)==.)){;error 2000;};
else if("`knots'"==""){;
  local rmin=r(min);local rmax=r(max);local knots "`rmin' `rmax'";
};
numlist "`knots'", sort;
local knots "`r(numlist)'";
local knots: list uniq knots;

* Extend knots if requested *;
if("`exknot'"!="noexknot"){;
  nlext,i(`knots') n(`power');
  local knots "`r(numlist)'";
};

*
 Initialise local macros splist, nknot, nspline and generatee
 (if necessary)
*;
local nknot:word count `knots';
* Fill in splist if absent *;
if("`splist'"!=""){;
  * Spline list has been provided by user *;
  local nspline:word count `splist';
  * Set generatee prefix (for column names of knot matrix) *;
  if("`generate'"==""){;local generate="c";};
};
else{;
  * Spline list must be generated *;
  if("`generate'"==""){;
    disp in red
     "Spline list unspecified - generate() or varlist required";
    error 498;
  };
  else{;
    *
     Number of splines to be guessed from knots and power
    *;
    local nspline=`nknot'-`power'-1;
    if(`nspline'<=0){;local nspline=1;};
    * Generate spline list *;
    local splist "`generate'1";
    local i1=1;
    while(`i1'<`nspline'){;local i1=`i1'+1;
      local splist "`splist' `generate'`i1'";
    };
  };
};

*
 Set number of knots to be used
 if there are more than enough to generate enough splines,
 or else generate extra knots
 if there are too few to generate enough splines
 and -noexknot- is not specified
*;
if(`nknot'>`nspline'+`power'+1){;
  * Ignore surplus knots at top of list *;
  local nknot=`nspline'+`power'+1;
  * Replace list of knots with shorter version *;
  local knotsn:word 1 of `knots';
  local i1=1;
  while(`i1'<`nknot'){;local i1=`i1'+1;
    local newk:word `i1' of `knots';
    local knotsn "`knotsn' `newk'";
  };
  local knots "`knotsn'";
};
else if(`nknot'<`nspline'+`power'+1){;
  if "`exknot'"=="noexknot" {;
    disp in red "Not enough knots specified for `nspline' splines of power `power'";
    error 498;
  };
  else {;
    *
     Generate extra knots
     (separated by the difference between the pre-existing
     ultimate and penultimate knots)
    *;
    local nnewk=`nspline'+`power'+1-`nknot';
    nlext,i(`knots') n(`nnewk') right;
    local knots "`r(numlist)'";
    local nknot:word count `knots';
  };
};
if `nknot'>c(matsize) {;
  disp as error "Too many knots for current matsize.";
  error 908;
};

*
 Check that generated spline and knot names are not too long
 (as they will be if the generate prefix is too long
 to prefix the required number of splines or knots)
*;
local lastsp:word `nspline' of `splist';
confirm name `lastsp';
local lastkn="`generate'`nknot'";
confirm name `lastkn';

* Generate label format from X-variate if necessary *;
if("`labfmt'"==""){;
  local labfmt:format `xvar';
};

*
 Create temporary variables containing plus-functions of power one
 originating at each of the knots
 and macro variable pflist
 containing list of plus-function variables
*;
local i1=0;local pflist="";
while(`i1'<`nknot'){;local i1=`i1'+1;
  tempvar p`i1';local pflist "`pflist' `p`i1''";
  if(`i1'<`nknot'){;
    * Plus-function variable to be generated *;
    local kncur:word `i1' of `knots';
    quietly{;
      gene `type' `p`i1''=0 if(`touse');
      replace `p`i1''=`xvar'-`kncur'
        if((`touse')&(`xvar'>=`kncur'));
    };
  };
};

*
 Create temporary vector knotv containing the knots
*;
tempname knotv;
local knotvv:word 1 of `knots';
local i1=1;
while(`i1'<`nknot'){;local i1=`i1'+1;
  local knoti1:word `i1' of `knots';
  local knotvv "`knotvv',`knoti1'";
};
capture quietly matr def `knotv'=(`knotvv');
if(_rc==908){;
  disp in red
    "matsize too small to create knot vector for `nknot' knots";
  disp in red
    "(required for `nspline' B-splines of power `power')";
  error 908;
};
else if(_rc==130){;
  disp in red "Too many knots for a Stata matrix definition";
  disp in red "The knot list generated was:";
  disp in red "`knotvv'";
  error 130;
};
else if(_rc!=0){;error _rc;};
* Set row and column names *;
matr rownames `knotv'=`xvar';
matr colnames `knotv'=`pflist';

* Create B-splines *;
tempname knotvc;
local i1=0;
while(`i1'<`nspline'){;local i1=`i1'+1;
  local splcur:word `i1' of `splist';
  local i2=`i1'+`power'+1;
  matr def `knotvc'=`knotv'[1,`i1'..`i2'];
  * Call _bspline *;
  _bspline `splcur' if(`touse'),
    knotv(`knotvc') xvar(`xvar') type(`type')
    labfmt(`labfmt') labprefix(`"`labprefix'"');
};

*
 Revise column names of knot vector
 (so as not to contain incomprehensible temporary varnames
 unless these were specified in the spline list)
*;
local knotnam "`splist'";
local i1=`nspline';
while(`i1'<`nknot'){;local i1=`i1'+1;
  local knotnam "`knotnam' `generate'`i1'";
};
matr colnames `knotv'=`knotnam';

*
 Find infimum and supremum X-values
 such that a spline in the space spanned by the B-splines
 is complete in the range [xinf,xsup)
 (which implies completeness at xsup for positive-power splines,
 which are left-continuous as well as right-continuous,
 but not for zero-power splines,
 which (by convention) only have to be right-continuous)
*;
local infk=`power'+1;local supk=`nknot'-`power';
tempname xinf xsup;
local xinfv:word `infk' of `knots';
local xsupv:word `supk' of `knots';
scal `xinf'=`xinfv';scal `xsup'=`xsupv';

*
 How many obs are out of the completeness range
 of a spline in the space spanned by the B-splines?
*;
tempvar incomp;
if(`power'==0){;
  gene byte `incomp'=((`xvar'<`xinf')|(`xvar'>=`xsup')) if(`touse');
};
else{;
  gene byte `incomp'=((`xvar'<`xinf')|(`xvar'>`xsup')) if(`touse');
};
quietly summ `xvar' if(`touse'&`incomp');
local nincomp=r(N);
if(`nincomp'>0){;
  disp in green "Note:"
    " `nincomp' obs have values of `xvar'"
    " outside the completeness range";
  if(`power'==0){;
    disp in green
      "( " `labfmt' `xinf' " <= `xvar' < " `labfmt' `xsup' " )";
  };
  else{;
    disp in green
      "( " `labfmt' `xinf' " <= `xvar' <= " `labfmt' `xsup' " )";
  };
};
drop `incomp';

* Return results *;
return local xvar "`xvar'";
return scalar power=`power';
return scalar nspline=`nspline';
return scalar nknot=`nknot';
return local type "`type'";
return local labprefix `"`labprefix'"';
return local labfmt "`labfmt'";
return local splist "`splist'";
return local knots "`knots'";
return scalar nincomp=`nincomp';
return scalar xinf=`xinf';
return scalar xsup=`xsup';
return matrix knotv `knotv';
end;

capture program drop _bspline;
program define _bspline, rclass;
version 10.0;
syntax newvarname [if] [in]
 ,Knotv(string) Xvar(varlist numeric min=1 max=1)
 Type(string) LABfmt(string) LABPrefix(string);
*
 Create B-spline in single variable of varlist
 corresponding to X-variate in xvar()
 and knots in row vector in knotv
 (whose column names are the plus-function variables
 originating at the respective knots)
 with type in type()
 and label specifying a range of X-values formatted by labfmt
 and prefixed by labprefix()
*;

* Local macros *;
local bspline:word 1 of `varlist';
* Number of knots = power plus 2 *;
local powp2=colsof(`knotv');
if(`powp2'<2){;
  disp in red "Not enough knots for a B-spline of any power";
  error 498;
};
local powp1=`powp2'-1;
local pflist:colnames `knotv';
local i1=0;
while(`i1'<`powp2'){;local i1=`i1'+1;
  local p`i1':word `i1' of `pflist';
  tempname s`i1';scal `s`i1''=`knotv'[1,`i1'];
};
local smin=`s1';local smax=`s`powp2'';

* Create to-use variable *;
tempvar touse;
mark `touse' `if' `in';markout `touse' `xvar';

* Initialize B-spline and its nonzero indicator *;
quietly{;
  gene `type' `bspline'=0 if(`touse');
  tempvar nonzero term;
  gene byte `nonzero'=`touse'&(`xvar'>=`smin')&(`xvar'<`smax');
  gene `type' `term'=0 if(`nonzero');
};

*
 Evaluate B-spline
 as a sum of products of dimensionless ratios
*;
local i1=0;
quietly while(`i1'<`powp1'){;local i1=`i1'+1;
  replace `term'=1 if(`nonzero');
  local i2=0;
  while(`i2'<`powp2'){;local i2=`i2'+1;
    if(`i2'==`i1'+1){;
      replace `term'=`term'*((`smax'-`smin')/(`s`i2''-`s`i1''))
        if(`nonzero');
    };
    else if(`i2'!=`i1'){;
      replace `term'=`term'*(`p`i1''/(`s`i2''-`s`i1''))
        if(`nonzero');
    };
  };
  replace `bspline'=`bspline'+`term' if(`nonzero');
};

* Variable label and format for B-spline *;
local fsmin=string(`smin',"`labfmt'");
local fsmax=string(`smax',"`labfmt'");
label variable `bspline' "`labprefix'[`fsmin',`fsmax')";
format `bspline' %8.4f;
char `bspline'[xsup] `smax';
char `bspline'[xinf] `smin';
char `bspline'[xvar] "`xvar'";

end;

program define nlext,rclass;
version 10.0;
*
 Take, as input, an input numlist in inlist
 and extend it to the left (if left present)
 and/or the right (if right present)
 or both ways (if neither present)
 by a number of extra values equal to next,
 separated by the distance between the ultimate and penultimate numbers
 on the appropriate side in inlist,
 and put the extended output into r(numlist)
*;

syntax,Inlist(numlist min=2) [Next(integer 1) Left Right];

* Set missing direction to both ways *;
if(("`left'"=="")&("`right'"=="")){;
  local left="left";local right="right";
};

* Extend as necessary *;
tempname cn dn;
* Extend on left if requested *;
if("`left'"!=""){;
  local cnv:word 1 of `inlist';scal `cn'=`cnv';
  local cnv:word 2 of `inlist';scal `dn'=`cnv'-`cn';
  local i1=0;
  while(`i1'<`next'){;local i1=`i1'+1;
    scal `cn'=`cn'-`dn';local cnv=`cn';
    local inlist "`cnv' `inlist'";
  };
};
* Extend on right if requested *;
if("`right'"!=""){;
  local nnum:word count `inlist';local nnumm=`nnum'-1;
  local cnv:word `nnum' of `inlist';scal `cn'=`cnv';
  local cnv:word `nnumm' of `inlist';scal `dn'=`cn'-`cnv';
  local i1=0;
  while(`i1'<`next'){;local i1=`i1'+1;
    scal `cn'=`cn'+`dn';local cnv=`cn';
    local inlist "`inlist' `cnv'";
  };
};

* Return output *;
return local numlist "`inlist'";

end;
