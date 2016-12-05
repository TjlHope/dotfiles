" xml configuration
"""""""""""""""""""""""""

""" Completion

" Fix SuperTab completion
function! XML_Context()
    " XML context for SuperTab (parsing modified from LatexBox_Complete).
    if &filetype =~? 'x\?\(\(ht\)\?ml\|xs\)'
	" find the starting position of the word
	let line = getline('.')
	let pos = col('.') - 1
	while pos > 0
	    let pos -= 1
            let char = line[pos]
            if char ==# '<'
                return "\<c-x>\<c-o>"
            elseif char =~# '\s'
                break
            endif
	endwhile
    endif
endfunction
call AddUnique(g:SuperTabCompletionContexts, "XML_Context")

