" Vim syntax file
" Language:	X Pixmap
" Maintainer:	Ronald Schild <rs@scutum.de>
" Last Change:	2008 May 28
" Version:	5.4n.1
" Modified to work with terminals with 88 or 256 color support.

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn keyword xpmType		char
syn keyword xpmStorageClass	static
syn keyword xpmTodo		TODO FIXME XXX  contained
syn region  xpmComment		start="/\*"  end="\*/"  contains=xpmTodo
syn region  xpmPixelString	start=+"+  skip=+\\\\\|\\"+  end=+"+  contains=@xpmColors

"if has("gui_running")
if has("gui_running") || &t_Co == 88 || &t_Co == 256

" I have taken the functions for the programmatic approximation of the gui 
" colors to the palettes of 88- and " 256- color xterms from the desert256 
" colorscheme. {{{
    fun <SID>grey_number(x)
        if &t_Co == 88
            if a:x < 23
                return 0
            elseif a:x < 69
                return 1
            elseif a:x < 103
                return 2
            elseif a:x < 127
                return 3
            elseif a:x < 150
                return 4
            elseif a:x < 173
                return 5
            elseif a:x < 196
                return 6
            elseif a:x < 219
                return 7
            elseif a:x < 243
                return 8
            else
                return 9
            endif
        else
            if a:x < 14
                return 0
            else
                let l:n = (a:x - 8) / 10
                let l:m = (a:x - 8) % 10
                if l:m < 5
                    return l:n
                else
                    return l:n + 1
                endif
            endif
        endif
    endfun
    " returns the actual grey level represented by the grey index
    fun <SID>grey_level(n)
        if &t_Co == 88
            if a:n == 0
                return 0
            elseif a:n == 1
                return 46
            elseif a:n == 2
                return 92
            elseif a:n == 3
                return 115
            elseif a:n == 4
                return 139
            elseif a:n == 5
                return 162
            elseif a:n == 6
                return 185
            elseif a:n == 7
                return 208
            elseif a:n == 8
                return 231
            else
                return 255
            endif
        else
            if a:n == 0
                return 0
            else
                return 8 + (a:n * 10)
            endif
        endif
    endfun
    " returns the palette index for the given grey index
    fun <SID>grey_color(n)
        if &t_Co == 88
            if a:n == 0
                return 16
            elseif a:n == 9
                return 79
            else
                return 79 + a:n
            endif
        else
            if a:n == 0
                return 16
            elseif a:n == 25
                return 231
            else
                return 231 + a:n
            endif
        endif
    endfun
    " returns an approximate color index for the given color level
    fun <SID>rgb_number(x)
        if &t_Co == 88
            if a:x < 69
                return 0
            elseif a:x < 172
                return 1
            elseif a:x < 230
                return 2
            else
                return 3
            endif
        else
            if a:x < 75
                return 0
            else
                let l:n = (a:x - 55) / 40
                let l:m = (a:x - 55) % 40
                if l:m < 20
                    return l:n
                else
                    return l:n + 1
                endif
            endif
        endif
    endfun
    " returns the actual color level for the given color index
    fun <SID>rgb_level(n)
        if &t_Co == 88
            if a:n == 0
                return 0
            elseif a:n == 1
                return 139
            elseif a:n == 2
                return 205
            else
                return 255
            endif
        else
            if a:n == 0
                return 0
            else
                return 55 + (a:n * 40)
            endif
        endif
    endfun
    " returns the palette index for the given R/G/B color indices
    fun <SID>rgb_color(x, y, z)
        if &t_Co == 88
            return 16 + (a:x * 16) + (a:y * 4) + a:z
        else
            return 16 + (a:x * 36) + (a:y * 6) + a:z
        endif
    endfun
    " returns the palette index to approximate the given R/G/B color levels
    fun <SID>color(r, g, b)
        " get the closest grey
        let l:gx = <SID>grey_number(a:r)
        let l:gy = <SID>grey_number(a:g)
        let l:gz = <SID>grey_number(a:b)

        " get the closest color
        let l:x = <SID>rgb_number(a:r)
        let l:y = <SID>rgb_number(a:g)
        let l:z = <SID>rgb_number(a:b)

        if l:gx == l:gy && l:gy == l:gz
            " there are two possibilities
            let l:dgr = <SID>grey_level(l:gx) - a:r
            let l:dgg = <SID>grey_level(l:gy) - a:g
            let l:dgb = <SID>grey_level(l:gz) - a:b
            let l:dgrey = (l:dgr * l:dgr) + (l:dgg * l:dgg) + (l:dgb * l:dgb)
            let l:dr = <SID>rgb_level(l:gx) - a:r
            let l:dg = <SID>rgb_level(l:gy) - a:g
            let l:db = <SID>rgb_level(l:gz) - a:b
            let l:drgb = (l:dr * l:dr) + (l:dg * l:dg) + (l:db * l:db)
            if l:dgrey < l:drgb
                " use the grey
                return <SID>grey_color(l:gx)
            else
                " use the color
                return <SID>rgb_color(l:x, l:y, l:z)
            endif
        else
            " only one possibility
            return <SID>rgb_color(l:x, l:y, l:z)
        endif
    endfun
    " returns the palette index to approximate the 'rrggbb' hex string
    fun <SID>rgb(rgb)
        " Strip optional # at start.
	let l:c = substitute(a:rgb, '^#', '', '')
        let l:r = ("0x" . strpart(l:c, 0, 2)) + 0
        let l:g = ("0x" . strpart(l:c, 2, 2)) + 0
        let l:b = ("0x" . strpart(l:c, 4, 2)) + 0

        return <SID>color(l:r, l:g, l:b)
    endfun
    " sets the highlighting for the given group
    fun <SID>X(group, fg, bg, attr)
        if a:fg != ""
            exec "hi " . a:group . " guifg=" . a:fg . " ctermfg=" . <SID>rgb(a:fg)
        endif
        if a:bg != ""
            exec "hi " . a:group . " guibg=" . a:bg . " ctermbg=" . <SID>rgb(a:bg)
        endif
        if a:attr != ""
            exec "hi " . a:group . " gui=" . a:attr . " cterm=" . a:attr
        endif
    endfun
    " }}}

