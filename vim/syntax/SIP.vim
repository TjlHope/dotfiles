" Syntax file for ngrep or tcpdump capture of SIP traffic
" (-qtt -W byline|port 5060)
" Language:	sip packets
" Last Change:	14 July 2008
" Maintainer:	Stanisław Pitucha <viraptor@gmail.com>
" License:	This file is placed in the public domain.

if exists("b:current_syntax")
	finish
endif

set foldmethod=syntax
set foldlevel=0
set foldcolumn=3

set foldtext=SipNgrepFolding()
function! SipNgrepFolding()
	if (v:foldlevel > 1)
		let line = getline(v:foldstart)
		" replace tabs with correct number of spaces
		let split_line = split(line, '	', 1)
		let [line; split_line] = split_line
		for item in split_line
			let line .= repeat(' ', (&tabstop - (strlen(line) % &tabstop))) . item
		endfor
		return line
	endif
	let ips = matchstr(getline(v:foldstart), '\(\d\+\.\d\+\.\d\+\.\d\+\|\S\+ \[\d\+\.\d\+\.\d\+\.\d\+\]\|[-a-zA-Z0-9\.]\+\)\(:\d\+\|\.[a-z-]\+\) -\?> \(\d\+\.\d\+\.\d\+\.\d\+\|\S\+ \[\d\+\.\d\+\.\d\+\.\d\+\]\|[-a-zA-Z0-9\.]\+\)\(:\d\+\|\.[a-z-]\+\)')
	let method = getline(v:foldstart+1)
	return ips . ' *** ' . method
endfunction

syn case ignore

syn cluster	sipErrors	contains=sipNoUser,sipNoHost,sipInternalIp

syn region	sipPacket	matchgroup=sipPacketHeader
			\ start='^[TU]\( .*\)\? \(\d\+\.\d\+\.\d\+\.\d\+\|\S\+ \[\d\+\.\d\+\.\d\+\.\d\+\]\):\d\+ -> \(\d\+\.\d\+\.\d\+\.\d\+\|\S\+ \[\d\+\.\d\+\.\d\+\.\d\+\]\):\d\+'
			\ end='^$' keepend transparent fold
			\ contains=sipPacketIP,sipRequest,sipResponse,sipHeaders,sipBody
syn region	sipPacket	matchgroup=sipPacketHeader
			\ start='^\d\d:\d\d:\d\d.\d\+ IP (.*) \(\d\+\.\d\+\.\d\+\.\d\+\|[-a-zA-Z0-9\.]\+\)\(:\d\+\|\.[a-z-]\+\) > \(\d\+\.\d\+\.\d\+\.\d\+\|[-a-zA-Z0-9\.]\+\)\(:\d\+\|\.[a-z-]\+\).*'
			\ end='^\t$' keepend transparent fold
			\ contains=sipPacketIP,sipRequest,sipResponse,sipHeaders,sipBody

syn match	sipPacketIP	'\(\d\+\.\d\+\.\d\+\.\d\+\|\S\+ \[\d\+\.\d\+\.\d\+\.\d\+\]\)\(:\d\+\|\.[a-z-]\+\)' contained


syn match	sipRequest	'^\t\?\zs[A-Z]\+ .\+ SIP/2\.0\.$' contained contains=sipMethod,sipMethodErr
" highlight unknown methods
syn match	sipMethodErr	'^\t\?\zs[A-Z]\+[ ]\@=' contained
syn match	sipMethod	'^\t\?\zs\(INVITE\|REFER\|ACK\|PRACK\|OPTIONS\|NOTIFY\|SUBSCRIBE\|PUBLISH\|BYE\|REGISTER\|CANCEL\|INFO\|UPDATE\)[ ]\@=' contained

syn match	sipResponse	'^\t\?\zsSIP/2\.0 \d\{3} .*$' contained contains=sipResonseErr
" highlight bad status
syn match	sipResonseErr	'^\t\?\zsSIP/2\.0\s\+[456]\d\d\s.*$' contained


syn region	sipHeaders	start='^\t[-a-zA-Z_]\+\s*:' end='^\t$' contained extend fold
			\ contains=sipHdr,sipKeyHdr,sipAddressDesc,sipAddress,@sipErrors
syn region	sipHeaders	start='^[-a-zA-Z_]\+\s*:' end='^\.$' contained fold
			\ contains=sipHdr,sipKeyHdr,sipAddressDesc,sipAddress,@sipErrors

syn match	sipHdr		'^\t\?\zs[-a-zA-Z_]\+\s*:' contained
syn match	sipKeyHdr	'^\t\?\zs\(From\|To\|Via\|Contact\|Call-Id\|Record-Route\|Route\)\s*:' contained

syn match	sipAddressDescr	'^\t\?\(From\|To\)\s*:\s*\zs"[^"]*"' contained

syn match	sipAddress	'sip:[0-9a-z_]\+@\(\d\+\.\d\+.\d\+.\d\+\|[a-zA-z0-9\.-]\+\)\(:\d\+\)' contained contains=sipNumber
syn match	sipNumber	'[0-9a-z_]\+' contained


syn region	sipBody		start='^\.$' end='^$' contained fold contains=sipInternalIp
syn region	sipBody		start='^\t$' end='^\t$' contained fold contains=sipInternalIp

" general errors (potential)
syn match	sipNoUser	'sip:@[a-zA-Z0-9\.]*' contained
syn match	sipNoHost	'sip:\S\+@[a-zA-Z0-9]\@!' contained
syn match	sipInternalIp	'\<\(10\|127\)\(\.[0-9]\{1,3\}\)\{3}\>' contained
syn match	sipInternalIp	'\<192\.168\(\.[0-9]\{1,3\}\)\{2}\>' contained
syn match	sipInternalIp	'\<172\.\(1[6-9]\|2[0-9]\|3[01]\)\(\.[0-9]\{1,3\}\)\{2}\>' contained

hi def link sipPacketHeader	Comment
hi def link sipPacketIP		Constant
hi def link sipNumber		Number
hi def link sipHdr		String
hi def link sipKeyHdr		Define
hi def link sipAddressDescr	String
hi def link sipMethod		Identifier

hi def link sipInternalIp	Error
hi def link sipResonseErr	Error
hi def link sipMethodErr	Error
hi def link sipNoUser		Error
hi def link sipNoHost		Error

let b:current_syntax = "SIP"

" vim: noet ts=8 sts=8 sw=8
