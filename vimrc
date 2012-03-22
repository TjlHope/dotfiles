""""""""""""""""""""""""""""""
" General settings
"""""""""""""""""""""""""

set nocompatible				" not VI compatible
set vb t_vb=					" disable bell
set listchars=trail:-,nbsp:% 			" characters to display specials
set history=50 					" lines of history to remember
set mouse=a					" always enable mouse input
set timeoutlen=700				" shorter timeout for mappings
set ttimeoutlen=100				" shorter timeout for key codes

set viminfo='100 				" save marks and jumps in viminfo

"let &cdpath=substitute($CDPATH, ':', ',', 'g')

""" Pathogen
runtime bundle/pathogen/autoload/pathogen.vim
"call pathogen#infect()
call pathogen#runtime_append_all_bundles()


""""""""""""""""""""""""""""""
" VIM UI
"""""""""""""""""""""""""

""" Look
set ruler					" always show ruler (position)
" Customise ruler
let s:_ruler_head = "%=%.24(%<%f%)%m\ %h%w%r"		" file name and status
if exists("*fugitive#statusline")			" fugitive branch info
    let s:_ruler_mid = " %.24(%{fugitive#statusline()}%)"
else | let s:_ruler_mid = ""
endif
let s:_ruler_tail = "%=%7(%c%V%)%=,%-6(%l%)\ %P"	" current position
" set rulerformat and statusline so they look identical.
let &rulerformat = "%50(" . s:_ruler_head . s:_ruler_mid . s:_ruler_tail . "%)"
let &statusline = "%=" . &rulerformat . " "
set laststatus=0				" don't show status line at end

set number					" set numbering rows
autocmd Filetype info,man setlocal nonumber
"autocmd StdinReadPost * setlocal nonumber	" but not in man
nnoremap <Leader><Leader>nu	:let &number = ! &number<CR>
nnoremap <Leader><Leader>rn	:let &relativenumber = ! &relativenumber<CR>

set showtabline=1				" 0:never 1:>1page 2:always
"autocmd Filetype info,man setlocal showtabline=1
"autocmd StdinReadPost * set showtabline=1

set tabpagemax=40				" max number opening tabs = ?

colorscheme TjlH_col
"colorscheme desert
"colorscheme elflord

set display+=lastline		" show as much of lastline as possible, not '@'s

" Set characters to display for non-printing charaters
if &encoding == "utf-8"
    let s:_lcs_chars = {"eol": "¶",	"tab": "➤∼",	"trail": "⋯",
		\	"extends": "⟫",	"precedes": "⟪",
		\	"conceal": "·",	"nbsp": "∾"}
else
    let s:_lcs_chars = {"eol": "$",	"tab": ">-",	"trail": "-",
		\	"extends": ">",	"precedes": "<",
		\	"conceal": " ",	"nbsp": "~"}
endif

let _lcs = deepcopy(s:_lcs_chars)	" Get a control copy
function _lcs._process() dict		" Add set function to control copy
    let &l:listchars = ""
    for key in keys(self)
	if key[0] != "_" && strlen(self[key])
	    let &l:listchars .= key . ":" . self[key] . ","
	endif
    endfor
endfunction
function _lcs._toggle(...) dict		" Add toggle function to control copy
    for key in a:000
	if strlen(self[key])
	    let self[key] = ""
	else
	    let self[key] = s:_lcs_chars[key]
	endif
    endfor
    call self._process()
endfunction

" set list[chars] functions
nnoremap <Leader><Leader>li	:let &list = ! &list<CR>
nnoremap <Leader><Leader>lce	:call _lcs._toggle("eol")<CR>
nnoremap <Leader><Leader>lct	:call _lcs._toggle("tab")<CR>
nnoremap <Leader><Leader>lcl	:call _lcs._toggle("trail")<CR>
nnoremap <Leader><Leader>lcx	:call _lcs._toggle("extends")<CR>
nnoremap <Leader><Leader>lcp	:call _lcs._toggle("precedes")<CR>
nnoremap <Leader><Leader>lcc	:call _lcs._toggle("conceal")<CR>
nnoremap <Leader><Leader>lcn	:call _lcs._toggle("nbsp")<CR>
" Disable some characters initially
call _lcs._toggle("eol", "conceal")

