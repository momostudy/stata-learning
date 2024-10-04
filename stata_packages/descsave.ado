#delim ;
prog def descsave;
version 10.0;
syntax [anything(id="varlist")] [using] [, DOfile(string asis)
 LIst(string asis) SAving(string asis) noREstore FAST FList(name)
 CHarlist(string asis) IDNum(string) IDStr(string)
 REName(string) GSort(string) KEep(string)
 DShead Detail VARList
 SImple Short Fullnames Numbers
 ];
/*
 Extension of describe
 creating a resultsset and/or a do-file.
 The dofile() option specifies a do-file
   which can reconstruct types, formats, value labels, variable labels,
   and characteristics specified by the charlist option,
   assuming that variables of the specified names exist
   (as they will if the data set has been saved using outsheet
   and re-input using insheet).
 The list() option specifies what (if anything) will be listed,
   using a [varlist] [if exp] [in range] [ , [list_options] ] format
   (as used by the official Stata list command.
 The saving() option specifies a Stata data set,
   with 1 obs per variable in varlist,
   and data on names, types, formats, value labels, variable labels,
   and characteristics specified by the charlist() option.
 The norestore option specifies that the pre-existing data set
  is not restored after the output data set has been produced
  (set to norestore if the fast option is present).
 The fast option specifies that parmest will not preserve the original data set
  so that it can be restored if the user presses Break
  (intended for use by programmers).
 The flist() option is a global macro name,
  belonging to a macro containing a filename list (possibly empty),
  to which parmest will append the name of the dataset
  specified in the saving() option.
  This enables the user to build a list of filenames
  in a global macro,
  containing the output of a sequence of descsave calls,
  which may later be concatenated using dsconcat (if installed) or append.
 The idnum() and idstr() options
   specify numeric and string identifiers, respectively,
   which will be stored in variables of the same name
   in the saving() data set,
   and can be used as identifiers if the saving data set
   is concatenated with other saving data sets.
 The rename() option specifies a list
   of alternating old and new variable names,
   so the user can rename variables in the saving data set.
   The gsort() option specifies the sort order of the output data set,
   which defaults to the single variable order.
 The keep() option specifies the variables to keep
   in the output data set.
 The dshead option specifies a list of header lines
   giving dataset options (as in describe, short).
 The detail option acts like the option of the same name for describe,
   and sets the dshead option on automatically.
 The varlist option acts like the option of the same name for describe.
 The options simple, short, fullnames and numbers
   correspond to options of the same names for the describe command,
   and are added for backwards compatibility (and ignored),
   because the Stata 8 version of descsave
   passed them to describe to get the listing,
   instead of having a list() option..
*! Author: Roger Newson
*! Date: 10 December 2009
*/

*
 Derive locals from the syntax
*;
local dsvarlist "`varlist'";
local varlist "`anything'";
if "`detail'"!="" {;
  local dshead "dshead";
};

*
 Create returned results in r()
 and output dataset header lines if requested
*;
if "`dshead'"=="" {;
  qui desc `using', simple `dsvarlist';
};
else {;
  desc `using', short `detail' `dsvarlist';
};

*
 Set restore to norestore if fast is present
 and check that the user has specified one of the five options:
 dofile() and/or list() and/or saving() and/or norestore and/or fast.
*;
if "`fast'"!="" {;
    local restore="norestore";
};
if (`"`dofile'"'=="")&(`"`list'"'=="")&(`"`saving'"'=="")&("`restore'"!="norestore")&("`fast'"=="") {;
    disp as error "You must specify at least one of the five options:"
      _n "dofile() list(), saving(), norestore, and fast."
      _n "If you specify dofile(), then a do-file is created."
      _n "If you specify list(), then the output variables specified are listed."
      _n "If you specify saving(), then the new data set is output to a disk file."
      _n "If you specify norestore and/or fast, then the new data set is created in the memory,"
      _n "and any existing data set in the memory is destroyed."
      _n "For more details, see {help descsave:on-line help for descsave}.";
    error 498;
};

*
 Preserve old dataset if fast is unset
*;
if("`fast'"==""){;
    preserve;
};

