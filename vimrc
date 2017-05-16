""""""""""""""""""""""""""""""	{{{1
" General settings		{{{1
"""""""""""""""""""""""""	{{{2

set nocompatible				" not VI compatible
set history=500					" lines of history to remember
set timeoutlen=700				" shorter timeout for mappings
set ttimeoutlen=100				" shorter timeout for key codes

" info 'for 100 files', 'nothing >100kB', 'nohlsearch'
set viminfo='100,s100,h
set undofile					" save undo trees
set undodir=/tmp/$USER/vim,.			" try and save undo trees to RAM
if exists("$SHM_D")
    let &undodir = $SHM_D."/vim,".&undodir
endif
if exists("*mkdir")
    for dir in split(&undodir, '\\\@<!,')
	try
	    if !len(glob(dir))
		call mkdir(dir, 'p', 0700)
	    endif
	    break
	catch /E739/
	endtry
    endfor
endif


"let &cdpath=substitute($CDPATH, ':', ',', 'g')

""" Pathogen			{{{2

" plugins to disable
let g:pathogen_disabled = ["zencoding"]

" these require ruby
if ! has("ruby")
    call add(g:pathogen_disabled, "lusty")
endif

" diable plugin auto stuff
let g:jedi#auto_initialization = 0
let g:jedi#auto_vim_configuration = 0

" source and call pathogen
runtime bundle/pathogen/autoload/pathogen.vim
call pathogen#infect()
"call pathogen#runtime_append_all_bundles()


""" helper functions		{{{2

" List AddUnique(List lst, Object val)			{{{
function! AddUnique(lst, val)
    if index(a:lst, a:val) == -1
	return add(a:lst, a:val)
    endif
    return a:lst
endfunction	" }}}

" int FirstOf(String|List|Dict haystack, String|List|Dict needles, int start=0)	{{{
" Finds the first of the given needles in the haystack.
function! FirstOf(haystack, needles, ...)
    if type(a:haystack) == type("")
	let Index = function('stridx')
    else
	let Index = function('index')
    endif
    let haystack = a:haystack
    if type(a:needles) == type([]) || type(a:needles) == type({})
	let needles = a:needles
    elseif type(a:needles) == type("")
	let needles = split(a:needles, '\zs')
    else
	let needles = [a:needles]
    endif
    if a:0
	let start = a:1
    else
	let start = 0
    endif
    let idx = len(haystack)
    for needle in needles
	let temp = Index(haystack, needle, start)
	if temp >= 0 && temp < idx
	    let idx = temp
	endif
    endfor
    if idx >= len(haystack)
	let idx = -1
    endif
    return idx
endfunction	" }}}

" logging style functions

function! Error(...)		" {{{
    echohl ErrorMsg
    echo "Error: " . join(a:000)
    echohl None
    return 0
endfunction			" }}}

function! Warn(...)		" {{{
    if &verbose >= 1
	echohl WarningMsg
	echo "Waring: " . join(a:000)
	echohl None
    endif
    return 0
endfunction			" }}}

function! Info(...)		" {{{
    if &verbose >= 2
	echo "Info: " . join(a:000)
    endif
    return 1
endfunction			" }}}

" Dictionary fuctions to be used to control dictionary like options	{{{3
" (e.g. listchars and fillchars). To use:
" 1. Create a dictionary called [s:][_]optname (no conflict with actual option
"    as that looks like &optname, but can prefix with '_' and make script local
"    for clarity.
" 2. Create a control dictionary by calling:
"	let CNTRL_NAME = deepcopy(_opt_ctrl_dict)._init('DICT_NAME'[, 'process'])
"    where DICT_NAME is the [s:][_]optname used above. This initialises the
"    control dictionary, and then either by passing the argument 'process',
"    calling CNTRL_NAME._process(), or an initial CNTRL_NAME._toggle(...) will
"    set the option appropriately.
let _opt_ctrl_dict = {}
function _opt_ctrl_dict._init(...) dict		" Initiate control dict	{{{
    " If given, set name
    if a:0			| let self._name = a:1			| endif
    " Check for global variable, else assume a script local
    if exists(self._name)	| let name = self._name
    else			| let name = 's:' . self._name
    endif
    " Get dictionaries keys
    exec "let keys = keys(" . name . ")"
    " Copy the keys
    for key in keys
	if key[0] != "_"
	    exec "let self[key] = " . name . "[key]"
	endif
    endfor
    if a:0 >= 2 && a:2 ==? "process"
	self._process()
    endif
    return self
endfunction			" }}}
function _opt_ctrl_dict._process() dict		" Process control dict	{{{
    " Get option name (removing leading '_')
    if self._name[0] == '_'	| let name = '&l:' . self._name[1:]
    else			| let name = '&l:' . self._name
    endif
    " Clear option
    exec "let " . name . " = ''"
    " Set option with 'self's items
    for key in keys(self)
	if key[0] != "_" && strlen(self[key])
	    exec "let " . name . " .= key . ':' . self[key] . ','"
	endif
    endfor
endfunction			" }}}
function _opt_ctrl_dict._toggle(...) dict	" Toggle key(s) in control dict	{{{
    " Check for global variable, else assume a script local
    if exists(self._name)	| let name = self._name
    else			| let name = 's:' . self._name
    endif
    " Toggle all arguments given
    for key in a:000
	if strlen(self[key])
	    let self[key] = ''
	else
	    exec "let self[key] = " . name . "[key]"
	endif
    endfor
    " Call our process method
    call self._process()
endfunction			" }}}
" end dictionary functions	}}}3


""""""""""""""""""""""""""""""	{{{1
" VIM UI			{{{1
"""""""""""""""""""""""""	{{{2

""" Look			{{{2

set vb t_vb=					" disable bell

set ruler					" always show ruler (position)
" Customise ruler
let s:_ruler_head = "%=%.24(%f%)%m%( %h%w%r%) "	" file name and status
if exists("*fugitive#statusline")			" fugitive branch info
    let s:_ruler_mid = "%.24(%{fugitive#statusline()}%)"
else | let s:_ruler_mid = ""
endif
let s:_ruler_tail = "%=%7(%c%V%)%=,%-6(%l%) %P"	" current position
" set rulerformat and statusline so they look identical.
let s:_ruler = s:_ruler_head . s:_ruler_mid . s:_ruler_tail
let &rulerformat = "%50(" . s:_ruler . "%)"
let &statusline = "%=" . s:_ruler . " "
" function to change ruler highlighting FIXME: no local ruler?
function! RulerHighlight(hlGroup)
    if hlexists(a:hlGroup) && exists('&rulerformat') && strlen(&rulerformat)
	let &l:rulerformat = substitute(&rulerformat,
		    \ '^\(%\([0-9]\+\)\?\(\.\([0-9]\+\)\?\)\?(\)\?'
		    \ . '\(%#[^#]*#\)\?\(.*\)$',
		    \ '\1%#' . a:hlGroup . '#\6', '')
    endif
endfunction
"autocmd WinEnter * call RulerHighlight('StatusLine')
"autocmd WinLeave * call RulerHighlight('StatusLineNC')
set laststatus=0				" don't show status line at end

set cmdwinheight=3				" smaller cmdline window

set number					" number rows
autocmd Filetype info,man setlocal nonumber

set showtabline=1				" 0:never 1:>1page 2:always
"autocmd Filetype info,man setlocal showtabline=1

set tabpagemax=40				" max number opening tabs = ?

"colorscheme TjlH_col
"colorscheme desert
"colorscheme elflord

" solarized
"if ! has("gui_running")
    "let g:solarized_termcolor = 256
    "let g:solarized_termtrans = 1
"endif
"call togglebg#map("<Leader><Leader>bg")
"set background=dark
"colorscheme solarized
"unmap <F5>

try
    colorscheme desert256-TjlH
catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme desert
    autocmd ColorScheme *
		\ highlight Normal	ctermbg=NONE |
		\ highlight NonText	ctermbg=NONE
endtry


set display+=lastline		" show as much of lastline as possible, not '@'s

" Set characters to display for non-printing and fill charaters
if &encoding == 'utf-8'
    let s:_listchars = {'eol': '¶',	'tab': '➤∼',	'trail': '⋯',
		\	'extends': '⟫',	'precedes': '⟪',
		\	'conceal': '·',	'nbsp': '∾'}
    let s:_fillchars = {'stl': '┴',	'stlnc': '─',	'vert': '│',
		\	'fold': '┄',	'diff': '╶'}
else
    let s:_listchars = {'eol': '$',	'tab': '>-',	'trail': '-',
		\	'extends': '>',	'precedes': '<',
		\	'conceal': ' ',	'nbsp': '~'}
    let s:_fillchars = {'stl': '^',	'stlnc': '-',	'vert': '|',
		\	'fold': '-',	'diff': '-'}
endif

let _lcs = deepcopy(_opt_ctrl_dict)._init('_listchars')	" Init &lcs ctrl dict
let _fcs = deepcopy(_opt_ctrl_dict)._init('_fillchars')	" Init &fcs ctrl dict
"let _lcs = deepcopy(s:_listchars)	" Get a control copy
"let _fcs = deepcopy(s:_fillchars)	" Get a control copy
" Disable some characters initially
call _lcs._toggle('eol', 'conceal')
call _fcs._toggle('stl', 'stlnc')


""" Feel			{{{2

set mouse=a					" always enable mouse input

" use <Esc> to enter cmd window and again from normal mode to exit it.
set cedit=<Esc>
autocmd CmdwinEnter * nmap <buffer> <silent> <Esc> :quit<CR>
autocmd CmdwinEnter * cmap <buffer> <silent> <Esc> <C-u>quit<CR>

let mapleader = ','
let maplocalleader = '\'
noremap!	jj			<Esc>

set scrolloff=4					" keep cursor 5 lines from edge
set sidescroll=8
set sidescrolloff=12

set whichwrap=b,s,>,< 				" which movement chars move lines

set incsearch					" search as type
set ignorecase smartcase 			" ignore case except explicit UC

set virtualedit+=block				" move past EOL in block mode

" make Y like C
noremap		Y	y$

" map increment and decrement TODO - equivalent for visual mode?
nnoremap	++	<C-a>
nnoremap	--	<C-x>

" remove search highlighting
noremap <silent>	<Space>		:<C-u>nohlsearch<CR>

" 'r'eload (source) 'c'onfiguration file
noremap		<Leader>rc		:<C-u>source $MYVIMRC<CR>
"autocmd BufWritePost **vimrc !source $MYVIMRC	" auto reload vimrc
"autocmd BufWritePost $MYVIMRC : $MYVIMRC

" function to cycle a numeric variable
function! CycleNumber(name, max)
    let current = eval(a:name)
    let new = (current + 1) % (a:max + 1)
    exec "let " . a:name . " = new"
    if a:name[0:0]== '&'
	echo "  " . a:name[1:] . " = " . new
    else
	echo "  " . a:name . " = " . new
    endif
endfunction

" set *number toggle mappings
nnoremap	<Leader><Leader>nu	:let &number = ! &nu<CR>
nnoremap	<Leader><Leader>rn	:let &relativenumber = ! &rnu<CR>

" set laststatus toggle mappings
nnoremap <Leader><Leader>ls	:call CycleNumber("&laststatus", 2)<CR>

" set list[chars] mappings
nnoremap	<Leader><Leader>li	:let &list = ! &list<CR>
nnoremap	<Leader><Leader>lce	:call _lcs._toggle("eol")<CR>
nnoremap	<Leader><Leader>lct	:call _lcs._toggle("tab")<CR>
nnoremap	<Leader><Leader>lcl	:call _lcs._toggle("trail")<CR>
nnoremap	<Leader><Leader>lcx	:call _lcs._toggle("extends")<CR>
nnoremap	<Leader><Leader>lcp	:call _lcs._toggle("precedes")<CR>
nnoremap	<Leader><Leader>lcc	:call _lcs._toggle("conceal")<CR>
nnoremap	<Leader><Leader>lcn	:call _lcs._toggle("nbsp")<CR>

" set paste						" enable paste INSERT
nnoremap <Leader><Leader>p :let &paste = ! &paste<CR>

" add PYTHONPATH to search path for 'gf' TODO: parse line for import, etc.
"autocmd FileType python let &path=&path.substitute($PYTHONPATH, ':', ',', 'g')

""" Binary edit			{{{2
function! s:setup_binary()
    if &bin
	%!xxd
	set ft=xxd
	augroup binary
	    autocmd BufWritePre <buffer>	%!xxd -r
	    autocmd BufWritePost <buffer>	%!xxd | set nomod
	augroup end
    else
	echoe "Not &binary"
    endif
endfunction
autocmd BufReadPre  *.bin	setlocal binary
" messes up afterimage: autocmd BufReadPost *		call s:setup_binary()
command! -bar Binary	call s:setup_binary()

""" Program Execution		{{{2

" Make executable / compile
" TODO: set makeprog rather than calling chmod, use writepre, etc.
map <buffer>	<Leader>mx		:update<Bar>make "%:t:r"<CR>
map <buffer>	<Leader>mX		:update<CR>:make "%:t:r" <Up>
autocmd Filetype javascript,perl,php,python,ruby,sh
	    \ map <buffer>	<Leader>mx	:update<Bar>!chmod +x %<CR>
autocmd Filetype javascript,perl,php,python,ruby,sh
	    \ map <buffer>	<Leader>mX	:update<CR>:!chmod <Up>
autocmd Filetype ebuild
	    \ map <buffer>	<Leader>mx	:update<Bar>!ebuild "%" manifest<CR>
autocmd Filetype ebuild
	    \ map <buffer>	<Leader>mX	:update<CR>:!ebuild "%" <Up>
autocmd Filetype dot
	    \ map <buffer>	<Leader>mx	:update<CR>:!dot -Tpng "%"<BAR>display &<CR>
map <buffer>	<Leader>mm		:update<Bar>make<CR>
map <buffer>	<Leader>ma		:update<Bar>make all<CR>
map <buffer>	<Leader>M		:update<CR>:make <Up>
map <buffer>	<Leader>mc		:make clean<CR>

" Execute file
autocmd Filetype javascript,perl,php,python,ruby,sh
	    \ map <buffer>	<Leader>x	:update<Bar>!"%:h/%:t"<CR>
autocmd Filetype c,cpp
	    \ map <buffer>	<Leader>x	:!"%:h/%:t:r"<CR>
autocmd Filetype make
	    \ map <buffer>	<Leader>x	:update<Bar>make<CR>
autocmd Filetype ebuild
	    \ map <buffer>	<Leader>x	:update<Bar>!emerge "=%:s:^.*/\([^/]\+/\)\([^/]\+\)/\2\(-.\+\)\.ebuild$:\1\2\3:"<CR>

" Execute file with args
autocmd Filetype javascript,perl,php,python,ruby,sh
	    \ map <buffer>	<Leader>X	:update<CR>:!"%:h/%:t" <Up>
autocmd Filetype c,cpp
	    \ map <buffer>	<Leader>X	:!"%:h/%:t:r" <Up>
autocmd Filetype make
	    \ map <buffer>	<Leader>X	:update<CR>:make <Up>
autocmd Filetype ebuild
	    \ map <buffer>	<Leader>X	:update<CR>:!ebuild "%"  <Up>


""" quit for buffers		{{{2

function! QuitBuf(...)
    " function to inteligently close windows and buffers
    if a:0	| let bang = a:1
    else	| let bang = ''
    endif
    " first check if it's a help/quickfix/preview window
    if &filetype =~ '\(help\|man\|info\|qf\)'
	execute 'quit' . bang
	return
    elseif &previewwindow == 1
	execute 'pclose' . bang
	return
    "elseif exists('b:fugitive_type') || exists('b:fugitive_commit_arguments')
	" also check if its from fugitive (e.g. Gdiff window)
	"execute 'quit' . bang
	"return
    endif
    " current vars
    let c_b = bufnr('%')			" current buffer
    let c_w = winnr()				" current window
    let c_t = tabpagenr()			" current tabpage
    " control vars
    let o_b = 1					" assume only buffer
    let o_w = 1					" assume only window to buffer
    " find if we're the only listed buffer
    for b_i in range(1, bufnr('$'))		" iterate from first buffer to last
	if buflisted(b_i)			" valid buffer?
	    if b_i != c_b
		let o_b = 0 | break		" not only buffer
	    endif
	endif
    endfor
    " find if we're the only window linked to the  buffer
    for t_i in range(1, tabpagenr('$'))		" iterate by tab and window
	let t_bs = tabpagebuflist(t_i)
	for w_i in range(1, tabpagewinnr(t_i, '$'))
	    if (! (t_i == c_t && w_i == c_w)) && (t_bs[w_i - 1] == c_b)
		let o_w = 0 | break		" not only window to buffer
	    endif
	endfor
	if ! o_w | break | endif
    endfor
    " perform the correct operation
    let bd_com = 'bdelete' . bang
    let bn_com = 'bnext'
    let q_com = 'quit' . bang
    if o_b && o_w | let x_com = q_com	" 1 buf, 1 win		: close vim
    elseif o_w	| let x_com = bd_com	" 1/n bufs, 1 win->buf	: close buf
    elseif o_b	| let x_com = q_com	" 1 buf, 1/n wins->buf	: close win
    else	| let x_com = bn_com	" 1/n bufs, 1/n wins->buf : close ?
    endif
    execute x_com
endfunction
command! Bwq		write<Bar>call QuitBuf()
command! Bx		update<Bar>call QuitBuf()
command! -bang Bq	call QuitBuf('<bang>')

" Close current buffer
nnoremap <silent>	ZX		:Bx<CR>
nnoremap <silent>	ZQ		:Bq<CR>
nnoremap <silent>	Z!Q		:Bq!<CR>
" Close all buffers
nnoremap <silent>	ZA		:xall<CR>
" Close other buffer and window
nnoremap <silent>	Zw		:wincmd w<Bar>exit<CR>
nnoremap <silent>	ZW		:wincmd w<Bar>exit<CR>
nnoremap <silent>	Zh		:wincmd h<Bar>exit<CR>
nnoremap <silent>	ZH		:wincmd h<Bar>exit<CR>
nnoremap <silent>	Zj		:wincmd j<Bar>exit<CR>
nnoremap <silent>	ZJ		:wincmd j<Bar>exit<CR>
nnoremap <silent>	Zk		:wincmd k<Bar>exit<CR>
nnoremap <silent>	ZK		:wincmd k<Bar>exit<CR>
nnoremap <silent>	Zl		:wincmd l<Bar>exit<CR>
nnoremap <silent>	ZL		:wincmd l<Bar>exit<CR>


""""""""""""""""""""""""""""""	{{{1
" Style and Syntax		{{{1
"""""""""""""""""""""""""	{{{2

filetype plugin indent on			" enable file type check and indent
syntax on					" enable syntax highlighting

" allow syntax (and diff) refreshing
noremap		<Leader>rs		:syntax sync fromstart<CR>
noremap		<Leader>rd		:diffupdate<CR>

""" Tabs			{{{2
set tabstop=8					" literal tab width
"autocmd Filetype c,cpp setlocal tabstop=4
set softtabstop=8				" spaces per tab (pressed)
set shiftwidth=4				" spaces per indent
autocmd Filetype ant,dtd,proto,xml,xsd setlocal
	    \ shiftwidth=2
set noexpandtab					" don't expand tabs to spaces
autocmd Filetype ant,c,cpp,dtd,java,javascript,jsp,json,python,rst,xml,xsd setlocal
	    \ expandtab		" for MLs, xfce and python 3 compatibility
set smarttab			" use shiftwidth for indent, else softtabstop

""" Wrapping			{{{2
set linebreak 					" wraps without <eol>
set breakindent					" indent wrappped lines
if &encoding == 'utf-8' | let &showbreak='↪' | else | let &showbreak='>' | endif
set breakindentopt+=sbr				" at begining, not start of text
set cpoptions+=n				" in the number column

" don't insert comment leader on <CR> or o/O
set formatoptions-=r formatoptions-=o
" code style: wrap at length, normal navigation
autocmd Filetype ant,c,cpp,css,dtd,html,javascript,make,python,sh,vim,xml,xsd setlocal
	    \ textwidth=79 formatoptions+=a2
	    \ formatoptions-=l formatoptions-=a formatoptions-=w
	    " auto wrap at standard terminal width (80) to 2nd line indent,
	    " allow auto formating long lines
" text style: no line wrap, g{j,k} <==> {j,k} for movement
autocmd Filetype markdown,rst,tex,text setlocal
	    \ textwidth=0
	    \ formatoptions+=n
	    " overide system vimrc (for text, others standard)
	    " recognise numbered and bulleted lists

function! s:TextMovement(...)
    if a:0 > 0 && a:1 == '!'
	nunmap gj
	nunmap gk
	nunmap j
	nunmap k
    else
	noremap gj j
	noremap gk k
	noremap j gj
	noremap k gk
    endif
endfunction
command! -bang TextMovement	call s:TextMovement('<bang>')
autocmd Filetype markdown,rst,tex,text TextMovement

" image formats: for use with afterimage
autocmd Filetype bmp,gif,png,xpm,xbm setlocal nowrap

""" file types			{{{2
let g:java_highlight_functions = "style"
let g:java_highlight_debug = 1
let g:php_sql_query = 1
let g:php_htmlInStrings = 1
let g:python_highlight_all = 1
let g:readlinke_has_bash = 1
let g:highlight_sedtabs = 1
let g:sh_noisk = 1			" don't add '.' to 'iskeyword'
let g:sh_syn_embed = "asprP"
autocmd FileType json	hi link jsonCommentError Comment

""""""""""""""""""""""""""""""	{{{1
" File Formats			{{{1
"""""""""""""""""""""""""	{{{2

"set fileformats=unix			" always use Unix file format

"autocmd FileType python set bomb	" enable BOM for listend filetypes
					" breaks *n?x shebangs (#!/path/2/prog)

let g:tex_flavor = 'latex'		" use latex styles
autocmd BufRead,BufNewFile */WEB_INF/tags/*.tag set filetype=jsp

""" use skeleton files		{{{2
autocmd BufNewFile * silent! 0r ~/Templates/%:e.%:e


""""""""""""""""""""""""""""""	{{{1
" Folding			{{{1
"""""""""""""""""""""""""	{{{2

set foldminlines=1 foldnestmax=10 foldignore=""
function! SplitFoldText(...)
    " Function for use with 'foldtext', displays half the window width as the
    " literal text, the other half taken up with (modified) v:folddashes and
    " the number of lines in the fold.
    " Allow calling function with a line number and prepare variables
    if a:0
	let line = getline(a:1)
	let lines = '?'
	let dashes = '+' . repeat('-', (level - 1))
    else
	let line = getline(v:foldstart)
	let lines = 1 + v:foldend - v:foldstart
	let dashes = '+' . v:folddashes[1:]
    endif
    " replace tabs with correct number of spaces
    "let line = substitute(line, '\t', repeat(' ', &tabstop), 'g')
    let split_line = split(line, '	', 1)
    let [line; split_line] = split_line
    for item in split_line
	let line .= repeat(' ', (&tabstop - (strlen(line) % &tabstop))) . item
    endfor
    " remove foldmarkers (and trailing text)
    let idx = stridx(&foldmarker, ',')
    let fmr_s = &foldmarker[:(idx - 1)]
    let fmr_e = &foldmarker[(idx + 1):]
    let idx = stridx(line, fmr_e)
    if idx != -1	| let line = line[:(idx - 1)]	| endif
    let idx = stridx(line, fmr_s)
    if idx != -1	| let line = line[:(idx - 1)]	| endif
    " make line the right size
    let width = winwidth(0) / 2
    let length = strlen(line)
    if length > (width - 1)
	let char = matchlist(&listchars, '.*extends:\(.\),')[1]
	if ! strlen(char)	| let char = '>'	| endif
	let line = line[:width - 2] . char
    else
	let line = line . repeat(' ', width - length)
    endif
    return  line . ' ' . dashes . ' (' . lines . ' lines) '
endfunction
set foldtext=SplitFoldText()

" Don't screw up folds when inserting text that might affect them, until
" leaving insert mode. Foldmethod is local to the window. Protect against
" screwing up folding when switching between windows.
autocmd InsertEnter *
	    \ if !exists('w:last_fdm')
	    \| let w:last_fdm = &foldmethod
	    \| setlocal foldmethod=manual
	    \|endif
autocmd InsertLeave,WinLeave *
	    \ if exists('w:last_fdm')
	    \| let &l:foldmethod = w:last_fdm
	    \| unlet w:last_fdm
	    \|endif

""" syntax folds		{{{2
"let g:clojure_fold = 1
"let g:baan_fold = 1
"let g:baan_fold_block = 1
"let g:baan_fold_sql = 1
"let g:eiffel_fold = 1
"let g:fortran_fold = 1
"let g:fortran_fold_conditionals = 1
"let g:fortran_fold_multilinecomments = 1
"let g:javaScript_fold = 1	" FIXME: BROKEN
let g:perl_fold = 1
let g:perl_fold_anonymous_subs = 1
let g:perl_fold_blocks = 1
let g:php_folding = 2
let g:r_syntax_folding = 1
let g:rcs_folding = 1
let g:ruby_fold = 1
let g:sh_fold_enabled = 31
let g:tex_fold_enabled = 1
"let g:vimsyn_folding = "aflprPtm"
let g:xml_syntax_folding = 1

""" filetype settings		{{{2
" let $code = "ant,c,cpp,css,dtd,gentoo-init-d,html,java,javascript,jsp,json,perl,php,prolog,python,sh,verilog,vhdl,xml,xsd"
autocmd Filetype ant,c,cpp,gentoo-init-d,html,java,jsp,json,perl,php,sh,xml,xsd setlocal
	    \ foldcolumn=5
	    \ foldmethod=syntax
	    \ foldlevel=1
autocmd Filetype bib,css,tex setlocal
	    \ foldcolumn=3
	    \ foldmethod=syntax
	    \ foldlevel=1
autocmd Filetype ada,dtd,javascript,prolog,proto,python,verilog,vhdl setlocal
	    \ foldcolumn=5
	    \ foldmethod=indent
	    \ foldlevel=1
autocmd Filetype c,cpp setlocal foldignore="#"
"autocmd Filetype python autocmd BufWritePre python mkview
"autocmd Filetype python autocmd BufReadPost python silent loadview

""" folding vim			{{{2
function! FoldVim(l)
    let line = getline(a:l)
    let p_line = getline(a:l - 1)
    if line =~# '^\"\{30\}' || line =~ '\svim\?:\s'
	return 0
    elseif p_line =~# '^\"\{30\}'
	return '>1'
    elseif line =~# '^\"\{25\}'
	return 1
    elseif line =~# '^\"\{3\} '
	return '>2'
    "elseif p_line =~# '^\"\{3\}'
	"return 2
    else
	if line !~# '^\s*end'
	    return 2 + float2nr(indent(a:l) / &shiftwidth)
	else
	    return 3 + float2nr(indent(a:l) / &shiftwidth)
	endif
	"let i_diff = float2nr((indent(a:l) - indent(a:l - 1)) / &shiftwidth)
	"if line =~ '^end' | let i_diff += 1 | endif
	"if p_line =~ '^end' | let i_diff -= 1 | endif
	"if i_diff > 0
	    "return 'a' . abs(i_diff)
	"elseif i_diff < 0
	    "return 's' . abs(i_diff)
	"else
	    "return '='
	"endif
    endif
endfunction
autocmd Filetype vim setlocal
	    \ foldcolumn=4
	    \ foldmethod=marker
	    \ foldexpr=FoldVim(v:lnum)
	    \ foldlevel=1
"autocmd BufRead **vimrc setlocal foldmethod=expr foldexpr=Fold_vimrc(v:lnum)
"autocmd Filetype vim setlocal foldlevel=1

""" folding tar			{{{2
function! FoldTar(l)
    let line = getline(a:l)
    if strlen(line) < 1 | return 0 | endif
    if line[0] == '"' | return 1 | endif
    return count(split(line, '\zs'), '/') + 1
endfunction
autocmd Filetype tar setlocal
	    \ foldcolumn=0
	    \ foldmethod=expr
	    \ foldexpr=FoldTar(v:lnum)
	    \ foldlevel=2


""""""""""""""""""""""""""""""	{{{1
" Navigation			{{{1
"""""""""""""""""""""""""	{{{2

""" Quick move windows		{{{2
nnoremap gw <C-W>
nnoremap gW <C-W>

""" Quick move buffers		{{{2
nnoremap <silent> gb :bnext<CR>
nnoremap <silent> gB :bprevious<CR>

""" Redifine tag mappings	{{{2
nnoremap g] <C-]>
nnoremap g} g<C-]>
nnoremap g<C-]> g]
nnoremap g[ <C-T>

noremap <Leader>i <C-i>
noremap <Leader>o <C-o>

""" Redifine goto mark mappings	{{{2
" Think the default should be the position in the previous line, rather than
" the start of it. Alse have ` set as tmux prefix, so using <Leader>' as start
" of previous line (although send-prefix allows ` to work, wil become confusing
" in nested sessions).
noremap <Leader>' '
noremap ' `

""""""""""""""""""""""""""""""	{{{1
" Spelling			{{{1
"""""""""""""""""""""""""	{{{2

" set spell						" enable spell check
nnoremap <Leader><Leader>sp :let &spell = ! &spell<CR>

autocmd Filetype css,html,javascript,php,tex,text setlocal spell
autocmd Filetype conf,help,info,man setlocal nospell
"autocmd StdinReadPost * setlocal nospell		" but not in man

set spelllang=en_gb					" spell check language to GB
set spellfile=/home/tom/.vim/spell/I.latin1.add		" set my spellfile
autocmd FileType tex setlocal spellfile+=/home/tom/.vim/spell/latex.latin1.add
autocmd BufRead **/Imperial/**/*.* setlocal spellfile+=/home/tom/.vim/spell/elec.latin1.add

" set dictionary+=/usr/share/dict/words			" add standard words


""""""""""""""""""""""""""""""	{{{1
" Completion			{{{1
"""""""""""""""""""""""""	{{{2

"set wildmenu
set wildmode=longest:list			" shell style file completion

set completeopt=longest,menuone,menu,preview
set complete=.,k,w,b,u,t,i			" add dictionary completion

"set autoindent				" indent new line to same as previous
"set smartindent				" indent on code type

" automatically open and close the popup menu / preview window
autocmd InsertLeave * if pumvisible() == 0|silent! pclose|endif

"set omnifunc=syntaxcomplete#Complete
"autocmd FileType c set omnifunc=ccomplete#Complete
"autocmd FileType css set omnifunc=csscomplete#CompleteCSS
"autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
"autocmd FileType java set omnifunc=javacomplete#Complete
"autocmd FileType jsp set omnifunc=javacomplete#Complete
"autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
"autocmd FileType python set omnifunc=pythoncomplete#Complete
"autocmd FileType ruby set omnifunc=pythoncomplete#Complete
"autocmd FileType sql set omnifunc=sqlcomplete#Complete

""" continue completion		{{{2
"imap <silent> <expr> <buffer> <CR> pumvisible() ? "<CR><C-R>=(col('.')-1&&match(getline(line('.')), '\\.', col('.')-2) == col('.')-2)?\"\<lt>C-X>\<lt>C-O>\":\"\"<CR>" : "<CR>"


""""""""""""""""""""""""""""""	{{{1
" Plugin configuration		{{{1
"""""""""""""""""""""""""	{{{2

""" csv				{{{2
autocmd BufRead,BufNewFile *.?sv setfiletype csv	" Allow for ?sv file editing
autocmd BufNewFile *.csv let g:csv_delim = ','	" set the csv delimiter for new files
autocmd BufNewFile *.tsv let g:csv_delim = '	'	" tsv delimiter ''
let g:csv_autocmd_arrange = 1				" auto arrange columns
function! CSVAlignColumns(align, bang) range
    exec "silent ".a:firstline.",".a:lastline."UnArrangeColumn"
    let b:csv_arrange_leftalign = a:align ==? "l" || a:align ==? "left" ? 1 : 0
    exec "silent ".a:firstline.",".a:lastline."ArrangeColumn".a:bang
endfunction
autocmd FileType csv	command! -range=% -bang -nargs=1 CSVAlignColumns
	    \ <line1>,<line2>call CSVAlignColumns(<args>, "<bang>")
autocmd FileType csv	noremap <Leader>cal	:CSVAlignColumns "left"<CR>
autocmd FileType csv	noremap <Leader>car	:CSVAlignColumns "right"<CR>
"TODO: following for visual and no header
autocmd FileType csv	nnoremap <Leader>cs	:2,$CSVSort<CR>
autocmd FileType csv	nnoremap <Leader>cS	:2,$CSVSort!<CR>

""" ctags			{{{2
"autocmd BufWritePost c,cpp,*.h !ctags -R --c++-kinds=+p --fields=+iaS --extra=+q
"noremap mtl :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
set tags=./.tags,./tags,.tags,tags
autocmd BufRead,BufNew */msp430/**/*.c setlocal tags+=~/.vim/tags/msp430
autocmd BufRead,BufNew */avr/**/*.c setlocal tags+=~/.vim/tags/avr
"set tags+=~/.vim/tags/gl
"set tags+=~/.vim/tags/sdl
"autocmd Filetype cpp set tags+=~/.vim/tags/qt4
"set tags+=~/.vim/tags/gtk-2

""" diffchar			{{{2
let g:DiffUpdate = 1

""" diffchanges			{{{2
nnoremap <Leader>dd	:DiffChangesDiffToggle<CR>
nnoremap <Leader>dp	:DiffChangesPatchToggle<CR>

""" easytags			{{{2
" DoC ubuntu machines default to ctags.emacs23, so do this manually.
for cmd in ["exuberant-ctags", "ctags-exuberant"]	" [gentoo, DoC-ubuntu]
    let full_cmd = system("which " . cmd)
    if full_cmd[0:-2] =~ cmd . "$"	" has newline on the end
	let g:easytags_cmd = full_cmd[0:-2]
	break
    endif
endfor
unlet cmd full_cmd
"autocmd Filetype c,cpp let g:easytags_on_cursorhold = 0
let g:easytags_file = "~/.vim/tags/general"
let g:easytags_by_filetype = "~/.vim/tags/"
let g:easytags_async = 1
let g:easytags_dynamic_files = 2
let g:easytags_include_members = 0
let g:easytags_autorecurse = 0
let g:easytags_resolve_links = 1
let g:easytags_include_members = 1
nnoremap <Leader>tu	:UpdateTags<CR>
nnoremap <Leader>th	:HighlightTags<CR>
set notagbsearch	" tag file seems to not play nice with binary search

""" Grep (lvimgrep with hl)	{{{2
function! s:grepClear()
    if exists("w:grep_matchID")
	call matchdelete(w:grep_matchID)
	unlet! w:grep_matchID
    endif
endfunction
function! Grep(pattern)
    call s:grepClear()		" delete any previous match
    exec "lvimgrep /".a:pattern."/gj %"
    lopen			" now we've done the search, open the list
    " add a autocmd on quickfix close to clean up after ourselves
    autocmd BufDelete,BufUnload <buffer>	call s:grepClear()
    call matchadd("Search", a:pattern, -1)	" highlight pattern in quickfix
    ll 1				" jump to first match
    " highlight main window, storing the ID for later deletion
    let w:grep_matchID = matchadd("Search", a:pattern, -1)
    normal zv
endfunction
command! -bar -nargs=? Grep	call Grep("<args>")
nnoremap grep	:Grep 
nnoremap gr/	:Grep 
nnoremap grn	:lnext<CR>zv
nnoremap grN	:lNext<CR>zv
nnoremap grp	:lprevious<CR>zv
nnoremap grq	:lclose<CR>

""" fugitive			{{{2
nnoremap <Leader>gs	:Gstatus<CR>
nnoremap <Leader>gc	:Gcommit<CR>
nnoremap <Leader>gca	:Gcommit -a<CR>
nnoremap <Leader>gd	:Gdiff<CR>
set diffopt+=vertical

""" gentoo			{{{2
let g:bugsummary_browser = "xdg-open '%s'"	" uses the desktop default

""" gundo			{{{2
noremap gu	:GundoToggle<CR>

""" jedi
let g:jedi#popup_on_dot = 0
let g:jedi#show_call_signatures = 0
autocmd FileType python setlocal omnifunc=jedi#completions

""" linediff			{{{2
let g:linediff_first_buffer_command = 'enew'    " don't use tabs
"let g:linediff_indent = 1                      " indent so as to ignore format
vnoremap <Leader>dl	:Linediff<CR>
"noremap <Leader>da	:LinediffAdd<CR> TODO
vnoremap <Leader>dr	:LinediffReset<CR>

""" lusty			{{{2
set hidden		" just hide abandoned buffers, don't unload
let g:LustyExplorerSuppressHiddenWarning = 1
nnoremap <Leader>j	:LustyJuggler<CR>
nnoremap <Leader>;	:LustyJugglePrevious<CR>
nnoremap <Leader>e	:LustyBufferExplorer<CR>
nnoremap <Leader>G	:LustyBufferGrep<CR>
nnoremap <Leader>f	:LustyFilesystemExplorer<CR>
nnoremap <Leader>F	:LustyFilesystemExplorerFromHere<CR>

""" Man				{{{2
"runtime ftplugin/man.vim

""" NERDTree			{{{2
let NERDTreeChDirMode = 2
let NERDTreeHijackNetrw = 1
let NERDTreeShowBookmarks = 1
noremap <Leader>nt	:NERDTreeToggle<CR>

""" OmniCppComplete		{{{2
let OmniCpp_NamespaceSearch = 1
let OmniCpp_GlobalScopeSearch = 1
let OmniCpp_ShowAccess = 1
let OmniCpp_ShowPrototypeInAbbr = 1 			" show function parameters
let OmniCpp_MayCompleteDot = 1 				" autocomplete after .
let OmniCpp_MayCompleteArrow = 1 			" autocomplete after ->
let OmniCpp_MayCompleteScope = 1 			" autocomplete after ::
let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]

""" PDF				{{{2
runtime ftplugin/pdf.vim		" doesn't seem to do it automatically

""" ros				{{{2
" Enable ros specific scripts if we're in a ROS environment.
if $ROS_ROOT != ''
    set filetype+=.ros
endif

""" Screen			{{{2
" Fix colors for xfce4 terminal
if $COLORTERM ==# 'Terminal'
    set t_Co=256
endif
let g:ScreenImpl = 'Tmux'
let g:ScreenShellHeight = 10
let g:ScreenShellExpandTabs = 1

function! s:ScreenShellListener()
    if exists('g:ScreenShellActive') && g:ScreenShellActive
	nunmap <Leader>ss
	nunmap <Leader>sh
	nunmap <Leader>sv
	nunmap <Leader>sa
	nunmap <Leader>sb
	nunmap <Leader>sd
	nunmap <Leader>sp
	nunmap <Leader>si
	nunmap <Leader>so
	noremap <Leader>ss	:ScreenSend<CR>
	nnoremap <Leader>sq	:ScreenQuit<CR>
    else
	silent! unmap <Leader>ss
	silent! nunmap <Leader>sq
	nnoremap <Leader>ss	:ScreenShell<CR>
	nnoremap <Leader>sh	:ScreenShell<CR>
	nnoremap <Leader>sv	:ScreenShellVertical<CR>
	nnoremap <Leader>sa	:ScreenShellAttach<CR>
	nnoremap <Leader>sb	:ScreenShell bash<CR>
	nnoremap <Leader>sd	:ScreenShell dash<CR>
	nnoremap <Leader>sp	:ScreenShell python<CR>
	nnoremap <Leader>si	:IPython<CR>
	nnoremap <Leader>so	:ScreenShell octave<CR>
    endif
endfunction
call <SID>ScreenShellListener()
augroup ScreenShellEnter
    autocmd User * call <SID>ScreenShellListener()
augroup END
augroup ScreenShellExit
    autocmd User * call <SID>ScreenShellListener()
augroup END

""" securemodelines		{{{2
set nomodeline
let g:secure_modelines_modelines=30
if ! exists("g:secure_modelines_allowed_items")
    let g:secure_modelines_allowed_items = []
endif
for _opt in [
	    \	'ft',	'filetype',
	    \	'ff',	'fileformat',
	    \	'tw',	'textwidth',
	    \	'ts',	'tabstop',
	    \	'spel',	'nospell',
	    \	'sts',	'softtabstop',
	    \	'sw',	'shiftwidth',
	    \	'et',	'noet',	'expandtab',	'noexpandtab',
	    \	'fo',	'formatoptions',
	    \	'rl',	'norl',	'rightleft',	'norightleft',
	    \	'fen',	'foldenable',
	    \	'fdc',	'foldcolumn',
	    \	'fdm',	'foldmethod',
	    \	'fmr',	'foldmarker',
	    \	'fdl',	'foldlevel',
	    \	'wrap',	'nowrap',
	    \]
	    "\	'fde',	'foldexpr',
    call AddUnique(g:secure_modelines_allowed_items, _opt)
endfor
unlet _opt
let g:secure_modelines_verbose = 1

""" SuperTab			{{{2
let g:SuperTabDefaultCompletionType = 'context'
let g:SuperTabMidWordCompletion = 1
let g:SuperTabRetainCompletionDuration = 'completion'
let g:SuperTabNoCompleteAfter = extend(['^', '\s'], split(",;|&+-=#()[]{}'\"", '\zs'))
let g:SuperTabLongestEnhanced = 1
let g:SuperTabLongestHighlight = 0
let g:SuperTabCrMapping = 0
" TODO: Check if above g:STCM=0 removes the need (not working anyway?).
"if exists("##InsertCharPre")	" A lot of boxes don't have this.
    "autocmd InsertCharPre * if v:char=="<CR>" && pumvisible()|let    v:char="<C-E>".v:char|endif
"endif

""" TagList			{{{2
noremap <Leader>tl :TlistToggle<CR>

""" txtfmt			{{{2
let g:txtfmtFgcolormask = "11111111"
let g:txtfmtBgcolormask = "11111111"
autocmd FileType *.tft setlocal
	    \ filetype=txtfmt
autocmd FileType *.tft.?,*.tft.??,*.tft.???,*.tft.???? setlocal
	    \ filetype+=.txtfmt

""" zencoding			{{{2
let g:user_zen_leader_key = '<LocalLeader>z'
let g:use_zen_complete_tag = 1


""""""""""""""""""""""""""""""	{{{1
" Printing			{{{1
"""""""""""""""""""""""""	{{{2

set printoptions=left:4pc,right:4pc,top:5pc,bottom:5pc
set printfont=:h9

""""""""""""""""""""""""""""""	{{{1
" Misc				{{{1
"""""""""""""""""""""""""	{{{2

if version >= 703
    " use stronger encryption
    set cryptmethod="blowfish"
endif

" edit macro
nnoremap <Leader>q	:<c-u><c-r><c-r>='let @'. v:register .' = '. string(getreg(v:register))<cr><c-f><left>

""" Miscellaneous functions	{{{2

function! SetLastModified()	" {{{
    " Function to set the modified time in a file
    let cursor_pos = getpos(".")
    call cursor(1, 1)
    let pat = '.*[Ll]ast[ _][Mm]odified[: ]\s*'
    let match_pos = search(pat, 'e')
    let match_str = matchstr(getline(match_pos), pat)
    call setline(match_pos, match_str . strftime('%F %T'))
    call setpos('.', cursor_pos)
endfunction		" }}}

" bool s:replace(string rep, int line='.', int start=0, int length=strlen)	{{{
" Performs the replacement (a:rep) supplied on the a:line using boundaries
" a:start and a:end.
function! s:replace(rep, ...)
    if a:0 >= 1		" Given line?
	let c_line = a:1	| else	| let c_line = line(".")
    endif			" ... otherwise use current line.
    let old_line = getline(c_line)	" Get old (current) line
    if a:0 >= 2		" Given start?
	let c_start = a:2	| else	| let c_start = 0
    endif			" ... otherwise use begining (0)
    if a:0 >= 3		" Given finish?
	let c_length = a:3	| else	| let c_length = strlen(old_line)
    endif			" ... otherwise use end (-1)
    if exists("*" . a:rep)	" Replacement given is a function?
	call Info("strpart(".old_line.", ".c_start.", ".c_length.")")
	let text = strpart(old_line, c_start, c_length)	" get current text
	call Info("\t=", text)
	let rep = function(a:rep)(text)		" call function with text
    else
	let rep = a:rep			" otherwise treat as a string.
    endif
    if ! rep	| return Warn("No replacement string.")		| endif
    let new_line =
		\ strpart(old_line, 0, c_start) .
		\ rep .
		\ strpart(old_line, c_length)
    if setline(c_line, new_line)
	return Error("Failed setting new line (".c_line.") text")
    endif
    return 1
endfunction	" s:replace()	}}}

" [mode, startpos, endpos] FindSelection(string expansion=NONE)		{{{
" Determines the current form of selection, and returns the mode (as from
" visualmode() or ""), start, and end positions (as from getpos()).
function! FindSelection(...) range	" TODO !!!!
    " Get position variables
    let start = getpos("'<")
    let end = getpos("'>")
    let pos = getpos(".")
    " Find if we have (and need) a valid buffer global cursor position
    " (this is a fix for [range]call messing up '.')
    if exists("b:cursor_pos") && pos[0:1] == b:cursor_pos[0:1]
		\ && pos != b:cursor_pos
	let pos = b:cursor_pos		" use buffer global cursor position
    endif
    call Info("position:", pos)
    if start[1] == a:firstline && end[1] == a:lastline
		\ && pos == start	" valid visual selection
	return [visualmode(), start, end]
    elseif pos[1] != a:firstline || pos[1] != a:lastline	" explicit range
	" TODO?
    elseif a:0			" Supplied an expansion?
	call setpos(".", pos)		" Fix [range]call messing up '.'
	let text = expand(a:1)		" text to replace
	let c_line = getline(pos[1])
	call Info("finding '".text."' in line\n\t".c_line)
	let idx = strridx(c_line, text, pos[2])	" get str idx to the left of '.'
	if idx < 0				" nothing to the left?
	    let idx = stridx(c_line, text)		" get first str
	endif
	call Info("found '".text."' at index ".idx)
	if idx < 0				" still not found?
	    return Error("Expansion '".a:1."' not found in line ".pos[1].".")
	endif
	" TODO: partial line replacement
	if ! s:replace(a:rep, pos[1], idx, strlen(text))
	    return Warn(a:1, "replace failed.")
	endif
    else
	return Error("No visual selection, and no default expansion.")
    endif
endfunction	" FindSelection()	}}}

" bool ReplaceSelection(string rep, string expansion=NONE)		{{{
" Determines the current form of selection and then perform the replacement
" (a:rep) suplied on the correct range.
function! ReplaceSelection(rep, ...) range
    " Get position variables
    let v_start = getpos("'<")
    let v_end = getpos("'>")
    let pos = getpos(".")
    " Find if we have (and need) a valid buffer global cursor position
    if exists("b:cursor_pos") && pos[0:1] == b:cursor_pos[0:1]
		\ && pos != b:cursor_pos
	let pos = b:cursor_pos		" use buffer global cursor position
    else
	let pos = getpos(".")		" or get current cursor position
    endif
    call Info("position:", pos)
    if v_start[1] == a:firstline && v_end[1] == a:lastline
		\ && pos == v_start	" Is it a valid visual selection?
	let v_mode = visualmode()		" get visual mode
	if v_mode ==# "v"		" Have a character visual selection
	    " TODO: partial line for a:(first|last)line, else complete line
	    if ! s:replace(a:rep, v_start[1], v_start[2])
		return Error("VISUAL replace failed")		| endif
	    for c_line in range(v_start[1] + 1, v_end[1] - 1)
		if ! s:replace(a:rep, c_line)
		    return Error("VISUAL replace failed")	| endif
	    endfor
	    if ! s:replace(a:rep, v_end[1], 0, v_end[2])
		return Error("VISUAL replace failed")		| endif
	elseif v_mode ==# "V"		" Have a line visual selection
	    " TODO: complete line for all
	    for c_line in range(v_start[1], v_end[1])
		if ! s:replace(a:rep, c_line)
		    return Error("VISUAL LINE replace failed")	| endif
	    endfor
	elseif v_mode ==# ""		" Have a block visual selection
	    " TODO: partial line for all
	    for c_line in range(v_start[1], v_end[1])
		if ! s:replace(a:rep, c_line, v_start[2], v_end[2])
		    return Error("VISUAL BLOCK replace failed")	| endif
	    endfor
	endif
    elseif a:0			" Supplied an expansion?
	call setpos(".", pos)		" Fix [range]call messing up '.'
	let text = expand(a:1)		" text to replace
	let c_line = getline(pos[1])
	call Info("finding '".text."' in line\n\t".c_line)
	let idx = strridx(c_line, text, pos[2])	" get str idx to the left of '.'
	if idx < 0				" nothing to the left?
	    let idx = stridx(c_line, text)		" get first str
	endif
	call Info("found '".text."' at index ".idx)
	if idx < 0				" still not found?
	    return Error("Expansion '".a:1."' not found in line ".pos[1].".")
	endif
	" TODO: partial line replacement
	if ! s:replace(a:rep, pos[1], idx, strlen(text))
	    return Warn(a:1, "replace failed.")
	endif
    else
	return Error("No visual selection, and no default expansion.")
    endif
endfunction	" ReplaceSelection()	}}}

" bool s:dig(string input)						{{{
" Uses command line utility 'dig' to resolve IPs and FQDNs from a:input.
function! s:dig(input)
    let syscall = "dig +short +time=1 +tries=1 "
    if a:input =~ "^[0-9\.:]*$"
	let syscall = syscall . "-x "
	call Info("Resolve IP to FQDN")
    else
	call Info("Resolve FQDN to IP")
    endif
    call Info("call:", syscall, a:input)
    let res = system(syscall . shellescape(a:input))
    if v:shell_error
	return Error("dig returned " . v:shell_error)
    endif
    return substitute(res, "\n", " ", "g")
endfunction
command! -range -bar DIG
	    \ let b:cursor_pos = getpos(".")
	    \|<line1>,<line2>call ReplaceSelection("s:dig", "<cWORD>")
	    \|call setpos(".", b:cursor_pos)
map <Leader>dig :DIG<CR>
" end dig		}}}

" String s:synName(int lineNumber, int column)				{{{
" Returns the name of the syntax group at the given position.
function! s:synName(line, col)
    return synIDattr(synID(a:line, a:col, 1), "name")
endfunction
command! -bar SynName	echo s:synName(line('.'), col('.'))
" end Syntax Name	}}}

" command IndentXML - (semi-)inteligently re-indent xml file		{{{
command! IndentXML
	    \ let b:syntax_on = exists("g:syntax_on")
	    \| if (b:syntax_on) | syntax off | endif
	    \| %s:>\s*<:><:ge
	    \| nohlsearch
	    \| exec "normal gg=G"
	    \| if (b:syntax_on) | syntax enable | endif
	    \| unlet b:syntax_on
" end IndentXML		}}}

" command IndentJSON - (semi-)inteligently re-indent json file		{{{
command! IndentJSON
	    \ let b:syntax_on = exists("g:syntax_on")
	    \| if (b:syntax_on) | syntax off | endif
	    \| %s:\([[{,]\)\s*$:\1:ge
	    \| %s:{\s*\([^}]\):{\1:ge | %s:\[\s*\([^]]\):[\1:ge
	    \| %s:{\s*}:{}:ge | %s:\[\s*\]:\[\]:ge
	    \| %s:,\s*\([^,]\):,\1:ge | %s:\s*\:\s*:\: :ge
	    \| %s:\([^{]\)\s*}:\1}:ge
	    \| %s:\([^[]\)\s*]:\1]:ge
	    \| nohlsearch
	    \| exec "normal gg=G"
	    \| if (b:syntax_on) | syntax enable | endif
	    \| unlet b:syntax_on
" end IndentJSON	}}}

" command CurrentHL - show current highlight information		{{{
command! CurrentHL	echo
	    \  'hi<' . synIDattr(synID(line("."),col("."),1),"name") . '>'
	    \ .' trans<' . synIDattr(synID(line("."),col("."),0),"name") . '>'
	    \ .' lo<' . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . '>'
	    \ .' fg<' . synIDattr(synIDtrans(synID(line("."),col("."),1)),"fg#") . '>'
map <Leader>hi	:CurrentHL<CR>
" end CurrentHL								}}}

""" Nagios			{{{2
autocmd BufNewFile */[Nn][Aa][Gg]**/host**/*.cfg silent! 0r ~/Templates/nag-host.cfg
autocmd BufNewFile */[Nn][Aa][Gg]**/service**/*.cfg silent! 0r ~/Templates/nag-service.cfg
autocmd BufNewFile */[Nn][Aa][Gg]**/templates.cfg silent! 0r ~/Templates/nag-template.cfg
autocmd BufWritePre */[Nn][Aa][Gg]**/*.cfg call SetLastModified()


" vi: ft=vim sw=4 sts=8 ts=8 noet :
