setlocal foldmethod=expr
setlocal foldexpr=GetHelpFold(v:lnum)

function! GetHelpFold(bufline)
  if getline(a:bufline) =~ '\v^[-|=]+$'
    return '0'
  else
    return '1'
  endif
endfunction