* Input using dataset without observations from file if requested *;
if `"`using'"'!="" {;
  qui use if 0 `using', clear;
};

*
 Fill in varlist if necessary
 and count the variables
*;
if "`varlist'"=="" {;unab varlist: *;};
else {;unab varlist: `varlist';};
keep `varlist';
local nvar:word count `varlist';

*
 Expand and contract charlist if necessary
*;
local nchar:word count `charlist';
local charlist2 "";
forv i1=1(1)`nchar' {;
  local charcur: word `i1' of `charlist';
  if `"`charcur'"'=="*" {;
    foreach X of var `varlist' {;
      local charcur2: char `X'[];
      local charlist2 `"`charlist2' `charcur2'"';
    };
  };
  else {;
    capture confirm name `charcur';
    if _rc!=0 {;
      disp as error `"Illegal characteristic name - `charcur'"';
      error 498;
    };
    local charlist2 `"`charlist2' `charcur'"';
  };
};
local charlist: list uniq charlist2;
local nchar: word count `charlist';

* Create macro variables containing descriptive features *;
local i1=0;
while(`i1'<`nvar'){;local i1=`i1'+1;
  local varcur:word `i1' of `varlist';
  local name`i1' "`varcur'";
  local type`i1':type `varcur';
  local form`i1':format `varcur';
  local vall`i1':value label `varcur';
  local varl`i1':variable label `varcur';
  local i2=0;
  while(`i2'<`nchar'){;local i2=`i2'+1;
    local charcur:word `i2' of `charlist';
    local char`i2'_`i1' `"``varcur'[`charcur']'"';
  };
};

*
 Create file containing label definitions
 if do-file is required
*;
if(`"`dofile'"'!=""){;
  tempfile labdef;
  local vllist "";
  local i1=0;
  while(`i1'<`nvar'){;local i1=`i1'+1;
    * Check that variable label exists *;
    cap lab list `vall`i1'';
    if _rc==0 {;
      if("`vllist'"==""){;local vllist "`vall`i1''";};
      else if("`vall`i1''"!=""){;
        *
         Check that the value label is not in the list
         and add it to the list if it is not already there
        *;
        local newvl=1;
        foreach vallcur in `vllist' {;
          if "`vallcur'" == "`vall`i1''" {; local newvl=0; };
        };
        if `newvl' {;local vllist "`vllist' `vall`i1''";};
      };
    };
  };
  if("`vllist'"!=""){;
   qui label save `vllist' using `"`labdef'"',replace;
   label drop _all;
  };
  else{;
    label drop _all;
    qui label save using `"`labdef'"',replace;
  };
};

*
 Drop any existing observations before creating resultsset
*;
drop _all;

*
 Create new data set with 1 obs per variable in varlist
*;
qui set obs `nvar';
qui gene long order=_n;
qui compress order;
foreach X of new name type format vallab varlab{;qui gene str1 `X'="";};
local i2=0;
while(`i2'<`nchar'){;local i2=`i2'+1;
  qui gene str1 char`i2'="";
};
local i1=0;
while(`i1'<`nvar'){;local i1=`i1'+1;
  qui{;
    replace name=`"`name`i1''"' in `i1';
    replace type=`"`type`i1''"' in `i1';
    replace format=`"`form`i1''"' in `i1';
    replace vallab=`"`vall`i1''"' in `i1';
    replace varlab=`"`varl`i1''"' in `i1';
    local i2=0;
    while(`i2'<`nchar'){;local i2=`i2'+1;
      replace char`i2'=`"`char`i2'_`i1''"' in `i1';
    };
  };
};
lab var order "Variable order";
lab var name "Variable name";
lab var type "Storage type";
lab var format "Display format";
lab var vallab "Value label";
lab var varlab "Variable label";
*
 var[varname] characteristic
 (for use with the subvarname option of the list command)
*;
char order[varname] "variable order";
char name[varname] "variable name";
char type[varname] "storage type";
char format[varname] "display format";
char vallab[varname] "value label";
char varlab[varname] "variable label";
local i2=0;
while(`i2'<`nchar'){;local i2=`i2'+1;
  local charcur:word `i2' of `charlist';
  lab var char`i2' `"var[`charcur']"';
  char char`i2'[varname] `"varname[`charcur']"';
};

*
 Left-justify formats for all character variables
 in the base output variable set
*;
unab outvars: *;
foreach X of var `outvars' {;
    local typecur: type `X';
    if strpos("`typecur'","str")==1 {;
        local formcur: format `X';
        local formcur=subinstr("`formcur'","%","%-",1);
        format `X' `formcur';
    };
};

*
 Create numeric and/or string ID variables if requested
 and move them to the beginning of the variable order
*;
if("`idstr'"!=""){;
    qui gene str1 idstr=" ";
    qui replace idstr="`idstr'";
    qui compress idstr;
    qui order idstr;
    lab var idstr "String id";
};
if("`idnum'"!=""){;
    qui gene double idnum=real("`idnum'");
    qui compress idnum;
    qui order idnum;
    lab var idnum "Numeric id";
};

*
 Create output do-file if required
