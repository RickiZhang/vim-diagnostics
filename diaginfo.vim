let g:diagnostics_window_enabled = 0
let s:infoboard_agent = v:null

let s:current_line = -1

function! s:ShowDiagnostics()
    let l:diagnostics = getloclist(0)
    let l:line_diagnostics = filter(copy(l:diagnostics), 'v:val["lnum"] == s:current_line')
    call s:infoboard_agent.ClearInfoboard('diaginfo')
    if len(l:line_diagnostics) == 0
        return 
    endif

    for l:entry in l:line_diagnostics
        let l:msg = l:entry['text'] .' (L' . l:entry['lnum'] . ', C' . l:entry['col'] . ')'
        call s:infoboard_agent.InsertLine('diaginfo', '$', l:msg)
    endfor
endfunction

command! ToggleDiagInfo call s:ToggleDiagnosticsWindow()

function! s:CheckShowDiagnostics()
    if g:diagnostics_window_enabled == 0 || s:infoboard_agent is# v:null
        return
    endif
    if s:current_line == line('.')
        return
    endif
    let s:current_line = line('.')
    call s:ShowDiagnostics()
endfunction

function! s:ToggleDiagnosticsWindow()
    if g:diagnostics_window_enabled == 1
        let g:diagnostics_window_enabled = 0
    else
        let g:diagnostics_window_enabled = 1
        let s:current_line = -1
        call s:CheckShowDiagnostics()
    endif
endfunction

augroup DiagnosticsWinCursorMove
    autocmd!
    autocmd CursorMoved * call s:CheckShowDiagnostics()
augroup END

function! s:RegisterToInfoboard()
    if !exists('g:loaded_infoboard') || g:loaded_infoboard != 1
        echom "infoboard not loaded"
        return
    endif
    let s:infoboard_agent = GetInfoboardAgent()
    call s:infoboard_agent.RegisterInfoSource('diaginfo')
endfunction

autocmd VimEnter * call s:RegisterToInfoboard()
