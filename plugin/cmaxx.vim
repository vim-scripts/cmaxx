"
"  Maintainer: Markus (MAxx) Trenkwalder
"     Version: 1.0.2
"     Summary: Provides a collection of macros and functions for programming
"              C/C++
" Last Change: $Date: 2006/04/26 11:48:50 $
" Revision:    $Revision: 1.50 $
"
" $Id: cmaxx.vim,v 1.50 2006/04/26 11:48:50 maxx Exp $


" ===========================================================================
" Documentation:
" ===========================================================================
" {{{ Documentation
"
"
" {{{ Feature Requests 
" Feature Requests:
" =================
"
" - expandFunction only works in one line function definitions
"   -> This could be solved using a mapping for the visual mode.
" - function for scanning a function definition and adding doxygen comments
"   for all parameters and the return value
"   -> Possible solution: using a spezial "#ARGUMENT#" macro.
" - Indent calculation: take "tabstop" and "softtabstop" in account for
"   the calculation of indent in CMAxx_doExpand.
" - "Tab completion": in insert mode press <TAB> to complete to either a
"   reserved word, a template or a word previousely typed (like in <CTRL-N>)
"   -> This inplies that the script knows about all existing templates.
" - The possibility of comments in the templates.
"   -> A possible comment character could be a double "b:CMAxx_Delimiter".
" - A selection of some default values for a macro.
" - Add a syntax script for the template files.
" }}}
"
"
" {{{ Implemented Features 
" Implemented Features:
" =====================
"
" - substitution works on whole lines, what about single words in long lines
"   (problem: "read" inserts only complete lines so we have to find a
"    mechanism to read in a buffer
"   => done by splitting the line in the part befor and the one after the
"      cursor (i.e. "first" and "last"). The whole line is deleted and the
"      tempalate is inserted. After that "first" is inserted at the
"      beginning of the first line and "last" at the end of the last line of
"      the template.
" - Ability to define variables (using ":let") of which the values are used
"   to substitute the macros in the templates.
"   => done by making the question for a macro value dependent from the
"      existance of a corresponding variable (function CMAxx_doExpand).
" - In visual mode cut the selection and insert it in the template at the
"   cursor position.
"   => Implemented by the function CMAxx_expandSelection()
" - Configurable macros in templates, compareable to the variable
"   substitution in bash scripts, i.e. #MYMACRO:uc:s/\s//g# where a ':'
"   donates a postprocessing rule for the macros value.
"   What the hack does the "uc" mean?
"   -> We do need some setting which defines the meaning of the string after
"      the second ":". In this light "c" could mean "command" and "u" could
"      be "update", but this could become to complicated. In the first
"      version only three different commands are implemented:
"      "r") interpret string as regular expression,
"      "a") append string and
"      "p") prepend string.
"   => Done! CMAxx_Substitute rewritten, CMAxx_substSpecial,
"      CMAxx_findMacro and CMAxx_substSpecial added	.	.	.	.	.	.	.	.	.	060326
" - Possibility to turn off the mappings.
"   => Added two variables to turn them off: "g:CMAxx_NoExpansionKey" and
"      "g:CMAxx_NoMappings".	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	060426
" }}}
"
"
" {{{ Bugs 
" BUGS:
" =====
"
" x one character macros do not work	.	.	.	.	.	.	.	.	.	.	.	.	.	fixed 040616
" x function mapping: '~' must be escaped
"   => first and last line part reworked	.	.	.	.	.	.	.	.	.	.	.	fixed 040626
" x vim mapping does not work properly	.	.	.	.	.	.	.	.	.	.	.	.	fixed 040626
" x Script kills the default (@") buffer
"   => Fixed by saving the @" register to @z. In This way the
"      less important register @z will be destroyed	.	.	.	.	.	.	fixed alta
" x Functions including '&' where not expanded correctly
"   => Fixed by introducing function CMaxx_escape	.	.	.	.	.	.	.	fixed 040705
" x A template at the character before the last character does
"   not expand correctly; i.e. it expands past the last
"   character.
"   => fixed by the expand mode argument in CMAxx_doExpand	.	.	fixed 060218
" x Two macros on one line will not be expanded
"   => fixed bug in CMAxx_scanMacro	.	.	.	.	.	.	.	.	.	.	.	.	.	.	fixed 050416
" x Two macros in one line where the first is the #CURSOR#
"   macro do not expand correctly (hint: here we have a problem
"   with the #CURSOR# macro, i.e. we first have to substitute
"   it).
"   => fixed by substituting the #CURSOR# macro with some
"      internal marker	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	fixed 050417
" x A Template does not expand correctly on the very FIRST
"   character of a line.
"   => this was a problem regarding the position of expansion
"      in CMAxx_doExpand	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	fixed 060218
" x A Template does not expand correctly on the very LAST
"   character of a line (this only happens in visual mode).
"   => automatically fixed by adopting the code in
"      CMAxx_expandSelection to the new behaviour of
"      CMAxx_doExpand	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	fixed 060218
" x Visual expansion does not work correctly at the first or
"   last character of a line.
"   => see above	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	fixed 060218
" x If the template could not be found, restore the word used
"   for the template.
"   => done by adding a return value in CMAxx_doExpand and
"      testting it in the other functions	.	.	.	.	.	.	.	.	.	.	.	fixed 060218
" - If the selection ends at the beforelast column, the
"   template is expanded at the wrong place (ie. after the last
"   character).
" x When showing the settings buffer local variables could not
"   be found.
"   => This is because the buffer is created before the
"      variables are used.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	fixed 060206
" x In some cases the cursor substitute is not replaced (thanx
"   to Igor Prischepoff).
"   => Now the cursor is set to the begining of the search ares
"      before starting the search.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	fixed 060426
" x When b:CMAxx_ConvertPrefix is not set, the local variable
"   inent is not set too.
"   => Fixed by checking the existence of this variable.	.	.	.	fixed 060426
" x The same as with b:CMAxx_ConvertPrefix may have happend with
"   b:CMAxx_Author and b:CMAxx_Version.
"   => Fixed by checking the existance of the variable first.	.	fixed 060426
" }}}
"
"
" {{{ Common TODOS 
" Common TODOs:
" =============
" x The words "template" and "macro" are sometimes mixed up,
"   i.e. rework comments	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	done 050109
" x Documentation	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	done 050109
" x If no cursor position could be found in the template, do
"   something intelligente with the cursor.
"   => the cursor is now set to the position, where it was
"      before the expansion	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	done 060209
" x Using '#' as delimiter for macros is bad in C/C++ files!
"   -> Possible character would be '@'.
"   -> Done by adding "b:CMAxx_Delimiter"	.	.	.	.	.	.	.	.	.	.	.	done 060326
" x Fix the local/global issue (this does not only regard
"   variables but also the loading of local configs).
"   => Seems to be fixed by making all user settings buffer
"      bound and adding event handlers for BufRead, BufNew and
"      VimEnter	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	done 060206
" x Document the macro value variables.	.	.	.	.	.	.	.	.	.	.	.	.	done 060416
" x Support Vim 6.x again.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	.	done 060425
" }}}
"
"
" {{{ Version Hisrtory
" Version History:
" ================
"
" 0.1.0	01.01.2004	Initial Version for first testings
" 0.2.0	05.07.2004	Several bugs fixed
" 0.3.0	10.01.2005	New features:
"										- there are now two locations for templates: a
"										  global folder (defined by g:CMAxx_TemplateDir)
"										  and a folder local to a project (defined by
"										  b:CMAxx_LocalTemplates);
"										- In each of these directories there reside several
"										  subdirectories: a "before" folder is searched
"										  first for templates; after that the script looks
"										  in the folder specific to the filetype and last
"										  the root folder specified by the two variables
"										  is visited.
"										- Values for macros can now be defined using ":let".
"										  The variables has to be defined globally (ie.
"										  by using "g:") and it's name is the one of the
"										  macro.
"										Fixed bugs:
"										- Indent is inserted only on none empty lines.
"										  Added the script documentation.
" 0.9.0	31.01.2005	Time to go online, but first we let test it. A
"										extra feature request was implemented for this:
"										- a new function can handle visual selections, the
"										  function either takes no argument, it than asks
"										  for the template name, or it takes the template
"										  name as an argument.
" 0.9.1	16.02.2006	New setting "CMAxx_ConvertPrefix": should the
"										prefix be conferted into spaces?
" 0.9.2 17.02.2006	New Feature:
"										- the cursor position is restored after expansion if
"										  #CURSOR# could not be found in the template (in visual
"										  mode it is set to the end of the selection).
"										Fixed bugs:
"										- undiscovered bug in CMAxx_expandTemplate: word type
"										  was not detected correctly and in consequence the
"										  template was not expanded at the coorect place.
"										- undiscovered bug in CMAxx_expandSelection: default
"										  buffer content was not restored after expansion.
"										- Refactored the code regarding the position where the
"										  template will be expanded.
" 0.9.8 26.03.2006	New Feature:
"										- The delimiter can now be configured with the variable
"										  "b:CMAxx_Delimiter".
"										- Changed the default delimiter to "@".
"										- Macros can now have a command after the name. This can
"										  be "p", "a" or "s". The command is followed by the
"										  data for the command.
" 0.9.9 15.04.2006	New Features:
"										- vim documentation added.
"										Other changes:
"										- buffer specific "CMAxx_Delimiter" made global.
"										- global "CMAxx_ConvertPrefix" made buffer specific.
" 1.0.0 21.04.2006	Fixed bugs:
"										- Fixed the loading of user defined and local config
"										  files (an issue with :e may be open, we will see).
"										- Fixed the settings dialog to show the right values.
"										Other changes:
"										- Added a version check (this script works for vim-7.0aa
"										  and higher only.
" 1.0.1 25.04.2006	Other changes:
"										- Made it work with 6.x again.
" 1.0.2 26.04.2006	Fixed bugs:
"										- Corrected the usage or the "search()" function by
"										  setting the cursor first to the begin of the search.
"										- When "b:CMAxx_ConvertPrefix" is not set, the local
"										  variable "indent" is not set too.
"										- Fixed the same issue as with "b:CMAxx_ConvertPrefix"
"										  for "b:CMAxx_Author" and "b:CMAxx_Version" too.
"										Other changes:
"										- "b:CMAxx_ConvertPrefix" is now set if it could not be
"										  found.
"										- Corrected the settings buffer content.
"										New features:
"										- Two variables "g:CMAxx_NoExpansionKey" and
"										  "g:CMAxx_NoMappings" now controll the creation of the
"										  default mappings.
" }}}
"
" }}}


