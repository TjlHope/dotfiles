" diff specifics
"""""""""""""""""""""""""

""" folding
function! DiffFold(lnum)
    let line = getline(a:lnum)
    if line =~ '^diff '
        return 0
    elseif line =~ '^\(---\|+++\|@@\|index\) '
        return 1
    elseif line[0] =~ '[-+ ]'
        return 2
    else
        return 0
    endif
endfunction
setlocal foldmethod=expr foldexpr=DiffFold(v:lnum)

