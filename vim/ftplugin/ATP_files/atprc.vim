" Configuration for AutomaticLaTexPlugin
""""""""""""""""""""""""""""""""""""""""""

""" default values for a variable are given in brackets [] after the comment.

"let b:atp_TexCompiler = "pdflatex"	" ["pdflatex"]

let b:atp_updatetime_normal = 4000	" [2000] play nice with easytags
let b:atp_updatetime_insert = 0		" [4000] don't compile in insert mode

let g:atp_ProjectScript = 0		" [1] Disable Local Project files
let g:atp_TempDir = '/dev/shm/'		" Dir for temporary compilation files

let b:atp_Viewer = "xpdf"		" use Xpdf for viewing
"let b:atp_OpenViewer = 1		" [1] open viewer after compilation
let g:atp_LogSync = 1			" [0] sync source file with log
let g:atp_SyncXpdfLog = 1		" [0] sync Xpdf with log

let g:atp_folding = 1			" [0] Enable folding
let g:atp_fold_environments = 1		" [0] Enable environment folding

" The highlighting screws up 'j' and 'k' movement and slows stuff down.
augroup LatexBox_HighlightPairs 
    au!
augroup END

" atp maps {rhs} to gw, defining here prevents conflict with my window maps
nnoremap gW m`vipgq``

" fix completion for SuperTab
let g:atp_no_tab_map = 1		" prevent SuperTab conflict
let g:SuperTabCompletionContexts += ['LatexBox_Context']

function! LatexBox_Context()
    if &filetype == 'tex'
	" return the starting position of the word
	let line = getline('.')
	let pos = col('.') - 1
	while pos > 0 && line[pos - 1] !~ '\s\|\\\|{'
	    let pos -= 1
	endwhile
	if line[pos - 2] == '{'
	    pos -= 1
	endif
	let char = line[pos - 1]
	if char == '\'
	    return "\<c-x>\<c-o>"
	elseif char == '{'
	    let line_start = line[:(pos - 1)]
	    if (line_start =~ '\C\\\(begin\|end\)\_\s*{$' ||
		    \ line_start =~ g:LatexBox_ref_pattern . '$' ||
		    \ line_start =~ g:LatexBox_cite_pattern . '$')
		return "\<c-x>\<c-o>"
	    endif
	endif
    endif
endfunction

