**IMPORTANT:** Always consult `:h macvim` (and `:help`) first!

Configuration settings for Vim (and hence MacVim) are set in the files "~/.vimrc" and "~/.gvimrc" (see `:h vimrc-intro`).  If these files don't already exist you simply have to create them (and make sure to save them in your home directory, i.e. "~/").

### How to change the default size of new windows ###

Snapshot 50 and later automatically restore the size of the first window opened.  However, if you always want the same number of lines and columns you can e.g add `set lines=35` and `set columns=100` to your "~/.gvimrc" file to make new windows open 35 lines high and/or 100 columns wide (see `:h 'lines'`, `:h 'columns'`).

### How to make a window fill the screen when zooming ###

This is covered in the help.  See `:h macvim-hints | /zoom`.

### Monaco 10pt is jagged even though 'antialias' is set ###

Open up Terminal and type
```
defaults write org.vim.MacVim AppleSmoothFixedFontsSizeThreshold 1
```
and restart MacVim.

Alternatively, enable the "experimental renderer" in the Advanced preferences (snapshot 51 or later).


### The keyboard layout switches on its own when I change mode ###

Add `set imd` to your "~/.vimrc" file (see `:h 'imd'` for more information).


### The toolbar does not stay hidden when restarting MacVim ###

Add `set go-=T` to "~/.gvimrc" (see `:h 'go'` for more information).


### How to use LaTeX with MacVim ###

These instructions are the bare minimum to get you started with the LaTeX-Suite ([search the vim\_mac archives](http://www.google.com/search?q=latex+site:groups.google.com/group/vim_mac) for more information):

  1. Make sure you have created a folder called `.vim` in your home directory first.  To create this folder, open up Terminal.app and type `mkdir ~/.vim` (the character before the "/" is a tilde "~", not a dash "-").
  1. Download the latest version of the Vim [LaTeX-suite](http://vim-latex.sourceforge.net) as a zip file and save it to the `~/.vim` folder.  _Hint:_ If you are using Safari, right-click the download link and choose "Download Linked File As...", press ⌘⇧G and type `~/.vim` and hit enter, and then click "Save" to save the archive in the `~/.vim` folder without having Safari extract it automatically.
  1. Extract the archive by opening Terminal.app and typing `cd ~/.vim` and then `unzip latex...` (hit Tab after typing "latex" and the rest of the archive's filename will be filled in for you).  You can delete the archive afterwards (`rm latex...`).
  1. Make sure your `~/.vimrc` file contains the two lines `filetype plugin indent on` and `let g:Tex_ViewRule_pdf = 'Preview'` (create a new `.vimrc` file if it does not already exist).
  1. Open MacVim and type `:helptags ~/.vim/doc`

_Note:_ When you start editing a new file you may have to enter `:set ft=tex` before all the plugin mappings are loaded (when you open an existing file the `filetype ...` line you added to `.vimrc` will take care of that for you).


### Using MacVim with Xcode ###

In Xcode, open Preferences and click the "File Types" tab, then expand "file -> text".  Under the "text" item there is an entry called "sourcecode"; click the second column (Preferred Editor) of this entry and choose "External Editor -> Other".  Navigate to MacVim.app in the dialog that pops up.

The "external editor" support in Xcode is very limited.  Basically all the above change does is to open source code files in MacVim.  You can also double click on build errors to open MacVim on the line where the error was reported.


### How to get MacVim to look like the screenshot ###

Add the following lines to "~/.gvimrc":
```
set go-=T
set bg=dark
if &background == "dark"
    hi normal guibg=black
    set transp=8
endif
```


### How to make Open and Save dialogs show hidden files ###

_MacVim 7.2 stable 1 and Snapshot 33 (or later) have a checkbox to show hidden files in the Open dialog box._

Open up Terminal and type
```
defaults write org.vim.MacVim AppleShowAllFiles 1
```
and restart MacVim.


### No window opens in MacVim even when I select "New Window" from the "File" menu! ###

Update to snapshot 28 or later.


### Backspace does not work ###

Update to snapshot 28 or later (or set the option 'backspace' to "indent,eol,start").