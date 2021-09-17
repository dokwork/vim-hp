" Command to generate the Contents
command! -nargs=? HpGenerateContents call <SID>InsertContents(<f-args>)

" Command to updates and format titles and the Contents
command! HpRefresh call hp#Refresh()

function! s:InsertContents(...)
  let width = ( a:0 > 0 ) ? a:1 : &textwidth
  let width = width > 0 ? width : 80
  let lnum = line('.')
  call append(lnum - 1, hp#GenerateContentsItems(width, lnum))
  call hp#Refresh()
endfunction