" ===========================================================================
" Settings:
" ===========================================================================
au BufRead,BufNew,VimEnter	*
	\ let b:CMAxx_Author         = ""
au BufRead,BufNew,VimEnter	*
	\ let b:CMAxx_Version        = "0.0.0"
au BufRead,BufNew,VimEnter	*
	\ let b:CMAxx_LocalTemplates = "."
au BufRead,BufNew,VimEnter	*
	\ let b:CMAxx_ConvertPrefix  = 1

let g:CMAxx_Delimiter          = "@"


" ===========================================================================
" Mappings:
" ===========================================================================
" {{{
if !exists("g:CMAxx_NoExpansionKey")
	" Insert Template:
	vnoremap <F6> :<C-U>call CMAxx_expandSelection()<cr>
	nmap <F6> :call CMAxx_expandTemplate()<cr>
	imap <F6> <esc>:call CMAxx_expandTemplate(1)<cr>
endif

if !exists("g:CMAxx_NoMappings")
	" Function:
	nmap <leader>f :call CMAxx_expandFunction('func')<cr>

	" Class:
	nmap <leader>c :call CMAxx_expandFunction('class')<cr>

	" Header:
	nmap <leader>h :call CMAxx_doExpand('header')<cr>

	" File Documentation:
	nmap <leader>F ggO<esc>:call CMAxx_doExpand('file')<cr>

	" Vim Scanline:
	nmap <leader>v Go<esc>:call CMAxx_doExpand('vim')<cr>

	" Doxygen Documentation:
	vnoremap <leader>d :<C-U>call CMAxx_expandSelection("dox")<cr>

	" Settings:
	nmap <leader>s :call CMAxx_ShowSettings()<cr>

	" List Templates:
	nmap <leader>l :call CMAxx_listFiles()<cr>
