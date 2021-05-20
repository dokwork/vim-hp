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
function s:FindSeparatorBefore(lnum)
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
function s:IsEmpty(str)
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

" FUNCTION: hp#GenerateContentLine {{{1
"
" Returns the line of the content with '\n' on the end.
function! hp#GenerateContentLine(sname, stag, sfold)

endfunction

" FUNCTION: hp#GenerateHelpContent {{{1
"
" Returns a string with multiline content
function! hp#GenerateHelpContent()
  let current = hp#NextSectionNum(1)
  let max = line('$')
  let titles = []
  let tags = []
  let folds = []
  while current > 0 && current <= max
    let str = getline(current)
    call add(titles, hp#ExtractSectionName(str))
    call add(tags, hp#ExtractSectionTag(str))
    call add(folds, hp#GetFoldLevel(current))
  endwhile

  return content
endfunction
