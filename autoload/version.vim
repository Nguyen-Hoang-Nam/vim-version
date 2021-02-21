let s:PACKAGENAME = '\v\C\"\@?[^A-Z\._][^A-Z~\)\(\!\*]*\":\s*\"'
let s:SEMVER = '(\^|\~|\>|\<|\=|\>\=|\<\=)?(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(-(0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*)?'

function! s:CheckPackageFile()
	let l:filename = expand('%:t')
	return l:filename == 'package.json'
endfunction

function! s:CheckBetween(start, end)
	let l:start_line = search(a:start, 'n')
	let l:end_line = search(a:end, 'n')
	let l:current_line = line('.')

	return l:current_line > l:start_line && l:current_line < l:end_line
endfunction

function! s:CheckPackageLine()
	if s:CheckBetween('"dependencies":', '}') ||
				\ s:CheckBetween('"devDependencies":', '}')
		let l:line = getline('.')
		return line =~ s:PACKAGENAME.s:SEMVER.'\"'
	endif

	return 0
endfunction

function! s:GetPackageElement()
	let l:line = getline('.')
	let l:line = substitute(l:line, '\v\"|\s|\t', '', 'g')
	return split(l:line, ':')
endfunction

function! s:TrimVersion(version)
	let result = substitute(a:version, '\v\^|\,', '', 'g')
	return result
endfunction

function! s:LastestVersion(package)
	let cmd = 'curl -s https://registry.npmjs.org/'.a:package.' | sed "s/,/\n/g" | awk "/dist-tags/{print}" | grep -Po "(?<=\")[0-9].*(?=\")"'
	let l:version = system(cmd)
	let trim = substitute(l:version, '\v\n+$', '', 'g')
	return trim
endfunction

function! version#lastest(args)
	let l:valid = 1

	if !s:CheckPackageFile()
		let l:valid = 0
		echo 'Invalid file'
	endif

	if !s:CheckPackageLine()
		let l:valid = 0
		echo 'Invalid line'
	endif

	if l:valid
		let l:elements = s:GetPackageElement()
		let l:lastest = s:LastestVersion(elements[0])

		if empty(a:args)
			echo 'lastest: '.l:lastest
		elseif a:args == '-r'
			let l:current = s:TrimVersion(elements[1])
			let l:newline = substitute(getline('.'), l:current, l:lastest, '')
			call setline('.', l:newline)
		endif
	endif
endfunction


