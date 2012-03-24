" Python specifics
"""""""""""""""""""""""""

""" fold
function! FoldPython(l)
    let line = getline(a:l)
    if line =~ "^\\s*[\"']\\{3\\}"
	return 1 + float2nr(indent(a:l) / &shiftwidth)
    elseif line == ''
	return -1
    else
	return float2nr(indent(a:l) / &shiftwidth)
    endif
endfunction
setlocal foldmethod=expr foldexpr=FoldPython(v:lnum) 


""""""""""""""""""""""""""""""
" Plugin configuration
"""""""""""""""""""""""""

""" Pydiction
"let g:pydiction_location = '~/.vim/after/pydiction/complete-dict'

""" pyflakes
let g:pyflakes_use_quickfix = 0

""" pep8
let g:pep8_map='<Leader>8'

""" SuperTab
"let g:SuperTabContextDefaultCompletionType = '<c-x><c-o>'