""" Feel
let mapleader = ','
let maplocalleader = '\'
noremap! jj	<Esc>

set scrolloff=4					" keep cursor 5 lines from edge
set sidescrolloff=10

set whichwrap=b,s,>,< 				" which movement chars move lines

set incsearch					" search as type
set ignorecase smartcase 			" ignore case except explicit UC

" remove search highlighting
"nohlsearch
nnoremap <silent> <Space>	:nohlsearch<CR>

noremap <Leader>rc		:source $MYVIMRC<CR>
"autocmd BufWritePost **vimrc !source $MYVIMRC	" auto reload vimrc
"autocmd BufWritePost $MYVIMRC : $MYVIMRC

" Map to toggle laststatus
function! CycleSetting(name, max)
    let current = eval('&' . a:name)
    let new = (current + 1) % (a:max + 1)
    exec "let &" . a:name . " = new"
    echo "  " . a:name . " = " . &laststatus
endfunction
noremap <Leader><Leader>ls	:call CycleSetting("laststatus", 2)<CR>

" add PYTHONPATH to search path for 'gf' TODO: parse line for import, etc.
"autocmd FileType python let &path = &path . substitute($PYTHONPATH, ':', ',', 'g')

""" Program Execution
" TODO: set makeprog rather than calling chmod, use writepre, etc.
" Make executable / compile
map <buffer> <Leader>mx		:update<Bar>make "%:t:r"<CR>
map <buffer> <Leader>mX		:update<CR>:make "%:t:r" <Up>
autocmd Filetype javascript,perl,php,python,ruby,sh
	    \ map <buffer> <Leader>mx	:update<Bar>!chmod +x %<CR>
autocmd Filetype javascript,perl,php,python,ruby,sh
	    \ map <buffer> <Leader>mX	:update<CR>:!chmod +x %<Left><Left><Left><Left>
map <buffer> <Leader>mm		:update<Bar>make<CR>
map <buffer> <Leader>ma		:update<Bar>make all<CR>
map <buffer> <Leader>M		:update<CR>:make <Up>
map <buffer> <Leader>mc		:make clean<CR>
" Execute file
autocmd Filetype javascript,perl,php,python,ruby,sh
	    \ map <buffer> <Leader>x	:update<Bar>!"%:h/%:t"<CR>
autocmd Filetype c,cpp
	    \ map <buffer> <Leader>x	:!"%:h/%:t:r"<CR>
autocmd Filetype make
	    \ map <buffer> <Leader>x	:update<Bar>make<CR>
" Execute file with args
autocmd Filetype javascript,perl,php,python,ruby,sh 
	    \ map <buffer> <Leader>X	:update<CR>:!"%:h/%:t" <Up>
autocmd Filetype c,cpp
	    \ map <buffer> <Leader>X	:!"%:h/%:t:r" <Up>
autocmd Filetype make
	    \ map <buffer> <Leader>X	:update<CR>:make <Up>

