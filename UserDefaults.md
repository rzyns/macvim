_As of snapshot 20 MacVim has a preferences panel where all the relevant user defaults can be changed. The information below is somewhat outdated. Check `:h macvim-prefs` in MacVim for more up-to-date information._

Some of the behaviour of MacVim can be changed by editing its user defaults database. Here is a quick summary of what you can change and how to do so.

To see what settings are currently in the database, start Terminal and type
```
localhost:~ user$ defaults read org.vim.MacVim
```

To change a setting, type
```
localhost:~ user$ defaults write org.vim.MacVim <setting> <value>
```
where `<setting>` is the name of the setting and `<value>` the value you want to set it to. For instance, to have new files open in the current window instead of in a new window, type
```
localhost:~ user$ defaults write org.vim.MacVim MMOpenFilesInTabs 1
```
and restart MacVim.

Finally, to remove _all_ settings, type
```
localhost:~ user$ defaults delete org.vim.MacVim
```

Here is a list of current user defaults; this list may well be out of date, check `MacVim.m` for the current list of defaults.
  * MMCellWidthMultiplier: width of a normal glyph in em units (float)
  * MMLoginShellArgument:		login shell parameter (string)
  * MMLoginShellCommand:		which shell to use to launch Vim (string)
  * MMNoFontSubstitution:		disable automatic font substitution (bool)
  * MMTabMaxWidth:			maximum width of a tab (int)
  * MMTabMinWidth:			minimum width of a tab (int)
  * MMTabOptimumWidth:		default width of a tab (int)
  * MMTextInsetBottom:		text area offset in pixels (int)
  * MMTextInsetLeft:			text area offset in pixels (int)
  * MMTextInsetRight:		text area offset in pixels (int)
  * MMTextInsetTop:			text area offset in pixels (int)
  * MMTexturedWindow:		use brushed metal window (Tiger only) (bool)
  * MMTranslateCtrlClick:		interpret ctrl-click as right-click (bool)
  * MMZoomBoth:			zoom button maximizes both directions (bool)