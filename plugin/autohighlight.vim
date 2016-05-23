" The MIT License (MIT)
"
" Copyright (c) 2016 Davit Samvelyan
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.


" Highlight all instances of word under cursor, when idle.
" Useful when studying strange source code.
"

if exists('g:autohighlight_loaded') && g:autohighlight_loaded
    finish
elseif !has('timers')
    echohl WarningMsg |
        \ echomsg "AutoHighlight unavailable: requires Vim compiled with +timers support." |
        \ echohl None
    finish
endif

" Support for |line-continuation|
let s:save_cpo = &cpo
set cpo&vim

" Options
let g:AH_style = get(g:, 'AH_style', 'bold')
let g:AH_timeout = get(g:, 'AH_timeout', 700)


augroup autohighlight_start
    " Defer autoload function calls
    autocmd VimEnter * call s:OnVimEnter()
augroup END

function! s:OnVimEnter()
    call autohighlight#Enable()
endfunction


let g:autohighlight_loaded = 1

" Restore previous 'cpo' value
let &cpo = s:save_cpo
unlet s:save_cpo
