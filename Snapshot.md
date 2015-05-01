# Important #

Snapshot builds of MacVim are based on recent (hence untested) versions of the source code and are released fairly often.  Use these if you want access to the latest features and bug fixes.  As a rule of thumb the latest snapshot can be considered stable if it was released more than a week ago.

# Download #

[Download snapshot 52](http://macvim.googlecode.com/files/MacVim-snapshot-52.tbz) (released Friday the 5th of March 2010).  This is a universal 32/64 bit binary which **requires an Intel processor and Mac OS X 10.5 or later**.

# Change log #

_Older change logs can be viewed by inspecting the various tags at the [source code repository](http://repo.or.cz/w/MacVim.git)._



## Snapshot 52 ##

Read the [announcement](http://groups.google.com/group/vim_mac/browse_thread/thread/12f46704b5dfcd53).


## Snapshot 51 ##

Read the [announcement](http://groups.google.com/group/vim_mac/browse_thread/thread/b93c6dd5183bdc5e).


## Snapshot 50 ##

Read the [announcement](http://groups.google.com/group/vim_mac/browse_thread/thread/2d58139a83d9ae62).


## Snapshot 49 ##

This release fixes a bug which caused Ctrl-@, Ctrl-h, Ctrl-o to fail.  It also includes a fix for the arrow and function key bug that only affected 10.4.


## Snapshot 48 ##

_Note: On Mac OS X 10.4 arrow and function keys are broken in this snapshot.  This bug does not affect Mac OS X 10.5._

Changes since snapshot 47:

  * ATSUI clips text to display cell to avoid "bleeding"
  * The pwd is set properly when dropping a folder on the Dock
  * Add Vimball (.vba) as a supported filetype
  * Refactored input code (e.g. can now bind to numeric keypad)
  * Improved IM support (separate keyboard layouts in normal/insert modes using the 'noimd' option, see ":h macvim-international")
  * Draw marked text inline (listed as +xim in ":ver")
  * Add user default MMUseInlineIm (use to disable above feature)
  * Update Vim source and runtime files



## Snapshot 47 ##

Changes since snapshot 45 (snapshot 46 is more or less identical to 47, except it lacks a patch for a crashing bug):

  * Markdown (Nico Weber) and reStructuredText (Travis Jeffery) are supported file types
  * The forever bouncing Dock icon bug should now really really be fixed (Kazuki Sakamoto)
  * Fixed bug when file name contained decomposed UTF8 characters
  * Quick Look should work for most/all supported filetypes now (although the preview is simple text and is not syntax highlighted)
  * Update the help file
  * 'guifontwide' is updated on Cmd-+/Cmd--
  * The titles of the next/previous tab menu items now match other apps
  * Add NetBeans support (Kazuki Sakamoto)
  * Add simple logging facility
  * Fix bug where MacVim would crash when dialog sheets were used
  * Update to latest Vim patches and runtime files


## Snapshot 45 ##

Changes since snapshot 44:

  * The toolbar is not hidden by default again (if you prefer having the toolbar hidden, then add the line "set go-=T" to your ~/.gvimrc file)
  * The ATSUI renderer honors the 'guisp' highlighting color
  * Fix the forever bouncing Dock icon bug (Kazuki Sakamoto)
  * Add the "Show Hidden Files" checkbox button to the Save dialog whenever the file browser is expanded
  * Frontend refactoring


## Snapshot 44 ##

Changes since snapshot 43:

  * The color table had many erroneous entries which have been corrected (Zvezdan Petkovic)
  * Ctrl+tab works again
  * Tab labels only show file tail by default to make them more legible (reset to default by adding "set guitablabel&" to .gvimrc)
  * The number of columns does not change on ":set go+=rT"
  * Fixed problems with view not maximizing when entering full-screen and the Dock was visible
  * Fix various problems related to having windows on a screen that got unplugged (fixes [Issue 162](https://code.google.com/p/macvim/issues/detail?id=162))
  * Latest source code version and runtime files (e.g. the Python syntax file is fixed, fixes [Issue 160](https://code.google.com/p/macvim/issues/detail?id=160))


## Snapshot 43 ##

Changes since snapshot 42:

  * Do inclusive search when opening files (Jonathon Mah)
  * Respect layout prefs when double-clicking an already open file
  * Fix two minor memory leaks
  * Ctrl-] works on German keyboard layout
  * The .viminfo file is written on Cmd-q
  * New 16x16 icons (Nico Weber)
  * Untitled window again opens on reopen event if requested in prefs
  * Fork earlier; fixes bug with 'autochdir', faster startup, "f" no longer supported in 'guioptions'
  * Some other minor bug fixes
  * Use latest runtime files and Vim patches



## Snapshot 42 ##

_Snapshot 41 and 42 are identical, except 41 is missing the iconv library and hence should not be used._

Here's the list of changes since snapshot 40:

  * The menu bar behaves better when using full-screen and switching Spaces (Nico Weber)
  * Don't switch Spaces when using "mvim" on one Space and a MacVim window is open on another Space
  * Add user default to toggle the "add tab" button on the tabline (to disable, enter `defaults org.vim.MacVim MMShowAddTabButton 0` in Terminal)
  * Avoid the "Press ENTER..." prompt when dragging and dropping
  * Faster startup (and shutdown, but you're not likely to notice that unless you are me ;-)
  * Automatic updating works again (?)
  * Possible to interrupt external commands (e.g. you can Ctrl-C during a lenghty :grep now)
  * The output from external commands is displayed "interactively" (i.e. you don't have to wait for the command to finish before any output is drawn; try `:!ls -l /usr/lib` and compare with snap 40 to see what I mean)
  * Cmd-. sends SIGINT (so that if a Vim process is stuck you should always be able to interrupt it with Cmd-. even if Ctrl-C doesn't work)
  * Fix crashing bug: e.g. with snap 40 if you go to the src/ folder of Vim and type ":grep a `*`.c" MacVim would crash
  * Toggle loading of default font with user default: MMLoadDefaultFont


## Snapshot 40 ##

Changes since snapshot 39:

  * Fix problems with Quickstart "leaking" Vim processes
  * 'imdisable' now on by default (i.e. IM is disabled by default)
  * Clipboard support in non-GUI mode (Kent Sibilev)
  * New document icons, more filetype associations (Nico Weber)
  * Add support for 'guitabtooltip' (hint: add the line "set gtl=%t gtt=%F" to your .gvimrc to make tabs display the name of the file and have the tooltip display the full path) (Jonathon Mah)
  * Look for toolbar icons in runtime path (plugins such as TVO now display toolbar icons properly)
  * Show dialog when clicking to close tab with modified buffers
  * Update documentation
  * Latest Vim source code and runtime files


## Snapshot 39 ##

Changes since snapshot 38:
  * Avoid "Stray process..." warning messages (Ben Schmidt)
  * Add Cmd-BS and Alt-BS insert mode mappings (Nico Weber)
  * Latest Vim patches and runtime files


## Snapshot 38 ##

Snapshot 37 had a problem with the "Login shell" option, so I've built a new snapshot containing a fix (by Ben Schmidt).

Changes since snapshot 37:
  * Dropping multiple files on a window no longer results in an error
  * Fix "Login shell" problems (Ben Schmidt)
  * Exit Vim process if connection becomes invalid -- this should avoid the system log filling up with error messages, but please let me know when it happens (and send me the output from Console.app)


## Snapshot 37 ##

Changes since snapshot 36:
  * Fix bug where Vim would crash when resizing a window with double-width characters
  * Add option 'macmeta' to use "alt/option" as meta key to allow bindings to <M-..> (see ":h 'macmeta')
  * Add basic support for AppleScript (Jason Foreman).  E.g. to zoom a window:
```
      tell application MacVim
          set zoomed of first window to true
      end tell
```
  * Fix various bugs relating to initial window positioning
  * Keep window is visible on ":set lines=..." and "set columns=..."
  * Inserting text from "Special Characters" palette works again
  * Remove the functionality to use a modifier key as Esc (use the PCKeyboardHack app instead, see ":h macvim-hints | /esc")
  * More help on keyboard shortcuts (":h macvim-shortcuts") and the mvim script (see ":h mvim")
  * Speed up live resize
  * Support mvim script symlinks to [m|g]ex and rmvim (see ":h mvim")
  * Tentative support for receiving input from system services (Try this: insert "2+3", select the text, then hit Cmd-Shift-8.  Result: "2+3" is replaced with "5".  Sometimes it seems you have to choose "MacVim->Services->Script Editor->Get Result of AppleScript" instead of pressing Cmd-Shift-8 for this to work.)
  * No more Vim zombie processes
  * Add "Reload"/"Ignore All" buttons to the file changed dialog
  * (Almost) Latest runtime files, and Vim patches


## Snapshot 36 ##

This snapshot fixes a problem with dropped characters that was introduced with snapshot 35.  Other changes since snapshot 35:

  * More help file updates
  * Fixed memory leak (Jonathon Mah)
  * Tool tips for truncated tab labels (Jonathon Mah)
  * Support drag and drop on tabs and on tabline (Jonathon Mah)
  * Modifier key can be used as Esc (useful for turning Caps Lock into Esc, see ":h macvim-esc")
  * Added "Find & Replace" dialog box (Cmd-f)



## Snapshot 35 ##

With this snapshot I have focused on making MacVim faster, fixing bugs, and updating the documentation.  As a result MacVim now feels snappier, flickers less, takes less time to startup from Terminal, and in some cases there are tremendous speed increases.

Here is a summary of the changes since snapshot 34:

  * Faster startup times
  * Overall faster drawing
  * Quicker response to key presses
  * Fix bug where key presses were ignored when mouse was moved simultaneously
  * Update ":h macvim" docs
  * Add mvim:// URL handler support (Nico Weber)
  * The VimLeave autocommand works with :maca (see ":h macvim-hints")
  * Multiple files opened from Finder are sorted
  * Don't shift new windows downwards if they are vertically maximized
  * Add option to hide MacVim when last window closes
  * The "Save changes" dialog conforms to the Apple HIG (works with Cmd-D)
  * Fix problems with 'fullscreen' and :mksession (Nico Weber)
  * Cmd-e copies selection to Find Pasteboard without searching
  * Fix bug with blurry text in full-screen with ATSUI (Jjgod Jiang)
  * Cmd-. can be used to interrupt Vim (and to exit insert mode)
  * Add "New Document Here" system service (Ron Olson)
  * Simplify system services menu (honors the "Open files..." pref)
  * Full-screen background color is updated immediately when 'fuopt' changes
  * Cursor no longer escapes the command line on Cmd-=/Cmd--
  * Add Input Manager support to ATSUI renderer (Kaoru Yoshida)
  * Use latest Vim source code and runtime files
  * Minor bug fixes


## Snapshot 34 ##

This snapshot is based on the recently released Vim 7.2 and it contains
some new features and bug fixes.  Here's a partial list:

  * More options on how new files should open (in tabs/splits/etc.): Open the preferences to check this out.
  * Quickstart: With this feature enabled new windows open instantaneously (but _not_ if you use the 'mvim' script).  It is disabled by default so go to the Advanced preferences to enable it (and be sure to read the "disclaimer"...note that any changes to ~/.vim or its subdirectories are automatically detected on Leopard).
  * The ATSUI renderer has received a few bug fixes and it now includes mouse support (it can be enabled in the Advanced prefs).  (bug fixes by Jjgod Jiang)
  * Some of the old toolbar icons have been resurrected.
  * The current directory is handled more consistently: New windows always have the user's home directory set as current.  Opening a file in the Finder results in the current directory being set to the directory the file is in (unless the file opened in a window with other files already open).
  * Windows opened from the Dock menu are in focus.
  * Menu item to toggle the Plug-in drawer (Matt Tolton).
  * Now possible to set 'linespace' in [g](g.md)vimrc.
  * Help file cleanup (Michael Wookey).
  * Problems with ptys on Leopard fixed (Ben Schmidt).
  * (Hopefully) no more annoying "dropping incoming DO message ..." warnings.
  * Scroll wheel (track pad) should behave better with fast machines ([Issue 100](https://code.google.com/p/macvim/issues/detail?id=100))
  * Various bug fixes...