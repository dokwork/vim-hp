# vim-hp 
  _"Helps to write a help"_

This plugin is created to help you generate a contents of the vim's help file.

This plugin expects that a section of document begins from the line-separator
followed by the section name:

```vimscript
=============================
<section name>
```

The line-separator can be a sequence of the `=` or `-` symbols.
The line with section name can have a tag at the end:

```vimscript
=============================
<section name>   *<tag name>*
```
```

A section which begins from the line-separator `=` is counted as section with level 1.
A section which begins from the line-separator `-` is counted as section with level 2.

To generate a contents under cursor use `:GenerateContents` command. This command can 
take a numeric argument to set the width of generated contents (default is 70):

[![asciicast](https://asciinema.org/a/W0lWEx7MaptV4WaQG7lWAi8vT.svg)](https://asciinema.org/a/W0lWEx7MaptV4WaQG7lWAi8vT)

**Note:** The `GenerateContents` command available only for buffers with `filetype=help`.
