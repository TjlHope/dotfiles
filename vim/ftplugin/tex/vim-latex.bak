""""""""""""""""""""""""""""""""""""""""
""" TjlH settings for the 
""" latex-suite ftplugin
""""""""""""""""""""""""""""""""""""""""

" Remap <C-j> to <C-space>
imap <C-space> <Plug>IMAP_JumpForward			

au BufWritePost tex call Tex_CompileMultipleTimes()

let g:Tex_DefaultTargetFormat = 'dvi'
let g:Tex_CompileRule_dvi = 'latex -src-specials -interaction=batchmode $*'
let g:Tex_CompileRule_pdf = 'pdflatex -interaction=batchmode $*'
let g:Tex_ViewRule_dvi = "xdvi"
let g:Tex_ViewRule_pdf = 'xpdf -remote LaTeX '
let g:Tex_MultipleCompileFormats = 'dvi,pdf'
"let g:Tex_IgnoredWarnings =
	"\'Underfull'."\n".
	"\'Overfull'."\n".
	"\'specifier changed to'."\n".
	"\'You have requested'."\n".
	"\'Missing number, treated as zero.'."\n".
	"\'There were undefined references'."\n".
	"\'Citation %.%# undefined'
"TexLet g:Tex_IgnoreLevel = 7

