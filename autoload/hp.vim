let s:level_regex = '((\d|\#)+\.?)+'

" Replace levels for titles according to the {sections}
function! hp#UpdateTitles(sections) 
  for section in a:sections 
    let line =  section.line
    try
      execute  line .. 's/\v' .. s:level_regex .. '/' .. section.level
    catch 
      throw 'Level was not found at line ' .. line .. ":\n" .. getline(line)
            \.. "\nSection was " .. string(section)
    endtry
  endfor
endfunction

" Returns the line with CONTENTS
function! hp#FindContents()
  let firstline = search('CONTENTS', 'nc')
  return firstline > 0 ? firstline : search('CONTENTS', 'n')
endfunction

" Returns an array with content's lines
function! hp#GenerateHelpContent(width, ...)
  let sections = a:0 > 1 ? a:1 : hp#BuildSections()
  let result = ['CONTENTS']
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

" Returns array with sections
function! hp#BuildSections() abort 
  let sections = []
  let i = hp#NextSectionNum(hp#FindContents())
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
  let mask = matchstr(getline(a:lnum), '\v^\s*\zs' .. s:level_regex)
  return substitute(mask, '\d', '#', 'g')
endfunction

" Returns the name of the section or an empty string
function! hp#ExtractSectionName(lnum)
  let name = matchstr(getline(a:lnum), '\v^.*\ze(\*\w+\*)')
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

function! s:IsSeparator(str)
  return  a:str =~ '\v^[-|=]'
endfunction  

" checks if the string is empty
function! s:IsEmpty(str)
  return  a:str =~ '^\s*$'
endfunction  
