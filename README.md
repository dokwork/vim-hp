# vim-hp 
  _"Helps to write a help"_

This plugin is created to help you generate a contents of a vim's help file.

It brings two commands:

```viml
:HpGenerateContents
```
...to generate the contents of the document at the cursor;

And 

```viml
:HpRefresh
```
... to regenerate already existed contents and update numbers of sections in the
document.

|![example](example.gif)|
|----|

Read more in the doc: [vim-hp.txt](doc/vim-hp.txt)

## How to install

* With [vim-lug](https://github.com/junegunn/vim-plug/):

```viml
Plug 'dokwork/vim-hp'
```

* With [packer.nvim](https://github.com/wbthomason/packer.nvim/):

```lua
use { 'dokwork/vim-hp' }
```
