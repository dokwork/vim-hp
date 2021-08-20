const s:CONTENTS = '*CONTENTS*'
const s:SEPARATOR_REGEX = '[-=]'
const s:LEVEL_REGEX = '((\d|\#)+\.?)+'
const s:TAG_REGEX = '(\*\w+\*)'

function! hp#UpdateAll() abort
  let sections = hp#BuildSections()
  if empty(sections)
    throw 'No one section was found.'
  endif

  call hp#UpdateContents(sections)

  for section in sections 
    let line =  section.line
    let orig_str = getline(line)

    " fullfill separator
    let prev_str = getline(line-1)
    if s:IsSeparator(prev_str)
      let separator = prev_str[0]
      call setline(line-1, repeat(separator, &textwidth))
    endif
    
    " replace level
    call hp#UpdateLevel(section)

    " move title to the left and tag to the right
    let str = getline(line)
    let tag_idx = stridx(str, section.tag) - 1 " -1 for *
    call hp#LeftRight(line, tag_idx)
  endfor
endfunction

function! hp#UpdateContents(sections) abort

endfunction

" Returns an array with content's lines
function! hp#GenerateHelpContent(width, ...)
  let sections = a:0 > 1 ? a:1 : hp#BuildSections()
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

function! hp#LeftRight(lnum, pos)
    const str = getline(a:lnum)
    if empty(str)
      return 0
    endif
    const left = trim(a:pos > 0 ? str[0:a:pos-1] : '')
    const right = trim(str[a:pos:])
    const spaces = &textwidth - len(left) - len(right)
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
      execute  line .. 's/\v' .. s:LEVEL_REGEX .. '/' .. a:section.level
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
  const i = stridx(getline(firstline), s:CONTENTS)
  let end = firstline
  while end < line('$') && !s:IsEmpty(getline(end + 1))
    let end += 1
  endwhile

  return { 'begin': firstline, 'end': end, 'width': len(getline(end)) - i }
endfunction

" Returns array with sections
function! hp#BuildSections() abort 
  let sections = []
  let i = hp#NextSectionNum(hp#FindContents()['end'])
  while i > 0 && i <= line('$')
    let str = getline(i)
    let mask = hp#ExtractSectionLevelMask(i)
    let section = {
          \ 'name': hp#ExtractSectionName(i),
          \ 'tag': hp#ExtractSectionTag(i),
          \ 'level': empty(sections) 
          \           ? '1.' 
          \           : hp#IncrementLevel(sections[-1].level, mask),
          \ 'line': i
          \ }
    call add(sections, section)
    let i = hp#NextSectionNum(i)
  endwhile

  return sections 
endfunction

" Returns a number of the line with a title of the next section or -1.
"
" lnum - number of the first line for a search.
function! hp#NextSectionNum(lnum)
  let current = a:lnum + 1
  while current <= line('$')
    let str = getline(current)
    " section begins on the next after separator string
    if !(s:IsEmpty(str) || s:IsSeparator(str))
          \ && s:IsSeparator(getline(current - 1))
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

" Checks that line begins from one of the symbols: '-' or '='
function! s:IsSeparator(str)
  return  a:str =~ '\v^' .. s:SEPARATOR_REGEX .. '+\s*$'
endfunction  

" checks if the string is empty
function! s:IsEmpty(str)
  return  a:str =~ '^\s*$'
endfunction  
