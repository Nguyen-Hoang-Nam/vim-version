let s:has_popup = has('textprop') && has('patch-8.2.0286')
let s:has_float = has('nvim') && exists('*nvim_win_set_config')

function! s:win_exist(winid) abort
	return !empty(getwininfo(a:winid))
endfunction

function! s:open_float(versions) abort
	let buf = nvim_create_buf(v:false, v:true)
	let width = version#utils#float_width()
	let height = version#utils#float_height()

	let top = "╭" . repeat("─", width - 2) . "╮"
	let mid = "│" . repeat(" ", width - 2) . "│"
	let bot = "╰" . repeat("─", width - 2) . "╯"
	let lines = [top] + repeat([mid], height - 2) + [bot]
	call nvim_buf_set_lines(buf, 0, -1, v:true, lines)

	let opts = {
				\ 'relative': 'editor',
				\ 'width': version#utils#float_width(),
				\ 'height': version#utils#float_height(),
				\ 'col': version#utils#float_column(),
				\ 'row': version#utils#float_row(),
				\ 'anchor': 'NW',
				\ 'style': 'minimal'
				\ }
	let win_background = nvim_open_win(buf, v:true, opts)
	call setwinvar(win_background, '&winhighlight', 'NormalFloat:Normal')
	call setwinvar(win_background, '&colorcolumn', '')

	let opts.row += 1
	let opts.height -= 2
	let opts.col += 2
	let opts.width -= 4
	let win_foreground = nvim_open_win(nvim_create_buf(v:false, v:true), v:true, opts)
	call setwinvar(win_foreground, '&winhighlight', 'NormalFloat:Normal')

	let item = 1
	for l:v in a:versions
		call append(item, l:v)
		let item += 1
	endfor

	startinsert
	inoremap <buffer> <Esc> <Esc>:q<CR>:q<CR>

	return buf
endfunction

function! version#window#support() abort
	return s:has_float || s:has_popup
endfunction

function! version#window#open(versions) abort
	if s:has_float
		let buf = s:open_float(a:versions)
	elseif s:has_popup
		echo 'Popup'
	endif
endfunction

