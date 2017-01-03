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

fun! SC_Init_Buffer(commentString)
	let idx = stridx(a:commentString, "%s")
	let com0 = escape(strcharpart(a:commentString, 0, idx), '[]\\\/.*')
	let com1 = escape(strcharpart(a:commentString, idx + 2, len(a:commentString)), '[]\\\/.*')
	if len(com1) == 0
		let rxAdd = 's/^/' . com0 . '/e'
		let com0 = substitute(com0, "\\s", "\\\\s", "g")
		let rxDel = 's/^' . com0 . '//e'
		let b:simple_comments_add = rxAdd
		let b:simple_comments_del = rxDel
		let b:simple_comments_move = idx
	endif
endfun

fun! CommentAdd(type) range
	let saveCursor = getcurpos()
	let begin = a:firstline
	let end = a:lastline
	if a:type == 'char' || a:type == 'line'
		let begin = "'["
		let end = "']"
	endif
	exe begin . "," . end . b:simple_comments_add
	call setpos('.', saveCursor)
endfun

fun! CommentDel(type) range
	let saveCursor = getcurpos()
	let begin = a:firstline
	let end = a:lastline
	if a:type == 'char' || a:type == 'line'
		let begin = "'["
		let end = "']"
	endif
	exe begin . "," . end . b:simple_comments_del
	call setpos('.', saveCursor)
endfun

let mapit = 'inoremap <Leader>!M <ESC>:call Comment!A(1)<CR>a
	\ | nnoremap <Leader>!M :call Comment!A(1)<CR>
  \ | vnoremap <Leader>!M :call Comment!A(1)<CR>
  \ | nnoremap !M :set operatorfunc=Comment!A<CR>g@'

exe substitute(substitute(mapit, '!M', 'c', 'g'), '!A', 'Add', 'g')
exe substitute(substitute(mapit, '!M', 'C', 'g'), '!A', 'Del', 'g')

augroup scomments
  autocmd!
  autocmd FileType * call SC_Init_Buffer(&commentstring)
  autocmd BufWinEnter * call SC_Init_Buffer(&commentstring)
augroup END

let &cpoptions = s:savedCpo
