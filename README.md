# vim-hp 
  _"Helps to write a help"_

This plugin is created to help you write documentation for your plugins.
The main feature is generating a contents of a vim's help file.

It brings two commands:

```viml
:HpGenerateContents
```
...to generate the contents of the document at the cursor;

and 

```viml
:HpRefresh
```
... to regenerate already existed contents and update numbers of sections in the
document.

Both commands available only for buffers with [filetype](https://vimhelp.org/filetype.txt.html#filetype) `help`.

|![example](example.gif)|
|----|

Read more in the doc: [vim-hp.txt](doc/vim-hp.txt).

## How to install

* With [vim-lug](https://github.com/junegunn/vim-plug/):

```viml
Plug 'dokwork/vim-hp'
```

* With [packer.nvim](https://github.com/wbthomason/packer.nvim/):

```lua
use { 'dokwork/vim-hp' }
```
