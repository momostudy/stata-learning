*! version 1.2  16nov2023  
// mirror update 2023/11/17 2:32
*! version 1.1  11apr2021
*! Yujun Lian  arlionn@163.com

//  Junjie Kang 642070192@qq.com
//  Ruihan Liu  2428172451@qq.com
//  https://www.lianxh.cn

program define lianxh, rclass

version 14
	
syntax [anything] [,      ///  
        Fields(string)    ///   // 检索字段
        EXclude(string)   ///   // 需要排除的关键词 exclude(面板 DID); exclude(面板 DID +)
        EXFields(string)  ///   // 指定排除关键词的检索字段
        Hot(string)       ///   // 浏览量最大的 # 条, 不能与 New() 同时用
        New(string)       ///   // 最新的 # 条
        FRomto(string)    ///   // 时间范围, from(2021), from(2023-1 2023-5)
        GSortby(string)   ///   // 指定排序变量, 支持 gsort. 设定此选项时自动加载 nocat 选项. {author, pubdate, click/view, catname, title} 
        UPdata            ///   // 强制更新本地数据 lianxh_t_data
        NOUPdata          ///   //   不更新本地数据, hide in help document
        Simple            ///   // 极简风格. {title with link}
        NUMlist           ///   // 显示推文序号. 设定此选项时自动加载 nocat 选项
        Md                ///   // - Author, Year, [title](URL), jname No.#. 
        md0               ///   // - [Author](url), Year, [title](URL), jname No.#.         
        md1               ///   // - [title](URL)
        md2               ///   // - Author, Year, [title](URL)
        md3               ///   // ## catname + md0, do not document in help
        mdc               ///   // Author([Year](url_blog))
        mdca              ///   // [Author](author_link)([Year](url_blog))  
        mdnum             ///   // "1. xxx". instead of default: '- xxxx'. 设定此选项时自动加载 nocat 选项
        Clicktimes        ///   // display click times
        Date              ///   // display publish date        
	    Latex             ///   // Author, Year, \href{URL}{title}, jname No.#.
        lac               ///   // Author(\href{url_blog}{Year})
		Weixin            ///   // Author, Year, title, URL, 
		Text              ///   // same as 'weixin'
        BRowse            ///   // display results in brower directly
        View              ///   // view Markdown / text documents  
        Jname(string)     ///   // default: 连享会推文           
		CLS               ///   // 清屏后显示结果
		NOCat             ///   // 不呈现推文分类信息  
        NORange           ///   // 不呈现检索时段, rarely use
        NOPreserve        ///   // 运行 lianxh 时，不执行 -preserve- 和 -restore-。当前内存中的数据会被替换为 lianxh.ado 产生的数据
        SAVEtopwd         ///   // Save [_lianxh_temp_out_.md] at current directory. Default: Plus        
        savedta(string)   ///   // save final .dta , do not show in help document 
        LINKs             ///   // 呈现各类常用链接   
	   ]
   

  if "`nopreserve'" != ""{
      local _preserve ""
      local _restore  ""
  }
  else{ 
      local _preserve "preserve"
      local _restore  "restore"
  }      
      
      
`_preserve'  //~~~~~~~~~~~~~~~~~~~~~~~~ preserve begin ~~~~~~~~~~~~~~~~~~~~~~~~~~


clear 

   tokenize `"`0'"', parse(",")
   local options `3'

       
*------------------
*- 1 Checks and pre-setting
*------------------
    
*-----------------  
*-option conflicts and validity  
  
  *-md/latex/weixin/text 只能填一个
    local formatoptions "`md' `mdc' `mdca' `md0' `md1' `md2' `md3' `latex' `lac' `weixin' `text'"
    if wordcount("`formatoptions'")>1{
        dis as error "Options conflict: only one of {cmd:md*} / {cmd:latex} / {cmd:lac} / {cmd:weixin} / {cmd:text} options is allowed"
        exit
    }
   
  *-updata / noupdata
    if "`updata'" !="" & "`noupdata'" != ""{
        dis as error "Options conflict: only one of {cmd:updata} / {cmd:noupdata} options is allowed"
        exit  
    }
    
  *-hot() and new() options
   	if ("`new'"!=""){
        if `new'<=0{
            dis as error "invalid new(#): # must be a positive integer"
            exit 198
        }
    } 
    
   	if ("`hot'"!=""){
        if `hot'<=0{
            dis as error "invalid hot(#): # must be a positive integer"
            exit 198
        }
    }
    
    if "`new'" !="" & "`hot'" != ""{
        di as err "{cmd:hot()} and {cmd:new()} options conflict. Note: you can use {cmd:fromto()} option to restrict the time range."
        exit 198
    }    
    
*-------------
* basic 
    
 *-Clear Results window?
   if "`cls'" != "" {
   	   cls
   }
   
 *-display common links   
 	if "`links'" != "" {  
		 lianxh_links                    // sub-program
		 exit
	}
    
 *-{without any options} & {'browse' option}         depend-sub: lianxh_br.ado
 * and 
 * <anything = '[key1] or [key2] or ...'> (only OR, without AND)
//     cls
//     local anything "DID RDD 面板数据"  
//     local 2 "br" 
   
   local No_AND = (strpos(`"`anything'"', "+")==0)
   if (`No_AND'==0) & (strpos("`options'", "br")>0){
       local anything = subinstr(`"`anything'"', "+", " ", .)
       dis as text "Note: '+' is ignored when option {cmd:browse} is specified"
   }
   
   local Only_browse = (strpos("`options'", "br")>0) & wordcount("`options'")==1 
   if (`Only_browse'==1) & (`No_AND'==1){  // only 'browse' option + no '+'
  
       lianxh_br `"`anything'"', br max(3)           // lianxh_br.ado >>>>>>
      
       dis `"Note: you can search keywords at {browse "https://www.lianxh.cn":www.lianxh.cn}"'
      
       if wordcount(`"`anything'"') > 4{
           dis as smcl _c `"type {stata "lianxh `anything', text"} or {stata "lianxh `anything', md"} to print all results as a whole"'
       }
      
       exit 
   }

  

*----------------------------------
*- download data from www.lianxh.cn using 'insheetjson.ado'
*----------------------------------

    local plus_dir "`c(sysdir_plus)'l"          // dir/path of PLUS folder
    local plus_dir = subinstr(`"`plus_dir'"', "\", "/", .)          // For Mac
   
    *cap confirm file `"`plus_dir'/_lianxh_full_data.dta"'
    qui cap des using `"`plus_dir'/_lianxh_full_data.dta"'
    
    if _rc{
        // download newest data
        cap lianxh_get_data                      // lianxh_get_data.ado >>>>>>                 
        if _rc{
            _error_fail_download 
        }
    }
    else{
        if "`noupdata'" ==""{
            if `c(stata_version)'<=15{           // for version <= Stata 15.0
                check_data_15
                local need_up = (`r(is_new)'==0)
            }
            else{                                // for version > Stata 15.0
                qui describe using `"`plus_dir'/_lianxh_full_data.dta"'
                local need_up = ("`r(datalabel)'" != "`c(current_date)'")
            }

            if (`need_up') | ("`updata'" != "") | ("`new'" != ""){ // check data version 
                cap lianxh_get_data    // download newest data
                if _rc{
                    _error_fail_download 
                }
            }
        }
    }

   
