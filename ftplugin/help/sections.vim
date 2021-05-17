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
