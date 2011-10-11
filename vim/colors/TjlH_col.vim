" Vim color file
" Maintainer:	TjlH <tjlhope@gmail.com>
" Last Change:	$Date: 2004/06/13 09:20:00 $
" Version:	$Id: TjlH_col.vim,v 0.1 2010/12/07 $

" help screens
" :he group-name
" :he highlight-groups
" :he cterm-colors

set background=dark

if version > 580
    " no guarantees for version 5.8 and below, but this makes it stop
    " complaining
    hi clear
    if exists("syntax_on")
	syntax reset
    endif
endif

let g:colors_name="TjlH_col"

""" gui definitions
"hi Normal	guifg=white guibg=black

" highlight groups
"hi Cursor	guibg=khaki guifg=slategrey
"hi CursorIM
"hi Directory
"hi DiffAdd
"hi DiffChange
"hi DiffDelete
"hi DiffText
"hi ErrorMsg
"hi VertSplit	guibg=#c2bfa5		guifg=grey50		    gui=none
"hi Folded	guibg=grey30		guifg=gold
"hi FoldColumn	guibg=grey30		guifg=tan
"hi IncSearch	guifg=slategrey		guibg=khaki
"hi LineNr
"hi ModeMsg	guifg=goldenrod
"hi MoreMsg	guifg=SeaGreen
"hi NonText	guifg=LightBlue		guibg=grey30
"hi Question	guifg=springgreen
"hi Search	guifg=wheat		guibg=peru 
"hi SpecialKey	guifg=yellowgreen
"hi StatusLine	guifg=black		guibg=#c2bfa5		    gui=none
"hi StatusLineNC	guifg=grey50		guibg=#c2bfa5		    gui=none
"hi Title	guifg=indianred
"hi Visual	guifg=khaki		guibg=olivedrab		    gui=none 
"hi VisualNOS
"hi WarningMsg	guifg=salmon
"hi WildMenu
"hi Menu
"hi Scrollbar
"hi Tooltip

" syntax highlighting groups
"hi Comment	guifg=SkyBlue
"hi Constant	guifg=#ffa0a0
"hi Identifier	guifg=palegreen
"hi Statement	guifg=khaki
"hi PreProc	guifg=indianred
"hi Type		guifg=darkkhaki
"hi Special	guifg=navajowhite
"hi Underlined
"hi Ignore	guifg=grey40
"hi Error
"hi Todo		guifg=orangered		guibg=yellow2

""" color terminal definitions
"" hl-groups
hi Normal	ctermfg=White		ctermbg=none
hi Cursor	ctermfg=Black		ctermbg=Green
"hi CursorIM
"hi CursorColumn
"hi CursorLine				ctermbg=Black
hi Directory	ctermfg=darkCyan
hi DiffAdd				ctermbg=darkBlue
hi DiffChange				ctermbg=darkMagenta
hi DiffDelete	ctermfg=darkBlue	ctermbg=darkCyan	cterm=bold 
hi DiffText				ctermbg=darkRed		cterm=bold 
hi ErrorMsg	ctermfg=White		ctermbg=darkRed		cterm=bold 
hi VertSplit							cterm=reverse
hi Folded	ctermfg=Cyan		ctermbg=none
hi FoldColumn	ctermfg=darkCyan	ctermbg=none
"hi SignColumn
hi IncSearch	ctermfg=Black		ctermbg=lightBlue	cterm=none 
hi LineNr	ctermfg=darkYellow
hi MatchParan	ctermfg=Grey		ctermbg=Blue
hi MoreMsg	ctermfg=Green
hi ModeMsg	ctermfg=Yellow					cterm=none 
hi NonText	ctermfg=darkBlue				cterm=bold 
hi Pmenu	ctermfg=White		ctermbg=darkMagenta
hi PmenuSel	ctermfg=Black		ctermbg=Magenta
hi PmenuSbar				ctermbg=Grey
hi PmenuThumb	ctermfg=White
hi Question	ctermfg=Green
hi Search	ctermfg=darkGray	ctermbg=lightBlue	cterm=none 
hi SpecialKey	ctermfg=darkGreen
hi SpellBad	ctermfg=grey		ctermbg=darkred
"hi SpellCap	ctermfg=
"hi SpellLocal
"hi SpellRare
hi StatusLine							cterm=bold,reverse
hi StatusLineNC							cterm=reverse
"hi TabLine
"hi TabLineFill
"hi TabLineSel
hi Title	ctermfg=darkMagenta
hi Visual				ctermbg=Black		cterm=reverse
hi VisualNOS							cterm=bold,underline
hi WarningMsg	ctermfg=darkRed
hi WildMenu	ctermfg=Black		ctermbg=darkYellow
"" syntax groups
hi Comment	ctermfg=darkCyan
hi Constant	ctermfg=darkYellow
hi String	ctermfg=Red
hi Character	ctermfg=Magenta
hi Number	ctermfg=darkYellow
hi Identifier	ctermfg=Cyan
hi Statement	ctermfg=Yellow
hi Operator	ctermfg=darkYellow
hi PreProc	ctermfg=Magenta
hi Type		ctermfg=Green
hi Special	ctermfg=darkMagenta
hi Underlined	ctermfg=Blue					cterm=underline
hi Ignore	ctermfg=darkGrey
hi Error	ctermfg=White		ctermbg=darkRed		cterm=bold
hi Todo		ctermfg=Black		ctermbg=Yellow

hi CSVColumnHilight	ctermfg=Red
hi CSVHeaderHilight						cterm=reverse
hi CSVColumnEven	ctermfg=Green	
hi CSVColumnOdd		ctermfg=darkGreen	
hi CSVColumnHeaderEven	ctermfg=Black	ctermbg=Green		cterm=bold
hi CSVColumnHeaderOdd	ctermfg=Black	ctermbg=darkGreen	cterm=bold

"vim: sw=4 ts=8