*-------------
*-load dataset 

  qui use `"`plus_dir'/_lianxh_full_data.dta"', clear 

  
*------------------
*-auto-update lianxh.ado?
*------------------

  if "$lianxh_update_" != "1"{
      lianxh_check_update
      global lianxh_update_ = "1"
  }

*------------------
*- check gsortby() option
*------------------
* varlist: author, pubdate, click/view, catname, title 
  if `"`gsortby'"' !="" & strpos(`"`gsortby'"', "-"){
      local _gsort = subinstr(`"`gsortby'"', "-", "", .)
      cap ds `_gsort'
      if _rc{
          noi ds `_gsort'
      }
  }


  
*------------------
*- time range          
*------------------

* fromto(2021-10-1 2023-10-1) | fromto(2021/10/1, 2023-10-1)
* fromto(2021-10   2023-1)
* fromto(2021-10)
* fromto(2021)
/* examples of tfromto.ado package
    view browse "https://gitee.com/arlionn/stata/wikis/adofile/tfromto-test.md"
*/

if `"`fromto'"' != ""{

    qui lianxh_fromto `"`fromto'"' // check and re-format time range                 
    local range_t "`r(range1)'" 
    qui keep if inrange(pubdate, `r(t0)', `r(t1)')
   
    if _N == 0{
        dis as error "Invalid syntax for time range, or no blogs found in this time range."
        exit
    }
    else{
        if "`norange'"== ""{
            dis _col(3) "Time Range: `range_t'"
        }
    }    
}

 
*-----------------  
*-Search fields
*-----------------     

 *-excluding   
   if "`exclude'" != ""{
       qui lianxh_fields `exfields', gen(exvar)
       qui lianxh_exclude exvar, ex(`"`exclude'"')
       
       _check_no_obs
       
   }
  
 *-selecting 
   if `"`anything'"' != ""{
       qui lianxh_fields `fields', gen(svar)
       local _fields = r(fields)              // to be returned 
       qui lianxh_select svar, sel(`"`anything'"')
       
       _check_no_obs
       
   }


*------------------
*- new(#)
*------------------
* #>_N  list all blogs, show hint. (列出所有结果，给出提示)
* #<0   error msg (报错)

if "`new'" != ""{ 
	if `new'>_N{
        local Num = _N
        dis as text "Note: `new' exceed the maximum number of blogs, -new(`Num')- used"
        local new = `Num'
    } 
    
    gsort -pubdate
    
    if `new'>0{
        qui keep in 1/`new'
    }
    
    _check_no_obs
}


*------------------
*- hot(#)
*------------------
* #>_N  list all blogs, show hint. (列出所有结果，给出提示)
* #<0   error msg (报错)

if "`hot'" != ""{
	if `hot'>_N{
        local Num = _N
        dis as text "Note: only `Num' blogs are found, -hot(`Num')- used"
        local hot = `Num'
    }  
    
    gsort -view
    
    if `hot'>0{
        qui keep in 1/`hot'
    }
     
    _check_no_obs
}



*------------------
*- format Author name and gen author_link
*------------------

// 1. 把多个作者中间的多余空格，中文逗号，|，分号之类的字符替换为半角逗号
// 2. 产生一个新变量，包含作者链接

qui{  //----------------------------------qui ----------01------
    replace author = ustrregexra(author, "[，；\|]", ",", 1)
    replace author = ustrregexra(author, "\s\s", " ")
    replace author = ustrtrim(author)
    gen Is_author_valid = (!ustrregexm(author,"[，、!\(\)（）\|]+"))
    
    *-Author link
    if "`md0'`md3'`mdca'" != ""{
        split author if Is_author_valid==1, parse(`", "') gen(_author)
        local k_new = r(nvars)   // stata 17: local k_new = r(k_new)
        local site "https://www.lianxh.cn/search.html?s="
        forvalues j = 1/`k_new'{
            replace _author`j' = "[" + _author`j' + "]" + "(" + `"`site'"' + _author`j' + ")"  ///
                    if (_author`j'! = "")&(Is_author_valid==1)
        }
        gen author_link = _author1  if Is_author_valid==1
        forvalues j = 2/`k_new'{
            replace author_link = author_link + ", " + _author`j' ///
                    if (_author`j'! = "")&(Is_author_valid==1)
        } 
    }
}  //----------------------------------qui ----------01---over---




*------------------
*- Display
*------------------

*-------------
*- series name

  if "`jname'" == ""{  // Series Name, eg. 连享会推文 No.135
      local jname "连享会"   // 连享会推文
      local No " No."
  }
  else if "`jname'" == "null"{
      local jname ""
      local No "No."
  }
  else{
      local No " No."
  }
  local jname_No `", `jname'`No'"'


*-------------  
*-click times 

  if ("`clicktimes'" != "") | ("`hot'" != ""){ 
      gen _clickStr = string(view) 
      label var _clickStr "点击次数(文字)"
      local hot_new  `" + "  Hits: " + _clickStr"'
      local click_yes = 1
  }
  else{
      local click_yes = 0
  }
  
*-------------  
*-pubdates

  if ("`date'" != "") | ("`new'" != ""){ 
      local hot_new  `" + "  " + pubtime"'
      local pubdate_yes = 1
  }
  else{
      local pubdate_yes = 0
  }

*-------------  
*-click times & date
  
  if (`click_yes'==1) & (`pubdate_yes'==1) { 
      local hot_new  `" + "  " + pubtime + ", Hits: " + _clickStr"'
  }


*------------- setting display FORMAT --------------

//    Md                ///   // - Author, Year, [title](URL), jname No.#. 
//    mdc               ///   // Author ([Year](url_blog))
//    mdca              ///   // [Author](au_url) ([Year](url_blog))
//    md0               ///   // - [Author](au_url), Year, [title](URL), jname No.#.         
//    md1               ///   // - [title](URL)
//    md2               ///   // - Author, Year, [title](URL).
//    md3               ///   // ## catname + md0, do not document in help
//    Latex             ///   // Author, Year, \href{URL}{title}, jname No.#.
//    lac               ///   // Author (\href{url_blog}{Year})
//    Weixin            ///   // Author, Year, title, URL, 每隔 8 行空一行
//    Text              ///   // Author, Year, title, URL, 不空行


*-Default format: show results in Results Window
  
  local dis_opt "`md'`mdc'`mdca'`md0'`md1'`md2'`md3'`latex'`lac'`weixin'`text'"
  
  if ("`dis_opt'" ==""){  
      gen _Cat_br = `">>专题：{browse ""' + url_cat +`"": "' + catname +`"}"'
      if "`simple'" != ""{
          gen _BlogDis = `"{browse ""' + url_blog +`"":"' + title +`"}"'`hot_new'
      }
      else{  // default
          gen _BlogDis = author + ", " + year + `", {browse ""' + url_blog +`"":"' + title +`"}"'`hot_new'
      }
  }
  