endif
" }}}


" ===========================================================================
" Local Variables:
" ===========================================================================
" {{{
let s:CMAxx_Function         = ''
let s:CMAxx_HomeConfig1      = $HOME.'/.cmaxxrc'
let s:CMAxx_HomeConfig2      = $HOME.'/_cmaxxrc'
let s:CMAxx_LocalConfig1     = '.cmaxxrc'
let s:CMAxx_LocalConfig2     = '_cmaxxrc'
let s:CMAxx_LocalConfig3     = 'cmaxxrc'
let s:CMAxx_CURSORSubstitute = '__CURSOR__'
" }}}


" ===========================================================================
" Syntax Highlighting:
" ===========================================================================
" {{{
syn match helpOption "'\([a-z]:\)\=[a-zA-Z_]\+'"
" }}}


" ===========================================================================
" Get Local Config:
" ===========================================================================
" {{{
au BufRead,BufNew,VimEnter *
	\ if filereadable(s:CMAxx_HomeConfig1) |
		\ exec ":so ".s:CMAxx_HomeConfig1 | endif
if filereadable(s:CMAxx_HomeConfig1)
	exec ":so ".s:CMAxx_HomeConfig1
endif
au BufRead,BufNew,VimEnter *
	\ if filereadable(s:CMAxx_HomeConfig2) |
		\ exec ":so ".s:CMAxx_HomeConfig2 | endif
if filereadable(s:CMAxx_HomeConfig2)
	exec ":so ".s:CMAxx_HomeConfig2
endif
au BufRead,BufNew,VimEnter *
	\ if filereadable(s:CMAxx_LocalConfig1) |
		\ exec ":so ".s:CMAxx_LocalConfig1 | endif
if filereadable(s:CMAxx_LocalConfig1)
	exec ":so ".s:CMAxx_LocalConfig1
endif
au BufRead,BufNew,VimEnter *
	\ if filereadable(s:CMAxx_LocalConfig2) |
		\ exec ":so ".s:CMAxx_LocalConfig2 | endif
if filereadable(s:CMAxx_LocalConfig2)
	exec ":so ".s:CMAxx_LocalConfig2
endif
au BufRead,BufNew,VimEnter *
	\ if filereadable(s:CMAxx_LocalConfig3) |
		\ exec ":so ".s:CMAxx_LocalConfig3 | endif
if filereadable(s:CMAxx_LocalConfig3)
	exec ":so ".s:CMAxx_LocalConfig3
endif
" }}}


