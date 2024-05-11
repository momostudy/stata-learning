*! -----------------------------------------------------------------------------------------------------------------------------
*! vs2.1 Lars Aengquist , 2011-12-22 (adding 'subs' and 'oldstx' options, etc.)
*! vs2.0 Lars Aengquist , 2011-07-19
*! vs1.0 Lars Aengquist , 2011-06-10 (removedots.ado)
*!
*! program renfiles
*!
*!	syntax	[anything]	[,	folder(string) match(string) subs(string) insign(string) outsign(string) erase oldstx]			
*!
*! -----------------------------------------------------------------------------------------------------------------------------

program renfiles

	syntax	[anything]	[,	folder(string) match(string) subs(string) insign(string) outsign(string) erase oldstx]			
					

   version 9


   * - Defaults for folder, (file) matching expression, and sign-replacement.

   if "`folder'"=="" {
      local folder="."
   }

   if "`match'"=="" {
      local match="*"
   }

   if "`insign'"=="" {
      local insign="."
   }

   if "`outsign'"=="" {
      local outsign="_"
   }
   else if "`outsign'"=="null" {
      local outsign=""
   }  


   * - Put matched file, in selected folder, in local macro (syntax-dependent).

   if "`oldstx'"=="" {
      local list : dir "`folder'" files "`match'", respectcase
   }
   else {
      local list : dir "`folder'" files "`match'"
   }

   * - Looping over matched files.

   foreach fname of local list {

      * - How many insigns to replace?

      local n1=length("`fname'")
      local n2=length(subinstr("`fname'","`insign'","",.))


      if "`insign'"!="." {
         local nbr=`n1'-`n2'
      }
      else {         
         local nbr=`n1'-`n2'-1
      }

      * - New filename.

      local outname=subinstr("`fname'","`insign'","`outsign'",`nbr')


      * - Create new file with new filename.
 
      capture copy "`folder'\\`fname'" "`folder'\\`outname'" , replace


      * - If filename updated - and erase-option selected - remove original file.

      if `nbr'>0 {
         capture `erase' "`folder'\\`fname'"
      }

   }


   * - If option selected, loop over possible subfolders (syntax-dependent).

   if "`subs'"!="" {

      if "`oldstx'"=="" {
         local subdirs: dir "`folder'" dirs "`subs'", respectcase
      }
      else{
         local subdirs: dir "`folder'" dirs "`subs'"
      }

      foreach subdir of local subdirs {

         * - Recursive call...

         if "`outsign'"=="" {
            local outsign="null"
         }

	 renfiles , folder("`folder'\\`subdir'") match("`match'") subs("`subs'") insign("`insign'") outsign("`outsign'") `erase' `oldstx'	
      }
   }


end



