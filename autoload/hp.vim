" Returns a number of the line with a title of the next section or -1.
"
" lnum - number of the first line for search.
function! hp#NextSectionNum(lnum)

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
