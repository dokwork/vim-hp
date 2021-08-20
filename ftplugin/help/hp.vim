setlocal foldmethod=expr
setlocal foldexpr=GetHelpFold(v:lnum)

function! GetHelpFold(bufline)
  if getline(a:bufline) =~ '\v^\s*[-|=]+\s*$'
    return '0'
  else
    return '1'
  endif
endfunction

" Create a command to generate the Contents
command! -nargs=? HpGenerateContents call <SID>InsertContents(<f-args>)

" Updates titles
command! HpUpdateAll call hp#UpdateAll()

function! s:InsertContents(...)
  let width = ( a:0 > 0 ) ? a:1 : 80
  call append(line('.') - 1, hp#GenerateHelpContent(width))
  call hp#UpdateAll()
endfunction

" Jump between any sections
noremap <script> <buffer> <silent> ]]
      \ :call <SID>NextSection(1, 0, 0)<bar>
      \ execute "normal z\r"<cr>
noremap <script> <buffer> <silent> [[
      \ :call <SID>NextSection(1, 1, 0)<bar>
      \ execute "normal z\r"<cr>

vnoremap <script> <buffer> <silent> ]]
      \ :call <SID>NextSection(1, 0, 1)<cr>
vnoremap <script> <buffer> <silent> [[
      \ :call <SID>NextSection(1, 1, 1)<cr>

" Jump between main sections
noremap <script> <buffer> <silent> []
      \ :call <SID>NextSection(0, 0, 0)<bar>
      \ execute "normal z\r"<cr>
noremap <script> <buffer> <silent> ][
      \ :call <SID>NextSection(0, 1, 0)<bar>
      \ execute "normal z\r"<cr>

vnoremap <script> <buffer> <silent> []
      \ :call <SID>NextSection(0, 0, 1)<cr>
vnoremap <script> <buffer> <silent> ][
      \ :call <SID>NextSection(0, 1, 1)<cr>

function! s:NextSection(separator, backwards, isVisual)
  if a:isVisual
    normal! gv
  endif

  if a:separator == 0
    let pattern ='\v^\=+'
  else
    let pattern = '\v^[-|=]+'
  endif

  if a:backwards
    let dir = '?'
  else
    let dir = '/'
  endif

  execute "silent normal! " . dir . pattern . dir . "\r"
endfunction
