if exists('g:loaded_version')
	finish
endif
let g:loaded_version = 1

command! -nargs=? LVersion call version#lastest(<q-args>)
command! AVersions call version#all()
