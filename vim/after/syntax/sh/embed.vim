""""""""""""""""""""""""""""""
" Embed scripts in sh
"""""""""""""""""""""""""

if !exists("sh_syn_embed")
    finish
endif
if !exists("s:sh_fold_heredoc")
    let s:sh_fold_heredoc  = and(g:sh_fold_enabled,2)
endif

""" awk
if sh_syn_embed =~ 'a'
    if exists("b:current_syntax")
        unlet b:current_syntax
    endif
    syn include @AWKScript syntax/awk.vim
    syn region AWKScriptSingleQuoteCode matchgroup=AWKCommand
                \ start=+[=\\]\@<!'+ end=+'+
                \ contains=@AWKScript contained
    syn region AWKScriptDoubleQuoteCode matchgroup=AWKCommand
                \ start=+[=\\]\@<!"+ skip=+\\"+ end=+"+
                \ contains=@shDblQuoteList,shStringSpecial,@AWKScript contained
    syn region AWKScriptEmbedded matchgroup=AWKCommand
                \ start=+\<awk\>+ skip=+\\$+ end=+[=\\]\@<!['"]+me=e-1
                \ contains=@shIdList,@shExprList2
                \ nextgroup=AWKScriptSingleQuoteCode,AWKScriptDoubleQuoteCode
    syn cluster shCommandSubList add=AWKScriptEmbedded
    hi def link AWKCommand Keyword
endif

""" sed
if sh_syn_embed =~ 's'
    if exists("b:current_syntax")
        unlet b:current_syntax
    endif
    syn include @SEDScript syntax/sed.vim
    syn region SEDScriptSingleQuoteCode matchgroup=SEDCommand
                \ start=+[=\\]\@<!'+ end=+'+
                \ contains=@SEDScript contained
    syn region SEDScriptDoubleQuoteCode matchgroup=SEDCommand
                \ start=+[=\\]\@<!"+ skip=+\\"+ end=+"+
                \ contains=@shDblQuoteList,shStringSpecial,@SEDScript contained
    syn region SEDScriptEmbedded matchgroup=SEDCommand
                \ start=+\<sed\>+ skip=+\\$+ end=+[=\\]\@<!['"]+me=e-1
                \ contains=@shIdList,@shExprList2
                \ nextgroup=SEDScriptSingleQuoteCode,SEDScriptDoubleQuoteCode
    syn cluster shCommandSubList add=SEDScriptEmbedded
    hi def link SEDCommand Keyword
endif

""" perl
if sh_syn_embed =~ 'p'
    if exists("b:current_syntax")
        unlet b:current_syntax
    endif
    syn include @PLScript syntax/perl.vim
    syn region PLScriptSingleQuoteCode matchgroup=shQuote
                \ start=+[=\\]\@<!'+ end=+'+
                \ contains=@PLScript contained
    syn region PLScriptDoubleQuoteCode matchgroup=shQuote
                \ start=+"+ skip=+\\"+ end=+"+
                \ contains=@shDblQuoteList,shStringSpecial,@PLScript contained
    syn match  PLOptE +\s-[a-zA-Z0-9]*[eE]\s*+
                \ nextgroup=PLScriptSingleQuoteCode,PLScriptDoubleQuoteCode
                \ contained
    syn region PLScriptEmbedded matchgroup=PLCommand
                \ start=+\<perl\>+ skip=+\\$+ end=+\ze\s-[a-zA-Z0-9]*[eE]\>+
                \ contains=@shIdList,@shExprList2
                \ nextgroup=PLOptE "PLScriptSingleQuoteCode,PLScriptDoubleQuoteCode
    syn cluster shCommandSubList add=PLScriptEmbedded
    hi def link PLCommand Keyword
    hi def link PLOptE shOption
endif

""" python
if sh_syn_embed =~ 'P'
    if exists("b:current_syntax")
        unlet b:current_syntax
    endif
    syn include @PYScript syntax/python.vim
    syn region PYScriptSingleQuoteCode matchgroup=PYCommand
                \ start=+[=\\]\@<!'+		end=+'+
                \ contains=@PYScript contained
    syn region PYScriptDoubleQuoteCode matchgroup=PYCommand
                \ start=+[=\\]\@<!"+ skip=+\\"+	end=+"+
                \ contains=@shDblQuoteList,shStringSpecial,@PYScript contained
    " Note: there are some more complex heare doc starts that I havn't
    " included, as I never use them...
    if s:sh_fold_heredoc
        syn region PYScriptHereDoc matchgroup=PYHereDoc fold 
                    \ start="<<\s*\z([^ \t|]*\)"	end="^\z1\s*$"
                    \ contains=@shDblQuoteList,@PYScript contained
        syn region PYScriptHereDoc matchgroup=PYHereDoc fold
                    \ start="<<\s*\"\z([^ \t|]*\)\""	end="^\z1\s*$"
                    \ contains=@PYScript contained
        syn region PYScriptHereDoc matchgroup=PYHereDoc fold
                    \ start="<<\s*'\z([^ \t|]*\)'"	end="^\z1\s*$"
                    \ contains=@PYScript contained
        syn region PYScriptHereDoc matchgroup=PYHereDoc fold
                    \ start="<<-\s*\z([^ \t|]*\)"	end="^\s*\z1\s*$"
                    \ contains=@shDblQuoteList,@PYScript contained
        syn region PYScriptHereDoc matchgroup=PYHereDoc fold
                    \ start="<<-\s*\"\z([^ \t|]*\)\""	end="^\s*\z1\s*$"
                    \ contains=@PYScript contained
        syn region PYScriptHereDoc matchgroup=PYHereDoc fold
                    \ start="<<-\s*'\z([^ \t|]*\)'"	end="^\s*\z1\s*$"
                    \ contains=@PYScript contained
        syn region PYScriptHereDoc matchgroup=PYHereDoc fold
                    \ start="<<\\\z([^ \t|]*\)"		end="^\z1\s*$"
                    \ contains=@PYScript contained
    else
        syn region PYScriptHereDoc matchgroup=PYHereDoc
                    \ start="<<\s*\\\=\z([^ \t|]*\)"	end="^\z1\s*$"
                    \ contains=@shDblQuoteList,@PYScript contained
        syn region PYScriptHereDoc matchgroup=PYHereDoc
                    \ start="<<\s*\"\z([^ \t|]*\)\""	end="^\z1\s*$"
                    \ contains=@PYScript contained
        syn region PYScriptHereDoc matchgroup=PYHereDoc
                    \ start="<<\s*'\z([^ \t|]*\)'"	end="^\z1\s*$"
                    \ contains=@PYScript contained
        syn region PYScriptHereDoc matchgroup=PYHereDoc
                    \ start="<<-\s*\z([^ \t|]*\)"	end="^\s*\z1\s*$"
                    \ contains=@shDblQuoteList,@PYScript contained
        syn region PYScriptHereDoc matchgroup=PYHereDoc
                    \ start="<<-\s*\"\z([^ \t|]*\)\""	end="^\s*\z1\s*$"
                    \ contains=@PYScript contained
        syn region PYScriptHereDoc matchgroup=PYHereDoc
                    \ start="<<-\s*'\z([^ \t|]*\)'"	end="^\s*\z1\s*$"
                    \ contains=@PYScript contained
        syn region PYScriptHereDoc matchgroup=PYHereDoc
                    \ start="<<\\\z([^ \t|]*\)"		end="^\z1\s*$"
                    \ contains=@PYScript contained
    endif
    syn region PYScriptEmbedded matchgroup=PYCommand
                \ start=+\<python[23]\?\>+ skip=+\\$+ end=+[=\\]\@<!-c\s*['"]+me=e-1
                \                               end=+[=\\]\@<!<<+me=e-2
                \ contains=@shIdList,@shExprList2
                \ nextgroup=PYScriptSingleQuoteCode,PYScriptDoubleQuoteCode,PYScriptHereDoc
    syn cluster shCommandSubList add=PYScriptEmbedded
    hi def link PYCommand Keyword
    hi def link PYHereDoc shRedir
endif

