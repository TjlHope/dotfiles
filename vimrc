""""""""""""""""""""""""""""""
" General settings
"""""""""""""""""""""""""

set nocompatible				" not VI compatible
set vb t_vb=					" disable bell
set listchars=trail:-,nbsp:% 			" characters to display specials
set history=50 					" lines of history to remember
set mouse=a					" always enable mouse input
set timeoutlen=500				" shorter timeout

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
set ruler					" always display cursor position

set number					" set numbering rows
autocmd StdinReadPost * setlocal nonumber	" but not in man

set showtabline=1				" 0:never 1:>1page 2:always
autocmd StdinReadPost * set showtabline=1

set tabpagemax=40				" max number opening tabs = ?

colorscheme TjlH_col
"colorscheme desert
"colorscheme elflord

""" Feel
let mapleader = '`'
noremap! jj <Esc>

noremap <Leader>rv :source $MYVIMRC<CR>
"autocmd BufWritePost **vimrc !source ~/.vimrc	" auto reload vimrc
"autocmd BufWritePost $MYVIMRC : $MYVIMRC

set scrolloff=4					" keep cursor 5 lines from edge
set sidescrolloff=10

set whichwrap=b,s,>,< 				" which movement chars move lines

set incsearch					" search as type
set ignorecase smartcase 			" ignore case except explicit UC

" remove search highlighting
"nohlsearch
nnoremap <silent> <Space> :nohlsearch<CR>

""" quit for buffers
function! ExitBuf(...)
    " function to inteligently close windows and buffers
    if a:0	| let bang = a:1
    else	| let bang = ''
    endif
    " current vars
    let c_b = bufnr("%")			" current buffer
    let c_w = winnr()				" current window
    let c_t = tabpagenr()			" current tabpage
    " control vars
    let o_b = 1					" assume only buffer
    let o_w = 1					" assume only window to buffer
    " find if we're the only listed buffer
    for b_i in range(1, bufnr("$"))		" iterate from first buffer to last
	if buflisted(b_i)			" valid buffer?
	    if b_i != c_b
		let o_b = 0 | break		" not only buffer
	    endif
	endif
    endfor
    " find if we're the only window linked to the  buffer
    for t_i in range(1, tabpagenr("$"))		" iterate by tab and window
	let t_bs = tabpagebuflist(t_i)
	for w_i in range(1, tabpagewinnr(t_i, "$"))
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

command! Bwq :write<Bar>call ExitBuf()
command! Bx :update<Bar>call ExitBuf()
command! -bang Bq :call ExitBuf('<bang>')
nnoremap <silent> ZX :Bx<CR>


""""""""""""""""""""""""""""""
" Style and Syntax
"""""""""""""""""""""""""

syntax on					" enable syntax highlighting
filetype plugin indent on			" enable file type check and indent

""" Tabs
set tabstop=8					" spaces per tab
autocmd Filetype c,cpp setlocal tabstop=4
set softtabstop=8
set shiftwidth=4				" spaces per indent
set noexpandtab					" don't expand tabs to spaces
set smarttab					" at start shiftwidth, else tabstop
autocmd Filetype python setlocal expandtab	" for python 3 compatibility

""" control wrapping
set linebreak 					" wraps without <eol>
autocmd Filetype text setlocal textwidth=0	" overide system vimrc
autocmd Filetype html,tex,text setlocal
	    \ wrapmargin=2
	    \ formatoptions+=aw
autocmd Filetype c,cpp,python setlocal
	    \ textwidth=78
	    \ formatoptions-=r			" don't insert comment on <CR>
	    \ formatoptions-=o			" don't insert comment on o/O
	    \ formatoptions-=l			" auto format long lines
	    \ formatoptions+=aw2		" Auto Wrap on textwidth to 2nd line


""""""""""""""""""""""""""""""
" File Formats
"""""""""""""""""""""""""

set fileformats=unix					" always use Unix file format

autocmd BufRead,BufNewFile *.txt setfiletype text
autocmd BufRead,BufNewFile *.prb setfiletype tex
"autocmd BufRead,BufNewFile *.bib setfiletype bib
autocmd BufRead,BufNewFile */AI/**/*.pl,*/prolog/**/*.pl setfiletype prolog

"autocmd FileType python set bomb			" enable BOM for listend filetypes

let g:tex_flavor='latex'				" use latex styles

""" use skeleton files
autocmd BufNewFile * silent! 0r ~/Templates/%:e.%:e


""""""""""""""""""""""""""""""
" Folding
"""""""""""""""""""""""""

" let $code_types = "c,cpp,css,gentoo-init-d,html,js,php,prolog,python,sh,verilog,vhdl,xml"
"set foldcolumn=5
autocmd Filetype c,cpp,css,gentoo-init-d,html,js,php,prolog,python,sh,verilog,vhdl,vim,xml setlocal
	    \ foldcolumn=5
	    \ foldmethod=indent
	    \ foldlevel=0
	    \ foldlevelstart=2
	    \ foldminlines=1
	    \ foldnestmax=10
autocmd Filetype c,cpp,js setlocal foldignore="#"
autocmd Filetype prolog,vim setlocal foldcolumn=3
"autocmd Filetype python,sh,js,css,html,xml,php,vhdl,verilog set foldignore="#"
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
nmap gw <C-W>
nmap gW <C-W>

""" Quick move buffers
nmap <silent> gb :bnext<CR>
nmap <silent> gB :bprevious<CR>

