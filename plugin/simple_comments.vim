" simple_comments.vim - Simple script for commenting and uncommenting lines
"
" Author:  Anders Thøgersen <anders [at] bladre.dk>
" Version: 1.4
" Date:    03-Jan-2017
"
" Complete rewrite, only handles start of line comments

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

fun! s:SC_Init_Buffer(commentString)
	let idx = stridx(a:commentString, "%s")
	let com0 = escape(strcharpart(a:commentString, 0, idx), '[]\\\/.*')
	let com1 = escape(strcharpart(a:commentString, idx + 2, len(a:commentString)), '[]\\\/.*')
	if len(com1) == 0
		let rxAdd = 's/^/' . com0 . '/e'
		let com0 = substitute(com0, "\\s", "\\\\s", "g")
		let rxDel = 's/^\(\s*\)' . com0 . '/\1/e'
		let b:simple_comments_add = rxAdd
		let b:simple_comments_del = rxDel
		let b:simple_comments_move = idx
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
	exe begin . "," . end . b:simple_comments_add
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
	" exe begin . "," . end . 'normal =='
	call setpos('.', saveCursor)
endfun

let s:mapit = 'inoremap !M <ESC>:call <SID>Comment!A(1)<CR>a
  \ | vnoremap !M :call <SID>Comment!A(1)<CR>
  \ | nnoremap !M :set operatorfunc=<SID>Comment!A<CR>g@'

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
