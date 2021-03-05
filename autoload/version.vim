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

function! s:FilterVersion(all_version)
	let valid_versions = []
	for l:version in a:all_version
		if l:version =~ '\v'.s:SEMVER
			let valid_versions = add(valid_versions, l:version)
		endif
	endfor
	return valid_versions
endfunction

function! s:LastestVersion(package)
	let cmd = 'curl -s https://registry.npmjs.org/'.a:package.' | sed "s/,/\n/g" | awk "/dist-tags/{print}" | grep -Po "(?<=\")[0-9].*(?=\")"'
	let l:version = system(cmd)
	let trim = substitute(l:version, '\v\n+$', '', 'g')
	return trim
endfunction

function! s:AllVersion(package)
	let cmd = 'curl -s https://registry.npmjs.org/'.a:package.' | sed "s/},\|],/\n/g" | awk "/time/{print}" | sed "s/,/\n/g" | sed "s/:.*//" | sed "s/\"//g"'
	let l:version_time = system(cmd)
	let l:trim_time = substitute(l:version_time, '\"time\":{', '', 'g')
	let l:all_version = split(l:trim_time, '\n')
	let l:valid_versions = s:FilterVersion(l:all_version)
	return l:valid_versions
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

function! version#all()
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
		let l:valid_versions = s:AllVersion(elements[0])
		let l:length = len(l:valid_versions)

		for i in [1, 2, 3, 4, 5]
			echo l:valid_versions[length - i]
		endfor

		call inputsave()
		let option = input('(r) replace current version, (m) more: ')
		call inputrestore()

		if option == 'r'
			call inputsave()
			let new_version = input('New version: ')
			call inputrestore()

			let l:current = s:TrimVersion(elements[1])
			let l:newline = substitute(getline('.'), l:current, new_version, '')
			call setline('.', l:newline)
		elseif option == 'm'
			redraw
			let l:valid_versions = sort(l:valid_versions)
			let l:valid_versions = reverse(l:valid_versions)
			for l:version in l:valid_versions
				echo l:version
			endfor
		endif
	endif
endfunction
