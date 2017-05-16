" java class file viewing
"""""""""""""""""""""""""

echom "start"
if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1

echom "readonly"
set readonly
if executable("kracatau")
    echom "executable"
    let filename = '%'
    echom expand(filename)
    if expand(filename)[0:7] == "zipfile:"
        let filename = tempname()
        echom expand('%')
        execute "silent" "write" filename
        echom expand('%')
    endif
    execute "silent" "%!kracatau" "decompile" "-out -" filename
    set ft=java
    silent normal gg=G
    set nomodified
endif

