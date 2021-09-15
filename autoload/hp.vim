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
const s:LEVEL_REGEX = '((\d|\#)+\.?)+'
const s:TAG_REGEX = '(\*\k+\*)'
const s:SECTION_REGEX = '\v^\S+.*' .. s:TAG_REGEX

function! hp#UpdateAll() abort
  const contents = hp#FindContents()
  if empty(contents)
    throw 'Contents was not found. Please, generate it before updating'
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

    " replace level
    call hp#UpdateLevel(section)

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
    let fold = len(split(section.level, '\.'))
    let tab = repeat(' ', fold * tab_size)
    let title = tab .. section.level .. ' ' .. section.name
    let dots = repeat('.', a:width - len(section.tag) - len(title) - 2)
    call add(result, title .. dots .. '|' .. section.tag .. '|')
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

function! hp#UpdateLevels(sections) abort
  for section in a:sections 
    call hp#UpdateLevel(section)
  endfor
endfunction

function! hp#UpdateLevel(section) abort
    let line = a:section.line
    try
      execute  line .. 's/\v^\s*' .. s:LEVEL_REGEX .. '/' .. a:section.level
    catch 
      throw 'Level was not found at line ' .. line .. ":\n" .. getline(line)
            \.. "\nSection was " .. string(a:section) .. "\nReason is:\n"
            \.. v:errmsg
    endtry
endfunction

" Returns { begin: <number>, end:<number>, width: <number> } or {}
function! hp#FindContents()
  " try to find before cursor
  " if not found, try to find after cursor
  let firstline = search(s:CONTENTS, 'nc')
  let firstline = firstline > 0 ? firstline : search(s:CONTENTS, 'n')
  if firstline < 0
    return {}
  endif
  let end = firstline
  while end < line('$') && !s:IsEmpty(getline(end + 1))
    let end += 1
  endwhile

  const padding = stridx(getline(firstline), s:CONTENTS)
  return { 'begin': firstline, 'end': end, 'width': len(getline(end)) - padding }
endfunction

" Returns array with sections which follow after line `lfrom`.
function! hp#BuildSections(lfrom) abort 
  let sections = []
  let i = hp#NextSectionNum(a:lfrom)
  while i > 0 && i <= line('$')
    try
      let section = ParseSection(i, sections)
    catch
      throw 'Exception on parsing section on the line ' .. i 
            \ .. '. The reason is: ' .. v:errmsg
    endtry
    call add(sections, section)
    let i = hp#NextSectionNum(i)
  endwhile

  return sections 
endfunction

function! ParseSection(lnum, sections) abort
  let str = getline(a:lnum)
  let mask = hp#ExtractSectionLevelMask(a:lnum)
  return {
        \ 'name': hp#ExtractSectionName(a:lnum),
        \ 'tag': hp#ExtractSectionTag(a:lnum),
        \ 'level': empty(a:sections) 
        \           ? '1.' 
        \           : hp#IncrementLevel(a:sections[-1].level, mask),
        \ 'line': a:lnum
        \ }
endfunction

" Returns a number of the line with a title of the next section or -1.
"
" lnum - number of the first line for a search.
function! hp#NextSectionNum(lnum)
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

" Returns a mask of level extracted from the section or empty string
function! hp#ExtractSectionLevelMask(lnum)
  let mask = matchstr(getline(a:lnum), '\v^\s*\zs' .. s:LEVEL_REGEX)
  return substitute(mask, '\d', '#', 'g')
endfunction

" Returns the name of the section or an empty string
function! hp#ExtractSectionName(lnum)
  let name = matchstr(getline(a:lnum), '\v^.*\ze' .. s:TAG_REGEX)
  let level = hp#ExtractSectionLevelMask(a:lnum)
  let name = trim(name[len(level):])
  return empty(name) ? trim(getline(a:lnum)) : name
endfunction

" Returns a tag of the section or an empty string
function! hp#ExtractSectionTag(lnum)
  let Tag = { i -> matchstr(getline(i), '\v\*\zs\w+\ze\*') }
  let tag = Tag(a:lnum)
  return empty(tag) ? Tag(a:lnum + 1) : tag
endfunction

" Increment the level by mask: >
"   hp#IncrementLevel('1.1', '#.#') => '1.2'
"   hp#IncrementLevel('1.1', '#.') => '2.'
function! hp#IncrementLevel(level, mask) abort
  let levels = split(a:level, '\.')
  if empty(levels) | throw "Wrong level: " .. a:level | endif

  let masks = split(a:mask, '\.')
  let i = len(masks) - 1
  if i < 0 | throw "Wrong mask: " .. a:mask | endif

  if i < len(levels)
    let levels[i] += 1
  else
    call add(levels, 1)
  endif
  return join(levels[:i], '.') .. '.'
endfunction

" checks if the string is empty
function! s:IsEmpty(str)
  return  a:str =~ '^\s*$'
endfunction  
