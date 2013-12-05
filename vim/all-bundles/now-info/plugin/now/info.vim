if exists('loaded_plugin_now_info')
  finish
endif
let loaded_plugin_now_info = 1

let s:cpo_save = &cpo
set cpo&vim

if !exists('g:now_info_buffer_name')
  let g:now_info_buffer_name = 'Info: '
endif

if !exists('g:now_info_command')
  let g:now_info_command = 'info --output=-'
endif

if !exists('g:now_info_dir_regex')
  let g:now_info_dir_regex = '^\* [^:]*: \(([^)]*)\)'
endif

if !exists('g:now_info_menu_regex')
  let g:now_info_menu_regex = '^\* \([^:]*\)::'
endif

if !exists('g:now_info_note_regex')
  let g:now_info_note_regex =
        \ '\*[Nn]ote\_s\=\%(\_[^:.]\+:\_s\_[^.,]*\%(\_[.,]\|$\)\|\_[^:]*::\)\='
endif

if !exists('g:now_info_note_ref_regex')
  let g:now_info_note_ref_regex = '\*[Nn]ote\s\([^:]\+\)::'
endif

if !exists('g:now_info_note_external_ref_regex')
  let g:now_info_note_external_ref_regex =
        \ '\*[Nn]ote\s[^:.]\+:\s\([^.,]\+\)\%([.,]\|$\)'
endif

if !exists('g:now_info_index_regex')
  let g:now_info_index_regex = '^\* [^:]*:\s*\([^.]*\)\.$'
endif

if !exists('g:now_info_index_highlight_regex')
  let g:now_info_index_highlight_regex = '^\* [^:]*:\s\+[^(]'
endif

if !exists('g:now_info_url_regex')
  let g:now_info_url_regex =
        \'\<\%(\(https\=\|s\=ftp\|news\)://\|\(mailto\):\)[^[:space:]>]\+'
endif

if !exists('g:now_info_url_handler')
  let g:now_info_url_handler = 'url_handler.sh'
endif

if !exists('g:now_info_mailer')
  let g:now_info_mailer = 'mutt'
endif

command! -nargs=* Info call s:info(<f-args>)

augroup plugin-now-info
  autocmd!
  execute 'autocmd BufUnload ' .
        \ escape(g:now_info_buffer_name, '\ ') . '*  setlocal nobuflisted'
augroup end

let s:info_search_string = ''

function! s:info(...)
  if a:0 > 0
    let file = a:1
    if file[0] != '('
      let file = '(' . file . ')'
    endif
    if a:0 > 1
      let node = a:2
      let i = 2
      while i < a:0
        let node .= ' ' . a:000[i]
	let i += 1
      endwhile
    else
      let node = 'Top'
    endif
  else
    let file = '(dir)'
    let node = 'Top'
  endif

  if !s:info_exec(file, node)
    return
  endif

  if winheight(0) < &helpheight
    execute 'resize ' . &helpheight
  endif
endfunction

function! s:info_exec(file, node, ...)
  if a:0 == 0
    if exists('b:info_file')
      let last_file = b:info_file
      let last_node = b:info_node
      let last_mark = now#vim#mark#cursor()
    endif
  endif
  
  let bufname = g:now_info_buffer_name . a:file . a:node
  if buflisted(bufname) && !getbufvar(bufname, '&hidden') && a:0 < 2
    silent execute (&ft == 'info' ? 'b!' : 'sb') escape(bufname, '\ ')
  else
    silent! execute (&ft == 'info' ? 'e!' : 'new')
          \ '+setlocal\ modifiable\ noswapfile\ buftype=nofile' .
                   \ '\ bufhidden=unload\ nobuflisted'
          \ escape(bufname, '\ ')
    setfiletype info
    let cmd = g:now_info_command . " '" . a:file.a:node . "' 2>/dev/null"
    execute 'silent 0read!' cmd
    $-1,$delete _

    call s:info_buffer_init()
  endif

  let b:info_file = a:file
  let b:info_node = a:node
  if exists('last_file')
    let b:info_last_file = last_file
    let b:info_last_node = last_node
    let b:info_last_mark = last_mark
  endif

  setlocal nomodifiable
  if s:info_is_first_line()
    if a:0 > 0
      if type(a:1) == type({})
        call a:1.restore()
      else
        call cursor(a:1, 1)
        call s:next_ref()
      endif
    else
      call cursor(1, 1)
      call s:next_ref()
    endif
    return 1
  else
    echohl ErrorMsg
    echo 'Info failed: node not found'
    echohl None
    return 0
  endif
endfunction