*-numlist 
  if "`numlist'" != ""{
      local nocat "nocat"
  }  
  
  
*-Weixin / Text

  if ("`text'`weixin'" !=""){
      gen _Cat_br = `">>专题："' + catname + " " + url_cat
      gen _BlogDis = author + ", " + year + ", " + title + ". " + url_blog `hot_new'
  }
  
  
*-Markdown 

  if "`mdnum'" == ""{
      local item `"- "'
  }
  else{
      local item `"1. "'
      local nocat "nocat"
  }
  

  if "`md'`md0'`mdca'`md1'`md2'" != ""{
      local cat_br_md `""- 专题：[" + catname + "](" + url_cat  + ")""'
      gen _Cat_br   = `cat_br_md'  
      gen _title_link  = "[" + title   + "](" + url_blog + ")"
  }
  if "`md3'" != ""{
      local cat_br_md `""## " + catname"'
      gen _Cat_br   = `cat_br_md'  
      gen _title_link  = "[" + title   + "](" + url_blog + ")"
  }  
  if "`md'" !=""{
      gen _BlogDis = "`item'" + author      + ", " + year + ", " + _title_link  + `"`jname_No'"' + id + "." `hot_new'
  }
  if "`md0'`md3'" !=""{
      gen _BlogDis = "`item'" + author_link + ", " + year + ", " + _title_link  + `"`jname_No'"' + id + "." `hot_new'
  }
  if "`md1'" !=""{
      gen _BlogDis = "`item'" + _title_link  `hot_new'
  }
  if "`md2'" !=""{
      gen _BlogDis = "`item'" + author + ", " + year + ", " + _title_link  + "." `hot_new'
  }
  if "`mdc'" !=""{   // Author([Year](blogurl))
      *gen _Cat_br = `">>专题："' + catname + " " + url_cat
      gen year_link = " ([" + year + "](" + url_blog + "))"  // ([2022](blogurl))
      gen _BlogDis = author + year_link
  }
  if "`mdca'" !=""{  // [Author](author_link)([Year](blogurl))
      *gen _Cat_br = `">>专题："' + catname + " " + url_cat
      gen year_link = " ([" + year + "](" + url_blog + "))"  // ([2022](blogurl))
      gen _BlogDis = author_link + year_link
  }

  
*-LaTeX

  if "`latex'" != ""{    
      gen _Cat_br   = "- \href{" + url_cat  + "}" + "{" + catname + "}"
      gen _title_link  = "\href{" + url_blog + "}" + "{" + title   + "}"
      gen _BlogDis = "- " + author + ", " + year + ", " + _title_link  + `"`jname_No'"' + id + "." `hot_new'
  }
  if "`lac'" != ""{
      gen _Cat_br = `">>专题："' + catname + " " + url_cat
      gen year_link = "\href{" + url_blog + "}" + "{(" + year   + ")}"
      gen _BlogDis = author + year_link
  }
  

*-sort   

  gsort catname author title -pubdate
  egen _tag = tag(catname)
  local N = _N
  dis "  " //_c

  if ("`hot'" != ""){
      gsort -view
  }
  else if "`new'" != ""{
      gsort -pubdate
  }
  else if "`mdc'`mdca" != ""{  // new 2023/11/17 1:03
      sort author -pubdate
  }
  else if "`gsortby'" != ""{
      gsort `gsortby'
      //local nocat "nocat"    // 设定 gsortby 选项后，不再呈现分类列表
  }
  else{
    //gsort catname author title -pubdate
      gsort url_cat author title -pubdate    // new 2023/11/17 0:56
  }

      
*------------------
*- Display
*------------------
        
forvalues i = 1/`N'{

    if "`nocat'" == "" & _tag[`i'] ==1{
        if (("`weixin'`text'" != "") | ("`dis_opt'" =="")) & ("`hot'`new'" == "") & (`i'!=1){
            dis " "
        } 
        if "`hot'`new'`mdc'`mdca'" == ""{
            dis _Cat_br[`i']
        }
    }
    
    if ("`hot'`new'" == "" | ("`dis_opt'" !="")) & ("`numlist'" == ""){
            dis _col(3)         _BlogDis[`i'] 
    }
    else{
            dis _col(3) "`i'. " _BlogDis[`i'] 
    }    
}


*---- Export 

if ("`dis_opt'" != ""){
    qui{             //----------------------------------qui --------02------
        if ("`mdc'`mdca'" == "") & ("`nocat'" == "") {  
            gen _tag2 = _tag + 1 if _tag==1
            expand _tag2, gen(orig)
            replace _BlogDis = "" if orig==1
            replace _BlogDis = "  " + _BlogDis if _BlogDis != "" 
            replace _BlogDis = _Cat_br if _BlogDis == "" 
         // gsort _Cat_br -orig  author title          // gsort 
            gsort url_cat -orig  author title          // new 2023/11/17 0:58
        }
    }                //----------------------------------qui --------02--over--
    
  *-export: path and filename   
	if "`savetopwd'" == ""{
        local path `plus_dir'
    }
    else{
        local path `"`c(pwd)'"'
		local path = subinstr(`"`path'"', "\", "/", .)
    }
        
    local dis_opt_md  "`md'`mdc'`mdca'`md0'`md1'`md2'`md3'"
    local dis_opt_txt "`latex'`lac'`weixin'`text'"
    
    if "`dis_opt_md'" != ""{
        local fn_suffix ".md"
    }
    if "`dis_opt_txt'" != ""{
        local fn_suffix ".txt"
    }
    
	local saving "_lianxh_temp_out_`fn_suffix'"
        
    qui export delimited _BlogDis using `"`path'/`saving'"' , ///
    	       novar nolabel delimiter(tab) replace
    local save "`saving'"   
    	    noi dis " "
    		noi dis _dup(58) "-" _n ///
    				_col(3)  `"{stata `" view  "`path'/`save'" "': View}"' ///
    				_col(17) `"{stata `" !open "`path'/`save'" "' : Open_Mac}"' ///
    				_col(30) `"{stata `" winexec cmd /c start "" "`path'/`save'" "' : Open_Win}"' ///
                    _col(50) `"{browse `"`path'"': dir}"'
            noi dis _dup(58) "-"
    
    if "`view'"!=""{  // ("`md'`latex'`text'`weixin'" != "") & 
        view  "`path'/`save'"
    } 
	
	return local doc `"`path'/`save'"'
}


*--------
* save Stata dataset   (do not show in Help document)
  
  cap drop orig

  if `"`savedta'"' != ""{
  
      qui compress 
      cap noi save `"`savedta'"', replace 
	  
	  return local dta `"`savedta'"'
  }