" ===========================================================================
" Spezial Variables:
"		g:CMAxx_TemplateDir
" ===========================================================================
" {{{
if !exists("g:CMAxx_TemplateDir")
	echohl ErrorMsg
	echo "Variable 'g:CMAxx_TemplateDir' not set!"
	if $OS =~ "Windows"
		echo "Setting it to '".$HOME."vimfiles\\templates'"
		let g:CMAxx_TemplateDir = $HOME."vimfiles\\templates"
		echo "\nPlease run '<leader>s' to open the settings"
		echo "buffer and write the content to '~\\_cmaxxrc'."
	elseif $OSTYPE =~ "linux"
		echo "Setting it to '".$HOME.".vim/templates'"
		let g:CMAxx_TemplateDir = $HOME.".vim/templates"
		echo "\nPlease run '<leader>s' to open the settings"
		echo "buffer and write the content to '~/.cmaxxrc'."
	else
		echo "OS type not determined: defaulting to '".$HOME.".vim/templates'"
		let g:CMAxx_TemplateDir = $HOME.".vim/templates"
		echo "\nPlease run '<leader>s' to open the settings"
		echo "buffer and write the content to '~/.cmaxxrc'."
	endif
	echohl None
	let s:CMAxx_TemplateDirNotSet = 1
else
	let s:CMAxx_TemplateDirNotSet = 0
endif
" }}}


" ===========================================================================
" Functions:
" ===========================================================================
" {{{


" Function:  Reinterprets the "s///" command and applies it on the value in
"            <ssval>.
" Arguments: <ssval>   The value to work on.
"            <sssubst> The substitution command.
" Return:    The value after the substitution.
" {{{ CMAxx_substSpecial( ssval, sssubst )
fun! CMAxx_substSpecial( ssval, sssubst )
	if a:sssubst[0] != 's' || a:sssubst[1] != '/'
		return a:ssval
	endif

	let pos = stridx(a:sssubst, '/', 2)
	if pos == -1
		return a:ssval
	endif
	let pat = strpart(a:sssubst, 2, pos-2)
	let pos2 = stridx(a:sssubst, '/', pos+1)
	if pos2 == -1
		return a:ssval
	endif
	let sub = strpart(a:sssubst, pos+1, pos2-pos-1)
	let flags = strpart(a:sssubst, pos2+1)

	return substitute(a:ssval, pat, sub, flags)
endfun
" }}} CMAxx_substSpecial( ssval, sssubst )


" Function:  Searches for a macro.
" Arguments: <smacro> The macro to be searched. If an empty string is given,
"                     the first string of the form
"                     "<del>\([^:]+\)\(:+*\)<del>" is searched.
"            <a:1>    Start position of the search. If omitted, the function
"                     searches from the gebinning of the text.
"            <a:2>    End position of the search. If omitted, the function
"                     searches to the end of the text.
" Return:    The line number of the first match.
" {{{ CMAxx_findMacro( smacro, ... )
fun! CMAxx_findMacro( smacro, ... )
	if a:0 > 0
		call cursor(a:1, 0)
	endif
	let line = search(a:smacro)
	let s:macro_name = substitute(getline(line), '.*'.a:smacro.'.*', "\\1", "")
	if line == 0
		return 0
	endif

	if a:0 > 0 && line < a:1
		return 0
	endif
	if a:0 > 1 && line > a:2
		return 0
	endif

	return line
endfun
" }}} CMAxx_findMacro( smacro, ... )


" Function:  Expands the <name> argument to a search string and cals
"            CMAxx_findMacro with this search string.
" Arguments: <name>  The macro name part of the search string.
"            <a:1>    Start position of the search. If omitted, the function
"                     searches from the gebinning of the text.
"            <a:2>    End position of the search. If omitted, the function
"                     searches to the end of the text.
" Return:    The line number of the first match.
" {{{ CMAxx_findMacroName( name, ... )
fun! CMAxx_findMacroName( name, ... )
	let pattern = g:CMAxx_Delimiter.'\([^:'.g:CMAxx_Delimiter.']\+\)\(:[^:'.
		\ g:CMAxx_Delimiter.']\+\)\='.g:CMAxx_Delimiter
	if strlen(a:name) > 0
		let pattern = g:CMAxx_Delimiter.'\('.a:name.'\)\(:[^:'.
			\ g:CMAxx_Delimiter.']\+\)\='.g:CMAxx_Delimiter
	endif


	let line = CMAxx_findMacro(pattern)

	if a:0 > 0 && line < a:1
		return 0
	endif
	if a:0 > 1 && line > a:2
		return 0
	endif

	return line
endfun
" }}} CMAxx_findMacroName( name, ... )


