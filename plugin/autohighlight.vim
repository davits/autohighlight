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
elseif v:version < 704 || (v:version == 704 && !has('patch1594'))
  echohl WarningMsg |
        \ echomsg "AutoHighlight unavailable: requires Vim 7.4.1594+" |
        \ echohl None
  finish
endif

" Support for |line-continuation|
let s:save_cpo = &cpo
set cpo&vim

let w:matchId = -1
let s:matchRegex = ''
let s:timer = 0

"{{{ Options

let g:AH_style = get(g:, 'AH_style', 'bold')
let g:AH_timeout = get(g:, 'AH_timeout', 700)

"}}}

"{{{ Commands

command! -bar AHOn call s:AHOn()
command! -bar AHOff call s:AHOff()
command! -bar AHToggle call s:AHToggle()

function! s:AHToggle()
    if exists('#autohighlight')
        call s:AHOff()
    else
        call s:AHOn()
    endif
endfunction

function! s:AHOn()
    if !exists('#autohighlight')
        call s:SetUpAutoCommands()
        call s:SetUpMappings()
        call s:OnCursorMoved()
    endif
endfunction

function! s:AHOff()
    if exists('#autohighlight')
        call s:RemoveAutoCommands()
        call s:RemoveMappings()
        call s:MatchDelete()
    endif
endfunction

"}}}

"{{{ Autocommands and mappings

augroup autohighlight_start
    " Defer autoload function calls
    autocmd VimEnter * call s:OnVimEnter()
augroup END

function! s:SetUpAutoCommands()
    augroup autohighlight
        autocmd!
        autocmd CursorMoved * call s:OnCursorMoved()
        autocmd InsertEnter * call s:OnInsertEntered()
    augroup END
endfunction

function! s:RemoveAutoCommands()
    au! autohighlight
    augroup! autohighlight
endfunction

function! s:SetUpMappings()
    nnoremap <silent> <LeftRelease> :call AHLightUp(0)<CR>
endfunction

function! s:RemoveMappings()
    unmap <LeftRelease>
endfunction

"}}}

"{{{ Event handlers

function! s:OnVimEnter()
    if g:AH_style == 'bold'
        call autohighlight#colors#CreateBoldVariant('AHGroup', 'Normal')
    elseif g:AH_style == 'italic'
        call autohighlight#colors#CreateItalicVariant('AHGroup', 'Normal')
    elseif g:AH_style == 'underlined'
        call autohighlight#colors#CreateUnderlinedVariant('AHGroup', 'Normal')
    else
        throw "Unsupported AutoHighlight style, use on of these (bold|italic|underlined)."
    endif
endfunction

function! s:OnCursorMoved()
    if mode() != 'n'
        return
    endif

    if getline(".")[col(".") - 1] !~# '\k' || synID(line("."), col("."), 1) != 0
        call s:MatchDelete()
        return
    endif

    let l:cword = expand('<cword>')
    let l:match = '\V\<'.escape(l:cword, '\').'\>'
    if l:match != s:matchRegex
        call s:MatchDelete()
        let s:matchRegex = l:match
        call s:FireTimer()
    endif
endfunction

function! s:OnInsertEntered()
    call s:CancelTimer()
    call s:MatchDelete()
endfunction

"}}}

"{{{ Utility functions

function! s:FireTimer()
    call s:CancelTimer()
    let s:timer = timer_start(g:AH_timeout, 'AHLightUp')
endfunction

function! s:CancelTimer()
    call timer_stop(s:timer)
    let s:timer = 0
endfunction

function! s:MatchDelete()
    let s:matchRegex = ''
    if exists('w:matchId') && w:matchId > 0
        call matchdelete(w:matchId)
        let w:matchId = 0
    endif
endfunction

function! s:MatchAdd()
    let w:matchId = matchadd('AHGroup', s:matchRegex, -1)
endfunction

"}}}

function! AHLightUp(timer)
    if a:timer == 0
        if s:timer != 0
            call s:CancelTimer()
            call s:MatchAdd()
        endif
        return
    endif
    let s:timer = 0
    call s:MatchAdd()
endfunction

call s:SetUpAutoCommands()
call s:SetUpMappings()
call s:OnCursorMoved()

let g:autohighlight_loaded = 1

" Restore previous 'cpo' value
let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker foldmarker={{{,}}}