*--------
* Return values 

  return scalar n = _N
  
  return local keywords = `"`anything'"'
  
  if `"`anything'"' != ""{
      return local search_fields `"`_fields'"'       
  }
  else{
      return local search_fields `"author title keywords"'  
  }
  

`_restore'  //~~~~~~~~~~~~~~~~~~~~~~~~ preserve over ~~~~~~~~~~~~~~~~~~~~~~~~~~~~


end 





*===================
*- Sub-programs     <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
*===================

// cap program drop _error_fail_download
program define _error_fail_download
    dis as error `"failed to download data. Check your network or visit {browse "https://www.lianxh.cn":www.lianxh.cn}"'
    dis ""
    exit 677
end  


// cap program drop _check_no_obs
program define _check_no_obs
    local N = _N
    if `N'==0{
        dis as error "Nothing found.  "    // 否则后面的 tag() 命令部分会报错
        dis as error _c `"You may change keyword(s), e.g. {stata "lianxh PSM "} or visit {browse "https://www.lianxh.cn/blogs/all.html": lianxh.cn  }"' _n
        exit 2000    // https://www.stata.com/manuals/perror.pdf#perror
    }
end 

*-------------------------------------------------------------------------------
*--------------------------------- lianxh_get_data.ado -------------------------

//*! version 1.4 8nov2023

//*  get JSON data from lianxh.cn's server using API
//*  Data saved as: <../plus/l/_lianxh_full_data.dta>
//*  Require: insheetjson.ado, libjson.ado

/* examples  
   lianxh_get_data
   lianxh_get_data, here
   lianxh_get_data, use
   lianxh_get_data, here use
   lianxh_get_data DID, here use
   
   qui lianxh_get_data
   des using "`c(sysdir_plus)'l/_lianxh_full_data.dta"
   use "`c(sysdir_plus)'l/_lianxh_full_data.dta", clear 
*/

// cap program drop lianxh_get_data  
program define lianxh_get_data, rclass
version 14

syntax [anything] [, Here Use Case(string) Path(string)]
                    * here: save data in working directory
                    *  use: load data, clear memory
                    * case: lower, upper, proper, preserve
                    
*-check requirement packages, if miss, install them
  cap which insheetjson
  if _rc{
      _install_pkg insheetjson
  }
  
  cap findfile libjson.mlib
  if _rc{
      _install_pkg libjson
  }
  
  
*-check 'use' option   
  if "`use'" != ""{
      local _preserve ""
      local _restore  ""
  }
  else{ 
      local _preserve "preserve"
      local _restore  "restore"
  }
  
*-filename of .dta according specification of 'anything'
  if "`anything'" == ""{
       local FN "full"         // _lianxh_full_data.dta
  }  
  else{
      local FN "temp"          // _lianxh_temp_data.dta
  }
  
*-insheetjson 

`_preserve'  /*--- preserve --- begin ---*/ 
   
    clear 
    
    local site "https://www.lianxh.cn/web-api/search?s="
    local key `"`anything'"' 
    
    mata: st_local("key", urlencode(`"`key'"')) // decode URL to ASCII
    
    local url `"`site'`key'"'
    // dis "`url'"                  // test 
    
    gen str20  catname  = ""
    gen str50  url_cat  = ""
    gen str50  url_blog = ""
    gen str150 title    = ""
    gen str200 keyword  = ""
    gen str30  author   = ""
    gen str10  view     = ""
    gen str20  pubtime  = "" 
 // gen str500 description  = ""
 
    local vlist "url_blog catname url_cat title keyword author view pubtime" // description
    local cols `""url" "type_name" "type_url" "title" "keyword" "author" "pv" "release_time""' // "description"
    
    noi dis "updating data: ......  " _c           // ---------- 是否保留 ？？
    
    cap insheetjson `vlist' using "`url'", replace table(data) ///
        columns(`cols') flatten   // savecontents("lxhData")
        
  *-中文乱码
    qui replace catname = "内生性-因果推断"   if strpos(catname, "内生性-因果")
    qui replace catname = "空间计量-网络分析" if strpos(catname, "空间计量-")
    qui replace catname = "交乘项-调节-中介"  if strpos(catname, "调节-")
 
    if _rc == 0 {
        noi dis _c "finished"                  // ---------- 是否保留 ？？
        if _N == 0 {  如果检索结果为空，需要给出提示，否则 insheetjson 会报错中断
            noi dis as text "Nothing found. You may change another keyword"
            exit 198
        }
    }
    else{
        noi dis as error "Can not insheet JSON data. Report an error to: arlionn@163.com"
    }
       
    gen pubdate = date(pubtime, "YMD")
    format pubdate %td
    
    qui destring view, replace 
    
    order cat author title keyword url*  // Desc
    
  *-version of Data
    label data "`c(current_date)'"   // data 的版本号
    local data_v: data label
//     dis "`data_v'"                   // 显示 data 版本号
    
  *-new variable: the ID of blog (Numb)
    qui gen ID = ustrregexs(0) if ustrregexm(url_blog, "\d{1,}")
    
  *-delete Special Characters in title: ✅ ⏩ ⏫
    local special_char "✅⏩⏫☝⚡⚽⛄⛳⛵⭐⭕"
    qui replace title = ustrregexra(title, "[`special_char']", "", 1)
//     foreach cc of local special_char{
//         replace title = subinstr(title, "`cc'", "",.) 
//     }
    qui replace title =  strtrim(title)  // delete leading and trailing blanks
    qui replace title = stritrim(title)  // delete internal blanks

    **Using Regular Expressions to Address Mixed Chinese and English titles
    * by adding blanks
    **Potential Issue: It may lead to inconsistency between titles 
    *        on the main page and those presented in related tweets.
    **Resolution:** No action will be taken at this time.
    * (?<![\x00-\x7F])([\x00-\x09\x0B-\x1F\x21-\x7F]+)(?![\x00-\x7F])    
    *-save the data to '../PLUS/l'
    
  *-pubtime, Year
    qui replace pubtime = subinstr(pubtime, "-", "/", .) // 2021-1-1 --> 2021/1/1
    qui gen Year = string(year(pubdate))
    qui compress
    
  *-Change the case of variable names  
    
    if (!mi("`case'")){
            rename *, `case'
    }
    else{
        rename *, lower
    }
   
   
  *-variable label
    label var catname     "推文分类名称"                
    label var author      "作者姓名"                
    label var title       "推文标题"                
    label var keyword     "推文关键词"                
    label var url_cat     "推文类别链接"                
    label var url_blog    "推文链接"                
    label var view        "浏览次数"                
    label var pubtime     "发布时间(文字)"                
    label var pubdate     "发布时间(数值)"                
    label var id          "推文编号"                
    label var year        "发布年份"
  
  *-clone new variable 
    clonevar click = view   
    
  *-------  
  *-saving 
  
    *-save to current working directory
    if "`here'" != ""{
        local plus_dir : pwd
//         dis "`plus_dir'"
//         save "`plus_dir'/_lianxh_full_data.dta", replace
    } 
    else{
        *-save to "`c(sysdir_plus)'"
        local plus_dir "`c(sysdir_plus)'l"    
        local plus_dir = subinstr(`"`plus_dir'"', "\", "/", .)  // For Mac
        mata: plus_Yes = direxists("`plus_dir'")  // Exist ?
        mata: st_local("plus_Yes", strofreal(plus_Yes)) 
        if (`plus_Yes' != 1){
            dis as error `"can not find dir: `plus_dir', where '_lianxh_full_data.dta' will be saved."'
            dis "Click {stata "sysdir"} to check. Report bugs to: arlionn@163.com"'
            return scalar get = 0
            exit 601
        }       
    }
    qui save "`plus_dir'/_lianxh_`FN'_data.dta", replace
    return scalar get = 1   
    
    if "`use'" != ""{
        qui use "`plus_dir'/_lianxh_`FN'_data.dta", clear
    }
    
  *-return value   
    local plus_dir = subinstr(`"`plus_dir'"', "\", "/", .)
    
    return local fndir  `"`plus_dir'/_lianxh_`FN'_data.dta"'  // dir/FN
    return local fn     `"_lianxh_`FN'_data.dta"'            // File name 
    
`_restore'  /*--- preserve --- end ---*/ 

end 

// cap program drop _install_pkg
program define _install_pkg
syntax anything 
local pkg "`anything'"

          noi dis as text `">> installing the required packages: {cmd:`pkg'}"'
          cap noi ssc install `pkg', replace 
          if _rc == 0{
              noi dis as text ":: Successed"
          }
          else{
              noi dis as error "Failed. Please check your network or your admin right for installation"
              noi dis as text  "Note: you can type -findit `pkg'- and install it by hand"
              exit 677
          }
          
end   



*-------------------------------------------------------------------------
*----------------------------- check_data_15.ado -------------------------
// cap program drop check_data_15
program define check_data_15, rclass
version 14

    local c_pwd : pwd
    
    local plus_dir "`c(sysdir_plus)'l/"  // dir/path of PLUS folder    
    local plus_dir = subinstr(`"`plus_dir'"', "\", "/", .)  // For Mac 
    
    qui cd `"`plus_dir'"'
    
	lianxh_dirlist  "_lianxh_full_data.dta"
	
    local fdates = date("`r(fdates)'", "YMD")
    local current_date = date("`c(current_date)'", "DMY")
    
    if "`fdates'" == "`current_date'"{
        local is_new = 1
    }
    else{
        local is_new = 0 
    }
    
    qui cd `"`c_pwd'"'  
    
    return scalar is_new = `is_new'

end

//*! version 2.0.1 9nov2023, simplized and modified from 'dirlist.ado'
//*! version 1.3.1 MA 2005-04-04 12:54:30, original version 
//*  Morten Andersen, mandersen@health.sdu.dk
//*  saves directory data in r() macros fnames, fdates, nfiles

// cap program drop lianxh_dirlist
program define   lianxh_dirlist, rclass

	version 8

	syntax anything
	
	tempfile dirlist

	if "`c(os)'" == "Windows" {
	
		local shellcmd `"dir `anything' > `dirlist'"'

	}
	
	if "`c(os)'" == "MacOSX" {
	
		local anything = subinstr(`"`anything'"', `"""', "", .)
	
		local shellcmd `"ls -lT `anything' > `dirlist'"'

	}
		
	if "`c(os)'" == "Unix" {
	
		local anything = subinstr(`"`anything'"', `"""', "", .)
	
		local shellcmd `"ls -l --time-style='+%Y-%m-%d %H:%M:%S'"'
		local shellcmd `"`shellcmd' `anything' > `dirlist'"'
		
	}

	quietly shell `shellcmd'

	* read directory data from temporary file
	
	tempname fh
	
	file open `fh' using "`dirlist'", text read
	file read `fh' line
	
	local nfiles = 0
	local curdate = date("`c(current_date)'","dmy")
	local curyear = substr("`c(current_date)'",-4,4)
	
	while r(eof)==0  {
	
		if `"`line'"' ~= "" & substr(`"`line'"',1,1) ~= " " {

			* read name and data for each file

			if "`c(os)'" == "MacOSX" {
				
				local fda   : word 6 of `line'
				local fmo   : word 7 of `line'
				local fyr   : word 9 of `line'
				local fname : word 10 of `line'
				local fdate =  ///
					string(date("`fmo' `fda' `fyr'","mdy"),"%dCY-N-D")
								
			}

			if "`c(os)'" == "Unix" {
				
				local fdate : word 6 of `line'
				local fname : word 8 of `line'
							
			}

			if "`c(os)'" == "Windows" {
			
				local fdate : word 1 of `line'
				local word3 : word 3 of `line'
				
				if upper("`word3'")=="AM" | upper("`word3'")=="PM" {
					local fname : word 5 of `line'
				}
				else {
					local fname : word 4 of `line'
				}							
	
			}

			local fnames "`fnames' `fname'"
			local fdates "`fdates' `fdate'"
			local nfiles = `nfiles' + 1

		}

		file read `fh' line
	
	}
	
	file close `fh'
	
	return local fnames `fnames'
	return local fdates `fdates'
	return local nfiles `nfiles'
	
end




*-------------------------------------------------------------------------------
*----------------------------- lianxh_check_update.ado -------------------------
//*! version 1.1  8nov2023

/*
~~~ basic idea
1. get newest version number (NVN) from <lianxh.cn>. NVN is save in blog with keyword="lianxh-update-v#.#"
2. if failed, check NVN from <lianxh.oss-cn.aliyuncs.com>. NVN is saved in 'lianxh-version.txt'
3. compare NVN with local version number (LVN) and update 
Note: every day, 'lianxh_check_update.ado' only works one time when lianxh.ado is first loaded
*/

/*
~~~~~~~test
cls
cap profiler clear 
profiler on
// set trace on
lianxh_check_update
ret list 
// set trace off 
profiler off
profiler report
*/

// cap program drop lianxh_check_update
program define lianxh_check_update, rclass
version 14

* require: which_version.ado
     cap which which_version 
     if _rc{
         cap ssc install which_version, replace 
     }
   
   *----
   * M1: get newest version of 'lianxh.ado' - from <lianxh.cn>
   capture ds title author catname
   if _rc==0{
     cap drop with_update
     qui gen with_update = 1 if strpos(title, "lianxh-update-v")
     qui sort with_update
     if ustrregexm(title, "lianxh-update-v(\d\.\d)"){
         local version_new = ustrregexs(1)
         if "`version_new'" != ""   local Got_hp_version = 1
         else                       local Got_hp_version = 0
         local IsUpdate = 0
         dis "hp: `version_new'"                  // test 
     }
     else{
         local Got_hp_version = 0
     }       
   }
   else{
       local Got_hp_version = 0
   }
   
   *----
   * M2: get newest version of 'lianxh.ado' - from <aliyuncs.com>
   *     file-lianxh / lianxh-ado / lianxh-version.txt 
     if "`Got_hp_version'" == "0"{
         local lxh_v "https://file-lianxh.oss-cn-shenzhen.aliyuncs.com/lianxh-ado/lianxh-version.txt"
         mata: a = cat("`lxh_v'")
         mata: v_new = ustrword(a[1,1], 1)
         mata: st_local("version_new", v_new)   
         if "`version_new'" != ""   local Got_hp_version = 1
         if "`version_new'" != ""   local Got_hp_version = 1
         else                       local Got_hp_version = 0
         local IsUpdate = 0     
     }

   * campare and update 
     if "`Got_hp_version'" == "1"{
         
         qui which_version lianxh 
         local version_local = s(version)
         
         if "`version_new'" != "`version_local'"{
             cap ssc install lianxh, replace 
             if _rc==0{
                 dis "lianxh.ado is updated: from 'v `version_local'' to 'v `version_new''"
                 local IsUpdate = 1 
                 local IsNew = 1
             }
             else{
                 local IsUpdate = 0
             }
         }
         else{
             local IsUpdate = 0
             local IsNew = 1
         }
     }
     
   * return value
     return scalar IsUpdate = `IsUpdate'
     return scalar IsNew    = `IsNew'
     return local  version_new   = "`version_new'"
     return local  version_local = "`version_local'"
     
end     



*-------------------------------------------------------------------------------
*--------------------------------- lianxh_br.ado -------------------------------

//*! version 1.2 6nov2023
/*
Examples

lianxh_br DID 
lianxh_br DID table
lianxh_br DID table RDD      // do not open in browser
lianxh_br DID table RDD, br  // open three new window in brower 
lianxh_br xxxyyzz            // found nothing, but do not report any error.
*/

// cap program drop lianxh_br   // delete later
program define   lianxh_br

syntax anything [, BRowse Maxkeyword(integer 2)]
    
    local key `"`anything'"'
    
    if "`maxkeywords'" == ""{
        local maxkeywords = 2
    }
    
  *-计算每个关键词的长度，将最大值记入暂元  maxlen 
    local maxlen = 0
    
    tokenize `key'
    
    local j = 1
    local       nof_words = wordcount(`"`key'"')
    while `j'<=`nof_words'{
        if ustrlen("``j''") > `maxlen'{
            local maxlen = ustrlen("``j''")
        }
        local j = `j' + 1
    }   

    local maxlen = `maxlen' + 8  // the length of Chinese Word is too short

    
  *-列示检索结果及链接     
    local hp_site "https://www.lianxh.cn/search.html?s="   
    local j = 1
    while `j'<=`nof_words'{
        local key "``j''"
        local url_key `"`hp_site'`key'"'
        
        mata: st_local("key_ascii", urlencode(`"`key'"'))  // URL --> percent-encoded ASCII format
        
        local url_key_ascii `"`hp_site'`key_ascii'"'
        * Format:    dis `"{browse "URL": Text}"'
        local key_dis: dis %`maxlen's "`key'"
        dis _col(1) "`key_dis': "`"{browse "`url_key_ascii'":`url_key'}"'
        if "`browse'" != "" | `nof_words' <= `maxkeywords'{
            view browse "`url_key_ascii'"   // view in default browser
        }
        local j = `j' + 1
    }

end 



*-------------------------------------------------------------------------------
*--------------------------------- lianxh_select.ado ---------------------------
// cap program drop lianxh_select  
program define   lianxh_select, rclass
version 14

syntax varname [, Select(string)]

//     cap qui ds `select'   //   
//     if _rc{
//         noi ds `select'
//     }
    
    if `"`select'"' == ""{
        exit 198
    }
    
    local sellist `"`select'"'
    local svar   "`varlist'"     // variable name to be searched
    
    local N0 = _N
    
    local Is_AND = (strpos(`"`sellist'"', "+")==0)
    

    tempvar Yes_select
    gen `Yes_select' = 0
 
 // select(A B):   keep if A | B 
    if strpos(`"`sellist'"', "+")==0{   
        foreach sword of local sellist{
           replace `Yes_select' = 1 if ustrregexm(`svar', "`sword'", 1) 
        }
        keep if `Yes_select' == 1
    }
    
 // select(A B +): keep if A & B  
    else{   
        local sellist = subinstr(`"`sellist'"', "+", " ", .)
        local nof_sellist = wordcount(`"`sellist'"')
        local sel_vlist ""
        local j = 1
        foreach sword of local sellist{
            tempvar sel_v
            gen `sel_v'`j' = ustrregexm(`svar', "`sword'", 1)
            local sel_vlist "`sel_vlist' `sel_v'`j'"
            local j = `j' + 1
        }       
        tempvar sel_v_sum
        egen `sel_v_sum' = rowtotal(`sel_vlist')
        keep if `sel_v_sum' == `nof_sellist'   
    }   
    
    local N1 = _N
    
  *-return values    
    return scalar nof_sel  = `N1'
    return scalar nof_drop = `=`N0' - `N1''
    

end   




*-------------------------------------------------------------------------------
*--------------------------------- lianxh_exclude.ado --------------------------

//*! version 1.0 26oct2023
//*  drop observations according keywords, with ' ' (blanks) means "OR", and '+' means "AND" 
//*  Usage: https://gitee.com/arlionn/stata/wikis/adofile/lianxh_exclude

// cap program drop lianxh_exclude  
program define lianxh_exclude, rclass
version 14

syntax varname, Exclude(string)

    local exlist `"`exclude'"'
    local svar   "`varlist'"     // variable name to be searched
    
    local N0 = _N
    
 // exclude(A B):   drop if A | B
    if strpos(`"`exlist'"', "+")==0{   
        foreach sword of local exlist{
           qui drop if ustrregexm(`svar', "`sword'", 1) 
        }
    }
 // exclude(A B +): drop if A & B  
    else{   
        local exlist = subinstr(`"`exlist'"', "+", " ", .)
        local nof_exlist = wordcount(`"`exlist'"')
        local ex_vlist ""
        local j = 1
        foreach sword of local exlist{
            tempvar ex_v
            gen `ex_v'`j' = ustrregexm(`svar', "`sword'", 1)
            local ex_vlist "`ex_vlist' `ex_v'`j'"
            local j = `j' + 1
        }       
        tempvar ex_v_sum
        egen `ex_v_sum' = rowtotal(`ex_vlist')
        qui drop if `ex_v_sum' == `nof_exlist'   
    }   
    
    local N1 = _N
    
    return scalar nof_drop = `=`N0' - `N1''

end   



*-------------------------------------------------------------------------------
*--------------------------------- lianxh_fields.ado ---------------------------
/* Examples

lianxh_fields a 
lianxh_fields a t k
lianxh_fields a t k, report

lianxh_fields a b           // error
lianxh_fields a t k url_ca  // error
lianxh_fields a t k id year // error
*/

// cap program drop lianxh_fields
program define lianxh_fields, rclass
version 14

syntax [anything] [, Gen(string) Report] 

if `"`anything'"' == ""{  // default: search within all 4 fields
    local fields "title author keyword"  // catname
    local user_list "`fields'"
    
    if "`gen'" == ""{
        cap drop svar
        egen svar = concat(`fields')  //  concatenates varlist  
    }
    else{
        cap drop `gen'
        noi egen `gen' = concat(`fields')
    }
    local nof_fields = 0
}

else{   // user specify

    local fields `"`anything'"'

    local nof_fields = wordcount(`"`fields'"')
  
  *-check nof_fields
    if `nof_fields'>5{
        dis as error "invalid -fields(keys)-. The max number of keys is 5."
        exit 198
    }
    
  *-check valist exit
    qui cap ds `fields'
    if _rc{
        cap noi ds `fields'  // display error message 'var not found'
        exit 111
    }
    
  *-limited within {t a k d c}  
    local accept_list "title author keyword catname description"
    unab  user_list: `fields'  // unabbreviate variable lists

    local invalid_list ""
    foreach v of local user_list{
        if strpos("`accept_list'", "`v'") == 0{
            local invalid_list "`invalid_list' `v'"
        }
    }
    local invalid_list = strltrim("`invalid_list'")
    if "`invalid_list'" != ""{
        dis as error `"'`invalid_list'' no allowed in option -fields()-."' 
        dis as error `"Valid variable should be selected among "' as text "{`accept_list'}" as error ", allowing abbreviations, i.e, " in text `"{t a k c d}."'
        exit 198
    }
}
    

*-generate combined variables to support 'Cross field query'
    if "`gen'" == ""{
        cap drop svar
        egen svar = concat(`fields')  //  concatenates varlist   
        label var svar `"concat(`fields')"'
    }
    else{
        cap drop `gen'
        noi egen `gen' = concat(`fields')
        label var `gen' `"concat(`fields')"'
    }
    
*-report 
    if "`report'" == "report"{
        dis as smcl `"'`user_list'' are combined into new variable {it:svar}"'
    }
    
*-return values
    unab _fields : `fields'
    return local fields "`_fields'"
    
    if "`gen'" == ""{
        return local svar "svar"
    }
    else{
        return local svar "`gen'"
    }


end 



*-------------------------------------------------------------------------------
*--------------------------------- lianxh_fromto.ado ---------------------------

// cap program drop lianxh_fromto             // delete later >>>>>>>
program define   lianxh_fromto, rclass

syntax anything [, Format(string) Myset(string) Display]

// Checking and setting options
 
    if "`format'" != "" & "`myset'" != ""{
        dis as error "Options conflict: either -format()- or -myset()-, not both."
        exit 198
    }

    if "`format'" == ""{
        local fdate "CCYY-NN-DD"                    // 2023-12-31, default
    }
    else{
        if `format' == 1  local fdate ""            // 31dec2023
        if `format' == 2  local fdate "CCYYNNDD"    // 20231231
        if `format' == 3  local fdate "CCYY.NN.DD"  // 2023.12.31
        if `format'<=0 | `format'>3{
            dis as error "Invalid format(#). # should be: 1 or 2 or 3"
            exit 198
        }
    }
    
    if "`myset'" != ""{
        local fdate "`myset'"
    }
    
//  regularize dates using regular expression   
    local fromto `anything'
    
    local fromto = subinstr("`fromto'", "," , " ", .)  // robust to "2022/01/1，2023-1-01"
    local fromto = subinstr("`fromto'", "，", " ", .)

    local nof_T = wordcount("`fromto'") // number of arguments  
    
    if `nof_T'>2{
        dis as error "invalid -fromto(time0 time1)-, only two arguments allowed"
    }
    else{
        tokenize "`fromto'"
        local j=1
        while "``j''" != ""{        
          //dis "`j'th: ``j''"                       // test
            local expYMD `"^(\d{4})([-\\/\.]?)(0?[1-9]|1[012])([-\\/\.]?)(0?[1-9]|[12][0-9]|3[01])$"'
            local expYM  `"^(\d{4})([-\\/\.]?)(0?[1-9]|1[012])$"'
            local expY   `"^((?:19|20)\d\d)$"'
          
          *-invalid time format   
            if !ustrregexm("``j''", `"`expYMD'"') & !ustrregexm("``j''", `"`expYM'"') & !ustrregexm("``j''", `"`expY'"'){           
                dis as error "invalid date format."
                dis as error "You should specify fromto(t0 t1), where -t0/t1- can be <2023-1-1>, <2023/1/1>, <2023-1> or <2022>"
                local valid = 0
                exit 198
            }
            
            
         // 2023-1 --> 2023-1-1 
         
            if ustrregexm("``j''", `"`expYM'"'){  
                local s1 = ustrregexs(1)
                local s2 = ustrregexs(2)
                local s3 = ustrregexs(3)
                if `j' == 1{      // 2022-1 --> 2022-1-01
                    local `j' = "`s1'" + "`s2'" + "`s3'" + "`s2'" + "01" 
                }
                if `j' == 2{      // 2023-1 --> 2023-2-01 
                    local `j' = "`s1'" + "`s2'" + "`=`s3'+1'" + "`s2'" + "01" 
                    local adjust2 = 1  // 2023-12-1 --> 2023-11-30
                }
                //--> ideas:
                //
                //  (\d{4})([-/]?)(\d{1,2})    |    2023-1
                //     $1     $2      $3
                //  $1$2$3$201                 |    2023-1-01     
            }
            
            
         // (2021 2022) --> (2022-1-1 2022-12-31)
         
            if ustrregexm("``j''", `"`expY'"'){
                local s1 = ustrregexs(1)
                if `j' == 1{      // 2022-1 --> 2022-1-01
                    local `j' = "`s1'" + "-01-01" 
                }
                if `j' == 2{      // 2023-1 --> 2023-2-01 
                    local `j' = "`s1'" + "-12-31" 
                } 
            }  
            
            local j = `j'+1
            
        }
    }
    
 // fromto(2023-1-1) ==> fromto(2023-1-1 curret_date)
    if `nof_T' == 1{   
        local time0 = date("`1'", "YMD")
        local time1 = date("`c(current_date)'", "DMY")
                                                 
    } 
    
    if `nof_T' == 2{   
        *tokenize "`fromto'"
        local t1 = date("`1'", "YMD") 
        if "`t1'" == "."{
            dis as error "Invalid time specification. Possible invalid example may be <2022-2-31>"
            local valid = 0
            exit 198
        }

        local t2 = date("`2'", "YMD")
        if "`t2'" == "."{
            dis as error "Invalid time specification. Possible invalid example may be <2022-2-31>"
            local valid = 0
            exit 198
        }        

        if "`adjust2'"=="1"{
            local t2 = `t2'-1    // backward one day
                                 // 2023-2-01 --> 2023-1-31 or 2023-3-01 --> 2023-2-28 
        }
        
      * resort the timeline 
      * e.g. 
      *      fromto(2023-10-20 2022-1-1) ==> fromto(2022-1-1 2023-10-20)
        local time0 = min(`t1', `t2')  
        local time1 = max(`t1', `t2')
    }


 // setting display format
 
    local date0 : dis %td`fdate' `time0'     // set display format `fdate'
    local date1 : dis %td`fdate' `time1'     // 
    
    local range1 "[`date0', `date1']"
    local range2 "(`date0', `date1')"
    
    
 // display option   
    if "`display'" != ""{
        dis "Range: `range1'"  
    }   
    
    
 // return values  
 
    return local  range2 = "`range2'"
    return local  range1 = "`range1'"    

    return scalar t1 = `time1'
    return scalar t0 = `time0'    
    return local  date1 = "`date1'"
    return local  date0 = "`date0'"
 