" Function:  Replaces the macro applied by a:smac with the user defined
"            value in a:scal.
" Arguments: <sline> The line number where the macro should be replaced.
"            <smac>  The macro name.
"            <sval>  The value with which the macro should be replaced.
" Return:    1 if the replacememt was successfull and 0 otherwise.
" {{{ CMAxx_substMacro( sline, smac, sval )
fun! CMAxx_substMacro( sline, smac, sval )
	let searchstr = g:CMAxx_Delimiter.a:smac.'\(:[^'.g:CMAxx_Delimiter.
		\ ']\+\)\='.g:CMAxx_Delimiter
	let match = matchstr(getline(a:sline), searchstr)
	if match == ""
		return 0
	endif

	let cmdsearch =
		\ ':[^:'.g:CMAxx_Delimiter.']\+:[^:'.g:CMAxx_Delimiter.']\+'.
		\ g:CMAxx_Delimiter
	let typecmd = matchstr(match, cmdsearch)
	let val = a:sval
	if typecmd != ""
		let type = matchstr(typecmd, ':[^:]:')
		let type = strpart(type, 1, strlen(type)-2)
		let cmd = matchstr(typecmd, ':[^:'.g:CMAxx_Delimiter.']\+'.
			\ g:CMAxx_Delimiter)
		let cmd = strpart(cmd, 1, strlen(cmd)-2)

		if type == 'a'
			let val = a:sval . cmd
		elseif type == 'p'
			let val = cmd . a:sval
		elseif type == 's'
			let val = CMAxx_substSpecial(val, cmd)
		endif
	endif

	let substcmd = ":".a:sline.",".a:sline.'s/'.searchstr.'/'.val.'/'
	silent exec substcmd
	return 1
endfun
" }}} CMAxx_substMacro( sline, smac, sval )


" Function:  replaces all occurences of a macro with it's value.
"            The 
" Arguments: <pbeg>  start line of replacement
"            <pend>  last line of replacement
"            <macro> the "macro" to replace
"            <value> the replacement
" TODO:      Why did this function do the substitution in a while loop?
"            -> Because a search would end in an error if it files.
" {{{ CMAxx_Substitute ( pbeg, pend, macro, value )
fun! CMAxx_Substitute ( pbeg, pend, macro, value )
	let searchstr = g:CMAxx_Delimiter.a:macro.'\(:.*\)\='.g:CMAxx_Delimiter
	let linenum = CMAxx_findMacro(searchstr, a:pbeg, a:pend)
	" if search did fail, the line number is 0 and therefor out of bound.
	while linenum != 0
		if CMAxx_substMacro(linenum, a:macro, a:value) == 1
			let linenum = CMAxx_findMacro(searchstr, a:pbeg, a:pend)
		else
			let linenum = 0
		endif
	endwhile
endfun
" }}}  CMAxx_Substitute (pbeg, pend, macro, value)


" Function:  scanns the inserted template and sets the cursor to the first
"            character of the '#CURSOR#' macro.
" TODO:      Should this function substitute all occurencies of the cursor
"            macro.
" {{{ CMAxx_setCursor ( strt, stp )
fun! CMAxx_setCursor ( strt, stp, pos )
	call cursor(a:strt, 0)
	let foundl = search(s:CMAxx_CURSORSubstitute)
	if a:strt <= foundl && foundl <= a:stp
		let foundc = match(getline(foundl), s:CMAxx_CURSORSubstitute)
		silent exec ":".foundl.",".foundl."s/".s:CMAxx_CURSORSubstitute."//"
		call cursor(foundl, foundc)
	endif
endfun
" }}} CMAxx_setCursor ( strt, stp )