""" Redifine tag mappings
nnoremap g] g<C-]>
nnoremap g} <C-]>
nnoremap g<C-]> g]
nnoremap g[ <C-T>

noremap <Leader>i <C-i>
noremap <Leader>o <C-o>


""""""""""""""""""""""""""""""
" Spelling
"""""""""""""""""""""""""

" set spell						" enable spell check
" autocmd BufRead *.use,*.conf,*.cfg,*/conf.d/*,*.log,.vimrc set nospell

"autocmd Filetype tex,python,javascript,html,css,php,c,cpp set spell
autocmd Filetype css,html,javascript,php,tex,text setlocal spell
autocmd Filetype help,conf setlocal nospell
autocmd StdinReadPost * setlocal nospell		" but not in man

set spelllang=en_gb					" spell check language to GB
set spellfile=/home/tom/.vim/spell/I.latin1.add		" set my spellfile
autocmd FileType tex setlocal spellfile+=/home/tom/.vim/spell/latex.latin1.add
autocmd BufRead tjh08*.* setlocal spellfile+=/home/tom/.vim/spell/elec.latin1.add

" set dictionary+=/usr/share/dict/words			" add standard words


""""""""""""""""""""""""""""""
" Completion
"""""""""""""""""""""""""

"set wildmenu
set wildmode=longest:list				" bash style file completion

set completeopt=longest,menuone,menu,preview
set complete=.,k,w,b,u,t,i				" add dictionary completion

"set autoindent					" indent new line to same as previous
"set smartindent				" indent on code type

" automatically open and close the popup menu / preview window
"autocmd CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif

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

""" csv
autocmd BufRead,BufNewFile *.?sv setfiletype csv	" Allow for ?sv file editing
"autocmd BufNewFile *.csv let g:csv_delim=','		" set the tsv delimiter to a TAB
"autocmd BufNewFile *.tsv let g:csv_delim='	'	" set the tsv delimiter to a TAB
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
set tags=./.tags;
autocmd BufRead,BufNew */msp430/**/*.c setlocal tags+=~/.vim/tags/msp430
autocmd BufRead,BufNew */avr/**/*.c setlocal tags+=~/.vim/tags/avr
"set tags+=~/.vim/tags/gl
"set tags+=~/.vim/tags/sdl
"autocmd Filetype cpp set tags+=~/.vim/tags/qt4 
"set tags+=~/.vim/tags/gtk-2 

""" easytags
let g:easytags_file = "~/.vim/tags/general"
let g:easytags_by_filetype = "~/.vim/tags/"
"let g:easytags_dynamic_files = 1
let g:easytags_include_members = 1
let g:easytags_autorecurse = 0
let g:easytags_resolve_links = 1
nnoremap <Leader>tu :UpdateTags<CR>
nnoremap <Leader>th :HighlightTags<CR>

""" lusty
set hidden		" just hide abandoned buffers, don't unload
let g:LustyExplorerSuppressHiddenWarning = 1
nnoremap <Leader>j :LustyJuggler<CR>
nnoremap <Leader>p :LustyJugglePrevious<CR>
nnoremap <Leader>e :LustyBufferExplorer<CR>
nnoremap <Leader>f :LustyFilesystemExplorer<CR>

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

""" Screen
let g:ScreenImpl = 'Tmux'
let g:ScreenShellHeight = 10
let g:ScreenShellExpandTabs = 1
noremap <Leader>sh :ScreenShell<CR>
noremap <Leader>sv :ScreenShell<CR>
noremap <Leader>sb :ScreenShell bash<CR>
noremap <Leader>sd :ScreenShell dash<CR>
noremap <Leader>sp :ScreenShell python<CR>
noremap <Leader>si :ScreenShell ipython<CR>
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
autocmd Filetype python
	    \ let g:SuperTabContextDefaultCompletionType = '<c-x><c-o>'
let g:SuperTabMidWordCompletion = 1
let g:SuperTabRetainCompletionDuration = 'completion'
let g:SuperTabNoCompletionAfter = ['\s', ',', ';', '|', '&']
let g:SuperTabLongestEnhanced = 1
let g:SuperTabLongestHighlight = 0
let g:SuperTabCrMapping = 1

""" TagList
noremap <Leader>tl :TlistToggle<CR>

""" txtfmt
autocmd FileType *.tft setlocal filetype=text.txtfmt
autocmd FileType *.tft.?,*.tft.??,*.tft.???,*.tft.???? setlocal filetype+=.txtfmt

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

" use stronger encryption
set cryptmethod="blowfish"

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

function! ResolveIP(input)
    let strs = split(system("resolveip " . shellescape(a:input)), "\n")
    let matches = []
    for str in strs
	let match = matchlist(str, escape(a:input, '.') . '.[i:]s\? \(.*\)')
	if len(match) > 1
	    call add(matches, match[1])
	else
	    return resolved_str
	endif
    endfor
    return join(matches)
endfunction
function! LineResolveIP()
    let input = substitute(getline('.'), '^\s*', '', '')
    let output = ResolveIP(input)
    call setline('.', output)
endfunction
map <Leader>rip WBEa<CR><Esc>Bi<CR><Esc>:call LineResolveIP()<CR>kJJ
vmap <Leader>rip <Esc>`>a<CR><Esc>`<i<CR><Esc>:call LineResolveIP()<CR>kJJ

""" Nagios
autocmd BufNewFile */[Nn][Aa][Gg]**/host**/*.cfg silent! 0r ~/Templates/nag-host.cfg
autocmd BufNewFile */[Nn][Aa][Gg]**/service**/*.cfg silent! 0r ~/Templates/nag-service.cfg
autocmd BufNewFile */[Nn][Aa][Gg]**/templates.cfg silent! 0r ~/Templates/nag-template.cfg
autocmd BufWritePre */[Nn][Aa][Gg]**/*.cfg call SetLastModified()