end 



*==============================================================================*	
****Sub programs****
// cap program drop lianxh_links
program define lianxh_links
version 8

	  dis    in w _col(20) _n _skip(25) "Hello, Stata!" _n
	  local c1 = 15    // 起始位置
	  local skip = 20  // 间距
	  local G = 6      // 每行个数
	  local cF = `skip'*`G'
	  forvalues i = 2/`G'{
	     local c`i' = `c1' + `skip'*`=`i'-1'
		 *dis "`c`i''"
	  }
	  

	  
	  dis in w " Stata官方: "  ///
		 _col(`c1') `"{browse "http://www.stata.com":`Lbb'Stata.com`Rbb'}"' ///
		 _col(`c2') `"{browse "http://www.stata.com/support/faqs/":`Lbb'FAQs`Rbb'}"' ///
		 _col(`c3') `"{browse "https://blog.stata.com/":`Lbb'Blogs`Rbb'}"' 
      dis in w  _col(11)  ///			 
		 _col(`c1') `"{browse "https://www.stata.com/links/resources-for-learning-stata/":`Lbb'Resources`Rbb'}"' ///
		 _col(`c2') `"{browse "https://www.lianxh.cn/details/310.html":`Lbb'Stata小抄`Rbb'}"' ///		 
		 _col(`c3') `"{browse "https://www.stata.com/links/examples-and-datasets/":`Lbb'Textbook Example`Rbb'}"' ///
		 _n

	  dis in w " Stata资源: "  ///	
		 _col(`c1') `"{browse "https://www.lianxh.cn/news/a630af7e186a2.html":`Lbb'书单`Rbb'}"' ///
		 _col(`c2') `"{browse "https://www.lianxh.cn/news/790a2c4103539.html":`Lbb'资源汇总`Rbb'}"' ///
		 _col(`c3') `"{browse "https://www.lianxh.cn/news/f2ad8bf464575.html":`Lbb'Stata16手册`Rbb'}"' 
      dis in w  _col(11)  ///			 
		 _col(`c1') `"{browse "https://www.lianxh.cn/news/12ffe67d8d8fb.html":`Lbb'Stata Journal`Rbb'}"' ///
		 _col(`c3') `"{browse "https://www.lianxh.cn/news/9e917d856a654.html":`Lbb'Links/Tools`Rbb'}"' ///
		 _n
		  	  
	  dis in w " 提问交流: "  ///
		 _col(`c1') `"{browse "http://www.statalist.com":`Lbb'Stata List`Rbb'}"'      ///
		 _col(`c2') `"{browse "https://gitee.com/arlionn/WD":`Lbb'连享会FAQs`Rbb'}"'  ///
		 _col(`c3') `"{browse "https://bbs.pinggu.org/forum-67-1.html":`Lbb'经管之家`Rbb'}"'  
      dis in w  _col(11)  ///			 
		 _col(`c1') `"{browse "https://stackoverflow.com":`Lbb'Stack Overflow`Rbb'}"' ///
		 _n
	  
	  dis in w " 推文视频: "  /// 
	     _col(`c1') `"{browse "https://www.lianxh.cn/blogs/all.html":`Lbb'连享会推文`Rbb'}"' ///
		 _col(`c2') `"{browse "https://www.zhihu.com/people/arlionn/":`Lbb'知乎`Rbb'}"'  ///
		 _col(`c3') `"{browse "https://gitee.com/arlionn":`Lbb'码云仓库`Rbb'}"' 
	  dis in w  _col(11)  ///		 
		 _col(`c1') `"{browse "https://www.lianxh.cn/news/46917f1076104.html":`Lbb'计量专题`Rbb'}"' ///
		 _col(`c2') `"{browse "https://lianxh-class.cn/":`Lbb'视频直播`Rbb'}"'  ///
		 _col(`c3') `"{browse "https://www.techtips.surveydesign.com.au/blog/categories/stata":`Lbb'Tech-Tips`Rbb'}"'  ///
		 _n

	  dis in w " 在线课程: "  ///
		 _col(`c1') `"{browse "https://stats.idre.ucla.edu/stata/":`Lbb'UCLA`Rbb'}"' ///
		 _col(`c2') `"{browse "http://www.princeton.edu/~otorres/Stata/":`Lbb'Princeton`Rbb'}"' ///
		 _col(`c3') `"{browse "http://wlm.userweb.mwn.de/Stata/":`Lbb'Online Stata`Rbb'}"'
	  dis in w  _col(11)  ///	
		 _col(`c1') `"{browse "https://www.lianxh.cn/details/1095.html":`Lbb'Stata 33 讲`Rbb'}"' ///	  
		 _col(`c3') `"{browse "https://gitee.com/arlionn/PanelData":`Lbb'面板数据模型`Rbb'}"' ///
		 _n
		 
	  dis in w " 学术搜索: "  /// 
		 _col(`c1') `"{browse "https://scholar.google.com/":`Lbb'Google学术`Rbb'}"'  ///
		 _col(`c2') `"{browse "https://academic.microsoft.com/home":`Lbb'微软学术`Rbb'}"'  ///		  
		 _col(`c3') `"{browse "http://scholar.chongbuluo.com/":`Lbb'学术搜索`Rbb'}"'  
	  dis in w  _col(11)  ///
		 _col(`c1') `"{browse "http://scholar.cnki.net/":`Lbb'CNKI`Rbb'}"' ///	
		 _col(`c2') `"{browse "http://xueshu.baidu.com/":`Lbb'百度学术`Rbb'}"' ///
		 _col(`c3') `"{browse "https://sci-hub.ren":`Lbb'SCI-HUB`Rbb'}"' ///
		 _n
		  
	  dis in w " 论文重现: "  ///	  		  
	     _col(`c1') `"{browse "https://www.lianxh.cn/news/e87e5976686d5.html":`Lbb'论文重现网站`Rbb'}"' ///
		 _col(`c2') `"{browse "https://dataverse.harvard.edu/dataverse/harvard?q=stata":`Lbb'Harvard dataverse`Rbb'}"' ///
		 _col(`c3') `"{browse "http://replication.uni-goettingen.de/wiki/index.php/Main_Page":`Lbb'Replication WIKI`Rbb'}"' 
	  dis in w  _col(11)  ///
	     _col(`c1') `"{browse "https://www.icpsr.umich.edu/icpsrweb/":`Lbb'ICPSR`Rbb'}"' ///
		 _col(`c2') `"{browse "https://data.mendeley.com/":`Lbb'Mendeley`Rbb'}"' ///
		 _col(`c3') `"{browse "https://github.com/search?utf8=%E2%9C%93&q=stata&type=":`Lbb'Github`Rbb'}"' 
	  dis in w  _col(11)  ///
	     _col(`c1') `"{browse "https://www.aeaweb.org/journals":`Lbb'AEA`Rbb'}"' ///
		 _col(`c2') `"{browse "http://jfe.rochester.edu/data.htm":`Lbb'JFE`Rbb'}"' ///
		 _col(`c3') `"{browse "http://economics.mit.edu/faculty/acemoglu/data":`Lbb'Acemoglu`Rbb'}"' ///
		 _n		 
		  
	  dis in w _col(15) ///
		  as smcl `"{stata "ssc install lianxh, replace": ~~更新~~}"' ///
		  _skip(15)     ///
		  as smcl `"{browse "https://www.lianxh.cn/blogs/all.html":-查看分类推文-}"'
		  
end
   	