" Function:  Executes several substitutions on <mysrc>.
" Arguments: <mysrc> the text to be excaped.
" {{{ CMAxx_escape( mysrc )
fun! CMAxx_escape( mysrc )
	let result = escape(a:mysrc, '~&/{[\')
	"let result = escape(result, '/')
	"let result = escape(result, '~')
	"let result = escape(result, '&')
	return result
endfun
" }}} CMAxx_escape(mysrc)


" Function:  nearly same as strpart, but does also some escaping. I.e.: the
"            function takes <len> characters from <src> beginning at
"            <start>, escapes them and returns the resulting string.
" Arguments: <src>   the source string
"            <start> start position in the string
"            <len>   number of characters to put from <src>
" {{{ CMAxx_strpart( src, start, len )
fun! CMAxx_strpart( src, start, len )
	let result = strpart(a:src, a:start, a:len)
	let result = CMAxx_escape(result)
	return result
endfun
" }}} CMAxx_strpart(src, start, len)


" Function:  Does the actual searching which is described in CMAxx_findFile.
"            This function searches first in the "before" folder, after
"            this the filetype-folder is looked up and at least the
"            function tries to finde the template in the root folder
"            given by <basedir>.
" Arguments: <basedir>  the basic folder in which the function should
"                       search
"            <tmplname> the name of the template to search for
" Result:    returns the full path or an empty string otherwise
" {{{ CMAxx_doFindFile( basedir, tmplname )
fun! CMAxx_doFindFile( basedir, tmplname )
	" First we take a look in the global before folder:
	let thefile = a:basedir.'/before/'.a:tmplname.'.tmpl'
	if filereadable(expand(thefile))
		return thefile
	endif
	" After this we check the filetype folder:
	if &filetype != ""
		let thefile = a:basedir.'/'.&filetype.'/'.a:tmplname.'.tmpl'
		if filereadable(expand(thefile))
			return thefile
		endif
	endif
	" And at least we look in the template root:
	let thefile = a:basedir.'/'.a:tmplname.'.tmpl'
	if filereadable(expand(thefile))
		return thefile
	endif
	return ""
endfun
" }}} CMAxx_doFindFile(basedir, tmplname)


" Function:  Tries to find the file representing the template <tmpl>. First
"            the directories holding the templates local to the project are
"            looked up and after this the global directories are visited.
" Arguments: <tmpl>  the name of the template.
" Result:    returns the full path of the template file.
" {{{ CMaxx_findFile( tmpl )
fun! CMAxx_findFile( tmpl )
	" First we search the local template folder.
	if exists("b:CMAxx_LocalTemplates")
		let result = CMAxx_doFindFile(b:CMAxx_LocalTemplates, a:tmpl)
		if result != ""
			return result
		endif
	endif
	" Then we search the global template folder
	if exists("g:CMAxx_TemplateDir")
		return CMAxx_doFindFile(g:CMAxx_TemplateDir, a:tmpl)
	else
		echohl ErrorMsg
		echo "Variable 'g:CMAxx_TemplateDir' not set!"
		echohl None
		return ""
	endif
endfun
" }}} CMaxx_findFile(tmpl)


" Function:  reads template from file. The filename expands to <arg>.tmpl
"            The function assumes that the cursor is at the position where
"            the template should be expanded. The extra argument controlls
"            the position of the expansion relative to the cursor.
" Arguments: <arg> is part of the filename
"            ...   The first extra argument is interpreted as an indicator
"                  for where to expand the template relative to the cursor.
"                  No extra argument or the 0 (zero) expands after the
"                  cursor position. 1 expands before the cursor.
"            ...   The second argument, if set specifies the position where
"                  the cursor should be set if no #CURSOR# macro could be
"                  found.
" Return:    1 if the expansion was successful and 0 otherwise.
" TODO proof behavier at first line
" {{{ CMAxx_doExpand( arg, ... )
fun! CMAxx_doExpand( arg, ... )
	" Save default buffer
	let save_def_reg = @"
	" Check file existense:
	let filename = CMAxx_findFile(a:arg)
	" extra arguments:
	if a:0 != 0
		let l:pos = a:1
	else
		let l:pos = 0
	endif
	" Insert the template:
	if filename == ""
		echohl ErrorMsg
		echo "File '".a:arg.".tmpl' could not be found!"
		echohl None
		return 0
	endif
	" Get file geometry
	let y = line('.')
	let x = col('.')
	let line = getline('.')
	let linelen = strlen(line)
	if l:pos == 0
		" after insertion
		let first = CMAxx_strpart(line, 0, x)
		let last = CMAxx_strpart(line, x, linelen)
	else
		" before insertion
		if x == 1
			let first = ""
			let last = line
		else
			let first = CMAxx_strpart(line, 0, x-1)
			let last = CMAxx_strpart(line, x-1, linelen)
		endif
	endif
	let indent = first
	if exists("b:CMAxx_ConvertPrefix")
		if b:CMAxx_ConvertPrefix != 0 && strlen(first)
			let indent = substitute(first, '\S', ' ', 'g')
		endif
	else
		let b:CMAxx_ConvertPrefix = 1
	endif
	let length = line('$')
	if length == 1
		let lenght = 0
	endif
	" include the template
	silent exec "read ".filename
	" calculate macro length ...
	let length = line('$') - length
	" delete the line above the insertion
	normal k
	normal dd
	" ... and now get start and end point
	let pstart = line('.')
	let pend = pstart + length - 1
	" Indent the template:
	if strlen(first) != 0
		silent exec ":".pstart.",".pstart."s/^/".first."/"
	endif
	if strlen(indent) != 0 && length > 1
		silent exec ":".pstart.",".pend."s/^$/@@EMPTY@@/e"
		silent exec ":".(pstart+1).",".pend."s/^/".indent."/"
		silent exec ":".pstart.",".pend."s/^.*@@EMPTY@@$//e"
	endif
	if strlen(last) != 0
		silent exec ":".pend.",".pend."s/$/".last."/"
	endif
	" Substitute known macros:
	" First we have to substitute the #CURSOR# macro:
	call CMAxx_Substitute(pstart, pend, 'CURSOR', s:CMAxx_CURSORSubstitute)
	if CMAxx_findMacroName('AUTHOR', pstart, pend) != ''
		if !exists("b:CMAxx_Author") || strlen(s:CMAxx_Author) == 0
			let b:CMAxx_Author = input('Author Name: ')
		endif
		call CMAxx_Substitute(pstart, pend, 'AUTHOR', b:CMAxx_Author)
	endif
	if strlen(s:CMAxx_Function) == 0 &&
	   \ CMAxx_findMacroName('FUNCTION', pstart, pend) != ''
		let s:CMAxx_Function = input('Function name: ')
	endif
	" TODO: change this.
	if strlen(s:CMAxx_Function) == 0 &&
	   \ CMAxx_findMacroName('CLASSNAME', pstart, pend) != ''
		let s:CMAxx_Function = input('Class name: ')
	endif
	call CMAxx_Substitute(pstart, pend, 'FUNCNAME', s:CMAxx_Function)
	call CMAxx_Substitute(pstart, pend, 'CLASSNAME', s:CMAxx_Function)
	call CMAxx_Substitute(pstart, pend, 'DATE', strftime("%d. %b %Y, %X"))
	" TODO: change this.
	if CMAxx_findMacroName('VERSION', pstart, pend) != ''
		if !exists("b:CMAxx_Version") ||strlen(b:CMAxx_Version) == 0 && 
			let b:CMAxx_Version = input "Version: "
		endif
		call CMAxx_Substitute(pstart, pend, 'VERSION', b:CMAxx_Version)
	endif
	let thefile = expand("%:t")
	if strlen(thefile) != 0
		call CMAxx_Substitute(pstart, pend, 'FILENAME', thefile)
		let thefiledef = toupper(thefile)
		let thefiledef = "__" . substitute(thefiledef, '\.', "_", "g") . "__"
		call CMAxx_Substitute(pstart, pend, 'FILEDEF', thefiledef)
	endif
	" Scan for unknown macros and ask vor their values:
	let line = CMAxx_findMacroName("", pstart, pend)
	while line != 0
		if exists("g:".s:macro_name)
			exec ":let value=g:".s:macro_name
		else
			let value = input('Value for '.s:macro_name.': ')
		endif
		call CMAxx_Substitute(pstart, pend, s:macro_name, value)
		let line = CMAxx_findMacroName("", pstart, pend)
	endwhile
	if a:0 >= 2
		let x = a:2
	endif
	call CMAxx_setCursor(pstart, pend, x)
	" Restore default buffer
	let @" = save_def_reg
	return 1
endfun
" }}} CMAxx_doExpand(arg)


" Function:  Expands the current line to a function or a class body with
"            doxygen comment prepended.
" {{{ CMAxx_expandFunction( type )
fun! CMAxx_expandFunction( type )
	let line = getline('.')
	let indent = matchstr(line, '^\s*')
	let s:CMAxx_Function = CMAxx_escape(substitute(line, '^\s*', '', ""))
	silent exec ":s/^.*$/".indent."/"
	normal $
	call CMAxx_doExpand(a:type)
endfun
" }}} CMAxx_expandFunction(type)


" Function:  Call the teplate which corresponds to the word under the cursor
" TODO Function handles macros at the second last column wrong
" {{{ CMAxx_expandTemplate( ... )
fun! CMAxx_expandTemplate( ... )
	" Save default buffer
	let save_def_reg = @"
	if a:0 == 0
		let insmode = 0
	else
		let insmode = a:1
	endif
	let line = getline('.')
	let length = strlen(line)
	let pos = col('.')
	let l:cursor = pos
	let template = ''
	let expMode = 1
	if length != 0
		if line[pos-1] =~ '\s'
			" User requests template expansion on a whitespace:
			if insmode == 1
				let expMode = 0
			else
				let expMode = 1
			endif
		else
			if pos != 1 && line[pos-2] !~ '\s'
				" we are not at the first position of the word so:
				normal b
				let pos = col('.')
			endif
			if pos == length || line[pos] =~ '\s'
				" we found a one letter macro so:
				if pos == length
					" noting is after the template
					let expMode = 0
				endif
				normal vd
			else
				" a word longer than one character so
				normal e
				if col('.') == length
					" noting is after the template
					let expMode = 0
				endif
				normal b
				normal ved
			endif
			let template = getreg()
		endif
	endif
	" If we have to restore the vermeintlichen template name
	let restore = template
	if strlen(template) == 0
		" we are at an empty line
		let template = input('Template name: ')
	endif
	let s:CMAxx_Function = ''
	let success = CMAxx_doExpand(template, expMode, cursor)
	if success != 1
		let @" = restore
		if expMode == 0
			normal p
		else
			normal P
		endif
		if insmode == 1
			sleep 1
		endif
	endif
	if insmode == 1
		" switch to insert mode, but do this like the 'a' command
		" so let's first get the position in the line:
		if col('.') < strlen(getline('.'))
			normal l
			startinsert
		else
			startinsert!
		endif
	endif
	" Restore default buffer
	let @" = save_def_reg
endfun
" }}} CMAxx_expandTemplate()


" Function:  This function can only be used in visual mode. It thakes the
"            actual selection, cut's it and inserts it at the cursor
"            position of the template.
" {{{ CMAxx_expandSelection( ... )
fun! CMAxx_expandSelection( ... )
	" Save default buffer
	let save_def_reg = @"
	normal gvx
	let selection = @"
	let expMode = 1
	let pos = col('.')
	if pos == strlen(getline('.'))
		let expMode = 0
	endif
	let firstCol = 0
	if pos == 1
		let firstCol = 1
	endif
	if a:0 == 0
		let template = input('Template name: ')
	else
		let template = a:1
	endif
	let s:CMAxx_Function = ''
	let success = CMAxx_doExpand(template, expMode, pos+strlen(selection))
	let @" = selection
	if success == 1
		normal p
	else
		if firstCol == 1
			normal P
		else
			normal p
		endif
	endif
	let @" = save_def_reg
endfun
" }}} CMAxx_expandSelection()


" Function:  prints the actual settings or writes them to a buffer so they
"            can be edited (This is be stolen from cvsmenu.vim; thanx to
"            Thorsten Maerz *bows*). The function uses the the buffer named
"            'z'!
" {{{ CMAxx_ShowSettings()
fun! CMAxx_ShowSettings()
	let zbak = @z
	if v:version > 700
		let @z = ""
\."\" Script: cmaxx $Revision: 1.50 $"
\."\n\" Current Directory: ".expand('%:p:h')
\."\n\" CMAxx's Variables Are:"
\."\n\"let b:CMAxx_LocalTemplates  = \'".b:CMAxx_LocalTemplates."\'"
		if s:CMAxx_TemplateDirNotSet == 1
			let @z .= ""
\."\nlet g:CMAxx_TemplateDir     = \'".g:CMAxx_TemplateDir."\'"
		else
			let @z .= ""
\."\n\"let g:CMAxx_TemplateDir     = \'".g:CMAxx_TemplateDir."\'"
		endif
		let @z .= ""
\."\nlet b:CMAxx_Author          = \'".b:CMAxx_Author."\'"
\."\nlet b:CMAxx_Version         = \'".b:CMAxx_Version."\'"
\."\nlet b:CMAxx_ConvertPrefix   = ".b:CMAxx_ConvertPrefix
\."\n\n\" --------------------------------------"
\."\n\" Change above values to your needs and execute the line to activate your"
\."\n\" settings. To execute a line either double click it or press Shift-Enter."
\."\n\" To close the buffer type 'q' or use ':bd'. To save this settings to"
\."\n\" ./.cmaxxrc press 's'."
	else
		let @z = ""
\."\" Script: cmaxx $Revision: 1.50 $"
\."\n\" Current Directory: ".expand('%:p:h')
\."\n\" CMAxx's Variables Are:"
\."\n\"let b:CMAxx_LocalTemplates  = \'".b:CMAxx_LocalTemplates."\'"
\."\n\"let g:CMAxx_TemplateDir     = \'".g:CMAxx_TemplateDir."\'"
\."\nlet b:CMAxx_Author          = \'".b:CMAxx_Author."\'"
\."\nlet b:CMAxx_Version         = \'".b:CMAxx_Version."\'"
\."\nlet b:CMAxx_ConvertPrefix   = ".b:CMAxx_ConvertPrefix
\."\n\n\" --------------------------------------"
\."\n\" Change above values to your needs and execute the line to activate your"
\."\n\" settings. To execute a line either double click it or press Shift-Enter."
\."\n\" To close the buffer type 'q' or use ':bd'. To save this settings to"
\."\n\" ./.cmaxxrc press 's'."
	endif
	new
	normal "zP
	let @z = zbak
	map <buffer>q :bd!<cr>
	map <buffer>S :w! .cmaxxrc<cr>
	map <buffer><s-cr> :exec getline('.')<cr>:set nomod<cr>:echo getline('.')<cr>
	map <buffer><2-LeftMouse> <s-cr>
	set syntax=vim
	set nomod
endfun
" }}} fun CMAxx_ShowSettings()


" Function:  List files in the folder given by 'a:f'.
" {{{ CMAxx_doListFiles( f )
fun! CMAxx_doListFiles( f )
	" First we take a look in the global before folder:
	let thefiles = expand(a:f.'/before/*.tmpl')
	if &filetype != ""
		if thefiles != ""
			let thefiles = thefiles . "\n"
		endif
		let thefiles = thefiles . expand(a:f.'/'.&filetype.'/*.tmpl')
	endif
	" And at least we look in the template root:
	if thefiles != ""
		let thefiles = thefiles . "\n"
	endif
	let thefiles = thefiles . expand(a:f.'/*.tmpl')
	echo thefiles
endfun
" }}} CMAxx_doListFiles(f)


" Function:  Lists all available templates.
" {{{ fun! CMAxx_listFiles()
fun! CMAxx_listFiles()
	" First we search the local template folder.
	if exists("b:CMAxx_LocalTemplates")
		call CMAxx_doListFiles(b:CMAxx_LocalTemplates)
	endif
	" Then we search the global template folder
	if exists("g:CMAxx_TemplateDir")
		call CMAxx_doListFiles(g:CMAxx_TemplateDir)
	endif
endfun
" }}} fun! CMAxx_listFiles()


" }}} Functions


" vim:fdm=marker:fdc=3:sts=2:ts=2:sw=2:tw=76
