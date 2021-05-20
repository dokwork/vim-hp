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

" try to find a separator
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

function s:IsEmpty(str)
  return  a:str =~ '^\s*$'
endfunction  

" Returns the name of the section
function! hp#ExtractSectionName(sline)

endfunction

" Returns a tag of the section
function! hp#ExtractSectionTag(sline)

endfunction

" Returns the line of the content with '\n' on the end.
function! hp#GenerateContentLine(sname, stag, sfold)

endfunction

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
