" 4-way diff setup using fugitive as a git mergetool
"
" +-----------+----------------------+------------+
" |           |                      |            |
" | HEAD (:2) | common ancestor (:1) | merge (:3) |
" |           |                      |            |
" +-----------+----------------------+------------+
" |                 working copy                  |
" +-----------------------------------------------+
"
"
Gsdiff :1
exe 1 . "wincmd w"
Gvdiff!
call feedkeys(winnr()."\<C-W>jgg", 'n')

