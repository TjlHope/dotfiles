" Source: https://gist.github.com/am4dr/4e6fc1bade7c1add02e5
" License: MIT
" (c) 2015 am4dr <t.f.octo@gmail.com>

if exists('g:loaded_syntastic_groovy_groovyc_checker')
    finish
endif
let g:loaded_syntastic_groovy_groovyc_checker = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:syntastic_groovy_groovyc_executable')
    let g:syntastic_groovy_groovyc_executable = 'groovyc'
endif

if !exists('g:syntastic_groovy_groovyc_options')
    let g:syntastic_groovy_groovyc_options = ''
endif

function! SyntaxCheckers_groovy_groovyc_IsAvailable() dict
    return executable(self.getExec())
endfunction

function! SyntaxCheckers_groovy_groovyc_GetLocList() dict
    let groovyc_opts = g:syntastic_groovy_groovyc_options
    let output_dir = syntastic#util#tmpdir()
    let groovyc_opts .= ' -d ' . syntastic#util#shescape(output_dir)
    let makeprg = self.makeprgBuild({
    \   'args' : groovyc_opts,
    \   'fname': syntastic#util#shescape(expand('%:p', 1)),
    \ })
    let errorformat =
    \   '%f: %l: %\%%([Static type checking] - %\)%\=%m @%.%#column %c.,' .
    \   '%E%f: %l: %\%%([Static type checking] - %\)%\=%m,' .
    \   '%-Z @ line %l%\, column %c.,' .
    \   '%-G%.%#,'
    let errors = SyntasticMake({
    \   'makeprg' : makeprg,
    \   'errorformat' : errorformat,
    \ })
    call syntastic#util#rmrf(output_dir)
    return errors
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
\   'filetype': 'groovy',
\   'name': 'groovyc',
\ })

let &cpo = s:save_cpo
unlet s:save_cpo
