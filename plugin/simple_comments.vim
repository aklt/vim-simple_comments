" simple_comments.vim - Simple script for commenting and uncommenting lines
"
" Author:  Anders Thøgersen <anders [at] bladre.dk>
" Version: 2.0
" Date:    03-Jan-2017
"
if exists('loaded_simple_comments') || &cp
    finish
endif
let loaded_simple_comments = 1

if v:version < 700
    echoerr "simple_comments: this plugin requires vim >= 7."
    finish
endif

let s:savedCpo = &cpoptions
set cpoptions&vim

if ! exists('g:simple_comments_comment')
  let g:simple_comments_comment = '<Leader>x'
endif

if ! exists('g:simple_comments_uncomment')
  let g:simple_comments_uncomment = '<Leader>X'
endif

if ! exists('g:simple_comments_left')
  let g:simple_comments_left = '<[ '
endif

if ! exists('g:simple_comments_right')
  let g:simple_comments_right = ' ]>'
endif

let s:esc = '\[\]\\\\\\/\.\*\(\)'

fun! s:SC_Init_Buffer(commentString)
  let idx = stridx(a:commentString, "%s")
  let com0 = escape(strcharpart(a:commentString, 0, idx), s:esc)
  let com1 = escape(strcharpart(a:commentString, idx + 2, len(a:commentString)), s:esc)
  let b:simple_comments_add = 's/^/' . com0 . '/e'
  let b:simple_comments_del = 's/^\(\s*\)' . com0 . '/\1/e'
  let b:simple_comments_move = idx
  if len(com1) > 0
    let b:simple_comments_add_end = 's/$/' . com1 . '/'
    let b:simple_comments_before_add = 's/' .
          \ com0 . '/' . g:simple_comments_left . '/e'
    let b:simple_comments_before_add_end = 's/' .
          \ com1 . '/' . g:simple_comments_right . '/e'
    let b:simple_comments_del_end = 's/\s*' . com1 . '\s*$//e'
    let b:simple_comments_after_del = 's/' .
          \ escape(g:simple_comments_left, s:esc) .  '/' . com0 . '/e'
    let b:simple_comments_after_del_end = 's/' .
          \ escape(g:simple_comments_right, s:esc) . '\s*$/' . com1 . '/e'
  endif
endfun

fun! s:CommentAdd(type) range
  let saveCursor = getcurpos()
  let begin = a:firstline
  let end = a:lastline
  if a:0 " Invoked from visual mode
    let begin = "'<"
    let end = "'>"
  elseif a:type == 'char' || a:type == 'line'
    let begin = "'["
    let end = "']"
  endif
  if exists('b:simple_comments_before_add')
    exe begin . "," . end . b:simple_comments_before_add
    exe begin . "," . end . b:simple_comments_before_add_end
  endif
  exe begin . "," . end . b:simple_comments_add
  if exists('b:simple_comments_add_end')
    exe begin . "," . end . b:simple_comments_add_end
  endif
  call setpos('.', saveCursor)
endfun

fun! s:CommentDel(type) range
  let saveCursor = getcurpos()
  let begin = a:firstline
  let end = a:lastline
  if a:0 " Invoked from visual mode
    let begin = "'<"
    let end = "'>"
  elseif a:type == 'char' || a:type == 'line'
    let begin = "'["
    let end = "']"
  endif
  exe begin . "," . end . b:simple_comments_del
  if exists('b:simple_comments_del_end')
    exe begin . "," . end . b:simple_comments_del_end
  endif
  if exists('b:simple_comments_after_del')
    exe begin . "," . end . b:simple_comments_after_del
    exe begin . "," . end . b:simple_comments_after_del_end
  endif
  call setpos('.', saveCursor)
endfun

let s:mapit = 'inoremap <silent> !M <ESC>:call <SID>Comment!A(1)<CR>a
  \ | vnoremap <silent> !M :call <SID>Comment!A(1)<CR>
  \ | nnoremap <silent> !M :silent set operatorfunc=<SID>Comment!A<CR>g@'

exe substitute(substitute(s:mapit, '!M', g:simple_comments_comment, 'g'), '!A', 'Add', 'g')
exe substitute(substitute(s:mapit, '!M', g:simple_comments_uncomment, 'g'), '!A', 'Del', 'g')
unlet s:mapit

augroup scomments
  autocmd!
  autocmd FileType * call s:SC_Init_Buffer(&commentstring)
  autocmd BufWinEnter * call s:SC_Init_Buffer(&commentstring)
augroup END

let &cpoptions = s:savedCpo
unlet s:savedCpo