""" quit for buffers
function! ExitBuf(...)
    " function to inteligently close windows and buffers
    if a:0	| let bang = a:1
    else	| let bang = ''
    endif
    " first check if it's a help/quickfix/preview windoe 
    if &filetype =~ '\(help\|man\|info\|qf\)'
	execute 'close' . bang
	return
    elseif &previewwindow == 1
	execute 'pclose' . bang
	return
    elseif exists('b:fugitive_type') || exists('b:fugitive_commit_arguments')
	" also check if its from fugitive (e.g. Gdiff window)
	execute 'close' . bang
	return
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
    let bd_com = 'bnext | bdelete' . bang . ' ' . c_b
    let bn_com = 'bnext'
    let q_com = 'quit' . bang
    if o_b && o_w | let x_com = q_com	" 1 buf, 1 win		: close vim
    elseif o_w	| let x_com = bd_com	" 1/n bufs, 1 win->buf	: close buf
    elseif o_b	| let x_com = q_com	" 1 buf, 1/n wins->buf	: close win
    else	| let x_com = bn_com	" 1/n bufs, 1/n wins->buf : close ?
    endif
    execute x_com
endfunction

command! Bwq		write<Bar>call ExitBuf()
command! Bx		update<Bar>call ExitBuf()
command! -bang Bq	call ExitBuf('<bang>')
" Close current buffer
nnoremap <silent> ZX	:Bx<CR>
nnoremap <silent> ZQ	:Bq<CR>
nnoremap <silent> Z!Q	:Bq!<CR>
" Close all buffers
nnoremap <silent> ZA	:xall<CR>
" Close other buffer and window
nnoremap <silent> Zh	:wincmd h<Bar>exit<CR>
nnoremap <silent> ZH	:wincmd h<Bar>exit<CR>
nnoremap <silent> Zj	:wincmd j<Bar>exit<CR>
nnoremap <silent> ZJ	:wincmd j<Bar>exit<CR>
nnoremap <silent> Zk	:wincmd k<Bar>exit<CR>
nnoremap <silent> ZK	:wincmd k<Bar>exit<CR>
nnoremap <silent> Zl	:wincmd l<Bar>exit<CR>
nnoremap <silent> ZL	:wincmd l<Bar>exit<CR>


""""""""""""""""""""""""""""""
" Style and Syntax
"""""""""""""""""""""""""

syntax on					" enable syntax highlighting
filetype plugin indent on			" enable file type check and indent

" allow syntax (and diff) refreshing
noremap <Leader>rs	:syntax sync fromstart<CR>
noremap <Leader>rd	:diffupdate<CR>

""" Tabs
set tabstop=8					" spaces per tab
"autocmd Filetype c,cpp setlocal tabstop=4
set softtabstop=8
set shiftwidth=4				" spaces per indent
autocmd Filetype markdown,rst setlocal shiftwidth=2
set noexpandtab					" don't expand tabs to spaces
autocmd Filetype c,cpp,rst,python setlocal 
	    \ expandtab		" for xfce and python 3 compatibility
set smarttab			" use shiftwidth for indent, else softtabstop

""" Wrapping
set linebreak 					" wraps without <eol>
" code style: wrap at length, normal navigation
autocmd Filetype c,cpp,html,make,python,sh,vim setlocal
	    \ textwidth=79 formatoptions+=aw2
	    \ formatoptions-=r formatoptions-=o formatoptions-=l
	    " auto wrap at standard terminal width (80) to 2nd line indent, 
	    " don't comment on <CR> or o/O, allow auto formating long lines
" text style: no line wrap, g{j,k} <==> {j,k} for movement
autocmd Filetype markdown,rst,tex,text setlocal 
autocmd Filetype markdown,rst,tex,text setlocal
	    \ textwidth=0
	    \ formatoptions+=n
	    " overide system vimrc (for text, others standard)
	    " recognise numbered and bulleted lists
autocmd Filetype markdown,rst,tex,text noremap gj j
autocmd Filetype markdown,rst,tex,text noremap gk k
autocmd Filetype markdown,rst,tex,text noremap j gj
autocmd Filetype markdown,rst,tex,text noremap k gk
" image formats: for use with afterimage
autocmd Filetype gif,png,xpm,xbm setlocal nowrap


""""""""""""""""""""""""""""""
" File Formats
"""""""""""""""""""""""""

set fileformats=unix					" always use Unix file format

autocmd BufRead,BufNewFile *.txt setfiletype text
autocmd BufRead,BufNewFile *.prb setfiletype tex
"autocmd BufRead,BufNewFile *.bib setfiletype bib
autocmd BufRead,BufNewFile */AI/**/*.pl,*/prolog/**/*.pl setfiletype prolog
autocmd BufRead,BufNewFile *.pde setfiletype cpp

"autocmd FileType python set bomb			" enable BOM for listend filetypes
							" messes up *n?x #!s

let g:tex_flavor='latex'				" use latex styles

""" use skeleton files
autocmd BufNewFile * silent! 0r ~/Templates/%:e.%:e


""""""""""""""""""""""""""""""
" Folding
"""""""""""""""""""""""""

" let $code = "c,cpp,css,gentoo-init-d,html,javascript,php,prolog,python,sh,verilog,vhdl,xml"
"set foldcolumn=5
autocmd Filetype c,cpp,css,gentoo-init-d,html,javascript,php,prolog,python,sh,verilog,vhdl,vim,xml setlocal
	    \ foldcolumn=5
	    \ foldmethod=indent
	    \ foldlevel=0
	    \ foldlevelstart=2
	    \ foldminlines=1
	    \ foldnestmax=10