let color  = ""
let chars  = ""
let colors = 0
let cpp    = 0
let n      = 0
let i      = 1

while i <= line("$")		" scanning all lines

   let s = matchstr(getline(i), '".\{-1,}"')
   if s != ""			" does line contain a string?

      if n == 0			" first string is the Values string

	 " get the 3rd value: colors = number of colors
	 let colors = substitute(s, '"\s*\d\+\s\+\d\+\s\+\(\d\+\).*"', '\1', '')
	 " get the 4th value: cpp = number of character per pixel
	 let cpp = substitute(s, '"\s*\d\+\s\+\d\+\s\+\d\+\s\+\(\d\+\).*"', '\1', '')
	 if cpp =~ '[^0-9]'
	    break  " if cpp is not made of digits there must be something wrong
	 endif

	 " Highlight the Values string as normal string (no pixel string).
	 " Only when there is no slash, it would terminate the pattern.
	 if s !~ '/'
	    exe 'syn match xpmValues /' . s . '/'
	 endif
	 hi link xpmValues String

	 let n = 1		" n = color index

      elseif n <= colors	" string is a color specification

	 " get chars = <cpp> length string representing the pixels
	 " (first incl. the following whitespace)
	 let chars = substitute(s, '"\(.\{'.cpp.'}\s\).*"', '\1', '')

	 " now get color, first try 'c' key if any (color visual)
	 let color = substitute(s, '".*\sc\s\+\(.\{-}\)\s*\(\(g4\=\|[ms]\)\s.*\)*\s*"', '\1', '')
	 if color == s
	    " no 'c' key, try 'g' key (grayscale with more than 4 levels)
	    let color = substitute(s, '".*\sg\s\+\(.\{-}\)\s*\(\(g4\|[ms]\)\s.*\)*\s*"', '\1', '')
	    if color == s
	       " next try: 'g4' key (4-level grayscale)
	       let color = substitute(s, '".*\sg4\s\+\(.\{-}\)\s*\([ms]\s.*\)*\s*"', '\1', '')
	       if color == s
		  " finally try 'm' key (mono visual)
		  let color = substitute(s, '".*\sm\s\+\(.\{-}\)\s*\(s\s.*\)*\s*"', '\1', '')
		  if color == s
		     let color = ""
		  endif
	       endif
	    endif
	 endif

	 " Vim cannot handle RGB codes with more than 6 hex digits
	 if color =~ '#\x\{10,}$'
	    let color = substitute(color, '\(\x\x\)\x\x', '\1', 'g')
	 elseif color =~ '#\x\{7,}$'
	    let color = substitute(color, '\(\x\x\)\x', '\1', 'g')
	 " nor with 3 digits
	 elseif color =~ '#\x\{3}$'
	    let color = substitute(color, '\(\x\)\(\x\)\(\x\)', '0\10\20\3', '')
	 endif

	 " escape meta characters in patterns
	 let s = escape(s, '/\*^$.~[]')
	 let chars = escape(chars, '/\*^$.~[]')

	 " now create syntax items
	 " highlight the color string as normal string (no pixel string)
	 exe 'syn match xpmCol'.n.'Def /'.s.'/ contains=xpmCol'.n.'inDef'
	 exe 'hi link xpmCol'.n.'Def String'

	 " but highlight the first whitespace after chars in its color
	 exe 'syn match xpmCol'.n.'inDef /"'.chars.'/hs=s+'.(cpp+1).' contained'
	 exe 'hi link xpmCol'.n.'inDef xpmColor'.n

	 " remove the following whitespace from chars
	 let chars = substitute(chars, '.$', '', '')

	 " and create the syntax item contained in the pixel strings
	 exe 'syn match xpmColor'.n.' /'.chars.'/ contained'
	 exe 'syn cluster xpmColors add=xpmColor'.n

	 " if no color or color = "None" show background
	 if color == ""  ||  substitute(color, '.*', '\L&', '') == 'none'
	    exe 'hi xpmColor'.n.' guifg=bg'
	    exe 'hi xpmColor'.n.' guibg=NONE'
	 elseif color !~ "'"
	    call <SID>X('xpmColor'.n, color, color, "")
	    "exe 'hi xpmColor'.n." guifg='".color."'"
	    "exe 'hi xpmColor'.n." guibg='".color."'"
	 endif
	 let n = n + 1
      else
	 break		" no more color string
      endif
   endif
   let i = i + 1
endwhile

unlet color chars colors cpp n i s

"endif		" has("gui_running")
endif		" has("gui_running") || &t_Co == 88 || &t_Co == 256

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_xpm_syntax_inits")
  if version < 508
    let did_xpm_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink xpmType		Type
  HiLink xpmStorageClass	StorageClass
  HiLink xpmTodo		Todo
  HiLink xpmComment		Comment
  HiLink xpmPixelString	String

  delcommand HiLink
endif

let b:current_syntax = "xpm"

" vim: ts=8:sw=3:noet:
