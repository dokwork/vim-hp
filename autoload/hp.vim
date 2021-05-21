" FUNCTION: hp#NextSectionNum{{{1
" Returns a number of the line with a title of the next section or -1.
"
" lnum - number of the first line for a search.
function! hp#NextSectionNum(lnum)
  let current = a:lnum + 1
  while current <= line('$')
    if !s:IsEmpty(getline(current)) && s:FindSeparatorBefore(current) != ''
      return current
    endif
    let current += 1
  endwhile

  return -1
endfunction

" try to find a separator {{{2
function! s:FindSeparatorBefore(lnum)
  " optimization to not looking for a separator for a lot of empty strings
  let limit = max([0, a:lnum - 5]) 
  
  let current = a:lnum 
  while current > limit
    let current -= 1
    let str = getline(current)

    if s:IsEmpty(str)
      " skip empty srting
      continue
    elseif str =~ '\v^[-|=]'
      " a separator is found
      return str
    else
      " break the search because we met non empty string
      return ''
    endif
  endwhile

  return ''
endfunction

" checks if the string is empty {{{2
function! s:IsEmpty(str)
  return  a:str =~ '^\s*$'
endfunction  

" FUNCTION: hp#ExtractSectionName {{{1
"
" Returns the name of the section or an empty string
function! hp#ExtractSectionName(sline)
  return trim(matchstr(a:sline, '\v^.*\ze(\*\w+\*)'))
endfunction

" FUNCTION: hp#ExtractSectionTag {{{1
"
" Returns a tag of the section or an empty string
function! hp#ExtractSectionTag(sline)
  return matchstr(a:sline, '\v\*\zs\w+\ze\*')
endfunction

" FUNCTION hp#ExtractFoldLevel {{{1
"
" Returns a fold level extracted from the prefix
function! hp#ExtractFoldLevel(sline)
  let index = matchstr(a:sline, '\v^(\d+\.?)+')
  return len(split(index, '\.'))
endfunction

" FUNCTION: hp#GenerateHelpContent {{{1
"
" Returns an array with content's lines
function! hp#GenerateHelpContent(width)
  let names = []
  let tags = []
  let folds = []
  let i = hp#NextSectionNum(1)
  while i > 0 && i <= line('$')
    let str = getline(i)
    call add(names, hp#ExtractSectionName(str))
    call add(tags, hp#ExtractSectionTag(str))
    call add(folds, hp#ExtractFoldLevel(str))
    let i = hp#NextSectionNum(i)
  endwhile

  let result = ['CONTENT']
  let longest_tag_length = max(map(copy(tags), 'len' . '(v:val)')) + 2
  let tab_size = 4
  let i = 0
  while i < len(names)
    let tab = repeat(' ', folds[i] * tab_size)
    let section = tab . names[i]
    let dots = repeat('.', a:width - longest_tag_length - len(section))
    call add(result, section . dots . '|' . tags[i] . '|')
    let i += 1
  endwhile

  return result
endfunction

function! s:InsertContent(width)
  call append(line('.') - 1, hp#GenerateHelpContent(a:width))
endfunction

command! -nargs=1 GenerateContent call s:InsertContent(<f-args>)