autocmd Filetype c,cpp setlocal foldignore="#"
"setlocal foldignore=""
autocmd Filetype prolog,vim setlocal foldcolumn=3
"autocmd Filetype python,sh,javascript,css,html,xml,php,vhdl,verilog set foldignore="#"
"autocmd Filetype python autocmd BufWritePre python mkview
"autocmd Filetype python autocmd BufReadPost python silent loadview

""" fold vimrc
function! Fold_vimrc(l)
    let line = getline(a:l)
    let p_line = getline(a:l - 1)
    if line =~ '^\"\{30\}' || line =~ '\svi?:\s'
	return 0
    elseif line =~ '^\"\{25\}' || p_line =~ '^\"\{30\}'
	return 1
    elseif line =~ '^\"\{3\} '
	return 1
    "elseif p_line =~ '^\"\{3\}'
	"return 2
    else
	if line =~ '^end'
	    return 3 + float2nr(indent(a:l) / &shiftwidth)
	else
	    return 2 + float2nr(indent(a:l) / &shiftwidth)
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
autocmd BufRead **vimrc setlocal foldmethod=expr foldexpr=Fold_vimrc(v:lnum) 
"autocmd Filetype vim setlocal foldlevel=1

""" fold python
function! Fold_python(l)
    let line = getline(a:l)
    if line =~ "^\\s*[\"']\\{3\\}"
	return 1 + float2nr(indent(a:l) / &shiftwidth)
    elseif line == ''
	return -1
    else
	return float2nr(indent(a:l) / &shiftwidth)
    endif
endfunction
autocmd Filetype python setlocal foldmethod=expr foldexpr=Fold_python(v:lnum) 
"autocmd Filetype vim setlocal foldlevel=1


""""""""""""""""""""""""""""""
" Navigation
"""""""""""""""""""""""""

""" Quick move windows
nnoremap gw <C-W>
nnoremap gW <C-W>

""" Quick move buffers
nnoremap <silent> gb :bnext<CR>
nnoremap <silent> gB :bprevious<CR>

""" Redifine tag mappings
nnoremap g] <C-]>
nnoremap g} g<C-]>
nnoremap g<C-]> g]
nnoremap g[ <C-T>

noremap <Leader>i <C-i>
noremap <Leader>o <C-o>

""" Redifine goto mark mappings
" Think the default should be the position in the previous line, rather than 
" the start of it. Alse have ` set as tmux prefix, so using <Leader>' as start 
" of previous line (although send-prefix allows ` to work, wil become confusing 
" in nested sessions).
noremap <Leader>' '
noremap ' `

""""""""""""""""""""""""""""""
" Spelling
"""""""""""""""""""""""""

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


""""""""""""""""""""""""""""""
" Completion
"""""""""""""""""""""""""

"set wildmenu
set wildmode=longest:list				" shell style file completion

set completeopt=longest,menuone,menu,preview
set complete=.,k,w,b,u,t,i				" add dictionary completion

"set autoindent					" indent new line to same as previous
"set smartindent				" indent on code type

" automatically open and close the popup menu / preview window
autocmd InsertLeave * if pumvisible() == 0|silent! pclose|endif

"set omnifunc=syntaxcomplete#Complete
"autocmd FileType css set omnifunc=csscomplete#CompleteCSS
"autocmd FileType python set omnifunc=pythoncomplete#Complete
"autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
"autocmd FileType html set omnifunc=htmlcomplete#CompleteTags

""" attempt to continue completion
"imap <silent> <expr> <buffer> <CR> pumvisible() ? "<CR><C-R>=(col('.')-1&&match(getline(line('.')), '\\.', col('.')-2) == col('.')-2)?\"\<lt>C-X>\<lt>C-O>\":\"\"<CR>" : "<CR>"


""""""""""""""""""""""""""""""
" Plugin configuration
"""""""""""""""""""""""""

""" AutomaticLaTexPlugin

