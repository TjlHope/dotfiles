" Configuration for AutomaticLaTexPlugin
""""""""""""""""""""""""""""""""""""""""""

""" default values for a variable are given in brackets [] after the comment.

"let b:atp_TexCompiler = "pdflatex"	" ["pdflatex"]

let b:atp_updatetime_normal = 4000	" [2000] play nice with easytags
let b:atp_updatetime_insert = 0		" [4000] don't compile in insert mode

let g:atp_ProjectScript = 0		" [1] Disable Local Project files
let g:atp_TempDir = $SHM		" Dir for temporary compilation files

"let b:atp_Viewer = "xpdf"		" Xpdf for viewer (no vim->mupdf :( ) 
let b:atp_Viewer = "zathura"		" Xpdf has become deprecated...
"let b:atp_OpenViewer = 1		" [1] open viewer after compilation
let g:atp_LogSync = 1			" [0] sync source file with log
"let g:atp_SyncXpdfLog = 1		" [0] sync Xpdf with log

let g:atp_folding = 1			" [0] Enable folding
let g:atp_fold_environments = 1		" [0] Enable environment folding

" atp maps {rhs} to gw, defining here prevents conflict with my window maps
nnoremap gW m`vipgq``

" fix completion for SuperTab
let g:atp_check_if_math_mode = 1		" only do $$ comps in $$
set omnifunc=atplib#complete#TabCompletion
let g:atp_tab_map = 0			" prevent SuperTab conflict

