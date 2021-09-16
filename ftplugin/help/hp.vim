" Command to generate the Contents
command! -nargs=? HpGenerateContents call <SID>InsertContents(<f-args>)

" Command to updates and format titles and the Contents
command! HpRefresh call hp#Refresh()

function! s:InsertContents(...)
  let width = ( a:0 > 0 ) ? a:1 : 80
  let lnum = line('.')
  call append(lnum - 1, hp#GenerateContentsItems(width, lnum))
  call hp#Refresh()
endfunction

if get(g:, 'hp_fold_off', v:false) | finish | endif

setlocal foldmethod=expr
setlocal foldexpr=GetHelpFold(v:lnum)

function! GetHelpFold(bufline)
  if getline(a:bufline) =~ '\v^\s*[-|=]+\s*$'
    return '0'
  else
    return '1'
  endif
endfunction
