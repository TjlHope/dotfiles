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

let &diffopt = s:_diffopt
unlet s:_diffopt
