let s:PACKAGENAME = '\v\C\"\@?[^A-Z\._][^A-Z~\)\(\!\*]*\":\s*\"'
let s:SEMVER = '(\^|\~|\>|\<|\=|\>\=|\<\=)?(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(-(0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*)?'

function! s:check_package_file()
	return expand('%:t') == 'package.json'
endfunction

function! s:check_between(start, end)
	let l:start_line = search(a:start, 'n')
	let l:end_line = search(a:end, 'n')
	let l:current_line = line('.')

	return l:current_line > l:start_line && l:current_line < l:end_line
endfunction

function! s:check_package_line()
	if s:check_between('"dependencies":', '}') ||
				\ s:check_between('"devDependencies":', '}')
		return getline('.') =~ s:PACKAGENAME.s:SEMVER.'\"'
	endif

	return 0
endfunction

function! version#utils#float_height()
	let l:height = winheight(0)
	return str2nr(string(l:height * 0.6))
endfunction

function! version#utils#float_width()
	let l:width = winwidth(0)
	return str2nr(string(l:width * 0.4))
endfunction

function! version#utils#float_column()
	let win_column = winwidth(0)
	let float_column = version#utils#float_width()
	return str2nr(string((win_column - float_column)/2))
endfunction

function! version#utils#float_row()
	let win_height = winheight(0)
	let float_height = version#utils#float_height()
	return str2nr(string((win_height - float_height)/2))
endfunction

function! version#utils#get_package_element()
	let l:line = getline('.')
	let l:line = substitute(l:line, '\v\"|\s|\t', '', 'g')
	return split(l:line, ':')
endfunction

function! version#utils#trim_version(version)
	let result = substitute(a:version, '\v\^|\,', '', 'g')
	return result
endfunction

function! version#utils#filter_version(all_version)
	let valid_versions = []
	for l:version in a:all_version
		if l:version =~ '\v'.s:SEMVER
			let valid_versions = add(valid_versions, l:version)
		endif
	endfor
	return valid_versions
endfunction

function! version#utils#valid() 
	let l:valid = 1

	if !s:check_package_file()
		let l:valid = 0
		echo 'Invalid file'
	elseif !s:check_package_line()
		let l:valid = 0
		echo 'Invalid line'
	endif

	return l:valid
endfunction


