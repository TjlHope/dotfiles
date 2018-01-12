if exists("g:apiblueprint_folding") && !exists("g:markdown_folding")
    let g:markdown_folding = g:apiblueprint_folding
endif
runtime! ftplugin/markdown.vim
