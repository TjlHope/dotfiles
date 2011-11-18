" Configuration for AutomaticLaTexPlugin
""""""""""""""""""""""""""""""""""""""""

"let b:atp_TexCompiler = "pdflatex"	" ["pdflatex"]

let b:atp_updatetime_normal = 4000	" play nice with easytags [2000]
let b:atp_updatetime_insert = 0		" don't compile in insert mode [4000]

let b:atp_Viewer = "xpdf"		" use Xpdf for viewing
"let b:atp_OpenViewer = 1		" open viewer after compilation [1]
let g:atp_LogSync = 1			" sync source file with log [0]
let g:atp_SyncXpdfLog = 1		" sync Xpdf with log [0]

let g:atp_folding = 1			" Enable folding [0]
let g:atp_fold_environments = 1		" Enable environment folding [0]