""" csv

autocmd BufNewFile *.csv let g:csv_delim = ','	" set the ?sv delimiter for new files
autocmd BufNewFile *.tsv let g:csv_delim = '	'	" - - '' - -
"autocmd BufNewFile *.csv let g:csv_delim=','
"autocmd BufNewFile *.tsv let g:csv_delim='	'
autocmd BufRead,BufNewFile *.?sv setfiletype csv	" Allow for ?sv file editing
" some nice mappings
autocmd Filetype csv nnoremap <Leader>h :Header<CR>
autocmd Filetype csv nnoremap <Leader>H :Header!<CR>
autocmd Filetype csv nnoremap <Leader>ch :HiColumn<CR>
autocmd Filetype csv nnoremap <Leader>cH :HiColumn!<CR>
autocmd Filetype csv nnoremap <Leader>dc :DeleteColumn<CR>
autocmd Filetype csv nnoremap <Leader>rc :InitCSV<CR>
let g:csv_highlight_column = 'y'
let g:csv_hiGroup = "CSVColumnHilight"
let g:csv_hiHeader = "CSVHeaderHilight"
let g:csv_no_conceal = 1
" fix highlighting problems
"autocmd Filetype csv nmap <silent><buffer> gb :call clearmatches()<Bar>bnext<CR>
"autocmd Filetype csv nmap <silent><buffer> gB :call clearmatches()<Bar>bprevious<CR>
autocmd Filetype csv autocmd BufLeave * call clearmatches()

""" ctags
"autocmd BufWritePost c,cpp,*.h !ctags -R --c++-kinds=+p --fields=+iaS --extra=+q
"noremap mtl :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>
set tags=./.tags,./tags,.tags,tags
autocmd BufRead,BufNew */msp430/**/*.c setlocal tags+=~/.vim/tags/msp430
autocmd BufRead,BufNew */avr/**/*.c setlocal tags+=~/.vim/tags/avr
"set tags+=~/.vim/tags/gl
"set tags+=~/.vim/tags/sdl
"autocmd Filetype cpp set tags+=~/.vim/tags/qt4 
"set tags+=~/.vim/tags/gtk-2 

""" easytags
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
let g:easytags_dynamic_files = 2
let g:easytags_include_members = 0
let g:easytags_autorecurse = 0
let g:easytags_resolve_links = 1
nnoremap <Leader>tu :UpdateTags<CR>
nnoremap <Leader>th :HighlightTags<CR>
set notagbsearch	" tag file seems to not play nice with binary search

""" fugitive
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gc :Gcommit<CR>
nnoremap <Leader>gca :Gcommit -a<CR>
nnoremap <Leader>gd :Gdiff<CR>

""" gentoo
let g:bugsummary_browser = "xdg-open '%s'"	" uses the desktop default

""" lusty
set hidden		" just hide abandoned buffers, don't unload
let g:LustyExplorerSuppressHiddenWarning = 1
nnoremap <Leader>j :LustyJuggler<CR>
nnoremap <Leader>p :LustyJugglePrevious<CR>
nnoremap <Leader>e :LustyBufferExplorer<CR>
nnoremap <Leader>f :LustyFilesystemExplorer<CR>
nnoremap <Leader>F :LustyFilesystemExplorerFromHere<CR>

""" Man
"runtime ftplugin/man.vim

""" NERDTree
let NERDTreeChDirMode = 2
let NERDTreeHijackNetrw = 1
let NERDTreeShowBookmarks = 1
noremap <Leader>nt :NERDTreeToggle<CR>

""" OmniCppComplete
let OmniCpp_NamespaceSearch = 1
let OmniCpp_GlobalScopeSearch = 1
let OmniCpp_ShowAccess = 1
let OmniCpp_ShowPrototypeInAbbr = 1 			" show function parameters
let OmniCpp_MayCompleteDot = 1 				" autocomplete after .
let OmniCpp_MayCompleteArrow = 1 			" autocomplete after ->
let OmniCpp_MayCompleteScope = 1 			" autocomplete after ::
let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]

""" PDF
runtime ftplugin/pdf.vim

""" Pydiction
"let g:pydiction_location = '~/.vim/after/pydiction/complete-dict'

""" pyflakes
let g:pyflakes_use_quickfix = 0

""" pep8
let g:pep8_map='<Leader>8'

""" ros
" Enable ros specific scripts if we're in a ROS environment.
if $ROS_ROOT != ''
    set filetype+=.ros
endif

