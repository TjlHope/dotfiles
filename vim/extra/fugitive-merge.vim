" 4-way diff setup using fugitive as a git mergetool
"
" +-----------+----------------------+------------+
" |           |                      |            |
" | HEAD (:2) | common ancestor (:1) | merge (:3) |
" |           |                      |            |
" +-----------+----------------------+------------+
" |                 working copy                  |
" +-----------------------------------------------+

" Gs and Gv diff don't seem to override diffopt vertical/horizontal
let s:_diffopt = &diffopt
set diffopt-=vertical
set diffopt-=horizontal

Gsdiff :1
exe 1 . "wincmd w"
Gvdiff!
call feedkeys(winnr()."\<C-W>jgg", 'n')

" create mappings by default
if !exists('g:fugitive_merge_maps') || g:fugitive_merge_maps
    " working copy is always buffer 1
    noremap dp  :diffput 1<CR>
    " common-ancestor always contains //1
    noremap dg1 :diffget //1<CR>
    " target always contains //2
    noremap dg2 :diffget //2<CR>
    " merge always contains //3
    noremap dg3 :diffget //3<CR>
endif


let &diffopt = s:_diffopt
unlet s:_diffopt
