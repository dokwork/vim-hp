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

const s:CONTENTS = '*CONTENTS*'
const s:NUMBER_REGEX = '(((\d|\#)+\.?)+)'
const s:NAME_REGEX = '\S.*'
const s:TAG_REGEX = '\*\S+\*'
const s:SECTION_REGEX = 
      \ '\v^' .. s:NUMBER_REGEX .. '?' .. s:NAME_REGEX .. s:TAG_REGEX .. '\s*$'

function! hp#Refresh() abort
  const contents = hp#FindContents()
  if empty(contents)
    throw 'Contents was not found. Please, generate it before updating.'
  endif

  const lfrom = contents['end']
  const sections = hp#BuildSections(lfrom)
  if empty(sections)
    throw 'No one section was found after ' .. lfrom .. ' line.'
  endif

  call s:UpdateSections(sections)
  call s:UpdateContents(contents, sections)
endfunction

function! s:UpdateSections(sections) abort
  for section in a:sections 
    let line =  section.line

    " replace number
    call hp#UpdateNumber(section)

    " move title to the left and tag to the right
    let str = getline(line)
    let tag_idx = stridx(str, section.tag) - 1 " -1 for *
    call hp#LeftRight(line, tag_idx)
  endfor
endfunction

function! s:UpdateContents(contents, sections) abort
  const lines = hp#GenerateContentsItems(a:contents.width, a:sections)
  let lnum = a:contents.begin
  for line in lines
    if lnum <= a:contents.end
      call setline(lnum, line)
    else 
      call append(lnum - 1, line)
    endif
    let lnum += 1
  endfor

  let result = copy(a:contents)
  let result.end = lnum - 1

  " remove old items
  if result.end < a:contents.end
    " execute lnum .. ',' .. a:contents.end .. 'delete_'
    call execute(lnum .. ',' .. a:contents.end .. 'delete_')
  endif

  return result
endfunction

" Returns an array with content's lines with width `width` for all 
" sections. Additionally, a list of sections or number of line can be 
" specified.
function! hp#GenerateContentsItems(width, lfromOrSections) abort
  let sections = type(a:lfromOrSections) == v:t_number 
    \ ? hp#BuildSections(a:lfromOrSections)
    \ : a:lfromOrSections
  let result = [s:CONTENTS]
  let tab_size = 4
  for section in sections
    let tab = repeat(' ', section.level * tab_size)
    let title = tab .. section.number .. ' ' .. section.name
    let dots = repeat('.', a:width - len(section.tag) - len(title))
    call add(result, title .. dots .. substitute(section.tag, '*', '|', 'g'))
  endfor

  return result
endfunction

" Moves everything befor `pos` on the line `lnum` to the left and
" other part to the right
function! hp#LeftRight(lnum, pos)
    const str = getline(a:lnum)
    if empty(str)
      return 0
    endif
    const width = &textwidth > 0 ? &textwidth : 80
    const left = trim(a:pos > 0 ? str[0:a:pos-1] : '')
    const right = trim(str[a:pos:])
    const spaces = width - len(left) - len(right)
    const new_str = left .. repeat(' ', spaces) .. right
    call setline(a:lnum, new_str)
endfunction

function! hp#UpdateNumbers(sections) abort
  for section in a:sections 
    call hp#UpdateNumber(section)
  endfor
endfunction

" Replaces a mask or number in the line of the section.
function! hp#UpdateNumber(section) abort
    if empty(a:section.number)
      return
    endif
    let line = a:section.line
    try
      execute  line .. 's/\v^\s*' .. s:NUMBER_REGEX .. '/' .. a:section.number
    catch 
      throw 'Number was not found at line ' .. line .. ":\n" .. getline(line)
            \.. "\nSection was: " .. string(a:section) .. "\nThe reason is:\n"
            \.. v:errmsg
    endtry
endfunction

" Returns { begin: <number>, end:<number>, width: <number> } or {}
function! hp#FindContents() abort
  " try to find before cursor
  " if not found, try to find after cursor
  let firstline = search(s:CONTENTS, 'nc')
  let firstline = firstline > 0 ? firstline : search(s:CONTENTS, 'n')
  if firstline <= 0
    return {}
  endif
  let end = firstline
  while end < line('$') && !IsBlank(getline(end + 1))
    let end += 1
  endwhile

  const padding = stridx(getline(firstline), s:CONTENTS)
  return { 'begin': firstline, 'end': end, 'width': len(getline(end)) - padding }