function! s:info_buffer_init()
  if has('syntax') && exists('g:syntax_on')
    syn case match
    syn match infoMenuTitle /^\* Menu:/hs=s+2,he=e-1
    syn match infoTitle /^\u[A-Za-z0-9 `',/&]\{,43}\([[:lower:]']\|\u\{2}\)$/
    syn match infoTitle /^[-=*]\{,45}$/
    syn match infoString /`[^']*'/
    execute 'syn match infoLink	/' . g:now_info_menu_regex . '/hs=s+2'
    execute 'syn match infoLink	/' . g:now_info_dir_regex . '/hs=s+2'
    execute 'syn match infoLink	/' .
          \ g:now_info_index_highlight_regex . '/hs=s+2,he=e-2'
    execute 'syn match infoLink +' . g:now_info_url_regex . '+'
    syn region infoLink	start=/\*[Nn]ote/ end=/\(::\|[.,]\)/

    " TODO: is this test still needed?
    if !exists("g:did_info_syntax_inits")
      let g:did_info_syntax_inits = 1

      hi def link infoMenuTitle	Title
      hi def link infoTitle	Title
      hi def link infoLink	Directory
      hi def link infoString	String
      hi def link infoPosition	IncSearch
    endif
  endif

  " XXX: make more 'normal' defaults
  noremap <buffer> <silent> > :call <SID>next_node()<CR>
  noremap <buffer> <silent> < :call <SID>prev_node()<CR>
  noremap <buffer> <silent> u :call <SID>up_node()<CR>
  noremap <buffer> <silent> T :call <SID>top_node()<CR>
  noremap <buffer> <silent> d :call <SID>dir_node()<CR>
  noremap <buffer> <silent> h :call <SID>last_node()<CR>
  noremap <buffer> <silent> j :call <SID>next_ref()<CR>
  noremap <buffer> <silent> k :call <SID>prev_ref()<CR>
  noremap <buffer> <silent> s :call <SID>follow_link()<CR>
  noremap <buffer> <silent> S :call <SID>search()<CR>
  noremap <buffer> <silent> q :q!<CR>
  noremap <buffer> <silent> H :call <SID>help()<CR>
endfunction

function! s:help()
  echohl Title
  echo '                           Info Browser Keys'
  echo 'Key              Action'
  echo '------------------------------------------------------------------------'
  echohl None
  echo 'j                Move to next reference or scroll forward (line down)'
  echo 'k                Move to previous reference or scroll backward (line up)'
  echo 's                Follow reference under cursor'
  echo 'h                Return to last viewed node'
  echo '>                Move to node following the current one ("next")'
  echo '<                Move to node preceding the current one ("previous")'
  echo 'u                Move "up" from this node'
  echo 'T                Move to "top" of this node'
  echo 'd                Move to "directory" node'
  echo '/                Search forward within current node'
  echo 'S                Search forward through all nodes'
  echo 'H                This screen'
  echo 'q                Quit browser'
endfunction

function! s:info_is_first_line()
  let b:info_prev_node = ''
  let b:info_next_node = ''
  let b:info_up_node = ''
  
  let line = getline(1)
  let node_offset = matchend(line, '^File: [^,	 ]*')
  if node_offset == -1
    return 0
  endif

  let file = strpart(line, 6, node_offset - 6)
  if file == 'dir'
    return 1
  endif

  let b:info_prev_node = s:get_submatch(line, '\s\+Prev: \([^,]*\),')
  let b:info_next_node = s:get_submatch(line, '\s\+Next: \([^,]*\),')
  let b:info_up_node = s:get_submatch(line, '\s\+Up: \([^,]*\),')

  return 1
endfunction

function! s:get_submatch(string, regex)
  let matched = matchstr(a:string, a:regex)
  if matched != ""
    let matched = substitute(matched, a:regex, '\1', "")
  endif
  return matched
endfunction

function! s:node_is_valid(node)
  return a:node != "" && match(a:node, '(.*)') == -1
endfunction

function! s:goto_node(node)
  if !s:node_is_valid(a:node)
    return
  endif
  call s:info_exec(b:info_file, a:node)
endfunction

function! s:next_node()
  call s:goto_node(b:info_next_node)
endfunction

function! s:prev_node()
  call s:goto_node(b:info_prev_node)
endfunction

function! s:up_node()
  call s:goto_node(b:info_up_node)
endfunction

function! s:top_node()
  if b:info_node != 'Top' || b:info_file != '(dir)'
    call s:info_exec(b:info_node == 'Top' ? '(dir)' : b:info_file, 'Top')
  endif
endfunction

function! s:dir_node()
  call s:info_exec('(dir)', 'Top')
endfunction

function! s:last_node()
  if exists('b:info_last_file')
    call s:info_exec(b:info_last_file, b:info_last_node, b:info_last_mark)
  endif
endfunction

function! s:follow_link()
  let cur_line = getline('.')
  let idx = col('.') - 1
  let link = matchstr(cur_line, g:now_info_note_regex, idx)
  if link != ''
    let cur_line = cur_line.' '.getline(line('.') + 1)
    let regex = g:now_info_note_ref_regex
    let link = matchstr(cur_line, regex, idx)
    if link == ''
      let regex = g:now_info_note_external_ref_regex
      let link = matchstr(cur_line, regex, idx)
      if link == ''
	return
      endif
    endif
    let node = substitute(link, regex, '\1', '')
    let sep_regex = '^\(([^)]*)\)\=\s*\(.*\)'
    let file = substitute(node, sep_regex, '\1', '')
    let node = substitute(node, sep_regex, '\2', '')
    if file == ''
      let file = b:info_file
    endif
    if node == ''
      let node = 'Top'
    endif
  else
    let link = matchstr(cur_line, g:now_info_dir_regex)
    if link != ''
      let regex = g:now_info_dir_regex
      let file = substitute(link, g:now_info_dir_regex, '\1', '')
      let node = 'Top'
    else
      let link = matchstr(cur_line, g:now_info_menu_regex)
      if link != ''
	let regex = g:now_info_menu_regex
      else
	let link = matchstr(cur_line, g:now_info_index_regex)
	if link == ''
	  let link = matchstr(cur_line, g:now_info_url_regex)
	  if link != ''
	    let node = substitute(link, g:now_info_url_regex, '\1', '')
	    call system('url-extract '. node)
	    return
	  else
	    return
	  endif
	else
	  let regex = g:now_info_index_regex
	endif
      endif
      let file = b:info_file
      let node = substitute(link, regex, '\1', '')
    endif
  endif
  call s:info_exec(file, node)
endfunction

function! s:goto_ref(direction)
  let regex = '\%('.g:now_info_dir_regex.'\|'.g:now_info_menu_regex.'\|'.
	\g:now_info_note_regex.'\|'.g:now_info_index_highlight_regex.'\|'.
	\g:now_info_url_regex.'\)'
  let cursor_line = line('.')
  let cursor_col = col('.')
  if a:direction == 1
    let col_spec = '>'
    let flags = 'W'
    let increment = 1
    let boundary_cmd = 'L'
    let key = "\<C-E>"
  else
    let col_spec = '<'
    let flags = 'bW'
    let increment = -1
    let boundary_cmd = 'H'
    let key = "\<C-Y>"
  end
  if search('\%'.cursor_line.'l\%'.col_spec.cursor_col.'c'.regex, flags) > 0
    execute 'match infoPosition +\%#'.regex.'+'
    return 1
  endif
  let i = cursor_line + increment
  execute 'normal! '.boundary_cmd
  let n = line('.')
  if (a:direction && i >= n) || (!a:direction && i <= n)
    execute "normal! ".key
    let n = n + increment
  endif
  call cursor(cursor_line, cursor_col)
  while (a:direction && i <= n) || (!a:direction && i >= n)
    if search('\%'.i.'l'.regex, flags) > 0
      execute 'match infoPosition +\%#'.regex.'+'
      return 1
    endif
    let i = i + increment
  endwhile
  execute 'normal! '.boundary_cmd.'0'
  return 0
endfunction

function! s:next_ref()
  call s:goto_ref(1)
endfunction

function! s:prev_ref()
  call s:goto_ref(0)
endfunction

" XXX: should move forward one character if searching again at same pos
" XXX: this doesn't work correctly if no match is found
function! s:search()
  let search_term = input('Search all nodes: ', s:info_search_string)
  if search_term == ''
    return
  endif
  let s:info_search_string = search_term
  let start_file = b:info_file
  let start_node = b:info_node
  let start_line = line('.')
  while search(s:info_search_string, 'W') == 0
    if !s:node_is_valid(b:info_next_node)
      silent! execute 'bwipe'
            \ escape(g:now_info_buffer_name . start_file . start_node, '\ ')
      silent! call s:info_exec(start_file, start_node, start_line)
      return
    endif
    echon "Searching “" . b:info_file . b:info_next_node . "”"
    let file = b:info_file
    let node = b:info_next_node
    let buffer = bufnr('%')
    silent call s:info_exec(file, node, 2, 1)
    silent execute 'bwipe' buffer
  endwhile
  let @/ = s:info_search_string
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
