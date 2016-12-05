" LaTeX-Box configuration
"""""""""""""""""""""""""

""" General
" The highlighting screws up 'j' and 'k' movement and slows stuff down.

let g:LatexBox_output_type = "pdf"		" [pdf]
let g:LatexBox_viewer = "zathura"		" [xdg-open]
let g:LatexBox_autojump = 1			" [0]


""" Mappings
"let g:LatexBox_no_mappings
imap <buffer> [[ 		\begin{
imap <buffer> ]]		<Plug>LatexCloseCurEnv
" à la surround.vim... [?]
nmap <buffer> <LocalLeader>cs	<Plug>LatexChangeEnv
vmap <buffer> <LocalLeader>ysc	<Plug>LatexWrapSelection
vmap <buffer> <LocalLeader>yse	<Plug>LatexEnvWrapSelection
"imap <buffer> (( 		\eqref{


""" Folding
let g:LaTeX_fold_sections = 1
let g:LaTeX_fold_paras = 1
let g:LaTeX_fold_envs = 1

function! FoldLaTeX(l)
    let line = getline(a:l)
    let p_line = getline(a:l - 1)
    if line =~# '^\\\(documentclass\|begin{document}\)'
	return '>1'
    endif
    if ! exists("g:LaTeX_fold_sections") || g:LaTeX_fold_sections
	if line =~# '^\s*\\section'
	    return '>2'
	elseif line =~# '^\s*\\subsection'
	    return '>3'
	elseif line =~# '^\s*\\subsubsection'
	    return '>4'
	endif
    endif
    if p_line =~# '^\\documentclass'
	return 1
    elseif p_line =~# '^\\begin{document}'
	" Fold stuff before first \section{}
	return 'a1'
    elseif line =~# '^\\end{document}'
	return '<1'
    endif
    if ! exists("g:LaTeX_fold_envs") || g:LaTeX_fold_envs
	if line =~# '^\s*\\begin'
	    return 'a1'
	elseif line =~# '^\s*\\end'
	    return 's1'
	endif
    endif
    if ! exists("g:LaTeX_fold_paras") || g:LaTeX_fold_paras
	if p_line =~# '^\s*$' && line !~# '^\s*$'
	    return 'a1'
	elseif p_line !~# '^\s*$' && line =~# '^\s*$'
	    return 's1'
	endif
    endif
    return '='
endfunction
setlocal foldmethod=expr foldexpr=FoldLaTeX(v:lnum)
"setlocal foldmethod=indent	" TODO: write a propper one.


""" Indenting
" Completion of env doesn't reindent, so... 
let g:LatexBox_completion_close_braces = 0	" typing '}' will close menu
setlocal indentkeys+=*<CR>	" typing <CR> will reindent current line


""" Completion

" Fix SuperTab completion
function! LatexBox_Context()
    " LaTeX context for SuperTab (parsing extracted from LatexBox_Complete).
    if &filetype ==? 'tex'
	" return the starting position of the word
	let line = getline('.')
	let pos = col('.') - 1
	while pos > 0 && line[pos - 1] !~# '\s\|\\\|{'
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
call AddUnique(g:SuperTabCompletionContexts, "LatexBox_Context")