""" Screen
" Fix colors for xfce4 terminal
if $COLORTERM == 'Terminal'
    set t_Co=256
endif
let g:ScreenImpl = 'Tmux'
let g:ScreenShellHeight = 10
let g:ScreenShellExpandTabs = 1
noremap <Leader>sh :ScreenShell<CR>
noremap <Leader>sv :ScreenShell<CR>
noremap <Leader>sb :ScreenShell bash<CR>
noremap <Leader>sd :ScreenShell dash<CR>
noremap <Leader>sp :ScreenShell python<CR>
noremap <Leader>si :IPython<CR>
noremap <Leader>so :ScreenShell octave<CR>
noremap <Leader>sa :ScreenShellAttach<CR>
noremap <Leader>ss :ScreenSend<CR>
noremap <Leader>sq :ScreenQuit<CR>

""" securemodelines
set nomodeline
if exists("g:secure_modelines_allowed_items")
    let g:secure_modelines_allowed_items += [
		\ 'foldenable', 'fen',
		\ 'foldmethod', 'fdm',
		\ 'formatoptions', 'fo',
		\]
		"\ 'foldexpr', 'fde',
endif
let g:secure_modelines_verbose = 1

""" SuperTab
let g:SuperTabDefaultCompletionType = 'context'
"autocmd Filetype python
	    "\ let g:SuperTabContextDefaultCompletionType = '<c-x><c-o>'
let g:SuperTabMidWordCompletion = 1
let g:SuperTabRetainCompletionDuration = 'completion'
let g:SuperTabNoCompleteAfter = ['\s', ',', ';', '|', '&', '+', '-', '=', '#']
let g:SuperTabLongestEnhanced = 1
let g:SuperTabLongestHighlight = 0
let g:SuperTabCrMapping = 0
if exists("##InsertCharPre")	" A lot of boxes don't have this.
    autocmd InsertCharPre <CR> let v:char = pumvisible() ? <C-E><CR>
endif

""" TagList
noremap <Leader>tl :TlistToggle<CR>

""" txtfmt
let g:txtfmtFgcolormask = "11111111"
let g:txtfmtBgcolormask = "11111111"
autocmd FileType *.tft setlocal
	    \ filetype=txtfmt
autocmd FileType *.tft.?,*.tft.??,*.tft.???,*.tft.???? setlocal
	    \ filetype+=.txtfmt

""" zencoding
let g:user_zen_leader_key = '<Leader>z'
let g:use_zen_complete_tag = 1


""""""""""""""""""""""""""""""
" Printing
"""""""""""""""""""""""""

set printoptions=left:4pc,right:4pc,top:5pc,bottom:5pc
set printfont=:h9

""""""""""""""""""""""""""""""
" Misc
"""""""""""""""""""""""""

if version >= 703
    " use stronger encryption
    set cryptmethod="blowfish"
endif

function! Error(...)
    echohl ErrorMsg
    echo "Error: " . join(a:000)
    echohl None
    return 0
endfunction

function! Warn(...)
    if &verbose >= 1
	echohl WarningMsg
	echo "Waring: " . join(a:000)
	echohl None
    endif
    return 0
endfunction

function! Info(...)
    if &verbose >= 2
	echo "Info: " . join(a:000)
    endif
    return 1
endfunction

function! SetLastModified()
    " Function to set the modified time in a file
    let cursor_pos = getpos(".")
    call cursor(1, 1)
    let pat = '.*[Ll]ast[ _][Mm]odified[: ]\s*'
    let match_pos = search(pat, 'e')
    let match_str = matchstr(getline(match_pos), pat)
    call setline(match_pos, match_str . strftime('%F %T'))
    call setpos('.', cursor_pos)
endfunction

" bool s:replace(string rep, int line='.', int start=0, int length=strlen)
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
endfunction	" s:replace()

" bool ReplaceSelection(string rep, string expansion=NONE)
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
		\ && c_pos == v_start	" Is it a valid visual selection?
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
endfunction	" ReplaceSelection()

" bool s:dig(string input)
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
	    \ | <line1>,<line2>call ReplaceSelection("s:dig", "<cWORD>")
	    \ | call setpos(".", b:cursor_pos)
map <Leader>dig :DIG<CR>

""" Nagios
autocmd BufNewFile */[Nn][Aa][Gg]**/host**/*.cfg silent! 0r ~/Templates/nag-host.cfg
autocmd BufNewFile */[Nn][Aa][Gg]**/service**/*.cfg silent! 0r ~/Templates/nag-service.cfg
autocmd BufNewFile */[Nn][Aa][Gg]**/templates.cfg silent! 0r ~/Templates/nag-template.cfg
autocmd BufWritePre */[Nn][Aa][Gg]**/*.cfg call SetLastModified()