*;
if(`"`dofile'"'!=""){;
  *
   Create variable dquote containing a single double quote
   (this is a workaround for an obscure Stata bug
   encountered on 18 April 2001. - RBN)
  *;
  gene str1 dquote=`""""';
  * Create file containing storage types *;
  tempfile type_f;
  qui{;
    gene str1 line1="";gene str1 line2="";gene str1 line3="";
    replace line1="cap recast "+type+" "+name if(type!="");
    linesave `"`type_f'"';
    drop line1 line2 line3;
  };
  * Create file containing formats *;
  tempfile format_f;
  qui{;
    gene str1 line1="";gene str1 line2="";gene str1 line3="";
    replace line1="cap form "+name+" "+format if(format!="");
    linesave `"`format_f'"';
    drop line1 line2 line3;
  };
  * Create file containing value labels *;
  tempfile vallab_f;
  qui{;
    gene str1 line1="";gene str1 line2="";gene str1 line3="";
    replace line1="cap la val "+name+" "+vallab if(vallab!="");
    linesave `"`vallab_f'"';
    drop line1 line2 line3;
  };
  * Create file containing variable labels *;
  tempfile varlab_f;
  qui{;
    gene str1 line1="";gene str1 line2="";gene str1 line3="";
    disp "Line variables initialised to missing...";
    replace line1="cap la var "+name+" `"+dquote if(varlab!="");
    replace line2=varlab if(varlab!="");
    replace line3=dquote+"'" if(varlab!="");
    linesave `"`varlab_f'"';
    drop line1 line2 line3;
  };
  * Create files containing characteristics *;
  local i2=0;
  while(`i2'<`nchar'){;local i2=`i2'+1;
    local charcur:word `i2' of `charlist';
    tempfile char`i2'_f;
    qui{;
    gene str1 line1="";gene str1 line2="";gene str1 line3="";
      replace line1="cap char "+name+"[`charcur'] "+" `"+dquote if(char`i2'!="");
      replace line2=char`i2' if(char`i2'!="");
      replace line3=dquote+"'" if(char`i2'!="");
      linesave `"`char`i2'_f'"';
    drop line1 line2 line3;
    };
  };
  * Drop variable dquote (unwanted in resultsset) *;
  drop dquote;
  *
   Concatenate all files into memory
   and write to output do-file
  *;
  local dinflist `"`"`labdef'"' `"`type_f'"' `"`format_f'"' `"`vallab_f'"' `"`varlab_f'"'"';
  forv i2=1(1)`nchar' {;
    local dinflist `"`dinflist'`"`char`i2'_f'"'"';
  };
  dosave `dinflist' using `dofile';
};

*
 Modify and/or save Stata output if required
*;

*
 Rename variables if requested
*;
if "`rename'"!="" {;
    local nrename:word count `rename';
    if mod(`nrename',2) {;
        disp in green 
          "Warning: odd number of variable names in rename list - last one ignored";
        local nrename=`nrename'-1;
    };
    local nrenp=`nrename'/2;
    local i1=0;
    while `i1'<`nrenp' {;
        local i1=`i1'+1;
        local i3=`i1'+`i1';
        local i2=`i3'-1;
        local oldname:word `i2' of `rename';
        local newname:word `i3' of `rename';
        cap{;
            confirm var `oldname';
            confirm new var `newname';
        };
        if _rc!=0 {;
            disp in green
             "Warning: it is not possible to rename `oldname' to `newname'";
        };
        else {;
            rename `oldname' `newname';
        };
    };
};

*
 Sort if requested
*;
if "`gsort'"=="" {;local gsort "order";};
tempvar tiebreak;
qui gene long `tiebreak'=_n;
qui compress `tiebreak';
gsort `gsort' + `tiebreak';
drop `tiebreak';

* Keep only selected variables if requested *;
if "`keep'"!="" {;
    confirm variable `keep';
    keep `keep';
};

*
 List file if requested
*;
if `"`list'"'!="" {;
  list `list';
};

*
 Save file if requested
*;
if(`"`saving'"'!=""){;
    capture noisily save `saving';
    if(_rc!=0){;
        disp in red `"saving(`saving') invalid"';
        exit 498;
    };
    tokenize `"`saving'"',parse(" ,");
    local fname `"`1'"';
    if(strpos(`"`fname'"'," ")>0){;
        local fname `""`fname'""';
    };
    * Add filename to file list in FList if requested *;
    if(`"`flist'"'!=""){;
        if(`"$`flist'"'==""){;
            global `flist' `"`fname'"';
        };
        else{;
            global `flist' `"$`flist' `fname'"';
        };
    };
};

*
 Restore old data set if restore is set
 or if program fails when fast is unset
*;
if "`fast'"=="" {;
    if "`restore'"=="norestore" {;
        restore,not;
    };
    else {;
        restore;
    };
};

end;

prog def linesave;
version 10.0;
args file;
* Save variables line1, line2 and line3 to data set file *;

preserve;
keep line1 line2 line3;
keep if((!missing(line1))|(!missing(line2))|(!missing(line3)));
save `"`file'"',replace;
restore;

end;

prog def dosave;
version 10.0;
*
 Save the do-file using anything as input file list
*;
syntax [anything] using/ [,REPLACE];
local ninf: word count `anything';
local labdef: word 1 of `anything';

preserve;

qui {;
  drop _all;
  * Input label definition file first *;
  infix str line1 1-80 str line2 81-160 str line3 161-240 using `"`labdef'"';
  replace line1=subinstr(line1,"label define ","cap la de ",1);
  * Concatenate other input files into memory *;
  forv i2=2(1)`ninf' {;
    local infcur: word `i2' of `anything';
    append using `"`infcur'"';
  };
  * Create output do-file *;
  outfile line1 line2 line3 using `"`using'"',runtogether `replace';
};

restore;

end;
