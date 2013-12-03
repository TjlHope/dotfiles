" csv specifics
"""""""""""""""""""""""""

" highlight groups
hi CSVColumnHilight	ctermfg=Red
hi CSVHeaderHilight						cterm=reverse
hi CSVColumnEven	ctermfg=Green
hi CSVColumnOdd		ctermfg=darkGreen
hi CSVColumnHeaderEven	ctermfg=Black	ctermbg=Green		cterm=bold
hi CSVColumnHeaderOdd	ctermfg=Black	ctermbg=darkGreen	cterm=bold

" fix highlighting problems
autocmd BufLeave <buffer> call clearmatches()

""" Plugin Settings
let g:csv_highlight_column = 'y'
let g:csv_hiGroup = "CSVColumnHilight"
let g:csv_hiHeader = "CSVHeaderHilight"
let g:csv_no_conceal = 1

""" Mappings
nmap <LocalLeader>h	:Header<CR>
nmap <LocalLeader>H	:Header!<CR>
nmap <LocalLeader>ch	:HiColumn<CR>
nmap <LocalLeader>cH	:HiColumn!<CR>
nmap <LocalLeader>dc	:DeleteColumn<CR>
nmap <LocalLeader>rc	:InitCSV<CR>

