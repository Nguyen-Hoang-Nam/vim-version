let s:has_popup = has('textprop') && has('patch-8.2.0286')
let s:has_float = has('nvim') && exists('*nvim_win_set_config')

function! s:lastest_version(package)
	let cmd = 'curl -s https://registry.npmjs.org/'.a:package.' | sed "s/,/\n/g" | awk "/dist-tags/{print}" | grep -Po "(?<=\")[0-9].*(?=\")"'
	let l:version = system(cmd)
	let trim = substitute(l:version, '\v\n+$', '', 'g')
	return trim
endfunction

function! s:all_version(package)
	let cmd = 'curl -s https://registry.npmjs.org/'.a:package.' | sed "s/},\|],/\n/g" | awk "/time/{print}" | sed "s/,/\n/g" | sed "s/:.*//" | sed "s/\"//g"'
	let l:version_time = system(cmd)
	let l:trim_time = substitute(l:version_time, '\"time\":{', '', 'g')
	let l:all_version = split(l:trim_time, '\n')
	let l:valid_versions = version#utils#filter_version(l:all_version)
	return l:valid_versions
endfunction

function! version#lastest(args)
	let l:valid = version#utils#valid()

	if l:valid
		let l:elements = version#utils#get_package_element()
		let l:lastest = s:lastest_version(elements[0])

		if empty(a:args)
			echo 'lastest: '.l:lastest
		elseif a:args == '-r'
			let l:current = version#utils#trim_version(elements[1])
			let l:newline = substitute(getline('.'), l:current, l:lastest, '')
			call setline('.', l:newline)
		endif
	endif
endfunction

function! version#all()
	let l:valid = version#utils#valid()

	if l:valid
		let l:elements = version#utils#get_package_element()
		let l:valid_versions = s:all_version(elements[0])
		let l:valid_versions = sort(l:valid_versions)
		let l:valid_versions = reverse(l:valid_versions)

		if version#window#support()
			call version#window#open(l:valid_versions)
		else
			let l:length = len(l:valid_versions)

			for i in [1, 2, 3, 4, 5]
				echo l:valid_versions[i]
			endfor

			call inputsave()
			let option = input('(r) replace current version, (m) more: ')
			call inputrestore()

			if option == 'r'
				call inputsave()
				let new_version = input('New version: ')
				call inputrestore()

				let l:current = version#utils#trim_version(elements[1])
				let l:newline = substitute(getline('.'), l:current, new_version, '')
				call setline('.', l:newline)
			elseif option == 'm'
				redraw

				for l:version in l:valid_versions
					echo l:version
				endfor
			endif
		endif
	endif
endfunction