endfunction

" Returns array with sections which follow after line `lfrom`.
function! hp#BuildSections(lfrom) abort 
  let sections = []
  let i = hp#NextSectionLine(a:lfrom)
  while i > 0 && i <= line('$')
    try
      let section = s:ParseSection(i, sections)
    catch
      throw 'Exception on parsing section on the line ' .. i ..
            \ '. The reason is: ' .. v:errmsg 
    endtry
    call add(sections, section)
    let i = hp#NextSectionLine(i)
  endwhile

  return sections 
endfunction

function! s:ParseSection(lnum, sections) abort
  let str = getline(a:lnum)
  let mask = hp#ExtractSectionNumberMask(str)
  return {
        \ 'name': hp#ExtractSectionName(str),
        \ 'tag': hp#ExtractSectionTag(str),
        \ 'number': empty(mask) 
        \    ? '' 
        \    :  hp#IncrementNumber(s:PrevNum(a:sections), mask),
        \ 'line': a:lnum,
        \ 'level': s:CalcSectionLevel(mask, a:sections)
        \ }
endfunction

function! s:CalcSectionLevel(mask, sections) abort
  " let's try take a level from the mask
  let level = empty(a:mask) ? 0 : len(split(a:mask, '\.'))
  if level > 0
    return level
  "if mask is empty, taking a level is more difficult:
  " if no one previous section exeists
  elseif empty(a:sections)
    " we should begin numeration from 1
    return 1
    " if previous section is not numered too 
  elseif empty(a:sections[-1].number)
    " we can continue with level from that section
    return a:sections[-1].level
  " or should increment it
  else
    return a:sections[-1].level + 1
  endif
endfunction

"Returns the last not empty number. In case of empty sections it returns '0.'
function! s:PrevNum(sections, ...) abort 
  " index from the end of sections
  let i = a:0 > 0 ? a:1 : 1

  return i > len(a:sections) ? '0.' : 
        \ empty(a:sections[-i].number) 
        \ ? s:PrevNum(a:sections, i+1)
        \ : a:sections[-i].number
endfunction

" Returns a mask of number extracted from the section or empty string
function! hp#ExtractSectionNumberMask(str)
  let mask = matchstr(a:str, '\v^' .. s:NUMBER_REGEX)
  return empty(mask) ? '' : substitute(mask, '\d', '#', 'g')
endfunction

" Returns the name of the section or an empty string
function! hp#ExtractSectionName(str)
  " the name is a part between optional number and requered tag
  let name = matchstr(a:str, 
        \ '\v^' .. s:NUMBER_REGEX .. '?\zs.*\ze' .. s:TAG_REGEX)
  return trim(name)
endfunction

" Returns a tag of the section or an empty string
function! hp#ExtractSectionTag(str)
  " find a tag within '*' at the end of string
  let tag = matchstr(a:str, '\v' .. s:TAG_REGEX .. '\s*')
  return empty(tag) ? '' : tag
endfunction

" Increment the number by mask: >
"   hp#IncrementNumber('', '#') => throw exception
"   hp#IncrementNumber('1.', '#.') => '2.'
"   hp#IncrementNumber('1.1', '#.#') => '1.2'
"   hp#IncrementNumber('1.1', '#.') => '2.'
function! hp#IncrementNumber(number, mask) abort
  let numbers = split(a:number, '\.')
  if empty(numbers)
    throw "Wron number: " .. a:number .. 
          \". Number should contains digitals separated by '.' "
  endif

  let placeholders = split(a:mask, '\.')
  if empty(placeholders) 
    throw "Wrong mask: " .. a:number .. ". Mask should look like '#.##'"
          \.." where '#' is a placeholder for number and '.' is just separator."
  endif
  let i = len(placeholders) - 1
  if i < len(numbers)
    let numbers[i] += 1
  else
    call extend(numbers, repeat([1], len(placeholders) - len(numbers)))
  endif
  return join(numbers[:i], '.') .. '.'
endfunction

" Returns a number of the line with a title of the next section or -1.
"
" lnum - number of the first line for a search.
function! hp#NextSectionLine(lnum)
  let current = a:lnum + 1
  while current <= line('$')
    let str = getline(current)
    " section must begin from a name and a tag must follow after the name
    if (str =~ s:SECTION_REGEX)
      return current
    endif

    let current += 1
  endwhile

  return -1
endfunction

" checks if the string is blank
function! IsBlank(str)
  return  a:str =~ '^\s*$'
endfunction  
