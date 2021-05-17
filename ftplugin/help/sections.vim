function! s:NextSection(backwards, isVisual)
  if a:isVisual
    normal! gv
  endif

  let pattern ='\v^[-|=]+'

  if a:backwards
    let dir = '?'
  else
    let dir = '/'
  endif

  execute 'silent normal! ' . dir . pattern . dir . "\r"
endfunction

noremap <script> <buffer> <silent> ]]
      \ :call <SID>NextDeclaration(0, 0)<cr>
noremap <script> <buffer> <silent> [[
      \ :call <SID>NextDeclaration(1, 0)<cr>

vnoremap <script> <buffer> <silent> ]]
      \ :call <SID>NextDeclaration(0, 1)<cr>
vnoremap <script> <buffer> <silent> [[
      \ :call <SID>NextDeclaration(1, 1)<cr>
