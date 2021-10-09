" MIT License
"
" Copyright (c) 2021 Vladimir Popov <vladimir@dokwork.ru>
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.


" Command to generate the Contents
command! -nargs=? HpGenerateContents call <SID>InsertContents(<f-args>)

" Command to updates and format titles and the Contents
command! HpRefresh call <SID>Refresh()

" Command to move everything before cursor to the left and other to the right
command! HpLeftRight call <SID>LeftRight()

function! s:InsertContents(...)
  let save_cursor = getcurpos()
  let width = ( a:0 > 0 ) ? a:1 : &textwidth
  let width = width > 0 ? width : 80
  let lnum = line('.')
  try
    call append(lnum - 1, hp#GenerateContentsItems(width, lnum))
    call hp#Refresh()
  finally
    call setpos('.', save_cursor)
  endtry
endfunction

function! s:Refresh()
  let save_cursor = getcurpos()
  try
    call hp#Refresh()
  finally
    call setpos('.', save_cursor)
  endtry
endfunction

function! s:LeftRight()
  " [bufnum, lnum, col, off]
  const pos = getpos('.')
  call hp#LeftRight(pos[1], pos[2])
endfunction
